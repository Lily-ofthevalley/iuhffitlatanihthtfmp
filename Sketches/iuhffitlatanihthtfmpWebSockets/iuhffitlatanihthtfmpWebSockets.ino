#include <Arduino.h>
#if defined(ESP32) || defined(LIBRETINY)
#include <AsyncTCP.h>
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#elif defined(TARGET_RP2040) || defined(TARGET_RP2350) || defined(PICO_RP2040) || defined(PICO_RP2350)
#include <RPAsyncTCP.h>
#include <WiFi.h>
#endif

#include <ESPAsyncWebServer.h>
#include <KY040.h>
#include <ArduinoJson.h>


#define KNOB_CLK_PIN 21
#define KNOB_DT_PIN 19
#define COMPASS_DAT_PIN 5
#define COMPASS_LAT_PIN 17
#define COMPASS_CLK_PIN 16
static int knobValue = 0;
static float compassAngle = 0.0;
static bool compassEnabled = false;
static byte CIRCLE[8] = {
  B00111100,
  B01000010,
  B10000001,
  B10000001,
  B10000001,
  B10000001,
  B01000010,
  B00111100
};
static KY040 g_rotaryEncoder(KNOB_CLK_PIN,KNOB_DT_PIN);
static AsyncWebServer server(80);
static AsyncWebSocket ws("/ws");


// Shift out a byte to the 74HC595
void shiftOutByte(byte data) {
  shiftOut(COMPASS_DAT_PIN, COMPASS_CLK_PIN, MSBFIRST, data);
}

// Bresenham line algorithm to find LEDs between center and border
void drawLine(byte *matrix, int x0, int y0, int x1, int y1) {
  int dx = abs(x1 - x0);
  int dy = abs(y1 - y0);
  int sx = (x0 < x1) ? 1 : -1;
  int sy = (y0 < y1) ? 1 : -1;
  int err = dx - dy;

  while (true) {
    if (x0 >= 0 && x0 < 8 && y0 >= 0 && y0 < 8) {
      matrix[y0] |= (1 << x0); // Light up the LED
    }
    if (x0 == x1 && y0 == y1) break;
    int e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x0 += sx; }
    if (e2 < dx)  { err += dx; y0 += sy; }
  }
}

// Draw the compass with full line at given angle (radians)
void drawCompass(float angleRad) {
  byte matrix[8] = {0}; // Start with all LEDs off
  // Copy the circle into the matrix
  for (int i = 0; i < 8; i++) {
    matrix[i] = CIRCLE[i];
  }

  // Calculate border point
  float cx = 3.5, cy = 3.5;
  float x = cx + 3.5 * sin(angleRad);
  float y = cy - 3.5 * cos(angleRad); // Subtract because y increases downward
  int px = round(x);
  int py = round(y);
  px = constrain(px, 0, 7);
  py = constrain(py, 0, 7);

  int centerX, centerY;
  if (angleRad >= 0 && angleRad < PI/2) {
    centerX = 4; centerY = 3;
  } else if (angleRad >= PI/2 && angleRad < PI) {
    centerX = 3; centerY = 3;
  } else if (angleRad >= PI && angleRad < 3*PI/2) {
    centerX = 3; centerY = 4;
  } else {
    centerX = 4; centerY = 4;
  }

  // Draw line from center (3,3) to border (px,py)
  drawLine(matrix, centerX, centerY, px, py);

  // Update each row
  for (int row = 0; row < 8; row++) {
    digitalWrite(COMPASS_LAT_PIN, LOW);
    // Select current row (active low)
    shiftOutByte(~(1 << row));
    // Send column data
    shiftOutByte(matrix[row]);
    digitalWrite(COMPASS_LAT_PIN, HIGH);
    delay(1);
  }
}

void setup() {
  pinMode(COMPASS_DAT_PIN, OUTPUT);
  pinMode(COMPASS_LAT_PIN, OUTPUT);
  pinMode(COMPASS_CLK_PIN, OUTPUT);
  Serial.begin(115200);
  WiFi.mode(WIFI_AP);
  WiFi.softAP("SCRIPTKIDDIE", "kattenburger");


  //
  // Run in terminal: websocat ws://192.168.4.1/ws => should stream data
  //
  ws.onEvent([](AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
    (void)len;

    if (type == WS_EVT_CONNECT) {
      ws.textAll("hello");
      Serial.println("ws: new client connected");
      client->setCloseClientOnQueueFull(false);
      client->ping();

    } else if (type == WS_EVT_DISCONNECT) {
      ws.textAll("bye");
      Serial.println("ws: client disconnected");

    } else if (type == WS_EVT_ERROR) {
      Serial.println("ws error");

    } else if (type == WS_EVT_PONG) {
      Serial.println("ws: pong");

    } else if (type == WS_EVT_DATA) {
      AwsFrameInfo *info = (AwsFrameInfo *)arg;
      Serial.printf("index: %" PRIu64 ", len: %" PRIu64 ", final: %" PRIu8 ", opcode: %" PRIu8 "\n", info->index, info->len, info->final, info->opcode);
      String msg = "";
      if (info->final && info->index == 0 && info->len == len) {
        if (info->opcode == WS_TEXT) {
          data[len] = 0;
          // Serial.printf("ws text: %s\n", (char *)data);
          msg = String((char * )data);
          msg.trim();
          if (msg.startsWith("COMPASS: ") && msg.length() > 9) {
            String payload = msg.substring(9);
            JsonDocument compass;
            deserializeJson(compass, payload);
            Serial.printf("Compass:\n\tEnabled: %s\n\tAngle: %f\n\n", compass["enabled"].as<bool>() ? "true" : "false", compass["angle"].as<float>());
            compassAngle = compass["angle"].as<float>();
            compassEnabled = compass["enabled"].as<float>();
          }
        }
      }
    }
  });

  // shows how to prevent a third WS client to connect
  server.addHandler(&ws).addMiddleware([](AsyncWebServerRequest *request, ArMiddlewareNext next) {
    // ws.count() is the current count of WS clients: this one is trying to upgrade its HTTP connection
    if (ws.count() > 1) {
      // if we have 2 clients or more, prevent the next one to connect
      request->send(503, "text/plain", "Server is busy");
    } else {
      // process next middleware and at the end the handler
      next();
    }
  });

  server.addHandler(&ws);

  server.begin();
}


static uint32_t lastHeap = 0;

void loop() {
  drawCompass(compassAngle);

  uint32_t now = millis();
  switch (g_rotaryEncoder.getRotation()) {
    case KY040::CLOCKWISE:
      knobValue++;
      ws.printfAll("%i", knobValue);
      break;
    case KY040::COUNTERCLOCKWISE:
      knobValue--;
      ws.printfAll("%i", knobValue);
      break;
  }

  if (now - lastHeap >= 2000) {
    Serial.printf("Connected clients: %u / %u total\n", ws.count(), ws.getClients().size());

    // this can be called to also set a soft limit on the number of connected clients
    ws.cleanupClients(2);  // no more than 2 clients

#ifdef ESP32
    Serial.printf("Free heap: %" PRIu32 "\n", ESP.getFreeHeap());
#endif
    lastHeap = now;
  }
}
