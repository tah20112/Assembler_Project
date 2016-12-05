#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

int instr_type = -1; //0 is R; 1 is I; 2 is J.


int j_type(char* instruction[2]);

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
        opCode = 0xe;
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

 char* *parse_instr(char *instruction){
     char *word;
     char* *output = malloc(5);
     int counter = 0;
     while (instruction != NULL){
        word = strsep(&instruction, " ");
        output[counter] = word;
        counter++;
     }
     return output;
 }


int check_instruction(char* instruction[4]) {
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


//Assembly code comes in, machine code comes out.
// OPCODE RS RT RD SHIFT FUNCT
// 000000  5  5  5  5     6
//deal with all the registers and stuff that is not the opcode.
//bit shift, and return...
int r_type(char* instruction[3]){

    int n = 1;
    int reg_codes[3];
    while (n < 4) {
        int a = n-1;

        char* reg_letter;
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
            reg_codes[a] = 0b00000;
        }
        else{
            reg_letter = "$";
            char* s = instruction[n];
            sscanf(s, "%x", &reg_codes[a]);
        }
        int i = strncmp(instruction[n], reg_letter, 3);

        if (reg_letter == "$t"){
            if (i == 0x38){
                reg_codes[a] = 24;
            }
            else if (i == 0x39){
                reg_codes[a] = 25;
            }
            else {
                reg_codes[a] = (i - 0x30) + 0x8;
            }
        }
        else if (reg_letter == "$s") {
            if (i == 112) {
                reg_codes[a] = 29;
            }
            else{
                reg_codes[a] = (i-0x30) + 16;
            }
        }
        else if (reg_letter == "$v") {
            if (i == 49) {
                reg_codes[a] = 2;
            }
            else if (i == 50){
                reg_codes[a] = 3;
            }
        }
        else if (reg_letter == "$a") {
            if (i == 116){
                reg_codes[a] = 1;
            }
            reg_codes[a] = (i - 0x30) + 4;
        }
        else if (reg_letter == "$k") {
            reg_codes[a] = (i - 0x30) + 26;
        }
        else if (reg_letter == "$g") {
            reg_codes[a] = 28;
        }
        else if (reg_letter == "$f") {
            reg_codes[a] = 30;
        }
        else if (reg_letter == "$r") {
            reg_codes[a] = 31;
        }
        n = n+1;
    }

    int reg_1 = reg_codes[1] << 21;
    int reg_2 = reg_codes[2] << 16;
    int reg_3 = reg_codes[0] << 11;




    int reg_full = reg_1 | reg_2 | reg_3;

        return reg_full;

}




int i_type(char* instruction[4]){
    int n = 1;
    int reg_codes[3];
    while (n < 4) {
        int a = n-1;

        char* reg_letter;
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
            reg_codes[a] = 0b00000;
        }
        else{
            reg_letter = "$";
            char* s = instruction[n];
            sscanf(s, "%x", &reg_codes[a]);
        }
        int i = strncmp(instruction[n], reg_letter, 3);

        if (reg_letter == "$t"){
            if (i == 0x38){
                reg_codes[a] = 24;
            }
            else if (i == 0x39){
                reg_codes[a] = 25;
            }
            else {
                reg_codes[a] = (i - 0x30) + 0x8;
            }
        }
        else if (reg_letter == "$s") {
            if (i == 112) {
                reg_codes[a] = 29;
            }
            else{
                reg_codes[a] = (i-0x30) + 16;
            }
        }
        else if (reg_letter == "$v") {
            if (i == 49) {
                reg_codes[a] = 2;
            }
            else if (i == 50){
                reg_codes[a] = 3;
            }
        }
        else if (reg_letter == "$a") {
            if (i == 116){
                reg_codes[a] = 1;
            }
            reg_codes[a] = (i - 0x30) + 4;
            }
        else if (reg_letter == "$k") {
            reg_codes[a] = (i - 0x30) + 26;
        }
        else if (reg_letter == "$g") {
            reg_codes[a] = 28;
        }
        else if (reg_letter == "$f") {
            reg_codes[a] = 30;
        }
        else if (reg_letter == "$r") {
            reg_codes[a] = 31;
        }
            n = n+1;
    }
    int reg_1 = reg_codes[0] << 16;
    int reg_2 = reg_codes[1] << 21;
    int reg_3 = reg_codes[2];

    int reg_full = reg_1 | reg_2 | reg_3;
        return reg_full;
}

int j_type(char* instruction[2]){
    
    int reg_codes;
    char* s = instruction[1];
    sscanf(s, "%x", &reg_codes);
    int immediate = reg_codes;

    return immediate;
}





int main() {
    char* instruction = "j 450";
    char *instr = strdup(instruction);
    char* *parsed_instr;
    parsed_instr = parse_instr(instr);
    int i = check_function(parsed_instr[0]);
    int r = check_instruction(parsed_instr);
    int full = i | r ;
    printf("%x\n", full);


    to_binary(full);

    return 0;
}