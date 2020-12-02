// BMLVN - Binary Masks Lotka-Voltera Network (similar to GLVM - "generalized L-V moodels)
//////////////////////////////////////////////////////////////////////////////////////////////////
// parametry modelu są w osobnym pliku żeby je było łatwo znaleźć
// a także dlatego że są tu procedury pomocnicze dla ich zapisu oraz tworzenia skrótowej nazwy modelu 
//////////////////////////////////////////////////////////////////////////////////////////////////////////
import java.net.InetAddress;
import java.net.UnknownHostException;

final int MASK=0xfff;//0xfff//0xff;//0x3f//0xf;  //Maska znaczących bitów kazdej charakterystyki
final int MASKBITS=12;//12//8;//6//4; //Ile bitów kazdej charakterystyki jest znaczących
final boolean allowSizeSyn=false;//Czy dopuszczamy mutowanie bitów "rozmiaru" czyli synonimiczne ekologicznie gatunki (czerwona składowa)
final boolean QUADRATICINTERACTIONS=true; //czy w małej chwili czasu wzrost biomasy targetowej populacji jest zależny wypełnienia przez nia przestrzeni?
final double  VIRTENVSIZE=25000;//1024*1024?; //Ile "biomasy" jednego gatunku(?) miesci się maksymalnie w środowisku
final float  TIMEQUANT=0.01; //Rozdzielczość czasowa - Ile czasu modelu upływa w każdym kroku

/*PARAM*/int[] FIDBITS={0xFFF,0x0FF,0x0F,0x777,0x555};//*MAX_INT & MASK*/ Jakie bity ma ustawione niesmiertelne źródło pokarmu ("komin hydrotermalny")
         int    LASTSOURCE=FIDBITS.length-1;//Tylko jedno zródło o indeksie 0        
final float   TIMEDUMP=0.997; //Koszty metaboliczne - Ile zasobów zostaje na skutek zużycia czasowego w każdym kwancie czasu
      float   FEEDPORTION=10000*TIMEQUANT*(LASTSOURCE+1); //Ile biomasy zródeł maksymalnie przypływa na jednostkę czasu (jest randomizowane) 
final float CATACLISMRATE=0.001*TIMEQUANT;//Jak często następuje losowa katastrofa populacji - może być zalezna odwrotnie proporcjonalnie od rozmiaru  
final float MUTATIONRATE=0.001*TIMEQUANT;//Jak czesto na krok powstaje mutant w populacji - może być zalezna proporcjonalnie od rozmiaru

final float LINKMINWEIGHT=0.1;//Jakie najsłabsze linki uznajemy za istniejące przy łączeniu populacji
final float MINSTART=2; //Startowy zasób "biomasy" populacji mutanta. Pierwsza populacja pewnie musi być większa bo zdechnie
final boolean FORCEMINSTART=false;//Czy zbyt małe populacje mogą mutować czy po prostu zmieniają się całe

//Czysto techniczne - prosta optymalizacja rozmiaru sieci
final boolean CLEAN=true;    //Czy czyścić sieć z martwych populacji? 
static String name;
  
String nameOfModel()
{
  if(name==null)
  {
    name="BMLVN"+MASKBITS+(allowSizeSyn?"x3":"x2");
    name+="met"+nf(TIMEDUMP,0,7)+"mut"+nf(MUTATIONRATE/TIMEQUANT,0,7)+"cat"+nf(CATACLISMRATE/TIMEQUANT,0,7);
    name+="minW"+LINKMINWEIGHT+"S"+MINSTART+(FORCEMINSTART?"t":"_");
    name+="env"+VIRTENVSIZE;
    for(int fb=0;fb<=LASTSOURCE;fb++)
        name+="fH"+hex(FIDBITS[fb],(MASKBITS+3)/4);
    name+="x"+(FEEDPORTION/TIMEQUANT);
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
  String description="BMLVN"+fsep+MASKBITS+fsep+(allowSizeSyn?"x3":"x2")+lsep;
  description+="metabolism"+fsep+nf(TIMEDUMP,0,7)+bsep+"mutations"+fsep+nf(MUTATIONRATE/TIMEQUANT,0,7)+bsep+"catastrofic"+fsep+nf(CATACLISMRATE/TIMEQUANT,0,7)+lsep;
  description+="minWeight"+fsep+LINKMINWEIGHT+bsep+"start biomas"+fsep+MINSTART+fsep+(FORCEMINSTART?"t":"_")+lsep;
  description+="env.size"+fsep+VIRTENVSIZE+bsep+(QUADRATICINTERACTIONS?"":"nQ-")+"feedSourceH"+fsep;
  for(int fb=0;fb<=LASTSOURCE;fb++)
     description+=hex(FIDBITS[fb],(MASKBITS+3)/4)+bsep;
  description+="feed port max"+fsep+(FEEDPORTION/TIMEQUANT)+lsep;
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