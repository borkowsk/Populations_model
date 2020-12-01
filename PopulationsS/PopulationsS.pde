// BMLVN - Binary Masks Lotka-Voltera Network
//////////////////////////////////////////////////////////////////////////////////////////////////
// v4 - poprawione kolorowanie
//    - wprowadzone wyłączanie czerwonej składowej (synonimiczne ekologicznie)
//    - POCZĄTEK wprowadzania zalezności od pojemności środowiska
import java.util.Map;
final int MASK=0x3f;//0xfff//0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
final int MASKBITS=6;//12//8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
final boolean allowSizeSyn=false;//Czy dopuszczamy mutowanie bitów "rozmiaru" czyli synonimiczne ekologicznie gatunki (czerwona składowa)
final int FIDBITS=0x3f;//*MAX_INT & MASK*/ Jakie bity ma ustawione niesmiertelne źródło pokarmu ("komin hydrotermalny")
final float MUTATIONRATE=0.001;//Jak czesto na krok powstaje mutant w populacji - 
final float LINKMINWEIGHT=0.001;//Jakie najsłabsze linki uznajemy za istniejące przy łączeniu populacji
final float MINSTART=10; //Startowy zasób "biomasy" populacji mutanta
final float FEEDPORTION=50000; //Ile biomasy zródła maksyymalnie przypływa na jednostkę czasu (jest randomizowane) 
final float TIMEQUANT=0.01; //Ile czasu modelu upływa w każdym kroku
final float TIMEDUMP=0.99; //Ile zasobów zostaje na skutek zużycia czasowego w każdym kroku
final double  VIRTENVSIZE=1;//00000;//1024*1024; //Ile "biomasy" jednego gatunku(?) miesci się maksymalnie w środowisku
final boolean CLEAN=true;    //Czy czyścić sieć z martwych populacji?

//Parametry wizualizacji
final int   STEPperFRAME=10; //Ile kroków symulacji pomiędzy wizualizacjami
final int FRAMES=20;
final int startX=100;
final int startY=100;
final float size=800;
float BACKGROUNDDENSITY=10; //Im większa wartośc tym szybciej znika stara zawartośc rysunku 
float      VDENSITY=20;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=5;//Ponizej jakiej całkiem intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV
float   bubleRad=2;//Współczynnik proporcjonalności promienia bloba do pierwiastka z biomasy populacji
int     console=0;
boolean mutantConnVis=true;
boolean VISTRANSFERS=true;

class aSpecies //Informacja o gatunku
{
  int suscepBits;//susceptibility bits (maska "obrony")
  int activeBits;//activity bits (maska "ataku")
  int maxsize;
  float sizelog;//logarytm z maxsize przydatny do wizualizacji
  String _key=null;
  
  aSpecies(int tB,int sB,int ms)
   { suscepBits=tB;activeBits=sB;maxsize=ms;sizelog=log(1+ms);}
  aSpecies(aSpecies p)
   { suscepBits=p.suscepBits;activeBits=p.activeBits;maxsize=p.maxsize;sizelog=p.sizelog;}
  aSpecies()
   {suscepBits=0;activeBits=0;maxsize=0;sizelog=0;}
  String Key()
   {
     if(_key==null) 
     {
     int form=(MASKBITS+3)/4;
     _key=hex(suscepBits,form)+":"+hex(activeBits,form)+":"+hex(maxsize,form);
     }
     return _key;
   }
}

HashMap<String,aSpecies> speciesDictionary=new HashMap<String,aSpecies>();

class aPopulation //Informacja o populacji jakiegoś gatunku
{
  double biomas;
  double currincome;//wpływy troficzne w aktualnym kroku
  double currloss;//straty troficzne w aktualnym kroku
  
  aSpecies species; 
  aPopulation(aSpecies sp,float bim)
  { species=sp; biomas=bim;}
  aPopulation()
  { biomas=0; }
}

class aPopLink
{
  aPopulation source;//Kto jest eksploatowany
  aPopulation target;//Kto jest ekspluatującym
  double      weight;//Siła związku eksploatacji
  double   lasttransfer;//Do celów statystycznych
  aPopLink(aPopulation so,aPopulation ta,double w)
  {
    source=so;target=ta;weight=w;lasttransfer=0;
  }
}

class anArea //Obszar z wieloma populacjami
{
  ArrayList<aPopulation> populations;
  ArrayList<aPopLink>    trophNet;
  int alivePopulations=0;
  anArea()
  {
    populations=new ArrayList<aPopulation>(0);
    trophNet=new ArrayList<aPopLink>(0);
  }
  int findPopulOf(aSpecies what)//Znajduje populację danego gatunku
  {
    for(int i=0;i<populations.size();i++)
     if(populations.get(i).species==what)//To samo
      return i;
   
    return -1;//Nie ma
  }
  void addPopulation(aPopulation what,boolean test)
  {
    if(test
    && findPopulOf(what.species)>=0) //już jest
    return;//NIC NIE ROBIĆ!
    
    populations.add(what);//Dodajemy nową.
    makeConnections(this,what);//Funkcja tworząca połączenia troficzne dla nowej populacji 
  }
  boolean delPopulation(aPopulation what)
  {
    if(console>0) println("Removing ",what.species.Key());
    removeConnections(this,what);
    return populations.remove(what);//SUKCES or FAIL TODO CHECK
  }
  boolean delPopulation(int iwhat)
  {
    aPopulation what=populations.get(iwhat);
    if(what!=null)
    {
      if(console>0) println("Removing ",what.species.Key());
      removeConnections(this,what);
      populations.remove(iwhat);
      return true;//SUKCES
    }
    return false;//FAIL
  }
  //"Friends"
  //void makeConnections(anArea self,aPopulation what);
  //void removeConnections(anArea self,aPopulation what);
  //void createnewspecies(anArea self);//Powstawanie populacji przez mutację któregoś z bitów
  //void timeStep(anArea self) //Upływ czasy dla obszaru z populacjami
}

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy

void setup()
{
  //noSmooth();
  size(1000,1000);
  background(128); //Clear the window
  noStroke();
  noFill();
  frameRate(FRAMES); //frames per second
  
  //Simple feeding source. 
  /////////////////////////////////////////////////////////////
  //Zero oznacza że nie jest pełnoprawną częścią sieci
  aSpecies FID=new aSpecies( FIDBITS, 0 ,1);
  aPopulation FP=new aPopulation(FID,FEEDPORTION);
  println("Feed is ",FID.Key()," ofs:",FID.sizelog);
  island.addPopulation(FP,false);
  
  
  //Przodek czyli LUA. Nie może mieć żadnego zera
  //////////////////////////////////////////////////////
  aSpecies LUA=//new aSpecies( int(1+random(MAX_INT & MASK)) & MASK,int(1+random(MAX_INT & MASK)) & MASK,1);//random LUA
                new aSpecies( MASK, MASK ,1);//Full autotrophic LUA
  String luaKey=LUA.Key();
  println("LUA is ",luaKey," ofs:",LUA.sizelog);
  speciesDictionary.put(luaKey,LUA);
  island.addPopulation(new aPopulation(LUA,MINSTART),false);
  island.alivePopulations=2;
}

void keyPressed() 
{
  switch(key)
  {
  case 'm': mutantConnVis=!mutantConnVis; break;
  case 'M': mutantConnVis=false; break;
  case ' ': VISTRANSFERS=!VISTRANSFERS; break;
  case ',': VDENSITY/=2;if(VDENSITY<10) VDENSITY=10;break;
  case '.': VDENSITY+=10;if(VDENSITY>255) VDENSITY=255;break;
  case '>': DENSITYDIV++;break;
  case '<': DENSITYDIV--;if(DENSITYDIV<2) DENSITYDIV=2;break;
  default:println("Command '"+key+"' unknown");break;
  }
}

void draw()
{
  if(island.alivePopulations<2) return;//Model się skończył
  noStroke(); 
  fill(128,BACKGROUNDDENSITY);//TŁO mocno półprzejrzyste
  rect(0,0,width,height-20);
  if(StepCounter==0)
  {
      drawArea(island);
      println("first draw");
  }
  
  runSteps(STEPperFRAME);
  if(VISTRANSFERS) 
      drawTransfers(island);
  drawArea(island);
  
  noStroke();
  fill(255);
  rect(0,height-20,width,20);//STATUS LINE
  fill(255,0,0);
  text(StepCounter+", NofSpec: "+speciesDictionary.size(),3,height-2);
  fill(0,255,0);
  text("AlivePop:"+island.alivePopulations+" NofLinks: "+island.trophNet.size()+" MaxTr:"+maxTransfer,width/3,height-2);
  fill(0,0,128);
  text((VISTRANSFERS?"Dens:"+VDENSITY+" Div"+DENSITYDIV:" ")+" Mask:"+hex(MASK)+" FR:"+frameRate,700,height-2); 
}

void drawArea(anArea is)
{
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
      
       //float R=(float)(1+Math.log(1.0+b)*bubleRad);
      float R=(float)(Math.sqrt(b)*bubleRad);
      if(R<1){ R=1; print(',');}//Musi być choc slad
      
      stroke(SINT,0,0,VDENSITY);//Trzeci chromosom - marker
      fill(SINT,XINT,YINT,VDENSITY);//"ciało"
      ellipse(x,y,R,R);
      if(popul.currincome>popul.currloss)
        stroke(255,255,0);
      else
        stroke(255,0,0);
      point(x,y);//"serce" 
    }
    else
    {
      float ofs=popul.species.sizelog;
      float x=startX+size*((float)popul.species.suscepBits/MASK)+ofs;
      float y=startY+size*((float)popul.species.activeBits/MASK)+ofs;
      stroke(0,0,0);
      point(x,y); //print(".");
      noStroke();
    }
  }
}

void drawTransfers(anArea is)
{
  for(aPopLink lnk:is.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.lasttransfer/maxTransfer));  
      if(intensity>VDENSITY/DENSITYDIV //)
      && intensity/DENSITYDIV>0)//Jak za dużo jest 
      {
        float of1=lnk.source.species.sizelog;
        float x1=startX+(float)(size*float(lnk.source.species.suscepBits)/MASK+of1);
        float y1=startY+(float)(size*float(lnk.source.species.activeBits)/MASK+of1);
        float of2=lnk.target.species.sizelog;
        float x2=startX+(float)(size*float(lnk.target.species.suscepBits)/MASK+of2);
        float y2=startY+(float)(size*float(lnk.target.species.activeBits)/MASK+of2);
        intensity/=DENSITYDIV;
        stroke(0,200,0,intensity);
        line(x1,y1,x2,y2);
        stroke(0,100,0,intensity);
        line(x2,y2,(x1+x2)/2,(y1+y2)/2);
      }
  }
}

int StepCounter=0;
void runSteps(int NofS)
{
  for(int sc=0;sc<NofS;sc++)//odlicza kroki symulacji
  {
    StepCounter++;
    if(MUTATIONRATE>0) createnewspecies(island);
    timeStep(island); //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
  }
}

int swithbit(int sou,int pos)//flip-flopuje bit na pozycji
{
  if(pos>=MASKBITS)
  {
    println(" Mutation autside BITMASK");
    return sou;
  }
  //Jest poprawny
  int bit=0x1<<pos;
  if(console>3) print(":"+bit+" ");
  return sou^bit;//xor should do the job?
}

void createnewspecies(anArea self)
{ //println("Who of us is able to mutate?");
  for(int i=1;i<self.populations.size();i++)//Musi być taka pętla bo mutacje modyfikują tablice populacji
  {
    aPopulation popul=self.populations.get(i);//Kolejna
    
    if(popul.biomas<=MINSTART //Zbyt małe populacje nie mutują
    || popul.species.suscepBits==0 
    || popul.species.activeBits==0)
    continue; //jeśli gdzieś jest 0 to nie jest prawdziwa populacja - nie może mutować
    //print("Mutation of...");
    
    if(VIRTENVSIZE>1)
    {
    }
    else //w przeciwnym wypadku ignorujemy wielkośc populacji
    {
      if(random(1.0)>MUTATIONRATE)
      {
        //println("Skipedd");
           continue;
      }
    }
    
    
    aSpecies newSpec=new aSpecies(popul.species);
    //JAK OKREŚLAMY GDZIE JEST MUTACJA?
    int bitpos=(allowSizeSyn?int(random(3*MASKBITS)):int(random(2*MASKBITS)));
    if(bitpos<MASKBITS) // int suscepBits;
    {
      newSpec.suscepBits=swithbit(newSpec.suscepBits,bitpos);
      if(newSpec.suscepBits==0) return; //KONSTRUKT ZABRONIONY
    }
    else
    if(bitpos<MASKBITS*2)// int activeBits;
    {
      newSpec.activeBits=swithbit(newSpec.activeBits,bitpos-MASKBITS);
      if(newSpec.activeBits==0) return; //KONSTRUKT ZABRONIONY
    }
    else
    if(bitpos<MASKBITS*3)// int maxsize;
    {
      newSpec.maxsize=swithbit(newSpec.maxsize,bitpos-MASKBITS*2);
      if(newSpec.maxsize==0) return; //KONSTRUKT ZABRONIONY
      newSpec.sizelog=log(1+newSpec.maxsize);
    }
    else
    {
      println(" WRONG MUTATION!");
      return;
    }
    
    //WSTAWIANIE NOWEJ POPULACJI
    String newKey=newSpec.Key();
    aSpecies test=speciesDictionary.get(newKey);//Czy już jest ten "gatunek"?
    if(test==null)
    {
      //popul.currloss+=MINSTART;//Czy to będzie efektywne? TODO NIE!!!
      popul.biomas-=MINSTART;
      speciesDictionary.put(newKey,newSpec);
      if(console>=0) println("+"+newKey+" "+newSpec.sizelog+' ');
      else 
      if(console>1) print("+");
      self.addPopulation(new aPopulation(newSpec,MINSTART),false);//już sprawdziliśmy że jest to nowy gatunek
    }
    else
    {
      int where=self.findPopulOf(test);
      if(where>=0) //JEST
      {
        aPopulation tmp=self.populations.get(where);
        if(tmp.biomas==0)
        {
          if(console>1) print("0");
        }
        else
          if(console>1) print("|");
        tmp.biomas+=MINSTART;//Dodajemy biomasy do istniejącej populacji (lub martwej)
        if(console>0) println(' '+newKey+" o!");
      }
      else
      {
        self.addPopulation(new aPopulation(test,MINSTART),false);//Dodajemy (ponownie) populacje do tego obszaru/wyspy
        println("->Recreaction of population!!!");
      }
    }
  }
}

void removeConnections(anArea self,aPopulation what)
//Funkcja usuwająca wszystkie powiązania danej populacji przed jej usunięciem z listy
{
  int ileBylo=self.trophNet.size();
  for(int i=0;i<self.trophNet.size();i++)
  {
    aPopLink lnk=self.trophNet.get(i);
    if(lnk.source==what
    || lnk.target==what)
    {
      if(console>0) println("Remove ",lnk.source.species.Key(),"->",lnk.target.species.Key() );
      self.trophNet.remove(lnk);
      i--;
    }
  }
  println(' ',self.trophNet.size()-ileBylo," links");
}

void makeConnections(anArea self,aPopulation what)
//Funkcja tworząca połączenia troficzne dla nowej populacji 
{
  strokeWeight(2); 
  int ileBylo=self.trophNet.size();
  if(console>1) print(what.species.Key()," Bio:",what.biomas,' ');
  aSpecies mySpec=what.species;
  
  int susceptibility=mySpec.suscepBits & MASK;//Dla pewności ;-)
  int activity=mySpec.activeBits & MASK;
  float ofs=what.species.sizelog;
  
  aSpecies othSpec;
  for(aPopulation popul: self.populations)
  if((othSpec=popul.species)!=mySpec)//Interakcje populacji samej ze sobą są bez sensu merytorycznego
  {
      int othsusceptibility=othSpec.suscepBits & MASK;//MASK dla pewności ;-)
      int othactivity=othSpec.activeBits & MASK;
      //Waga związku danej populacji do nowej (what)
      double Wd=(othsusceptibility & activity)/((double)(activity))*((othsusceptibility & activity)/((double)(othsusceptibility)));
      //Waga związku nowej populacji do danej
      double Wr=(susceptibility & othactivity)/((double)(othactivity))*((susceptibility & othactivity)/((double)(susceptibility)));
      if(Wd>LINKMINWEIGHT) 
      {
          //println("Add ",Wd,mySpec.Key(),"->",popul.species.Key() );
          self.trophNet.add(  new aPopLink(popul,what,Wd) );//związek danej populacji do nowej (what)
      }
      if(Wr>LINKMINWEIGHT) 
      {
          //println("Add ",Wr,mySpec.Key(),"<-",popul.species.Key() );
          self.trophNet.add(  new aPopLink(what,popul,Wr) );//związek nowej populacji do danej
      }
      //New mutant relations visualisation
      if(mutantConnVis
      && popul.biomas>0)
      {
        if(Wd>LINKMINWEIGHT || Wr>LINKMINWEIGHT)//Wstępny test
        {
          float x1=startX+(float)(size*float(susceptibility)/MASK+ofs);
          float y1=startY+(float)(size*float(activity)/MASK+ofs);
          float ofo=othSpec.sizelog;
          float x2=startX+(float)(size*float(othsusceptibility)/MASK+ofo);
          float y2=startY+(float)(size*float(othactivity)/MASK+ofo);
          //String mark=(Wd>Wr*10?">>":(Wr>Wd*10?"<<":"~~"));
          //println(x1,y1,x2,y2,Wd,mark,Wr);
          if(Wd*VDENSITY>VDENSITY/DENSITYDIV)//Sterowanie dokładnościa prezentacji linków
          {
            stroke(255,0,0,(float)(Wd*VDENSITY));
            line(x1,y1,x2,y2);
            stroke(255,255,0,(float)(Wd*VDENSITY));
            line(x2,y2,(x2+x1)/2,(y2+y1)/2);
          }
          if(Wr*VDENSITY>VDENSITY/DENSITYDIV)
          {
            stroke(255,0,0,(float)(Wr*VDENSITY));
            line(x2,y2,x1,y1);
            stroke(255,255,0,(float)(Wr*VDENSITY));
            line(x1,y1,(x2+x1)/2,(y2+y1)/2);
          }
        }
      }
  }
  strokeWeight(1);
  println('+',self.trophNet.size()-ileBylo," links");
}

/*
class aPopLink
{
  aPopulation source;//Kto jest eksploatowany
  aPopulation target;//Kto jest ekspluatującym
  double      weight;//Siła związku eksploatacji
  aPopLink(aPopulation so,aPopulation ta,double w)
  {
    source=so;target=ta;weight=w;
  }
}
*/

double maxTransfer=0;
void timeStep(anArea self) //Upływ czasu dla obszaru z populacjami
{  
  for(aPopulation popul: self.populations)
  { //Zerowanie "buforów interakcji"
    popul.currincome=0;
    popul.currloss=0;
  }
  
  maxTransfer=0;
  for(aPopLink lnk:self.trophNet)//Obliczenie wszystkich interakcji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  { //TIMEQUANT!
    double transfer=lnk.weight*lnk.source.biomas*TIMEQUANT;
    if(VIRTENVSIZE>1) //Jeśli istotny jest współczynnik kontaktu populacji ze sobą
      transfer*=lnk.source.biomas/VIRTENVSIZE*lnk.target.biomas/VIRTENVSIZE;
    if(transfer>maxTransfer) 
            maxTransfer=transfer;
    //println("Tr:",transfer,' ');
    lnk.lasttransfer=transfer;
    lnk.target.currincome+=transfer;
    lnk.source.currloss+=transfer;
  }
  
  //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
  //Najprostrza wersja - jedno źródło podstawowe
  self.populations.get(0).currincome=random(FEEDPORTION)*TIMEQUANT;//Samo się doda za chwilę
  if(console>1) print(self.populations.get(0).currloss,self.populations.get(0).currincome);//Jak z wykożystaniem pokarmu
  if(self.populations.get(0).biomas<=0)
  {
    self.populations.get(0).biomas=1;//Zrodlo zewnetrzne jest niesmiertelne!
    if(console>0) print(" !!! ");
  }
  
  //Podsumowanie interakcji 
  for(aPopulation popul: self.populations)
  if(popul.biomas>0)//jeszcze jest to istotna populacja
  { //TIMEQUANT!
    popul.biomas+=popul.currincome;
    popul.biomas-=popul.currloss;
  }
  
  if(console>3) 
     print("Source biomas A:",self.populations.get(0).biomas);
  
  //...i upływu czasu
  self.alivePopulations=0;
  for(aPopulation popul: self.populations)
  if(popul.biomas>0)//nadal jeszcze jest istotny
  {
    popul.biomas=popul.biomas*TIMEDUMP;
    if(popul.biomas<1) 
        popul.biomas=0;
    else
        self.alivePopulations++;
        
    if(VIRTENVSIZE>1
    && popul.biomas>VIRTENVSIZE)
      popul.biomas=VIRTENVSIZE;
  }
  
  if(CLEAN)//Mniejsza lub równa zero!?
  for(int i=1;i<self.populations.size();i++)
  {
    if(self.populations.get(i).biomas<=0
    && self.delPopulation(i) )
    {
      if(console>=0)print('-'); 
        i--;
    }
  }
  
  if(console>2) 
    println(" Source biomas B:",self.populations.get(0).biomas);
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////