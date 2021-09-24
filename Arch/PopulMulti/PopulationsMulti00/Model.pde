// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// Definicje klas modelu
//////////////////////////////////////////////////////////////////////////////////////////////////
import java.util.Map;

//Słownik gatunków jest globalny - ponad obszarami (anArea), których może być różna liczba
HashMap<String,aSpecies> speciesDictionary=new HashMap<String,aSpecies>();

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
     _key=hex(suscepBits,form)+":"+hex(activeBits,form);
     if(allowSizeSyn)
         _key+=":"+hex(maxsize,form);
     }
     return _key;
   }
}

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
  int LastSource=-1;
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
  void importPopulation(aSpecies what,float biomas)
  {
    int iwhat=findPopulOf(what);//Znajduje populację danego gatunku
    if(iwhat>=0)
    {
        aPopulation pwhat=populations.get(iwhat);
        pwhat.biomas+=biomas;
    }
    else //Jeszcze nie ma
    {
        aPopulation pwhat=new aPopulation(what,biomas);
        populations.add(pwhat);//Dodajemy nową.
        makeConnections(this,pwhat);//Funkcja tworząca połączenia troficzne dla nowej populacji 
    } 
  }
  //"Friends"
  //void makeConnections(anArea self,aPopulation what);
  //void removeConnections(anArea self,aPopulation what);
  //void createnewspecies(anArea self);//Powstawanie populacji przez mutację któregoś z bitów
  //void timeStep(anArea self) //Upływ czasy dla obszaru z populacjami
  //void write(anArea self,String Filename);//Zapis populacji do pliku
}





///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////