PrintWriter outtxt;//For writing ecosystem state into disk drive

void write(anArea self,String Filename)
//Zapis populacji do pliku
{
  outtxt = createWriter(Filename+".txt"); // Create a new file in the sketch directory
  String desc=descriptionOfModel('\t','\n','\n');
  outtxt.println(desc);
  outtxt.println("key\tsuscepBits\tactiveBits\tmaxsize\tpopBiomas\tcurrincome\tcurrloss");
  for(aPopulation popul:self.populations)
  {
    outtxt.print(popul.species.Key()+"\t");
    outtxt.print(popul.species.suscepBits+"\t");
    outtxt.print(popul.species.activeBits+"\t");
    outtxt.print(popul.species.maxsize+"\t");
    outtxt.print(popul.biomas+"\t");
    outtxt.print(popul.currincome+"\t");
    outtxt.print(popul.currloss+"\t");
    outtxt.println();
  }
  outtxt.println();
  outtxt.close();
}

PrintWriter output;//Do zapisu statystyk z działania symulacji

void initStats()
{
  output=createWriter(modelName+".out");
  output.println("$STEP\tPopulationN\tConnectionN\tSpeciesSum\tmaxTransfer");
}

void doStatistics()
{              
   //Na razie nic nie liczymy tylko używamy statystyk policzonych gdzie indziej
   //"$STEP\tPopulationN\tConnectionN\tSpeciesSum"
   output.println(StepCounter+"\t"+island.alivePopulations+"\t"+island.trophNet.size()+"\t"+speciesDictionary.size()+"\t"+maxTransfer);
   //output powinno być zamknięte w Exit()
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////