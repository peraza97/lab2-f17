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
    int i;
    acquire(&(shm_table.lock));
    for (i = 0; i< 64; i++) {
 
    }
    release(&(shm_table.lock));
    /*    
    //figure out if it was found or not
    if(found){
        //allocate variables needed for mappages
        pde_t * pgdir = myproc()->pgdir;
        uint va = PGROUNDUP(myproc()->sz);
        char *mem = shm_table.shm_pages[i].frame; 
        //mappages
        mappages(pgdir,(char*)va, PGSIZE, V2P(mem), PTE_W|PTE_U);
        //increment reference
        myproc()->sz = va;
        shm_table.shm_pages[i].refcnt +=1;
        *pointer=(char *)va;
    }
    //not found 
    else{
        //initialize id and frame
        shm_table.shm_pages[first].id = id;
        char *frame = kalloc(); 
        shm_table.shm_pages[first].frame = frame;
        shm_table.shm_pages[first].refcnt = 1;
        //mappages
        pde_t * pgdir = myproc()->pgdir;
        uint va = PGROUNDUP(myproc()->sz);
        mappages(pgdir,(char*)va,PGSIZE,V2P(frame),PTE_W|PTE_U);
        myproc()->sz = va;
        *pointer=(char*)va;        
    }
*/
return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
}
