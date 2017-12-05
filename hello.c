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
    //printf(1,"hello world = %d \n", n);
    print(a);
    
}

int rec(int n){
    if(n == 57000){
        return n;
    }
    if(n == 5700){
        printf(1,"half\n");
    }
    return rec(n + 1);


}

int main(int argc, char *argv[]){
    print(1);
    exit();
}
