PrintWriter outstat;

void initStats()
{
  outstat=createWriter(modelName+".out");
  outstat.println("modelName\t"+modelName);
  outstat.println("modelName\t"+altModel);
  outstat.println("descriptionOfModel('\t','\t','\n')");
  outstat.print("$STEP\tSpeciesSum\tmaxTransfer\tPopulation0\tConnection0");
  for(int i=1;i<NofISLAND;i++)
    outstat.print("\tPopulation"+i+"\tConnection"+i);
  outstat.println();
}

void doStatistics()
{              
   //Na razie nic nie liczymy tylko używamy statystyk policzonych gdzie indziej
   //"$STEP\tPopulationN\tConnectionN\tSpeciesSum"
   outstat.print(StepCounter+"\t"+speciesDictionary.size()+"\t"+maxTransfer);
   for(int i=0;i<NofISLAND;i++)
    if(islands[i]!=null)
       outstat.print("\t"+islands[i].alivePopulations+"\t"+islands[i].trophNet.size());
    else
       outstat.print("\t \t ");
   outstat.println();
   //output powinno być zamknięte w Exit()
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
