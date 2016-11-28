//
// Created by anna on 11/28/16.
//

#include <stdio.h>



int disassemble(int instruction)
{
    int code;
    if (instruction <= 0x3fff820)
    {
        printf("add");
        code = 0;
    }
    else
    {
        printf("not add");
        code = 1;
    }
    return code;
}


int main() {
    int code;
    int add;
    add = 0x014B4820;
    code = disassemble(add);
    return code;
}

