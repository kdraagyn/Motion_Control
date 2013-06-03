bez curve1;

int i;

void setup()
{
  size(displayWidth, displayHeight);
  smooth();
  curve1 = new bez();
  frameRate(60);
}

void draw()
{
  background(255);
  backing();
  curve1.show();
}



void mouseDragged() 
{
  if (curve1.c1.clicked()) {
    curve1.c1.move(mouseX,mouseY);
  } 
  if (curve1.c2.clicked()) {
    curve1.c2.move(mouseX, mouseY);
  }
  if (curve1.a1.clicked()) {
    curve1.a1.move(mouseX,mouseY);
  } 
  if (curve1.a2.clicked()) {
    curve1.a2.move(mouseX, mouseY);
  }
}

void backing() {
  fill(180);
  rectMode(CENTER);
  rect(width / 2, height / 2, width - 40, height / 4);
  rect(width / 2, height / 6, width - 40, height / 4);
  rect(width / 2, height * 5 / 6, width - 40, height / 4);
}

class control {
  int x;
  int y;
  
  control(int a, int b) {
    x = a;
    y = b;
  }
  
  void move(int a,int b) {
    x = a;
    y = b;
  }
  
  void display() {
    fill(255,0,0);
    stroke(0);
    ellipse(x,y,15,15);
  }
  
  boolean clicked() {
    if(centerDist() <= 15) {
      return true;
    } else {
      return false;
    }
  }
  
  float centerDist() {
    float distX = abs(mouseX - x);
    float distY = abs(mouseY - y);
    float dist = sqrt(distX * distX + distY * distY);
    return dist;
  }
}

class anchor {
    int x;
    int y;
    
    anchor (int a, int b) {
      x = a;
      y = b;
    }
    
    void move (int a, int b) {
      x = a;
      y = b;
    }
    
    void display() {
      fill(100);
      stroke(0);
      ellipse(x,y,15,15);
    }
  
  boolean clicked() {
    if(centerDist() <= 15) {
      return true;
    } else {
      return false;
    }
  }
  
  float centerDist() {
    float distX = abs(mouseX - x);
    float distY = abs(mouseY - y);
    float dist = sqrt(distX * distX + distY * distY);
    return dist;
  }
}

class bez {
  control c1;
  control c2;
  anchor a1;
  anchor a2;
  float step = 120;
  float mult = .25;
  
  bez () {
    c1 = new control(width / 6, height * 5 / 9);
    c2 = new control(width * 8 / 9, height * 5 / 9);
    a1 = new anchor(20, height / 2);
    a2 = new anchor(width - 20, height / 2 - 50);
  }
  
  void show() 
  {
    c1.display();
    c2.display();
    a1.display();
    a2.display();
    noFill();
    line(a1.x, a1.y, c1.x, c1.y);
    line(a2.x, a2.y, c2.x, c2.y);
    bezier(a1.x, a1.y, c1.x, c1.y, c2.x, c2.y, a2.x, a2.y);
    for (int i = 0; i <= step; i++) {
      float t = i / step;
      float x = bezierPoint(a1.x, c1.x, c2.x, a2.x, t);
      float y = bezierPoint(a1.y, c1.y, c2.y, a2.y, t);
      ellipse(x, y, 5, 5);
    }
  }
}
