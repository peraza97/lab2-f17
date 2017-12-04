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
    struct proc * curproc = myproc();
    uint sz = curproc->sz;
    pte_t * pgdir = curproc->pgdir;
    acquire(&(shm_table.lock));
    for(i = 0; i < 64; i++){ 
        uint val_id = shm_table.shm_pages[i].id;
        //if it matches
        if(val_id == id){
            char * fr = shm_table.shm_pages[i].frame;
            if( mappages(pgdir,(char*)PGROUNDUP(sz),PGSIZE,V2P(fr),PTE_W|PTE_U) < 0){
                goto release;
            }
            shm_table.shm_pages[i].refcnt++;
            *pointer=(char*)PGROUNDUP(sz);
            goto release;
        }
        //set the found variable
        if(found == -1 && val_id == 0){
            found = i;
        }    
    }
    //not found
    shm_table.shm_pages[found].id = id;
    char * fr = kalloc();
    memset(fr,0,PGSIZE);
    shm_table.shm_pages[found].frame = fr;
    shm_table.shm_pages[found].refcnt = 1;
    if( mappages(pgdir,(char*)PGROUNDUP(sz),PGSIZE,V2P(fr),PTE_W|PTE_U) < 0){
        goto release;
    }
    *pointer=(char*)PGROUNDUP(sz);
    curproc->sz = PGROUNDUP(sz) + PGSIZE;
    release:
    release(&(shm_table.lock));

    return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
    //you write this too!
    int i=0;
    acquire(&(shm_table.lock));
    for (i = 0; i< 64; i++) {
        uint val_id = shm_table.shm_pages[i].id;
        int ref = shm_table.shm_pages[i].refcnt;
        if(val_id == id){
            if(ref > 1){
                shm_table.shm_pages[i].refcnt -=1;
            }
            else{
                shm_table.shm_pages[i].id =0;
                shm_table.shm_pages[i].frame =0;
                shm_table.shm_pages[i].refcnt =0; 
            }
        }
    }
    release(&(shm_table.lock));


return 0; //added to remove compiler warning -- you should decide what to return
}
