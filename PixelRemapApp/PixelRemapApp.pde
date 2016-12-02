
int margin;

int nextPaletteIndex;
ArrayList<String> paletteFilenames;
color[] palette;
PaletteSlider paletteSlider;
int paletteWidth;
PGraphics inputImg, outputImg;

Brush brush;
int brushSize;
color brushColor;
int brushStep;
int prevStepX;
int prevStepY;

int imageX;
int imageY;

boolean showInputImg;

FileNamer fileNamer;

void setup() {
  size(1024, 768, P2D);
  smooth();

  margin = 15;

  paletteWidth = 40;
  paletteSlider = new PaletteSlider(margin, margin, paletteWidth, height - 2 * margin);

  nextPaletteIndex = 0;
  paletteFilenames = new ArrayList<String>();
  paletteFilenames.add("flake01.png");
  paletteFilenames.add("blobby.png");
  paletteFilenames.add("stripey.png");
  loadNextPalette();

  showInputImg = false;

  fileNamer = new FileNamer("output/export", "png");

  PImage inputTempImg = loadImage("input.png");

  inputImg = createGraphics(inputTempImg.width, inputTempImg.height, P2D);
  outputImg = createGraphics(inputImg.width, inputImg.height, P2D);

  brushColor = color(128);
  brushStep = 15;
  brushSize = 70;
  brush = new Brush(inputImg, inputImg.width, inputImg.height);

  reset();
}

void draw() {
  background(0);

  imageX = margin + paletteWidth + margin;
  imageY = margin;

  if (showInputImg) {
    inputImg.updatePixels();
    image(inputImg, imageX, imageY);
  }
  else {
    updateOutputImg();
    outputImg.updatePixels();
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
  PImage inputTempImg = loadImage("input.png");

  inputImg.beginDraw();
  inputImg.image(inputTempImg, 0, 0);
  inputImg.endDraw();

  inputImg.loadPixels();
}

void toggleInputOutput() {
  showInputImg = !showInputImg;
}

void updateOutputImg() {
  outputImg.loadPixels();
  for (int i = 0; i < outputImg.width * outputImg.height; i++) {
    outputImg.pixels[i] = translatePixel(inputImg.pixels[i]);
  }
}

void loadNextPalette() {
  String paletteFilename = paletteFilenames.get(nextPaletteIndex);
  nextPaletteIndex = (nextPaletteIndex + 1) % paletteFilenames.size();

  PImage paletteImg = loadImage(paletteFilename);
  palette = new color[paletteImg.width];
  paletteImg.loadPixels();
  for (int i = 0; i < paletteImg.width; i++) {
    palette[i] = paletteImg.pixels[i];
  }
  paletteSlider.setPalette(palette);
}

void keyReleased() {
  switch (key) {
    case 'e':
    case ' ':
      reset();
      break;
    case 'c':
      clear();
      break;
    case 'p':
      loadNextPalette();
      break;
    case 't':
      toggleInputOutput();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}

void mouseReleased() {
  if (mouseHitTestImage()) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    stepped(mouseX - imageX, mouseY - imageY);
  }
}

void mouseDragged() {
  if (mouseHitTestImage() && stepCheck(mouseX, mouseY)) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    stepped(mouseX - imageX, mouseY - imageY);
  }
}

void drawBrush(int x, int y) {
  //brush.squareBrush(x, y, brushSize, brushColor);
  //brush.squareFalloffBrush(x, y, brushSize, brushColor);
  //brush.circleBrush(x, y, brushSize, brushColor);
  brush.circleFalloffBrush(x, y, brushSize, brushColor);
  //brush.voronoiBrush(x, y, brushSize, brushColor);
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + inputImg.width
      && mouseY > imageY && mouseY < imageY + inputImg.height;
}

boolean stepCheck(int x, int y) {
  float dx = x - prevStepX;
  float dy = y - prevStepY;
  return brushStep * brushStep < dx * dx  +  dy * dy;
}

void stepped(int x, int y) {
  prevStepX = x;
  prevStepY = y;
}

color translatePixel(color c) {
  float b = brightness(c);
  return palette[floor(map(b, 0, 255, 0, palette.length - 1))];
}

float randf(float low, float high) {
  return low + random(1) * (high - low);
}

int randi(int low, int high) {
  return low + floor(random(1) * (high - low));
}
