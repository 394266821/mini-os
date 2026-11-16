extern char my_var;
char my_var1 = 'G';

void kernel_main(void){
    char* video = (char*)0xb8000;
    *video = 'G';
}

void kernel_test(void){
    char* video = (char*)0xb8000;
    *video = 'A';
}

void kernel_test_char(char c){
    char* video = (char*)0xb8000;
    *video = c;
}

void kernel_test_my_var(){
    char* video = (char*)0xb8000;
    *video = my_var;
}

void kernel_change_var(){
    char* video = (char*)0xb8000;
    asm volatile("call change_char_to_Z");
    *video = my_var;
}