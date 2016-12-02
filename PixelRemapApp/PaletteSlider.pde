
public class PaletteSlider {
  private float x;
  private float y;
  private float w;
  private float h;
  private color[] palette;

  PaletteSlider(float xArg, float yArg, float wArg, float hArg) {
    x = xArg;
    y = yArg;
    w = wArg;
    h = hArg;
  }

  public void draw(PGraphics g) {
    g.noStroke();
    g.fill(32);
    g.rect(x, y, w, h);

    for (int i = 0; i < palette.length; i++) {
      g.fill(palette[i]);
      g.rect(x, y, w, h * (1 - (float) i / palette.length));
    }
  }

  public void setPalette(color[] p) {
    palette = p;
  }

  public void mousePressed() {
  }

  public void mouseDragged() {
  }

  public void mouseReleased() {
  }
}
