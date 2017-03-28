
FileNamer fileNamer;

void setup() {
  size(800, 800);

  fileNamer = new FileNamer("output/export", "png");
}

void draw() {
  //float targetAngle = atan2(mouseY - height/2, mouseX - width/2);
  float targetAngle = PI/4;

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
  return color(
      floor(map(radius + mouseX * (cos(2*angleDelta) + 1)/2, 0, width * 0.4, 0, 8)) * 32,
      190, 255);
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
