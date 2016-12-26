
class FloatGrayscaleBrush {
  FloatGrayscaleImage _image;
  int _width;
  int _height;

  FloatGrayscaleBrush(FloatGrayscaleImage image, int w, int h) {
    _image = image;
    _width = w;
    _height = h;
  }
  
  color getPixel(int x, int y) {
    return _image.getPixel(x, y);
  }
  
  void setPixel(int x, int y, color v) {
    _image.setPixel(x, y, v);
  }

  void squareBrush(int targetX, int targetY, int brushSize, float targetValue) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _width) continue;
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * targetValue);
      }
    }
  }

  void squareFalloffBrush(int targetX, int targetY, int brushSize, float targetValue) {
    float falloff = 0.88;

    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = abs(x - targetX);
        float dy = abs(y - targetY);

        float factor = max(dx, dy) / brushSize;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * targetValue, 0, 255));
      }
    }
  }
  
  void circleBrush(int targetX, int targetY, int brushSize, float targetValue) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        if (dx * dx  +  dy * dy > brushSize * brushSize) continue;
        // FIXME: Factor out blend mode.
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * targetValue);
      }
    }
  }

  void circleFalloffBrush(int targetX, int targetY, int brushSize, float targetValue) {
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

        float factor = sqrt(dSq) / brushSize;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * targetValue, 0, 255));
      }
    }
  }

  void voronoiBrush(int targetX, int targetY, int brushSize, float targetValue) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float v = constrain(map(dx * dx + dy * dy, 0, brushSize * brushSize, targetValue, 0), 0, 255);
        
        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, max(currentValue, v));
      }
    }
  }

  void waveBrush(int targetX, int targetY, int brushSize, int wavelength, float targetValue) {
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > brushSize) continue;
        
        float factor = (cos(d / wavelength * (2 * PI)) + 1) / 2;
        
        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * targetValue, 0, 255));
      }
    }
  }

  void waveFalloffBrush(int targetX, int targetY, int brushSize, int wavelength, float targetValue) {
    float falloff = 0.88;
    for (int x = targetX - brushSize; x <= targetX + brushSize; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - brushSize; y <= targetY + brushSize; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > brushSize) continue;
        
        float factor = d / brushSize;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);
        
        factor *= (cos(d / wavelength * (2 * PI)) + 1) / 2;
        
        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * targetValue, 0, 255));
      }
    }
  }
}