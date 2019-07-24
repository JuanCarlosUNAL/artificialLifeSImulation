class Planta {

    int depth = 6;
    float ANGLE = 22.5 * PI / 180;
    float movementAngle = 0.5 * PI / 180;

    float inclinationAngle = 0;

    String initString = "X";
    String productionString;
    StringBuilder productionStringBuilder = new StringBuilder();

    LinkedList<PVector> stack = new LinkedList<PVector>();

    int positionX;

    Planta(int position){
        positionX = position;
        for(int j = 0; j < depth; j++){
            productionStringBuilder.setLength(0);
            for(int i = 0; i < initString.length(); i++ ){
            productionStringBuilder.append( productionRule( initString.charAt(i) ) );
            }
            initString = productionStringBuilder.toString();
        }
        
        productionString = initString;
    }

    void draw(){
        stack.clear();
        PVector position = new PVector(positionX, h);
        PVector direction = new PVector(0, -2);
        
        inclinationAngle += sin(frameCount/5) * movementAngle;

        for(int i = 0; i<productionString.length(); i++){
            switch (productionString.charAt(i)) {
                case 'F':
                stroke(255,0,0);
                if(random(1) > 0.99 && 
                    position.x < w && position.y < h && 
                    position.x > 0 && position.y > 0) 

                    comida[(int)position.x][(int)position.y] += 1;

                line(position.x, position.y, position.x + direction.x, position.y + direction.y);
                position = new PVector(position.x + direction.x, position.y + direction.y);
                break;
                case 'X':
                stroke(0,255,0);
                line(position.x, position.y, position.x + direction.x, position.y + direction.y);
                position = new PVector(position.x + direction.x, position.y + direction.y);
                break;
                case '+':
                direction = new PVector(direction.x, direction.y).rotate(-ANGLE + inclinationAngle );
                break;
                case '-':
                direction = new PVector(direction.x, direction.y).rotate(ANGLE + inclinationAngle );
                break;
                case '[':
                stack.addFirst(position);
                stack.addFirst(direction);
                break; 
                case ']':
                direction = stack.poll();
                position = stack.poll();
                break; 
            }
        }
    }

    String productionRule(char input) {
        if(input == 'F')
            return "FF";
        if(input == 'X')
            return "F-[[X]+X]+F[+FX]-X";
        return "" + input;
    } 
}