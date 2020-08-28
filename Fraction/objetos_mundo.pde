class OverworldObject extends Collision
{
  float px,py;
  int x, y;
  PImage m_sprite,m_imgFrame;
  private int m_direction, m_spriteCount, m_npcType;
  float vel = 0.3;
  OverworldObject(float posX, float posY, PImage sprite, int type)
  {
    super(posX,posY,tileSize);
    m_sprite = sprite;
    m_npcType = type;
    
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
    PVector direction = getDireccion(player.getPosX(),player.getPosY(), px, py, vel);
    noStroke();
    /*fill(200, 0, 0);
    rectMode(CENTER);
    rect(px, py, w, h);
   */
    px += direction.x;
    py += direction.y;
    x= int(px);
    y= int(py);
    copy(m_imgFrame,0,0,80,96,x,y,80,96);
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
