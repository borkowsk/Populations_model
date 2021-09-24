  
import java.util.Map;
final int MASK=0xfff;//0xfff//0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
final int MASKBITS=12;//12//8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
final int FIDBITS=0xf00;//*MAX_INT & MASK*/
final float MUTATIONRATE=0.01;//Jak czesto na krok powstaje mutant - troche marne bo niezalezne od populacji
final float MINSTART=10; //Startowy zasób "biomasy" mutanta
final float FEEDPORTION=250; //Ile biomasy zródła maksyymalni eprzypływa na krok (jest random) 
final float TIMEQUANT=0.005; //Ile czasu modelu upływa w każdym kroku
final float TIMEDUMP=0.90; //Ile zasobów zostaje na skutek zużycia czasowego


//Parametry wizualizacji
final int   STEPperFRAME=50; //Ile kroków symulacji pomiędzy wizualizacjami
final int FRAMES=10;
final int startX=100;
final int startY=100;
final float size=800;
final float VDENSITY=20;//Maksymalna intensywność pojedynczej krawędzi
float     DENSITYDIV=2;//Ponizej jakiej intensywności rezygnujemy z wświetlania < VDENSITY/DENSITYDIV
float   bubleRad=10;
int     console=1;
boolean mutantConnVis=true;
boolean VISTRANSFERS=true;

class aSpecies //Informacja o gatunku
{
  int suscepBits;//susceptibility bits (maska "obrony")
  int activeBits;//activity bits (maska "ataku")
  int maxsize;
  aSpecies(int tB,int sB,int ms)
   { suscepBits=tB;activeBits=sB;maxsize=ms;}
  aSpecies(aSpecies p)
   { suscepBits=p.suscepBits;activeBits=p.activeBits;maxsize=p.maxsize;}
  aSpecies()
   {suscepBits=0;activeBits=0;maxsize=0;}
  String Key()
   {
     int form=(MASKBITS+3)/4;
     String out=hex(suscepBits,form)+":"+hex(activeBits,form)+":"+hex(maxsize,form);
     return out;
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
  //"Friends"
  //void makeConnections(anArea self,aPopulation what);
  //void createnewspecies(anArea self);//Powstawanie populacji przez mutację któregoś z bitów
  //void timeStep(anArea self) //Upływ czasy dla obszaru z populacjami
}

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy

void setup()
{
  noSmooth();
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
  island.addPopulation(FP,false);
  
  
  //Przodek czyli LUA. Nie może mieć żadnego zera
  //////////////////////////////////////////////////////
  aSpecies LUA=//new aSpecies( int(1+random(MAX_INT & MASK)) & MASK,int(1+random(MAX_INT & MASK)) & MASK,1);//random LUA
                new aSpecies( MASK, MASK ,1);//Full autotrophic LUA
  String luaKey=LUA.Key();
  println("LUA is ",luaKey);
  speciesDictionary.put(luaKey,LUA);
  island.addPopulation(new aPopulation(LUA,MINSTART),false);
  island.alivePopulations=2;
}

void keyPressed() 
{
  VISTRANSFERS=!VISTRANSFERS;
}

void draw()
{
  if(island.alivePopulations<2) return;//Model się skończył
   
  fill(128,25);//TŁO mocno półprzejrzyste
  rect(0,0,width,height-20);
  if(StepCounter==0)
      drawArea(island);
  runSteps(STEPperFRAME);
  drawArea(island);
  
  fill(255);
  rect(0,height-20,width,20);//STATUS LINE
  fill(255,0,0);
  text(StepCounter+":  "+speciesDictionary.size(),3,height-2);
  fill(0,255,0);
  text(island.alivePopulations,100,height-2);
  fill(0,0,128);
  text("FR:"+frameRate,800,height-2); 
}

void drawArea(anArea is)
{
  noStroke();
  for(aPopulation popul: is.populations)
 // if(popul.biomas>0)//jeszcze jest istotny
  {
    float x=popul.species.suscepBits;
    float y=popul.species.activeBits;
    double b=popul.biomas;
    //stroke(255*popul.species.maxsize/MASK,0,0,VDENSITY);//255*x/MASK,255*y/MASK,VDENSITY);
    x=(float)(startX+size*x/MASK);
    y=(float)(startY+size*y/MASK);
    if(b>0)
    {
      float R=(float)(1+Math.log(1.0+b)*bubleRad);
      if(R<1) R=1;//Musi być choc slad
      fill(255*popul.species.maxsize/MASK,255*x/MASK,255*y/MASK,VDENSITY);
      ellipse(x,y,R,R);
    }
    else
    {
      //print(".");
      stroke(0,0,0);
      point(x,y);
      noStroke();
    }
  }
}

int StepCounter=0;
void runSteps(int NofS)
{
  for(int sc=0;sc<NofS;sc++)//odlicza kroki symulacji
  {
    StepCounter++;
    timeStep(island); //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
    if(random(1.0)<MUTATIONRATE) createnewspecies(island);
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
{
  int what=int(random(self.populations.size()));
  if(console>4) print(" "+what);
  aPopulation popul=self.populations.get(what);
  //popul.biomas+=2;//Tymczasowe zabezpieczenie przed przedwczesną "śmiercią"
  
  if(popul.biomas==0
  || popul.species.suscepBits==0 
  || popul.species.activeBits==0)
  return; //jeśli gdzieś jest 0 to nie jest prawdziwa populacja - nie może mutować
  
  aSpecies newSpec=new aSpecies(popul.species);
  //JAK OKREŚLAMY GDZIE JEST MUTACJA?
  int bitpos=int(random(3*MASKBITS));
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
  }
  else
  {
    println(" WRONG MUTATION!");
    return;
  }
  
  //WSTAWIANIE NOWEJ POPULACJI
  String newKey=newSpec.Key();
  aSpecies test=speciesDictionary.get(newKey);//Czy już jest ten gatunek?
  if(test==null)
  {
    popul.biomas+=MINSTART;//popul.species.maxsize;//PREMIA ZA ROZMNOŻENIE - DEBUG
    speciesDictionary.put(newKey,newSpec);
    self.addPopulation(new aPopulation(newSpec,MINSTART),false);//już sprawdziliśmy że jest to nowy gatunek
    if(console>2) print(newKey+" ");
    else 
    if(console>1) print(".");
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
      println(" o!");
    }
    else
    {
      self.addPopulation(new aPopulation(newSpec,MINSTART),false);//Dodajemy (ponownie) populacje do tego obszaru/wyspy
      println("UPS... recreaction of population?");
    }
  }
}

/*
int suscepBits;//susceptibility bits (maska "obrony")
int activeBits;//activity bits (maska "ataku")
*/

void makeConnections(anArea self,aPopulation what)
//Funkcja tworząca połączenia troficzne dla nowej populacji 
{
  strokeWeight(2);
  aSpecies mySpec=what.species;
  
  int susceptibility=mySpec.suscepBits & MASK;//Dla pewności ;-)
  int activity=mySpec.activeBits & MASK;
  
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
      if(Wd>0) self.trophNet.add(  new aPopLink(popul,what,Wd) );//związek danej populacji do nowej (what)
      if(Wr>0) self.trophNet.add(  new aPopLink(what,popul,Wr) );//związek nowej populacji do danej
      //New mutant relations visualisation
      if(mutantConnVis
      && popul.biomas>0)
      {
        float x1=startX+(float)(size*float(susceptibility)/MASK);
        float y1=startY+(float)(size*float(activity)/MASK);
        float x2=startX+(float)(size*float(othsusceptibility)/MASK);
        float y2=startY+(float)(size*float(othactivity)/MASK);
        if(Wd!=0 || Wr!=0)//Wstępny test
        {
          //String mark=(Wd>Wr*10?">>":(Wr>Wd*10?"<<":"~~"));
          //println(x1,y1,x2,y2,Wd,mark,Wr);
          if(Wd*VDENSITY>VDENSITY/DENSITYDIV)//Sterowanie dokładnościa prezentacji linków
          {
            stroke(255,0,0,(float)(Wd*VDENSITY));
            line(x1+1,y1+1,x2,y2);
          }
          if(Wr*VDENSITY>VDENSITY/DENSITYDIV)
          {
            stroke(0,0,255,(float)(Wr*VDENSITY));
            line(x2+1,y2+1,x1,y1);
          }
        }
      }
  }
  strokeWeight(1);
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
    if(transfer>maxTransfer) 
            maxTransfer=transfer;
    lnk.lasttransfer=transfer;
    lnk.target.currincome+=transfer;
    lnk.source.currloss+=transfer;
  }
  
  if(VISTRANSFERS)
  for(aPopLink lnk:self.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.lasttransfer/maxTransfer));  
      if(intensity>VDENSITY/DENSITYDIV)
      {
        float x1=startX+(float)(size*float(lnk.source.species.suscepBits)/MASK);
        float y1=startY+(float)(size*float(lnk.source.species.activeBits)/MASK);
        float x2=startX+(float)(size*float(lnk.target.species.suscepBits)/MASK);
        float y2=startY+(float)(size*float(lnk.target.species.activeBits)/MASK);
        stroke(0,200,0,intensity);
        line(x1,y1,x2,y2);
        stroke(0,100,0,intensity);
        line(x2,y2,(x1+x2)/2,(y1+y2)/2);
      }
  }
  
  //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
  //Najprostrza wersja - jedno źródło podstawowe
  self.populations.get(0).currincome=random(FEEDPORTION);//Samo się doda za chwilę
  if(console>1) print(self.populations.get(0).currloss,self.populations.get(0).currincome);//Jak z wykożystaniem pokarmu
  if(self.populations.get(0).biomas<=0)
  {
    self.populations.get(0).biomas=1;
    print(" !!! ");
  }
  
  //Podsumowanie interakcji 
  for(aPopulation popul: self.populations)
  if(popul.biomas>0)//jeszcze jest to istotna populacja
  { //TIMEQUANT!
    popul.biomas+=popul.currincome;
    popul.biomas-=popul.currloss;
  }
  
  if(console>1) print(" ",self.populations.get(0).biomas);
  
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
  }
  
  if(console>0) println(" ",self.populations.get(0).biomas);
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////