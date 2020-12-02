// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// parametry modelu są w osobnym pliku żeby je było łatwo znaleźć
// a także dlatego że są tu procedury pomocnicze dla ich zapisu oraz tworzenia skrótowej nazwy modelu 
//////////////////////////////////////////////////////////////////////////////////////////////////////////
import java.net.InetAddress;
import java.net.UnknownHostException;

int MASK=0xff;//0xfff//0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
int MASKBITS=8;//12//8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
boolean allowSizeSyn=false;//Czy dopuszczamy mutowanie bitów "rozmiaru" czyli synonimiczne ekologicznie gatunki (czerwona składowa)
boolean QUADRATICINTERACTIONS=true; //czy w małej chwili czasu wzrost biomasy targetowej populacji jest zależny wypełnienia przez nia przestrzeni?
double  VIRTENVSIZE=25000;//1024*1024?; //Ile "biomasy" jednego gatunku(?) miesci się maksymalnie w środowisku
float  TIMEQUANT=0.01; //Rozdzielczość czasowa - Ile czasu modelu upływa w każdym kroku
float  CHILDINTERVAL=10;//Czy dzieci wszystkie na raz czy co jakiś czas?

///*PARAM*/int[] FIDBITS={0xFF,0xc7,0xb5,0x23,0x11};//*MAX_INT & MASK*/ Jakie bity ma ustawione niesmiertelne źródło pokarmu ("komin hydrotermalny")
IntList FIDBITS=new IntList(0xFF,0xc7,0xb5,0x23,0x11); //*MAX_INT & MASK*/ Jakie bity mają ustawione niesmiertelne źródła pokarmu ("kominy hydrotermalne")
         int    LASTSOURCED=FIDBITS.size()-1;//Tylko jedno zródło o indeksie 0    
boolean LIMITFEEDS=true;
float   TIMEDUMP=0.997; //Koszty metaboliczne - Ile zasobów zostaje na skutek zużycia czasowego w każdym kwancie czasu
float   FEEDPORTION=15000*TIMEQUANT*(LASTSOURCED+1); //Ile biomasy zródeł maksymalnie przypływa na jednostkę czasu (jest randomizowane) 
float CATACLISMRATE=0.001*TIMEQUANT;//Jak często następuje losowa katastrofa populacji - może być zalezna odwrotnie proporcjonalnie od rozmiaru  
float MUTATIONRATE=0.001*TIMEQUANT;//Jak czesto na krok powstaje mutant w populacji - może być zalezna proporcjonalnie od rozmiaru

float LINKMINWEIGHT=0.1;//Jakie najsłabsze linki uznajemy za istniejące przy łączeniu populacji
float MINSTART=2; //Startowy zasób "biomasy" populacji mutanta. Pierwsza populacja pewnie musi być większa bo zdechnie
boolean FORCEMINSTART=false;//Czy zbyt małe populacje mogą mutować czy po prostu zmieniają się całe

//Czysto techniczne - prosta optymalizacja rozmiaru sieci
final boolean CLEAN=true;    //Czy czyścić sieć z martwych populacji? 
static String name;
  
String nameOfModel()
{
  if(name==null)
  {
    name="BMLVN"+MASKBITS+(allowSizeSyn?"x3":"x2")+"MULTI"+(CHILDINTERVAL!=0?"ch"+CHILDINTERVAL:"");
    name+="met"+nf(TIMEDUMP,0,7)+"mut"+nf(MUTATIONRATE/TIMEQUANT,0,7)+"cat"+nf(CATACLISMRATE/TIMEQUANT,0,7);
    name+="minW"+LINKMINWEIGHT+"S"+MINSTART+(FORCEMINSTART?"t":"_");
    name+="env"+VIRTENVSIZE;
    for(int fb=0;fb<=LASTSOURCED;fb++)
        name+="fH"+hex(FIDBITS.get(fb),(MASKBITS+3)/4);
    name+="x"+(FEEDPORTION/TIMEQUANT)+(LIMITFEEDS?"lim":"");
    name+="tq"+TIMEQUANT;
    name+="dt"+year()+'.'+nf(month(),2)+'.'+nf(day(),2)+'.'+nf(hour(),2)+'.'+nf(minute(),2)+'.'+nf(second(),2)+'.'+millis();
    //Nazwa hosta na koncu nazwy populacji
    //localHost hN=new localHost();
    //hN.run();
    //name+=+'.'+hN.canonicalHostName+"."+hN.hostName;
  }
  return name;
}

String descriptionOfModel(char fsep,char bsep,char lsep)
{
  String description="BMLVN"+fsep+MASKBITS+fsep+(allowSizeSyn?"x3":"x2")+fsep+"MULTI"+fsep+(CHILDINTERVAL!=0?"ch"+CHILDINTERVAL:"")+lsep;
  description+="metabolism"+fsep+nf(TIMEDUMP,0,7)+bsep+"mutations"+fsep+nf(MUTATIONRATE/TIMEQUANT,0,7)+bsep+"catastrofic"+fsep+nf(CATACLISMRATE/TIMEQUANT,0,7)+lsep;
  description+="minWeight"+fsep+LINKMINWEIGHT+bsep+"start biomas"+fsep+MINSTART+fsep+(FORCEMINSTART?"t":"_")+lsep;
  description+="env.size"+fsep+VIRTENVSIZE+bsep+(QUADRATICINTERACTIONS?"":"nQ-")+"feedSourceH"+fsep;
  for(int fb=0;fb<=LASTSOURCED;fb++)
     description+=hex(FIDBITS.get(fb),(MASKBITS+3)/4)+bsep;
  description+="feed port max"+fsep+(FEEDPORTION/TIMEQUANT)+fsep+(LIMITFEEDS?"limited":"")+lsep;
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