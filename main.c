
//
// Created by anna on 11/28/16.
//

#include <stdio.h>
#include <string.h>

int check_function(const char* instr)
{
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
        goto end;
    }
    if(strcmp(instr,"sw") == 0){
        opCode = 0x2b;
        goto end;
    }
    if(strcmp(instr,"j") == 0){
        opCode = 0x2;
        goto end;
    }
    if(strcmp(instr,"jr") == 0){
        opCode = 0x0;
        funct = 0x8;
        goto end;
    }
    if(strcmp(instr,"jal") == 0){
        opCode = 0x3;
        goto end;
    }
    if(strcmp(instr,"bne") == 0){
        opCode = 0x5;
        goto end;
    }
    if(strcmp(instr,"xori") == 0){
        opCode = 0x14;
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
    result = (opCode << 26) + opCode;
    end:
        return result;
}

char** parse_instr(char* instruction){
    char* result;
    while((result = strsep(&instruction, " "))) printf("%s\n",result);
    printf("%s\n", result);
    return result;
}

int main() {
    int i = check_function("slt");
    char ** f = parse_instr("slt $t3 $t4 $t1");
    printf("%d\n", f);
    return i;
}
