#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

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

int r_type(int instruction){
    return 0;
}

int i_type(int instruction){
    return 1;
}

int j_type(int instruction){
    return 2;
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

void check_instr(int instr_type){
    switch(instr_type){
        case 0:    
            r_type(4);
            break;
        case 1:
            i_type(4);
            break;
        case 2:
            j_type(4);
            break;
    }
}


int main() {
    //instr_type: 0 is R; 1 is I; 2 is J.
    const char fake[] = "slt $t3 $t4 $t1";
    char *instr = strdup(fake);
    char* *f;
    f = parse_instr(instr);
    int i = check_function(f[0]);
    to_binary(i);
    printf("%x\n", i);
    return i;
}
