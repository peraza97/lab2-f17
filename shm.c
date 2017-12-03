#include "param.h"
#include "types.h"
#include "defs.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct shm_page {
    uint id;
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
}

int shm_open(int id, char **pointer) {

    //you write this
    int i,found=0;
    acquire(&(shm_table.lock));
    for (i = 0; i< 64; i++){
        uint val = shm_table.shm_pages[i].id;
        //id is found
        if(val == id){
            cprintf("\nID match of %d\n\n",id);
            uint va = PGROUNDUP(myproc()->sz);
            char * fr = shm_table.shm_pages[i].frame;
            mappages(myproc()->pgdir,(char*)va ,PGSIZE,V2P(fr),PTE_W|PTE_U);
            shm_table.shm_pages[i].refcnt +=1;
            *pointer=(char *)va;
            found = 1;
            break;
        }
     }
    //ID IS NOT FOUND
    if(found == 0){
        for(i = 0; i < 64; i++){      
            uint val = shm_table.shm_pages[i].id;
            if(val == 0){
                cprintf("\nNOT FOUND\n\n");
                shm_table.shm_pages[i].id = id;            
                shm_table.shm_pages[i].frame = kalloc();
                shm_table.shm_pages[i].refcnt = 1;
                uint va = PGROUNDUP(myproc()->sz);
                char * fr = shm_table.shm_pages[i].frame;
                mappages(myproc()->pgdir,(char*)va ,PGSIZE,V2P(fr),PTE_W|PTE_U);
                *pointer=(char*)va;
                break;
            }
        }
    }
    cprintf("\ngoing to release the lock in shm_open\n");
    release(&(shm_table.lock));
    cprintf("\nreleased\n\n");
return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
//you write this too!



return 0; //added to remove compiler warning -- you should decide what to return
}
