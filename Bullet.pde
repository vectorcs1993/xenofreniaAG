class Bullet extends PVector {
  PVector vel;
  float size, speed;
  int x0, y0, x1, y1;
  PImage sprite;
  Bullet(PVector loc, int x1, int y1, PImage sprite) {
    super(loc.x, loc.y);
    speed = 1;
    PVector vel = new PVector(x1, y1).sub(new PVector(loc.x, loc.y));
    this.vel = vel.copy().normalize();
    this.vel.mult(speed);
    size = 5;
    x0=int(loc.x);
    y0=int(loc.y);
    this.x1=x1;
    this.y1=y1;
    this.sprite=sprite;
  }
  boolean isTarget() {
    int dx, dy;
    if (x0<x1)
      dx = x1-x0;
    else if (x0>x1)
      dx=x0-x1;
    else 
    dx=0;
    if (y0<y1)
      dy = y1-y0;
    else if (y0>y1)
      dy = y0-y1;
    else 
    dy=0;
    if (x0<x1 && y0<y1)
      return int(x)>=x0+dx && int(y)>=y0+dy;
    else if (x0>x1 && y0>y1)
      return int(x)<=x0-dx && int(y)<=y0-dy;
    else if (x0>x1 && y0<y1)
      return int(x)<=x0-dx && int(y)>=y0+dy;
    if (x0<x1 && y0>y1)
      return int(x)>=x0+dx && int(y)<=y0-dy;
    else if (x0<x1 && y0==y1)
      return int(x)>=x0+dx;
    else if (x0>x1 && y0==y1)
      return int(x)<=x0-dx;
    else if (x0==x1 && y0>y1)
      return int(y)<=y0-dy;
    else if (x0==x1 && y0<y1)
      return int(y)>=y0+dy;
    else return true;
  }
  void update() {
    add(vel);
    display();
  }
  void remove() {
    vel=null;
  }
  void display() {
    if (sprite==null) {
    fill(yellow);
    ellipse((x-game.posX)*game.size_grid+game.size_grid/2, (y-game.posY)*game.size_grid+game.size_grid/2, 5, 5);
    } else
    image(sprite, (x-game.posX)*game.size_grid+game.size_grid/2, (y-game.posY)*game.size_grid+game.size_grid/2);
  }
}
