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

int main()
{
  std::vector<int> iVec;
  if (iVec.empty()) {
    std::cout<<"Vector is empty: "<<std::endl;
  }
  std::cout<<"Size of empty vector : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of empty vector : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of empty vector : "<<iVec.capacity()<<std::endl;

  for (int i = 1; i <= 10; i++) {
    iVec.push_back(i);
  }
  std::cout<<"Size of vector(10) : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of vector(10) : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of vector(10) : "<<iVec.capacity()<<std::endl;
  printVec(iVec);

  iVec.shrink_to_fit();
  std::cout<<"After shrink to fit : "<<std::endl;
  std::cout<<"Size of vector(10) : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of vector(10) : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of vector(10) : "<<iVec.capacity()<<std::endl;

  iVec.resize(8);
  std::cout<<"After resize to 8 : "<<std::endl;
  std::cout<<"Size of vector(10) : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of vector(10) : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of vector(10) : "<<iVec.capacity()<<std::endl;
  printVec(iVec);

  iVec.resize(12);
  std::cout<<"After to resize 12 : "<<std::endl;
  std::cout<<"Size of vector(10) : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of vector(10) : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of vector(10) : "<<iVec.capacity()<<std::endl;
  printVec(iVec);

  iVec.reserve(100);
  std::cout<<"After reserve to 100 : "<<std::endl;
  std::cout<<"Size of vector(10) : "<<iVec.size()<<std::endl;
  std::cout<<"Max size of vector(10) : "<<iVec.max_size()<<std::endl;
  std::cout<<"Capacity of vector(10) : "<<iVec.capacity()<<std::endl;
  printVec(iVec);

  return 0;
}
