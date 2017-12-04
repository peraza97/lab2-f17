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
    int i=0,found=-1;
    acquire(&(shm_table.lock));
    struct proc * curproc = myproc();
    for(i = 0; i < 64; ++i){
        uint stored_id = shm_table.shm_pages[i].id;
        //found the id
        if(stored_id == id){
            char * fr = shm_table.shm_pages[i].frame;
            if(mappages(curproc->pgdir,(char*)PGROUNDUP(curproc->sz),PGSIZE,V2P(fr),PTE_W|PTE_U) <0){
                release(&(shm_table.lock));
                panic("fucked");
            }
            shm_table.shm_pages[i].refcnt +=1;
            *pointer=(char*)PGROUNDUP(curproc->sz);
            release(&(shm_table.lock)); 
            curproc->sz = PGROUNDUP(curproc->sz) + PGSIZE;
            return 0;
        }
        //store the first available index
        if(found == -1 &&  stored_id == 0){
            found = i;
        }
    }   
    //it means we have not found it 
    shm_table.shm_pages[found].id = id;
    char * fr = kalloc();
    shm_table.shm_pages[found].frame = fr; 
    if(mappages(curproc->pgdir,(char*)PGROUNDUP(curproc->sz),PGSIZE,V2P(fr),PTE_W|PTE_U) < 0){
        panic("Fucked up");
    } 
    shm_table.shm_pages[found].refcnt = 1; 
    *pointer=(char*)PGROUNDUP(curproc->sz);
    curproc->sz = PGROUNDUP(curproc->sz) + PGSIZE;
    release(&(shm_table.lock));
    return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
//you write this too!



return 0; //added to remove compiler warning -- you should decide what to return
}
