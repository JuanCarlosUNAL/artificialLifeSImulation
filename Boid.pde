class Boid {
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

    Boid(){
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
        shape = loadShape("fishReduced.obj");
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

    Boid(ArrayList<Float> genoma){

        // personalDistance
        // visionDistance
        // reproductiveDistance
        // edadEserada
        // edadReproduccion
        // energiaMaxima
        // energiaMovimiento
        // energiaReproduccion

        pos = new PVector( genoma.get(8), genoma.get(9));
        velocity = new PVector( random(-1, 1), random(-.2, .2) );

        // Pieles 
        pielNumber = (int) genoma.get(0).floatValue();
        piel = loadImage("skins/" + pielNumber + ".PNG");
        shape = loadShape("fish.obj");
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

    void draw(){
         
        PVector direction = convPolar(velocity);
        PVector dir = velocity.copy();
        pushMatrix();   

        translate(pos.x, pos.y);
        scale(5 + edad);
        rotateX(PI/2 );
        rotateZ(PI/2);
        rotateX(- direction.y );
        shape(shape, 0, 0);

        popMatrix();

        rect(pos.x - 2, pos.y - 2, 4, 4);
    }

    // Calc Flock
    void calcFlock(ArrayList<Boid> boidList, ArrayList<Cazador> huntersList){
        PVector force = new PVector(0,0);

        ArrayList<Boid> nearBoids = new ArrayList<Boid>();
        for(Boid boid : boidList){
            if(boid == this) continue;

            float distace = PVector.dist(pos, boid.pos);
            if(distace < visionDistance )
                nearBoids.add(boid);
        }

        ArrayList<Cazador> nearHunters = new ArrayList<Cazador>();
        for(Cazador hunter : huntersList){
            float distace = PVector.dist(pos, hunter.pos);
            if(distace < visionDistance )
                nearHunters.add(hunter);
        }

        PVector border = caclBorder();
        PVector predators = caclpredators(nearHunters);
        PVector separation = caclSeparaion(nearBoids);
        PVector meanVelocity = calcVelocity(nearBoids);
        PVector cohesion = calcCohesion(nearBoids);

        separation.normalize();
        predators.normalize();
        border.normalize();
        meanVelocity.normalize();
        cohesion.normalize();

        separation.mult(1.);
        predators.mult(1.5);
        border.mult(1.5);
        meanVelocity.mult(1.0);

        cohesion.mult( 
            edad >= edadReproduccion 
            ? 1.5
            : 1.
        );

        //force.add(border);
        force.add(separation);
        force.add(predators);
        force.add(meanVelocity);
        force.add(cohesion);

        force.limit(0.5);
        velocity.add(force);
        velocity.limit(2.0);
    }

    PVector caclpredators(ArrayList<Cazador> nearHunters){
        PVector force = new PVector(0,0);
        for(Cazador b : nearHunters){
            float distace = PVector.dist(pos, b.pos);
            if(distace < personalDistance ){
                PVector vDistace = PVector.sub(pos, b.pos);
                force.add(vDistace);
            }
        }
        return force;
    }

    PVector caclSeparaion(ArrayList<Boid> nearBoids){
        PVector force = new PVector(0,0);
        for(Boid b : nearBoids){
            float distace = PVector.dist(pos, b.pos);
            if(distace < personalDistance ){
                PVector vDistace = PVector.sub(pos, b.pos);
                force.add(vDistace);
            }
        }
        return force;
    }

    PVector calcVelocity(ArrayList<Boid> boidList){
        PVector force = new PVector(0,0);
        for(Boid b : boidList)
            force.add(b.velocity);
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

    PVector calcCohesion(ArrayList<Boid> boidList){
        PVector force = new PVector(0,0);
        float xMax = -1, xMin = width + 1, 
            yMax= -1, yMin = height + 1;
        
        for(Boid boid : boidList){
            xMax = boid.pos.x > xMax 
            ? boid.pos.x
            : xMax;

            xMin = boid.pos.x < xMin 
            ? boid.pos.x
            : xMin;

            yMax = boid.pos.y > yMax 
            ? boid.pos.y
            : yMax;

            yMin = boid.pos.y < yMin 
            ? boid.pos.y
            : yMin;
        }

        PVector middlePoint = new PVector( (xMax + xMin)/2, (yMax + yMin)/2 );

        for(Boid boid : boidList){
            float distace = PVector.dist(pos, boid.pos);
            if(distace > personalDistance )
                force.add( PVector.sub(middlePoint, boid.pos) );
        }

        return force;
    }

    PVector convPolar(PVector coord){
        float h = sqrt(sq(coord.x) + sq(coord.y));
        float theta = acos(coord.x/h);

        return new PVector(h, theta);
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
    void reproducir(ArrayList<Boid> boidList) {
        if(edad < edadReproduccion) return;

        Boid pareja = null;
        for(Boid boid : boidList){
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
        
        genoma.add( (float) pielNumber );
        genoma.add( (float) personalDistance );
        genoma.add( (float) visionDistance );
        genoma.add( (float) reproductiveDistance );
        genoma.add( (float) edadEserada );
        genoma.add( (float) edadReproduccion );
        genoma.add( (float) energiaMaxima );
        genoma.add( (float) energiaMovimiento );
        genoma.add( (float) energiaReproduccion );
        genoma.add( (float) pos.x );
        genoma.add( (float) pos.y );

        return genoma;
    }

    void comer(){
        
        if(comida[(int)pos.x][(int)pos.y] > 0){
            energia += comida[(int)pos.x][(int)pos.y] * 0.2;
            comida[(int)pos.x][(int)pos.y] = 0;
        }
    }
}

void mesclarPareja(Boid a, Boid b){
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

    genomaC = mutarGenoma(genomaC);
    genomaC = mutarGenoma(genomaC);

    presas.add(new Boid(genomaC));
    presas.add(new Boid(genomaD));
}

ArrayList<Float> mutarGenoma(ArrayList<Float> gen) {

    // personalDistance
    // visionDistance
    // reproductiveDistance
    // edadEserada
    // edadReproduccion
    // energiaMaxima
    // energiaMovimiento
    // energiaReproduccion

    for(int i= 0; i< gen.size(); i++){
        if(random(1) < 1/gen.size())
            gen.set(i, random(-1, 1) + gen.get(i) );
    }

    return gen;
}