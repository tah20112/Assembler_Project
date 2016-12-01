
//
// Created by anna on 11/28/16.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>



void byte_to_binary(int n){

    while (n){
        if (n & 0x80000000)
            printf("1");
        else
            printf("0");
        n <<= 1;
    }
    printf("\n");
}

int check_function(const char* instr){
    int result = 0;
    int funct = 0;
    int opCode = 0;
    if(strcmp(instr,"add") == 0){
        opCode = 0x0;
        funct = 0x0020;
        goto end;
    }
    if(strcmp(instr,"lw") == 0){
        opCode = 0x0023;
        instr_type = 1;
        goto end;
    }
    if(strcmp(instr,"sw") == 0){
        opCode = 0x2b;
        instr_type = 1;
        goto end;
    }
    if(strcmp(instr,"j") == 0){
        opCode = 0x2;
        instr_type = 2;
        goto end;
    }
    if(strcmp(instr,"jr") == 0){
        opCode = 0x0;
        funct = 0x8;
        goto end;
    }
    if(strcmp(instr,"jal") == 0){
        opCode = 0x3;
        instr_type = 2;
        goto end;
    }
    if(strcmp(instr,"bne") == 0){
        opCode = 0x5;
        instr_type = 1;
        goto end;
    }
    if(strcmp(instr,"xori") == 0){
        opCode = 0x14;
        instr_type = 1;
        goto end;
    }
    if(strcmp(instr,"sub") == 0){
        opCode = 0x0;
        funct = 0x22;
        goto end;
    }
    if(strcmp(instr,"slt") == 0){
        opCode = 0x0;
        funct = 0x2a;
        goto end;
    }
    end:
        result = (opCode << 26) | funct;
        return result;
}

// char** parse_instr(char* instruction){
//     char* result;
//     while((result = strsep(&instruction, " "))) printf("%s\n",result);
//     printf("%s\n", result);
//     return result;
// }

int main() {
    int instr_type = 0; //0 is R; 1 is I; 2 is J.
    int i = check_function("bne");
    // char ** f = parse_instr("slt $t3 $t4 $t1");
    // printf("%d\n", f);
    byte_to_binary(i);
    return i;
}
