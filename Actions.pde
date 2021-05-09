AGAction getObjectInfo, getLayerInfo, lightOn, lightOff, noteRead, getAllItemsFromObjectInItems, putAllItemsFromContainer, 

  getItemInfo, getWearInfo, itemThrow, itemThrowAll, itemPut, itemPutAll, itemEat, itemDrink, itemUse, 

  entityAtack, 

  buyAllItems, 
  objectDestroy;

Runnable getAllItemFromItems, putAllItemForItems, getItemFromItems, putItemForItems, setItemWear, removeItemWear, closeDoor, openDoor, lockDoor, unlockDoor, 
  throwItemForEntity, buyItem, objectCreate;

void createActions() {


  objectDestroy = new AGAction ("разобрать", new Runnable() {
    public void run() {
      AGObject object =game.room.getAllObjects().getAGObject(mainList.select.id);
      game.room.removeObject(object);

      game.room.forTick(1);
      game.player.updateNeighbor();
    }
  }
  );
  objectCreate = new Runnable() {  //
    public void run() {
    }
  };
  setItemWear = new Runnable() {  //функция надевает какое либо снаряжение из инвентаря на часть тела игрока
    public void run() {
      int item = mainList.select.id;
      int itemEquip = game.player.parts.get(d.getItem(item).getInt("body"));
      if (itemEquip!=-1)
        game.player.items.append(itemEquip);
      game.player.parts.put(d.getItem(item).getInt("body"), item);
      game.player.items.removeValue(item);
      clearAllLists();
      game.room.forTick(1);
      loadMainListInventory(game.player);
    }
  };
  removeItemWear = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      int item = game.player.parts.get(mainList.select.id);
      game.player.parts.put(d.getItem(item).getInt("body"), -1);
      game.player.items.append(item);
      clearAllLists();
      game.room.forTick(1);
      loadMainListEquip(game.player);
    }
  };
  buyItem = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      AGObject object = game.room.markets.getAGObject(mainList.select.id);
      int item = secondList.select.id, 
        fragments_cost = game.player.items.getCount(AGData.FRAGMENT);
      AGMarket market = (AGMarket)object;
      boolean buy = false;
      Integer count, 
        cost = d.getItem(item).getInt("cost");
      if (market.items.getCount(item)>1) {
        count = dialog.showSlider(
          "Выбор значения", // question
          "Укажите количество", // title
          1, // range: start value
          market.items.getCount(item), // market.items.getCount(item), // range: end value
          1, // initial value
          market.items.getCount(item)-1, // steps for ticks with value
          1);
        if (count!=null) {
          cost = d.getItem(item).getInt("cost")*count;
          buy= true;
          clearAllLists();
          game.player.updateNeighbor();
        }
      } else {
        buy = true;
        count = 1 ;
      }
      if (buy && count!=null) {
        if (fragments_cost>=cost) {
          for (int i = 0; i<count; i++) {
            game.player.items.append(item);
            market.items.removeValue(item);
          }
          for (int i = 0; i<cost; i++) 
            game.player.items.removeValue(AGData.FRAGMENT);
          game.room.forTick(1);
          game.printConsole("вы купили: "+d.getItem(item).getString("name")+" x"+count+", стоимость: "+cost+
            " остаток: "+game.player.items.getCount(AGData.FRAGMENT), false);
        } else
          game.printConsole("не хватает осколков для покупки: "+d.getItem(item).getString("name")+", стоимость: "+cost+
            " остаток: "+game.player.items.getCount(AGData.FRAGMENT), false);
      }
    }
  };
  closeDoor = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      AGDoor door = (AGDoor)game.room.doors.getAGObject(mainList.select.id);
      door.open = false;
      game.room.node[door.x][door.y].through=door.getThrough();
      game.room.node[door.x][door.y].solid=door.getSolid();
      clearAllLists();
      game.room.forTick(1);
    }
  };
  openDoor = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      AGDoor door = (AGDoor)game.room.doors.getAGObject(mainList.select.id);
      door.open = true;
      game.room.node[door.x][door.y].through=door.getThrough();
      game.room.node[door.x][door.y].solid=door.getSolid();
      clearAllLists();
      game.room.forTick(1);
    }
  };
  lockDoor = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      AGDoor door = (AGDoor)game.room.doors.getAGObject(mainList.select.id);
      door.lock = true;
      game.room.node[door.x][door.y].through=door.getThrough();
      game.room.node[door.x][door.y].solid=door.getSolid();
      clearAllLists();
      game.room.forTick(1);
    }
  };
  unlockDoor = new Runnable() {  //функция убирает какое либо снаряжение из части тела игрока и кладет в инвентарь
    public void run() {
      AGDoor door = (AGDoor)game.room.doors.getAGObject(mainList.select.id);
      door.lock = false;
      game.room.node[door.x][door.y].through=door.getThrough();
      game.room.node[door.x][door.y].solid=door.getSolid();
      clearAllLists();
      game.room.forTick(1);
    }
  };
  throwItemForEntity = new Runnable() {
    public void run() {
      AGEntity enemy = (AGEntity)game.room.entities.getAGObject(mainList.select.id);
      int item = secondList.select.id;
      game.player.items.removeValue(item);
      game.room.bullets.add(new Bullet(new PVector(game.player.x, game.player.y), enemy.x, enemy.y, d.getItemSprite(item)));
      if (game.player.isHit(enemy.x, enemy.y)) {
        int damage = int(random(d.getItem(item).getInt("weight")))+1;
        game.printConsole(game.player.getName()+" наносит "+damage+" повреждений "+enemy.getName()+" бросив в него "+d.getItem(item).getString("name"), true);
        enemy.hp-=damage;
        game.player.checkKill(enemy);
      } else
        game.printConsole(game.player.getName()+" промахнулся", true);
      game.room.dropItem(enemy.x, enemy.y, item, 1);
      clearAllLists();
      game.room.forTick(1);
    }
  };
  getItemFromItems = new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjectsInItems().getAGObject(mainList.select.id);
      int item = secondList.select.id;
      if (object instanceof capacity) {
        ((capacity)object).getItems().removeValue(item);
        game.player.items.append(item);
      } 
      clearAllLists();
      game.room.forTick(1);
    }
  };
  getAllItemFromItems = new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjectsInItems().getAGObject(mainList.select.id);
      int item = secondList.select.id;
      if (object instanceof capacity) {
        while (((capacity)object).getItems().hasValue(item)) {
          ((capacity)object).getItems().removeValue(item); 
          game.player.items.append(item);
        }
      }
      clearAllLists();
      game.room.forTick(1);
    }
  };
  putAllItemForItems = new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjectsInItems().getAGObject(mainList.select.id);
      int item = secondList.select.id;
      if (object instanceof capacity) {
        while (game.player.items.hasValue(item)) {
          game.player.items.removeValue(item); 
          ((capacity)object).getItems().append(item);
        }
      }
      clearAllLists();
      game.room.forTick(1);
    }
  };
  putItemForItems = new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjectsInItems().getAGObject(mainList.select.id);
      int item = secondList.select.id;
      if (object instanceof capacity) {
        ((capacity)object).getItems().append(item);
        game.player.items.removeValue(item);
      }
      clearAllLists();
      game.room.forTick(1);
    }
  };
  getObjectInfo = new AGAction ("информация", new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjects().getAGObject(mainList.select.id);
      String info = object.getName()+" расстояние: "+game.player.matrixView[object.x][object.y];
      if (object instanceof AGEntity) {
        AGEntity entity = (AGEntity) object;
        if (entity.hp<=0) 
        info+=" (труп)";
        else {
          info+=", здоровье: "+entity.hp+"/"+entity.getHpMax()+", характер: "+d.getDescriptCharacter(entity.character)+", атака: "+entity.getWeaponClass()+
            ", защита: "+entity.getArmorClass();
          if (entity instanceof AGHuman) {
            AGHuman human = (AGHuman)entity;
            info+=", в руках: "+human.getDescriptWeapons();
          }
        }
      }
      game.printConsole("вы видите: "+info, false);
      clearAllLists();
      game.player.updateNeighbor();
    }
  }
  );
  getLayerInfo = new AGAction ("информация", new Runnable() {
    public void run() {
      AGObject object = game.room.layer[mainList.select.id-(int(mainList.select.id/game.room.sizeX)*game.room.sizeX)][int(mainList.select.id/game.room.sizeX)];
      String info = object.getName();
      game.printConsole("вы видите: "+info, false);
      clearAllLists();
      game.player.updateNeighbor();
    }
  }
  );
  entityAtack = new AGAction ("атаковать", new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjects().getAGObject(mainList.select.id);
      AGEntity entity = (AGEntity) object;
      if (game.player.isAllowAtack()) {
        game.player.atack(entity);
        game.room.forTick(1);
      }
      clearAllLists();
      game.player.updateNeighbor();
    }
  }
  );
  getItemInfo = new AGAction ("информация", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      game.printConsole("у вас в инвентаре:\n"+d.getDescriptItem(item), false);
      clearAllLists();
      loadMainListInventory(game.player);
    }
  }
  );
  getWearInfo = new AGAction ("информация", new Runnable() {
    public void run() {
      int item = game.player.parts.get(mainList.select.id);
      if (item!=-1) 
      game.printConsole("слот снаряжения: "+d.getNameEquip(mainList.select.id)+", содержимое: "+d.getDescriptItem(item), false);
      else 
      game.printConsole("слот снаряжения: "+d.getNameEquip(mainList.select.id)+", содержимое: пусто", false);
      clearAllLists();
      loadMainListEquip(game.player);
    }
  }
  );
  lightOn = new AGAction ("включить", new Runnable() {
    public void run() {
      AGLight  light = (AGLight)game.room.getAllObjects().getAGObject(mainList.select.id);
      light.on=true;
      game.room.forTick(1);
    }
  }
  );
  lightOff = new AGAction ("выключить", new Runnable() {
    public void run() {
      AGLight  light = (AGLight)game.room.getAllObjects().getAGObject(mainList.select.id);
      light.on=false;
      game.room.forTick(1);
    }
  }
  );
  noteRead = new AGAction ("читать надпись", new Runnable() {
    public void run() {
      AGWall  wall = (AGWall)game.room.getAllObjects().getAGObject(mainList.select.id);
      game.printConsole("вы читаете надпись: "+wall.note, false);
    }
  }
  );
  itemThrow = new AGAction ("выбросить", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      if (game.room.dropItem(game.player.x, game.player.y, item, 1)) {
        game.player.items.removeValue(item);
        clearAllLists();
        game.room.forTick(1);
        loadMainListInventory(game.player);
      }
    }
  }
  );
  buyAllItems = new AGAction ("купить все", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      if (game.room.dropItem(game.player.x, game.player.y, item, game.player.items.getCount(item))) {
        while (game.player.items.hasValue(item))
        game.player.items.removeValue(item);
        clearAllLists();
        game.room.forTick(1);
        loadMainListInventory(game.player);
      }
    }
  }
  );
  itemThrowAll = new AGAction ("выбросить все", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      if (game.room.dropItem(game.player.x, game.player.y, item, game.player.items.getCount(item))) {
        while (game.player.items.hasValue(item))
        game.player.items.removeValue(item);
        clearAllLists();
        game.room.forTick(1);
        loadMainListInventory(game.player);
      }
    }
  }
  );
  getAllItemsFromObjectInItems = new AGAction ("взять все", new Runnable() {
    public void run() {
      AGObject object = game.room.getAllObjectsInItems().getAGObject(mainList.select.id);
      if (object instanceof capacity) {
        game.player.items.addAll(((capacity)object).getItems());
        ((capacity)object).clearItems();
      } 
      clearAllLists();
      game.room.forTick(1);
    }
  }
  );
  putAllItemsFromContainer = new AGAction ("положить все", new Runnable() {
    public void run() {
      AGContainer objectContainer = (AGContainer)game.room.containers.getAGObject(mainList.select.id);
      objectContainer.items.addAll(game.player.items);
      game.player.items.clear();
      clearAllLists();
      game.room.forTick(1);
    }
  }
  );
  itemPut = new AGAction ("взять", new Runnable() {
    public void run() {
      AGItem objectItem = (AGItem)game.room.items.getAGObject(mainList.select.id);
      game.player.items.append(objectItem.type);
      objectItem.count--;
      if (objectItem.count<=0)
      game.room.items.remove(objectItem);
      clearAllLists();
      game.room.forTick(1);
    }
  }
  );
  itemPutAll = new AGAction ("взять все", new Runnable() {
    public void run() {
      AGItem objectItem = (AGItem)game.room.items.getAGObject(mainList.select.id);
      for (int i=0; i<objectItem.count; i++)
      game.player.items.append(objectItem.type);
      game.room.items.remove(objectItem);
      clearAllLists();
      game.room.forTick(1);
    }
  }
  );
  itemUse = new AGAction ("использовать", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      JSONObject itemObject = d.getItem(item);
      game.player.hp+=itemObject.getInt("effect");
      game.player.items.removeValue(item);
      clearAllLists();
      game.room.forTick(1);
      loadMainListInventory(game.player);
    }
  }
  );
  itemDrink = new AGAction ("выпить", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      JSONObject itemObject = d.getItem(item);
      game.player.thirst+=itemObject.getInt("effect");
      game.player.items.removeValue(item);
      clearAllLists();
      game.room.forTick(1);
      loadMainListInventory(game.player);
    }
  }
  );
  itemEat = new AGAction ("сьесть", new Runnable() {
    public void run() {
      int item = mainList.select.id;
      JSONObject itemObject = d.getItem(item);
      game.player.hunger+=itemObject.getInt("effect");
      game.player.items.removeValue(item);
      clearAllLists();
      game.room.forTick(1);
      loadMainListInventory(game.player);
    }
  }
  );
}



class AGAction {
  int id;
  String name;
  Runnable script;
  PImage sprite;

  AGAction(String name, Runnable script) {
    this (-1, name, null, script);
  }
  AGAction(int id, String name, PImage sprite, Runnable script) {
    this.name=name;
    this.script=script;
    this.id=id;
    this.sprite = sprite;
  }
}


class Actions extends ArrayList <AGAction> {
}
