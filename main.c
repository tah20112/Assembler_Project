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
            //i = j_type(instruction);
            break;
    }
    return i;
}

int r_type(char* instruction[3]){

    return 0;
}


int i_type(char* instruction[3]){
    int n = 0;
    int reg_codes[3];
    while (n < 3) {

        char *reg_letter = "$";
        if (strncmp(instruction[n], "$s", 2) == 0) {
            reg_letter = "$s";
        }
        else if (strncmp(instruction[n], "$t", 2) == 0) {
            reg_letter = "$t";
        }
        else if (strncmp(instruction[n], "$a", 2) == 0) {
            reg_letter = "$a";
        }
        else if (strncmp(instruction[n], "$v", 2) == 0) {
            reg_letter = "$v";
        }
        else if (strncmp(instruction[n], "$k", 2) == 0) {
            reg_letter = "$k";
        }
        else if (strncmp(instruction[n], "$g", 2) == 0) {
            reg_letter = "$g";
        }
        else if (strncmp(instruction[n], "$g", 2) == 0) {
            reg_letter = "$f";
        }
        else if (strncmp(instruction[n], "$g", 2) == 0) {
            reg_letter = "$r";
        }
        else if (strncmp(instruction[n], "$z", 2) == 0) {
            reg_letter = "$";
            reg_codes[n] = 0b00000;
        }
        else{
            reg_letter = "$";
            char* s = instruction[n];
            sscanf(s, "%x", &reg_codes[n]);
        }
        int i = strncmp(instruction[n], reg_letter, 3);

        if (reg_letter == "$t"){
            if (i == 0x38){
                reg_codes[n] = 24;
            }
            else if (i == 0x39){
                reg_codes[n] = 25;
            }
            else {
                reg_codes[n] = (i - 0x30) + 0x8;
            }
        }
        else if (reg_letter == "$s") {
            if (i == 112) {
                reg_codes[n] = 29;
            }
            else{
                reg_codes[n] = (i-0x30) + 16;
            }
        }
        else if (reg_letter == "$v") {
            if (i == 49) {
                reg_codes[n] = 2;
            }
            else if (i == 50){
                reg_codes[n] = 3;
            }
        }
        else if (reg_letter == "$a") {
            if (i == 116){
                reg_codes[n] = 1;
            }
            reg_codes[n] = (i - 0x30) + 4;
            }
        else if (reg_letter == "$k") {
            reg_codes[n] = (i - 0x30) + 26;
        }
        else if (reg_letter == "$g") {
            reg_codes[n] = 28;
        }
        else if (reg_letter == "$f") {
            reg_codes[n] = 30;
        }
        else if (reg_letter == "$r") {
            reg_codes[n] = 31;
        }
            n = n+1;
    }
    int reg_1 = reg_codes[0] << 16;
    int reg_2 = reg_codes[1] << 21;
    int reg_3 = reg_codes[2];

    int reg_full =reg_1 | reg_2 | reg_3;

        return reg_full;
}

int j_type(char* instruction[3]){

    return 2;
}



int main() {
    //instr_type: 0 is R; 1 is I; 2 is J.
    int i = check_function("bne");
    // char ** f = parse_instr("slt $t3 $t4 $t1");
    // printf("%d\n", f);
    //to_binary(i);
    char* f[3];
    f[0] = "$at";
    f[1] = "$zero";
    f[2] = "3ffc";
    int reg = check_instr(instr_type, f);
    printf("%x\n", reg);
    return i;
}
