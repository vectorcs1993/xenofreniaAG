/*
    String input = dialog.showTextInputDialog("введите количество:");
        if (input!=null) {
          if (int(input)>0) {
            count=int(input); 
            cost = d.getItem(item).getInt("cost")*count;
            buy= true;
          }
          clearAllLists();
          game.player.updateNeighbor();
        }

  void placeRandomBuildings(Cell [][] node, int [][] objects, int [][] terrain, int [][] roof, int count, int groundwork_size) {    //размещает заданнное count количество построек в случайном порядке 
    int i=0, stage=0;
    while (i<count) {
      int building = int(random(objectsData.size()));
      int [][] buildObjects = setBorderjBuilding(objectsData.get(building), groundwork_size, NULL), 
        buildTerrain = setBorderjBuilding(terrainData.get(building), groundwork_size, TERRAIN_STONE), 
        buildRoof = setBorderjBuilding(roofData.get(building), groundwork_size, EMPTY);
      int placeX = 1+int(random(objects.length-buildObjects.length-2)), 
        placeY = 1+int(random(objects[0].length-buildObjects[0].length-2));
      if (isPlaceBuildingAllow(objects, buildObjects, placeX, placeY)) {
        if (isClear(objects, buildObjects, placeX, placeY)) {
          placeBuilding(node, buildObjects, buildTerrain, buildRoof, objects, terrain, roof, placeX, placeY);
          i++;
        }
      }
      stage++;
      if (stage>count*100)
        i=count;
    }
  }
 
    void placeRandomBuildings(Cell [][] node, int [][] map, int count) {
   int i=0;
   for (int p =0; p<count; p++) {
   int building = int(random(buildingData.size()));
   int placeX = int (random(map.length-1))+i;
   int placeY = int (random(map[building].length-1));
   if (isPlaceBuildingAllow(map, buildingData.get(building), placeX, placeY)) {
   if (isClear(map, buildingData.get(building), placeX, placeY)) 
   placeBuilding(node, map, buildingData.get(building), placeX, placeY);
   i++;
   }
   }
   }
   boolean isSolid() {
    for (Cell part : this) {
      if (part.solid)
        return true;
    }
    return false;
  }
   Cells getCellsEntryCoord (int x1, int y1, int x2, int y2) { //возвращает все объекты входящие в определенный диапазон координат
    Cells cells = new Cells();
    for (Cell cell : this) {
      if (cell.x>=x1 && cell.x<x2 && cell.y>=y1 && cell.y<y2)
        cells.add(cell);
    }
    return cells;
  }
  Cells getCellsNotSolid () { //возвращает все объекты по краям карты
    Cells cells = new Cells();
    for (Cell cell : this) {
      if (!cell.solid) 
        cells.add(cell);
    }
    return cells;
  }
 
  void generatePortals(Cell[][] node, int [][] objects, int [][] grid_roads) {   //размещение порталов
    Cells freeSectors = getCellsFreePlace(node, grid_roads).getCellsNotSolid().getCellsIsBorders (grid_roads.length, grid_roads[0].length);   
    Cells entry = freeSectors.getCellsEntryCoord(0, 0, 1, grid_roads[0].length-1);
    int placeEntry = int (random(entry.size()-1));   
    Cells exit = freeSectors.getCellsEntryCoord(grid_roads.length-1, 0, grid_roads.length, grid_roads[0].length);
    int placeExit = int (random(exit.size()-1));
    objects[entry.get(placeEntry).x][entry.get(placeEntry).y]=objects[exit.get(placeExit).x][exit.get(placeExit).y]=PORTAL;  //размещает портал  <<<вот здесь
    grid_roads[entry.get(placeEntry).x][entry.get(placeEntry).y]=grid_roads[exit.get(placeExit).x][exit.get(placeExit).y]=EMPTY; //удаляет дорогу под порталом
  }
  
  
  
  void drawBorderViewSegment(int x, int y) {
    pushMatrix();
    translate(x*room.window.size_grid-room.window.size_grid/2, y*room.window.size_grid-room.window.size_grid/2);
    rect(0, 0, room.window.size_grid, room.window.size_grid);
    popMatrix();
  }
  void drawView(int view, color _color) { //отображает секту прямой видимости
   
     int n=0; //формирование матриц поиска 
     for (int ix=-5; ix<6; ix++) {
     for (int iy=-5; iy<6; iy++) {
     text(n, d.matrixShearch[n][0]*game.size_grid+game.size_grid/2, d.matrixShearch[n][1]*game.size_grid+game.size_grid/2); 
     n++;
     }
     }
     
     
    pushStyle();
    stroke(_color);
    noFill();
    for (int l=0; l<d.matrixLine.length; l++) {
      int px=x, py=y;
      for (int i=0; i<constrain(view, 1, d.matrixLine[l].length); i++) { 
        int ix=d.matrixShearch[d.matrixLine[l][i]][0];
        int iy=d.matrixShearch[d.matrixLine[l][i]][1];
        int gx=constrain(x+ix, 0, room.sizeX-1);
        int gy=constrain(y+iy, 0, room.sizeY-1);
        if (!getApplyDiagonal(room.node, gx, gy, px, py, true))
          break;
        px=gx;
        py=gy;
        if ((ix!=0 || iy!=0) && ix>=-x && iy>=-y && x+ix<=room.sizeX-1 && iy+y<=room.sizeY-1) { 
          pushMatrix();
          translate(ix*room.window.size_grid, iy*room.window.size_grid);
          point(0, 0);
          popMatrix();
        }
        if (room.node[gx][gy].solid && !room.node[gx][gy].through) {
          drawBorderViewSegment(ix, iy);
          break;
        }
        if (i==constrain(view, 1, d.matrixLine[l].length)-1) 
          drawBorderViewSegment(ix, iy);
      }
    }
    popStyle();
  }


  void drawBullet(int x0, int y0, int x1, int y1) {
    pushStyle();
    strokeWeight(4);
    int dx, dy;
    if (x0<x1)
      dx = 1;
    else if (x0>x1)
      dx=-1;
    else 
    dx=0;
    if (y0<y1)
      dy = 1;
    else if (y0>y1)
      dy = -1;
    else 
    dy=0;
    line((x0-window.posX)*window.size_grid+window.size_grid/2+(dx*window.size_grid/2), 
      (y0-window.posY)*window.size_grid+window.size_grid/2+(dy*window.size_grid/2), 
      (x1-window.posX)*window.size_grid+window.size_grid/2, 
      (y1-window.posY)*window.size_grid+window.size_grid/2);
    popStyle();
  }





*/
