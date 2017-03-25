import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;
int paletteWidth;

color[] palette;
PGraphics inputImage, outputImage;
ShortImage shortImage;
ShortImageBlurrer blurrer;

int imageX;
int imageY;

boolean showInputImage;
PVector lineStart;

FileNamer fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  inputFilename = "input.png";
  PImage inputTempImage = loadImage(inputFilename);

  margin = 15;
  paletteWidth = 40;

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, margin)
    .setSize(240, 20)
    .setRange(0, 1);

  regeneratePalette();

  showInputImage = false;

  fileNamer = new FileNamer("output/export", "png");

  inputImage = createGraphics(inputTempImage.width, inputTempImage.height, P2D);
  outputImage = createGraphics(inputImage.width, inputImage.height, P2D);

  shortImage = new ShortImage(inputImage.width, inputImage.height, RGB);
  blurrer = new ShortImageBlurrer(inputImage.width, inputImage.height, 30);

  reset();
}

void draw() {
  background(0);

  imageX = margin + paletteWidth + margin;
  imageY = margin;

  drawPalette(margin, margin, paletteWidth, height - 2 * margin);

  if (showInputImage) {
    image(shortImage.getImageRef(), imageX, imageY);
  }
  else {
    image(outputImage, imageX, imageY);
  }
}

void drawPalette(int paletteX, int paletteY, int paletteWidth, int paletteHeight) {
  noStroke();
  fill(32);
  rect(paletteX - 2, paletteY - 2, paletteWidth + 4, paletteHeight + 4);

  for (int y = 0; y < paletteHeight; y++) {
    int i = floor(y * palette.length / paletteHeight);
    fill(palette[i]);
    rect(
      paletteX, paletteY,
      paletteWidth, paletteHeight * (1 - (float) i / palette.length));
  }
}

void clear() {
  inputImage.beginDraw();
  inputImage.background(0);
  inputImage.endDraw();
  updateOutputImage();
}

void reset() {
  PImage inputTempImage = loadImage(inputFilename);
  inputImage.beginDraw();
  inputImage.image(inputTempImage, 0, 0);
  inputImage.endDraw();
  updateOutputImage();
}

void updateOutputImage() {
  shortImage.setImage(inputImage);
  blurrer.blur(shortImage.getValuesRef(), 3);

  inputImage.loadPixels();

  outputImage.beginDraw();
  outputImage.loadPixels();
  for (int y = 0; y < outputImage.height; y++) {
    for (int x = 0; x < outputImage.width; x++) {
      outputImage.pixels[y * outputImage.width + x] = translateValue(shortImage.getRedValue(x, y));
    }
  }
  outputImage.updatePixels();
  outputImage.endDraw();
}

void regeneratePalette() {
  int shortRange = Short.MAX_VALUE - Short.MIN_VALUE;
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  palette = new color[shortRange];
  for (int i = 0; i < shortRange; i++) {
    float k = float(i) / shortRange;
    palette[i] = color(255. * (
          (cos((20 * k + offset) * 2 * PI) / 2 + 0.5) * 4 * k
        ));
  }
}

void keyReleased() {
  float offset;
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        adjustOffset(0.1);
        regeneratePalette();
        updateOutputImage();
        break;
      case DOWN:
        adjustOffset(-0.1);
        regeneratePalette();
        updateOutputImage();
        break;
    }
  }

  switch (key) {
    case 'c':
      clear();
      break;
    case 'e':
    case ' ':
      reset();
      break;
    case 'r':
      saveRender();
      break;
    case 't':
      showInputImage = !showInputImage;
      break;
  }
}

void mousePressed() {
  if (mouseHitTestImage()) {
    lineStart = new PVector(mouseX - imageX, mouseY - imageY);
  }
}

void mouseReleased() {
  if (lineStart != null) {
    inputImage.beginDraw();
    inputImage.stroke(255);
    inputImage.strokeWeight(10);
    inputImage.line(lineStart.x, lineStart.y, mouseX - imageX, mouseY - imageY);
    inputImage.endDraw();
    updateOutputImage();

    lineStart = null;
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(cp5.getController("paletteOffsetSlider"))) {
    regeneratePalette();
    updateOutputImage();
  }
}

void adjustOffset(float amount) {
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  offset += amount;
  while (offset < 0) {
    offset += 1;
  }
  while (offset >= 1) {
    offset -= 1;
  }
  cp5.getController("paletteOffsetSlider").setValue(offset);
}

void saveRender() {
  String filename = fileNamer.next();
  updateOutputImage();
  outputImage.save(filename);

  String rawFilename = getRawFilename(filename);
  inputImage.save(savePath(rawFilename));
}

String getRawFilename(String filename) {
  int index;

  index = filename.lastIndexOf('.');
  String pathAndBaseName = filename.substring(0, index);
  String extension = filename.substring(index);

  return pathAndBaseName + "raw" + extension;
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + inputImage.width
      && mouseY > imageY && mouseY < imageY + inputImage.height;
}

color translateValue(short v) {
  int len = palette.length;
  float value = map(v, Short.MIN_VALUE, Short.MAX_VALUE, 0, len);
  int index = floor(value % len);
  if (index >= len) {
    index--;
  }
  return palette[index];
}

