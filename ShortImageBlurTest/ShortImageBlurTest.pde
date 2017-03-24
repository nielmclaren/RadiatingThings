import controlP5.*;

PImage inputImage;
ShortImage shortImage;
ShortImageBlurrer blurrer;

FileNamer fileNamer;

void setup() {
  size(1024, 512, P2D);

  inputImage = loadImage("lenna.png");
  shortImage = new ShortImage(inputImage.width, inputImage.height, RGB);
  shortImage.setImage(inputImage);
  blurrer = new ShortImageBlurrer(inputImage.width, inputImage.height, 10);
  blurrer.blur(shortImage.getValuesRef());

  fileNamer = new FileNamer("output/export", "png");
}

void draw() {
  image(inputImage, 0, 0);
  image(shortImage.getImageRef(), inputImage.width, 0);
}

void keyReleased() {
  switch (key) {
    case 'r':
      save(fileNamer.next());
      break;
  }
}
