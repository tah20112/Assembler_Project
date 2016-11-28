#include <iostream>

using namespace std;


int disassemble(int instruction)
{
    int code;
    if (instruction <= 0x3fff820)
    {
        cout<<"add"<<endl;
        code = 0;
    }
    else
    {
        cout << "not add" << endl;
        code = 1;
    }
    return code;
}


int main() {
    int code;
    int add;
    add = 0x014B4820;
    code = disassemble(add);
    cout<<code<<endl;
    return code;
}

