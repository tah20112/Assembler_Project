
//
// Created by anna on 11/28/16.
//

#include <stdio.h>
#include <string.h>

void assemble(const char* instruction)
{
    int result;
    result = strncmp (instruction,"addi",4);
    if (result == 0)
    {
        printf("%d\n", result);
        printf("%s\n", "add immediate");
    }
    printf("%d\n", result);
}


int main() {
    assemble("addi s");
    return 0;
}