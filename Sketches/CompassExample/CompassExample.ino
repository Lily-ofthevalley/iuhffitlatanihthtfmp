int dataPin = 5;   // DS (Serial Data Input)
int latchPin = 17;  // ST_CP (Latch)
int clockPin = 16;  // SH_CP (Clock)

byte circle[8] = {
  B00111100,
  B01000010,
  B10000001,
  B10000001,
  B10000001,
  B10000001,
  B01000010,
  B00111100
};

void setup() {
  pinMode(dataPin, OUTPUT);
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
}

// Shift out a byte to the 74HC595
void shiftOutByte(byte data) {
  shiftOut(dataPin, clockPin, MSBFIRST, data);
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
    matrix[i] = circle[i];
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
    digitalWrite(latchPin, LOW);
    // Select current row (active low)
    shiftOutByte(~(1 << row));
    // Send column data
    shiftOutByte(matrix[row]);
    digitalWrite(latchPin, HIGH);
    delay(1);
  }
}

void loop() {
  // Example: Rotate the line smoothly
  for (float angle = 0; angle < 2 * PI; angle += 0.1) {
    drawCompass(angle);
  }
}
