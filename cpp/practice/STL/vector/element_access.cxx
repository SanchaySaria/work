#include <iostream>
#include <vector>
#include <string>

int main()
{
  std::vector<std::string> sVec = {"one", "two", "three", "four", "five"};
  std::cout<<"sVec.front() : "<<sVec.front()<<std::endl;
  std::cout<<"sVec[1] : "<<sVec[1]<<std::endl;
  std::cout<<"sVec.at(2) : "<<sVec.at(2)<<std::endl;
  std::cout<<"sVec.data()[3] : "<<sVec.data()[3]<<std::endl;
  return 0;
}
