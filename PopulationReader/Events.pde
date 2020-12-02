//  Dopasowana do modelu obsługa zdarzeń
///////////////////////////////////////////////////
int searchedX=-1;
int searchedY=-1;
aPopulation theSelected=null;
double minDist2Selec=MAX_INT;
double maxTransSelec=-MAX_INT;
boolean Clicked=false;

void mouseClicked()
{
  Clicked=true;
  searchedX=mouseX;
  searchedY=mouseY;
}

void keyPressed() 
{
  print("KEY:","'",key,"'",(int)key,"\t");
  switch(key)
  {
  case '\n': VISTRANSFERS=!VISTRANSFERS; break;
  case ',': VDENSITY/=2;if(VDENSITY<10) VDENSITY=10;break;
  case '.': VDENSITY+=10;if(VDENSITY>255) VDENSITY=255;break;
  case '>': DENSITYDIV++;break;
  case '<': DENSITYDIV--;if(DENSITYDIV<2) DENSITYDIV=2;
          break;
  //default:println("Command '"+key+"' unknown");break;
  }
  
  if (key == ESC) 
  {
    key = 0;  // Fools! don't let them escape!
  }
}


void exit() //it is called whenever a window is closed. 
{
  noLoop();      //For to be sure...
  CloseVideo();    //Finalise of Video export
  delay(100);      // it is possible to close window when draw() is still working!
  write(island,modelName+".INPECTION"+nf(frameCount,10));//Koncowy zapis filmu
  //output.flush();  // Writes the remaining data to the file
  //output.close();  // Finishes the file
  println("Thank You");
  super.exit(); //What library superclass have to do at exit
} 

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI 
///////////////////////////////////////////////////////////////////////////////////////////