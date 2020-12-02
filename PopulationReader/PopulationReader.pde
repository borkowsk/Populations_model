// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// v12 - to już chyba finał :-D

import java.util.Map;

//Parametry wizualizacji
final boolean GENERATEMOVIE=false;//Czy wogóle tworzyć film?
final boolean COLOR=false;      

final int FRAMES=5;
final int VFRAMES=100;//Co ile klatek obrazu zapisujemy klatke filmu
final int startX=100;
final int startY=100;
final float size=800;

final boolean ORBVISUAL=true;//wizualizacja typu ORB (kule)
final int BACKGROUND=255;//Tło 
float BACKGROUNDDENSITY=200; //Im większa wartośc tym szybciej znika stara zawartośc rysunku 
float      VDENSITY=255;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=200;//Ponizej jakiej całkiem intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV
float   bubleRad=2;//Współczynnik proporcjonalności promienia bloba do pierwiastka z biomasy populacji
int     console=0;

boolean mutantConnVis=false;
boolean VISTRANSFERS=true;//Czy w ogóle linie
boolean VISALLTRANSF=true;//Czy tylko wybranego węzła czy wszystkie

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy
String foldSelection=//"/data/wb/SCC/PROCESSING/Populations";
  //"/home/borkowsk/data/wb/Dokumenty/Moje dokumenty/2018_Memetyka-nieSczyrk/";
  //"/data/wb/_DANE/MemetykaSieciEkologiczneKultur/Population10fff/"
  //"/data/wb/_DANE/MemetykaSieciEkologiczneKultur/Population10fff/"
  "../nets/"
  ;
File   foldSelectorF=null;
String modelName=//null;
      "../nets/BMLVN12x2MULTImet0.9970000mut0.0000100cat0.0010000minW0.1S2.0_env25000.0fH0FFfH0C7fH0B5fH023fH011x50000.0tq0.01dt2018.02.13.12.55.11.386.00031.19000.txt"
      //"BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fH800fH400fH200fH0F0fH001x35000.0tq0.01dt2018.02.13.12.51.37.267.21650.98047.txt"
      //"BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fH800fH400fH200fH0F0fH001x25000.0tq0.01dt2018.02.13.12.23.03.228.12483.59961.txt"
      //"BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.20.34.314.00013.00000.txt"
      ;
String lastDescr;

void setup()
{
  checkCommnadLine();//Ewentualne uzycie parametrów wywołania
  //noSmooth()
  size(1000,1000);
  background(128); //Clear the window
  noStroke();
  noFill();
  frameRate(FRAMES); //frames per second
  
  if(modelName==null)
  {
    if(foldSelection!=null)
    {
        foldSelectorF=new File(foldSelection);
        foldSelection=null;
        println("Wejście do folderu ",foldSelectorF.getAbsolutePath());
    }
    selectFolder("Select a folder to process:", "folderSelected",foldSelectorF);
    do{ delay(100);} while(foldSelection==null);
    if(foldSelectorF!=null)
      selectInput("Select a file to process:", "fileSelected",foldSelectorF);
    else
      selectInput("Select a file to process:", "fileSelected");
    do{ delay(100);} while(modelName==null);
    frame.setTitle(foldSelectorF.getName());
  }
  
  if(modelName==null || modelName=="") //Jak się nie uda pliku znakeźć
          exit();
   
  int lines=readModel(island,modelName); // inicjalizacja modelu z pliku
  
  initStats();
  println(modelName,lines,"lines");
  text(modelName,10,height-40);
  lastDescr=descriptionOfModel(':','\n','\n');
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
  fill(BACKGROUND,BACKGROUNDDENSITY);//TŁO mocno półprzejrzyste
  rect(0,0,width,height-20);
  
  if(frameCount==0)
  {
      if(COLOR)
        drawAreaCO(island); 
      else
        drawAreaBW(island); 
      println("first draw");
      doStatistics();
      FirstVideoFrame();
  }
    
  timeStep(island);//Dodawanie połączeń
  
  if(VISTRANSFERS) 
  if(COLOR)
      drawTransfersCO(island);
  else
      drawTransfersBW(island);
      
  //Główna wizualizacja zawsze    
  if(COLOR)
       drawAreaCO(island); 
  else
       drawAreaBW(island); 
  
  noStroke();
  fill(255);
  rect(0,height-20,width,20);//STATUS LINE
  fill(0);
  text(" NofSpec: "+speciesDictionary.size(),3,height-2);
  fill(200);
  text("AlivePop:"+island.alivePopulations+" NofLinks: "+island.trophNet.size()+" MaxTr:"+maxTransfer,width/3,height-2);
  fill(128);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,700,height-2); 
  println();
  if(frameCount % VFRAMES==0) 
                  NextVideoFrame();
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
