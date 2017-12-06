#include "types.h"
#include "user.h"
void test(int x){

if(x>1000){
exit();
}

int a = x;
int b = 1;
float c = 2;
char d = 's';
int e = 3;
a+=1;
b+=2;
c+=3;
d+=1;
e+=4;

printf(1,"testy = %d\n",x);
test(a);

}
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
//    printf(1,"hello world = %d \n", n);
    print(a);
    
}

int rec(int n){
    if(n == 5000){
        return n;
    }
    printf(1,"%d\n",n);
    return rec(n + 1);
}

int main(int argc, char *argv[]){
    //test(1);
    print(1);
    //printf(1,"\n%d\n",rec(1));

    exit();
}
