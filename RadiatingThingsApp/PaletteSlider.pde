
public class PaletteSlider {
  private float _x;
  private float _y;
  private float _w;
  private float _h;

  private color[] _palette;

  private float _low;
  private float _high;
  private boolean _isDragging;
  private boolean _isDraggingLow;

  PaletteSlider(float xArg, float yArg, float wArg, float hArg) {
    _x = xArg;
    _y = yArg;
    _w = wArg;
    _h = hArg;

    _low = 0;
    _high = 1;
    _isDragging = false;
    _isDraggingLow = false;
  }

  public float getLow() {
    return _low;
  }
  public float getHigh() {
    return _high;
  }

  public void draw(PGraphics g) {
    g.noStroke();
    g.fill(32);
    g.rect(_x, _y, _w, _h);

    drawPalette(g);
    drawFades(g);
    drawBorder(g);
  }

  private void drawPalette(PGraphics g) {
    for (int i = 0; i < _palette.length; i++) {
      g.fill(_palette[_palette.length - i - 1]);
      g.rect(_x, _y, _w, _h * (1 - (float) i / _palette.length));
    }
  }

  private void drawFades(PGraphics g) {
    float lowHeight = fractionToLocal(_low);
    float highHeight = fractionToLocal(1 - _high);

    g.noStroke();
    g.fill(0, 128);
    g.rect(_x, _y, _w, lowHeight);

    g.noStroke();
    g.fill(0, 128);
    g.rect(_x, _y + _h - highHeight, _w, highHeight);
  }

  private void drawBorder(PGraphics g) {
    if (_isDragging) {
      g.stroke(128);
    }
    else {
      g.stroke(255);
    }
    g.noFill();
    g.rect(_x, _y, _w, _h);
  }

  public void setPalette(color[] p) {
    _palette = p;
  }

  public void mousePressed() {
    if (hitTest(mouseX, mouseY)) {
      _isDragging = true;

      float deltaLow = abs(_low - globalToFraction(mouseY));
      float deltaHigh = abs(_high - globalToFraction(mouseY));
      _isDraggingLow = deltaLow < deltaHigh;

      handleDrag();
    }
  }

  public void mouseDragged() {
    if (_isDragging) {
      handleDrag();
    }
  }

  public void mouseReleased() {
    if (hitTest(mouseX, mouseY)) {
      handleDrag();
    }

    _isDragging = false;
  }

  private void handleDrag() {
    if (_isDraggingLow) {
      _low = constrain(globalToFraction(mouseY), 0, 1);
    }
    else {
      _high = constrain(globalToFraction(mouseY), 0, 1);
    }
  }

  private boolean hitTest(float x, float y) {
    return _x < x && x < _x + _w && _y < y && y < _y + _h;
  }

  private float globalToFraction(float globalY) {
    return (globalY - _y) / _h;
  }

  private float fractionToLocal(float fractionY) {
    return fractionY * _h;
  }
}