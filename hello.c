#include "types.h"
#include "user.h"

void print(int n){
    int a=n;
    int b =1;
    float c = 2;
    char d = 's';
    int e = 3;
    a+=1;
    b+=2;
    c+=3;
    e+=4;
    d+=1;
    printf(1,"hello world = %d \n", n);
    print(a);
    
}

int main(int argc, char *argv[]){
    print(1);
    exit();
}
