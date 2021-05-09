import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.utils.*;



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
//color hud1 = #2D0E4D;
color hud1 =#433737;
color purple = #CB44E0;
color sky = #99AAE3;
PFont fontText;

UiBooster dialog;
WaitingDialog wait;
AGGame game;
AGData d;
MenuBar mainMenu;
Runtime rt = Runtime.getRuntime();

void setup() {
  size(1090, 720, JAVA2D);
background(hud1);
  surface.setResizable(true);
  surface.setIcon(loadImage("icon64.png"));
  surface.setTitle("Xenofrenia");
  Interactive.make(this);
  dialog = new UiBooster();
  wait = dialog.showWaitingDialog("loader", "Загрузка...");
  wait.addToLargeMessage("Создание базы данных ...");
  d = new AGData();
  createInterface();
  createActions();
  game = new AGGame(1, 33, 20, 14, 32);  //
  wait.addToLargeMessage("Создание мира...");
  game.generateRooms();
  wait.addToLargeMessage("Создание персонажа");
  game.setSession(game.global_room[2][2], new AGPlayer(1, d.player.getString("name"), 100, 2, 
    d.player.getJSONArray("items").getIntArray()));
  wait.close();
  mainMenu= new MenuBar(this);
  textSize(16);
  fontText = createFont("Arial", 14);
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
