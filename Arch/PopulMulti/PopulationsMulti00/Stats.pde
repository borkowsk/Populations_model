PrintWriter outstat;

void initStats()
{
  outstat=createWriter(modelName+".out");
  outstat.println("$STEP\tPopulationN\tConnectionN\tSpeciesSum\tmaxTransfer");
}

void doStatistics()
{              
   //Na razie nic nie liczymy tylko używamy statystyk policzonych gdzie indziej
   //"$STEP\tPopulationN\tConnectionN\tSpeciesSum"
   outstat.println(StepCounter+"\t"+islands[0].alivePopulations+"\t"+islands[0].trophNet.size()+"\t"+speciesDictionary.size()+"\t"+maxTransfer);
   //output powinno być zamknięte w Exit()
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////