//IMPLEMENTACJA WIZUALIZACJI  I ROBIENIA FILMU
/////////////////////////////////////////////////////////////////////
void drawAreaCO(anArea is,int startX,int startY,int size)
{
  if(Clicked)//Żądanie zmiany wybranego
  {
     minDist2Selec=MAX_INT;
     maxTransSelec=-MAX_INT;
     println("  Looking for ",searchedX,searchedY);
     Clicked=false;
  }
  noStroke();
  for(aPopulation popul: is.populations)
  {
    double b=popul.biomas;

    if(b>0.0)
    {
      float fSusc=popul.species.suscepBits;
      float fActi=popul.species.activeBits;
      float ofs=popul.species.sizelog;
      
      float x=(float)(startX+size*fSusc/MASK+ofs);
      float y=(float)(startY+size*fActi/MASK+ofs); 
      float SINT=255.0*((float)popul.species.maxsize/MASK);
      float XINT=255.0*(fSusc/MASK);
      float YINT=255.0*(fActi/MASK);
      
      float R;
      //R=(float)(1+Math.log(1.0+b)*bubleRad);
      if(ORBVISUAL)
        R=(float)(Math.pow(b,0.33333333333)*bubleRad);
      else
        R=(float)(Math.sqrt(b)*bubleRad);
      if(R<1){ R=1; print(',');}//Musi być choc slad
      
      stroke(SINT,0,0,VDENSITY);//Trzeci chromosom - marker
      fill(SINT,XINT,YINT,VDENSITY);//"ciało"
      ellipse(x,y,R,R);
      
      if(ORBVISUAL && R>5)
      {
        noStroke();
        fill(255,VDENSITY/3);
        ellipse(x,y-R/2+R/8,R/4,R/8);
      }
      
      if(popul.currincome>popul.currloss)
        stroke(255,255,0);
      else
        stroke(255,0,0);
      point(x,y);//"serce" 
      
      
      if(searchedX>0 && searchedY>0)
      {
        double dist2=Math.sqrt(sqr(x-searchedX)+sqr(y-searchedY));//Szukanie print(dist2,", ");
        if(dist2 < minDist2Selec)
        {
          minDist2Selec=dist2;        //print(" ? ");
          theSelected=popul;
        }
      }
      else //Jak już znalezione poprzednio
      if(popul==theSelected)
      {
        noFill(); stroke(255);
        ellipse(x,y,R+1,R+1);
        fill(128); noStroke();
        rect(0,0,400,25);
        fill(255);
        text(popul.species.Key()+" Bio: "+popul.biomas+" "+binary(popul.species.suscepBits,MASKBITS)+":"+binary(popul.species.activeBits,MASKBITS),1,20);
      }
    }
    else
    {
      float ofs=popul.species.sizelog;
      float x=startX+size*((float)popul.species.suscepBits/MASK)+ofs;
      float y=startY+size*((float)popul.species.activeBits/MASK)+ofs;
      stroke(0,0,0);
      point(x,y); //print(".");
      noStroke();
    }
  }
  
  //NIE SZUKA DO NASTĘPNEGO KLIKNIECIA
  searchedX=-1;
  searchedY=-1;
}

void drawTransfersCO(anArea is,int startX,int startY,int size)
{
  for(aPopLink lnk:is.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.lasttransfer/maxTransfer));  
      if(lnk.target==theSelected
      || intensity>VDENSITY/DENSITYDIV )
      //&& intensity/DENSITYDIV>0)//Jak za dużo jest 
      {
        float of1=lnk.source.species.sizelog;
        float x1=startX+(float)(size*float(lnk.source.species.suscepBits)/MASK+of1);
        float y1=startY+(float)(size*float(lnk.source.species.activeBits)/MASK+of1);
        float of2=lnk.target.species.sizelog;
        float x2=startX+(float)(size*float(lnk.target.species.suscepBits)/MASK+of2);
        float y2=startY+(float)(size*float(lnk.target.species.activeBits)/MASK+of2);
        if(lnk.target==theSelected)//Trzeba (?) niestety powtórzyć sprawdzanie warunku
        {
          if(maxTransSelec<lnk.lasttransfer)
             maxTransSelec=lnk.lasttransfer;//Na początku może być trochę kiepsko ale się naprawi w kolejnych wizualizacjach
          int inten=(int)(255*(lnk.lasttransfer/maxTransSelec));
          stroke(255,inten);
          line(x1,y1,x2,y2);
          println("   ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
        }
        if(lnk.lasttransfer>=maxTransfer)
        {
          intensity=255;
          stroke(intensity,intensity,0);
          println(" M ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
        }
        else
        {
          //intensity/=DENSITYDIV;//Czy to konieczne?
          stroke(0,200,0,intensity);
        }
        line(x1,y1,x2,y2);
        stroke(0,100,0,intensity);
        line(x2,y2,(x1+x2)/2,(y1+y2)/2);
      }
  }
}

void drawAreaBW(anArea is,int startX,int startY,int size)
{
  if(Clicked)//Żądanie zmiany wybranego
  {
     minDist2Selec=MAX_INT;
     maxTransSelec=-MAX_INT;
     println("  Looking for ",searchedX,searchedY);
     Clicked=false;
  }
  
  noStroke();
  for(aPopulation popul: is.populations)
  {
    double b=popul.biomas;

    if(b>0.0)
    {
      float fSusc=popul.species.suscepBits;
      float fActi=popul.species.activeBits;
      float ofs=popul.species.sizelog;
      
      float x=(float)(startX+size*fSusc/MASK+ofs);
      float y=(float)(startY+size*fActi/MASK+ofs); 
      float SINT=255.0*((float)popul.species.maxsize/MASK);
     // float XINT=255.0*(fSusc/MASK);
     // float YINT=255.0*(fActi/MASK);
      float SPEC=popul.species.countBits/float(MASKBITS*2);
      //print(SPEC,",");//Poziom omnipotencji genetycznej - im mniej tym mniej bitów czyli większa specjalizacja
      SPEC*=255;
      
      float R;
      //R=(float)(1+Math.log(1.0+b)*bubleRad);
      if(ORBVISUAL)
        R=(float)(Math.pow(b,0.33333333333)*bubleRad);
      else
        R=(float)(Math.sqrt(b)*bubleRad);
        
      if(R<1){ R=1; print(',');}//Musi być choc slad
      
      stroke(SINT,0,0,VDENSITY);//Trzeci chromosom - marker
      fill(SPEC,VDENSITY);//"ciało"
      ellipse(x,y,R,R);
      
      if(ORBVISUAL && R>5)
      {
        noStroke();
        fill(255,VDENSITY/3);
        ellipse(x,y-R/2+R/8,R/4,R/8);
      }
      
      if(popul.currincome>popul.currloss)
        stroke(0);
      else
        stroke(255);
      point(x,y);//"serce" 
      
      
      if(searchedX>0 && searchedY>0)
      {
        double dist2=Math.sqrt(sqr(x-searchedX)+sqr(y-searchedY));//Szukanie print(dist2,", ");
        if(dist2 < minDist2Selec)
        {
          minDist2Selec=dist2;        //print(" ? ");
          theSelected=popul;
        }
      }
      else //Jak już znalezione poprzednio
      if(popul==theSelected)
      {
        noFill(); stroke(255);strokeWeight(3);
        ellipse(x,y,R+1,R+1);
        strokeWeight(1);fill(200); noStroke();
        rect(0,0,400,25);
        fill(128);
        text(popul.species.Key()+" Bio: "+popul.biomas+" "+binary(popul.species.suscepBits,MASKBITS)+":"+binary(popul.species.activeBits,MASKBITS),1,20);
      }
    }
    else
    {
      float ofs=popul.species.sizelog;
      float x=startX+size*((float)popul.species.suscepBits/MASK)+ofs;
      float y=startY+size*((float)popul.species.activeBits/MASK)+ofs;
      stroke(0);
      point(x,y); //print(".");
      noStroke();
    }
  }
  
  //NIE SZUKA DO NASTĘPNEGO KLIKNIECIA
  searchedX=-1;
  searchedY=-1;
}

void drawTransfersBW(anArea is,int startX,int startY,int size)
{
  for(aPopLink lnk:is.trophNet)//Wizualizacja intereackji
  if(lnk.source.biomas>0
  && lnk.target.biomas>0 )//link jest istotny
  {
      float intensity=(float)(VDENSITY*(lnk.lasttransfer/maxTransfer));  
      if(lnk.target==theSelected
      || intensity>VDENSITY/DENSITYDIV )
      //&& intensity/DENSITYDIV>0)//Jak za dużo jest 
      {
        float of1=lnk.source.species.sizelog;
        float x1=startX+(float)(size*float(lnk.source.species.suscepBits)/MASK+of1);
        float y1=startY+(float)(size*float(lnk.source.species.activeBits)/MASK+of1);
        float of2=lnk.target.species.sizelog;
        float x2=startX+(float)(size*float(lnk.target.species.suscepBits)/MASK+of2);
        float y2=startY+(float)(size*float(lnk.target.species.activeBits)/MASK+of2);
        
        if(lnk.target==theSelected)//Trzeba (?) niestety powtórzyć sprawdzanie warunku
        {
          if(maxTransSelec<lnk.lasttransfer)
             maxTransSelec=lnk.lasttransfer;//Na początku może być trochę kiepsko ale się naprawi w kolejnych wizualizacjach
          int inten=(int)(255*(lnk.lasttransfer/maxTransSelec));
          strokeWeight(2);
          stroke(0,inten);
          line(x1,y1,x2,y2);
          strokeWeight(1);
          //println("   ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
        }
        
        if(VISALLTRANSF)
        {
          if(lnk.lasttransfer>=maxTransfer)
          {
            stroke(0);
            //println(" M ",lnk.lasttransfer,lnk.target.species.Key(),"<-",lnk.source.species.Key() );
          }
          else
          {
            //intensity/=DENSITYDIV;//Czy to konieczne?
            stroke(BACKGROUND/3,intensity);
          }
          
          line(x1,y1,(x1+x2)/2,(y1+y2)/2);
          stroke(BACKGROUND/2,intensity);
          line(x2,y2,(x1+x2)/2,(y1+y2)/2);
        }
      }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////
//  https://www.researchgate.net/profile/WOJCIECH_BORKOWSKI
///////////////////////////////////////////////////////////////////////////////////////////
