
class ShortImageBlurrer {
  int w;
  int h;
  int radius;

  int shortRange;
  int wm;
  int hm;
  int wh;
  int div;
  int[] r;
  int[] g;
  int[] b;
  int rsum,gsum,bsum,x,y,i,pi,pr,pg,pb,pi1,pr1,pg1,pb1,pi2,pr2,pg2,pb2,yp,yi,yw;
  int[] vmin;
  int[] vmax;
  int[] dv;

  ShortImageBlurrer(int _width, int _height, int _radius) {
    w = _width;
    h = _height;
    radius = _radius;

    shortRange = Short.MAX_VALUE - Short.MIN_VALUE;
    wm = w-1;
    hm = h-1;
    wh = w*h;
    div = radius+radius+1;
    r = new int[wh];
    g = new int[wh];
    b = new int[wh];
    vmin = new int[max(w,h)];
    vmax = new int[max(w,h)];
    dv = new int[shortRange*div];
  }

  void blur(short[] shortPixels, int n) {
    for (int i = 0; i < n; i++) {
      blur(shortPixels);
    }
  }

  /**
   * Thanks Mario!
   * @see http://incubator.quasimondo.com/processing/superfastblur.pde
   */
  void blur(short[] shortPixels) {
    if (radius < 1) return;

    colorMode(RGB);

    for (i=0;i<shortRange*div;i++){
      dv[i]=i/div;
    }

    yw=yi=0;

    for (y=0;y<h;y++){
      rsum=gsum=bsum=0;
      for(i=-radius;i<=radius;i++){
        pi=(yi+min(wm,max(i,0)))*3;
        pr=(int)shortPixels[pi+0]-Short.MIN_VALUE;
        pg=(int)shortPixels[pi+1]-Short.MIN_VALUE;
        pb=(int)shortPixels[pi+2]-Short.MIN_VALUE;
        rsum+=pr;
        gsum+=pg;
        bsum+=pb;
      }
      for (x=0;x<w;x++){
        r[yi]=dv[rsum];
        g[yi]=dv[gsum];
        b[yi]=dv[bsum];

        if(y==0){
          vmin[x]=min(x+radius+1,wm);
          vmax[x]=max(x-radius,0);
        }
        pi1=(yw+vmin[x])*3;
        pr1=shortPixels[pi1+0]-Short.MIN_VALUE;
        pg1=shortPixels[pi1+1]-Short.MIN_VALUE;
        pb1=shortPixels[pi1+2]-Short.MIN_VALUE;
        pi2=(yw+vmax[x])*3;
        pr2=shortPixels[pi2+0]-Short.MIN_VALUE;
        pg2=shortPixels[pi2+1]-Short.MIN_VALUE;
        pb2=shortPixels[pi2+2]-Short.MIN_VALUE;

        rsum+=pr1 - pr2;
        gsum+=pg1 - pg2;
        bsum+=pb1 - pb2;
        yi++;
      }
      yw+=w;
    }

    for (x=0;x<w;x++){
      rsum=gsum=bsum=0;
      yp=-radius*w;
      for(i=-radius;i<=radius;i++){
        yi=max(0,yp)+x;
        rsum+=r[yi];
        gsum+=g[yi];
        bsum+=b[yi];
        yp+=w;
      }
      yi=x;
      for (y=0;y<h;y++){
        shortPixels[yi*3+0]=(short)(Short.MIN_VALUE + dv[rsum]);
        shortPixels[yi*3+1]=(short)(Short.MIN_VALUE + dv[gsum]);
        shortPixels[yi*3+2]=(short)(Short.MIN_VALUE + dv[bsum]);

        if(x==0){
          vmin[y]=min(y+radius+1,hm)*w;
          vmax[y]=max(y-radius,0)*w;
        }
        pi1=x+vmin[y];
        pi2=x+vmax[y];

        rsum+=r[pi1]-r[pi2];
        gsum+=g[pi1]-g[pi2];
        bsum+=b[pi1]-b[pi2];

        yi+=w;
      }
    }
  }
}