#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "uthash.h"


int instr_type = -1; //0 is R; 1 is I; 2 is J; 3 is label




struct my_struct *jumps = NULL;
struct my_struct {
    int lineNum;                    /* key */
    char label[10];
    UT_hash_handle hh;         /* makes this structure hashable */
};

//This function prints the binary of a hex input
//Input: hex number
//Output: none (prints binary number)

void to_binary(int n){
    while (n){
        if (n & 0x80000000)
            printf("1");
        else
            printf("0");
        n <<= 1;
    }
}


void add_label(int lineNum, char *label) {
    struct my_struct *s;

    HASH_FIND_INT(jumps, &lineNum, s);  /* id already in the hash? */
    if (s==NULL) {
        s = (struct my_struct*)malloc(sizeof(struct my_struct));
        s->lineNum = lineNum;
        HASH_ADD_INT( jumps, lineNum, s );  /* id: name of key field */
    }
    strcpy(s->label, label);
}

int check_function(char* instr, int lineNum){

//This function takes the function instruction and
//  checks it and outputs the correct opcodes and function codes
//Input: string containing function ('add','j','xori',etc...)
//Output: 32-bit opcode and, if used, function code

    int result = 0;
    int funct = 0;
    int opCode = 0;

    if(strcmp(instr,"add") == 0){
        opCode = 0x0;
        funct = 0x0020;
        instr_type = 0;
        goto end;
    }
    else if(strcmp(instr,"addi") == 0){
        opCode = 0x8;
        funct = 0x0020;
        instr_type = 1;
        goto end;
    }
    else if(strcmp(instr,"lw") == 0){
        opCode = 0x0023;
        instr_type = 1;
        goto end;
    }
    else if(strcmp(instr,"sw") == 0){
        opCode = 0x2b;
        instr_type = 1;
        goto end;
    }
    else if(strcmp(instr,"j") == 0){
        opCode = 0x2;
        instr_type = 2;
        goto end;
    }
    else if(strcmp(instr,"jr") == 0){
        opCode = 0x0;
        funct = 0x8;
        instr_type = 0;
        goto end;
    }
    else if(strcmp(instr,"jal") == 0){
        opCode = 0x3;
        instr_type = 2;
        goto end;
    }
    else if(strcmp(instr,"bne") == 0){
        opCode = 0x5;
        instr_type = 1;
        goto end;
    }
    else if(strcmp(instr,"xori") == 0){
        opCode = 0xe;
        instr_type = 1;
        goto end;
    }
    else if(strcmp(instr,"sub") == 0){
        opCode = 0x0;
        funct = 0x22;
        instr_type = 0;
        goto end;
    }
    else if(strcmp(instr,"slt") == 0){
        opCode = 0x0;
        funct = 0x2a;
        instr_type = 0;
        goto end;
    }
    else {
        add_label(lineNum, instr);
        opCode = 0x0;
        funct = 0x0;
        instr_type = 3;
        goto end;
    }
    end:
        result = (opCode << 26) | funct;
        return result;
}

//This function takes in the full mips instruction
//  and separates it into the four instruction strings
//Input: string containing full mips instruction ("add $t1 $t2 $s1)
//Output: string with pointer containing separated instruction ("add" "$t1" "$t2" "$s1")
 char* *parse_instr(char *instruction){
     char *word;
     char* *output = malloc(5);
     int counter = 0;
     size_t comm_test;

     while (instruction != NULL){
        word = strsep(&instruction, " ");
        comm_test = strcspn(word, "#");
        if (comm_test != 0){
            output[counter] = word;
            counter++;
        } else{
            break;
        }
     }
     return output;
 }


//Assembly code comes in, machine code comes out.
// OPCODE RS RT RD SHIFT FUNCT
// 000000  5  5  5  5     6

//This function takes in the full parsed mips instruction
//  and outputs the correct register codes for an r-type instruction
//Input: parsed string with pointer containing separated instruction ("add" "$t1" "$t2" "$s1")
//Output: 26-bit machine code corresponding to the correct registers used
int r_type(char* instruction[4]){
    int n = 1;          //start at 1st register, which is 2nd in mips instruction
    int reg_codes[3];   //create array to place the machine code for each register
    while (n < 4) {     //run it for each of the three registers/immediates
        int a = n-1;    //just to avoid calculating [n-1] every time the array is called
        char* reg_letter;

        //First, run strncmp on the first two letters with each register letter
        //if strncmp(instruction[n], $(letter), 2) == 0, the first two characters are $(letter).

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
        else if (strncmp(instruction[n], "$r", 2) == 0) {
            reg_letter = "$r";
        }
        else if (strncmp(instruction[n], "$z", 2) == 0) {
            reg_letter = "$";   //set to null reg_letter value
            reg_codes[a] = 0b00000;
            //if the register call starts with $z, it must be the zero register
            //and we can just fill in reg_codes[a] here.
        }
        else{
            //if none of the above are correct, then we must be dealing with an immediate
            reg_letter = "$";               //set to null reg_letter value
            char* s = instruction[n];       //do string convert from hex value to integer
            sscanf(s, "%x", &reg_codes[a]); //and save it to the reg_codes[a]
        }

        //if we got a reg_letter earlier, we can run the strncmp to get the value for the next
        //  character after the reg_letter. We use that value to find the full register address.
        int i = strncmp(instruction[n], reg_letter, 3);

        //calculated equations for the difference between strncmp return value and corresponding register address
        if (reg_letter == "$t"){
            if (i == 0x38){
                reg_codes[a] = 0x18;
            }
            else if (i == 0x39){
                reg_codes[a] = 0x19;
            }
            else {
                reg_codes[a] = (i - 0x28);
            }
        }
        else if (reg_letter == "$s") {
            if (i == 0x70) {
                reg_codes[a] = 0x1d;
            }
            else{
                reg_codes[a] = (i-0x1a);
            }
        }
        else if (reg_letter == "$v") {
            if (i == 0x31) {
                reg_codes[a] = 0x2;
            }
            else if (i == 0x32){
                reg_codes[a] = 0x3;
            }
        }
        else if (reg_letter == "$a") {
            if (i == 116){
                reg_codes[a] = 1;
            }
            reg_codes[a] = (i - 0x2c);
        }
        else if (reg_letter == "$k") {
            reg_codes[a] = (i - 0x16);
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


//This function takes in the full parsed mips instruction
//  and outputs the correct register codes for an i-type instruction
//Input: parsed string with pointer containing separated instruction ("addi" "$t1" "$t2" "45")
//Output: 26-bit machine code corresponding to the correct registers and immediate used

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
            // return j; //get value from hashtable and return int
            break;
        default:break;
    }
    return i;
}


// function that takes in all instructions, saves
// all labels and line numbers in hashtable first?





//This function takes in the full parsed mips instruction
//  and outputs the correct register codes for an i-type instruction
//Input: parsed string with pointer containing separated instruction ("j" "45")
//Output: 26-bit machine code corresponding to the correct registers and immediate used
int j_type(char* instruction[2]){

    int reg_codes;
    char* a = instruction[1];
    sscanf(a, "%x", &reg_codes);
    int immediate = reg_codes;


    char* label = instruction[1];
    struct my_struct *s;

    for(s=jumps; s != NULL; s=s->hh.next) {
        //printf("user id %d: name %s\n", s->lineNum, s->label);
        char* checklabel = &s->label[0];
        printf("%s", checklabel);
        printf("%s", label);
        printf("%s", checklabel);
        if (label == checklabel){
            return s -> lineNum;
        }
    }
    printf("%s\n", "not found");
    return 0;


}

//This function takes in the full parsed mips instruction
//  and according to the instruction type (global variable instr_type, assigned in check_function)
//  runs the correct type of instruction parser
//Input: parsed string with pointer containing separated instruction ("addi" "$s1" "$t2" "45")
//Output: 26-bit machine code corresponding to the correct registers and immediate used


char* *readFile(char * file){

    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    char* *text_lines = calloc(128, sizeof(char*));
    int counter = 0;
  
    fp = fopen(file, "r");
    if (fp == NULL){
        printf("Error: file empty");
        exit(EXIT_FAILURE);
    }
      while((read = getline(&line, &len, fp)) != -1){
        if (line[0] != '\n'){
            text_lines[counter] = strdup(line);
            counter ++;
        }
    }

    //fclose(fp);
    //if (line)
    //    free(line);
    return text_lines;
}




//This is the main function of the  program
//  it runs all the other functions
//Input: none
//Output: 32-bit machine code corresponding to the correct functions, registers, and immediate used


struct my_struct *find_label(int lineNum) {
    struct my_struct *s;
    HASH_FIND_INT( jumps, &lineNum, s );  /* s: output pointer */
    return s;
}

int run_each(char* instruction, int lineNum){
    char *instr = strdup(instruction);
    char* *parsed_instr;
    parsed_instr = parse_instr(instr);
    int i = check_function(parsed_instr[0], lineNum);
    if (instr_type == 3){
        return 0;
    }
    else{
        int r = check_instruction(parsed_instr);
        int full = i | r ;
        return full;
    }
}


int main(int argc, char* argv[]) {

    //instr_type: 0 is R; 1 is I; 2 is J.

    char* *file_text = readFile(argv[1]);
    FILE * fout = fopen(argv[2], "w+");
    int fileSize = atoi(argv[3]);

    const char fake[] = "xori $t3 $t4 $t1 # Now a comment";
    char *instr = strdup(fake);
    char* *f;
    int reg;
    int i;
    int lineNum;

    for (lineNum = 0; lineNum < fileSize; lineNum++){ // Use Python to determine number of lines
        instr = strdup(file_text[lineNum]);
        f = parse_instr(instr);
        if (f[0] != 0){
            printf("%d\n", lineNum); // anything that happens in this conditional happens with the useful values of f
            fprintf(fout, "%s\n",f[0]);
        }
    }
    fclose(fout);
    i = check_function(file_text[0], lineNum);
    reg = check_instruction(f);
    printf("%x\n", reg);

    /*    char* instruction = "frog";
    char *instr = strdup(instruction);
    char* *parsed_instr;
    parsed_instr = parse_instr(instr);
    int i = check_function(parsed_instr[0], 30);
    int r = check_instruction(parsed_instr);
    int full = i | r ;
    struct my_struct *s;
    instruction = "j frog";
    instr = strdup(instruction);
    parsed_instr = parse_instr(instr);
    i = check_function(parsed_instr[0],11);
    r = check_instruction(parsed_instr);
    full = i | r;*/
    char* test = "frog";
    int result = run_each(test, 2);
    test = "j frog";
    result = run_each(test, 2);

    printf("%s\n", "result:");
    printf("%x\n", result);
    //to_binary(full);

//    add_label(35, "frog");

//    s = find_label(35);

    return 0;
}

