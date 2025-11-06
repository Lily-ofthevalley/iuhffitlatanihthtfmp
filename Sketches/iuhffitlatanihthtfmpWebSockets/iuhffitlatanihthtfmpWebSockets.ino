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
#include <AceButton.h>
using namespace ace_button;
static const uint8_t CONTROLLER_PIN = 13;



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
String knobState = "";
String inputString = "";      // a String to hold incoming data
bool stringComplete = false;  // whether the string is complete


bool upBtnPressed = false;
bool downBtnPressed = false;
bool leftBtnPressed = false;
bool rightBtnPressed = false;
bool selectBtnPressed = false;



// Bron: https://forum.arduino.cc/t/how-to-use-acebutton-with-keyes-keyer-ad-key-5-key-ladder/1313338
// Create 5 AceButton objects, with specific names for each button.
static const uint8_t NUM_BUTTONS = 5;
static AceButton btnLeft(nullptr, 0);   // Left button (SW1)
static AceButton btnUp(nullptr, 1);     // Up button (SW2)
static AceButton btnDown(nullptr, 2);   // Down button (SW3)
static AceButton btnRight(nullptr, 3);  // Right button (SW4)
static AceButton btnSelect(nullptr, 4); // Select button (SW5)
static AceButton* const BUTTONS[NUM_BUTTONS] = {
    &btnLeft, &btnUp, &btnDown, &btnRight, &btnSelect
};

// Define specific ADC thresholds based on resolution (10-bit, 12-bit, or 14-bit)
static const uint16_t LEVELS_10BIT[] = { 0, 144, 324, 498, 734, 1023 };    // 10-bit resolution
static const uint16_t LEVELS_12BIT[] = { 0, 577, 1300, 1990, 2940, 4095 }; // 12-bit resolution
static const uint16_t LEVELS_14BIT[] = { 0, 2310, 5190, 7980, 11750, 16380 }; // 14-bit resolution

// Pointer to the button config object
LadderButtonConfig* buttonConfig = nullptr;

// Function to dynamically update levels based on resolution
void setLevelsBasedOnResolution(uint8_t resolution) {
  delete buttonConfig;  // Delete the previous buttonConfig instance if it exists

  switch (resolution) {
    case 10: // 10-bit resolution
      buttonConfig = new LadderButtonConfig(CONTROLLER_PIN, NUM_BUTTONS + 1, LEVELS_10BIT, NUM_BUTTONS, BUTTONS);
      Serial.println("Using 10-bit resolution ADC levels.");
      break;
    case 12: // 12-bit resolution
      buttonConfig = new LadderButtonConfig(CONTROLLER_PIN, NUM_BUTTONS + 1, LEVELS_12BIT, NUM_BUTTONS, BUTTONS);
      Serial.println("Using 12-bit resolution ADC levels.");
      break;
    case 14: // 14-bit resolution
      buttonConfig = new LadderButtonConfig(CONTROLLER_PIN, NUM_BUTTONS + 1, LEVELS_14BIT, NUM_BUTTONS, BUTTONS);
      Serial.println("Using 14-bit resolution ADC levels.");
      break;
    default: // Fallback to 10-bit if unknown
      buttonConfig = new LadderButtonConfig(CONTROLLER_PIN, NUM_BUTTONS + 1, LEVELS_10BIT, NUM_BUTTONS, BUTTONS);
      Serial.println("Unknown resolution, using 10-bit by default.");
      break;
  }

  // Reassign the event handler and enable features after reinitializing buttonConfig
  buttonConfig->setEventHandler(handleEvent);
  buttonConfig->setFeature(ButtonConfig::kFeatureClick);
  buttonConfig->setFeature(ButtonConfig::kFeatureDoubleClick);
  buttonConfig->setFeature(ButtonConfig::kFeatureLongPress);
  buttonConfig->setFeature(ButtonConfig::kFeatureRepeatPress);
}

// Event handler for each button press.
void handleEvent(AceButton* button, uint8_t eventType, uint8_t buttonState) {
  switch (eventType) {
    case AceButton::kEventPressed:
      switch (button->getPin()) {
        case 0:
          leftBtnPressed = true;
          break;
        case 1:
          upBtnPressed = true;
          break;
        case 2:
          downBtnPressed = true;
          break;
        case 3:
          rightBtnPressed = true;
          break;
        case 4:
          selectBtnPressed = true;
          break;
        default:
          break;
        }
      break;
    case AceButton::kEventReleased:
      switch (button->getPin()) {
        case 0:
          leftBtnPressed = false;
          break;
        case 1:
          upBtnPressed = false;
          break;
        case 2:
          downBtnPressed = false;
          break;
        case 3:
          rightBtnPressed = false;
          break;
        case 4:
          selectBtnPressed = false;
          break;
        default:
          break;
        }
      break;
  }
}


// Call checkButtons every 5ms or faster for debounce.
void checkButtons() {
  static unsigned long prev = millis();
  unsigned long now = millis();
  if (now - prev > 5) {
    buttonConfig->checkButtons();
    prev = now;
  }
}



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
void drawCompass(bool enabled, float angleRad) {
  if (!enabled) {
    digitalWrite(COMPASS_LAT_PIN, LOW);
    digitalWrite(COMPASS_LAT_PIN, HIGH);
    return;
  }
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
  pinMode(CONTROLLER_PIN, INPUT);
  pinMode(COMPASS_DAT_PIN, OUTPUT);
  pinMode(COMPASS_LAT_PIN, OUTPUT);
  pinMode(COMPASS_CLK_PIN, OUTPUT);
  inputString.reserve(200);
  Serial.begin(115200);
  while (!Serial);
  // Set ADC levels based on device resolution (example: 10-bit resolution)
  setLevelsBasedOnResolution(10); // Adjust the parameter (10, 12, 14) based on your current resolution
}

void updateRotaryEncoder() {
  switch (g_rotaryEncoder.getRotation()) {
    case KY040::CLOCKWISE:
      knobState = "clockwise";
      knobValue++;
      break;
    case KY040::COUNTERCLOCKWISE:
      knobValue--;
      knobState = "counterclockwise";
      break;
  }
}

String collectSensorData() {
  String payload = "";
  // Combine data into JSON object and serialize to string
  JsonDocument sensorData;
  sensorData["knobValue"] = knobValue;
  sensorData["buttons"]["up"] = upBtnPressed;
  sensorData["buttons"]["down"] = downBtnPressed;
  sensorData["buttons"]["left"] = leftBtnPressed;
  sensorData["buttons"]["right"] = rightBtnPressed;
  sensorData["buttons"]["select"] = selectBtnPressed;

  serializeJson(sensorData, payload);

  return payload;
}



void loop() {
  checkButtons();

  updateRotaryEncoder();

  // Check for new incoming data
  if (stringComplete) {
    inputString.trim();

    if (inputString.startsWith("GRAB")) {
      // Client is requesting new data
      Serial.println(collectSensorData());
    }
    else if (inputString.startsWith("CONFIRM")) {
      // Client confirmed receival of data.
      // upBtnPressed = false;
      // downBtnPressed = false;
      // leftBtnPressed = false;
      // rightBtnPressed = false;
      // selectBtnPressed = false;
    }
    else if (inputString.startsWith("DATA: ") && inputString.length() > 6) {
      Serial.println(collectSensorData()); // First respond with our sensor data

      String sensorData = inputString.substring(6);
      JsonDocument payload;
      deserializeJson(payload, sensorData);
      compassAngle = payload["compass"]["angle"].as<float>();
      compassEnabled = payload["compass"]["enabled"].as<float>();
    }

    // clear the string:
    inputString = "";
    stringComplete = false;
  }

  // Update compass
  drawCompass(compassEnabled, compassAngle);
}


void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString += inChar;
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}
