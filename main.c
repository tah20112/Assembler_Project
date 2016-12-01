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
    for (int n = 0; n < 3; ++n) {

        char *reg_letter = "$";
        int reg_codes[3];
        if (strncmp(instruction[0], "$s", 2) == 0) {
            reg_letter = "$s";
        }
        else if (strncmp(instruction[0], "$t", 2) == 0) {
            reg_letter = "$t";
        }
        else if (strncmp(instruction[0], "$a", 2) == 0) {
            reg_letter = "$a";
        }
        else if (strncmp(instruction[0], "$v", 2) == 0) {
            reg_letter = "$v";
        }
        else if (strncmp(instruction[0], "$k", 2) == 0) {
            reg_letter = "$k";
        }
        else if (strncmp(instruction[0], "$z", 2) == 0) {
            goto zero;
        }

        printf("%d\n", strncmp(instruction[0], reg_letter, 3));
        switch (strncmp(instruction[0], reg_letter, 3)) {
            case 48: //0
                break;
            case 49: //1
                break;
            case 50: //2
                break;
            case 51: //3
                break;
            case 52: //4
                break;
            case 53: //5
                break;
            case 54: //6
                break;
            case 55: //7
                break;
            case 56: //8
                break;
            case 57: //9
                break;
            case 97: //a
                break;
            case 112: //p
                if (reg_letter == "$s"){
                    reg_codes[n] = 0x1d;
                }
                break;
        };
        zero:
            reg_codes[n] = 00000;

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
    f[0] = "$sa";
    f[1] = "$s2";
    f[3] = "100";
    int reg = check_instr(instr_type, f);

    return i;
}
