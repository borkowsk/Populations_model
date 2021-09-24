
void checkCommnadLine()
{
    //Is passing parameters possible?
    if(args==null)
            return; //NIE!
    println("args length is " + args.length);
    FIDBITS=new int[args.length];
    int count=0;
    for(int a=0;a<args.length;a++)
    {
      print(args[a]);
      int pom=unhex(args[a]);
      if(pom!=0)
      {
        FIDBITS[count]=pom & MASK;
        println("-->"+hex(FIDBITS[count]));
        count++;
      }
    }
    LASTSOURCE=count-1;
    FEEDPORTION=100000*TIMEQUANT*(LASTSOURCE+1);//Aktualizacja
}