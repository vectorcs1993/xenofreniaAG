import controlP5.*;
import de.bezier.guido.*;
import java.util.HashSet;

ControlP5 interfaces;
Textarea console;
Listbox mainList, secondList;
RadioButton menuActions, menuPlayer;
SimpleButton drawMap;

void createInterface() {
  Interactive.make(this);
  interfaces = new ControlP5(this);
  console = interfaces.addTextarea("console")
    .setPosition(1, 15*32+5)
    .setSize(20*32, 192)
    .setFont(createFont("arial", 16))
    .setLineHeight(18)
    .setColor(white)
    .setBorderColor(white)
    .setColorBackground(hud1)
    .setScrollForeground(white)
    .setScrollBackground(blue);

  mainList=new Listbox(645, 289, 220, 384);
  secondList=new Listbox(868, 289, 220, 384);
  menuPlayer = new RadioButton (645, 1, 444, 29, RadioButton.HORIZONTAL);  //главное меню
  menuPlayer.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("персонаж", "person"), new SimpleRadioButton("потребности", "need_person"), 
    new SimpleRadioButton("местность", "map"), new SimpleRadioButton("мир", "global_map")});
  menuActions = new RadioButton (645, 257, 444, 29, RadioButton.HORIZONTAL);  //меню действий
  menuActions.addButtons(new SimpleRadioButton [] {new SimpleRadioButton("окружение", "enviroment", new Runnable() {
      public void run() {
        clearAllLists();
  if (game!=null)
  game.player.updateNeighbor();
}
}), 
  new SimpleRadioButton("вещи", "inventory", new Runnable() {
  public void run() {
    clearAllLists();
    loadMainListInventory(game.player);
  }
}
), 
  new SimpleRadioButton("экипировка", "speed3", new Runnable() {
  public void run() {
    clearAllLists();
    loadMainListEquip(game.player);
  }
}
), 
  new SimpleRadioButton("постройки", "build", new Runnable() {
  public void run() {
    clearAllLists();
    loadMainListEquip(game.player);
  }
}
)});

drawMap = new SimpleButton(870, 60, 128, 32, "отрисовать", new Runnable() {
  public void run() {
    game.global_map = game.createGlobalMap();
  }
}
);

}



void updateInterface() {
  menuActions.control();
}

void clearAllLists() {
  mainList.items.clear();
  mainList.select=null;
  secondList.items.clear(); 
  secondList.select=null;
  mainList.resetScroll();
  secondList.resetScroll();
}

void loadMainListObjects(AGObjects objects) {
  clearAllLists();

  for (AGObject part : objects) {
    if (part!=null) {
      String name;
      if (part instanceof AGItem) {
        AGItem item = (AGItem)part; 
        if (item.count>1)
          name = part.getName()+" ("+item.count+")";
        else
          name = part.getName();
      } else if (part instanceof AGEntity) {
        AGEntity entity = (AGEntity)part; 
        if (entity.hp>0)
          name = part.getName();
        else
          name = part.getName()+" (труп)";
      } else
        name = part.getName();

      mainList.items.add(new ListElement(part.id, name, part.sprite, white, false, new Runnable() {
        public void run() {
          loadSecondListObjectActions(mainList.select.getObject());
        }
      }
      ));
      mainList.resizeSlider();
    }
  }
}
void loadMainListInventory(AGHuman human) {
  clearAllLists();
  for (int part : human.items.sortId()) {
    String name = d.getItem(part).getString("name");
    if (human.items.getCount(part)>1)
      name +=" ("+human.items.getCount(part)+")";
    mainList.items.add(new ListElement(part, name, d.getItemSprite(part), white, false, new Runnable() {
      public void run() {
        loadSecondListItemActions(game.player, mainList.select.id);
      }
    }
    ));
    mainList.resizeSlider();
  }
}
void loadMainListEquip(AGHuman human) {
  clearAllLists();
  for (int part : human.parts.keySet()) {
    String name;
    PImage sprite = null;
    int item = human.parts.get(part);
    if (item!=-1) {
      name=d.getItem(item).getString("name");
      sprite = d.getItemSprite(item);
    } else 
    name = d.getNameEquip(part);
    mainList.items.add(new ListElement(part, name, sprite, white, false, new Runnable() {
      public void run() {
        loadSecondListWearActions(game.player, mainList.select.id);
      }
    }
    ));
    mainList.resizeSlider();
  }
}


void loadSecondListObjectActions(AGObject object) {
  secondList.items.clear(); 
  Actions actions = object.getActions();
  if (object instanceof AGContainer) {
    if (game.player.items.size()>0) 
      actions.add(putAllItemsFromContainer);
    for (int item : game.player.items.sortId()) {
      actions.add(new AGAction (item, "положить "+d.getItem(item).getString("name"), d.getItemSprite(item), putItemForItems));
      if (game.player.items.getCount(item)>1) 
        actions.add(new AGAction (item, "положить "+d.getItem(item).getString("name")+" x"+game.player.items.getCount(item), d.getItemSprite(item), putAllItemForItems));
    }
  } else if (object instanceof AGEntity) {
    if (((AGEntity)object).hp>0)
      for (int item : game.player.items.sortId()) {
        String count = "";
        if (game.player.items.getCount(item)>1)
          count=str(game.player.items.getCount(item));
        actions.add(new AGAction (item, "кинуть "+d.getItem(item).getString("name")+" "+count, d.getItemSprite(item), throwItemForEntity));
      }
  }
  for (AGAction part : actions) 
    secondList.items.add(new ListElement(part.id, part.name, part.sprite, white, true, part.script));
  secondList.resizeSlider();
}
void loadSecondListItemActions(AGHuman human, int id) {
  secondList.items.clear(); 
  Actions actions = new Actions();
  actions.add(getItemInfo);
  actions.add(itemThrow);
  if (human.items.getCount(id)>1)
    actions.add(itemThrowAll);
  int itemClass = d.getItemClass(id);
  if (itemClass==Database.DRUG)
    actions.add(itemUse);
  else if (itemClass==Database.FOOD)
    actions.add(itemEat);
  else if (itemClass==Database.DRINK)
    actions.add(itemDrink);
  else if (itemClass==Database.ARMOR || itemClass==Database.CONTAINER)
    actions.add(new AGAction ("надеть", setItemWear));
  else if (itemClass==Database.WEAPON_FIRE || itemClass==Database.WEAPON_HOLD)
    actions.add(new AGAction ("вооружиться", setItemWear));
  for (AGAction part : actions) 
    secondList.items.add(new ListElement(part.id, part.name, null, white, true, part.script));
  secondList.resizeSlider();
}
void loadSecondListWearActions(AGHuman human, int id_body) {
  secondList.items.clear(); 
  Actions actions = new Actions();
  actions.add(getWearInfo);
  int item = human.parts.get(id_body), itemClass = d.getItemClass(item);
  if (item!=-1) {
    if (itemClass==Database.ARMOR || itemClass==Database.CONTAINER)
      actions.add(new AGAction ("снять", removeItemWear));
    else if (itemClass==Database.WEAPON_FIRE || itemClass==Database.WEAPON_HOLD)
      actions.add(new AGAction ("убрать", removeItemWear));
  }
  for (AGAction part : actions) 
    secondList.items.add(new ListElement(part.id, part.name, null, white, true, part.script));
  secondList.resizeSlider();
}


class Listbox extends ActiveElement {
  ArrayList <ListElement> items;
  float itemHeight = 32;
  int listStartAt = 0;
  int hoverItem = -1;
  ListElement select=null;
  float valueY = 0;
  boolean hasSlider = false;

  Listbox (float x, float y, float w, float h) {
    super(x, y, w, h);
    valueY =y;
    items = new ArrayList <ListElement> ();
  }
  void resizeSlider() {
    hasSlider=items.size()*itemHeight> this.height;
  }
  void resetScroll() {
    valueY=y;
    update();
  }
  void mouseMoved ( float mx, float my ) {
    if ((hasSlider && mx > x+this.width-20)) return;
    if (hover)
      hoverItem = listStartAt + int((my-y)/itemHeight);
  }
  void mouseExited ( float mx, float my ) {
    hoverItem = -1;
  }
  void mouseDragged (float mx, float my) {
    if (!hasSlider) return;
    if (mx < x+this.width-20) return;
    valueY = my-itemHeight;
    valueY = constrain(valueY, y, y+this.height-itemHeight);
    update();
  }
  void mouseScrolled (float step) {
    if (items.size()*itemHeight>height && hover) {
      float heightScroll = items.size()*itemHeight-this.height; 
      float hS = heightScroll/itemHeight;
      valueY += constrain(step, -1, 1)*((items.size()*itemHeight)/hS);
      valueY = constrain(valueY, y, y+this.height-itemHeight);
      update();
    }
  }
  void update () {
    float totalHeight = items.size() * itemHeight;
    float listOffset = (map(valueY, y, y+this.height-itemHeight, 0, totalHeight-this.height));
    listStartAt = int( listOffset / itemHeight );
    listStartAt = constrain(listStartAt, 0, listStartAt);
  }
  void mousePressed (float mx, float my) { 
    if (this.items==null) return;
    if (this.items.isEmpty()) return;
    if (hasSlider && mx > x+this.width-20) return;
    int pressed=listStartAt + int((my-y)/itemHeight);
    if (pressed<this.items.size()) {
      ListElement element = items.get(constrain(pressed, 0, items.size()-1));
      select = element;
      if (element.script!=null)
        element.script.run();
    }
  }
  boolean hoverNoSlider() {
    return (mouseX<x+width-20);
  }
  void draw () { 
    pushMatrix();
    stroke(white);
    noFill();
    rect(x, y, this.width, this.height);
    if (items != null) {
      for (int i = 0; i<int(this.height/itemHeight) && i <items.size(); i++) {
        color _color= items.get(constrain(i+listStartAt, 0, items.size()-1))._color;
        stroke(white);
        if (i+listStartAt==items.indexOf(select))
          fill(white);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider()) ? white : hud1);
        rect(x, y + (i*itemHeight), this.width, itemHeight);
        noStroke();
        if (i+listStartAt==items.indexOf(select))
          fill(hud1);
        else 
        fill(((i+listStartAt) == hoverItem && hoverNoSlider()) ? hud1 : _color);
        PImage image = items.get(constrain(i+listStartAt, 0, items.size()-1)).sprite;
        int h=5;
        if (image!=null) {
          image(image, x+1, y+(i+1)*itemHeight-32);
          h+=32;
        }
        text(items.get(constrain(i+listStartAt, 0, items.size()-1)).label, x+h, y+(i+1)*itemHeight-5 );
      }
    }
    if (hasSlider) {
      stroke(white);
      fill(hud1);
      rect(x+this.width-20, y, 20, this.height);
      fill(white);
      rect(x+this.width-20, valueY, 20, 20);
    }
    popMatrix();
  }
}
class ListElement {
  int id;  //ассоциация кнопки с объектом/действием
  String label;
  PImage sprite;
  color _color;
  boolean button;
  Runnable script;

  ListElement (int id, String label, PImage sprite, color _color, boolean button, Runnable script) {
    this(id, label, _color, button, script);
    this.sprite=sprite;
  }
  ListElement (int id, String label, color _color, boolean button, Runnable script) {
    this.id=id;
    this.label=label;
    this._color=_color;
    this.button=button;
    this.script=script;
    sprite=null;
  }
  AGObject getObject() {
    return game.room.getAllObjects().getAGObject(id);
  }
}
class RadioButton extends ActiveElement {
  int orientation;
  SimpleRadioButton select;
  ArrayList <SimpleRadioButton> buttons= new ArrayList <SimpleRadioButton>();
  final static int HORIZONTAL = 0, VERTICAL = 1;

  RadioButton  (int x, int y, int widthObj, int  heightObj, int orientation) {
    super(x, y, widthObj, heightObj);
    this.orientation = constrain(orientation, 0, 1);
    select=null;
  }
  void addButton(SimpleRadioButton button) {
    buttons.add(button);
    update();
  }
  void control () {
    setActive(true); 
    for (SimpleRadioButton button : buttons) {
      if (button.pressed) 
        setSelect(button);
    }
  }
  void resetSelect() {
    setSelect(buttons.get(0));
  }
  void setActive(boolean active) {
    super.setActive(active);
    for (SimpleRadioButton button : buttons)
      button.setActive(active);
  }
  void addButtons(SimpleRadioButton [] buttons) {
    this.buttons.clear();
    for (SimpleRadioButton button : buttons)
      this.buttons.add(button);
    update();
  }
  private void update() {
    for (int i=0; i<buttons.size(); i++) {
      SimpleRadioButton button = buttons.get(i);
      if (orientation==HORIZONTAL) {
        int widthButton = (int)width/buttons.size()-1;
        button.width=widthButton;
        button.height=height;
        button.y=y;
        button.x=x+i*(widthButton+1);
      } else if (orientation==VERTICAL) {
        int heightButton =  (int)height/buttons.size();
        button.height=heightButton;
        button.width=width;
        button.x=x;
        button.y=y+i*(heightButton+1);
      }
    }
    setSelect(buttons.get(0));
  }
  int select() {
    return buttons.indexOf(select);
  }
  void setSelect(SimpleRadioButton button) {
    select=button;
    for (SimpleRadioButton part : buttons) {
      if (part.equals(select)) {
        part.on=true;
        if (select.script!=null)
          select.script.run();
      } else 
      part.on=false;
    }
  }
}


class SimpleButton extends ActiveElement {
  boolean on;
  String text;
  Runnable script;
  PImage sprite;

  SimpleButton (float x, float y, float w, float h, String text, Runnable script) {
    super(x, y, w, h);
    this.text=text;
    this.script=script;
    sprite=null;
  }

  SimpleButton (float x, float y, float w, float h, PImage sprite, Runnable script) {
    this(x, y, w, h, "", script);
    this.sprite=sprite;
  }
  void mousePressed () {
    if (script!=null)
      script.run();
  }
  void draw () {
    pushMatrix();
    pushStyle();  
    if (sprite!=null) {
      if (hover && mousePressed) 
        image(sprite, x-2, y-2, width+4, height+4);
      else 
      image(sprite, x, y);
      if (on) {
        noFill();
        stroke( white );
        rect(x+2, y+2, width-4, height-4);
      }
    } else {
      if (on) fill(white);
      else fill(hud1);
      noStroke();
      rect(x, y, width, height);
      if (hover)
        if (mousePressed) 
          stroke(color(90));
        else 
        stroke(white);
      else noStroke();
      rect(x+2, y+2, width-4, height-4);
      strokeWeight(1);
      textAlign(CENTER, CENTER);
      if ( on ) fill(black);
      else fill(white);
      text(text, x+this.width/2, y+this.height/2-textDescent());
    }
    popStyle();
    popMatrix();
  }
}

class SimpleRadioButton extends SimpleButton {
  String event;

  SimpleRadioButton (String text, String event, Runnable script) {
    this(text, event);
    this.script=script;
  }
  SimpleRadioButton (String text, String event) {
    super(-600, -600, 1, 1, text, null);  
    this.event=event;
  }
  void mouseClicked () {
    if (mouseButton==LEFT)
      on=!on;
  }
}

void drawParameter(int x, int y, int width, String text, String parameter, color _color) {
  float widthText = textWidth(text);
  float lengthPoint = (x+width-textWidth(parameter))-(x+widthText);
  String points="";
  while (textWidth(points)<lengthPoint)
    points+=".";
    fill(_color);
  text(text+points+parameter, x, y);
}
