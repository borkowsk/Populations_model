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
  switch(key)
  {
  case '1': STEPperFRAME=1;text("StPerF: "+STEPperFRAME,1,16);break;
  case '2': STEPperFRAME=2;text("StPerF: "+STEPperFRAME,1,16);break;
  case '3': STEPperFRAME=5;text("StPerF: "+STEPperFRAME,1,16);break;
  case '4': STEPperFRAME=10;text("StPerF: "+STEPperFRAME,1,16);break;
  case '5': STEPperFRAME=25;text("StPerF: "+STEPperFRAME,1,16);break;
  case '6': STEPperFRAME=50;text("StPerF: "+STEPperFRAME,1,16);break;
  case '7': STEPperFRAME=100;text("StPerF: "+STEPperFRAME,1,16);break;
  case '8': STEPperFRAME=150;text("StPerF: "+STEPperFRAME,1,16);break;
  case '9': STEPperFRAME=200;text("StPerF: "+STEPperFRAME,1,16);break;
  case '0': STEPperFRAME=10;text("StPerF: "+STEPperFRAME,1,16);break;
  case ' ': save(modelName+"."+nf((float)StepCounter,6,5)+".PNG");
            write(island,modelName+"."+nf((float)StepCounter,6,5));//Aktualny stan ekosystemu
            break;
  case 's': simulationRun=false; break;
  case 'r': simulationRun=true; break;
  case 'm': mutantConnVis=!mutantConnVis; break;
  case 'M': mutantConnVis=false; break;
  case '\n': VISTRANSFERS=!VISTRANSFERS; break;
  case ',': VDENSITY/=2;if(VDENSITY<10) VDENSITY=10;break;
  case '.': VDENSITY+=10;if(VDENSITY>255) VDENSITY=255;break;
  case '>': DENSITYDIV++;break;
  case '<': DENSITYDIV--;if(DENSITYDIV<2) DENSITYDIV=2;break;
  default:println("Command '"+key+"' unknown");break;
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
  write(island,modelName+"."+nf((float)StepCounter,5,5));//Koncowy stan ekosystemu
  outstat.flush();  // Writes the remaining data to the file
  outstat.close();  // Finishes the file
  println("Thank You");
  super.exit(); //What library superclass have to do at exit
} 

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI 
///////////////////////////////////////////////////////////////////////////////////////////