void folderSelected(File selection) 
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
}
/*
  "BMLVN"+fsep+MASKBITS+fsep+(allowSizeSyn?"x3":"x2")+lsep;
  "metabolism"+fsep+nf(TIMEDUMP,0,7)+bsep+
  "mutations"+fsep+nf(MUTATIONRATE/TIMEQUANT,0,7)+bsep+
  "catastrofic"+fsep+nf(CATACLISMRATE/TIMEQUANT,0,7)+lsep;
  "minWeight"+fsep+LINKMINWEIGHT+bsep+
  "start biomas"+fsep+MINSTART+fsep+(FORCEMINSTART?"t":"_")+lsep;
  "env.size"+fsep+VIRTENVSIZE+bsep+(QUADRATICINTERACTIONS?"":"nQ-")+
  "feedSourceH"+fsep;
  for(int fb=0;fb<=LASTSOURCE;fb++)
     description+=hex(FIDBITS[fb],(MASKBITS+3)/4)+bsep;
  "feed port max"+fsep+(FEEDPORTION/TIMEQUANT)+lsep;
  "timeQuant"+fsep+TIMEQUANT+lsep;
*/
void tryToSetVariable(String[] pieces)
{
  println(pieces[0]);//pieces[1]);//,pieces[2]);
  if(pieces[0].equals("BMLVN"))
  {
    MASKBITS=int(pieces[1]);
    if(pieces[2].equals("x2"))
      {
        //....
      }
    MASK=0; int JEDEN=1;
    for(int i=0;i<MASKBITS;i++)
    {
      MASK|=JEDEN;//print(hex(JEDEN)," ");
      JEDEN<<=1;
    }
    println("MASK",hex(MASK));
  }
  else if(pieces[0].equals("metabolism"))
  {
    TIMEDUMP=float(pieces[1]);
  }
  else if(pieces[0].equals("mutations"))
  {
    MUTATIONRATE=float(pieces[1])*TIMEQUANT;
  }
  else if(pieces[0].equals("catastrofic"))
  {
    CATACLISMRATE=float(pieces[1])*TIMEQUANT;
  }
  else if(pieces[0].equals("minWeight"))
  {
    LINKMINWEIGHT=float(pieces[1]);
  }
  else if(pieces[0].equals("start biomas"))
  {
    MINSTART=float(pieces[1]);
    if(pieces[2].equals("t"))
        FORCEMINSTART=true;
  }
  else if(pieces[0].equals("env.size"))
  {
    VIRTENVSIZE=float(pieces[1]);
  }
  else if(pieces[0].equals("feed port max"))
  {
    println(pieces[1]);//,pieces[2]);//,pieces[2]);
    FEEDPORTION=float(pieces[1])*TIMEQUANT;
  }
  else if(pieces[0].equals("timeQuant"))
  {
    TIMEQUANT=float(pieces[1]);
    if(TIMEQUANT>0)
    {
     //FEEDPORTION*=TIMEQUANT;
     CATACLISMRATE*=TIMEQUANT;
     MUTATIONRATE*=TIMEQUANT;
    }
  }
  else if(pieces[0].equals("feedSourceH"))
  {
    int pom=unhex(pieces[1]);
    if(pom>0)
    {
      LASTSOURCE=0;
      FIDBITS.append(pom);
    }
  }
  else if(pieces[0].length()>0) //Albo HEXy albo smiecie 
  {
    int pom=unhex(pieces[0]);
    if(pom>0)
    {
      ++LASTSOURCE;
      FIDBITS.append(pom);
    }
  }
  
}

int readModel(anArea self,String Filename)
// inicjalizacja modelu z pliku
{
  String line;
  int lcounter=0;
  int popCounter=0;
  boolean beforeKey=true;
  BufferedReader reader=createReader(Filename); 
  println(Filename+" :  ");//+reader.ready() );
  
  do{
  try 
  {
    line = reader.readLine();
  } 
  catch (IOException e) 
  {
    println(e.getMessage());
    //e.printStackTrace();
    line = null;
  }
  
  if (line == null) 
  {
    // Stop reading because of an error or file is empty
    try{
    //reader.close();//???? IDE Exception!?!?
    } 
    finally
    {
    self.alivePopulations=popCounter;
    write(self,"test.out");
    println(popCounter,"populations red");
    }
    return lcounter;
  } 
  else 
  {
    lcounter++;
    String[] pieces = split(line, TAB);

    if(beforeKey)
    {
      if(pieces[0].length()>=3 
      && pieces[0].charAt(0)=='k' 
      && pieces[0].charAt(1)=='e' 
      && pieces[0].charAt(2)=='y')//Moze być jeszcze $ na koncu ale nie musi!
      {
        beforeKey=false;
        continue;
      }
      
      tryToSetVariable(pieces);
    }
    else
    {
       for(String pic: pieces) print(pic+'\t');
       println(pieces.length);
       if(pieces.length>=7)
       {
         int suscepBits=int(pieces[1]);
         int activeBits=int(pieces[2]);  
         int maxsize=int(pieces[3]);    
         aSpecies Curr = new aSpecies( suscepBits, activeBits ,maxsize);
         float Biomas=float(pieces[4]);
         aPopulation CPop = new aPopulation(Curr,Biomas);
         CPop.currincome = float(pieces[5]);
         CPop.currloss = float(pieces[6]);
         self.addPopulation(CPop,false);
         popCounter++;
       }
       else println(" Invalid line #"+lcounter);
    }
  }
  }while(true);
  //return -lcounter;
}

void write(anArea self,String Filename)
//Zapis populacji do pliku
{
  PrintWriter  output = createWriter(Filename+".txt"); // Create a new file in the sketch directory
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


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////