  
import java.util.Map;
final int STEPperFRAME=100; //Ile kroków symulacji pomiędzy wizualizacjami
final int MASK=0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
final int MASKBITS=8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
final float MUTATIONRATE=1.0;
final float MINSTART=10;
final float TIMEDUMP=0.999;
final int console=0;

class aSpecies //Informacja o gatunku
{
  int targetBits;
  int sourceBits;
  int maxsize;
  aSpecies(int tB,int sB,int ms)
  { targetBits=tB;sourceBits=sB;maxsize=ms;}
  aSpecies(aSpecies p)
  { targetBits=p.targetBits;sourceBits=p.sourceBits;maxsize=p.maxsize;}
  aSpecies()
  {targetBits=0;sourceBits=0;maxsize=0;}
 String Key()
 {
   int form=(MASKBITS+3)/4;
   String out=hex(targetBits,form)+":"+hex(sourceBits,form)+":"+hex(maxsize,form);
   return out;
 }
}

HashMap<String,aSpecies> speciesDictionary=new HashMap<String,aSpecies>();

class aPopulation //Informacja o populacji jakiegoś gatunku
{
  float biomas;
  aSpecies species; 
  aPopulation(aSpecies sp,float bim)
  { species=sp; biomas=bim;}
  aPopulation()
  { biomas=0; }
}

class anArea //Obszar z wieloma populacjami
{
  ArrayList<aPopulation> populations;
  anArea()
  {
    populations=new ArrayList<aPopulation>(0);
  }
  int findPopulOf(aSpecies what)//Znajduje populację danego gatunku
  {https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
    for(int i=0;i<populations.size();i++)
     if(populations.get(i).species==what)//To samo
      return i;
   
    return -1;//Nie ma
  }
}

anArea island=new anArea(); //Pojemnik na zbiór populacji - na razie pojedynczy

void setup()
{
  size(1000,1000);
  background(128); //Clear the window
  noSmooth();
  noStroke();
  noFill();
  //Simple feeding source. NA RAZIE NIE UZYWANY
  //Zero oznacza że nie jest pełnoprawną częścią sieci
  /*
  aSpecies FID=new aSpecies( 0, MAX_INT & MASK,1);
  aPopulation FP=new aPopulation(FID,10000);
  island.populations.add(FP);
  */
  
  //Przodek czyli LUA. Nie może mieć żadnego zera
  aSpecies LUA=new aSpecies( int(1+random(MAX_INT & MASK)) & MASK,int(1+random(MAX_INT & MASK)) & MASK,1);
  String luaKey=LUA.Key();
  println("LUA is ",luaKey);
  speciesDictionary.put(luaKey,LUA);
  island.populations.add(new aPopulation(LUA,MINSTART));
}

void draw()
{
  fill(128,25);//TŁO mocno półprzejrzyste
  rect(0,0,width,height);
  drawArea(island,100,100,800);
  fill(255,0,0);
  text(speciesDictionary.size(),3,height-20);
  runSteps(STEPperFRAME);
}

void drawArea(anArea is,int startX,int startY,float size)
{
  for(aPopulation popul: is.populations)
  if(popul.biomas>0)//jeszcze jest istotny
  {
    int x=popul.species.targetBits;
    int y=popul.species.sourceBits;
    float b=popul.biomas;
    fill(0,255*x/MASK,255*y/MASK,10);
    stroke(255*popul.species.maxsize/MASK,0,0,10);//255*x/MASK,255*y/MASK,10);
    x=int(startX+size*x/MASK);
    y=int(startY+size*y/MASK);
    ellipse(x,y,1+log(1.0+b)*10,1+log(1.0+b)*10);
  }
}

void runSteps(int NofS)
{
  for(int sc=0;sc<NofS;sc++)//odlicza kroki symulacji
  {
    timeStep(island); //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
    if(random(1.0)<MUTATIONRATE) createnewspecies(island);
  }
}

void timeStep(anArea is)
//Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
{
  for(aPopulation popul: is.populations)
  if(popul.biomas>0)//jeszcze jest istotny
  {
    //popul.biomas++;//DEBUG
    popul.biomas=popul.biomas*TIMEDUMP;
    if(popul.biomas<1) popul.biomas=0;
  }
}

int swithbit(int sou,int pos)//flip flopuje bit na pozycji
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

void createnewspecies(anArea is)
{
  int what=int(random(is.populations.size()));
  if(console>4) print(" "+what);
  aPopulation popul=is.populations.get(what);
  popul.biomas+=2;//Tymczasowe zabezpieczenie przed przedwczesną "śmiercią"
  
  if(popul.biomas==0
  || popul.species.targetBits==0 
  || popul.species.sourceBits==0)
  return; //jeśli gdzieś jest 0 to nie jest prawdziwa populacja - nie może mutować
  
  aSpecies newSpec=new aSpecies(popul.species);
  //JAK OKREŚLAMY GDZIE JEST MUTACJA?
  int bitpos=int(random(3*MASKBITS));
  if(bitpos<MASKBITS) // int targetBits;
  {
    newSpec.targetBits=swithbit(newSpec.targetBits,bitpos);
    if(newSpec.targetBits==0) return; //KONSTRUKT ZABRONIONY
  }
  else
  if(bitpos<MASKBITS*2)// int sourceBits;
  {
    newSpec.sourceBits=swithbit(newSpec.sourceBits,bitpos-MASKBITS);
    if(newSpec.sourceBits==0) return; //KONSTRUKT ZABRONIONY
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
    popul.biomas+=8;//popul.species.maxsize;//PREMIA ZA ROZMNOŻENIE - DEBUG
    speciesDictionary.put(newKey,newSpec);
    is.populations.add(new aPopulation(newSpec,MINSTART));
    if(console>2) print(newKey+" ");
    else 
    if(console>1) print(".");
  }
  else
  {
    int where=is.findPopulOf(test);
    if(where>=0) //JEST
    {
      aPopulation tmp=is.populations.get(where);
      if(tmp.biomas==0)
      {
        if(console>1) print("0");
      }
      else
        if(console>1) print("|");
      tmp.biomas+=MINSTART;//Dodajemy biomasy do istniejącej populacji (lub martwej)
    }
    else
    {
      is.populations.add(new aPopulation(newSpec,MINSTART));//Dodajemy (ponownie) populacje do tego obszaru/wyspy
      println("UPS... recreaction of population?");
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
