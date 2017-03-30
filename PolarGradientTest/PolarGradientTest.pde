
float targetAngle;
FileNamer fileNamer;

void setup() {
  size(800, 800);

  targetAngle = -PI/4;
  fileNamer = new FileNamer("output/export", "png");
}

void draw() {
  colorMode(HSB);

  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float dx = x - width/2;
      float dy = y - height/2;
      float d = sqrt(dx * dx + dy * dy);
      pixels[y * width + x] = getPixel(d, getAngleDelta(targetAngle, atan2(y - height/2, x - width/2)));
    }
  }
  updatePixels();
}

color getPixel(float radius, float angleDelta) {
  float k = 1
    * map(cos(angleDelta), -1, 1, 7, 1)
    * map(cos(7 * angleDelta), -1, 1, 1.3, 1)
    * map(cos(13 * angleDelta), -1, 1, 1.2, 1);
  return color(map(radius * k, 0, 2 * width, 0, 255));
}

float getAngleDelta(float from, float to) {
  float delta = abs(to - from);
  if (delta > PI) {
    return 2 * PI - delta;
  }
  return delta;
}

void keyReleased() {
  switch (key) {
    case 'r':
      save(fileNamer.next());
      break;
  }
}

void mouseReleased() {
  float dx = mouseX - width/2;
  float dy = mouseY - height/2;
  float d = sqrt(dx * dx + dy * dy);
  float angleDelta = getAngleDelta(targetAngle, atan2(mouseY - height/2, mouseX - width/2));
  println(deg(angleDelta), cos(angleDelta));
}

int deg(float radians) {
  return floor(radians * 180/PI);
}
