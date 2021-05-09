class AGRoom {
  String name;
  int [][] terrain, objects, roads, temperature, roof, houses_id;
  AGObjects enviroments, doors, entities, containers, sourcesOfLight, deathEntities, portals, items, markets;
  Cell [][] node;
  AGLayer [][] layer;
  int x, y, sizeX, sizeY, stepScroll, maxEnemy;
  AGGame window;
  ArrayList <Bullet> bullets;
  PGraphics map;
  AGObject select;
  AGRoom (AGGame window, int x, int y, int sizeX, int sizeY, int [][] terrain, int [][] roof, int [][] roads, int [][] objects, String name) {
    this.x=x;
    this.y=y;
    this.sizeX=sizeX;
    this.sizeY=sizeY;
    this.window = window;
    stepScroll = 1;
    maxEnemy = 0;
    this.name=name;
    this.terrain = terrain;
    this.roof=roof;
    this.roads=roads;   //массив дорог 1 - свободная клетка с дорожным покрытием, доступно для размещения сущностей.
    // 0 - занятая каким либо объектом или пустотой клетка
    this.objects=objects;
    node =  d.getNewNodes(sizeX, sizeY);
    layer = new AGLayer [sizeX][sizeY];
    enviroments= new AGObjects();
    doors= new AGObjects();
    entities= new AGObjects();
    sourcesOfLight = new AGObjects();
    deathEntities = new AGObjects();
    portals = new AGObjects();
    items = new AGObjects();
    markets = new AGObjects();
    containers = new AGObjects();
    bullets = new ArrayList<Bullet>();
    map = createGraphics(sizeX, sizeY);
    map.beginDraw();
    map.background(black);
    for (int ix=0; ix<sizeX; ix++) {
      for (int iy=0; iy<sizeY; iy++) {
        //cоздание террайна
        layer[ix][iy] = new AGLayer(this, terrain[ix][iy], ix, iy);
        layer[ix][iy].id = sizeX*iy+ix;
        //создание объектов 
        if (objects[ix][iy]!=0) {
          if (objects[ix][iy]==AGData.WALL) {
            enviroments.add(new AGWall(this, AGData.WALL, ix, iy));
            map.stroke(white);
            map.point(ix, iy);
          } else if (objects[ix][iy]==AGData.DOOR) {
            doors.add(new AGDoor(this, AGData.DOOR, ix, iy));
            node[ix][iy].door=true;
          } else if (objects[ix][iy]==AGData.TREE1 || objects[ix][iy]==AGData.TREE2) 
            enviroments.add(new AGEnviroment(this, objects[ix][iy], ix, iy));
          else if (objects[ix][iy]==AGData.BONFIRE) 
            sourcesOfLight.add(new AGBonfire(this, AGData.BONFIRE, ix, iy, 2, 51));
          else if (objects[ix][iy]==AGData.PORTAL) 
            portals.add(new AGPortal(this, AGData.PORTAL, ix, iy));
          else if (objects[ix][iy]==AGData.OBJ_CONTAINER || objects[ix][iy]==AGData.WARDROBE) 
            containers.add(new AGContainer(this, objects[ix][iy], ix, iy));
          else if (objects[ix][iy]==AGData.FRAGMENT) 
            items.add(new AGItem(this, ix, iy, AGData.FRAGMENT, 1));
          else if (objects[ix][iy]==AGData.MARKET_AMMO || objects[ix][iy]==AGData.MARKET_WEAPONS ||
            objects[ix][iy]==AGData.MARKET_ARMOR || objects[ix][iy]==AGData.MARKET_DRUGS || objects[ix][iy]==AGData.MARKET_EAT_AND_DRINKS) {
            markets.add(new AGMarket(this, objects[ix][iy], ix, iy, d.getMarketItems(objects[ix][iy])));
          }
        } else {
          if (roads[ix][iy]==1) {
            map.stroke(gray);
            map.point(ix, iy);
          }
        }
      }
    }
    map.endDraw();
    map = scaleGrapgics(map, 4);
  }
  void setPlayer(AGPlayer player, int x, int y) { //размещение игрока
    player.x=x; 
    player.y=y;
    entities.add(player);
    player.setRoom(this);
    player.updateNeighbor();
  }
  void drawMap(int scale) {
    for (int ix=0; ix<sizeX; ix++) {
      for (int iy=0; iy<sizeY; iy++) {
        if (node[ix][iy].open) {
          if (objects[ix][iy]!=0) {
            if (objects[ix][iy]==1) {
              fill(brown);
              rect(ix*scale, iy*scale, scale, scale);
            } else if (objects[ix][iy]==2) {
            } else if (objects[ix][iy]==9) {
            } else if (objects[ix][iy]==3) {
              fill(tree);
              rect(ix*scale, iy*scale, scale, scale);
            } else if (objects[ix][iy]==4) {
            } else if (objects[ix][iy]==7) {
              fill(purple);
              rect(ix*scale, iy*scale, scale, scale);
            } else if (objects[ix][iy]==27) {
            } else if (objects[ix][iy]==AGData.FRAGMENT) {
              fill(sky);
              rect(ix*scale, iy*scale, scale, scale);
            }
          } else {
            if (roads[ix][iy]==1) {
              fill(black);
              rect(ix*scale, iy*scale, scale, scale);
            }
          }
        }
      }
    }
  }
  void drawMapEntity(int scale) {
    fill(white);
    rect(window.player.x*scale, window.player.y*scale, scale, scale);  //отображение игрока
    for (AGObject entity : window.player.getAllNeighbors(AGEntity.ENTITY, window.player.view)) {
      if (((AGEntity)entity).side!=window.player.side) 
        fill(red);
      else
        fill(green);
      rect(entity.x*scale, entity.y*scale, scale, scale);
    }
  }
  void forTick(int i) {
    for (int tick = 0; tick<i; tick++) {
      tick();
      window.player.tick();
    }
  }
  void tick() {
    game.date.tick();
    for (AGObject object : getObjectsUpdates()) { //для всех объектов требующих обновление
      if (object instanceof updates)
        ((updates)object).tick();
    }
    if (entities.size()-1<maxEnemy)
      spawn();
  }
  void spawn() { //создает новых мобов в комнате спавн в объектах порталах
    for (AGObject portal : portals) {
      if (!window.player.isSee(portal)) {
        //   int enemy = int(random(20));
        //   if (enemy==0)
        //    entities.add(new AGHuman(this, portal.x, portal.y, 1, -1, AGEntity.STAND, 50));
        //   else if (enemy>=1 && enemy<=10)
        entities.add(createEntity(portal.x, portal.y));
      }
    }
  }

  boolean dropItem(int cx, int cy, int item, int count) {
    int [] neighbors = new int [] {59, 49, 61, 71, 48, 50, 72, 70};
    int stack = 100;
    for (int i=0; i<neighbors.length; i++) {  //цикл перебирает все соседник клетки в соответствией с матрицей размещения
      int ix=cx+d.matrixShearch[neighbors[i]][0]; //корректировка координаты х
      int iy=cy+d.matrixShearch[neighbors[i]][1]; //корректировка координаты у
      if (ix<0 || iy<0 || ix>=sizeX || iy>=sizeY)  //если алгоритм выходит за пределы карты
        continue;  //переходим к следующей клетке
      AGObject object = items.getAGObject(ix, iy);
      if (!node[ix][iy].solid && object==null && getApplyDiagonal(node, cx, cy, ix, iy, true)) { //если клетка пустая,
        if (stack>=count) { //и если количество предметов умещается в стэк 
          items.add(new AGItem(this, ix, iy, item, count)); //то создает новый объект предмета на карте
          return true;
        } else {
          items.add(new AGItem(this, ix, iy, item, stack)); //то создает новый объект предмета на карте
          count-=stack;
        }
      } else {
        if (object instanceof AGItem) {
          AGItem itemMap = (AGItem)object;
          if (itemMap.type==item) {
            int newCount = itemMap.count+count;
            if (newCount>stack) {        //проверяем не переполнен ли стэк объекта itemMap, если да, то
              itemMap.count=stack;      //устанавливаем значение itemMap.count равным значению стэка вложенного предмета
              count=newCount-stack;      //вычисляем сколько предметов осталось после размещения
            } else {              //если стэк объекта itemMap не переполнен
              itemMap.count=newCount;          //устанавливает значение count
              return true;              //продолжает поиск что бы разместить оставшиеся предметы
            }
          }
        }
      }
    }
    window.printConsole("не удалось выбросить предмет: "+d.getItem(item).getString("name"), false);
    return false;
  }
  void removeAllTraceXY(int x, int y, int typeEntity) {   //удаляет все следы cущности type в секторе X Y
    for (AGObject object : entities) {
      AGEntity entity = (AGEntity)object;
      if (entity.trace.hasCell(x, y)) {
        if (entity.trace.hasTypeEntity(typeEntity)) 
          entity.trace.removeXYTypeEntity(x, y, typeEntity);
      }
    }
  }

  AGEntity createEntity(int x, int y) {
    //   JSONObject entity = d.getEntityRandom();
    JSONObject entity = d.getEntity(32);
    if (AGData.HUMAN==d.getEntityClass(entity.getInt("id")))
      return new AGHuman(this, entity.getInt("id"), x, y, 
        entity.getInt("side"), 
        entity.getInt("character"), 
        entity.getInt("hp"), 
        entity.getInt("wc"), 
        entity.getJSONArray("items").getIntArray());
    else if (AGData.MONSTER==d.getEntityClass(entity.getInt("id")))
      return new AGEntity(this, entity.getInt("id"), x, y, 
        entity.getInt("radius_atack"), 
        entity.getInt("side"), 
        entity.getInt("character"), 
        entity.getInt("hp"), 
        entity.getInt("ac"), 
        entity.getInt("wc"));
    else
      return null;
  }
  int [][] adjView(AGObject object, int radius, int [][] view) {
    return adjView(object, radius, view, false);
  }
  int [][] adjView(AGObject object, int radius, int [][] view, boolean player) {   //корректирует и возвращает освещенные участки местность
    view[object.x][object.y]=0;
    if (player)
      node[object.x][object.y].open=true;
    for (int l=0; l<d.matrixLine.length; l++) {
      int px=object.x, py=object.y;
      for (int i=0; i<constrain(radius, 1, d.matrixLine[l].length); i++) { 
        int ix=d.matrixShearch[d.matrixLine[l][i]][0];
        int iy=d.matrixShearch[d.matrixLine[l][i]][1];
        int gx=constrain(object.x+ix, 0, sizeX-1);
        int gy=constrain(object.y+iy, 0, sizeY-1);
        if (!getApplyDiagonal(node, gx, gy, px, py, true)) 
          break;   
        px=gx;
        py=gy;
        if ((view[gx][gy]==-1 || view[gx][gy]>i) && ix>=-object.x && iy>=-object.y && object.x+ix<=sizeX-1 && iy+object.y<=sizeY-1) {
          view[gx][gy]=i;
          if (player)
            node[gx][gy].open=true;
        }
        if (node[gx][gy].solid && !node[gx][gy].through)
          break;
      }
    }
    return view;
  }
  int [][] adjTemperature(AGObject object, int radius, int [][] view) {   //корректирует и возвращает освещенные участки местность
    view[object.x][object.y]=75;
    for (int l=0; l<d.matrixLine.length; l++) {
      int px=object.x, py=object.y;
      for (int i=0; i<constrain(radius, 1, d.matrixLine[l].length); i++) { 
        int ix=d.matrixShearch[d.matrixLine[l][i]][0];
        int iy=d.matrixShearch[d.matrixLine[l][i]][1];
        int gx=constrain(object.x+ix, 0, sizeX-1);
        int gy=constrain(object.y+iy, 0, sizeY-1);
        if (!getApplyDiagonal(node, gx, gy, px, py, true)) 
          break;   
        px=gx;
        py=gy;
        if (ix>=-object.x && iy>=-object.y && object.x+ix<=sizeX-1 && iy+object.y<=sizeY-1)
          view[gx][gy]=int(map(i, 0, radius, 65, 22));
        if (node[gx][gy].solid && !node[gx][gy].through)
          break;
      }
    }
    return view;
  }



  boolean isOverWindow(int x, int y) { //возвращает истину если объект находится внутри карты
    return x<game.posX+game.windowX && y<game.posY+game.windowY && x>=game.posX && y>=game.posY;
  }
  void draw() {
    int [][] view = createGrid(sizeX, sizeY); //создает массив значений освещенности 
    if (window.player.matrixView==null)
      window.player.matrixView = createGrid(sizeX, sizeY); //создает массив значений освещенности
    if (temperature==null)
      temperature = createGrid(sizeX, sizeY); //создает массив значений освещенности
    frozenGrid(temperature);
    setGrid(window.player.matrixView, AGData.NULL);//очищает массив значений освещенности
    for (AGObject light : sourcesOfLight) { //перебираем все функционируемые источники света
      if (((AGLight)light).on) {             //если фонарь включен
        adjView(light, ((AGLight)light).light, view); //корректируем массив освещенности
        adjTemperature(light, ((AGBonfire)light).light, temperature); //корректируем массив освещенности
      }
    }
    if (window.player.hp>0)
      adjView(window.player, window.player.view, window.player.matrixView, true);
    for (int ix=0; ix<game.windowX; ix++) {
      for (int iy=0; iy<game.windowY; iy++) {
        int ax = ix+game.posX;
        int ay = iy+game.posY;
        if (ax>=0 && ay>=0 && ax<sizeX && ay<sizeY) {
          if (node[ax][ay].open) {
            pushStyle();
            if (roof[ax][ay]==AGData.ROOF_ON &&  window.player.matrixView[ax][ay]==-1)
              node[ax][ay].transparent=0;
            else {
              if (window.player.hp>0)
                adjView(window.player, window.player.view, view);
              if (view[ax][ay]!=-1)
                node[ax][ay].transparent=int(map(view[ax][ay], 0, window.player.view, 255, game.date.getDarknessValue()));
              else 
              node[ax][ay].transparent=game.date.getDarknessValue();
            }
            layer[ax][ay].display();
            if (node[ax][ay].transparent==0 && roof[ax][ay]==AGData.ROOF_ON) { 
              tint(white, 255);
              image(d.roof, ix*window.size_grid, iy*window.size_grid);
            }
            popStyle();
          }
        }
      }
    }

    if (deathEntities.size()>10)
      deathEntities.remove(0);
    for (AGObjects objects : new AGObjects [] {getAllTraces(), enviroments, portals, doors, sourcesOfLight, items, containers, markets, deathEntities, entities}) {
      for (int i = objects.size()-1; i>=0; i--) {
        if (isOverWindow(objects.get(i).x, objects.get(i).y)) 
          controlDraw(objects.get(i));
      }
    }
    if (frameCount%2==0) {
      for (int i = bullets.size()-1; i>=0; i--) {
        Bullet bullet = bullets.get(i);
        if (bullet.isTarget())
          bullets.remove(i);
        else
          bullet.update();
      }
    }
    select = null;
    if (mainList.select!=null) {
      if (menuActions.select.event.equals("enviroment"))
        select = mainList.select.getObject();
      else if (menuActions.select.event.equals("terrain"))
        select = mainList.select.getLayer();
    }
    if (select!=null) {
      select.beginDisplay();

      select.drawSelected();
      select.endDisplay();
    }
  }
  void controlDraw(AGObject object) {
    if (object instanceof AGEntity) {
      AGEntity entity = (AGEntity)object;
      if (entity!=window.player) {
        if (entity.hp>0) {
          if (window.player.isSee(entity))
            entity.display();
        } else
          entity.display();
      } else 
      entity.display();
    } else 
    object.display();
  }
  AGObjects getAllObjects() {
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {getAllTraces(), items, portals, enviroments, doors, containers, markets, sourcesOfLight, deathEntities, entities}) { 
      for (AGObject object : objects) 
        all_objects.add(object);
    }
    return all_objects;
  }
  AGObjects getAllObjectsNotEntitiesNotTraces() {
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {items, portals, enviroments, doors, containers, markets, sourcesOfLight, deathEntities}) { 
      for (AGObject object : objects) 
        all_objects.add(object);
    }
    return all_objects;
  }
  AGObjects getAllObjectsNotTraces() {
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {items, portals, enviroments, doors, containers, markets, sourcesOfLight, entities, deathEntities}) { 
      for (AGObject object : objects) 
        all_objects.add(object);
    }
    return all_objects;
  }
  AGObjects getAllEntities() {
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {deathEntities, entities}) { 
      for (AGObject object : objects) 
        all_objects.add(object);
    }
    return all_objects;
  }
  AGObjects getAllTraces() {
    AGObjects entities = getAllEntities();
    AGObjects traces  = new AGObjects();
    for (AGObject entity : entities) 
      traces.addAll(((AGEntity)entity).trace);
    return traces;
  }
  AGObjects getObjectsUpdates() {
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {entities}) { 
      for (AGObject object : objects) {
        if (object!=window.player)
          all_objects.add(object);
      }
    }
    return all_objects;
  }
  AGObjects getAllObjectsInItems() {  //возвращает списки объектов которые могут содержать предметы
    AGObjects all_objects = new AGObjects();
    for (AGObjects objects : new AGObjects [] {containers, deathEntities, entities}) { 
      for (AGObject object : objects) 
        all_objects.add(object);
    }
    return all_objects;
  }
  void removeObject(AGObject object) {
   if (object instanceof AGEnviroment)
     enviroments.remove(object);
     
     node[object.x][object.y].solid=false;
     node[object.x][object.y].through=true;
  }
}


class AGTraces extends ArrayList <AGTrace> {

  boolean hasTypeEntity(int type) {
    for (AGTrace trace : this) {
      if (trace.type==type)
        return true;
    }
    return false;
  }
  boolean hasCell(int x, int y) {
    for (AGTrace trace : this) {
      if (trace.x==x && trace.y==y)
        return true;
    }
    return false;
  }
  AGTrace getXY(int x, int y) {
    for (AGTrace trace : this) {
      if (trace.x==x && trace.y==y)
        return trace;
    }
    return null;
  }
  void removeXYTypeEntity(int x, int y, int typeEntity) {
    for (int i = this.size()-1; i>0; i--) {
      AGTrace trace = this.get(i);
      if (trace.entity==typeEntity && trace.x==x && trace.y==y) 
        this.remove(i);
    }
  }
  AGTrace getTraceEnemy(AGEntity entity) {  //возвращает самый ближайший вражеский след
    for (AGTrace trace : this) {
      int sideEntity;
      if (trace.entity==0)
        sideEntity=0;
      else 
      sideEntity = d.getEntity(trace.entity).getInt("side");
      if (sideEntity!=entity.side) 
        return trace;
    }
    return null;
  }
}
