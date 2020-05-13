#include <iostream>
#include <vector>

void
printVecConst(std::vector<int> &iVec)
{
  std::vector<int>::const_iterator vIter = iVec.cbegin();
  for (; vIter < iVec.cend(); vIter++) {
    //*vIter = *vIter + 1; // error
    std::cout<<*vIter<<" ";
  }
  std::cout<<std::endl;
}

void
revPrintVecConst(const std::vector<int> &iVec)
{
  std::vector<int>::const_reverse_iterator vIter = iVec.rbegin();
  for (; vIter < iVec.rend(); vIter++) {
    //*vIter = *vIter + 1; // error
    std::cout<<*vIter<<" ";
  }
  std::cout<<std::endl;
}

void
printVec(std::vector<int> &iVec)
{
  std::vector<int>::iterator vIter = iVec.begin();
  for (; vIter < iVec.end(); vIter++) {
    std::cout<<*vIter<<" ";
  }
  std::cout<<std::endl;
}

void
revPrintVec(std::vector<int> &iVec)
{
  std::vector<int>::reverse_iterator vIter = iVec.rbegin();
  for (; vIter < iVec.rend(); vIter++) {
    std::cout<<*vIter<<" ";
  }
  std::cout<<std::endl;
}

void
incrVec(std::vector<int> &iVec)
{
  std::vector<int>::iterator vIter = iVec.begin();
  for (; vIter < iVec.end(); vIter++) {
    *vIter = *vIter + 1;
  }
}

void
printVecPtr(std::vector<int*> &iVec)
{
  std::vector<int*>::const_iterator vIter = iVec.cbegin();
  for (; vIter < iVec.cend(); vIter++) {
    std::cout<<**vIter<<"  "<<*vIter<<"  "<<std::endl;;
  }
  std::cout<<std::endl;
}

void
printVecPtrConst(const std::vector<int*> &iVec)
{
  std::vector<int*>::const_iterator vIter = iVec.cbegin();
  for (; vIter < iVec.cend(); vIter++) {
    std::cout<<**vIter<<"  "<<*vIter<<"  "<<std::endl;;
  }
  std::cout<<std::endl;
}

void
incrVecPtrConst(const std::vector<int*> &iVec)
{
  std::vector<int*>::const_iterator vIter = iVec.cbegin();
  for (; vIter < iVec.cend(); vIter++) {
    **vIter = **vIter + 1;
  }
}

int main()
{
  std::vector<int> iVec1;

  for (int i = 1; i <= 10; i++) {
    iVec1.push_back(i);
  }

  std::cout<<"Vector 1 :"<<std::endl;
  printVec(iVec1);
  std::cout<<"Vector 1 reverse :"<<std::endl;
  revPrintVec(iVec1);

  std::cout<<"Vector 1 : const print"<<std::endl;
  printVecConst(iVec1);
  std::cout<<"Vector 1 reverse : const print"<<std::endl;
  revPrintVec(iVec1);

  std::cout<<"Vector 1 : incr"<<std::endl;
  incrVec(iVec1);
  printVec(iVec1);

  const std::vector<int> iVec2;
  /*
  for (int i = 1; i <= 10; i++) {
    iVec2.push_back(i*2);
  }
  */ // error

  const std::vector<int> iVec3(iVec1);
  //printVec(iVec3); // error
  //printVecConst(iVec3); // error
  std::cout<<"Vector 3 : const : reverse print "<<std::endl;
  revPrintVecConst(iVec3);

  const std::vector<int> iVec4 = {2, 4, 6, 8, 10, 12 , 14, 16, 18, 20}; // -std=c++11 when compile
  std::cout<<"Vector 4 : const : reverse print "<<std::endl;
  revPrintVecConst(iVec4);

  std::vector<int*> iPtrVec1;
  for (int i = 1; i <= 10; i++) {
    int *ptr = new int(i);
    iPtrVec1.push_back(ptr);
  }
  std::cout<<"Vector ptr 1 :"<<std::endl;
  printVecPtr(iPtrVec1);

  const std::vector<int*> iPtrVec2(iPtrVec1);
  std::cout<<"Vector ptr const 2 :"<<std::endl;
  printVecPtrConst(iPtrVec2);
  std::cout<<"Vector ptr const 2 incr:"<<std::endl;
  incrVecPtrConst(iPtrVec2);
  printVecPtrConst(iPtrVec2);

  return 0;
}
