import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList;

public class Project3D extends PApplet {



ArrayList<Presa> presas = new ArrayList<Presa>();

int x = 500;
int y = 500;
int z = 500;

int numPresas = 10;

public void setup() {
    
    textureWrap(CLAMP);

    for(int i = 0; i < numPresas ; i++){
        presas.add(new Presa());
    }
}

public void draw() {
    background(204);
    for(Presa p :presas)
        p.dibujar();
}

class Entidad {
    public PVector convPolar(PVector coord){
        float h = sqrt(sq(coord.x) + sq(coord.y));
        float theta = acos(coord.x/h);

        return new PVector(h, theta);
    }
}

class Presa extends Entidad {
    
    PVector pos;
    PVector velocity;

    PShape shape;
    PImage piel;
    int pielNumber;

    float personalDistance = 10f;
    float visionDistance = 50f;

    Presa(){
        // Movimiento y posicionamiento
        pos = new PVector(random(x), z-50, random(z));
        // pos = new PVector(100, 100, 0);
        velocity = new PVector(random(-1, 1), random(-1, 1));

        // Pieles 
        pielNumber = (int) random(13);
        piel = loadImage("skins/1.PNG");
        shape = loadShape("fish.obj");
        shape.setTexture(piel);
        
    }

    public void dibujar(){
        
        PVector direction = convPolar(velocity);

        pushMatrix();

        translate(pos.x, pos.y ,-pos.z);
        scale(20);
        rotateX(PI/2);
        rotateZ(direction.y);
        shape(shape, 0, 0);

        popMatrix();
    }

}
  public void settings() {  size(500, 500, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Project3D" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
