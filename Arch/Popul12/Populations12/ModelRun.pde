// Tu mogą być różne rzeczy w zalezności od potrzeb
//////////////////////////////////////////////////////////////////////////////////////////
double StepCounter=0;
void runSteps(int NofS)
{
  for(int sc=0;sc<NofS;sc++)//odlicza kroki symulacji
  {
    StepCounter+=TIMEQUANT;
    if(CATACLISMRATE>0) trytokillspecies(island);  
    if(MUTATIONRATE>0) createnewspecies(island);
    timeStep(island); //Karmienie zewnętrznym zasobem o parametrach ustalonych (ważne parametry modelu) 
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////