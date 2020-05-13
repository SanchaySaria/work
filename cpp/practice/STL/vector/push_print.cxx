#include <iostream>
#include <vector>

void
printVec(std::vector<int> &iVec)
{
  std::cout<<"Printing Vector"<<std::endl;
  std::vector<int>::iterator vIter = iVec.begin();
  while(vIter != iVec.end()) {
    std::cout<<*vIter<<std::endl;
    vIter++;
  }
}

void
revPrintVec(std::vector<int> &iVec)
{
  std::cout<<"Printing Vector"<<std::endl;
  std::vector<int>::reverse_iterator vIter = iVec.rbegin();
  while(vIter != iVec.rend()) {
    std::cout<<*vIter<<std::endl;
    vIter++;
  }
}

int main() {
  std::vector<int> iVec;
  for (int i=1; i<=10; i++) {
    iVec.push_back(i);
  }
  printVec(iVec);
  revPrintVec(iVec);
  return 0;
}

