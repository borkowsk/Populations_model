// Inicjalizacja modelu może się różnic w różnych sytuacjach mimo że model się nie zmienia
///////////////////////////////////////////////////////////////////////////////////////////

void initializeModel()
{
  //Simple feeding source. 
  /////////////////////////////////////////////////////////////
  //Zero oznacza że nie jest pełnoprawną częścią sieci
  aSpecies[] FID=new aSpecies[LASTSOURCE+1];
  for(int fb=0;fb<=LASTSOURCE;fb++)
    FID[fb]=new aSpecies( FIDBITS[fb], 0 ,1);
    
  for(int fb=0;fb<=LASTSOURCE;fb++)
  {
    aPopulation FP=new aPopulation(FID[fb],FEEDPORTION);
    println("Feed #",fb," is ",FID[fb].Key()," ofs:",FID[fb].sizelog);
    island.addPopulation(FP,false);
  }
  
  //Przodek czyli LUA. Nie może mieć żadnego zera
  //////////////////////////////////////////////////////
  aSpecies LUA=//new aSpecies( int(1+random(MAX_INT & MASK)) & MASK,int(1+random(MAX_INT & MASK)) & MASK,1);//random LUA
                new aSpecies( MASK, MASK ,1);//Full autotrophic LUA
  String luaKey=LUA.Key();
  println("LUA is ",luaKey," ofs:",LUA.sizelog);
  speciesDictionary.put(luaKey,LUA);
  island.addPopulation(new aPopulation(LUA,MINSTART*100),false);//Dużo żeby zawsze wystartował, potem jak jest więcej populacji to nie taki problem
  island.alivePopulations=2;
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////