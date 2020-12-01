
void checkCommnadLine()
{
    //Is passing parameters possible?
    if(args==null)
            return; //NIE!
    println("args length is " + args.length);
    for(int a=0;a<args.length;a++)
    {
      print(args[a]);
      //int pom=unhex(args[a]);
      //FIDBITS=pom & MASK;
      //println("-->"+hex(FIDBITS));
    }
}
