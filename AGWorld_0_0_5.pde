

boolean[] keys = new boolean [255];
color blue = color(0, 0, 255);                                                                               //задание цветовых констант
color red = color(255, 0, 0);
color green = color(0, 255, 0);
color tree = #134304;
color white = color(255, 255, 255);
color brown = #9B510B;
color black = color(0, 0, 0);
color gray = color(185, 176, 176);
color yellow = #EDFF03;
color hud1 = #2D0E4D;
color purple = #CB44E0;
color sky = #99AAE3;
PFont fontText;


AGGame game;
Database d;
MenuBar mainMenu;
Runtime rt = Runtime.getRuntime();
PImage wall, container, bonfire, spr_roof, floor0, floor1, floor2, floor3, actor, door_open, door, floor4, tree1, tree2, portal, trace;
void setup() {
  size(1090, 720, JAVA2D);
  surface.setResizable(true);
  surface.setIcon(loadImage("icon64.png"));
  surface.setTitle("Xenofrenia");
  Interactive.make(this);
  d = new Database();
  mainMenu= new MenuBar(this);
  floor0 = loadImage("floor0.png");
  floor1 = loadImage("floor1.png");
  floor2 = loadImage("floor2.png");
  floor3 = loadImage("floor3.png");
  floor4 = loadImage("floor4.png");
  wall = loadImage("wall.png");
  portal = loadImage("portal.png");
  tree1 = loadImage("tree1.png");
  tree2 = loadImage("tree2.png");
  door_open = loadImage("door_open.png");
  door = loadImage("door_close.png");
  bonfire = loadImage("bonfire.png");
  spr_roof = loadImage("roof.png");
  container = loadImage("container.png");
  actor = loadImage("actor.png");
  trace = loadImage("trace.png");
  createInterface();
  createActions();
  game = new AGGame(1, 33, 20, 14, 32);  //
  game.generateRooms();
  game.setSession(game.global_room[2][2], new AGPlayer(1, "виктор", 100, 2, 
    new int [] {d.getItemRandom().getInt("id"), d.getItemRandom().getInt("id"), d.getItemRandom().getInt("id"), 31, 160, 51, 51, 51, 51, 51, 51, 51, 51
  , 51, 51, 51, 51}));
  textSize(16);
  fontText = createFont("Arial", 18);
  textFont(fontText);
}


void draw() {
  pushMatrix(); 
  game.tick();
  game.display();
  popMatrix();
  updateInterface();
  mainMenu.update();
}
void keyReleased() {
  keys[keyCode]=false;
}
void keyPressed() {
  if (game.player.hp>0) {
    if (keyCode==32) {
      game.player.keyEvent(9);
    }
    if (!keys[keyCode])
      keys[keyCode]=true;
    if (keys[65]) //влево
      game.player.keyEvent(2);
    else if (keys[68]) //вправо
      game.player.keyEvent(0);
    else if (keys[83]) //вверх
      game.player.keyEvent(1);
    else if (keys[87]) //вниз
      game.player.keyEvent(3);
    else if (keys[90]) 
      game.player.keyEvent(4);
    else if (keys[67]) 
      game.player.keyEvent(6);
    else if (keys[81]) 
      game.player.keyEvent(5);
    else  if (keys[69]) 
      game.player.keyEvent(7);
  }
}
