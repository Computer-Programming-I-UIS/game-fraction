void suboptions(){
  background(0);
switch (opt) {
    //opciones
  case 0:
    caso0();
    break;
    //ayuda

  case 1:
    //créditos
    creditos();
    break;
  }
}

void caso0() { //realiza el caso 0, muestra en pantalla las opciones
  fill(0);
  textSize(60);
  text("Opciones", 440, 70);
  fill(b1, 160);

  //al hacer click el color de los botones se invierte y entra en la ayuda
  if ((mouseX>425) && (mouseX<425+130) && (mouseY>160) && (mouseY<160+60)) { 
    b1=255;
    n1=0;
  } else {
    b1=0;
    n1=255;
  }
  if ((mouseX>425) && (mouseX<425+130) && (mouseY>160) && (mouseY<160+60) && (mousePressed==true)) {
    opt = 1;
  }
  fill(b2, 160);
  rect(425, 300, 130, 60, 5);
  fill(n2);
  textSize(30);
  text("Créditos", 480, 340);
  //al hacer click el color de los botones se invierte y entra en los créditos
  if ((mouseX>425) && (mouseX<425+130) && (mouseY>300) && (mouseY<300+60)) { 
    b2=255;
    n2=0;
  } else {
    b2=0;
    n2=255;
  }
  if ((mouseX>425) && (mouseX<425+130) && (mouseY>300) && (mouseY<300+60) && (mousePressed==true)) {
    opt = 1;
  }
  fill(b3, 160);
  rect(10, 430, 100, 50, 5);
  fill(n3);
  textSize(30);
  text("Atrás", 65, 465);
  //al hacer click el color de los botones se invierte y regresa a la pestaña anterior
  if ((mouseX>10) && (mouseX<10+100) && (mouseY>430) && (mouseY<430+50)) {
    b3=255;
    n3=0;
  } else {
    b3=0;
    n3=255;
  }
  if ((mouseX>10) && (mouseX<10+100) && (mouseY>430) && (mouseY<430+50) && (mousePressed==true)) {
    option = 0;
  }
}


void creditos() { 
  //Créditos
  fill(0);
  textSize(50);
  text("Créditos", 400, 70);
  fill(#1F2BFF);
  textSize(30);
  text("Creadores: Ali Isaak", 200, 150);
  text("           Andrade Otto", 240, 200);
  fill(0);
  textSize(25);
  text("A continuación se refieren los derechos de autor de algunas imagenes utilizadas ", 30, 250);
  text("en nuestro juego (cuyo autor es conocido), por otra parte, las imagenes con autor ", 30, 280);
  text("desconocido se encuentran debidamente referenciadas en el código(pestaña Menu, línea 200),", 30, 310);
  text("al igual que los audios.", 30, 340);
  text("Muñeco de nieve:   Cisily", 300, 360);
  text("Montañas:   Carlos A. Gatica V.", 300, 400);
  fill(l, 160);
  rect(10, 430, 100, 50, 5);
  fill(n2);
  textSize(30);
  text("Atrás", 25, 465);
  //al hacer click el color de los botones se invierte y regresa a la pestaña anterior
  if ((mouseX>10) && (mouseX<10+100) && (mouseY>430) && (mouseY<430+50)) {
    l=255;
    n2=0;
  } else {
    l=0;
    n2=255;
  }
  if ((mouseX>10) && (mouseX<10+100) && (mouseY>430) && (mouseY<430+50) && (mousePressed==true)) {
    option = 0;
    delay(150);
    
  }
}
