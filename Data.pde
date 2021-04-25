class Database {
  HashMap <Integer, int[][]> buildingData;

  //объекты
  HashMap <Integer, JSONObject> objects;

  //сущности
  HashMap <Integer, JSONObject> monsters;
  HashMap <Integer, JSONObject> humans;
  HashMap <Integer, PImage> entitiesSprites;
  IntList entities;

  //части тела Human
  HashMap <Integer, JSONObject> bodyParts;

  //характеры сущностей
  HashMap <Integer, JSONObject> characters;

  //предметы
  HashMap <Integer, JSONObject> weapons_hold;
  HashMap <Integer, JSONObject> weapons_fire;
  HashMap <Integer, JSONObject> armors;
  HashMap <Integer, JSONObject> drugs;
  HashMap <Integer, JSONObject> foods;
  HashMap <Integer, JSONObject> drinks;
  HashMap <Integer, JSONObject> ammo;
  HashMap <Integer, JSONObject> artefacts;
  HashMap <Integer, JSONObject> containers;
  HashMap <Integer, PImage> itemsSprites;

  IntList items;


  static final int NULL=-1, EMPTY=0, WALL=1, ROOF=9, TREE=3, DOOR=2, LIGHT=4, PORTAL=7, ROAD=1, 
    MONSTER=0, HUMAN=1, 
    WEAPON_HOLD=0, WEAPON_FIRE=1, ARMOR=2, FOOD=3, DRINK=4, DRUG=5, AMMO=6, ARTEFACT=7, CONTAINER=8, FRAGMENT=70;
  final int [][] matrixShearch = new int [122][2];
  final int [] matrixRadius = { 59, 49, 61, 71, 48, 50, 72, 70, //1 радиус
    47, 36, 37, 38, 39, 40, 51, 62, 73, 84, 83, 82, 81, 80, 69, 58, //2 радиус
    46, 35, 24, 25, 26, 27, 28, 29, 30, 41, 52, 63, 74, 85, 96, 95, 94, 93, 92, 91, 90, 79, 68, 57, //3 радиус
    56, 45, 34, 23, 12, 13, 14, 15, 16, 17, 18, 19, 20, 31, 42, 53, 64, 75, 86, 97, 108, 107, 106, 105, 104, 103, 102, 101, 100, 89, 78, 67, //4 радиус
    55, 44, 33, 22, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 32, 43, 54, 65, 76, 87, 98, 109, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 99, 88, 77, 66}; //5 радиус 
  final int [][] matrixLine;

  Database() {
    int n=0; //формирование матриц поиска
    for (int ix=-5; ix<6; ix++) {
      for (int iy=-5; iy<6; iy++) {
        matrixShearch[n][0]=ix;
        matrixShearch[n][1]=iy;
        n++;
      }
    }
    matrixLine = generateLOS(matrixShearch);
    weapons_hold=new HashMap <Integer, JSONObject>();
    weapons_fire=new HashMap <Integer, JSONObject>();
    armors=new HashMap <Integer, JSONObject>();
    drugs=new HashMap <Integer, JSONObject>();
    foods=new HashMap <Integer, JSONObject>();
    drinks=new HashMap <Integer, JSONObject>();
    ammo=new HashMap <Integer, JSONObject>();
    artefacts=new HashMap <Integer, JSONObject>();
    containers=new HashMap <Integer, JSONObject>();
    itemsSprites = new HashMap <Integer, PImage>();
    items = new IntList();
    bodyParts = new HashMap <Integer, JSONObject>();
    characters = new HashMap <Integer, JSONObject>();

    JSONObject itemsFile = loadJSONObject("items.json");

    JSONArray itemsArray = itemsFile.getJSONArray("weapons_hold");
    for (int j=0; j<itemsArray.size(); j++) {
      weapons_hold.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }

    itemsArray = itemsFile.getJSONArray("weapons_fire");
    for (int j=0; j<itemsArray.size(); j++) {
      weapons_fire.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("armors");
    for (int j=0; j<itemsArray.size(); j++) {
      armors.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("foods");
    for (int j=0; j<itemsArray.size(); j++) {
      foods.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("drinks");
    for (int j=0; j<itemsArray.size(); j++) {
      drinks.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("ammo");
    for (int j=0; j<itemsArray.size(); j++) {
      ammo.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("drugs");
    for (int j=0; j<itemsArray.size(); j++) {
      drugs.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("artefacts");
    for (int j=0; j<itemsArray.size(); j++) {
      artefacts.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }
    itemsArray = itemsFile.getJSONArray("containers");
    for (int j=0; j<itemsArray.size(); j++) {
      containers.put(itemsArray.getJSONObject(j).getInt("id"), itemsArray.getJSONObject(j));
      items.append(itemsArray.getJSONObject(j).getInt("id"));
      itemsSprites.put(itemsArray.getJSONObject(j).getInt("id"), loadImage(itemsArray.getJSONObject(j).getString("sprite")+".png") );
    }

    monsters = new HashMap <Integer, JSONObject>();
    humans = new HashMap <Integer, JSONObject>();
    entitiesSprites = new HashMap <Integer, PImage>();
    entities = new IntList();
    //загрузка сущностей
    JSONObject entitiesFile = loadJSONObject("entities.json");
    JSONArray entitiesArray = entitiesFile.getJSONArray("monsters");
    for (int j=0; j<entitiesArray.size(); j++) {
      monsters.put(entitiesArray.getJSONObject(j).getInt("id"), entitiesArray.getJSONObject(j));
      entitiesSprites.put(entitiesArray.getJSONObject(j).getInt("id"), loadImage(entitiesArray.getJSONObject(j).getString("sprite")+".png"));
      entities.append(entitiesArray.getJSONObject(j).getInt("id"));
    }
    JSONArray humansArray = entitiesFile.getJSONArray("humans");
    for (int j=0; j<humansArray.size(); j++) {
      humans.put(humansArray.getJSONObject(j).getInt("id"), humansArray.getJSONObject(j));
      entitiesSprites.put(humansArray.getJSONObject(j).getInt("id"), loadImage(humansArray.getJSONObject(j).getString("sprite")+".png"));
      entities.append(humansArray.getJSONObject(j).getInt("id"));
    }


    //загрузка построек
    buildingData = new  HashMap <Integer, int[][]>();
    JSONArray build = loadJSONObject("buildings.json").getJSONArray("house");
    for (int j=0; j<build.size(); j++) {
      JSONArray arrayD = build.getJSONArray(j);
      int [][] house = new int [arrayD.getJSONArray(0).size()][arrayD.size()];
      for (int ix=0; ix<arrayD.size(); ix++) {
        JSONArray arrayH = arrayD.getJSONArray(ix);
        for (int iy=0; iy<arrayH.size(); iy++) 
          house[iy][ix] = arrayH.getInt(iy);
      }
      buildingData.put(j, getAdjBuilding(house, 1));  //1 - не менять, это корректировка ширины и высоты
    }

    //загрузка частей тела человека
    JSONArray bodyPartFile = loadJSONArray("body_parts.json");
    for (int ix=0; ix<bodyPartFile.size(); ix++) 
      bodyParts.put(bodyPartFile.getJSONObject(ix).getInt("id"), bodyPartFile.getJSONObject(ix));

    //загрузка характеров сущностей
    JSONArray characterFile = loadJSONArray("characters.json");
    for (int ix=0; ix<characterFile.size(); ix++) 
      characters.put(characterFile.getJSONObject(ix).getInt("id"), characterFile.getJSONObject(ix));
  }

  JSONObject getItemRandom() {
    int random = int(random(items.size()));
    return getItem(items.get(random));
  }
  JSONObject getEntityRandom() {
    int random = int(random(entities.size()));
    return getEntity(entities.get(random));
  }
  JSONObject getEntity(int id) {
    HashMap <Integer, JSONObject> all = new HashMap <Integer, JSONObject>();
    all.putAll(monsters);
    all.putAll(humans);
    return all.get(id);
  }
  JSONObject getItem(int id) {
    HashMap <Integer, JSONObject> all = new HashMap <Integer, JSONObject>();
    all.putAll(weapons_hold);
    all.putAll(weapons_fire);
    all.putAll(armors);
    all.putAll(drugs);
    all.putAll(foods);
    all.putAll(drinks);
    all.putAll(ammo);
    all.putAll(artefacts);
    all.putAll(containers);
    return all.get(id);
  }
  int getItemClass(int id) {  //возвращает класс предмета
    if (weapons_hold.containsKey(id)) 
      return WEAPON_HOLD;
    else if (weapons_fire.containsKey(id)) 
      return WEAPON_FIRE;
    else if (armors.containsKey(id)) 
      return ARMOR;
    else if (foods.containsKey(id)) 
      return FOOD;
    else if (drinks.containsKey(id)) 
      return DRINK;
    else if (drugs.containsKey(id)) 
      return DRUG;
    else if (artefacts.containsKey(id)) 
      return ARTEFACT;
    else if (containers.containsKey(id)) 
      return CONTAINER;
    else 
    return -1;
  }

  int getMaxInt(IntList items, String parameter) {
    int [] s=new int [items.size()];
    for (int i=0; i<items.size(); i++)  
      s[i]=getItem(items.get(i)).getInt(parameter);
    int result = -1;
    for (int i : items) {
      if (getItem(i).getInt(parameter)==max(s)) 
        result = i;
    }
    return result;
  }
  JSONObject getCharacter(int id) {
    if (characters.containsKey(id))
      return characters.get(id); 
    else return null;
  }
  String getDescriptCharacter(int id) {
    switch (id) {
    case 0: 
      return "безобидный";
    case 1: 
      return "исследующий";
    case 2: 
      return "опасный";
    case 3: 
      return "агрессивный";
    default: 
      return "неопределен";
    }
  }
  String getDescriptItem(int item) {
    JSONObject itemObject = getItem(item);
    String info = itemObject.getString("name")+", вес: "+itemObject.getInt("weight");
    int itemClass = getItemClass(item);
    if (itemClass==Database.FOOD)
      info+=", голод: "+itemObject.getInt("effect");
    else if (itemClass==Database.DRINK)
      info+=", жажда: "+itemObject.getInt("effect");
    else if (itemClass==Database.DRUG)
      info+=", здоровье: +"+itemObject.getInt("effect");
    else if (itemClass==Database.ARMOR) {
      info+=", назначение: "+getNameEquip(itemObject.getInt("body"))+", защита: +"+itemObject.getInt("ac");
    } else if (itemClass==Database.WEAPON_FIRE || itemClass==Database.WEAPON_HOLD) {
      info+=", назначение: "+getNameEquip(itemObject.getInt("body"))+", урон: "+itemObject.getInt("wc")+", дальность: "+itemObject.getInt("distance");
    }
    return info;
  }
  HashMap <Integer, Integer> getStartEquip() {
    HashMap parts = new HashMap <Integer, Integer>(); 
    for (int i : bodyParts.keySet())
      parts.put(i, -1);
    return parts;
  }
  String getNameEquip(int id) {
    if (bodyParts.containsKey(id))
      return bodyParts.get(id).getString("name");
    else
      return "не определено";
  }
  int getEntityClass(int id) {
    if (monsters.containsKey(id)) 
      return MONSTER;
    else if (humans.containsKey(id)) 
      return HUMAN;
    else 
    return -1;
  }
  PImage getEntitySprite(int id) {
    return entitiesSprites.get(id);
  }
  PImage getItemSprite(int id) {
    return itemsSprites.get(id);
  }

  void generateRoads(Cell[][] node, int [][] map, int [][] objects, Cells doors, int x, int y, int sizeX, int sizeY) {
    doors=doors.sortRandom();
    for (int i = 0; i<doors.size()-1; i++) { 
      Cells road = getPathTo(node, doors.get(i), doors.get(i+1)); 
      if (!road.isEmpty()) {
        for (Cell point : road) {
          Cells neighbor = getNeighboring(node, node[point.x][point.y], null);
          for (Cell n : neighbor) {
            if (objects[n.x][n.y]==EMPTY)
              map[n.x][n.y]=ROAD;
          }
        }
      }
    }
    int border = 10; //отступ
    for (int i = 0; i<4; i++) {
      Cell exit = null;
      if (i==0) {//выход вправо
        if (x!=sizeX-1)
          exit = node[node.length-1][int(random(border, node[0].length-(1+border)))];
      } else if (i==1) {//выход вверх
        if (y!=0)
          exit = node[int(random(border, node.length-(1+border)))][0];
      } else if (i==2) { //выход вниз
        if (y!=sizeY-1)
          exit = node[int(random(border, node.length-(1+border)))][node[0].length-1];
      } else if (i==3) {//выход влево
        if (x!=0)
          exit = node[0][int(random(border, node[0].length-(1+border)))];
      }
      if (exit!=null) {
        Cells road = getPathTo(node, doors.get(int(random(doors.size()-1))), exit); 
        if (!road.isEmpty()) {
          for (Cell point : road) {
            Cells neighbor = getNeighboring(node, node[point.x][point.y], null);
            for (Cell n : neighbor) {
              if (objects[n.x][n.y]==EMPTY)
                map[n.x][n.y]=ROAD;
            }
          }
        }
      }
    }
  }
  void generateLights(Cell[][] node, int [][] objects, int [][] grid_roads, int count) {
    Cells roads = getRoads(node, grid_roads);
    for (int p =0; p<count; p++) {
      Cell road = roads.get(int(random(roads.size()-1)));
      Cells neighbor = getNeighboring(node, node[road.x][road.y], null);
      if (neighbor.size()==8) {
        boolean place = true;
        for (Cell n : neighbor) {
          if (objects[n.x][n.y]!=EMPTY)
            place=false;
        }
        if (place) {
          objects[road.x][road.y]=LIGHT;
          grid_roads[road.x][road.y]=EMPTY;
        }
      }
    }
  }
  void generateFragments(Cell[][] node, int [][] objects, int [][] grid_roads, int count) {
    Cells roads = getRoads(node, grid_roads);
    for (int p =0; p<count; p++) {
      Cell road = roads.get(int(random(roads.size()-1)));
      objects[road.x][road.y]=Database.FRAGMENT;
    }
  }
  void generateEnviroments(Cell[][] node, int [][] objects, int [][] grid_roads) {
    Cells roads = getRoads(node, grid_roads);
    for (Cell road : roads) { 
      Cells neighbor = getNeighboring(node, node[road.x][road.y], null);
      for (Cell n : neighbor) {
        if (objects[n.x][n.y]==EMPTY) {  //размещение объектов окружения
          if (!roads.contains(n)) {
            if (!isNeighboring(node, objects, n.x, n.y, WALL)) {
              int place =int(random(4));
              if (place==1) 
                objects[n.x][n.y]=TREE;
            }
          }
        }
      }
    }
    for (int ix=0; ix<objects.length; ix++) { //заполнение всех сеток
      for (int iy=0; iy<objects[0].length; iy++) {
        if (!isNeighboring(node, objects, ix, iy, WALL) && objects[ix][iy]==EMPTY && grid_roads[ix][iy]==EMPTY) {
          if (ix==0 || iy==0 || ix==objects.length-1 || iy==objects[0].length-1)
            objects[ix][iy]=TREE;
          else {
            int place =int(random(2));
            if (place==1) 
              objects[ix][iy]=TREE;
          }
        }
      }
    }
  }
  void placeRandomBuildings(Cell [][] node, int [][] map, int count) {    //размещает заданнное count количество построек в случайном порядке 
    int i=0, stage=0;
    while (i<count) {
      int building = int(random(buildingData.size()));
      int [][] build = buildingData.get(building);
      int placeX = 1+int(random(map.length-build.length-2));
      int placeY = 1+int(random(map[0].length-build[0].length-2));
      if (isPlaceBuildingAllow(map, build, placeX, placeY)) {
        if (isClear(map, build, placeX, placeY)) {
          placeBuilding(node, map, build, placeX, placeY);
          i++;
        }
      }
      stage++;
      if (stage>count*100)
        i=count;
    }
  }
  void generateLandArea(int [][] map, int tile, int point_count, int radius) {
    int [][] point = new int [point_count][2];
    for (int ip = 0; ip<point_count; ip++) {
      point[ip][0]=int(random(map.length));
      point[ip][1]=int(random(map[0].length));
    }
    for (int iv = 0; iv<point_count; iv++) {
      map[point[iv][0]][point[iv][1]]=tile;
      for (int i=0; i<constrain(random(radius), 1, matrixRadius.length); i++) {
        int tempX=constrain(point[iv][0]+matrixShearch[matrixRadius[i]][0], 0, map.length-1);
        int tempY=constrain(point[iv][1]+matrixShearch[matrixRadius[i]][1], 0, map[0].length-1);  
        map[tempX][tempY]=tile;
      }
    }
  }
  PImage getTile(int id) {
    switch (id) {
    case 1: 
      return floor1;
    case 2: 
      return floor2;
    case 3: 
      return floor3;
    case 4: 
      return floor4;
    default :
      return floor0;
    }
  }
  Cell [][] getNewNodes(int sizeX, int sizeY) {
    Cell [][] nodes = new Cell [sizeX][sizeY];
    for (int ix=0; ix<sizeX; ix++) {   //заполнение графа
      for (int iy=0; iy<sizeY; iy++) 
        nodes[ix][iy]=new Cell(ix, iy);
    } 
    return nodes;
  }
  void landSumRoads(int [][] roads, int [][] land) {
    for (int ix=0; ix<roads.length; ix++) { //заполнение всех сеток
      for (int iy=0; iy<roads[0].length; iy++) {
        if (roads[iy][ix]!=EMPTY)
          land[iy][ix]=3;
      }
    }
  }

  void generatePortals(Cell[][] node, int [][] objects, int [][] grid_roads, int x, int y, int sizeX, int sizeY) {   //размещение порталов
    Cells all_borders = getCellsFreePlace(node, grid_roads).getCellsIsBorders(node.length, node[0].length);
    int sX = node.length-1, sY=node[0].length-1;
    for (Cell cell : all_borders) {
      if (!((cell.x==0 && cell.y==0) || 
        (cell.x==0 && cell.y==sY) ||
        (cell.y==0 && cell.x==sX) ||
        (cell.x==sX && cell.y==sY))) {
        boolean place = true;
        if  ((cell.x==0 && x==0) ||
          (cell.y==0 && y==0) ||
          (cell.x==sX && x==sizeX-1) ||
          (cell.y==sY && y==sizeY-1)) {
          place = false;
        }
        if ((cell.x==0 && !getPortals(node, objects).getCellsEntryCoord(0, 0, 1, sY).isEmpty()) ||
          (cell.y==0 && !getPortals(node, objects).getCellsEntryCoord(0, 0, sX, 1).isEmpty()) ||
          (cell.x==sX && !getPortals(node, objects).getCellsEntryCoord(sX-1, 0, sX, sY).isEmpty()) ||
          (cell.y==sY && !getPortals(node, objects).getCellsEntryCoord(0, sY-1, sX, sY).isEmpty()))
          place=false; 
        if (place) 
          objects[cell.x][cell.y]=PORTAL;  //размещает портал  <<<вот здесь
        else 
        objects[cell.x][cell.y]=TREE;
        grid_roads[cell.x][cell.y]=EMPTY;
      }
    }
  }

  AGRoom getGenerateRoom(int x, int y, int sizeGlobalX, int sizeGlobalY, int sizeX, int sizeY, String name) {

    Cell [][] nodes = getNewNodes(sizeX, sizeY);
    /*
    ОБЪЕКТЫ:
     0 - пустая клетка, ничего нет
     1 - стена
     9 - стена с крышей
     2 - дверь
     3 - дерево
     4 - фонарь
     7 - портал
     15 - предмет
     27 - ящик
     
     ДОРОГИ:
     0-нет дороги
     1-есть
     
     for (int ix=0; ix<grid_roads.length; ix++) {
     println();
     for (int iy=0; iy<grid_roads[ix].length; iy++) 
     print(objects[ix][iy]);
     }
     
     */
    int [][] grid_land = new int [sizeX][sizeY]; //сетка ландшафта/тайлов
    int [][] grid_objects = new int [sizeX][sizeY]; //сетка объектов
    int [][] grid_roads = new int [sizeX][sizeY]; //сетка дорог
    for (int ix=0; ix<sizeX; ix++) { //заполнение всех сеток
      for (int iy=0; iy<sizeY; iy++) 
        grid_land[ix][iy]=grid_objects[ix][iy]=grid_roads[ix][iy]=EMPTY;
    }
    //генерация ландшафта  
    generateLandArea(grid_land, 1, 100, 120);
    generateLandArea(grid_land, 2, 80, 100);
    //генерация построек
    placeRandomBuildings(nodes, grid_objects, 10);  //размещение построек
    generateRoads(nodes, grid_roads, grid_objects, getDoors(nodes, grid_objects), x, y, sizeGlobalX, sizeGlobalY);  //размещение дорог и тропинок
    landSumRoads(grid_roads, grid_land); //наложение массива дорог на массив местности (массив местности редактируется)
    generateEnviroments(nodes, grid_objects, grid_roads);  //размещение объектов окружения (деревья горы и т.д.)
    generatePortals(nodes, grid_objects, grid_roads, x, y, sizeGlobalX, sizeGlobalY);  //размещение порталов
    generateLights(nodes, grid_objects, grid_roads, int(random(10)));  //размещение источников света
    generateFragments(nodes, grid_objects, grid_roads, int(random(10))); //генерация фрагментов
    return new AGRoom(game, x, y, sizeX, sizeY, grid_land, grid_roads, grid_objects, name);  //создание комнаты
  }
}
int [][] getAdjBuilding(int [][] building, int n) {  //корректирует область размещения, увеличивает ее на n с каждой стороны
  int [][] newBuild = new int [building.length+n+1][building[0].length+n+1];
  clearGrid(newBuild);
  for (int ix=0; ix<building.length; ix++) {
    for (int iy=0; iy<building[ix].length; iy++)
      newBuild[n+ix][n+iy]=building[ix][iy];
  }
  return newBuild;
}
boolean isPlaceBuildingAllow(int [][] map, int [][] building, int x, int y) {
  return !((x+building.length-1>map.length-1 || y+building[building.length-1].length-1>map[map.length-1].length-1));
}
boolean isClear(int [][] map, int [][] building, int x, int y) {
  for (int ix=0; ix<building.length; ix++) {
    for (int iy=0; iy<building[ix].length; iy++) {
      if (map[x+ix][y+iy]!=Database.EMPTY)
        return false;
    }
  }
  return true;
}
void placeBuilding(Cell [][] node, int [][] map, int [][] building, int x, int y) {
  for (int ix=0; ix<building.length; ix++) {
    for (int iy=0; iy<building[ix].length; iy++) {
      if (building[ix][iy]!=Database.EMPTY) {
        map[x+ix][y+iy]=building[ix][iy];
        if (building[ix][iy]==Database.WALL)
          node[x+ix][y+iy].solid=true;
      }
    }
  }
}
int [][] createGrid(int sizeX, int sizeY) {
  int [][] view = new int [sizeX][sizeY];
  for (int ix=0; ix<sizeX; ix++) {
    for (int iy=0; iy<sizeY; iy++)
      view[ix][iy]=-1;
  }
  return view;
}
void clearGrid(int [][] grid) {
  for (int ix=0; ix<grid.length; ix++) {
    for (int iy=0; iy<grid[0].length; iy++) 
      grid[ix][iy]=Database.EMPTY;
  }
}
void nullGrid(int [][] grid) {
  for (int ix=0; ix<grid.length; ix++) {
    for (int iy=0; iy<grid[0].length; iy++) 
      grid[ix][iy]=Database.NULL;
  }
}
void frozenGrid(int [][] grid) {
  for (int ix=0; ix<grid.length; ix++) {
    for (int iy=0; iy<grid[0].length; iy++) 
      grid[ix][iy]=22;
  }
}
float getG (Cell start, Cell end) {
  if (start.x==end.x || start.y==end.y) 
    return 32;
  else 
  return 48;
}
float getHeuristic(Cell start, Cell target) {
  return dist(start.x*32+16, start.y*32+16, target.x*32+16, target.y*32+16);
}

void updateF(Cell current, Cell neighbor, Cell target) {
  neighbor.parent=current;
  neighbor.g=current.g+getG(current, neighbor);
  neighbor.h=getHeuristic(neighbor, target);
  neighbor.f=neighbor.g+neighbor.h;
}
boolean getDiagonal (int startX, int startY, int endX, int endY) {
  if (startX==endX || startY==endY) 
    return false;
  else 
  return true;
}
int [] getArrayDirection(int x1, int y1, int x2, int y2) {
  if (getDiagonal(x1, y1, x2, y2)) {
    if (x1>x2 && y1>y2)    //влево и вверх
      return   new int [] {72, 61, 71, 50, 70, 49, 59, 48};
    else if (x1<x2 && y1>y2)   //вправо и вверх
      return   new int [] {50, 49, 61, 72, 48, 59, 71, 70};
    else if (x1>x2 && y1<y2)   //влево и вниз
      return   new int [] {48, 59, 49, 50, 70, 61, 71, 72};
    else    //вправо и вниз
    return   new int [] {70, 59, 71, 48, 72, 49, 61, 50};
  } else {
    if (x1>x2 && y1==y2) 
      return   new int [] {71, 72, 70, 61, 59, 50, 48, 49};
    else if (x1<x2 && y1==y2) 
      return new int [] {49, 50, 48, 61, 59, 70, 72, 71};
    else if (x1==x2 && y1>y2) 
      return   new int [] {61, 50, 72, 49, 71, 48, 70, 59};
    else 
    return   new int [] {59, 48, 70, 49, 71, 50, 72, 61};
  }
}
boolean getApplyDiagonal (Cell [][] node, int x, int y, int curX, int curY, boolean light) {   //функция разрешающая, запрещающая диагональное перемещение луча света, либо перемещение
  if (getDiagonal(curX, curY, x, y)) {
    int resX1, resY1, resX2, resY2;
    resX1=resX2=curX;
    resY1=resY2=curY;
    if (curX<x && curY<y) {
      resX1=curX+1;
      resY2=curY+1;
    } else
      if (curX>x && curY>y) {
        resX1=curX-1;
        resY2=curY-1;
      } else
        if (curX>x && curY<y) { 
          resX1=curX-1;
          resY2=curY+1;
        } else 
        if (curX<x && curY>y) {
          resX1=curX+1;
          resY2=curY-1;
        }
    if (light) {  //если распространение луча света
      if (!node[resX1][resY1].through && !node[resX2][resY2].through) 
        return false;
      else 
      return true;
    } else {
      if (node[resX1][resY1].solid || node[resX2][resY2].solid) 
        return false;
      else 
      return true;
    }
  } else 
  return true;
}
boolean isNeighboring(Cell [][] node, int [][] objects, int x, int y, int id) {   //возвращает список координат соседних клеток
  int [] neighbor; 
  neighbor=new int [] {59, 48, 70, 49, 71, 50, 72, 61};
  for (int i=0; i<neighbor.length; i++) {
    int tempX=x+d.matrixShearch[neighbor[i]][0];
    int tempY=y+d.matrixShearch[neighbor[i]][1];
    if (tempX>=0 && tempX<node.length && tempY>=0 && tempY<node[0].length) {
      if (objects[tempX][tempY]==id) 
        return true;
    }
  }
  return false;
}

//операции со списками и чекпоинтами
Cells getNeighboring(Cell [][] node, Cell start, Cell target) {   //возвращает список координат соседних клеток
  Cells cells = new Cells();
  int [] neighbor;
  if (target!=null)
    neighbor = getArrayDirection(start.x, start.y, target.x, target.y);
  else 
  neighbor=new int [] {59, 48, 70, 49, 71, 50, 72, 61};
  for (int i=0; i<neighbor.length; i++) {
    int tempX=start.x+d.matrixShearch[neighbor[i]][0];
    int tempY=start.y+d.matrixShearch[neighbor[i]][1];
    if (tempX>=0 && tempX<node.length && tempY>=0 && tempY<node[0].length) {
      if ((!node[tempX][tempY].solid || node[tempX][tempY].door) && getApplyDiagonal(node, tempX, tempY, start.x, start.y, false)) 
        cells.add(node[tempX][tempY]);
    }
  }
  return cells;
}
Cells getPortals(Cell [][] node, int [][] map) {   //возвращает список координат всех дверей
  Cells portals = new Cells();
  for (int ix=0; ix<map.length; ix++) {
    for (int iy=0; iy<map[ix].length; iy++) {
      if (map[ix][iy]==Database.PORTAL) 
        portals.add(node[ix][iy]);
    }
  }
  return portals;
}
Cells getDoors(Cell [][] node, int [][] map) {   //возвращает список координат всех дверей
  Cells doors = new Cells();
  for (int ix=0; ix<map.length; ix++) {
    for (int iy=0; iy<map[ix].length; iy++) {
      if (map[ix][iy]==Database.DOOR) 
        doors.add(node[ix][iy]);
    }
  }
  return doors;
}
Cells getRoads(Cell [][] node, int [][] map) {   //возвращает список координат всех дорог
  Cells roads= new Cells();
  for (int ix=0; ix<map.length; ix++) {
    for (int iy=0; iy<map[ix].length; iy++) {
      if (map[ix][iy]==Database.ROAD) 
        roads.add(node[ix][iy]);
    }
  }
  return roads;
}
Cells getCellsFreePlace(Cell [][] node, int [][] map) {   //возвращает список доступных для размещения сущностей координат
  Cells sectors= new Cells();
  for (int ix=0; ix<map.length; ix++) {
    for (int iy=0; iy<map[ix].length; iy++) {
      if (map[ix][iy]==1 && !node[ix][iy].solid) 
        sectors.add(node[ix][iy]);
    }
  }
  return sectors;
}
Cells getPathTo(Cell [][] node, Cell start, Cell target) {
  Cells   open = new Cells ();
  Cells  close = new Cells  ();
  Cell  current;
  start.g=0;
  start.h=getHeuristic(start, target);
  start.f=start.g+start.h;
  start.parent=null;
  open.add(start);
  while (!open.isEmpty()) {
    current = open.getMinF();
    if (close.size()>1000) 
      break;
    if (current.x==target.x && current.y==target.y) 
      return getReconstructPath(target);
    open.remove(current);
    close.add(current);
    for (Cell part : getNeighboring(node, current, target)) {
      if (!close.contains(part)) {
        if (open.contains(part)) {
          if (part.g>current.g) 
            updateF(current, part, target);
        } else {
          updateF(current, part, target);
          open.add(part);
        }
      }
    }
  }
  return new Cells ();
}
Cells getReconstructPath(Cell start) {
  Cells map = new Cells ();
  Cell current=start;
  while (current.parent!=null) {
    map.add(current);
    current=current.parent;
  }
  return map;
}

class Cell {
  final int x, y;
  float g, f, h;
  Cell parent;
  boolean solid, through, open, roof, door;
  int transparent, temperature; 

  Cell(int x, int y) {
    this.x=x;
    this.y=y;
    g=f=h=0;
    parent = null;
    solid=roof=open=door=false;
    through=true;
    transparent = game.date.getDarknessValue();
    temperature = 22;
  }
}

class Cells extends ArrayList<Cell> {
  Cells sortRandom() {
    IntList sort = new IntList();
    Cells cells = new Cells();
    for (int i = 0; i<this.size(); i++)
      sort.append(i);
    sort.shuffle();
    for (int i : sort)
      cells.add(this.get(i));
    return cells;
  }
  Cell getMinF() {
    float [] s=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      s[i]=this.get(i).f;
    for (Cell part : this) {
      if (part.f==min(s)) 
        return part;
    }
    return null;
  }

  Cell getNearest(int tx, int ty) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      dist[i]=dist(this.get(i).x, this.get(i).y, tx, ty);
    for (Cell part : this) {  
      float tdist = dist(part.x, part.y, tx, ty);
      if (tdist==min(dist)) 
        return part;
    }
    return null;
  }
  Cell getFar(int tx, int ty) {
    float [] dist=new float [this.size()];
    for (int i=0; i<this.size(); i++) 
      dist[i]=dist(this.get(i).x, this.get(i).y, tx, ty);
    for (Cell part : this) {  
      float tdist = dist(part.x, part.y, tx, ty);
      if (tdist==max(dist)) 
        return part;
    }
    return null;
  }
  Cells getSortNear(int x, int y) {  //возвращает объекты начиная с самого ближайшего
    Cells cells= new  Cells();
    Cells temp= new  Cells();
    for (Cell object : this)
      temp.add(object);
    while (!temp.isEmpty()) {
      Cell  cell = temp.getNearest(x, y);
      temp.remove(cell);
      cells.add(cell);
    }
    return cells;
  }
  Cell getFreePath(Cell [][] node, int x, int y) {       //возвращает первый граф из списка до которого успешно проложен путь
    for (Cell part : this.getSortNear(x, y)) {
      if (!getPathTo(node, node[x][y], node[part.x][part.y]).isEmpty()) 
        return part;
    }
    return null;
  }
  Cells getCellsIsBorders (int sizeX, int sizeY) { //возвращает все объекты по краям карты
    Cells cells = new Cells();
    for (Cell cell : this) {
      if (cell.x==0 || cell.y==0 || cell.x==sizeX-1 || cell.y==sizeY-1)
        cells.add(cell);
    }
    return cells;
  }
  Cells getCellsEntryCoord (int x1, int y1, int x2, int y2) { //возвращает все объекты входящие в определенный диапазон координат (включительно)
    Cells cells = new Cells();
    for (Cell cell : this) {
      if (cell.x>=x1 && cell.x<=x2 && cell.y>=y1 && cell.y<=y2)
        cells.add(cell);
    }
    return cells;
  }
}


int getMatrixIndex(int [][] matrix, int x, int y) {
  for (int i=0; i<matrix.length; i++) {
    if (matrix[i][0]==x && matrix[i][1]==y)
      return i;
  }
  return -1;
}
int sign (int x) {
  return (x > 0) ? 1 : (x < 0) ? -1 : 0;
}
int [] getLineLOS(int [][] matrix, int xstart, int ystart, int xend, int yend) {   //формирует массив координат линии прямого взгляда (взято с википедии)
  IntList line = new IntList();
  int x, y, dx, dy, incx, incy, pdx, pdy, es, el, err;
  dx = xend - xstart;
  dy = yend - ystart;
  incx = sign(dx);
  incy = sign(dy);
  if (dx < 0) dx = -dx;
  if (dy < 0) dy = -dy;
  if (dx > dy) {
    pdx = incx;  
    pdy = 0;
    es = dy;  
    el = dx;
  } else {
    pdx = 0;  
    pdy = incy;
    es = dx;  
    el = dy;
  }
  x = xstart; 
  y = ystart;
  err = el/2;
  for (int t = 0; t < el; t++) {
    err -= es;
    if (err < 0) {
      err += el;
      x += incx;
      y += incy;
    } else {
      x += pdx;
      y += pdy;
    }
    int index = getMatrixIndex(matrix, x, y);
    if (index!=-1) 
      line.append(index);
  }
  return line.array();
}
int [][] generateLOS(int [][] matrix) {
  int [] borders = new int [] {5, 115, 65, 55, 66, 77, 88, 89, 100, 101, 112, 113, 114, 116, 117, 118, 107, 108, 
    97, 98, 87, 76, 54, 43, 32, 31, 20, 19, 8, 7, 6, 4, 3, 2, 13, 23, 12, 22, 33, 44};
  int [][] lineLOS = new int [borders.length][];
  for (int i = 0; i<borders.length; i++) 
    lineLOS[i]=getLineLOS(matrix, 0, 0, matrix[borders[i]][0], matrix[borders[i]][1]);
  return lineLOS;
}
PGraphics scaleGrapgics(PGraphics image, int scale) {
  int [][] pix= new int[image.width*scale] [image.height*scale];
  image.loadPixels();
  for (int px=0; px<image.width; px++) {
    for (int py=0; py<image.height; py++) {
      for (int ix = 0; ix<scale; ix++) {
        for (int iy = 0; iy<scale; iy++)
          pix[px+ix][py+iy]=image.get(px, py);
      }
    }
  }
  int newWidth = image.width*scale, newHeight = image.height*scale;
  PGraphics newImage = createGraphics(newWidth, newHeight);
  newImage.beginDraw();
  newImage.background(black);
  for (int px=0; px<newWidth; px++) {
    for (int py=0; py<newHeight; py++) {
      newImage.stroke(image.get(int(px/scale), int(py/scale)));
      newImage.point(px, py);
    }
  }
  newImage.endDraw();
  return newImage;
}
