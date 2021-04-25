
interface capacity {
  Items getItems();
  void clearItems();
}
interface updates {
  void tick();
}


abstract class AGObject {
  int id, x, y, angle, 
    type; //тип объекта;
  final static int ALIVE=0, DEATH=90;
  PImage sprite;
  AGRoom room;
  AGObject (AGRoom room, int type, int x, int y) {
    this.x=x;
    this.y=y;
    this.type=type;
    sprite = getSprite(type);
    angle=ALIVE;
    setRoom(room);
  }
  Actions getActions() {
    Actions actions = new Actions();
    actions.add(getObjectInfo);
    return actions;
  }
  void setRoom(AGRoom room) {
    if (room!=null) {
      this.room=room;
      room.node[x][y].solid=getSolid();
      room.node[x][y].through=getThrough();
      id = room.getAllObjects().getLastId();
    }
  }

  void beginDisplay() {
    pushMatrix();
    translate((x-game.posX)*room.window.size_grid, (y-game.posY)*room.window.size_grid);
    pushStyle();
    tint(white, room.node[x][y].transparent);
    translate(room.window.size_grid/2, room.window.size_grid/2);
    rotate(radians(angle));
  }
  abstract PImage getSprite(int id);
  void display() {
    if (room.node[x][y].open) {
      beginDisplay();
      draw();
      if (mainList.select!=null) {
        if (mainList.select.id==id)
          drawSelected();
      }
      endDisplay();
    }
  }
  void draw() {
    image(sprite, -room.window.size_grid/2, -room.window.size_grid/2);
  }
  void endDisplay() {
    popStyle();
    popMatrix();
  }
  void drawSelected() {
    pushStyle();
    noFill();
    stroke(green);
    strokeWeight(3);
    rect(-room.window.size_grid/2, -room.window.size_grid/2, room.window.size_grid, room.window.size_grid);
    popStyle();
  }
  void drawCount(int count) {
    pushStyle();
    textSize(14);
    textAlign(RIGHT, BOTTOM);
    fill(white);
    text(count, room.window.size_grid/2-3, room.window.size_grid/2);
    popStyle();
  }
  boolean getSolid() {
    return false;
  }
  boolean getThrough() {
    return true;
  }
  abstract String getName();
}

class AGTrace extends AGObject {
  int entity;
  AGTrace(AGRoom room, int x, int y, int entity) {
    super(room, 0, x, y);
    this.entity = entity;
  }
  String getName() {
    if (entity==0)
      return "следы "+room.window.player.getName();
    else
      return "следы "+d.getEntity(entity).getString("name");
  }
  PImage getSprite(int type) {
    return trace;
  }
}

abstract class AGEnviroment extends AGObject {
  boolean through;

  AGEnviroment(AGRoom room, int type, int x, int y, boolean through) {
    super(room, type, x, y);
    this.through=through;
  }
  AGEnviroment(AGRoom room, int type, int x, int y) {
    this(room, type, x, y, false);
  }
  boolean getSolid() {
    return true;
  }
  PImage getSprite() {
    return null;
  }
  boolean getThrough() {
    return through;
  }
  String getName() {
    return "дерево";
  }
}
class AGTree extends AGEnviroment {

  AGTree(AGRoom room, int type, int x, int y) {
    super(room, type, x, y);
  }
  PImage getSprite(int type) {
    switch (type) {
    case 1: 
      return tree1;
    case 2: 
      return tree2;
    default : 
      return null;
    }
  }
  String getName() {
    return "дерево";
  }
}
class AGWall extends AGEnviroment {
  String note;
  AGWall (AGRoom room, int type, int x, int y) {
    super(room, type, x, y);
    note=null;
  }
  PImage getSprite(int type) {
    return wall;
  }
  Actions getActions() {
    Actions actions = super.getActions();
    if (note!=null) 
      actions.add(noteRead);
    return actions;
  }
  void draw() {
    if (room.terrain[room.window.player.x][room.window.player.y]!=4 && (room.buildings[x][y+1]==1 || room.node[x][y+1].roof)) {
      pushStyle();
      tint(white, 255);
      image(spr_roof, -room.window.size_grid/2, -room.window.size_grid/2);
      popStyle();
    } else
      image(sprite, -room.window.size_grid/2, -room.window.size_grid/2);
  }
  String getName() {
    return "стена";
  }
}
class AGDoor extends AGEnviroment implements updates {
  PImage sprite_open;
  AGObject user;
  boolean lock;
  AGDoor(AGRoom room, int type, int x, int y) {
    super(room, type, x, y);
    sprite_open = door_open;
    user = null;
    lock=false;
  }
  Actions getActions() {
    Actions actions = super.getActions();
    if (user==null) {
      if (lock)
        actions.add(new AGAction ("открыть", actionDoor));
      else
        actions.add(new AGAction ("запереть", actionDoor));
    }
    return actions;
  }
  PImage getSprite(int type) {
    return door;
  }
  void tick() {
    user = room.entities.getEntityList().getAGObject(x, y, this);
  }
  void draw() {
    if (user!=null) {
      room.node[x][y].solid=false;
      image(sprite_open, -room.window.size_grid/2, -room.window.size_grid/2);
    } else {
      room.node[x][y].solid=true;
      image(sprite, -room.window.size_grid/2, -room.window.size_grid/2);
    }
  }
  boolean isOpen() {
    return !lock && user==null;
  }
  String getName() {
    return "дверь";
  }
}
class AGLight extends AGObject {
  int light;
  boolean on;
  AGLight(AGRoom room, int type, int x, int y, int light) {
    super(room, type, x, y);
    this.light=constrain(light, 1, 5);
    on=true;
  }
  Actions getActions() {
    Actions actions = super.getActions();
    if (on)
      actions.add(lightOff);
    else
      actions.add(lightOn);
    return actions;
  }
  PImage getSprite(int type) {
    return bonfire;
  }
  boolean getSolid() {
    return true;
  }
  String getName() {
    return "фонарь";
  }
}
class AGBonfire extends AGLight {
  int maxTemperature;
  AGBonfire(AGRoom room, int type, int x, int y, int light, int maxTemperature) {
    super(room, type, x, y, light);
    this.maxTemperature=maxTemperature;
  }

  String getName() {
    return "костер";
  }
}
class AGContainer extends AGObject implements capacity {
  Items items; //список предметов
  AGContainer(AGRoom room, int type, int x, int y) {
    super(room, type, x, y);
    items = new Items();
    items.append(d.getItemRandom().getInt("id"));
    items.append(d.getItemRandom().getInt("id"));
    items.append(d.getItemRandom().getInt("id"));
    items.append(d.getItemRandom().getInt("id"));
    items.append(d.getItemRandom().getInt("id"));
  }
  Actions getActions() {
    Actions actions = super.getActions();
    if (items.sortId().size()>1)
      actions.add(getAllItemsFromObjectInItems);
    for (int item : items.sortId()) {
      actions.add(new AGAction (item, "взять "+d.getItem(item).getString("name"), d.getItemSprite(item), getItemFromItems));
      if (items.getCount(item)>1) 
        actions.add(new AGAction (item, "взять "+d.getItem(item).getString("name")+" x"+items.getCount(item), d.getItemSprite(item), getAllItemFromItems));
    }
    return actions;
  }
  PImage getSprite(int type) {
    return container;
  }
  Items getItems() {
    return items;
  }
  void clearItems() {
    items.clear();
  }
  boolean getSolid() {
    return true;
  }
  String getName() {
    return "контейнер";
  }
}
class AGEntity extends AGObject implements updates {
  final static int STAND=0, ESCAPE=1, DEFENSE=2, WARRIOR=3;
  int [][] matrixView;
  int view, //радиус обзора 
    viewAtack, //радиус атаки 
    hp, //здоровье и максимальное здоровье
    armor, //класс брони
    force, //класс оружия
    exp, 
    accuracy; //ловкость 
  int character; //характер сущности
  Cell target;   //цель, условный чек поинт куда держит путь сущность
  AGTraces trace; //список следов
  int side; //принадлежность к стороне
  final static int ENTITY =0, OBJECT=1, TRACE=2;
  int stun; //счетчик оглушения

  AGEntity(AGRoom room, int type, int x, int y, int atack, int side, int character, int hp, int ac, int wc) {
    super(room, type, x, y);
    this.character=character;
    this.view=5;
    this.viewAtack=constrain(atack, 1, view); //радиус атаки не может быть больше радиуса обзора
    this.side=side;
    this.hp=hp;
    this.armor=ac;
    this.force=wc;
    exp = 0;
    target = null;
    trace = new AGTraces ();
    accuracy = 5;
    stun=0;
  }
  void setRoom(AGRoom room) {
    super.setRoom(room); 
    if (room!=null)
      matrixView = createGrid(room.sizeX, room.sizeY);
  }
  PImage getSprite(int type) {
    return d.entitiesSprites.get(type);
  }
  int getHpMax() {
    return d.getEntity(type).getInt("hp");
  }
  boolean getSolid() {
    return true;
  }
  boolean getThrough() {
    return false;
  }
  void draw() {
    super.draw();
    if (hp<=getHpMax() && hp>0 && room.window.player.isSee(this)) {
      drawStatus(2, hp, getHpMax(), blue, red);
      if (this!=room.window.player) {
        if (room.window.player.matrixView[x][y]>0)
          drawCount(room.window.player.matrixView[x][y]);
      }
    }
  }
  void drawStatus(int ty, float a, float b, color one, color two) {
    if (a<b) {
      pushMatrix();
      translate(-room.window.size_grid/2, -room.window.size_grid/2);
      pushStyle();
      strokeWeight(3);
      stroke(one);
      float xMax = map(a, 0, b, 2, room.window.size_grid-2);
      line(2, ty, xMax, ty);
      stroke(two);
      line(xMax, ty, room.window.size_grid-2, ty);
      popStyle();
      popMatrix();
    }
  }
  void drawText(String text, color _color) {
    pushStyle();
    textAlign(RIGHT, BOTTOM);
    fill(_color);
    text(text, textWidth(getName())/2, -room.window.size_grid/2);
    popStyle();
  }
  Actions getActions() {
    Actions actions = super.getActions(); 
    //специальная возможность вручную атаковать противника
    if (room.window.player.getAllNeighbors(ENTITY, room.window.player.getViewAtack()).contains(this))
      actions.add(entityAtack);
    return actions;
  }
  boolean isAllowWar() {
    return hp*100/getHpMax()>30;
  }
  boolean isAllowAtack() {
    return true;
  }
  void tick() {
    if (stun==0) {//если сущность не оглушена
      angle=ALIVE;
      room.node[x][y].through=getThrough();
      room.node[x][y].solid=getSolid();
      nullGrid(matrixView);
      room.adjView(this, view, matrixView, this==room.window.player); 
      JSONObject ch = d.getCharacter(character);
      Cells neighbors = getNeighboring(room.node, room.node[x][y], null);   
      if (d.getEntityClass(type)==Database.MONSTER) {
        Cell targetTemperature = null;
        for (Cell part : neighbors) {
          if (room.temperature[part.x][part.y]>35) 
            targetTemperature = part;
        }
        if (targetTemperature!=null) {
          target = null;
          Cell cell = neighbors.getFar(targetTemperature.x, targetTemperature.y);                                                //убегаем в дальнюю от врага
          move(cell.x, cell.y);
          game.printConsole(getName()+" спасается от огня", true);
          return;
        }
      }
      AGObjects neighborsEntity =  getAllNeighbors(ENTITY, view);                   //получает список всех сущностей в зоне прямой видимости
      AGObjects neighborsViewEnemy = neighborsEntity.getEnemyList(this);            //получает список всех вражеских сущностей в зоне прямой видимости
      AGObjects neighborsViewFriend = neighborsEntity.getFriendList(this);           //получает список всех дружественных сущностей в зоне прямой видимости
      if (!neighborsViewEnemy.isEmpty()) {     //если в зоне прямой видимости есть враг
        AGEntity enemyTarget;             //создаем пустую служебную ссылку
        if (ch.getBoolean("warrior") || ch.getBoolean("hunt")) {   //если сущность воинственна   
          if ((isAllowWar() && !neighborsViewEnemy.isFearEntity(this)) || !neighborsViewFriend.isEmpty()) {    //если может атаковать c учетом здоровья, снаряжения, наличия союзников, боевой мощи и прочее
            AGObjects neighborsAtack = getAllNeighbors(ENTITY, getViewAtack()).getEnemyList(this);       //получает список всех вражеских сущностей в зоне поражения
            if (!neighborsAtack.isEmpty() && isAllowAtack())        //если в зоне атаки (поражения) есть враги и атака доступна           
              atack((AGEntity)neighborsAtack.getNear(x, y));                                             //выбирает ближайшего врага и атакует
            else {                                                                                        //если в зоне атаки врагов нет, значит нужно добраться до них
              enemyTarget = (AGEntity)neighborsViewEnemy.getNear(x, y);                                             //определеляет ближайшего врага в зоне видимости
              neighbors = getNeighboring(room.node, room.node[x][y], null);                                      //находит соседние клетки 
              if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
                Cell cell = neighbors.getNearest(enemyTarget.x, enemyTarget.y);                                                // преследуем врага
                move(cell.x, cell.y);
                game.printConsole(getName()+" преследует "+enemyTarget.getName(), true);
              }
            }
          } else {                                                                                                    //если не может атаковать, то
            enemyTarget = (AGEntity)neighborsViewEnemy.getNear(x, y);                                             //определеляет ближайшего врага в зоне видимости
            neighbors = getNeighboring(room.node, room.node[x][y], null);                                      //находит соседние клетки 
            if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
              Cell cell = neighbors.getFar(enemyTarget.x, enemyTarget.y);                                                //убегаем в дальнюю от врага
              move(cell.x, cell.y);
              game.printConsole(getName()+" убегает от "+enemyTarget.getName(), true);
            } else {                                                                                                    //если по соседству нет пустых клеток
              AGObjects neighborsAtack = getAllNeighbors(ENTITY, getViewAtack()).getEnemyList(this);                  //получает список всех вражеских сущностей в зоне поражения
              if (!neighborsAtack.isEmpty() && isAllowAtack()) {                                                                       //если в зоне атаки (поражения) есть враги
                enemyTarget = (AGEntity)neighborsAtack.getNear(x, y);                                   //выбирает ближайшего врага
                atack(enemyTarget);                                                                                       //атакует
              }
            }
          }
        } else {
          enemyTarget = (AGEntity)neighborsViewEnemy.getNear(x, y);                                             //определеляет ближайшего врага в зоне видимости
          neighbors = getNeighboring(room.node, room.node[x][y], null);                                      //находит соседние клетки 
          if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
            Cell cell = neighbors.getFar(enemyTarget.x, enemyTarget.y);                                                //убегаем в дальнюю от врага
            move(cell.x, cell.y);
            game.printConsole(getName()+" убегает от "+enemyTarget.getName(), true);
          }
        }
        if (neighborsViewEnemy.contains(room.window.player)) {
          if (!room.node[x][y].open) {
            room.node[x][y].open=true;
            game.printConsole(getName()+" обнаружил "+room.window.player, true);
          }
        }
      } else {      //если в зоне видимости нет врагов
        if (ch.getBoolean("hunt") && (isAllowWar() || !neighborsViewFriend.isEmpty())) {
          AGTrace trace= getAllNeighbors(TRACE, view).getSortNear(x, y).getTraces().getTraceEnemy(this);  //ищет вблизи следы врагов
          if (trace!=null) {
            neighbors = getNeighboring(room.node, room.node[x][y], null);                                      //находит соседние клетки 
            if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
              Cell cell = neighbors.getNearest(trace.x, trace.y);                                                // направляемся к ближайшему следу
              move(cell.x, cell.y);
              room.removeAllTraceXY(x, y, trace.entity);
            }
            if (trace.entity==0)
              game.printConsole(getName()+" идет по следу "+room.window.player.getName(), true);
            else
              game.printConsole(getName()+" идет по следу "+d.getEntity(trace.entity).getString("name"), true);
          } else {
            if (target == null) {
              Cells freeSectors = getCellsFreePlace(room.node, room.roads);
              target = freeSectors.get(int(random(freeSectors.size()-1)));
              game.printConsole(getName()+" бродит в "+target.x+":"+target.y, true);
            } 
            neighbors = getPathTo(room.node, room.node[x][y], room.node[target.x][target.y]);                   //возвращается на свой старый маршрут
            if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
              Cell cell = neighbors.get(neighbors.size()-1);                                                          //двигаемся в хаотичном направлении
              move(cell.x, cell.y);
            } else
              target = null;
          }
        } else if (ch.getBoolean("move")) {
          if (target == null) {
            Cells freeSectors = getCellsFreePlace(room.node, room.roads);
            target = freeSectors.get(int(random(freeSectors.size()-1)));
            game.printConsole(getName()+" бродит в "+target.x+":"+target.y, true);
          } 
          neighbors = getPathTo(room.node, room.node[x][y], room.node[target.x][target.y]);                   //возвращается на свой старый маршрут
          if (!neighbors.isEmpty()) {                                                                              //если есть пустые соседние клетки
            Cell cell = neighbors.get(neighbors.size()-1);                                                          //двигаемся в хаотичном направлении
            move(cell.x, cell.y);
            if (hp<getHpMax())
              hp++;
          } else
            target = null;
        }
      }
    } else {  //если оглушен
      stun--;
      angle=DEATH;
      room.node[x][y].through=true;
      room.node[x][y].solid=false;
      game.printConsole(getName()+" оглушен и пропускает ход", true);
    }
  }
  int getArmorClass() {
    return armor;
  }
  int getWeaponClass() {
    return force;
  }
  int getAccuracy() {
    return accuracy;
  }
  boolean isHit(int x, int y) {
    int dist = matrixView[x][y];
    return random(dist+2)<2;
  }
  boolean isStun() {
    return random(6)>=3;
  }
  void atack(AGEntity enemy) {
    if (isHit(enemy.x, enemy.y)) {
      int forceAttack = constrain(getWeaponClass()-enemy.getArmorClass(), 0, 999);
      enemy.hp-=forceAttack;
      if (isStun()) {
        enemy.stun=3;
        game.printConsole(getName()+" наносит "+forceAttack+" повреждений и оглушает "+enemy.getName(), true);
      } else
        game.printConsole(getName()+" наносит "+forceAttack+" повреждений "+enemy.getName(), true);
      checkKill(enemy);
    } else
      game.printConsole(getName()+" промахнулся", true);
  }
  void death() {
    trace.clear();
    if (this!=room.window.player) {
      if (room.window.player.entities.contains(this))
        room.window.player.entities.remove(this);
    }
    angle=DEATH;
    room.node[x][y].solid=false;
    room.node[x][y].through=true;
    room.window.printConsole(getName()+" погиб", true);
    room.entities.remove(this);
    room.deathEntities.add(this);
  }
  void checkKill(AGEntity enemy) {
    if (enemy.hp<=0) {
      enemy.death();
      if (enemy!=room.window.player)
        exp+=d.getEntity(enemy.type).getInt("exp");
    }
  }
  void move(int x, int y) {
    //создается новый след
    if (!trace.hasCell(this.x, this.y))
      trace.add(new AGTrace(room, this.x, this.y, type));
    //удаляем последний свой след
    if (trace.size()>=25)
      trace.remove(0);
    //после каждого перемещения
    //восстанавливаем матрицу твердости
    room.node[this.x][this.y].solid=false;
    room.node[x][y].solid=getSolid();
    //восстанавливаем матрицу прозрачности
    AGObject object = room.getAllObjectsNotEntitiesNotTraces().getAGObject(this.x, this.y);
    if (object!=null)
      room.node[this.x][this.y].through=object.getThrough();
    else
      room.node[this.x][this.y].through=true;
    room.node[x][y].through=getThrough();
    //меняем координаты
    this.x=x;
    this.y=y;
  }
  boolean isSee(AGObject object) {   //возвращает истину если объект object находится в зоне прямой видимости 
    if (this==object) return true;
    AGObjects allView = new AGObjects();
    allView.addAll(getAllNeighbors(ENTITY, view));
    allView.addAll(getAllNeighbors(OBJECT, view));
    return allView.contains(object);
  }
  AGObjects getAllNeighbors(int shearch, int view) {   //возвращает список всех объектов (OBJECT) или всех сущностей (ENTITY) в соответствии с указанным радиусом
    AGObjects neighbors = new AGObjects();
    for (int l=0; l<d.matrixLine.length; l++) {
      int px=x, py=y;
      for (int i=0; i<constrain(view, 1, d.matrixLine[l].length); i++) { 
        int ix=d.matrixShearch[d.matrixLine[l][i]][0];
        int iy=d.matrixShearch[d.matrixLine[l][i]][1];
        int gx=constrain(x+ix, 0, room.sizeX-1);
        int gy=constrain(y+iy, 0, room.sizeY-1);
        if (!getApplyDiagonal(room.node, gx, gy, px, py, true))
          break;
        else {
          px=gx;
          py=gy;
        }
        AGObject object = null;
        if (shearch == TRACE) {
          for (AGObject trace : room.getAllTraces().getAGObjects(gx, gy)) {
            if (!neighbors.contains(trace))
              neighbors.add(trace);
          }
        } else
          if (shearch == OBJECT) {
            object  = room.getAllObjectsNotEntitiesNotTraces().getAGObject(gx, gy);
            if (object!=this && !neighbors.contains(object))
              neighbors.add(object);
          } else 
          if (shearch == ENTITY) {
            object  = room.entities.getEntityList().getAGObject(gx, gy);
            if (object!=null) {
              if (object!=this && !neighbors.contains(object))
                neighbors.add(object);
            }
          }
        if (room.node[gx][gy].solid && !room.node[gx][gy].through)  //!=shearch != ENTITY блокировка видимости н работает на существ
          break;
        if (object!=null) {
          if (this==room.window.player) {
            if (room.node[object.x][object.y].open)
              room.node[object.x][object.y].open=true;
          }
        }
      }
    }
    return neighbors;
  }
  String getName() {
    return d.getEntity(type).getString("name");
  }
  int getViewAtack() {
    return viewAtack;
  }
} 
class AGHuman extends AGEntity implements capacity {
  Items items; //список предметов
  int capacity; //максимальная грузоподъемность
  HashMap <Integer, Integer> parts; 

  AGHuman(AGRoom room, int type, int x, int y, int side, int character, int hp, int wc, int [] items) {
    super(room, type, x, y, 1, side, character, hp, 0, wc);  
    capacity=100;
    this.items = new Items();
    for (int item : items)
      this.items.append(item);
    parts = d.getStartEquip();
  }
  Actions getActions() {
    Actions actions = super.getActions();
    if (hp<=0) {
      if (items.sortId().size()>1)
        actions.add(getAllItemsFromObjectInItems);
      for (int item : items.sortId()) {
        actions.add(new AGAction (item, "взять "+d.getItem(item).getString("name"), d.getItemSprite(item), getItemFromItems));
        if (items.getCount(item)>1)
          actions.add(new AGAction (item, "взять "+d.getItem(item).getString("name")+" x"+items.getCount(item), d.getItemSprite(item), getAllItemFromItems));
      }
    }
    return actions;
  }
  Items getItems() {
    return items;
  }
  void clearItems() {
    items.clear();
  }
  int getCapacity() {
    int container = parts.get(4);
    if (container!=-1)
      return d.getItem(container).getInt("capacity");
    else
      return capacity;
  }
  int getArmorClass() {
    int modAC = 0;
    for (int part : parts.keySet()) {
      int item = parts.get(part);
      if (item!=-1) {
        JSONObject dataItem = d.getItem(item);
        if (dataItem.hasKey("ac"))
          modAC+=dataItem.getInt("ac");
      }
    }
    return modAC;
  }
  int getWeaponClass() {
    int weapon = parts.get(7);
    if (weapon!=-1)
      return d.getItem(weapon).getInt("wc");
    else
      return force;
  }
  int getItemsAllWeight() {
    return items.getAllWeight();
  }
  int getViewAtack() {
    int weapon = parts.get(7);
    if (weapon!=-1)
      return d.getItem(weapon).getInt("distance");
    else
      return viewAtack; // у людей по умолчанию дальность в ближнем бою равна 1
  }
  int getAccuracy() {
    int weapon = parts.get(7);
    if (weapon!=-1) 
      return d.getItem(weapon).getInt("accuracy");
    else
      return super.getAccuracy();
  }
  String getDescriptWeapons() {
    int weapon = parts.get(7);
    if (weapon!=-1)
      return d.getItem(weapon).getString("name");
    else
      return "ничего";
  }
  void lowAmmo() {
    int weapon = parts.get(7);  //проверка слота руки
    if (weapon!=-1) { 
      items.append(weapon);
      parts.put(7, -1);
      room.window.printConsole("у "+getName()+" закончились боеприпасы", true);
    }
  }
  boolean isAllowAtack() {
    int weapon = parts.get(7);  //проверка слота руки
    if (weapon!=-1) {           //при наличии оружия
      if (d.getItemClass(weapon)==Database.WEAPON_FIRE) {
        int ammo = d.getItem(weapon).getInt("ammo");
        if (items.hasValue(ammo)) {
          items.removeValue(ammo);
          if (this==room.window.player && menuActions.select.event.equals("inventory"))
            loadMainListInventory(this);
          return true;
        } else {
          lowAmmo();  
          return false;
        }
      } else 
      return true;
    } else
      return true;
  }
  void death() {
    super.death();
    for (int i : parts.keySet()) {   //бросает всю экипировку
      int item = parts.get(i);
      if (item!=-1) {
        if (!room.dropItem(x, y, item, 1))
          items.append(item);
      }
    }
  }
  void atack(AGEntity enemy) {
    super.atack(enemy);
    int weapon = parts.get(7);
    if (weapon!=-1) {
      int itemClass = d.getItemClass(weapon);
      if (itemClass == Database.WEAPON_FIRE)
        room.bullets.add(new Bullet(new PVector(x, y), enemy.x, enemy.y, null));
    }
  }
  void tick() {
    int weapon = parts.get(7);
    Items weapons = new Items();
    if (weapon!=-1)
      weapons.append(weapon);
    Items armors = new Items();
    for (int item : items) {
      int itemClass = d.getItemClass(item);
      if (itemClass==Database.WEAPON_HOLD) 
        weapons.append(item);
      else if (itemClass==Database.WEAPON_FIRE) {
        int ammo = d.getItem(item).getInt("ammo");
        if (items.hasValue(ammo)) 
          weapons.append(item);
      } else if (itemClass==Database.ARMOR) {
        armors.append(item);
      }
    }
    if (armors.size()>0) {
      for (int armor : armors) {
        int body = parts.get(d.getItem(armor).getInt("body"));
        if (body==-1) {
          body=armor;
          parts.put(d.getItem(armor).getInt("body"), armor);
          items.removeValue(armor);
          room.window.printConsole(getName()+" экипируется в "+d.getItem(armor).getString("name"), true);
          return;//тратит ход на экипировку
        }
      }
    }
    if (weapons.size()>0) {
      int weaponMaxDamage = d.getMaxInt(weapons, "wc");
      if (weaponMaxDamage!=weapon || weapon==-1) {
        parts.put(7, weaponMaxDamage);
        items.removeValue(weaponMaxDamage);
        room.window.printConsole(getName()+" вооружается "+d.getItem(weaponMaxDamage).getString("name"), true);
        return;   //тратит ход на вооружение
      }
    }
    super.tick();
  }
}
class AGPlayer extends AGHuman {
  String name;
  Timer sprint;
  AGObjects entities;
  int hpMax;
  int hunger, thirst;
  AGPlayer(int side, String name, int hp, int wc, int [] items) {
    super(null, 0, -1, -1, side, -1, hp, wc, items);
    this.name=name;
    entities = new AGObjects();
    thirst=hunger=0;
    hpMax=hp;
  }
  int getHpMax() {
    return hpMax;
  }
  void death() {
    super.death();
    updateStats();
    clearAllLists();
    room.window.printConsole("игра проиграна", false);
  }
  void setRoom(AGRoom room) {
    super.setRoom(room);
    sprint=new Timer();
    game.timers.add(sprint);
  }
  String getName() {
    return name;
  }
  PImage getSprite(int type) {
    return actor;
  }
  void draw() {
    super.draw();  
    if (hp>0)
      drawText(getName(), yellow);
  }
  void tick() {
    updateNeighbor();
    updateStats();
    if (hunger>=100) {
      room.window.printConsole("вы страдаете от голодания и теряете здоровье", false);
      hp--;
    }
    if (thirst>=100) {
      room.window.printConsole("вы страдаете от обезвоживания и пропускаете ход", false);
      room.tick();
    }
    if (room.window.date.minute%(int(map(getItemsAllWeight(), 0, capacity, 20, 0))+1)==0) { //чем тяжелее груз у игрока тем быстрее происходит обезвоживание
      if (thirst<100)
        thirst++;
    }
    if (room.window.date.minute%30==0) {
      if (hunger<100) 
        hunger++;
    }
  }
  void updateStats() {
    hunger = constrain (hunger, 0, 100);
    thirst = constrain (thirst, 0, 100);
    hp = constrain (hp, 0, getHpMax());
  }
  void updateNeighbor() {
    AGObjects list  = new AGObjects();
    AGObjects entityAllList = getAllNeighbors(ENTITY, view);
    AGObjects objectsList= getAllNeighbors(OBJECT, 1);
    AGObjects tracesList= getAllNeighbors(TRACE, 1);
    AGObjects entityList = entityAllList.getEnemyList(this);
    if (entityList.size()>0) {
      for (AGObject entity : entityList) { 
        AGEntity enemyTarget = (AGEntity)entity;
        if (enemyTarget.side!=side || enemyTarget.side==-1) {
          if (!entities.contains(enemyTarget)) {
            game.printConsole("обнаружен новый противник: "+enemyTarget.getName()+", "+d.getDescriptCharacter(enemyTarget.character), true);
            entities.add(enemyTarget);
          }
        }
      }
    } 
    if (menuActions.select.event.equals("enviroment")) {
      list.addAll(entityAllList);
      list.addAll(objectsList);
      list.addAll(tracesList);
      loadMainListObjects(list);
    }
  }
  void lowAmmo() {
    room.window.printConsole("нет боеприпасов", false);
  }
  void keyEvent(int code) {
    int y=this.y;
    int x=this.x;
    if (code==9) {
      AGObjects enemyList = getAllNeighbors(ENTITY, getViewAtack()).getEnemyList(this);
      if (enemyList.size()>0) {
        AGEntity enemy = (AGEntity)enemyList.getNear(x, y);
        if (isAllowAtack())
          atack(enemy);
        else
          return;
      } else {
        game.printConsole("нет подходящей цели для атаки", false);
        return;
      }
      room.tick();
      tick();
    } else {
      if (items.getAllWeight()<=getCapacity()) {
        if (code==1)  
          y++;
        else if (code==3) 
          y--;
        else if (code==2) 
          x--;
        else if (code==0)
          x++;
        else if (code==4) {
          x--;
          y++;
        } else if (code==5) {
          x--;
          y--;
        } else if (code==6) {
          x++;
          y++;
        } else if (code==7) {
          x++;
          y--;
        }
        x=constrain(x, 0, room.sizeX-1);
        y=constrain(y, 0, room.sizeY-1); 
        boolean move = false;
        if (getApplyDiagonal(room.node, this.x, this.y, x, y, false)) {
          if (room.node[x][y].door) {
            AGDoor door = (AGDoor)room.doors.getAGObject(x, y);
            if (door.isOpen())
              move =true;
          } else {
            if (!room.node[x][y].solid)
              move=true;
          }
        }
        if (move) {
          move(x, y);
          room.tick();
          tick();
          AGObject portal = room.portals.getAGObject(x, y);
          AGObject item = room.items.getAGObject(x, y);
          if (portal!=null) {
            room.node[x][y].solid=false;
            trace.clear();
            game.nextRoom(room, this);
          } else if (item!=null) {
            AGItem itemPlace = (AGItem)item;
            if (items.hasValue(itemPlace.type)) {
              while (itemPlace.count>0) {
                game.player.items.append(itemPlace.type);
                itemPlace.count--;
              }
              room.items.remove(itemPlace);
              if (menuActions.select.event.equals("inventory"))
                loadMainListInventory(this);
            }
          }
        }
      } else
        game.printConsole("максимальный груз, перемещение невозможно", false);
    }
  }
  void move(int x, int y) {
    super.move(x, y);
    if (this.x>=game.posX+game.windowX-view)   //следование за персонажем
      game.posX+=room.stepScroll;
    if (this.x<game.posX+view)
      game.posX-=room.stepScroll;
    if (this.y>=game.posY+game.windowY-view)
      game.posY+=room.stepScroll;
    if (this.y<game.posY+view)
      game.posY-=room.stepScroll;
  }
}  
class AGObjects extends ArrayList <AGObject> {

  int getLastId() {
    if (this.isEmpty())
      return 0;
    IntList s = new IntList();
    for (AGObject part : this) 
      s.append(part.id);
    return s.max()+1;
  }
  AGObject getAGObject(int x, int y) {
    for (AGObject object : this) {
      if (object.x==x && object.y==y)
        return object;
    }
    return null;
  }
  AGPortal getObjectArea(int sideX0, int sideY0, int sideX1, int sideY1) {
    for (AGObject object : this) {
      if (object.x>=sideX0 && object.x<=sideX1 && object.y>=sideY0 && object.y<=sideY1) 
        return (AGPortal)object;
    }
    return null;
  }

  AGObjects getAGObjects(int x, int y) {
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (object.x==x && object.y==y)
        objects.add(object);
    }
    return objects;
  }
  AGObject getAGObject(int id) {
    for (AGObject object : this) {
      if (object.id==id)
        return object;
    }
    return null;
  }
  AGObject getAGObject(int x, int y, AGObject exception) {
    if (exception!=null) {
      for (AGObject object : this) {
        if (object.x==x && object.y==y && exception!=object)
          return object;
      }
    }
    return null;
  }
  AGObjects getContainers() {            ////!!!!!!!!!!!!!!!!!!!не используется
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (object instanceof AGContainer) 
        objects.add(object);
    }
    return objects;
  }
  AGTraces getTraces() {
    AGTraces objects = new AGTraces();
    for (AGObject object : this) {
      if (object instanceof AGTrace) 
        objects.add((AGTrace)object);
    }
    return objects;
  }
  AGObjects getLightActive() {          ////!!!!!!!!!!!!!!!!!!!не используется
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (object instanceof AGLight) {
        if (((AGLight)object).on)
          objects.add(object);
      }
    }
    return objects;
  }
  AGObjects getEntityList() {               //возвращает список всех живых существ
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (object instanceof AGEntity) 
        objects.add(object);
    }
    return objects;
  }
  AGObjects getEnemyList(AGEntity entity) {   //возвращает список всех вражеских существ из списка
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (entity!=object) {
        if (object instanceof AGEntity) {
          if (((AGEntity)object).side!=entity.side || entity.side==-1)    
            objects.add(object);
        }
      }
    }
    return objects;
  }
  AGObjects getFriendList(AGEntity entity) {   //возвращает список всех дружественных существ из списка
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      if (entity!=object) {
        if (object instanceof AGEntity) {
          if (((AGEntity)object).side==entity.side)    
            objects.add(object);
        }
      }
    }
    return objects;
  }
  boolean isFearEntity(AGEntity entity) {   //возвращает истину, если в списке найдена сущность которую боится entity
    for (AGObject object : this) {
      if (entity!=object) {
        if (object instanceof AGEntity) {
          AGEntity fear = (AGEntity)object;
          if (fear.getWeaponClass()>entity.getWeaponClass() || fear.getArmorClass()>entity.getArmorClass())   
            return true;
        }
      }
    }
    return false;
  }
  AGObjects getIsPath(AGRoom room, int x, int y) {   //возвращает список всех объектов из списка до которых разрешено перемещение
    AGObjects objects = new AGObjects();
    for (AGObject object : this) {
      Cells neighborings = getNeighboring(room.node, room.node[object.x][object.y], null);
      for (Cell target : neighborings) {
        if (!getPathTo(room.node, room.node[x][y], room.node[target.x][target.y]).isEmpty()) 
          objects.add(object);
      }
    }
    return objects;
  }
  AGObject getNear(int x, int y) {  //возвращает ближайший из списка обьект
    FloatList dist = new FloatList();
    for (AGObject object : this) 
      dist.append(dist(object.x, object.y, x, y));
    for (AGObject object : this) {
      float tdist = dist(object.x, object.y, x, y);
      if (tdist==dist.min()) 
        return object;
    }
    return null;
  }
  AGObject getFar(int x, int y) {   //возвращает самый дальний из списка обьект
    FloatList dist = new FloatList();
    for (AGObject object : this) 
      dist.append(dist(object.x, object.y, x, y));
    for (AGObject object : this) {
      float tdist = dist(object.x, object.y, x, y);
      if (tdist==dist.max()) 
        return object;
    }
    return null;
  }
  AGObjects getSortNear(int x, int y) {  //возвращает список объектов начиная с самого ближайшего
    AGObjects objects = new AGObjects();
    AGObjects temp = new AGObjects();
    for (AGObject object : this)
      temp.add(object);
    while (!temp.isEmpty()) {
      AGObject  obj = temp.getNear(x, y);
      temp.remove(obj);
      objects.add(obj);
    }
    return objects;
  }
}
class AGPortal extends AGObject {
  AGPortal(AGRoom room, int type, int x, int y) {
    super(room, type, x, y);
    room.roads[x][y]=0;   //создает флаг для массива дорог
  }
  PImage getSprite(int type) {
    return portal;
  }
  boolean getThrough() {
    return false;
  }
  String getName() {
    return "портал";
  }
}

class AGItem extends AGObject {
  int count;
  AGItem(AGRoom room, int x, int y, int item, int count) {
    super(room, item, x, y);
    this.count=count;
    sprite = getSprite(item);
  }

  Actions getActions() {
    Actions actions = super.getActions();
    actions.add(itemPut);
    if (count>1)
      actions.add(itemPutAll);
    return actions;
  }
  PImage getSprite(int type) {
    return d.getItemSprite(type);
  }
  String getName() {
    return d.getItem(type).getString("name");
  }
  void draw() {
    super.draw();
    if (count>1)
      drawCount(count);
  }
}
