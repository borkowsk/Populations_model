// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// Multi00 - uruchomienie wersji kilkuwyspowej - wpływ kultur.
// v12 - to już chyba finał :-D
// v11 - umożliwienie istnienia wielu źródeł sygnału/pokarmu jednocześnie i ewentualnie losowe zmiany obserwowanego
// v10 - przywrócenie domyślnej QUADRATICINTERACTIONS na true.
//       bo bez niej małe klasy są nadmiernie preferowane
//     - wizualizacja ORB
//     - sterowanie szybkościa symulacji z klawiszy 1-0
// v9 - Szansa mutacji jest zawsze zalezna od liczebności populacji (niezaleznie od VIRTSIZE)
//    - \n do przelączania widocznosci transferów (linków) a SPC do zrzutów ekranu
//    - 9b zródła nie odzyskują "życia" od razu tylko muszą spłacić deficyt
//    - QUADRATICINTERACTIONS - czy w małej chwili czasu wzrost biomasy targetowej populacji jest zależny wypełnienia przez nia przestrzeni?
// v8 - zapis filmu tylko co iles klatek
//    - parametr wywołania
// v7 - podział aplikacji na pliki
//    - zaopatrzenie w zapis wideo
//    - zapis populacji do pliku
// v6 - włącznik zabezpieczenia małych populacji przed mutowaniem
//    - katastrofy: wymuszenie optymalizacji przez losowe uszkadzanie - zmniejszanie biomasy węzłów, 
//      co powinno bardziej szkodzić małym, ale nie koniecznie tak działa
// v5 - umożliwienie trybu populacji zależnych od rozmiaru środowiska
//    - wprowadzenie inspekcji populacji
//    - możliwość zatrzymywania symulacji bez zatrzymywania wizualizacji
//    - wizualizacja wybranego węzła i jego połączeń wchodzących
// v4 - poprawione kolorowanie i rozmiarowanie blobów
//    - wprowadzone wyłączanie czerwonej składowej (synonimiczne ekologicznie)
//    - POCZĄTEK wprowadzania zalezności od pojemności środowiska
import java.util.Map;

//Parametry wizualizacji
final boolean GENERATEMOVIE=false;//Czy wogóle tworzyć film?
      int STEPperFRAME=1; //Ile kroków symulacji pomiędzy wizualizacjami
final int FRAMES=25;
final int VFRAMES=1;//Co ile klatek obrazu zapisujemy klatke filmu
final int INSMARGINS=100;
final int EXTMARGINS=50;
      float size=800;
final float STATUS=20;

final boolean ORBVISUAL=true;//wizualizacja typu ORB (kule)
final float  RANDSELECT=0.001;//Prawdopodobieństwo spontanicznej zmiany obserwowanego obiektu
float BACKGROUNDDENSITY=10; //Im większa wartośc tym szybciej znika stara zawartośc rysunku 
float      VDENSITY=20;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=15;//Ponizej jakiej całkiem intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV
float   bubleRad=1;//Współczynnik proporcjonalności promienia bloba do pierwiastka z biomasy populacji
int     console=0;
boolean simulationRun=false;
boolean VISTRANSFERS=true;


//file:///home/borkowsk/ProcessingSkeches/PopulationsMulti00/BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFx350000.0tq0.01dt2018.01.30.12.42.06.209.22000.txt
//file:///home/borkowsk/ProcessingSkeches/PopulationsMulti00/BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.21.24.276.010000.00000.txt
//file:///home/borkowsk/ProcessingSkeches/PopulationsMulti00/BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.21.24.276.001000.00000.txt
//BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fH800fH400fH200fH0F0fH001x35000.0tq0.01dt2018.02.13.12.51.37.267.003851.45996.txt
//BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fH800fH400fH200fH0F0fH001x35000.0tq0.01dt2018.02.13.12.51.37.267.21650.98047.txt
String altModel="BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fHFFFfH0FFfH00FfH777fH555x50000.0tq0.01dt2018.02.06.11.21.24.276.010000.00000.txt";
String modelName="BMLVN12x2met0.9970000mut0.0010000cat0.0010000minW0.1S2.0_env25000.0fH800fH400fH200fH0F0fH001x35000.0tq0.01dt2018.02.13.12.51.37.267.003851.45996.txt";

String lastDescr;

int NofISLAND=9;
anArea[] islands=new anArea[NofISLAND]; //Pojemnik na zbiór populacji

void setup()
{
  checkCommnadLine();//Ewentualne uzycie parametrów wywołania
  //noSmooth()
  size(900,920);
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
  
  if(CHILDINTERVAL==0)
  {
    for(int i=0;i<NofISLAND;i++)
        islands[i]=new anArea();
  }
  else
  {
    islands[3]=new anArea();
    islands[4]=new anArea();
    islands[5]=new anArea();
  }
  
  size=(size-INSMARGINS)/sqrt(NofISLAND);
  
  int lines=readModel(islands[3],altModel); // inicjalizacja modelu z pliku
      lines=readModel(islands[5],modelName); // inicjalizacja modelu z pliku      

  initializeModel(); // inicjalizacja modelu może się różnic w różnych sytuacjach mimo że model się nie zmienia

  modelName=nameOfModel();
  initStats();
  
  //text(modelName,10,height-40);
  lastDescr=descriptionOfModel(':','\n','\n');
  text(lastDescr,size+EXTMARGINS,32);
  
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
  println(" Step: ",StepCounter, ": ");
  
  noStroke(); 
  fill(128,BACKGROUNDDENSITY);//TŁO mocno półprzejrzyste
  rect(0,0,width,height-20);
  
  if(Clicked)//Żądanie zmiany wybranego
  {
     minDist2Selec=MAX_INT;
     maxTransSelec=-MAX_INT;
     println("  Looking for ",searchedX,searchedY);
     Clicked=false;
  }
  
  int n=int(sqrt(NofISLAND));
  for(int j=0;j<NofISLAND;j++)
  {
    //print(NofISLAND,j);
    int a=j%n;
    int b=j/n;
    //println(" ",a,b);
    if(VISTRANSFERS && islands[j]!=null) 
    {
      drawTransfers(islands[j],int(a*(size+INSMARGINS/2)+EXTMARGINS),int(b*(size+INSMARGINS/2)+EXTMARGINS),int(size));
    }
        
    //Główna wizualizacja zawsze    
    if(islands[j]!=null)
      drawArea(islands[j],int(a*(size+INSMARGINS/2)+EXTMARGINS),int(b*(size+INSMARGINS/2)+EXTMARGINS),int(size));
  }
 
    
  //NIE SZUKA DO NASTĘPNEGO KLIKNIECIA
  searchedX=-1;
  searchedY=-1;
  
  fill(128);noStroke();
  rect(0,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,width,-16);
  rect(0,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,width,-16);
  rect(0,3*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,width,-16);
  fill(255);
  
  if(islands[0]!=null) text("AlivePop:"+islands[0].alivePopulations+" NofLinks: "+islands[0].trophNet.size(),0      ,   size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4);
  if(islands[3]!=null) text("AlivePop:"+islands[3].alivePopulations+" NofLinks: "+islands[3].trophNet.size(),0      ,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  if(islands[6]!=null) text("AlivePop:"+islands[6].alivePopulations+" NofLinks: "+islands[6].trophNet.size(),0      ,3*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  if(islands[1]!=null) text("AlivePop:"+islands[1].alivePopulations+" NofLinks: "+islands[1].trophNet.size(),1*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,   size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4);
  if(islands[4]!=null) text("AlivePop:"+islands[4].alivePopulations+" NofLinks: "+islands[4].trophNet.size(),1*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  if(islands[7]!=null) text("AlivePop:"+islands[7].alivePopulations+" NofLinks: "+islands[7].trophNet.size(),1*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,3*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  if(islands[2]!=null) text("AlivePop:"+islands[2].alivePopulations+" NofLinks: "+islands[2].trophNet.size(),2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,   size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4);
  if(islands[5]!=null) text("AlivePop:"+islands[5].alivePopulations+" NofLinks: "+islands[5].trophNet.size(),2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  if(islands[8]!=null) text("AlivePop:"+islands[8].alivePopulations+" NofLinks: "+islands[8].trophNet.size(),2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,3*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  stroke(255);
  line(0,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,width,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4);
  line(0,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,width,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  line(size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,0,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,height-STATUS);
  line(2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,0,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,height-STATUS);
  
  if(StepCounter==0)
  {
      doStatistics();
      FirstVideoFrame();
      //write(islands[0],modelName+".0START");//Startowy stan ekosystemu
      fill(255,255,0);
      text("STPS:"+STEPperFRAME //Ile kroków symulacji pomiędzy wizualizacjami
          +" FRM:"+FRAMES  //Ile klatek na realną sekundę próbuje liczyć
          +" VID:"+VFRAMES //Co ile klatek obrazu zapisujemy klatke filmu
          +(ORBVISUAL?" ORB VIS.":"") //Czy wizualizacja kulami?
          ,1,16);
  }
    
  if(simulationRun)
  {
      runSteps(STEPperFRAME);// Tu mogą być różne rzeczy w zależności od potrzeb
      doStatistics();
  }
    
  println();  
  noStroke();
  fill(255);
  rect(0,height-20,width,20);//STATUS LINE
  if(simulationRun)
      fill(255,0,0);
  else
      fill(0);
  text(StepCounter+", NofSpec: "+speciesDictionary.size(),3,height-2);
  fill(0,200,0);
  text(" MaxTr:"+maxTransfer,width/3,height-2);
  fill(0,0,128);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,width/2,height-2); 
  println();
  if(frameCount % VFRAMES==0) 
                  NextVideoFrame();
  //Tylko przy pełnych JEDNOSTKACH czasu
  //if(frameCount % STEPperFRAME==0  ) //???
  if( -(StepCounter-Math.ceil(StepCounter)) <= TIMEQUANT*STEPperFRAME ) // <-- to nie działa jeśli zmieniany jest STEPperFRAME
  {
    println(" ---------------------------------------------------------------->complete next unit of time "+(StepCounter-Math.ceil(StepCounter)));
    int SC=(int)(StepCounter);
    if(SC%1000==0)
    {
      //println(" -------------------------------------------------------------->writing populations");
      //write(islands[0],modelName+"."+nf(SC,5));//Aktualny stan ekosystemu
      save(modelName+"."+nf((float)StepCounter,6,5)+".PNG");
    }
    
    if(CHILDINTERVAL!=0 && SC%CHILDINTERVAL==0)
    {
      int c=int(random(NofISLAND));
      if(islands[c]==null)
          islands[c]=new anArea();
    }
  }
}

void fileSelected(File selection) 
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    modelName=selection.getAbsolutePath();
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
