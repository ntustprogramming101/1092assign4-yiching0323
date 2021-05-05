final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int START_BUTTON_W = 144;
final int START_BUTTON_H = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;
final int PLAYERHEALTH_MAX = 5;

final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage bg, groundhogIdle, groundhogDown, groundhogLeft, groundhogRight;
PImage life;
PImage soldier, cabbage;
PImage[][] soils, stones;

int[][] soilHealth;
PImage soilEmpty;

float groundhogSpeed = 4;
float groundhogX; 
float groundhogY;
float groundhogWidth = 80;
float groundhogHeight = 80;
int number =0;
int down = 0;
int right = 0;
int left = 0;
float step = 80.0;
int frames = 15;
int floorSpeed = 0;
float downMove = 0;

float[] cabbageX, cabbageY, soldierX, soldierY, emptySoilX, emptySoilY;
float[] initCabbageY, initSoldierY, initEmptySoilY;
float soldierXSpeed = 5;

boolean downPressed  = false;
boolean leftPressed  = false;
boolean rightPressed  = false;


// For debug function; DO NOT edit or remove this!
int playerHealth = 2;
float cameraOffsetY = 0;
boolean debugMode = false;
boolean demoMode = false;

void setup() {
  size(640, 480, P2D);
  // Enter your setup code here (please put loadImage() here or your game will lag like crazy)
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");

  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");
  soilEmpty = loadImage("img/soilEmpty.png");

  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");

  life = loadImage("img/life.png");

  // Load PImage[][] soils
  soils = new PImage[6][5];
  for (int i = 0; i < soils.length; i++) {
    for (int j = 0; j < soils[i].length; j++) {
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for (int i = 0; i < stones.length; i++) {
    for (int j = 0; j < stones[i].length; j++) {
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }

  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
    }
  }


  //soldierPosition
  soldierX = new float[6];
  soldierY = new float[6];
  initSoldierY = new float[6];

  soldierY[0] = floor(random(2, 6))* SOIL_SIZE;
  soldierX[0] = floor(random(8)) * SOIL_SIZE;
  initSoldierY[0] = soldierY[0];
  for (int i = 1; i < 6; i++) {
    initSoldierY[i] = soldierY[i] ;
    soldierX[i] = floor(random(8)) * SOIL_SIZE;
    soldierY[i] = (floor(random(4))+ i * 4) * SOIL_SIZE+2*SOIL_SIZE; //changed
    initSoldierY[i] = soldierY[i];
  }

  soldierXSpeed = 5;


  //cabbagePosition
  cabbageX = new float[6];
  cabbageY = new float[6];
  initCabbageY = new float[6];

  cabbageY[0] = floor(random(2, 6))* SOIL_SIZE;
  cabbageX[0] = floor(random(8)) * SOIL_SIZE;
  initCabbageY[0] = cabbageY[0];
  for (int i = 1; i < 6; i++) {
    initCabbageY[i] = cabbageY[i] ;
    cabbageX[i] = floor(random(8)) * SOIL_SIZE;
    cabbageY[i] = (floor(random(4))+ i * 4) * SOIL_SIZE+2*SOIL_SIZE; //changed
    initCabbageY[i] = cabbageY[i];
  }


  //groundhogPosition
  groundhogX = 320;
  groundhogY = 80;

  //Stone 1-8
  for (int i = 0; i < 8; i++) {
    int j = int((i*80)/80);
    soilHealth[i][j] += 15;
  }

  //Stone 9-16
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      if (x%4 == 1) {
        if (y%4 == 0 || y%4 == 3) {
          int j = int((640+y*80)/80);
          soilHealth[x][j] += 15;
          soilHealth[x+1][j] += 15;
        }
      } else if (x%4 == 3) {
        if (y%4 == 1 || y%4 == 2) {
          int i = int((x*80)%640/80);
          int k = int(((x+1)*80)%640/80);
          int j = int((640+y*80)/80);
          soilHealth[i][j] += 15;
          soilHealth[k][j] += 15;
        }
      }
    }
  }

  //Stone 17-24
  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 8; y++) {
      if (x%3 == 1) {
        if (y%3 == 0) {

          int i = int((x*80)%720/80);
          int k = int(((x+1)*80)%720/80);
          int j = int((1280+y*80)/80);
          if (i<8)
            soilHealth[i][j] += 15;
          if (k<8)
            soilHealth[k][j] += 30;
        }
      } else if (x%3 == 0) {
        if (y%3 == 1 ) {

          int i = int((x*80)%720/80);
          int k = int(((x+1)*80)%720/80);
          int j = int((1280+y*80)/80);
          if (i<8)
            soilHealth[i][j] += 15;
          if (k<8)
            soilHealth[k][j] += 30;
        }
      } else if (x%3 == 2) {
        if (y%3 == 2 ) {

          int i = int((x*80)%720/80);
          int k = int(((x+1)*80)%720/80);
          int j = int((1280+y*80)/80);
          if (i<8)
            soilHealth[i][j] += 15;
          if (k<8)
            soilHealth[k][j] += 30;
        }
      }
    }
  }

  //empty soil
  emptySoilX = new float[46];
  emptySoilY = new float[46];
  initEmptySoilY = new float[46];
  number=0;


  for (int i = 0; i < 23; i++) {

    if (floor(random(2))==1) {
      emptySoilX[number] = floor(random(8)) * SOIL_SIZE;
      emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE; //changed

      initEmptySoilY[number] = emptySoilY[number];
      number += 1;
    } else { // two hole in one row
      int rand_num1=0;
      int rand_num2=0;
      rand_num1=floor(random(8));
      rand_num2=floor(random(8));
      while (rand_num1==rand_num2) {
        rand_num2=floor(random(8));
      }

      emptySoilX[number]=rand_num1*SOIL_SIZE;
      emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE;
      initEmptySoilY[number] = emptySoilY[number];

      number+=1;
      emptySoilX[number]=rand_num2*SOIL_SIZE;
      emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE;
      initEmptySoilY[number] = emptySoilY[number];

      number+=1;
    }
  }
}


void draw() {
  /* ------ Debug Function ------ 
   
   Please DO NOT edit the code here.
   It's for reviewing other requirements when you fail to complete the camera moving requirement.
   
   */
  if (debugMode) {
    pushMatrix();
    translate(0, cameraOffsetY);
  }
  /* ------ End of Debug Function ------ */


  switch (gameState) {

  case GAME_START: // Start Screen
    image(title, 0, 0);

    if (START_BUTTON_X + START_BUTTON_W > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_H > mouseY
      && START_BUTTON_Y < mouseY) {

      image(startHovered, START_BUTTON_X, START_BUTTON_Y);
      if (mousePressed) {
        gameState = GAME_RUN;
        mousePressed = false;
      }
    } else {

      image(startNormal, START_BUTTON_X, START_BUTTON_Y);
    }
    break;

  case GAME_RUN: // In-Game

    // Background
    image(bg, 0, 0);

    // Sun
    stroke(255, 255, 0);
    strokeWeight(5);
    fill(253, 184, 19);
    ellipse(590, 50, 120, 120);

    // Grass
    fill(124, 204, 25);
    noStroke();
    rect(0, 160 - GRASS_HEIGHT + downMove, width, GRASS_HEIGHT);

    // Soil
    for (int x = 0; x < 8; x ++) {
      for (int y = 0; y < 4; y ++) {
        image(soils[0][4], x*80, 160+y*80+downMove);
        image(soils[1][4], x*80, 480+y*80+downMove);
        image(soils[2][4], x*80, 800+y*80+downMove);
        image(soils[3][4], x*80, 1120+y*80+downMove);
        image(soils[4][4], x*80, 1440+y*80+downMove);
        image(soils[5][4], x*80, 1760+y*80+downMove);
      }
    }

    //Stone 1-8
    for (int i = 0; i < 8; i++) {
      image(stones[0][4], i*80, 160+i*80+downMove);
    }

    //Stone 9-16
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        if (x%4 == 1) {
          if (y%4 == 0 || y%4 == 3) {
            image(stones[0][4], x*80, 160+640+y*80+downMove);
            image(stones[0][4], (x+1)*80, 160+640+y*80+downMove);
          }
        } else if (x%4 == 3) {
          if (y%4 == 1 || y%4 == 2) {
            image(stones[0][4], (x*80)%640, 160+640+y*80+downMove);
            image(stones[0][4], ((x+1)*80)%640, 160+640+y*80+downMove);
          }
        }
      }
    }

    //Stone 17-24
    for (int x = 0; x < 9; x++) {
      for (int y = 0; y < 8; y++) {
        if (x%3 == 1) {
          if (y%3 == 0) {
            image(stones[0][4], (x*80)%720, 160+1280+y*80+downMove);
            image(stones[0][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
            image(stones[1][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
          }
        } else if (x%3 == 0) {
          if (y%3 == 1 ) {
            image(stones[0][4], (x*80)%720, 160+1280+y*80+downMove);
            image(stones[0][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
            image(stones[1][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
          }
        } else if (x%3 == 2) {
          if (y%3 == 2 ) {
            image(stones[0][4], (x*80)%720, 160+1280+y*80+downMove);
            image(stones[0][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
            image(stones[1][4], ((x+1)*80)%720, 160+1280+y*80+downMove);
          }
        }
      }
    }

    //empty soil
    for (int i=0; i<number; i++) {
      emptySoilY[i] = initEmptySoilY[i] + downMove; 
      image(soilEmpty, emptySoilX[i], emptySoilY[i]);
    }

    //hole detect
    for (int i=0; i<number; i++) {
      if (groundhogY+80==emptySoilY[i]&&groundhogX==emptySoilX[i]) {
        down=15;
      }
    }
    
    
    // Player
    //groundhog move
    //down
    if (down > 0 && downMove > -1600) {
      floorSpeed -=1;
      if (down == 1) {
        downMove = round(step/frames*floorSpeed);
        //print(downMove);
        image(groundhogIdle, groundhogX, groundhogY);
      } else {
        downMove = step/frames*floorSpeed;
        image(groundhogDown, groundhogX, groundhogY);
      }
      down -=1;
    }

    if (down > 0 && downMove == -1600) {
      if (down == 1) {
        groundhogY = round(groundhogY + step/frames);
        image(groundhogIdle, groundhogX, groundhogY);
      } else {
        groundhogY = groundhogY + step/frames;
        image(groundhogDown, groundhogX, groundhogY);
      }
      down -=1;
    }

    //left
    if (left > 0) {
      if (left == 1) {
        groundhogX = round(groundhogX - step/frames);
        image(groundhogIdle, groundhogX, groundhogY);
      } else {
        groundhogX = groundhogX - step/frames;
        image(groundhogLeft, groundhogX, groundhogY);
      }
      left -=1;
    }

    //right
    if (right > 0) {
      if (right == 1) {
        groundhogX = round(groundhogX + step/frames);
        image(groundhogIdle, groundhogX, groundhogY);
      } else {
        groundhogX = groundhogX + step/frames;
        image(groundhogRight, groundhogX, groundhogY);
      }
      right -=1;
    }

    //no move
    if (down == 0 && left == 0 && right == 0 ) {
      image(groundhogIdle, groundhogX, groundhogY);
    }

    //soldierMove
    for (int i=0; i<6; i++) {
      soldierY[i] = initSoldierY[i] + downMove;
      image(soldier, soldierX[i], soldierY[i]);
      soldierX[i] += soldierXSpeed;
      if (soldierX[i]>=640) {
        soldierX[i] = -80;
      }
    }

    //soldierDetect
    for (int i=0; i<6; i++) {
      // soldierY[i] = soldierY[i] +downMove;
      if (groundhogX < soldierX[i] + 80 && groundhogX + 80 > soldierX[i] && groundhogY < soldierY[i] + 80 && groundhogY + 80 > soldierY[i]) {
        groundhogX = 320;
        groundhogY = 80;
        playerHealth -= 1;
        down = 0;
        left = 0;
        right = 0;
        downMove = 0;
        floorSpeed = 0;
      }
    }

    //cabbage
    for (int i=0; i<6; i++) {
      cabbageY[i] = initCabbageY[i] + downMove; 
      image(cabbage, cabbageX[i], cabbageY[i]);
      if (groundhogX < cabbageX[i] + 80 && groundhogX + 80 > cabbageX[i] && groundhogY < cabbageY[i] + 80 && groundhogY + 80 > cabbageY[i]) {
        cabbageX[i] = -80;
        cabbageY[i] = 0;
        playerHealth +=1 ;
      }
    }

    // Health UI
    if (playerHealth <= PLAYERHEALTH_MAX && playerHealth > 0) {
      for (int x = 0; x < playerHealth; x++) {
        pushMatrix();
        translate(x*70, 0);
        image(life, 10, 10);
        popMatrix();
      }
    }
    if (playerHealth >= PLAYERHEALTH_MAX) {
      playerHealth = 5;
    }

    //gameOver
    if (playerHealth==0) {
      gameState=GAME_OVER;
    }
    if (demoMode) {

      fill(255);
      textSize(26);
      textAlign(LEFT, TOP);

      for (int i = 0; i < soilHealth.length; i++) {
        for (int j = 0; j < soilHealth[i].length; j++) {
          text(soilHealth[i][j], i * SOIL_SIZE, 160+j * SOIL_SIZE+downMove);
        }
      }
    }


    break;

  case GAME_OVER: // Gameover Screen
    image(gameover, 0, 0);

    if (START_BUTTON_X + START_BUTTON_W > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_H > mouseY
      && START_BUTTON_Y < mouseY) {

      image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
      if (mousePressed) {

        //initialize the game 
        gameState = GAME_RUN;
        mousePressed = false;
        //soldierPosition
        soldierX = new float[6];
        soldierY = new float[6];
        initSoldierY = new float[6];

        soldierY[0] = floor(random(2, 6))* SOIL_SIZE;
        soldierX[0] = floor(random(8)) * SOIL_SIZE;
        initSoldierY[0] = soldierY[0];
        for (int i = 1; i < 6; i++) {
          initSoldierY[i] = soldierY[i] ;
          soldierX[i] = floor(random(8)) * SOIL_SIZE;
          soldierY[i] = (floor(random(4))+ i * 4) * SOIL_SIZE+2*SOIL_SIZE; //changed
          initSoldierY[i] = soldierY[i];
        }

        //cabbagePosition
        cabbageX = new float[6];
        cabbageY = new float[6];
        initCabbageY = new float[6];

        cabbageY[0] = floor(random(2, 6))* SOIL_SIZE;
        cabbageX[0] = floor(random(8)) * SOIL_SIZE;
        initCabbageY[0] = cabbageY[0];
        for (int i = 1; i < 6; i++) {
          initCabbageY[i] = cabbageY[i] ;
          cabbageX[i] = floor(random(8)) * SOIL_SIZE;
          cabbageY[i] = (floor(random(4))+ i * 4) * SOIL_SIZE+2*SOIL_SIZE; //changed
          initCabbageY[i] = cabbageY[i];
        }

        //empty soil
        emptySoilX = new float[46];
        emptySoilY = new float[46];
        initEmptySoilY = new float[46];
        number=0;

        for (int i = 0; i < 23; i++) {

          if (floor(random(2))==1) {
            emptySoilX[number] = floor(random(8)) * SOIL_SIZE;
            emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE; //changed

            initEmptySoilY[number] = emptySoilY[number];
            number += 1;
          } else { // two hole in one row
            int rand_num1=0;
            int rand_num2=0;
            rand_num1=floor(random(8));
            rand_num2=floor(random(8));
            while (rand_num1==rand_num2) {
              rand_num2=floor(random(8));
            }

            emptySoilX[number]=rand_num1*SOIL_SIZE;
            emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE;
            initEmptySoilY[number] = emptySoilY[number];

            number+=1;
            emptySoilX[number]=rand_num2*SOIL_SIZE;
            emptySoilY[number] = i * SOIL_SIZE+ 3 * SOIL_SIZE;
            initEmptySoilY[number] = emptySoilY[number];

            number+=1;
          }
        }

        down = 0;
        left = 0;
        right = 0;
        playerHealth=2;
      }
    } else {

      image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
    }
    break;
  }

  // DO NOT REMOVE OR EDIT THE FOLLOWING 3 LINES
  if (debugMode) {
    popMatrix();
  }
}

void keyPressed() {
  if (down>0 || left>0 || right>0) {
    return;
  }
  if (key == CODED) {
    switch(keyCode) {
    case DOWN:
      if (groundhogY < 400) {
        downPressed = true;
        down = 15;
      }
      break;
    case LEFT:
      if (groundhogX > 0) {
        leftPressed = true;
        left = 15;
      }
      break;
    case RIGHT:
      if (groundhogX < 560) {
        rightPressed = true;
        right = 15;
      }
      break;
    }
  } else {
    if (key=='b') {
      // Press B to toggle demo mode
      demoMode = !demoMode;
    }
  }

  // DO NOT REMOVE OR EDIT THE FOLLOWING SWITCH/CASES
  switch(key) {
  case 'w':
    debugMode = true;
    cameraOffsetY += 25;
    break;

  case 's':
    debugMode = true;
    cameraOffsetY -= 25;
    break;

  case 'a':
    if (playerHealth > 0) playerHealth --;
    break;

  case 'd':
    if (playerHealth < 5) playerHealth ++;
    break;
  }
}

void keyReleased() {
}
