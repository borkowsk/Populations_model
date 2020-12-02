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
final int FRAMES=10;
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
boolean simulationRun=true;
boolean VISTRANSFERS=true;

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
  
  for(int i=0;i<NofISLAND;i++)
      islands[i]=new anArea();
  
  size=(size-INSMARGINS)/sqrt(NofISLAND);
  
  int lines=readModel(islands[3],altModel); // inicjalizacja modelu z pliku
      lines=readModel(islands[5],altModel); // inicjalizacja modelu z pliku      

  initializeModel(); // inicjalizacja modelu może się różnic w różnych sytuacjach mimo że model się nie zmienia
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
 
  stroke(255);
  line(0,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,width,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4);
  line(0,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,width,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4);
  line(size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,0,size+INSMARGINS/2+EXTMARGINS-INSMARGINS/4,height-STATUS);
  line(2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,0,2*(size+INSMARGINS/2)+EXTMARGINS-INSMARGINS/4,height-STATUS);
  
  if(StepCounter==0)
  {
      doStatistics();
      FirstVideoFrame();
      write(islands[0],modelName+".0START");//Startowy stan ekosystemu
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
  text("AlivePop:"+islands[0].alivePopulations+" NofLinks: "+islands[0].trophNet.size()+" MaxTr:"+maxTransfer,width/3,height-2);
  fill(0,0,128);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,700,height-2); 
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
      println(" -------------------------------------------------------------->writing populations");
      write(islands[0],modelName+"."+nf(SC,5));//Aktualny stan ekosystemu
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
