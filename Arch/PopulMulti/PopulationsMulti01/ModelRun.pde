// Tu mogą być różne rzeczy w zalezności od potrzeb
//////////////////////////////////////////////////////////////////////////////////////////
double StepCounter=0;
void runSteps(int NofS)
{
  for(int sc=0;sc<NofS;sc++)//odlicza kroki symulacji
  {
      maxTransfer=0;
      //Lokalna dymanika
      for(int j=0;j<NofISLAND;j++) //Odlicza kolejne wyspy
      if(islands[j]!=null)
      {
        if(CATACLISMRATE>0) trytokillspecies(islands[j]);  
        if(MUTATIONRATE>0) createnewspecies(islands[j]);
        timeStep(islands[j]); //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
      }
      
      //MIGRACJE
      for(int i=0;i<NofISLAND;i++) //Odlicza kolejne wyspy
      {
        int j,k;
        do {
          j=int(random(NofISLAND));//Z której wyspy?
        } while(islands[j]==null);
        
        aPopulation what=randImportant(islands[j]);
        if(what!=null
        && (k=int(random(NofISLAND)))!=j //Na którą wyspę?
        && islands[k]!=null 
        )
        {
          //println(what,"from",j,"to",k);
          islands[k].importPopulation(what.species,(float)(what.biomas*0.1));
          what.biomas*=0.9;
        }
      }
      StepCounter+=TIMEQUANT;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////