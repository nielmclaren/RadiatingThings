import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;
int paletteWidth;

color[] palette;
PImage baseImage;
PGraphics inputImage, outputImage;
ShortImage shortImage;
ShortImageBlurrer blurrer, blurrer2;

int imageX;
int imageY;

boolean showInputImage;
boolean showBaseImage;
PVector lineStart;

FileNamer animationFolderNamer, fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  baseImage = loadImage("data/dronedefendersky.png");

  inputFilename = "input.png";
  PImage inputTempImage = loadImage(inputFilename);

  margin = 15;
  paletteWidth = 40;
  int currY = margin;

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 1);
  currY += 30;

  cp5.addSlider("wavelengthSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 100)
    .setNumberOfTickMarks(100 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(3);
  currY += 30;

  cp5.addSlider("wavelengthSlider2")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 100)
    .setNumberOfTickMarks(100 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(12);
  currY += 30;

  cp5.addSlider("wavelengthWeightingSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 1)
    .setNumberOfTickMarks(20 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(0.7);
  currY += 30;

  cp5.addSlider("multiplierSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 10)
    .setNumberOfTickMarks(40 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(1);
  currY += 30;

  currY += 30;

  cp5.addSlider("blurRadiusSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 100)
    .setNumberOfTickMarks(100 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(60);
  currY += 30;

  cp5.addSlider("blurRadiusSlider2")
    .setPosition(margin + paletteWidth + margin + inputTempImage.width + margin, currY)
    .setSize(240, 20)
    .setRange(0, 100)
    .setNumberOfTickMarks(100 + 1)
    .snapToTickMarks(true)
    .showTickMarks(false)
    .setValue(30);
  currY += 30;

  regeneratePalette();

  showInputImage = false;
  showBaseImage = true;

  animationFolderNamer = new FileNamer("output/anim", "/");
  fileNamer = new FileNamer("output/export", "png");

  inputImage = createGraphics(inputTempImage.width, inputTempImage.height, P2D);
  outputImage = createGraphics(inputImage.width, inputImage.height, P2D);

  shortImage = new ShortImage(inputImage.width, inputImage.height, RGB);
  blurrer = new ShortImageBlurrer(inputImage.width, inputImage.height, 60);
  blurrer2 = new ShortImageBlurrer(inputImage.width, inputImage.height, 30);

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
  inputImage.beginDraw();
  inputImage.background(0);
  inputImage.endDraw();
  updateOutputImage();
}

void updateOutputImage() {
  shortImage.drawSpecialThing();

  inputImage.beginDraw();
  inputImage.background(0);
  inputImage.image(shortImage.getImageRef(), 0, 0);
  inputImage.endDraw();

  PGraphics translatedImage = createGraphics(inputImage.width, inputImage.height, P2D);
  translatedImage.beginDraw();
  translatedImage.loadPixels();
  for (int y = 0; y < translatedImage.height; y++) {
    for (int x = 0; x < translatedImage.width; x++) {
      translatedImage.pixels[y * translatedImage.width + x] = translateValue(shortImage.getRedValue(x, y));
    }
  }
  translatedImage.updatePixels();
  translatedImage.endDraw();

  outputImage.beginDraw();
  outputImage.blendMode(BLEND);
  if (showBaseImage) {
    outputImage.image(baseImage, 0, 0);
    outputImage.blendMode(MULTIPLY);
  }
  outputImage.image(translatedImage, 0, 0);
  outputImage.endDraw();
}

void regeneratePalette() {
  int shortRange = Short.MAX_VALUE - Short.MIN_VALUE;
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  int wavelength1 = floor(cp5.getController("wavelengthSlider").getValue());
  int wavelength2 = floor(cp5.getController("wavelengthSlider2").getValue());
  float weight = cp5.getController("wavelengthWeightingSlider").getValue();
  int combinedWavelength = getCombinedWavelength(wavelength1, wavelength2);
  float multiplier = cp5.getController("multiplierSlider").getValue();
  palette = new color[shortRange];
  for (int i = 0; i < shortRange; i++) {
    float k = float(i) / shortRange;
    palette[i] = color(255. * (1 - multiplier * k * (
          weight * (cos((k * wavelength1 + offset * combinedWavelength) * 2 * PI) / 2 + 0.5)
          + (1 - weight) * (cos((k * wavelength2 + offset * combinedWavelength) * 2 * PI) / 2 + 0.5)
        )));
  }
}

int getCombinedWavelength(int w1, int w2) {
  int low = min(w1, w2);
  int high = max(w1, w2);
  int candidate = high;
  while (candidate % low != 0) {
    candidate += high;
  }
  return candidate;
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
    case 'a':
      saveAnimation();
      break;
    case 'b':
      showBaseImage = !showBaseImage;
      updateOutputImage();
      break;
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
  if (theEvent.isFrom(cp5.getController("paletteOffsetSlider"))
      || theEvent.isFrom(cp5.getController("wavelengthSlider"))
      || theEvent.isFrom(cp5.getController("wavelengthSlider2"))
      || theEvent.isFrom(cp5.getController("wavelengthWeightingSlider"))
      || theEvent.isFrom(cp5.getController("multiplierSlider"))) {
    regeneratePalette();
    updateOutputImage();
  } else if (theEvent.isFrom(cp5.getController("blurRadiusSlider"))) {
    int blur = floor(cp5.getController("blurRadiusSlider").getValue());
    blurrer = new ShortImageBlurrer(inputImage.width, inputImage.height, blur);
    updateOutputImage();
  } else if (theEvent.isFrom(cp5.getController("blurRadiusSlider2"))) {
    int blur = floor(cp5.getController("blurRadiusSlider2").getValue());
    blurrer2 = new ShortImageBlurrer(inputImage.width, inputImage.height, blur);
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

void saveAnimation() {
  FileNamer frameNamer = new FileNamer(animationFolderNamer.next() + "frame", "png");

  int wavelength1 = floor(cp5.getController("wavelengthSlider").getValue());
  int wavelength2 = floor(cp5.getController("wavelengthSlider2").getValue());
  int totalWavelength = getCombinedWavelength(wavelength1, wavelength2);
  int numFrames = 30 * totalWavelength;
  for (int i = 0; i < numFrames; i++) {
    String filename = frameNamer.next();

    cp5.getController("paletteOffsetSlider").setValue(float(i) / frameCount);
    regeneratePalette();
    updateOutputImage();

    outputImage.save(filename);
  }
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

