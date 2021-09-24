// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// parametry modelu są w osobnym pliku żeby je było łatwo znaleźć
// a także dlatego że są tu procedury pomocnicze dla ich zapisu oraz tworzenia skrótowej nazwy modelu 
//////////////////////////////////////////////////////////////////////////////////////////////////////////
import java.net.InetAddress;
import java.net.UnknownHostException;

int MASK=0xfff;//0xfff//0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
int MASKBITS=-1;//12//8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
boolean allowSizeSyn=false;//Czy dopuszczamy mutowanie bitów "rozmiaru" czyli synonimiczne ekologicznie gatunki (czerwona składowa)
boolean QUADRATICINTERACTIONS=true; //czy w małej chwili czasu wzrost biomasy targetowej populacji jest zależny wypełnienia przez nia przestrzeni?
double  VIRTENVSIZE=0;//1024*1024?; //Ile "biomasy" jednego gatunku(?) miesci się maksymalnie w środowisku
float  TIMEQUANT=1; //Rozdzielczość czasowa - Ile czasu modelu upływa w każdym kroku

/*PARAM*/   
IntList FIDBITS=new IntList(); //*MAX_INT & MASK*/ Jakie bity mają ustawione niesmiertelne źródła pokarmu ("kominy hydrotermalne")
         int    LASTSOURCE=-1;//Ile żródeł pokarmu?
float   TIMEDUMP=0; //Koszty metaboliczne - Ile zasobów zostaje na skutek zużycia czasowego w każdym kwancie czasu
float   FEEDPORTION=0; //Ile biomasy zródeł maksymalnie przypływa na jednostkę czasu (jest randomizowane) 
float CATACLISMRATE=0;//Jak często następuje losowa katastrofa populacji - może być zalezna odwrotnie proporcjonalnie od rozmiaru  
float MUTATIONRATE=0;//Jak czesto na krok powstaje mutant w populacji - może być zalezna proporcjonalnie od rozmiaru

float LINKMINWEIGHT=-0.1;//Jakie najsłabsze linki uznajemy za istniejące przy łączeniu populacji
float MINSTART=-1; //Startowy zasób "biomasy" populacji mutanta. Pierwsza populacja pewnie musi być większa bo zdechnie
boolean FORCEMINSTART=false;//Czy zbyt małe populacje mogą mutować czy po prostu zmieniają się całe

//Czysto techniczne - prosta optymalizacja rozmiaru sieci
final boolean CLEAN=true;    //Czy czyścić sieć z martwych populacji? 
static String name;
  
String nameOfModel()
{
  if(name==null)
  {
     name="*UNDEFINED*";
  }
  return name;
}

String descriptionOfModel(char fsep,char bsep,char lsep)
{
  String description="BMLVN"+fsep+MASKBITS+fsep+(allowSizeSyn?"x3":"x2")+lsep;
  description+="metabolism"+fsep+nf(TIMEDUMP,0,7)+bsep+"mutations"+fsep+nf(MUTATIONRATE/TIMEQUANT,0,7)+bsep+"catastrofic"+fsep+nf(CATACLISMRATE/TIMEQUANT,0,7)+lsep;
  description+="minWeight"+fsep+LINKMINWEIGHT+bsep+"start biomas"+fsep+MINSTART+fsep+(FORCEMINSTART?"t":"_")+lsep;
  description+="env.size"+fsep+VIRTENVSIZE+bsep+(QUADRATICINTERACTIONS?"":"nQ-")+"feedSourceH";
  for(int fb=0;fb<=LASTSOURCE;fb++)
     description+=fsep+hex(FIDBITS.get(fb),(MASKBITS+3)/4);
  description+=lsep+"feed port max"+fsep+(FEEDPORTION/TIMEQUANT)+lsep;
  description+="timeQuant"+fsep+TIMEQUANT+lsep;
  return description;
}

/*Time & Date
day()
hour()
millis()
minute()
month()
second()
year()
*/