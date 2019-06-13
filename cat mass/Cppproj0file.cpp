#include "iostream.h"



int main()
{
  int sequence [25] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,-1,-1} 
  int projectedMass [25]= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,500}
  int  v24 =21;
  while(v24 > -1)
  {
    sequence[v24] = sequence[v24+3] + sequenc[v24+2] + sequence[v24+1];
    v24--;    
  }
  v24 = 24;
  while(v24 > -1)
  {
    projectedMass[v24] = projectedMass[v24+1] + sequence[v24]
    v24--;
  }
  char a;
  std::cin >> a;
  return 0;
}