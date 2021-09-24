// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// v12 - to już chyba finał :-D

import java.util.Map;

//Parametry wizualizacji
final boolean GENERATEMOVIE=false;//Czy wogóle tworzyć film?
      
final int FRAMES=3;
final int VFRAMES=100;//Co ile klatek obrazu zapisujemy klatke filmu
final int startX=100;
final int startY=100;
final float size=800;

final boolean ORBVISUAL=true;//wizualizacja typu ORB (kule)

float BACKGROUNDDENSITY=10; //Im większa wartośc tym szybciej znika stara zawartośc rysunku 
float      VDENSITY=100;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=25;//Ponizej jakiej całkiem intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV
float   bubleRad=3;//Współczynnik proporcjonalności promienia bloba do pierwiastka z biomasy populacji
int     console=0;

boolean mutantConnVis=false;
boolean VISTRANSFERS=true;

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy
String lastDescr;

String modelName=null;//"test.txt";
      //"/home/borkowsk/ProcessingSkeches/Population1Reader/BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.20.34.314.00013.00000.txt";
      //"./BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.20.34.314.00013.00000.txt";

void fileSelected(File selection) 
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    modelName=selection.getAbsolutePath();
  }
}

void setup()
{
  checkCommnadLine();//Ewentualne uzycie parametrów wywołania
  //noSmooth()
  size(1000,1000);
  background(128); //Clear the window
  noStroke();
  noFill();
  frameRate(FRAMES); //frames per second
  
  //OTWIERANIE PLIKU
  //selectFolder("Select a folder to process:", "folderSelected");
  if(modelName==null)
  {
    selectInput("Select a file to process:", "fileSelected");
    do{ delay(100);} while(modelName==null);
  }
  
  int lines=readModel(island,modelName); // inicjalizacja modelu z pliku
  initStats();
  println(modelName,lines,"lines");
  text(modelName,10,height-40);
  
  lastDescr=descriptionOfModel(':',' ','\n');
  text(lastDescr,10,32);
  
  if(GENERATEMOVIE)
  {
    videoExportEnabled=true;
    println("Start video export");
    initVideoExport(this,modelName+".mp4",FRAMES*2);//x2 przyśpieszone
  }
  else videoExportEnabled=false;
}

void draw()
{
  if(island.alivePopulations<2) 
      return;//Model się skończył przedwczesnie
      
  noStroke(); 
  fill(128,BACKGROUNDDENSITY);//TŁO mocno półprzejrzyste
  rect(0,0,width,height-20);
  
  if(frameCount==0)
  {
      drawArea(island); println("first draw");
      doStatistics();
      FirstVideoFrame();
  }
    
  if(VISTRANSFERS) 
      drawConnections(island);
      
  //Główna wizualizacja zawsze    
  drawArea(island);
  
  noStroke();
  fill(255);
  text(lastDescr,10,32);
  rect(0,height-20,width,20);//STATUS LINE
  fill(0);
  text(" NofSpec: "+speciesDictionary.size(),3,height-2);
  fill(0,200,0);
  text("AlivePop:"+island.alivePopulations+" NofLinks: "+island.trophNet.size()+" MaxTr:"+maxTransfer,width/3,height-2);
  fill(0,0,128);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,700,height-2); 
  println();
  
  if(frameCount % VFRAMES==0) 
                  NextVideoFrame();
}

//IMPLEMENTACJA WIZUALIZACJI  I ROBIENIA FILMU
/////////////////////////////////////////////////////////////////////
void drawArea(anArea is)
{
  if(Clicked)//Żądanie zmiany wybranego
  {
     minDist2Selec=MAX_INT;
     maxTransSelec=-MAX_INT;
     println("  Looking for ",searchedX,searchedY);
     Clicked=false;
  }
  noStroke(); 
  
  for(aPopulation popul: is.populations)
  { 
    double b=popul.biomas;
   
    if(b>0.0)
    {
      float fSusc=popul.species.suscepBits;
      float fActi=popul.species.activeBits;
      float ofs=popul.species.sizelog;
      
      float x=(float)(startX+size*fSusc/MASK+ofs);
      float y=(float)(startY+size*fActi/MASK+ofs); 
      float SINT=255.0*((float)popul.species.maxsize/MASK);
      float XINT=255.0*(fSusc/MASK);
      float YINT=255.0*(fActi/MASK);
      
      float R;
      
      if(ORBVISUAL)
        R=(float)(Math.pow(b,0.33333333333)*bubleRad);
      else
        R=(float)(Math.sqrt(b)*bubleRad);
      if(R<1){ R=1; print(',');}//Musi być choc slad
      
      stroke(SINT,0,0,VDENSITY);//Trzeci chromosom - marker
      fill(SINT,XINT,YINT,VDENSITY);//"ciało"
      ellipse(x,y,R,R);//println(x,y,R);
      
      if(ORBVISUAL && R>5)
      {
        //print('.');
        noStroke();
        fill(255,VDENSITY/3);
        ellipse(x,y-R/2+R/8,R/4,R/8);
      }
      
      if(popul.currincome>popul.currloss)
        stroke(255,255,0);
      else
        stroke(255,0,0);
      point(x,y);//"serce" 
      
      
      if(searchedX>0 && searchedY>0)
      {
        double dist2=Math.sqrt(sqr(x-searchedX)+sqr(y-searchedY));//Szukanie print(dist2,", ");
        if(dist2 < minDist2Selec)
        {
          minDist2Selec=dist2;        //print(" ? ");
          theSelected=popul;
        }
      }
      else //Jak już znalezione poprzednio
      if(popul==theSelected)
      {
        noFill(); stroke(255);
        ellipse(x,y,R+1,R+1);
        fill(128); noStroke();
        rect(0,0,400,25);
        fill(255);
        text(popul.species.Key()+" Bio: "+popul.biomas+" "+binary(popul.species.suscepBits,MASKBITS)+":"+binary(popul.species.activeBits,MASKBITS),1,20);
      }
    }
    else
    {
      print('`');
      float ofs=popul.species.sizelog;
      float x=startX+size*((float)popul.species.suscepBits/MASK)+ofs;
      float y=startY+size*((float)popul.species.activeBits/MASK)+ofs;
      stroke(0,0,0);
      point(x,y); //print(".");
      noStroke();
    }
  }
  
  //NIE SZUKA DO NASTĘPNEGO KLIKNIECIA
  searchedX=-1;
  searchedY=-1;
}

void drawConnections(anArea is)
{
  for(aPopLink lnk:is.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.weight));  
      //print(intensity,", ");
      if(lnk.target==theSelected
      || intensity>VDENSITY/DENSITYDIV )
      //&& intensity/DENSITYDIV>0)//Jak za dużo jest 
      {
        float of1=lnk.source.species.sizelog;
        float x1=startX+(float)(size*float(lnk.source.species.suscepBits)/MASK+of1);
        float y1=startY+(float)(size*float(lnk.source.species.activeBits)/MASK+of1);
        float of2=lnk.target.species.sizelog;
        float x2=startX+(float)(size*float(lnk.target.species.suscepBits)/MASK+of2);
        float y2=startY+(float)(size*float(lnk.target.species.activeBits)/MASK+of2);
        if(lnk.target==theSelected)//Trzeba (?) niestety powtórzyć sprawdzanie warunku
        {
          stroke(255,255,255,intensity*2);
          line(x1,y1,x2,y2);
          stroke(175,175,175,intensity*2);
          line(x2,y2,(x1+x2)/2,(y1+y2)/2);
        }
        else
        if(intensity>VDENSITY/DENSITYDIV)
        {
          stroke(200,200,0,intensity);
          line(x1,y1,x2,y2);
          stroke(100,100,0,intensity);
          line(x2,y2,(x1+x2)/2,(y1+y2)/2);
        }
      }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////