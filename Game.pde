class AGGame extends ActiveElement {
  AGRoom room;
  AGRoom [][] global_room;
  PGraphics global_map;
  ArrayList <Timer> timers;
  Date date;
  int posX, posY, windowX, windowY, speed, size_grid;
  AGPlayer player;

  AGGame(float x, float y, float w, float h, int size_grid) {
    super(x, y, w, h);
    windowX=int(w);
    windowY=int(h);
    this.size_grid=size_grid;
    width=windowX*size_grid;
    height=windowY*size_grid;
    posX=posY=0;
    room=null;
    timers = new ArrayList <Timer>();
    date = new Date (12, 5, 2057);
    speed=100;
    global_room = new AGRoom [10][10];
    global_map = null;
    player = null;
  }
  void generateRooms() {
    for (int ix = 0; ix<5; ix++) {
      for (int iy = 0; iy<5; iy++)
        global_room[ix][iy] = d.getGenerateRoom(ix, iy, 5, 5, 40, 40, "комната ["+str(ix)+":"+str(iy)+"]");
    }
    global_map = createGlobalMap();
  }
  void nextRoom(AGRoom room, AGPlayer player) {  //перемещает игрока в случайную комнату 
    if (player.x==0 ) 
      setSession(global_room[room.x-1][room.y], player);
    else if (player.y==0)
      setSession(global_room[room.x][room.y-1], player);
    else if (player.x==room.sizeX-1)
      setSession(global_room[room.x+1][room.y], player);
    else if (player.y==room.sizeY-1)
      setSession(global_room[room.x][room.y+1], player);
  }
  void setSession(AGRoom room, AGPlayer player) {
    this.room=room;
    this.player=player;
    AGPortal portal = null;
    if (player.x==0)
      portal = room.portals.getObjectArea(room.sizeX-2, 0, room.sizeX-1, room.sizeY-1);
    else if (player.y==0)
      portal = room.portals.getObjectArea(0, room.sizeY-2, room.sizeX-1, room.sizeY-1);
    else if (player.x==room.sizeX-1)
      portal = room.portals.getObjectArea(0, 0, 1, room.sizeY-1);
    else if (player.y==room.sizeY-1)
      portal = room.portals.getObjectArea(0, 0, room.sizeX-1, 1);
    if (portal!=null)
      room.setPlayer(player, portal.x, portal.y);
    else {
      Cells freeSectors = getCellsFreePlace(room.node, room.roads);
      int start = int (random(freeSectors.size()-1));
      room.setPlayer(player, freeSectors.get(start).x, freeSectors.get(start).y);
    }
    posX=player.x-int(windowX/2);
    posY=player.y-int(windowY/2);
    printConsole(player.getName()+" попадает на локацию: "+room.name, true);
  }
  void printConsole(String text, boolean timing) {
    if (text.length()>0) {
      String [] str =split(console.getText(), "\n");
      if (str.length>20) 
        console.setText(join(subset(str, 0, 20), "\n"));
      if (timing)
        text="["+date.getDate()+"] "+text+"\n"+console.getText();
      else
        text=text+"\n"+console.getText();
      console.setText(text).scroll(0);
    }
  }
  void display() {
    drawMap.setActive(false);


    background(hud1);
    stroke(white);
    fill(black);
    rect(x-1, y-1, width+2, height+2);
    fill(hud1);
    rect(1, 1, 641, 29);
    pushMatrix();
    translate(x, y);
    if (room!=null && player!=null)
      room.draw();
    popMatrix();
    fill(white);
    text(date.getDescript(), 352, 22);
    text(date.getDate(), 480, 22);
    menuPlayer.control();
    pushStyle();
    stroke(white);
    noFill();
    rect(645, 32, 444, 222);
    if (menuPlayer.select.event.equals("person")) {
      if (player!=null) {
        pushMatrix();
        translate(650, 60);
        drawParameter(0, 0, 224, "имя", player.getName(), green);
        if (player.hp*100/player.getHpMax()>50)
          drawParameter(0, 20, 224, "здоровье", player.hp+"/"+player.getHpMax(), green);
        else {
          if (frameCount%40<40/2) 
            drawParameter(0, 20, 224, "!здоровье", player.hp+"/"+player.getHpMax(), red);
        }
        drawParameter(0, 40, 224, "опыт", str(player.exp), yellow);
        drawParameter(0, 60, 224, "атака", str(player.getWeaponClass()), white);
        drawParameter(0, 80, 224, "дальность атаки", str(player.getViewAtack()), white);
        drawParameter(0, 100, 224, "обзор", str(player.view), white);
        drawParameter(0, 120, 224, "защита", str(player.getArmorClass()), white);
        if (player.getItemsAllWeight()<=player.getCapacity())
          drawParameter(0, 140, 224, "груз", player.getItemsAllWeight()+"/"+player.getCapacity(), white);
        else {
          if (frameCount%40<40/2) 
            drawParameter(0, 140, 224, "!груз", player.getItemsAllWeight()+"/"+player.getCapacity(), red);
        }
        //отображение потребностей
        if (player.thirst<80)
          drawParameter(244, 0, 160, "жажда", str(player.thirst), green);
        else { 
          if (frameCount%40<40/2) 
            drawParameter(244, 0, 160, "!жажда", str(player.thirst), red);
        }
        if (player.hunger<80)
          drawParameter(244, 20, 160, "голод", str(player.hunger), green);
        else {
          if (frameCount%40<40/2) 
            drawParameter(244, 20, 160, "!голод", str(player.hunger), red);
        }
        popMatrix();
      }
    } else if (menuPlayer.select.event.equals("need_person")) {
      if (player!=null) {
        pushMatrix();
        translate(650, 60);

        popMatrix();
      }
    } else if (menuPlayer.select.event.equals("map")) {
      pushMatrix();
      translate(650, 42);
      pushStyle();
      noStroke();
      fill(black);
      rect(0, 0, room.sizeX*5, room.sizeY*5);
      room.drawMap(5);
      if (frameCount%40<40/2) 
        room.drawMapEntity(5);
      popStyle();
      popMatrix();
      fill(white);
      text("местность: "+room.name+
        "\nпозиция: x:"+player.x+", y:"+player.y+
        "\nтемпература: "+room.temperature[player.x][player.y]+" град. C", 860, 64);
    } else if (menuPlayer.select.event.equals("global_map")) {
      pushMatrix();
      translate(650, 42);
      pushStyle();
      drawGlobalMap();

      popStyle();
      popMatrix();
      drawMap.setActive(true);
    }
    popStyle();
    text("FPS: "+int(frameRate)+
      "\nMU: " + ((rt.totalMemory() - rt.freeMemory()) / 1024) / 1024+ " MB"+
      "\nmouse x: "+mouseX+
      "\nmouse y: "+mouseY+
      "\nabs x: "+int((mouseX-x)/size_grid)+
      "\nabs y: "+int((mouseY-y)/size_grid), 18, 50);
  }
  PGraphics createGlobalMap() {
    PGraphics map = createGraphics(5*40, 5*40);
    map.beginDraw();
    for (int ix = 0; ix<5; ix++) {
      for (int iy = 0; iy<5; iy++) {
        for (int ixr=0; ixr<global_room[ix][iy].buildings.length; ixr++) {
          for (int iyr=0; iyr<global_room[ix][iy].buildings[ixr].length; iyr++) {
            if (global_room[ix][iy].node[ixr][iyr].open) {
              if (global_room[ix][iy].buildings[ixr][iyr]!=0) {
                if (global_room[ix][iy].buildings[ixr][iyr]==Database.WALL) {
                  map.stroke(white);
                  map.point(ix*40+ixr, iy*40+iyr);
                } else if (global_room[ix][iy].buildings[ixr][iyr]==Database.TREE) {
                  map.stroke(green);
                  map.point(ix*40+ixr, iy*40+iyr);
                }
              }
            }
          }
        }
      }
    }
    map.endDraw();
    return map;
  }
  void drawGlobalMap() {
    fill(black);
    rect(0, 0, room.sizeX*5, room.sizeY*5);
    image(global_map, 0, 0);
    for (int ix = 0; ix<5; ix++) {
      for (int iy = 0; iy<5; iy++) {
        // noFill();
        // stroke(gray);
        // rect(ix*player.room.sizeX+1, iy*player.room.sizeY+1, player.room.sizeX-2, player.room.sizeY-2); //края комнат
        if (player.room.x==ix && player.room.y==iy) {  //отображение игрока
          if (frameCount%40<40/2) {
            fill(yellow);
            rect(ix*player.room.sizeX+player.x-2, iy*player.room.sizeY+player.y-2, 4, 4);
          }
        }
      }
    }
  }



  void tick() {
    for (Timer part : timers)                                                                       //отсчет таймеров
      part.tick();
  }
  class Date {
    int minute, hour, day, month, year;
    Timer timer;
    Date (int day, int month, int year) {
      minute=hour=0;
      this.day=day;
      this.month=month;
      this.year=year;
      timer = new Timer();
      timers.add(timer);
    }
    Date (int day, int month, int year, int hour, int minute) {
      this(day, month, year);
      this.minute=minute;
      this.hour=hour;
    }
    void setDateFromString(String dateStr) {
      day = int(dateStr.substring(6, 8));
      month = int(dateStr.substring(9, 11));
      year = int(dateStr.substring(12, 16));
      hour = int(dateStr.substring(0, 2));
      minute = int(dateStr.substring(3, 5));
    }
    int getDarknessValue() {
      if (hour>=18 && hour<24) {
        return int(map((hour*60)+minute, 18*60, 24*60, 255, 70));
      } else if (hour>=0 && hour<=5) {
        return int(map(hour*60, 0, 5*60, 70, 80));
      } else if (hour>=6 && hour<11) {
        return int(map((hour*60)+minute, 6*60, 11*60, 80, 235));
      } else {
        return int(map((hour*60)+minute, 10*60, 17*60, 235, 255));
      }
    }
    String getDescript() {
      if (hour>=18 && hour<24) {
        return "вечер";
      } else if (hour>=0 && hour<=5) {
        return "ночь";
      } else if (hour>=6 && hour<11) {
        return "утро";
      } else {
        return "день";
      }
    }
    void tick() {
      minute++;
      if (minute>59) {
        minute=0;
        hour++;
        if (hour>23) {
          hour=0;
          day++;
          if (day>30) {
            day=1;
            month++;
            if (month>11) 
              year++;
          }
        }
      }
    }
    String isNotZero(int num) {
      if (num<10)
        return "0"+str(num);
      else
        return str(num);
    }
    String getDateNotTime() {
      return  isNotZero(day)+"."+isNotZero(month)+"."+year;
    }
    String getDate() {
      return  isNotZero(hour)+":"+isNotZero(minute)+" "+isNotZero(day)+"."+isNotZero(month)+"."+year;
    }
    String getTime() {
      return  isNotZero(hour)+":"+isNotZero(minute);
    }
  }
  Date getDateFromString(String dateStr) {
    if (dateStr!=null) {
      int day = int(dateStr.substring(6, 8));
      int month = int(dateStr.substring(9, 11));
      int year = int(dateStr.substring(12, 16));
      int hour = int(dateStr.substring(0, 2));
      int minute = int(dateStr.substring(3, 5));
      return new Date(day, month, year, hour, minute);
    } else 
    return null;
  }
}
