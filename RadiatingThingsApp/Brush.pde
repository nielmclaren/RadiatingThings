
class Brush {
  PGraphics _g;
  int _width;
  int _height;

  Brush(PGraphics g, int w, int h) {
    _g = g;
    _width = w;
    _height = h;
  }
  
  color getPixel(int x, int y) {
    y = _height - y - 1;
    return _g.pixels[y * _width + x];
  }
  
  void setPixel(int x, int y, color v) {
    y = _height - y - 1;
    _g.pixels[y * _width + x] = v;
  }

  void squareBrush(int targetX, int targetY, int brushSize, color targetColor) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _width) continue;
        // FIXME: Factor out blend mode.
        setPixel(x, y, lerpColor(getPixel(x, y), targetColor, 0.5));
      }
    }
  }

  void squareFalloffBrush(int targetX, int targetY, int brushSize, color targetColor) {
    float falloff = 0.88;

    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = abs(x - targetX);
        float dy = abs(y - targetY);

        float v = max(dx, dy) / brushSize;
        v = 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
        v = constrain(v, 0, 1);

        color c = getPixel(x, y);
        // FIXME: Factor out blend mode.
        setPixel(x, y, color(
          constrain(red(c) + red(targetColor) * v, 0, 255),
          constrain(green(c) + green(targetColor) * v, 0, 255),
          constrain(blue(c) + blue(targetColor) * v, 0, 255)));
      }
    }
  }

  void circleBrush(int targetX, int targetY, int brushSize, color targetColor) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        if (dx * dx  +  dy * dy > brushSize * brushSize) continue;
        // FIXME: Factor out blend mode.
        setPixel(x, y, lerpColor(getPixel(x, y), targetColor, 0.5));
      }
    }
  }

  void circleFalloffBrush(int targetX, int targetY, int brushSize, color targetColor) {
    float falloff = 0.88;
    int brushSizeSq = brushSize * brushSize;

    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float dSq = dx * dx + dy * dy;
        if (dSq > brushSizeSq) continue;

        float v = sqrt(dSq) / brushSize;
        v = 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
        v = constrain(v, 0, 1);

        color c = getPixel(x, y);
        // FIXME: Factor out blend mode.
        setPixel(x, y, color(
          constrain(red(c) + red(targetColor) * v, 0, 255),
          constrain(green(c) + green(targetColor) * v, 0, 255),
          constrain(blue(c) + blue(targetColor) * v, 0, 255)));
      }
    }
  }

  void voronoiBrush(int targetX, int targetY, int brushSize, color targetColor) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float v = map(dx * dx + dy * dy, 0, brushSize * brushSize, 255, 0);
        color c = g.pixels[y * _width + x];
        // FIXME: Factor out blend mode.
        setPixel(x, y, color(max(brightness(c), v)));
      }
    }
  }

  void waveBrush(int targetX, int targetY, int brushSize, int wavelength, color targetColor) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > brushSize) continue;
        
        float v = (cos(d / wavelength * (2 * PI)) + 1) / 2;
        
        color c = getPixel(x, y);
        // FIXME: Factor out blend mode.
        setPixel(x, y, color(
          constrain(red(c) + red(targetColor) * v, 0, 255),
          constrain(green(c) + green(targetColor) * v, 0, 255),
          constrain(blue(c) + blue(targetColor) * v, 0, 255)));
      }
    }
  }

  void waveFalloffBrush(int targetX, int targetY, int brushSize, int wavelength, color targetColor) {
    float falloff = 0.88;
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > brushSize) continue;
        
        float v = d / brushSize;
        v = 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
        v = constrain(v, 0, 1);
        
        v *= (cos(d / wavelength * (2 * PI)) + 1) / 2;
        
        color c = getPixel(x, y);
        // FIXME: Factor out blend mode.
        setPixel(x, y, color(
          constrain(red(c) + red(targetColor) * v, 0, 255),
          constrain(green(c) + green(targetColor) * v, 0, 255),
          constrain(blue(c) + blue(targetColor) * v, 0, 255)));
      }
    }
  }
}