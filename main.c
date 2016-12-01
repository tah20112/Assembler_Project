#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int instr_type = -1; //0 is R; 1 is I; 2 is J.


void to_binary(int n){

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
    //int instr_type = 0; //0 is R; 1 is I; 2 is J.
    if(strcmp(instr,"add") == 0){
        opCode = 0x0;
        funct = 0x0020;
        instr_type = 0;
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
        instr_type = 0;
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
        instr_type = 0;
        goto end;
    }
    if(strcmp(instr,"slt") == 0){
        opCode = 0x0;
        funct = 0x2a;
        instr_type = 0;
        goto end;
    }
    end:

        printf("%d\n",instr_type);
        result = (opCode << 26) | funct;
        return result;
}

// char** parse_instr(char* instruction){
//     char* result;
//     while((result = strsep(&instruction, " "))) printf("%s\n",result);
//     printf("%s\n", result);
//     return result;
// }

int check_instr(int instr_type, char* instruction[3]){
    int i = 0;
    switch(instr_type) {
        case 0:
            i = r_type(instruction);
            break;
        case 1:
            i = i_type(instruction);
            break;
        case 2:
            i = j_type(instruction);
            break;
    }
    return i;
}

int r_type(char* instruction[3]){

    return 0;
}

int i_type(char* instruction[3]){
    if (strncmp(instruction[0], "$s", 2) == 0){
        switch(strncmp(instruction[0], "$s", 3)){
            case 48: //s0
                break;
            case 49: //s1
                break;
            case 50: //s2
        };


    }
    return 1;
}

int j_type(char* instruction[3]){

    return 2;
}



int main() {
    //instr_type: 0 is R; 1 is I; 2 is J.
    int i = check_function("bne");
    // char ** f = parse_instr("slt $t3 $t4 $t1");
    // printf("%d\n", f);
    to_binary(i);
    printf("%x\n", i);
    char* f[3];
    f[0] = "$s0";
    f[1] = "$s2";
    f[3] = "100";
    int reg = check_instr(instr_type, f);

    return i;
}
