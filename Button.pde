import controlP5.*;


class Button {
  //member variables
  int x, y;
  int w, h;
  PShape shape;
  PImage image;
  controlP5.Button b;
  Button(int _x, int _y, int _w, int _h, PImage _image,ControlP5 cp5) {
    
    setPosition(_x, _y);
    setSize(_w, _h);
    b = cp5.addButton("b1")
      .setPosition(x, y)
        .setSize(w, h)
          .setImages(_image, _image, _image)
            .updateSize();
  }
  
  Button(int _x, int _y, int _w, int _h, String name, PImage _image,ControlP5 cp5) {
    
    setPosition(_x, _y);
    setSize(_w, _h);
    b = cp5.addButton(name)
      .setPosition(x, y)
        .setSize(w, h)
          .setImages(_image, _image, _image)
            .updateSize();
  }

  void draw() {
  }
  void update() {
  }


  void setPosition(int _x, int _y) {
    x = _x; 
    y = _y;
    return;
  }
  void setSize(int _w, int _h) {
    h = _h; 
    w = _w;
    return;
  }
  void setImage(String s) {
    
  }
  boolean over() {
    if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }
}

