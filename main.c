
//
// Created by anna on 11/28/16.
//

#include <stdio.h>
#include <string.h>

int check_function(const char* instruction)
{
    int result;
    if(strcmp(instruction,"add") == 0){
        result = 0;
        goto end;
    }
    if(strcmp(instruction,"lw") == 0){
        result = 1;
        goto end;
    }
    if(strcmp(instruction,"sw") == 0){
        result = 2;
        goto end;
    }
    if(strcmp(instruction,"j") == 0){
        result = 3;
        goto end;
    }
    if(strcmp(instruction,"jr") == 0){
        result = 4;
        goto end;
    }
    if(strcmp(instruction,"jal") == 0){
        result = 5;
        goto end;
    }
    if(strcmp(instruction,"bne") == 0){
        result = 6;
        goto end;
    }
    if(strcmp(instruction,"xori") == 0){
        result = 7;
        goto end;
    }
    if(strcmp(instruction,"sub") == 0){
        result = 8;
        goto end;
    }
    if(strcmp(instruction,"slt") == 0){
        result = 9;
        goto end;
    }
    result = -1;
    end:
        return result;
}

char** parse_instr(char* instruction){
    char* result;
    while((result = strsep(&instruction, " "))) printf("%s\n",result);
    printf("%s\n", result);

}

int main() {
    int i = check_function("slt");
    char ** f = parse_instr("slt $t3 $t4 $t1");
    printf("%d\n", f);
    return i;
}
