class Cazador{

    PVector colorReplace = new PVector(255, 255, 158);

    PVector pos;
    PVector velocity;

    PShape shape;
    PImage piel;
    int pielNumber;

    float personalDistance;
    float visionDistance;
    float reproductiveDistance;

    // Edad
    float edad;
    float edadEserada;
    float edadReproduccion;

    // Energia
    float energia;
    float energiaMaxima;
    float energiaMovimiento;
    float energiaReproduccion;

    Cazador(){
        // pos = new PVector(random(width), random(height));
        pos = new PVector(random(width/2), random(height/2));
        velocity = new PVector( random(-1, 1), random(-.2, .2) );

        // Vision
        personalDistance = random(10, 15);
        visionDistance = random(40, 50);
        reproductiveDistance = random(personalDistance, visionDistance-5);

        // Pieles 
        pielNumber = (int) random(1, 13);
        piel = loadImage("skins/" + pielNumber + ".PNG");
        cambiarColorImagen();
        shape = loadShape("fish.obj");
        shape.setTexture(piel);

        // Edad
        edad = 0;
        edadEserada = random(5, 7);
        edadReproduccion = random(edadEserada/2, edadEserada);

        // Energia
        energiaMaxima = random(5, 15);
        energia = energiaMaxima * 0.6;
        energiaMovimiento = 0.005; 
        energiaReproduccion = random(energiaMaxima/5 ,energiaMaxima/3); 
    }

    Cazador(ArrayList<Float> genoma){

        // personalDistance
        // visionDistance
        // reproductiveDistance
        // edadEserada
        // edadReproduccion
        // energiaMaxima
        // energiaMovimiento
        // energiaReproduccion

        // print( "Posicion: ",genoma.get(9), genoma.get(10));

        pos = new PVector( genoma.get(9), genoma.get(10));
        velocity = new PVector( random(-1, 1), random(-.2, .2) );

        // Pieles 
        // println(genoma);
        pielNumber = (int) genoma.get(0).floatValue();
        piel = loadImage("skins/" + pielNumber + ".PNG");
        shape = loadShape("fishReduced.obj");
        shape.setTexture(piel);

        // Edad
        edad = 0;
        edadEserada = genoma.get(4);
        edadReproduccion = genoma.get(5);

        // Energia
        energiaMaxima = genoma.get(6);
        energia = energiaMaxima * 0.6;
        energiaMovimiento = 0.01; 
        energiaReproduccion = genoma.get(7); 

        // Vision
        personalDistance = genoma.get(1);
        visionDistance =genoma.get(2);
        reproductiveDistance = genoma.get(3);
    }

    void cambiarColorImagen(){
        piel.loadPixels();
        for (int i = 0; i < piel.pixels.length; i++) {
            color c = piel.pixels[i];
            PVector colorVector = new PVector( red(c), green(c), blue(c));
            float distace = PVector.dist(colorVector, colorReplace);
            if(distace < 200 ){
                piel.pixels[i] = color(255, 0, 0);
            }
        }
        piel.updatePixels();
    }

    void draw(){
        PVector direction = convPolar(velocity);
        PVector dir = velocity.copy();
        pushMatrix();   

        translate(pos.x, pos.y);
        scale(10 + edad);
        // scale(10);
        rotateX(PI/2 );
        rotateZ(PI/2);
        rotateX(- direction.y );
        shape(shape, 0, 0);

        popMatrix();

        fill(color(255, 0,0));
        rect(pos.x - 5, pos.y - 2, 10, 4);
        fill(color(0,0,255));
    }

    PVector convPolar(PVector coord){
        float h = sqrt(sq(coord.x) + sq(coord.y));
        float theta = acos(coord.x/h);

        return new PVector(h, theta);
    }

    // Calc Flock

    void move(){
        pos.add(velocity);
        testPosition();
        energia -= energiaMovimiento;
    }
    
    void testPosition(){
        float x = pos.x % width;

        float y = pos.y % height;

        x = (x < 0)
        ? x + width
        : x;

        y = (y < 0)
        ? y + height
        : y;

        pos.set(x, y);
    }

    void calcFlock(ArrayList<Boid> boidList, ArrayList<Cazador> nearHunters){
        PVector force = new PVector(0,0);

        ArrayList<Boid> nearBoids = new ArrayList<Boid>();
        for(Boid boid : boidList){
            float distace = PVector.dist(pos, boid.pos);
            if(distace < visionDistance )
                nearBoids.add(boid);
        }

        PVector border = caclBorder();
        PVector huntering = caclHunter(boidList);
        PVector reproduction = caclReproduction(nearHunters);

        huntering.normalize();
        border.normalize();
        reproduction.normalize();

        huntering.mult( (energia - 2 == energiaMaxima) 
         ?.2
         : 1.
        );
        border.mult(1.5);

        boolean wantToReproduce = 
            edad >= edadReproduccion && 
            energia >= energiaReproduccion;


        force.add(border);
        force.add(wantToReproduce ? reproduction : huntering);

        force.limit(0.5);
        velocity.add(force);
        velocity.limit(2.1);
    }

    PVector caclHunter(ArrayList<Boid> nearBoids){
        PVector force = null;
        float distance = w;
        for(Boid boid : nearBoids){
            float auxDistace = PVector.dist(pos, boid.pos);
            if(distance > auxDistace ){
                distance = auxDistace;
                force =  PVector.sub(boid.pos, pos);
            }
        }

        return force;
    }

    PVector caclReproduction(ArrayList<Cazador> nearHunters){
        PVector force = null;
        float distance = w;
        for(Cazador hunter : nearHunters){
            float auxDistace = PVector.dist(pos, hunter.pos);
            if(distance > auxDistace ){
                distance = auxDistace;
                force =  PVector.sub(hunter.pos, pos);
            }
        }

        return force;
    }

    PVector caclBorder(){
        PVector force = new PVector(0,0);
        
        PVector[] borders = {
            new PVector(pos.x, height),
            new PVector(pos.x, 0),
            new PVector(0, pos.y ),
            new PVector(width, pos.y)
         };

        for(PVector borde : borders){
            float distace = PVector.dist(pos, borde);
            if(distace < visionDistance ){
                PVector vDistace = PVector.sub(pos, borde);
                force.add(vDistace);
            }
        }
        
        return force;
    }

    // Calc Life
    boolean estaMuyViejo(){
        edad += 0.01;
        boolean muerto = false;

        muerto |= edad > edadEserada;
        muerto |= energia < 0.01;

        return muerto;
    }

    // Reproduccion
    void reproducir(ArrayList<Cazador> boidList) {
        if(edad < edadReproduccion) return;

        Cazador pareja = null;
        for(Cazador boid : boidList){
            if(boid == this) continue;

            float distace = PVector.dist(pos, boid.pos);
            if(distace < reproductiveDistance ){
                pareja = boid;
                break;
            }
        }

        if(pareja == null) return;

        if(this.energia > energiaReproduccion)
            mesclarPareja(this, pareja);

        pareja.iniciarReproduccion();
        this.iniciarReproduccion();
        
    }

    void iniciarReproduccion(){
        this.energia -= energiaReproduccion;
        if(this.energia > energiaReproduccion){
            this.energia -= 1;
        }
    }

    ArrayList<Float> getGenoma(){
        ArrayList<Float> genoma = new ArrayList();
        
        genoma.add( (float) pielNumber );           // 0
        genoma.add( (float) personalDistance );     // 1
        genoma.add( (float) visionDistance );       // 2
        genoma.add( (float) reproductiveDistance ); // 3
        genoma.add( (float) edadEserada );          // 4
        genoma.add( (float) edadReproduccion );     // 5
        genoma.add( (float) energiaMaxima );        // 6
        genoma.add( (float) energiaMovimiento );    // 7
        genoma.add( (float) energiaReproduccion );  // 8
        genoma.add( (float) pos.x );                // 9
        genoma.add( (float) pos.y );                // 10

        return genoma;
    }

    void cazar(ArrayList<Boid> nearBoids){
        for(int i = 0; i < nearBoids.size(); i++){
            Boid  b = nearBoids.get(i);
            float distace = PVector.dist(pos, b.pos);
            if(distace < personalDistance - 5 ){
                energia += nearBoids.get(i).edad * 0.2;
                nearBoids.remove(i);
            }
        }
    }
}

void mesclarPareja(Cazador a, Cazador b){
    // println("Reproduccion de Cazadores ----------------------------------------------------------------------------");
    ArrayList<Float> genomaA = a.getGenoma();
    ArrayList<Float> genomaB = b.getGenoma();
    
    ArrayList<Float> genomaC = new ArrayList();
    ArrayList<Float> genomaD = new ArrayList();

    int puntoCorte = (int) round( random( genomaA.size() ) );
    for(int i = 0; i < puntoCorte; i++){
        genomaC.add( genomaA.get(i) );
        genomaD.add( genomaB.get(i) );
    }

    for(int i = puntoCorte; i < genomaA.size(); i++){
        genomaC.add( genomaA.get(i) );
        genomaD.add( genomaB.get(i) );
    }

    cazadores.add(new Cazador(genomaC));
    cazadores.add(new Cazador(genomaD));

    // println("Reproduccion de Cazadores -------------------------------");
}