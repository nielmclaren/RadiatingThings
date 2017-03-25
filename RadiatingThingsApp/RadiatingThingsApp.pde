import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;

int paletteIndex;
ArrayList<String> paletteFilenames;
color[] palette;
int paletteWidth;
boolean isReversedPalette;

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

  paletteIndex = 0;
  paletteFilenames = new ArrayList<String>();
  paletteFilenames.add("powerlines_palette01.png");
  paletteFilenames.add("stripe02.png");
  paletteFilenames.add("stripe01.png");
  paletteFilenames.add("flake04.png");
  paletteFilenames.add("blacktogradient.png");
  paletteFilenames.add("neon.png");
  paletteFilenames.add("flake03.png");
  paletteFilenames.add("flake02.png");
  paletteFilenames.add("stripey02.png");
  paletteFilenames.add("flake01.png");
  paletteFilenames.add("blobby.png");
  loadPalette();

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
    updateOutputImage();
    image(outputImage, imageX, imageY);
  }
}

void drawPalette(int paletteX, int paletteY, int paletteWidth, int paletteHeight) {
  noStroke();
  fill(32);
  rect(paletteX - 2, paletteY - 2, paletteWidth + 4, paletteHeight + 4);

  for (int i = 0; i < palette.length; i++) {
    fill(palette[i]);
    rect(
      paletteX, paletteY,
      paletteWidth, paletteHeight * (1 - (float) i / palette.length));
  }
}

void reset() {
  PImage inputTempImage = loadImage(inputFilename);

  inputImage.beginDraw();
  inputImage.image(inputTempImage, 0, 0);
  inputImage.endDraw();

  inputImage.loadPixels();

  shortImage.setImage(inputImage);
  blurrer.blur(shortImage.getValuesRef(), 3);
}

void updateOutputImage() {
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

void loadPalette() {
  int shortRange = Short.MAX_VALUE - Short.MIN_VALUE;
  palette = new color[shortRange];
  for (int i = 0; i < shortRange; i++) {
    palette[i] = color(255. * (cos(20 * (float(i) / shortRange) * 2 * PI) / 2 + 0.5));
  }
}

void keyReleased() {
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

    shortImage.setImage(inputImage);
    blurrer.blur(shortImage.getValuesRef(), 3);

    lineStart = null;
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
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  float value = map(v, Short.MIN_VALUE, Short.MAX_VALUE, 0, len) + offset * len;
  int index = floor(value % len);
  if (index >= len) {
    index--;
  }
  return palette[index];
}

