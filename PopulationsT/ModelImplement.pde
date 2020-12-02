PrintWriter output;//For writing statistics into disk drive

void write(anArea self,String Filename)
//Zapis populacji do pliku
{
  output = createWriter(Filename+".txt"); // Create a new file in the sketch directory
  String desc=descriptionOfModel('\t','\n','\n');
  output.println(desc);
  output.println("key\tsuscepBits\tactiveBits\tmaxsize\tpopBiomas\tcurrincome\tcurrloss");
  for(aPopulation popul:self.populations)
  {
    output.print(popul.species.Key()+"\t");
    output.print(popul.species.suscepBits+"\t");
    output.print(popul.species.activeBits+"\t");
    output.print(popul.species.maxsize+"\t");
    output.print(popul.biomas+"\t");
    output.print(popul.currincome+"\t");
    output.print(popul.currloss+"\t");
    output.println();
  }
  output.println();
  output.close();
}

void trytokillspecies(anArea self)
{
  for(aPopulation popul:self.populations)
  {
    if(VIRTENVSIZE>1)
    {
      if(random((float)(popul.biomas/VIRTENVSIZE)) > CATACLISMRATE )//Liczba osobników w populacji zmniejsza szanse wymarcia
      {
        //println("Skipedd");
           continue;
      }
    }
    else //w przeciwnym wypadku ignorujemy wielkośc populacji
    {
      if(random(1.0)>CATACLISMRATE)
      {
        //println("Skipedd");
           continue;
      }
    }
    //print(" CATASTR.: ",popul.biomas);
    popul.biomas*=1-random(1)*random(1)*random(1);//*random(1)*random(1)*random(1);//Zmniejsza się trochę lub bardziej, ale rozkład jest "pareto" - "bardziej" jest rzadkie
    //if(popul.biomas<1) println(" --> ",popul.biomas,"   !!!");  
}
}

void createnewspecies(anArea self)
{ //println("Who of us is able to mutate?");
  for(int i=1;i<self.populations.size();i++)//Musi być taka pętla bo mutacje modyfikują tablice populacji
  {
    aPopulation popul=self.populations.get(i);//Kolejna
    
    if((popul.biomas<=MINSTART && FORCEMINSTART) //Zbyt małe populacje nie mutują jeśli chcemy to zabezpieczyć
    || popul.species.suscepBits==0 
    || popul.species.activeBits==0)
    continue; //jeśli gdzieś jest 0 to nie jest prawdziwa populacja - nie może mutować
    //print("Mutation of...");
    

    if(random(1.0) > MUTATIONRATE * (popul.biomas/popul.species.maxsize))
    //Liczba osobników w populacji zwiększa szanse mutacji aż w pewnym momencie jest ona pewna
    {
        //println("Mutation skipedd");
         continue;
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
    //popul.currloss+=MINSTART;//Czy to będzie efektywne? TODO NIE!!!
    popul.biomas-=MINSTART; //KOSZT POTOMNEJ POPULACJI
      
    String newKey=newSpec.Key();
    aSpecies test=speciesDictionary.get(newKey);//Czy już jest ten "gatunek"?
    if(test==null)
    {
      speciesDictionary.put(newKey,newSpec);
      if(console>1) println("+"+newKey+" "+newSpec.sizelog+' ');
      else 
      if(console>=0) print("+");
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
        if(console>1) println("->Recreaction of population!!!");
        else
        if(console>=0) print('R');
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
  if(console>1) println(' ',self.trophNet.size()-ileBylo," links");
}

void makeConnections(anArea self,aPopulation what)
//Funkcja tworząca połączenia troficzne dla nowej populacji 
{
  strokeWeight(2); 
  int ileBylo=self.trophNet.size();
  if(console>1) print(what.species.Key()," Bio:",what.biomas,' ');
  aSpecies mySpec=what.species;
  
  int susceptibility=mySpec.suscepBits & MASK;//Dla pewności ;-)
  int activity=      mySpec.activeBits & MASK;
  float ofs=what.species.sizelog;
  
  aSpecies othSpec;
  for(aPopulation popul: self.populations)
  if((othSpec=popul.species)!=mySpec)//Interakcje populacji samej ze sobą są bez sensu merytorycznego
  {
      int othsusceptibility=othSpec.suscepBits & MASK;//MASK dla pewności ;-)
      int othactivity=      othSpec.activeBits & MASK;
      //Waga związku danej populacji do nowej (what)
      double Wd=((othsusceptibility & activity)/((double)activity))*((othsusceptibility & activity)/((double)othsusceptibility));
      //Waga związku nowej populacji do danej
      double Wr=((susceptibility & othactivity)/((double)othactivity))*((susceptibility & othactivity)/((double)susceptibility));
      if(Wd>LINKMINWEIGHT) //Jeśli wcześniej jest dzielenie przez 0 to link chyba nie powstanie?
      {
          //if(othsusceptibility == activity)
          //  println("!!!Add ",Wd,mySpec.Key(),"->",popul.species.Key(),binary(othsusceptibility,MASKBITS)," exp.by ",binary(activity,MASKBITS));
          self.trophNet.add(  new aPopLink(popul,what,Wd) );//związek danej populacji do nowej (what)
      }
      if(Wr>LINKMINWEIGHT) 
      {
          //if(susceptibility == othactivity)
          //  println("!!!Add ",Wr,mySpec.Key(),"<-",popul.species.Key() ,binary(susceptibility,MASKBITS)," exp.by ",binary(othactivity,MASKBITS) );
          self.trophNet.add(  new aPopLink(what,popul,Wr) );//związek nowej populacji do danej
      }
      //New mutant relations visualisation
      if(mutantConnVis
      && popul.biomas>0)
      {
        if(Wd>LINKMINWEIGHT || Wr>LINKMINWEIGHT)//Wstępny test do rysowania
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
  if(console>1) println('+',self.trophNet.size()-ileBylo," links");
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
    {
      transfer*=lnk.source.biomas/VIRTENVSIZE;
      if(QUADRATICINTERACTIONS)
      transfer*=lnk.target.biomas/VIRTENVSIZE;
    }
    if(transfer>maxTransfer) 
            maxTransfer=transfer;
    //println("Tr:",transfer,' ');
    lnk.lasttransfer=transfer;
    lnk.target.currincome+=transfer;
    lnk.source.currloss+=transfer;
  }
  
  //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
  for(int fb=0;fb<=LASTSOURCE;fb++) //Wiele zrodel
  {  
    self.populations.get(fb).currincome=random(FEEDPORTION);//Samo się doda za chwilę
    if(console>1) print(self.populations.get(fb).currincome);//Jak z wykożystaniem pokarmu
  }
  
  //Podsumowanie interakcji 
  for(aPopulation popul: self.populations)
  if(popul.biomas>0)//jeszcze jest to istotna populacja
  { //TIMEQUANT!
    popul.biomas+=popul.currincome;
    popul.biomas-=popul.currloss;
  }
  
  for(int fb=0;fb<=LASTSOURCE;fb++)  //Jeśli zródła zewnetrzne spadną poniżej zera nie giną tylko moga się odbudowac
  if(self.populations.get(fb).biomas<=0)
  {
    aPopulation popul=self.populations.get(fb);
    popul.biomas+=popul.currincome;
    if(console>=0) println("    "+popul.species.Key()+" !!! "+popul.biomas);
  }
  
  //...i upływu czasu
  self.alivePopulations=0;
  for(aPopulation popul: self.populations)
  if(popul.biomas>0)//nadal jeszcze jest istotny
  {
    popul.biomas=popul.biomas*TIMEDUMP;
    if(popul.biomas>=1) 
        self.alivePopulations++;
        else
        if(Math.abs(popul.biomas)<1)
              popul.biomas=0;       
      
    if(VIRTENVSIZE>1
    && popul.biomas>VIRTENVSIZE) //NIE ZA DUŻE!
      popul.biomas=VIRTENVSIZE;
  }
  
  if(CLEAN)//Mniejsza lub równa zero!?
  for(int i=LASTSOURCE+1;i<self.populations.size();i++)//POMIJAMY ŹRÓDŁA POKARMU!
  {
    if(self.populations.get(i).biomas<=0
    && self.delPopulation(i) )
    {
      if(console>=0) print('-'); 
        i--;
    }
  }
  
  if(console>2) 
    println(" Source biomas B:",self.populations.get(0).biomas);
  else
    print('/');
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////