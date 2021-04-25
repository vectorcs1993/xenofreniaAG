class Items extends IntList {

  IntList sortId() {                     //сортирует и возвращает множество отсортированное
    IntList itemsList= new IntList(); 
    for (int part : this) {
      if (!itemsList.hasValue(part)) 
        itemsList.append(part);
    }
    return itemsList;
  }
  int getCount(int id) {               //пересчет количества одинаковых предметов в списке
    int total=0;
    for (int part : this) {
      if (part==id) 
        total++;
    }
    return total;
  }
  void addAll(Items items) {
    for (int part : items) 
      this.append(part);
  }
  int getAllWeight() {
    int allWeight=0;
    for (int item : this) {
      allWeight+=d.getItem(item).getInt("weight");
    }
    return allWeight;
  }
}
