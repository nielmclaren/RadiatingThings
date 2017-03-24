import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;

int paletteIndex;
ArrayList<String> paletteFilenames;
color[] palette;
PaletteSlider paletteSlider;
int paletteWidth;
int paletteRepeatCount;
boolean isMirroredPaletteRepeat;
boolean isReversedPalette;

PGraphics inputImg, outputImg;
FloatGrayscaleImage deepImage;

int imageX;
int imageY;

boolean showInputImg;
PVector lineStart;

FileNamer fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  inputFilename = "input.png";
  PImage inputTempImg = loadImage(inputFilename);

  margin = 15;
  paletteWidth = 40;

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImg.width + margin, margin)
    .setSize(240, 20)
    .setRange(0, 1);

  paletteSlider = new PaletteSlider(margin, margin, paletteWidth, height - 2 * margin);

  paletteRepeatCount = 1;
  cp5.addSlider("paletteRepeatSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImg.width + margin, margin + 30)
    .setSize(240, 20)
    .setRange(1, 50)
    .setValue(1)
    .setNumberOfTickMarks(50)
    .snapToTickMarks(true)
    .showTickMarks(false);

  isMirroredPaletteRepeat = true;
  isReversedPalette = false;

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
  reloadPalette();

  showInputImg = false;

  fileNamer = new FileNamer("output/export", "png");

  inputImg = createGraphics(inputTempImg.width, inputTempImg.height, P2D);
  outputImg = createGraphics(inputImg.width, inputImg.height, P2D);

  deepImage = new FloatGrayscaleImage(inputImg.width, inputImg.height);

  reset();
}

void draw() {
  updatePaletteRepeatCount();

  background(0);

  imageX = margin + paletteWidth + margin;
  imageY = margin;

  if (showInputImg) {
    PImage inputImage = deepImage.getImageRef();
    image(inputImage, imageX, imageY);
  }
  else {
    updateOutputImg();
    image(outputImg, imageX, imageY);
  }

  paletteSlider.draw(g);
}

void drawPalette(int paletteX, int paletteY, int paletteWidth, int paletteHeight) {
  noStroke();
  fill(32);
  rect(paletteX, paletteY, paletteWidth, paletteHeight);

  for (int i = 0; i < palette.length; i++) {
    fill(palette[i]);
    rect(
      paletteX, paletteY,
      paletteWidth, paletteHeight * (1 - (float) i / palette.length));
  }
}

void reset() {
  PImage inputTempImg = loadImage(inputFilename);

  inputImg.beginDraw();
  inputImg.image(inputTempImg, 0, 0);
  inputImg.endDraw();

  inputImg.loadPixels();

  deepImage.setImage(inputImg);
}

void updateOutputImg() {
  outputImg.loadPixels();
  for (int y = 0; y < outputImg.height; y++) {
    for (int x = 0; x < outputImg.width; x++) {
      outputImg.pixels[(outputImg.height - y - 1) * outputImg.width + x] = translateValue(deepImage.getValue(x, y));
    }
  }
  outputImg.updatePixels();
}

void loadNextPalette() {
  paletteIndex = (paletteIndex + 1) % paletteFilenames.size();
  reloadPalette();
}

void updatePaletteRepeatCount() {
  int sliderValue = max(1, floor(cp5.getController("paletteRepeatSlider").getValue()));
  if (sliderValue != paletteRepeatCount) {
    paletteRepeatCount = sliderValue;
    reloadPalette();
  }
}

void resetPaletteRepeatCount() {
  cp5.getController("paletteRepeatSlider").setValue(1);
}

void reloadPalette() {
  String paletteFilename = paletteFilenames.get(paletteIndex);
  loadPalette(paletteFilename);
}

void loadPalette(String paletteFilename) {
  println(paletteFilename + " " + paletteRepeatCount);
  PImage paletteImg = loadImage(paletteFilename);
  palette = new color[paletteImg.width * paletteRepeatCount];
  paletteImg.loadPixels();
  for (int repeat = 0; repeat < paletteRepeatCount; repeat++) {
    for (int i = 0; i < paletteImg.width; i++) {
      int index = i;
      if (isReversedPalette) {
        index = paletteImg.width - index - 1;
      }
      if (isMirroredPaletteRepeat && repeat % 2 == 0) {
        index = (repeat + 1) * paletteImg.width - index - 1;
      }
      else {
        index = repeat * paletteImg.width + index;
      }
      palette[index] = paletteImg.pixels[i];
    }
  }
  paletteSlider.setPalette(palette);
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
    case 'm':
      isMirroredPaletteRepeat = !isMirroredPaletteRepeat;
      reloadPalette();
      break;
    case 'p':
      resetPaletteRepeatCount();
      loadNextPalette();
      break;
    case 'r':
      save(fileNamer.next());
      break;
    case 't':
      showInputImg = !showInputImg;
      break;
    case 'v':
      isReversedPalette = !isReversedPalette;
      reloadPalette();
      break;
  }
}

void mousePressed() {
  paletteSlider.mousePressed();

  if (mouseHitTestImage()) {
    lineStart = new PVector(mouseX - imageX, mouseY - imageY);
  }
}

void mouseDragged() {
  paletteSlider.mouseDragged();
}

void mouseReleased() {
  paletteSlider.mouseReleased();

  if (lineStart != null) {
    inputImg.beginDraw();
    inputImg.stroke(255);
    inputImg.strokeWeight(2);
    inputImg.line(lineStart.x, lineStart.y, mouseX - imageX, mouseY - imageY);
    inputImg.endDraw();

    deepImage.setImage(inputImg);
    lineStart = null;
  }
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + inputImg.width
      && mouseY > imageY && mouseY < imageY + inputImg.height;
}

color translateValue(float v) {
  int len = palette.length;
  float paletteLow = len * paletteSlider.getLow();
  float paletteHigh = len * paletteSlider.getHigh();
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  float value = map(v, 0, 256, paletteLow, paletteHigh) + offset * len;
  int index = floor(value % len);
  if (index >= len) {
    index--;
  }
  return palette[index];
}

