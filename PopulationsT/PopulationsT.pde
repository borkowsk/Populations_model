// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
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
final boolean GENERATEMOVIE=true;//Czy wogóle tworzyć film?
      int STEPperFRAME=20; //Ile kroków symulacji pomiędzy wizualizacjami
final int FRAMES=50;
final int VFRAMES=10;//Co ile klatek obrazu zapisujemy klatke filmu
final int startX=100;
final int startY=100;
final float size=800;
final boolean ORBVISUAL=true;//wizualizacja typu ORB (kule)
final float  RANDSELECT=0.001;//Prawdopodobieństwo spontanicznej zmiany obserwowanego obiektu

final int BACKGROUND=255;
float BACKGROUNDDENSITY=250; //Im większa wartośc tym szybciej znika stara zawartośc rysunku 
float      VDENSITY=200;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=25;//Ponizej jakiej całkiem intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV

float   bubleRad=2;//Współczynnik proporcjonalności promienia bloba do pierwiastka z biomasy populacji
int     console=0;
boolean simulationRun=true;
boolean mutantConnVis=false;
boolean VISTRANSFERS=true;//Czy w ogóle linie
boolean VISALLTRANSF=true;//Czy tylko wybranego węzła czy wszystkie

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy
String modelName;
String lastDescr;

void setup()
{
  checkCommnadLine();//Ewentualne uzycie parametrów wywołania
  //noSmooth()
  size(1000,1000);
  background(BACKGROUND); //Clear the window
  noStroke();
  noFill();
  frameRate(FRAMES); //frames per second
  initializeModel(); // inicjalizacja modelu może się różnic w różnych sytuacjach mimo że model się nie zmienia
  initStats();
  modelName=nameOfModel();
  println(modelName);
  //text(modelName,10,height-40);
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
      
  println(" Step: ",StepCounter, ": ");
  
  noStroke(); 
  
  fill(BACKGROUND,BACKGROUNDDENSITY);//TŁO mocno półprzejrzyste albo i nie
  
  rect(0,0,width,height-20);
  
  if(StepCounter==0)
  {
      drawArea(island); println("first draw");
      doStatistics();
      if(GENERATEMOVIE)
            FirstVideoFrame();
      write(island,modelName+".0START");//Startowy stan ekosystemu
      fill(5);
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
  
  if(RANDSELECT > random(1) ) // akcja spontanicznej zmiany obserwowanego obiektu
  {
    theSelected=island.populations.get( int(random( island.populations.size() )) );
  }
  
  if(VISTRANSFERS) 
      drawTransfers(island);
      
  //Główna wizualizacja zawsze    
  drawArea(island);
  
  noStroke();
  fill(255);
  rect(0,height-20,width,20);//STATUS LINE
  if(simulationRun)
      fill(55);
  else
      fill(0);
  text(StepCounter+", NofSpec: "+speciesDictionary.size(),3,height-2);
  fill(100);
  text("AlivePop:"+island.alivePopulations+" NofLinks: "+island.trophNet.size()+" MaxTr:"+maxTransfer,width/3,height-2);
  fill(150);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,700,height-2); 
  println();
  if(GENERATEMOVIE && (frameCount % VFRAMES==0)) 
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
      write(island,modelName+"."+nf(SC,5));//Aktualny stan ekosystemu
    }
  }
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
     // float XINT=255.0*(fSusc/MASK);
     // float YINT=255.0*(fActi/MASK);
      float SPEC=popul.species.countBits/float(MASKBITS*2);
      //print(SPEC,",");//Poziom omnipotencji genetycznej - im mniej tym mniej bitów czyli większa specjalizacja
      SPEC*=255;
      
      float R;
      //R=(float)(1+Math.log(1.0+b)*bubleRad);
      if(ORBVISUAL)
        R=(float)(Math.pow(b,0.33333333333)*bubleRad);
      else
        R=(float)(Math.sqrt(b)*bubleRad);
        
      if(R<1){ R=1; print(',');}//Musi być choc slad
      
      stroke(SINT,0,0,VDENSITY);//Trzeci chromosom - marker
      fill(SPEC,VDENSITY);//"ciało"
      ellipse(x,y,R,R);
      
      if(ORBVISUAL && R>5)
      {
        noStroke();
        fill(255,VDENSITY/3);
        ellipse(x,y-R/2+R/8,R/4,R/8);
      }
      
      if(popul.currincome>popul.currloss)
        stroke(0);
      else
        stroke(255);
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
        noFill(); stroke(255);strokeWeight(3);
        ellipse(x,y,R+1,R+1);
        strokeWeight(1);fill(200); noStroke();
        rect(0,0,400,25);
        fill(128);
        text(popul.species.Key()+" Bio: "+popul.biomas+" "+binary(popul.species.suscepBits,MASKBITS)+":"+binary(popul.species.activeBits,MASKBITS),1,20);
      }
    }
    else
    {
      float ofs=popul.species.sizelog;
      float x=startX+size*((float)popul.species.suscepBits/MASK)+ofs;
      float y=startY+size*((float)popul.species.activeBits/MASK)+ofs;
      stroke(0);
      point(x,y); //print(".");
      noStroke();
    }
  }
  
  //NIE SZUKA DO NASTĘPNEGO KLIKNIECIA
  searchedX=-1;
  searchedY=-1;
}

void drawTransfers(anArea is)
{
  for(aPopLink lnk:is.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.lasttransfer/maxTransfer));  
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
          if(maxTransSelec<lnk.lasttransfer)
             maxTransSelec=lnk.lasttransfer;//Na początku może być trochę kiepsko ale się naprawi w kolejnych wizualizacjach
          int inten=(int)(255*(lnk.lasttransfer/maxTransSelec));
          strokeWeight(2);
          stroke(0,inten);
          line(x1,y1,x2,y2);
          strokeWeight(1);
          //println("   ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
        }
        
        if(VISALLTRANSF)
        {
          if(lnk.lasttransfer>=maxTransfer)
          {
            stroke(0);
            //println(" M ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
          }
          else
          {
            //intensity/=DENSITYDIV;//Czy to konieczne?
            stroke(BACKGROUND/3,intensity);
          }
          
          line(x1,y1,(x1+x2)/2,(y1+y2)/2);
          stroke(BACKGROUND/2,intensity);
          line(x2,y2,(x1+x2)/2,(y1+y2)/2);
        }
      }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
