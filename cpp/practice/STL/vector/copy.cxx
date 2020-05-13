#include <iostream>
#include <vector>
#include <algorithm> // for copy and assign

void
printVec(std::vector<int> &iVec)
{
  std::vector<int>::iterator vIter = iVec.begin();
  while(vIter != iVec.end()) {
    std::cout<<*vIter<<"  ";
    vIter++;
  }
  std::cout<<std::endl;
}

void
copyIterative(std::vector<int> &iVec1, std::vector<int> &iVec2)
{
  std::vector<int>::iterator vIter;
  for (vIter = iVec1.begin(); vIter < iVec1.end(); vIter++) {
    iVec2.push_back(*vIter);
  }
}

int main() {
  std::vector<int> iVec;
  for (int i=1; i<=10; i++) {
    iVec.push_back(i);
  }
  std::cout<<"Vector :"<<std::endl;
  printVec(iVec);

  std::vector<int> iVecC1;
  std::cout<<"Copy iterative :"<<std::endl;
  copyIterative(iVec, iVecC1);
  printVec(iVecC1);

  std::vector<int> iVecC2;
  std::cout<<"Copy assignment :"<<std::endl;
  iVecC2 = iVec;
  printVec(iVecC2);

  std::cout<<"Copy by passing vector as constructor :"<<std::endl;
  std::vector<int> iVecC3(iVec);
  printVec(iVecC3);

  std::vector<int> iVecC4;
  std::cout<<"Copy using copy : Range, last minus 2:"<<std::endl;
  //std::vector<int>::iterator copyEnd = iVec.end();
  //--copyEnd;
  //--copyEnd;
  //std::copy(iVec.begin(), copyEnd, std::back_inserter(iVecC4));
  copy(iVec.begin(), iVec.end() - 2, std::back_inserter(iVecC4));
  printVec(iVecC4);

  std::vector<int> iVecC5;
  std::cout<<"Copy using assign:"<<std::endl;
  iVecC5.assign(iVec.begin(), iVec.end());
  printVec(iVecC5);

  return 0;
}

