#include "types.h"
#include "user.h"

void print(){
    int a,b,c,d;
    a = 1;
    b = 1;
    c = 1;
    d = 1;
    printf(1,"hello world%d%d%d%d\n",a,b,c,d);
    print();
    
}

int main(int argc, char *argv[]){
    print();
    exit();
}
