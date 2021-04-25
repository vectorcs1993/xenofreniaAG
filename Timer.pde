class Timer {
  boolean flag;
  long timing;
  float set;
  Timer() {  
    flag=false;
  }
  void set(float set) {
    timing=millis();
    flag=true;
    this.set=set;
  }
  void tick() {
    if (millis() - timing > set)
      flag=false;
    else 
    flag=true;
  }
  long getTime() {
    return millis() - timing;
  }
}
