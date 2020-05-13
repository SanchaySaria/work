#include <iostream>
#include <vector>

void
printVec(std::vector<int> &iVec)
{
  std::cout<<"Printing Vector"<<std::endl;
  std::vector<int>::iterator vIter = iVec.begin();
  while(vIter != iVec.end()) {
    std::cout<<*vIter<<" ";
    vIter++;
  }
  std::cout<<std::endl;
}

int main()
{
  std::vector<int> iVec;
  for (int i = 1; i <= 20; i++) {
    iVec.push_back(i);
  }
  printVec(iVec);
  for (int i = 1; i <= 10; i++) {
    std::cout<<"removing : "<<iVec.back()<<std::endl;
    iVec.pop_back();
  }
  printVec(iVec);

  std::cout<<"Insert 0 in middle"<<std::endl;
  {
    std::vector<int>::iterator vIter = iVec.begin();
    for (int i = 1; i <= 5; i++) {
      ++vIter;
    }
    iVec.insert(vIter, 0);
    printVec(iVec);
    std::cout<<"iterator at after insert"<<*vIter<<std::endl;
  }

  std::cout<<"Erase first halt of vector"<<std::endl;
  std::vector<int>::iterator vIterBegin = iVec.begin();
  std::vector<int>::iterator vIter = iVec.begin();
  for (int i = 1; i <= 4; i++) {
    ++vIter;
  }
  iVec.erase(vIterBegin, vIter);
  printVec(iVec);
  std::cout<<"iterator at after insert"<<*vIterBegin<<"  "<<*vIter<<std::endl;


  std::cout<<"assign vector, sizw 10, val 5"<<std::endl;
  iVec.assign(10, 5);
  printVec(iVec);

  std::cout<<"clear vector"<<std::endl;
  iVec.clear();
  printVec(iVec);

  std::cout<<"assign vector, sizw 10, val 5"<<std::endl;
  iVec.assign(10, 5);
  printVec(iVec);

  std::cout<<"emplace 0 at position 5"<<std::endl;
  {
    std::vector<int>::iterator vIter = iVec.begin();
    for (int i = 1; i <= 5; i++) {
      ++vIter;
    }
    iVec.emplace(vIter, 0);
    printVec(iVec);
    std::cout<<"iterator at after insert"<<*vIter<<std::endl;
  }

  std::cout<<"emplace 10 at back"<<std::endl;
  iVec.emplace_back(10);
  printVec(iVec);


  std::cout<<"\nswap"<<std::endl;
  std::vector<int> iVec2(12, 1);

  std::cout<<"vec 1"<<std::endl;
  printVec(iVec);
  std::cout<<"vec 2"<<std::endl;
  printVec(iVec2);

  iVec.swap(iVec2);

  std::cout<<"vec 1"<<std::endl;
  printVec(iVec);
  std::cout<<"vec 2"<<std::endl;
  printVec(iVec2);

  return 0;
}
