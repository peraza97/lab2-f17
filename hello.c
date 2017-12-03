#include "types.h"
#include "user.h"

void print(int n){
    int a=1,b=1,c=1,d=1;
    a = a + b + c + d;
    printf(1,"hello world %d\n",n);
    print(n+1);
    
}

int main(int argc, char *argv[]){
    print(1);
    exit();
}
