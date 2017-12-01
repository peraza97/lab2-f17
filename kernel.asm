
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 a0 2e 10 80       	mov    $0x80102ea0,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
  struct buf head;
} bcache;

void
binit(void)
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010004c:	68 00 70 10 80       	push   $0x80107000
80100051:	68 c0 b5 10 80       	push   $0x8010b5c0
80100056:	e8 85 41 00 00       	call   801041e0 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010005b:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100062:	fc 10 80 
  bcache.head.next = &bcache.head;
80100065:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010006c:	fc 10 80 
8010006f:	83 c4 10             	add    $0x10,%esp
80100072:	ba bc fc 10 80       	mov    $0x8010fcbc,%edx
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 c3                	mov    %eax,%ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100082:	8d 43 0c             	lea    0xc(%ebx),%eax
80100085:	83 ec 08             	sub    $0x8,%esp
//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
80100088:	89 53 54             	mov    %edx,0x54(%ebx)
    b->prev = &bcache.head;
8010008b:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 07 70 10 80       	push   $0x80107007
80100097:	50                   	push   %eax
80100098:	e8 33 40 00 00       	call   801040d0 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 10 fd 10 80       	mov    0x8010fd10,%eax

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	83 c4 10             	add    $0x10,%esp
801000a5:	89 da                	mov    %ebx,%edx
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
801000a7:	89 58 50             	mov    %ebx,0x50(%eax)

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	8d 83 5c 02 00 00    	lea    0x25c(%ebx),%eax
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
801000b0:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	3d bc fc 10 80       	cmp    $0x8010fcbc,%eax
801000bb:	75 c3                	jne    80100080 <binit+0x40>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c0:	c9                   	leave  
801000c1:	c3                   	ret    
801000c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
801000df:	68 c0 b5 10 80       	push   $0x8010b5c0
801000e4:	e8 f7 41 00 00       	call   801042e0 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	90                   	nop
8010011c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100126:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 60                	jmp    80100190 <bread+0xc0>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100139:	74 55                	je     80100190 <bread+0xc0>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 c0 b5 10 80       	push   $0x8010b5c0
80100162:	e8 99 42 00 00       	call   80104400 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 9e 3f 00 00       	call   80104110 <acquiresleep>
80100172:	83 c4 10             	add    $0x10,%esp
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	75 0c                	jne    80100186 <bread+0xb6>
    iderw(b);
8010017a:	83 ec 0c             	sub    $0xc,%esp
8010017d:	53                   	push   %ebx
8010017e:	e8 4d 20 00 00       	call   801021d0 <iderw>
80100183:	83 c4 10             	add    $0x10,%esp
  }
  return b;
}
80100186:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100189:	89 d8                	mov    %ebx,%eax
8010018b:	5b                   	pop    %ebx
8010018c:	5e                   	pop    %esi
8010018d:	5f                   	pop    %edi
8010018e:	5d                   	pop    %ebp
8010018f:	c3                   	ret    
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100190:	83 ec 0c             	sub    $0xc,%esp
80100193:	68 0e 70 10 80       	push   $0x8010700e
80100198:	e8 d3 01 00 00       	call   80100370 <panic>
8010019d:	8d 76 00             	lea    0x0(%esi),%esi

801001a0 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001a0:	55                   	push   %ebp
801001a1:	89 e5                	mov    %esp,%ebp
801001a3:	53                   	push   %ebx
801001a4:	83 ec 10             	sub    $0x10,%esp
801001a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001aa:	8d 43 0c             	lea    0xc(%ebx),%eax
801001ad:	50                   	push   %eax
801001ae:	e8 fd 3f 00 00       	call   801041b0 <holdingsleep>
801001b3:	83 c4 10             	add    $0x10,%esp
801001b6:	85 c0                	test   %eax,%eax
801001b8:	74 0f                	je     801001c9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ba:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001bd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c3:	c9                   	leave  
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
801001c4:	e9 07 20 00 00       	jmp    801021d0 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
801001c9:	83 ec 0c             	sub    $0xc,%esp
801001cc:	68 1f 70 10 80       	push   $0x8010701f
801001d1:	e8 9a 01 00 00       	call   80100370 <panic>
801001d6:	8d 76 00             	lea    0x0(%esi),%esi
801001d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801001e0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001e0:	55                   	push   %ebp
801001e1:	89 e5                	mov    %esp,%ebp
801001e3:	56                   	push   %esi
801001e4:	53                   	push   %ebx
801001e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001e8:	83 ec 0c             	sub    $0xc,%esp
801001eb:	8d 73 0c             	lea    0xc(%ebx),%esi
801001ee:	56                   	push   %esi
801001ef:	e8 bc 3f 00 00       	call   801041b0 <holdingsleep>
801001f4:	83 c4 10             	add    $0x10,%esp
801001f7:	85 c0                	test   %eax,%eax
801001f9:	74 66                	je     80100261 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 6c 3f 00 00       	call   80104170 <releasesleep>

  acquire(&bcache.lock);
80100204:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010020b:	e8 d0 40 00 00       	call   801042e0 <acquire>
  b->refcnt--;
80100210:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100213:	83 c4 10             	add    $0x10,%esp
    panic("brelse");

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;
80100216:	83 e8 01             	sub    $0x1,%eax
  if (b->refcnt == 0) {
80100219:	85 c0                	test   %eax,%eax
    panic("brelse");

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;
8010021b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010021e:	75 2f                	jne    8010024f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100220:	8b 43 54             	mov    0x54(%ebx),%eax
80100223:	8b 53 50             	mov    0x50(%ebx),%edx
80100226:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100229:	8b 43 50             	mov    0x50(%ebx),%eax
8010022c:	8b 53 54             	mov    0x54(%ebx),%edx
8010022f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100232:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
    b->prev = &bcache.head;
80100237:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
8010023e:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
80100241:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100246:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100249:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
8010024f:	c7 45 08 c0 b5 10 80 	movl   $0x8010b5c0,0x8(%ebp)
}
80100256:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100259:	5b                   	pop    %ebx
8010025a:	5e                   	pop    %esi
8010025b:	5d                   	pop    %ebp
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
8010025c:	e9 9f 41 00 00       	jmp    80104400 <release>
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
80100261:	83 ec 0c             	sub    $0xc,%esp
80100264:	68 26 70 10 80       	push   $0x80107026
80100269:	e8 02 01 00 00       	call   80100370 <panic>
8010026e:	66 90                	xchg   %ax,%ax

80100270 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100270:	55                   	push   %ebp
80100271:	89 e5                	mov    %esp,%ebp
80100273:	57                   	push   %edi
80100274:	56                   	push   %esi
80100275:	53                   	push   %ebx
80100276:	83 ec 28             	sub    $0x28,%esp
80100279:	8b 7d 08             	mov    0x8(%ebp),%edi
8010027c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010027f:	57                   	push   %edi
80100280:	e8 ab 15 00 00       	call   80101830 <iunlock>
  target = n;
  acquire(&cons.lock);
80100285:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028c:	e8 4f 40 00 00       	call   801042e0 <acquire>
  while(n > 0){
80100291:	8b 5d 10             	mov    0x10(%ebp),%ebx
80100294:	83 c4 10             	add    $0x10,%esp
80100297:	31 c0                	xor    %eax,%eax
80100299:	85 db                	test   %ebx,%ebx
8010029b:	0f 8e 9a 00 00 00    	jle    8010033b <consoleread+0xcb>
    while(input.r == input.w){
801002a1:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801002a6:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002ac:	74 24                	je     801002d2 <consoleread+0x62>
801002ae:	eb 58                	jmp    80100308 <consoleread+0x98>
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b0:	83 ec 08             	sub    $0x8,%esp
801002b3:	68 20 a5 10 80       	push   $0x8010a520
801002b8:	68 a0 ff 10 80       	push   $0x8010ffa0
801002bd:	e8 ae 3a 00 00       	call   80103d70 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801002c2:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801002c7:	83 c4 10             	add    $0x10,%esp
801002ca:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002d0:	75 36                	jne    80100308 <consoleread+0x98>
      if(myproc()->killed){
801002d2:	e8 e9 34 00 00       	call   801037c0 <myproc>
801002d7:	8b 40 24             	mov    0x24(%eax),%eax
801002da:	85 c0                	test   %eax,%eax
801002dc:	74 d2                	je     801002b0 <consoleread+0x40>
        release(&cons.lock);
801002de:	83 ec 0c             	sub    $0xc,%esp
801002e1:	68 20 a5 10 80       	push   $0x8010a520
801002e6:	e8 15 41 00 00       	call   80104400 <release>
        ilock(ip);
801002eb:	89 3c 24             	mov    %edi,(%esp)
801002ee:	e8 5d 14 00 00       	call   80101750 <ilock>
        return -1;
801002f3:	83 c4 10             	add    $0x10,%esp
801002f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002fe:	5b                   	pop    %ebx
801002ff:	5e                   	pop    %esi
80100300:	5f                   	pop    %edi
80100301:	5d                   	pop    %ebp
80100302:	c3                   	ret    
80100303:	90                   	nop
80100304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100308:	8d 50 01             	lea    0x1(%eax),%edx
8010030b:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
80100311:	89 c2                	mov    %eax,%edx
80100313:	83 e2 7f             	and    $0x7f,%edx
80100316:	0f be 92 20 ff 10 80 	movsbl -0x7fef00e0(%edx),%edx
    if(c == C('D')){  // EOF
8010031d:	83 fa 04             	cmp    $0x4,%edx
80100320:	74 39                	je     8010035b <consoleread+0xeb>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
80100322:	83 c6 01             	add    $0x1,%esi
    --n;
80100325:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100328:	83 fa 0a             	cmp    $0xa,%edx
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
8010032b:	88 56 ff             	mov    %dl,-0x1(%esi)
    --n;
    if(c == '\n')
8010032e:	74 35                	je     80100365 <consoleread+0xf5>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100330:	85 db                	test   %ebx,%ebx
80100332:	0f 85 69 ff ff ff    	jne    801002a1 <consoleread+0x31>
80100338:	8b 45 10             	mov    0x10(%ebp),%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
8010033b:	83 ec 0c             	sub    $0xc,%esp
8010033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100341:	68 20 a5 10 80       	push   $0x8010a520
80100346:	e8 b5 40 00 00       	call   80104400 <release>
  ilock(ip);
8010034b:	89 3c 24             	mov    %edi,(%esp)
8010034e:	e8 fd 13 00 00       	call   80101750 <ilock>

  return target - n;
80100353:	83 c4 10             	add    $0x10,%esp
80100356:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100359:	eb a0                	jmp    801002fb <consoleread+0x8b>
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
8010035b:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010035e:	76 05                	jbe    80100365 <consoleread+0xf5>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100360:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
80100365:	8b 45 10             	mov    0x10(%ebp),%eax
80100368:	29 d8                	sub    %ebx,%eax
8010036a:	eb cf                	jmp    8010033b <consoleread+0xcb>
8010036c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100370 <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
80100370:	55                   	push   %ebp
80100371:	89 e5                	mov    %esp,%ebp
80100373:	56                   	push   %esi
80100374:	53                   	push   %ebx
80100375:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100378:	fa                   	cli    
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
80100379:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100380:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
80100383:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100386:	8d 75 f8             	lea    -0x8(%ebp),%esi
  uint pcs[10];

  cli();
  cons.locking = 0;
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100389:	e8 a2 23 00 00       	call   80102730 <lapicid>
8010038e:	83 ec 08             	sub    $0x8,%esp
80100391:	50                   	push   %eax
80100392:	68 2d 70 10 80       	push   $0x8010702d
80100397:	e8 c4 02 00 00       	call   80100660 <cprintf>
  cprintf(s);
8010039c:	58                   	pop    %eax
8010039d:	ff 75 08             	pushl  0x8(%ebp)
801003a0:	e8 bb 02 00 00       	call   80100660 <cprintf>
  cprintf("\n");
801003a5:	c7 04 24 85 79 10 80 	movl   $0x80107985,(%esp)
801003ac:	e8 af 02 00 00       	call   80100660 <cprintf>
  getcallerpcs(&s, pcs);
801003b1:	5a                   	pop    %edx
801003b2:	8d 45 08             	lea    0x8(%ebp),%eax
801003b5:	59                   	pop    %ecx
801003b6:	53                   	push   %ebx
801003b7:	50                   	push   %eax
801003b8:	e8 43 3e 00 00       	call   80104200 <getcallerpcs>
801003bd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
801003c0:	83 ec 08             	sub    $0x8,%esp
801003c3:	ff 33                	pushl  (%ebx)
801003c5:	83 c3 04             	add    $0x4,%ebx
801003c8:	68 41 70 10 80       	push   $0x80107041
801003cd:	e8 8e 02 00 00       	call   80100660 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801003d2:	83 c4 10             	add    $0x10,%esp
801003d5:	39 f3                	cmp    %esi,%ebx
801003d7:	75 e7                	jne    801003c0 <panic+0x50>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801003d9:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003e0:	00 00 00 
801003e3:	eb fe                	jmp    801003e3 <panic+0x73>
801003e5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801003e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801003f0 <consputc>:
}

void
consputc(int c)
{
  if(panicked){
801003f0:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
801003f6:	85 d2                	test   %edx,%edx
801003f8:	74 06                	je     80100400 <consputc+0x10>
801003fa:	fa                   	cli    
801003fb:	eb fe                	jmp    801003fb <consputc+0xb>
801003fd:	8d 76 00             	lea    0x0(%esi),%esi
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c3                	mov    %eax,%ebx
80100408:	83 ec 0c             	sub    $0xc,%esp
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 b8 00 00 00    	je     801004ce <consputc+0xde>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 31 57 00 00       	call   80105b50 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 fa                	mov    %edi,%edx
8010042e:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100434:	89 f2                	mov    %esi,%edx
80100436:	ec                   	in     (%dx),%al
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 fa                	mov    %edi,%edx
8010043c:	c1 e0 08             	shl    $0x8,%eax
8010043f:	89 c1                	mov    %eax,%ecx
80100441:	b8 0f 00 00 00       	mov    $0xf,%eax
80100446:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100447:	89 f2                	mov    %esi,%edx
80100449:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
8010044a:	0f b6 c0             	movzbl %al,%eax
8010044d:	09 c8                	or     %ecx,%eax

  if(c == '\n')
8010044f:	83 fb 0a             	cmp    $0xa,%ebx
80100452:	0f 84 0b 01 00 00    	je     80100563 <consputc+0x173>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
80100458:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010045e:	0f 84 e6 00 00 00    	je     8010054a <consputc+0x15a>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100464:	0f b6 d3             	movzbl %bl,%edx
80100467:	8d 78 01             	lea    0x1(%eax),%edi
8010046a:	80 ce 07             	or     $0x7,%dh
8010046d:	66 89 94 00 00 80 0b 	mov    %dx,-0x7ff48000(%eax,%eax,1)
80100474:	80 

  if(pos < 0 || pos > 25*80)
80100475:	81 ff d0 07 00 00    	cmp    $0x7d0,%edi
8010047b:	0f 8f bc 00 00 00    	jg     8010053d <consputc+0x14d>
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
80100481:	81 ff 7f 07 00 00    	cmp    $0x77f,%edi
80100487:	7f 6f                	jg     801004f8 <consputc+0x108>
80100489:	89 f8                	mov    %edi,%eax
8010048b:	8d 8c 3f 00 80 0b 80 	lea    -0x7ff48000(%edi,%edi,1),%ecx
80100492:	89 fb                	mov    %edi,%ebx
80100494:	c1 e8 08             	shr    $0x8,%eax
80100497:	89 c6                	mov    %eax,%esi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100499:	bf d4 03 00 00       	mov    $0x3d4,%edi
8010049e:	b8 0e 00 00 00       	mov    $0xe,%eax
801004a3:	89 fa                	mov    %edi,%edx
801004a5:	ee                   	out    %al,(%dx)
801004a6:	ba d5 03 00 00       	mov    $0x3d5,%edx
801004ab:	89 f0                	mov    %esi,%eax
801004ad:	ee                   	out    %al,(%dx)
801004ae:	b8 0f 00 00 00       	mov    $0xf,%eax
801004b3:	89 fa                	mov    %edi,%edx
801004b5:	ee                   	out    %al,(%dx)
801004b6:	ba d5 03 00 00       	mov    $0x3d5,%edx
801004bb:	89 d8                	mov    %ebx,%eax
801004bd:	ee                   	out    %al,(%dx)

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
801004be:	b8 20 07 00 00       	mov    $0x720,%eax
801004c3:	66 89 01             	mov    %ax,(%ecx)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
801004c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c9:	5b                   	pop    %ebx
801004ca:	5e                   	pop    %esi
801004cb:	5f                   	pop    %edi
801004cc:	5d                   	pop    %ebp
801004cd:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004ce:	83 ec 0c             	sub    $0xc,%esp
801004d1:	6a 08                	push   $0x8
801004d3:	e8 78 56 00 00       	call   80105b50 <uartputc>
801004d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004df:	e8 6c 56 00 00       	call   80105b50 <uartputc>
801004e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004eb:	e8 60 56 00 00       	call   80105b50 <uartputc>
801004f0:	83 c4 10             	add    $0x10,%esp
801004f3:	e9 2a ff ff ff       	jmp    80100422 <consputc+0x32>

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004f8:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
801004fb:	8d 5f b0             	lea    -0x50(%edi),%ebx

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004fe:	68 60 0e 00 00       	push   $0xe60
80100503:	68 a0 80 0b 80       	push   $0x800b80a0
80100508:	68 00 80 0b 80       	push   $0x800b8000
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010050d:	8d b4 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%esi

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100514:	e8 e7 3f 00 00       	call   80104500 <memmove>
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100519:	b8 80 07 00 00       	mov    $0x780,%eax
8010051e:	83 c4 0c             	add    $0xc,%esp
80100521:	29 d8                	sub    %ebx,%eax
80100523:	01 c0                	add    %eax,%eax
80100525:	50                   	push   %eax
80100526:	6a 00                	push   $0x0
80100528:	56                   	push   %esi
80100529:	e8 22 3f 00 00       	call   80104450 <memset>
8010052e:	89 f1                	mov    %esi,%ecx
80100530:	83 c4 10             	add    $0x10,%esp
80100533:	be 07 00 00 00       	mov    $0x7,%esi
80100538:	e9 5c ff ff ff       	jmp    80100499 <consputc+0xa9>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
8010053d:	83 ec 0c             	sub    $0xc,%esp
80100540:	68 45 70 10 80       	push   $0x80107045
80100545:	e8 26 fe ff ff       	call   80100370 <panic>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
8010054a:	85 c0                	test   %eax,%eax
8010054c:	8d 78 ff             	lea    -0x1(%eax),%edi
8010054f:	0f 85 20 ff ff ff    	jne    80100475 <consputc+0x85>
80100555:	b9 00 80 0b 80       	mov    $0x800b8000,%ecx
8010055a:	31 db                	xor    %ebx,%ebx
8010055c:	31 f6                	xor    %esi,%esi
8010055e:	e9 36 ff ff ff       	jmp    80100499 <consputc+0xa9>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
80100563:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100568:	f7 ea                	imul   %edx
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	c1 e8 05             	shr    $0x5,%eax
8010056f:	8d 04 80             	lea    (%eax,%eax,4),%eax
80100572:	c1 e0 04             	shl    $0x4,%eax
80100575:	8d 78 50             	lea    0x50(%eax),%edi
80100578:	e9 f8 fe ff ff       	jmp    80100475 <consputc+0x85>
8010057d:	8d 76 00             	lea    0x0(%esi),%esi

80100580 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100580:	55                   	push   %ebp
80100581:	89 e5                	mov    %esp,%ebp
80100583:	57                   	push   %edi
80100584:	56                   	push   %esi
80100585:	53                   	push   %ebx
80100586:	89 d6                	mov    %edx,%esi
80100588:	83 ec 2c             	sub    $0x2c,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010058b:	85 c9                	test   %ecx,%ecx
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010058d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100590:	74 0c                	je     8010059e <printint+0x1e>
80100592:	89 c7                	mov    %eax,%edi
80100594:	c1 ef 1f             	shr    $0x1f,%edi
80100597:	85 c0                	test   %eax,%eax
80100599:	89 7d d4             	mov    %edi,-0x2c(%ebp)
8010059c:	78 51                	js     801005ef <printint+0x6f>
    x = -xx;
  else
    x = xx;

  i = 0;
8010059e:	31 ff                	xor    %edi,%edi
801005a0:	8d 5d d7             	lea    -0x29(%ebp),%ebx
801005a3:	eb 05                	jmp    801005aa <printint+0x2a>
801005a5:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
801005a8:	89 cf                	mov    %ecx,%edi
801005aa:	31 d2                	xor    %edx,%edx
801005ac:	8d 4f 01             	lea    0x1(%edi),%ecx
801005af:	f7 f6                	div    %esi
801005b1:	0f b6 92 70 70 10 80 	movzbl -0x7fef8f90(%edx),%edx
  }while((x /= base) != 0);
801005b8:	85 c0                	test   %eax,%eax
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
801005ba:	88 14 0b             	mov    %dl,(%ebx,%ecx,1)
  }while((x /= base) != 0);
801005bd:	75 e9                	jne    801005a8 <printint+0x28>

  if(sign)
801005bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801005c2:	85 c0                	test   %eax,%eax
801005c4:	74 08                	je     801005ce <printint+0x4e>
    buf[i++] = '-';
801005c6:	c6 44 0d d8 2d       	movb   $0x2d,-0x28(%ebp,%ecx,1)
801005cb:	8d 4f 02             	lea    0x2(%edi),%ecx
801005ce:	8d 74 0d d7          	lea    -0x29(%ebp,%ecx,1),%esi
801005d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  while(--i >= 0)
    consputc(buf[i]);
801005d8:	0f be 06             	movsbl (%esi),%eax
801005db:	83 ee 01             	sub    $0x1,%esi
801005de:	e8 0d fe ff ff       	call   801003f0 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801005e3:	39 de                	cmp    %ebx,%esi
801005e5:	75 f1                	jne    801005d8 <printint+0x58>
    consputc(buf[i]);
}
801005e7:	83 c4 2c             	add    $0x2c,%esp
801005ea:	5b                   	pop    %ebx
801005eb:	5e                   	pop    %esi
801005ec:	5f                   	pop    %edi
801005ed:	5d                   	pop    %ebp
801005ee:	c3                   	ret    
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
801005ef:	f7 d8                	neg    %eax
801005f1:	eb ab                	jmp    8010059e <printint+0x1e>
801005f3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801005f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100600 <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100600:	55                   	push   %ebp
80100601:	89 e5                	mov    %esp,%ebp
80100603:	57                   	push   %edi
80100604:	56                   	push   %esi
80100605:	53                   	push   %ebx
80100606:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100609:	ff 75 08             	pushl  0x8(%ebp)
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
8010060c:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
8010060f:	e8 1c 12 00 00       	call   80101830 <iunlock>
  acquire(&cons.lock);
80100614:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010061b:	e8 c0 3c 00 00       	call   801042e0 <acquire>
80100620:	8b 7d 0c             	mov    0xc(%ebp),%edi
  for(i = 0; i < n; i++)
80100623:	83 c4 10             	add    $0x10,%esp
80100626:	85 f6                	test   %esi,%esi
80100628:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
8010062b:	7e 12                	jle    8010063f <consolewrite+0x3f>
8010062d:	8d 76 00             	lea    0x0(%esi),%esi
    consputc(buf[i] & 0xff);
80100630:	0f b6 07             	movzbl (%edi),%eax
80100633:	83 c7 01             	add    $0x1,%edi
80100636:	e8 b5 fd ff ff       	call   801003f0 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
8010063b:	39 df                	cmp    %ebx,%edi
8010063d:	75 f1                	jne    80100630 <consolewrite+0x30>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
8010063f:	83 ec 0c             	sub    $0xc,%esp
80100642:	68 20 a5 10 80       	push   $0x8010a520
80100647:	e8 b4 3d 00 00       	call   80104400 <release>
  ilock(ip);
8010064c:	58                   	pop    %eax
8010064d:	ff 75 08             	pushl  0x8(%ebp)
80100650:	e8 fb 10 00 00       	call   80101750 <ilock>

  return n;
}
80100655:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100658:	89 f0                	mov    %esi,%eax
8010065a:	5b                   	pop    %ebx
8010065b:	5e                   	pop    %esi
8010065c:	5f                   	pop    %edi
8010065d:	5d                   	pop    %ebp
8010065e:	c3                   	ret    
8010065f:	90                   	nop

80100660 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100660:	55                   	push   %ebp
80100661:	89 e5                	mov    %esp,%ebp
80100663:	57                   	push   %edi
80100664:	56                   	push   %esi
80100665:	53                   	push   %ebx
80100666:	83 ec 1c             	sub    $0x1c,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100669:	a1 54 a5 10 80       	mov    0x8010a554,%eax
  if(locking)
8010066e:	85 c0                	test   %eax,%eax
{
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100670:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
80100673:	0f 85 47 01 00 00    	jne    801007c0 <cprintf+0x160>
    acquire(&cons.lock);

  if (fmt == 0)
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	85 c0                	test   %eax,%eax
8010067e:	89 c1                	mov    %eax,%ecx
80100680:	0f 84 4f 01 00 00    	je     801007d5 <cprintf+0x175>
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100686:	0f b6 00             	movzbl (%eax),%eax
80100689:	31 db                	xor    %ebx,%ebx
8010068b:	8d 75 0c             	lea    0xc(%ebp),%esi
8010068e:	89 cf                	mov    %ecx,%edi
80100690:	85 c0                	test   %eax,%eax
80100692:	75 55                	jne    801006e9 <cprintf+0x89>
80100694:	eb 68                	jmp    801006fe <cprintf+0x9e>
80100696:	8d 76 00             	lea    0x0(%esi),%esi
80100699:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if(c != '%'){
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
801006a0:	83 c3 01             	add    $0x1,%ebx
801006a3:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
    if(c == 0)
801006a7:	85 d2                	test   %edx,%edx
801006a9:	74 53                	je     801006fe <cprintf+0x9e>
      break;
    switch(c){
801006ab:	83 fa 70             	cmp    $0x70,%edx
801006ae:	74 7a                	je     8010072a <cprintf+0xca>
801006b0:	7f 6e                	jg     80100720 <cprintf+0xc0>
801006b2:	83 fa 25             	cmp    $0x25,%edx
801006b5:	0f 84 ad 00 00 00    	je     80100768 <cprintf+0x108>
801006bb:	83 fa 64             	cmp    $0x64,%edx
801006be:	0f 85 84 00 00 00    	jne    80100748 <cprintf+0xe8>
    case 'd':
      printint(*argp++, 10, 1);
801006c4:	8d 46 04             	lea    0x4(%esi),%eax
801006c7:	b9 01 00 00 00       	mov    $0x1,%ecx
801006cc:	ba 0a 00 00 00       	mov    $0xa,%edx
801006d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006d4:	8b 06                	mov    (%esi),%eax
801006d6:	e8 a5 fe ff ff       	call   80100580 <printint>
801006db:	8b 75 e4             	mov    -0x1c(%ebp),%esi

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006de:	83 c3 01             	add    $0x1,%ebx
801006e1:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801006e5:	85 c0                	test   %eax,%eax
801006e7:	74 15                	je     801006fe <cprintf+0x9e>
    if(c != '%'){
801006e9:	83 f8 25             	cmp    $0x25,%eax
801006ec:	74 b2                	je     801006a0 <cprintf+0x40>
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
801006ee:	e8 fd fc ff ff       	call   801003f0 <consputc>

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006f3:	83 c3 01             	add    $0x1,%ebx
801006f6:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801006fa:	85 c0                	test   %eax,%eax
801006fc:	75 eb                	jne    801006e9 <cprintf+0x89>
      consputc(c);
      break;
    }
  }

  if(locking)
801006fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100701:	85 c0                	test   %eax,%eax
80100703:	74 10                	je     80100715 <cprintf+0xb5>
    release(&cons.lock);
80100705:	83 ec 0c             	sub    $0xc,%esp
80100708:	68 20 a5 10 80       	push   $0x8010a520
8010070d:	e8 ee 3c 00 00       	call   80104400 <release>
80100712:	83 c4 10             	add    $0x10,%esp
}
80100715:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100718:	5b                   	pop    %ebx
80100719:	5e                   	pop    %esi
8010071a:	5f                   	pop    %edi
8010071b:	5d                   	pop    %ebp
8010071c:	c3                   	ret    
8010071d:	8d 76 00             	lea    0x0(%esi),%esi
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
80100720:	83 fa 73             	cmp    $0x73,%edx
80100723:	74 5b                	je     80100780 <cprintf+0x120>
80100725:	83 fa 78             	cmp    $0x78,%edx
80100728:	75 1e                	jne    80100748 <cprintf+0xe8>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010072a:	8d 46 04             	lea    0x4(%esi),%eax
8010072d:	31 c9                	xor    %ecx,%ecx
8010072f:	ba 10 00 00 00       	mov    $0x10,%edx
80100734:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100737:	8b 06                	mov    (%esi),%eax
80100739:	e8 42 fe ff ff       	call   80100580 <printint>
8010073e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
      break;
80100741:	eb 9b                	jmp    801006de <cprintf+0x7e>
80100743:	90                   	nop
80100744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100748:	b8 25 00 00 00       	mov    $0x25,%eax
8010074d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100750:	e8 9b fc ff ff       	call   801003f0 <consputc>
      consputc(c);
80100755:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80100758:	89 d0                	mov    %edx,%eax
8010075a:	e8 91 fc ff ff       	call   801003f0 <consputc>
      break;
8010075f:	e9 7a ff ff ff       	jmp    801006de <cprintf+0x7e>
80100764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
80100768:	b8 25 00 00 00       	mov    $0x25,%eax
8010076d:	e8 7e fc ff ff       	call   801003f0 <consputc>
80100772:	e9 7c ff ff ff       	jmp    801006f3 <cprintf+0x93>
80100777:	89 f6                	mov    %esi,%esi
80100779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
80100780:	8d 46 04             	lea    0x4(%esi),%eax
80100783:	8b 36                	mov    (%esi),%esi
80100785:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        s = "(null)";
80100788:	b8 58 70 10 80       	mov    $0x80107058,%eax
8010078d:	85 f6                	test   %esi,%esi
8010078f:	0f 44 f0             	cmove  %eax,%esi
      for(; *s; s++)
80100792:	0f be 06             	movsbl (%esi),%eax
80100795:	84 c0                	test   %al,%al
80100797:	74 16                	je     801007af <cprintf+0x14f>
80100799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801007a0:	83 c6 01             	add    $0x1,%esi
        consputc(*s);
801007a3:	e8 48 fc ff ff       	call   801003f0 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801007a8:	0f be 06             	movsbl (%esi),%eax
801007ab:	84 c0                	test   %al,%al
801007ad:	75 f1                	jne    801007a0 <cprintf+0x140>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
801007af:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801007b2:	e9 27 ff ff ff       	jmp    801006de <cprintf+0x7e>
801007b7:	89 f6                	mov    %esi,%esi
801007b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
801007c0:	83 ec 0c             	sub    $0xc,%esp
801007c3:	68 20 a5 10 80       	push   $0x8010a520
801007c8:	e8 13 3b 00 00       	call   801042e0 <acquire>
801007cd:	83 c4 10             	add    $0x10,%esp
801007d0:	e9 a4 fe ff ff       	jmp    80100679 <cprintf+0x19>

  if (fmt == 0)
    panic("null fmt");
801007d5:	83 ec 0c             	sub    $0xc,%esp
801007d8:	68 5f 70 10 80       	push   $0x8010705f
801007dd:	e8 8e fb ff ff       	call   80100370 <panic>
801007e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801007e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801007f0 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f0:	55                   	push   %ebp
801007f1:	89 e5                	mov    %esp,%ebp
801007f3:	57                   	push   %edi
801007f4:	56                   	push   %esi
801007f5:	53                   	push   %ebx
  int c, doprocdump = 0;
801007f6:	31 f6                	xor    %esi,%esi

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f8:	83 ec 18             	sub    $0x18,%esp
801007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int c, doprocdump = 0;

  acquire(&cons.lock);
801007fe:	68 20 a5 10 80       	push   $0x8010a520
80100803:	e8 d8 3a 00 00       	call   801042e0 <acquire>
  while((c = getc()) >= 0){
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	90                   	nop
8010080c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100810:	ff d3                	call   *%ebx
80100812:	85 c0                	test   %eax,%eax
80100814:	89 c7                	mov    %eax,%edi
80100816:	78 48                	js     80100860 <consoleintr+0x70>
    switch(c){
80100818:	83 ff 10             	cmp    $0x10,%edi
8010081b:	0f 84 3f 01 00 00    	je     80100960 <consoleintr+0x170>
80100821:	7e 5d                	jle    80100880 <consoleintr+0x90>
80100823:	83 ff 15             	cmp    $0x15,%edi
80100826:	0f 84 dc 00 00 00    	je     80100908 <consoleintr+0x118>
8010082c:	83 ff 7f             	cmp    $0x7f,%edi
8010082f:	75 54                	jne    80100885 <consoleintr+0x95>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100831:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100836:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010083c:	74 d2                	je     80100810 <consoleintr+0x20>
        input.e--;
8010083e:	83 e8 01             	sub    $0x1,%eax
80100841:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100846:	b8 00 01 00 00       	mov    $0x100,%eax
8010084b:	e8 a0 fb ff ff       	call   801003f0 <consputc>
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100850:	ff d3                	call   *%ebx
80100852:	85 c0                	test   %eax,%eax
80100854:	89 c7                	mov    %eax,%edi
80100856:	79 c0                	jns    80100818 <consoleintr+0x28>
80100858:	90                   	nop
80100859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	68 20 a5 10 80       	push   $0x8010a520
80100868:	e8 93 3b 00 00       	call   80104400 <release>
  if(doprocdump) {
8010086d:	83 c4 10             	add    $0x10,%esp
80100870:	85 f6                	test   %esi,%esi
80100872:	0f 85 f8 00 00 00    	jne    80100970 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100878:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010087b:	5b                   	pop    %ebx
8010087c:	5e                   	pop    %esi
8010087d:	5f                   	pop    %edi
8010087e:	5d                   	pop    %ebp
8010087f:	c3                   	ret    
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
80100880:	83 ff 08             	cmp    $0x8,%edi
80100883:	74 ac                	je     80100831 <consoleintr+0x41>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100885:	85 ff                	test   %edi,%edi
80100887:	74 87                	je     80100810 <consoleintr+0x20>
80100889:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010088e:	89 c2                	mov    %eax,%edx
80100890:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
80100896:	83 fa 7f             	cmp    $0x7f,%edx
80100899:	0f 87 71 ff ff ff    	ja     80100810 <consoleintr+0x20>
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
8010089f:	8d 50 01             	lea    0x1(%eax),%edx
801008a2:	83 e0 7f             	and    $0x7f,%eax
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
801008a5:	83 ff 0d             	cmp    $0xd,%edi
        input.buf[input.e++ % INPUT_BUF] = c;
801008a8:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
801008ae:	0f 84 c8 00 00 00    	je     8010097c <consoleintr+0x18c>
        input.buf[input.e++ % INPUT_BUF] = c;
801008b4:	89 f9                	mov    %edi,%ecx
801008b6:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
        consputc(c);
801008bc:	89 f8                	mov    %edi,%eax
801008be:	e8 2d fb ff ff       	call   801003f0 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c3:	83 ff 0a             	cmp    $0xa,%edi
801008c6:	0f 84 c1 00 00 00    	je     8010098d <consoleintr+0x19d>
801008cc:	83 ff 04             	cmp    $0x4,%edi
801008cf:	0f 84 b8 00 00 00    	je     8010098d <consoleintr+0x19d>
801008d5:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801008da:	83 e8 80             	sub    $0xffffff80,%eax
801008dd:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
801008e3:	0f 85 27 ff ff ff    	jne    80100810 <consoleintr+0x20>
          input.w = input.e;
          wakeup(&input.r);
801008e9:	83 ec 0c             	sub    $0xc,%esp
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
801008ec:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
801008f1:	68 a0 ff 10 80       	push   $0x8010ffa0
801008f6:	e8 25 36 00 00       	call   80103f20 <wakeup>
801008fb:	83 c4 10             	add    $0x10,%esp
801008fe:	e9 0d ff ff ff       	jmp    80100810 <consoleintr+0x20>
80100903:	90                   	nop
80100904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100908:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010090d:	39 05 a4 ff 10 80    	cmp    %eax,0x8010ffa4
80100913:	75 2b                	jne    80100940 <consoleintr+0x150>
80100915:	e9 f6 fe ff ff       	jmp    80100810 <consoleintr+0x20>
8010091a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100920:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100925:	b8 00 01 00 00       	mov    $0x100,%eax
8010092a:	e8 c1 fa ff ff       	call   801003f0 <consputc>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010092f:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100934:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010093a:	0f 84 d0 fe ff ff    	je     80100810 <consoleintr+0x20>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100940:	83 e8 01             	sub    $0x1,%eax
80100943:	89 c2                	mov    %eax,%edx
80100945:	83 e2 7f             	and    $0x7f,%edx
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100948:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
8010094f:	75 cf                	jne    80100920 <consoleintr+0x130>
80100951:	e9 ba fe ff ff       	jmp    80100810 <consoleintr+0x20>
80100956:	8d 76 00             	lea    0x0(%esi),%esi
80100959:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100960:	be 01 00 00 00       	mov    $0x1,%esi
80100965:	e9 a6 fe ff ff       	jmp    80100810 <consoleintr+0x20>
8010096a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100970:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100973:	5b                   	pop    %ebx
80100974:	5e                   	pop    %esi
80100975:	5f                   	pop    %edi
80100976:	5d                   	pop    %ebp
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
80100977:	e9 94 36 00 00       	jmp    80104010 <procdump>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
8010097c:	c6 80 20 ff 10 80 0a 	movb   $0xa,-0x7fef00e0(%eax)
        consputc(c);
80100983:	b8 0a 00 00 00       	mov    $0xa,%eax
80100988:	e8 63 fa ff ff       	call   801003f0 <consputc>
8010098d:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100992:	e9 52 ff ff ff       	jmp    801008e9 <consoleintr+0xf9>
80100997:	89 f6                	mov    %esi,%esi
80100999:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801009a0 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
801009a0:	55                   	push   %ebp
801009a1:	89 e5                	mov    %esp,%ebp
801009a3:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
801009a6:	68 68 70 10 80       	push   $0x80107068
801009ab:	68 20 a5 10 80       	push   $0x8010a520
801009b0:	e8 2b 38 00 00       	call   801041e0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
801009b5:	58                   	pop    %eax
801009b6:	5a                   	pop    %edx
801009b7:	6a 00                	push   $0x0
801009b9:	6a 01                	push   $0x1
void
consoleinit(void)
{
  initlock(&cons.lock, "console");

  devsw[CONSOLE].write = consolewrite;
801009bb:	c7 05 6c 09 11 80 00 	movl   $0x80100600,0x8011096c
801009c2:	06 10 80 
  devsw[CONSOLE].read = consoleread;
801009c5:	c7 05 68 09 11 80 70 	movl   $0x80100270,0x80110968
801009cc:	02 10 80 
  cons.locking = 1;
801009cf:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801009d6:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801009d9:	e8 a2 19 00 00       	call   80102380 <ioapicenable>
}
801009de:	83 c4 10             	add    $0x10,%esp
801009e1:	c9                   	leave  
801009e2:	c3                   	ret    

801009e3 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801009e3:	55                   	push   %ebp
801009e4:	89 e5                	mov    %esp,%ebp
801009e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801009ec:	e8 cf 2d 00 00       	call   801037c0 <myproc>
801009f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
801009f4:	e8 97 21 00 00       	call   80102b90 <begin_op>

  if((ip = namei(path)) == 0){
801009f9:	83 ec 0c             	sub    $0xc,%esp
801009fc:	ff 75 08             	pushl  0x8(%ebp)
801009ff:	e8 9c 15 00 00       	call   80101fa0 <namei>
80100a04:	83 c4 10             	add    $0x10,%esp
80100a07:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100a0a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100a0e:	75 1f                	jne    80100a2f <exec+0x4c>
    end_op();
80100a10:	e8 eb 21 00 00       	call   80102c00 <end_op>
    cprintf("exec: fail\n");
80100a15:	83 ec 0c             	sub    $0xc,%esp
80100a18:	68 81 70 10 80       	push   $0x80107081
80100a1d:	e8 3e fc ff ff       	call   80100660 <cprintf>
80100a22:	83 c4 10             	add    $0x10,%esp
    return -1;
80100a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a2a:	e9 f1 03 00 00       	jmp    80100e20 <exec+0x43d>
  }
  ilock(ip);
80100a2f:	83 ec 0c             	sub    $0xc,%esp
80100a32:	ff 75 d8             	pushl  -0x28(%ebp)
80100a35:	e8 16 0d 00 00       	call   80101750 <ilock>
80100a3a:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100a3d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100a44:	6a 34                	push   $0x34
80100a46:	6a 00                	push   $0x0
80100a48:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100a4e:	50                   	push   %eax
80100a4f:	ff 75 d8             	pushl  -0x28(%ebp)
80100a52:	e8 d9 0f 00 00       	call   80101a30 <readi>
80100a57:	83 c4 10             	add    $0x10,%esp
80100a5a:	83 f8 34             	cmp    $0x34,%eax
80100a5d:	0f 85 66 03 00 00    	jne    80100dc9 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100a63:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100a69:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100a6e:	0f 85 58 03 00 00    	jne    80100dcc <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100a74:	e8 67 62 00 00       	call   80106ce0 <setupkvm>
80100a79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100a7c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100a80:	0f 84 49 03 00 00    	je     80100dcf <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100a86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100a94:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100a9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100a9d:	e9 de 00 00 00       	jmp    80100b80 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100aa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100aa5:	6a 20                	push   $0x20
80100aa7:	50                   	push   %eax
80100aa8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100aae:	50                   	push   %eax
80100aaf:	ff 75 d8             	pushl  -0x28(%ebp)
80100ab2:	e8 79 0f 00 00       	call   80101a30 <readi>
80100ab7:	83 c4 10             	add    $0x10,%esp
80100aba:	83 f8 20             	cmp    $0x20,%eax
80100abd:	0f 85 0f 03 00 00    	jne    80100dd2 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ac3:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ac9:	83 f8 01             	cmp    $0x1,%eax
80100acc:	0f 85 a0 00 00 00    	jne    80100b72 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100ad2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100ad8:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100ade:	39 c2                	cmp    %eax,%edx
80100ae0:	0f 82 ef 02 00 00    	jb     80100dd5 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100ae6:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100aec:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100af2:	01 c2                	add    %eax,%edx
80100af4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100afa:	39 c2                	cmp    %eax,%edx
80100afc:	0f 82 d6 02 00 00    	jb     80100dd8 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100b02:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100b08:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100b0e:	01 d0                	add    %edx,%eax
80100b10:	83 ec 04             	sub    $0x4,%esp
80100b13:	50                   	push   %eax
80100b14:	ff 75 e0             	pushl  -0x20(%ebp)
80100b17:	ff 75 d4             	pushl  -0x2c(%ebp)
80100b1a:	e8 11 60 00 00       	call   80106b30 <allocuvm>
80100b1f:	83 c4 10             	add    $0x10,%esp
80100b22:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100b25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100b29:	0f 84 ac 02 00 00    	je     80100ddb <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100b2f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100b35:	25 ff 0f 00 00       	and    $0xfff,%eax
80100b3a:	85 c0                	test   %eax,%eax
80100b3c:	0f 85 9c 02 00 00    	jne    80100dde <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100b42:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100b48:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100b4e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	52                   	push   %edx
80100b58:	50                   	push   %eax
80100b59:	ff 75 d8             	pushl  -0x28(%ebp)
80100b5c:	51                   	push   %ecx
80100b5d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100b60:	e8 0b 5f 00 00       	call   80106a70 <loaduvm>
80100b65:	83 c4 20             	add    $0x20,%esp
80100b68:	85 c0                	test   %eax,%eax
80100b6a:	0f 88 71 02 00 00    	js     80100de1 <exec+0x3fe>
80100b70:	eb 01                	jmp    80100b73 <exec+0x190>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100b72:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100b77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b7a:	83 c0 20             	add    $0x20,%eax
80100b7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b80:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100b87:	0f b7 c0             	movzwl %ax,%eax
80100b8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100b8d:	0f 8f 0f ff ff ff    	jg     80100aa2 <exec+0xbf>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100b93:	83 ec 0c             	sub    $0xc,%esp
80100b96:	ff 75 d8             	pushl  -0x28(%ebp)
80100b99:	e8 42 0e 00 00       	call   801019e0 <iunlockput>
80100b9e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ba1:	e8 5a 20 00 00       	call   80102c00 <end_op>
  ip = 0;
80100ba6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100bb0:	05 ff 0f 00 00       	add    $0xfff,%eax
80100bb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100bba:	89 45 e0             	mov    %eax,-0x20(%ebp)

///////////
//PART 1 OF THE LAB
///////////
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE )) == 0)
80100bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100bc0:	05 00 20 00 00       	add    $0x2000,%eax
80100bc5:	83 ec 04             	sub    $0x4,%esp
80100bc8:	50                   	push   %eax
80100bc9:	ff 75 e0             	pushl  -0x20(%ebp)
80100bcc:	ff 75 d4             	pushl  -0x2c(%ebp)
80100bcf:	e8 5c 5f 00 00       	call   80106b30 <allocuvm>
80100bd4:	83 c4 10             	add    $0x10,%esp
80100bd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100bda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100bde:	0f 84 00 02 00 00    	je     80100de4 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100be4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100be7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100bec:	83 ec 08             	sub    $0x8,%esp
80100bef:	50                   	push   %eax
80100bf0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100bf3:	e8 88 61 00 00       	call   80106d80 <clearpteu>
80100bf8:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100bfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100bfe:	89 45 dc             	mov    %eax,-0x24(%ebp)
///////////
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100c01:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100c08:	e9 96 00 00 00       	jmp    80100ca3 <exec+0x2c0>
    if(argc >= MAXARG)
80100c0d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100c11:	0f 87 d0 01 00 00    	ja     80100de7 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100c17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100c1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100c21:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c24:	01 d0                	add    %edx,%eax
80100c26:	8b 00                	mov    (%eax),%eax
80100c28:	83 ec 0c             	sub    $0xc,%esp
80100c2b:	50                   	push   %eax
80100c2c:	e8 5f 3a 00 00       	call   80104690 <strlen>
80100c31:	83 c4 10             	add    $0x10,%esp
80100c34:	89 c2                	mov    %eax,%edx
80100c36:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100c39:	29 d0                	sub    %edx,%eax
80100c3b:	83 e8 01             	sub    $0x1,%eax
80100c3e:	83 e0 fc             	and    $0xfffffffc,%eax
80100c41:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100c47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c51:	01 d0                	add    %edx,%eax
80100c53:	8b 00                	mov    (%eax),%eax
80100c55:	83 ec 0c             	sub    $0xc,%esp
80100c58:	50                   	push   %eax
80100c59:	e8 32 3a 00 00       	call   80104690 <strlen>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 c0 01             	add    $0x1,%eax
80100c64:	89 c1                	mov    %eax,%ecx
80100c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100c69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100c70:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c73:	01 d0                	add    %edx,%eax
80100c75:	8b 00                	mov    (%eax),%eax
80100c77:	51                   	push   %ecx
80100c78:	50                   	push   %eax
80100c79:	ff 75 dc             	pushl  -0x24(%ebp)
80100c7c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7f:	e8 5c 62 00 00       	call   80106ee0 <copyout>
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	85 c0                	test   %eax,%eax
80100c89:	0f 88 5b 01 00 00    	js     80100dea <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100c8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100c92:	8d 50 03             	lea    0x3(%eax),%edx
80100c95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100c98:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  sp = sz;
///////////
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100c9f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ca6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100cad:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cb0:	01 d0                	add    %edx,%eax
80100cb2:	8b 00                	mov    (%eax),%eax
80100cb4:	85 c0                	test   %eax,%eax
80100cb6:	0f 85 51 ff ff ff    	jne    80100c0d <exec+0x22a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100cbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cbf:	83 c0 03             	add    $0x3,%eax
80100cc2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100cc9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ccd:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100cd4:	ff ff ff 
  ustack[1] = argc;
80100cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cda:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ce3:	83 c0 01             	add    $0x1,%eax
80100ce6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ced:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100cf0:	29 d0                	sub    %edx,%eax
80100cf2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cfb:	83 c0 04             	add    $0x4,%eax
80100cfe:	c1 e0 02             	shl    $0x2,%eax
80100d01:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d07:	83 c0 04             	add    $0x4,%eax
80100d0a:	c1 e0 02             	shl    $0x2,%eax
80100d0d:	50                   	push   %eax
80100d0e:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100d14:	50                   	push   %eax
80100d15:	ff 75 dc             	pushl  -0x24(%ebp)
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 c0 61 00 00       	call   80106ee0 <copyout>
80100d20:	83 c4 10             	add    $0x10,%esp
80100d23:	85 c0                	test   %eax,%eax
80100d25:	0f 88 c2 00 00 00    	js     80100ded <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80100d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100d37:	eb 17                	jmp    80100d50 <exec+0x36d>
    if(*s == '/')
80100d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d3c:	0f b6 00             	movzbl (%eax),%eax
80100d3f:	3c 2f                	cmp    $0x2f,%al
80100d41:	75 09                	jne    80100d4c <exec+0x369>
      last = s+1;
80100d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d46:	83 c0 01             	add    $0x1,%eax
80100d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100d4c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d53:	0f b6 00             	movzbl (%eax),%eax
80100d56:	84 c0                	test   %al,%al
80100d58:	75 df                	jne    80100d39 <exec+0x356>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100d5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d5d:	83 c0 6c             	add    $0x6c,%eax
80100d60:	83 ec 04             	sub    $0x4,%esp
80100d63:	6a 10                	push   $0x10
80100d65:	ff 75 f0             	pushl  -0x10(%ebp)
80100d68:	50                   	push   %eax
80100d69:	e8 e2 38 00 00       	call   80104650 <safestrcpy>
80100d6e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100d71:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d74:	8b 40 04             	mov    0x4(%eax),%eax
80100d77:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100d7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d7d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100d80:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100d83:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d86:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100d89:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100d8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d8e:	8b 40 18             	mov    0x18(%eax),%eax
80100d91:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100d97:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100d9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d9d:	8b 40 18             	mov    0x18(%eax),%eax
80100da0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100da3:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100da6:	83 ec 0c             	sub    $0xc,%esp
80100da9:	ff 75 d0             	pushl  -0x30(%ebp)
80100dac:	e8 2f 5b 00 00       	call   801068e0 <switchuvm>
80100db1:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100db4:	83 ec 0c             	sub    $0xc,%esp
80100db7:	ff 75 cc             	pushl  -0x34(%ebp)
80100dba:	e8 a1 5e 00 00       	call   80106c60 <freevm>
80100dbf:	83 c4 10             	add    $0x10,%esp
  return 0;
80100dc2:	b8 00 00 00 00       	mov    $0x0,%eax
80100dc7:	eb 57                	jmp    80100e20 <exec+0x43d>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80100dc9:	90                   	nop
80100dca:	eb 22                	jmp    80100dee <exec+0x40b>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100dcc:	90                   	nop
80100dcd:	eb 1f                	jmp    80100dee <exec+0x40b>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100dcf:	90                   	nop
80100dd0:	eb 1c                	jmp    80100dee <exec+0x40b>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100dd2:	90                   	nop
80100dd3:	eb 19                	jmp    80100dee <exec+0x40b>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100dd5:	90                   	nop
80100dd6:	eb 16                	jmp    80100dee <exec+0x40b>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80100dd8:	90                   	nop
80100dd9:	eb 13                	jmp    80100dee <exec+0x40b>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ddb:	90                   	nop
80100ddc:	eb 10                	jmp    80100dee <exec+0x40b>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80100dde:	90                   	nop
80100ddf:	eb 0d                	jmp    80100dee <exec+0x40b>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100de1:	90                   	nop
80100de2:	eb 0a                	jmp    80100dee <exec+0x40b>

///////////
//PART 1 OF THE LAB
///////////
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE )) == 0)
    goto bad;
80100de4:	90                   	nop
80100de5:	eb 07                	jmp    80100dee <exec+0x40b>
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100de7:	90                   	nop
80100de8:	eb 04                	jmp    80100dee <exec+0x40b>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100dea:	90                   	nop
80100deb:	eb 01                	jmp    80100dee <exec+0x40b>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ded:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100dee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100df2:	74 0e                	je     80100e02 <exec+0x41f>
    freevm(pgdir);
80100df4:	83 ec 0c             	sub    $0xc,%esp
80100df7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dfa:	e8 61 5e 00 00       	call   80106c60 <freevm>
80100dff:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100e02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e06:	74 13                	je     80100e1b <exec+0x438>
    iunlockput(ip);
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	ff 75 d8             	pushl  -0x28(%ebp)
80100e0e:	e8 cd 0b 00 00       	call   801019e0 <iunlockput>
80100e13:	83 c4 10             	add    $0x10,%esp
    end_op();
80100e16:	e8 e5 1d 00 00       	call   80102c00 <end_op>
  }
  return -1;
80100e1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e20:	c9                   	leave  
80100e21:	c3                   	ret    
80100e22:	66 90                	xchg   %ax,%ax
80100e24:	66 90                	xchg   %ax,%ax
80100e26:	66 90                	xchg   %ax,%ax
80100e28:	66 90                	xchg   %ax,%ax
80100e2a:	66 90                	xchg   %ax,%ax
80100e2c:	66 90                	xchg   %ax,%ax
80100e2e:	66 90                	xchg   %ax,%ax

80100e30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100e30:	55                   	push   %ebp
80100e31:	89 e5                	mov    %esp,%ebp
80100e33:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100e36:	68 8d 70 10 80       	push   $0x8010708d
80100e3b:	68 c0 ff 10 80       	push   $0x8010ffc0
80100e40:	e8 9b 33 00 00       	call   801041e0 <initlock>
}
80100e45:	83 c4 10             	add    $0x10,%esp
80100e48:	c9                   	leave  
80100e49:	c3                   	ret    
80100e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100e50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e50:	55                   	push   %ebp
80100e51:	89 e5                	mov    %esp,%ebp
80100e53:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e54:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
}

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e59:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100e5c:	68 c0 ff 10 80       	push   $0x8010ffc0
80100e61:	e8 7a 34 00 00       	call   801042e0 <acquire>
80100e66:	83 c4 10             	add    $0x10,%esp
80100e69:	eb 10                	jmp    80100e7b <filealloc+0x2b>
80100e6b:	90                   	nop
80100e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e70:	83 c3 18             	add    $0x18,%ebx
80100e73:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100e79:	74 25                	je     80100ea0 <filealloc+0x50>
    if(f->ref == 0){
80100e7b:	8b 43 04             	mov    0x4(%ebx),%eax
80100e7e:	85 c0                	test   %eax,%eax
80100e80:	75 ee                	jne    80100e70 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100e82:	83 ec 0c             	sub    $0xc,%esp
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
      f->ref = 1;
80100e85:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100e8c:	68 c0 ff 10 80       	push   $0x8010ffc0
80100e91:	e8 6a 35 00 00       	call   80104400 <release>
      return f;
80100e96:	89 d8                	mov    %ebx,%eax
80100e98:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e9e:	c9                   	leave  
80100e9f:	c3                   	ret    
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100ea0:	83 ec 0c             	sub    $0xc,%esp
80100ea3:	68 c0 ff 10 80       	push   $0x8010ffc0
80100ea8:	e8 53 35 00 00       	call   80104400 <release>
  return 0;
80100ead:	83 c4 10             	add    $0x10,%esp
80100eb0:	31 c0                	xor    %eax,%eax
}
80100eb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100eb5:	c9                   	leave  
80100eb6:	c3                   	ret    
80100eb7:	89 f6                	mov    %esi,%esi
80100eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100ec0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ec0:	55                   	push   %ebp
80100ec1:	89 e5                	mov    %esp,%ebp
80100ec3:	53                   	push   %ebx
80100ec4:	83 ec 10             	sub    $0x10,%esp
80100ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100eca:	68 c0 ff 10 80       	push   $0x8010ffc0
80100ecf:	e8 0c 34 00 00       	call   801042e0 <acquire>
  if(f->ref < 1)
80100ed4:	8b 43 04             	mov    0x4(%ebx),%eax
80100ed7:	83 c4 10             	add    $0x10,%esp
80100eda:	85 c0                	test   %eax,%eax
80100edc:	7e 1a                	jle    80100ef8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ede:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ee1:	83 ec 0c             	sub    $0xc,%esp
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
  f->ref++;
80100ee4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ee7:	68 c0 ff 10 80       	push   $0x8010ffc0
80100eec:	e8 0f 35 00 00       	call   80104400 <release>
  return f;
}
80100ef1:	89 d8                	mov    %ebx,%eax
80100ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ef6:	c9                   	leave  
80100ef7:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
80100ef8:	83 ec 0c             	sub    $0xc,%esp
80100efb:	68 94 70 10 80       	push   $0x80107094
80100f00:	e8 6b f4 ff ff       	call   80100370 <panic>
80100f05:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100f10 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100f10:	55                   	push   %ebp
80100f11:	89 e5                	mov    %esp,%ebp
80100f13:	57                   	push   %edi
80100f14:	56                   	push   %esi
80100f15:	53                   	push   %ebx
80100f16:	83 ec 28             	sub    $0x28,%esp
80100f19:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct file ff;

  acquire(&ftable.lock);
80100f1c:	68 c0 ff 10 80       	push   $0x8010ffc0
80100f21:	e8 ba 33 00 00       	call   801042e0 <acquire>
  if(f->ref < 1)
80100f26:	8b 47 04             	mov    0x4(%edi),%eax
80100f29:	83 c4 10             	add    $0x10,%esp
80100f2c:	85 c0                	test   %eax,%eax
80100f2e:	0f 8e 9b 00 00 00    	jle    80100fcf <fileclose+0xbf>
    panic("fileclose");
  if(--f->ref > 0){
80100f34:	83 e8 01             	sub    $0x1,%eax
80100f37:	85 c0                	test   %eax,%eax
80100f39:	89 47 04             	mov    %eax,0x4(%edi)
80100f3c:	74 1a                	je     80100f58 <fileclose+0x48>
    release(&ftable.lock);
80100f3e:	c7 45 08 c0 ff 10 80 	movl   $0x8010ffc0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f48:	5b                   	pop    %ebx
80100f49:	5e                   	pop    %esi
80100f4a:	5f                   	pop    %edi
80100f4b:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
80100f4c:	e9 af 34 00 00       	jmp    80104400 <release>
80100f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return;
  }
  ff = *f;
80100f58:	0f b6 47 09          	movzbl 0x9(%edi),%eax
80100f5c:	8b 1f                	mov    (%edi),%ebx
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f5e:	83 ec 0c             	sub    $0xc,%esp
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f61:	8b 77 0c             	mov    0xc(%edi),%esi
  f->ref = 0;
  f->type = FD_NONE;
80100f64:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f6a:	88 45 e7             	mov    %al,-0x19(%ebp)
80100f6d:	8b 47 10             	mov    0x10(%edi),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f70:	68 c0 ff 10 80       	push   $0x8010ffc0
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f78:	e8 83 34 00 00       	call   80104400 <release>

  if(ff.type == FD_PIPE)
80100f7d:	83 c4 10             	add    $0x10,%esp
80100f80:	83 fb 01             	cmp    $0x1,%ebx
80100f83:	74 13                	je     80100f98 <fileclose+0x88>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100f85:	83 fb 02             	cmp    $0x2,%ebx
80100f88:	74 26                	je     80100fb0 <fileclose+0xa0>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f8d:	5b                   	pop    %ebx
80100f8e:	5e                   	pop    %esi
80100f8f:	5f                   	pop    %edi
80100f90:	5d                   	pop    %ebp
80100f91:	c3                   	ret    
80100f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
80100f98:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100f9c:	83 ec 08             	sub    $0x8,%esp
80100f9f:	53                   	push   %ebx
80100fa0:	56                   	push   %esi
80100fa1:	e8 8a 23 00 00       	call   80103330 <pipeclose>
80100fa6:	83 c4 10             	add    $0x10,%esp
80100fa9:	eb df                	jmp    80100f8a <fileclose+0x7a>
80100fab:	90                   	nop
80100fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  else if(ff.type == FD_INODE){
    begin_op();
80100fb0:	e8 db 1b 00 00       	call   80102b90 <begin_op>
    iput(ff.ip);
80100fb5:	83 ec 0c             	sub    $0xc,%esp
80100fb8:	ff 75 e0             	pushl  -0x20(%ebp)
80100fbb:	e8 c0 08 00 00       	call   80101880 <iput>
    end_op();
80100fc0:	83 c4 10             	add    $0x10,%esp
  }
}
80100fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc6:	5b                   	pop    %ebx
80100fc7:	5e                   	pop    %esi
80100fc8:	5f                   	pop    %edi
80100fc9:	5d                   	pop    %ebp
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
80100fca:	e9 31 1c 00 00       	jmp    80102c00 <end_op>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
80100fcf:	83 ec 0c             	sub    $0xc,%esp
80100fd2:	68 9c 70 10 80       	push   $0x8010709c
80100fd7:	e8 94 f3 ff ff       	call   80100370 <panic>
80100fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100fe0 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	53                   	push   %ebx
80100fe4:	83 ec 04             	sub    $0x4,%esp
80100fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100fea:	83 3b 02             	cmpl   $0x2,(%ebx)
80100fed:	75 31                	jne    80101020 <filestat+0x40>
    ilock(f->ip);
80100fef:	83 ec 0c             	sub    $0xc,%esp
80100ff2:	ff 73 10             	pushl  0x10(%ebx)
80100ff5:	e8 56 07 00 00       	call   80101750 <ilock>
    stati(f->ip, st);
80100ffa:	58                   	pop    %eax
80100ffb:	5a                   	pop    %edx
80100ffc:	ff 75 0c             	pushl  0xc(%ebp)
80100fff:	ff 73 10             	pushl  0x10(%ebx)
80101002:	e8 f9 09 00 00       	call   80101a00 <stati>
    iunlock(f->ip);
80101007:	59                   	pop    %ecx
80101008:	ff 73 10             	pushl  0x10(%ebx)
8010100b:	e8 20 08 00 00       	call   80101830 <iunlock>
    return 0;
80101010:	83 c4 10             	add    $0x10,%esp
80101013:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80101015:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101018:	c9                   	leave  
80101019:	c3                   	ret    
8010101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
80101020:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101028:	c9                   	leave  
80101029:	c3                   	ret    
8010102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101030 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101030:	55                   	push   %ebp
80101031:	89 e5                	mov    %esp,%ebp
80101033:	57                   	push   %edi
80101034:	56                   	push   %esi
80101035:	53                   	push   %ebx
80101036:	83 ec 0c             	sub    $0xc,%esp
80101039:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010103c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010103f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101042:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101046:	74 60                	je     801010a8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101048:	8b 03                	mov    (%ebx),%eax
8010104a:	83 f8 01             	cmp    $0x1,%eax
8010104d:	74 41                	je     80101090 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010104f:	83 f8 02             	cmp    $0x2,%eax
80101052:	75 5b                	jne    801010af <fileread+0x7f>
    ilock(f->ip);
80101054:	83 ec 0c             	sub    $0xc,%esp
80101057:	ff 73 10             	pushl  0x10(%ebx)
8010105a:	e8 f1 06 00 00       	call   80101750 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010105f:	57                   	push   %edi
80101060:	ff 73 14             	pushl  0x14(%ebx)
80101063:	56                   	push   %esi
80101064:	ff 73 10             	pushl  0x10(%ebx)
80101067:	e8 c4 09 00 00       	call   80101a30 <readi>
8010106c:	83 c4 20             	add    $0x20,%esp
8010106f:	85 c0                	test   %eax,%eax
80101071:	89 c6                	mov    %eax,%esi
80101073:	7e 03                	jle    80101078 <fileread+0x48>
      f->off += r;
80101075:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	ff 73 10             	pushl  0x10(%ebx)
8010107e:	e8 ad 07 00 00       	call   80101830 <iunlock>
    return r;
80101083:	83 c4 10             	add    $0x10,%esp
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
    ilock(f->ip);
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101086:	89 f0                	mov    %esi,%eax
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80101088:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010108b:	5b                   	pop    %ebx
8010108c:	5e                   	pop    %esi
8010108d:	5f                   	pop    %edi
8010108e:	5d                   	pop    %ebp
8010108f:	c3                   	ret    
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80101090:	8b 43 0c             	mov    0xc(%ebx),%eax
80101093:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80101096:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101099:	5b                   	pop    %ebx
8010109a:	5e                   	pop    %esi
8010109b:	5f                   	pop    %edi
8010109c:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
8010109d:	e9 2e 24 00 00       	jmp    801034d0 <piperead>
801010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
fileread(struct file *f, char *addr, int n)
{
  int r;

  if(f->readable == 0)
    return -1;
801010a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010ad:	eb d9                	jmp    80101088 <fileread+0x58>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 a6 70 10 80       	push   $0x801070a6
801010b7:	e8 b4 f2 ff ff       	call   80100370 <panic>
801010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801010c0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	57                   	push   %edi
801010c4:	56                   	push   %esi
801010c5:	53                   	push   %ebx
801010c6:	83 ec 1c             	sub    $0x1c,%esp
801010c9:	8b 75 08             	mov    0x8(%ebp),%esi
801010cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  int r;

  if(f->writable == 0)
801010cf:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801010d6:	8b 45 10             	mov    0x10(%ebp),%eax
801010d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
801010dc:	0f 84 aa 00 00 00    	je     8010118c <filewrite+0xcc>
    return -1;
  if(f->type == FD_PIPE)
801010e2:	8b 06                	mov    (%esi),%eax
801010e4:	83 f8 01             	cmp    $0x1,%eax
801010e7:	0f 84 c2 00 00 00    	je     801011af <filewrite+0xef>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801010ed:	83 f8 02             	cmp    $0x2,%eax
801010f0:	0f 85 d8 00 00 00    	jne    801011ce <filewrite+0x10e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010f9:	31 ff                	xor    %edi,%edi
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 34                	jg     80101133 <filewrite+0x73>
801010ff:	e9 9c 00 00 00       	jmp    801011a0 <filewrite+0xe0>
80101104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101108:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	ff 76 10             	pushl  0x10(%esi)
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101111:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101114:	e8 17 07 00 00       	call   80101830 <iunlock>
      end_op();
80101119:	e8 e2 1a 00 00       	call   80102c00 <end_op>
8010111e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101121:	83 c4 10             	add    $0x10,%esp

      if(r < 0)
        break;
      if(r != n1)
80101124:	39 d8                	cmp    %ebx,%eax
80101126:	0f 85 95 00 00 00    	jne    801011c1 <filewrite+0x101>
        panic("short filewrite");
      i += r;
8010112c:	01 c7                	add    %eax,%edi
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010112e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101131:	7e 6d                	jle    801011a0 <filewrite+0xe0>
      int n1 = n - i;
80101133:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101136:	b8 00 1a 00 00       	mov    $0x1a00,%eax
8010113b:	29 fb                	sub    %edi,%ebx
8010113d:	81 fb 00 1a 00 00    	cmp    $0x1a00,%ebx
80101143:	0f 4f d8             	cmovg  %eax,%ebx
      if(n1 > max)
        n1 = max;

      begin_op();
80101146:	e8 45 1a 00 00       	call   80102b90 <begin_op>
      ilock(f->ip);
8010114b:	83 ec 0c             	sub    $0xc,%esp
8010114e:	ff 76 10             	pushl  0x10(%esi)
80101151:	e8 fa 05 00 00       	call   80101750 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101156:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101159:	53                   	push   %ebx
8010115a:	ff 76 14             	pushl  0x14(%esi)
8010115d:	01 f8                	add    %edi,%eax
8010115f:	50                   	push   %eax
80101160:	ff 76 10             	pushl  0x10(%esi)
80101163:	e8 c8 09 00 00       	call   80101b30 <writei>
80101168:	83 c4 20             	add    $0x20,%esp
8010116b:	85 c0                	test   %eax,%eax
8010116d:	7f 99                	jg     80101108 <filewrite+0x48>
        f->off += r;
      iunlock(f->ip);
8010116f:	83 ec 0c             	sub    $0xc,%esp
80101172:	ff 76 10             	pushl  0x10(%esi)
80101175:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101178:	e8 b3 06 00 00       	call   80101830 <iunlock>
      end_op();
8010117d:	e8 7e 1a 00 00       	call   80102c00 <end_op>

      if(r < 0)
80101182:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101185:	83 c4 10             	add    $0x10,%esp
80101188:	85 c0                	test   %eax,%eax
8010118a:	74 98                	je     80101124 <filewrite+0x64>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
8010118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010118f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80101194:	5b                   	pop    %ebx
80101195:	5e                   	pop    %esi
80101196:	5f                   	pop    %edi
80101197:	5d                   	pop    %ebp
80101198:	c3                   	ret    
80101199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801011a0:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
801011a3:	75 e7                	jne    8010118c <filewrite+0xcc>
  }
  panic("filewrite");
}
801011a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a8:	89 f8                	mov    %edi,%eax
801011aa:	5b                   	pop    %ebx
801011ab:	5e                   	pop    %esi
801011ac:	5f                   	pop    %edi
801011ad:	5d                   	pop    %ebp
801011ae:	c3                   	ret    
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
801011af:	8b 46 0c             	mov    0xc(%esi),%eax
801011b2:	89 45 08             	mov    %eax,0x8(%ebp)
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
801011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b8:	5b                   	pop    %ebx
801011b9:	5e                   	pop    %esi
801011ba:	5f                   	pop    %edi
801011bb:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
801011bc:	e9 0f 22 00 00       	jmp    801033d0 <pipewrite>
      end_op();

      if(r < 0)
        break;
      if(r != n1)
        panic("short filewrite");
801011c1:	83 ec 0c             	sub    $0xc,%esp
801011c4:	68 af 70 10 80       	push   $0x801070af
801011c9:	e8 a2 f1 ff ff       	call   80100370 <panic>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
801011ce:	83 ec 0c             	sub    $0xc,%esp
801011d1:	68 b5 70 10 80       	push   $0x801070b5
801011d6:	e8 95 f1 ff ff       	call   80100370 <panic>
801011db:	66 90                	xchg   %ax,%ax
801011dd:	66 90                	xchg   %ax,%ax
801011df:	90                   	nop

801011e0 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801011e0:	55                   	push   %ebp
801011e1:	89 e5                	mov    %esp,%ebp
801011e3:	57                   	push   %edi
801011e4:	56                   	push   %esi
801011e5:	53                   	push   %ebx
801011e6:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801011e9:	8b 0d c0 09 11 80    	mov    0x801109c0,%ecx
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801011ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801011f2:	85 c9                	test   %ecx,%ecx
801011f4:	0f 84 85 00 00 00    	je     8010127f <balloc+0x9f>
801011fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101201:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101204:	83 ec 08             	sub    $0x8,%esp
80101207:	89 f0                	mov    %esi,%eax
80101209:	c1 f8 0c             	sar    $0xc,%eax
8010120c:	03 05 d8 09 11 80    	add    0x801109d8,%eax
80101212:	50                   	push   %eax
80101213:	ff 75 d8             	pushl  -0x28(%ebp)
80101216:	e8 b5 ee ff ff       	call   801000d0 <bread>
8010121b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010121e:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101223:	83 c4 10             	add    $0x10,%esp
80101226:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101229:	31 c0                	xor    %eax,%eax
8010122b:	eb 2d                	jmp    8010125a <balloc+0x7a>
8010122d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101230:	89 c1                	mov    %eax,%ecx
80101232:	ba 01 00 00 00       	mov    $0x1,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101237:	8b 5d e4             	mov    -0x1c(%ebp),%ebx

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
8010123a:	83 e1 07             	and    $0x7,%ecx
8010123d:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010123f:	89 c1                	mov    %eax,%ecx
80101241:	c1 f9 03             	sar    $0x3,%ecx
80101244:	0f b6 7c 0b 5c       	movzbl 0x5c(%ebx,%ecx,1),%edi
80101249:	85 d7                	test   %edx,%edi
8010124b:	74 43                	je     80101290 <balloc+0xb0>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010124d:	83 c0 01             	add    $0x1,%eax
80101250:	83 c6 01             	add    $0x1,%esi
80101253:	3d 00 10 00 00       	cmp    $0x1000,%eax
80101258:	74 05                	je     8010125f <balloc+0x7f>
8010125a:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010125d:	72 d1                	jb     80101230 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010125f:	83 ec 0c             	sub    $0xc,%esp
80101262:	ff 75 e4             	pushl  -0x1c(%ebp)
80101265:	e8 76 ef ff ff       	call   801001e0 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010126a:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80101271:	83 c4 10             	add    $0x10,%esp
80101274:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101277:	39 05 c0 09 11 80    	cmp    %eax,0x801109c0
8010127d:	77 82                	ja     80101201 <balloc+0x21>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	68 bf 70 10 80       	push   $0x801070bf
80101287:	e8 e4 f0 ff ff       	call   80100370 <panic>
8010128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
80101290:	09 fa                	or     %edi,%edx
80101292:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101295:	83 ec 0c             	sub    $0xc,%esp
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
80101298:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010129c:	57                   	push   %edi
8010129d:	e8 ce 1a 00 00       	call   80102d70 <log_write>
        brelse(bp);
801012a2:	89 3c 24             	mov    %edi,(%esp)
801012a5:	e8 36 ef ff ff       	call   801001e0 <brelse>
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
801012aa:	58                   	pop    %eax
801012ab:	5a                   	pop    %edx
801012ac:	56                   	push   %esi
801012ad:	ff 75 d8             	pushl  -0x28(%ebp)
801012b0:	e8 1b ee ff ff       	call   801000d0 <bread>
801012b5:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801012b7:	8d 40 5c             	lea    0x5c(%eax),%eax
801012ba:	83 c4 0c             	add    $0xc,%esp
801012bd:	68 00 02 00 00       	push   $0x200
801012c2:	6a 00                	push   $0x0
801012c4:	50                   	push   %eax
801012c5:	e8 86 31 00 00       	call   80104450 <memset>
  log_write(bp);
801012ca:	89 1c 24             	mov    %ebx,(%esp)
801012cd:	e8 9e 1a 00 00       	call   80102d70 <log_write>
  brelse(bp);
801012d2:	89 1c 24             	mov    %ebx,(%esp)
801012d5:	e8 06 ef ff ff       	call   801001e0 <brelse>
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801012da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012dd:	89 f0                	mov    %esi,%eax
801012df:	5b                   	pop    %ebx
801012e0:	5e                   	pop    %esi
801012e1:	5f                   	pop    %edi
801012e2:	5d                   	pop    %ebp
801012e3:	c3                   	ret    
801012e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801012ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801012f0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	57                   	push   %edi
801012f4:	56                   	push   %esi
801012f5:	53                   	push   %ebx
801012f6:	89 c7                	mov    %eax,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
801012f8:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801012fa:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801012ff:	83 ec 28             	sub    $0x28,%esp
80101302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101305:	68 e0 09 11 80       	push   $0x801109e0
8010130a:	e8 d1 2f 00 00       	call   801042e0 <acquire>
8010130f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101312:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101315:	eb 1b                	jmp    80101332 <iget+0x42>
80101317:	89 f6                	mov    %esi,%esi
80101319:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101320:	85 f6                	test   %esi,%esi
80101322:	74 44                	je     80101368 <iget+0x78>

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101324:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010132a:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
80101330:	74 4e                	je     80101380 <iget+0x90>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101332:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101335:	85 c9                	test   %ecx,%ecx
80101337:	7e e7                	jle    80101320 <iget+0x30>
80101339:	39 3b                	cmp    %edi,(%ebx)
8010133b:	75 e3                	jne    80101320 <iget+0x30>
8010133d:	39 53 04             	cmp    %edx,0x4(%ebx)
80101340:	75 de                	jne    80101320 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
80101342:	83 ec 0c             	sub    $0xc,%esp

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
80101345:	83 c1 01             	add    $0x1,%ecx
      release(&icache.lock);
      return ip;
80101348:	89 de                	mov    %ebx,%esi
  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
8010134a:	68 e0 09 11 80       	push   $0x801109e0

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
8010134f:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
80101352:	e8 a9 30 00 00       	call   80104400 <release>
      return ip;
80101357:	83 c4 10             	add    $0x10,%esp
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);

  return ip;
}
8010135a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010135d:	89 f0                	mov    %esi,%eax
8010135f:	5b                   	pop    %ebx
80101360:	5e                   	pop    %esi
80101361:	5f                   	pop    %edi
80101362:	5d                   	pop    %ebp
80101363:	c3                   	ret    
80101364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101368:	85 c9                	test   %ecx,%ecx
8010136a:	0f 44 f3             	cmove  %ebx,%esi

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010136d:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101373:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
80101379:	75 b7                	jne    80101332 <iget+0x42>
8010137b:	90                   	nop
8010137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101380:	85 f6                	test   %esi,%esi
80101382:	74 2d                	je     801013b1 <iget+0xc1>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
80101384:	83 ec 0c             	sub    $0xc,%esp
  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80101387:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101389:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
8010138c:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101393:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010139a:	68 e0 09 11 80       	push   $0x801109e0
8010139f:	e8 5c 30 00 00       	call   80104400 <release>

  return ip;
801013a4:	83 c4 10             	add    $0x10,%esp
}
801013a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013aa:	89 f0                	mov    %esi,%eax
801013ac:	5b                   	pop    %ebx
801013ad:	5e                   	pop    %esi
801013ae:	5f                   	pop    %edi
801013af:	5d                   	pop    %ebp
801013b0:	c3                   	ret    
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
801013b1:	83 ec 0c             	sub    $0xc,%esp
801013b4:	68 d5 70 10 80       	push   $0x801070d5
801013b9:	e8 b2 ef ff ff       	call   80100370 <panic>
801013be:	66 90                	xchg   %ax,%ax

801013c0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801013c0:	55                   	push   %ebp
801013c1:	89 e5                	mov    %esp,%ebp
801013c3:	57                   	push   %edi
801013c4:	56                   	push   %esi
801013c5:	53                   	push   %ebx
801013c6:	89 c6                	mov    %eax,%esi
801013c8:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801013cb:	83 fa 0b             	cmp    $0xb,%edx
801013ce:	77 18                	ja     801013e8 <bmap+0x28>
801013d0:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
    if((addr = ip->addrs[bn]) == 0)
801013d3:	8b 43 5c             	mov    0x5c(%ebx),%eax
801013d6:	85 c0                	test   %eax,%eax
801013d8:	74 76                	je     80101450 <bmap+0x90>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
801013da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013dd:	5b                   	pop    %ebx
801013de:	5e                   	pop    %esi
801013df:	5f                   	pop    %edi
801013e0:	5d                   	pop    %ebp
801013e1:	c3                   	ret    
801013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
801013e8:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
801013eb:	83 fb 7f             	cmp    $0x7f,%ebx
801013ee:	0f 87 83 00 00 00    	ja     80101477 <bmap+0xb7>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801013f4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801013fa:	85 c0                	test   %eax,%eax
801013fc:	74 6a                	je     80101468 <bmap+0xa8>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801013fe:	83 ec 08             	sub    $0x8,%esp
80101401:	50                   	push   %eax
80101402:	ff 36                	pushl  (%esi)
80101404:	e8 c7 ec ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101409:	8d 54 98 5c          	lea    0x5c(%eax,%ebx,4),%edx
8010140d:	83 c4 10             	add    $0x10,%esp

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
80101410:	89 c7                	mov    %eax,%edi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101412:	8b 1a                	mov    (%edx),%ebx
80101414:	85 db                	test   %ebx,%ebx
80101416:	75 1d                	jne    80101435 <bmap+0x75>
      a[bn] = addr = balloc(ip->dev);
80101418:	8b 06                	mov    (%esi),%eax
8010141a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010141d:	e8 be fd ff ff       	call   801011e0 <balloc>
80101422:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
80101425:	83 ec 0c             	sub    $0xc,%esp
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->dev);
80101428:	89 c3                	mov    %eax,%ebx
8010142a:	89 02                	mov    %eax,(%edx)
      log_write(bp);
8010142c:	57                   	push   %edi
8010142d:	e8 3e 19 00 00       	call   80102d70 <log_write>
80101432:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101435:	83 ec 0c             	sub    $0xc,%esp
80101438:	57                   	push   %edi
80101439:	e8 a2 ed ff ff       	call   801001e0 <brelse>
8010143e:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
80101441:	8d 65 f4             	lea    -0xc(%ebp),%esp
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
80101444:	89 d8                	mov    %ebx,%eax
    return addr;
  }

  panic("bmap: out of range");
}
80101446:	5b                   	pop    %ebx
80101447:	5e                   	pop    %esi
80101448:	5f                   	pop    %edi
80101449:	5d                   	pop    %ebp
8010144a:	c3                   	ret    
8010144b:	90                   	nop
8010144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80101450:	8b 06                	mov    (%esi),%eax
80101452:	e8 89 fd ff ff       	call   801011e0 <balloc>
80101457:	89 43 5c             	mov    %eax,0x5c(%ebx)
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
8010145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010145d:	5b                   	pop    %ebx
8010145e:	5e                   	pop    %esi
8010145f:	5f                   	pop    %edi
80101460:	5d                   	pop    %ebp
80101461:	c3                   	ret    
80101462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101468:	8b 06                	mov    (%esi),%eax
8010146a:	e8 71 fd ff ff       	call   801011e0 <balloc>
8010146f:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101475:	eb 87                	jmp    801013fe <bmap+0x3e>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
80101477:	83 ec 0c             	sub    $0xc,%esp
8010147a:	68 e5 70 10 80       	push   $0x801070e5
8010147f:	e8 ec ee ff ff       	call   80100370 <panic>
80101484:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010148a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101490 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101490:	55                   	push   %ebp
80101491:	89 e5                	mov    %esp,%ebp
80101493:	56                   	push   %esi
80101494:	53                   	push   %ebx
80101495:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct buf *bp;

  bp = bread(dev, 1);
80101498:	83 ec 08             	sub    $0x8,%esp
8010149b:	6a 01                	push   $0x1
8010149d:	ff 75 08             	pushl  0x8(%ebp)
801014a0:	e8 2b ec ff ff       	call   801000d0 <bread>
801014a5:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801014a7:	8d 40 5c             	lea    0x5c(%eax),%eax
801014aa:	83 c4 0c             	add    $0xc,%esp
801014ad:	6a 1c                	push   $0x1c
801014af:	50                   	push   %eax
801014b0:	56                   	push   %esi
801014b1:	e8 4a 30 00 00       	call   80104500 <memmove>
  brelse(bp);
801014b6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801014b9:	83 c4 10             	add    $0x10,%esp
}
801014bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014bf:	5b                   	pop    %ebx
801014c0:	5e                   	pop    %esi
801014c1:	5d                   	pop    %ebp
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
801014c2:	e9 19 ed ff ff       	jmp    801001e0 <brelse>
801014c7:	89 f6                	mov    %esi,%esi
801014c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801014d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d0:	55                   	push   %ebp
801014d1:	89 e5                	mov    %esp,%ebp
801014d3:	56                   	push   %esi
801014d4:	53                   	push   %ebx
801014d5:	89 d3                	mov    %edx,%ebx
801014d7:	89 c6                	mov    %eax,%esi
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014d9:	83 ec 08             	sub    $0x8,%esp
801014dc:	68 c0 09 11 80       	push   $0x801109c0
801014e1:	50                   	push   %eax
801014e2:	e8 a9 ff ff ff       	call   80101490 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801014e7:	58                   	pop    %eax
801014e8:	5a                   	pop    %edx
801014e9:	89 da                	mov    %ebx,%edx
801014eb:	c1 ea 0c             	shr    $0xc,%edx
801014ee:	03 15 d8 09 11 80    	add    0x801109d8,%edx
801014f4:	52                   	push   %edx
801014f5:	56                   	push   %esi
801014f6:	e8 d5 eb ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801014fb:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801014fd:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
80101503:	ba 01 00 00 00       	mov    $0x1,%edx
80101508:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
8010150b:	c1 fb 03             	sar    $0x3,%ebx
8010150e:	83 c4 10             	add    $0x10,%esp
  int bi, m;

  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
80101511:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
80101513:	0f b6 4c 18 5c       	movzbl 0x5c(%eax,%ebx,1),%ecx
80101518:	85 d1                	test   %edx,%ecx
8010151a:	74 27                	je     80101543 <bfree+0x73>
8010151c:	89 c6                	mov    %eax,%esi
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
8010151e:	f7 d2                	not    %edx
80101520:	89 c8                	mov    %ecx,%eax
  log_write(bp);
80101522:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101525:	21 d0                	and    %edx,%eax
80101527:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010152b:	56                   	push   %esi
8010152c:	e8 3f 18 00 00       	call   80102d70 <log_write>
  brelse(bp);
80101531:	89 34 24             	mov    %esi,(%esp)
80101534:	e8 a7 ec ff ff       	call   801001e0 <brelse>
}
80101539:	83 c4 10             	add    $0x10,%esp
8010153c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010153f:	5b                   	pop    %ebx
80101540:	5e                   	pop    %esi
80101541:	5d                   	pop    %ebp
80101542:	c3                   	ret    
  readsb(dev, &sb);
  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
80101543:	83 ec 0c             	sub    $0xc,%esp
80101546:	68 f8 70 10 80       	push   $0x801070f8
8010154b:	e8 20 ee ff ff       	call   80100370 <panic>

80101550 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101550:	55                   	push   %ebp
80101551:	89 e5                	mov    %esp,%ebp
80101553:	53                   	push   %ebx
80101554:	bb 20 0a 11 80       	mov    $0x80110a20,%ebx
80101559:	83 ec 0c             	sub    $0xc,%esp
  int i = 0;
  
  initlock(&icache.lock, "icache");
8010155c:	68 0b 71 10 80       	push   $0x8010710b
80101561:	68 e0 09 11 80       	push   $0x801109e0
80101566:	e8 75 2c 00 00       	call   801041e0 <initlock>
8010156b:	83 c4 10             	add    $0x10,%esp
8010156e:	66 90                	xchg   %ax,%ax
  for(i = 0; i < NINODE; i++) {
    initsleeplock(&icache.inode[i].lock, "inode");
80101570:	83 ec 08             	sub    $0x8,%esp
80101573:	68 12 71 10 80       	push   $0x80107112
80101578:	53                   	push   %ebx
80101579:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010157f:	e8 4c 2b 00 00       	call   801040d0 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101584:	83 c4 10             	add    $0x10,%esp
80101587:	81 fb 40 26 11 80    	cmp    $0x80112640,%ebx
8010158d:	75 e1                	jne    80101570 <iinit+0x20>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
8010158f:	83 ec 08             	sub    $0x8,%esp
80101592:	68 c0 09 11 80       	push   $0x801109c0
80101597:	ff 75 08             	pushl  0x8(%ebp)
8010159a:	e8 f1 fe ff ff       	call   80101490 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010159f:	ff 35 d8 09 11 80    	pushl  0x801109d8
801015a5:	ff 35 d4 09 11 80    	pushl  0x801109d4
801015ab:	ff 35 d0 09 11 80    	pushl  0x801109d0
801015b1:	ff 35 cc 09 11 80    	pushl  0x801109cc
801015b7:	ff 35 c8 09 11 80    	pushl  0x801109c8
801015bd:	ff 35 c4 09 11 80    	pushl  0x801109c4
801015c3:	ff 35 c0 09 11 80    	pushl  0x801109c0
801015c9:	68 78 71 10 80       	push   $0x80107178
801015ce:	e8 8d f0 ff ff       	call   80100660 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801015d3:	83 c4 30             	add    $0x30,%esp
801015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801015d9:	c9                   	leave  
801015da:	c3                   	ret    
801015db:	90                   	nop
801015dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801015e0 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801015e0:	55                   	push   %ebp
801015e1:	89 e5                	mov    %esp,%ebp
801015e3:	57                   	push   %edi
801015e4:	56                   	push   %esi
801015e5:	53                   	push   %ebx
801015e6:	83 ec 1c             	sub    $0x1c,%esp
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801015e9:	83 3d c8 09 11 80 01 	cmpl   $0x1,0x801109c8
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801015f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f3:	8b 75 08             	mov    0x8(%ebp),%esi
801015f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801015f9:	0f 86 91 00 00 00    	jbe    80101690 <ialloc+0xb0>
801015ff:	bb 01 00 00 00       	mov    $0x1,%ebx
80101604:	eb 21                	jmp    80101627 <ialloc+0x47>
80101606:	8d 76 00             	lea    0x0(%esi),%esi
80101609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101610:	83 ec 0c             	sub    $0xc,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101613:	83 c3 01             	add    $0x1,%ebx
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101616:	57                   	push   %edi
80101617:	e8 c4 eb ff ff       	call   801001e0 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010161c:	83 c4 10             	add    $0x10,%esp
8010161f:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
80101625:	76 69                	jbe    80101690 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101627:	89 d8                	mov    %ebx,%eax
80101629:	83 ec 08             	sub    $0x8,%esp
8010162c:	c1 e8 03             	shr    $0x3,%eax
8010162f:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101635:	50                   	push   %eax
80101636:	56                   	push   %esi
80101637:	e8 94 ea ff ff       	call   801000d0 <bread>
8010163c:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
8010163e:	89 d8                	mov    %ebx,%eax
    if(dip->type == 0){  // a free inode
80101640:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
    bp = bread(dev, IBLOCK(inum, sb));
    dip = (struct dinode*)bp->data + inum%IPB;
80101643:	83 e0 07             	and    $0x7,%eax
80101646:	c1 e0 06             	shl    $0x6,%eax
80101649:	8d 4c 07 5c          	lea    0x5c(%edi,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010164d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101651:	75 bd                	jne    80101610 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101653:	83 ec 04             	sub    $0x4,%esp
80101656:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101659:	6a 40                	push   $0x40
8010165b:	6a 00                	push   $0x0
8010165d:	51                   	push   %ecx
8010165e:	e8 ed 2d 00 00       	call   80104450 <memset>
      dip->type = type;
80101663:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101667:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010166a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010166d:	89 3c 24             	mov    %edi,(%esp)
80101670:	e8 fb 16 00 00       	call   80102d70 <log_write>
      brelse(bp);
80101675:	89 3c 24             	mov    %edi,(%esp)
80101678:	e8 63 eb ff ff       	call   801001e0 <brelse>
      return iget(dev, inum);
8010167d:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101680:	8d 65 f4             	lea    -0xc(%ebp),%esp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
80101683:	89 da                	mov    %ebx,%edx
80101685:	89 f0                	mov    %esi,%eax
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101687:	5b                   	pop    %ebx
80101688:	5e                   	pop    %esi
80101689:	5f                   	pop    %edi
8010168a:	5d                   	pop    %ebp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
8010168b:	e9 60 fc ff ff       	jmp    801012f0 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101690:	83 ec 0c             	sub    $0xc,%esp
80101693:	68 18 71 10 80       	push   $0x80107118
80101698:	e8 d3 ec ff ff       	call   80100370 <panic>
8010169d:	8d 76 00             	lea    0x0(%esi),%esi

801016a0 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801016a0:	55                   	push   %ebp
801016a1:	89 e5                	mov    %esp,%ebp
801016a3:	56                   	push   %esi
801016a4:	53                   	push   %ebx
801016a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016a8:	83 ec 08             	sub    $0x8,%esp
801016ab:	8b 43 04             	mov    0x4(%ebx),%eax
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016ae:	83 c3 5c             	add    $0x5c,%ebx
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016b1:	c1 e8 03             	shr    $0x3,%eax
801016b4:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801016ba:	50                   	push   %eax
801016bb:	ff 73 a4             	pushl  -0x5c(%ebx)
801016be:	e8 0d ea ff ff       	call   801000d0 <bread>
801016c3:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016c5:	8b 43 a8             	mov    -0x58(%ebx),%eax
  dip->type = ip->type;
801016c8:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016cc:	83 c4 0c             	add    $0xc,%esp
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016cf:	83 e0 07             	and    $0x7,%eax
801016d2:	c1 e0 06             	shl    $0x6,%eax
801016d5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801016d9:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016dc:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016e0:	83 c0 0c             	add    $0xc,%eax
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
801016e3:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
801016e7:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
801016eb:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
801016ef:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
801016f3:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
801016f7:	8b 53 fc             	mov    -0x4(%ebx),%edx
801016fa:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016fd:	6a 34                	push   $0x34
801016ff:	53                   	push   %ebx
80101700:	50                   	push   %eax
80101701:	e8 fa 2d 00 00       	call   80104500 <memmove>
  log_write(bp);
80101706:	89 34 24             	mov    %esi,(%esp)
80101709:	e8 62 16 00 00       	call   80102d70 <log_write>
  brelse(bp);
8010170e:	89 75 08             	mov    %esi,0x8(%ebp)
80101711:	83 c4 10             	add    $0x10,%esp
}
80101714:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101717:	5b                   	pop    %ebx
80101718:	5e                   	pop    %esi
80101719:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
8010171a:	e9 c1 ea ff ff       	jmp    801001e0 <brelse>
8010171f:	90                   	nop

80101720 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101720:	55                   	push   %ebp
80101721:	89 e5                	mov    %esp,%ebp
80101723:	53                   	push   %ebx
80101724:	83 ec 10             	sub    $0x10,%esp
80101727:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010172a:	68 e0 09 11 80       	push   $0x801109e0
8010172f:	e8 ac 2b 00 00       	call   801042e0 <acquire>
  ip->ref++;
80101734:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101738:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010173f:	e8 bc 2c 00 00       	call   80104400 <release>
  return ip;
}
80101744:	89 d8                	mov    %ebx,%eax
80101746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101749:	c9                   	leave  
8010174a:	c3                   	ret    
8010174b:	90                   	nop
8010174c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101750 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101750:	55                   	push   %ebp
80101751:	89 e5                	mov    %esp,%ebp
80101753:	56                   	push   %esi
80101754:	53                   	push   %ebx
80101755:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101758:	85 db                	test   %ebx,%ebx
8010175a:	0f 84 b7 00 00 00    	je     80101817 <ilock+0xc7>
80101760:	8b 53 08             	mov    0x8(%ebx),%edx
80101763:	85 d2                	test   %edx,%edx
80101765:	0f 8e ac 00 00 00    	jle    80101817 <ilock+0xc7>
    panic("ilock");

  acquiresleep(&ip->lock);
8010176b:	8d 43 0c             	lea    0xc(%ebx),%eax
8010176e:	83 ec 0c             	sub    $0xc,%esp
80101771:	50                   	push   %eax
80101772:	e8 99 29 00 00       	call   80104110 <acquiresleep>

  if(ip->valid == 0){
80101777:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010177a:	83 c4 10             	add    $0x10,%esp
8010177d:	85 c0                	test   %eax,%eax
8010177f:	74 0f                	je     80101790 <ilock+0x40>
    brelse(bp);
    ip->valid = 1;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
80101781:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101784:	5b                   	pop    %ebx
80101785:	5e                   	pop    %esi
80101786:	5d                   	pop    %ebp
80101787:	c3                   	ret    
80101788:	90                   	nop
80101789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    panic("ilock");

  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101790:	8b 43 04             	mov    0x4(%ebx),%eax
80101793:	83 ec 08             	sub    $0x8,%esp
80101796:	c1 e8 03             	shr    $0x3,%eax
80101799:	03 05 d4 09 11 80    	add    0x801109d4,%eax
8010179f:	50                   	push   %eax
801017a0:	ff 33                	pushl  (%ebx)
801017a2:	e8 29 e9 ff ff       	call   801000d0 <bread>
801017a7:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017a9:	8b 43 04             	mov    0x4(%ebx),%eax
    ip->type = dip->type;
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017ac:	83 c4 0c             	add    $0xc,%esp

  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017af:	83 e0 07             	and    $0x7,%eax
801017b2:	c1 e0 06             	shl    $0x6,%eax
801017b5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801017b9:	0f b7 10             	movzwl (%eax),%edx
    ip->major = dip->major;
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017bc:	83 c0 0c             	add    $0xc,%eax
  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    ip->type = dip->type;
801017bf:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801017c3:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801017c7:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801017cb:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801017cf:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801017d3:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
801017d7:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801017db:	8b 50 fc             	mov    -0x4(%eax),%edx
801017de:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017e1:	6a 34                	push   $0x34
801017e3:	50                   	push   %eax
801017e4:	8d 43 5c             	lea    0x5c(%ebx),%eax
801017e7:	50                   	push   %eax
801017e8:	e8 13 2d 00 00       	call   80104500 <memmove>
    brelse(bp);
801017ed:	89 34 24             	mov    %esi,(%esp)
801017f0:	e8 eb e9 ff ff       	call   801001e0 <brelse>
    ip->valid = 1;
    if(ip->type == 0)
801017f5:	83 c4 10             	add    $0x10,%esp
801017f8:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->minor = dip->minor;
    ip->nlink = dip->nlink;
    ip->size = dip->size;
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    brelse(bp);
    ip->valid = 1;
801017fd:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101804:	0f 85 77 ff ff ff    	jne    80101781 <ilock+0x31>
      panic("ilock: no type");
8010180a:	83 ec 0c             	sub    $0xc,%esp
8010180d:	68 30 71 10 80       	push   $0x80107130
80101812:	e8 59 eb ff ff       	call   80100370 <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
80101817:	83 ec 0c             	sub    $0xc,%esp
8010181a:	68 2a 71 10 80       	push   $0x8010712a
8010181f:	e8 4c eb ff ff       	call   80100370 <panic>
80101824:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010182a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101830 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101830:	55                   	push   %ebp
80101831:	89 e5                	mov    %esp,%ebp
80101833:	56                   	push   %esi
80101834:	53                   	push   %ebx
80101835:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101838:	85 db                	test   %ebx,%ebx
8010183a:	74 28                	je     80101864 <iunlock+0x34>
8010183c:	8d 73 0c             	lea    0xc(%ebx),%esi
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	56                   	push   %esi
80101843:	e8 68 29 00 00       	call   801041b0 <holdingsleep>
80101848:	83 c4 10             	add    $0x10,%esp
8010184b:	85 c0                	test   %eax,%eax
8010184d:	74 15                	je     80101864 <iunlock+0x34>
8010184f:	8b 43 08             	mov    0x8(%ebx),%eax
80101852:	85 c0                	test   %eax,%eax
80101854:	7e 0e                	jle    80101864 <iunlock+0x34>
    panic("iunlock");

  releasesleep(&ip->lock);
80101856:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101859:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010185c:	5b                   	pop    %ebx
8010185d:	5e                   	pop    %esi
8010185e:	5d                   	pop    %ebp
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");

  releasesleep(&ip->lock);
8010185f:	e9 0c 29 00 00       	jmp    80104170 <releasesleep>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");
80101864:	83 ec 0c             	sub    $0xc,%esp
80101867:	68 3f 71 10 80       	push   $0x8010713f
8010186c:	e8 ff ea ff ff       	call   80100370 <panic>
80101871:	eb 0d                	jmp    80101880 <iput>
80101873:	90                   	nop
80101874:	90                   	nop
80101875:	90                   	nop
80101876:	90                   	nop
80101877:	90                   	nop
80101878:	90                   	nop
80101879:	90                   	nop
8010187a:	90                   	nop
8010187b:	90                   	nop
8010187c:	90                   	nop
8010187d:	90                   	nop
8010187e:	90                   	nop
8010187f:	90                   	nop

80101880 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101880:	55                   	push   %ebp
80101881:	89 e5                	mov    %esp,%ebp
80101883:	57                   	push   %edi
80101884:	56                   	push   %esi
80101885:	53                   	push   %ebx
80101886:	83 ec 28             	sub    $0x28,%esp
80101889:	8b 75 08             	mov    0x8(%ebp),%esi
  acquiresleep(&ip->lock);
8010188c:	8d 7e 0c             	lea    0xc(%esi),%edi
8010188f:	57                   	push   %edi
80101890:	e8 7b 28 00 00       	call   80104110 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101895:	8b 56 4c             	mov    0x4c(%esi),%edx
80101898:	83 c4 10             	add    $0x10,%esp
8010189b:	85 d2                	test   %edx,%edx
8010189d:	74 07                	je     801018a6 <iput+0x26>
8010189f:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
801018a4:	74 32                	je     801018d8 <iput+0x58>
      ip->type = 0;
      iupdate(ip);
      ip->valid = 0;
    }
  }
  releasesleep(&ip->lock);
801018a6:	83 ec 0c             	sub    $0xc,%esp
801018a9:	57                   	push   %edi
801018aa:	e8 c1 28 00 00       	call   80104170 <releasesleep>

  acquire(&icache.lock);
801018af:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801018b6:	e8 25 2a 00 00       	call   801042e0 <acquire>
  ip->ref--;
801018bb:	83 6e 08 01          	subl   $0x1,0x8(%esi)
  release(&icache.lock);
801018bf:	83 c4 10             	add    $0x10,%esp
801018c2:	c7 45 08 e0 09 11 80 	movl   $0x801109e0,0x8(%ebp)
}
801018c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018cc:	5b                   	pop    %ebx
801018cd:	5e                   	pop    %esi
801018ce:	5f                   	pop    %edi
801018cf:	5d                   	pop    %ebp
  }
  releasesleep(&ip->lock);

  acquire(&icache.lock);
  ip->ref--;
  release(&icache.lock);
801018d0:	e9 2b 2b 00 00       	jmp    80104400 <release>
801018d5:	8d 76 00             	lea    0x0(%esi),%esi
void
iput(struct inode *ip)
{
  acquiresleep(&ip->lock);
  if(ip->valid && ip->nlink == 0){
    acquire(&icache.lock);
801018d8:	83 ec 0c             	sub    $0xc,%esp
801018db:	68 e0 09 11 80       	push   $0x801109e0
801018e0:	e8 fb 29 00 00       	call   801042e0 <acquire>
    int r = ip->ref;
801018e5:	8b 5e 08             	mov    0x8(%esi),%ebx
    release(&icache.lock);
801018e8:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801018ef:	e8 0c 2b 00 00       	call   80104400 <release>
    if(r == 1){
801018f4:	83 c4 10             	add    $0x10,%esp
801018f7:	83 fb 01             	cmp    $0x1,%ebx
801018fa:	75 aa                	jne    801018a6 <iput+0x26>
801018fc:	8d 8e 8c 00 00 00    	lea    0x8c(%esi),%ecx
80101902:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101905:	8d 5e 5c             	lea    0x5c(%esi),%ebx
80101908:	89 cf                	mov    %ecx,%edi
8010190a:	eb 0b                	jmp    80101917 <iput+0x97>
8010190c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101910:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101913:	39 fb                	cmp    %edi,%ebx
80101915:	74 19                	je     80101930 <iput+0xb0>
    if(ip->addrs[i]){
80101917:	8b 13                	mov    (%ebx),%edx
80101919:	85 d2                	test   %edx,%edx
8010191b:	74 f3                	je     80101910 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
8010191d:	8b 06                	mov    (%esi),%eax
8010191f:	e8 ac fb ff ff       	call   801014d0 <bfree>
      ip->addrs[i] = 0;
80101924:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
8010192a:	eb e4                	jmp    80101910 <iput+0x90>
8010192c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101930:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101939:	85 c0                	test   %eax,%eax
8010193b:	75 33                	jne    80101970 <iput+0xf0>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
8010193d:	83 ec 0c             	sub    $0xc,%esp
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
80101940:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101947:	56                   	push   %esi
80101948:	e8 53 fd ff ff       	call   801016a0 <iupdate>
    int r = ip->ref;
    release(&icache.lock);
    if(r == 1){
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
      ip->type = 0;
8010194d:	31 c0                	xor    %eax,%eax
8010194f:	66 89 46 50          	mov    %ax,0x50(%esi)
      iupdate(ip);
80101953:	89 34 24             	mov    %esi,(%esp)
80101956:	e8 45 fd ff ff       	call   801016a0 <iupdate>
      ip->valid = 0;
8010195b:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
80101962:	83 c4 10             	add    $0x10,%esp
80101965:	e9 3c ff ff ff       	jmp    801018a6 <iput+0x26>
8010196a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101970:	83 ec 08             	sub    $0x8,%esp
80101973:	50                   	push   %eax
80101974:	ff 36                	pushl  (%esi)
80101976:	e8 55 e7 ff ff       	call   801000d0 <bread>
8010197b:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101981:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101984:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101987:	8d 58 5c             	lea    0x5c(%eax),%ebx
8010198a:	83 c4 10             	add    $0x10,%esp
8010198d:	89 cf                	mov    %ecx,%edi
8010198f:	eb 0e                	jmp    8010199f <iput+0x11f>
80101991:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101998:	83 c3 04             	add    $0x4,%ebx
    for(j = 0; j < NINDIRECT; j++){
8010199b:	39 fb                	cmp    %edi,%ebx
8010199d:	74 0f                	je     801019ae <iput+0x12e>
      if(a[j])
8010199f:	8b 13                	mov    (%ebx),%edx
801019a1:	85 d2                	test   %edx,%edx
801019a3:	74 f3                	je     80101998 <iput+0x118>
        bfree(ip->dev, a[j]);
801019a5:	8b 06                	mov    (%esi),%eax
801019a7:	e8 24 fb ff ff       	call   801014d0 <bfree>
801019ac:	eb ea                	jmp    80101998 <iput+0x118>
    }
    brelse(bp);
801019ae:	83 ec 0c             	sub    $0xc,%esp
801019b1:	ff 75 e4             	pushl  -0x1c(%ebp)
801019b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
801019b7:	e8 24 e8 ff ff       	call   801001e0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801019bc:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
801019c2:	8b 06                	mov    (%esi),%eax
801019c4:	e8 07 fb ff ff       	call   801014d0 <bfree>
    ip->addrs[NDIRECT] = 0;
801019c9:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
801019d0:	00 00 00 
801019d3:	83 c4 10             	add    $0x10,%esp
801019d6:	e9 62 ff ff ff       	jmp    8010193d <iput+0xbd>
801019db:	90                   	nop
801019dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801019e0 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	53                   	push   %ebx
801019e4:	83 ec 10             	sub    $0x10,%esp
801019e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801019ea:	53                   	push   %ebx
801019eb:	e8 40 fe ff ff       	call   80101830 <iunlock>
  iput(ip);
801019f0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801019f3:	83 c4 10             	add    $0x10,%esp
}
801019f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801019f9:	c9                   	leave  
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
801019fa:	e9 81 fe ff ff       	jmp    80101880 <iput>
801019ff:	90                   	nop

80101a00 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	8b 55 08             	mov    0x8(%ebp),%edx
80101a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101a09:	8b 0a                	mov    (%edx),%ecx
80101a0b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101a0e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101a11:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101a14:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101a18:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101a1b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101a1f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101a23:	8b 52 58             	mov    0x58(%edx),%edx
80101a26:	89 50 10             	mov    %edx,0x10(%eax)
}
80101a29:	5d                   	pop    %ebp
80101a2a:	c3                   	ret    
80101a2b:	90                   	nop
80101a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101a30 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	57                   	push   %edi
80101a34:	56                   	push   %esi
80101a35:	53                   	push   %ebx
80101a36:	83 ec 1c             	sub    $0x1c,%esp
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101a3f:	8b 75 10             	mov    0x10(%ebp),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101a42:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101a47:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101a4a:	8b 7d 14             	mov    0x14(%ebp),%edi
80101a4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101a50:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101a53:	0f 84 a7 00 00 00    	je     80101b00 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101a59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101a5c:	8b 40 58             	mov    0x58(%eax),%eax
80101a5f:	39 f0                	cmp    %esi,%eax
80101a61:	0f 82 c1 00 00 00    	jb     80101b28 <readi+0xf8>
80101a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101a6a:	89 fa                	mov    %edi,%edx
80101a6c:	01 f2                	add    %esi,%edx
80101a6e:	0f 82 b4 00 00 00    	jb     80101b28 <readi+0xf8>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101a74:	89 c1                	mov    %eax,%ecx
80101a76:	29 f1                	sub    %esi,%ecx
80101a78:	39 d0                	cmp    %edx,%eax
80101a7a:	0f 43 cf             	cmovae %edi,%ecx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101a7d:	31 ff                	xor    %edi,%edi
80101a7f:	85 c9                	test   %ecx,%ecx
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101a81:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101a84:	74 6d                	je     80101af3 <readi+0xc3>
80101a86:	8d 76 00             	lea    0x0(%esi),%esi
80101a89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101a90:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101a93:	89 f2                	mov    %esi,%edx
80101a95:	c1 ea 09             	shr    $0x9,%edx
80101a98:	89 d8                	mov    %ebx,%eax
80101a9a:	e8 21 f9 ff ff       	call   801013c0 <bmap>
80101a9f:	83 ec 08             	sub    $0x8,%esp
80101aa2:	50                   	push   %eax
80101aa3:	ff 33                	pushl  (%ebx)
    m = min(n - tot, BSIZE - off%BSIZE);
80101aa5:	bb 00 02 00 00       	mov    $0x200,%ebx
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101aaa:	e8 21 e6 ff ff       	call   801000d0 <bread>
80101aaf:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ab4:	89 f1                	mov    %esi,%ecx
80101ab6:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
80101abc:	83 c4 0c             	add    $0xc,%esp
    memmove(dst, bp->data + off%BSIZE, m);
80101abf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101ac2:	29 cb                	sub    %ecx,%ebx
80101ac4:	29 f8                	sub    %edi,%eax
80101ac6:	39 c3                	cmp    %eax,%ebx
80101ac8:	0f 47 d8             	cmova  %eax,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101acb:	8d 44 0a 5c          	lea    0x5c(%edx,%ecx,1),%eax
80101acf:	53                   	push   %ebx
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ad0:	01 df                	add    %ebx,%edi
80101ad2:	01 de                	add    %ebx,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
80101ad4:	50                   	push   %eax
80101ad5:	ff 75 e0             	pushl  -0x20(%ebp)
80101ad8:	e8 23 2a 00 00       	call   80104500 <memmove>
    brelse(bp);
80101add:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101ae0:	89 14 24             	mov    %edx,(%esp)
80101ae3:	e8 f8 e6 ff ff       	call   801001e0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ae8:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101aeb:	83 c4 10             	add    $0x10,%esp
80101aee:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101af1:	77 9d                	ja     80101a90 <readi+0x60>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101af3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101af9:	5b                   	pop    %ebx
80101afa:	5e                   	pop    %esi
80101afb:	5f                   	pop    %edi
80101afc:	5d                   	pop    %ebp
80101afd:	c3                   	ret    
80101afe:	66 90                	xchg   %ax,%ax
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101b00:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101b04:	66 83 f8 09          	cmp    $0x9,%ax
80101b08:	77 1e                	ja     80101b28 <readi+0xf8>
80101b0a:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
80101b11:	85 c0                	test   %eax,%eax
80101b13:	74 13                	je     80101b28 <readi+0xf8>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101b15:	89 7d 10             	mov    %edi,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
80101b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b1b:	5b                   	pop    %ebx
80101b1c:	5e                   	pop    %esi
80101b1d:	5f                   	pop    %edi
80101b1e:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101b1f:	ff e0                	jmp    *%eax
80101b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
80101b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b2d:	eb c7                	jmp    80101af6 <readi+0xc6>
80101b2f:	90                   	nop

80101b30 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	57                   	push   %edi
80101b34:	56                   	push   %esi
80101b35:	53                   	push   %ebx
80101b36:	83 ec 1c             	sub    $0x1c,%esp
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
80101b3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101b42:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101b47:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101b4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101b4d:	8b 75 10             	mov    0x10(%ebp),%esi
80101b50:	89 7d e0             	mov    %edi,-0x20(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101b53:	0f 84 b7 00 00 00    	je     80101c10 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101b59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101b5c:	39 70 58             	cmp    %esi,0x58(%eax)
80101b5f:	0f 82 eb 00 00 00    	jb     80101c50 <writei+0x120>
80101b65:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101b68:	89 f8                	mov    %edi,%eax
80101b6a:	01 f0                	add    %esi,%eax
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101b6c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101b71:	0f 87 d9 00 00 00    	ja     80101c50 <writei+0x120>
80101b77:	39 c6                	cmp    %eax,%esi
80101b79:	0f 87 d1 00 00 00    	ja     80101c50 <writei+0x120>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101b7f:	85 ff                	test   %edi,%edi
80101b81:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101b88:	74 78                	je     80101c02 <writei+0xd2>
80101b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b90:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101b93:	89 f2                	mov    %esi,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101b95:	bb 00 02 00 00       	mov    $0x200,%ebx
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b9a:	c1 ea 09             	shr    $0x9,%edx
80101b9d:	89 f8                	mov    %edi,%eax
80101b9f:	e8 1c f8 ff ff       	call   801013c0 <bmap>
80101ba4:	83 ec 08             	sub    $0x8,%esp
80101ba7:	50                   	push   %eax
80101ba8:	ff 37                	pushl  (%edi)
80101baa:	e8 21 e5 ff ff       	call   801000d0 <bread>
80101baf:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101bb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101bb4:	2b 45 e4             	sub    -0x1c(%ebp),%eax
80101bb7:	89 f1                	mov    %esi,%ecx
80101bb9:	83 c4 0c             	add    $0xc,%esp
80101bbc:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
80101bc2:	29 cb                	sub    %ecx,%ebx
80101bc4:	39 c3                	cmp    %eax,%ebx
80101bc6:	0f 47 d8             	cmova  %eax,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101bc9:	8d 44 0f 5c          	lea    0x5c(%edi,%ecx,1),%eax
80101bcd:	53                   	push   %ebx
80101bce:	ff 75 dc             	pushl  -0x24(%ebp)
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101bd1:	01 de                	add    %ebx,%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(bp->data + off%BSIZE, src, m);
80101bd3:	50                   	push   %eax
80101bd4:	e8 27 29 00 00       	call   80104500 <memmove>
    log_write(bp);
80101bd9:	89 3c 24             	mov    %edi,(%esp)
80101bdc:	e8 8f 11 00 00       	call   80102d70 <log_write>
    brelse(bp);
80101be1:	89 3c 24             	mov    %edi,(%esp)
80101be4:	e8 f7 e5 ff ff       	call   801001e0 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101be9:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101bec:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101bef:	83 c4 10             	add    $0x10,%esp
80101bf2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101bf5:	39 55 e0             	cmp    %edx,-0x20(%ebp)
80101bf8:	77 96                	ja     80101b90 <writei+0x60>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80101bfa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bfd:	3b 70 58             	cmp    0x58(%eax),%esi
80101c00:	77 36                	ja     80101c38 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c08:	5b                   	pop    %ebx
80101c09:	5e                   	pop    %esi
80101c0a:	5f                   	pop    %edi
80101c0b:	5d                   	pop    %ebp
80101c0c:	c3                   	ret    
80101c0d:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101c10:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c14:	66 83 f8 09          	cmp    $0x9,%ax
80101c18:	77 36                	ja     80101c50 <writei+0x120>
80101c1a:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
80101c21:	85 c0                	test   %eax,%eax
80101c23:	74 2b                	je     80101c50 <writei+0x120>
      return -1;
    return devsw[ip->major].write(ip, src, n);
80101c25:	89 7d 10             	mov    %edi,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
80101c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c2b:	5b                   	pop    %ebx
80101c2c:	5e                   	pop    %esi
80101c2d:	5f                   	pop    %edi
80101c2e:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
80101c2f:	ff e0                	jmp    *%eax
80101c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
80101c38:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101c3b:	83 ec 0c             	sub    $0xc,%esp
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
    ip->size = off;
80101c3e:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101c41:	50                   	push   %eax
80101c42:	e8 59 fa ff ff       	call   801016a0 <iupdate>
80101c47:	83 c4 10             	add    $0x10,%esp
80101c4a:	eb b6                	jmp    80101c02 <writei+0xd2>
80101c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
80101c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c55:	eb ae                	jmp    80101c05 <writei+0xd5>
80101c57:	89 f6                	mov    %esi,%esi
80101c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101c60 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101c60:	55                   	push   %ebp
80101c61:	89 e5                	mov    %esp,%ebp
80101c63:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101c66:	6a 0e                	push   $0xe
80101c68:	ff 75 0c             	pushl  0xc(%ebp)
80101c6b:	ff 75 08             	pushl  0x8(%ebp)
80101c6e:	e8 0d 29 00 00       	call   80104580 <strncmp>
}
80101c73:	c9                   	leave  
80101c74:	c3                   	ret    
80101c75:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101c80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101c80:	55                   	push   %ebp
80101c81:	89 e5                	mov    %esp,%ebp
80101c83:	57                   	push   %edi
80101c84:	56                   	push   %esi
80101c85:	53                   	push   %ebx
80101c86:	83 ec 1c             	sub    $0x1c,%esp
80101c89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101c8c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101c91:	0f 85 80 00 00 00    	jne    80101d17 <dirlookup+0x97>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101c97:	8b 53 58             	mov    0x58(%ebx),%edx
80101c9a:	31 ff                	xor    %edi,%edi
80101c9c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101c9f:	85 d2                	test   %edx,%edx
80101ca1:	75 0d                	jne    80101cb0 <dirlookup+0x30>
80101ca3:	eb 5b                	jmp    80101d00 <dirlookup+0x80>
80101ca5:	8d 76 00             	lea    0x0(%esi),%esi
80101ca8:	83 c7 10             	add    $0x10,%edi
80101cab:	39 7b 58             	cmp    %edi,0x58(%ebx)
80101cae:	76 50                	jbe    80101d00 <dirlookup+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101cb0:	6a 10                	push   $0x10
80101cb2:	57                   	push   %edi
80101cb3:	56                   	push   %esi
80101cb4:	53                   	push   %ebx
80101cb5:	e8 76 fd ff ff       	call   80101a30 <readi>
80101cba:	83 c4 10             	add    $0x10,%esp
80101cbd:	83 f8 10             	cmp    $0x10,%eax
80101cc0:	75 48                	jne    80101d0a <dirlookup+0x8a>
      panic("dirlookup read");
    if(de.inum == 0)
80101cc2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101cc7:	74 df                	je     80101ca8 <dirlookup+0x28>
// Directories

int
namecmp(const char *s, const char *t)
{
  return strncmp(s, t, DIRSIZ);
80101cc9:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ccc:	83 ec 04             	sub    $0x4,%esp
80101ccf:	6a 0e                	push   $0xe
80101cd1:	50                   	push   %eax
80101cd2:	ff 75 0c             	pushl  0xc(%ebp)
80101cd5:	e8 a6 28 00 00       	call   80104580 <strncmp>
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
80101cda:	83 c4 10             	add    $0x10,%esp
80101cdd:	85 c0                	test   %eax,%eax
80101cdf:	75 c7                	jne    80101ca8 <dirlookup+0x28>
      // entry matches path element
      if(poff)
80101ce1:	8b 45 10             	mov    0x10(%ebp),%eax
80101ce4:	85 c0                	test   %eax,%eax
80101ce6:	74 05                	je     80101ced <dirlookup+0x6d>
        *poff = off;
80101ce8:	8b 45 10             	mov    0x10(%ebp),%eax
80101ceb:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
      return iget(dp->dev, inum);
80101ced:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
80101cf1:	8b 03                	mov    (%ebx),%eax
80101cf3:	e8 f8 f5 ff ff       	call   801012f0 <iget>
    }
  }

  return 0;
}
80101cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101cfb:	5b                   	pop    %ebx
80101cfc:	5e                   	pop    %esi
80101cfd:	5f                   	pop    %edi
80101cfe:	5d                   	pop    %ebp
80101cff:	c3                   	ret    
80101d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80101d03:	31 c0                	xor    %eax,%eax
}
80101d05:	5b                   	pop    %ebx
80101d06:	5e                   	pop    %esi
80101d07:	5f                   	pop    %edi
80101d08:	5d                   	pop    %ebp
80101d09:	c3                   	ret    
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
80101d0a:	83 ec 0c             	sub    $0xc,%esp
80101d0d:	68 59 71 10 80       	push   $0x80107159
80101d12:	e8 59 e6 ff ff       	call   80100370 <panic>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
80101d17:	83 ec 0c             	sub    $0xc,%esp
80101d1a:	68 47 71 10 80       	push   $0x80107147
80101d1f:	e8 4c e6 ff ff       	call   80100370 <panic>
80101d24:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101d2a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101d30 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101d30:	55                   	push   %ebp
80101d31:	89 e5                	mov    %esp,%ebp
80101d33:	57                   	push   %edi
80101d34:	56                   	push   %esi
80101d35:	53                   	push   %ebx
80101d36:	89 cf                	mov    %ecx,%edi
80101d38:	89 c3                	mov    %eax,%ebx
80101d3a:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101d3d:	80 38 2f             	cmpb   $0x2f,(%eax)
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101d40:	89 55 e0             	mov    %edx,-0x20(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101d43:	0f 84 53 01 00 00    	je     80101e9c <namex+0x16c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101d49:	e8 72 1a 00 00       	call   801037c0 <myproc>
// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  acquire(&icache.lock);
80101d4e:	83 ec 0c             	sub    $0xc,%esp
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101d51:	8b 70 68             	mov    0x68(%eax),%esi
// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
  acquire(&icache.lock);
80101d54:	68 e0 09 11 80       	push   $0x801109e0
80101d59:	e8 82 25 00 00       	call   801042e0 <acquire>
  ip->ref++;
80101d5e:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101d62:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101d69:	e8 92 26 00 00       	call   80104400 <release>
80101d6e:	83 c4 10             	add    $0x10,%esp
80101d71:	eb 08                	jmp    80101d7b <namex+0x4b>
80101d73:	90                   	nop
80101d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  char *s;
  int len;

  while(*path == '/')
    path++;
80101d78:	83 c3 01             	add    $0x1,%ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80101d7b:	0f b6 03             	movzbl (%ebx),%eax
80101d7e:	3c 2f                	cmp    $0x2f,%al
80101d80:	74 f6                	je     80101d78 <namex+0x48>
    path++;
  if(*path == 0)
80101d82:	84 c0                	test   %al,%al
80101d84:	0f 84 e3 00 00 00    	je     80101e6d <namex+0x13d>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101d8a:	0f b6 03             	movzbl (%ebx),%eax
80101d8d:	89 da                	mov    %ebx,%edx
80101d8f:	84 c0                	test   %al,%al
80101d91:	0f 84 ac 00 00 00    	je     80101e43 <namex+0x113>
80101d97:	3c 2f                	cmp    $0x2f,%al
80101d99:	75 09                	jne    80101da4 <namex+0x74>
80101d9b:	e9 a3 00 00 00       	jmp    80101e43 <namex+0x113>
80101da0:	84 c0                	test   %al,%al
80101da2:	74 0a                	je     80101dae <namex+0x7e>
    path++;
80101da4:	83 c2 01             	add    $0x1,%edx
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101da7:	0f b6 02             	movzbl (%edx),%eax
80101daa:	3c 2f                	cmp    $0x2f,%al
80101dac:	75 f2                	jne    80101da0 <namex+0x70>
80101dae:	89 d1                	mov    %edx,%ecx
80101db0:	29 d9                	sub    %ebx,%ecx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
80101db2:	83 f9 0d             	cmp    $0xd,%ecx
80101db5:	0f 8e 8d 00 00 00    	jle    80101e48 <namex+0x118>
    memmove(name, s, DIRSIZ);
80101dbb:	83 ec 04             	sub    $0x4,%esp
80101dbe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101dc1:	6a 0e                	push   $0xe
80101dc3:	53                   	push   %ebx
80101dc4:	57                   	push   %edi
80101dc5:	e8 36 27 00 00       	call   80104500 <memmove>
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80101dca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
80101dcd:	83 c4 10             	add    $0x10,%esp
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80101dd0:	89 d3                	mov    %edx,%ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101dd2:	80 3a 2f             	cmpb   $0x2f,(%edx)
80101dd5:	75 11                	jne    80101de8 <namex+0xb8>
80101dd7:	89 f6                	mov    %esi,%esi
80101dd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80101de0:	83 c3 01             	add    $0x1,%ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101de3:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101de6:	74 f8                	je     80101de0 <namex+0xb0>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101de8:	83 ec 0c             	sub    $0xc,%esp
80101deb:	56                   	push   %esi
80101dec:	e8 5f f9 ff ff       	call   80101750 <ilock>
    if(ip->type != T_DIR){
80101df1:	83 c4 10             	add    $0x10,%esp
80101df4:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101df9:	0f 85 7f 00 00 00    	jne    80101e7e <namex+0x14e>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101dff:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101e02:	85 d2                	test   %edx,%edx
80101e04:	74 09                	je     80101e0f <namex+0xdf>
80101e06:	80 3b 00             	cmpb   $0x0,(%ebx)
80101e09:	0f 84 a3 00 00 00    	je     80101eb2 <namex+0x182>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101e0f:	83 ec 04             	sub    $0x4,%esp
80101e12:	6a 00                	push   $0x0
80101e14:	57                   	push   %edi
80101e15:	56                   	push   %esi
80101e16:	e8 65 fe ff ff       	call   80101c80 <dirlookup>
80101e1b:	83 c4 10             	add    $0x10,%esp
80101e1e:	85 c0                	test   %eax,%eax
80101e20:	74 5c                	je     80101e7e <namex+0x14e>

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
80101e22:	83 ec 0c             	sub    $0xc,%esp
80101e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101e28:	56                   	push   %esi
80101e29:	e8 02 fa ff ff       	call   80101830 <iunlock>
  iput(ip);
80101e2e:	89 34 24             	mov    %esi,(%esp)
80101e31:	e8 4a fa ff ff       	call   80101880 <iput>
80101e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101e39:	83 c4 10             	add    $0x10,%esp
80101e3c:	89 c6                	mov    %eax,%esi
80101e3e:	e9 38 ff ff ff       	jmp    80101d7b <namex+0x4b>
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101e43:	31 c9                	xor    %ecx,%ecx
80101e45:	8d 76 00             	lea    0x0(%esi),%esi
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80101e48:	83 ec 04             	sub    $0x4,%esp
80101e4b:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101e4e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101e51:	51                   	push   %ecx
80101e52:	53                   	push   %ebx
80101e53:	57                   	push   %edi
80101e54:	e8 a7 26 00 00       	call   80104500 <memmove>
    name[len] = 0;
80101e59:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101e5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101e5f:	83 c4 10             	add    $0x10,%esp
80101e62:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
80101e66:	89 d3                	mov    %edx,%ebx
80101e68:	e9 65 ff ff ff       	jmp    80101dd2 <namex+0xa2>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101e70:	85 c0                	test   %eax,%eax
80101e72:	75 54                	jne    80101ec8 <namex+0x198>
80101e74:	89 f0                	mov    %esi,%eax
    iput(ip);
    return 0;
  }
  return ip;
}
80101e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e79:	5b                   	pop    %ebx
80101e7a:	5e                   	pop    %esi
80101e7b:	5f                   	pop    %edi
80101e7c:	5d                   	pop    %ebp
80101e7d:	c3                   	ret    

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
80101e7e:	83 ec 0c             	sub    $0xc,%esp
80101e81:	56                   	push   %esi
80101e82:	e8 a9 f9 ff ff       	call   80101830 <iunlock>
  iput(ip);
80101e87:	89 34 24             	mov    %esi,(%esp)
80101e8a:	e8 f1 f9 ff ff       	call   80101880 <iput>
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
      return 0;
80101e8f:	83 c4 10             	add    $0x10,%esp
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
      return 0;
80101e95:	31 c0                	xor    %eax,%eax
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101e97:	5b                   	pop    %ebx
80101e98:	5e                   	pop    %esi
80101e99:	5f                   	pop    %edi
80101e9a:	5d                   	pop    %ebp
80101e9b:	c3                   	ret    
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
80101e9c:	ba 01 00 00 00       	mov    $0x1,%edx
80101ea1:	b8 01 00 00 00       	mov    $0x1,%eax
80101ea6:	e8 45 f4 ff ff       	call   801012f0 <iget>
80101eab:	89 c6                	mov    %eax,%esi
80101ead:	e9 c9 fe ff ff       	jmp    80101d7b <namex+0x4b>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101eb2:	83 ec 0c             	sub    $0xc,%esp
80101eb5:	56                   	push   %esi
80101eb6:	e8 75 f9 ff ff       	call   80101830 <iunlock>
      return ip;
80101ebb:	83 c4 10             	add    $0x10,%esp
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
      return ip;
80101ec1:	89 f0                	mov    %esi,%eax
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101ec3:	5b                   	pop    %ebx
80101ec4:	5e                   	pop    %esi
80101ec5:	5f                   	pop    %edi
80101ec6:	5d                   	pop    %ebp
80101ec7:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
80101ec8:	83 ec 0c             	sub    $0xc,%esp
80101ecb:	56                   	push   %esi
80101ecc:	e8 af f9 ff ff       	call   80101880 <iput>
    return 0;
80101ed1:	83 c4 10             	add    $0x10,%esp
80101ed4:	31 c0                	xor    %eax,%eax
80101ed6:	eb 9e                	jmp    80101e76 <namex+0x146>
80101ed8:	90                   	nop
80101ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ee0 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80101ee0:	55                   	push   %ebp
80101ee1:	89 e5                	mov    %esp,%ebp
80101ee3:	57                   	push   %edi
80101ee4:	56                   	push   %esi
80101ee5:	53                   	push   %ebx
80101ee6:	83 ec 20             	sub    $0x20,%esp
80101ee9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80101eec:	6a 00                	push   $0x0
80101eee:	ff 75 0c             	pushl  0xc(%ebp)
80101ef1:	53                   	push   %ebx
80101ef2:	e8 89 fd ff ff       	call   80101c80 <dirlookup>
80101ef7:	83 c4 10             	add    $0x10,%esp
80101efa:	85 c0                	test   %eax,%eax
80101efc:	75 67                	jne    80101f65 <dirlink+0x85>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101efe:	8b 7b 58             	mov    0x58(%ebx),%edi
80101f01:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101f04:	85 ff                	test   %edi,%edi
80101f06:	74 29                	je     80101f31 <dirlink+0x51>
80101f08:	31 ff                	xor    %edi,%edi
80101f0a:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101f0d:	eb 09                	jmp    80101f18 <dirlink+0x38>
80101f0f:	90                   	nop
80101f10:	83 c7 10             	add    $0x10,%edi
80101f13:	39 7b 58             	cmp    %edi,0x58(%ebx)
80101f16:	76 19                	jbe    80101f31 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101f18:	6a 10                	push   $0x10
80101f1a:	57                   	push   %edi
80101f1b:	56                   	push   %esi
80101f1c:	53                   	push   %ebx
80101f1d:	e8 0e fb ff ff       	call   80101a30 <readi>
80101f22:	83 c4 10             	add    $0x10,%esp
80101f25:	83 f8 10             	cmp    $0x10,%eax
80101f28:	75 4e                	jne    80101f78 <dirlink+0x98>
      panic("dirlink read");
    if(de.inum == 0)
80101f2a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101f2f:	75 df                	jne    80101f10 <dirlink+0x30>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80101f31:	8d 45 da             	lea    -0x26(%ebp),%eax
80101f34:	83 ec 04             	sub    $0x4,%esp
80101f37:	6a 0e                	push   $0xe
80101f39:	ff 75 0c             	pushl  0xc(%ebp)
80101f3c:	50                   	push   %eax
80101f3d:	e8 ae 26 00 00       	call   801045f0 <strncpy>
  de.inum = inum;
80101f42:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101f45:	6a 10                	push   $0x10
80101f47:	57                   	push   %edi
80101f48:	56                   	push   %esi
80101f49:	53                   	push   %ebx
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
80101f4a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101f4e:	e8 dd fb ff ff       	call   80101b30 <writei>
80101f53:	83 c4 20             	add    $0x20,%esp
80101f56:	83 f8 10             	cmp    $0x10,%eax
80101f59:	75 2a                	jne    80101f85 <dirlink+0xa5>
    panic("dirlink");

  return 0;
80101f5b:	31 c0                	xor    %eax,%eax
}
80101f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f60:	5b                   	pop    %ebx
80101f61:	5e                   	pop    %esi
80101f62:	5f                   	pop    %edi
80101f63:	5d                   	pop    %ebp
80101f64:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
80101f65:	83 ec 0c             	sub    $0xc,%esp
80101f68:	50                   	push   %eax
80101f69:	e8 12 f9 ff ff       	call   80101880 <iput>
    return -1;
80101f6e:	83 c4 10             	add    $0x10,%esp
80101f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f76:	eb e5                	jmp    80101f5d <dirlink+0x7d>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
80101f78:	83 ec 0c             	sub    $0xc,%esp
80101f7b:	68 68 71 10 80       	push   $0x80107168
80101f80:	e8 eb e3 ff ff       	call   80100370 <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
80101f85:	83 ec 0c             	sub    $0xc,%esp
80101f88:	68 66 77 10 80       	push   $0x80107766
80101f8d:	e8 de e3 ff ff       	call   80100370 <panic>
80101f92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fa0 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
80101fa0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101fa1:	31 d2                	xor    %edx,%edx
  return ip;
}

struct inode*
namei(char *path)
{
80101fa3:	89 e5                	mov    %esp,%ebp
80101fa5:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fab:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101fae:	e8 7d fd ff ff       	call   80101d30 <namex>
}
80101fb3:	c9                   	leave  
80101fb4:	c3                   	ret    
80101fb5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101fb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101fc0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101fc0:	55                   	push   %ebp
  return namex(path, 1, name);
80101fc1:	ba 01 00 00 00       	mov    $0x1,%edx
  return namex(path, 0, name);
}

struct inode*
nameiparent(char *path, char *name)
{
80101fc6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101fce:	5d                   	pop    %ebp
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
80101fcf:	e9 5c fd ff ff       	jmp    80101d30 <namex>
80101fd4:	66 90                	xchg   %ax,%ax
80101fd6:	66 90                	xchg   %ax,%ax
80101fd8:	66 90                	xchg   %ax,%ax
80101fda:	66 90                	xchg   %ax,%ax
80101fdc:	66 90                	xchg   %ax,%ax
80101fde:	66 90                	xchg   %ax,%ax

80101fe0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101fe0:	55                   	push   %ebp
  if(b == 0)
80101fe1:	85 c0                	test   %eax,%eax
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101fe3:	89 e5                	mov    %esp,%ebp
80101fe5:	56                   	push   %esi
80101fe6:	53                   	push   %ebx
  if(b == 0)
80101fe7:	0f 84 ad 00 00 00    	je     8010209a <idestart+0xba>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101fed:	8b 58 08             	mov    0x8(%eax),%ebx
80101ff0:	89 c1                	mov    %eax,%ecx
80101ff2:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101ff8:	0f 87 8f 00 00 00    	ja     8010208d <idestart+0xad>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101ffe:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102003:	90                   	nop
80102004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102008:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102009:	83 e0 c0             	and    $0xffffffc0,%eax
8010200c:	3c 40                	cmp    $0x40,%al
8010200e:	75 f8                	jne    80102008 <idestart+0x28>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102010:	31 f6                	xor    %esi,%esi
80102012:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102017:	89 f0                	mov    %esi,%eax
80102019:	ee                   	out    %al,(%dx)
8010201a:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010201f:	b8 01 00 00 00       	mov    $0x1,%eax
80102024:	ee                   	out    %al,(%dx)
80102025:	ba f3 01 00 00       	mov    $0x1f3,%edx
8010202a:	89 d8                	mov    %ebx,%eax
8010202c:	ee                   	out    %al,(%dx)
8010202d:	89 d8                	mov    %ebx,%eax
8010202f:	ba f4 01 00 00       	mov    $0x1f4,%edx
80102034:	c1 f8 08             	sar    $0x8,%eax
80102037:	ee                   	out    %al,(%dx)
80102038:	ba f5 01 00 00       	mov    $0x1f5,%edx
8010203d:	89 f0                	mov    %esi,%eax
8010203f:	ee                   	out    %al,(%dx)
80102040:	0f b6 41 04          	movzbl 0x4(%ecx),%eax
80102044:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102049:	83 e0 01             	and    $0x1,%eax
8010204c:	c1 e0 04             	shl    $0x4,%eax
8010204f:	83 c8 e0             	or     $0xffffffe0,%eax
80102052:	ee                   	out    %al,(%dx)
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
80102053:	f6 01 04             	testb  $0x4,(%ecx)
80102056:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010205b:	75 13                	jne    80102070 <idestart+0x90>
8010205d:	b8 20 00 00 00       	mov    $0x20,%eax
80102062:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102063:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102066:	5b                   	pop    %ebx
80102067:	5e                   	pop    %esi
80102068:	5d                   	pop    %ebp
80102069:	c3                   	ret    
8010206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102070:	b8 30 00 00 00       	mov    $0x30,%eax
80102075:	ee                   	out    %al,(%dx)
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
80102076:	ba f0 01 00 00       	mov    $0x1f0,%edx
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
8010207b:	8d 71 5c             	lea    0x5c(%ecx),%esi
8010207e:	b9 80 00 00 00       	mov    $0x80,%ecx
80102083:	fc                   	cld    
80102084:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102086:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102089:	5b                   	pop    %ebx
8010208a:	5e                   	pop    %esi
8010208b:	5d                   	pop    %ebp
8010208c:	c3                   	ret    
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  if(b->blockno >= FSSIZE)
    panic("incorrect blockno");
8010208d:	83 ec 0c             	sub    $0xc,%esp
80102090:	68 d4 71 10 80       	push   $0x801071d4
80102095:	e8 d6 e2 ff ff       	call   80100370 <panic>
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
8010209a:	83 ec 0c             	sub    $0xc,%esp
8010209d:	68 cb 71 10 80       	push   $0x801071cb
801020a2:	e8 c9 e2 ff ff       	call   80100370 <panic>
801020a7:	89 f6                	mov    %esi,%esi
801020a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801020b0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
801020b0:	55                   	push   %ebp
801020b1:	89 e5                	mov    %esp,%ebp
801020b3:	83 ec 10             	sub    $0x10,%esp
  int i;

  initlock(&idelock, "ide");
801020b6:	68 e6 71 10 80       	push   $0x801071e6
801020bb:	68 80 a5 10 80       	push   $0x8010a580
801020c0:	e8 1b 21 00 00       	call   801041e0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801020c5:	58                   	pop    %eax
801020c6:	a1 00 2d 11 80       	mov    0x80112d00,%eax
801020cb:	5a                   	pop    %edx
801020cc:	83 e8 01             	sub    $0x1,%eax
801020cf:	50                   	push   %eax
801020d0:	6a 0e                	push   $0xe
801020d2:	e8 a9 02 00 00       	call   80102380 <ioapicenable>
801020d7:	83 c4 10             	add    $0x10,%esp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801020da:	ba f7 01 00 00       	mov    $0x1f7,%edx
801020df:	90                   	nop
801020e0:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801020e1:	83 e0 c0             	and    $0xffffffc0,%eax
801020e4:	3c 40                	cmp    $0x40,%al
801020e6:	75 f8                	jne    801020e0 <ideinit+0x30>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801020e8:	ba f6 01 00 00       	mov    $0x1f6,%edx
801020ed:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
801020f2:	ee                   	out    %al,(%dx)
801020f3:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801020f8:	ba f7 01 00 00       	mov    $0x1f7,%edx
801020fd:	eb 06                	jmp    80102105 <ideinit+0x55>
801020ff:	90                   	nop
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102100:	83 e9 01             	sub    $0x1,%ecx
80102103:	74 0f                	je     80102114 <ideinit+0x64>
80102105:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102106:	84 c0                	test   %al,%al
80102108:	74 f6                	je     80102100 <ideinit+0x50>
      havedisk1 = 1;
8010210a:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80102111:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102114:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102119:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
8010211e:	ee                   	out    %al,(%dx)
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
8010211f:	c9                   	leave  
80102120:	c3                   	ret    
80102121:	eb 0d                	jmp    80102130 <ideintr>
80102123:	90                   	nop
80102124:	90                   	nop
80102125:	90                   	nop
80102126:	90                   	nop
80102127:	90                   	nop
80102128:	90                   	nop
80102129:	90                   	nop
8010212a:	90                   	nop
8010212b:	90                   	nop
8010212c:	90                   	nop
8010212d:	90                   	nop
8010212e:	90                   	nop
8010212f:	90                   	nop

80102130 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
80102130:	55                   	push   %ebp
80102131:	89 e5                	mov    %esp,%ebp
80102133:	57                   	push   %edi
80102134:	56                   	push   %esi
80102135:	53                   	push   %ebx
80102136:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102139:	68 80 a5 10 80       	push   $0x8010a580
8010213e:	e8 9d 21 00 00       	call   801042e0 <acquire>

  if((b = idequeue) == 0){
80102143:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80102149:	83 c4 10             	add    $0x10,%esp
8010214c:	85 db                	test   %ebx,%ebx
8010214e:	74 34                	je     80102184 <ideintr+0x54>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102150:	8b 43 58             	mov    0x58(%ebx),%eax
80102153:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102158:	8b 33                	mov    (%ebx),%esi
8010215a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102160:	74 3e                	je     801021a0 <ideintr+0x70>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80102162:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
80102165:	83 ec 0c             	sub    $0xc,%esp
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80102168:	83 ce 02             	or     $0x2,%esi
8010216b:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
8010216d:	53                   	push   %ebx
8010216e:	e8 ad 1d 00 00       	call   80103f20 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102173:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80102178:	83 c4 10             	add    $0x10,%esp
8010217b:	85 c0                	test   %eax,%eax
8010217d:	74 05                	je     80102184 <ideintr+0x54>
    idestart(idequeue);
8010217f:	e8 5c fe ff ff       	call   80101fe0 <idestart>

  // First queued buffer is the active request.
  acquire(&idelock);

  if((b = idequeue) == 0){
    release(&idelock);
80102184:	83 ec 0c             	sub    $0xc,%esp
80102187:	68 80 a5 10 80       	push   $0x8010a580
8010218c:	e8 6f 22 00 00       	call   80104400 <release>
  // Start disk on next buf in queue.
  if(idequeue != 0)
    idestart(idequeue);

  release(&idelock);
}
80102191:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102194:	5b                   	pop    %ebx
80102195:	5e                   	pop    %esi
80102196:	5f                   	pop    %edi
80102197:	5d                   	pop    %ebp
80102198:	c3                   	ret    
80102199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021a0:	ba f7 01 00 00       	mov    $0x1f7,%edx
801021a5:	8d 76 00             	lea    0x0(%esi),%esi
801021a8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021a9:	89 c1                	mov    %eax,%ecx
801021ab:	83 e1 c0             	and    $0xffffffc0,%ecx
801021ae:	80 f9 40             	cmp    $0x40,%cl
801021b1:	75 f5                	jne    801021a8 <ideintr+0x78>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801021b3:	a8 21                	test   $0x21,%al
801021b5:	75 ab                	jne    80102162 <ideintr+0x32>
  }
  idequeue = b->qnext;

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
    insl(0x1f0, b->data, BSIZE/4);
801021b7:	8d 7b 5c             	lea    0x5c(%ebx),%edi
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
801021ba:	b9 80 00 00 00       	mov    $0x80,%ecx
801021bf:	ba f0 01 00 00       	mov    $0x1f0,%edx
801021c4:	fc                   	cld    
801021c5:	f3 6d                	rep insl (%dx),%es:(%edi)
801021c7:	8b 33                	mov    (%ebx),%esi
801021c9:	eb 97                	jmp    80102162 <ideintr+0x32>
801021cb:	90                   	nop
801021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801021d0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801021d0:	55                   	push   %ebp
801021d1:	89 e5                	mov    %esp,%ebp
801021d3:	53                   	push   %ebx
801021d4:	83 ec 10             	sub    $0x10,%esp
801021d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801021da:	8d 43 0c             	lea    0xc(%ebx),%eax
801021dd:	50                   	push   %eax
801021de:	e8 cd 1f 00 00       	call   801041b0 <holdingsleep>
801021e3:	83 c4 10             	add    $0x10,%esp
801021e6:	85 c0                	test   %eax,%eax
801021e8:	0f 84 ad 00 00 00    	je     8010229b <iderw+0xcb>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801021ee:	8b 03                	mov    (%ebx),%eax
801021f0:	83 e0 06             	and    $0x6,%eax
801021f3:	83 f8 02             	cmp    $0x2,%eax
801021f6:	0f 84 b9 00 00 00    	je     801022b5 <iderw+0xe5>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
801021fc:	8b 53 04             	mov    0x4(%ebx),%edx
801021ff:	85 d2                	test   %edx,%edx
80102201:	74 0d                	je     80102210 <iderw+0x40>
80102203:	a1 60 a5 10 80       	mov    0x8010a560,%eax
80102208:	85 c0                	test   %eax,%eax
8010220a:	0f 84 98 00 00 00    	je     801022a8 <iderw+0xd8>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102210:	83 ec 0c             	sub    $0xc,%esp
80102213:	68 80 a5 10 80       	push   $0x8010a580
80102218:	e8 c3 20 00 00       	call   801042e0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010221d:	8b 15 64 a5 10 80    	mov    0x8010a564,%edx
80102223:	83 c4 10             	add    $0x10,%esp
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
80102226:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010222d:	85 d2                	test   %edx,%edx
8010222f:	75 09                	jne    8010223a <iderw+0x6a>
80102231:	eb 58                	jmp    8010228b <iderw+0xbb>
80102233:	90                   	nop
80102234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102238:	89 c2                	mov    %eax,%edx
8010223a:	8b 42 58             	mov    0x58(%edx),%eax
8010223d:	85 c0                	test   %eax,%eax
8010223f:	75 f7                	jne    80102238 <iderw+0x68>
80102241:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
80102244:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80102246:	3b 1d 64 a5 10 80    	cmp    0x8010a564,%ebx
8010224c:	74 44                	je     80102292 <iderw+0xc2>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010224e:	8b 03                	mov    (%ebx),%eax
80102250:	83 e0 06             	and    $0x6,%eax
80102253:	83 f8 02             	cmp    $0x2,%eax
80102256:	74 23                	je     8010227b <iderw+0xab>
80102258:	90                   	nop
80102259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(b, &idelock);
80102260:	83 ec 08             	sub    $0x8,%esp
80102263:	68 80 a5 10 80       	push   $0x8010a580
80102268:	53                   	push   %ebx
80102269:	e8 02 1b 00 00       	call   80103d70 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010226e:	8b 03                	mov    (%ebx),%eax
80102270:	83 c4 10             	add    $0x10,%esp
80102273:	83 e0 06             	and    $0x6,%eax
80102276:	83 f8 02             	cmp    $0x2,%eax
80102279:	75 e5                	jne    80102260 <iderw+0x90>
    sleep(b, &idelock);
  }


  release(&idelock);
8010227b:	c7 45 08 80 a5 10 80 	movl   $0x8010a580,0x8(%ebp)
}
80102282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102285:	c9                   	leave  
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }


  release(&idelock);
80102286:	e9 75 21 00 00       	jmp    80104400 <release>

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010228b:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80102290:	eb b2                	jmp    80102244 <iderw+0x74>
    ;
  *pp = b;

  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
80102292:	89 d8                	mov    %ebx,%eax
80102294:	e8 47 fd ff ff       	call   80101fe0 <idestart>
80102299:	eb b3                	jmp    8010224e <iderw+0x7e>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
8010229b:	83 ec 0c             	sub    $0xc,%esp
8010229e:	68 ea 71 10 80       	push   $0x801071ea
801022a3:	e8 c8 e0 ff ff       	call   80100370 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	68 15 72 10 80       	push   $0x80107215
801022b0:	e8 bb e0 ff ff       	call   80100370 <panic>
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
801022b5:	83 ec 0c             	sub    $0xc,%esp
801022b8:	68 00 72 10 80       	push   $0x80107200
801022bd:	e8 ae e0 ff ff       	call   80100370 <panic>
801022c2:	66 90                	xchg   %ax,%ax
801022c4:	66 90                	xchg   %ax,%ax
801022c6:	66 90                	xchg   %ax,%ax
801022c8:	66 90                	xchg   %ax,%ax
801022ca:	66 90                	xchg   %ax,%ax
801022cc:	66 90                	xchg   %ax,%ax
801022ce:	66 90                	xchg   %ax,%ax

801022d0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801022d0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801022d1:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
801022d8:	00 c0 fe 
  ioapic->data = data;
}

void
ioapicinit(void)
{
801022db:	89 e5                	mov    %esp,%ebp
801022dd:	56                   	push   %esi
801022de:	53                   	push   %ebx
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
801022df:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801022e6:	00 00 00 
  return ioapic->data;
801022e9:	8b 15 34 26 11 80    	mov    0x80112634,%edx
801022ef:	8b 72 10             	mov    0x10(%edx),%esi
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
801022f2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
801022f8:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
801022fe:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
ioapicinit(void)
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102305:	89 f0                	mov    %esi,%eax
80102307:	c1 e8 10             	shr    $0x10,%eax
8010230a:	0f b6 f0             	movzbl %al,%esi

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
  return ioapic->data;
8010230d:	8b 41 10             	mov    0x10(%ecx),%eax
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102310:	c1 e8 18             	shr    $0x18,%eax
80102313:	39 d0                	cmp    %edx,%eax
80102315:	74 16                	je     8010232d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102317:	83 ec 0c             	sub    $0xc,%esp
8010231a:	68 34 72 10 80       	push   $0x80107234
8010231f:	e8 3c e3 ff ff       	call   80100660 <cprintf>
80102324:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
8010232a:	83 c4 10             	add    $0x10,%esp
8010232d:	83 c6 21             	add    $0x21,%esi
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102330:	ba 10 00 00 00       	mov    $0x10,%edx
80102335:	b8 20 00 00 00       	mov    $0x20,%eax
8010233a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102340:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102342:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102348:	89 c3                	mov    %eax,%ebx
8010234a:	81 cb 00 00 01 00    	or     $0x10000,%ebx
80102350:	83 c0 01             	add    $0x1,%eax

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
80102353:	89 59 10             	mov    %ebx,0x10(%ecx)
80102356:	8d 5a 01             	lea    0x1(%edx),%ebx
80102359:	83 c2 02             	add    $0x2,%edx
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010235c:	39 f0                	cmp    %esi,%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
8010235e:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
80102360:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102366:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010236d:	75 d1                	jne    80102340 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010236f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102372:	5b                   	pop    %ebx
80102373:	5e                   	pop    %esi
80102374:	5d                   	pop    %ebp
80102375:	c3                   	ret    
80102376:	8d 76 00             	lea    0x0(%esi),%esi
80102379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102380 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102380:	55                   	push   %ebp
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102381:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  }
}

void
ioapicenable(int irq, int cpunum)
{
80102387:	89 e5                	mov    %esp,%ebp
80102389:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010238c:	8d 50 20             	lea    0x20(%eax),%edx
8010238f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102393:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102395:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
8010239b:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
8010239e:	89 51 10             	mov    %edx,0x10(%ecx)
{
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801023a1:	8b 55 0c             	mov    0xc(%ebp),%edx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
801023a4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801023a6:	a1 34 26 11 80       	mov    0x80112634,%eax
{
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801023ab:	c1 e2 18             	shl    $0x18,%edx

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
  ioapic->data = data;
801023ae:	89 50 10             	mov    %edx,0x10(%eax)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801023b1:	5d                   	pop    %ebp
801023b2:	c3                   	ret    

801023b3 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801023b3:	55                   	push   %ebp
801023b4:	89 e5                	mov    %esp,%ebp
801023b6:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801023b9:	83 ec 08             	sub    $0x8,%esp
801023bc:	68 66 72 10 80       	push   $0x80107266
801023c1:	68 40 26 11 80       	push   $0x80112640
801023c6:	e8 15 1e 00 00       	call   801041e0 <initlock>
801023cb:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801023ce:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
801023d5:	00 00 00 
  freerange(vstart, vend);
801023d8:	83 ec 08             	sub    $0x8,%esp
801023db:	ff 75 0c             	pushl  0xc(%ebp)
801023de:	ff 75 08             	pushl  0x8(%ebp)
801023e1:	e8 2a 00 00 00       	call   80102410 <freerange>
801023e6:	83 c4 10             	add    $0x10,%esp
}
801023e9:	90                   	nop
801023ea:	c9                   	leave  
801023eb:	c3                   	ret    

801023ec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801023ec:	55                   	push   %ebp
801023ed:	89 e5                	mov    %esp,%ebp
801023ef:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801023f2:	83 ec 08             	sub    $0x8,%esp
801023f5:	ff 75 0c             	pushl  0xc(%ebp)
801023f8:	ff 75 08             	pushl  0x8(%ebp)
801023fb:	e8 10 00 00 00       	call   80102410 <freerange>
80102400:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102403:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
8010240a:	00 00 00 
}
8010240d:	90                   	nop
8010240e:	c9                   	leave  
8010240f:	c3                   	ret    

80102410 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102410:	55                   	push   %ebp
80102411:	89 e5                	mov    %esp,%ebp
80102413:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102416:	8b 45 08             	mov    0x8(%ebp),%eax
80102419:	05 ff 0f 00 00       	add    $0xfff,%eax
8010241e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102423:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102426:	eb 15                	jmp    8010243d <freerange+0x2d>
    kfree(p);
80102428:	83 ec 0c             	sub    $0xc,%esp
8010242b:	ff 75 f4             	pushl  -0xc(%ebp)
8010242e:	e8 1a 00 00 00       	call   8010244d <kfree>
80102433:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102436:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010243d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102440:	05 00 10 00 00       	add    $0x1000,%eax
80102445:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102448:	76 de                	jbe    80102428 <freerange+0x18>
    kfree(p);
}
8010244a:	90                   	nop
8010244b:	c9                   	leave  
8010244c:	c3                   	ret    

8010244d <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010244d:	55                   	push   %ebp
8010244e:	89 e5                	mov    %esp,%ebp
80102450:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	25 ff 0f 00 00       	and    $0xfff,%eax
8010245b:	85 c0                	test   %eax,%eax
8010245d:	75 18                	jne    80102477 <kfree+0x2a>
8010245f:	81 7d 08 f4 57 11 80 	cmpl   $0x801157f4,0x8(%ebp)
80102466:	72 0f                	jb     80102477 <kfree+0x2a>
80102468:	8b 45 08             	mov    0x8(%ebp),%eax
8010246b:	05 00 00 00 80       	add    $0x80000000,%eax
80102470:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102475:	76 0d                	jbe    80102484 <kfree+0x37>
    panic("kfree");
80102477:	83 ec 0c             	sub    $0xc,%esp
8010247a:	68 6b 72 10 80       	push   $0x8010726b
8010247f:	e8 ec de ff ff       	call   80100370 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102484:	83 ec 04             	sub    $0x4,%esp
80102487:	68 00 10 00 00       	push   $0x1000
8010248c:	6a 01                	push   $0x1
8010248e:	ff 75 08             	pushl  0x8(%ebp)
80102491:	e8 ba 1f 00 00       	call   80104450 <memset>
80102496:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102499:	a1 74 26 11 80       	mov    0x80112674,%eax
8010249e:	85 c0                	test   %eax,%eax
801024a0:	74 10                	je     801024b2 <kfree+0x65>
    acquire(&kmem.lock);
801024a2:	83 ec 0c             	sub    $0xc,%esp
801024a5:	68 40 26 11 80       	push   $0x80112640
801024aa:	e8 31 1e 00 00       	call   801042e0 <acquire>
801024af:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801024b2:	8b 45 08             	mov    0x8(%ebp),%eax
801024b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801024b8:	8b 15 78 26 11 80    	mov    0x80112678,%edx
801024be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c6:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
801024cb:	a1 74 26 11 80       	mov    0x80112674,%eax
801024d0:	85 c0                	test   %eax,%eax
801024d2:	74 10                	je     801024e4 <kfree+0x97>
    release(&kmem.lock);
801024d4:	83 ec 0c             	sub    $0xc,%esp
801024d7:	68 40 26 11 80       	push   $0x80112640
801024dc:	e8 1f 1f 00 00       	call   80104400 <release>
801024e1:	83 c4 10             	add    $0x10,%esp
}
801024e4:	90                   	nop
801024e5:	c9                   	leave  
801024e6:	c3                   	ret    

801024e7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801024e7:	55                   	push   %ebp
801024e8:	89 e5                	mov    %esp,%ebp
801024ea:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801024ed:	a1 74 26 11 80       	mov    0x80112674,%eax
801024f2:	85 c0                	test   %eax,%eax
801024f4:	74 10                	je     80102506 <kalloc+0x1f>
    acquire(&kmem.lock);
801024f6:	83 ec 0c             	sub    $0xc,%esp
801024f9:	68 40 26 11 80       	push   $0x80112640
801024fe:	e8 dd 1d 00 00       	call   801042e0 <acquire>
80102503:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102506:	a1 78 26 11 80       	mov    0x80112678,%eax
8010250b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010250e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102512:	74 0a                	je     8010251e <kalloc+0x37>
    kmem.freelist = r->next;
80102514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102517:	8b 00                	mov    (%eax),%eax
80102519:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
8010251e:	a1 74 26 11 80       	mov    0x80112674,%eax
80102523:	85 c0                	test   %eax,%eax
80102525:	74 10                	je     80102537 <kalloc+0x50>
    release(&kmem.lock);
80102527:	83 ec 0c             	sub    $0xc,%esp
8010252a:	68 40 26 11 80       	push   $0x80112640
8010252f:	e8 cc 1e 00 00       	call   80104400 <release>
80102534:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102537:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010253a:	c9                   	leave  
8010253b:	c3                   	ret    
8010253c:	66 90                	xchg   %ax,%ax
8010253e:	66 90                	xchg   %ax,%ax

80102540 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102540:	55                   	push   %ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102541:	ba 64 00 00 00       	mov    $0x64,%edx
80102546:	89 e5                	mov    %esp,%ebp
80102548:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102549:	a8 01                	test   $0x1,%al
8010254b:	0f 84 af 00 00 00    	je     80102600 <kbdgetc+0xc0>
80102551:	ba 60 00 00 00       	mov    $0x60,%edx
80102556:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102557:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010255a:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102560:	74 7e                	je     801025e0 <kbdgetc+0xa0>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102562:	84 c0                	test   %al,%al
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102564:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010256a:	79 24                	jns    80102590 <kbdgetc+0x50>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010256c:	f6 c1 40             	test   $0x40,%cl
8010256f:	75 05                	jne    80102576 <kbdgetc+0x36>
80102571:	89 c2                	mov    %eax,%edx
80102573:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102576:	0f b6 82 a0 73 10 80 	movzbl -0x7fef8c60(%edx),%eax
8010257d:	83 c8 40             	or     $0x40,%eax
80102580:	0f b6 c0             	movzbl %al,%eax
80102583:	f7 d0                	not    %eax
80102585:	21 c8                	and    %ecx,%eax
80102587:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
8010258c:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010258e:	5d                   	pop    %ebp
8010258f:	c3                   	ret    
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102590:	f6 c1 40             	test   $0x40,%cl
80102593:	74 09                	je     8010259e <kbdgetc+0x5e>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102595:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102598:	83 e1 bf             	and    $0xffffffbf,%ecx
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010259b:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
8010259e:	0f b6 82 a0 73 10 80 	movzbl -0x7fef8c60(%edx),%eax
801025a5:	09 c1                	or     %eax,%ecx
801025a7:	0f b6 82 a0 72 10 80 	movzbl -0x7fef8d60(%edx),%eax
801025ae:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
801025b0:	89 c8                	mov    %ecx,%eax
    data |= 0x80;
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
801025b2:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801025b8:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
801025bb:	83 e1 08             	and    $0x8,%ecx
    shift &= ~E0ESC;
  }

  shift |= shiftcode[data];
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
801025be:	8b 04 85 80 72 10 80 	mov    -0x7fef8d80(,%eax,4),%eax
801025c5:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801025c9:	74 c3                	je     8010258e <kbdgetc+0x4e>
    if('a' <= c && c <= 'z')
801025cb:	8d 50 9f             	lea    -0x61(%eax),%edx
801025ce:	83 fa 19             	cmp    $0x19,%edx
801025d1:	77 1d                	ja     801025f0 <kbdgetc+0xb0>
      c += 'A' - 'a';
801025d3:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801025d6:	5d                   	pop    %ebp
801025d7:	c3                   	ret    
801025d8:	90                   	nop
801025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
    return 0;
801025e0:	31 c0                	xor    %eax,%eax
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801025e2:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret    
801025eb:	90                   	nop
801025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
801025f0:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801025f3:	8d 50 20             	lea    0x20(%eax),%edx
  }
  return c;
}
801025f6:	5d                   	pop    %ebp
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
801025f7:	83 f9 19             	cmp    $0x19,%ecx
801025fa:	0f 46 c2             	cmovbe %edx,%eax
  }
  return c;
}
801025fd:	c3                   	ret    
801025fe:	66 90                	xchg   %ax,%ax
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
    return -1;
80102600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102605:	5d                   	pop    %ebp
80102606:	c3                   	ret    
80102607:	89 f6                	mov    %esi,%esi
80102609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102610 <kbdintr>:

void
kbdintr(void)
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102616:	68 40 25 10 80       	push   $0x80102540
8010261b:	e8 d0 e1 ff ff       	call   801007f0 <consoleintr>
}
80102620:	83 c4 10             	add    $0x10,%esp
80102623:	c9                   	leave  
80102624:	c3                   	ret    
80102625:	66 90                	xchg   %ax,%ax
80102627:	66 90                	xchg   %ax,%ax
80102629:	66 90                	xchg   %ax,%ax
8010262b:	66 90                	xchg   %ax,%ax
8010262d:	66 90                	xchg   %ax,%ax
8010262f:	90                   	nop

80102630 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102630:	a1 7c 26 11 80       	mov    0x8011267c,%eax
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
80102635:	55                   	push   %ebp
80102636:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102638:	85 c0                	test   %eax,%eax
8010263a:	0f 84 c8 00 00 00    	je     80102708 <lapicinit+0xd8>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102640:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102647:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010264a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010264d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102654:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102657:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010265a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102661:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102664:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102667:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010266e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102671:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102674:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010267b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010267e:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102681:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102688:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010268b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010268e:	8b 50 30             	mov    0x30(%eax),%edx
80102691:	c1 ea 10             	shr    $0x10,%edx
80102694:	80 fa 03             	cmp    $0x3,%dl
80102697:	77 77                	ja     80102710 <lapicinit+0xe0>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102699:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801026a0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026a3:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026a6:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026ad:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026b0:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026b3:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801026ba:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026bd:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026c0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801026c7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026ca:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026cd:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801026d4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801026d7:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026da:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801026e1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801026e4:	8b 50 20             	mov    0x20(%eax),%edx
801026e7:	89 f6                	mov    %esi,%esi
801026e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801026f0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801026f6:	80 e6 10             	and    $0x10,%dh
801026f9:	75 f5                	jne    801026f0 <lapicinit+0xc0>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801026fb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102702:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102705:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102708:	5d                   	pop    %ebp
80102709:	c3                   	ret    
8010270a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102710:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102717:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010271a:	8b 50 20             	mov    0x20(%eax),%edx
8010271d:	e9 77 ff ff ff       	jmp    80102699 <lapicinit+0x69>
80102722:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102730 <lapicid>:
}

int
lapicid(void)
{
  if (!lapic)
80102730:	a1 7c 26 11 80       	mov    0x8011267c,%eax
  lapicw(TPR, 0);
}

int
lapicid(void)
{
80102735:	55                   	push   %ebp
80102736:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102738:	85 c0                	test   %eax,%eax
8010273a:	74 0c                	je     80102748 <lapicid+0x18>
    return 0;
  return lapic[ID] >> 24;
8010273c:	8b 40 20             	mov    0x20(%eax),%eax
}
8010273f:	5d                   	pop    %ebp
int
lapicid(void)
{
  if (!lapic)
    return 0;
  return lapic[ID] >> 24;
80102740:	c1 e8 18             	shr    $0x18,%eax
}
80102743:	c3                   	ret    
80102744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

int
lapicid(void)
{
  if (!lapic)
    return 0;
80102748:	31 c0                	xor    %eax,%eax
  return lapic[ID] >> 24;
}
8010274a:	5d                   	pop    %ebp
8010274b:	c3                   	ret    
8010274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102750 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102750:	a1 7c 26 11 80       	mov    0x8011267c,%eax
}

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102755:	55                   	push   %ebp
80102756:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102758:	85 c0                	test   %eax,%eax
8010275a:	74 0d                	je     80102769 <lapiceoi+0x19>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010275c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102763:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102766:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
80102769:	5d                   	pop    %ebp
8010276a:	c3                   	ret    
8010276b:	90                   	nop
8010276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102770 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102770:	55                   	push   %ebp
80102771:	89 e5                	mov    %esp,%ebp
}
80102773:	5d                   	pop    %ebp
80102774:	c3                   	ret    
80102775:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102780 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102780:	55                   	push   %ebp
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102781:	ba 70 00 00 00       	mov    $0x70,%edx
80102786:	b8 0f 00 00 00       	mov    $0xf,%eax
8010278b:	89 e5                	mov    %esp,%ebp
8010278d:	53                   	push   %ebx
8010278e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102791:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102794:	ee                   	out    %al,(%dx)
80102795:	ba 71 00 00 00       	mov    $0x71,%edx
8010279a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010279f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
801027a0:	31 c0                	xor    %eax,%eax

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027a2:	c1 e3 18             	shl    $0x18,%ebx
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
801027a5:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
801027ab:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
801027ad:	c1 e9 0c             	shr    $0xc,%ecx
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
801027b0:	c1 e8 04             	shr    $0x4,%eax

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027b3:	89 da                	mov    %ebx,%edx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
801027b5:	80 cd 06             	or     $0x6,%ch
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
  wrv[1] = addr >> 4;
801027b8:	66 a3 69 04 00 80    	mov    %ax,0x80000469

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027be:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801027c3:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801027c9:	8b 58 20             	mov    0x20(%eax),%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027cc:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
801027d3:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027d6:	8b 58 20             	mov    0x20(%eax),%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027d9:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
801027e0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027e3:	8b 58 20             	mov    0x20(%eax),%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027e6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801027ec:	8b 58 20             	mov    0x20(%eax),%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027ef:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801027f5:	8b 58 20             	mov    0x20(%eax),%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801027f8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801027fe:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102801:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102807:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010280a:	5b                   	pop    %ebx
8010280b:	5d                   	pop    %ebp
8010280c:	c3                   	ret    
8010280d:	8d 76 00             	lea    0x0(%esi),%esi

80102810 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102810:	55                   	push   %ebp
80102811:	ba 70 00 00 00       	mov    $0x70,%edx
80102816:	b8 0b 00 00 00       	mov    $0xb,%eax
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	57                   	push   %edi
8010281e:	56                   	push   %esi
8010281f:	53                   	push   %ebx
80102820:	83 ec 4c             	sub    $0x4c,%esp
80102823:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102824:	ba 71 00 00 00       	mov    $0x71,%edx
80102829:	ec                   	in     (%dx),%al
8010282a:	83 e0 04             	and    $0x4,%eax
8010282d:	8d 75 d0             	lea    -0x30(%ebp),%esi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102830:	31 db                	xor    %ebx,%ebx
80102832:	88 45 b7             	mov    %al,-0x49(%ebp)
80102835:	bf 70 00 00 00       	mov    $0x70,%edi
8010283a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102840:	89 d8                	mov    %ebx,%eax
80102842:	89 fa                	mov    %edi,%edx
80102844:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102845:	b9 71 00 00 00       	mov    $0x71,%ecx
8010284a:	89 ca                	mov    %ecx,%edx
8010284c:	ec                   	in     (%dx),%al
  return inb(CMOS_RETURN);
}

static void fill_rtcdate(struct rtcdate *r)
{
  r->second = cmos_read(SECS);
8010284d:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102850:	89 fa                	mov    %edi,%edx
80102852:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102855:	b8 02 00 00 00       	mov    $0x2,%eax
8010285a:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010285b:	89 ca                	mov    %ecx,%edx
8010285d:	ec                   	in     (%dx),%al
  r->minute = cmos_read(MINS);
8010285e:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102861:	89 fa                	mov    %edi,%edx
80102863:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102866:	b8 04 00 00 00       	mov    $0x4,%eax
8010286b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010286c:	89 ca                	mov    %ecx,%edx
8010286e:	ec                   	in     (%dx),%al
  r->hour   = cmos_read(HOURS);
8010286f:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102872:	89 fa                	mov    %edi,%edx
80102874:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102877:	b8 07 00 00 00       	mov    $0x7,%eax
8010287c:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010287d:	89 ca                	mov    %ecx,%edx
8010287f:	ec                   	in     (%dx),%al
  r->day    = cmos_read(DAY);
80102880:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102883:	89 fa                	mov    %edi,%edx
80102885:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102888:	b8 08 00 00 00       	mov    $0x8,%eax
8010288d:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010288e:	89 ca                	mov    %ecx,%edx
80102890:	ec                   	in     (%dx),%al
  r->month  = cmos_read(MONTH);
80102891:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102894:	89 fa                	mov    %edi,%edx
80102896:	89 45 c8             	mov    %eax,-0x38(%ebp)
80102899:	b8 09 00 00 00       	mov    $0x9,%eax
8010289e:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010289f:	89 ca                	mov    %ecx,%edx
801028a1:	ec                   	in     (%dx),%al
  r->year   = cmos_read(YEAR);
801028a2:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028a5:	89 fa                	mov    %edi,%edx
801028a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
801028aa:	b8 0a 00 00 00       	mov    $0xa,%eax
801028af:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028b0:	89 ca                	mov    %ecx,%edx
801028b2:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801028b3:	84 c0                	test   %al,%al
801028b5:	78 89                	js     80102840 <cmostime+0x30>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028b7:	89 d8                	mov    %ebx,%eax
801028b9:	89 fa                	mov    %edi,%edx
801028bb:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028bc:	89 ca                	mov    %ecx,%edx
801028be:	ec                   	in     (%dx),%al
  return inb(CMOS_RETURN);
}

static void fill_rtcdate(struct rtcdate *r)
{
  r->second = cmos_read(SECS);
801028bf:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028c2:	89 fa                	mov    %edi,%edx
801028c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
801028c7:	b8 02 00 00 00       	mov    $0x2,%eax
801028cc:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028cd:	89 ca                	mov    %ecx,%edx
801028cf:	ec                   	in     (%dx),%al
  r->minute = cmos_read(MINS);
801028d0:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028d3:	89 fa                	mov    %edi,%edx
801028d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801028d8:	b8 04 00 00 00       	mov    $0x4,%eax
801028dd:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028de:	89 ca                	mov    %ecx,%edx
801028e0:	ec                   	in     (%dx),%al
  r->hour   = cmos_read(HOURS);
801028e1:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028e4:	89 fa                	mov    %edi,%edx
801028e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
801028e9:	b8 07 00 00 00       	mov    $0x7,%eax
801028ee:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028ef:	89 ca                	mov    %ecx,%edx
801028f1:	ec                   	in     (%dx),%al
  r->day    = cmos_read(DAY);
801028f2:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801028f5:	89 fa                	mov    %edi,%edx
801028f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
801028fa:	b8 08 00 00 00       	mov    $0x8,%eax
801028ff:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102900:	89 ca                	mov    %ecx,%edx
80102902:	ec                   	in     (%dx),%al
  r->month  = cmos_read(MONTH);
80102903:	0f b6 c0             	movzbl %al,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102906:	89 fa                	mov    %edi,%edx
80102908:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010290b:	b8 09 00 00 00       	mov    $0x9,%eax
80102910:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102911:	89 ca                	mov    %ecx,%edx
80102913:	ec                   	in     (%dx),%al
  r->year   = cmos_read(YEAR);
80102914:	0f b6 c0             	movzbl %al,%eax
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102917:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
  r->minute = cmos_read(MINS);
  r->hour   = cmos_read(HOURS);
  r->day    = cmos_read(DAY);
  r->month  = cmos_read(MONTH);
  r->year   = cmos_read(YEAR);
8010291a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010291d:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102920:	6a 18                	push   $0x18
80102922:	56                   	push   %esi
80102923:	50                   	push   %eax
80102924:	e8 77 1b 00 00       	call   801044a0 <memcmp>
80102929:	83 c4 10             	add    $0x10,%esp
8010292c:	85 c0                	test   %eax,%eax
8010292e:	0f 85 0c ff ff ff    	jne    80102840 <cmostime+0x30>
      break;
  }

  // convert
  if(bcd) {
80102934:	80 7d b7 00          	cmpb   $0x0,-0x49(%ebp)
80102938:	75 78                	jne    801029b2 <cmostime+0x1a2>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010293a:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010293d:	89 c2                	mov    %eax,%edx
8010293f:	83 e0 0f             	and    $0xf,%eax
80102942:	c1 ea 04             	shr    $0x4,%edx
80102945:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102948:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010294b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
8010294e:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102951:	89 c2                	mov    %eax,%edx
80102953:	83 e0 0f             	and    $0xf,%eax
80102956:	c1 ea 04             	shr    $0x4,%edx
80102959:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010295c:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010295f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102962:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102965:	89 c2                	mov    %eax,%edx
80102967:	83 e0 0f             	and    $0xf,%eax
8010296a:	c1 ea 04             	shr    $0x4,%edx
8010296d:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102970:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102973:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102976:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102979:	89 c2                	mov    %eax,%edx
8010297b:	83 e0 0f             	and    $0xf,%eax
8010297e:	c1 ea 04             	shr    $0x4,%edx
80102981:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102984:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102987:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
8010298a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010298d:	89 c2                	mov    %eax,%edx
8010298f:	83 e0 0f             	and    $0xf,%eax
80102992:	c1 ea 04             	shr    $0x4,%edx
80102995:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102998:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010299b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
8010299e:	8b 45 cc             	mov    -0x34(%ebp),%eax
801029a1:	89 c2                	mov    %eax,%edx
801029a3:	83 e0 0f             	and    $0xf,%eax
801029a6:	c1 ea 04             	shr    $0x4,%edx
801029a9:	8d 14 92             	lea    (%edx,%edx,4),%edx
801029ac:	8d 04 50             	lea    (%eax,%edx,2),%eax
801029af:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
801029b2:	8b 75 08             	mov    0x8(%ebp),%esi
801029b5:	8b 45 b8             	mov    -0x48(%ebp),%eax
801029b8:	89 06                	mov    %eax,(%esi)
801029ba:	8b 45 bc             	mov    -0x44(%ebp),%eax
801029bd:	89 46 04             	mov    %eax,0x4(%esi)
801029c0:	8b 45 c0             	mov    -0x40(%ebp),%eax
801029c3:	89 46 08             	mov    %eax,0x8(%esi)
801029c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801029c9:	89 46 0c             	mov    %eax,0xc(%esi)
801029cc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801029cf:	89 46 10             	mov    %eax,0x10(%esi)
801029d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801029d5:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801029d8:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801029df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801029e2:	5b                   	pop    %ebx
801029e3:	5e                   	pop    %esi
801029e4:	5f                   	pop    %edi
801029e5:	5d                   	pop    %ebp
801029e6:	c3                   	ret    
801029e7:	66 90                	xchg   %ax,%ax
801029e9:	66 90                	xchg   %ax,%ax
801029eb:	66 90                	xchg   %ax,%ax
801029ed:	66 90                	xchg   %ax,%ax
801029ef:	90                   	nop

801029f0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801029f0:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
801029f6:	85 c9                	test   %ecx,%ecx
801029f8:	0f 8e 85 00 00 00    	jle    80102a83 <install_trans+0x93>
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801029fe:	55                   	push   %ebp
801029ff:	89 e5                	mov    %esp,%ebp
80102a01:	57                   	push   %edi
80102a02:	56                   	push   %esi
80102a03:	53                   	push   %ebx
80102a04:	31 db                	xor    %ebx,%ebx
80102a06:	83 ec 0c             	sub    $0xc,%esp
80102a09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102a10:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102a15:	83 ec 08             	sub    $0x8,%esp
80102a18:	01 d8                	add    %ebx,%eax
80102a1a:	83 c0 01             	add    $0x1,%eax
80102a1d:	50                   	push   %eax
80102a1e:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102a24:	e8 a7 d6 ff ff       	call   801000d0 <bread>
80102a29:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102a2b:	58                   	pop    %eax
80102a2c:	5a                   	pop    %edx
80102a2d:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
80102a34:	ff 35 c4 26 11 80    	pushl  0x801126c4
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102a3a:	83 c3 01             	add    $0x1,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102a3d:	e8 8e d6 ff ff       	call   801000d0 <bread>
80102a42:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102a44:	8d 47 5c             	lea    0x5c(%edi),%eax
80102a47:	83 c4 0c             	add    $0xc,%esp
80102a4a:	68 00 02 00 00       	push   $0x200
80102a4f:	50                   	push   %eax
80102a50:	8d 46 5c             	lea    0x5c(%esi),%eax
80102a53:	50                   	push   %eax
80102a54:	e8 a7 1a 00 00       	call   80104500 <memmove>
    bwrite(dbuf);  // write dst to disk
80102a59:	89 34 24             	mov    %esi,(%esp)
80102a5c:	e8 3f d7 ff ff       	call   801001a0 <bwrite>
    brelse(lbuf);
80102a61:	89 3c 24             	mov    %edi,(%esp)
80102a64:	e8 77 d7 ff ff       	call   801001e0 <brelse>
    brelse(dbuf);
80102a69:	89 34 24             	mov    %esi,(%esp)
80102a6c:	e8 6f d7 ff ff       	call   801001e0 <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102a71:	83 c4 10             	add    $0x10,%esp
80102a74:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
80102a7a:	7f 94                	jg     80102a10 <install_trans+0x20>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80102a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102a7f:	5b                   	pop    %ebx
80102a80:	5e                   	pop    %esi
80102a81:	5f                   	pop    %edi
80102a82:	5d                   	pop    %ebp
80102a83:	f3 c3                	repz ret 
80102a85:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102a89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102a90 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102a90:	55                   	push   %ebp
80102a91:	89 e5                	mov    %esp,%ebp
80102a93:	53                   	push   %ebx
80102a94:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102a97:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102a9d:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102aa3:	e8 28 d6 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102aa8:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
  for (i = 0; i < log.lh.n; i++) {
80102aae:	83 c4 10             	add    $0x10,%esp
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102ab1:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102ab3:	85 c9                	test   %ecx,%ecx
write_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102ab5:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102ab8:	7e 1f                	jle    80102ad9 <write_head+0x49>
80102aba:	8d 04 8d 00 00 00 00 	lea    0x0(,%ecx,4),%eax
80102ac1:	31 d2                	xor    %edx,%edx
80102ac3:	90                   	nop
80102ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    hb->block[i] = log.lh.block[i];
80102ac8:	8b 8a cc 26 11 80    	mov    -0x7feed934(%edx),%ecx
80102ace:	89 4c 13 60          	mov    %ecx,0x60(%ebx,%edx,1)
80102ad2:	83 c2 04             	add    $0x4,%edx
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102ad5:	39 c2                	cmp    %eax,%edx
80102ad7:	75 ef                	jne    80102ac8 <write_head+0x38>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80102ad9:	83 ec 0c             	sub    $0xc,%esp
80102adc:	53                   	push   %ebx
80102add:	e8 be d6 ff ff       	call   801001a0 <bwrite>
  brelse(buf);
80102ae2:	89 1c 24             	mov    %ebx,(%esp)
80102ae5:	e8 f6 d6 ff ff       	call   801001e0 <brelse>
}
80102aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102aed:	c9                   	leave  
80102aee:	c3                   	ret    
80102aef:	90                   	nop

80102af0 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102af0:	55                   	push   %ebp
80102af1:	89 e5                	mov    %esp,%ebp
80102af3:	53                   	push   %ebx
80102af4:	83 ec 2c             	sub    $0x2c,%esp
80102af7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102afa:	68 a0 74 10 80       	push   $0x801074a0
80102aff:	68 80 26 11 80       	push   $0x80112680
80102b04:	e8 d7 16 00 00       	call   801041e0 <initlock>
  readsb(dev, &sb);
80102b09:	58                   	pop    %eax
80102b0a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102b0d:	5a                   	pop    %edx
80102b0e:	50                   	push   %eax
80102b0f:	53                   	push   %ebx
80102b10:	e8 7b e9 ff ff       	call   80101490 <readsb>
  log.start = sb.logstart;
  log.size = sb.nlog;
80102b15:	8b 55 e8             	mov    -0x18(%ebp),%edx
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
80102b18:	8b 45 ec             	mov    -0x14(%ebp),%eax

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102b1b:	59                   	pop    %ecx
  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
80102b1c:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
80102b22:	89 15 b8 26 11 80    	mov    %edx,0x801126b8
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
  readsb(dev, &sb);
  log.start = sb.logstart;
80102b28:	a3 b4 26 11 80       	mov    %eax,0x801126b4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
80102b2d:	5a                   	pop    %edx
80102b2e:	50                   	push   %eax
80102b2f:	53                   	push   %ebx
80102b30:	e8 9b d5 ff ff       	call   801000d0 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102b35:	8b 48 5c             	mov    0x5c(%eax),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102b38:	83 c4 10             	add    $0x10,%esp
80102b3b:	85 c9                	test   %ecx,%ecx
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102b3d:	89 0d c8 26 11 80    	mov    %ecx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
80102b43:	7e 1c                	jle    80102b61 <initlog+0x71>
80102b45:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80102b4c:	31 d2                	xor    %edx,%edx
80102b4e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102b50:	8b 4c 10 60          	mov    0x60(%eax,%edx,1),%ecx
80102b54:	83 c2 04             	add    $0x4,%edx
80102b57:	89 8a c8 26 11 80    	mov    %ecx,-0x7feed938(%edx)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80102b5d:	39 da                	cmp    %ebx,%edx
80102b5f:	75 ef                	jne    80102b50 <initlog+0x60>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80102b61:	83 ec 0c             	sub    $0xc,%esp
80102b64:	50                   	push   %eax
80102b65:	e8 76 d6 ff ff       	call   801001e0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102b6a:	e8 81 fe ff ff       	call   801029f0 <install_trans>
  log.lh.n = 0;
80102b6f:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102b76:	00 00 00 
  write_head(); // clear the log
80102b79:	e8 12 ff ff ff       	call   80102a90 <write_head>
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
  recover_from_log();
}
80102b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b81:	c9                   	leave  
80102b82:	c3                   	ret    
80102b83:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102b89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102b90 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102b90:	55                   	push   %ebp
80102b91:	89 e5                	mov    %esp,%ebp
80102b93:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102b96:	68 80 26 11 80       	push   $0x80112680
80102b9b:	e8 40 17 00 00       	call   801042e0 <acquire>
80102ba0:	83 c4 10             	add    $0x10,%esp
80102ba3:	eb 18                	jmp    80102bbd <begin_op+0x2d>
80102ba5:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102ba8:	83 ec 08             	sub    $0x8,%esp
80102bab:	68 80 26 11 80       	push   $0x80112680
80102bb0:	68 80 26 11 80       	push   $0x80112680
80102bb5:	e8 b6 11 00 00       	call   80103d70 <sleep>
80102bba:	83 c4 10             	add    $0x10,%esp
void
begin_op(void)
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
80102bbd:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102bc2:	85 c0                	test   %eax,%eax
80102bc4:	75 e2                	jne    80102ba8 <begin_op+0x18>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102bc6:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102bcb:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102bd1:	83 c0 01             	add    $0x1,%eax
80102bd4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102bd7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102bda:	83 fa 1e             	cmp    $0x1e,%edx
80102bdd:	7f c9                	jg     80102ba8 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102bdf:	83 ec 0c             	sub    $0xc,%esp
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80102be2:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
80102be7:	68 80 26 11 80       	push   $0x80112680
80102bec:	e8 0f 18 00 00       	call   80104400 <release>
      break;
    }
  }
}
80102bf1:	83 c4 10             	add    $0x10,%esp
80102bf4:	c9                   	leave  
80102bf5:	c3                   	ret    
80102bf6:	8d 76 00             	lea    0x0(%esi),%esi
80102bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c00 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102c00:	55                   	push   %ebp
80102c01:	89 e5                	mov    %esp,%ebp
80102c03:	57                   	push   %edi
80102c04:	56                   	push   %esi
80102c05:	53                   	push   %ebx
80102c06:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102c09:	68 80 26 11 80       	push   $0x80112680
80102c0e:	e8 cd 16 00 00       	call   801042e0 <acquire>
  log.outstanding -= 1;
80102c13:	a1 bc 26 11 80       	mov    0x801126bc,%eax
  if(log.committing)
80102c18:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
80102c1e:	83 c4 10             	add    $0x10,%esp
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102c21:	83 e8 01             	sub    $0x1,%eax
  if(log.committing)
80102c24:	85 db                	test   %ebx,%ebx
end_op(void)
{
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
80102c26:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
80102c2b:	0f 85 23 01 00 00    	jne    80102d54 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102c31:	85 c0                	test   %eax,%eax
80102c33:	0f 85 f7 00 00 00    	jne    80102d30 <end_op+0x130>
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102c39:	83 ec 0c             	sub    $0xc,%esp
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
  if(log.outstanding == 0){
    do_commit = 1;
    log.committing = 1;
80102c3c:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
80102c43:	00 00 00 
}

static void
commit()
{
  if (log.lh.n > 0) {
80102c46:	31 db                	xor    %ebx,%ebx
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102c48:	68 80 26 11 80       	push   $0x80112680
80102c4d:	e8 ae 17 00 00       	call   80104400 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102c52:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
80102c58:	83 c4 10             	add    $0x10,%esp
80102c5b:	85 c9                	test   %ecx,%ecx
80102c5d:	0f 8e 8a 00 00 00    	jle    80102ced <end_op+0xed>
80102c63:	90                   	nop
80102c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102c68:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c6d:	83 ec 08             	sub    $0x8,%esp
80102c70:	01 d8                	add    %ebx,%eax
80102c72:	83 c0 01             	add    $0x1,%eax
80102c75:	50                   	push   %eax
80102c76:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102c7c:	e8 4f d4 ff ff       	call   801000d0 <bread>
80102c81:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102c83:	58                   	pop    %eax
80102c84:	5a                   	pop    %edx
80102c85:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
80102c8c:	ff 35 c4 26 11 80    	pushl  0x801126c4
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102c92:	83 c3 01             	add    $0x1,%ebx
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102c95:	e8 36 d4 ff ff       	call   801000d0 <bread>
80102c9a:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102c9c:	8d 40 5c             	lea    0x5c(%eax),%eax
80102c9f:	83 c4 0c             	add    $0xc,%esp
80102ca2:	68 00 02 00 00       	push   $0x200
80102ca7:	50                   	push   %eax
80102ca8:	8d 46 5c             	lea    0x5c(%esi),%eax
80102cab:	50                   	push   %eax
80102cac:	e8 4f 18 00 00       	call   80104500 <memmove>
    bwrite(to);  // write the log
80102cb1:	89 34 24             	mov    %esi,(%esp)
80102cb4:	e8 e7 d4 ff ff       	call   801001a0 <bwrite>
    brelse(from);
80102cb9:	89 3c 24             	mov    %edi,(%esp)
80102cbc:	e8 1f d5 ff ff       	call   801001e0 <brelse>
    brelse(to);
80102cc1:	89 34 24             	mov    %esi,(%esp)
80102cc4:	e8 17 d5 ff ff       	call   801001e0 <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102cc9:	83 c4 10             	add    $0x10,%esp
80102ccc:	3b 1d c8 26 11 80    	cmp    0x801126c8,%ebx
80102cd2:	7c 94                	jl     80102c68 <end_op+0x68>
static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102cd4:	e8 b7 fd ff ff       	call   80102a90 <write_head>
    install_trans(); // Now install writes to home locations
80102cd9:	e8 12 fd ff ff       	call   801029f0 <install_trans>
    log.lh.n = 0;
80102cde:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102ce5:	00 00 00 
    write_head();    // Erase the transaction from the log
80102ce8:	e8 a3 fd ff ff       	call   80102a90 <write_head>

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
80102ced:	83 ec 0c             	sub    $0xc,%esp
80102cf0:	68 80 26 11 80       	push   $0x80112680
80102cf5:	e8 e6 15 00 00       	call   801042e0 <acquire>
    log.committing = 0;
    wakeup(&log);
80102cfa:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
    log.committing = 0;
80102d01:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
80102d08:	00 00 00 
    wakeup(&log);
80102d0b:	e8 10 12 00 00       	call   80103f20 <wakeup>
    release(&log.lock);
80102d10:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102d17:	e8 e4 16 00 00       	call   80104400 <release>
80102d1c:	83 c4 10             	add    $0x10,%esp
  }
}
80102d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d22:	5b                   	pop    %ebx
80102d23:	5e                   	pop    %esi
80102d24:	5f                   	pop    %edi
80102d25:	5d                   	pop    %ebp
80102d26:	c3                   	ret    
80102d27:	89 f6                	mov    %esi,%esi
80102d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    log.committing = 1;
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80102d30:	83 ec 0c             	sub    $0xc,%esp
80102d33:	68 80 26 11 80       	push   $0x80112680
80102d38:	e8 e3 11 00 00       	call   80103f20 <wakeup>
  }
  release(&log.lock);
80102d3d:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102d44:	e8 b7 16 00 00       	call   80104400 <release>
80102d49:	83 c4 10             	add    $0x10,%esp
    acquire(&log.lock);
    log.committing = 0;
    wakeup(&log);
    release(&log.lock);
  }
}
80102d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d4f:	5b                   	pop    %ebx
80102d50:	5e                   	pop    %esi
80102d51:	5f                   	pop    %edi
80102d52:	5d                   	pop    %ebp
80102d53:	c3                   	ret    
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
80102d54:	83 ec 0c             	sub    $0xc,%esp
80102d57:	68 a4 74 10 80       	push   $0x801074a4
80102d5c:	e8 0f d6 ff ff       	call   80100370 <panic>
80102d61:	eb 0d                	jmp    80102d70 <log_write>
80102d63:	90                   	nop
80102d64:	90                   	nop
80102d65:	90                   	nop
80102d66:	90                   	nop
80102d67:	90                   	nop
80102d68:	90                   	nop
80102d69:	90                   	nop
80102d6a:	90                   	nop
80102d6b:	90                   	nop
80102d6c:	90                   	nop
80102d6d:	90                   	nop
80102d6e:	90                   	nop
80102d6f:	90                   	nop

80102d70 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102d70:	55                   	push   %ebp
80102d71:	89 e5                	mov    %esp,%ebp
80102d73:	53                   	push   %ebx
80102d74:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102d77:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102d7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102d80:	83 fa 1d             	cmp    $0x1d,%edx
80102d83:	0f 8f 97 00 00 00    	jg     80102e20 <log_write+0xb0>
80102d89:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102d8e:	83 e8 01             	sub    $0x1,%eax
80102d91:	39 c2                	cmp    %eax,%edx
80102d93:	0f 8d 87 00 00 00    	jge    80102e20 <log_write+0xb0>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102d99:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d9e:	85 c0                	test   %eax,%eax
80102da0:	0f 8e 87 00 00 00    	jle    80102e2d <log_write+0xbd>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102da6:	83 ec 0c             	sub    $0xc,%esp
80102da9:	68 80 26 11 80       	push   $0x80112680
80102dae:	e8 2d 15 00 00       	call   801042e0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102db3:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102db9:	83 c4 10             	add    $0x10,%esp
80102dbc:	83 fa 00             	cmp    $0x0,%edx
80102dbf:	7e 50                	jle    80102e11 <log_write+0xa1>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102dc1:	8b 4b 08             	mov    0x8(%ebx),%ecx
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102dc4:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102dc6:	3b 0d cc 26 11 80    	cmp    0x801126cc,%ecx
80102dcc:	75 0b                	jne    80102dd9 <log_write+0x69>
80102dce:	eb 38                	jmp    80102e08 <log_write+0x98>
80102dd0:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
80102dd7:	74 2f                	je     80102e08 <log_write+0x98>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102dd9:	83 c0 01             	add    $0x1,%eax
80102ddc:	39 d0                	cmp    %edx,%eax
80102dde:	75 f0                	jne    80102dd0 <log_write+0x60>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80102de0:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  if (i == log.lh.n)
    log.lh.n++;
80102de7:	83 c2 01             	add    $0x1,%edx
80102dea:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
  b->flags |= B_DIRTY; // prevent eviction
80102df0:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102df3:	c7 45 08 80 26 11 80 	movl   $0x80112680,0x8(%ebp)
}
80102dfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102dfd:	c9                   	leave  
  }
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&log.lock);
80102dfe:	e9 fd 15 00 00       	jmp    80104400 <release>
80102e03:	90                   	nop
80102e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80102e08:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
80102e0f:	eb df                	jmp    80102df0 <log_write+0x80>
80102e11:	8b 43 08             	mov    0x8(%ebx),%eax
80102e14:	a3 cc 26 11 80       	mov    %eax,0x801126cc
  if (i == log.lh.n)
80102e19:	75 d5                	jne    80102df0 <log_write+0x80>
80102e1b:	eb ca                	jmp    80102de7 <log_write+0x77>
80102e1d:	8d 76 00             	lea    0x0(%esi),%esi
log_write(struct buf *b)
{
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
80102e20:	83 ec 0c             	sub    $0xc,%esp
80102e23:	68 b3 74 10 80       	push   $0x801074b3
80102e28:	e8 43 d5 ff ff       	call   80100370 <panic>
  if (log.outstanding < 1)
    panic("log_write outside of trans");
80102e2d:	83 ec 0c             	sub    $0xc,%esp
80102e30:	68 c9 74 10 80       	push   $0x801074c9
80102e35:	e8 36 d5 ff ff       	call   80100370 <panic>
80102e3a:	66 90                	xchg   %ax,%ax
80102e3c:	66 90                	xchg   %ax,%ax
80102e3e:	66 90                	xchg   %ax,%ax

80102e40 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	53                   	push   %ebx
80102e44:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102e47:	e8 54 09 00 00       	call   801037a0 <cpuid>
80102e4c:	89 c3                	mov    %eax,%ebx
80102e4e:	e8 4d 09 00 00       	call   801037a0 <cpuid>
80102e53:	83 ec 04             	sub    $0x4,%esp
80102e56:	53                   	push   %ebx
80102e57:	50                   	push   %eax
80102e58:	68 e4 74 10 80       	push   $0x801074e4
80102e5d:	e8 fe d7 ff ff       	call   80100660 <cprintf>
  idtinit();       // load idt register
80102e62:	e8 39 29 00 00       	call   801057a0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102e67:	e8 b4 08 00 00       	call   80103720 <mycpu>
80102e6c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102e6e:	b8 01 00 00 00       	mov    $0x1,%eax
80102e73:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102e7a:	e8 01 0c 00 00       	call   80103a80 <scheduler>
80102e7f:	90                   	nop

80102e80 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102e86:	e8 35 3a 00 00       	call   801068c0 <switchkvm>
  seginit();
80102e8b:	e8 a0 38 00 00       	call   80106730 <seginit>
  lapicinit();
80102e90:	e8 9b f7 ff ff       	call   80102630 <lapicinit>
  mpmain();
80102e95:	e8 a6 ff ff ff       	call   80102e40 <mpmain>
80102e9a:	66 90                	xchg   %ax,%ax
80102e9c:	66 90                	xchg   %ax,%ax
80102e9e:	66 90                	xchg   %ax,%ax

80102ea0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80102ea0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102ea4:	83 e4 f0             	and    $0xfffffff0,%esp
80102ea7:	ff 71 fc             	pushl  -0x4(%ecx)
80102eaa:	55                   	push   %ebp
80102eab:	89 e5                	mov    %esp,%ebp
80102ead:	53                   	push   %ebx
80102eae:	51                   	push   %ecx
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80102eaf:	bb 80 27 11 80       	mov    $0x80112780,%ebx
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102eb4:	83 ec 08             	sub    $0x8,%esp
80102eb7:	68 00 00 40 80       	push   $0x80400000
80102ebc:	68 f4 57 11 80       	push   $0x801157f4
80102ec1:	e8 ed f4 ff ff       	call   801023b3 <kinit1>
  kvmalloc();      // kernel page table
80102ec6:	e8 95 3e 00 00       	call   80106d60 <kvmalloc>
  mpinit();        // detect other processors
80102ecb:	e8 70 01 00 00       	call   80103040 <mpinit>
  lapicinit();     // interrupt controller
80102ed0:	e8 5b f7 ff ff       	call   80102630 <lapicinit>
  seginit();       // segment descriptors
80102ed5:	e8 56 38 00 00       	call   80106730 <seginit>
  picinit();       // disable pic
80102eda:	e8 31 03 00 00       	call   80103210 <picinit>
  ioapicinit();    // another interrupt controller
80102edf:	e8 ec f3 ff ff       	call   801022d0 <ioapicinit>
  consoleinit();   // console hardware
80102ee4:	e8 b7 da ff ff       	call   801009a0 <consoleinit>
  uartinit();      // serial port
80102ee9:	e8 a2 2b 00 00       	call   80105a90 <uartinit>
  pinit();         // process table
80102eee:	e8 0d 08 00 00       	call   80103700 <pinit>
  shminit();       // shared memory
80102ef3:	e8 88 40 00 00       	call   80106f80 <shminit>
  tvinit();        // trap vectors
80102ef8:	e8 03 28 00 00       	call   80105700 <tvinit>
  binit();         // buffer cache
80102efd:	e8 3e d1 ff ff       	call   80100040 <binit>
  fileinit();      // file table
80102f02:	e8 29 df ff ff       	call   80100e30 <fileinit>
  ideinit();       // disk 
80102f07:	e8 a4 f1 ff ff       	call   801020b0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102f0c:	83 c4 0c             	add    $0xc,%esp
80102f0f:	68 8a 00 00 00       	push   $0x8a
80102f14:	68 8c a4 10 80       	push   $0x8010a48c
80102f19:	68 00 70 00 80       	push   $0x80007000
80102f1e:	e8 dd 15 00 00       	call   80104500 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102f23:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102f2a:	00 00 00 
80102f2d:	83 c4 10             	add    $0x10,%esp
80102f30:	05 80 27 11 80       	add    $0x80112780,%eax
80102f35:	39 d8                	cmp    %ebx,%eax
80102f37:	76 6a                	jbe    80102fa3 <main+0x103>
80102f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(c == mycpu())  // We've started already.
80102f40:	e8 db 07 00 00       	call   80103720 <mycpu>
80102f45:	39 d8                	cmp    %ebx,%eax
80102f47:	74 41                	je     80102f8a <main+0xea>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102f49:	e8 99 f5 ff ff       	call   801024e7 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102f4e:	05 00 10 00 00       	add    $0x1000,%eax
    *(void**)(code-8) = mpenter;
80102f53:	c7 05 f8 6f 00 80 80 	movl   $0x80102e80,0x80006ff8
80102f5a:	2e 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102f5d:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102f64:	90 10 00 

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
    *(void**)(code-4) = stack + KSTACKSIZE;
80102f67:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80102f6c:	0f b6 03             	movzbl (%ebx),%eax
80102f6f:	83 ec 08             	sub    $0x8,%esp
80102f72:	68 00 70 00 00       	push   $0x7000
80102f77:	50                   	push   %eax
80102f78:	e8 03 f8 ff ff       	call   80102780 <lapicstartap>
80102f7d:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102f80:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102f86:	85 c0                	test   %eax,%eax
80102f88:	74 f6                	je     80102f80 <main+0xe0>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80102f8a:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102f91:	00 00 00 
80102f94:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102f9a:	05 80 27 11 80       	add    $0x80112780,%eax
80102f9f:	39 c3                	cmp    %eax,%ebx
80102fa1:	72 9d                	jb     80102f40 <main+0xa0>
  tvinit();        // trap vectors
  binit();         // buffer cache
  fileinit();      // file table
  ideinit();       // disk 
  startothers();   // start other processors
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102fa3:	83 ec 08             	sub    $0x8,%esp
80102fa6:	68 00 00 00 8e       	push   $0x8e000000
80102fab:	68 00 00 40 80       	push   $0x80400000
80102fb0:	e8 37 f4 ff ff       	call   801023ec <kinit2>
  userinit();      // first user process
80102fb5:	e8 36 08 00 00       	call   801037f0 <userinit>
  mpmain();        // finish this processor's setup
80102fba:	e8 81 fe ff ff       	call   80102e40 <mpmain>
80102fbf:	90                   	nop

80102fc0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102fc0:	55                   	push   %ebp
80102fc1:	89 e5                	mov    %esp,%ebp
80102fc3:	57                   	push   %edi
80102fc4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80102fc5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102fcb:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102fcc:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102fcf:	83 ec 0c             	sub    $0xc,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80102fd2:	39 de                	cmp    %ebx,%esi
80102fd4:	73 48                	jae    8010301e <mpsearch1+0x5e>
80102fd6:	8d 76 00             	lea    0x0(%esi),%esi
80102fd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102fe0:	83 ec 04             	sub    $0x4,%esp
80102fe3:	8d 7e 10             	lea    0x10(%esi),%edi
80102fe6:	6a 04                	push   $0x4
80102fe8:	68 f8 74 10 80       	push   $0x801074f8
80102fed:	56                   	push   %esi
80102fee:	e8 ad 14 00 00       	call   801044a0 <memcmp>
80102ff3:	83 c4 10             	add    $0x10,%esp
80102ff6:	85 c0                	test   %eax,%eax
80102ff8:	75 1e                	jne    80103018 <mpsearch1+0x58>
80102ffa:	8d 7e 10             	lea    0x10(%esi),%edi
80102ffd:	89 f2                	mov    %esi,%edx
80102fff:	31 c9                	xor    %ecx,%ecx
80103001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
80103008:	0f b6 02             	movzbl (%edx),%eax
8010300b:	83 c2 01             	add    $0x1,%edx
8010300e:	01 c1                	add    %eax,%ecx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103010:	39 fa                	cmp    %edi,%edx
80103012:	75 f4                	jne    80103008 <mpsearch1+0x48>
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103014:	84 c9                	test   %cl,%cl
80103016:	74 10                	je     80103028 <mpsearch1+0x68>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103018:	39 fb                	cmp    %edi,%ebx
8010301a:	89 fe                	mov    %edi,%esi
8010301c:	77 c2                	ja     80102fe0 <mpsearch1+0x20>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
}
8010301e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103021:	31 c0                	xor    %eax,%eax
}
80103023:	5b                   	pop    %ebx
80103024:	5e                   	pop    %esi
80103025:	5f                   	pop    %edi
80103026:	5d                   	pop    %ebp
80103027:	c3                   	ret    
80103028:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010302b:	89 f0                	mov    %esi,%eax
8010302d:	5b                   	pop    %ebx
8010302e:	5e                   	pop    %esi
8010302f:	5f                   	pop    %edi
80103030:	5d                   	pop    %ebp
80103031:	c3                   	ret    
80103032:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103039:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103040 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
80103043:	57                   	push   %edi
80103044:	56                   	push   %esi
80103045:	53                   	push   %ebx
80103046:	83 ec 1c             	sub    $0x1c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103049:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103050:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103057:	c1 e0 08             	shl    $0x8,%eax
8010305a:	09 d0                	or     %edx,%eax
8010305c:	c1 e0 04             	shl    $0x4,%eax
8010305f:	85 c0                	test   %eax,%eax
80103061:	75 1b                	jne    8010307e <mpinit+0x3e>
    if((mp = mpsearch1(p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
80103063:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010306a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103071:	c1 e0 08             	shl    $0x8,%eax
80103074:	09 d0                	or     %edx,%eax
80103076:	c1 e0 0a             	shl    $0xa,%eax
80103079:	2d 00 04 00 00       	sub    $0x400,%eax
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
    if((mp = mpsearch1(p, 1024)))
8010307e:	ba 00 04 00 00       	mov    $0x400,%edx
80103083:	e8 38 ff ff ff       	call   80102fc0 <mpsearch1>
80103088:	85 c0                	test   %eax,%eax
8010308a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010308d:	0f 84 37 01 00 00    	je     801031ca <mpinit+0x18a>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103096:	8b 58 04             	mov    0x4(%eax),%ebx
80103099:	85 db                	test   %ebx,%ebx
8010309b:	0f 84 43 01 00 00    	je     801031e4 <mpinit+0x1a4>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
801030a1:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
801030a7:	83 ec 04             	sub    $0x4,%esp
801030aa:	6a 04                	push   $0x4
801030ac:	68 fd 74 10 80       	push   $0x801074fd
801030b1:	56                   	push   %esi
801030b2:	e8 e9 13 00 00       	call   801044a0 <memcmp>
801030b7:	83 c4 10             	add    $0x10,%esp
801030ba:	85 c0                	test   %eax,%eax
801030bc:	0f 85 22 01 00 00    	jne    801031e4 <mpinit+0x1a4>
    return 0;
  if(conf->version != 1 && conf->version != 4)
801030c2:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
801030c9:	3c 01                	cmp    $0x1,%al
801030cb:	74 08                	je     801030d5 <mpinit+0x95>
801030cd:	3c 04                	cmp    $0x4,%al
801030cf:	0f 85 0f 01 00 00    	jne    801031e4 <mpinit+0x1a4>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
801030d5:	0f b7 bb 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801030dc:	85 ff                	test   %edi,%edi
801030de:	74 21                	je     80103101 <mpinit+0xc1>
801030e0:	31 d2                	xor    %edx,%edx
801030e2:	31 c0                	xor    %eax,%eax
801030e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    sum += addr[i];
801030e8:	0f b6 8c 03 00 00 00 	movzbl -0x80000000(%ebx,%eax,1),%ecx
801030ef:	80 
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801030f0:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801030f3:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
801030f5:	39 c7                	cmp    %eax,%edi
801030f7:	75 ef                	jne    801030e8 <mpinit+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
801030f9:	84 d2                	test   %dl,%dl
801030fb:	0f 85 e3 00 00 00    	jne    801031e4 <mpinit+0x1a4>
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103101:	85 f6                	test   %esi,%esi
80103103:	0f 84 db 00 00 00    	je     801031e4 <mpinit+0x1a4>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103109:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
8010310f:	a3 7c 26 11 80       	mov    %eax,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103114:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
8010311b:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
80103121:	bb 01 00 00 00       	mov    $0x1,%ebx
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103126:	01 d6                	add    %edx,%esi
80103128:	90                   	nop
80103129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103130:	39 c6                	cmp    %eax,%esi
80103132:	76 23                	jbe    80103157 <mpinit+0x117>
80103134:	0f b6 10             	movzbl (%eax),%edx
    switch(*p){
80103137:	80 fa 04             	cmp    $0x4,%dl
8010313a:	0f 87 c0 00 00 00    	ja     80103200 <mpinit+0x1c0>
80103140:	ff 24 95 3c 75 10 80 	jmp    *-0x7fef8ac4(,%edx,4)
80103147:	89 f6                	mov    %esi,%esi
80103149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103150:	83 c0 08             	add    $0x8,%eax

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103153:	39 c6                	cmp    %eax,%esi
80103155:	77 dd                	ja     80103134 <mpinit+0xf4>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103157:	85 db                	test   %ebx,%ebx
80103159:	0f 84 92 00 00 00    	je     801031f1 <mpinit+0x1b1>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010315f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103162:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80103166:	74 15                	je     8010317d <mpinit+0x13d>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103168:	ba 22 00 00 00       	mov    $0x22,%edx
8010316d:	b8 70 00 00 00       	mov    $0x70,%eax
80103172:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103173:	ba 23 00 00 00       	mov    $0x23,%edx
80103178:	ec                   	in     (%dx),%al
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103179:	83 c8 01             	or     $0x1,%eax
8010317c:	ee                   	out    %al,(%dx)
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
8010317d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103180:	5b                   	pop    %ebx
80103181:	5e                   	pop    %esi
80103182:	5f                   	pop    %edi
80103183:	5d                   	pop    %ebp
80103184:	c3                   	ret    
80103185:	8d 76 00             	lea    0x0(%esi),%esi
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80103188:	8b 0d 00 2d 11 80    	mov    0x80112d00,%ecx
8010318e:	83 f9 07             	cmp    $0x7,%ecx
80103191:	7f 19                	jg     801031ac <mpinit+0x16c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103193:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80103197:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
        ncpu++;
8010319d:	83 c1 01             	add    $0x1,%ecx
801031a0:	89 0d 00 2d 11 80    	mov    %ecx,0x80112d00
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
801031a6:	88 97 80 27 11 80    	mov    %dl,-0x7feed880(%edi)
        ncpu++;
      }
      p += sizeof(struct mpproc);
801031ac:	83 c0 14             	add    $0x14,%eax
      continue;
801031af:	e9 7c ff ff ff       	jmp    80103130 <mpinit+0xf0>
801031b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
801031b8:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      p += sizeof(struct mpioapic);
801031bc:	83 c0 08             	add    $0x8,%eax
      }
      p += sizeof(struct mpproc);
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
801031bf:	88 15 60 27 11 80    	mov    %dl,0x80112760
      p += sizeof(struct mpioapic);
      continue;
801031c5:	e9 66 ff ff ff       	jmp    80103130 <mpinit+0xf0>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
801031ca:	ba 00 00 01 00       	mov    $0x10000,%edx
801031cf:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801031d4:	e8 e7 fd ff ff       	call   80102fc0 <mpsearch1>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801031d9:	85 c0                	test   %eax,%eax
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
801031db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801031de:	0f 85 af fe ff ff    	jne    80103093 <mpinit+0x53>
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
801031e4:	83 ec 0c             	sub    $0xc,%esp
801031e7:	68 02 75 10 80       	push   $0x80107502
801031ec:	e8 7f d1 ff ff       	call   80100370 <panic>
      ismp = 0;
      break;
    }
  }
  if(!ismp)
    panic("Didn't find a suitable machine");
801031f1:	83 ec 0c             	sub    $0xc,%esp
801031f4:	68 1c 75 10 80       	push   $0x8010751c
801031f9:	e8 72 d1 ff ff       	call   80100370 <panic>
801031fe:	66 90                	xchg   %ax,%ax
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      ismp = 0;
80103200:	31 db                	xor    %ebx,%ebx
80103202:	e9 30 ff ff ff       	jmp    80103137 <mpinit+0xf7>
80103207:	66 90                	xchg   %ax,%ax
80103209:	66 90                	xchg   %ax,%ax
8010320b:	66 90                	xchg   %ax,%ax
8010320d:	66 90                	xchg   %ax,%ax
8010320f:	90                   	nop

80103210 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103210:	55                   	push   %ebp
80103211:	ba 21 00 00 00       	mov    $0x21,%edx
80103216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010321b:	89 e5                	mov    %esp,%ebp
8010321d:	ee                   	out    %al,(%dx)
8010321e:	ba a1 00 00 00       	mov    $0xa1,%edx
80103223:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103224:	5d                   	pop    %ebp
80103225:	c3                   	ret    
80103226:	66 90                	xchg   %ax,%ax
80103228:	66 90                	xchg   %ax,%ax
8010322a:	66 90                	xchg   %ax,%ax
8010322c:	66 90                	xchg   %ax,%ax
8010322e:	66 90                	xchg   %ax,%ax

80103230 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103230:	55                   	push   %ebp
80103231:	89 e5                	mov    %esp,%ebp
80103233:	57                   	push   %edi
80103234:	56                   	push   %esi
80103235:	53                   	push   %ebx
80103236:	83 ec 0c             	sub    $0xc,%esp
80103239:	8b 75 08             	mov    0x8(%ebp),%esi
8010323c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010323f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103245:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010324b:	e8 00 dc ff ff       	call   80100e50 <filealloc>
80103250:	85 c0                	test   %eax,%eax
80103252:	89 06                	mov    %eax,(%esi)
80103254:	0f 84 a8 00 00 00    	je     80103302 <pipealloc+0xd2>
8010325a:	e8 f1 db ff ff       	call   80100e50 <filealloc>
8010325f:	85 c0                	test   %eax,%eax
80103261:	89 03                	mov    %eax,(%ebx)
80103263:	0f 84 87 00 00 00    	je     801032f0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103269:	e8 79 f2 ff ff       	call   801024e7 <kalloc>
8010326e:	85 c0                	test   %eax,%eax
80103270:	89 c7                	mov    %eax,%edi
80103272:	0f 84 b0 00 00 00    	je     80103328 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103278:	83 ec 08             	sub    $0x8,%esp
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
  p->readopen = 1;
8010327b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103282:	00 00 00 
  p->writeopen = 1;
80103285:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010328c:	00 00 00 
  p->nwrite = 0;
8010328f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103296:	00 00 00 
  p->nread = 0;
80103299:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801032a0:	00 00 00 
  initlock(&p->lock, "pipe");
801032a3:	68 50 75 10 80       	push   $0x80107550
801032a8:	50                   	push   %eax
801032a9:	e8 32 0f 00 00       	call   801041e0 <initlock>
  (*f0)->type = FD_PIPE;
801032ae:	8b 06                	mov    (%esi),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801032b0:	83 c4 10             	add    $0x10,%esp
  p->readopen = 1;
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
  (*f0)->type = FD_PIPE;
801032b3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801032b9:	8b 06                	mov    (%esi),%eax
801032bb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801032bf:	8b 06                	mov    (%esi),%eax
801032c1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801032c5:	8b 06                	mov    (%esi),%eax
801032c7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801032ca:	8b 03                	mov    (%ebx),%eax
801032cc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801032d2:	8b 03                	mov    (%ebx),%eax
801032d4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801032d8:	8b 03                	mov    (%ebx),%eax
801032da:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801032de:	8b 03                	mov    (%ebx),%eax
801032e0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801032e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801032e6:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801032e8:	5b                   	pop    %ebx
801032e9:	5e                   	pop    %esi
801032ea:	5f                   	pop    %edi
801032eb:	5d                   	pop    %ebp
801032ec:	c3                   	ret    
801032ed:	8d 76 00             	lea    0x0(%esi),%esi

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
801032f0:	8b 06                	mov    (%esi),%eax
801032f2:	85 c0                	test   %eax,%eax
801032f4:	74 1e                	je     80103314 <pipealloc+0xe4>
    fileclose(*f0);
801032f6:	83 ec 0c             	sub    $0xc,%esp
801032f9:	50                   	push   %eax
801032fa:	e8 11 dc ff ff       	call   80100f10 <fileclose>
801032ff:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103302:	8b 03                	mov    (%ebx),%eax
80103304:	85 c0                	test   %eax,%eax
80103306:	74 0c                	je     80103314 <pipealloc+0xe4>
    fileclose(*f1);
80103308:	83 ec 0c             	sub    $0xc,%esp
8010330b:	50                   	push   %eax
8010330c:	e8 ff db ff ff       	call   80100f10 <fileclose>
80103311:	83 c4 10             	add    $0x10,%esp
  return -1;
}
80103314:	8d 65 f4             	lea    -0xc(%ebp),%esp
    kfree((char*)p);
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
80103317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010331c:	5b                   	pop    %ebx
8010331d:	5e                   	pop    %esi
8010331e:	5f                   	pop    %edi
8010331f:	5d                   	pop    %ebp
80103320:	c3                   	ret    
80103321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80103328:	8b 06                	mov    (%esi),%eax
8010332a:	85 c0                	test   %eax,%eax
8010332c:	75 c8                	jne    801032f6 <pipealloc+0xc6>
8010332e:	eb d2                	jmp    80103302 <pipealloc+0xd2>

80103330 <pipeclose>:
  return -1;
}

void
pipeclose(struct pipe *p, int writable)
{
80103330:	55                   	push   %ebp
80103331:	89 e5                	mov    %esp,%ebp
80103333:	56                   	push   %esi
80103334:	53                   	push   %ebx
80103335:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103338:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010333b:	83 ec 0c             	sub    $0xc,%esp
8010333e:	53                   	push   %ebx
8010333f:	e8 9c 0f 00 00       	call   801042e0 <acquire>
  if(writable){
80103344:	83 c4 10             	add    $0x10,%esp
80103347:	85 f6                	test   %esi,%esi
80103349:	74 45                	je     80103390 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
8010334b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103351:	83 ec 0c             	sub    $0xc,%esp
void
pipeclose(struct pipe *p, int writable)
{
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
80103354:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010335b:	00 00 00 
    wakeup(&p->nread);
8010335e:	50                   	push   %eax
8010335f:	e8 bc 0b 00 00       	call   80103f20 <wakeup>
80103364:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103367:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010336d:	85 d2                	test   %edx,%edx
8010336f:	75 0a                	jne    8010337b <pipeclose+0x4b>
80103371:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103377:	85 c0                	test   %eax,%eax
80103379:	74 35                	je     801033b0 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010337b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010337e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103381:	5b                   	pop    %ebx
80103382:	5e                   	pop    %esi
80103383:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80103384:	e9 77 10 00 00       	jmp    80104400 <release>
80103389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
80103390:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103396:	83 ec 0c             	sub    $0xc,%esp
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
80103399:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801033a0:	00 00 00 
    wakeup(&p->nwrite);
801033a3:	50                   	push   %eax
801033a4:	e8 77 0b 00 00       	call   80103f20 <wakeup>
801033a9:	83 c4 10             	add    $0x10,%esp
801033ac:	eb b9                	jmp    80103367 <pipeclose+0x37>
801033ae:	66 90                	xchg   %ax,%ax
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
801033b0:	83 ec 0c             	sub    $0xc,%esp
801033b3:	53                   	push   %ebx
801033b4:	e8 47 10 00 00       	call   80104400 <release>
    kfree((char*)p);
801033b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801033bc:	83 c4 10             	add    $0x10,%esp
  } else
    release(&p->lock);
}
801033bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033c2:	5b                   	pop    %ebx
801033c3:	5e                   	pop    %esi
801033c4:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
801033c5:	e9 83 f0 ff ff       	jmp    8010244d <kfree>
801033ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801033d0 <pipewrite>:
}

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	57                   	push   %edi
801033d4:	56                   	push   %esi
801033d5:	53                   	push   %ebx
801033d6:	83 ec 28             	sub    $0x28,%esp
801033d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801033dc:	53                   	push   %ebx
801033dd:	e8 fe 0e 00 00       	call   801042e0 <acquire>
  for(i = 0; i < n; i++){
801033e2:	8b 45 10             	mov    0x10(%ebp),%eax
801033e5:	83 c4 10             	add    $0x10,%esp
801033e8:	85 c0                	test   %eax,%eax
801033ea:	0f 8e b9 00 00 00    	jle    801034a9 <pipewrite+0xd9>
801033f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801033f3:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801033f9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801033ff:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
80103405:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80103408:	03 4d 10             	add    0x10(%ebp),%ecx
8010340b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010340e:	8b 8b 34 02 00 00    	mov    0x234(%ebx),%ecx
80103414:	8d 91 00 02 00 00    	lea    0x200(%ecx),%edx
8010341a:	39 d0                	cmp    %edx,%eax
8010341c:	74 38                	je     80103456 <pipewrite+0x86>
8010341e:	eb 59                	jmp    80103479 <pipewrite+0xa9>
      if(p->readopen == 0 || myproc()->killed){
80103420:	e8 9b 03 00 00       	call   801037c0 <myproc>
80103425:	8b 48 24             	mov    0x24(%eax),%ecx
80103428:	85 c9                	test   %ecx,%ecx
8010342a:	75 34                	jne    80103460 <pipewrite+0x90>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010342c:	83 ec 0c             	sub    $0xc,%esp
8010342f:	57                   	push   %edi
80103430:	e8 eb 0a 00 00       	call   80103f20 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103435:	58                   	pop    %eax
80103436:	5a                   	pop    %edx
80103437:	53                   	push   %ebx
80103438:	56                   	push   %esi
80103439:	e8 32 09 00 00       	call   80103d70 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010343e:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103444:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010344a:	83 c4 10             	add    $0x10,%esp
8010344d:	05 00 02 00 00       	add    $0x200,%eax
80103452:	39 c2                	cmp    %eax,%edx
80103454:	75 2a                	jne    80103480 <pipewrite+0xb0>
      if(p->readopen == 0 || myproc()->killed){
80103456:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
8010345c:	85 c0                	test   %eax,%eax
8010345e:	75 c0                	jne    80103420 <pipewrite+0x50>
        release(&p->lock);
80103460:	83 ec 0c             	sub    $0xc,%esp
80103463:	53                   	push   %ebx
80103464:	e8 97 0f 00 00       	call   80104400 <release>
        return -1;
80103469:	83 c4 10             	add    $0x10,%esp
8010346c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103471:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103474:	5b                   	pop    %ebx
80103475:	5e                   	pop    %esi
80103476:	5f                   	pop    %edi
80103477:	5d                   	pop    %ebp
80103478:	c3                   	ret    
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103479:	89 c2                	mov    %eax,%edx
8010347b:	90                   	nop
8010347c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103480:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103483:	8d 42 01             	lea    0x1(%edx),%eax
80103486:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010348a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103490:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103496:	0f b6 09             	movzbl (%ecx),%ecx
80103499:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
8010349d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801034a0:	3b 4d e0             	cmp    -0x20(%ebp),%ecx
801034a3:	0f 85 65 ff ff ff    	jne    8010340e <pipewrite+0x3e>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801034a9:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801034af:	83 ec 0c             	sub    $0xc,%esp
801034b2:	50                   	push   %eax
801034b3:	e8 68 0a 00 00       	call   80103f20 <wakeup>
  release(&p->lock);
801034b8:	89 1c 24             	mov    %ebx,(%esp)
801034bb:	e8 40 0f 00 00       	call   80104400 <release>
  return n;
801034c0:	83 c4 10             	add    $0x10,%esp
801034c3:	8b 45 10             	mov    0x10(%ebp),%eax
801034c6:	eb a9                	jmp    80103471 <pipewrite+0xa1>
801034c8:	90                   	nop
801034c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801034d0 <piperead>:
}

int
piperead(struct pipe *p, char *addr, int n)
{
801034d0:	55                   	push   %ebp
801034d1:	89 e5                	mov    %esp,%ebp
801034d3:	57                   	push   %edi
801034d4:	56                   	push   %esi
801034d5:	53                   	push   %ebx
801034d6:	83 ec 18             	sub    $0x18,%esp
801034d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801034df:	53                   	push   %ebx
801034e0:	e8 fb 0d 00 00       	call   801042e0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801034e5:	83 c4 10             	add    $0x10,%esp
801034e8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801034ee:	39 83 38 02 00 00    	cmp    %eax,0x238(%ebx)
801034f4:	75 6a                	jne    80103560 <piperead+0x90>
801034f6:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
801034fc:	85 f6                	test   %esi,%esi
801034fe:	0f 84 cc 00 00 00    	je     801035d0 <piperead+0x100>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103504:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
8010350a:	eb 2d                	jmp    80103539 <piperead+0x69>
8010350c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103510:	83 ec 08             	sub    $0x8,%esp
80103513:	53                   	push   %ebx
80103514:	56                   	push   %esi
80103515:	e8 56 08 00 00       	call   80103d70 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010351a:	83 c4 10             	add    $0x10,%esp
8010351d:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103523:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103529:	75 35                	jne    80103560 <piperead+0x90>
8010352b:	8b 93 40 02 00 00    	mov    0x240(%ebx),%edx
80103531:	85 d2                	test   %edx,%edx
80103533:	0f 84 97 00 00 00    	je     801035d0 <piperead+0x100>
    if(myproc()->killed){
80103539:	e8 82 02 00 00       	call   801037c0 <myproc>
8010353e:	8b 48 24             	mov    0x24(%eax),%ecx
80103541:	85 c9                	test   %ecx,%ecx
80103543:	74 cb                	je     80103510 <piperead+0x40>
      release(&p->lock);
80103545:	83 ec 0c             	sub    $0xc,%esp
80103548:	53                   	push   %ebx
80103549:	e8 b2 0e 00 00       	call   80104400 <release>
      return -1;
8010354e:	83 c4 10             	add    $0x10,%esp
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103551:	8d 65 f4             	lea    -0xc(%ebp),%esp

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
    if(myproc()->killed){
      release(&p->lock);
      return -1;
80103554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103559:	5b                   	pop    %ebx
8010355a:	5e                   	pop    %esi
8010355b:	5f                   	pop    %edi
8010355c:	5d                   	pop    %ebp
8010355d:	c3                   	ret    
8010355e:	66 90                	xchg   %ax,%ax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103560:	8b 45 10             	mov    0x10(%ebp),%eax
80103563:	85 c0                	test   %eax,%eax
80103565:	7e 69                	jle    801035d0 <piperead+0x100>
    if(p->nread == p->nwrite)
80103567:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010356d:	31 c9                	xor    %ecx,%ecx
8010356f:	eb 15                	jmp    80103586 <piperead+0xb6>
80103571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103578:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010357e:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103584:	74 5a                	je     801035e0 <piperead+0x110>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103586:	8d 70 01             	lea    0x1(%eax),%esi
80103589:	25 ff 01 00 00       	and    $0x1ff,%eax
8010358e:	89 b3 34 02 00 00    	mov    %esi,0x234(%ebx)
80103594:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103599:	88 04 0f             	mov    %al,(%edi,%ecx,1)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010359c:	83 c1 01             	add    $0x1,%ecx
8010359f:	39 4d 10             	cmp    %ecx,0x10(%ebp)
801035a2:	75 d4                	jne    80103578 <piperead+0xa8>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801035a4:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	50                   	push   %eax
801035ae:	e8 6d 09 00 00       	call   80103f20 <wakeup>
  release(&p->lock);
801035b3:	89 1c 24             	mov    %ebx,(%esp)
801035b6:	e8 45 0e 00 00       	call   80104400 <release>
  return i;
801035bb:	8b 45 10             	mov    0x10(%ebp),%eax
801035be:	83 c4 10             	add    $0x10,%esp
}
801035c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035c4:	5b                   	pop    %ebx
801035c5:	5e                   	pop    %esi
801035c6:	5f                   	pop    %edi
801035c7:	5d                   	pop    %ebp
801035c8:	c3                   	ret    
801035c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801035d0:	c7 45 10 00 00 00 00 	movl   $0x0,0x10(%ebp)
801035d7:	eb cb                	jmp    801035a4 <piperead+0xd4>
801035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801035e0:	89 4d 10             	mov    %ecx,0x10(%ebp)
801035e3:	eb bf                	jmp    801035a4 <piperead+0xd4>
801035e5:	66 90                	xchg   %ax,%ax
801035e7:	66 90                	xchg   %ax,%ax
801035e9:	66 90                	xchg   %ax,%ax
801035eb:	66 90                	xchg   %ax,%ax
801035ed:	66 90                	xchg   %ax,%ax
801035ef:	90                   	nop

801035f0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801035f0:	55                   	push   %ebp
801035f1:	89 e5                	mov    %esp,%ebp
801035f3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801035f4:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801035f9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801035fc:	68 20 2d 11 80       	push   $0x80112d20
80103601:	e8 da 0c 00 00       	call   801042e0 <acquire>
80103606:	83 c4 10             	add    $0x10,%esp
80103609:	eb 10                	jmp    8010361b <allocproc+0x2b>
8010360b:	90                   	nop
8010360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103610:	83 c3 7c             	add    $0x7c,%ebx
80103613:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103619:	74 75                	je     80103690 <allocproc+0xa0>
    if(p->state == UNUSED)
8010361b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010361e:	85 c0                	test   %eax,%eax
80103620:	75 ee                	jne    80103610 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103622:	a1 04 a0 10 80       	mov    0x8010a004,%eax

  release(&ptable.lock);
80103627:	83 ec 0c             	sub    $0xc,%esp

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010362a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;

  release(&ptable.lock);
80103631:	68 20 2d 11 80       	push   $0x80112d20
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103636:	8d 50 01             	lea    0x1(%eax),%edx
80103639:	89 43 10             	mov    %eax,0x10(%ebx)
8010363c:	89 15 04 a0 10 80    	mov    %edx,0x8010a004

  release(&ptable.lock);
80103642:	e8 b9 0d 00 00       	call   80104400 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103647:	e8 9b ee ff ff       	call   801024e7 <kalloc>
8010364c:	83 c4 10             	add    $0x10,%esp
8010364f:	85 c0                	test   %eax,%eax
80103651:	89 43 08             	mov    %eax,0x8(%ebx)
80103654:	74 51                	je     801036a7 <allocproc+0xb7>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103656:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
8010365c:	83 ec 04             	sub    $0x4,%esp
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
8010365f:	05 9c 0f 00 00       	add    $0xf9c,%eax
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103664:	89 53 18             	mov    %edx,0x18(%ebx)
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
80103667:	c7 40 14 f2 56 10 80 	movl   $0x801056f2,0x14(%eax)

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
8010366e:	6a 14                	push   $0x14
80103670:	6a 00                	push   $0x0
80103672:	50                   	push   %eax
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
80103673:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103676:	e8 d5 0d 00 00       	call   80104450 <memset>
  p->context->eip = (uint)forkret;
8010367b:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
8010367e:	83 c4 10             	add    $0x10,%esp
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;
80103681:	c7 40 10 b0 36 10 80 	movl   $0x801036b0,0x10(%eax)

  return p;
80103688:	89 d8                	mov    %ebx,%eax
}
8010368a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010368d:	c9                   	leave  
8010368e:	c3                   	ret    
8010368f:	90                   	nop

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80103690:	83 ec 0c             	sub    $0xc,%esp
80103693:	68 20 2d 11 80       	push   $0x80112d20
80103698:	e8 63 0d 00 00       	call   80104400 <release>
  return 0;
8010369d:	83 c4 10             	add    $0x10,%esp
801036a0:	31 c0                	xor    %eax,%eax
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
801036a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801036a5:	c9                   	leave  
801036a6:	c3                   	ret    

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801036a7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801036ae:	eb da                	jmp    8010368a <allocproc+0x9a>

801036b0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801036b0:	55                   	push   %ebp
801036b1:	89 e5                	mov    %esp,%ebp
801036b3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801036b6:	68 20 2d 11 80       	push   $0x80112d20
801036bb:	e8 40 0d 00 00       	call   80104400 <release>

  if (first) {
801036c0:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	85 c0                	test   %eax,%eax
801036ca:	75 04                	jne    801036d0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801036cc:	c9                   	leave  
801036cd:	c3                   	ret    
801036ce:	66 90                	xchg   %ax,%ax
  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
801036d0:	83 ec 0c             	sub    $0xc,%esp

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801036d3:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801036da:	00 00 00 
    iinit(ROOTDEV);
801036dd:	6a 01                	push   $0x1
801036df:	e8 6c de ff ff       	call   80101550 <iinit>
    initlog(ROOTDEV);
801036e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801036eb:	e8 00 f4 ff ff       	call   80102af0 <initlog>
801036f0:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801036f3:	c9                   	leave  
801036f4:	c3                   	ret    
801036f5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801036f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103700 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103700:	55                   	push   %ebp
80103701:	89 e5                	mov    %esp,%ebp
80103703:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103706:	68 55 75 10 80       	push   $0x80107555
8010370b:	68 20 2d 11 80       	push   $0x80112d20
80103710:	e8 cb 0a 00 00       	call   801041e0 <initlock>
}
80103715:	83 c4 10             	add    $0x10,%esp
80103718:	c9                   	leave  
80103719:	c3                   	ret    
8010371a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103720 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103720:	55                   	push   %ebp
80103721:	89 e5                	mov    %esp,%ebp
80103723:	56                   	push   %esi
80103724:	53                   	push   %ebx

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103725:	9c                   	pushf  
80103726:	58                   	pop    %eax
  int apicid, i;
  
  if(readeflags()&FL_IF)
80103727:	f6 c4 02             	test   $0x2,%ah
8010372a:	75 5b                	jne    80103787 <mycpu+0x67>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
8010372c:	e8 ff ef ff ff       	call   80102730 <lapicid>
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103731:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80103737:	85 f6                	test   %esi,%esi
80103739:	7e 3f                	jle    8010377a <mycpu+0x5a>
    if (cpus[i].apicid == apicid)
8010373b:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
80103742:	39 d0                	cmp    %edx,%eax
80103744:	74 30                	je     80103776 <mycpu+0x56>
80103746:	b9 30 28 11 80       	mov    $0x80112830,%ecx
8010374b:	31 d2                	xor    %edx,%edx
8010374d:	8d 76 00             	lea    0x0(%esi),%esi
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103750:	83 c2 01             	add    $0x1,%edx
80103753:	39 f2                	cmp    %esi,%edx
80103755:	74 23                	je     8010377a <mycpu+0x5a>
    if (cpus[i].apicid == apicid)
80103757:	0f b6 19             	movzbl (%ecx),%ebx
8010375a:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
80103760:	39 d8                	cmp    %ebx,%eax
80103762:	75 ec                	jne    80103750 <mycpu+0x30>
      return &cpus[i];
80103764:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
  }
  panic("unknown apicid\n");
}
8010376a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010376d:	5b                   	pop    %ebx
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
8010376e:	05 80 27 11 80       	add    $0x80112780,%eax
  }
  panic("unknown apicid\n");
}
80103773:	5e                   	pop    %esi
80103774:	5d                   	pop    %ebp
80103775:	c3                   	ret    
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103776:	31 d2                	xor    %edx,%edx
80103778:	eb ea                	jmp    80103764 <mycpu+0x44>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
8010377a:	83 ec 0c             	sub    $0xc,%esp
8010377d:	68 5c 75 10 80       	push   $0x8010755c
80103782:	e8 e9 cb ff ff       	call   80100370 <panic>
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 38 76 10 80       	push   $0x80107638
8010378f:	e8 dc cb ff ff       	call   80100370 <panic>
80103794:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010379a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801037a0 <cpuid>:
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
801037a0:	55                   	push   %ebp
801037a1:	89 e5                	mov    %esp,%ebp
801037a3:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801037a6:	e8 75 ff ff ff       	call   80103720 <mycpu>
801037ab:	2d 80 27 11 80       	sub    $0x80112780,%eax
}
801037b0:	c9                   	leave  
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
801037b1:	c1 f8 04             	sar    $0x4,%eax
801037b4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801037ba:	c3                   	ret    
801037bb:	90                   	nop
801037bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801037c0 <myproc>:
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801037c0:	55                   	push   %ebp
801037c1:	89 e5                	mov    %esp,%ebp
801037c3:	53                   	push   %ebx
801037c4:	83 ec 04             	sub    $0x4,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801037c7:	e8 d4 0a 00 00       	call   801042a0 <pushcli>
  c = mycpu();
801037cc:	e8 4f ff ff ff       	call   80103720 <mycpu>
  p = c->proc;
801037d1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801037d7:	e8 b4 0b 00 00       	call   80104390 <popcli>
  return p;
}
801037dc:	83 c4 04             	add    $0x4,%esp
801037df:	89 d8                	mov    %ebx,%eax
801037e1:	5b                   	pop    %ebx
801037e2:	5d                   	pop    %ebp
801037e3:	c3                   	ret    
801037e4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801037ea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801037f0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	53                   	push   %ebx
801037f4:	83 ec 04             	sub    $0x4,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801037f7:	e8 f4 fd ff ff       	call   801035f0 <allocproc>
801037fc:	89 c3                	mov    %eax,%ebx
  
  initproc = p;
801037fe:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103803:	e8 d8 34 00 00       	call   80106ce0 <setupkvm>
80103808:	85 c0                	test   %eax,%eax
8010380a:	89 43 04             	mov    %eax,0x4(%ebx)
8010380d:	0f 84 bd 00 00 00    	je     801038d0 <userinit+0xe0>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103813:	83 ec 04             	sub    $0x4,%esp
80103816:	68 2c 00 00 00       	push   $0x2c
8010381b:	68 60 a4 10 80       	push   $0x8010a460
80103820:	50                   	push   %eax
80103821:	e8 ca 31 00 00       	call   801069f0 <inituvm>
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
80103826:	83 c4 0c             	add    $0xc,%esp
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
80103829:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010382f:	6a 4c                	push   $0x4c
80103831:	6a 00                	push   $0x0
80103833:	ff 73 18             	pushl  0x18(%ebx)
80103836:	e8 15 0c 00 00       	call   80104450 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010383b:	8b 43 18             	mov    0x18(%ebx),%eax
8010383e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103843:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103848:	83 c4 0c             	add    $0xc,%esp
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010384b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010384f:	8b 43 18             	mov    0x18(%ebx),%eax
80103852:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103856:	8b 43 18             	mov    0x18(%ebx),%eax
80103859:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010385d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103861:	8b 43 18             	mov    0x18(%ebx),%eax
80103864:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103868:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010386c:	8b 43 18             	mov    0x18(%ebx),%eax
8010386f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103876:	8b 43 18             	mov    0x18(%ebx),%eax
80103879:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103880:	8b 43 18             	mov    0x18(%ebx),%eax
80103883:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010388a:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010388d:	6a 10                	push   $0x10
8010388f:	68 85 75 10 80       	push   $0x80107585
80103894:	50                   	push   %eax
80103895:	e8 b6 0d 00 00       	call   80104650 <safestrcpy>
  p->cwd = namei("/");
8010389a:	c7 04 24 8e 75 10 80 	movl   $0x8010758e,(%esp)
801038a1:	e8 fa e6 ff ff       	call   80101fa0 <namei>
801038a6:	89 43 68             	mov    %eax,0x68(%ebx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801038a9:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038b0:	e8 2b 0a 00 00       	call   801042e0 <acquire>

  p->state = RUNNABLE;
801038b5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)

  release(&ptable.lock);
801038bc:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038c3:	e8 38 0b 00 00       	call   80104400 <release>
}
801038c8:	83 c4 10             	add    $0x10,%esp
801038cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038ce:	c9                   	leave  
801038cf:	c3                   	ret    

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
801038d0:	83 ec 0c             	sub    $0xc,%esp
801038d3:	68 6c 75 10 80       	push   $0x8010756c
801038d8:	e8 93 ca ff ff       	call   80100370 <panic>
801038dd:	8d 76 00             	lea    0x0(%esi),%esi

801038e0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801038e0:	55                   	push   %ebp
801038e1:	89 e5                	mov    %esp,%ebp
801038e3:	56                   	push   %esi
801038e4:	53                   	push   %ebx
801038e5:	8b 75 08             	mov    0x8(%ebp),%esi
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
801038e8:	e8 b3 09 00 00       	call   801042a0 <pushcli>
  c = mycpu();
801038ed:	e8 2e fe ff ff       	call   80103720 <mycpu>
  p = c->proc;
801038f2:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801038f8:	e8 93 0a 00 00       	call   80104390 <popcli>
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
801038fd:	83 fe 00             	cmp    $0x0,%esi
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
80103900:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103902:	7e 34                	jle    80103938 <growproc+0x58>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103904:	83 ec 04             	sub    $0x4,%esp
80103907:	01 c6                	add    %eax,%esi
80103909:	56                   	push   %esi
8010390a:	50                   	push   %eax
8010390b:	ff 73 04             	pushl  0x4(%ebx)
8010390e:	e8 1d 32 00 00       	call   80106b30 <allocuvm>
80103913:	83 c4 10             	add    $0x10,%esp
80103916:	85 c0                	test   %eax,%eax
80103918:	74 36                	je     80103950 <growproc+0x70>
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
8010391a:	83 ec 0c             	sub    $0xc,%esp
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
8010391d:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010391f:	53                   	push   %ebx
80103920:	e8 bb 2f 00 00       	call   801068e0 <switchuvm>
  return 0;
80103925:	83 c4 10             	add    $0x10,%esp
80103928:	31 c0                	xor    %eax,%eax
}
8010392a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010392d:	5b                   	pop    %ebx
8010392e:	5e                   	pop    %esi
8010392f:	5d                   	pop    %ebp
80103930:	c3                   	ret    
80103931:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
80103938:	74 e0                	je     8010391a <growproc+0x3a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010393a:	83 ec 04             	sub    $0x4,%esp
8010393d:	01 c6                	add    %eax,%esi
8010393f:	56                   	push   %esi
80103940:	50                   	push   %eax
80103941:	ff 73 04             	pushl  0x4(%ebx)
80103944:	e8 e7 32 00 00       	call   80106c30 <deallocuvm>
80103949:	83 c4 10             	add    $0x10,%esp
8010394c:	85 c0                	test   %eax,%eax
8010394e:	75 ca                	jne    8010391a <growproc+0x3a>
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
80103950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103955:	eb d3                	jmp    8010392a <growproc+0x4a>
80103957:	89 f6                	mov    %esi,%esi
80103959:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103960 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
80103963:	57                   	push   %edi
80103964:	56                   	push   %esi
80103965:	53                   	push   %ebx
80103966:	83 ec 1c             	sub    $0x1c,%esp
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103969:	e8 32 09 00 00       	call   801042a0 <pushcli>
  c = mycpu();
8010396e:	e8 ad fd ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103973:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103979:	e8 12 0a 00 00       	call   80104390 <popcli>
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
8010397e:	e8 6d fc ff ff       	call   801035f0 <allocproc>
80103983:	85 c0                	test   %eax,%eax
80103985:	89 c7                	mov    %eax,%edi
80103987:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010398a:	0f 84 b5 00 00 00    	je     80103a45 <fork+0xe5>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103990:	83 ec 08             	sub    $0x8,%esp
80103993:	ff 33                	pushl  (%ebx)
80103995:	ff 73 04             	pushl  0x4(%ebx)
80103998:	e8 13 34 00 00       	call   80106db0 <copyuvm>
8010399d:	83 c4 10             	add    $0x10,%esp
801039a0:	85 c0                	test   %eax,%eax
801039a2:	89 47 04             	mov    %eax,0x4(%edi)
801039a5:	0f 84 a1 00 00 00    	je     80103a4c <fork+0xec>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
801039ab:	8b 03                	mov    (%ebx),%eax
801039ad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801039b0:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801039b2:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801039b5:	89 c8                	mov    %ecx,%eax
801039b7:	8b 79 18             	mov    0x18(%ecx),%edi
801039ba:	8b 73 18             	mov    0x18(%ebx),%esi
801039bd:	b9 13 00 00 00       	mov    $0x13,%ecx
801039c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801039c4:	31 f6                	xor    %esi,%esi
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801039c6:	8b 40 18             	mov    0x18(%eax),%eax
801039c9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
801039d0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801039d4:	85 c0                	test   %eax,%eax
801039d6:	74 13                	je     801039eb <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
801039d8:	83 ec 0c             	sub    $0xc,%esp
801039db:	50                   	push   %eax
801039dc:	e8 df d4 ff ff       	call   80100ec0 <filedup>
801039e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801039e4:	83 c4 10             	add    $0x10,%esp
801039e7:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801039eb:	83 c6 01             	add    $0x1,%esi
801039ee:	83 fe 10             	cmp    $0x10,%esi
801039f1:	75 dd                	jne    801039d0 <fork+0x70>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801039f3:	83 ec 0c             	sub    $0xc,%esp
801039f6:	ff 73 68             	pushl  0x68(%ebx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801039f9:	83 c3 6c             	add    $0x6c,%ebx
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801039fc:	e8 1f dd ff ff       	call   80101720 <idup>
80103a01:	8b 7d e4             	mov    -0x1c(%ebp),%edi

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103a04:	83 c4 0c             	add    $0xc,%esp
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80103a07:	89 47 68             	mov    %eax,0x68(%edi)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103a0a:	8d 47 6c             	lea    0x6c(%edi),%eax
80103a0d:	6a 10                	push   $0x10
80103a0f:	53                   	push   %ebx
80103a10:	50                   	push   %eax
80103a11:	e8 3a 0c 00 00       	call   80104650 <safestrcpy>

  pid = np->pid;
80103a16:	8b 5f 10             	mov    0x10(%edi),%ebx

  acquire(&ptable.lock);
80103a19:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a20:	e8 bb 08 00 00       	call   801042e0 <acquire>

  np->state = RUNNABLE;
80103a25:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)

  release(&ptable.lock);
80103a2c:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a33:	e8 c8 09 00 00       	call   80104400 <release>

  return pid;
80103a38:	83 c4 10             	add    $0x10,%esp
80103a3b:	89 d8                	mov    %ebx,%eax
}
80103a3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a40:	5b                   	pop    %ebx
80103a41:	5e                   	pop    %esi
80103a42:	5f                   	pop    %edi
80103a43:	5d                   	pop    %ebp
80103a44:	c3                   	ret    
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
80103a45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a4a:	eb f1                	jmp    80103a3d <fork+0xdd>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
80103a4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	ff 77 08             	pushl  0x8(%edi)
80103a55:	e8 f3 e9 ff ff       	call   8010244d <kfree>
    np->kstack = 0;
80103a5a:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
    np->state = UNUSED;
80103a61:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
    return -1;
80103a68:	83 c4 10             	add    $0x10,%esp
80103a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a70:	eb cb                	jmp    80103a3d <fork+0xdd>
80103a72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103a80 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80103a80:	55                   	push   %ebp
80103a81:	89 e5                	mov    %esp,%ebp
80103a83:	57                   	push   %edi
80103a84:	56                   	push   %esi
80103a85:	53                   	push   %ebx
80103a86:	83 ec 0c             	sub    $0xc,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80103a89:	e8 92 fc ff ff       	call   80103720 <mycpu>
80103a8e:	8d 78 04             	lea    0x4(%eax),%edi
80103a91:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103a93:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103a9a:	00 00 00 
80103a9d:	8d 76 00             	lea    0x0(%esi),%esi
}

static inline void
sti(void)
{
  asm volatile("sti");
80103aa0:	fb                   	sti    
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80103aa1:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aa4:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80103aa9:	68 20 2d 11 80       	push   $0x80112d20
80103aae:	e8 2d 08 00 00       	call   801042e0 <acquire>
80103ab3:	83 c4 10             	add    $0x10,%esp
80103ab6:	eb 13                	jmp    80103acb <scheduler+0x4b>
80103ab8:	90                   	nop
80103ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ac0:	83 c3 7c             	add    $0x7c,%ebx
80103ac3:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103ac9:	74 45                	je     80103b10 <scheduler+0x90>
      if(p->state != RUNNABLE)
80103acb:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103acf:	75 ef                	jne    80103ac0 <scheduler+0x40>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
80103ad1:	83 ec 0c             	sub    $0xc,%esp
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80103ad4:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103ada:	53                   	push   %ebx
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103adb:	83 c3 7c             	add    $0x7c,%ebx

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
80103ade:	e8 fd 2d 00 00       	call   801068e0 <switchuvm>
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
80103ae3:	58                   	pop    %eax
80103ae4:	5a                   	pop    %edx
80103ae5:	ff 73 a0             	pushl  -0x60(%ebx)
80103ae8:	57                   	push   %edi
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;
80103ae9:	c7 43 90 04 00 00 00 	movl   $0x4,-0x70(%ebx)

      swtch(&(c->scheduler), p->context);
80103af0:	e8 b6 0b 00 00       	call   801046ab <swtch>
      switchkvm();
80103af5:	e8 c6 2d 00 00       	call   801068c0 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80103afa:	83 c4 10             	add    $0x10,%esp
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103afd:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80103b03:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103b0a:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b0d:	75 bc                	jne    80103acb <scheduler+0x4b>
80103b0f:	90                   	nop

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80103b10:	83 ec 0c             	sub    $0xc,%esp
80103b13:	68 20 2d 11 80       	push   $0x80112d20
80103b18:	e8 e3 08 00 00       	call   80104400 <release>

  }
80103b1d:	83 c4 10             	add    $0x10,%esp
80103b20:	e9 7b ff ff ff       	jmp    80103aa0 <scheduler+0x20>
80103b25:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103b29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103b30 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	56                   	push   %esi
80103b34:	53                   	push   %ebx
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103b35:	e8 66 07 00 00       	call   801042a0 <pushcli>
  c = mycpu();
80103b3a:	e8 e1 fb ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103b3f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b45:	e8 46 08 00 00       	call   80104390 <popcli>
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 20 2d 11 80       	push   $0x80112d20
80103b52:	e8 09 07 00 00       	call   80104260 <holding>
80103b57:	83 c4 10             	add    $0x10,%esp
80103b5a:	85 c0                	test   %eax,%eax
80103b5c:	74 4f                	je     80103bad <sched+0x7d>
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
80103b5e:	e8 bd fb ff ff       	call   80103720 <mycpu>
80103b63:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103b6a:	75 68                	jne    80103bd4 <sched+0xa4>
    panic("sched locks");
  if(p->state == RUNNING)
80103b6c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103b70:	74 55                	je     80103bc7 <sched+0x97>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b72:	9c                   	pushf  
80103b73:	58                   	pop    %eax
    panic("sched running");
  if(readeflags()&FL_IF)
80103b74:	f6 c4 02             	test   $0x2,%ah
80103b77:	75 41                	jne    80103bba <sched+0x8a>
    panic("sched interruptible");
  intena = mycpu()->intena;
80103b79:	e8 a2 fb ff ff       	call   80103720 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103b7e:	83 c3 1c             	add    $0x1c,%ebx
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
80103b81:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103b87:	e8 94 fb ff ff       	call   80103720 <mycpu>
80103b8c:	83 ec 08             	sub    $0x8,%esp
80103b8f:	ff 70 04             	pushl  0x4(%eax)
80103b92:	53                   	push   %ebx
80103b93:	e8 13 0b 00 00       	call   801046ab <swtch>
  mycpu()->intena = intena;
80103b98:	e8 83 fb ff ff       	call   80103720 <mycpu>
}
80103b9d:	83 c4 10             	add    $0x10,%esp
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
80103ba0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ba9:	5b                   	pop    %ebx
80103baa:	5e                   	pop    %esi
80103bab:	5d                   	pop    %ebp
80103bac:	c3                   	ret    
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
80103bad:	83 ec 0c             	sub    $0xc,%esp
80103bb0:	68 90 75 10 80       	push   $0x80107590
80103bb5:	e8 b6 c7 ff ff       	call   80100370 <panic>
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
80103bba:	83 ec 0c             	sub    $0xc,%esp
80103bbd:	68 bc 75 10 80       	push   $0x801075bc
80103bc2:	e8 a9 c7 ff ff       	call   80100370 <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
80103bc7:	83 ec 0c             	sub    $0xc,%esp
80103bca:	68 ae 75 10 80       	push   $0x801075ae
80103bcf:	e8 9c c7 ff ff       	call   80100370 <panic>
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
80103bd4:	83 ec 0c             	sub    $0xc,%esp
80103bd7:	68 a2 75 10 80       	push   $0x801075a2
80103bdc:	e8 8f c7 ff ff       	call   80100370 <panic>
80103be1:	eb 0d                	jmp    80103bf0 <exit>
80103be3:	90                   	nop
80103be4:	90                   	nop
80103be5:	90                   	nop
80103be6:	90                   	nop
80103be7:	90                   	nop
80103be8:	90                   	nop
80103be9:	90                   	nop
80103bea:	90                   	nop
80103beb:	90                   	nop
80103bec:	90                   	nop
80103bed:	90                   	nop
80103bee:	90                   	nop
80103bef:	90                   	nop

80103bf0 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103bf0:	55                   	push   %ebp
80103bf1:	89 e5                	mov    %esp,%ebp
80103bf3:	57                   	push   %edi
80103bf4:	56                   	push   %esi
80103bf5:	53                   	push   %ebx
80103bf6:	83 ec 0c             	sub    $0xc,%esp
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bf9:	e8 a2 06 00 00       	call   801042a0 <pushcli>
  c = mycpu();
80103bfe:	e8 1d fb ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103c03:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103c09:	e8 82 07 00 00       	call   80104390 <popcli>
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103c0e:	39 35 b8 a5 10 80    	cmp    %esi,0x8010a5b8
80103c14:	8d 5e 28             	lea    0x28(%esi),%ebx
80103c17:	8d 7e 68             	lea    0x68(%esi),%edi
80103c1a:	0f 84 e7 00 00 00    	je     80103d07 <exit+0x117>
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
80103c20:	8b 03                	mov    (%ebx),%eax
80103c22:	85 c0                	test   %eax,%eax
80103c24:	74 12                	je     80103c38 <exit+0x48>
      fileclose(curproc->ofile[fd]);
80103c26:	83 ec 0c             	sub    $0xc,%esp
80103c29:	50                   	push   %eax
80103c2a:	e8 e1 d2 ff ff       	call   80100f10 <fileclose>
      curproc->ofile[fd] = 0;
80103c2f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103c35:	83 c4 10             	add    $0x10,%esp
80103c38:	83 c3 04             	add    $0x4,%ebx

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103c3b:	39 df                	cmp    %ebx,%edi
80103c3d:	75 e1                	jne    80103c20 <exit+0x30>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80103c3f:	e8 4c ef ff ff       	call   80102b90 <begin_op>
  iput(curproc->cwd);
80103c44:	83 ec 0c             	sub    $0xc,%esp
80103c47:	ff 76 68             	pushl  0x68(%esi)
80103c4a:	e8 31 dc ff ff       	call   80101880 <iput>
  end_op();
80103c4f:	e8 ac ef ff ff       	call   80102c00 <end_op>
  curproc->cwd = 0;
80103c54:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)

  acquire(&ptable.lock);
80103c5b:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103c62:	e8 79 06 00 00       	call   801042e0 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103c67:	8b 56 14             	mov    0x14(%esi),%edx
80103c6a:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c6d:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103c72:	eb 0e                	jmp    80103c82 <exit+0x92>
80103c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103c78:	83 c0 7c             	add    $0x7c,%eax
80103c7b:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103c80:	74 1c                	je     80103c9e <exit+0xae>
    if(p->state == SLEEPING && p->chan == chan)
80103c82:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103c86:	75 f0                	jne    80103c78 <exit+0x88>
80103c88:	3b 50 20             	cmp    0x20(%eax),%edx
80103c8b:	75 eb                	jne    80103c78 <exit+0x88>
      p->state = RUNNABLE;
80103c8d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c94:	83 c0 7c             	add    $0x7c,%eax
80103c97:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103c9c:	75 e4                	jne    80103c82 <exit+0x92>
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80103c9e:	8b 0d b8 a5 10 80    	mov    0x8010a5b8,%ecx
80103ca4:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103ca9:	eb 10                	jmp    80103cbb <exit+0xcb>
80103cab:	90                   	nop
80103cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103cb0:	83 c2 7c             	add    $0x7c,%edx
80103cb3:	81 fa 54 4c 11 80    	cmp    $0x80114c54,%edx
80103cb9:	74 33                	je     80103cee <exit+0xfe>
    if(p->parent == curproc){
80103cbb:	39 72 14             	cmp    %esi,0x14(%edx)
80103cbe:	75 f0                	jne    80103cb0 <exit+0xc0>
      p->parent = initproc;
      if(p->state == ZOMBIE)
80103cc0:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80103cc4:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103cc7:	75 e7                	jne    80103cb0 <exit+0xc0>
80103cc9:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103cce:	eb 0a                	jmp    80103cda <exit+0xea>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103cd0:	83 c0 7c             	add    $0x7c,%eax
80103cd3:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103cd8:	74 d6                	je     80103cb0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
80103cda:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103cde:	75 f0                	jne    80103cd0 <exit+0xe0>
80103ce0:	3b 48 20             	cmp    0x20(%eax),%ecx
80103ce3:	75 eb                	jne    80103cd0 <exit+0xe0>
      p->state = RUNNABLE;
80103ce5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103cec:	eb e2                	jmp    80103cd0 <exit+0xe0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103cee:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103cf5:	e8 36 fe ff ff       	call   80103b30 <sched>
  panic("zombie exit");
80103cfa:	83 ec 0c             	sub    $0xc,%esp
80103cfd:	68 dd 75 10 80       	push   $0x801075dd
80103d02:	e8 69 c6 ff ff       	call   80100370 <panic>
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");
80103d07:	83 ec 0c             	sub    $0xc,%esp
80103d0a:	68 d0 75 10 80       	push   $0x801075d0
80103d0f:	e8 5c c6 ff ff       	call   80100370 <panic>
80103d14:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103d1a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103d20 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	53                   	push   %ebx
80103d24:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103d27:	68 20 2d 11 80       	push   $0x80112d20
80103d2c:	e8 af 05 00 00       	call   801042e0 <acquire>
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103d31:	e8 6a 05 00 00       	call   801042a0 <pushcli>
  c = mycpu();
80103d36:	e8 e5 f9 ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103d3b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d41:	e8 4a 06 00 00       	call   80104390 <popcli>
// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
80103d46:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
80103d4d:	e8 de fd ff ff       	call   80103b30 <sched>
  release(&ptable.lock);
80103d52:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103d59:	e8 a2 06 00 00       	call   80104400 <release>
}
80103d5e:	83 c4 10             	add    $0x10,%esp
80103d61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d64:	c9                   	leave  
80103d65:	c3                   	ret    
80103d66:	8d 76 00             	lea    0x0(%esi),%esi
80103d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103d70 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80103d70:	55                   	push   %ebp
80103d71:	89 e5                	mov    %esp,%ebp
80103d73:	57                   	push   %edi
80103d74:	56                   	push   %esi
80103d75:	53                   	push   %ebx
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	8b 7d 08             	mov    0x8(%ebp),%edi
80103d7c:	8b 75 0c             	mov    0xc(%ebp),%esi
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103d7f:	e8 1c 05 00 00       	call   801042a0 <pushcli>
  c = mycpu();
80103d84:	e8 97 f9 ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103d89:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d8f:	e8 fc 05 00 00       	call   80104390 <popcli>
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
80103d94:	85 db                	test   %ebx,%ebx
80103d96:	0f 84 87 00 00 00    	je     80103e23 <sleep+0xb3>
    panic("sleep");

  if(lk == 0)
80103d9c:	85 f6                	test   %esi,%esi
80103d9e:	74 76                	je     80103e16 <sleep+0xa6>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103da0:	81 fe 20 2d 11 80    	cmp    $0x80112d20,%esi
80103da6:	74 50                	je     80103df8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103da8:	83 ec 0c             	sub    $0xc,%esp
80103dab:	68 20 2d 11 80       	push   $0x80112d20
80103db0:	e8 2b 05 00 00       	call   801042e0 <acquire>
    release(lk);
80103db5:	89 34 24             	mov    %esi,(%esp)
80103db8:	e8 43 06 00 00       	call   80104400 <release>
  }
  // Go to sleep.
  p->chan = chan;
80103dbd:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103dc0:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)

  sched();
80103dc7:	e8 64 fd ff ff       	call   80103b30 <sched>

  // Tidy up.
  p->chan = 0;
80103dcc:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
80103dd3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103dda:	e8 21 06 00 00       	call   80104400 <release>
    acquire(lk);
80103ddf:	89 75 08             	mov    %esi,0x8(%ebp)
80103de2:	83 c4 10             	add    $0x10,%esp
  }
}
80103de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103de8:	5b                   	pop    %ebx
80103de9:	5e                   	pop    %esi
80103dea:	5f                   	pop    %edi
80103deb:	5d                   	pop    %ebp
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
80103dec:	e9 ef 04 00 00       	jmp    801042e0 <acquire>
80103df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
80103df8:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103dfb:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)

  sched();
80103e02:	e8 29 fd ff ff       	call   80103b30 <sched>

  // Tidy up.
  p->chan = 0;
80103e07:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
80103e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e11:	5b                   	pop    %ebx
80103e12:	5e                   	pop    %esi
80103e13:	5f                   	pop    %edi
80103e14:	5d                   	pop    %ebp
80103e15:	c3                   	ret    
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
80103e16:	83 ec 0c             	sub    $0xc,%esp
80103e19:	68 ef 75 10 80       	push   $0x801075ef
80103e1e:	e8 4d c5 ff ff       	call   80100370 <panic>
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");
80103e23:	83 ec 0c             	sub    $0xc,%esp
80103e26:	68 e9 75 10 80       	push   $0x801075e9
80103e2b:	e8 40 c5 ff ff       	call   80100370 <panic>

80103e30 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	56                   	push   %esi
80103e34:	53                   	push   %ebx
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
80103e35:	e8 66 04 00 00       	call   801042a0 <pushcli>
  c = mycpu();
80103e3a:	e8 e1 f8 ff ff       	call   80103720 <mycpu>
  p = c->proc;
80103e3f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103e45:	e8 46 05 00 00       	call   80104390 <popcli>
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
80103e4a:	83 ec 0c             	sub    $0xc,%esp
80103e4d:	68 20 2d 11 80       	push   $0x80112d20
80103e52:	e8 89 04 00 00       	call   801042e0 <acquire>
80103e57:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103e5a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e5c:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103e61:	eb 10                	jmp    80103e73 <wait+0x43>
80103e63:	90                   	nop
80103e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103e68:	83 c3 7c             	add    $0x7c,%ebx
80103e6b:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103e71:	74 1d                	je     80103e90 <wait+0x60>
      if(p->parent != curproc)
80103e73:	39 73 14             	cmp    %esi,0x14(%ebx)
80103e76:	75 f0                	jne    80103e68 <wait+0x38>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
80103e78:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103e7c:	74 30                	je     80103eae <wait+0x7e>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e7e:	83 c3 7c             	add    $0x7c,%ebx
      if(p->parent != curproc)
        continue;
      havekids = 1;
80103e81:	b8 01 00 00 00       	mov    $0x1,%eax
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e86:	81 fb 54 4c 11 80    	cmp    $0x80114c54,%ebx
80103e8c:	75 e5                	jne    80103e73 <wait+0x43>
80103e8e:	66 90                	xchg   %ax,%ax
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80103e90:	85 c0                	test   %eax,%eax
80103e92:	74 70                	je     80103f04 <wait+0xd4>
80103e94:	8b 46 24             	mov    0x24(%esi),%eax
80103e97:	85 c0                	test   %eax,%eax
80103e99:	75 69                	jne    80103f04 <wait+0xd4>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103e9b:	83 ec 08             	sub    $0x8,%esp
80103e9e:	68 20 2d 11 80       	push   $0x80112d20
80103ea3:	56                   	push   %esi
80103ea4:	e8 c7 fe ff ff       	call   80103d70 <sleep>
  }
80103ea9:	83 c4 10             	add    $0x10,%esp
80103eac:	eb ac                	jmp    80103e5a <wait+0x2a>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	ff 73 08             	pushl  0x8(%ebx)
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
80103eb4:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103eb7:	e8 91 e5 ff ff       	call   8010244d <kfree>
        p->kstack = 0;
        freevm(p->pgdir);
80103ebc:	5a                   	pop    %edx
80103ebd:	ff 73 04             	pushl  0x4(%ebx)
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
80103ec0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103ec7:	e8 94 2d 00 00       	call   80106c60 <freevm>
        p->pid = 0;
80103ecc:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103ed3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103eda:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103ede:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103ee5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103eec:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103ef3:	e8 08 05 00 00       	call   80104400 <release>
        return pid;
80103ef8:	83 c4 10             	add    $0x10,%esp
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
80103efe:	89 f0                	mov    %esi,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103f00:	5b                   	pop    %ebx
80103f01:	5e                   	pop    %esi
80103f02:	5d                   	pop    %ebp
80103f03:	c3                   	ret    
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
80103f04:	83 ec 0c             	sub    $0xc,%esp
80103f07:	68 20 2d 11 80       	push   $0x80112d20
80103f0c:	e8 ef 04 00 00       	call   80104400 <release>
      return -1;
80103f11:	83 c4 10             	add    $0x10,%esp
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103f14:	8d 65 f8             	lea    -0x8(%ebp),%esp
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
80103f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103f1c:	5b                   	pop    %ebx
80103f1d:	5e                   	pop    %esi
80103f1e:	5d                   	pop    %ebp
80103f1f:	c3                   	ret    

80103f20 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103f20:	55                   	push   %ebp
80103f21:	89 e5                	mov    %esp,%ebp
80103f23:	53                   	push   %ebx
80103f24:	83 ec 10             	sub    $0x10,%esp
80103f27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80103f2a:	68 20 2d 11 80       	push   $0x80112d20
80103f2f:	e8 ac 03 00 00       	call   801042e0 <acquire>
80103f34:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f37:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103f3c:	eb 0c                	jmp    80103f4a <wakeup+0x2a>
80103f3e:	66 90                	xchg   %ax,%ax
80103f40:	83 c0 7c             	add    $0x7c,%eax
80103f43:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103f48:	74 1c                	je     80103f66 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
80103f4a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f4e:	75 f0                	jne    80103f40 <wakeup+0x20>
80103f50:	3b 58 20             	cmp    0x20(%eax),%ebx
80103f53:	75 eb                	jne    80103f40 <wakeup+0x20>
      p->state = RUNNABLE;
80103f55:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f5c:	83 c0 7c             	add    $0x7c,%eax
80103f5f:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103f64:	75 e4                	jne    80103f4a <wakeup+0x2a>
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103f66:	c7 45 08 20 2d 11 80 	movl   $0x80112d20,0x8(%ebp)
}
80103f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f70:	c9                   	leave  
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103f71:	e9 8a 04 00 00       	jmp    80104400 <release>
80103f76:	8d 76 00             	lea    0x0(%esi),%esi
80103f79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103f80 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	53                   	push   %ebx
80103f84:	83 ec 10             	sub    $0x10,%esp
80103f87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103f8a:	68 20 2d 11 80       	push   $0x80112d20
80103f8f:	e8 4c 03 00 00       	call   801042e0 <acquire>
80103f94:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f97:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103f9c:	eb 0c                	jmp    80103faa <kill+0x2a>
80103f9e:	66 90                	xchg   %ax,%ax
80103fa0:	83 c0 7c             	add    $0x7c,%eax
80103fa3:	3d 54 4c 11 80       	cmp    $0x80114c54,%eax
80103fa8:	74 3e                	je     80103fe8 <kill+0x68>
    if(p->pid == pid){
80103faa:	39 58 10             	cmp    %ebx,0x10(%eax)
80103fad:	75 f1                	jne    80103fa0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103faf:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
80103fb3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103fba:	74 1c                	je     80103fd8 <kill+0x58>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103fbc:	83 ec 0c             	sub    $0xc,%esp
80103fbf:	68 20 2d 11 80       	push   $0x80112d20
80103fc4:	e8 37 04 00 00       	call   80104400 <release>
      return 0;
80103fc9:	83 c4 10             	add    $0x10,%esp
80103fcc:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103fd1:	c9                   	leave  
80103fd2:	c3                   	ret    
80103fd3:	90                   	nop
80103fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103fd8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103fdf:	eb db                	jmp    80103fbc <kill+0x3c>
80103fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80103fe8:	83 ec 0c             	sub    $0xc,%esp
80103feb:	68 20 2d 11 80       	push   $0x80112d20
80103ff0:	e8 0b 04 00 00       	call   80104400 <release>
  return -1;
80103ff5:	83 c4 10             	add    $0x10,%esp
80103ff8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104000:	c9                   	leave  
80104001:	c3                   	ret    
80104002:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104010 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104010:	55                   	push   %ebp
80104011:	89 e5                	mov    %esp,%ebp
80104013:	57                   	push   %edi
80104014:	56                   	push   %esi
80104015:	53                   	push   %ebx
80104016:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104019:	bb c0 2d 11 80       	mov    $0x80112dc0,%ebx
8010401e:	83 ec 3c             	sub    $0x3c,%esp
80104021:	eb 24                	jmp    80104047 <procdump+0x37>
80104023:	90                   	nop
80104024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104028:	83 ec 0c             	sub    $0xc,%esp
8010402b:	68 85 79 10 80       	push   $0x80107985
80104030:	e8 2b c6 ff ff       	call   80100660 <cprintf>
80104035:	83 c4 10             	add    $0x10,%esp
80104038:	83 c3 7c             	add    $0x7c,%ebx
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010403b:	81 fb c0 4c 11 80    	cmp    $0x80114cc0,%ebx
80104041:	0f 84 81 00 00 00    	je     801040c8 <procdump+0xb8>
    if(p->state == UNUSED)
80104047:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010404a:	85 c0                	test   %eax,%eax
8010404c:	74 ea                	je     80104038 <procdump+0x28>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010404e:	83 f8 05             	cmp    $0x5,%eax
      state = states[p->state];
    else
      state = "???";
80104051:	ba 00 76 10 80       	mov    $0x80107600,%edx
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104056:	77 11                	ja     80104069 <procdump+0x59>
80104058:	8b 14 85 60 76 10 80 	mov    -0x7fef89a0(,%eax,4),%edx
      state = states[p->state];
    else
      state = "???";
8010405f:	b8 00 76 10 80       	mov    $0x80107600,%eax
80104064:	85 d2                	test   %edx,%edx
80104066:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104069:	53                   	push   %ebx
8010406a:	52                   	push   %edx
8010406b:	ff 73 a4             	pushl  -0x5c(%ebx)
8010406e:	68 04 76 10 80       	push   $0x80107604
80104073:	e8 e8 c5 ff ff       	call   80100660 <cprintf>
    if(p->state == SLEEPING){
80104078:	83 c4 10             	add    $0x10,%esp
8010407b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010407f:	75 a7                	jne    80104028 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104081:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104084:	83 ec 08             	sub    $0x8,%esp
80104087:	8d 7d c0             	lea    -0x40(%ebp),%edi
8010408a:	50                   	push   %eax
8010408b:	8b 43 b0             	mov    -0x50(%ebx),%eax
8010408e:	8b 40 0c             	mov    0xc(%eax),%eax
80104091:	83 c0 08             	add    $0x8,%eax
80104094:	50                   	push   %eax
80104095:	e8 66 01 00 00       	call   80104200 <getcallerpcs>
8010409a:	83 c4 10             	add    $0x10,%esp
8010409d:	8d 76 00             	lea    0x0(%esi),%esi
      for(i=0; i<10 && pc[i] != 0; i++)
801040a0:	8b 17                	mov    (%edi),%edx
801040a2:	85 d2                	test   %edx,%edx
801040a4:	74 82                	je     80104028 <procdump+0x18>
        cprintf(" %p", pc[i]);
801040a6:	83 ec 08             	sub    $0x8,%esp
801040a9:	83 c7 04             	add    $0x4,%edi
801040ac:	52                   	push   %edx
801040ad:	68 41 70 10 80       	push   $0x80107041
801040b2:	e8 a9 c5 ff ff       	call   80100660 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801040b7:	83 c4 10             	add    $0x10,%esp
801040ba:	39 f7                	cmp    %esi,%edi
801040bc:	75 e2                	jne    801040a0 <procdump+0x90>
801040be:	e9 65 ff ff ff       	jmp    80104028 <procdump+0x18>
801040c3:	90                   	nop
801040c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801040c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040cb:	5b                   	pop    %ebx
801040cc:	5e                   	pop    %esi
801040cd:	5f                   	pop    %edi
801040ce:	5d                   	pop    %ebp
801040cf:	c3                   	ret    

801040d0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801040d0:	55                   	push   %ebp
801040d1:	89 e5                	mov    %esp,%ebp
801040d3:	53                   	push   %ebx
801040d4:	83 ec 0c             	sub    $0xc,%esp
801040d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801040da:	68 78 76 10 80       	push   $0x80107678
801040df:	8d 43 04             	lea    0x4(%ebx),%eax
801040e2:	50                   	push   %eax
801040e3:	e8 f8 00 00 00       	call   801041e0 <initlock>
  lk->name = name;
801040e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
801040eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801040f1:	83 c4 10             	add    $0x10,%esp
initsleeplock(struct sleeplock *lk, char *name)
{
  initlock(&lk->lk, "sleep lock");
  lk->name = name;
  lk->locked = 0;
  lk->pid = 0;
801040f4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)

void
initsleeplock(struct sleeplock *lk, char *name)
{
  initlock(&lk->lk, "sleep lock");
  lk->name = name;
801040fb:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
  lk->pid = 0;
}
801040fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104101:	c9                   	leave  
80104102:	c3                   	ret    
80104103:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104110 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104110:	55                   	push   %ebp
80104111:	89 e5                	mov    %esp,%ebp
80104113:	56                   	push   %esi
80104114:	53                   	push   %ebx
80104115:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104118:	83 ec 0c             	sub    $0xc,%esp
8010411b:	8d 73 04             	lea    0x4(%ebx),%esi
8010411e:	56                   	push   %esi
8010411f:	e8 bc 01 00 00       	call   801042e0 <acquire>
  while (lk->locked) {
80104124:	8b 13                	mov    (%ebx),%edx
80104126:	83 c4 10             	add    $0x10,%esp
80104129:	85 d2                	test   %edx,%edx
8010412b:	74 16                	je     80104143 <acquiresleep+0x33>
8010412d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104130:	83 ec 08             	sub    $0x8,%esp
80104133:	56                   	push   %esi
80104134:	53                   	push   %ebx
80104135:	e8 36 fc ff ff       	call   80103d70 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
8010413a:	8b 03                	mov    (%ebx),%eax
8010413c:	83 c4 10             	add    $0x10,%esp
8010413f:	85 c0                	test   %eax,%eax
80104141:	75 ed                	jne    80104130 <acquiresleep+0x20>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104143:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104149:	e8 72 f6 ff ff       	call   801037c0 <myproc>
8010414e:	8b 40 10             	mov    0x10(%eax),%eax
80104151:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104154:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104157:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010415a:	5b                   	pop    %ebx
8010415b:	5e                   	pop    %esi
8010415c:	5d                   	pop    %ebp
  while (lk->locked) {
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
8010415d:	e9 9e 02 00 00       	jmp    80104400 <release>
80104162:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104170 <releasesleep>:
}

void
releasesleep(struct sleeplock *lk)
{
80104170:	55                   	push   %ebp
80104171:	89 e5                	mov    %esp,%ebp
80104173:	56                   	push   %esi
80104174:	53                   	push   %ebx
80104175:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104178:	83 ec 0c             	sub    $0xc,%esp
8010417b:	8d 73 04             	lea    0x4(%ebx),%esi
8010417e:	56                   	push   %esi
8010417f:	e8 5c 01 00 00       	call   801042e0 <acquire>
  lk->locked = 0;
80104184:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010418a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104191:	89 1c 24             	mov    %ebx,(%esp)
80104194:	e8 87 fd ff ff       	call   80103f20 <wakeup>
  release(&lk->lk);
80104199:	89 75 08             	mov    %esi,0x8(%ebp)
8010419c:	83 c4 10             	add    $0x10,%esp
}
8010419f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041a2:	5b                   	pop    %ebx
801041a3:	5e                   	pop    %esi
801041a4:	5d                   	pop    %ebp
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
801041a5:	e9 56 02 00 00       	jmp    80104400 <release>
801041aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801041b0 <holdingsleep>:
}

int
holdingsleep(struct sleeplock *lk)
{
801041b0:	55                   	push   %ebp
801041b1:	89 e5                	mov    %esp,%ebp
801041b3:	56                   	push   %esi
801041b4:	53                   	push   %ebx
801041b5:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
801041b8:	83 ec 0c             	sub    $0xc,%esp
801041bb:	8d 5e 04             	lea    0x4(%esi),%ebx
801041be:	53                   	push   %ebx
801041bf:	e8 1c 01 00 00       	call   801042e0 <acquire>
  r = lk->locked;
801041c4:	8b 36                	mov    (%esi),%esi
  release(&lk->lk);
801041c6:	89 1c 24             	mov    %ebx,(%esp)
801041c9:	e8 32 02 00 00       	call   80104400 <release>
  return r;
}
801041ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041d1:	89 f0                	mov    %esi,%eax
801041d3:	5b                   	pop    %ebx
801041d4:	5e                   	pop    %esi
801041d5:	5d                   	pop    %ebp
801041d6:	c3                   	ret    
801041d7:	66 90                	xchg   %ax,%ax
801041d9:	66 90                	xchg   %ax,%ax
801041db:	66 90                	xchg   %ax,%ax
801041dd:	66 90                	xchg   %ax,%ax
801041df:	90                   	nop

801041e0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801041e0:	55                   	push   %ebp
801041e1:	89 e5                	mov    %esp,%ebp
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801041e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801041e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
801041ef:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
  lk->cpu = 0;
801041f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801041f9:	5d                   	pop    %ebp
801041fa:	c3                   	ret    
801041fb:	90                   	nop
801041fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104200 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104200:	55                   	push   %ebp
80104201:	89 e5                	mov    %esp,%ebp
80104203:	53                   	push   %ebx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104204:	8b 45 08             	mov    0x8(%ebp),%eax
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010420a:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
8010420d:	31 c0                	xor    %eax,%eax
8010420f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104210:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104216:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010421c:	77 1a                	ja     80104238 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010421e:	8b 5a 04             	mov    0x4(%edx),%ebx
80104221:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104224:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
80104227:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104229:	83 f8 0a             	cmp    $0xa,%eax
8010422c:	75 e2                	jne    80104210 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010422e:	5b                   	pop    %ebx
8010422f:	5d                   	pop    %ebp
80104230:	c3                   	ret    
80104231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104238:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010423f:	83 c0 01             	add    $0x1,%eax
80104242:	83 f8 0a             	cmp    $0xa,%eax
80104245:	74 e7                	je     8010422e <getcallerpcs+0x2e>
    pcs[i] = 0;
80104247:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010424e:	83 c0 01             	add    $0x1,%eax
80104251:	83 f8 0a             	cmp    $0xa,%eax
80104254:	75 e2                	jne    80104238 <getcallerpcs+0x38>
80104256:	eb d6                	jmp    8010422e <getcallerpcs+0x2e>
80104258:	90                   	nop
80104259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104260 <holding>:
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
80104263:	53                   	push   %ebx
80104264:	83 ec 04             	sub    $0x4,%esp
80104267:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == mycpu();
8010426a:	8b 02                	mov    (%edx),%eax
8010426c:	85 c0                	test   %eax,%eax
8010426e:	75 10                	jne    80104280 <holding+0x20>
}
80104270:	83 c4 04             	add    $0x4,%esp
80104273:	31 c0                	xor    %eax,%eax
80104275:	5b                   	pop    %ebx
80104276:	5d                   	pop    %ebp
80104277:	c3                   	ret    
80104278:	90                   	nop
80104279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
80104280:	8b 5a 08             	mov    0x8(%edx),%ebx
80104283:	e8 98 f4 ff ff       	call   80103720 <mycpu>
80104288:	39 c3                	cmp    %eax,%ebx
8010428a:	0f 94 c0             	sete   %al
}
8010428d:	83 c4 04             	add    $0x4,%esp

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
80104290:	0f b6 c0             	movzbl %al,%eax
}
80104293:	5b                   	pop    %ebx
80104294:	5d                   	pop    %ebp
80104295:	c3                   	ret    
80104296:	8d 76 00             	lea    0x0(%esi),%esi
80104299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801042a0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801042a0:	55                   	push   %ebp
801042a1:	89 e5                	mov    %esp,%ebp
801042a3:	53                   	push   %ebx
801042a4:	83 ec 04             	sub    $0x4,%esp
801042a7:	9c                   	pushf  
801042a8:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
801042a9:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801042aa:	e8 71 f4 ff ff       	call   80103720 <mycpu>
801042af:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801042b5:	85 c0                	test   %eax,%eax
801042b7:	75 11                	jne    801042ca <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
801042b9:	81 e3 00 02 00 00    	and    $0x200,%ebx
801042bf:	e8 5c f4 ff ff       	call   80103720 <mycpu>
801042c4:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
801042ca:	e8 51 f4 ff ff       	call   80103720 <mycpu>
801042cf:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
801042d6:	83 c4 04             	add    $0x4,%esp
801042d9:	5b                   	pop    %ebx
801042da:	5d                   	pop    %ebp
801042db:	c3                   	ret    
801042dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801042e0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801042e0:	55                   	push   %ebp
801042e1:	89 e5                	mov    %esp,%ebp
801042e3:	56                   	push   %esi
801042e4:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
801042e5:	e8 b6 ff ff ff       	call   801042a0 <pushcli>
  if(holding(lk))
801042ea:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
801042ed:	8b 03                	mov    (%ebx),%eax
801042ef:	85 c0                	test   %eax,%eax
801042f1:	75 7d                	jne    80104370 <acquire+0x90>
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801042f3:	ba 01 00 00 00       	mov    $0x1,%edx
801042f8:	eb 09                	jmp    80104303 <acquire+0x23>
801042fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104300:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104303:	89 d0                	mov    %edx,%eax
80104305:	f0 87 03             	lock xchg %eax,(%ebx)
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104308:	85 c0                	test   %eax,%eax
8010430a:	75 f4                	jne    80104300 <acquire+0x20>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010430c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104311:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104314:	e8 07 f4 ff ff       	call   80103720 <mycpu>
getcallerpcs(void *v, uint pcs[])
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104319:	89 ea                	mov    %ebp,%edx
  // references happen after the lock is acquired.
  __sync_synchronize();

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
  getcallerpcs(&lk, lk->pcs);
8010431b:	8d 4b 0c             	lea    0xc(%ebx),%ecx
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010431e:	89 43 08             	mov    %eax,0x8(%ebx)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104321:	31 c0                	xor    %eax,%eax
80104323:	90                   	nop
80104324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104328:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
8010432e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104334:	77 1a                	ja     80104350 <acquire+0x70>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104336:	8b 5a 04             	mov    0x4(%edx),%ebx
80104339:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010433c:	83 c0 01             	add    $0x1,%eax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
8010433f:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104341:	83 f8 0a             	cmp    $0xa,%eax
80104344:	75 e2                	jne    80104328 <acquire+0x48>
  __sync_synchronize();

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
  getcallerpcs(&lk, lk->pcs);
}
80104346:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104349:	5b                   	pop    %ebx
8010434a:	5e                   	pop    %esi
8010434b:	5d                   	pop    %ebp
8010434c:	c3                   	ret    
8010434d:	8d 76 00             	lea    0x0(%esi),%esi
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104350:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104357:	83 c0 01             	add    $0x1,%eax
8010435a:	83 f8 0a             	cmp    $0xa,%eax
8010435d:	74 e7                	je     80104346 <acquire+0x66>
    pcs[i] = 0;
8010435f:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104366:	83 c0 01             	add    $0x1,%eax
80104369:	83 f8 0a             	cmp    $0xa,%eax
8010436c:	75 e2                	jne    80104350 <acquire+0x70>
8010436e:	eb d6                	jmp    80104346 <acquire+0x66>

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
80104370:	8b 73 08             	mov    0x8(%ebx),%esi
80104373:	e8 a8 f3 ff ff       	call   80103720 <mycpu>
80104378:	39 c6                	cmp    %eax,%esi
8010437a:	0f 85 73 ff ff ff    	jne    801042f3 <acquire+0x13>
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
80104380:	83 ec 0c             	sub    $0xc,%esp
80104383:	68 83 76 10 80       	push   $0x80107683
80104388:	e8 e3 bf ff ff       	call   80100370 <panic>
8010438d:	8d 76 00             	lea    0x0(%esi),%esi

80104390 <popcli>:
  mycpu()->ncli += 1;
}

void
popcli(void)
{
80104390:	55                   	push   %ebp
80104391:	89 e5                	mov    %esp,%ebp
80104393:	83 ec 08             	sub    $0x8,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104396:	9c                   	pushf  
80104397:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104398:	f6 c4 02             	test   $0x2,%ah
8010439b:	75 52                	jne    801043ef <popcli+0x5f>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010439d:	e8 7e f3 ff ff       	call   80103720 <mycpu>
801043a2:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
801043a8:	8d 51 ff             	lea    -0x1(%ecx),%edx
801043ab:	85 d2                	test   %edx,%edx
801043ad:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801043b3:	78 2d                	js     801043e2 <popcli+0x52>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801043b5:	e8 66 f3 ff ff       	call   80103720 <mycpu>
801043ba:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801043c0:	85 d2                	test   %edx,%edx
801043c2:	74 0c                	je     801043d0 <popcli+0x40>
    sti();
}
801043c4:	c9                   	leave  
801043c5:	c3                   	ret    
801043c6:	8d 76 00             	lea    0x0(%esi),%esi
801043c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801043d0:	e8 4b f3 ff ff       	call   80103720 <mycpu>
801043d5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043db:	85 c0                	test   %eax,%eax
801043dd:	74 e5                	je     801043c4 <popcli+0x34>
}

static inline void
sti(void)
{
  asm volatile("sti");
801043df:	fb                   	sti    
    sti();
}
801043e0:	c9                   	leave  
801043e1:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
801043e2:	83 ec 0c             	sub    $0xc,%esp
801043e5:	68 a2 76 10 80       	push   $0x801076a2
801043ea:	e8 81 bf ff ff       	call   80100370 <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	68 8b 76 10 80       	push   $0x8010768b
801043f7:	e8 74 bf ff ff       	call   80100370 <panic>
801043fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104400 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	56                   	push   %esi
80104404:	53                   	push   %ebx
80104405:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
80104408:	8b 03                	mov    (%ebx),%eax
8010440a:	85 c0                	test   %eax,%eax
8010440c:	75 12                	jne    80104420 <release+0x20>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
8010440e:	83 ec 0c             	sub    $0xc,%esp
80104411:	68 a9 76 10 80       	push   $0x801076a9
80104416:	e8 55 bf ff ff       	call   80100370 <panic>
8010441b:	90                   	nop
8010441c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == mycpu();
80104420:	8b 73 08             	mov    0x8(%ebx),%esi
80104423:	e8 f8 f2 ff ff       	call   80103720 <mycpu>
80104428:	39 c6                	cmp    %eax,%esi
8010442a:	75 e2                	jne    8010440e <release+0xe>
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");

  lk->pcs[0] = 0;
8010442c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104433:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010443a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010443f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

  popcli();
}
80104445:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104448:	5b                   	pop    %ebx
80104449:	5e                   	pop    %esi
8010444a:	5d                   	pop    %ebp
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );

  popcli();
8010444b:	e9 40 ff ff ff       	jmp    80104390 <popcli>

80104450 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104450:	55                   	push   %ebp
80104451:	89 e5                	mov    %esp,%ebp
80104453:	57                   	push   %edi
80104454:	53                   	push   %ebx
80104455:	8b 55 08             	mov    0x8(%ebp),%edx
80104458:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
8010445b:	f6 c2 03             	test   $0x3,%dl
8010445e:	75 05                	jne    80104465 <memset+0x15>
80104460:	f6 c1 03             	test   $0x3,%cl
80104463:	74 13                	je     80104478 <memset+0x28>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80104465:	89 d7                	mov    %edx,%edi
80104467:	8b 45 0c             	mov    0xc(%ebp),%eax
8010446a:	fc                   	cld    
8010446b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
8010446d:	5b                   	pop    %ebx
8010446e:	89 d0                	mov    %edx,%eax
80104470:	5f                   	pop    %edi
80104471:	5d                   	pop    %ebp
80104472:	c3                   	ret    
80104473:	90                   	nop
80104474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

void*
memset(void *dst, int c, uint n)
{
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
80104478:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
8010447c:	c1 e9 02             	shr    $0x2,%ecx
8010447f:	89 fb                	mov    %edi,%ebx
80104481:	89 f8                	mov    %edi,%eax
80104483:	c1 e3 18             	shl    $0x18,%ebx
80104486:	c1 e0 10             	shl    $0x10,%eax
80104489:	09 d8                	or     %ebx,%eax
8010448b:	09 f8                	or     %edi,%eax
8010448d:	c1 e7 08             	shl    $0x8,%edi
80104490:	09 f8                	or     %edi,%eax
80104492:	89 d7                	mov    %edx,%edi
80104494:	fc                   	cld    
80104495:	f3 ab                	rep stos %eax,%es:(%edi)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104497:	5b                   	pop    %ebx
80104498:	89 d0                	mov    %edx,%eax
8010449a:	5f                   	pop    %edi
8010449b:	5d                   	pop    %ebp
8010449c:	c3                   	ret    
8010449d:	8d 76 00             	lea    0x0(%esi),%esi

801044a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	57                   	push   %edi
801044a4:	56                   	push   %esi
801044a5:	8b 45 10             	mov    0x10(%ebp),%eax
801044a8:	53                   	push   %ebx
801044a9:	8b 75 0c             	mov    0xc(%ebp),%esi
801044ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801044af:	85 c0                	test   %eax,%eax
801044b1:	74 29                	je     801044dc <memcmp+0x3c>
    if(*s1 != *s2)
801044b3:	0f b6 13             	movzbl (%ebx),%edx
801044b6:	0f b6 0e             	movzbl (%esi),%ecx
801044b9:	38 d1                	cmp    %dl,%cl
801044bb:	75 2b                	jne    801044e8 <memcmp+0x48>
801044bd:	8d 78 ff             	lea    -0x1(%eax),%edi
801044c0:	31 c0                	xor    %eax,%eax
801044c2:	eb 14                	jmp    801044d8 <memcmp+0x38>
801044c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044c8:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
801044cd:	83 c0 01             	add    $0x1,%eax
801044d0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
801044d4:	38 ca                	cmp    %cl,%dl
801044d6:	75 10                	jne    801044e8 <memcmp+0x48>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801044d8:	39 f8                	cmp    %edi,%eax
801044da:	75 ec                	jne    801044c8 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
801044dc:	5b                   	pop    %ebx
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801044dd:	31 c0                	xor    %eax,%eax
}
801044df:	5e                   	pop    %esi
801044e0:	5f                   	pop    %edi
801044e1:	5d                   	pop    %ebp
801044e2:	c3                   	ret    
801044e3:	90                   	nop
801044e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
801044e8:	0f b6 c2             	movzbl %dl,%eax
    s1++, s2++;
  }

  return 0;
}
801044eb:	5b                   	pop    %ebx

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
801044ec:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
801044ee:	5e                   	pop    %esi
801044ef:	5f                   	pop    %edi
801044f0:	5d                   	pop    %ebp
801044f1:	c3                   	ret    
801044f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801044f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104500 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104500:	55                   	push   %ebp
80104501:	89 e5                	mov    %esp,%ebp
80104503:	56                   	push   %esi
80104504:	53                   	push   %ebx
80104505:	8b 45 08             	mov    0x8(%ebp),%eax
80104508:	8b 75 0c             	mov    0xc(%ebp),%esi
8010450b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010450e:	39 c6                	cmp    %eax,%esi
80104510:	73 2e                	jae    80104540 <memmove+0x40>
80104512:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
80104515:	39 c8                	cmp    %ecx,%eax
80104517:	73 27                	jae    80104540 <memmove+0x40>
    s += n;
    d += n;
    while(n-- > 0)
80104519:	85 db                	test   %ebx,%ebx
8010451b:	8d 53 ff             	lea    -0x1(%ebx),%edx
8010451e:	74 17                	je     80104537 <memmove+0x37>
      *--d = *--s;
80104520:	29 d9                	sub    %ebx,%ecx
80104522:	89 cb                	mov    %ecx,%ebx
80104524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104528:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
8010452c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010452f:	83 ea 01             	sub    $0x1,%edx
80104532:	83 fa ff             	cmp    $0xffffffff,%edx
80104535:	75 f1                	jne    80104528 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104537:	5b                   	pop    %ebx
80104538:	5e                   	pop    %esi
80104539:	5d                   	pop    %ebp
8010453a:	c3                   	ret    
8010453b:	90                   	nop
8010453c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104540:	31 d2                	xor    %edx,%edx
80104542:	85 db                	test   %ebx,%ebx
80104544:	74 f1                	je     80104537 <memmove+0x37>
80104546:	8d 76 00             	lea    0x0(%esi),%esi
80104549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      *d++ = *s++;
80104550:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
80104554:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104557:	83 c2 01             	add    $0x1,%edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010455a:	39 d3                	cmp    %edx,%ebx
8010455c:	75 f2                	jne    80104550 <memmove+0x50>
      *d++ = *s++;

  return dst;
}
8010455e:	5b                   	pop    %ebx
8010455f:	5e                   	pop    %esi
80104560:	5d                   	pop    %ebp
80104561:	c3                   	ret    
80104562:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104569:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104570 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104573:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104574:	eb 8a                	jmp    80104500 <memmove>
80104576:	8d 76 00             	lea    0x0(%esi),%esi
80104579:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104580 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104580:	55                   	push   %ebp
80104581:	89 e5                	mov    %esp,%ebp
80104583:	57                   	push   %edi
80104584:	56                   	push   %esi
80104585:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104588:	53                   	push   %ebx
80104589:	8b 7d 08             	mov    0x8(%ebp),%edi
8010458c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
8010458f:	85 c9                	test   %ecx,%ecx
80104591:	74 37                	je     801045ca <strncmp+0x4a>
80104593:	0f b6 17             	movzbl (%edi),%edx
80104596:	0f b6 1e             	movzbl (%esi),%ebx
80104599:	84 d2                	test   %dl,%dl
8010459b:	74 3f                	je     801045dc <strncmp+0x5c>
8010459d:	38 d3                	cmp    %dl,%bl
8010459f:	75 3b                	jne    801045dc <strncmp+0x5c>
801045a1:	8d 47 01             	lea    0x1(%edi),%eax
801045a4:	01 cf                	add    %ecx,%edi
801045a6:	eb 1b                	jmp    801045c3 <strncmp+0x43>
801045a8:	90                   	nop
801045a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045b0:	0f b6 10             	movzbl (%eax),%edx
801045b3:	84 d2                	test   %dl,%dl
801045b5:	74 21                	je     801045d8 <strncmp+0x58>
801045b7:	0f b6 19             	movzbl (%ecx),%ebx
801045ba:	83 c0 01             	add    $0x1,%eax
801045bd:	89 ce                	mov    %ecx,%esi
801045bf:	38 da                	cmp    %bl,%dl
801045c1:	75 19                	jne    801045dc <strncmp+0x5c>
801045c3:	39 c7                	cmp    %eax,%edi
    n--, p++, q++;
801045c5:	8d 4e 01             	lea    0x1(%esi),%ecx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801045c8:	75 e6                	jne    801045b0 <strncmp+0x30>
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
801045ca:	5b                   	pop    %ebx
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
    n--, p++, q++;
  if(n == 0)
    return 0;
801045cb:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}
801045cd:	5e                   	pop    %esi
801045ce:	5f                   	pop    %edi
801045cf:	5d                   	pop    %ebp
801045d0:	c3                   	ret    
801045d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045d8:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
{
  while(n > 0 && *p && *p == *q)
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
801045dc:	0f b6 c2             	movzbl %dl,%eax
801045df:	29 d8                	sub    %ebx,%eax
}
801045e1:	5b                   	pop    %ebx
801045e2:	5e                   	pop    %esi
801045e3:	5f                   	pop    %edi
801045e4:	5d                   	pop    %ebp
801045e5:	c3                   	ret    
801045e6:	8d 76 00             	lea    0x0(%esi),%esi
801045e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801045f0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801045f0:	55                   	push   %ebp
801045f1:	89 e5                	mov    %esp,%ebp
801045f3:	56                   	push   %esi
801045f4:	53                   	push   %ebx
801045f5:	8b 45 08             	mov    0x8(%ebp),%eax
801045f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801045fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801045fe:	89 c2                	mov    %eax,%edx
80104600:	eb 19                	jmp    8010461b <strncpy+0x2b>
80104602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104608:	83 c3 01             	add    $0x1,%ebx
8010460b:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
8010460f:	83 c2 01             	add    $0x1,%edx
80104612:	84 c9                	test   %cl,%cl
80104614:	88 4a ff             	mov    %cl,-0x1(%edx)
80104617:	74 09                	je     80104622 <strncpy+0x32>
80104619:	89 f1                	mov    %esi,%ecx
8010461b:	85 c9                	test   %ecx,%ecx
8010461d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104620:	7f e6                	jg     80104608 <strncpy+0x18>
    ;
  while(n-- > 0)
80104622:	31 c9                	xor    %ecx,%ecx
80104624:	85 f6                	test   %esi,%esi
80104626:	7e 17                	jle    8010463f <strncpy+0x4f>
80104628:	90                   	nop
80104629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104630:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104634:	89 f3                	mov    %esi,%ebx
80104636:	83 c1 01             	add    $0x1,%ecx
80104639:	29 cb                	sub    %ecx,%ebx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010463b:	85 db                	test   %ebx,%ebx
8010463d:	7f f1                	jg     80104630 <strncpy+0x40>
    *s++ = 0;
  return os;
}
8010463f:	5b                   	pop    %ebx
80104640:	5e                   	pop    %esi
80104641:	5d                   	pop    %ebp
80104642:	c3                   	ret    
80104643:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104650 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104650:	55                   	push   %ebp
80104651:	89 e5                	mov    %esp,%ebp
80104653:	56                   	push   %esi
80104654:	53                   	push   %ebx
80104655:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104658:	8b 45 08             	mov    0x8(%ebp),%eax
8010465b:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
8010465e:	85 c9                	test   %ecx,%ecx
80104660:	7e 26                	jle    80104688 <safestrcpy+0x38>
80104662:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104666:	89 c1                	mov    %eax,%ecx
80104668:	eb 17                	jmp    80104681 <safestrcpy+0x31>
8010466a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104670:	83 c2 01             	add    $0x1,%edx
80104673:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104677:	83 c1 01             	add    $0x1,%ecx
8010467a:	84 db                	test   %bl,%bl
8010467c:	88 59 ff             	mov    %bl,-0x1(%ecx)
8010467f:	74 04                	je     80104685 <safestrcpy+0x35>
80104681:	39 f2                	cmp    %esi,%edx
80104683:	75 eb                	jne    80104670 <safestrcpy+0x20>
    ;
  *s = 0;
80104685:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104688:	5b                   	pop    %ebx
80104689:	5e                   	pop    %esi
8010468a:	5d                   	pop    %ebp
8010468b:	c3                   	ret    
8010468c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104690 <strlen>:

int
strlen(const char *s)
{
80104690:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104691:	31 c0                	xor    %eax,%eax
  return os;
}

int
strlen(const char *s)
{
80104693:	89 e5                	mov    %esp,%ebp
80104695:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104698:	80 3a 00             	cmpb   $0x0,(%edx)
8010469b:	74 0c                	je     801046a9 <strlen+0x19>
8010469d:	8d 76 00             	lea    0x0(%esi),%esi
801046a0:	83 c0 01             	add    $0x1,%eax
801046a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801046a7:	75 f7                	jne    801046a0 <strlen+0x10>
    ;
  return n;
}
801046a9:	5d                   	pop    %ebp
801046aa:	c3                   	ret    

801046ab <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801046ab:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801046af:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801046b3:	55                   	push   %ebp
  pushl %ebx
801046b4:	53                   	push   %ebx
  pushl %esi
801046b5:	56                   	push   %esi
  pushl %edi
801046b6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801046b7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801046b9:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801046bb:	5f                   	pop    %edi
  popl %esi
801046bc:	5e                   	pop    %esi
  popl %ebx
801046bd:	5b                   	pop    %ebx
  popl %ebp
801046be:	5d                   	pop    %ebp
  ret
801046bf:	c3                   	ret    

801046c0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	53                   	push   %ebx
801046c4:	83 ec 04             	sub    $0x4,%esp
801046c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801046ca:	e8 f1 f0 ff ff       	call   801037c0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801046cf:	8b 00                	mov    (%eax),%eax
801046d1:	39 d8                	cmp    %ebx,%eax
801046d3:	76 1b                	jbe    801046f0 <fetchint+0x30>
801046d5:	8d 53 04             	lea    0x4(%ebx),%edx
801046d8:	39 d0                	cmp    %edx,%eax
801046da:	72 14                	jb     801046f0 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
801046dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801046df:	8b 13                	mov    (%ebx),%edx
801046e1:	89 10                	mov    %edx,(%eax)
  return 0;
801046e3:	31 c0                	xor    %eax,%eax
}
801046e5:	83 c4 04             	add    $0x4,%esp
801046e8:	5b                   	pop    %ebx
801046e9:	5d                   	pop    %ebp
801046ea:	c3                   	ret    
801046eb:	90                   	nop
801046ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
801046f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f5:	eb ee                	jmp    801046e5 <fetchint+0x25>
801046f7:	89 f6                	mov    %esi,%esi
801046f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104700 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	53                   	push   %ebx
80104704:	83 ec 04             	sub    $0x4,%esp
80104707:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010470a:	e8 b1 f0 ff ff       	call   801037c0 <myproc>

  if(addr >= curproc->sz)
8010470f:	39 18                	cmp    %ebx,(%eax)
80104711:	76 29                	jbe    8010473c <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104716:	89 da                	mov    %ebx,%edx
80104718:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)curproc->sz;
8010471a:	8b 00                	mov    (%eax),%eax
  for(s = *pp; s < ep; s++){
8010471c:	39 c3                	cmp    %eax,%ebx
8010471e:	73 1c                	jae    8010473c <fetchstr+0x3c>
    if(*s == 0)
80104720:	80 3b 00             	cmpb   $0x0,(%ebx)
80104723:	75 10                	jne    80104735 <fetchstr+0x35>
80104725:	eb 29                	jmp    80104750 <fetchstr+0x50>
80104727:	89 f6                	mov    %esi,%esi
80104729:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104730:	80 3a 00             	cmpb   $0x0,(%edx)
80104733:	74 1b                	je     80104750 <fetchstr+0x50>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80104735:	83 c2 01             	add    $0x1,%edx
80104738:	39 d0                	cmp    %edx,%eax
8010473a:	77 f4                	ja     80104730 <fetchstr+0x30>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
}
8010473c:	83 c4 04             	add    $0x4,%esp
{
  char *s, *ep;
  struct proc *curproc = myproc();

  if(addr >= curproc->sz)
    return -1;
8010473f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  for(s = *pp; s < ep; s++){
    if(*s == 0)
      return s - *pp;
  }
  return -1;
}
80104744:	5b                   	pop    %ebx
80104745:	5d                   	pop    %ebp
80104746:	c3                   	ret    
80104747:	89 f6                	mov    %esi,%esi
80104749:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104750:	83 c4 04             	add    $0x4,%esp
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
      return s - *pp;
80104753:	89 d0                	mov    %edx,%eax
80104755:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104757:	5b                   	pop    %ebx
80104758:	5d                   	pop    %ebp
80104759:	c3                   	ret    
8010475a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104760 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104760:	55                   	push   %ebp
80104761:	89 e5                	mov    %esp,%ebp
80104763:	56                   	push   %esi
80104764:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104765:	e8 56 f0 ff ff       	call   801037c0 <myproc>
8010476a:	8b 40 18             	mov    0x18(%eax),%eax
8010476d:	8b 55 08             	mov    0x8(%ebp),%edx
80104770:	8b 40 44             	mov    0x44(%eax),%eax
80104773:	8d 1c 90             	lea    (%eax,%edx,4),%ebx

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();
80104776:	e8 45 f0 ff ff       	call   801037c0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010477b:	8b 00                	mov    (%eax),%eax

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010477d:	8d 73 04             	lea    0x4(%ebx),%esi
int
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104780:	39 c6                	cmp    %eax,%esi
80104782:	73 1c                	jae    801047a0 <argint+0x40>
80104784:	8d 53 08             	lea    0x8(%ebx),%edx
80104787:	39 d0                	cmp    %edx,%eax
80104789:	72 15                	jb     801047a0 <argint+0x40>
    return -1;
  *ip = *(int*)(addr);
8010478b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010478e:	8b 53 04             	mov    0x4(%ebx),%edx
80104791:	89 10                	mov    %edx,(%eax)
  return 0;
80104793:	31 c0                	xor    %eax,%eax
// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
}
80104795:	5b                   	pop    %ebx
80104796:	5e                   	pop    %esi
80104797:	5d                   	pop    %ebp
80104798:	c3                   	ret    
80104799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
801047a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a5:	eb ee                	jmp    80104795 <argint+0x35>
801047a7:	89 f6                	mov    %esi,%esi
801047a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801047b0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801047b0:	55                   	push   %ebp
801047b1:	89 e5                	mov    %esp,%ebp
801047b3:	56                   	push   %esi
801047b4:	53                   	push   %ebx
801047b5:	83 ec 10             	sub    $0x10,%esp
801047b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
801047bb:	e8 00 f0 ff ff       	call   801037c0 <myproc>
801047c0:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801047c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047c5:	83 ec 08             	sub    $0x8,%esp
801047c8:	50                   	push   %eax
801047c9:	ff 75 08             	pushl  0x8(%ebp)
801047cc:	e8 8f ff ff ff       	call   80104760 <argint>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801047d1:	c1 e8 1f             	shr    $0x1f,%eax
801047d4:	83 c4 10             	add    $0x10,%esp
801047d7:	84 c0                	test   %al,%al
801047d9:	75 2d                	jne    80104808 <argptr+0x58>
801047db:	89 d8                	mov    %ebx,%eax
801047dd:	c1 e8 1f             	shr    $0x1f,%eax
801047e0:	84 c0                	test   %al,%al
801047e2:	75 24                	jne    80104808 <argptr+0x58>
801047e4:	8b 16                	mov    (%esi),%edx
801047e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e9:	39 c2                	cmp    %eax,%edx
801047eb:	76 1b                	jbe    80104808 <argptr+0x58>
801047ed:	01 c3                	add    %eax,%ebx
801047ef:	39 da                	cmp    %ebx,%edx
801047f1:	72 15                	jb     80104808 <argptr+0x58>
    return -1;
  *pp = (char*)i;
801047f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801047f6:	89 02                	mov    %eax,(%edx)
  return 0;
801047f8:	31 c0                	xor    %eax,%eax
}
801047fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801047fd:	5b                   	pop    %ebx
801047fe:	5e                   	pop    %esi
801047ff:	5d                   	pop    %ebp
80104800:	c3                   	ret    
80104801:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
80104808:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480d:	eb eb                	jmp    801047fa <argptr+0x4a>
8010480f:	90                   	nop

80104810 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104816:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104819:	50                   	push   %eax
8010481a:	ff 75 08             	pushl  0x8(%ebp)
8010481d:	e8 3e ff ff ff       	call   80104760 <argint>
80104822:	83 c4 10             	add    $0x10,%esp
80104825:	85 c0                	test   %eax,%eax
80104827:	78 17                	js     80104840 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
80104829:	83 ec 08             	sub    $0x8,%esp
8010482c:	ff 75 0c             	pushl  0xc(%ebp)
8010482f:	ff 75 f4             	pushl  -0xc(%ebp)
80104832:	e8 c9 fe ff ff       	call   80104700 <fetchstr>
80104837:	83 c4 10             	add    $0x10,%esp
}
8010483a:	c9                   	leave  
8010483b:	c3                   	ret    
8010483c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
80104840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
80104845:	c9                   	leave  
80104846:	c3                   	ret    
80104847:	89 f6                	mov    %esi,%esi
80104849:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104850 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
80104850:	55                   	push   %ebp
80104851:	89 e5                	mov    %esp,%ebp
80104853:	56                   	push   %esi
80104854:	53                   	push   %ebx
  int num;
  struct proc *curproc = myproc();
80104855:	e8 66 ef ff ff       	call   801037c0 <myproc>

  num = curproc->tf->eax;
8010485a:	8b 70 18             	mov    0x18(%eax),%esi

void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();
8010485d:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010485f:	8b 46 1c             	mov    0x1c(%esi),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104862:	8d 50 ff             	lea    -0x1(%eax),%edx
80104865:	83 fa 16             	cmp    $0x16,%edx
80104868:	77 1e                	ja     80104888 <syscall+0x38>
8010486a:	8b 14 85 e0 76 10 80 	mov    -0x7fef8920(,%eax,4),%edx
80104871:	85 d2                	test   %edx,%edx
80104873:	74 13                	je     80104888 <syscall+0x38>
    curproc->tf->eax = syscalls[num]();
80104875:	ff d2                	call   *%edx
80104877:	89 46 1c             	mov    %eax,0x1c(%esi)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010487a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010487d:	5b                   	pop    %ebx
8010487e:	5e                   	pop    %esi
8010487f:	5d                   	pop    %ebp
80104880:	c3                   	ret    
80104881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80104888:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104889:	8d 43 6c             	lea    0x6c(%ebx),%eax

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010488c:	50                   	push   %eax
8010488d:	ff 73 10             	pushl  0x10(%ebx)
80104890:	68 b1 76 10 80       	push   $0x801076b1
80104895:	e8 c6 bd ff ff       	call   80100660 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
8010489a:	8b 43 18             	mov    0x18(%ebx),%eax
8010489d:	83 c4 10             	add    $0x10,%esp
801048a0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801048a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801048aa:	5b                   	pop    %ebx
801048ab:	5e                   	pop    %esi
801048ac:	5d                   	pop    %ebp
801048ad:	c3                   	ret    
801048ae:	66 90                	xchg   %ax,%ax

801048b0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801048b0:	55                   	push   %ebp
801048b1:	89 e5                	mov    %esp,%ebp
801048b3:	57                   	push   %edi
801048b4:	56                   	push   %esi
801048b5:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801048b6:	8d 75 da             	lea    -0x26(%ebp),%esi
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801048b9:	83 ec 44             	sub    $0x44,%esp
801048bc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
801048bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801048c2:	56                   	push   %esi
801048c3:	50                   	push   %eax
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801048c4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801048c7:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801048ca:	e8 f1 d6 ff ff       	call   80101fc0 <nameiparent>
801048cf:	83 c4 10             	add    $0x10,%esp
801048d2:	85 c0                	test   %eax,%eax
801048d4:	0f 84 f6 00 00 00    	je     801049d0 <create+0x120>
    return 0;
  ilock(dp);
801048da:	83 ec 0c             	sub    $0xc,%esp
801048dd:	89 c7                	mov    %eax,%edi
801048df:	50                   	push   %eax
801048e0:	e8 6b ce ff ff       	call   80101750 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801048e5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801048e8:	83 c4 0c             	add    $0xc,%esp
801048eb:	50                   	push   %eax
801048ec:	56                   	push   %esi
801048ed:	57                   	push   %edi
801048ee:	e8 8d d3 ff ff       	call   80101c80 <dirlookup>
801048f3:	83 c4 10             	add    $0x10,%esp
801048f6:	85 c0                	test   %eax,%eax
801048f8:	89 c3                	mov    %eax,%ebx
801048fa:	74 54                	je     80104950 <create+0xa0>
    iunlockput(dp);
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	57                   	push   %edi
80104900:	e8 db d0 ff ff       	call   801019e0 <iunlockput>
    ilock(ip);
80104905:	89 1c 24             	mov    %ebx,(%esp)
80104908:	e8 43 ce ff ff       	call   80101750 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010490d:	83 c4 10             	add    $0x10,%esp
80104910:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104915:	75 19                	jne    80104930 <create+0x80>
80104917:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
8010491c:	89 d8                	mov    %ebx,%eax
8010491e:	75 10                	jne    80104930 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104920:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104923:	5b                   	pop    %ebx
80104924:	5e                   	pop    %esi
80104925:	5f                   	pop    %edi
80104926:	5d                   	pop    %ebp
80104927:	c3                   	ret    
80104928:	90                   	nop
80104929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if((ip = dirlookup(dp, name, &off)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
80104930:	83 ec 0c             	sub    $0xc,%esp
80104933:	53                   	push   %ebx
80104934:	e8 a7 d0 ff ff       	call   801019e0 <iunlockput>
    return 0;
80104939:	83 c4 10             	add    $0x10,%esp
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010493c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
    return 0;
8010493f:	31 c0                	xor    %eax,%eax
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104941:	5b                   	pop    %ebx
80104942:	5e                   	pop    %esi
80104943:	5f                   	pop    %edi
80104944:	5d                   	pop    %ebp
80104945:	c3                   	ret    
80104946:	8d 76 00             	lea    0x0(%esi),%esi
80104949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      return ip;
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80104950:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104954:	83 ec 08             	sub    $0x8,%esp
80104957:	50                   	push   %eax
80104958:	ff 37                	pushl  (%edi)
8010495a:	e8 81 cc ff ff       	call   801015e0 <ialloc>
8010495f:	83 c4 10             	add    $0x10,%esp
80104962:	85 c0                	test   %eax,%eax
80104964:	89 c3                	mov    %eax,%ebx
80104966:	0f 84 cc 00 00 00    	je     80104a38 <create+0x188>
    panic("create: ialloc");

  ilock(ip);
8010496c:	83 ec 0c             	sub    $0xc,%esp
8010496f:	50                   	push   %eax
80104970:	e8 db cd ff ff       	call   80101750 <ilock>
  ip->major = major;
80104975:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104979:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010497d:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80104981:	66 89 43 54          	mov    %ax,0x54(%ebx)
  ip->nlink = 1;
80104985:	b8 01 00 00 00       	mov    $0x1,%eax
8010498a:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010498e:	89 1c 24             	mov    %ebx,(%esp)
80104991:	e8 0a cd ff ff       	call   801016a0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80104996:	83 c4 10             	add    $0x10,%esp
80104999:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010499e:	74 40                	je     801049e0 <create+0x130>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
801049a0:	83 ec 04             	sub    $0x4,%esp
801049a3:	ff 73 04             	pushl  0x4(%ebx)
801049a6:	56                   	push   %esi
801049a7:	57                   	push   %edi
801049a8:	e8 33 d5 ff ff       	call   80101ee0 <dirlink>
801049ad:	83 c4 10             	add    $0x10,%esp
801049b0:	85 c0                	test   %eax,%eax
801049b2:	78 77                	js     80104a2b <create+0x17b>
    panic("create: dirlink");

  iunlockput(dp);
801049b4:	83 ec 0c             	sub    $0xc,%esp
801049b7:	57                   	push   %edi
801049b8:	e8 23 d0 ff ff       	call   801019e0 <iunlockput>

  return ip;
801049bd:	83 c4 10             	add    $0x10,%esp
}
801049c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
801049c3:	89 d8                	mov    %ebx,%eax
}
801049c5:	5b                   	pop    %ebx
801049c6:	5e                   	pop    %esi
801049c7:	5f                   	pop    %edi
801049c8:	5d                   	pop    %ebp
801049c9:	c3                   	ret    
801049ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    return 0;
801049d0:	31 c0                	xor    %eax,%eax
801049d2:	e9 49 ff ff ff       	jmp    80104920 <create+0x70>
801049d7:	89 f6                	mov    %esi,%esi
801049d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
801049e0:	66 83 47 56 01       	addw   $0x1,0x56(%edi)
    iupdate(dp);
801049e5:	83 ec 0c             	sub    $0xc,%esp
801049e8:	57                   	push   %edi
801049e9:	e8 b2 cc ff ff       	call   801016a0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801049ee:	83 c4 0c             	add    $0xc,%esp
801049f1:	ff 73 04             	pushl  0x4(%ebx)
801049f4:	68 5c 77 10 80       	push   $0x8010775c
801049f9:	53                   	push   %ebx
801049fa:	e8 e1 d4 ff ff       	call   80101ee0 <dirlink>
801049ff:	83 c4 10             	add    $0x10,%esp
80104a02:	85 c0                	test   %eax,%eax
80104a04:	78 18                	js     80104a1e <create+0x16e>
80104a06:	83 ec 04             	sub    $0x4,%esp
80104a09:	ff 77 04             	pushl  0x4(%edi)
80104a0c:	68 5b 77 10 80       	push   $0x8010775b
80104a11:	53                   	push   %ebx
80104a12:	e8 c9 d4 ff ff       	call   80101ee0 <dirlink>
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	79 82                	jns    801049a0 <create+0xf0>
      panic("create dots");
80104a1e:	83 ec 0c             	sub    $0xc,%esp
80104a21:	68 4f 77 10 80       	push   $0x8010774f
80104a26:	e8 45 b9 ff ff       	call   80100370 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	68 5e 77 10 80       	push   $0x8010775e
80104a33:	e8 38 b9 ff ff       	call   80100370 <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 40 77 10 80       	push   $0x80107740
80104a40:	e8 2b b9 ff ff       	call   80100370 <panic>
80104a45:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104a50 <argfd.constprop.0>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
80104a50:	55                   	push   %ebp
80104a51:	89 e5                	mov    %esp,%ebp
80104a53:	56                   	push   %esi
80104a54:	53                   	push   %ebx
80104a55:	89 c6                	mov    %eax,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
80104a5a:	89 d3                	mov    %edx,%ebx
80104a5c:	83 ec 18             	sub    $0x18,%esp
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104a5f:	50                   	push   %eax
80104a60:	6a 00                	push   $0x0
80104a62:	e8 f9 fc ff ff       	call   80104760 <argint>
80104a67:	83 c4 10             	add    $0x10,%esp
80104a6a:	85 c0                	test   %eax,%eax
80104a6c:	78 32                	js     80104aa0 <argfd.constprop.0+0x50>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104a6e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104a72:	77 2c                	ja     80104aa0 <argfd.constprop.0+0x50>
80104a74:	e8 47 ed ff ff       	call   801037c0 <myproc>
80104a79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a7c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104a80:	85 c0                	test   %eax,%eax
80104a82:	74 1c                	je     80104aa0 <argfd.constprop.0+0x50>
    return -1;
  if(pfd)
80104a84:	85 f6                	test   %esi,%esi
80104a86:	74 02                	je     80104a8a <argfd.constprop.0+0x3a>
    *pfd = fd;
80104a88:	89 16                	mov    %edx,(%esi)
  if(pf)
80104a8a:	85 db                	test   %ebx,%ebx
80104a8c:	74 22                	je     80104ab0 <argfd.constprop.0+0x60>
    *pf = f;
80104a8e:	89 03                	mov    %eax,(%ebx)
  return 0;
80104a90:	31 c0                	xor    %eax,%eax
}
80104a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a95:	5b                   	pop    %ebx
80104a96:	5e                   	pop    %esi
80104a97:	5d                   	pop    %ebp
80104a98:	c3                   	ret    
80104a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
80104aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
}
80104aa8:	5b                   	pop    %ebx
80104aa9:	5e                   	pop    %esi
80104aaa:	5d                   	pop    %ebp
80104aab:	c3                   	ret    
80104aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
80104ab0:	31 c0                	xor    %eax,%eax
80104ab2:	eb de                	jmp    80104a92 <argfd.constprop.0+0x42>
80104ab4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104aba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104ac0 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
80104ac0:	55                   	push   %ebp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ac1:	31 c0                	xor    %eax,%eax
  return -1;
}

int
sys_dup(void)
{
80104ac3:	89 e5                	mov    %esp,%ebp
80104ac5:	56                   	push   %esi
80104ac6:	53                   	push   %ebx
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ac7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  return -1;
}

int
sys_dup(void)
{
80104aca:	83 ec 10             	sub    $0x10,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104acd:	e8 7e ff ff ff       	call   80104a50 <argfd.constprop.0>
80104ad2:	85 c0                	test   %eax,%eax
80104ad4:	78 1a                	js     80104af0 <sys_dup+0x30>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80104ad6:	31 db                	xor    %ebx,%ebx
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
80104ad8:	8b 75 f4             	mov    -0xc(%ebp),%esi
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();
80104adb:	e8 e0 ec ff ff       	call   801037c0 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
80104ae0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80104ae4:	85 d2                	test   %edx,%edx
80104ae6:	74 18                	je     80104b00 <sys_dup+0x40>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80104ae8:	83 c3 01             	add    $0x1,%ebx
80104aeb:	83 fb 10             	cmp    $0x10,%ebx
80104aee:	75 f0                	jne    80104ae0 <sys_dup+0x20>
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
80104af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
{
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
80104af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}
80104af8:	5b                   	pop    %ebx
80104af9:	5e                   	pop    %esi
80104afa:	5d                   	pop    %ebp
80104afb:	c3                   	ret    
80104afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
80104b00:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
80104b04:	83 ec 0c             	sub    $0xc,%esp
80104b07:	ff 75 f4             	pushl  -0xc(%ebp)
80104b0a:	e8 b1 c3 ff ff       	call   80100ec0 <filedup>
  return fd;
80104b0f:	83 c4 10             	add    $0x10,%esp
}
80104b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
80104b15:	89 d8                	mov    %ebx,%eax
}
80104b17:	5b                   	pop    %ebx
80104b18:	5e                   	pop    %esi
80104b19:	5d                   	pop    %ebp
80104b1a:	c3                   	ret    
80104b1b:	90                   	nop
80104b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104b20 <sys_read>:

int
sys_read(void)
{
80104b20:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104b21:	31 c0                	xor    %eax,%eax
  return fd;
}

int
sys_read(void)
{
80104b23:	89 e5                	mov    %esp,%ebp
80104b25:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104b28:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104b2b:	e8 20 ff ff ff       	call   80104a50 <argfd.constprop.0>
80104b30:	85 c0                	test   %eax,%eax
80104b32:	78 4c                	js     80104b80 <sys_read+0x60>
80104b34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b37:	83 ec 08             	sub    $0x8,%esp
80104b3a:	50                   	push   %eax
80104b3b:	6a 02                	push   $0x2
80104b3d:	e8 1e fc ff ff       	call   80104760 <argint>
80104b42:	83 c4 10             	add    $0x10,%esp
80104b45:	85 c0                	test   %eax,%eax
80104b47:	78 37                	js     80104b80 <sys_read+0x60>
80104b49:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b4c:	83 ec 04             	sub    $0x4,%esp
80104b4f:	ff 75 f0             	pushl  -0x10(%ebp)
80104b52:	50                   	push   %eax
80104b53:	6a 01                	push   $0x1
80104b55:	e8 56 fc ff ff       	call   801047b0 <argptr>
80104b5a:	83 c4 10             	add    $0x10,%esp
80104b5d:	85 c0                	test   %eax,%eax
80104b5f:	78 1f                	js     80104b80 <sys_read+0x60>
    return -1;
  return fileread(f, p, n);
80104b61:	83 ec 04             	sub    $0x4,%esp
80104b64:	ff 75 f0             	pushl  -0x10(%ebp)
80104b67:	ff 75 f4             	pushl  -0xc(%ebp)
80104b6a:	ff 75 ec             	pushl  -0x14(%ebp)
80104b6d:	e8 be c4 ff ff       	call   80101030 <fileread>
80104b72:	83 c4 10             	add    $0x10,%esp
}
80104b75:	c9                   	leave  
80104b76:	c3                   	ret    
80104b77:	89 f6                	mov    %esi,%esi
80104b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
80104b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fileread(f, p, n);
}
80104b85:	c9                   	leave  
80104b86:	c3                   	ret    
80104b87:	89 f6                	mov    %esi,%esi
80104b89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104b90 <sys_write>:

int
sys_write(void)
{
80104b90:	55                   	push   %ebp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104b91:	31 c0                	xor    %eax,%eax
  return fileread(f, p, n);
}

int
sys_write(void)
{
80104b93:	89 e5                	mov    %esp,%ebp
80104b95:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104b98:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104b9b:	e8 b0 fe ff ff       	call   80104a50 <argfd.constprop.0>
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	78 4c                	js     80104bf0 <sys_write+0x60>
80104ba4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ba7:	83 ec 08             	sub    $0x8,%esp
80104baa:	50                   	push   %eax
80104bab:	6a 02                	push   $0x2
80104bad:	e8 ae fb ff ff       	call   80104760 <argint>
80104bb2:	83 c4 10             	add    $0x10,%esp
80104bb5:	85 c0                	test   %eax,%eax
80104bb7:	78 37                	js     80104bf0 <sys_write+0x60>
80104bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bbc:	83 ec 04             	sub    $0x4,%esp
80104bbf:	ff 75 f0             	pushl  -0x10(%ebp)
80104bc2:	50                   	push   %eax
80104bc3:	6a 01                	push   $0x1
80104bc5:	e8 e6 fb ff ff       	call   801047b0 <argptr>
80104bca:	83 c4 10             	add    $0x10,%esp
80104bcd:	85 c0                	test   %eax,%eax
80104bcf:	78 1f                	js     80104bf0 <sys_write+0x60>
    return -1;
  return filewrite(f, p, n);
80104bd1:	83 ec 04             	sub    $0x4,%esp
80104bd4:	ff 75 f0             	pushl  -0x10(%ebp)
80104bd7:	ff 75 f4             	pushl  -0xc(%ebp)
80104bda:	ff 75 ec             	pushl  -0x14(%ebp)
80104bdd:	e8 de c4 ff ff       	call   801010c0 <filewrite>
80104be2:	83 c4 10             	add    $0x10,%esp
}
80104be5:	c9                   	leave  
80104be6:	c3                   	ret    
80104be7:	89 f6                	mov    %esi,%esi
80104be9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
80104bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filewrite(f, p, n);
}
80104bf5:	c9                   	leave  
80104bf6:	c3                   	ret    
80104bf7:	89 f6                	mov    %esi,%esi
80104bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c00 <sys_close>:

int
sys_close(void)
{
80104c00:	55                   	push   %ebp
80104c01:	89 e5                	mov    %esp,%ebp
80104c03:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104c06:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104c09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c0c:	e8 3f fe ff ff       	call   80104a50 <argfd.constprop.0>
80104c11:	85 c0                	test   %eax,%eax
80104c13:	78 2b                	js     80104c40 <sys_close+0x40>
    return -1;
  myproc()->ofile[fd] = 0;
80104c15:	e8 a6 eb ff ff       	call   801037c0 <myproc>
80104c1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
80104c1d:	83 ec 0c             	sub    $0xc,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    return -1;
  myproc()->ofile[fd] = 0;
80104c20:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104c27:	00 
  fileclose(f);
80104c28:	ff 75 f4             	pushl  -0xc(%ebp)
80104c2b:	e8 e0 c2 ff ff       	call   80100f10 <fileclose>
  return 0;
80104c30:	83 c4 10             	add    $0x10,%esp
80104c33:	31 c0                	xor    %eax,%eax
}
80104c35:	c9                   	leave  
80104c36:	c3                   	ret    
80104c37:	89 f6                	mov    %esi,%esi
80104c39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
{
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    return -1;
80104c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  myproc()->ofile[fd] = 0;
  fileclose(f);
  return 0;
}
80104c45:	c9                   	leave  
80104c46:	c3                   	ret    
80104c47:	89 f6                	mov    %esi,%esi
80104c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c50 <sys_fstat>:

int
sys_fstat(void)
{
80104c50:	55                   	push   %ebp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104c51:	31 c0                	xor    %eax,%eax
  return 0;
}

int
sys_fstat(void)
{
80104c53:	89 e5                	mov    %esp,%ebp
80104c55:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104c58:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104c5b:	e8 f0 fd ff ff       	call   80104a50 <argfd.constprop.0>
80104c60:	85 c0                	test   %eax,%eax
80104c62:	78 2c                	js     80104c90 <sys_fstat+0x40>
80104c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c67:	83 ec 04             	sub    $0x4,%esp
80104c6a:	6a 14                	push   $0x14
80104c6c:	50                   	push   %eax
80104c6d:	6a 01                	push   $0x1
80104c6f:	e8 3c fb ff ff       	call   801047b0 <argptr>
80104c74:	83 c4 10             	add    $0x10,%esp
80104c77:	85 c0                	test   %eax,%eax
80104c79:	78 15                	js     80104c90 <sys_fstat+0x40>
    return -1;
  return filestat(f, st);
80104c7b:	83 ec 08             	sub    $0x8,%esp
80104c7e:	ff 75 f4             	pushl  -0xc(%ebp)
80104c81:	ff 75 f0             	pushl  -0x10(%ebp)
80104c84:	e8 57 c3 ff ff       	call   80100fe0 <filestat>
80104c89:	83 c4 10             	add    $0x10,%esp
}
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    
80104c8e:	66 90                	xchg   %ax,%ax
{
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
    return -1;
80104c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filestat(f, st);
}
80104c95:	c9                   	leave  
80104c96:	c3                   	ret    
80104c97:	89 f6                	mov    %esi,%esi
80104c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ca0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	57                   	push   %edi
80104ca4:	56                   	push   %esi
80104ca5:	53                   	push   %ebx
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104ca6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
}

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80104ca9:	83 ec 34             	sub    $0x34,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104cac:	50                   	push   %eax
80104cad:	6a 00                	push   $0x0
80104caf:	e8 5c fb ff ff       	call   80104810 <argstr>
80104cb4:	83 c4 10             	add    $0x10,%esp
80104cb7:	85 c0                	test   %eax,%eax
80104cb9:	0f 88 fb 00 00 00    	js     80104dba <sys_link+0x11a>
80104cbf:	8d 45 d0             	lea    -0x30(%ebp),%eax
80104cc2:	83 ec 08             	sub    $0x8,%esp
80104cc5:	50                   	push   %eax
80104cc6:	6a 01                	push   $0x1
80104cc8:	e8 43 fb ff ff       	call   80104810 <argstr>
80104ccd:	83 c4 10             	add    $0x10,%esp
80104cd0:	85 c0                	test   %eax,%eax
80104cd2:	0f 88 e2 00 00 00    	js     80104dba <sys_link+0x11a>
    return -1;

  begin_op();
80104cd8:	e8 b3 de ff ff       	call   80102b90 <begin_op>
  if((ip = namei(old)) == 0){
80104cdd:	83 ec 0c             	sub    $0xc,%esp
80104ce0:	ff 75 d4             	pushl  -0x2c(%ebp)
80104ce3:	e8 b8 d2 ff ff       	call   80101fa0 <namei>
80104ce8:	83 c4 10             	add    $0x10,%esp
80104ceb:	85 c0                	test   %eax,%eax
80104ced:	89 c3                	mov    %eax,%ebx
80104cef:	0f 84 f3 00 00 00    	je     80104de8 <sys_link+0x148>
    end_op();
    return -1;
  }

  ilock(ip);
80104cf5:	83 ec 0c             	sub    $0xc,%esp
80104cf8:	50                   	push   %eax
80104cf9:	e8 52 ca ff ff       	call   80101750 <ilock>
  if(ip->type == T_DIR){
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104d06:	0f 84 c4 00 00 00    	je     80104dd0 <sys_link+0x130>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
80104d0c:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  iupdate(ip);
80104d11:	83 ec 0c             	sub    $0xc,%esp
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
80104d14:	8d 7d da             	lea    -0x26(%ebp),%edi
    end_op();
    return -1;
  }

  ip->nlink++;
  iupdate(ip);
80104d17:	53                   	push   %ebx
80104d18:	e8 83 c9 ff ff       	call   801016a0 <iupdate>
  iunlock(ip);
80104d1d:	89 1c 24             	mov    %ebx,(%esp)
80104d20:	e8 0b cb ff ff       	call   80101830 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80104d25:	58                   	pop    %eax
80104d26:	5a                   	pop    %edx
80104d27:	57                   	push   %edi
80104d28:	ff 75 d0             	pushl  -0x30(%ebp)
80104d2b:	e8 90 d2 ff ff       	call   80101fc0 <nameiparent>
80104d30:	83 c4 10             	add    $0x10,%esp
80104d33:	85 c0                	test   %eax,%eax
80104d35:	89 c6                	mov    %eax,%esi
80104d37:	74 5b                	je     80104d94 <sys_link+0xf4>
    goto bad;
  ilock(dp);
80104d39:	83 ec 0c             	sub    $0xc,%esp
80104d3c:	50                   	push   %eax
80104d3d:	e8 0e ca ff ff       	call   80101750 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104d42:	83 c4 10             	add    $0x10,%esp
80104d45:	8b 03                	mov    (%ebx),%eax
80104d47:	39 06                	cmp    %eax,(%esi)
80104d49:	75 3d                	jne    80104d88 <sys_link+0xe8>
80104d4b:	83 ec 04             	sub    $0x4,%esp
80104d4e:	ff 73 04             	pushl  0x4(%ebx)
80104d51:	57                   	push   %edi
80104d52:	56                   	push   %esi
80104d53:	e8 88 d1 ff ff       	call   80101ee0 <dirlink>
80104d58:	83 c4 10             	add    $0x10,%esp
80104d5b:	85 c0                	test   %eax,%eax
80104d5d:	78 29                	js     80104d88 <sys_link+0xe8>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
80104d5f:	83 ec 0c             	sub    $0xc,%esp
80104d62:	56                   	push   %esi
80104d63:	e8 78 cc ff ff       	call   801019e0 <iunlockput>
  iput(ip);
80104d68:	89 1c 24             	mov    %ebx,(%esp)
80104d6b:	e8 10 cb ff ff       	call   80101880 <iput>

  end_op();
80104d70:	e8 8b de ff ff       	call   80102c00 <end_op>

  return 0;
80104d75:	83 c4 10             	add    $0x10,%esp
80104d78:	31 c0                	xor    %eax,%eax
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
}
80104d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104d7d:	5b                   	pop    %ebx
80104d7e:	5e                   	pop    %esi
80104d7f:	5f                   	pop    %edi
80104d80:	5d                   	pop    %ebp
80104d81:	c3                   	ret    
80104d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
80104d88:	83 ec 0c             	sub    $0xc,%esp
80104d8b:	56                   	push   %esi
80104d8c:	e8 4f cc ff ff       	call   801019e0 <iunlockput>
    goto bad;
80104d91:	83 c4 10             	add    $0x10,%esp
  end_op();

  return 0;

bad:
  ilock(ip);
80104d94:	83 ec 0c             	sub    $0xc,%esp
80104d97:	53                   	push   %ebx
80104d98:	e8 b3 c9 ff ff       	call   80101750 <ilock>
  ip->nlink--;
80104d9d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104da2:	89 1c 24             	mov    %ebx,(%esp)
80104da5:	e8 f6 c8 ff ff       	call   801016a0 <iupdate>
  iunlockput(ip);
80104daa:	89 1c 24             	mov    %ebx,(%esp)
80104dad:	e8 2e cc ff ff       	call   801019e0 <iunlockput>
  end_op();
80104db2:	e8 49 de ff ff       	call   80102c00 <end_op>
  return -1;
80104db7:	83 c4 10             	add    $0x10,%esp
}
80104dba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
80104dbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dc2:	5b                   	pop    %ebx
80104dc3:	5e                   	pop    %esi
80104dc4:	5f                   	pop    %edi
80104dc5:	5d                   	pop    %ebp
80104dc6:	c3                   	ret    
80104dc7:	89 f6                	mov    %esi,%esi
80104dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
  }

  ilock(ip);
  if(ip->type == T_DIR){
    iunlockput(ip);
80104dd0:	83 ec 0c             	sub    $0xc,%esp
80104dd3:	53                   	push   %ebx
80104dd4:	e8 07 cc ff ff       	call   801019e0 <iunlockput>
    end_op();
80104dd9:	e8 22 de ff ff       	call   80102c00 <end_op>
    return -1;
80104dde:	83 c4 10             	add    $0x10,%esp
80104de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de6:	eb 92                	jmp    80104d7a <sys_link+0xda>
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
    return -1;

  begin_op();
  if((ip = namei(old)) == 0){
    end_op();
80104de8:	e8 13 de ff ff       	call   80102c00 <end_op>
    return -1;
80104ded:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df2:	eb 86                	jmp    80104d7a <sys_link+0xda>
80104df4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104dfa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104e00 <sys_unlink>:
}

//PAGEBREAK!
int
sys_unlink(void)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	57                   	push   %edi
80104e04:	56                   	push   %esi
80104e05:	53                   	push   %ebx
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80104e06:	8d 45 c0             	lea    -0x40(%ebp),%eax
}

//PAGEBREAK!
int
sys_unlink(void)
{
80104e09:	83 ec 54             	sub    $0x54,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80104e0c:	50                   	push   %eax
80104e0d:	6a 00                	push   $0x0
80104e0f:	e8 fc f9 ff ff       	call   80104810 <argstr>
80104e14:	83 c4 10             	add    $0x10,%esp
80104e17:	85 c0                	test   %eax,%eax
80104e19:	0f 88 82 01 00 00    	js     80104fa1 <sys_unlink+0x1a1>
    return -1;

  begin_op();
  if((dp = nameiparent(path, name)) == 0){
80104e1f:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  uint off;

  if(argstr(0, &path) < 0)
    return -1;

  begin_op();
80104e22:	e8 69 dd ff ff       	call   80102b90 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104e27:	83 ec 08             	sub    $0x8,%esp
80104e2a:	53                   	push   %ebx
80104e2b:	ff 75 c0             	pushl  -0x40(%ebp)
80104e2e:	e8 8d d1 ff ff       	call   80101fc0 <nameiparent>
80104e33:	83 c4 10             	add    $0x10,%esp
80104e36:	85 c0                	test   %eax,%eax
80104e38:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80104e3b:	0f 84 6a 01 00 00    	je     80104fab <sys_unlink+0x1ab>
    end_op();
    return -1;
  }

  ilock(dp);
80104e41:	8b 75 b4             	mov    -0x4c(%ebp),%esi
80104e44:	83 ec 0c             	sub    $0xc,%esp
80104e47:	56                   	push   %esi
80104e48:	e8 03 c9 ff ff       	call   80101750 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104e4d:	58                   	pop    %eax
80104e4e:	5a                   	pop    %edx
80104e4f:	68 5c 77 10 80       	push   $0x8010775c
80104e54:	53                   	push   %ebx
80104e55:	e8 06 ce ff ff       	call   80101c60 <namecmp>
80104e5a:	83 c4 10             	add    $0x10,%esp
80104e5d:	85 c0                	test   %eax,%eax
80104e5f:	0f 84 fc 00 00 00    	je     80104f61 <sys_unlink+0x161>
80104e65:	83 ec 08             	sub    $0x8,%esp
80104e68:	68 5b 77 10 80       	push   $0x8010775b
80104e6d:	53                   	push   %ebx
80104e6e:	e8 ed cd ff ff       	call   80101c60 <namecmp>
80104e73:	83 c4 10             	add    $0x10,%esp
80104e76:	85 c0                	test   %eax,%eax
80104e78:	0f 84 e3 00 00 00    	je     80104f61 <sys_unlink+0x161>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80104e7e:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e81:	83 ec 04             	sub    $0x4,%esp
80104e84:	50                   	push   %eax
80104e85:	53                   	push   %ebx
80104e86:	56                   	push   %esi
80104e87:	e8 f4 cd ff ff       	call   80101c80 <dirlookup>
80104e8c:	83 c4 10             	add    $0x10,%esp
80104e8f:	85 c0                	test   %eax,%eax
80104e91:	89 c3                	mov    %eax,%ebx
80104e93:	0f 84 c8 00 00 00    	je     80104f61 <sys_unlink+0x161>
    goto bad;
  ilock(ip);
80104e99:	83 ec 0c             	sub    $0xc,%esp
80104e9c:	50                   	push   %eax
80104e9d:	e8 ae c8 ff ff       	call   80101750 <ilock>

  if(ip->nlink < 1)
80104ea2:	83 c4 10             	add    $0x10,%esp
80104ea5:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104eaa:	0f 8e 24 01 00 00    	jle    80104fd4 <sys_unlink+0x1d4>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
80104eb0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104eb5:	8d 75 d8             	lea    -0x28(%ebp),%esi
80104eb8:	74 66                	je     80104f20 <sys_unlink+0x120>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
80104eba:	83 ec 04             	sub    $0x4,%esp
80104ebd:	6a 10                	push   $0x10
80104ebf:	6a 00                	push   $0x0
80104ec1:	56                   	push   %esi
80104ec2:	e8 89 f5 ff ff       	call   80104450 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104ec7:	6a 10                	push   $0x10
80104ec9:	ff 75 c4             	pushl  -0x3c(%ebp)
80104ecc:	56                   	push   %esi
80104ecd:	ff 75 b4             	pushl  -0x4c(%ebp)
80104ed0:	e8 5b cc ff ff       	call   80101b30 <writei>
80104ed5:	83 c4 20             	add    $0x20,%esp
80104ed8:	83 f8 10             	cmp    $0x10,%eax
80104edb:	0f 85 e6 00 00 00    	jne    80104fc7 <sys_unlink+0x1c7>
    panic("unlink: writei");
  if(ip->type == T_DIR){
80104ee1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ee6:	0f 84 9c 00 00 00    	je     80104f88 <sys_unlink+0x188>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
80104eec:	83 ec 0c             	sub    $0xc,%esp
80104eef:	ff 75 b4             	pushl  -0x4c(%ebp)
80104ef2:	e8 e9 ca ff ff       	call   801019e0 <iunlockput>

  ip->nlink--;
80104ef7:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104efc:	89 1c 24             	mov    %ebx,(%esp)
80104eff:	e8 9c c7 ff ff       	call   801016a0 <iupdate>
  iunlockput(ip);
80104f04:	89 1c 24             	mov    %ebx,(%esp)
80104f07:	e8 d4 ca ff ff       	call   801019e0 <iunlockput>

  end_op();
80104f0c:	e8 ef dc ff ff       	call   80102c00 <end_op>

  return 0;
80104f11:	83 c4 10             	add    $0x10,%esp
80104f14:	31 c0                	xor    %eax,%eax

bad:
  iunlockput(dp);
  end_op();
  return -1;
}
80104f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f19:	5b                   	pop    %ebx
80104f1a:	5e                   	pop    %esi
80104f1b:	5f                   	pop    %edi
80104f1c:	5d                   	pop    %ebp
80104f1d:	c3                   	ret    
80104f1e:	66 90                	xchg   %ax,%ax
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104f20:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80104f24:	76 94                	jbe    80104eba <sys_unlink+0xba>
80104f26:	bf 20 00 00 00       	mov    $0x20,%edi
80104f2b:	eb 0f                	jmp    80104f3c <sys_unlink+0x13c>
80104f2d:	8d 76 00             	lea    0x0(%esi),%esi
80104f30:	83 c7 10             	add    $0x10,%edi
80104f33:	3b 7b 58             	cmp    0x58(%ebx),%edi
80104f36:	0f 83 7e ff ff ff    	jae    80104eba <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104f3c:	6a 10                	push   $0x10
80104f3e:	57                   	push   %edi
80104f3f:	56                   	push   %esi
80104f40:	53                   	push   %ebx
80104f41:	e8 ea ca ff ff       	call   80101a30 <readi>
80104f46:	83 c4 10             	add    $0x10,%esp
80104f49:	83 f8 10             	cmp    $0x10,%eax
80104f4c:	75 6c                	jne    80104fba <sys_unlink+0x1ba>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104f4e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80104f53:	74 db                	je     80104f30 <sys_unlink+0x130>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
80104f55:	83 ec 0c             	sub    $0xc,%esp
80104f58:	53                   	push   %ebx
80104f59:	e8 82 ca ff ff       	call   801019e0 <iunlockput>
    goto bad;
80104f5e:	83 c4 10             	add    $0x10,%esp
  end_op();

  return 0;

bad:
  iunlockput(dp);
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	ff 75 b4             	pushl  -0x4c(%ebp)
80104f67:	e8 74 ca ff ff       	call   801019e0 <iunlockput>
  end_op();
80104f6c:	e8 8f dc ff ff       	call   80102c00 <end_op>
  return -1;
80104f71:	83 c4 10             	add    $0x10,%esp
}
80104f74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;

bad:
  iunlockput(dp);
  end_op();
  return -1;
80104f77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f7c:	5b                   	pop    %ebx
80104f7d:	5e                   	pop    %esi
80104f7e:	5f                   	pop    %edi
80104f7f:	5d                   	pop    %ebp
80104f80:	c3                   	ret    
80104f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
80104f88:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80104f8b:	83 ec 0c             	sub    $0xc,%esp

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
80104f8e:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
80104f93:	50                   	push   %eax
80104f94:	e8 07 c7 ff ff       	call   801016a0 <iupdate>
80104f99:	83 c4 10             	add    $0x10,%esp
80104f9c:	e9 4b ff ff ff       	jmp    80104eec <sys_unlink+0xec>
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
80104fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa6:	e9 6b ff ff ff       	jmp    80104f16 <sys_unlink+0x116>

  begin_op();
  if((dp = nameiparent(path, name)) == 0){
    end_op();
80104fab:	e8 50 dc ff ff       	call   80102c00 <end_op>
    return -1;
80104fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fb5:	e9 5c ff ff ff       	jmp    80104f16 <sys_unlink+0x116>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
80104fba:	83 ec 0c             	sub    $0xc,%esp
80104fbd:	68 80 77 10 80       	push   $0x80107780
80104fc2:	e8 a9 b3 ff ff       	call   80100370 <panic>
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
80104fc7:	83 ec 0c             	sub    $0xc,%esp
80104fca:	68 92 77 10 80       	push   $0x80107792
80104fcf:	e8 9c b3 ff ff       	call   80100370 <panic>
  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
80104fd4:	83 ec 0c             	sub    $0xc,%esp
80104fd7:	68 6e 77 10 80       	push   $0x8010776e
80104fdc:	e8 8f b3 ff ff       	call   80100370 <panic>
80104fe1:	eb 0d                	jmp    80104ff0 <sys_open>
80104fe3:	90                   	nop
80104fe4:	90                   	nop
80104fe5:	90                   	nop
80104fe6:	90                   	nop
80104fe7:	90                   	nop
80104fe8:	90                   	nop
80104fe9:	90                   	nop
80104fea:	90                   	nop
80104feb:	90                   	nop
80104fec:	90                   	nop
80104fed:	90                   	nop
80104fee:	90                   	nop
80104fef:	90                   	nop

80104ff0 <sys_open>:
  return ip;
}

int
sys_open(void)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	57                   	push   %edi
80104ff4:	56                   	push   %esi
80104ff5:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ff6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  return ip;
}

int
sys_open(void)
{
80104ff9:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ffc:	50                   	push   %eax
80104ffd:	6a 00                	push   $0x0
80104fff:	e8 0c f8 ff ff       	call   80104810 <argstr>
80105004:	83 c4 10             	add    $0x10,%esp
80105007:	85 c0                	test   %eax,%eax
80105009:	0f 88 9e 00 00 00    	js     801050ad <sys_open+0xbd>
8010500f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105012:	83 ec 08             	sub    $0x8,%esp
80105015:	50                   	push   %eax
80105016:	6a 01                	push   $0x1
80105018:	e8 43 f7 ff ff       	call   80104760 <argint>
8010501d:	83 c4 10             	add    $0x10,%esp
80105020:	85 c0                	test   %eax,%eax
80105022:	0f 88 85 00 00 00    	js     801050ad <sys_open+0xbd>
    return -1;

  begin_op();
80105028:	e8 63 db ff ff       	call   80102b90 <begin_op>

  if(omode & O_CREATE){
8010502d:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
80105031:	0f 85 89 00 00 00    	jne    801050c0 <sys_open+0xd0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80105037:	83 ec 0c             	sub    $0xc,%esp
8010503a:	ff 75 e0             	pushl  -0x20(%ebp)
8010503d:	e8 5e cf ff ff       	call   80101fa0 <namei>
80105042:	83 c4 10             	add    $0x10,%esp
80105045:	85 c0                	test   %eax,%eax
80105047:	89 c6                	mov    %eax,%esi
80105049:	0f 84 8e 00 00 00    	je     801050dd <sys_open+0xed>
      end_op();
      return -1;
    }
    ilock(ip);
8010504f:	83 ec 0c             	sub    $0xc,%esp
80105052:	50                   	push   %eax
80105053:	e8 f8 c6 ff ff       	call   80101750 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105058:	83 c4 10             	add    $0x10,%esp
8010505b:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105060:	0f 84 d2 00 00 00    	je     80105138 <sys_open+0x148>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105066:	e8 e5 bd ff ff       	call   80100e50 <filealloc>
8010506b:	85 c0                	test   %eax,%eax
8010506d:	89 c7                	mov    %eax,%edi
8010506f:	74 2b                	je     8010509c <sys_open+0xac>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105071:	31 db                	xor    %ebx,%ebx
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();
80105073:	e8 48 e7 ff ff       	call   801037c0 <myproc>
80105078:	90                   	nop
80105079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
80105080:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105084:	85 d2                	test   %edx,%edx
80105086:	74 68                	je     801050f0 <sys_open+0x100>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105088:	83 c3 01             	add    $0x1,%ebx
8010508b:	83 fb 10             	cmp    $0x10,%ebx
8010508e:	75 f0                	jne    80105080 <sys_open+0x90>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
80105090:	83 ec 0c             	sub    $0xc,%esp
80105093:	57                   	push   %edi
80105094:	e8 77 be ff ff       	call   80100f10 <fileclose>
80105099:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010509c:	83 ec 0c             	sub    $0xc,%esp
8010509f:	56                   	push   %esi
801050a0:	e8 3b c9 ff ff       	call   801019e0 <iunlockput>
    end_op();
801050a5:	e8 56 db ff ff       	call   80102c00 <end_op>
    return -1;
801050aa:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
801050ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
801050b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
  return fd;
}
801050b5:	5b                   	pop    %ebx
801050b6:	5e                   	pop    %esi
801050b7:	5f                   	pop    %edi
801050b8:	5d                   	pop    %ebp
801050b9:	c3                   	ret    
801050ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
801050c0:	83 ec 0c             	sub    $0xc,%esp
801050c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801050c6:	31 c9                	xor    %ecx,%ecx
801050c8:	6a 00                	push   $0x0
801050ca:	ba 02 00 00 00       	mov    $0x2,%edx
801050cf:	e8 dc f7 ff ff       	call   801048b0 <create>
    if(ip == 0){
801050d4:	83 c4 10             	add    $0x10,%esp
801050d7:	85 c0                	test   %eax,%eax
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
801050d9:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801050db:	75 89                	jne    80105066 <sys_open+0x76>
      end_op();
801050dd:	e8 1e db ff ff       	call   80102c00 <end_op>
      return -1;
801050e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e7:	eb 43                	jmp    8010512c <sys_open+0x13c>
801050e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801050f0:	83 ec 0c             	sub    $0xc,%esp
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
801050f3:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801050f7:	56                   	push   %esi
801050f8:	e8 33 c7 ff ff       	call   80101830 <iunlock>
  end_op();
801050fd:	e8 fe da ff ff       	call   80102c00 <end_op>

  f->type = FD_INODE;
80105102:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105108:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010510b:	83 c4 10             	add    $0x10,%esp
  }
  iunlock(ip);
  end_op();

  f->type = FD_INODE;
  f->ip = ip;
8010510e:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105111:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105118:	89 d0                	mov    %edx,%eax
8010511a:	83 e0 01             	and    $0x1,%eax
8010511d:	83 f0 01             	xor    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105120:	83 e2 03             	and    $0x3,%edx
  end_op();

  f->type = FD_INODE;
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105123:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105126:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
8010512a:	89 d8                	mov    %ebx,%eax
}
8010512c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010512f:	5b                   	pop    %ebx
80105130:	5e                   	pop    %esi
80105131:	5f                   	pop    %edi
80105132:	5d                   	pop    %ebp
80105133:	c3                   	ret    
80105134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((ip = namei(path)) == 0){
      end_op();
      return -1;
    }
    ilock(ip);
    if(ip->type == T_DIR && omode != O_RDONLY){
80105138:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010513b:	85 c9                	test   %ecx,%ecx
8010513d:	0f 84 23 ff ff ff    	je     80105066 <sys_open+0x76>
80105143:	e9 54 ff ff ff       	jmp    8010509c <sys_open+0xac>
80105148:	90                   	nop
80105149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105150 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105156:	e8 35 da ff ff       	call   80102b90 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010515b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010515e:	83 ec 08             	sub    $0x8,%esp
80105161:	50                   	push   %eax
80105162:	6a 00                	push   $0x0
80105164:	e8 a7 f6 ff ff       	call   80104810 <argstr>
80105169:	83 c4 10             	add    $0x10,%esp
8010516c:	85 c0                	test   %eax,%eax
8010516e:	78 30                	js     801051a0 <sys_mkdir+0x50>
80105170:	83 ec 0c             	sub    $0xc,%esp
80105173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105176:	31 c9                	xor    %ecx,%ecx
80105178:	6a 00                	push   $0x0
8010517a:	ba 01 00 00 00       	mov    $0x1,%edx
8010517f:	e8 2c f7 ff ff       	call   801048b0 <create>
80105184:	83 c4 10             	add    $0x10,%esp
80105187:	85 c0                	test   %eax,%eax
80105189:	74 15                	je     801051a0 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010518b:	83 ec 0c             	sub    $0xc,%esp
8010518e:	50                   	push   %eax
8010518f:	e8 4c c8 ff ff       	call   801019e0 <iunlockput>
  end_op();
80105194:	e8 67 da ff ff       	call   80102c00 <end_op>
  return 0;
80105199:	83 c4 10             	add    $0x10,%esp
8010519c:	31 c0                	xor    %eax,%eax
}
8010519e:	c9                   	leave  
8010519f:	c3                   	ret    
  char *path;
  struct inode *ip;

  begin_op();
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    end_op();
801051a0:	e8 5b da ff ff       	call   80102c00 <end_op>
    return -1;
801051a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
801051aa:	c9                   	leave  
801051ab:	c3                   	ret    
801051ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801051b0 <sys_mknod>:

int
sys_mknod(void)
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801051b6:	e8 d5 d9 ff ff       	call   80102b90 <begin_op>
  if((argstr(0, &path)) < 0 ||
801051bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051be:	83 ec 08             	sub    $0x8,%esp
801051c1:	50                   	push   %eax
801051c2:	6a 00                	push   $0x0
801051c4:	e8 47 f6 ff ff       	call   80104810 <argstr>
801051c9:	83 c4 10             	add    $0x10,%esp
801051cc:	85 c0                	test   %eax,%eax
801051ce:	78 60                	js     80105230 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801051d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051d3:	83 ec 08             	sub    $0x8,%esp
801051d6:	50                   	push   %eax
801051d7:	6a 01                	push   $0x1
801051d9:	e8 82 f5 ff ff       	call   80104760 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801051de:	83 c4 10             	add    $0x10,%esp
801051e1:	85 c0                	test   %eax,%eax
801051e3:	78 4b                	js     80105230 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801051e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051e8:	83 ec 08             	sub    $0x8,%esp
801051eb:	50                   	push   %eax
801051ec:	6a 02                	push   $0x2
801051ee:	e8 6d f5 ff ff       	call   80104760 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801051f3:	83 c4 10             	add    $0x10,%esp
801051f6:	85 c0                	test   %eax,%eax
801051f8:	78 36                	js     80105230 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801051fa:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801051fe:	83 ec 0c             	sub    $0xc,%esp
80105201:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105205:	ba 03 00 00 00       	mov    $0x3,%edx
8010520a:	50                   	push   %eax
8010520b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010520e:	e8 9d f6 ff ff       	call   801048b0 <create>
80105213:	83 c4 10             	add    $0x10,%esp
80105216:	85 c0                	test   %eax,%eax
80105218:	74 16                	je     80105230 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
8010521a:	83 ec 0c             	sub    $0xc,%esp
8010521d:	50                   	push   %eax
8010521e:	e8 bd c7 ff ff       	call   801019e0 <iunlockput>
  end_op();
80105223:	e8 d8 d9 ff ff       	call   80102c00 <end_op>
  return 0;
80105228:	83 c4 10             	add    $0x10,%esp
8010522b:	31 c0                	xor    %eax,%eax
}
8010522d:	c9                   	leave  
8010522e:	c3                   	ret    
8010522f:	90                   	nop
  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80105230:	e8 cb d9 ff ff       	call   80102c00 <end_op>
    return -1;
80105235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
8010523a:	c9                   	leave  
8010523b:	c3                   	ret    
8010523c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105240 <sys_chdir>:

int
sys_chdir(void)
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	56                   	push   %esi
80105244:	53                   	push   %ebx
80105245:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105248:	e8 73 e5 ff ff       	call   801037c0 <myproc>
8010524d:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010524f:	e8 3c d9 ff ff       	call   80102b90 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105254:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105257:	83 ec 08             	sub    $0x8,%esp
8010525a:	50                   	push   %eax
8010525b:	6a 00                	push   $0x0
8010525d:	e8 ae f5 ff ff       	call   80104810 <argstr>
80105262:	83 c4 10             	add    $0x10,%esp
80105265:	85 c0                	test   %eax,%eax
80105267:	78 77                	js     801052e0 <sys_chdir+0xa0>
80105269:	83 ec 0c             	sub    $0xc,%esp
8010526c:	ff 75 f4             	pushl  -0xc(%ebp)
8010526f:	e8 2c cd ff ff       	call   80101fa0 <namei>
80105274:	83 c4 10             	add    $0x10,%esp
80105277:	85 c0                	test   %eax,%eax
80105279:	89 c3                	mov    %eax,%ebx
8010527b:	74 63                	je     801052e0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
8010527d:	83 ec 0c             	sub    $0xc,%esp
80105280:	50                   	push   %eax
80105281:	e8 ca c4 ff ff       	call   80101750 <ilock>
  if(ip->type != T_DIR){
80105286:	83 c4 10             	add    $0x10,%esp
80105289:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010528e:	75 30                	jne    801052c0 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105290:	83 ec 0c             	sub    $0xc,%esp
80105293:	53                   	push   %ebx
80105294:	e8 97 c5 ff ff       	call   80101830 <iunlock>
  iput(curproc->cwd);
80105299:	58                   	pop    %eax
8010529a:	ff 76 68             	pushl  0x68(%esi)
8010529d:	e8 de c5 ff ff       	call   80101880 <iput>
  end_op();
801052a2:	e8 59 d9 ff ff       	call   80102c00 <end_op>
  curproc->cwd = ip;
801052a7:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
801052aa:	83 c4 10             	add    $0x10,%esp
801052ad:	31 c0                	xor    %eax,%eax
}
801052af:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052b2:	5b                   	pop    %ebx
801052b3:	5e                   	pop    %esi
801052b4:	5d                   	pop    %ebp
801052b5:	c3                   	ret    
801052b6:	8d 76 00             	lea    0x0(%esi),%esi
801052b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
801052c0:	83 ec 0c             	sub    $0xc,%esp
801052c3:	53                   	push   %ebx
801052c4:	e8 17 c7 ff ff       	call   801019e0 <iunlockput>
    end_op();
801052c9:	e8 32 d9 ff ff       	call   80102c00 <end_op>
    return -1;
801052ce:	83 c4 10             	add    $0x10,%esp
801052d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d6:	eb d7                	jmp    801052af <sys_chdir+0x6f>
801052d8:	90                   	nop
801052d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  struct inode *ip;
  struct proc *curproc = myproc();
  
  begin_op();
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
    end_op();
801052e0:	e8 1b d9 ff ff       	call   80102c00 <end_op>
    return -1;
801052e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ea:	eb c3                	jmp    801052af <sys_chdir+0x6f>
801052ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801052f0 <sys_exec>:
  return 0;
}

int
sys_exec(void)
{
801052f0:	55                   	push   %ebp
801052f1:	89 e5                	mov    %esp,%ebp
801052f3:	57                   	push   %edi
801052f4:	56                   	push   %esi
801052f5:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801052f6:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  return 0;
}

int
sys_exec(void)
{
801052fc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105302:	50                   	push   %eax
80105303:	6a 00                	push   $0x0
80105305:	e8 06 f5 ff ff       	call   80104810 <argstr>
8010530a:	83 c4 10             	add    $0x10,%esp
8010530d:	85 c0                	test   %eax,%eax
8010530f:	78 7f                	js     80105390 <sys_exec+0xa0>
80105311:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105317:	83 ec 08             	sub    $0x8,%esp
8010531a:	50                   	push   %eax
8010531b:	6a 01                	push   $0x1
8010531d:	e8 3e f4 ff ff       	call   80104760 <argint>
80105322:	83 c4 10             	add    $0x10,%esp
80105325:	85 c0                	test   %eax,%eax
80105327:	78 67                	js     80105390 <sys_exec+0xa0>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105329:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010532f:	83 ec 04             	sub    $0x4,%esp
80105332:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
80105338:	68 80 00 00 00       	push   $0x80
8010533d:	6a 00                	push   $0x0
8010533f:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105345:	50                   	push   %eax
80105346:	31 db                	xor    %ebx,%ebx
80105348:	e8 03 f1 ff ff       	call   80104450 <memset>
8010534d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105350:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105356:	83 ec 08             	sub    $0x8,%esp
80105359:	57                   	push   %edi
8010535a:	8d 04 98             	lea    (%eax,%ebx,4),%eax
8010535d:	50                   	push   %eax
8010535e:	e8 5d f3 ff ff       	call   801046c0 <fetchint>
80105363:	83 c4 10             	add    $0x10,%esp
80105366:	85 c0                	test   %eax,%eax
80105368:	78 26                	js     80105390 <sys_exec+0xa0>
      return -1;
    if(uarg == 0){
8010536a:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105370:	85 c0                	test   %eax,%eax
80105372:	74 2c                	je     801053a0 <sys_exec+0xb0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105374:	83 ec 08             	sub    $0x8,%esp
80105377:	56                   	push   %esi
80105378:	50                   	push   %eax
80105379:	e8 82 f3 ff ff       	call   80104700 <fetchstr>
8010537e:	83 c4 10             	add    $0x10,%esp
80105381:	85 c0                	test   %eax,%eax
80105383:	78 0b                	js     80105390 <sys_exec+0xa0>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105385:	83 c3 01             	add    $0x1,%ebx
80105388:	83 c6 04             	add    $0x4,%esi
    if(i >= NELEM(argv))
8010538b:	83 fb 20             	cmp    $0x20,%ebx
8010538e:	75 c0                	jne    80105350 <sys_exec+0x60>
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
80105390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
80105393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
}
80105398:	5b                   	pop    %ebx
80105399:	5e                   	pop    %esi
8010539a:	5f                   	pop    %edi
8010539b:	5d                   	pop    %ebp
8010539c:	c3                   	ret    
8010539d:	8d 76 00             	lea    0x0(%esi),%esi
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801053a0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801053a6:	83 ec 08             	sub    $0x8,%esp
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
801053a9:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
801053b0:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801053b4:	50                   	push   %eax
801053b5:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
801053bb:	e8 23 b6 ff ff       	call   801009e3 <exec>
801053c0:	83 c4 10             	add    $0x10,%esp
}
801053c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053c6:	5b                   	pop    %ebx
801053c7:	5e                   	pop    %esi
801053c8:	5f                   	pop    %edi
801053c9:	5d                   	pop    %ebp
801053ca:	c3                   	ret    
801053cb:	90                   	nop
801053cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801053d0 <sys_pipe>:

int
sys_pipe(void)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	57                   	push   %edi
801053d4:	56                   	push   %esi
801053d5:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801053d6:	8d 45 dc             	lea    -0x24(%ebp),%eax
  return exec(path, argv);
}

int
sys_pipe(void)
{
801053d9:	83 ec 20             	sub    $0x20,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801053dc:	6a 08                	push   $0x8
801053de:	50                   	push   %eax
801053df:	6a 00                	push   $0x0
801053e1:	e8 ca f3 ff ff       	call   801047b0 <argptr>
801053e6:	83 c4 10             	add    $0x10,%esp
801053e9:	85 c0                	test   %eax,%eax
801053eb:	78 4a                	js     80105437 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
801053ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801053f0:	83 ec 08             	sub    $0x8,%esp
801053f3:	50                   	push   %eax
801053f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053f7:	50                   	push   %eax
801053f8:	e8 33 de ff ff       	call   80103230 <pipealloc>
801053fd:	83 c4 10             	add    $0x10,%esp
80105400:	85 c0                	test   %eax,%eax
80105402:	78 33                	js     80105437 <sys_pipe+0x67>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105404:	31 db                	xor    %ebx,%ebx
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105406:	8b 7d e0             	mov    -0x20(%ebp),%edi
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();
80105409:	e8 b2 e3 ff ff       	call   801037c0 <myproc>
8010540e:	66 90                	xchg   %ax,%ax

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
80105410:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105414:	85 f6                	test   %esi,%esi
80105416:	74 30                	je     80105448 <sys_pipe+0x78>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105418:	83 c3 01             	add    $0x1,%ebx
8010541b:	83 fb 10             	cmp    $0x10,%ebx
8010541e:	75 f0                	jne    80105410 <sys_pipe+0x40>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105420:	83 ec 0c             	sub    $0xc,%esp
80105423:	ff 75 e0             	pushl  -0x20(%ebp)
80105426:	e8 e5 ba ff ff       	call   80100f10 <fileclose>
    fileclose(wf);
8010542b:	58                   	pop    %eax
8010542c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010542f:	e8 dc ba ff ff       	call   80100f10 <fileclose>
    return -1;
80105434:	83 c4 10             	add    $0x10,%esp
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
80105437:	8d 65 f4             	lea    -0xc(%ebp),%esp
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
8010543a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
}
8010543f:	5b                   	pop    %ebx
80105440:	5e                   	pop    %esi
80105441:	5f                   	pop    %edi
80105442:	5d                   	pop    %ebp
80105443:	c3                   	ret    
80105444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
80105448:	8d 73 08             	lea    0x8(%ebx),%esi
8010544b:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010544f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();
80105452:	e8 69 e3 ff ff       	call   801037c0 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80105457:	31 d2                	xor    %edx,%edx
80105459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105460:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80105464:	85 c9                	test   %ecx,%ecx
80105466:	74 18                	je     80105480 <sys_pipe+0xb0>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105468:	83 c2 01             	add    $0x1,%edx
8010546b:	83 fa 10             	cmp    $0x10,%edx
8010546e:	75 f0                	jne    80105460 <sys_pipe+0x90>
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
80105470:	e8 4b e3 ff ff       	call   801037c0 <myproc>
80105475:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
8010547c:	00 
8010547d:	eb a1                	jmp    80105420 <sys_pipe+0x50>
8010547f:	90                   	nop
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
80105480:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105484:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105487:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105489:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010548c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
}
8010548f:	8d 65 f4             	lea    -0xc(%ebp),%esp
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
  fd[1] = fd1;
  return 0;
80105492:	31 c0                	xor    %eax,%eax
}
80105494:	5b                   	pop    %ebx
80105495:	5e                   	pop    %esi
80105496:	5f                   	pop    %edi
80105497:	5d                   	pop    %ebp
80105498:	c3                   	ret    
80105499:	66 90                	xchg   %ax,%ax
8010549b:	66 90                	xchg   %ax,%ax
8010549d:	66 90                	xchg   %ax,%ax
8010549f:	90                   	nop

801054a0 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
801054a0:	55                   	push   %ebp
801054a1:	89 e5                	mov    %esp,%ebp
801054a3:	83 ec 20             	sub    $0x20,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
801054a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054a9:	50                   	push   %eax
801054aa:	6a 00                	push   $0x0
801054ac:	e8 af f2 ff ff       	call   80104760 <argint>
801054b1:	83 c4 10             	add    $0x10,%esp
801054b4:	85 c0                	test   %eax,%eax
801054b6:	78 30                	js     801054e8 <sys_shm_open+0x48>
    return -1;

  if(argptr(1, (char **) (&pointer),4)<0)
801054b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054bb:	83 ec 04             	sub    $0x4,%esp
801054be:	6a 04                	push   $0x4
801054c0:	50                   	push   %eax
801054c1:	6a 01                	push   $0x1
801054c3:	e8 e8 f2 ff ff       	call   801047b0 <argptr>
801054c8:	83 c4 10             	add    $0x10,%esp
801054cb:	85 c0                	test   %eax,%eax
801054cd:	78 19                	js     801054e8 <sys_shm_open+0x48>
    return -1;
  return shm_open(id, pointer);
801054cf:	83 ec 08             	sub    $0x8,%esp
801054d2:	ff 75 f4             	pushl  -0xc(%ebp)
801054d5:	ff 75 f0             	pushl  -0x10(%ebp)
801054d8:	e8 03 1b 00 00       	call   80106fe0 <shm_open>
801054dd:	83 c4 10             	add    $0x10,%esp
}
801054e0:	c9                   	leave  
801054e1:	c3                   	ret    
801054e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
int sys_shm_open(void) {
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
    return -1;
801054e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

  if(argptr(1, (char **) (&pointer),4)<0)
    return -1;
  return shm_open(id, pointer);
}
801054ed:	c9                   	leave  
801054ee:	c3                   	ret    
801054ef:	90                   	nop

801054f0 <sys_shm_close>:

int sys_shm_close(void) {
801054f0:	55                   	push   %ebp
801054f1:	89 e5                	mov    %esp,%ebp
801054f3:	83 ec 20             	sub    $0x20,%esp
  int id;

  if(argint(0, &id) < 0)
801054f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f9:	50                   	push   %eax
801054fa:	6a 00                	push   $0x0
801054fc:	e8 5f f2 ff ff       	call   80104760 <argint>
80105501:	83 c4 10             	add    $0x10,%esp
80105504:	85 c0                	test   %eax,%eax
80105506:	78 18                	js     80105520 <sys_shm_close+0x30>
    return -1;

  
  return shm_close(id);
80105508:	83 ec 0c             	sub    $0xc,%esp
8010550b:	ff 75 f4             	pushl  -0xc(%ebp)
8010550e:	e8 dd 1a 00 00       	call   80106ff0 <shm_close>
80105513:	83 c4 10             	add    $0x10,%esp
}
80105516:	c9                   	leave  
80105517:	c3                   	ret    
80105518:	90                   	nop
80105519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

int sys_shm_close(void) {
  int id;

  if(argint(0, &id) < 0)
    return -1;
80105520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

  
  return shm_close(id);
}
80105525:	c9                   	leave  
80105526:	c3                   	ret    
80105527:	89 f6                	mov    %esi,%esi
80105529:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105530 <sys_fork>:

int
sys_fork(void)
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105533:	5d                   	pop    %ebp
}

int
sys_fork(void)
{
  return fork();
80105534:	e9 27 e4 ff ff       	jmp    80103960 <fork>
80105539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105540 <sys_exit>:
}

int
sys_exit(void)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 08             	sub    $0x8,%esp
  exit();
80105546:	e8 a5 e6 ff ff       	call   80103bf0 <exit>
  return 0;  // not reached
}
8010554b:	31 c0                	xor    %eax,%eax
8010554d:	c9                   	leave  
8010554e:	c3                   	ret    
8010554f:	90                   	nop

80105550 <sys_wait>:

int
sys_wait(void)
{
80105550:	55                   	push   %ebp
80105551:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105553:	5d                   	pop    %ebp
}

int
sys_wait(void)
{
  return wait();
80105554:	e9 d7 e8 ff ff       	jmp    80103e30 <wait>
80105559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105560 <sys_kill>:
}

int
sys_kill(void)
{
80105560:	55                   	push   %ebp
80105561:	89 e5                	mov    %esp,%ebp
80105563:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105566:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105569:	50                   	push   %eax
8010556a:	6a 00                	push   $0x0
8010556c:	e8 ef f1 ff ff       	call   80104760 <argint>
80105571:	83 c4 10             	add    $0x10,%esp
80105574:	85 c0                	test   %eax,%eax
80105576:	78 18                	js     80105590 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105578:	83 ec 0c             	sub    $0xc,%esp
8010557b:	ff 75 f4             	pushl  -0xc(%ebp)
8010557e:	e8 fd e9 ff ff       	call   80103f80 <kill>
80105583:	83 c4 10             	add    $0x10,%esp
}
80105586:	c9                   	leave  
80105587:	c3                   	ret    
80105588:	90                   	nop
80105589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
80105590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return kill(pid);
}
80105595:	c9                   	leave  
80105596:	c3                   	ret    
80105597:	89 f6                	mov    %esi,%esi
80105599:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801055a0 <sys_getpid>:

int
sys_getpid(void)
{
801055a0:	55                   	push   %ebp
801055a1:	89 e5                	mov    %esp,%ebp
801055a3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801055a6:	e8 15 e2 ff ff       	call   801037c0 <myproc>
801055ab:	8b 40 10             	mov    0x10(%eax),%eax
}
801055ae:	c9                   	leave  
801055af:	c3                   	ret    

801055b0 <sys_sbrk>:

int
sys_sbrk(void)
{
801055b0:	55                   	push   %ebp
801055b1:	89 e5                	mov    %esp,%ebp
801055b3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
801055b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return myproc()->pid;
}

int
sys_sbrk(void)
{
801055b7:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801055ba:	50                   	push   %eax
801055bb:	6a 00                	push   $0x0
801055bd:	e8 9e f1 ff ff       	call   80104760 <argint>
801055c2:	83 c4 10             	add    $0x10,%esp
801055c5:	85 c0                	test   %eax,%eax
801055c7:	78 27                	js     801055f0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
801055c9:	e8 f2 e1 ff ff       	call   801037c0 <myproc>
  if(growproc(n) < 0)
801055ce:	83 ec 0c             	sub    $0xc,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
801055d1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
801055d3:	ff 75 f4             	pushl  -0xc(%ebp)
801055d6:	e8 05 e3 ff ff       	call   801038e0 <growproc>
801055db:	83 c4 10             	add    $0x10,%esp
801055de:	85 c0                	test   %eax,%eax
801055e0:	78 0e                	js     801055f0 <sys_sbrk+0x40>
    return -1;
  return addr;
801055e2:	89 d8                	mov    %ebx,%eax
}
801055e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801055e7:	c9                   	leave  
801055e8:	c3                   	ret    
801055e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
801055f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f5:	eb ed                	jmp    801055e4 <sys_sbrk+0x34>
801055f7:	89 f6                	mov    %esi,%esi
801055f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105600 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  return addr;
}

int
sys_sleep(void)
{
80105607:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010560a:	50                   	push   %eax
8010560b:	6a 00                	push   $0x0
8010560d:	e8 4e f1 ff ff       	call   80104760 <argint>
80105612:	83 c4 10             	add    $0x10,%esp
80105615:	85 c0                	test   %eax,%eax
80105617:	0f 88 8a 00 00 00    	js     801056a7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
8010561d:	83 ec 0c             	sub    $0xc,%esp
80105620:	68 60 4c 11 80       	push   $0x80114c60
80105625:	e8 b6 ec ff ff       	call   801042e0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010562a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010562d:	83 c4 10             	add    $0x10,%esp
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
80105630:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  while(ticks - ticks0 < n){
80105636:	85 d2                	test   %edx,%edx
80105638:	75 27                	jne    80105661 <sys_sleep+0x61>
8010563a:	eb 54                	jmp    80105690 <sys_sleep+0x90>
8010563c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105640:	83 ec 08             	sub    $0x8,%esp
80105643:	68 60 4c 11 80       	push   $0x80114c60
80105648:	68 a0 54 11 80       	push   $0x801154a0
8010564d:	e8 1e e7 ff ff       	call   80103d70 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105652:	a1 a0 54 11 80       	mov    0x801154a0,%eax
80105657:	83 c4 10             	add    $0x10,%esp
8010565a:	29 d8                	sub    %ebx,%eax
8010565c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010565f:	73 2f                	jae    80105690 <sys_sleep+0x90>
    if(myproc()->killed){
80105661:	e8 5a e1 ff ff       	call   801037c0 <myproc>
80105666:	8b 40 24             	mov    0x24(%eax),%eax
80105669:	85 c0                	test   %eax,%eax
8010566b:	74 d3                	je     80105640 <sys_sleep+0x40>
      release(&tickslock);
8010566d:	83 ec 0c             	sub    $0xc,%esp
80105670:	68 60 4c 11 80       	push   $0x80114c60
80105675:	e8 86 ed ff ff       	call   80104400 <release>
      return -1;
8010567a:	83 c4 10             	add    $0x10,%esp
8010567d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
80105682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105685:	c9                   	leave  
80105686:	c3                   	ret    
80105687:	89 f6                	mov    %esi,%esi
80105689:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80105690:	83 ec 0c             	sub    $0xc,%esp
80105693:	68 60 4c 11 80       	push   $0x80114c60
80105698:	e8 63 ed ff ff       	call   80104400 <release>
  return 0;
8010569d:	83 c4 10             	add    $0x10,%esp
801056a0:	31 c0                	xor    %eax,%eax
}
801056a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056a5:	c9                   	leave  
801056a6:	c3                   	ret    
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
801056a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ac:	eb d4                	jmp    80105682 <sys_sleep+0x82>
801056ae:	66 90                	xchg   %ax,%ax

801056b0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801056b0:	55                   	push   %ebp
801056b1:	89 e5                	mov    %esp,%ebp
801056b3:	53                   	push   %ebx
801056b4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
801056b7:	68 60 4c 11 80       	push   $0x80114c60
801056bc:	e8 1f ec ff ff       	call   801042e0 <acquire>
  xticks = ticks;
801056c1:	8b 1d a0 54 11 80    	mov    0x801154a0,%ebx
  release(&tickslock);
801056c7:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
801056ce:	e8 2d ed ff ff       	call   80104400 <release>
  return xticks;
}
801056d3:	89 d8                	mov    %ebx,%eax
801056d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056d8:	c9                   	leave  
801056d9:	c3                   	ret    

801056da <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801056da:	1e                   	push   %ds
  pushl %es
801056db:	06                   	push   %es
  pushl %fs
801056dc:	0f a0                	push   %fs
  pushl %gs
801056de:	0f a8                	push   %gs
  pushal
801056e0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801056e1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801056e5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801056e7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801056e9:	54                   	push   %esp
  call trap
801056ea:	e8 e1 00 00 00       	call   801057d0 <trap>
  addl $4, %esp
801056ef:	83 c4 04             	add    $0x4,%esp

801056f2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801056f2:	61                   	popa   
  popl %gs
801056f3:	0f a9                	pop    %gs
  popl %fs
801056f5:	0f a1                	pop    %fs
  popl %es
801056f7:	07                   	pop    %es
  popl %ds
801056f8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801056f9:	83 c4 08             	add    $0x8,%esp
  iret
801056fc:	cf                   	iret   
801056fd:	66 90                	xchg   %ax,%ax
801056ff:	90                   	nop

80105700 <tvinit>:
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80105700:	31 c0                	xor    %eax,%eax
80105702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105708:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
8010570f:	b9 08 00 00 00       	mov    $0x8,%ecx
80105714:	c6 04 c5 a4 4c 11 80 	movb   $0x0,-0x7feeb35c(,%eax,8)
8010571b:	00 
8010571c:	66 89 0c c5 a2 4c 11 	mov    %cx,-0x7feeb35e(,%eax,8)
80105723:	80 
80105724:	c6 04 c5 a5 4c 11 80 	movb   $0x8e,-0x7feeb35b(,%eax,8)
8010572b:	8e 
8010572c:	66 89 14 c5 a0 4c 11 	mov    %dx,-0x7feeb360(,%eax,8)
80105733:	80 
80105734:	c1 ea 10             	shr    $0x10,%edx
80105737:	66 89 14 c5 a6 4c 11 	mov    %dx,-0x7feeb35a(,%eax,8)
8010573e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010573f:	83 c0 01             	add    $0x1,%eax
80105742:	3d 00 01 00 00       	cmp    $0x100,%eax
80105747:	75 bf                	jne    80105708 <tvinit+0x8>
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105749:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010574a:	ba 08 00 00 00       	mov    $0x8,%edx
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010574f:	89 e5                	mov    %esp,%ebp
80105751:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105754:	a1 08 a1 10 80       	mov    0x8010a108,%eax

  initlock(&tickslock, "time");
80105759:	68 a1 77 10 80       	push   $0x801077a1
8010575e:	68 60 4c 11 80       	push   $0x80114c60
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105763:	66 89 15 a2 4e 11 80 	mov    %dx,0x80114ea2
8010576a:	c6 05 a4 4e 11 80 00 	movb   $0x0,0x80114ea4
80105771:	66 a3 a0 4e 11 80    	mov    %ax,0x80114ea0
80105777:	c1 e8 10             	shr    $0x10,%eax
8010577a:	c6 05 a5 4e 11 80 ef 	movb   $0xef,0x80114ea5
80105781:	66 a3 a6 4e 11 80    	mov    %ax,0x80114ea6

  initlock(&tickslock, "time");
80105787:	e8 54 ea ff ff       	call   801041e0 <initlock>
}
8010578c:	83 c4 10             	add    $0x10,%esp
8010578f:	c9                   	leave  
80105790:	c3                   	ret    
80105791:	eb 0d                	jmp    801057a0 <idtinit>
80105793:	90                   	nop
80105794:	90                   	nop
80105795:	90                   	nop
80105796:	90                   	nop
80105797:	90                   	nop
80105798:	90                   	nop
80105799:	90                   	nop
8010579a:	90                   	nop
8010579b:	90                   	nop
8010579c:	90                   	nop
8010579d:	90                   	nop
8010579e:	90                   	nop
8010579f:	90                   	nop

801057a0 <idtinit>:

void
idtinit(void)
{
801057a0:	55                   	push   %ebp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
801057a1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
801057a6:	89 e5                	mov    %esp,%ebp
801057a8:	83 ec 10             	sub    $0x10,%esp
801057ab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801057af:	b8 a0 4c 11 80       	mov    $0x80114ca0,%eax
801057b4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801057b8:	c1 e8 10             	shr    $0x10,%eax
801057bb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801057bf:	8d 45 fa             	lea    -0x6(%ebp),%eax
801057c2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801057c5:	c9                   	leave  
801057c6:	c3                   	ret    
801057c7:	89 f6                	mov    %esi,%esi
801057c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801057d0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801057d0:	55                   	push   %ebp
801057d1:	89 e5                	mov    %esp,%ebp
801057d3:	57                   	push   %edi
801057d4:	56                   	push   %esi
801057d5:	53                   	push   %ebx
801057d6:	83 ec 1c             	sub    $0x1c,%esp
801057d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(tf->trapno == T_SYSCALL){
801057dc:	8b 47 30             	mov    0x30(%edi),%eax
801057df:	83 f8 40             	cmp    $0x40,%eax
801057e2:	0f 84 88 01 00 00    	je     80105970 <trap+0x1a0>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801057e8:	83 e8 20             	sub    $0x20,%eax
801057eb:	83 f8 1f             	cmp    $0x1f,%eax
801057ee:	77 10                	ja     80105800 <trap+0x30>
801057f0:	ff 24 85 48 78 10 80 	jmp    *-0x7fef87b8(,%eax,4)
801057f7:	89 f6                	mov    %esi,%esi
801057f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105800:	e8 bb df ff ff       	call   801037c0 <myproc>
80105805:	85 c0                	test   %eax,%eax
80105807:	0f 84 d7 01 00 00    	je     801059e4 <trap+0x214>
8010580d:	f6 47 3c 03          	testb  $0x3,0x3c(%edi)
80105811:	0f 84 cd 01 00 00    	je     801059e4 <trap+0x214>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105817:	0f 20 d1             	mov    %cr2,%ecx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010581a:	8b 57 38             	mov    0x38(%edi),%edx
8010581d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105820:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105823:	e8 78 df ff ff       	call   801037a0 <cpuid>
80105828:	8b 77 34             	mov    0x34(%edi),%esi
8010582b:	8b 5f 30             	mov    0x30(%edi),%ebx
8010582e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105831:	e8 8a df ff ff       	call   801037c0 <myproc>
80105836:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105839:	e8 82 df ff ff       	call   801037c0 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010583e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105841:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105844:	51                   	push   %ecx
80105845:	52                   	push   %edx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105846:	8b 55 e0             	mov    -0x20(%ebp),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105849:	ff 75 e4             	pushl  -0x1c(%ebp)
8010584c:	56                   	push   %esi
8010584d:	53                   	push   %ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010584e:	83 c2 6c             	add    $0x6c,%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105851:	52                   	push   %edx
80105852:	ff 70 10             	pushl  0x10(%eax)
80105855:	68 04 78 10 80       	push   $0x80107804
8010585a:	e8 01 ae ff ff       	call   80100660 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010585f:	83 c4 20             	add    $0x20,%esp
80105862:	e8 59 df ff ff       	call   801037c0 <myproc>
80105867:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010586e:	66 90                	xchg   %ax,%ax
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105870:	e8 4b df ff ff       	call   801037c0 <myproc>
80105875:	85 c0                	test   %eax,%eax
80105877:	74 0c                	je     80105885 <trap+0xb5>
80105879:	e8 42 df ff ff       	call   801037c0 <myproc>
8010587e:	8b 50 24             	mov    0x24(%eax),%edx
80105881:	85 d2                	test   %edx,%edx
80105883:	75 4b                	jne    801058d0 <trap+0x100>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105885:	e8 36 df ff ff       	call   801037c0 <myproc>
8010588a:	85 c0                	test   %eax,%eax
8010588c:	74 0b                	je     80105899 <trap+0xc9>
8010588e:	e8 2d df ff ff       	call   801037c0 <myproc>
80105893:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105897:	74 4f                	je     801058e8 <trap+0x118>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105899:	e8 22 df ff ff       	call   801037c0 <myproc>
8010589e:	85 c0                	test   %eax,%eax
801058a0:	74 1d                	je     801058bf <trap+0xef>
801058a2:	e8 19 df ff ff       	call   801037c0 <myproc>
801058a7:	8b 40 24             	mov    0x24(%eax),%eax
801058aa:	85 c0                	test   %eax,%eax
801058ac:	74 11                	je     801058bf <trap+0xef>
801058ae:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
801058b2:	83 e0 03             	and    $0x3,%eax
801058b5:	66 83 f8 03          	cmp    $0x3,%ax
801058b9:	0f 84 da 00 00 00    	je     80105999 <trap+0x1c9>
    exit();
}
801058bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058c2:	5b                   	pop    %ebx
801058c3:	5e                   	pop    %esi
801058c4:	5f                   	pop    %edi
801058c5:	5d                   	pop    %ebp
801058c6:	c3                   	ret    
801058c7:	89 f6                	mov    %esi,%esi
801058c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801058d0:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
801058d4:	83 e0 03             	and    $0x3,%eax
801058d7:	66 83 f8 03          	cmp    $0x3,%ax
801058db:	75 a8                	jne    80105885 <trap+0xb5>
    exit();
801058dd:	e8 0e e3 ff ff       	call   80103bf0 <exit>
801058e2:	eb a1                	jmp    80105885 <trap+0xb5>
801058e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801058e8:	83 7f 30 20          	cmpl   $0x20,0x30(%edi)
801058ec:	75 ab                	jne    80105899 <trap+0xc9>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801058ee:	e8 2d e4 ff ff       	call   80103d20 <yield>
801058f3:	eb a4                	jmp    80105899 <trap+0xc9>
801058f5:	8d 76 00             	lea    0x0(%esi),%esi
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801058f8:	e8 a3 de ff ff       	call   801037a0 <cpuid>
801058fd:	85 c0                	test   %eax,%eax
801058ff:	0f 84 ab 00 00 00    	je     801059b0 <trap+0x1e0>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
80105905:	e8 46 ce ff ff       	call   80102750 <lapiceoi>
    break;
8010590a:	e9 61 ff ff ff       	jmp    80105870 <trap+0xa0>
8010590f:	90                   	nop
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80105910:	e8 fb cc ff ff       	call   80102610 <kbdintr>
    lapiceoi();
80105915:	e8 36 ce ff ff       	call   80102750 <lapiceoi>
    break;
8010591a:	e9 51 ff ff ff       	jmp    80105870 <trap+0xa0>
8010591f:	90                   	nop
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80105920:	e8 5b 02 00 00       	call   80105b80 <uartintr>
    lapiceoi();
80105925:	e8 26 ce ff ff       	call   80102750 <lapiceoi>
    break;
8010592a:	e9 41 ff ff ff       	jmp    80105870 <trap+0xa0>
8010592f:	90                   	nop
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105930:	0f b7 5f 3c          	movzwl 0x3c(%edi),%ebx
80105934:	8b 77 38             	mov    0x38(%edi),%esi
80105937:	e8 64 de ff ff       	call   801037a0 <cpuid>
8010593c:	56                   	push   %esi
8010593d:	53                   	push   %ebx
8010593e:	50                   	push   %eax
8010593f:	68 ac 77 10 80       	push   $0x801077ac
80105944:	e8 17 ad ff ff       	call   80100660 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80105949:	e8 02 ce ff ff       	call   80102750 <lapiceoi>
    break;
8010594e:	83 c4 10             	add    $0x10,%esp
80105951:	e9 1a ff ff ff       	jmp    80105870 <trap+0xa0>
80105956:	8d 76 00             	lea    0x0(%esi),%esi
80105959:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105960:	e8 cb c7 ff ff       	call   80102130 <ideintr>
80105965:	eb 9e                	jmp    80105905 <trap+0x135>
80105967:	89 f6                	mov    %esi,%esi
80105969:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
80105970:	e8 4b de ff ff       	call   801037c0 <myproc>
80105975:	8b 58 24             	mov    0x24(%eax),%ebx
80105978:	85 db                	test   %ebx,%ebx
8010597a:	75 2c                	jne    801059a8 <trap+0x1d8>
      exit();
    myproc()->tf = tf;
8010597c:	e8 3f de ff ff       	call   801037c0 <myproc>
80105981:	89 78 18             	mov    %edi,0x18(%eax)
    syscall();
80105984:	e8 c7 ee ff ff       	call   80104850 <syscall>
    if(myproc()->killed)
80105989:	e8 32 de ff ff       	call   801037c0 <myproc>
8010598e:	8b 48 24             	mov    0x24(%eax),%ecx
80105991:	85 c9                	test   %ecx,%ecx
80105993:	0f 84 26 ff ff ff    	je     801058bf <trap+0xef>
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80105999:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010599c:	5b                   	pop    %ebx
8010599d:	5e                   	pop    %esi
8010599e:	5f                   	pop    %edi
8010599f:	5d                   	pop    %ebp
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
801059a0:	e9 4b e2 ff ff       	jmp    80103bf0 <exit>
801059a5:	8d 76 00             	lea    0x0(%esi),%esi
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
801059a8:	e8 43 e2 ff ff       	call   80103bf0 <exit>
801059ad:	eb cd                	jmp    8010597c <trap+0x1ac>
801059af:	90                   	nop
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
801059b0:	83 ec 0c             	sub    $0xc,%esp
801059b3:	68 60 4c 11 80       	push   $0x80114c60
801059b8:	e8 23 e9 ff ff       	call   801042e0 <acquire>
      ticks++;
      wakeup(&ticks);
801059bd:	c7 04 24 a0 54 11 80 	movl   $0x801154a0,(%esp)

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
801059c4:	83 05 a0 54 11 80 01 	addl   $0x1,0x801154a0
      wakeup(&ticks);
801059cb:	e8 50 e5 ff ff       	call   80103f20 <wakeup>
      release(&tickslock);
801059d0:	c7 04 24 60 4c 11 80 	movl   $0x80114c60,(%esp)
801059d7:	e8 24 ea ff ff       	call   80104400 <release>
801059dc:	83 c4 10             	add    $0x10,%esp
801059df:	e9 21 ff ff ff       	jmp    80105905 <trap+0x135>
801059e4:	0f 20 d6             	mov    %cr2,%esi

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801059e7:	8b 5f 38             	mov    0x38(%edi),%ebx
801059ea:	e8 b1 dd ff ff       	call   801037a0 <cpuid>
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	56                   	push   %esi
801059f3:	53                   	push   %ebx
801059f4:	50                   	push   %eax
801059f5:	ff 77 30             	pushl  0x30(%edi)
801059f8:	68 d0 77 10 80       	push   $0x801077d0
801059fd:	e8 5e ac ff ff       	call   80100660 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80105a02:	83 c4 14             	add    $0x14,%esp
80105a05:	68 a6 77 10 80       	push   $0x801077a6
80105a0a:	e8 61 a9 ff ff       	call   80100370 <panic>
80105a0f:	90                   	nop

80105a10 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105a10:	a1 bc a5 10 80       	mov    0x8010a5bc,%eax
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105a15:	55                   	push   %ebp
80105a16:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105a18:	85 c0                	test   %eax,%eax
80105a1a:	74 1c                	je     80105a38 <uartgetc+0x28>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105a1c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105a21:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105a22:	a8 01                	test   $0x1,%al
80105a24:	74 12                	je     80105a38 <uartgetc+0x28>
80105a26:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105a2b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105a2c:	0f b6 c0             	movzbl %al,%eax
}
80105a2f:	5d                   	pop    %ebp
80105a30:	c3                   	ret    
80105a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

static int
uartgetc(void)
{
  if(!uart)
    return -1;
80105a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(!(inb(COM1+5) & 0x01))
    return -1;
  return inb(COM1+0);
}
80105a3d:	5d                   	pop    %ebp
80105a3e:	c3                   	ret    
80105a3f:	90                   	nop

80105a40 <uartputc.part.0>:
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}

void
uartputc(int c)
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	57                   	push   %edi
80105a44:	56                   	push   %esi
80105a45:	53                   	push   %ebx
80105a46:	89 c7                	mov    %eax,%edi
80105a48:	bb 80 00 00 00       	mov    $0x80,%ebx
80105a4d:	be fd 03 00 00       	mov    $0x3fd,%esi
80105a52:	83 ec 0c             	sub    $0xc,%esp
80105a55:	eb 1b                	jmp    80105a72 <uartputc.part.0+0x32>
80105a57:	89 f6                	mov    %esi,%esi
80105a59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
80105a60:	83 ec 0c             	sub    $0xc,%esp
80105a63:	6a 0a                	push   $0xa
80105a65:	e8 06 cd ff ff       	call   80102770 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105a6a:	83 c4 10             	add    $0x10,%esp
80105a6d:	83 eb 01             	sub    $0x1,%ebx
80105a70:	74 07                	je     80105a79 <uartputc.part.0+0x39>
80105a72:	89 f2                	mov    %esi,%edx
80105a74:	ec                   	in     (%dx),%al
80105a75:	a8 20                	test   $0x20,%al
80105a77:	74 e7                	je     80105a60 <uartputc.part.0+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105a79:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105a7e:	89 f8                	mov    %edi,%eax
80105a80:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
80105a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a84:	5b                   	pop    %ebx
80105a85:	5e                   	pop    %esi
80105a86:	5f                   	pop    %edi
80105a87:	5d                   	pop    %ebp
80105a88:	c3                   	ret    
80105a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105a90 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80105a90:	55                   	push   %ebp
80105a91:	31 c9                	xor    %ecx,%ecx
80105a93:	89 c8                	mov    %ecx,%eax
80105a95:	89 e5                	mov    %esp,%ebp
80105a97:	57                   	push   %edi
80105a98:	56                   	push   %esi
80105a99:	53                   	push   %ebx
80105a9a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
80105a9f:	89 da                	mov    %ebx,%edx
80105aa1:	83 ec 0c             	sub    $0xc,%esp
80105aa4:	ee                   	out    %al,(%dx)
80105aa5:	bf fb 03 00 00       	mov    $0x3fb,%edi
80105aaa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105aaf:	89 fa                	mov    %edi,%edx
80105ab1:	ee                   	out    %al,(%dx)
80105ab2:	b8 0c 00 00 00       	mov    $0xc,%eax
80105ab7:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105abc:	ee                   	out    %al,(%dx)
80105abd:	be f9 03 00 00       	mov    $0x3f9,%esi
80105ac2:	89 c8                	mov    %ecx,%eax
80105ac4:	89 f2                	mov    %esi,%edx
80105ac6:	ee                   	out    %al,(%dx)
80105ac7:	b8 03 00 00 00       	mov    $0x3,%eax
80105acc:	89 fa                	mov    %edi,%edx
80105ace:	ee                   	out    %al,(%dx)
80105acf:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105ad4:	89 c8                	mov    %ecx,%eax
80105ad6:	ee                   	out    %al,(%dx)
80105ad7:	b8 01 00 00 00       	mov    $0x1,%eax
80105adc:	89 f2                	mov    %esi,%edx
80105ade:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105adf:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105ae4:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80105ae5:	3c ff                	cmp    $0xff,%al
80105ae7:	74 5a                	je     80105b43 <uartinit+0xb3>
    return;
  uart = 1;
80105ae9:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105af0:	00 00 00 
80105af3:	89 da                	mov    %ebx,%edx
80105af5:	ec                   	in     (%dx),%al
80105af6:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105afb:	ec                   	in     (%dx),%al

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);
80105afc:	83 ec 08             	sub    $0x8,%esp
80105aff:	bb c8 78 10 80       	mov    $0x801078c8,%ebx
80105b04:	6a 00                	push   $0x0
80105b06:	6a 04                	push   $0x4
80105b08:	e8 73 c8 ff ff       	call   80102380 <ioapicenable>
80105b0d:	83 c4 10             	add    $0x10,%esp
80105b10:	b8 78 00 00 00       	mov    $0x78,%eax
80105b15:	eb 13                	jmp    80105b2a <uartinit+0x9a>
80105b17:	89 f6                	mov    %esi,%esi
80105b19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80105b20:	83 c3 01             	add    $0x1,%ebx
80105b23:	0f be 03             	movsbl (%ebx),%eax
80105b26:	84 c0                	test   %al,%al
80105b28:	74 19                	je     80105b43 <uartinit+0xb3>
void
uartputc(int c)
{
  int i;

  if(!uart)
80105b2a:	8b 15 bc a5 10 80    	mov    0x8010a5bc,%edx
80105b30:	85 d2                	test   %edx,%edx
80105b32:	74 ec                	je     80105b20 <uartinit+0x90>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80105b34:	83 c3 01             	add    $0x1,%ebx
80105b37:	e8 04 ff ff ff       	call   80105a40 <uartputc.part.0>
80105b3c:	0f be 03             	movsbl (%ebx),%eax
80105b3f:	84 c0                	test   %al,%al
80105b41:	75 e7                	jne    80105b2a <uartinit+0x9a>
    uartputc(*p);
}
80105b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b46:	5b                   	pop    %ebx
80105b47:	5e                   	pop    %esi
80105b48:	5f                   	pop    %edi
80105b49:	5d                   	pop    %ebp
80105b4a:	c3                   	ret    
80105b4b:	90                   	nop
80105b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b50 <uartputc>:
void
uartputc(int c)
{
  int i;

  if(!uart)
80105b50:	8b 15 bc a5 10 80    	mov    0x8010a5bc,%edx
    uartputc(*p);
}

void
uartputc(int c)
{
80105b56:	55                   	push   %ebp
80105b57:	89 e5                	mov    %esp,%ebp
  int i;

  if(!uart)
80105b59:	85 d2                	test   %edx,%edx
    uartputc(*p);
}

void
uartputc(int c)
{
80105b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  int i;

  if(!uart)
80105b5e:	74 10                	je     80105b70 <uartputc+0x20>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80105b60:	5d                   	pop    %ebp
80105b61:	e9 da fe ff ff       	jmp    80105a40 <uartputc.part.0>
80105b66:	8d 76 00             	lea    0x0(%esi),%esi
80105b69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80105b70:	5d                   	pop    %ebp
80105b71:	c3                   	ret    
80105b72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105b80 <uartintr>:
  return inb(COM1+0);
}

void
uartintr(void)
{
80105b80:	55                   	push   %ebp
80105b81:	89 e5                	mov    %esp,%ebp
80105b83:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105b86:	68 10 5a 10 80       	push   $0x80105a10
80105b8b:	e8 60 ac ff ff       	call   801007f0 <consoleintr>
}
80105b90:	83 c4 10             	add    $0x10,%esp
80105b93:	c9                   	leave  
80105b94:	c3                   	ret    

80105b95 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105b95:	6a 00                	push   $0x0
  pushl $0
80105b97:	6a 00                	push   $0x0
  jmp alltraps
80105b99:	e9 3c fb ff ff       	jmp    801056da <alltraps>

80105b9e <vector1>:
.globl vector1
vector1:
  pushl $0
80105b9e:	6a 00                	push   $0x0
  pushl $1
80105ba0:	6a 01                	push   $0x1
  jmp alltraps
80105ba2:	e9 33 fb ff ff       	jmp    801056da <alltraps>

80105ba7 <vector2>:
.globl vector2
vector2:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $2
80105ba9:	6a 02                	push   $0x2
  jmp alltraps
80105bab:	e9 2a fb ff ff       	jmp    801056da <alltraps>

80105bb0 <vector3>:
.globl vector3
vector3:
  pushl $0
80105bb0:	6a 00                	push   $0x0
  pushl $3
80105bb2:	6a 03                	push   $0x3
  jmp alltraps
80105bb4:	e9 21 fb ff ff       	jmp    801056da <alltraps>

80105bb9 <vector4>:
.globl vector4
vector4:
  pushl $0
80105bb9:	6a 00                	push   $0x0
  pushl $4
80105bbb:	6a 04                	push   $0x4
  jmp alltraps
80105bbd:	e9 18 fb ff ff       	jmp    801056da <alltraps>

80105bc2 <vector5>:
.globl vector5
vector5:
  pushl $0
80105bc2:	6a 00                	push   $0x0
  pushl $5
80105bc4:	6a 05                	push   $0x5
  jmp alltraps
80105bc6:	e9 0f fb ff ff       	jmp    801056da <alltraps>

80105bcb <vector6>:
.globl vector6
vector6:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $6
80105bcd:	6a 06                	push   $0x6
  jmp alltraps
80105bcf:	e9 06 fb ff ff       	jmp    801056da <alltraps>

80105bd4 <vector7>:
.globl vector7
vector7:
  pushl $0
80105bd4:	6a 00                	push   $0x0
  pushl $7
80105bd6:	6a 07                	push   $0x7
  jmp alltraps
80105bd8:	e9 fd fa ff ff       	jmp    801056da <alltraps>

80105bdd <vector8>:
.globl vector8
vector8:
  pushl $8
80105bdd:	6a 08                	push   $0x8
  jmp alltraps
80105bdf:	e9 f6 fa ff ff       	jmp    801056da <alltraps>

80105be4 <vector9>:
.globl vector9
vector9:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $9
80105be6:	6a 09                	push   $0x9
  jmp alltraps
80105be8:	e9 ed fa ff ff       	jmp    801056da <alltraps>

80105bed <vector10>:
.globl vector10
vector10:
  pushl $10
80105bed:	6a 0a                	push   $0xa
  jmp alltraps
80105bef:	e9 e6 fa ff ff       	jmp    801056da <alltraps>

80105bf4 <vector11>:
.globl vector11
vector11:
  pushl $11
80105bf4:	6a 0b                	push   $0xb
  jmp alltraps
80105bf6:	e9 df fa ff ff       	jmp    801056da <alltraps>

80105bfb <vector12>:
.globl vector12
vector12:
  pushl $12
80105bfb:	6a 0c                	push   $0xc
  jmp alltraps
80105bfd:	e9 d8 fa ff ff       	jmp    801056da <alltraps>

80105c02 <vector13>:
.globl vector13
vector13:
  pushl $13
80105c02:	6a 0d                	push   $0xd
  jmp alltraps
80105c04:	e9 d1 fa ff ff       	jmp    801056da <alltraps>

80105c09 <vector14>:
.globl vector14
vector14:
  pushl $14
80105c09:	6a 0e                	push   $0xe
  jmp alltraps
80105c0b:	e9 ca fa ff ff       	jmp    801056da <alltraps>

80105c10 <vector15>:
.globl vector15
vector15:
  pushl $0
80105c10:	6a 00                	push   $0x0
  pushl $15
80105c12:	6a 0f                	push   $0xf
  jmp alltraps
80105c14:	e9 c1 fa ff ff       	jmp    801056da <alltraps>

80105c19 <vector16>:
.globl vector16
vector16:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $16
80105c1b:	6a 10                	push   $0x10
  jmp alltraps
80105c1d:	e9 b8 fa ff ff       	jmp    801056da <alltraps>

80105c22 <vector17>:
.globl vector17
vector17:
  pushl $17
80105c22:	6a 11                	push   $0x11
  jmp alltraps
80105c24:	e9 b1 fa ff ff       	jmp    801056da <alltraps>

80105c29 <vector18>:
.globl vector18
vector18:
  pushl $0
80105c29:	6a 00                	push   $0x0
  pushl $18
80105c2b:	6a 12                	push   $0x12
  jmp alltraps
80105c2d:	e9 a8 fa ff ff       	jmp    801056da <alltraps>

80105c32 <vector19>:
.globl vector19
vector19:
  pushl $0
80105c32:	6a 00                	push   $0x0
  pushl $19
80105c34:	6a 13                	push   $0x13
  jmp alltraps
80105c36:	e9 9f fa ff ff       	jmp    801056da <alltraps>

80105c3b <vector20>:
.globl vector20
vector20:
  pushl $0
80105c3b:	6a 00                	push   $0x0
  pushl $20
80105c3d:	6a 14                	push   $0x14
  jmp alltraps
80105c3f:	e9 96 fa ff ff       	jmp    801056da <alltraps>

80105c44 <vector21>:
.globl vector21
vector21:
  pushl $0
80105c44:	6a 00                	push   $0x0
  pushl $21
80105c46:	6a 15                	push   $0x15
  jmp alltraps
80105c48:	e9 8d fa ff ff       	jmp    801056da <alltraps>

80105c4d <vector22>:
.globl vector22
vector22:
  pushl $0
80105c4d:	6a 00                	push   $0x0
  pushl $22
80105c4f:	6a 16                	push   $0x16
  jmp alltraps
80105c51:	e9 84 fa ff ff       	jmp    801056da <alltraps>

80105c56 <vector23>:
.globl vector23
vector23:
  pushl $0
80105c56:	6a 00                	push   $0x0
  pushl $23
80105c58:	6a 17                	push   $0x17
  jmp alltraps
80105c5a:	e9 7b fa ff ff       	jmp    801056da <alltraps>

80105c5f <vector24>:
.globl vector24
vector24:
  pushl $0
80105c5f:	6a 00                	push   $0x0
  pushl $24
80105c61:	6a 18                	push   $0x18
  jmp alltraps
80105c63:	e9 72 fa ff ff       	jmp    801056da <alltraps>

80105c68 <vector25>:
.globl vector25
vector25:
  pushl $0
80105c68:	6a 00                	push   $0x0
  pushl $25
80105c6a:	6a 19                	push   $0x19
  jmp alltraps
80105c6c:	e9 69 fa ff ff       	jmp    801056da <alltraps>

80105c71 <vector26>:
.globl vector26
vector26:
  pushl $0
80105c71:	6a 00                	push   $0x0
  pushl $26
80105c73:	6a 1a                	push   $0x1a
  jmp alltraps
80105c75:	e9 60 fa ff ff       	jmp    801056da <alltraps>

80105c7a <vector27>:
.globl vector27
vector27:
  pushl $0
80105c7a:	6a 00                	push   $0x0
  pushl $27
80105c7c:	6a 1b                	push   $0x1b
  jmp alltraps
80105c7e:	e9 57 fa ff ff       	jmp    801056da <alltraps>

80105c83 <vector28>:
.globl vector28
vector28:
  pushl $0
80105c83:	6a 00                	push   $0x0
  pushl $28
80105c85:	6a 1c                	push   $0x1c
  jmp alltraps
80105c87:	e9 4e fa ff ff       	jmp    801056da <alltraps>

80105c8c <vector29>:
.globl vector29
vector29:
  pushl $0
80105c8c:	6a 00                	push   $0x0
  pushl $29
80105c8e:	6a 1d                	push   $0x1d
  jmp alltraps
80105c90:	e9 45 fa ff ff       	jmp    801056da <alltraps>

80105c95 <vector30>:
.globl vector30
vector30:
  pushl $0
80105c95:	6a 00                	push   $0x0
  pushl $30
80105c97:	6a 1e                	push   $0x1e
  jmp alltraps
80105c99:	e9 3c fa ff ff       	jmp    801056da <alltraps>

80105c9e <vector31>:
.globl vector31
vector31:
  pushl $0
80105c9e:	6a 00                	push   $0x0
  pushl $31
80105ca0:	6a 1f                	push   $0x1f
  jmp alltraps
80105ca2:	e9 33 fa ff ff       	jmp    801056da <alltraps>

80105ca7 <vector32>:
.globl vector32
vector32:
  pushl $0
80105ca7:	6a 00                	push   $0x0
  pushl $32
80105ca9:	6a 20                	push   $0x20
  jmp alltraps
80105cab:	e9 2a fa ff ff       	jmp    801056da <alltraps>

80105cb0 <vector33>:
.globl vector33
vector33:
  pushl $0
80105cb0:	6a 00                	push   $0x0
  pushl $33
80105cb2:	6a 21                	push   $0x21
  jmp alltraps
80105cb4:	e9 21 fa ff ff       	jmp    801056da <alltraps>

80105cb9 <vector34>:
.globl vector34
vector34:
  pushl $0
80105cb9:	6a 00                	push   $0x0
  pushl $34
80105cbb:	6a 22                	push   $0x22
  jmp alltraps
80105cbd:	e9 18 fa ff ff       	jmp    801056da <alltraps>

80105cc2 <vector35>:
.globl vector35
vector35:
  pushl $0
80105cc2:	6a 00                	push   $0x0
  pushl $35
80105cc4:	6a 23                	push   $0x23
  jmp alltraps
80105cc6:	e9 0f fa ff ff       	jmp    801056da <alltraps>

80105ccb <vector36>:
.globl vector36
vector36:
  pushl $0
80105ccb:	6a 00                	push   $0x0
  pushl $36
80105ccd:	6a 24                	push   $0x24
  jmp alltraps
80105ccf:	e9 06 fa ff ff       	jmp    801056da <alltraps>

80105cd4 <vector37>:
.globl vector37
vector37:
  pushl $0
80105cd4:	6a 00                	push   $0x0
  pushl $37
80105cd6:	6a 25                	push   $0x25
  jmp alltraps
80105cd8:	e9 fd f9 ff ff       	jmp    801056da <alltraps>

80105cdd <vector38>:
.globl vector38
vector38:
  pushl $0
80105cdd:	6a 00                	push   $0x0
  pushl $38
80105cdf:	6a 26                	push   $0x26
  jmp alltraps
80105ce1:	e9 f4 f9 ff ff       	jmp    801056da <alltraps>

80105ce6 <vector39>:
.globl vector39
vector39:
  pushl $0
80105ce6:	6a 00                	push   $0x0
  pushl $39
80105ce8:	6a 27                	push   $0x27
  jmp alltraps
80105cea:	e9 eb f9 ff ff       	jmp    801056da <alltraps>

80105cef <vector40>:
.globl vector40
vector40:
  pushl $0
80105cef:	6a 00                	push   $0x0
  pushl $40
80105cf1:	6a 28                	push   $0x28
  jmp alltraps
80105cf3:	e9 e2 f9 ff ff       	jmp    801056da <alltraps>

80105cf8 <vector41>:
.globl vector41
vector41:
  pushl $0
80105cf8:	6a 00                	push   $0x0
  pushl $41
80105cfa:	6a 29                	push   $0x29
  jmp alltraps
80105cfc:	e9 d9 f9 ff ff       	jmp    801056da <alltraps>

80105d01 <vector42>:
.globl vector42
vector42:
  pushl $0
80105d01:	6a 00                	push   $0x0
  pushl $42
80105d03:	6a 2a                	push   $0x2a
  jmp alltraps
80105d05:	e9 d0 f9 ff ff       	jmp    801056da <alltraps>

80105d0a <vector43>:
.globl vector43
vector43:
  pushl $0
80105d0a:	6a 00                	push   $0x0
  pushl $43
80105d0c:	6a 2b                	push   $0x2b
  jmp alltraps
80105d0e:	e9 c7 f9 ff ff       	jmp    801056da <alltraps>

80105d13 <vector44>:
.globl vector44
vector44:
  pushl $0
80105d13:	6a 00                	push   $0x0
  pushl $44
80105d15:	6a 2c                	push   $0x2c
  jmp alltraps
80105d17:	e9 be f9 ff ff       	jmp    801056da <alltraps>

80105d1c <vector45>:
.globl vector45
vector45:
  pushl $0
80105d1c:	6a 00                	push   $0x0
  pushl $45
80105d1e:	6a 2d                	push   $0x2d
  jmp alltraps
80105d20:	e9 b5 f9 ff ff       	jmp    801056da <alltraps>

80105d25 <vector46>:
.globl vector46
vector46:
  pushl $0
80105d25:	6a 00                	push   $0x0
  pushl $46
80105d27:	6a 2e                	push   $0x2e
  jmp alltraps
80105d29:	e9 ac f9 ff ff       	jmp    801056da <alltraps>

80105d2e <vector47>:
.globl vector47
vector47:
  pushl $0
80105d2e:	6a 00                	push   $0x0
  pushl $47
80105d30:	6a 2f                	push   $0x2f
  jmp alltraps
80105d32:	e9 a3 f9 ff ff       	jmp    801056da <alltraps>

80105d37 <vector48>:
.globl vector48
vector48:
  pushl $0
80105d37:	6a 00                	push   $0x0
  pushl $48
80105d39:	6a 30                	push   $0x30
  jmp alltraps
80105d3b:	e9 9a f9 ff ff       	jmp    801056da <alltraps>

80105d40 <vector49>:
.globl vector49
vector49:
  pushl $0
80105d40:	6a 00                	push   $0x0
  pushl $49
80105d42:	6a 31                	push   $0x31
  jmp alltraps
80105d44:	e9 91 f9 ff ff       	jmp    801056da <alltraps>

80105d49 <vector50>:
.globl vector50
vector50:
  pushl $0
80105d49:	6a 00                	push   $0x0
  pushl $50
80105d4b:	6a 32                	push   $0x32
  jmp alltraps
80105d4d:	e9 88 f9 ff ff       	jmp    801056da <alltraps>

80105d52 <vector51>:
.globl vector51
vector51:
  pushl $0
80105d52:	6a 00                	push   $0x0
  pushl $51
80105d54:	6a 33                	push   $0x33
  jmp alltraps
80105d56:	e9 7f f9 ff ff       	jmp    801056da <alltraps>

80105d5b <vector52>:
.globl vector52
vector52:
  pushl $0
80105d5b:	6a 00                	push   $0x0
  pushl $52
80105d5d:	6a 34                	push   $0x34
  jmp alltraps
80105d5f:	e9 76 f9 ff ff       	jmp    801056da <alltraps>

80105d64 <vector53>:
.globl vector53
vector53:
  pushl $0
80105d64:	6a 00                	push   $0x0
  pushl $53
80105d66:	6a 35                	push   $0x35
  jmp alltraps
80105d68:	e9 6d f9 ff ff       	jmp    801056da <alltraps>

80105d6d <vector54>:
.globl vector54
vector54:
  pushl $0
80105d6d:	6a 00                	push   $0x0
  pushl $54
80105d6f:	6a 36                	push   $0x36
  jmp alltraps
80105d71:	e9 64 f9 ff ff       	jmp    801056da <alltraps>

80105d76 <vector55>:
.globl vector55
vector55:
  pushl $0
80105d76:	6a 00                	push   $0x0
  pushl $55
80105d78:	6a 37                	push   $0x37
  jmp alltraps
80105d7a:	e9 5b f9 ff ff       	jmp    801056da <alltraps>

80105d7f <vector56>:
.globl vector56
vector56:
  pushl $0
80105d7f:	6a 00                	push   $0x0
  pushl $56
80105d81:	6a 38                	push   $0x38
  jmp alltraps
80105d83:	e9 52 f9 ff ff       	jmp    801056da <alltraps>

80105d88 <vector57>:
.globl vector57
vector57:
  pushl $0
80105d88:	6a 00                	push   $0x0
  pushl $57
80105d8a:	6a 39                	push   $0x39
  jmp alltraps
80105d8c:	e9 49 f9 ff ff       	jmp    801056da <alltraps>

80105d91 <vector58>:
.globl vector58
vector58:
  pushl $0
80105d91:	6a 00                	push   $0x0
  pushl $58
80105d93:	6a 3a                	push   $0x3a
  jmp alltraps
80105d95:	e9 40 f9 ff ff       	jmp    801056da <alltraps>

80105d9a <vector59>:
.globl vector59
vector59:
  pushl $0
80105d9a:	6a 00                	push   $0x0
  pushl $59
80105d9c:	6a 3b                	push   $0x3b
  jmp alltraps
80105d9e:	e9 37 f9 ff ff       	jmp    801056da <alltraps>

80105da3 <vector60>:
.globl vector60
vector60:
  pushl $0
80105da3:	6a 00                	push   $0x0
  pushl $60
80105da5:	6a 3c                	push   $0x3c
  jmp alltraps
80105da7:	e9 2e f9 ff ff       	jmp    801056da <alltraps>

80105dac <vector61>:
.globl vector61
vector61:
  pushl $0
80105dac:	6a 00                	push   $0x0
  pushl $61
80105dae:	6a 3d                	push   $0x3d
  jmp alltraps
80105db0:	e9 25 f9 ff ff       	jmp    801056da <alltraps>

80105db5 <vector62>:
.globl vector62
vector62:
  pushl $0
80105db5:	6a 00                	push   $0x0
  pushl $62
80105db7:	6a 3e                	push   $0x3e
  jmp alltraps
80105db9:	e9 1c f9 ff ff       	jmp    801056da <alltraps>

80105dbe <vector63>:
.globl vector63
vector63:
  pushl $0
80105dbe:	6a 00                	push   $0x0
  pushl $63
80105dc0:	6a 3f                	push   $0x3f
  jmp alltraps
80105dc2:	e9 13 f9 ff ff       	jmp    801056da <alltraps>

80105dc7 <vector64>:
.globl vector64
vector64:
  pushl $0
80105dc7:	6a 00                	push   $0x0
  pushl $64
80105dc9:	6a 40                	push   $0x40
  jmp alltraps
80105dcb:	e9 0a f9 ff ff       	jmp    801056da <alltraps>

80105dd0 <vector65>:
.globl vector65
vector65:
  pushl $0
80105dd0:	6a 00                	push   $0x0
  pushl $65
80105dd2:	6a 41                	push   $0x41
  jmp alltraps
80105dd4:	e9 01 f9 ff ff       	jmp    801056da <alltraps>

80105dd9 <vector66>:
.globl vector66
vector66:
  pushl $0
80105dd9:	6a 00                	push   $0x0
  pushl $66
80105ddb:	6a 42                	push   $0x42
  jmp alltraps
80105ddd:	e9 f8 f8 ff ff       	jmp    801056da <alltraps>

80105de2 <vector67>:
.globl vector67
vector67:
  pushl $0
80105de2:	6a 00                	push   $0x0
  pushl $67
80105de4:	6a 43                	push   $0x43
  jmp alltraps
80105de6:	e9 ef f8 ff ff       	jmp    801056da <alltraps>

80105deb <vector68>:
.globl vector68
vector68:
  pushl $0
80105deb:	6a 00                	push   $0x0
  pushl $68
80105ded:	6a 44                	push   $0x44
  jmp alltraps
80105def:	e9 e6 f8 ff ff       	jmp    801056da <alltraps>

80105df4 <vector69>:
.globl vector69
vector69:
  pushl $0
80105df4:	6a 00                	push   $0x0
  pushl $69
80105df6:	6a 45                	push   $0x45
  jmp alltraps
80105df8:	e9 dd f8 ff ff       	jmp    801056da <alltraps>

80105dfd <vector70>:
.globl vector70
vector70:
  pushl $0
80105dfd:	6a 00                	push   $0x0
  pushl $70
80105dff:	6a 46                	push   $0x46
  jmp alltraps
80105e01:	e9 d4 f8 ff ff       	jmp    801056da <alltraps>

80105e06 <vector71>:
.globl vector71
vector71:
  pushl $0
80105e06:	6a 00                	push   $0x0
  pushl $71
80105e08:	6a 47                	push   $0x47
  jmp alltraps
80105e0a:	e9 cb f8 ff ff       	jmp    801056da <alltraps>

80105e0f <vector72>:
.globl vector72
vector72:
  pushl $0
80105e0f:	6a 00                	push   $0x0
  pushl $72
80105e11:	6a 48                	push   $0x48
  jmp alltraps
80105e13:	e9 c2 f8 ff ff       	jmp    801056da <alltraps>

80105e18 <vector73>:
.globl vector73
vector73:
  pushl $0
80105e18:	6a 00                	push   $0x0
  pushl $73
80105e1a:	6a 49                	push   $0x49
  jmp alltraps
80105e1c:	e9 b9 f8 ff ff       	jmp    801056da <alltraps>

80105e21 <vector74>:
.globl vector74
vector74:
  pushl $0
80105e21:	6a 00                	push   $0x0
  pushl $74
80105e23:	6a 4a                	push   $0x4a
  jmp alltraps
80105e25:	e9 b0 f8 ff ff       	jmp    801056da <alltraps>

80105e2a <vector75>:
.globl vector75
vector75:
  pushl $0
80105e2a:	6a 00                	push   $0x0
  pushl $75
80105e2c:	6a 4b                	push   $0x4b
  jmp alltraps
80105e2e:	e9 a7 f8 ff ff       	jmp    801056da <alltraps>

80105e33 <vector76>:
.globl vector76
vector76:
  pushl $0
80105e33:	6a 00                	push   $0x0
  pushl $76
80105e35:	6a 4c                	push   $0x4c
  jmp alltraps
80105e37:	e9 9e f8 ff ff       	jmp    801056da <alltraps>

80105e3c <vector77>:
.globl vector77
vector77:
  pushl $0
80105e3c:	6a 00                	push   $0x0
  pushl $77
80105e3e:	6a 4d                	push   $0x4d
  jmp alltraps
80105e40:	e9 95 f8 ff ff       	jmp    801056da <alltraps>

80105e45 <vector78>:
.globl vector78
vector78:
  pushl $0
80105e45:	6a 00                	push   $0x0
  pushl $78
80105e47:	6a 4e                	push   $0x4e
  jmp alltraps
80105e49:	e9 8c f8 ff ff       	jmp    801056da <alltraps>

80105e4e <vector79>:
.globl vector79
vector79:
  pushl $0
80105e4e:	6a 00                	push   $0x0
  pushl $79
80105e50:	6a 4f                	push   $0x4f
  jmp alltraps
80105e52:	e9 83 f8 ff ff       	jmp    801056da <alltraps>

80105e57 <vector80>:
.globl vector80
vector80:
  pushl $0
80105e57:	6a 00                	push   $0x0
  pushl $80
80105e59:	6a 50                	push   $0x50
  jmp alltraps
80105e5b:	e9 7a f8 ff ff       	jmp    801056da <alltraps>

80105e60 <vector81>:
.globl vector81
vector81:
  pushl $0
80105e60:	6a 00                	push   $0x0
  pushl $81
80105e62:	6a 51                	push   $0x51
  jmp alltraps
80105e64:	e9 71 f8 ff ff       	jmp    801056da <alltraps>

80105e69 <vector82>:
.globl vector82
vector82:
  pushl $0
80105e69:	6a 00                	push   $0x0
  pushl $82
80105e6b:	6a 52                	push   $0x52
  jmp alltraps
80105e6d:	e9 68 f8 ff ff       	jmp    801056da <alltraps>

80105e72 <vector83>:
.globl vector83
vector83:
  pushl $0
80105e72:	6a 00                	push   $0x0
  pushl $83
80105e74:	6a 53                	push   $0x53
  jmp alltraps
80105e76:	e9 5f f8 ff ff       	jmp    801056da <alltraps>

80105e7b <vector84>:
.globl vector84
vector84:
  pushl $0
80105e7b:	6a 00                	push   $0x0
  pushl $84
80105e7d:	6a 54                	push   $0x54
  jmp alltraps
80105e7f:	e9 56 f8 ff ff       	jmp    801056da <alltraps>

80105e84 <vector85>:
.globl vector85
vector85:
  pushl $0
80105e84:	6a 00                	push   $0x0
  pushl $85
80105e86:	6a 55                	push   $0x55
  jmp alltraps
80105e88:	e9 4d f8 ff ff       	jmp    801056da <alltraps>

80105e8d <vector86>:
.globl vector86
vector86:
  pushl $0
80105e8d:	6a 00                	push   $0x0
  pushl $86
80105e8f:	6a 56                	push   $0x56
  jmp alltraps
80105e91:	e9 44 f8 ff ff       	jmp    801056da <alltraps>

80105e96 <vector87>:
.globl vector87
vector87:
  pushl $0
80105e96:	6a 00                	push   $0x0
  pushl $87
80105e98:	6a 57                	push   $0x57
  jmp alltraps
80105e9a:	e9 3b f8 ff ff       	jmp    801056da <alltraps>

80105e9f <vector88>:
.globl vector88
vector88:
  pushl $0
80105e9f:	6a 00                	push   $0x0
  pushl $88
80105ea1:	6a 58                	push   $0x58
  jmp alltraps
80105ea3:	e9 32 f8 ff ff       	jmp    801056da <alltraps>

80105ea8 <vector89>:
.globl vector89
vector89:
  pushl $0
80105ea8:	6a 00                	push   $0x0
  pushl $89
80105eaa:	6a 59                	push   $0x59
  jmp alltraps
80105eac:	e9 29 f8 ff ff       	jmp    801056da <alltraps>

80105eb1 <vector90>:
.globl vector90
vector90:
  pushl $0
80105eb1:	6a 00                	push   $0x0
  pushl $90
80105eb3:	6a 5a                	push   $0x5a
  jmp alltraps
80105eb5:	e9 20 f8 ff ff       	jmp    801056da <alltraps>

80105eba <vector91>:
.globl vector91
vector91:
  pushl $0
80105eba:	6a 00                	push   $0x0
  pushl $91
80105ebc:	6a 5b                	push   $0x5b
  jmp alltraps
80105ebe:	e9 17 f8 ff ff       	jmp    801056da <alltraps>

80105ec3 <vector92>:
.globl vector92
vector92:
  pushl $0
80105ec3:	6a 00                	push   $0x0
  pushl $92
80105ec5:	6a 5c                	push   $0x5c
  jmp alltraps
80105ec7:	e9 0e f8 ff ff       	jmp    801056da <alltraps>

80105ecc <vector93>:
.globl vector93
vector93:
  pushl $0
80105ecc:	6a 00                	push   $0x0
  pushl $93
80105ece:	6a 5d                	push   $0x5d
  jmp alltraps
80105ed0:	e9 05 f8 ff ff       	jmp    801056da <alltraps>

80105ed5 <vector94>:
.globl vector94
vector94:
  pushl $0
80105ed5:	6a 00                	push   $0x0
  pushl $94
80105ed7:	6a 5e                	push   $0x5e
  jmp alltraps
80105ed9:	e9 fc f7 ff ff       	jmp    801056da <alltraps>

80105ede <vector95>:
.globl vector95
vector95:
  pushl $0
80105ede:	6a 00                	push   $0x0
  pushl $95
80105ee0:	6a 5f                	push   $0x5f
  jmp alltraps
80105ee2:	e9 f3 f7 ff ff       	jmp    801056da <alltraps>

80105ee7 <vector96>:
.globl vector96
vector96:
  pushl $0
80105ee7:	6a 00                	push   $0x0
  pushl $96
80105ee9:	6a 60                	push   $0x60
  jmp alltraps
80105eeb:	e9 ea f7 ff ff       	jmp    801056da <alltraps>

80105ef0 <vector97>:
.globl vector97
vector97:
  pushl $0
80105ef0:	6a 00                	push   $0x0
  pushl $97
80105ef2:	6a 61                	push   $0x61
  jmp alltraps
80105ef4:	e9 e1 f7 ff ff       	jmp    801056da <alltraps>

80105ef9 <vector98>:
.globl vector98
vector98:
  pushl $0
80105ef9:	6a 00                	push   $0x0
  pushl $98
80105efb:	6a 62                	push   $0x62
  jmp alltraps
80105efd:	e9 d8 f7 ff ff       	jmp    801056da <alltraps>

80105f02 <vector99>:
.globl vector99
vector99:
  pushl $0
80105f02:	6a 00                	push   $0x0
  pushl $99
80105f04:	6a 63                	push   $0x63
  jmp alltraps
80105f06:	e9 cf f7 ff ff       	jmp    801056da <alltraps>

80105f0b <vector100>:
.globl vector100
vector100:
  pushl $0
80105f0b:	6a 00                	push   $0x0
  pushl $100
80105f0d:	6a 64                	push   $0x64
  jmp alltraps
80105f0f:	e9 c6 f7 ff ff       	jmp    801056da <alltraps>

80105f14 <vector101>:
.globl vector101
vector101:
  pushl $0
80105f14:	6a 00                	push   $0x0
  pushl $101
80105f16:	6a 65                	push   $0x65
  jmp alltraps
80105f18:	e9 bd f7 ff ff       	jmp    801056da <alltraps>

80105f1d <vector102>:
.globl vector102
vector102:
  pushl $0
80105f1d:	6a 00                	push   $0x0
  pushl $102
80105f1f:	6a 66                	push   $0x66
  jmp alltraps
80105f21:	e9 b4 f7 ff ff       	jmp    801056da <alltraps>

80105f26 <vector103>:
.globl vector103
vector103:
  pushl $0
80105f26:	6a 00                	push   $0x0
  pushl $103
80105f28:	6a 67                	push   $0x67
  jmp alltraps
80105f2a:	e9 ab f7 ff ff       	jmp    801056da <alltraps>

80105f2f <vector104>:
.globl vector104
vector104:
  pushl $0
80105f2f:	6a 00                	push   $0x0
  pushl $104
80105f31:	6a 68                	push   $0x68
  jmp alltraps
80105f33:	e9 a2 f7 ff ff       	jmp    801056da <alltraps>

80105f38 <vector105>:
.globl vector105
vector105:
  pushl $0
80105f38:	6a 00                	push   $0x0
  pushl $105
80105f3a:	6a 69                	push   $0x69
  jmp alltraps
80105f3c:	e9 99 f7 ff ff       	jmp    801056da <alltraps>

80105f41 <vector106>:
.globl vector106
vector106:
  pushl $0
80105f41:	6a 00                	push   $0x0
  pushl $106
80105f43:	6a 6a                	push   $0x6a
  jmp alltraps
80105f45:	e9 90 f7 ff ff       	jmp    801056da <alltraps>

80105f4a <vector107>:
.globl vector107
vector107:
  pushl $0
80105f4a:	6a 00                	push   $0x0
  pushl $107
80105f4c:	6a 6b                	push   $0x6b
  jmp alltraps
80105f4e:	e9 87 f7 ff ff       	jmp    801056da <alltraps>

80105f53 <vector108>:
.globl vector108
vector108:
  pushl $0
80105f53:	6a 00                	push   $0x0
  pushl $108
80105f55:	6a 6c                	push   $0x6c
  jmp alltraps
80105f57:	e9 7e f7 ff ff       	jmp    801056da <alltraps>

80105f5c <vector109>:
.globl vector109
vector109:
  pushl $0
80105f5c:	6a 00                	push   $0x0
  pushl $109
80105f5e:	6a 6d                	push   $0x6d
  jmp alltraps
80105f60:	e9 75 f7 ff ff       	jmp    801056da <alltraps>

80105f65 <vector110>:
.globl vector110
vector110:
  pushl $0
80105f65:	6a 00                	push   $0x0
  pushl $110
80105f67:	6a 6e                	push   $0x6e
  jmp alltraps
80105f69:	e9 6c f7 ff ff       	jmp    801056da <alltraps>

80105f6e <vector111>:
.globl vector111
vector111:
  pushl $0
80105f6e:	6a 00                	push   $0x0
  pushl $111
80105f70:	6a 6f                	push   $0x6f
  jmp alltraps
80105f72:	e9 63 f7 ff ff       	jmp    801056da <alltraps>

80105f77 <vector112>:
.globl vector112
vector112:
  pushl $0
80105f77:	6a 00                	push   $0x0
  pushl $112
80105f79:	6a 70                	push   $0x70
  jmp alltraps
80105f7b:	e9 5a f7 ff ff       	jmp    801056da <alltraps>

80105f80 <vector113>:
.globl vector113
vector113:
  pushl $0
80105f80:	6a 00                	push   $0x0
  pushl $113
80105f82:	6a 71                	push   $0x71
  jmp alltraps
80105f84:	e9 51 f7 ff ff       	jmp    801056da <alltraps>

80105f89 <vector114>:
.globl vector114
vector114:
  pushl $0
80105f89:	6a 00                	push   $0x0
  pushl $114
80105f8b:	6a 72                	push   $0x72
  jmp alltraps
80105f8d:	e9 48 f7 ff ff       	jmp    801056da <alltraps>

80105f92 <vector115>:
.globl vector115
vector115:
  pushl $0
80105f92:	6a 00                	push   $0x0
  pushl $115
80105f94:	6a 73                	push   $0x73
  jmp alltraps
80105f96:	e9 3f f7 ff ff       	jmp    801056da <alltraps>

80105f9b <vector116>:
.globl vector116
vector116:
  pushl $0
80105f9b:	6a 00                	push   $0x0
  pushl $116
80105f9d:	6a 74                	push   $0x74
  jmp alltraps
80105f9f:	e9 36 f7 ff ff       	jmp    801056da <alltraps>

80105fa4 <vector117>:
.globl vector117
vector117:
  pushl $0
80105fa4:	6a 00                	push   $0x0
  pushl $117
80105fa6:	6a 75                	push   $0x75
  jmp alltraps
80105fa8:	e9 2d f7 ff ff       	jmp    801056da <alltraps>

80105fad <vector118>:
.globl vector118
vector118:
  pushl $0
80105fad:	6a 00                	push   $0x0
  pushl $118
80105faf:	6a 76                	push   $0x76
  jmp alltraps
80105fb1:	e9 24 f7 ff ff       	jmp    801056da <alltraps>

80105fb6 <vector119>:
.globl vector119
vector119:
  pushl $0
80105fb6:	6a 00                	push   $0x0
  pushl $119
80105fb8:	6a 77                	push   $0x77
  jmp alltraps
80105fba:	e9 1b f7 ff ff       	jmp    801056da <alltraps>

80105fbf <vector120>:
.globl vector120
vector120:
  pushl $0
80105fbf:	6a 00                	push   $0x0
  pushl $120
80105fc1:	6a 78                	push   $0x78
  jmp alltraps
80105fc3:	e9 12 f7 ff ff       	jmp    801056da <alltraps>

80105fc8 <vector121>:
.globl vector121
vector121:
  pushl $0
80105fc8:	6a 00                	push   $0x0
  pushl $121
80105fca:	6a 79                	push   $0x79
  jmp alltraps
80105fcc:	e9 09 f7 ff ff       	jmp    801056da <alltraps>

80105fd1 <vector122>:
.globl vector122
vector122:
  pushl $0
80105fd1:	6a 00                	push   $0x0
  pushl $122
80105fd3:	6a 7a                	push   $0x7a
  jmp alltraps
80105fd5:	e9 00 f7 ff ff       	jmp    801056da <alltraps>

80105fda <vector123>:
.globl vector123
vector123:
  pushl $0
80105fda:	6a 00                	push   $0x0
  pushl $123
80105fdc:	6a 7b                	push   $0x7b
  jmp alltraps
80105fde:	e9 f7 f6 ff ff       	jmp    801056da <alltraps>

80105fe3 <vector124>:
.globl vector124
vector124:
  pushl $0
80105fe3:	6a 00                	push   $0x0
  pushl $124
80105fe5:	6a 7c                	push   $0x7c
  jmp alltraps
80105fe7:	e9 ee f6 ff ff       	jmp    801056da <alltraps>

80105fec <vector125>:
.globl vector125
vector125:
  pushl $0
80105fec:	6a 00                	push   $0x0
  pushl $125
80105fee:	6a 7d                	push   $0x7d
  jmp alltraps
80105ff0:	e9 e5 f6 ff ff       	jmp    801056da <alltraps>

80105ff5 <vector126>:
.globl vector126
vector126:
  pushl $0
80105ff5:	6a 00                	push   $0x0
  pushl $126
80105ff7:	6a 7e                	push   $0x7e
  jmp alltraps
80105ff9:	e9 dc f6 ff ff       	jmp    801056da <alltraps>

80105ffe <vector127>:
.globl vector127
vector127:
  pushl $0
80105ffe:	6a 00                	push   $0x0
  pushl $127
80106000:	6a 7f                	push   $0x7f
  jmp alltraps
80106002:	e9 d3 f6 ff ff       	jmp    801056da <alltraps>

80106007 <vector128>:
.globl vector128
vector128:
  pushl $0
80106007:	6a 00                	push   $0x0
  pushl $128
80106009:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010600e:	e9 c7 f6 ff ff       	jmp    801056da <alltraps>

80106013 <vector129>:
.globl vector129
vector129:
  pushl $0
80106013:	6a 00                	push   $0x0
  pushl $129
80106015:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010601a:	e9 bb f6 ff ff       	jmp    801056da <alltraps>

8010601f <vector130>:
.globl vector130
vector130:
  pushl $0
8010601f:	6a 00                	push   $0x0
  pushl $130
80106021:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106026:	e9 af f6 ff ff       	jmp    801056da <alltraps>

8010602b <vector131>:
.globl vector131
vector131:
  pushl $0
8010602b:	6a 00                	push   $0x0
  pushl $131
8010602d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106032:	e9 a3 f6 ff ff       	jmp    801056da <alltraps>

80106037 <vector132>:
.globl vector132
vector132:
  pushl $0
80106037:	6a 00                	push   $0x0
  pushl $132
80106039:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010603e:	e9 97 f6 ff ff       	jmp    801056da <alltraps>

80106043 <vector133>:
.globl vector133
vector133:
  pushl $0
80106043:	6a 00                	push   $0x0
  pushl $133
80106045:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010604a:	e9 8b f6 ff ff       	jmp    801056da <alltraps>

8010604f <vector134>:
.globl vector134
vector134:
  pushl $0
8010604f:	6a 00                	push   $0x0
  pushl $134
80106051:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106056:	e9 7f f6 ff ff       	jmp    801056da <alltraps>

8010605b <vector135>:
.globl vector135
vector135:
  pushl $0
8010605b:	6a 00                	push   $0x0
  pushl $135
8010605d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106062:	e9 73 f6 ff ff       	jmp    801056da <alltraps>

80106067 <vector136>:
.globl vector136
vector136:
  pushl $0
80106067:	6a 00                	push   $0x0
  pushl $136
80106069:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010606e:	e9 67 f6 ff ff       	jmp    801056da <alltraps>

80106073 <vector137>:
.globl vector137
vector137:
  pushl $0
80106073:	6a 00                	push   $0x0
  pushl $137
80106075:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010607a:	e9 5b f6 ff ff       	jmp    801056da <alltraps>

8010607f <vector138>:
.globl vector138
vector138:
  pushl $0
8010607f:	6a 00                	push   $0x0
  pushl $138
80106081:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106086:	e9 4f f6 ff ff       	jmp    801056da <alltraps>

8010608b <vector139>:
.globl vector139
vector139:
  pushl $0
8010608b:	6a 00                	push   $0x0
  pushl $139
8010608d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106092:	e9 43 f6 ff ff       	jmp    801056da <alltraps>

80106097 <vector140>:
.globl vector140
vector140:
  pushl $0
80106097:	6a 00                	push   $0x0
  pushl $140
80106099:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010609e:	e9 37 f6 ff ff       	jmp    801056da <alltraps>

801060a3 <vector141>:
.globl vector141
vector141:
  pushl $0
801060a3:	6a 00                	push   $0x0
  pushl $141
801060a5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801060aa:	e9 2b f6 ff ff       	jmp    801056da <alltraps>

801060af <vector142>:
.globl vector142
vector142:
  pushl $0
801060af:	6a 00                	push   $0x0
  pushl $142
801060b1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801060b6:	e9 1f f6 ff ff       	jmp    801056da <alltraps>

801060bb <vector143>:
.globl vector143
vector143:
  pushl $0
801060bb:	6a 00                	push   $0x0
  pushl $143
801060bd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801060c2:	e9 13 f6 ff ff       	jmp    801056da <alltraps>

801060c7 <vector144>:
.globl vector144
vector144:
  pushl $0
801060c7:	6a 00                	push   $0x0
  pushl $144
801060c9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801060ce:	e9 07 f6 ff ff       	jmp    801056da <alltraps>

801060d3 <vector145>:
.globl vector145
vector145:
  pushl $0
801060d3:	6a 00                	push   $0x0
  pushl $145
801060d5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801060da:	e9 fb f5 ff ff       	jmp    801056da <alltraps>

801060df <vector146>:
.globl vector146
vector146:
  pushl $0
801060df:	6a 00                	push   $0x0
  pushl $146
801060e1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801060e6:	e9 ef f5 ff ff       	jmp    801056da <alltraps>

801060eb <vector147>:
.globl vector147
vector147:
  pushl $0
801060eb:	6a 00                	push   $0x0
  pushl $147
801060ed:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801060f2:	e9 e3 f5 ff ff       	jmp    801056da <alltraps>

801060f7 <vector148>:
.globl vector148
vector148:
  pushl $0
801060f7:	6a 00                	push   $0x0
  pushl $148
801060f9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801060fe:	e9 d7 f5 ff ff       	jmp    801056da <alltraps>

80106103 <vector149>:
.globl vector149
vector149:
  pushl $0
80106103:	6a 00                	push   $0x0
  pushl $149
80106105:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010610a:	e9 cb f5 ff ff       	jmp    801056da <alltraps>

8010610f <vector150>:
.globl vector150
vector150:
  pushl $0
8010610f:	6a 00                	push   $0x0
  pushl $150
80106111:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106116:	e9 bf f5 ff ff       	jmp    801056da <alltraps>

8010611b <vector151>:
.globl vector151
vector151:
  pushl $0
8010611b:	6a 00                	push   $0x0
  pushl $151
8010611d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106122:	e9 b3 f5 ff ff       	jmp    801056da <alltraps>

80106127 <vector152>:
.globl vector152
vector152:
  pushl $0
80106127:	6a 00                	push   $0x0
  pushl $152
80106129:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010612e:	e9 a7 f5 ff ff       	jmp    801056da <alltraps>

80106133 <vector153>:
.globl vector153
vector153:
  pushl $0
80106133:	6a 00                	push   $0x0
  pushl $153
80106135:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010613a:	e9 9b f5 ff ff       	jmp    801056da <alltraps>

8010613f <vector154>:
.globl vector154
vector154:
  pushl $0
8010613f:	6a 00                	push   $0x0
  pushl $154
80106141:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106146:	e9 8f f5 ff ff       	jmp    801056da <alltraps>

8010614b <vector155>:
.globl vector155
vector155:
  pushl $0
8010614b:	6a 00                	push   $0x0
  pushl $155
8010614d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106152:	e9 83 f5 ff ff       	jmp    801056da <alltraps>

80106157 <vector156>:
.globl vector156
vector156:
  pushl $0
80106157:	6a 00                	push   $0x0
  pushl $156
80106159:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010615e:	e9 77 f5 ff ff       	jmp    801056da <alltraps>

80106163 <vector157>:
.globl vector157
vector157:
  pushl $0
80106163:	6a 00                	push   $0x0
  pushl $157
80106165:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010616a:	e9 6b f5 ff ff       	jmp    801056da <alltraps>

8010616f <vector158>:
.globl vector158
vector158:
  pushl $0
8010616f:	6a 00                	push   $0x0
  pushl $158
80106171:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106176:	e9 5f f5 ff ff       	jmp    801056da <alltraps>

8010617b <vector159>:
.globl vector159
vector159:
  pushl $0
8010617b:	6a 00                	push   $0x0
  pushl $159
8010617d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106182:	e9 53 f5 ff ff       	jmp    801056da <alltraps>

80106187 <vector160>:
.globl vector160
vector160:
  pushl $0
80106187:	6a 00                	push   $0x0
  pushl $160
80106189:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010618e:	e9 47 f5 ff ff       	jmp    801056da <alltraps>

80106193 <vector161>:
.globl vector161
vector161:
  pushl $0
80106193:	6a 00                	push   $0x0
  pushl $161
80106195:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010619a:	e9 3b f5 ff ff       	jmp    801056da <alltraps>

8010619f <vector162>:
.globl vector162
vector162:
  pushl $0
8010619f:	6a 00                	push   $0x0
  pushl $162
801061a1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801061a6:	e9 2f f5 ff ff       	jmp    801056da <alltraps>

801061ab <vector163>:
.globl vector163
vector163:
  pushl $0
801061ab:	6a 00                	push   $0x0
  pushl $163
801061ad:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801061b2:	e9 23 f5 ff ff       	jmp    801056da <alltraps>

801061b7 <vector164>:
.globl vector164
vector164:
  pushl $0
801061b7:	6a 00                	push   $0x0
  pushl $164
801061b9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801061be:	e9 17 f5 ff ff       	jmp    801056da <alltraps>

801061c3 <vector165>:
.globl vector165
vector165:
  pushl $0
801061c3:	6a 00                	push   $0x0
  pushl $165
801061c5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801061ca:	e9 0b f5 ff ff       	jmp    801056da <alltraps>

801061cf <vector166>:
.globl vector166
vector166:
  pushl $0
801061cf:	6a 00                	push   $0x0
  pushl $166
801061d1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801061d6:	e9 ff f4 ff ff       	jmp    801056da <alltraps>

801061db <vector167>:
.globl vector167
vector167:
  pushl $0
801061db:	6a 00                	push   $0x0
  pushl $167
801061dd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801061e2:	e9 f3 f4 ff ff       	jmp    801056da <alltraps>

801061e7 <vector168>:
.globl vector168
vector168:
  pushl $0
801061e7:	6a 00                	push   $0x0
  pushl $168
801061e9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801061ee:	e9 e7 f4 ff ff       	jmp    801056da <alltraps>

801061f3 <vector169>:
.globl vector169
vector169:
  pushl $0
801061f3:	6a 00                	push   $0x0
  pushl $169
801061f5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801061fa:	e9 db f4 ff ff       	jmp    801056da <alltraps>

801061ff <vector170>:
.globl vector170
vector170:
  pushl $0
801061ff:	6a 00                	push   $0x0
  pushl $170
80106201:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106206:	e9 cf f4 ff ff       	jmp    801056da <alltraps>

8010620b <vector171>:
.globl vector171
vector171:
  pushl $0
8010620b:	6a 00                	push   $0x0
  pushl $171
8010620d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106212:	e9 c3 f4 ff ff       	jmp    801056da <alltraps>

80106217 <vector172>:
.globl vector172
vector172:
  pushl $0
80106217:	6a 00                	push   $0x0
  pushl $172
80106219:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010621e:	e9 b7 f4 ff ff       	jmp    801056da <alltraps>

80106223 <vector173>:
.globl vector173
vector173:
  pushl $0
80106223:	6a 00                	push   $0x0
  pushl $173
80106225:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010622a:	e9 ab f4 ff ff       	jmp    801056da <alltraps>

8010622f <vector174>:
.globl vector174
vector174:
  pushl $0
8010622f:	6a 00                	push   $0x0
  pushl $174
80106231:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106236:	e9 9f f4 ff ff       	jmp    801056da <alltraps>

8010623b <vector175>:
.globl vector175
vector175:
  pushl $0
8010623b:	6a 00                	push   $0x0
  pushl $175
8010623d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106242:	e9 93 f4 ff ff       	jmp    801056da <alltraps>

80106247 <vector176>:
.globl vector176
vector176:
  pushl $0
80106247:	6a 00                	push   $0x0
  pushl $176
80106249:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010624e:	e9 87 f4 ff ff       	jmp    801056da <alltraps>

80106253 <vector177>:
.globl vector177
vector177:
  pushl $0
80106253:	6a 00                	push   $0x0
  pushl $177
80106255:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010625a:	e9 7b f4 ff ff       	jmp    801056da <alltraps>

8010625f <vector178>:
.globl vector178
vector178:
  pushl $0
8010625f:	6a 00                	push   $0x0
  pushl $178
80106261:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106266:	e9 6f f4 ff ff       	jmp    801056da <alltraps>

8010626b <vector179>:
.globl vector179
vector179:
  pushl $0
8010626b:	6a 00                	push   $0x0
  pushl $179
8010626d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106272:	e9 63 f4 ff ff       	jmp    801056da <alltraps>

80106277 <vector180>:
.globl vector180
vector180:
  pushl $0
80106277:	6a 00                	push   $0x0
  pushl $180
80106279:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010627e:	e9 57 f4 ff ff       	jmp    801056da <alltraps>

80106283 <vector181>:
.globl vector181
vector181:
  pushl $0
80106283:	6a 00                	push   $0x0
  pushl $181
80106285:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010628a:	e9 4b f4 ff ff       	jmp    801056da <alltraps>

8010628f <vector182>:
.globl vector182
vector182:
  pushl $0
8010628f:	6a 00                	push   $0x0
  pushl $182
80106291:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106296:	e9 3f f4 ff ff       	jmp    801056da <alltraps>

8010629b <vector183>:
.globl vector183
vector183:
  pushl $0
8010629b:	6a 00                	push   $0x0
  pushl $183
8010629d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801062a2:	e9 33 f4 ff ff       	jmp    801056da <alltraps>

801062a7 <vector184>:
.globl vector184
vector184:
  pushl $0
801062a7:	6a 00                	push   $0x0
  pushl $184
801062a9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801062ae:	e9 27 f4 ff ff       	jmp    801056da <alltraps>

801062b3 <vector185>:
.globl vector185
vector185:
  pushl $0
801062b3:	6a 00                	push   $0x0
  pushl $185
801062b5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801062ba:	e9 1b f4 ff ff       	jmp    801056da <alltraps>

801062bf <vector186>:
.globl vector186
vector186:
  pushl $0
801062bf:	6a 00                	push   $0x0
  pushl $186
801062c1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801062c6:	e9 0f f4 ff ff       	jmp    801056da <alltraps>

801062cb <vector187>:
.globl vector187
vector187:
  pushl $0
801062cb:	6a 00                	push   $0x0
  pushl $187
801062cd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801062d2:	e9 03 f4 ff ff       	jmp    801056da <alltraps>

801062d7 <vector188>:
.globl vector188
vector188:
  pushl $0
801062d7:	6a 00                	push   $0x0
  pushl $188
801062d9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801062de:	e9 f7 f3 ff ff       	jmp    801056da <alltraps>

801062e3 <vector189>:
.globl vector189
vector189:
  pushl $0
801062e3:	6a 00                	push   $0x0
  pushl $189
801062e5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801062ea:	e9 eb f3 ff ff       	jmp    801056da <alltraps>

801062ef <vector190>:
.globl vector190
vector190:
  pushl $0
801062ef:	6a 00                	push   $0x0
  pushl $190
801062f1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801062f6:	e9 df f3 ff ff       	jmp    801056da <alltraps>

801062fb <vector191>:
.globl vector191
vector191:
  pushl $0
801062fb:	6a 00                	push   $0x0
  pushl $191
801062fd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106302:	e9 d3 f3 ff ff       	jmp    801056da <alltraps>

80106307 <vector192>:
.globl vector192
vector192:
  pushl $0
80106307:	6a 00                	push   $0x0
  pushl $192
80106309:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010630e:	e9 c7 f3 ff ff       	jmp    801056da <alltraps>

80106313 <vector193>:
.globl vector193
vector193:
  pushl $0
80106313:	6a 00                	push   $0x0
  pushl $193
80106315:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010631a:	e9 bb f3 ff ff       	jmp    801056da <alltraps>

8010631f <vector194>:
.globl vector194
vector194:
  pushl $0
8010631f:	6a 00                	push   $0x0
  pushl $194
80106321:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106326:	e9 af f3 ff ff       	jmp    801056da <alltraps>

8010632b <vector195>:
.globl vector195
vector195:
  pushl $0
8010632b:	6a 00                	push   $0x0
  pushl $195
8010632d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106332:	e9 a3 f3 ff ff       	jmp    801056da <alltraps>

80106337 <vector196>:
.globl vector196
vector196:
  pushl $0
80106337:	6a 00                	push   $0x0
  pushl $196
80106339:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010633e:	e9 97 f3 ff ff       	jmp    801056da <alltraps>

80106343 <vector197>:
.globl vector197
vector197:
  pushl $0
80106343:	6a 00                	push   $0x0
  pushl $197
80106345:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010634a:	e9 8b f3 ff ff       	jmp    801056da <alltraps>

8010634f <vector198>:
.globl vector198
vector198:
  pushl $0
8010634f:	6a 00                	push   $0x0
  pushl $198
80106351:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106356:	e9 7f f3 ff ff       	jmp    801056da <alltraps>

8010635b <vector199>:
.globl vector199
vector199:
  pushl $0
8010635b:	6a 00                	push   $0x0
  pushl $199
8010635d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106362:	e9 73 f3 ff ff       	jmp    801056da <alltraps>

80106367 <vector200>:
.globl vector200
vector200:
  pushl $0
80106367:	6a 00                	push   $0x0
  pushl $200
80106369:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010636e:	e9 67 f3 ff ff       	jmp    801056da <alltraps>

80106373 <vector201>:
.globl vector201
vector201:
  pushl $0
80106373:	6a 00                	push   $0x0
  pushl $201
80106375:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010637a:	e9 5b f3 ff ff       	jmp    801056da <alltraps>

8010637f <vector202>:
.globl vector202
vector202:
  pushl $0
8010637f:	6a 00                	push   $0x0
  pushl $202
80106381:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106386:	e9 4f f3 ff ff       	jmp    801056da <alltraps>

8010638b <vector203>:
.globl vector203
vector203:
  pushl $0
8010638b:	6a 00                	push   $0x0
  pushl $203
8010638d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106392:	e9 43 f3 ff ff       	jmp    801056da <alltraps>

80106397 <vector204>:
.globl vector204
vector204:
  pushl $0
80106397:	6a 00                	push   $0x0
  pushl $204
80106399:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010639e:	e9 37 f3 ff ff       	jmp    801056da <alltraps>

801063a3 <vector205>:
.globl vector205
vector205:
  pushl $0
801063a3:	6a 00                	push   $0x0
  pushl $205
801063a5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801063aa:	e9 2b f3 ff ff       	jmp    801056da <alltraps>

801063af <vector206>:
.globl vector206
vector206:
  pushl $0
801063af:	6a 00                	push   $0x0
  pushl $206
801063b1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801063b6:	e9 1f f3 ff ff       	jmp    801056da <alltraps>

801063bb <vector207>:
.globl vector207
vector207:
  pushl $0
801063bb:	6a 00                	push   $0x0
  pushl $207
801063bd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801063c2:	e9 13 f3 ff ff       	jmp    801056da <alltraps>

801063c7 <vector208>:
.globl vector208
vector208:
  pushl $0
801063c7:	6a 00                	push   $0x0
  pushl $208
801063c9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801063ce:	e9 07 f3 ff ff       	jmp    801056da <alltraps>

801063d3 <vector209>:
.globl vector209
vector209:
  pushl $0
801063d3:	6a 00                	push   $0x0
  pushl $209
801063d5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801063da:	e9 fb f2 ff ff       	jmp    801056da <alltraps>

801063df <vector210>:
.globl vector210
vector210:
  pushl $0
801063df:	6a 00                	push   $0x0
  pushl $210
801063e1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801063e6:	e9 ef f2 ff ff       	jmp    801056da <alltraps>

801063eb <vector211>:
.globl vector211
vector211:
  pushl $0
801063eb:	6a 00                	push   $0x0
  pushl $211
801063ed:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801063f2:	e9 e3 f2 ff ff       	jmp    801056da <alltraps>

801063f7 <vector212>:
.globl vector212
vector212:
  pushl $0
801063f7:	6a 00                	push   $0x0
  pushl $212
801063f9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801063fe:	e9 d7 f2 ff ff       	jmp    801056da <alltraps>

80106403 <vector213>:
.globl vector213
vector213:
  pushl $0
80106403:	6a 00                	push   $0x0
  pushl $213
80106405:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010640a:	e9 cb f2 ff ff       	jmp    801056da <alltraps>

8010640f <vector214>:
.globl vector214
vector214:
  pushl $0
8010640f:	6a 00                	push   $0x0
  pushl $214
80106411:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106416:	e9 bf f2 ff ff       	jmp    801056da <alltraps>

8010641b <vector215>:
.globl vector215
vector215:
  pushl $0
8010641b:	6a 00                	push   $0x0
  pushl $215
8010641d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106422:	e9 b3 f2 ff ff       	jmp    801056da <alltraps>

80106427 <vector216>:
.globl vector216
vector216:
  pushl $0
80106427:	6a 00                	push   $0x0
  pushl $216
80106429:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010642e:	e9 a7 f2 ff ff       	jmp    801056da <alltraps>

80106433 <vector217>:
.globl vector217
vector217:
  pushl $0
80106433:	6a 00                	push   $0x0
  pushl $217
80106435:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010643a:	e9 9b f2 ff ff       	jmp    801056da <alltraps>

8010643f <vector218>:
.globl vector218
vector218:
  pushl $0
8010643f:	6a 00                	push   $0x0
  pushl $218
80106441:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106446:	e9 8f f2 ff ff       	jmp    801056da <alltraps>

8010644b <vector219>:
.globl vector219
vector219:
  pushl $0
8010644b:	6a 00                	push   $0x0
  pushl $219
8010644d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106452:	e9 83 f2 ff ff       	jmp    801056da <alltraps>

80106457 <vector220>:
.globl vector220
vector220:
  pushl $0
80106457:	6a 00                	push   $0x0
  pushl $220
80106459:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010645e:	e9 77 f2 ff ff       	jmp    801056da <alltraps>

80106463 <vector221>:
.globl vector221
vector221:
  pushl $0
80106463:	6a 00                	push   $0x0
  pushl $221
80106465:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010646a:	e9 6b f2 ff ff       	jmp    801056da <alltraps>

8010646f <vector222>:
.globl vector222
vector222:
  pushl $0
8010646f:	6a 00                	push   $0x0
  pushl $222
80106471:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106476:	e9 5f f2 ff ff       	jmp    801056da <alltraps>

8010647b <vector223>:
.globl vector223
vector223:
  pushl $0
8010647b:	6a 00                	push   $0x0
  pushl $223
8010647d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106482:	e9 53 f2 ff ff       	jmp    801056da <alltraps>

80106487 <vector224>:
.globl vector224
vector224:
  pushl $0
80106487:	6a 00                	push   $0x0
  pushl $224
80106489:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010648e:	e9 47 f2 ff ff       	jmp    801056da <alltraps>

80106493 <vector225>:
.globl vector225
vector225:
  pushl $0
80106493:	6a 00                	push   $0x0
  pushl $225
80106495:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010649a:	e9 3b f2 ff ff       	jmp    801056da <alltraps>

8010649f <vector226>:
.globl vector226
vector226:
  pushl $0
8010649f:	6a 00                	push   $0x0
  pushl $226
801064a1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801064a6:	e9 2f f2 ff ff       	jmp    801056da <alltraps>

801064ab <vector227>:
.globl vector227
vector227:
  pushl $0
801064ab:	6a 00                	push   $0x0
  pushl $227
801064ad:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801064b2:	e9 23 f2 ff ff       	jmp    801056da <alltraps>

801064b7 <vector228>:
.globl vector228
vector228:
  pushl $0
801064b7:	6a 00                	push   $0x0
  pushl $228
801064b9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801064be:	e9 17 f2 ff ff       	jmp    801056da <alltraps>

801064c3 <vector229>:
.globl vector229
vector229:
  pushl $0
801064c3:	6a 00                	push   $0x0
  pushl $229
801064c5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801064ca:	e9 0b f2 ff ff       	jmp    801056da <alltraps>

801064cf <vector230>:
.globl vector230
vector230:
  pushl $0
801064cf:	6a 00                	push   $0x0
  pushl $230
801064d1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801064d6:	e9 ff f1 ff ff       	jmp    801056da <alltraps>

801064db <vector231>:
.globl vector231
vector231:
  pushl $0
801064db:	6a 00                	push   $0x0
  pushl $231
801064dd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801064e2:	e9 f3 f1 ff ff       	jmp    801056da <alltraps>

801064e7 <vector232>:
.globl vector232
vector232:
  pushl $0
801064e7:	6a 00                	push   $0x0
  pushl $232
801064e9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801064ee:	e9 e7 f1 ff ff       	jmp    801056da <alltraps>

801064f3 <vector233>:
.globl vector233
vector233:
  pushl $0
801064f3:	6a 00                	push   $0x0
  pushl $233
801064f5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801064fa:	e9 db f1 ff ff       	jmp    801056da <alltraps>

801064ff <vector234>:
.globl vector234
vector234:
  pushl $0
801064ff:	6a 00                	push   $0x0
  pushl $234
80106501:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106506:	e9 cf f1 ff ff       	jmp    801056da <alltraps>

8010650b <vector235>:
.globl vector235
vector235:
  pushl $0
8010650b:	6a 00                	push   $0x0
  pushl $235
8010650d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106512:	e9 c3 f1 ff ff       	jmp    801056da <alltraps>

80106517 <vector236>:
.globl vector236
vector236:
  pushl $0
80106517:	6a 00                	push   $0x0
  pushl $236
80106519:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010651e:	e9 b7 f1 ff ff       	jmp    801056da <alltraps>

80106523 <vector237>:
.globl vector237
vector237:
  pushl $0
80106523:	6a 00                	push   $0x0
  pushl $237
80106525:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010652a:	e9 ab f1 ff ff       	jmp    801056da <alltraps>

8010652f <vector238>:
.globl vector238
vector238:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $238
80106531:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106536:	e9 9f f1 ff ff       	jmp    801056da <alltraps>

8010653b <vector239>:
.globl vector239
vector239:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $239
8010653d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106542:	e9 93 f1 ff ff       	jmp    801056da <alltraps>

80106547 <vector240>:
.globl vector240
vector240:
  pushl $0
80106547:	6a 00                	push   $0x0
  pushl $240
80106549:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010654e:	e9 87 f1 ff ff       	jmp    801056da <alltraps>

80106553 <vector241>:
.globl vector241
vector241:
  pushl $0
80106553:	6a 00                	push   $0x0
  pushl $241
80106555:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010655a:	e9 7b f1 ff ff       	jmp    801056da <alltraps>

8010655f <vector242>:
.globl vector242
vector242:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $242
80106561:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106566:	e9 6f f1 ff ff       	jmp    801056da <alltraps>

8010656b <vector243>:
.globl vector243
vector243:
  pushl $0
8010656b:	6a 00                	push   $0x0
  pushl $243
8010656d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106572:	e9 63 f1 ff ff       	jmp    801056da <alltraps>

80106577 <vector244>:
.globl vector244
vector244:
  pushl $0
80106577:	6a 00                	push   $0x0
  pushl $244
80106579:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010657e:	e9 57 f1 ff ff       	jmp    801056da <alltraps>

80106583 <vector245>:
.globl vector245
vector245:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $245
80106585:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010658a:	e9 4b f1 ff ff       	jmp    801056da <alltraps>

8010658f <vector246>:
.globl vector246
vector246:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $246
80106591:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106596:	e9 3f f1 ff ff       	jmp    801056da <alltraps>

8010659b <vector247>:
.globl vector247
vector247:
  pushl $0
8010659b:	6a 00                	push   $0x0
  pushl $247
8010659d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801065a2:	e9 33 f1 ff ff       	jmp    801056da <alltraps>

801065a7 <vector248>:
.globl vector248
vector248:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $248
801065a9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801065ae:	e9 27 f1 ff ff       	jmp    801056da <alltraps>

801065b3 <vector249>:
.globl vector249
vector249:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $249
801065b5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801065ba:	e9 1b f1 ff ff       	jmp    801056da <alltraps>

801065bf <vector250>:
.globl vector250
vector250:
  pushl $0
801065bf:	6a 00                	push   $0x0
  pushl $250
801065c1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801065c6:	e9 0f f1 ff ff       	jmp    801056da <alltraps>

801065cb <vector251>:
.globl vector251
vector251:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $251
801065cd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801065d2:	e9 03 f1 ff ff       	jmp    801056da <alltraps>

801065d7 <vector252>:
.globl vector252
vector252:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $252
801065d9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801065de:	e9 f7 f0 ff ff       	jmp    801056da <alltraps>

801065e3 <vector253>:
.globl vector253
vector253:
  pushl $0
801065e3:	6a 00                	push   $0x0
  pushl $253
801065e5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801065ea:	e9 eb f0 ff ff       	jmp    801056da <alltraps>

801065ef <vector254>:
.globl vector254
vector254:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $254
801065f1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801065f6:	e9 df f0 ff ff       	jmp    801056da <alltraps>

801065fb <vector255>:
.globl vector255
vector255:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $255
801065fd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106602:	e9 d3 f0 ff ff       	jmp    801056da <alltraps>
80106607:	66 90                	xchg   %ax,%ax
80106609:	66 90                	xchg   %ax,%ax
8010660b:	66 90                	xchg   %ax,%ax
8010660d:	66 90                	xchg   %ax,%ax
8010660f:	90                   	nop

80106610 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106610:	55                   	push   %ebp
80106611:	89 e5                	mov    %esp,%ebp
80106613:	57                   	push   %edi
80106614:	56                   	push   %esi
80106615:	53                   	push   %ebx
80106616:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106618:	c1 ea 16             	shr    $0x16,%edx
8010661b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010661e:	83 ec 0c             	sub    $0xc,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
80106621:	8b 07                	mov    (%edi),%eax
80106623:	a8 01                	test   $0x1,%al
80106625:	74 29                	je     80106650 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106627:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010662c:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}
80106632:	8d 65 f4             	lea    -0xc(%ebp),%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106635:	c1 eb 0a             	shr    $0xa,%ebx
80106638:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
8010663e:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
}
80106641:	5b                   	pop    %ebx
80106642:	5e                   	pop    %esi
80106643:	5f                   	pop    %edi
80106644:	5d                   	pop    %ebp
80106645:	c3                   	ret    
80106646:	8d 76 00             	lea    0x0(%esi),%esi
80106649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106650:	85 c9                	test   %ecx,%ecx
80106652:	74 2c                	je     80106680 <walkpgdir+0x70>
80106654:	e8 8e be ff ff       	call   801024e7 <kalloc>
80106659:	85 c0                	test   %eax,%eax
8010665b:	89 c6                	mov    %eax,%esi
8010665d:	74 21                	je     80106680 <walkpgdir+0x70>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010665f:	83 ec 04             	sub    $0x4,%esp
80106662:	68 00 10 00 00       	push   $0x1000
80106667:	6a 00                	push   $0x0
80106669:	50                   	push   %eax
8010666a:	e8 e1 dd ff ff       	call   80104450 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010666f:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106675:	83 c4 10             	add    $0x10,%esp
80106678:	83 c8 07             	or     $0x7,%eax
8010667b:	89 07                	mov    %eax,(%edi)
8010667d:	eb b3                	jmp    80106632 <walkpgdir+0x22>
8010667f:	90                   	nop
  }
  return &pgtab[PTX(va)];
}
80106680:	8d 65 f4             	lea    -0xc(%ebp),%esp
  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
80106683:	31 c0                	xor    %eax,%eax
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}
80106685:	5b                   	pop    %ebx
80106686:	5e                   	pop    %esi
80106687:	5f                   	pop    %edi
80106688:	5d                   	pop    %ebp
80106689:	c3                   	ret    
8010668a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106690 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	57                   	push   %edi
80106694:	56                   	push   %esi
80106695:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106696:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
8010669c:	89 c7                	mov    %eax,%edi
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
8010669e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
801066a4:	83 ec 1c             	sub    $0x1c,%esp
801066a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801066aa:	39 d3                	cmp    %edx,%ebx
801066ac:	73 66                	jae    80106714 <deallocuvm.part.0+0x84>
801066ae:	89 d6                	mov    %edx,%esi
801066b0:	eb 3d                	jmp    801066ef <deallocuvm.part.0+0x5f>
801066b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
801066b8:	8b 10                	mov    (%eax),%edx
801066ba:	f6 c2 01             	test   $0x1,%dl
801066bd:	74 26                	je     801066e5 <deallocuvm.part.0+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801066bf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801066c5:	74 58                	je     8010671f <deallocuvm.part.0+0x8f>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801066c7:	83 ec 0c             	sub    $0xc,%esp
801066ca:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801066d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801066d3:	52                   	push   %edx
801066d4:	e8 74 bd ff ff       	call   8010244d <kfree>
      *pte = 0;
801066d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066dc:	83 c4 10             	add    $0x10,%esp
801066df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801066e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801066eb:	39 f3                	cmp    %esi,%ebx
801066ed:	73 25                	jae    80106714 <deallocuvm.part.0+0x84>
    pte = walkpgdir(pgdir, (char*)a, 0);
801066ef:	31 c9                	xor    %ecx,%ecx
801066f1:	89 da                	mov    %ebx,%edx
801066f3:	89 f8                	mov    %edi,%eax
801066f5:	e8 16 ff ff ff       	call   80106610 <walkpgdir>
    if(!pte)
801066fa:	85 c0                	test   %eax,%eax
801066fc:	75 ba                	jne    801066b8 <deallocuvm.part.0+0x28>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801066fe:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
80106704:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010670a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106710:	39 f3                	cmp    %esi,%ebx
80106712:	72 db                	jb     801066ef <deallocuvm.part.0+0x5f>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106714:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106717:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010671a:	5b                   	pop    %ebx
8010671b:	5e                   	pop    %esi
8010671c:	5f                   	pop    %edi
8010671d:	5d                   	pop    %ebp
8010671e:	c3                   	ret    
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
8010671f:	83 ec 0c             	sub    $0xc,%esp
80106722:	68 d0 78 10 80       	push   $0x801078d0
80106727:	e8 44 9c ff ff       	call   80100370 <panic>
8010672c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106730 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106730:	55                   	push   %ebp
80106731:	89 e5                	mov    %esp,%ebp
80106733:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106736:	e8 65 d0 ff ff       	call   801037a0 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010673b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106741:	31 c9                	xor    %ecx,%ecx
80106743:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80106748:	66 89 90 f8 27 11 80 	mov    %dx,-0x7feed808(%eax)
8010674f:	66 89 88 fa 27 11 80 	mov    %cx,-0x7feed806(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106756:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010675b:	31 c9                	xor    %ecx,%ecx
8010675d:	66 89 90 00 28 11 80 	mov    %dx,-0x7feed800(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106764:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106769:	66 89 88 02 28 11 80 	mov    %cx,-0x7feed7fe(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106770:	31 c9                	xor    %ecx,%ecx
80106772:	66 89 90 08 28 11 80 	mov    %dx,-0x7feed7f8(%eax)
80106779:	66 89 88 0a 28 11 80 	mov    %cx,-0x7feed7f6(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106780:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80106785:	31 c9                	xor    %ecx,%ecx
80106787:	66 89 90 10 28 11 80 	mov    %dx,-0x7feed7f0(%eax)
  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010678e:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
80106795:	ba 2f 00 00 00       	mov    $0x2f,%edx
8010679a:	c6 80 fd 27 11 80 9a 	movb   $0x9a,-0x7feed803(%eax)
801067a1:	c6 80 fe 27 11 80 cf 	movb   $0xcf,-0x7feed802(%eax)
801067a8:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801067af:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
801067b6:	c6 80 05 28 11 80 92 	movb   $0x92,-0x7feed7fb(%eax)
801067bd:	c6 80 06 28 11 80 cf 	movb   $0xcf,-0x7feed7fa(%eax)
801067c4:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801067cb:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
801067d2:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
801067d9:	c6 80 0e 28 11 80 cf 	movb   $0xcf,-0x7feed7f2(%eax)
801067e0:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801067e7:	66 89 88 12 28 11 80 	mov    %cx,-0x7feed7ee(%eax)
801067ee:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
801067f5:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
801067fc:	c6 80 16 28 11 80 cf 	movb   $0xcf,-0x7feed7ea(%eax)
80106803:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010680a:	05 f0 27 11 80       	add    $0x801127f0,%eax
8010680f:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  pd[1] = (uint)p;
80106813:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106817:	c1 e8 10             	shr    $0x10,%eax
8010681a:	66 89 45 f6          	mov    %ax,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010681e:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106821:	0f 01 10             	lgdtl  (%eax)
}
80106824:	c9                   	leave  
80106825:	c3                   	ret    
80106826:	8d 76 00             	lea    0x0(%esi),%esi
80106829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106830 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106830:	55                   	push   %ebp
80106831:	89 e5                	mov    %esp,%ebp
80106833:	57                   	push   %edi
80106834:	56                   	push   %esi
80106835:	53                   	push   %ebx
80106836:	83 ec 1c             	sub    $0x1c,%esp
80106839:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010683c:	8b 55 10             	mov    0x10(%ebp),%edx
8010683f:	8b 7d 14             	mov    0x14(%ebp),%edi
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106842:	89 c3                	mov    %eax,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106844:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106848:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010684e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106853:	29 df                	sub    %ebx,%edi
80106855:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80106858:	8b 45 18             	mov    0x18(%ebp),%eax
8010685b:	83 c8 01             	or     $0x1,%eax
8010685e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106861:	eb 1a                	jmp    8010687d <mappages+0x4d>
80106863:	90                   	nop
80106864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80106868:	f6 00 01             	testb  $0x1,(%eax)
8010686b:	75 3d                	jne    801068aa <mappages+0x7a>
      panic("remap");
    *pte = pa | perm | PTE_P;
8010686d:	0b 75 e0             	or     -0x20(%ebp),%esi
    if(a == last)
80106870:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80106873:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106875:	74 29                	je     801068a0 <mappages+0x70>
      break;
    a += PGSIZE;
80106877:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010687d:	8b 45 08             	mov    0x8(%ebp),%eax
80106880:	b9 01 00 00 00       	mov    $0x1,%ecx
80106885:	89 da                	mov    %ebx,%edx
80106887:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
8010688a:	e8 81 fd ff ff       	call   80106610 <walkpgdir>
8010688f:	85 c0                	test   %eax,%eax
80106891:	75 d5                	jne    80106868 <mappages+0x38>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
80106893:	8d 65 f4             	lea    -0xc(%ebp),%esp

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
80106896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
8010689b:	5b                   	pop    %ebx
8010689c:	5e                   	pop    %esi
8010689d:	5f                   	pop    %edi
8010689e:	5d                   	pop    %ebp
8010689f:	c3                   	ret    
801068a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801068a3:	31 c0                	xor    %eax,%eax
}
801068a5:	5b                   	pop    %ebx
801068a6:	5e                   	pop    %esi
801068a7:	5f                   	pop    %edi
801068a8:	5d                   	pop    %ebp
801068a9:	c3                   	ret    
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
801068aa:	83 ec 0c             	sub    $0xc,%esp
801068ad:	68 d6 78 10 80       	push   $0x801078d6
801068b2:	e8 b9 9a ff ff       	call   80100370 <panic>
801068b7:	89 f6                	mov    %esi,%esi
801068b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801068c0 <switchkvm>:
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801068c0:	a1 a4 54 11 80       	mov    0x801154a4,%eax

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801068c5:	55                   	push   %ebp
801068c6:	89 e5                	mov    %esp,%ebp
801068c8:	05 00 00 00 80       	add    $0x80000000,%eax
801068cd:	0f 22 d8             	mov    %eax,%cr3
  lcr3(V2P(kpgdir));   // switch to the kernel page table
}
801068d0:	5d                   	pop    %ebp
801068d1:	c3                   	ret    
801068d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801068d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801068e0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801068e0:	55                   	push   %ebp
801068e1:	89 e5                	mov    %esp,%ebp
801068e3:	57                   	push   %edi
801068e4:	56                   	push   %esi
801068e5:	53                   	push   %ebx
801068e6:	83 ec 1c             	sub    $0x1c,%esp
801068e9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801068ec:	85 f6                	test   %esi,%esi
801068ee:	0f 84 cd 00 00 00    	je     801069c1 <switchuvm+0xe1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801068f4:	8b 46 08             	mov    0x8(%esi),%eax
801068f7:	85 c0                	test   %eax,%eax
801068f9:	0f 84 dc 00 00 00    	je     801069db <switchuvm+0xfb>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801068ff:	8b 7e 04             	mov    0x4(%esi),%edi
80106902:	85 ff                	test   %edi,%edi
80106904:	0f 84 c4 00 00 00    	je     801069ce <switchuvm+0xee>
    panic("switchuvm: no pgdir");

  pushcli();
8010690a:	e8 91 d9 ff ff       	call   801042a0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010690f:	e8 0c ce ff ff       	call   80103720 <mycpu>
80106914:	89 c3                	mov    %eax,%ebx
80106916:	e8 05 ce ff ff       	call   80103720 <mycpu>
8010691b:	89 c7                	mov    %eax,%edi
8010691d:	e8 fe cd ff ff       	call   80103720 <mycpu>
80106922:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106925:	83 c7 08             	add    $0x8,%edi
80106928:	e8 f3 cd ff ff       	call   80103720 <mycpu>
8010692d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106930:	83 c0 08             	add    $0x8,%eax
80106933:	ba 67 00 00 00       	mov    $0x67,%edx
80106938:	c1 e8 18             	shr    $0x18,%eax
8010693b:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
80106942:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106949:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
80106950:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106957:	83 c1 08             	add    $0x8,%ecx
8010695a:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106960:	c1 e9 10             	shr    $0x10,%ecx
80106963:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
  mycpu()->gdt[SEG_TSS].s = 0;
  mycpu()->ts.ss0 = SEG_KDATA << 3;
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106969:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
    panic("switchuvm: no pgdir");

  pushcli();
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010696e:	e8 ad cd ff ff       	call   80103720 <mycpu>
80106973:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010697a:	e8 a1 cd ff ff       	call   80103720 <mycpu>
8010697f:	b9 10 00 00 00       	mov    $0x10,%ecx
80106984:	66 89 48 10          	mov    %cx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106988:	e8 93 cd ff ff       	call   80103720 <mycpu>
8010698d:	8b 56 08             	mov    0x8(%esi),%edx
80106990:	8d 8a 00 10 00 00    	lea    0x1000(%edx),%ecx
80106996:	89 48 0c             	mov    %ecx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106999:	e8 82 cd ff ff       	call   80103720 <mycpu>
8010699e:	66 89 58 6e          	mov    %bx,0x6e(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
801069a2:	b8 28 00 00 00       	mov    $0x28,%eax
801069a7:	0f 00 d8             	ltr    %ax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801069aa:	8b 46 04             	mov    0x4(%esi),%eax
801069ad:	05 00 00 00 80       	add    $0x80000000,%eax
801069b2:	0f 22 d8             	mov    %eax,%cr3
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
}
801069b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801069b8:	5b                   	pop    %ebx
801069b9:	5e                   	pop    %esi
801069ba:	5f                   	pop    %edi
801069bb:	5d                   	pop    %ebp
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
801069bc:	e9 cf d9 ff ff       	jmp    80104390 <popcli>
// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
801069c1:	83 ec 0c             	sub    $0xc,%esp
801069c4:	68 dc 78 10 80       	push   $0x801078dc
801069c9:	e8 a2 99 ff ff       	call   80100370 <panic>
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
801069ce:	83 ec 0c             	sub    $0xc,%esp
801069d1:	68 07 79 10 80       	push   $0x80107907
801069d6:	e8 95 99 ff ff       	call   80100370 <panic>
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
801069db:	83 ec 0c             	sub    $0xc,%esp
801069de:	68 f2 78 10 80       	push   $0x801078f2
801069e3:	e8 88 99 ff ff       	call   80100370 <panic>
801069e8:	90                   	nop
801069e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801069f0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801069f0:	55                   	push   %ebp
801069f1:	89 e5                	mov    %esp,%ebp
801069f3:	57                   	push   %edi
801069f4:	56                   	push   %esi
801069f5:	53                   	push   %ebx
801069f6:	83 ec 1c             	sub    $0x1c,%esp
801069f9:	8b 75 10             	mov    0x10(%ebp),%esi
801069fc:	8b 55 08             	mov    0x8(%ebp),%edx
801069ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *mem;

  if(sz >= PGSIZE)
80106a02:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106a08:	77 50                	ja     80106a5a <inituvm+0x6a>
80106a0a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    panic("inituvm: more than a page");
  mem = kalloc();
80106a0d:	e8 d5 ba ff ff       	call   801024e7 <kalloc>
  memset(mem, 0, PGSIZE);
80106a12:	83 ec 04             	sub    $0x4,%esp
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
80106a15:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106a17:	68 00 10 00 00       	push   $0x1000
80106a1c:	6a 00                	push   $0x0
80106a1e:	50                   	push   %eax
80106a1f:	e8 2c da ff ff       	call   80104450 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106a24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a27:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106a2d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106a34:	50                   	push   %eax
80106a35:	68 00 10 00 00       	push   $0x1000
80106a3a:	6a 00                	push   $0x0
80106a3c:	52                   	push   %edx
80106a3d:	e8 ee fd ff ff       	call   80106830 <mappages>
  memmove(mem, init, sz);
80106a42:	89 75 10             	mov    %esi,0x10(%ebp)
80106a45:	89 7d 0c             	mov    %edi,0xc(%ebp)
80106a48:	83 c4 20             	add    $0x20,%esp
80106a4b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80106a4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a51:	5b                   	pop    %ebx
80106a52:	5e                   	pop    %esi
80106a53:	5f                   	pop    %edi
80106a54:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
80106a55:	e9 a6 da ff ff       	jmp    80104500 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
80106a5a:	83 ec 0c             	sub    $0xc,%esp
80106a5d:	68 1b 79 10 80       	push   $0x8010791b
80106a62:	e8 09 99 ff ff       	call   80100370 <panic>
80106a67:	89 f6                	mov    %esi,%esi
80106a69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106a70 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106a70:	55                   	push   %ebp
80106a71:	89 e5                	mov    %esp,%ebp
80106a73:	57                   	push   %edi
80106a74:	56                   	push   %esi
80106a75:	53                   	push   %ebx
80106a76:	83 ec 0c             	sub    $0xc,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106a79:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106a80:	0f 85 91 00 00 00    	jne    80106b17 <loaduvm+0xa7>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106a86:	8b 75 18             	mov    0x18(%ebp),%esi
80106a89:	31 db                	xor    %ebx,%ebx
80106a8b:	85 f6                	test   %esi,%esi
80106a8d:	75 1a                	jne    80106aa9 <loaduvm+0x39>
80106a8f:	eb 6f                	jmp    80106b00 <loaduvm+0x90>
80106a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106a98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106a9e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80106aa4:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80106aa7:	76 57                	jbe    80106b00 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
80106aac:	8b 45 08             	mov    0x8(%ebp),%eax
80106aaf:	31 c9                	xor    %ecx,%ecx
80106ab1:	01 da                	add    %ebx,%edx
80106ab3:	e8 58 fb ff ff       	call   80106610 <walkpgdir>
80106ab8:	85 c0                	test   %eax,%eax
80106aba:	74 4e                	je     80106b0a <loaduvm+0x9a>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
80106abc:	8b 00                	mov    (%eax),%eax
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106abe:	8b 4d 14             	mov    0x14(%ebp),%ecx
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
80106ac1:	bf 00 10 00 00       	mov    $0x1000,%edi
  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
80106ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106acb:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106ad1:	0f 46 fe             	cmovbe %esi,%edi
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106ad4:	01 d9                	add    %ebx,%ecx
80106ad6:	05 00 00 00 80       	add    $0x80000000,%eax
80106adb:	57                   	push   %edi
80106adc:	51                   	push   %ecx
80106add:	50                   	push   %eax
80106ade:	ff 75 10             	pushl  0x10(%ebp)
80106ae1:	e8 4a af ff ff       	call   80101a30 <readi>
80106ae6:	83 c4 10             	add    $0x10,%esp
80106ae9:	39 c7                	cmp    %eax,%edi
80106aeb:	74 ab                	je     80106a98 <loaduvm+0x28>
      return -1;
  }
  return 0;
}
80106aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
80106af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106af5:	5b                   	pop    %ebx
80106af6:	5e                   	pop    %esi
80106af7:	5f                   	pop    %edi
80106af8:	5d                   	pop    %ebp
80106af9:	c3                   	ret    
80106afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80106b03:	31 c0                	xor    %eax,%eax
}
80106b05:	5b                   	pop    %ebx
80106b06:	5e                   	pop    %esi
80106b07:	5f                   	pop    %edi
80106b08:	5d                   	pop    %ebp
80106b09:	c3                   	ret    

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106b0a:	83 ec 0c             	sub    $0xc,%esp
80106b0d:	68 35 79 10 80       	push   $0x80107935
80106b12:	e8 59 98 ff ff       	call   80100370 <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
80106b17:	83 ec 0c             	sub    $0xc,%esp
80106b1a:	68 d8 79 10 80       	push   $0x801079d8
80106b1f:	e8 4c 98 ff ff       	call   80100370 <panic>
80106b24:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106b2a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106b30 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106b30:	55                   	push   %ebp
80106b31:	89 e5                	mov    %esp,%ebp
80106b33:	57                   	push   %edi
80106b34:	56                   	push   %esi
80106b35:	53                   	push   %ebx
80106b36:	83 ec 0c             	sub    $0xc,%esp
80106b39:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80106b3c:	85 ff                	test   %edi,%edi
80106b3e:	0f 88 ca 00 00 00    	js     80106c0e <allocuvm+0xde>
    return 0;
  if(newsz < oldsz)
80106b44:	3b 7d 0c             	cmp    0xc(%ebp),%edi
    return oldsz;
80106b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
80106b4a:	0f 82 84 00 00 00    	jb     80106bd4 <allocuvm+0xa4>
    return oldsz;

  a = PGROUNDUP(oldsz);
80106b50:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106b56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106b5c:	39 df                	cmp    %ebx,%edi
80106b5e:	77 45                	ja     80106ba5 <allocuvm+0x75>
80106b60:	e9 bb 00 00 00       	jmp    80106c20 <allocuvm+0xf0>
80106b65:	8d 76 00             	lea    0x0(%esi),%esi
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
80106b68:	83 ec 04             	sub    $0x4,%esp
80106b6b:	68 00 10 00 00       	push   $0x1000
80106b70:	6a 00                	push   $0x0
80106b72:	50                   	push   %eax
80106b73:	e8 d8 d8 ff ff       	call   80104450 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106b78:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106b7e:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106b85:	50                   	push   %eax
80106b86:	68 00 10 00 00       	push   $0x1000
80106b8b:	53                   	push   %ebx
80106b8c:	ff 75 08             	pushl  0x8(%ebp)
80106b8f:	e8 9c fc ff ff       	call   80106830 <mappages>
80106b94:	83 c4 20             	add    $0x20,%esp
80106b97:	85 c0                	test   %eax,%eax
80106b99:	78 45                	js     80106be0 <allocuvm+0xb0>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80106b9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106ba1:	39 df                	cmp    %ebx,%edi
80106ba3:	76 7b                	jbe    80106c20 <allocuvm+0xf0>
    mem = kalloc();
80106ba5:	e8 3d b9 ff ff       	call   801024e7 <kalloc>
    if(mem == 0){
80106baa:	85 c0                	test   %eax,%eax
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
80106bac:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106bae:	75 b8                	jne    80106b68 <allocuvm+0x38>
      cprintf("allocuvm out of memory\n");
80106bb0:	83 ec 0c             	sub    $0xc,%esp
80106bb3:	68 53 79 10 80       	push   $0x80107953
80106bb8:	e8 a3 9a ff ff       	call   80100660 <cprintf>
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106bbd:	83 c4 10             	add    $0x10,%esp
80106bc0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106bc3:	76 49                	jbe    80106c0e <allocuvm+0xde>
80106bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106bcb:	89 fa                	mov    %edi,%edx
80106bcd:	e8 be fa ff ff       	call   80106690 <deallocuvm.part.0>
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
80106bd2:	31 c0                	xor    %eax,%eax
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
80106bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bd7:	5b                   	pop    %ebx
80106bd8:	5e                   	pop    %esi
80106bd9:	5f                   	pop    %edi
80106bda:	5d                   	pop    %ebp
80106bdb:	c3                   	ret    
80106bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
80106be0:	83 ec 0c             	sub    $0xc,%esp
80106be3:	68 6b 79 10 80       	push   $0x8010796b
80106be8:	e8 73 9a ff ff       	call   80100660 <cprintf>
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106bed:	83 c4 10             	add    $0x10,%esp
80106bf0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106bf3:	76 0d                	jbe    80106c02 <allocuvm+0xd2>
80106bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfb:	89 fa                	mov    %edi,%edx
80106bfd:	e8 8e fa ff ff       	call   80106690 <deallocuvm.part.0>
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
80106c02:	83 ec 0c             	sub    $0xc,%esp
80106c05:	56                   	push   %esi
80106c06:	e8 42 b8 ff ff       	call   8010244d <kfree>
      return 0;
80106c0b:	83 c4 10             	add    $0x10,%esp
    }
  }
  return newsz;
}
80106c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
80106c11:	31 c0                	xor    %eax,%eax
    }
  }
  return newsz;
}
80106c13:	5b                   	pop    %ebx
80106c14:	5e                   	pop    %esi
80106c15:	5f                   	pop    %edi
80106c16:	5d                   	pop    %ebp
80106c17:	c3                   	ret    
80106c18:	90                   	nop
80106c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80106c23:	89 f8                	mov    %edi,%eax
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
80106c25:	5b                   	pop    %ebx
80106c26:	5e                   	pop    %esi
80106c27:	5f                   	pop    %edi
80106c28:	5d                   	pop    %ebp
80106c29:	c3                   	ret    
80106c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106c30 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
80106c33:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c36:	8b 4d 10             	mov    0x10(%ebp),%ecx
80106c39:	8b 45 08             	mov    0x8(%ebp),%eax
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106c3c:	39 d1                	cmp    %edx,%ecx
80106c3e:	73 10                	jae    80106c50 <deallocuvm+0x20>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106c40:	5d                   	pop    %ebp
80106c41:	e9 4a fa ff ff       	jmp    80106690 <deallocuvm.part.0>
80106c46:	8d 76 00             	lea    0x0(%esi),%esi
80106c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106c50:	89 d0                	mov    %edx,%eax
80106c52:	5d                   	pop    %ebp
80106c53:	c3                   	ret    
80106c54:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106c5a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106c60 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106c60:	55                   	push   %ebp
80106c61:	89 e5                	mov    %esp,%ebp
80106c63:	57                   	push   %edi
80106c64:	56                   	push   %esi
80106c65:	53                   	push   %ebx
80106c66:	83 ec 0c             	sub    $0xc,%esp
80106c69:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106c6c:	85 f6                	test   %esi,%esi
80106c6e:	74 59                	je     80106cc9 <freevm+0x69>
80106c70:	31 c9                	xor    %ecx,%ecx
80106c72:	ba 00 00 00 80       	mov    $0x80000000,%edx
80106c77:	89 f0                	mov    %esi,%eax
80106c79:	e8 12 fa ff ff       	call   80106690 <deallocuvm.part.0>
80106c7e:	89 f3                	mov    %esi,%ebx
80106c80:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80106c86:	eb 0f                	jmp    80106c97 <freevm+0x37>
80106c88:	90                   	nop
80106c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c90:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80106c93:	39 fb                	cmp    %edi,%ebx
80106c95:	74 23                	je     80106cba <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80106c97:	8b 03                	mov    (%ebx),%eax
80106c99:	a8 01                	test   $0x1,%al
80106c9b:	74 f3                	je     80106c90 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106c9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106ca2:	83 ec 0c             	sub    $0xc,%esp
80106ca5:	83 c3 04             	add    $0x4,%ebx
80106ca8:	05 00 00 00 80       	add    $0x80000000,%eax
80106cad:	50                   	push   %eax
80106cae:	e8 9a b7 ff ff       	call   8010244d <kfree>
80106cb3:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80106cb6:	39 fb                	cmp    %edi,%ebx
80106cb8:	75 dd                	jne    80106c97 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80106cba:	89 75 08             	mov    %esi,0x8(%ebp)
}
80106cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cc0:	5b                   	pop    %ebx
80106cc1:	5e                   	pop    %esi
80106cc2:	5f                   	pop    %edi
80106cc3:	5d                   	pop    %ebp
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80106cc4:	e9 84 b7 ff ff       	jmp    8010244d <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
80106cc9:	83 ec 0c             	sub    $0xc,%esp
80106ccc:	68 87 79 10 80       	push   $0x80107987
80106cd1:	e8 9a 96 ff ff       	call   80100370 <panic>
80106cd6:	8d 76 00             	lea    0x0(%esi),%esi
80106cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106ce0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80106ce0:	55                   	push   %ebp
80106ce1:	89 e5                	mov    %esp,%ebp
80106ce3:	56                   	push   %esi
80106ce4:	53                   	push   %ebx
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80106ce5:	e8 fd b7 ff ff       	call   801024e7 <kalloc>
80106cea:	85 c0                	test   %eax,%eax
80106cec:	74 6a                	je     80106d58 <setupkvm+0x78>
    return 0;
  memset(pgdir, 0, PGSIZE);
80106cee:	83 ec 04             	sub    $0x4,%esp
80106cf1:	89 c6                	mov    %eax,%esi
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106cf3:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
80106cf8:	68 00 10 00 00       	push   $0x1000
80106cfd:	6a 00                	push   $0x0
80106cff:	50                   	push   %eax
80106d00:	e8 4b d7 ff ff       	call   80104450 <memset>
80106d05:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106d08:	8b 43 04             	mov    0x4(%ebx),%eax
80106d0b:	8b 53 08             	mov    0x8(%ebx),%edx
80106d0e:	83 ec 0c             	sub    $0xc,%esp
80106d11:	ff 73 0c             	pushl  0xc(%ebx)
80106d14:	29 c2                	sub    %eax,%edx
80106d16:	50                   	push   %eax
80106d17:	52                   	push   %edx
80106d18:	ff 33                	pushl  (%ebx)
80106d1a:	56                   	push   %esi
80106d1b:	e8 10 fb ff ff       	call   80106830 <mappages>
80106d20:	83 c4 20             	add    $0x20,%esp
80106d23:	85 c0                	test   %eax,%eax
80106d25:	78 19                	js     80106d40 <setupkvm+0x60>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106d27:	83 c3 10             	add    $0x10,%ebx
80106d2a:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106d30:	75 d6                	jne    80106d08 <setupkvm+0x28>
80106d32:	89 f0                	mov    %esi,%eax
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
}
80106d34:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106d37:	5b                   	pop    %ebx
80106d38:	5e                   	pop    %esi
80106d39:	5d                   	pop    %ebp
80106d3a:	c3                   	ret    
80106d3b:	90                   	nop
80106d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80106d40:	83 ec 0c             	sub    $0xc,%esp
80106d43:	56                   	push   %esi
80106d44:	e8 17 ff ff ff       	call   80106c60 <freevm>
      return 0;
80106d49:	83 c4 10             	add    $0x10,%esp
    }
  return pgdir;
}
80106d4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
80106d4f:	31 c0                	xor    %eax,%eax
    }
  return pgdir;
}
80106d51:	5b                   	pop    %ebx
80106d52:	5e                   	pop    %esi
80106d53:	5d                   	pop    %ebp
80106d54:	c3                   	ret    
80106d55:	8d 76 00             	lea    0x0(%esi),%esi
{
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
80106d58:	31 c0                	xor    %eax,%eax
80106d5a:	eb d8                	jmp    80106d34 <setupkvm+0x54>
80106d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106d60 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80106d60:	55                   	push   %ebp
80106d61:	89 e5                	mov    %esp,%ebp
80106d63:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106d66:	e8 75 ff ff ff       	call   80106ce0 <setupkvm>
80106d6b:	a3 a4 54 11 80       	mov    %eax,0x801154a4
80106d70:	05 00 00 00 80       	add    $0x80000000,%eax
80106d75:	0f 22 d8             	mov    %eax,%cr3
  switchkvm();
}
80106d78:	c9                   	leave  
80106d79:	c3                   	ret    
80106d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106d80 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106d80:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106d81:	31 c9                	xor    %ecx,%ecx

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106d83:	89 e5                	mov    %esp,%ebp
80106d85:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106d88:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8e:	e8 7d f8 ff ff       	call   80106610 <walkpgdir>
  if(pte == 0)
80106d93:	85 c0                	test   %eax,%eax
80106d95:	74 05                	je     80106d9c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106d97:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106d9a:	c9                   	leave  
80106d9b:	c3                   	ret    
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80106d9c:	83 ec 0c             	sub    $0xc,%esp
80106d9f:	68 98 79 10 80       	push   $0x80107998
80106da4:	e8 c7 95 ff ff       	call   80100370 <panic>
80106da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106db0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106db0:	55                   	push   %ebp
80106db1:	89 e5                	mov    %esp,%ebp
80106db3:	57                   	push   %edi
80106db4:	56                   	push   %esi
80106db5:	53                   	push   %ebx
80106db6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106db9:	e8 22 ff ff ff       	call   80106ce0 <setupkvm>
80106dbe:	85 c0                	test   %eax,%eax
80106dc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106dc3:	0f 84 b2 00 00 00    	je     80106e7b <copyuvm+0xcb>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
80106dcc:	85 d2                	test   %edx,%edx
80106dce:	0f 84 9c 00 00 00    	je     80106e70 <copyuvm+0xc0>
80106dd4:	31 f6                	xor    %esi,%esi
80106dd6:	eb 48                	jmp    80106e20 <copyuvm+0x70>
80106dd8:	90                   	nop
80106dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106de0:	83 ec 04             	sub    $0x4,%esp
80106de3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106de9:	68 00 10 00 00       	push   $0x1000
80106dee:	57                   	push   %edi
80106def:	50                   	push   %eax
80106df0:	e8 0b d7 ff ff       	call   80104500 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80106df5:	58                   	pop    %eax
80106df6:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
80106dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
80106dff:	52                   	push   %edx
80106e00:	68 00 10 00 00       	push   $0x1000
80106e05:	56                   	push   %esi
80106e06:	ff 75 e0             	pushl  -0x20(%ebp)
80106e09:	e8 22 fa ff ff       	call   80106830 <mappages>
80106e0e:	83 c4 20             	add    $0x20,%esp
80106e11:	85 c0                	test   %eax,%eax
80106e13:	78 3e                	js     80106e53 <copyuvm+0xa3>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106e15:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106e1b:	39 75 0c             	cmp    %esi,0xc(%ebp)
80106e1e:	76 50                	jbe    80106e70 <copyuvm+0xc0>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106e20:	8b 45 08             	mov    0x8(%ebp),%eax
80106e23:	31 c9                	xor    %ecx,%ecx
80106e25:	89 f2                	mov    %esi,%edx
80106e27:	e8 e4 f7 ff ff       	call   80106610 <walkpgdir>
80106e2c:	85 c0                	test   %eax,%eax
80106e2e:	74 5c                	je     80106e8c <copyuvm+0xdc>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106e30:	8b 18                	mov    (%eax),%ebx
80106e32:	f6 c3 01             	test   $0x1,%bl
80106e35:	74 48                	je     80106e7f <copyuvm+0xcf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106e37:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
80106e39:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
80106e3f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106e42:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
80106e48:	e8 9a b6 ff ff       	call   801024e7 <kalloc>
80106e4d:	85 c0                	test   %eax,%eax
80106e4f:	89 c3                	mov    %eax,%ebx
80106e51:	75 8d                	jne    80106de0 <copyuvm+0x30>
      goto bad;
  }
  return d;

bad:
  freevm(d);
80106e53:	83 ec 0c             	sub    $0xc,%esp
80106e56:	ff 75 e0             	pushl  -0x20(%ebp)
80106e59:	e8 02 fe ff ff       	call   80106c60 <freevm>
  return 0;
80106e5e:	83 c4 10             	add    $0x10,%esp
80106e61:	31 c0                	xor    %eax,%eax
}
80106e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e66:	5b                   	pop    %ebx
80106e67:	5e                   	pop    %esi
80106e68:	5f                   	pop    %edi
80106e69:	5d                   	pop    %ebp
80106e6a:	c3                   	ret    
80106e6b:	90                   	nop
80106e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106e70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  return d;

bad:
  freevm(d);
  return 0;
}
80106e73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e76:	5b                   	pop    %ebx
80106e77:	5e                   	pop    %esi
80106e78:	5f                   	pop    %edi
80106e79:	5d                   	pop    %ebp
80106e7a:	c3                   	ret    
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
80106e7b:	31 c0                	xor    %eax,%eax
80106e7d:	eb e4                	jmp    80106e63 <copyuvm+0xb3>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106e7f:	83 ec 0c             	sub    $0xc,%esp
80106e82:	68 bc 79 10 80       	push   $0x801079bc
80106e87:	e8 e4 94 ff ff       	call   80100370 <panic>

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106e8c:	83 ec 0c             	sub    $0xc,%esp
80106e8f:	68 a2 79 10 80       	push   $0x801079a2
80106e94:	e8 d7 94 ff ff       	call   80100370 <panic>
80106e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106ea0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106ea0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ea1:	31 c9                	xor    %ecx,%ecx

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106ea3:	89 e5                	mov    %esp,%ebp
80106ea5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
80106eab:	8b 45 08             	mov    0x8(%ebp),%eax
80106eae:	e8 5d f7 ff ff       	call   80106610 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106eb3:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
80106eb5:	89 c2                	mov    %eax,%edx
80106eb7:	83 e2 05             	and    $0x5,%edx
80106eba:	83 fa 05             	cmp    $0x5,%edx
80106ebd:	75 11                	jne    80106ed0 <uva2ka+0x30>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106ebf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
80106ec4:	c9                   	leave  
  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106ec5:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106eca:	c3                   	ret    
80106ecb:	90                   	nop
80106ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
80106ed0:	31 c0                	xor    %eax,%eax
  return (char*)P2V(PTE_ADDR(*pte));
}
80106ed2:	c9                   	leave  
80106ed3:	c3                   	ret    
80106ed4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106eda:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106ee0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106ee0:	55                   	push   %ebp
80106ee1:	89 e5                	mov    %esp,%ebp
80106ee3:	57                   	push   %edi
80106ee4:	56                   	push   %esi
80106ee5:	53                   	push   %ebx
80106ee6:	83 ec 1c             	sub    $0x1c,%esp
80106ee9:	8b 5d 14             	mov    0x14(%ebp),%ebx
80106eec:	8b 55 0c             	mov    0xc(%ebp),%edx
80106eef:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106ef2:	85 db                	test   %ebx,%ebx
80106ef4:	75 40                	jne    80106f36 <copyout+0x56>
80106ef6:	eb 70                	jmp    80106f68 <copyout+0x88>
80106ef8:	90                   	nop
80106ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80106f00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106f03:	89 f1                	mov    %esi,%ecx
80106f05:	29 d1                	sub    %edx,%ecx
80106f07:	81 c1 00 10 00 00    	add    $0x1000,%ecx
80106f0d:	39 d9                	cmp    %ebx,%ecx
80106f0f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106f12:	29 f2                	sub    %esi,%edx
80106f14:	83 ec 04             	sub    $0x4,%esp
80106f17:	01 d0                	add    %edx,%eax
80106f19:	51                   	push   %ecx
80106f1a:	57                   	push   %edi
80106f1b:	50                   	push   %eax
80106f1c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80106f1f:	e8 dc d5 ff ff       	call   80104500 <memmove>
    len -= n;
    buf += n;
80106f24:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106f27:	83 c4 10             	add    $0x10,%esp
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
80106f2a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
80106f30:	01 cf                	add    %ecx,%edi
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106f32:	29 cb                	sub    %ecx,%ebx
80106f34:	74 32                	je     80106f68 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80106f36:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106f38:	83 ec 08             	sub    $0x8,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
80106f3b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80106f3e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106f44:	56                   	push   %esi
80106f45:	ff 75 08             	pushl  0x8(%ebp)
80106f48:	e8 53 ff ff ff       	call   80106ea0 <uva2ka>
    if(pa0 == 0)
80106f4d:	83 c4 10             	add    $0x10,%esp
80106f50:	85 c0                	test   %eax,%eax
80106f52:	75 ac                	jne    80106f00 <copyout+0x20>
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
80106f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  buf = (char*)p;
  while(len > 0){
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
80106f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
80106f5c:	5b                   	pop    %ebx
80106f5d:	5e                   	pop    %esi
80106f5e:	5f                   	pop    %edi
80106f5f:	5d                   	pop    %ebp
80106f60:	c3                   	ret    
80106f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80106f6b:	31 c0                	xor    %eax,%eax
}
80106f6d:	5b                   	pop    %ebx
80106f6e:	5e                   	pop    %esi
80106f6f:	5f                   	pop    %edi
80106f70:	5d                   	pop    %ebp
80106f71:	c3                   	ret    
80106f72:	66 90                	xchg   %ax,%ax
80106f74:	66 90                	xchg   %ax,%ax
80106f76:	66 90                	xchg   %ax,%ax
80106f78:	66 90                	xchg   %ax,%ax
80106f7a:	66 90                	xchg   %ax,%ax
80106f7c:	66 90                	xchg   %ax,%ax
80106f7e:	66 90                	xchg   %ax,%ax

80106f80 <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
80106f80:	55                   	push   %ebp
80106f81:	89 e5                	mov    %esp,%ebp
80106f83:	83 ec 10             	sub    $0x10,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
80106f86:	68 fc 79 10 80       	push   $0x801079fc
80106f8b:	68 c0 54 11 80       	push   $0x801154c0
80106f90:	e8 4b d2 ff ff       	call   801041e0 <initlock>
  acquire(&(shm_table.lock));
80106f95:	c7 04 24 c0 54 11 80 	movl   $0x801154c0,(%esp)
80106f9c:	e8 3f d3 ff ff       	call   801042e0 <acquire>
80106fa1:	b8 f4 54 11 80       	mov    $0x801154f4,%eax
80106fa6:	83 c4 10             	add    $0x10,%esp
80106fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for (i = 0; i< 64; i++) {
    shm_table.shm_pages[i].id =0;
80106fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80106fb6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
80106fbd:	83 c0 0c             	add    $0xc,%eax
    shm_table.shm_pages[i].refcnt =0;
80106fc0:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
80106fc7:	3d f4 57 11 80       	cmp    $0x801157f4,%eax
80106fcc:	75 e2                	jne    80106fb0 <shminit+0x30>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
80106fce:	83 ec 0c             	sub    $0xc,%esp
80106fd1:	68 c0 54 11 80       	push   $0x801154c0
80106fd6:	e8 25 d4 ff ff       	call   80104400 <release>
}
80106fdb:	83 c4 10             	add    $0x10,%esp
80106fde:	c9                   	leave  
80106fdf:	c3                   	ret    

80106fe0 <shm_open>:

int shm_open(int id, char **pointer) {
80106fe0:	55                   	push   %ebp




return 0; //added to remove compiler warning -- you should decide what to return
}
80106fe1:	31 c0                	xor    %eax,%eax
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
}

int shm_open(int id, char **pointer) {
80106fe3:	89 e5                	mov    %esp,%ebp




return 0; //added to remove compiler warning -- you should decide what to return
}
80106fe5:	5d                   	pop    %ebp
80106fe6:	c3                   	ret    
80106fe7:	89 f6                	mov    %esi,%esi
80106fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106ff0 <shm_close>:


int shm_close(int id) {
80106ff0:	55                   	push   %ebp




return 0; //added to remove compiler warning -- you should decide what to return
}
80106ff1:	31 c0                	xor    %eax,%eax

return 0; //added to remove compiler warning -- you should decide what to return
}


int shm_close(int id) {
80106ff3:	89 e5                	mov    %esp,%ebp




return 0; //added to remove compiler warning -- you should decide what to return
}
80106ff5:	5d                   	pop    %ebp
80106ff6:	c3                   	ret    
