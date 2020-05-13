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
  // push_back
  std::vector<int> iVec1{1, 2, 3, 4};
  printVec(iVec1);
  std::vector<int> iVec2(10, 2);
  printVec(iVec2);
  std::vector<int> iVec3{iVec2.begin(), iVec2.end()};
  printVec(iVec3);

  int arr[] = {5, 4, 3, 2, 1};
  int size = sizeof(arr)/sizeof(arr[0]);
  std::vector<int> iVec4{arr, arr+size};
  printVec(iVec4);

  return 0;
}
