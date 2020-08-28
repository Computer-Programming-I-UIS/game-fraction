
/***********************/

import processing.sound.*;

//arrays de objetos y de personaje
Player player;
Collision[] blokje = new Collision[0];//colisiones con los bloques
OverworldObject[] map01obj = new OverworldObject[0];//objetos interactivos
OverworldObject[] overworldSprites = new OverworldObject[0];//sprites arriba del escenario
OverworldObject[] mapTransitions = new OverworldObject[0];//usado para mostrar el área donde eestá el jugador
OverworldObject[] warpTiles = new OverworldObject[0];//usado cuando entra a un edificio
OverworldObject[] grassPatches = new OverworldObject[0];

//parametros del mapa
final int rows = 20;          //uso la funcion final, para indicar de qu esta variable no puede ser cambiada.
final int columns = 50;
final int tileSize = 16;

//colores
  color n1, n2, n3, l;
  color b1, b2, b3;

float owScaler = 3.0;//usado para hacer la escala de zooom
int currentArea; //usado para saber donde se encuentra el jugador
int notificationTimer = 0;
String[] areaName = {"PUEBLO", "BOSQUE"};//nombre de las areas para utilizar en el index
boolean grasspatchTick;//notifica cuando el usuario entra a lo salvaje

//variables para el jugador
float pPosX, pPosY;                       //posiciones del jugador          
boolean pLeft, pRight, pDown, pUp, pRun; //las utilizo para utilizar el metodo  de doble boton presionado 

//sprites e imagenes
PImage pSprite, npcSprite01, npcSprite02, npcSprite03;//sprites de el jugador y los npc's
PImage imgArrow, boxFrame01, boxFrame02, boxFrame03, boxFrame04, boxFrame05;//sprites para los menu
PImage overworldmapImg, house01Img, house02Img, house03Img, tileset01;//sprites de los lugares
PImage trainerSprite01, battleBackground01;//sprites de pelea
PImage infected;

//menu importaciones
PImage background, menu, clasification;
int option, opt;

//sprites iconos
PImage[] SpritesIcons = new PImage[0];  //iconos
PImage healthbarBg, healthbarOver, expbarOver;//barra de vida

//menu e interaccion de variables
PFont font;                         //fuente de las letras
boolean isInConversation = false;   //conversaciones
int conversationNum = 0;            //acumulacion de conversaciones
String[] conversation = new String[0];// almacen de las conversaciones pra lo NPC's

boolean owMenuOpened;
int owMenu = -1; //menu principal
int menuOption, submenuOption;
int owMenu1storeID = -1;//menu para los identificador
int owMenu5option1 = 1;//opcion 1 de configuraciones en el menu
int owMenu5option2;//opcion de mostrar fps
boolean heal;//hrecuperacion de vida (conversacion)
boolean giveItems;//dar items cuando hables con este personaje

//variables a deformar
int blackoutEffectAlpha;//tranparaencia de prueba de efecto blackout(pantalla negra para aparecer en otro lugar)
boolean isTransitioning; //transicionon del efecto
int fadeAmount = 15; //diracion de 0.25 seg
float destinationX, destinationY;//destino de teletransportacion

//variables Armas
String[] Objetlist = {"motosierra", "pistola", "Rifle", "escopeta", "punio americano","hacha"};//unicas armas

//variable de batallas
boolean isBattling = false;//saber cuando dibujar la fase de batalla
Monster opposing;//the monster the player is battling against
int battleOption;// opciones de batalla
boolean fightMenu, Menu, bagMenu;//menus

//otros
boolean showFPS;    
String resolution;  //mostrar fps y tamaño de la pantalla..., pero no son aditivos, son para saber si estan activados, y que poner en esa parte

//variables progresiva
int pMonsterSeen; //posicion del infectado visto
int pMonstersCaught; //infectado atrapado
int pBattlesWon;    //posicion de batalla ganata
int pPlaytimeFrame, pPlaytimeMin, pPlaytimeHour; //tiempo jugado
int[] pUniqueMonstersCaught = new int[0];// saber que tienes en la mochila

void setup()
{
  size(1000, 700);    //tamaño de resolucion inicial

  frameRate(480);
  noSmooth();//para que todo se vea en pixelfo

  overworldmapImg = loadImage("data/sprites/map02.png");        //el mapa
  tileset01 = loadImage("sprites/spr_tileset01.png");// tejedos sobre el mapa

  //menu 
  boxFrame01 = loadImage("data/sprites/boxFrame01.png");
  boxFrame02 = loadImage("data/sprites/boxFrame02.png");//cajas de texto
  boxFrame03 = loadImage("data/sprites/boxFrame03.png");//player vista previa
  boxFrame04 = loadImage("data/sprites/boxFrame04.png");
  boxFrame05 = loadImage("data/sprites/boxFrame05.png");
  imgArrow = loadImage("data/sprites/imgArrow.png");//flecha (la utilizamos para indicar las opciones en el menu principal )
  font = createFont("data/pkmnrs.ttf", 14);      //fuente de texto
  textFont(font);
  
  //main menu
  clasification = loadImage("data/mainmenu/clasification.png");
  
  for (int i= 0; i < Objetlist.length; ++i){
  PImage loadedIconimg = loadImage("data/Sprites/Spritesicon" + i + ".png");
  SpritesIcons = (PImage[])(append(SpritesIcons, loadedIconimg));
  }

  //player
  pSprite = loadImage("sprites/spr_jugador02.png");  //sprites del personaje
  Monster[] testPlayerTeam = new Monster[1];   //comienza con el primer Arma
  int playerStarterMonster = int(random(Objetlist.length));//arma aleatorio de inicio
  testPlayerTeam[0] = new Monster(playerStarterMonster, 5, int(random(10, 20)), int(random(3, 10)), int(random(3, 10)), int(random(3, 10)), 0, 0);
  pUniqueMonstersCaught = append(pUniqueMonstersCaught, playerStarterMonster);
  player = new Player(tileSize*5, tileSize*7, pSprite, testPlayerTeam);

  
  
  //npc's
  npcSprite01 = loadImage("data/sprites/spr_npc01.png");//npc 1
  npcSprite02 = loadImage("data/sprites/spr_npc02.png");//npc 2
  npcSprite03 = loadImage("data/sprites/spr_npc03.png");//npc 3
  trainerSprite01 = loadImage("data/sprites/spr_trainer01.png");//imagen del juagor en el menú
   infected = loadImage("data/sprites/infected.png");
  
  loadCollision();   //llamar a funciones
  loadEntities();
}

void loadCollision()
{
  String[] loadFile = loadStrings("data/scripts/map03.txt");//está en el archivo que map01colision4, básicamente te dice donde están las cordenadas de de las colisiones 
  String[] dissection = new String[0];//toma el anterior dato para ser usado de mejor, forma.

  for (int i = 0; i<loadFile.length; ++i)
  {
    dissection = split(loadFile[i], ",");//separa datos entre cada linea
    //solo append collision funciona si la linea de comienzo  esta con  "0" (usando "1" para commentar)
    if (int(dissection[0]) == 0) blokje = (Collision[]) append(blokje, new Collision(float(dissection[1])*tileSize, float(dissection[2])*tileSize, tileSize));//crea una colision con los datos del .txt
  }
}

void loadEntities()
{  

  String[] loadEnts = loadStrings("data/scripts/map01entities.txt"); //en este texto aparece el id, la posicion  y el tipo de objeto
  String[] disectEnts = new String[0];               //otra vez a dicescionar
  for (int i = 0; i<loadEnts.length; ++i)
  {
    disectEnts = split(loadEnts[i], ",");
    if (int(disectEnts[0]) == -5) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite03, int(disectEnts[3])));
    if (int(disectEnts[0]) == -4) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite02, int(disectEnts[3])));
    if (int(disectEnts[0]) == -3) map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, npcSprite01, int(disectEnts[3])));
    //if (int(disectEnts[0]) == -2) warpTiles = (OverworldObject[]) append(warpTiles, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, null, int(disectEnts[3])));
    //if (int(disectEnts[0]) == -1) mapTransitions = (OverworldObject[]) append(mapTransitions, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, null, int(disectEnts[3])));
    //if (int(disectEnts[0]) > 0 && int(disectEnts[0]) != 10)  map01obj = (OverworldObject[]) append(map01obj, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, tileset01.get(int(disectEnts[0])*tileSize, 0, tileSize, tileSize), int(disectEnts[3])));
    //if (int(disectEnts[0]) == 10) grassPatches = (OverworldObject[]) append(grassPatches, new OverworldObject(float(disectEnts[1])*tileSize, float(disectEnts[2])*tileSize, tileset01.get(int(disectEnts[0])*tileSize, 0, tileSize, tileSize), 0));
  }

  //objetos sobredibujados
 /* String[] loadFile = loadStrings("data/scripts/map01overdrawn.txt");  //datos donde se encuentran estos objetos
  String[] dissection = new String[0];  //disceccion de los datos
  for (int i = 0; i<loadFile.length; ++i)
  {
    dissection = split(loadFile[i], ",");

    overworldSprites = (OverworldObject[]) append(overworldSprites, new OverworldObject(float(dissection[1])*tileSize, float(dissection[2])*tileSize, tileset01.get((int(dissection[0])-1)*tileSize, 0, tileSize, tileSize), 1));
  }*/
}

void draw()
{

  switch(option){
  case 0:
  background(0);
    //image(background, 0, 0);
    //image(menu, -50, -70);
    image(clasification, 10, 500, 120,160);
    fill(0);
    textSize(80);
    textAlign(CENTER);
    text("Fraction", width/2, 70);
    button();
    break;
    
   case 1:
  
  pPlaytimeFrame++;//aumenta cada frame
  if (pPlaytimeFrame >= 120*60)//despues 60 segundos, incrementa tiempo jugado(minutos) por  1 
  {
    ++pPlaytimeMin;
    pPlaytimeFrame = 0;
  }
  if (pPlaytimeMin >= 60)//despues de 60 minutos, incrementa el tiempo jugao(horas) por 1
  {
    ++pPlaytimeHour;
    pPlaytimeMin = 0;
  }

  background(0);

  //dibujando la parte normal
  pushMatrix();
  translate(width/2, height/2);//transladar a los centros
  scale(owScaler);//zoom 

  translate(player.getPosX()*-1-(tileSize/2), player.getPosY()*-1-(tileSize/2));//hacer que el jugador siempre esté en el centro incluso si se aumenta la escala
 drawOverworldmap();//IMPORTANT: dibujando todos lo mapas en una sola pestaña 


  //creacion de malla
  noFill();
  for (int i = 0; i<columns; ++i)
  {   
    for (int j = 0; j<rows; ++j)
    {
      rect(i*tileSize, j*tileSize, tileSize, tileSize);//generar escala para el dibujo del pueblo a apartir de la malla
    }
  }

  if (owMenuOpened == false && isInConversation == false)//siempre y cuando el munu de mundo este desactivado y no esté en otra conversacion
  {
    if (player.getIsMoving() == false)//si el jugadpos está parado y no en movimiento
    {
      if (pUp) checkCollision(3);          
      else if (pDown) checkCollision(1);      
      else if (pLeft) checkCollision(2);//si el jugador se encuentra en una de estas posiciones interactua
      else if (pRight) checkCollision(0);
      if (pRun)
      {
        player.setRunState(true);  //si prun está presionado (lo usamos para generar el efecto que corre si presionas w o z), "se verá más adelante"
      } else
      {                            
        player.setRunState(false); //si no, pues camina normal, pero esto se utiliza más tarde
      }
    }
  }

  //dibuja objetos del mapa
  for (int i = 0; i<map01obj.length; ++i)
  {
    map01obj[i].display();
  }

  //draw hierba

  player.display();//dibujar al juagdor

  //dibujar objetos sobre el mapa (tejadors, etc)
  for (int i = 0; i<overworldSprites.length; ++i)
  {
    overworldSprites[i].display();
    
    }

  popMatrix();//resetear a lo componentes originales

  displayOWMenu();
  handleTransitions();//esto es para el mensaje que se muestra cuando entras a una ruta correspondiente

  //informacion del texto
  fill(0);//negro
  textSize(15);
  textAlign(LEFT);
  textLeading(30);
  if (showFPS) textMessage(width/2, height-30, str(frameRate), color(255));//si showfps esta activado se muestra en la parte inferior  

  if (isInConversation == true) conversationHandler(0);// si está en conversación

  blackoutEffect();//dibuja el efecto apagon
    break;
    
    case 3: 
    suboptions();
    break;
    
    case 4:
    lose();
    break;
  }
  
    
    
  
}

void keyPressed()
{

  //zoom screen in and out 
  if (key == 'o') owScaler += 0.2;
  if (key == 'l') owScaler -= 0.2;
  if (key == 'p')//cargar partida
  {
    String[] loadfile = loadStrings("savegame01.txt"); //guarda la posicion del jugador y ademas...  /set posicion (getPosX, getPosY)
    player.setPosition(float(loadfile[0]), float(loadfile[1])); //posicion
    showFPS = boolean(loadfile[2]);                             //fps utilizado
    surface.setSize(int(loadfile[3]), int(loadfile[4]));        //tamaño de la superficie


    player.setItemCount(0, int(loadfile[5]));
    player.setItemCount(1, int(loadfile[6]));
    pMonsterSeen = int(loadfile[7]);
    pMonstersCaught = int(loadfile[8]);
    pBattlesWon = int(loadfile[9]);
    pPlaytimeMin = int(loadfile[10]);
    pPlaytimeHour = int(loadfile[11]);

    int loadUniqueMonstersCaught = int(loadfile[12]);//que obejetos tiene
    pUniqueMonstersCaught = new int[0];//resetea el array

    for (int j = 13; j<13+loadUniqueMonstersCaught; ++j)//comienza en este lugar
    {
      pUniqueMonstersCaught = append(pUniqueMonstersCaught, int(loadfile[j]));  //sobre escribe lo que tienes
    }
    pPlaytimeFrame = 0;// comienza la cuenta de frames

    Monster[] importPlayerMonsterTeam = new Monster[0];//importa el equpio de jugador
    for (int i = 0; i<loadfile.length; ++i)// otra diseccion
    {
      String[] dissection = split(loadfile[i], "/");
      if (int(dissection[0]) == -100) //si el datoi es sobre los monstruos de jugador, llena este dato temporamlmente en el array Monster[] a el jugador (yo tratamos de usar MONSTERDATA pero if(dissection[0] == "MONSTERDATA") resulta flasa, entonces fue inuti
      {
        importPlayerMonsterTeam = (Monster[]) append(importPlayerMonsterTeam, new Monster(int(dissection[1]), int(dissection[2]), int(dissection[4]), int(dissection[5]), int(dissection[6]), int(dissection[7]), 0, 0));
        importPlayerMonsterTeam[importPlayerMonsterTeam.length-1].setHP(int(dissection[3]));//intruce la vida de los monstruos
      }
    }
    player.setPlayerTeam(importPlayerMonsterTeam);//asigna el equipo del jugador
  }

  if (keyCode == 10 && isInConversation == false)
  {
    owMenuOpened = !owMenuOpened;
    owMenu = -1;
  }

  if (owMenuOpened == false && isInConversation == false && isTransitioning == false)//no esta en menu, ni en coversacion, ni en transicion.
  {
    if (keyCode == LEFT) pLeft = true;            
    if (keyCode == RIGHT) pRight = true;
    if (keyCode == UP) pUp = true;
    if (keyCode == DOWN) pDown = true;
    if (key == 'z' || key == 'w') pRun = true;
    if (key == 'x')
    {
      checkPlayerInteraction();//mira si estas frente a un npc
      checkWarp();//mira si estas en una puerta
    }
    if (key == 'r' && player.getIsMoving() == false) player.setPosition(tileSize*5, tileSize*7);//si el jugador presiona r mientras no se está moviendo, resetea la posicion a  cerca de su hogar
  } else if (isInConversation == true)//si está en conversacion(es true cuando está cerca a un objeto el cual pueda interactuar)
  {
    if (key == 'x') //si x es presionado
    {
      conversationNum++;
      if (conversationNum >= conversation.length)
      {
       
        isInConversation = false;
        conversationNum = 0;
        conversation = new String[0];
      }
    }
  }

  if (owMenu == -1 && owMenuOpened == true)//si el jugador presiona enter  (owMenu -1 = main menu del mundo principal)
  {
    if (keyCode == DOWN) menuOption = (menuOption+1)%7;
    if (keyCode == UP) menuOption--;//1eccoger en el menú
    if (menuOption < 0) menuOption = 6; //para que se devuelva el menu cuando llegue a menos de 0

    if (key == 'z' || key == 'w') owMenuOpened = false; // cuando estés en el menu si presionas z o w  tes sales del menu
    if (key == 'x')                                     //si x es presionado en los ociones se habren los submenu 
    {
      owMenu = menuOption;// del menu principal al submenu
      submenuOption = 0;
    }
  } else if (owMenu == 0 && owMenuOpened == true)
  {
    if (key == 'z' || key == 'w') owMenu = -1;
  } else if (owMenu == 1 && owMenuOpened == true)//objetos
  {
    if (keyCode == DOWN) submenuOption = (submenuOption+1)%player.getPlayerTeam().length;//cantidad de cosas en el submenu
    if (keyCode == UP) submenuOption--;
    if (submenuOption < 0) submenuOption = player.getPlayerTeam().length-1;//para que se devuelva en el submenu
    if (key == 'x' && owMenu1storeID == -1) //is no seleccionames nada se que da con el ultimo id que selecionamos
    {
      owMenu1storeID = submenuOption;
    } else if (key == 'x' && owMenu1storeID != -1) //en caso que si seleconemos no quedos con ese objeto
    {
      player.swapMonster(owMenu1storeID, submenuOption);
      owMenu1storeID = -1;
    }
    if (key == 'z' || key == 'w') owMenu = -1;
  } else if (owMenu == 2 && owMenuOpened == true)//mochila
  {
    if (key == 'z' || key == 'w') owMenu = -1;
  } else if (owMenu == 3 && owMenuOpened == true)//jugador
  {
    if (key == 'z' || key == 'w') owMenu = -1;
  } else if (owMenu == 4 && owMenuOpened == true)//opcion de guardado
  {
    if (key == 'z' || key == 'w') owMenu = -1; //volver
    if (keyCode == DOWN) submenuOption = 0;//no quiere guardar
    if (keyCode == UP) submenuOption = 1;//si quiere guardar
    if (key == 'x' && submenuOption == 0) owMenu = -1;//no guarda y se sale
    if (key == 'x' && submenuOption == 1)//guarda el juego, si esto lo hace pasa...
    {
      String[] savefile = new String[0];
      savefile = append(savefile, str(player.getPosX()));//guarda posicion en x del jugador
      savefile = append(savefile, str(player.getPosY()));//guarda posicion en y del jugador
      savefile = append(savefile, str(showFPS));//guarda las opciones que hiciste
      savefile = append(savefile, str(width));  //guarda las opciones de tamañoqu elegiste
      savefile = append(savefile, str(height));
      savefile = append(savefile, str(player.getItemCount(0)));//meta los items
      savefile = append(savefile, str(player.getItemCount(1)));
      savefile = append(savefile, str(pMonsterSeen));          //guarde habilidades
      savefile = append(savefile, str(pMonstersCaught));       
      savefile = append(savefile, str(pBattlesWon));           //batallas ganadas
      savefile = append(savefile, str(pPlaytimeMin));          //batllas perdidas
      savefile = append(savefile, str(pPlaytimeHour));          //guarde el tiempo jugado
      savefile = append(savefile, str(pUniqueMonstersCaught.length));//cuantas habilidades tienes
      for (int j = 0; j<pUniqueMonstersCaught.length; ++j)            
      {
        savefile = append(savefile, str(pUniqueMonstersCaught[j]));//alamacena los ids de la habilidades obtenidas
      }

      Monster[] Data = player.getPlayerTeam();
      for (int i = 0; i<Data.length; ++i)//pasar todas la habilidades del jugador   
      {
        savefile = append(savefile, Data[i].getData());//almacena tiodas las habilidades
      }

      saveStrings("savegame01.txt", savefile);

      owMenu = -1;//devuelta al mapa al mapa
      owMenuOpened = false;//la pestaña menu esta apagada
      menuOption = 0;//devuelta a la opcion principal, cuando vuelva aingresar
    }
  } else if (owMenu == 5 && owMenuOpened == true)//opciones
  {
    if (key == 'z' || key == 'w') owMenu = -1;//me saca del menu
    if (keyCode == DOWN) submenuOption = (submenuOption+1)%3; //hay 3 opciones
    if (keyCode == UP) submenuOption--;
    if (submenuOption < 0) submenuOption = 2; //me lleva a la opcion 3

    if (keyCode == RIGHT)// si presiona la derecha o izquierda cambia la resolucion y fps
    {
      if (submenuOption == 0) owMenu5option1 = (owMenu5option1+1)%3;// hay 3 opciones en resolucion, se selciona hacia la derecha
      if (submenuOption == 1) owMenu5option2 = (owMenu5option2+1)%2;//hay 2 opciones en fps
    }
    if (keyCode == LEFT)
    {
      if (submenuOption == 0) owMenu5option1--; //se seleciona a la izquierda 
      if (submenuOption == 1) owMenu5option2--;
    }
    if (owMenu5option1 < 0) owMenu5option1 = 2;//si supera lo minimo en las opciones de resolucion y fps, se devuelva al max
    if (owMenu5option2 < 0) owMenu5option2 = 1;

    if (key == 'x' && submenuOption == 2)//confirmar
    {
      String[] changeRes = split(resolution, "x");// sobre escribe la resolucion, la cual está separa por una "x" (1000 x 700) resolucion size (1000, 700)
      surface.setSize(int(changeRes[0]), int(changeRes[1]));//asigna el cambiio por el split  y lo introduce en la resolucion
      // battleBackground01.resize(int(changeRes[0]), int(changeRes[1])); 

      if (owMenu5option2 == 1) showFPS = true;
      else showFPS = false;
    }
  }

  //need salir (utilizadao para probar los el menu
  if (owMenu == 6 && owMenuOpened == true)//Salir
  {
    owMenuOpened = false;
    owMenu = -1;
  }
  //}
}

PVector getDireccion(float x1, float y1, float x2, float y2, float v) {  //funcion para obtener direccion
  PVector vec1 = new PVector(x1, y1);
  PVector vec2 = new PVector(x2, y2);
  PVector dir = new PVector();

  dir.set(PVector.sub(vec1, vec2));
  dir.normalize();
  dir.mult(resizeX(v));

  return dir;
}

float resizeX(float value) {              //función para hacer el resize en X
  float newValue = (width*value)/1920;
  return newValue;
}

float resizeY(float value) {              //función para hacer el resize en Y
  float newValue = (height*value)/1080;
  return newValue;
}

void keyReleased()
{
  if (keyCode == LEFT) pLeft = false;   //acá es donde se identifica que la techa  se ha dejado de punsar, util para poder presionar 2 teclas a la vez, sacado de Konat( gracias) compañero, 
  if (keyCode == RIGHT) pRight = false;
  if (keyCode == UP) pUp = false;
  if (keyCode == DOWN) pDown = false;
  if (key == 'z' || key == 'w') pRun = false;
}

void displayOWMenu()// muestra el menu
{
  if (owMenu == -1 && owMenuOpened == true)//si el menu está desactivado, y enter es presionado
  {
    textSize(17);
    int textGap = 45;

    image(boxFrame01, width-boxFrame01.width, height/2-boxFrame01.height/2);//frame
    textAlign(CENTER);
    rectMode(CENTER);
    color c = color(256, 30, 30);
    float textPosX = width-boxFrame01.width/2;
    float textPosY = height/2-boxFrame01.height/2;
    textLeading(45);//  /n espacios en vertical
    textMessage(textPosX, textPosY+textGap, "HABILIDADES\nARMAS\nOBJETOS\nJUGADOR\nGUARDAR\nOPCIONES\nSALIR", c);
    image(imgArrow, width-boxFrame01.width+10, textPosY+30+(menuOption*textGap));
    rectMode(CORNER);
  }
  if (owMenu == 0)//Habilidades
  {
    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    imageMode(CORNER);

    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+45, "HABILIDADES POSIBLES: " +Objetlist.length +"\n\n HABBILIDAD OBTENIDAS: " +str(pUniqueMonstersCaught.length), color(0));
  }
  if (owMenu == 1)//OBJETOS
  {
    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    imageMode(CORNER);
    int gap = 58;

    if (owMenu1storeID != -1) 
    {
      stroke(150);
      rect(width/2-boxFrame03.width/2+10, (height/2-boxFrame03.height/2+15)+((boxFrame03.height/4-5)*owMenu1storeID), boxFrame03.width*0.75, 50);
    }
    noFill();
    stroke(225, 0, 0);//rojo
    strokeWeight(4);
    rect(width/2-boxFrame03.width/2+10, (height/2-boxFrame03.height/2+15)+((boxFrame03.height/4-5)*submenuOption), boxFrame03.width*0.80, 50);

    Monster[] testDisplay = player.getPlayerTeam();
    for (int i = 0; i<testDisplay.length; ++i)
    {
      testDisplay[i].setSprite(SpritesIcons[testDisplay[i].getMonsterID()]);//mete el array de las imagenes de las armas
      testDisplay[i].setPosition(width/2-boxFrame03.width/2+30, height/2-boxFrame03.height/2+30+(i*gap));
      textSize(16);
      textMessage(width/2-boxFrame03.width/2+64, height/2-boxFrame03.height/2+45+(i*gap), (testDisplay[i].getMonsterName()) +"  poder "+ str(testDisplay[i].getMonsterLvl()) +"precison"+ str(testDisplay[i].getMonsterHP())+"/"+str(testDisplay[i].getMonsterMaxHP()), color(255, 30, 30));
      testDisplay[i].display();
    }
  }
  if (owMenu == 2)//Morral
  {
    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    imageMode(CORNER);
    color c = color(255,30,30);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+40, "  "+ player.getItemCount(0) +"\nPOTIONS x"+ player.getItemCount(1), c);//texto en la parte superior izquierda
  }
  if (owMenu == 3)//player
  {
    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    imageMode(CORNER);
    image(trainerSprite01, width/2+boxFrame03.width/2-trainerSprite01.width, height/2-boxFrame03.height/2+30);
    color c = color(255,30,30);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+40, "NOMBRE\nGENERO\nARMA\nINFECTADOS ENCONTRADOS\nBATALLAS GANADAS\nTIEMPO JUGADO", c);
    textMessage(width/2, height/2-boxFrame03.height/2+40, "PLAYER\nMALE\n"+ pMonsterSeen +"\n"+ pMonstersCaught +"\n"+ pBattlesWon +"\n"+ pPlaytimeHour+":"+pPlaytimeMin, c);
  }
  if (owMenu == 4)//guardar
  {
    int gap = 20;
    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    image(boxFrame02, width/2, height*0.8);
    imageMode(CORNER);
    
    color c = color(255,30,30);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+gap, height/2-boxFrame03.height/2+gap*3, "NOMBRE DEL DATO GUARDADO\n\nGUARDANDO:\n- POSICION\n- PROGRESO\n- STADISTICAS", c);//texto en la parte superior izquierda
    textMessage(width/2, height/2-boxFrame03.height/2+gap*3, "savegame01.txt", c);//top box right
    textMessage(width/2-boxFrame02.width/2+gap, height*0.75+gap, "EL JUEGO SE VA SOBRE ESCRIBIR\n¿ESTAS SEGURO?", c);//
    textMessage(width/2+boxFrame02.width/4+gap, height*0.75+gap, "SI\nNO", color(40));//CONFIRMACION
    image(imgArrow, width/2+boxFrame02.width/4, height*0.75+35-(submenuOption*(30)));
    stroke(255, 0, 0);
    noFill();
  }
  if (owMenu == 5)//OPCIONES
  {
    if (owMenu5option1 == 0) resolution = "512x512";
    if (owMenu5option1 == 1) resolution = "1000x700";
    if (owMenu5option1 == 2) resolution = "1024x1024";
    boolean showFPScounter = false;
    if (owMenu5option2 == 1) showFPScounter = true;

    imageMode(CENTER);
    image(boxFrame03, width/2, height/2);
    imageMode(CORNER);
    color c = color(255,30,30);
    textLeading(30);
    textMessage(width/2-boxFrame03.width/2+20, height/2-boxFrame03.height/2+40, "OPCIONES\n\nRESOLUCION DE PANTALLA\nMOSTRAR FPS", c);//texto en la parte superior izquierda
    textMessage(width/2, height/2-boxFrame03.height/2+40, "PRESIONA CONFIRMAR PARA APLICAR\n\n"+ resolution +"\n"+ showFPScounter +"\nCONFIRMAR", c);//texto en la parte superior izquierd 
    image(imgArrow, width/2-imgArrow.width*2, height/2-40+(submenuOption*(30)));
  }
}

void drawOverworldmap()
{
  image(overworldmapImg, 0, 0);

}
                                                                
void textMessage(float posX, float posY, String text, color c)
{
  fill(125);
  text(text, posX+1, posY+1);
  fill(c);
  text(text, posX, posY);
}

void handleTransitions()
{
  for (int i = 0; i<mapTransitions.length; ++i)
  {
    //si el jugador se posiciona en el lugar de la transiocio pasa que
    if (player.getPosX() == mapTransitions[i].getPosX()  && currentArea != mapTransitions[i].getNPCType()) // a la posicion segun el mmpa
    {
      notificationTimer = 360;
      currentArea = mapTransitions[i].getNPCType();
    }
  }

  if (notificationTimer > 0)
  {
    textAlign(CENTER);
    image(boxFrame02, width/2-boxFrame02.width/2, height*0.05);//acá me dice donde estoy...
    textSize(48);
    textMessage(width/2, height*0.15, areaName[currentArea], color(355,30,30));//cambio de area
    notificationTimer--;
  }
}

void checkWarp()
{
  for (int i = 0; i<warpTiles.length; ++i)
  {
    
    if ((player.getPosX() == warpTiles[i].getPosX() && player.getPosY() == warpTiles[i].getPosY()+(1*tileSize) && player.getDirection() == 3) || (player.getPosX() == warpTiles[i].getPosX() && player.getPosY() == warpTiles[i].getPosY()-(1*tileSize) && player.getDirection() == 1))
    {
      if (warpTiles[i].getNPCType() == 0)
      {
        destinationX = warpTiles[i+1].getPosX();
        destinationY = warpTiles[i+1].getPosY()-(1*tileSize);
        isTransitioning = true;
      } else if (warpTiles[i].getNPCType() == 1)
      {
        destinationX = warpTiles[i-1].getPosX();
        destinationY = warpTiles[i-1].getPosY()+(1*tileSize);
        isTransitioning = true;
      }
    }
  }
}

void blackoutEffect()
{
  noStroke();
  fill(0, 0, 0, blackoutEffectAlpha);//black

  if (isTransitioning)
  {
    rect(0, 0, width, height);//the drawn fade
    blackoutEffectAlpha += fadeAmount;

    if (blackoutEffectAlpha >= 255) 
    {
      fadeAmount *= -1;// se multiplica por el contrario para generar el efecto diminucion
      player.setPosition(destinationX, destinationY);
    }
    if (blackoutEffectAlpha <= 0)//si llega de nuevo a cerp le damos los datos iniciales
    {
      blackoutEffectAlpha = 0;
      fadeAmount = 15;
      isTransitioning = false;
    }
  }
}

//mirar si el jugador está chocando
void checkCollision(int direction)
{
  boolean playerCollision = false;
  //colision con las paredes
  for (int i = 0; i<blokje.length; ++i)
  {
    if (blokje[i].checkCollision(player.getPosX(), player.getPosY(), direction))//mira si el jugador está sobre el objeto
    {
      playerCollision = true;
    }
  }  
  //colision con objetos
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), direction))//mira si el jugador está con algun obstaculo
    {
      playerCollision = true;//era una colision
    }
  }  

  if (playerCollision == false)
  {
    player.move(direction);        //el jugador se puede mover y correr
    player.setRunState(true);
  } else if (playerCollision == true)
  {
    player.setDirection(direction); //no se puede mover ni correr
    player.setRunState(false);
  }
}

//interaccion de juagdor con npc
void checkPlayerInteraction()
{
  heal = false;
  for (int i = 0; i<map01obj.length; ++i)
  {
    if (map01obj[i].checkCollision(player.getPosX(), player.getPosY(), player.getDirection()))//mira si el jugador se encuentra en los parametros del npc
    {
      //
      if (map01obj[i].getNPCType() == 0)//tipo 0 = personaje
      {
        if (player.getDirection() == 0) map01obj[i].changeDir(2);       
        else if (player.getDirection() == 1) map01obj[i].changeDir(3);  
        else if (player.getDirection() == 2) map01obj[i].changeDir(2);  
        else if (player.getDirection() == 3) map01obj[i].changeDir(1);  
      }
      isInConversation = true;//se activa el modo conversacion 

      //datos de conversaciones con Npc
      String[] loadFile = loadStrings("data/scripts/map01strings.txt");
      String[] dissection = new String[0];
      for (int j = 0; j<loadFile.length; ++j)
      {
        dissection = split(loadFile[j], "/");
        if (int(dissection[0]) == i) conversation = append(conversation, dissection[1]);
      }

      //loading in strings from textfiles discared the \n effect (new line effect), use custom alternative and replace that with a \n
      for (int k = 0; k<conversation.length; ++k)
      {
        conversation[k] = conversation[k].replaceAll("nuevalineas", "\n");
        conversation[k] = conversation[k].replaceAll("tildee", "é");    //uso de palabras palabra a conversacion
      }

      println("Character ID: "+i);//lo utilice de prueba para hacer las lineas texto

      //uso a futuro
    /*  if (i == 3) heal = true;
      else heal = false;
      if (i == 10) giveItems = true;
      else giveItems = false;
      */
    }
  }
}

void conversationHandler(int type)//tipo de conversacion: npc
{
  int gap = 20;// espacio entre ekl lado izquierdo y el texto actual
  textAlign(LEFT);
  imageMode(CENTER);
  if (type == 0) image(boxFrame02, width/2, height*0.8);//rectangulo de texto
  if (type == 1) image(boxFrame02, width/2, height*0.1);
  imageMode(CORNER);

  fill(0);//negro
  textFont(font);
  textSize(28);
  textLeading(30);
  if (type == 0) textMessage(width/2-boxFrame02.width/2+gap, height*0.75+gap, conversation[conversationNum], color(255, 30, 30));//conversacion normal
  else if (type == 1) textMessage(width/2-boxFrame02.width/2+gap, height*0.1, conversation[conversationNum], color(255, 30, 30));
}



/*hecho por Isaak Ali Gomez
            Otto Andrade
            Kelvinosse (ayudó a hacer el efecto colision) 
*/
