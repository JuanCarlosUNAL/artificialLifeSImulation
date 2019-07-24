import java.lang.StringBuilder;
import java.util.LinkedList;

boolean showMeal = false;

ArrayList<Boid> presas = new ArrayList<Boid>();
ArrayList<Cazador> cazadores = new ArrayList<Cazador>();
ArrayList<Planta> plantas = new ArrayList<Planta>();

int comida[][];

int w = 700;
int h = 500;

int numPresas = 20;
int numCazadores = 3;
int maxComida = 5;

void setup() {
    size(700, 500, P3D);
    textureWrap(CLAMP);

    comida = new int[w][h];
    for(int i = 0; i < w; i++){
        for(int j = 0; j < h; j++){
            comida[i][j] = 0;
        }
    }

    for(int i = 0; i < numPresas ; i++){
        presas.add(new Boid());
    }

    for(int i = 0; i < numCazadores ; i++){
        cazadores.add(new Cazador());
    }

    plantas.add(new Planta(100));
    plantas.add(new Planta(400));

}

void draw() {
    background(0);

    if(showMeal) pintarComida();
    

    for(int i = 0; i < presas.size(); i++){

        Boid p = presas.get(i);
        if( p.estaMuyViejo() )
            presas.remove(i);
        
        p.reproducir(presas);
        p.calcFlock(presas, cazadores);
        p.move();
        p.draw();
        p.comer();
    }

    for(int i = 0; i < cazadores.size(); i++){

        Cazador p = cazadores.get(i);
        if( p.estaMuyViejo() )
            cazadores.remove(i);
        p.cazar(presas);
        p.reproducir(cazadores);
        p.calcFlock(presas, cazadores);
        p.move();
        p.draw();
    }

    for(Planta p: plantas){
        p.draw();
    }

}

void pintarComida(){
    for(int i = 0; i < w; i++){
        for(int j = 0; j < h; j++){
            float value = (float) comida[i][j]; 
            stroke( color((int) ((255. * value)/maxComida), (int)((255. * value)/maxComida), 0) );
            point(i,j);
        }
    }
}

void keyPressed(){
    switch (key) {
        case '1':
            showMeal = !showMeal; 
            break;
    }
}

