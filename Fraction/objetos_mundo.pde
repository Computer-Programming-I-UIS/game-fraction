class OverworldObject extends Collision
{
  PImage infected; 
  float px,py;
  int x, y;
  float vel = 0.3;
  PImage m_sprite,m_imgFrame, m_infected;
  private int m_direction, m_spriteCount, m_npcType;
  
 
  OverworldObject(float posX, float posY, PImage sprite, int type)
  {
    super(posX,posY,tileSize);
    m_sprite = sprite;
    m_npcType = type;
    m_infected = infected;
    m_direction = 1;
    if(sprite != null) m_spriteCount = m_sprite.width/tileSize;
  }
  
  void display()
  {
    
    //muestra al sprite y su direccion
    if(m_npcType == 0)
    {
      if (m_direction == 1) m_imgFrame = m_sprite.get(0, 0, m_sprite.width/m_spriteCount, m_sprite.height);// DOWN 
      else if (m_direction == 0) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*6, 0, m_sprite.width/m_spriteCount, m_sprite.height);// RIGHT
      else if (m_direction == 2) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*9, 0, m_sprite.width/m_spriteCount, m_sprite.height);// LEFT
      else if (m_direction == 3) m_imgFrame = m_sprite.get((m_sprite.width/m_spriteCount)*3, 0, m_sprite.width/m_spriteCount, m_sprite.height);// UP  
    }
    else
    {
      m_imgFrame = m_sprite.get(0, 0, m_sprite.width/m_spriteCount, m_sprite.height);// DOWN 
    }
    image(m_imgFrame, m_posX+tileSize-m_imgFrame.width, m_posY+tileSize-m_imgFrame.height);
   pushMatrix();
  PVector direction = getDireccion(player.getPosX(),player.getPosY(), px, py, vel);
    noStroke();
    /*fill(200, 0, 0);
    rectMode(CENTER);
    rect(px, py, 32, 32);
    */
   
    px += direction.x;
    py += direction.y;
    x= int(px);
    y= int(py);
    copy(m_imgFrame,0,0,80,96,x,y,80,96);
    popMatrix();
    
  if((x < player.getPosX()+1*tileSize && x > player.getPosX()-1*tileSize )&& (y < player.getPosY()+1*tileSize && y > player.getPosY()-1*tileSize)){
    option = 4;
    lose();
    px = 0;
    py = 0;
    
  }
    
    
}


       
  
  
  void changeDir(int direction)
  {
    m_direction = direction;
  }
  
  int getNPCType()
  {
    return m_npcType;
  }
  
  float getPosX()
  {
    return m_posX;
  }
  
  float getPosY()
  {
    return m_posY;
  }
  
  int getType()
  {
    return m_npcType;
  }
}


void lose() { //metodo al perder
  //image(fondo2, 0, 0);
  background(0);
  fill(0);
  textSize(80);
  text("Perdiste!", 300, 100);
  fill(b1, 160);
  rect(80, 165, 140, 60, 5);
  textSize(30);
  fill(n1);
  text("Reiniciar", 90, 205);
  //al hacer click el color de los botones se invierte y reinicia el juego
  if ((mouseX>80) && (mouseX<80+140) && (mouseY>165) && (mouseY<165+60)) {
    b1=255;
    n1=0;
  } else {
    b1=0;
    n1=255;
  }
  if ((mouseX>80) && (mouseX<80+140) && (mouseY>165) && (mouseY<165+60) && (mousePressed==true)) {
    option = 1;
  }
  fill(b2, 160);
  rect(80, 285, 140, 60, 5);
  textSize(30);
  fill(n2);
  text("Menú", 110, 325);
  //al hacer click el color de los botones se invierte y lleva al menú principal
  if ((mouseX>80) && (mouseX<80+140) && (mouseY>285) && (mouseY<285+60)) {
    b2=255;
    n2=0;
  } else {
    b2=0;
    n2=255;
  }
  if ((mouseX>80) && (mouseX<80+140) && (mouseY>285) && (mouseY<285+60) && (mousePressed==true)) {
    option = 0;
  }
}
