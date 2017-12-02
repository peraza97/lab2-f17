
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 30 c6 10 80       	mov    $0x8010c630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 4a 38 10 80       	mov    $0x8010384a,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 94 85 10 80       	push   $0x80108594
80100042:	68 40 c6 10 80       	push   $0x8010c640
80100047:	e8 e4 4e 00 00       	call   80104f30 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 8c 0d 11 80 3c 	movl   $0x80110d3c,0x80110d8c
80100056:	0d 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 90 0d 11 80 3c 	movl   $0x80110d3c,0x80110d90
80100060:	0d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 74 c6 10 80 	movl   $0x8010c674,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 9b 85 10 80       	push   $0x8010859b
80100090:	50                   	push   %eax
80100091:	e8 3d 4d 00 00       	call   80104dd3 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 90 0d 11 80       	mov    0x80110d90,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 90 0d 11 80       	mov    %eax,0x80110d90

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 3c 0d 11 80       	mov    $0x80110d3c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000bd:	90                   	nop
801000be:	c9                   	leave  
801000bf:	c3                   	ret    

801000c0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c0:	55                   	push   %ebp
801000c1:	89 e5                	mov    %esp,%ebp
801000c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c6:	83 ec 0c             	sub    $0xc,%esp
801000c9:	68 40 c6 10 80       	push   $0x8010c640
801000ce:	e8 7f 4e 00 00       	call   80104f52 <acquire>
801000d3:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d6:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801000db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000de:	eb 58                	jmp    80100138 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e3:	8b 40 04             	mov    0x4(%eax),%eax
801000e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e9:	75 44                	jne    8010012f <bget+0x6f>
801000eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ee:	8b 40 08             	mov    0x8(%eax),%eax
801000f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000f4:	75 39                	jne    8010012f <bget+0x6f>
      b->refcnt++;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fc:	8d 50 01             	lea    0x1(%eax),%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 40 c6 10 80       	push   $0x8010c640
8010010d:	e8 ae 4e 00 00       	call   80104fc0 <release>
80100112:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	83 c0 0c             	add    $0xc,%eax
8010011b:	83 ec 0c             	sub    $0xc,%esp
8010011e:	50                   	push   %eax
8010011f:	e8 eb 4c 00 00       	call   80104e0f <acquiresleep>
80100124:	83 c4 10             	add    $0x10,%esp
      return b;
80100127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012a:	e9 9d 00 00 00       	jmp    801001cc <bget+0x10c>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100132:	8b 40 54             	mov    0x54(%eax),%eax
80100135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100138:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
8010013f:	75 9f                	jne    801000e0 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 8c 0d 11 80       	mov    0x80110d8c,%eax
80100146:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100149:	eb 6b                	jmp    801001b6 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100151:	85 c0                	test   %eax,%eax
80100153:	75 58                	jne    801001ad <bget+0xed>
80100155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100158:	8b 00                	mov    (%eax),%eax
8010015a:	83 e0 04             	and    $0x4,%eax
8010015d:	85 c0                	test   %eax,%eax
8010015f:	75 4c                	jne    801001ad <bget+0xed>
      b->dev = dev;
80100161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100164:	8b 55 08             	mov    0x8(%ebp),%edx
80100167:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100170:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100186:	83 ec 0c             	sub    $0xc,%esp
80100189:	68 40 c6 10 80       	push   $0x8010c640
8010018e:	e8 2d 4e 00 00       	call   80104fc0 <release>
80100193:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	83 c0 0c             	add    $0xc,%eax
8010019c:	83 ec 0c             	sub    $0xc,%esp
8010019f:	50                   	push   %eax
801001a0:	e8 6a 4c 00 00       	call   80104e0f <acquiresleep>
801001a5:	83 c4 10             	add    $0x10,%esp
      return b;
801001a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ab:	eb 1f                	jmp    801001cc <bget+0x10c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b0:	8b 40 50             	mov    0x50(%eax),%eax
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	81 7d f4 3c 0d 11 80 	cmpl   $0x80110d3c,-0xc(%ebp)
801001bd:	75 8c                	jne    8010014b <bget+0x8b>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001bf:	83 ec 0c             	sub    $0xc,%esp
801001c2:	68 a2 85 10 80       	push   $0x801085a2
801001c7:	e8 d4 03 00 00       	call   801005a0 <panic>
}
801001cc:	c9                   	leave  
801001cd:	c3                   	ret    

801001ce <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001ce:	55                   	push   %ebp
801001cf:	89 e5                	mov    %esp,%ebp
801001d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d4:	83 ec 08             	sub    $0x8,%esp
801001d7:	ff 75 0c             	pushl  0xc(%ebp)
801001da:	ff 75 08             	pushl  0x8(%ebp)
801001dd:	e8 de fe ff ff       	call   801000c0 <bget>
801001e2:	83 c4 10             	add    $0x10,%esp
801001e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 00                	mov    (%eax),%eax
801001ed:	83 e0 02             	and    $0x2,%eax
801001f0:	85 c0                	test   %eax,%eax
801001f2:	75 0e                	jne    80100202 <bread+0x34>
    iderw(b);
801001f4:	83 ec 0c             	sub    $0xc,%esp
801001f7:	ff 75 f4             	pushl  -0xc(%ebp)
801001fa:	e8 4a 27 00 00       	call   80102949 <iderw>
801001ff:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100202:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100205:	c9                   	leave  
80100206:	c3                   	ret    

80100207 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100207:	55                   	push   %ebp
80100208:	89 e5                	mov    %esp,%ebp
8010020a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020d:	8b 45 08             	mov    0x8(%ebp),%eax
80100210:	83 c0 0c             	add    $0xc,%eax
80100213:	83 ec 0c             	sub    $0xc,%esp
80100216:	50                   	push   %eax
80100217:	e8 a5 4c 00 00       	call   80104ec1 <holdingsleep>
8010021c:	83 c4 10             	add    $0x10,%esp
8010021f:	85 c0                	test   %eax,%eax
80100221:	75 0d                	jne    80100230 <bwrite+0x29>
    panic("bwrite");
80100223:	83 ec 0c             	sub    $0xc,%esp
80100226:	68 b3 85 10 80       	push   $0x801085b3
8010022b:	e8 70 03 00 00       	call   801005a0 <panic>
  b->flags |= B_DIRTY;
80100230:	8b 45 08             	mov    0x8(%ebp),%eax
80100233:	8b 00                	mov    (%eax),%eax
80100235:	83 c8 04             	or     $0x4,%eax
80100238:	89 c2                	mov    %eax,%edx
8010023a:	8b 45 08             	mov    0x8(%ebp),%eax
8010023d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010023f:	83 ec 0c             	sub    $0xc,%esp
80100242:	ff 75 08             	pushl  0x8(%ebp)
80100245:	e8 ff 26 00 00       	call   80102949 <iderw>
8010024a:	83 c4 10             	add    $0x10,%esp
}
8010024d:	90                   	nop
8010024e:	c9                   	leave  
8010024f:	c3                   	ret    

80100250 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100250:	55                   	push   %ebp
80100251:	89 e5                	mov    %esp,%ebp
80100253:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100256:	8b 45 08             	mov    0x8(%ebp),%eax
80100259:	83 c0 0c             	add    $0xc,%eax
8010025c:	83 ec 0c             	sub    $0xc,%esp
8010025f:	50                   	push   %eax
80100260:	e8 5c 4c 00 00       	call   80104ec1 <holdingsleep>
80100265:	83 c4 10             	add    $0x10,%esp
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 0d                	jne    80100279 <brelse+0x29>
    panic("brelse");
8010026c:	83 ec 0c             	sub    $0xc,%esp
8010026f:	68 ba 85 10 80       	push   $0x801085ba
80100274:	e8 27 03 00 00       	call   801005a0 <panic>

  releasesleep(&b->lock);
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	83 c0 0c             	add    $0xc,%eax
8010027f:	83 ec 0c             	sub    $0xc,%esp
80100282:	50                   	push   %eax
80100283:	e8 eb 4b 00 00       	call   80104e73 <releasesleep>
80100288:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028b:	83 ec 0c             	sub    $0xc,%esp
8010028e:	68 40 c6 10 80       	push   $0x8010c640
80100293:	e8 ba 4c 00 00       	call   80104f52 <acquire>
80100298:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029b:	8b 45 08             	mov    0x8(%ebp),%eax
8010029e:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a1:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002aa:	8b 45 08             	mov    0x8(%ebp),%eax
801002ad:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b0:	85 c0                	test   %eax,%eax
801002b2:	75 47                	jne    801002fb <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b4:	8b 45 08             	mov    0x8(%ebp),%eax
801002b7:	8b 40 54             	mov    0x54(%eax),%eax
801002ba:	8b 55 08             	mov    0x8(%ebp),%edx
801002bd:	8b 52 50             	mov    0x50(%edx),%edx
801002c0:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c3:	8b 45 08             	mov    0x8(%ebp),%eax
801002c6:	8b 40 50             	mov    0x50(%eax),%eax
801002c9:	8b 55 08             	mov    0x8(%ebp),%edx
801002cc:	8b 52 54             	mov    0x54(%edx),%edx
801002cf:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d2:	8b 15 90 0d 11 80    	mov    0x80110d90,%edx
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	c7 40 50 3c 0d 11 80 	movl   $0x80110d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002e8:	a1 90 0d 11 80       	mov    0x80110d90,%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	a3 90 0d 11 80       	mov    %eax,0x80110d90
  }
  
  release(&bcache.lock);
801002fb:	83 ec 0c             	sub    $0xc,%esp
801002fe:	68 40 c6 10 80       	push   $0x8010c640
80100303:	e8 b8 4c 00 00       	call   80104fc0 <release>
80100308:	83 c4 10             	add    $0x10,%esp
}
8010030b:	90                   	nop
8010030c:	c9                   	leave  
8010030d:	c3                   	ret    

8010030e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030e:	55                   	push   %ebp
8010030f:	89 e5                	mov    %esp,%ebp
80100311:	83 ec 14             	sub    $0x14,%esp
80100314:	8b 45 08             	mov    0x8(%ebp),%eax
80100317:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010031f:	89 c2                	mov    %eax,%edx
80100321:	ec                   	in     (%dx),%al
80100322:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100325:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80100329:	c9                   	leave  
8010032a:	c3                   	ret    

8010032b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032b:	55                   	push   %ebp
8010032c:	89 e5                	mov    %esp,%ebp
8010032e:	83 ec 08             	sub    $0x8,%esp
80100331:	8b 55 08             	mov    0x8(%ebp),%edx
80100334:	8b 45 0c             	mov    0xc(%ebp),%eax
80100337:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010033b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010033e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100342:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100346:	ee                   	out    %al,(%dx)
}
80100347:	90                   	nop
80100348:	c9                   	leave  
80100349:	c3                   	ret    

8010034a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034a:	55                   	push   %ebp
8010034b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010034d:	fa                   	cli    
}
8010034e:	90                   	nop
8010034f:	5d                   	pop    %ebp
80100350:	c3                   	ret    

80100351 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100351:	55                   	push   %ebp
80100352:	89 e5                	mov    %esp,%ebp
80100354:	53                   	push   %ebx
80100355:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100358:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035c:	74 1c                	je     8010037a <printint+0x29>
8010035e:	8b 45 08             	mov    0x8(%ebp),%eax
80100361:	c1 e8 1f             	shr    $0x1f,%eax
80100364:	0f b6 c0             	movzbl %al,%eax
80100367:	89 45 10             	mov    %eax,0x10(%ebp)
8010036a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036e:	74 0a                	je     8010037a <printint+0x29>
    x = -xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	f7 d8                	neg    %eax
80100375:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100378:	eb 06                	jmp    80100380 <printint+0x2f>
  else
    x = xx;
8010037a:	8b 45 08             	mov    0x8(%ebp),%eax
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100387:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010038a:	8d 41 01             	lea    0x1(%ecx),%eax
8010038d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100396:	ba 00 00 00 00       	mov    $0x0,%edx
8010039b:	f7 f3                	div    %ebx
8010039d:	89 d0                	mov    %edx,%eax
8010039f:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
801003a6:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
801003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801003ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b0:	ba 00 00 00 00       	mov    $0x0,%edx
801003b5:	f7 f3                	div    %ebx
801003b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003be:	75 c7                	jne    80100387 <printint+0x36>

  if(sign)
801003c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c4:	74 2a                	je     801003f0 <printint+0x9f>
    buf[i++] = '-';
801003c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003c9:	8d 50 01             	lea    0x1(%eax),%edx
801003cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003cf:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d4:	eb 1a                	jmp    801003f0 <printint+0x9f>
    consputc(buf[i]);
801003d6:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003dc:	01 d0                	add    %edx,%eax
801003de:	0f b6 00             	movzbl (%eax),%eax
801003e1:	0f be c0             	movsbl %al,%eax
801003e4:	83 ec 0c             	sub    $0xc,%esp
801003e7:	50                   	push   %eax
801003e8:	e8 d8 03 00 00       	call   801007c5 <consputc>
801003ed:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003f8:	79 dc                	jns    801003d6 <printint+0x85>
    consputc(buf[i]);
}
801003fa:	90                   	nop
801003fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 d4 b5 10 80       	mov    0x8010b5d4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 a0 b5 10 80       	push   $0x8010b5a0
8010041c:	e8 31 4b 00 00       	call   80104f52 <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 c1 85 10 80       	push   $0x801085c1
80100433:	e8 68 01 00 00       	call   801005a0 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 1a 01 00 00       	jmp    80100564 <cprintf+0x164>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	pushl  -0x1c(%ebp)
80100456:	e8 6a 03 00 00       	call   801007c5 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 fd 00 00 00       	jmp    80100560 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 ff 00 00 00    	je     80100586 <cprintf+0x186>
      break;
    switch(c){
80100487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010048a:	83 f8 70             	cmp    $0x70,%eax
8010048d:	74 47                	je     801004d6 <cprintf+0xd6>
8010048f:	83 f8 70             	cmp    $0x70,%eax
80100492:	7f 13                	jg     801004a7 <cprintf+0xa7>
80100494:	83 f8 25             	cmp    $0x25,%eax
80100497:	0f 84 98 00 00 00    	je     80100535 <cprintf+0x135>
8010049d:	83 f8 64             	cmp    $0x64,%eax
801004a0:	74 14                	je     801004b6 <cprintf+0xb6>
801004a2:	e9 9d 00 00 00       	jmp    80100544 <cprintf+0x144>
801004a7:	83 f8 73             	cmp    $0x73,%eax
801004aa:	74 47                	je     801004f3 <cprintf+0xf3>
801004ac:	83 f8 78             	cmp    $0x78,%eax
801004af:	74 25                	je     801004d6 <cprintf+0xd6>
801004b1:	e9 8e 00 00 00       	jmp    80100544 <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
801004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b9:	8d 50 04             	lea    0x4(%eax),%edx
801004bc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004bf:	8b 00                	mov    (%eax),%eax
801004c1:	83 ec 04             	sub    $0x4,%esp
801004c4:	6a 01                	push   $0x1
801004c6:	6a 0a                	push   $0xa
801004c8:	50                   	push   %eax
801004c9:	e8 83 fe ff ff       	call   80100351 <printint>
801004ce:	83 c4 10             	add    $0x10,%esp
      break;
801004d1:	e9 8a 00 00 00       	jmp    80100560 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d9:	8d 50 04             	lea    0x4(%eax),%edx
801004dc:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004df:	8b 00                	mov    (%eax),%eax
801004e1:	83 ec 04             	sub    $0x4,%esp
801004e4:	6a 00                	push   $0x0
801004e6:	6a 10                	push   $0x10
801004e8:	50                   	push   %eax
801004e9:	e8 63 fe ff ff       	call   80100351 <printint>
801004ee:	83 c4 10             	add    $0x10,%esp
      break;
801004f1:	eb 6d                	jmp    80100560 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004f6:	8d 50 04             	lea    0x4(%eax),%edx
801004f9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004fc:	8b 00                	mov    (%eax),%eax
801004fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100501:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100505:	75 22                	jne    80100529 <cprintf+0x129>
        s = "(null)";
80100507:	c7 45 ec ca 85 10 80 	movl   $0x801085ca,-0x14(%ebp)
      for(; *s; s++)
8010050e:	eb 19                	jmp    80100529 <cprintf+0x129>
        consputc(*s);
80100510:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100513:	0f b6 00             	movzbl (%eax),%eax
80100516:	0f be c0             	movsbl %al,%eax
80100519:	83 ec 0c             	sub    $0xc,%esp
8010051c:	50                   	push   %eax
8010051d:	e8 a3 02 00 00       	call   801007c5 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
80100525:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100529:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010052c:	0f b6 00             	movzbl (%eax),%eax
8010052f:	84 c0                	test   %al,%al
80100531:	75 dd                	jne    80100510 <cprintf+0x110>
        consputc(*s);
      break;
80100533:	eb 2b                	jmp    80100560 <cprintf+0x160>
    case '%':
      consputc('%');
80100535:	83 ec 0c             	sub    $0xc,%esp
80100538:	6a 25                	push   $0x25
8010053a:	e8 86 02 00 00       	call   801007c5 <consputc>
8010053f:	83 c4 10             	add    $0x10,%esp
      break;
80100542:	eb 1c                	jmp    80100560 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100544:	83 ec 0c             	sub    $0xc,%esp
80100547:	6a 25                	push   $0x25
80100549:	e8 77 02 00 00       	call   801007c5 <consputc>
8010054e:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100551:	83 ec 0c             	sub    $0xc,%esp
80100554:	ff 75 e4             	pushl  -0x1c(%ebp)
80100557:	e8 69 02 00 00       	call   801007c5 <consputc>
8010055c:	83 c4 10             	add    $0x10,%esp
      break;
8010055f:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100564:	8b 55 08             	mov    0x8(%ebp),%edx
80100567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010056a:	01 d0                	add    %edx,%eax
8010056c:	0f b6 00             	movzbl (%eax),%eax
8010056f:	0f be c0             	movsbl %al,%eax
80100572:	25 ff 00 00 00       	and    $0xff,%eax
80100577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010057e:	0f 85 c6 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100584:	eb 01                	jmp    80100587 <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100586:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100587:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010058b:	74 10                	je     8010059d <cprintf+0x19d>
    release(&cons.lock);
8010058d:	83 ec 0c             	sub    $0xc,%esp
80100590:	68 a0 b5 10 80       	push   $0x8010b5a0
80100595:	e8 26 4a 00 00       	call   80104fc0 <release>
8010059a:	83 c4 10             	add    $0x10,%esp
}
8010059d:	90                   	nop
8010059e:	c9                   	leave  
8010059f:	c3                   	ret    

801005a0 <panic>:

void
panic(char *s)
{
801005a0:	55                   	push   %ebp
801005a1:	89 e5                	mov    %esp,%ebp
801005a3:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005a6:	e8 9f fd ff ff       	call   8010034a <cli>
  cons.locking = 0;
801005ab:	c7 05 d4 b5 10 80 00 	movl   $0x0,0x8010b5d4
801005b2:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005b5:	e8 1e 2a 00 00       	call   80102fd8 <lapicid>
801005ba:	83 ec 08             	sub    $0x8,%esp
801005bd:	50                   	push   %eax
801005be:	68 d1 85 10 80       	push   $0x801085d1
801005c3:	e8 38 fe ff ff       	call   80100400 <cprintf>
801005c8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005cb:	8b 45 08             	mov    0x8(%ebp),%eax
801005ce:	83 ec 0c             	sub    $0xc,%esp
801005d1:	50                   	push   %eax
801005d2:	e8 29 fe ff ff       	call   80100400 <cprintf>
801005d7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005da:	83 ec 0c             	sub    $0xc,%esp
801005dd:	68 e5 85 10 80       	push   $0x801085e5
801005e2:	e8 19 fe ff ff       	call   80100400 <cprintf>
801005e7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ea:	83 ec 08             	sub    $0x8,%esp
801005ed:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f0:	50                   	push   %eax
801005f1:	8d 45 08             	lea    0x8(%ebp),%eax
801005f4:	50                   	push   %eax
801005f5:	e8 18 4a 00 00       	call   80105012 <getcallerpcs>
801005fa:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100604:	eb 1c                	jmp    80100622 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100609:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060d:	83 ec 08             	sub    $0x8,%esp
80100610:	50                   	push   %eax
80100611:	68 e7 85 10 80       	push   $0x801085e7
80100616:	e8 e5 fd ff ff       	call   80100400 <cprintf>
8010061b:	83 c4 10             	add    $0x10,%esp
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
8010061e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100622:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100626:	7e de                	jle    80100606 <panic+0x66>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100628:	c7 05 80 b5 10 80 01 	movl   $0x1,0x8010b580
8010062f:	00 00 00 
  for(;;)
    ;
80100632:	eb fe                	jmp    80100632 <panic+0x92>

80100634 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100634:	55                   	push   %ebp
80100635:	89 e5                	mov    %esp,%ebp
80100637:	83 ec 18             	sub    $0x18,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010063a:	6a 0e                	push   $0xe
8010063c:	68 d4 03 00 00       	push   $0x3d4
80100641:	e8 e5 fc ff ff       	call   8010032b <outb>
80100646:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100649:	68 d5 03 00 00       	push   $0x3d5
8010064e:	e8 bb fc ff ff       	call   8010030e <inb>
80100653:	83 c4 04             	add    $0x4,%esp
80100656:	0f b6 c0             	movzbl %al,%eax
80100659:	c1 e0 08             	shl    $0x8,%eax
8010065c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010065f:	6a 0f                	push   $0xf
80100661:	68 d4 03 00 00       	push   $0x3d4
80100666:	e8 c0 fc ff ff       	call   8010032b <outb>
8010066b:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010066e:	68 d5 03 00 00       	push   $0x3d5
80100673:	e8 96 fc ff ff       	call   8010030e <inb>
80100678:	83 c4 04             	add    $0x4,%esp
8010067b:	0f b6 c0             	movzbl %al,%eax
8010067e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100681:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100685:	75 30                	jne    801006b7 <cgaputc+0x83>
    pos += 80 - pos%80;
80100687:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010068a:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	f7 ea                	imul   %edx
80100693:	c1 fa 05             	sar    $0x5,%edx
80100696:	89 c8                	mov    %ecx,%eax
80100698:	c1 f8 1f             	sar    $0x1f,%eax
8010069b:	29 c2                	sub    %eax,%edx
8010069d:	89 d0                	mov    %edx,%eax
8010069f:	c1 e0 02             	shl    $0x2,%eax
801006a2:	01 d0                	add    %edx,%eax
801006a4:	c1 e0 04             	shl    $0x4,%eax
801006a7:	29 c1                	sub    %eax,%ecx
801006a9:	89 ca                	mov    %ecx,%edx
801006ab:	b8 50 00 00 00       	mov    $0x50,%eax
801006b0:	29 d0                	sub    %edx,%eax
801006b2:	01 45 f4             	add    %eax,-0xc(%ebp)
801006b5:	eb 34                	jmp    801006eb <cgaputc+0xb7>
  else if(c == BACKSPACE){
801006b7:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006be:	75 0c                	jne    801006cc <cgaputc+0x98>
    if(pos > 0) --pos;
801006c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006c4:	7e 25                	jle    801006eb <cgaputc+0xb7>
801006c6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ca:	eb 1f                	jmp    801006eb <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006cc:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006d5:	8d 50 01             	lea    0x1(%eax),%edx
801006d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006db:	01 c0                	add    %eax,%eax
801006dd:	01 c8                	add    %ecx,%eax
801006df:	8b 55 08             	mov    0x8(%ebp),%edx
801006e2:	0f b6 d2             	movzbl %dl,%edx
801006e5:	80 ce 07             	or     $0x7,%dh
801006e8:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ef:	78 09                	js     801006fa <cgaputc+0xc6>
801006f1:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006f8:	7e 0d                	jle    80100707 <cgaputc+0xd3>
    panic("pos under/overflow");
801006fa:	83 ec 0c             	sub    $0xc,%esp
801006fd:	68 eb 85 10 80       	push   $0x801085eb
80100702:	e8 99 fe ff ff       	call   801005a0 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100707:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070e:	7e 4c                	jle    8010075c <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100710:	a1 00 90 10 80       	mov    0x80109000,%eax
80100715:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010071b:	a1 00 90 10 80       	mov    0x80109000,%eax
80100720:	83 ec 04             	sub    $0x4,%esp
80100723:	68 60 0e 00 00       	push   $0xe60
80100728:	52                   	push   %edx
80100729:	50                   	push   %eax
8010072a:	e8 59 4b 00 00       	call   80105288 <memmove>
8010072f:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100732:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100736:	b8 80 07 00 00       	mov    $0x780,%eax
8010073b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073e:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100741:	a1 00 90 10 80       	mov    0x80109000,%eax
80100746:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100749:	01 c9                	add    %ecx,%ecx
8010074b:	01 c8                	add    %ecx,%eax
8010074d:	83 ec 04             	sub    $0x4,%esp
80100750:	52                   	push   %edx
80100751:	6a 00                	push   $0x0
80100753:	50                   	push   %eax
80100754:	e8 70 4a 00 00       	call   801051c9 <memset>
80100759:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010075c:	83 ec 08             	sub    $0x8,%esp
8010075f:	6a 0e                	push   $0xe
80100761:	68 d4 03 00 00       	push   $0x3d4
80100766:	e8 c0 fb ff ff       	call   8010032b <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100771:	c1 f8 08             	sar    $0x8,%eax
80100774:	0f b6 c0             	movzbl %al,%eax
80100777:	83 ec 08             	sub    $0x8,%esp
8010077a:	50                   	push   %eax
8010077b:	68 d5 03 00 00       	push   $0x3d5
80100780:	e8 a6 fb ff ff       	call   8010032b <outb>
80100785:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100788:	83 ec 08             	sub    $0x8,%esp
8010078b:	6a 0f                	push   $0xf
8010078d:	68 d4 03 00 00       	push   $0x3d4
80100792:	e8 94 fb ff ff       	call   8010032b <outb>
80100797:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010079d:	0f b6 c0             	movzbl %al,%eax
801007a0:	83 ec 08             	sub    $0x8,%esp
801007a3:	50                   	push   %eax
801007a4:	68 d5 03 00 00       	push   $0x3d5
801007a9:	e8 7d fb ff ff       	call   8010032b <outb>
801007ae:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007b1:	a1 00 90 10 80       	mov    0x80109000,%eax
801007b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007b9:	01 d2                	add    %edx,%edx
801007bb:	01 d0                	add    %edx,%eax
801007bd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007c2:	90                   	nop
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <consputc>:

void
consputc(int c)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007cb:	a1 80 b5 10 80       	mov    0x8010b580,%eax
801007d0:	85 c0                	test   %eax,%eax
801007d2:	74 07                	je     801007db <consputc+0x16>
    cli();
801007d4:	e8 71 fb ff ff       	call   8010034a <cli>
    for(;;)
      ;
801007d9:	eb fe                	jmp    801007d9 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007db:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007e2:	75 29                	jne    8010080d <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007e4:	83 ec 0c             	sub    $0xc,%esp
801007e7:	6a 08                	push   $0x8
801007e9:	e8 da 63 00 00       	call   80106bc8 <uartputc>
801007ee:	83 c4 10             	add    $0x10,%esp
801007f1:	83 ec 0c             	sub    $0xc,%esp
801007f4:	6a 20                	push   $0x20
801007f6:	e8 cd 63 00 00       	call   80106bc8 <uartputc>
801007fb:	83 c4 10             	add    $0x10,%esp
801007fe:	83 ec 0c             	sub    $0xc,%esp
80100801:	6a 08                	push   $0x8
80100803:	e8 c0 63 00 00       	call   80106bc8 <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
8010080b:	eb 0e                	jmp    8010081b <consputc+0x56>
  } else
    uartputc(c);
8010080d:	83 ec 0c             	sub    $0xc,%esp
80100810:	ff 75 08             	pushl  0x8(%ebp)
80100813:	e8 b0 63 00 00       	call   80106bc8 <uartputc>
80100818:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010081b:	83 ec 0c             	sub    $0xc,%esp
8010081e:	ff 75 08             	pushl  0x8(%ebp)
80100821:	e8 0e fe ff ff       	call   80100634 <cgaputc>
80100826:	83 c4 10             	add    $0x10,%esp
}
80100829:	90                   	nop
8010082a:	c9                   	leave  
8010082b:	c3                   	ret    

8010082c <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010082c:	55                   	push   %ebp
8010082d:	89 e5                	mov    %esp,%ebp
8010082f:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100839:	83 ec 0c             	sub    $0xc,%esp
8010083c:	68 a0 b5 10 80       	push   $0x8010b5a0
80100841:	e8 0c 47 00 00       	call   80104f52 <acquire>
80100846:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100849:	e9 44 01 00 00       	jmp    80100992 <consoleintr+0x166>
    switch(c){
8010084e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100851:	83 f8 10             	cmp    $0x10,%eax
80100854:	74 1e                	je     80100874 <consoleintr+0x48>
80100856:	83 f8 10             	cmp    $0x10,%eax
80100859:	7f 0a                	jg     80100865 <consoleintr+0x39>
8010085b:	83 f8 08             	cmp    $0x8,%eax
8010085e:	74 6b                	je     801008cb <consoleintr+0x9f>
80100860:	e9 9b 00 00 00       	jmp    80100900 <consoleintr+0xd4>
80100865:	83 f8 15             	cmp    $0x15,%eax
80100868:	74 33                	je     8010089d <consoleintr+0x71>
8010086a:	83 f8 7f             	cmp    $0x7f,%eax
8010086d:	74 5c                	je     801008cb <consoleintr+0x9f>
8010086f:	e9 8c 00 00 00       	jmp    80100900 <consoleintr+0xd4>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100874:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010087b:	e9 12 01 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100880:	a1 28 10 11 80       	mov    0x80111028,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
8010088d:	83 ec 0c             	sub    $0xc,%esp
80100890:	68 00 01 00 00       	push   $0x100
80100895:	e8 2b ff ff ff       	call   801007c5 <consputc>
8010089a:	83 c4 10             	add    $0x10,%esp
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010089d:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008a3:	a1 24 10 11 80       	mov    0x80111024,%eax
801008a8:	39 c2                	cmp    %eax,%edx
801008aa:	0f 84 e2 00 00 00    	je     80100992 <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008b0:	a1 28 10 11 80       	mov    0x80111028,%eax
801008b5:	83 e8 01             	sub    $0x1,%eax
801008b8:	83 e0 7f             	and    $0x7f,%eax
801008bb:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008c2:	3c 0a                	cmp    $0xa,%al
801008c4:	75 ba                	jne    80100880 <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008c6:	e9 c7 00 00 00       	jmp    80100992 <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008cb:	8b 15 28 10 11 80    	mov    0x80111028,%edx
801008d1:	a1 24 10 11 80       	mov    0x80111024,%eax
801008d6:	39 c2                	cmp    %eax,%edx
801008d8:	0f 84 b4 00 00 00    	je     80100992 <consoleintr+0x166>
        input.e--;
801008de:	a1 28 10 11 80       	mov    0x80111028,%eax
801008e3:	83 e8 01             	sub    $0x1,%eax
801008e6:	a3 28 10 11 80       	mov    %eax,0x80111028
        consputc(BACKSPACE);
801008eb:	83 ec 0c             	sub    $0xc,%esp
801008ee:	68 00 01 00 00       	push   $0x100
801008f3:	e8 cd fe ff ff       	call   801007c5 <consputc>
801008f8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008fb:	e9 92 00 00 00       	jmp    80100992 <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100904:	0f 84 87 00 00 00    	je     80100991 <consoleintr+0x165>
8010090a:	8b 15 28 10 11 80    	mov    0x80111028,%edx
80100910:	a1 20 10 11 80       	mov    0x80111020,%eax
80100915:	29 c2                	sub    %eax,%edx
80100917:	89 d0                	mov    %edx,%eax
80100919:	83 f8 7f             	cmp    $0x7f,%eax
8010091c:	77 73                	ja     80100991 <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
8010091e:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100922:	74 05                	je     80100929 <consoleintr+0xfd>
80100924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100927:	eb 05                	jmp    8010092e <consoleintr+0x102>
80100929:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100931:	a1 28 10 11 80       	mov    0x80111028,%eax
80100936:	8d 50 01             	lea    0x1(%eax),%edx
80100939:	89 15 28 10 11 80    	mov    %edx,0x80111028
8010093f:	83 e0 7f             	and    $0x7f,%eax
80100942:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100945:	88 90 a0 0f 11 80    	mov    %dl,-0x7feef060(%eax)
        consputc(c);
8010094b:	83 ec 0c             	sub    $0xc,%esp
8010094e:	ff 75 f0             	pushl  -0x10(%ebp)
80100951:	e8 6f fe ff ff       	call   801007c5 <consputc>
80100956:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100959:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010095d:	74 18                	je     80100977 <consoleintr+0x14b>
8010095f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100963:	74 12                	je     80100977 <consoleintr+0x14b>
80100965:	a1 28 10 11 80       	mov    0x80111028,%eax
8010096a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100970:	83 ea 80             	sub    $0xffffff80,%edx
80100973:	39 d0                	cmp    %edx,%eax
80100975:	75 1a                	jne    80100991 <consoleintr+0x165>
          input.w = input.e;
80100977:	a1 28 10 11 80       	mov    0x80111028,%eax
8010097c:	a3 24 10 11 80       	mov    %eax,0x80111024
          wakeup(&input.r);
80100981:	83 ec 0c             	sub    $0xc,%esp
80100984:	68 20 10 11 80       	push   $0x80111020
80100989:	e8 91 42 00 00       	call   80104c1f <wakeup>
8010098e:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100991:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100992:	8b 45 08             	mov    0x8(%ebp),%eax
80100995:	ff d0                	call   *%eax
80100997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010099a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099e:	0f 89 aa fe ff ff    	jns    8010084e <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009a4:	83 ec 0c             	sub    $0xc,%esp
801009a7:	68 a0 b5 10 80       	push   $0x8010b5a0
801009ac:	e8 0f 46 00 00       	call   80104fc0 <release>
801009b1:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b8:	74 05                	je     801009bf <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
801009ba:	e8 1b 43 00 00       	call   80104cda <procdump>
  }
}
801009bf:	90                   	nop
801009c0:	c9                   	leave  
801009c1:	c3                   	ret    

801009c2 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c2:	55                   	push   %ebp
801009c3:	89 e5                	mov    %esp,%ebp
801009c5:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	ff 75 08             	pushl  0x8(%ebp)
801009ce:	e8 3d 11 00 00       	call   80101b10 <iunlock>
801009d3:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009dc:	83 ec 0c             	sub    $0xc,%esp
801009df:	68 a0 b5 10 80       	push   $0x8010b5a0
801009e4:	e8 69 45 00 00       	call   80104f52 <acquire>
801009e9:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ec:	e9 ab 00 00 00       	jmp    80100a9c <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009f1:	e8 84 38 00 00       	call   8010427a <myproc>
801009f6:	8b 40 24             	mov    0x24(%eax),%eax
801009f9:	85 c0                	test   %eax,%eax
801009fb:	74 28                	je     80100a25 <consoleread+0x63>
        release(&cons.lock);
801009fd:	83 ec 0c             	sub    $0xc,%esp
80100a00:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a05:	e8 b6 45 00 00       	call   80104fc0 <release>
80100a0a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0d:	83 ec 0c             	sub    $0xc,%esp
80100a10:	ff 75 08             	pushl  0x8(%ebp)
80100a13:	e8 e5 0f 00 00       	call   801019fd <ilock>
80100a18:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a20:	e9 ab 00 00 00       	jmp    80100ad0 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
80100a25:	83 ec 08             	sub    $0x8,%esp
80100a28:	68 a0 b5 10 80       	push   $0x8010b5a0
80100a2d:	68 20 10 11 80       	push   $0x80111020
80100a32:	e8 02 41 00 00       	call   80104b39 <sleep>
80100a37:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a3a:	8b 15 20 10 11 80    	mov    0x80111020,%edx
80100a40:	a1 24 10 11 80       	mov    0x80111024,%eax
80100a45:	39 c2                	cmp    %eax,%edx
80100a47:	74 a8                	je     801009f1 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a49:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a4e:	8d 50 01             	lea    0x1(%eax),%edx
80100a51:	89 15 20 10 11 80    	mov    %edx,0x80111020
80100a57:	83 e0 7f             	and    $0x7f,%eax
80100a5a:	0f b6 80 a0 0f 11 80 	movzbl -0x7feef060(%eax),%eax
80100a61:	0f be c0             	movsbl %al,%eax
80100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a67:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6b:	75 17                	jne    80100a84 <consoleread+0xc2>
      if(n < target){
80100a6d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a70:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a73:	73 2f                	jae    80100aa4 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a75:	a1 20 10 11 80       	mov    0x80111020,%eax
80100a7a:	83 e8 01             	sub    $0x1,%eax
80100a7d:	a3 20 10 11 80       	mov    %eax,0x80111020
      }
      break;
80100a82:	eb 20                	jmp    80100aa4 <consoleread+0xe2>
    }
    *dst++ = c;
80100a84:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a87:	8d 50 01             	lea    0x1(%eax),%edx
80100a8a:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a90:	88 10                	mov    %dl,(%eax)
    --n;
80100a92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a96:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a9a:	74 0b                	je     80100aa7 <consoleread+0xe5>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100aa0:	7f 98                	jg     80100a3a <consoleread+0x78>
80100aa2:	eb 04                	jmp    80100aa8 <consoleread+0xe6>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100aa4:	90                   	nop
80100aa5:	eb 01                	jmp    80100aa8 <consoleread+0xe6>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100aa7:	90                   	nop
  }
  release(&cons.lock);
80100aa8:	83 ec 0c             	sub    $0xc,%esp
80100aab:	68 a0 b5 10 80       	push   $0x8010b5a0
80100ab0:	e8 0b 45 00 00       	call   80104fc0 <release>
80100ab5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab8:	83 ec 0c             	sub    $0xc,%esp
80100abb:	ff 75 08             	pushl  0x8(%ebp)
80100abe:	e8 3a 0f 00 00       	call   801019fd <ilock>
80100ac3:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac6:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acc:	29 c2                	sub    %eax,%edx
80100ace:	89 d0                	mov    %edx,%eax
}
80100ad0:	c9                   	leave  
80100ad1:	c3                   	ret    

80100ad2 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad2:	55                   	push   %ebp
80100ad3:	89 e5                	mov    %esp,%ebp
80100ad5:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad8:	83 ec 0c             	sub    $0xc,%esp
80100adb:	ff 75 08             	pushl  0x8(%ebp)
80100ade:	e8 2d 10 00 00       	call   80101b10 <iunlock>
80100ae3:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 a0 b5 10 80       	push   $0x8010b5a0
80100aee:	e8 5f 44 00 00       	call   80104f52 <acquire>
80100af3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afd:	eb 21                	jmp    80100b20 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100aff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b05:	01 d0                	add    %edx,%eax
80100b07:	0f b6 00             	movzbl (%eax),%eax
80100b0a:	0f be c0             	movsbl %al,%eax
80100b0d:	0f b6 c0             	movzbl %al,%eax
80100b10:	83 ec 0c             	sub    $0xc,%esp
80100b13:	50                   	push   %eax
80100b14:	e8 ac fc ff ff       	call   801007c5 <consputc>
80100b19:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b23:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b26:	7c d7                	jl     80100aff <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b28:	83 ec 0c             	sub    $0xc,%esp
80100b2b:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b30:	e8 8b 44 00 00       	call   80104fc0 <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 ba 0e 00 00       	call   801019fd <ilock>
80100b43:	83 c4 10             	add    $0x10,%esp

  return n;
80100b46:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b49:	c9                   	leave  
80100b4a:	c3                   	ret    

80100b4b <consoleinit>:

void
consoleinit(void)
{
80100b4b:	55                   	push   %ebp
80100b4c:	89 e5                	mov    %esp,%ebp
80100b4e:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b51:	83 ec 08             	sub    $0x8,%esp
80100b54:	68 fe 85 10 80       	push   $0x801085fe
80100b59:	68 a0 b5 10 80       	push   $0x8010b5a0
80100b5e:	e8 cd 43 00 00       	call   80104f30 <initlock>
80100b63:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b66:	c7 05 ec 19 11 80 d2 	movl   $0x80100ad2,0x801119ec
80100b6d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b70:	c7 05 e8 19 11 80 c2 	movl   $0x801009c2,0x801119e8
80100b77:	09 10 80 
  cons.locking = 1;
80100b7a:	c7 05 d4 b5 10 80 01 	movl   $0x1,0x8010b5d4
80100b81:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b84:	83 ec 08             	sub    $0x8,%esp
80100b87:	6a 00                	push   $0x0
80100b89:	6a 01                	push   $0x1
80100b8b:	e8 81 1f 00 00       	call   80102b11 <ioapicenable>
80100b90:	83 c4 10             	add    $0x10,%esp
}
80100b93:	90                   	nop
80100b94:	c9                   	leave  
80100b95:	c3                   	ret    

80100b96 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b96:	55                   	push   %ebp
80100b97:	89 e5                	mov    %esp,%ebp
80100b99:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b9f:	e8 d6 36 00 00       	call   8010427a <myproc>
80100ba4:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100ba7:	e8 76 29 00 00       	call   80103522 <begin_op>

  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	pushl  0x8(%ebp)
80100bb2:	e8 86 19 00 00       	call   8010253d <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 1f                	jne    80100be2 <exec+0x4c>
    end_op();
80100bc3:	e8 e6 29 00 00       	call   801035ae <end_op>
    cprintf("exec: fail\n");
80100bc8:	83 ec 0c             	sub    $0xc,%esp
80100bcb:	68 06 86 10 80       	push   $0x80108606
80100bd0:	e8 2b f8 ff ff       	call   80100400 <cprintf>
80100bd5:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bdd:	e9 de 03 00 00       	jmp    80100fc0 <exec+0x42a>
  }
  ilock(ip);
80100be2:	83 ec 0c             	sub    $0xc,%esp
80100be5:	ff 75 d8             	pushl  -0x28(%ebp)
80100be8:	e8 10 0e 00 00       	call   801019fd <ilock>
80100bed:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bf0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bf7:	6a 34                	push   $0x34
80100bf9:	6a 00                	push   $0x0
80100bfb:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c01:	50                   	push   %eax
80100c02:	ff 75 d8             	pushl  -0x28(%ebp)
80100c05:	e8 e4 12 00 00       	call   80101eee <readi>
80100c0a:	83 c4 10             	add    $0x10,%esp
80100c0d:	83 f8 34             	cmp    $0x34,%eax
80100c10:	0f 85 53 03 00 00    	jne    80100f69 <exec+0x3d3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c16:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c1c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c21:	0f 85 45 03 00 00    	jne    80100f6c <exec+0x3d6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c27:	e8 98 6f 00 00       	call   80107bc4 <setupkvm>
80100c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c33:	0f 84 36 03 00 00    	je     80100f6f <exec+0x3d9>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c39:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c40:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c47:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c50:	e9 de 00 00 00       	jmp    80100d33 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c58:	6a 20                	push   $0x20
80100c5a:	50                   	push   %eax
80100c5b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c61:	50                   	push   %eax
80100c62:	ff 75 d8             	pushl  -0x28(%ebp)
80100c65:	e8 84 12 00 00       	call   80101eee <readi>
80100c6a:	83 c4 10             	add    $0x10,%esp
80100c6d:	83 f8 20             	cmp    $0x20,%eax
80100c70:	0f 85 fc 02 00 00    	jne    80100f72 <exec+0x3dc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c76:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c7c:	83 f8 01             	cmp    $0x1,%eax
80100c7f:	0f 85 a0 00 00 00    	jne    80100d25 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c91:	39 c2                	cmp    %eax,%edx
80100c93:	0f 82 dc 02 00 00    	jb     80100f75 <exec+0x3df>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c99:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c9f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ca5:	01 c2                	add    %eax,%edx
80100ca7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cad:	39 c2                	cmp    %eax,%edx
80100caf:	0f 82 c3 02 00 00    	jb     80100f78 <exec+0x3e2>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cb5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cbb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cc1:	01 d0                	add    %edx,%eax
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff 75 e0             	pushl  -0x20(%ebp)
80100cca:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ccd:	e8 97 72 00 00       	call   80107f69 <allocuvm>
80100cd2:	83 c4 10             	add    $0x10,%esp
80100cd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdc:	0f 84 99 02 00 00    	je     80100f7b <exec+0x3e5>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ce2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ce8:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	0f 85 89 02 00 00    	jne    80100f7e <exec+0x3e8>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cf5:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cfb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d01:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	52                   	push   %edx
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 d8             	pushl  -0x28(%ebp)
80100d0f:	51                   	push   %ecx
80100d10:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d13:	e8 84 71 00 00       	call   80107e9c <loaduvm>
80100d18:	83 c4 20             	add    $0x20,%esp
80100d1b:	85 c0                	test   %eax,%eax
80100d1d:	0f 88 5e 02 00 00    	js     80100f81 <exec+0x3eb>
80100d23:	eb 01                	jmp    80100d26 <exec+0x190>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d25:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d26:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d2d:	83 c0 20             	add    $0x20,%eax
80100d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d33:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d3a:	0f b7 c0             	movzwl %ax,%eax
80100d3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d40:	0f 8f 0f ff ff ff    	jg     80100c55 <exec+0xbf>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d46:	83 ec 0c             	sub    $0xc,%esp
80100d49:	ff 75 d8             	pushl  -0x28(%ebp)
80100d4c:	e8 dd 0e 00 00       	call   80101c2e <iunlockput>
80100d51:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d54:	e8 55 28 00 00       	call   801035ae <end_op>
  ip = 0;
80100d59:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d63:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)

///////////
//PART 1 OF THE LAB
///////////
  if((allocuvm(pgdir, STACKTOP - PGSIZE, STACKTOP)) == 0)
80100d70:	83 ec 04             	sub    $0x4,%esp
80100d73:	68 ff ff ff 7f       	push   $0x7fffffff
80100d78:	68 ff ef ff 7f       	push   $0x7fffefff
80100d7d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d80:	e8 e4 71 00 00       	call   80107f69 <allocuvm>
80100d85:	83 c4 10             	add    $0x10,%esp
80100d88:	85 c0                	test   %eax,%eax
80100d8a:	0f 84 f4 01 00 00    	je     80100f84 <exec+0x3ee>
    goto bad;
  sp = STACKTOP;
80100d90:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)
///////////
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d97:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d9e:	e9 96 00 00 00       	jmp    80100e39 <exec+0x2a3>
    if(argc >= MAXARG)
80100da3:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100da7:	0f 87 da 01 00 00    	ja     80100f87 <exec+0x3f1>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dba:	01 d0                	add    %edx,%eax
80100dbc:	8b 00                	mov    (%eax),%eax
80100dbe:	83 ec 0c             	sub    $0xc,%esp
80100dc1:	50                   	push   %eax
80100dc2:	e8 4f 46 00 00       	call   80105416 <strlen>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	89 c2                	mov    %eax,%edx
80100dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dcf:	29 d0                	sub    %edx,%eax
80100dd1:	83 e8 01             	sub    $0x1,%eax
80100dd4:	83 e0 fc             	and    $0xfffffffc,%eax
80100dd7:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de7:	01 d0                	add    %edx,%eax
80100de9:	8b 00                	mov    (%eax),%eax
80100deb:	83 ec 0c             	sub    $0xc,%esp
80100dee:	50                   	push   %eax
80100def:	e8 22 46 00 00       	call   80105416 <strlen>
80100df4:	83 c4 10             	add    $0x10,%esp
80100df7:	83 c0 01             	add    $0x1,%eax
80100dfa:	89 c1                	mov    %eax,%ecx
80100dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e09:	01 d0                	add    %edx,%eax
80100e0b:	8b 00                	mov    (%eax),%eax
80100e0d:	51                   	push   %ecx
80100e0e:	50                   	push   %eax
80100e0f:	ff 75 dc             	pushl  -0x24(%ebp)
80100e12:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e15:	e8 32 76 00 00       	call   8010844c <copyout>
80100e1a:	83 c4 10             	add    $0x10,%esp
80100e1d:	85 c0                	test   %eax,%eax
80100e1f:	0f 88 65 01 00 00    	js     80100f8a <exec+0x3f4>
      goto bad;
    ustack[3+argc] = sp;
80100e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e28:	8d 50 03             	lea    0x3(%eax),%edx
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  sp = STACKTOP;
///////////
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e35:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e46:	01 d0                	add    %edx,%eax
80100e48:	8b 00                	mov    (%eax),%eax
80100e4a:	85 c0                	test   %eax,%eax
80100e4c:	0f 85 51 ff ff ff    	jne    80100da3 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e55:	83 c0 03             	add    $0x3,%eax
80100e58:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e5f:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e63:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e6a:	ff ff ff 
  ustack[1] = argc;
80100e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e70:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e79:	83 c0 01             	add    $0x1,%eax
80100e7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e86:	29 d0                	sub    %edx,%eax
80100e88:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e91:	83 c0 04             	add    $0x4,%eax
80100e94:	c1 e0 02             	shl    $0x2,%eax
80100e97:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9d:	83 c0 04             	add    $0x4,%eax
80100ea0:	c1 e0 02             	shl    $0x2,%eax
80100ea3:	50                   	push   %eax
80100ea4:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eaa:	50                   	push   %eax
80100eab:	ff 75 dc             	pushl  -0x24(%ebp)
80100eae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eb1:	e8 96 75 00 00       	call   8010844c <copyout>
80100eb6:	83 c4 10             	add    $0x10,%esp
80100eb9:	85 c0                	test   %eax,%eax
80100ebb:	0f 88 cc 00 00 00    	js     80100f8d <exec+0x3f7>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ecd:	eb 17                	jmp    80100ee6 <exec+0x350>
    if(*s == '/')
80100ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed2:	0f b6 00             	movzbl (%eax),%eax
80100ed5:	3c 2f                	cmp    $0x2f,%al
80100ed7:	75 09                	jne    80100ee2 <exec+0x34c>
      last = s+1;
80100ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edc:	83 c0 01             	add    $0x1,%eax
80100edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ee2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee9:	0f b6 00             	movzbl (%eax),%eax
80100eec:	84 c0                	test   %al,%al
80100eee:	75 df                	jne    80100ecf <exec+0x339>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ef3:	83 c0 6c             	add    $0x6c,%eax
80100ef6:	83 ec 04             	sub    $0x4,%esp
80100ef9:	6a 10                	push   $0x10
80100efb:	ff 75 f0             	pushl  -0x10(%ebp)
80100efe:	50                   	push   %eax
80100eff:	e8 c8 44 00 00       	call   801053cc <safestrcpy>
80100f04:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f07:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0a:	8b 40 04             	mov    0x4(%eax),%eax
80100f0d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f16:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f19:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f1f:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 40 18             	mov    0x18(%eax),%eax
80100f27:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f2d:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f33:	8b 40 18             	mov    0x18(%eax),%eax
80100f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f39:	89 50 44             	mov    %edx,0x44(%eax)
  curproc->stack_pages = 1; //lab2 
80100f3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3f:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
  switchuvm(curproc);
80100f46:	83 ec 0c             	sub    $0xc,%esp
80100f49:	ff 75 d0             	pushl  -0x30(%ebp)
80100f4c:	e8 3d 6d 00 00       	call   80107c8e <switchuvm>
80100f51:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f54:	83 ec 0c             	sub    $0xc,%esp
80100f57:	ff 75 cc             	pushl  -0x34(%ebp)
80100f5a:	e8 d3 71 00 00       	call   80108132 <freevm>
80100f5f:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f62:	b8 00 00 00 00       	mov    $0x0,%eax
80100f67:	eb 57                	jmp    80100fc0 <exec+0x42a>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 22                	jmp    80100f8e <exec+0x3f8>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1f                	jmp    80100f8e <exec+0x3f8>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f6f:	90                   	nop
80100f70:	eb 1c                	jmp    80100f8e <exec+0x3f8>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 19                	jmp    80100f8e <exec+0x3f8>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 16                	jmp    80100f8e <exec+0x3f8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 13                	jmp    80100f8e <exec+0x3f8>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 10                	jmp    80100f8e <exec+0x3f8>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0d                	jmp    80100f8e <exec+0x3f8>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f81:	90                   	nop
80100f82:	eb 0a                	jmp    80100f8e <exec+0x3f8>

///////////
//PART 1 OF THE LAB
///////////
  if((allocuvm(pgdir, STACKTOP - PGSIZE, STACKTOP)) == 0)
    goto bad;
80100f84:	90                   	nop
80100f85:	eb 07                	jmp    80100f8e <exec+0x3f8>
///////////

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 04                	jmp    80100f8e <exec+0x3f8>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f8a:	90                   	nop
80100f8b:	eb 01                	jmp    80100f8e <exec+0x3f8>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f8d:	90                   	nop
  switchuvm(curproc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f8e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f92:	74 0e                	je     80100fa2 <exec+0x40c>
    freevm(pgdir);
80100f94:	83 ec 0c             	sub    $0xc,%esp
80100f97:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f9a:	e8 93 71 00 00       	call   80108132 <freevm>
80100f9f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa6:	74 13                	je     80100fbb <exec+0x425>
    iunlockput(ip);
80100fa8:	83 ec 0c             	sub    $0xc,%esp
80100fab:	ff 75 d8             	pushl  -0x28(%ebp)
80100fae:	e8 7b 0c 00 00       	call   80101c2e <iunlockput>
80100fb3:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb6:	e8 f3 25 00 00       	call   801035ae <end_op>
  }
  return -1;
80100fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc0:	c9                   	leave  
80100fc1:	c3                   	ret    

80100fc2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc2:	55                   	push   %ebp
80100fc3:	89 e5                	mov    %esp,%ebp
80100fc5:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc8:	83 ec 08             	sub    $0x8,%esp
80100fcb:	68 12 86 10 80       	push   $0x80108612
80100fd0:	68 40 10 11 80       	push   $0x80111040
80100fd5:	e8 56 3f 00 00       	call   80104f30 <initlock>
80100fda:	83 c4 10             	add    $0x10,%esp
}
80100fdd:	90                   	nop
80100fde:	c9                   	leave  
80100fdf:	c3                   	ret    

80100fe0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe6:	83 ec 0c             	sub    $0xc,%esp
80100fe9:	68 40 10 11 80       	push   $0x80111040
80100fee:	e8 5f 3f 00 00       	call   80104f52 <acquire>
80100ff3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff6:	c7 45 f4 74 10 11 80 	movl   $0x80111074,-0xc(%ebp)
80100ffd:	eb 2d                	jmp    8010102c <filealloc+0x4c>
    if(f->ref == 0){
80100fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101002:	8b 40 04             	mov    0x4(%eax),%eax
80101005:	85 c0                	test   %eax,%eax
80101007:	75 1f                	jne    80101028 <filealloc+0x48>
      f->ref = 1;
80101009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101013:	83 ec 0c             	sub    $0xc,%esp
80101016:	68 40 10 11 80       	push   $0x80111040
8010101b:	e8 a0 3f 00 00       	call   80104fc0 <release>
80101020:	83 c4 10             	add    $0x10,%esp
      return f;
80101023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101026:	eb 23                	jmp    8010104b <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101028:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010102c:	b8 d4 19 11 80       	mov    $0x801119d4,%eax
80101031:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101034:	72 c9                	jb     80100fff <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101036:	83 ec 0c             	sub    $0xc,%esp
80101039:	68 40 10 11 80       	push   $0x80111040
8010103e:	e8 7d 3f 00 00       	call   80104fc0 <release>
80101043:	83 c4 10             	add    $0x10,%esp
  return 0;
80101046:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010104b:	c9                   	leave  
8010104c:	c3                   	ret    

8010104d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104d:	55                   	push   %ebp
8010104e:	89 e5                	mov    %esp,%ebp
80101050:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101053:	83 ec 0c             	sub    $0xc,%esp
80101056:	68 40 10 11 80       	push   $0x80111040
8010105b:	e8 f2 3e 00 00       	call   80104f52 <acquire>
80101060:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	85 c0                	test   %eax,%eax
8010106b:	7f 0d                	jg     8010107a <filedup+0x2d>
    panic("filedup");
8010106d:	83 ec 0c             	sub    $0xc,%esp
80101070:	68 19 86 10 80       	push   $0x80108619
80101075:	e8 26 f5 ff ff       	call   801005a0 <panic>
  f->ref++;
8010107a:	8b 45 08             	mov    0x8(%ebp),%eax
8010107d:	8b 40 04             	mov    0x4(%eax),%eax
80101080:	8d 50 01             	lea    0x1(%eax),%edx
80101083:	8b 45 08             	mov    0x8(%ebp),%eax
80101086:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101089:	83 ec 0c             	sub    $0xc,%esp
8010108c:	68 40 10 11 80       	push   $0x80111040
80101091:	e8 2a 3f 00 00       	call   80104fc0 <release>
80101096:	83 c4 10             	add    $0x10,%esp
  return f;
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010109c:	c9                   	leave  
8010109d:	c3                   	ret    

8010109e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109e:	55                   	push   %ebp
8010109f:	89 e5                	mov    %esp,%ebp
801010a1:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a4:	83 ec 0c             	sub    $0xc,%esp
801010a7:	68 40 10 11 80       	push   $0x80111040
801010ac:	e8 a1 3e 00 00       	call   80104f52 <acquire>
801010b1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 04             	mov    0x4(%eax),%eax
801010ba:	85 c0                	test   %eax,%eax
801010bc:	7f 0d                	jg     801010cb <fileclose+0x2d>
    panic("fileclose");
801010be:	83 ec 0c             	sub    $0xc,%esp
801010c1:	68 21 86 10 80       	push   $0x80108621
801010c6:	e8 d5 f4 ff ff       	call   801005a0 <panic>
  if(--f->ref > 0){
801010cb:	8b 45 08             	mov    0x8(%ebp),%eax
801010ce:	8b 40 04             	mov    0x4(%eax),%eax
801010d1:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d4:	8b 45 08             	mov    0x8(%ebp),%eax
801010d7:	89 50 04             	mov    %edx,0x4(%eax)
801010da:	8b 45 08             	mov    0x8(%ebp),%eax
801010dd:	8b 40 04             	mov    0x4(%eax),%eax
801010e0:	85 c0                	test   %eax,%eax
801010e2:	7e 15                	jle    801010f9 <fileclose+0x5b>
    release(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 40 10 11 80       	push   $0x80111040
801010ec:	e8 cf 3e 00 00       	call   80104fc0 <release>
801010f1:	83 c4 10             	add    $0x10,%esp
801010f4:	e9 8b 00 00 00       	jmp    80101184 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f9:	8b 45 08             	mov    0x8(%ebp),%eax
801010fc:	8b 10                	mov    (%eax),%edx
801010fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101101:	8b 50 04             	mov    0x4(%eax),%edx
80101104:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101107:	8b 50 08             	mov    0x8(%eax),%edx
8010110a:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110d:	8b 50 0c             	mov    0xc(%eax),%edx
80101110:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101113:	8b 50 10             	mov    0x10(%eax),%edx
80101116:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101119:	8b 40 14             	mov    0x14(%eax),%eax
8010111c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111f:	8b 45 08             	mov    0x8(%ebp),%eax
80101122:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101132:	83 ec 0c             	sub    $0xc,%esp
80101135:	68 40 10 11 80       	push   $0x80111040
8010113a:	e8 81 3e 00 00       	call   80104fc0 <release>
8010113f:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101142:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101145:	83 f8 01             	cmp    $0x1,%eax
80101148:	75 19                	jne    80101163 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010114a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114e:	0f be d0             	movsbl %al,%edx
80101151:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101154:	83 ec 08             	sub    $0x8,%esp
80101157:	52                   	push   %edx
80101158:	50                   	push   %eax
80101159:	e8 a6 2d 00 00       	call   80103f04 <pipeclose>
8010115e:	83 c4 10             	add    $0x10,%esp
80101161:	eb 21                	jmp    80101184 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101163:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101166:	83 f8 02             	cmp    $0x2,%eax
80101169:	75 19                	jne    80101184 <fileclose+0xe6>
    begin_op();
8010116b:	e8 b2 23 00 00       	call   80103522 <begin_op>
    iput(ff.ip);
80101170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101173:	83 ec 0c             	sub    $0xc,%esp
80101176:	50                   	push   %eax
80101177:	e8 e2 09 00 00       	call   80101b5e <iput>
8010117c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117f:	e8 2a 24 00 00       	call   801035ae <end_op>
  }
}
80101184:	c9                   	leave  
80101185:	c3                   	ret    

80101186 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101186:	55                   	push   %ebp
80101187:	89 e5                	mov    %esp,%ebp
80101189:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010118c:	8b 45 08             	mov    0x8(%ebp),%eax
8010118f:	8b 00                	mov    (%eax),%eax
80101191:	83 f8 02             	cmp    $0x2,%eax
80101194:	75 40                	jne    801011d6 <filestat+0x50>
    ilock(f->ip);
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	8b 40 10             	mov    0x10(%eax),%eax
8010119c:	83 ec 0c             	sub    $0xc,%esp
8010119f:	50                   	push   %eax
801011a0:	e8 58 08 00 00       	call   801019fd <ilock>
801011a5:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a8:	8b 45 08             	mov    0x8(%ebp),%eax
801011ab:	8b 40 10             	mov    0x10(%eax),%eax
801011ae:	83 ec 08             	sub    $0x8,%esp
801011b1:	ff 75 0c             	pushl  0xc(%ebp)
801011b4:	50                   	push   %eax
801011b5:	e8 ee 0c 00 00       	call   80101ea8 <stati>
801011ba:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011bd:	8b 45 08             	mov    0x8(%ebp),%eax
801011c0:	8b 40 10             	mov    0x10(%eax),%eax
801011c3:	83 ec 0c             	sub    $0xc,%esp
801011c6:	50                   	push   %eax
801011c7:	e8 44 09 00 00       	call   80101b10 <iunlock>
801011cc:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cf:	b8 00 00 00 00       	mov    $0x0,%eax
801011d4:	eb 05                	jmp    801011db <filestat+0x55>
  }
  return -1;
801011d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011db:	c9                   	leave  
801011dc:	c3                   	ret    

801011dd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011dd:	55                   	push   %ebp
801011de:	89 e5                	mov    %esp,%ebp
801011e0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e3:	8b 45 08             	mov    0x8(%ebp),%eax
801011e6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ea:	84 c0                	test   %al,%al
801011ec:	75 0a                	jne    801011f8 <fileread+0x1b>
    return -1;
801011ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f3:	e9 9b 00 00 00       	jmp    80101293 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 00                	mov    (%eax),%eax
801011fd:	83 f8 01             	cmp    $0x1,%eax
80101200:	75 1a                	jne    8010121c <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101202:	8b 45 08             	mov    0x8(%ebp),%eax
80101205:	8b 40 0c             	mov    0xc(%eax),%eax
80101208:	83 ec 04             	sub    $0x4,%esp
8010120b:	ff 75 10             	pushl  0x10(%ebp)
8010120e:	ff 75 0c             	pushl  0xc(%ebp)
80101211:	50                   	push   %eax
80101212:	e8 94 2e 00 00       	call   801040ab <piperead>
80101217:	83 c4 10             	add    $0x10,%esp
8010121a:	eb 77                	jmp    80101293 <fileread+0xb6>
  if(f->type == FD_INODE){
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	8b 00                	mov    (%eax),%eax
80101221:	83 f8 02             	cmp    $0x2,%eax
80101224:	75 60                	jne    80101286 <fileread+0xa9>
    ilock(f->ip);
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	83 ec 0c             	sub    $0xc,%esp
8010122f:	50                   	push   %eax
80101230:	e8 c8 07 00 00       	call   801019fd <ilock>
80101235:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101238:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 50 14             	mov    0x14(%eax),%edx
80101241:	8b 45 08             	mov    0x8(%ebp),%eax
80101244:	8b 40 10             	mov    0x10(%eax),%eax
80101247:	51                   	push   %ecx
80101248:	52                   	push   %edx
80101249:	ff 75 0c             	pushl  0xc(%ebp)
8010124c:	50                   	push   %eax
8010124d:	e8 9c 0c 00 00       	call   80101eee <readi>
80101252:	83 c4 10             	add    $0x10,%esp
80101255:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101258:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010125c:	7e 11                	jle    8010126f <fileread+0x92>
      f->off += r;
8010125e:	8b 45 08             	mov    0x8(%ebp),%eax
80101261:	8b 50 14             	mov    0x14(%eax),%edx
80101264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101267:	01 c2                	add    %eax,%edx
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126f:	8b 45 08             	mov    0x8(%ebp),%eax
80101272:	8b 40 10             	mov    0x10(%eax),%eax
80101275:	83 ec 0c             	sub    $0xc,%esp
80101278:	50                   	push   %eax
80101279:	e8 92 08 00 00       	call   80101b10 <iunlock>
8010127e:	83 c4 10             	add    $0x10,%esp
    return r;
80101281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101284:	eb 0d                	jmp    80101293 <fileread+0xb6>
  }
  panic("fileread");
80101286:	83 ec 0c             	sub    $0xc,%esp
80101289:	68 2b 86 10 80       	push   $0x8010862b
8010128e:	e8 0d f3 ff ff       	call   801005a0 <panic>
}
80101293:	c9                   	leave  
80101294:	c3                   	ret    

80101295 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101295:	55                   	push   %ebp
80101296:	89 e5                	mov    %esp,%ebp
80101298:	53                   	push   %ebx
80101299:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010129c:	8b 45 08             	mov    0x8(%ebp),%eax
8010129f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a3:	84 c0                	test   %al,%al
801012a5:	75 0a                	jne    801012b1 <filewrite+0x1c>
    return -1;
801012a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ac:	e9 1b 01 00 00       	jmp    801013cc <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b1:	8b 45 08             	mov    0x8(%ebp),%eax
801012b4:	8b 00                	mov    (%eax),%eax
801012b6:	83 f8 01             	cmp    $0x1,%eax
801012b9:	75 1d                	jne    801012d8 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 40 0c             	mov    0xc(%eax),%eax
801012c1:	83 ec 04             	sub    $0x4,%esp
801012c4:	ff 75 10             	pushl  0x10(%ebp)
801012c7:	ff 75 0c             	pushl  0xc(%ebp)
801012ca:	50                   	push   %eax
801012cb:	e8 de 2c 00 00       	call   80103fae <pipewrite>
801012d0:	83 c4 10             	add    $0x10,%esp
801012d3:	e9 f4 00 00 00       	jmp    801013cc <filewrite+0x137>
  if(f->type == FD_INODE){
801012d8:	8b 45 08             	mov    0x8(%ebp),%eax
801012db:	8b 00                	mov    (%eax),%eax
801012dd:	83 f8 02             	cmp    $0x2,%eax
801012e0:	0f 85 d9 00 00 00    	jne    801013bf <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012e6:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f4:	e9 a3 00 00 00       	jmp    8010139c <filewrite+0x107>
      int n1 = n - i;
801012f9:	8b 45 10             	mov    0x10(%ebp),%eax
801012fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101302:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101305:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101308:	7e 06                	jle    80101310 <filewrite+0x7b>
        n1 = max;
8010130a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130d:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101310:	e8 0d 22 00 00       	call   80103522 <begin_op>
      ilock(f->ip);
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	8b 40 10             	mov    0x10(%eax),%eax
8010131b:	83 ec 0c             	sub    $0xc,%esp
8010131e:	50                   	push   %eax
8010131f:	e8 d9 06 00 00       	call   801019fd <ilock>
80101324:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101327:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 50 14             	mov    0x14(%eax),%edx
80101330:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101333:	8b 45 0c             	mov    0xc(%ebp),%eax
80101336:	01 c3                	add    %eax,%ebx
80101338:	8b 45 08             	mov    0x8(%ebp),%eax
8010133b:	8b 40 10             	mov    0x10(%eax),%eax
8010133e:	51                   	push   %ecx
8010133f:	52                   	push   %edx
80101340:	53                   	push   %ebx
80101341:	50                   	push   %eax
80101342:	e8 fe 0c 00 00       	call   80102045 <writei>
80101347:	83 c4 10             	add    $0x10,%esp
8010134a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101351:	7e 11                	jle    80101364 <filewrite+0xcf>
        f->off += r;
80101353:	8b 45 08             	mov    0x8(%ebp),%eax
80101356:	8b 50 14             	mov    0x14(%eax),%edx
80101359:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010135c:	01 c2                	add    %eax,%edx
8010135e:	8b 45 08             	mov    0x8(%ebp),%eax
80101361:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101364:	8b 45 08             	mov    0x8(%ebp),%eax
80101367:	8b 40 10             	mov    0x10(%eax),%eax
8010136a:	83 ec 0c             	sub    $0xc,%esp
8010136d:	50                   	push   %eax
8010136e:	e8 9d 07 00 00       	call   80101b10 <iunlock>
80101373:	83 c4 10             	add    $0x10,%esp
      end_op();
80101376:	e8 33 22 00 00       	call   801035ae <end_op>

      if(r < 0)
8010137b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137f:	78 29                	js     801013aa <filewrite+0x115>
        break;
      if(r != n1)
80101381:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101384:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101387:	74 0d                	je     80101396 <filewrite+0x101>
        panic("short filewrite");
80101389:	83 ec 0c             	sub    $0xc,%esp
8010138c:	68 34 86 10 80       	push   $0x80108634
80101391:	e8 0a f2 ff ff       	call   801005a0 <panic>
      i += r;
80101396:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101399:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139f:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a2:	0f 8c 51 ff ff ff    	jl     801012f9 <filewrite+0x64>
801013a8:	eb 01                	jmp    801013ab <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013aa:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b1:	75 05                	jne    801013b8 <filewrite+0x123>
801013b3:	8b 45 10             	mov    0x10(%ebp),%eax
801013b6:	eb 14                	jmp    801013cc <filewrite+0x137>
801013b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013bd:	eb 0d                	jmp    801013cc <filewrite+0x137>
  }
  panic("filewrite");
801013bf:	83 ec 0c             	sub    $0xc,%esp
801013c2:	68 44 86 10 80       	push   $0x80108644
801013c7:	e8 d4 f1 ff ff       	call   801005a0 <panic>
}
801013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cf:	c9                   	leave  
801013d0:	c3                   	ret    

801013d1 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d1:	55                   	push   %ebp
801013d2:	89 e5                	mov    %esp,%ebp
801013d4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d7:	8b 45 08             	mov    0x8(%ebp),%eax
801013da:	83 ec 08             	sub    $0x8,%esp
801013dd:	6a 01                	push   $0x1
801013df:	50                   	push   %eax
801013e0:	e8 e9 ed ff ff       	call   801001ce <bread>
801013e5:	83 c4 10             	add    $0x10,%esp
801013e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ee:	83 c0 5c             	add    $0x5c,%eax
801013f1:	83 ec 04             	sub    $0x4,%esp
801013f4:	6a 1c                	push   $0x1c
801013f6:	50                   	push   %eax
801013f7:	ff 75 0c             	pushl  0xc(%ebp)
801013fa:	e8 89 3e 00 00       	call   80105288 <memmove>
801013ff:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101402:	83 ec 0c             	sub    $0xc,%esp
80101405:	ff 75 f4             	pushl  -0xc(%ebp)
80101408:	e8 43 ee ff ff       	call   80100250 <brelse>
8010140d:	83 c4 10             	add    $0x10,%esp
}
80101410:	90                   	nop
80101411:	c9                   	leave  
80101412:	c3                   	ret    

80101413 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101413:	55                   	push   %ebp
80101414:	89 e5                	mov    %esp,%ebp
80101416:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101419:	8b 55 0c             	mov    0xc(%ebp),%edx
8010141c:	8b 45 08             	mov    0x8(%ebp),%eax
8010141f:	83 ec 08             	sub    $0x8,%esp
80101422:	52                   	push   %edx
80101423:	50                   	push   %eax
80101424:	e8 a5 ed ff ff       	call   801001ce <bread>
80101429:	83 c4 10             	add    $0x10,%esp
8010142c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101432:	83 c0 5c             	add    $0x5c,%eax
80101435:	83 ec 04             	sub    $0x4,%esp
80101438:	68 00 02 00 00       	push   $0x200
8010143d:	6a 00                	push   $0x0
8010143f:	50                   	push   %eax
80101440:	e8 84 3d 00 00       	call   801051c9 <memset>
80101445:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101448:	83 ec 0c             	sub    $0xc,%esp
8010144b:	ff 75 f4             	pushl  -0xc(%ebp)
8010144e:	e8 07 23 00 00       	call   8010375a <log_write>
80101453:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101456:	83 ec 0c             	sub    $0xc,%esp
80101459:	ff 75 f4             	pushl  -0xc(%ebp)
8010145c:	e8 ef ed ff ff       	call   80100250 <brelse>
80101461:	83 c4 10             	add    $0x10,%esp
}
80101464:	90                   	nop
80101465:	c9                   	leave  
80101466:	c3                   	ret    

80101467 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101467:	55                   	push   %ebp
80101468:	89 e5                	mov    %esp,%ebp
8010146a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101474:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010147b:	e9 13 01 00 00       	jmp    80101593 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101483:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101489:	85 c0                	test   %eax,%eax
8010148b:	0f 48 c2             	cmovs  %edx,%eax
8010148e:	c1 f8 0c             	sar    $0xc,%eax
80101491:	89 c2                	mov    %eax,%edx
80101493:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101498:	01 d0                	add    %edx,%eax
8010149a:	83 ec 08             	sub    $0x8,%esp
8010149d:	50                   	push   %eax
8010149e:	ff 75 08             	pushl  0x8(%ebp)
801014a1:	e8 28 ed ff ff       	call   801001ce <bread>
801014a6:	83 c4 10             	add    $0x10,%esp
801014a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b3:	e9 a6 00 00 00       	jmp    8010155e <balloc+0xf7>
      m = 1 << (bi % 8);
801014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014bb:	99                   	cltd   
801014bc:	c1 ea 1d             	shr    $0x1d,%edx
801014bf:	01 d0                	add    %edx,%eax
801014c1:	83 e0 07             	and    $0x7,%eax
801014c4:	29 d0                	sub    %edx,%eax
801014c6:	ba 01 00 00 00       	mov    $0x1,%edx
801014cb:	89 c1                	mov    %eax,%ecx
801014cd:	d3 e2                	shl    %cl,%edx
801014cf:	89 d0                	mov    %edx,%eax
801014d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d7:	8d 50 07             	lea    0x7(%eax),%edx
801014da:	85 c0                	test   %eax,%eax
801014dc:	0f 48 c2             	cmovs  %edx,%eax
801014df:	c1 f8 03             	sar    $0x3,%eax
801014e2:	89 c2                	mov    %eax,%edx
801014e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e7:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014ec:	0f b6 c0             	movzbl %al,%eax
801014ef:	23 45 e8             	and    -0x18(%ebp),%eax
801014f2:	85 c0                	test   %eax,%eax
801014f4:	75 64                	jne    8010155a <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f9:	8d 50 07             	lea    0x7(%eax),%edx
801014fc:	85 c0                	test   %eax,%eax
801014fe:	0f 48 c2             	cmovs  %edx,%eax
80101501:	c1 f8 03             	sar    $0x3,%eax
80101504:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101507:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150c:	89 d1                	mov    %edx,%ecx
8010150e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101511:	09 ca                	or     %ecx,%edx
80101513:	89 d1                	mov    %edx,%ecx
80101515:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101518:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151c:	83 ec 0c             	sub    $0xc,%esp
8010151f:	ff 75 ec             	pushl  -0x14(%ebp)
80101522:	e8 33 22 00 00       	call   8010375a <log_write>
80101527:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 ec             	pushl  -0x14(%ebp)
80101530:	e8 1b ed ff ff       	call   80100250 <brelse>
80101535:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101538:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	01 c2                	add    %eax,%edx
80101540:	8b 45 08             	mov    0x8(%ebp),%eax
80101543:	83 ec 08             	sub    $0x8,%esp
80101546:	52                   	push   %edx
80101547:	50                   	push   %eax
80101548:	e8 c6 fe ff ff       	call   80101413 <bzero>
8010154d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101550:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101556:	01 d0                	add    %edx,%eax
80101558:	eb 57                	jmp    801015b1 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010155a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101565:	7f 17                	jg     8010157e <balloc+0x117>
80101567:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156d:	01 d0                	add    %edx,%eax
8010156f:	89 c2                	mov    %eax,%edx
80101571:	a1 40 1a 11 80       	mov    0x80111a40,%eax
80101576:	39 c2                	cmp    %eax,%edx
80101578:	0f 82 3a ff ff ff    	jb     801014b8 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010157e:	83 ec 0c             	sub    $0xc,%esp
80101581:	ff 75 ec             	pushl  -0x14(%ebp)
80101584:	e8 c7 ec ff ff       	call   80100250 <brelse>
80101589:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010158c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101593:	8b 15 40 1a 11 80    	mov    0x80111a40,%edx
80101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159c:	39 c2                	cmp    %eax,%edx
8010159e:	0f 87 dc fe ff ff    	ja     80101480 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015a4:	83 ec 0c             	sub    $0xc,%esp
801015a7:	68 50 86 10 80       	push   $0x80108650
801015ac:	e8 ef ef ff ff       	call   801005a0 <panic>
}
801015b1:	c9                   	leave  
801015b2:	c3                   	ret    

801015b3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b3:	55                   	push   %ebp
801015b4:	89 e5                	mov    %esp,%ebp
801015b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b9:	83 ec 08             	sub    $0x8,%esp
801015bc:	68 40 1a 11 80       	push   $0x80111a40
801015c1:	ff 75 08             	pushl  0x8(%ebp)
801015c4:	e8 08 fe ff ff       	call   801013d1 <readsb>
801015c9:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cf:	c1 e8 0c             	shr    $0xc,%eax
801015d2:	89 c2                	mov    %eax,%edx
801015d4:	a1 58 1a 11 80       	mov    0x80111a58,%eax
801015d9:	01 c2                	add    %eax,%edx
801015db:	8b 45 08             	mov    0x8(%ebp),%eax
801015de:	83 ec 08             	sub    $0x8,%esp
801015e1:	52                   	push   %edx
801015e2:	50                   	push   %eax
801015e3:	e8 e6 eb ff ff       	call   801001ce <bread>
801015e8:	83 c4 10             	add    $0x10,%esp
801015eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f1:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fc:	99                   	cltd   
801015fd:	c1 ea 1d             	shr    $0x1d,%edx
80101600:	01 d0                	add    %edx,%eax
80101602:	83 e0 07             	and    $0x7,%eax
80101605:	29 d0                	sub    %edx,%eax
80101607:	ba 01 00 00 00       	mov    $0x1,%edx
8010160c:	89 c1                	mov    %eax,%ecx
8010160e:	d3 e2                	shl    %cl,%edx
80101610:	89 d0                	mov    %edx,%eax
80101612:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101618:	8d 50 07             	lea    0x7(%eax),%edx
8010161b:	85 c0                	test   %eax,%eax
8010161d:	0f 48 c2             	cmovs  %edx,%eax
80101620:	c1 f8 03             	sar    $0x3,%eax
80101623:	89 c2                	mov    %eax,%edx
80101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101628:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010162d:	0f b6 c0             	movzbl %al,%eax
80101630:	23 45 ec             	and    -0x14(%ebp),%eax
80101633:	85 c0                	test   %eax,%eax
80101635:	75 0d                	jne    80101644 <bfree+0x91>
    panic("freeing free block");
80101637:	83 ec 0c             	sub    $0xc,%esp
8010163a:	68 66 86 10 80       	push   $0x80108666
8010163f:	e8 5c ef ff ff       	call   801005a0 <panic>
  bp->data[bi/8] &= ~m;
80101644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101647:	8d 50 07             	lea    0x7(%eax),%edx
8010164a:	85 c0                	test   %eax,%eax
8010164c:	0f 48 c2             	cmovs  %edx,%eax
8010164f:	c1 f8 03             	sar    $0x3,%eax
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010165a:	89 d1                	mov    %edx,%ecx
8010165c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010165f:	f7 d2                	not    %edx
80101661:	21 ca                	and    %ecx,%edx
80101663:	89 d1                	mov    %edx,%ecx
80101665:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101668:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010166c:	83 ec 0c             	sub    $0xc,%esp
8010166f:	ff 75 f4             	pushl  -0xc(%ebp)
80101672:	e8 e3 20 00 00       	call   8010375a <log_write>
80101677:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010167a:	83 ec 0c             	sub    $0xc,%esp
8010167d:	ff 75 f4             	pushl  -0xc(%ebp)
80101680:	e8 cb eb ff ff       	call   80100250 <brelse>
80101685:	83 c4 10             	add    $0x10,%esp
}
80101688:	90                   	nop
80101689:	c9                   	leave  
8010168a:	c3                   	ret    

8010168b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010168b:	55                   	push   %ebp
8010168c:	89 e5                	mov    %esp,%ebp
8010168e:	57                   	push   %edi
8010168f:	56                   	push   %esi
80101690:	53                   	push   %ebx
80101691:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101694:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010169b:	83 ec 08             	sub    $0x8,%esp
8010169e:	68 79 86 10 80       	push   $0x80108679
801016a3:	68 60 1a 11 80       	push   $0x80111a60
801016a8:	e8 83 38 00 00       	call   80104f30 <initlock>
801016ad:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016b7:	eb 2d                	jmp    801016e6 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016bc:	89 d0                	mov    %edx,%eax
801016be:	c1 e0 03             	shl    $0x3,%eax
801016c1:	01 d0                	add    %edx,%eax
801016c3:	c1 e0 04             	shl    $0x4,%eax
801016c6:	83 c0 30             	add    $0x30,%eax
801016c9:	05 60 1a 11 80       	add    $0x80111a60,%eax
801016ce:	83 c0 10             	add    $0x10,%eax
801016d1:	83 ec 08             	sub    $0x8,%esp
801016d4:	68 80 86 10 80       	push   $0x80108680
801016d9:	50                   	push   %eax
801016da:	e8 f4 36 00 00       	call   80104dd3 <initsleeplock>
801016df:	83 c4 10             	add    $0x10,%esp
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801016e2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016e6:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016ea:	7e cd                	jle    801016b9 <iinit+0x2e>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801016ec:	83 ec 08             	sub    $0x8,%esp
801016ef:	68 40 1a 11 80       	push   $0x80111a40
801016f4:	ff 75 08             	pushl  0x8(%ebp)
801016f7:	e8 d5 fc ff ff       	call   801013d1 <readsb>
801016fc:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ff:	a1 58 1a 11 80       	mov    0x80111a58,%eax
80101704:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101707:	8b 3d 54 1a 11 80    	mov    0x80111a54,%edi
8010170d:	8b 35 50 1a 11 80    	mov    0x80111a50,%esi
80101713:	8b 1d 4c 1a 11 80    	mov    0x80111a4c,%ebx
80101719:	8b 0d 48 1a 11 80    	mov    0x80111a48,%ecx
8010171f:	8b 15 44 1a 11 80    	mov    0x80111a44,%edx
80101725:	a1 40 1a 11 80       	mov    0x80111a40,%eax
8010172a:	ff 75 d4             	pushl  -0x2c(%ebp)
8010172d:	57                   	push   %edi
8010172e:	56                   	push   %esi
8010172f:	53                   	push   %ebx
80101730:	51                   	push   %ecx
80101731:	52                   	push   %edx
80101732:	50                   	push   %eax
80101733:	68 88 86 10 80       	push   $0x80108688
80101738:	e8 c3 ec ff ff       	call   80100400 <cprintf>
8010173d:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101740:	90                   	nop
80101741:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101744:	5b                   	pop    %ebx
80101745:	5e                   	pop    %esi
80101746:	5f                   	pop    %edi
80101747:	5d                   	pop    %ebp
80101748:	c3                   	ret    

80101749 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101749:	55                   	push   %ebp
8010174a:	89 e5                	mov    %esp,%ebp
8010174c:	83 ec 28             	sub    $0x28,%esp
8010174f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101752:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101756:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010175d:	e9 9e 00 00 00       	jmp    80101800 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101765:	c1 e8 03             	shr    $0x3,%eax
80101768:	89 c2                	mov    %eax,%edx
8010176a:	a1 54 1a 11 80       	mov    0x80111a54,%eax
8010176f:	01 d0                	add    %edx,%eax
80101771:	83 ec 08             	sub    $0x8,%esp
80101774:	50                   	push   %eax
80101775:	ff 75 08             	pushl  0x8(%ebp)
80101778:	e8 51 ea ff ff       	call   801001ce <bread>
8010177d:	83 c4 10             	add    $0x10,%esp
80101780:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101786:	8d 50 5c             	lea    0x5c(%eax),%edx
80101789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178c:	83 e0 07             	and    $0x7,%eax
8010178f:	c1 e0 06             	shl    $0x6,%eax
80101792:	01 d0                	add    %edx,%eax
80101794:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010179a:	0f b7 00             	movzwl (%eax),%eax
8010179d:	66 85 c0             	test   %ax,%ax
801017a0:	75 4c                	jne    801017ee <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017a2:	83 ec 04             	sub    $0x4,%esp
801017a5:	6a 40                	push   $0x40
801017a7:	6a 00                	push   $0x0
801017a9:	ff 75 ec             	pushl  -0x14(%ebp)
801017ac:	e8 18 3a 00 00       	call   801051c9 <memset>
801017b1:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017bb:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017be:	83 ec 0c             	sub    $0xc,%esp
801017c1:	ff 75 f0             	pushl  -0x10(%ebp)
801017c4:	e8 91 1f 00 00       	call   8010375a <log_write>
801017c9:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017cc:	83 ec 0c             	sub    $0xc,%esp
801017cf:	ff 75 f0             	pushl  -0x10(%ebp)
801017d2:	e8 79 ea ff ff       	call   80100250 <brelse>
801017d7:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017dd:	83 ec 08             	sub    $0x8,%esp
801017e0:	50                   	push   %eax
801017e1:	ff 75 08             	pushl  0x8(%ebp)
801017e4:	e8 f8 00 00 00       	call   801018e1 <iget>
801017e9:	83 c4 10             	add    $0x10,%esp
801017ec:	eb 30                	jmp    8010181e <ialloc+0xd5>
    }
    brelse(bp);
801017ee:	83 ec 0c             	sub    $0xc,%esp
801017f1:	ff 75 f0             	pushl  -0x10(%ebp)
801017f4:	e8 57 ea ff ff       	call   80100250 <brelse>
801017f9:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101800:	8b 15 48 1a 11 80    	mov    0x80111a48,%edx
80101806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101809:	39 c2                	cmp    %eax,%edx
8010180b:	0f 87 51 ff ff ff    	ja     80101762 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101811:	83 ec 0c             	sub    $0xc,%esp
80101814:	68 db 86 10 80       	push   $0x801086db
80101819:	e8 82 ed ff ff       	call   801005a0 <panic>
}
8010181e:	c9                   	leave  
8010181f:	c3                   	ret    

80101820 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101820:	55                   	push   %ebp
80101821:	89 e5                	mov    %esp,%ebp
80101823:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101826:	8b 45 08             	mov    0x8(%ebp),%eax
80101829:	8b 40 04             	mov    0x4(%eax),%eax
8010182c:	c1 e8 03             	shr    $0x3,%eax
8010182f:	89 c2                	mov    %eax,%edx
80101831:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101836:	01 c2                	add    %eax,%edx
80101838:	8b 45 08             	mov    0x8(%ebp),%eax
8010183b:	8b 00                	mov    (%eax),%eax
8010183d:	83 ec 08             	sub    $0x8,%esp
80101840:	52                   	push   %edx
80101841:	50                   	push   %eax
80101842:	e8 87 e9 ff ff       	call   801001ce <bread>
80101847:	83 c4 10             	add    $0x10,%esp
8010184a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	8d 50 5c             	lea    0x5c(%eax),%edx
80101853:	8b 45 08             	mov    0x8(%ebp),%eax
80101856:	8b 40 04             	mov    0x4(%eax),%eax
80101859:	83 e0 07             	and    $0x7,%eax
8010185c:	c1 e0 06             	shl    $0x6,%eax
8010185f:	01 d0                	add    %edx,%eax
80101861:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101864:	8b 45 08             	mov    0x8(%ebp),%eax
80101867:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010186b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186e:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101871:	8b 45 08             	mov    0x8(%ebp),%eax
80101874:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187b:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101889:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010188d:	8b 45 08             	mov    0x8(%ebp),%eax
80101890:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101894:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101897:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010189b:	8b 45 08             	mov    0x8(%ebp),%eax
8010189e:	8b 50 58             	mov    0x58(%eax),%edx
801018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a4:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018a7:	8b 45 08             	mov    0x8(%ebp),%eax
801018aa:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b0:	83 c0 0c             	add    $0xc,%eax
801018b3:	83 ec 04             	sub    $0x4,%esp
801018b6:	6a 34                	push   $0x34
801018b8:	52                   	push   %edx
801018b9:	50                   	push   %eax
801018ba:	e8 c9 39 00 00       	call   80105288 <memmove>
801018bf:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018c2:	83 ec 0c             	sub    $0xc,%esp
801018c5:	ff 75 f4             	pushl  -0xc(%ebp)
801018c8:	e8 8d 1e 00 00       	call   8010375a <log_write>
801018cd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018d0:	83 ec 0c             	sub    $0xc,%esp
801018d3:	ff 75 f4             	pushl  -0xc(%ebp)
801018d6:	e8 75 e9 ff ff       	call   80100250 <brelse>
801018db:	83 c4 10             	add    $0x10,%esp
}
801018de:	90                   	nop
801018df:	c9                   	leave  
801018e0:	c3                   	ret    

801018e1 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018e1:	55                   	push   %ebp
801018e2:	89 e5                	mov    %esp,%ebp
801018e4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018e7:	83 ec 0c             	sub    $0xc,%esp
801018ea:	68 60 1a 11 80       	push   $0x80111a60
801018ef:	e8 5e 36 00 00       	call   80104f52 <acquire>
801018f4:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018fe:	c7 45 f4 94 1a 11 80 	movl   $0x80111a94,-0xc(%ebp)
80101905:	eb 60                	jmp    80101967 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	8b 40 08             	mov    0x8(%eax),%eax
8010190d:	85 c0                	test   %eax,%eax
8010190f:	7e 39                	jle    8010194a <iget+0x69>
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	8b 00                	mov    (%eax),%eax
80101916:	3b 45 08             	cmp    0x8(%ebp),%eax
80101919:	75 2f                	jne    8010194a <iget+0x69>
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 04             	mov    0x4(%eax),%eax
80101921:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101924:	75 24                	jne    8010194a <iget+0x69>
      ip->ref++;
80101926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101929:	8b 40 08             	mov    0x8(%eax),%eax
8010192c:	8d 50 01             	lea    0x1(%eax),%edx
8010192f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101932:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101935:	83 ec 0c             	sub    $0xc,%esp
80101938:	68 60 1a 11 80       	push   $0x80111a60
8010193d:	e8 7e 36 00 00       	call   80104fc0 <release>
80101942:	83 c4 10             	add    $0x10,%esp
      return ip;
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	eb 77                	jmp    801019c1 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010194a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010194e:	75 10                	jne    80101960 <iget+0x7f>
80101950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101953:	8b 40 08             	mov    0x8(%eax),%eax
80101956:	85 c0                	test   %eax,%eax
80101958:	75 06                	jne    80101960 <iget+0x7f>
      empty = ip;
8010195a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101960:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101967:	81 7d f4 b4 36 11 80 	cmpl   $0x801136b4,-0xc(%ebp)
8010196e:	72 97                	jb     80101907 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101970:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101974:	75 0d                	jne    80101983 <iget+0xa2>
    panic("iget: no inodes");
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	68 ed 86 10 80       	push   $0x801086ed
8010197e:	e8 1d ec ff ff       	call   801005a0 <panic>

  ip = empty;
80101983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101986:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198c:	8b 55 08             	mov    0x8(%ebp),%edx
8010198f:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	8b 55 0c             	mov    0xc(%ebp),%edx
80101997:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019ae:	83 ec 0c             	sub    $0xc,%esp
801019b1:	68 60 1a 11 80       	push   $0x80111a60
801019b6:	e8 05 36 00 00       	call   80104fc0 <release>
801019bb:	83 c4 10             	add    $0x10,%esp

  return ip;
801019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019c1:	c9                   	leave  
801019c2:	c3                   	ret    

801019c3 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019c3:	55                   	push   %ebp
801019c4:	89 e5                	mov    %esp,%ebp
801019c6:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 60 1a 11 80       	push   $0x80111a60
801019d1:	e8 7c 35 00 00       	call   80104f52 <acquire>
801019d6:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019d9:	8b 45 08             	mov    0x8(%ebp),%eax
801019dc:	8b 40 08             	mov    0x8(%eax),%eax
801019df:	8d 50 01             	lea    0x1(%eax),%edx
801019e2:	8b 45 08             	mov    0x8(%ebp),%eax
801019e5:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019e8:	83 ec 0c             	sub    $0xc,%esp
801019eb:	68 60 1a 11 80       	push   $0x80111a60
801019f0:	e8 cb 35 00 00       	call   80104fc0 <release>
801019f5:	83 c4 10             	add    $0x10,%esp
  return ip;
801019f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019fb:	c9                   	leave  
801019fc:	c3                   	ret    

801019fd <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019fd:	55                   	push   %ebp
801019fe:	89 e5                	mov    %esp,%ebp
80101a00:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a07:	74 0a                	je     80101a13 <ilock+0x16>
80101a09:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0c:	8b 40 08             	mov    0x8(%eax),%eax
80101a0f:	85 c0                	test   %eax,%eax
80101a11:	7f 0d                	jg     80101a20 <ilock+0x23>
    panic("ilock");
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	68 fd 86 10 80       	push   $0x801086fd
80101a1b:	e8 80 eb ff ff       	call   801005a0 <panic>

  acquiresleep(&ip->lock);
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	83 c0 0c             	add    $0xc,%eax
80101a26:	83 ec 0c             	sub    $0xc,%esp
80101a29:	50                   	push   %eax
80101a2a:	e8 e0 33 00 00       	call   80104e0f <acquiresleep>
80101a2f:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	0f 85 cd 00 00 00    	jne    80101b0d <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 40 04             	mov    0x4(%eax),%eax
80101a46:	c1 e8 03             	shr    $0x3,%eax
80101a49:	89 c2                	mov    %eax,%edx
80101a4b:	a1 54 1a 11 80       	mov    0x80111a54,%eax
80101a50:	01 c2                	add    %eax,%edx
80101a52:	8b 45 08             	mov    0x8(%ebp),%eax
80101a55:	8b 00                	mov    (%eax),%eax
80101a57:	83 ec 08             	sub    $0x8,%esp
80101a5a:	52                   	push   %edx
80101a5b:	50                   	push   %eax
80101a5c:	e8 6d e7 ff ff       	call   801001ce <bread>
80101a61:	83 c4 10             	add    $0x10,%esp
80101a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a70:	8b 40 04             	mov    0x4(%eax),%eax
80101a73:	83 e0 07             	and    $0x7,%eax
80101a76:	c1 e0 06             	shl    $0x6,%eax
80101a79:	01 d0                	add    %edx,%eax
80101a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a81:	0f b7 10             	movzwl (%eax),%edx
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a92:	8b 45 08             	mov    0x8(%ebp),%eax
80101a95:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa3:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aaa:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab8:	8b 50 08             	mov    0x8(%eax),%edx
80101abb:	8b 45 08             	mov    0x8(%ebp),%eax
80101abe:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac4:	8d 50 0c             	lea    0xc(%eax),%edx
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	83 c0 5c             	add    $0x5c,%eax
80101acd:	83 ec 04             	sub    $0x4,%esp
80101ad0:	6a 34                	push   $0x34
80101ad2:	52                   	push   %edx
80101ad3:	50                   	push   %eax
80101ad4:	e8 af 37 00 00       	call   80105288 <memmove>
80101ad9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101adc:	83 ec 0c             	sub    $0xc,%esp
80101adf:	ff 75 f4             	pushl  -0xc(%ebp)
80101ae2:	e8 69 e7 ff ff       	call   80100250 <brelse>
80101ae7:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101af4:	8b 45 08             	mov    0x8(%ebp),%eax
80101af7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101afb:	66 85 c0             	test   %ax,%ax
80101afe:	75 0d                	jne    80101b0d <ilock+0x110>
      panic("ilock: no type");
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	68 03 87 10 80       	push   $0x80108703
80101b08:	e8 93 ea ff ff       	call   801005a0 <panic>
  }
}
80101b0d:	90                   	nop
80101b0e:	c9                   	leave  
80101b0f:	c3                   	ret    

80101b10 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b10:	55                   	push   %ebp
80101b11:	89 e5                	mov    %esp,%ebp
80101b13:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b16:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b1a:	74 20                	je     80101b3c <iunlock+0x2c>
80101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1f:	83 c0 0c             	add    $0xc,%eax
80101b22:	83 ec 0c             	sub    $0xc,%esp
80101b25:	50                   	push   %eax
80101b26:	e8 96 33 00 00       	call   80104ec1 <holdingsleep>
80101b2b:	83 c4 10             	add    $0x10,%esp
80101b2e:	85 c0                	test   %eax,%eax
80101b30:	74 0a                	je     80101b3c <iunlock+0x2c>
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	8b 40 08             	mov    0x8(%eax),%eax
80101b38:	85 c0                	test   %eax,%eax
80101b3a:	7f 0d                	jg     80101b49 <iunlock+0x39>
    panic("iunlock");
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	68 12 87 10 80       	push   $0x80108712
80101b44:	e8 57 ea ff ff       	call   801005a0 <panic>

  releasesleep(&ip->lock);
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	83 c0 0c             	add    $0xc,%eax
80101b4f:	83 ec 0c             	sub    $0xc,%esp
80101b52:	50                   	push   %eax
80101b53:	e8 1b 33 00 00       	call   80104e73 <releasesleep>
80101b58:	83 c4 10             	add    $0x10,%esp
}
80101b5b:	90                   	nop
80101b5c:	c9                   	leave  
80101b5d:	c3                   	ret    

80101b5e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b5e:	55                   	push   %ebp
80101b5f:	89 e5                	mov    %esp,%ebp
80101b61:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	50                   	push   %eax
80101b6e:	e8 9c 32 00 00       	call   80104e0f <acquiresleep>
80101b73:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b76:	8b 45 08             	mov    0x8(%ebp),%eax
80101b79:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b7c:	85 c0                	test   %eax,%eax
80101b7e:	74 6a                	je     80101bea <iput+0x8c>
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b87:	66 85 c0             	test   %ax,%ax
80101b8a:	75 5e                	jne    80101bea <iput+0x8c>
    acquire(&icache.lock);
80101b8c:	83 ec 0c             	sub    $0xc,%esp
80101b8f:	68 60 1a 11 80       	push   $0x80111a60
80101b94:	e8 b9 33 00 00       	call   80104f52 <acquire>
80101b99:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ba5:	83 ec 0c             	sub    $0xc,%esp
80101ba8:	68 60 1a 11 80       	push   $0x80111a60
80101bad:	e8 0e 34 00 00       	call   80104fc0 <release>
80101bb2:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bb5:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bb9:	75 2f                	jne    80101bea <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 b2 01 00 00       	call   80101d78 <itrunc>
80101bc6:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 08             	pushl  0x8(%ebp)
80101bd8:	e8 43 fc ff ff       	call   80101820 <iupdate>
80101bdd:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	83 c0 0c             	add    $0xc,%eax
80101bf0:	83 ec 0c             	sub    $0xc,%esp
80101bf3:	50                   	push   %eax
80101bf4:	e8 7a 32 00 00       	call   80104e73 <releasesleep>
80101bf9:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bfc:	83 ec 0c             	sub    $0xc,%esp
80101bff:	68 60 1a 11 80       	push   $0x80111a60
80101c04:	e8 49 33 00 00       	call   80104f52 <acquire>
80101c09:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 40 08             	mov    0x8(%eax),%eax
80101c12:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c15:	8b 45 08             	mov    0x8(%ebp),%eax
80101c18:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c1b:	83 ec 0c             	sub    $0xc,%esp
80101c1e:	68 60 1a 11 80       	push   $0x80111a60
80101c23:	e8 98 33 00 00       	call   80104fc0 <release>
80101c28:	83 c4 10             	add    $0x10,%esp
}
80101c2b:	90                   	nop
80101c2c:	c9                   	leave  
80101c2d:	c3                   	ret    

80101c2e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2e:	55                   	push   %ebp
80101c2f:	89 e5                	mov    %esp,%ebp
80101c31:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	ff 75 08             	pushl  0x8(%ebp)
80101c3a:	e8 d1 fe ff ff       	call   80101b10 <iunlock>
80101c3f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c42:	83 ec 0c             	sub    $0xc,%esp
80101c45:	ff 75 08             	pushl  0x8(%ebp)
80101c48:	e8 11 ff ff ff       	call   80101b5e <iput>
80101c4d:	83 c4 10             	add    $0x10,%esp
}
80101c50:	90                   	nop
80101c51:	c9                   	leave  
80101c52:	c3                   	ret    

80101c53 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c53:	55                   	push   %ebp
80101c54:	89 e5                	mov    %esp,%ebp
80101c56:	53                   	push   %ebx
80101c57:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c5a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5e:	77 42                	ja     80101ca2 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c60:	8b 45 08             	mov    0x8(%ebp),%eax
80101c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c66:	83 c2 14             	add    $0x14,%edx
80101c69:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c74:	75 24                	jne    80101c9a <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 00                	mov    (%eax),%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 e3 f7 ff ff       	call   80101467 <balloc>
80101c84:	83 c4 10             	add    $0x10,%esp
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c90:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c96:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c9d:	e9 d1 00 00 00       	jmp    80101d73 <bmap+0x120>
  }
  bn -= NDIRECT;
80101ca2:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca6:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101caa:	0f 87 b6 00 00 00    	ja     80101d66 <bmap+0x113>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cc0:	75 20                	jne    80101ce2 <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 00                	mov    (%eax),%eax
80101cc7:	83 ec 0c             	sub    $0xc,%esp
80101cca:	50                   	push   %eax
80101ccb:	e8 97 f7 ff ff       	call   80101467 <balloc>
80101cd0:	83 c4 10             	add    $0x10,%esp
80101cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cdc:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	8b 00                	mov    (%eax),%eax
80101ce7:	83 ec 08             	sub    $0x8,%esp
80101cea:	ff 75 f4             	pushl  -0xc(%ebp)
80101ced:	50                   	push   %eax
80101cee:	e8 db e4 ff ff       	call   801001ce <bread>
80101cf3:	83 c4 10             	add    $0x10,%esp
80101cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cfc:	83 c0 5c             	add    $0x5c,%eax
80101cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d0f:	01 d0                	add    %edx,%eax
80101d11:	8b 00                	mov    (%eax),%eax
80101d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d1a:	75 37                	jne    80101d53 <bmap+0x100>
      a[bn] = addr = balloc(ip->dev);
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	8b 00                	mov    (%eax),%eax
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	50                   	push   %eax
80101d35:	e8 2d f7 ff ff       	call   80101467 <balloc>
80101d3a:	83 c4 10             	add    $0x10,%esp
80101d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d43:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d45:	83 ec 0c             	sub    $0xc,%esp
80101d48:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4b:	e8 0a 1a 00 00       	call   8010375a <log_write>
80101d50:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d53:	83 ec 0c             	sub    $0xc,%esp
80101d56:	ff 75 f0             	pushl  -0x10(%ebp)
80101d59:	e8 f2 e4 ff ff       	call   80100250 <brelse>
80101d5e:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d64:	eb 0d                	jmp    80101d73 <bmap+0x120>
  }

  panic("bmap: out of range");
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 1a 87 10 80       	push   $0x8010871a
80101d6e:	e8 2d e8 ff ff       	call   801005a0 <panic>
}
80101d73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d76:	c9                   	leave  
80101d77:	c3                   	ret    

80101d78 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d78:	55                   	push   %ebp
80101d79:	89 e5                	mov    %esp,%ebp
80101d7b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d85:	eb 45                	jmp    80101dcc <itrunc+0x54>
    if(ip->addrs[i]){
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8d:	83 c2 14             	add    $0x14,%edx
80101d90:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d94:	85 c0                	test   %eax,%eax
80101d96:	74 30                	je     80101dc8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d98:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9e:	83 c2 14             	add    $0x14,%edx
80101da1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da5:	8b 55 08             	mov    0x8(%ebp),%edx
80101da8:	8b 12                	mov    (%edx),%edx
80101daa:	83 ec 08             	sub    $0x8,%esp
80101dad:	50                   	push   %eax
80101dae:	52                   	push   %edx
80101daf:	e8 ff f7 ff ff       	call   801015b3 <bfree>
80101db4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101db7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dbd:	83 c2 14             	add    $0x14,%edx
80101dc0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dc7:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dc8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dcc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dd0:	7e b5                	jle    80101d87 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ddb:	85 c0                	test   %eax,%eax
80101ddd:	0f 84 aa 00 00 00    	je     80101e8d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dec:	8b 45 08             	mov    0x8(%ebp),%eax
80101def:	8b 00                	mov    (%eax),%eax
80101df1:	83 ec 08             	sub    $0x8,%esp
80101df4:	52                   	push   %edx
80101df5:	50                   	push   %eax
80101df6:	e8 d3 e3 ff ff       	call   801001ce <bread>
80101dfb:	83 c4 10             	add    $0x10,%esp
80101dfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e04:	83 c0 5c             	add    $0x5c,%eax
80101e07:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e11:	eb 3c                	jmp    80101e4f <itrunc+0xd7>
      if(a[j])
80101e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e20:	01 d0                	add    %edx,%eax
80101e22:	8b 00                	mov    (%eax),%eax
80101e24:	85 c0                	test   %eax,%eax
80101e26:	74 23                	je     80101e4b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e35:	01 d0                	add    %edx,%eax
80101e37:	8b 00                	mov    (%eax),%eax
80101e39:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3c:	8b 12                	mov    (%edx),%edx
80101e3e:	83 ec 08             	sub    $0x8,%esp
80101e41:	50                   	push   %eax
80101e42:	52                   	push   %edx
80101e43:	e8 6b f7 ff ff       	call   801015b3 <bfree>
80101e48:	83 c4 10             	add    $0x10,%esp
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e4b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e52:	83 f8 7f             	cmp    $0x7f,%eax
80101e55:	76 bc                	jbe    80101e13 <itrunc+0x9b>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e57:	83 ec 0c             	sub    $0xc,%esp
80101e5a:	ff 75 ec             	pushl  -0x14(%ebp)
80101e5d:	e8 ee e3 ff ff       	call   80100250 <brelse>
80101e62:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e71:	8b 12                	mov    (%edx),%edx
80101e73:	83 ec 08             	sub    $0x8,%esp
80101e76:	50                   	push   %eax
80101e77:	52                   	push   %edx
80101e78:	e8 36 f7 ff ff       	call   801015b3 <bfree>
80101e7d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e8a:	00 00 00 
  }

  ip->size = 0;
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e97:	83 ec 0c             	sub    $0xc,%esp
80101e9a:	ff 75 08             	pushl  0x8(%ebp)
80101e9d:	e8 7e f9 ff ff       	call   80101820 <iupdate>
80101ea2:	83 c4 10             	add    $0x10,%esp
}
80101ea5:	90                   	nop
80101ea6:	c9                   	leave  
80101ea7:	c3                   	ret    

80101ea8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ea8:	55                   	push   %ebp
80101ea9:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eab:	8b 45 08             	mov    0x8(%ebp),%eax
80101eae:	8b 00                	mov    (%eax),%eax
80101eb0:	89 c2                	mov    %eax,%edx
80101eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebb:	8b 50 04             	mov    0x4(%eax),%edx
80101ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ece:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	8b 50 58             	mov    0x58(%eax),%edx
80101ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eeb:	90                   	nop
80101eec:	5d                   	pop    %ebp
80101eed:	c3                   	ret    

80101eee <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101eee:	55                   	push   %ebp
80101eef:	89 e5                	mov    %esp,%ebp
80101ef1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101efb:	66 83 f8 03          	cmp    $0x3,%ax
80101eff:	75 5c                	jne    80101f5d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f08:	66 85 c0             	test   %ax,%ax
80101f0b:	78 20                	js     80101f2d <readi+0x3f>
80101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f10:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f14:	66 83 f8 09          	cmp    $0x9,%ax
80101f18:	7f 13                	jg     80101f2d <readi+0x3f>
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f21:	98                   	cwtl   
80101f22:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101f29:	85 c0                	test   %eax,%eax
80101f2b:	75 0a                	jne    80101f37 <readi+0x49>
      return -1;
80101f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f32:	e9 0c 01 00 00       	jmp    80102043 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f3e:	98                   	cwtl   
80101f3f:	8b 04 c5 e0 19 11 80 	mov    -0x7feee620(,%eax,8),%eax
80101f46:	8b 55 14             	mov    0x14(%ebp),%edx
80101f49:	83 ec 04             	sub    $0x4,%esp
80101f4c:	52                   	push   %edx
80101f4d:	ff 75 0c             	pushl  0xc(%ebp)
80101f50:	ff 75 08             	pushl  0x8(%ebp)
80101f53:	ff d0                	call   *%eax
80101f55:	83 c4 10             	add    $0x10,%esp
80101f58:	e9 e6 00 00 00       	jmp    80102043 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	8b 40 58             	mov    0x58(%eax),%eax
80101f63:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f66:	72 0d                	jb     80101f75 <readi+0x87>
80101f68:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	01 d0                	add    %edx,%eax
80101f70:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f73:	73 0a                	jae    80101f7f <readi+0x91>
    return -1;
80101f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7a:	e9 c4 00 00 00       	jmp    80102043 <readi+0x155>
  if(off + n > ip->size)
80101f7f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f82:	8b 45 14             	mov    0x14(%ebp),%eax
80101f85:	01 c2                	add    %eax,%edx
80101f87:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8a:	8b 40 58             	mov    0x58(%eax),%eax
80101f8d:	39 c2                	cmp    %eax,%edx
80101f8f:	76 0c                	jbe    80101f9d <readi+0xaf>
    n = ip->size - off;
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	8b 40 58             	mov    0x58(%eax),%eax
80101f97:	2b 45 10             	sub    0x10(%ebp),%eax
80101f9a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa4:	e9 8b 00 00 00       	jmp    80102034 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fa9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fac:	c1 e8 09             	shr    $0x9,%eax
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	50                   	push   %eax
80101fb3:	ff 75 08             	pushl  0x8(%ebp)
80101fb6:	e8 98 fc ff ff       	call   80101c53 <bmap>
80101fbb:	83 c4 10             	add    $0x10,%esp
80101fbe:	89 c2                	mov    %eax,%edx
80101fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc3:	8b 00                	mov    (%eax),%eax
80101fc5:	83 ec 08             	sub    $0x8,%esp
80101fc8:	52                   	push   %edx
80101fc9:	50                   	push   %eax
80101fca:	e8 ff e1 ff ff       	call   801001ce <bread>
80101fcf:	83 c4 10             	add    $0x10,%esp
80101fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdd:	ba 00 02 00 00       	mov    $0x200,%edx
80101fe2:	29 c2                	sub    %eax,%edx
80101fe4:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fea:	39 c2                	cmp    %eax,%edx
80101fec:	0f 46 c2             	cmovbe %edx,%eax
80101fef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff5:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ff8:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffb:	25 ff 01 00 00       	and    $0x1ff,%eax
80102000:	01 d0                	add    %edx,%eax
80102002:	83 ec 04             	sub    $0x4,%esp
80102005:	ff 75 ec             	pushl  -0x14(%ebp)
80102008:	50                   	push   %eax
80102009:	ff 75 0c             	pushl  0xc(%ebp)
8010200c:	e8 77 32 00 00       	call   80105288 <memmove>
80102011:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102014:	83 ec 0c             	sub    $0xc,%esp
80102017:	ff 75 f0             	pushl  -0x10(%ebp)
8010201a:	e8 31 e2 ff ff       	call   80100250 <brelse>
8010201f:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102022:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102025:	01 45 f4             	add    %eax,-0xc(%ebp)
80102028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202b:	01 45 10             	add    %eax,0x10(%ebp)
8010202e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102031:	01 45 0c             	add    %eax,0xc(%ebp)
80102034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102037:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203a:	0f 82 69 ff ff ff    	jb     80101fa9 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102040:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102043:	c9                   	leave  
80102044:	c3                   	ret    

80102045 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102045:	55                   	push   %ebp
80102046:	89 e5                	mov    %esp,%ebp
80102048:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102052:	66 83 f8 03          	cmp    $0x3,%ax
80102056:	75 5c                	jne    801020b4 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205f:	66 85 c0             	test   %ax,%ax
80102062:	78 20                	js     80102084 <writei+0x3f>
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206b:	66 83 f8 09          	cmp    $0x9,%ax
8010206f:	7f 13                	jg     80102084 <writei+0x3f>
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102078:	98                   	cwtl   
80102079:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
80102080:	85 c0                	test   %eax,%eax
80102082:	75 0a                	jne    8010208e <writei+0x49>
      return -1;
80102084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102089:	e9 3d 01 00 00       	jmp    801021cb <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102095:	98                   	cwtl   
80102096:	8b 04 c5 e4 19 11 80 	mov    -0x7feee61c(,%eax,8),%eax
8010209d:	8b 55 14             	mov    0x14(%ebp),%edx
801020a0:	83 ec 04             	sub    $0x4,%esp
801020a3:	52                   	push   %edx
801020a4:	ff 75 0c             	pushl  0xc(%ebp)
801020a7:	ff 75 08             	pushl  0x8(%ebp)
801020aa:	ff d0                	call   *%eax
801020ac:	83 c4 10             	add    $0x10,%esp
801020af:	e9 17 01 00 00       	jmp    801021cb <writei+0x186>
  }

  if(off > ip->size || off + n < off)
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	8b 40 58             	mov    0x58(%eax),%eax
801020ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bd:	72 0d                	jb     801020cc <writei+0x87>
801020bf:	8b 55 10             	mov    0x10(%ebp),%edx
801020c2:	8b 45 14             	mov    0x14(%ebp),%eax
801020c5:	01 d0                	add    %edx,%eax
801020c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ca:	73 0a                	jae    801020d6 <writei+0x91>
    return -1;
801020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d1:	e9 f5 00 00 00       	jmp    801021cb <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020d6:	8b 55 10             	mov    0x10(%ebp),%edx
801020d9:	8b 45 14             	mov    0x14(%ebp),%eax
801020dc:	01 d0                	add    %edx,%eax
801020de:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e3:	76 0a                	jbe    801020ef <writei+0xaa>
    return -1;
801020e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ea:	e9 dc 00 00 00       	jmp    801021cb <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f6:	e9 99 00 00 00       	jmp    80102194 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fb:	8b 45 10             	mov    0x10(%ebp),%eax
801020fe:	c1 e8 09             	shr    $0x9,%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	50                   	push   %eax
80102105:	ff 75 08             	pushl  0x8(%ebp)
80102108:	e8 46 fb ff ff       	call   80101c53 <bmap>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 c2                	mov    %eax,%edx
80102112:	8b 45 08             	mov    0x8(%ebp),%eax
80102115:	8b 00                	mov    (%eax),%eax
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	52                   	push   %edx
8010211b:	50                   	push   %eax
8010211c:	e8 ad e0 ff ff       	call   801001ce <bread>
80102121:	83 c4 10             	add    $0x10,%esp
80102124:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102127:	8b 45 10             	mov    0x10(%ebp),%eax
8010212a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212f:	ba 00 02 00 00       	mov    $0x200,%edx
80102134:	29 c2                	sub    %eax,%edx
80102136:	8b 45 14             	mov    0x14(%ebp),%eax
80102139:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010213c:	39 c2                	cmp    %eax,%edx
8010213e:	0f 46 c2             	cmovbe %edx,%eax
80102141:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102147:	8d 50 5c             	lea    0x5c(%eax),%edx
8010214a:	8b 45 10             	mov    0x10(%ebp),%eax
8010214d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102152:	01 d0                	add    %edx,%eax
80102154:	83 ec 04             	sub    $0x4,%esp
80102157:	ff 75 ec             	pushl  -0x14(%ebp)
8010215a:	ff 75 0c             	pushl  0xc(%ebp)
8010215d:	50                   	push   %eax
8010215e:	e8 25 31 00 00       	call   80105288 <memmove>
80102163:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	ff 75 f0             	pushl  -0x10(%ebp)
8010216c:	e8 e9 15 00 00       	call   8010375a <log_write>
80102171:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	pushl  -0x10(%ebp)
8010217a:	e8 d1 e0 ff ff       	call   80100250 <brelse>
8010217f:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102185:	01 45 f4             	add    %eax,-0xc(%ebp)
80102188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218b:	01 45 10             	add    %eax,0x10(%ebp)
8010218e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102191:	01 45 0c             	add    %eax,0xc(%ebp)
80102194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102197:	3b 45 14             	cmp    0x14(%ebp),%eax
8010219a:	0f 82 5b ff ff ff    	jb     801020fb <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021a0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021a4:	74 22                	je     801021c8 <writei+0x183>
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 40 58             	mov    0x58(%eax),%eax
801021ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801021af:	73 17                	jae    801021c8 <writei+0x183>
    ip->size = off;
801021b1:	8b 45 08             	mov    0x8(%ebp),%eax
801021b4:	8b 55 10             	mov    0x10(%ebp),%edx
801021b7:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021ba:	83 ec 0c             	sub    $0xc,%esp
801021bd:	ff 75 08             	pushl  0x8(%ebp)
801021c0:	e8 5b f6 ff ff       	call   80101820 <iupdate>
801021c5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021cb:	c9                   	leave  
801021cc:	c3                   	ret    

801021cd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021d3:	83 ec 04             	sub    $0x4,%esp
801021d6:	6a 0e                	push   $0xe
801021d8:	ff 75 0c             	pushl  0xc(%ebp)
801021db:	ff 75 08             	pushl  0x8(%ebp)
801021de:	e8 3b 31 00 00       	call   8010531e <strncmp>
801021e3:	83 c4 10             	add    $0x10,%esp
}
801021e6:	c9                   	leave  
801021e7:	c3                   	ret    

801021e8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021e8:	55                   	push   %ebp
801021e9:	89 e5                	mov    %esp,%ebp
801021eb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ee:	8b 45 08             	mov    0x8(%ebp),%eax
801021f1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021f5:	66 83 f8 01          	cmp    $0x1,%ax
801021f9:	74 0d                	je     80102208 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	68 2d 87 10 80       	push   $0x8010872d
80102203:	e8 98 e3 ff ff       	call   801005a0 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220f:	eb 7b                	jmp    8010228c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102211:	6a 10                	push   $0x10
80102213:	ff 75 f4             	pushl  -0xc(%ebp)
80102216:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102219:	50                   	push   %eax
8010221a:	ff 75 08             	pushl  0x8(%ebp)
8010221d:	e8 cc fc ff ff       	call   80101eee <readi>
80102222:	83 c4 10             	add    $0x10,%esp
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0d                	je     80102237 <dirlookup+0x4f>
      panic("dirlookup read");
8010222a:	83 ec 0c             	sub    $0xc,%esp
8010222d:	68 3f 87 10 80       	push   $0x8010873f
80102232:	e8 69 e3 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
80102237:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223b:	66 85 c0             	test   %ax,%ax
8010223e:	74 47                	je     80102287 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102240:	83 ec 08             	sub    $0x8,%esp
80102243:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102246:	83 c0 02             	add    $0x2,%eax
80102249:	50                   	push   %eax
8010224a:	ff 75 0c             	pushl  0xc(%ebp)
8010224d:	e8 7b ff ff ff       	call   801021cd <namecmp>
80102252:	83 c4 10             	add    $0x10,%esp
80102255:	85 c0                	test   %eax,%eax
80102257:	75 2f                	jne    80102288 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010225d:	74 08                	je     80102267 <dirlookup+0x7f>
        *poff = off;
8010225f:	8b 45 10             	mov    0x10(%ebp),%eax
80102262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102265:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102267:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010226b:	0f b7 c0             	movzwl %ax,%eax
8010226e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 00                	mov    (%eax),%eax
80102276:	83 ec 08             	sub    $0x8,%esp
80102279:	ff 75 f0             	pushl  -0x10(%ebp)
8010227c:	50                   	push   %eax
8010227d:	e8 5f f6 ff ff       	call   801018e1 <iget>
80102282:	83 c4 10             	add    $0x10,%esp
80102285:	eb 19                	jmp    801022a0 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
80102287:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102288:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	8b 40 58             	mov    0x58(%eax),%eax
80102292:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102295:	0f 87 76 ff ff ff    	ja     80102211 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010229b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a0:	c9                   	leave  
801022a1:	c3                   	ret    

801022a2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a2:	55                   	push   %ebp
801022a3:	89 e5                	mov    %esp,%ebp
801022a5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022a8:	83 ec 04             	sub    $0x4,%esp
801022ab:	6a 00                	push   $0x0
801022ad:	ff 75 0c             	pushl  0xc(%ebp)
801022b0:	ff 75 08             	pushl  0x8(%ebp)
801022b3:	e8 30 ff ff ff       	call   801021e8 <dirlookup>
801022b8:	83 c4 10             	add    $0x10,%esp
801022bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022c2:	74 18                	je     801022dc <dirlink+0x3a>
    iput(ip);
801022c4:	83 ec 0c             	sub    $0xc,%esp
801022c7:	ff 75 f0             	pushl  -0x10(%ebp)
801022ca:	e8 8f f8 ff ff       	call   80101b5e <iput>
801022cf:	83 c4 10             	add    $0x10,%esp
    return -1;
801022d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d7:	e9 9c 00 00 00       	jmp    80102378 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e3:	eb 39                	jmp    8010231e <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e8:	6a 10                	push   $0x10
801022ea:	50                   	push   %eax
801022eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ee:	50                   	push   %eax
801022ef:	ff 75 08             	pushl  0x8(%ebp)
801022f2:	e8 f7 fb ff ff       	call   80101eee <readi>
801022f7:	83 c4 10             	add    $0x10,%esp
801022fa:	83 f8 10             	cmp    $0x10,%eax
801022fd:	74 0d                	je     8010230c <dirlink+0x6a>
      panic("dirlink read");
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	68 4e 87 10 80       	push   $0x8010874e
80102307:	e8 94 e2 ff ff       	call   801005a0 <panic>
    if(de.inum == 0)
8010230c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102310:	66 85 c0             	test   %ax,%ax
80102313:	74 18                	je     8010232d <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102318:	83 c0 10             	add    $0x10,%eax
8010231b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 50 58             	mov    0x58(%eax),%edx
80102324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102327:	39 c2                	cmp    %eax,%edx
80102329:	77 ba                	ja     801022e5 <dirlink+0x43>
8010232b:	eb 01                	jmp    8010232e <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010232d:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010232e:	83 ec 04             	sub    $0x4,%esp
80102331:	6a 0e                	push   $0xe
80102333:	ff 75 0c             	pushl  0xc(%ebp)
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	83 c0 02             	add    $0x2,%eax
8010233c:	50                   	push   %eax
8010233d:	e8 32 30 00 00       	call   80105374 <strncpy>
80102342:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	6a 10                	push   $0x10
80102351:	50                   	push   %eax
80102352:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102355:	50                   	push   %eax
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 e7 fc ff ff       	call   80102045 <writei>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	83 f8 10             	cmp    $0x10,%eax
80102364:	74 0d                	je     80102373 <dirlink+0xd1>
    panic("dirlink");
80102366:	83 ec 0c             	sub    $0xc,%esp
80102369:	68 5b 87 10 80       	push   $0x8010875b
8010236e:	e8 2d e2 ff ff       	call   801005a0 <panic>

  return 0;
80102373:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102378:	c9                   	leave  
80102379:	c3                   	ret    

8010237a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010237a:	55                   	push   %ebp
8010237b:	89 e5                	mov    %esp,%ebp
8010237d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102380:	eb 04                	jmp    80102386 <skipelem+0xc>
    path++;
80102382:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	3c 2f                	cmp    $0x2f,%al
8010238e:	74 f2                	je     80102382 <skipelem+0x8>
    path++;
  if(*path == 0)
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b6 00             	movzbl (%eax),%eax
80102396:	84 c0                	test   %al,%al
80102398:	75 07                	jne    801023a1 <skipelem+0x27>
    return 0;
8010239a:	b8 00 00 00 00       	mov    $0x0,%eax
8010239f:	eb 7b                	jmp    8010241c <skipelem+0xa2>
  s = path;
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023a7:	eb 04                	jmp    801023ad <skipelem+0x33>
    path++;
801023a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	0f b6 00             	movzbl (%eax),%eax
801023b3:	3c 2f                	cmp    $0x2f,%al
801023b5:	74 0a                	je     801023c1 <skipelem+0x47>
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	84 c0                	test   %al,%al
801023bf:	75 e8                	jne    801023a9 <skipelem+0x2f>
    path++;
  len = path - s;
801023c1:	8b 55 08             	mov    0x8(%ebp),%edx
801023c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c7:	29 c2                	sub    %eax,%edx
801023c9:	89 d0                	mov    %edx,%eax
801023cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023d2:	7e 15                	jle    801023e9 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 f4             	pushl  -0xc(%ebp)
801023dc:	ff 75 0c             	pushl  0xc(%ebp)
801023df:	e8 a4 2e 00 00       	call   80105288 <memmove>
801023e4:	83 c4 10             	add    $0x10,%esp
801023e7:	eb 26                	jmp    8010240f <skipelem+0x95>
  else {
    memmove(name, s, len);
801023e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ec:	83 ec 04             	sub    $0x4,%esp
801023ef:	50                   	push   %eax
801023f0:	ff 75 f4             	pushl  -0xc(%ebp)
801023f3:	ff 75 0c             	pushl  0xc(%ebp)
801023f6:	e8 8d 2e 00 00       	call   80105288 <memmove>
801023fb:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102401:	8b 45 0c             	mov    0xc(%ebp),%eax
80102404:	01 d0                	add    %edx,%eax
80102406:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102409:	eb 04                	jmp    8010240f <skipelem+0x95>
    path++;
8010240b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010240f:	8b 45 08             	mov    0x8(%ebp),%eax
80102412:	0f b6 00             	movzbl (%eax),%eax
80102415:	3c 2f                	cmp    $0x2f,%al
80102417:	74 f2                	je     8010240b <skipelem+0x91>
    path++;
  return path;
80102419:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010241c:	c9                   	leave  
8010241d:	c3                   	ret    

8010241e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010241e:	55                   	push   %ebp
8010241f:	89 e5                	mov    %esp,%ebp
80102421:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102424:	8b 45 08             	mov    0x8(%ebp),%eax
80102427:	0f b6 00             	movzbl (%eax),%eax
8010242a:	3c 2f                	cmp    $0x2f,%al
8010242c:	75 17                	jne    80102445 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010242e:	83 ec 08             	sub    $0x8,%esp
80102431:	6a 01                	push   $0x1
80102433:	6a 01                	push   $0x1
80102435:	e8 a7 f4 ff ff       	call   801018e1 <iget>
8010243a:	83 c4 10             	add    $0x10,%esp
8010243d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102440:	e9 ba 00 00 00       	jmp    801024ff <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102445:	e8 30 1e 00 00       	call   8010427a <myproc>
8010244a:	8b 40 68             	mov    0x68(%eax),%eax
8010244d:	83 ec 0c             	sub    $0xc,%esp
80102450:	50                   	push   %eax
80102451:	e8 6d f5 ff ff       	call   801019c3 <idup>
80102456:	83 c4 10             	add    $0x10,%esp
80102459:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010245c:	e9 9e 00 00 00       	jmp    801024ff <namex+0xe1>
    ilock(ip);
80102461:	83 ec 0c             	sub    $0xc,%esp
80102464:	ff 75 f4             	pushl  -0xc(%ebp)
80102467:	e8 91 f5 ff ff       	call   801019fd <ilock>
8010246c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010246f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102472:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102476:	66 83 f8 01          	cmp    $0x1,%ax
8010247a:	74 18                	je     80102494 <namex+0x76>
      iunlockput(ip);
8010247c:	83 ec 0c             	sub    $0xc,%esp
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	e8 a7 f7 ff ff       	call   80101c2e <iunlockput>
80102487:	83 c4 10             	add    $0x10,%esp
      return 0;
8010248a:	b8 00 00 00 00       	mov    $0x0,%eax
8010248f:	e9 a7 00 00 00       	jmp    8010253b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102494:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102498:	74 20                	je     801024ba <namex+0x9c>
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	0f b6 00             	movzbl (%eax),%eax
801024a0:	84 c0                	test   %al,%al
801024a2:	75 16                	jne    801024ba <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024a4:	83 ec 0c             	sub    $0xc,%esp
801024a7:	ff 75 f4             	pushl  -0xc(%ebp)
801024aa:	e8 61 f6 ff ff       	call   80101b10 <iunlock>
801024af:	83 c4 10             	add    $0x10,%esp
      return ip;
801024b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b5:	e9 81 00 00 00       	jmp    8010253b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024ba:	83 ec 04             	sub    $0x4,%esp
801024bd:	6a 00                	push   $0x0
801024bf:	ff 75 10             	pushl  0x10(%ebp)
801024c2:	ff 75 f4             	pushl  -0xc(%ebp)
801024c5:	e8 1e fd ff ff       	call   801021e8 <dirlookup>
801024ca:	83 c4 10             	add    $0x10,%esp
801024cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d4:	75 15                	jne    801024eb <namex+0xcd>
      iunlockput(ip);
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	ff 75 f4             	pushl  -0xc(%ebp)
801024dc:	e8 4d f7 ff ff       	call   80101c2e <iunlockput>
801024e1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024e4:	b8 00 00 00 00       	mov    $0x0,%eax
801024e9:	eb 50                	jmp    8010253b <namex+0x11d>
    }
    iunlockput(ip);
801024eb:	83 ec 0c             	sub    $0xc,%esp
801024ee:	ff 75 f4             	pushl  -0xc(%ebp)
801024f1:	e8 38 f7 ff ff       	call   80101c2e <iunlockput>
801024f6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
801024ff:	83 ec 08             	sub    $0x8,%esp
80102502:	ff 75 10             	pushl  0x10(%ebp)
80102505:	ff 75 08             	pushl  0x8(%ebp)
80102508:	e8 6d fe ff ff       	call   8010237a <skipelem>
8010250d:	83 c4 10             	add    $0x10,%esp
80102510:	89 45 08             	mov    %eax,0x8(%ebp)
80102513:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102517:	0f 85 44 ff ff ff    	jne    80102461 <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010251d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102521:	74 15                	je     80102538 <namex+0x11a>
    iput(ip);
80102523:	83 ec 0c             	sub    $0xc,%esp
80102526:	ff 75 f4             	pushl  -0xc(%ebp)
80102529:	e8 30 f6 ff ff       	call   80101b5e <iput>
8010252e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102531:	b8 00 00 00 00       	mov    $0x0,%eax
80102536:	eb 03                	jmp    8010253b <namex+0x11d>
  }
  return ip;
80102538:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010253b:	c9                   	leave  
8010253c:	c3                   	ret    

8010253d <namei>:

struct inode*
namei(char *path)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102543:	83 ec 04             	sub    $0x4,%esp
80102546:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102549:	50                   	push   %eax
8010254a:	6a 00                	push   $0x0
8010254c:	ff 75 08             	pushl  0x8(%ebp)
8010254f:	e8 ca fe ff ff       	call   8010241e <namex>
80102554:	83 c4 10             	add    $0x10,%esp
}
80102557:	c9                   	leave  
80102558:	c3                   	ret    

80102559 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102559:	55                   	push   %ebp
8010255a:	89 e5                	mov    %esp,%ebp
8010255c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010255f:	83 ec 04             	sub    $0x4,%esp
80102562:	ff 75 0c             	pushl  0xc(%ebp)
80102565:	6a 01                	push   $0x1
80102567:	ff 75 08             	pushl  0x8(%ebp)
8010256a:	e8 af fe ff ff       	call   8010241e <namex>
8010256f:	83 c4 10             	add    $0x10,%esp
}
80102572:	c9                   	leave  
80102573:	c3                   	ret    

80102574 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102574:	55                   	push   %ebp
80102575:	89 e5                	mov    %esp,%ebp
80102577:	83 ec 14             	sub    $0x14,%esp
8010257a:	8b 45 08             	mov    0x8(%ebp),%eax
8010257d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102581:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102585:	89 c2                	mov    %eax,%edx
80102587:	ec                   	in     (%dx),%al
80102588:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010258b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010258f:	c9                   	leave  
80102590:	c3                   	ret    

80102591 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102591:	55                   	push   %ebp
80102592:	89 e5                	mov    %esp,%ebp
80102594:	57                   	push   %edi
80102595:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102596:	8b 55 08             	mov    0x8(%ebp),%edx
80102599:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010259c:	8b 45 10             	mov    0x10(%ebp),%eax
8010259f:	89 cb                	mov    %ecx,%ebx
801025a1:	89 df                	mov    %ebx,%edi
801025a3:	89 c1                	mov    %eax,%ecx
801025a5:	fc                   	cld    
801025a6:	f3 6d                	rep insl (%dx),%es:(%edi)
801025a8:	89 c8                	mov    %ecx,%eax
801025aa:	89 fb                	mov    %edi,%ebx
801025ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025af:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025b2:	90                   	nop
801025b3:	5b                   	pop    %ebx
801025b4:	5f                   	pop    %edi
801025b5:	5d                   	pop    %ebp
801025b6:	c3                   	ret    

801025b7 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025b7:	55                   	push   %ebp
801025b8:	89 e5                	mov    %esp,%ebp
801025ba:	83 ec 08             	sub    $0x8,%esp
801025bd:	8b 55 08             	mov    0x8(%ebp),%edx
801025c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025c7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ca:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025ce:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025d2:	ee                   	out    %al,(%dx)
}
801025d3:	90                   	nop
801025d4:	c9                   	leave  
801025d5:	c3                   	ret    

801025d6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025d6:	55                   	push   %ebp
801025d7:	89 e5                	mov    %esp,%ebp
801025d9:	56                   	push   %esi
801025da:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025db:	8b 55 08             	mov    0x8(%ebp),%edx
801025de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025e1:	8b 45 10             	mov    0x10(%ebp),%eax
801025e4:	89 cb                	mov    %ecx,%ebx
801025e6:	89 de                	mov    %ebx,%esi
801025e8:	89 c1                	mov    %eax,%ecx
801025ea:	fc                   	cld    
801025eb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ed:	89 c8                	mov    %ecx,%eax
801025ef:	89 f3                	mov    %esi,%ebx
801025f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025f7:	90                   	nop
801025f8:	5b                   	pop    %ebx
801025f9:	5e                   	pop    %esi
801025fa:	5d                   	pop    %ebp
801025fb:	c3                   	ret    

801025fc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025fc:	55                   	push   %ebp
801025fd:	89 e5                	mov    %esp,%ebp
801025ff:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102602:	90                   	nop
80102603:	68 f7 01 00 00       	push   $0x1f7
80102608:	e8 67 ff ff ff       	call   80102574 <inb>
8010260d:	83 c4 04             	add    $0x4,%esp
80102610:	0f b6 c0             	movzbl %al,%eax
80102613:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102616:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102619:	25 c0 00 00 00       	and    $0xc0,%eax
8010261e:	83 f8 40             	cmp    $0x40,%eax
80102621:	75 e0                	jne    80102603 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102623:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102627:	74 11                	je     8010263a <idewait+0x3e>
80102629:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010262c:	83 e0 21             	and    $0x21,%eax
8010262f:	85 c0                	test   %eax,%eax
80102631:	74 07                	je     8010263a <idewait+0x3e>
    return -1;
80102633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102638:	eb 05                	jmp    8010263f <idewait+0x43>
  return 0;
8010263a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010263f:	c9                   	leave  
80102640:	c3                   	ret    

80102641 <ideinit>:

void
ideinit(void)
{
80102641:	55                   	push   %ebp
80102642:	89 e5                	mov    %esp,%ebp
80102644:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102647:	83 ec 08             	sub    $0x8,%esp
8010264a:	68 63 87 10 80       	push   $0x80108763
8010264f:	68 e0 b5 10 80       	push   $0x8010b5e0
80102654:	e8 d7 28 00 00       	call   80104f30 <initlock>
80102659:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010265c:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80102661:	83 e8 01             	sub    $0x1,%eax
80102664:	83 ec 08             	sub    $0x8,%esp
80102667:	50                   	push   %eax
80102668:	6a 0e                	push   $0xe
8010266a:	e8 a2 04 00 00       	call   80102b11 <ioapicenable>
8010266f:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102672:	83 ec 0c             	sub    $0xc,%esp
80102675:	6a 00                	push   $0x0
80102677:	e8 80 ff ff ff       	call   801025fc <idewait>
8010267c:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010267f:	83 ec 08             	sub    $0x8,%esp
80102682:	68 f0 00 00 00       	push   $0xf0
80102687:	68 f6 01 00 00       	push   $0x1f6
8010268c:	e8 26 ff ff ff       	call   801025b7 <outb>
80102691:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010269b:	eb 24                	jmp    801026c1 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010269d:	83 ec 0c             	sub    $0xc,%esp
801026a0:	68 f7 01 00 00       	push   $0x1f7
801026a5:	e8 ca fe ff ff       	call   80102574 <inb>
801026aa:	83 c4 10             	add    $0x10,%esp
801026ad:	84 c0                	test   %al,%al
801026af:	74 0c                	je     801026bd <ideinit+0x7c>
      havedisk1 = 1;
801026b1:	c7 05 18 b6 10 80 01 	movl   $0x1,0x8010b618
801026b8:	00 00 00 
      break;
801026bb:	eb 0d                	jmp    801026ca <ideinit+0x89>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026c1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c8:	7e d3                	jle    8010269d <ideinit+0x5c>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026ca:	83 ec 08             	sub    $0x8,%esp
801026cd:	68 e0 00 00 00       	push   $0xe0
801026d2:	68 f6 01 00 00       	push   $0x1f6
801026d7:	e8 db fe ff ff       	call   801025b7 <outb>
801026dc:	83 c4 10             	add    $0x10,%esp
}
801026df:	90                   	nop
801026e0:	c9                   	leave  
801026e1:	c3                   	ret    

801026e2 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026e2:	55                   	push   %ebp
801026e3:	89 e5                	mov    %esp,%ebp
801026e5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026ec:	75 0d                	jne    801026fb <idestart+0x19>
    panic("idestart");
801026ee:	83 ec 0c             	sub    $0xc,%esp
801026f1:	68 67 87 10 80       	push   $0x80108767
801026f6:	e8 a5 de ff ff       	call   801005a0 <panic>
  if(b->blockno >= FSSIZE)
801026fb:	8b 45 08             	mov    0x8(%ebp),%eax
801026fe:	8b 40 08             	mov    0x8(%eax),%eax
80102701:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102706:	76 0d                	jbe    80102715 <idestart+0x33>
    panic("incorrect blockno");
80102708:	83 ec 0c             	sub    $0xc,%esp
8010270b:	68 70 87 10 80       	push   $0x80108770
80102710:	e8 8b de ff ff       	call   801005a0 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102715:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010271c:	8b 45 08             	mov    0x8(%ebp),%eax
8010271f:	8b 50 08             	mov    0x8(%eax),%edx
80102722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102725:	0f af c2             	imul   %edx,%eax
80102728:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010272b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010272f:	75 07                	jne    80102738 <idestart+0x56>
80102731:	b8 20 00 00 00       	mov    $0x20,%eax
80102736:	eb 05                	jmp    8010273d <idestart+0x5b>
80102738:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010273d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102740:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102744:	75 07                	jne    8010274d <idestart+0x6b>
80102746:	b8 30 00 00 00       	mov    $0x30,%eax
8010274b:	eb 05                	jmp    80102752 <idestart+0x70>
8010274d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102752:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102755:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102759:	7e 0d                	jle    80102768 <idestart+0x86>
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 67 87 10 80       	push   $0x80108767
80102763:	e8 38 de ff ff       	call   801005a0 <panic>

  idewait(0);
80102768:	83 ec 0c             	sub    $0xc,%esp
8010276b:	6a 00                	push   $0x0
8010276d:	e8 8a fe ff ff       	call   801025fc <idewait>
80102772:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102775:	83 ec 08             	sub    $0x8,%esp
80102778:	6a 00                	push   $0x0
8010277a:	68 f6 03 00 00       	push   $0x3f6
8010277f:	e8 33 fe ff ff       	call   801025b7 <outb>
80102784:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278a:	0f b6 c0             	movzbl %al,%eax
8010278d:	83 ec 08             	sub    $0x8,%esp
80102790:	50                   	push   %eax
80102791:	68 f2 01 00 00       	push   $0x1f2
80102796:	e8 1c fe ff ff       	call   801025b7 <outb>
8010279b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010279e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a1:	0f b6 c0             	movzbl %al,%eax
801027a4:	83 ec 08             	sub    $0x8,%esp
801027a7:	50                   	push   %eax
801027a8:	68 f3 01 00 00       	push   $0x1f3
801027ad:	e8 05 fe ff ff       	call   801025b7 <outb>
801027b2:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b8:	c1 f8 08             	sar    $0x8,%eax
801027bb:	0f b6 c0             	movzbl %al,%eax
801027be:	83 ec 08             	sub    $0x8,%esp
801027c1:	50                   	push   %eax
801027c2:	68 f4 01 00 00       	push   $0x1f4
801027c7:	e8 eb fd ff ff       	call   801025b7 <outb>
801027cc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027d2:	c1 f8 10             	sar    $0x10,%eax
801027d5:	0f b6 c0             	movzbl %al,%eax
801027d8:	83 ec 08             	sub    $0x8,%esp
801027db:	50                   	push   %eax
801027dc:	68 f5 01 00 00       	push   $0x1f5
801027e1:	e8 d1 fd ff ff       	call   801025b7 <outb>
801027e6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027e9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ec:	8b 40 04             	mov    0x4(%eax),%eax
801027ef:	83 e0 01             	and    $0x1,%eax
801027f2:	c1 e0 04             	shl    $0x4,%eax
801027f5:	89 c2                	mov    %eax,%edx
801027f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027fa:	c1 f8 18             	sar    $0x18,%eax
801027fd:	83 e0 0f             	and    $0xf,%eax
80102800:	09 d0                	or     %edx,%eax
80102802:	83 c8 e0             	or     $0xffffffe0,%eax
80102805:	0f b6 c0             	movzbl %al,%eax
80102808:	83 ec 08             	sub    $0x8,%esp
8010280b:	50                   	push   %eax
8010280c:	68 f6 01 00 00       	push   $0x1f6
80102811:	e8 a1 fd ff ff       	call   801025b7 <outb>
80102816:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102819:	8b 45 08             	mov    0x8(%ebp),%eax
8010281c:	8b 00                	mov    (%eax),%eax
8010281e:	83 e0 04             	and    $0x4,%eax
80102821:	85 c0                	test   %eax,%eax
80102823:	74 35                	je     8010285a <idestart+0x178>
    outb(0x1f7, write_cmd);
80102825:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102828:	0f b6 c0             	movzbl %al,%eax
8010282b:	83 ec 08             	sub    $0x8,%esp
8010282e:	50                   	push   %eax
8010282f:	68 f7 01 00 00       	push   $0x1f7
80102834:	e8 7e fd ff ff       	call   801025b7 <outb>
80102839:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	83 c0 5c             	add    $0x5c,%eax
80102842:	83 ec 04             	sub    $0x4,%esp
80102845:	68 80 00 00 00       	push   $0x80
8010284a:	50                   	push   %eax
8010284b:	68 f0 01 00 00       	push   $0x1f0
80102850:	e8 81 fd ff ff       	call   801025d6 <outsl>
80102855:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102858:	eb 17                	jmp    80102871 <idestart+0x18f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
8010285a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010285d:	0f b6 c0             	movzbl %al,%eax
80102860:	83 ec 08             	sub    $0x8,%esp
80102863:	50                   	push   %eax
80102864:	68 f7 01 00 00       	push   $0x1f7
80102869:	e8 49 fd ff ff       	call   801025b7 <outb>
8010286e:	83 c4 10             	add    $0x10,%esp
  }
}
80102871:	90                   	nop
80102872:	c9                   	leave  
80102873:	c3                   	ret    

80102874 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102874:	55                   	push   %ebp
80102875:	89 e5                	mov    %esp,%ebp
80102877:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 e0 b5 10 80       	push   $0x8010b5e0
80102882:	e8 cb 26 00 00       	call   80104f52 <acquire>
80102887:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010288a:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010288f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102892:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102896:	75 15                	jne    801028ad <ideintr+0x39>
    release(&idelock);
80102898:	83 ec 0c             	sub    $0xc,%esp
8010289b:	68 e0 b5 10 80       	push   $0x8010b5e0
801028a0:	e8 1b 27 00 00       	call   80104fc0 <release>
801028a5:	83 c4 10             	add    $0x10,%esp
    return;
801028a8:	e9 9a 00 00 00       	jmp    80102947 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b0:	8b 40 58             	mov    0x58(%eax),%eax
801028b3:	a3 14 b6 10 80       	mov    %eax,0x8010b614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bb:	8b 00                	mov    (%eax),%eax
801028bd:	83 e0 04             	and    $0x4,%eax
801028c0:	85 c0                	test   %eax,%eax
801028c2:	75 2d                	jne    801028f1 <ideintr+0x7d>
801028c4:	83 ec 0c             	sub    $0xc,%esp
801028c7:	6a 01                	push   $0x1
801028c9:	e8 2e fd ff ff       	call   801025fc <idewait>
801028ce:	83 c4 10             	add    $0x10,%esp
801028d1:	85 c0                	test   %eax,%eax
801028d3:	78 1c                	js     801028f1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d8:	83 c0 5c             	add    $0x5c,%eax
801028db:	83 ec 04             	sub    $0x4,%esp
801028de:	68 80 00 00 00       	push   $0x80
801028e3:	50                   	push   %eax
801028e4:	68 f0 01 00 00       	push   $0x1f0
801028e9:	e8 a3 fc ff ff       	call   80102591 <insl>
801028ee:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f4:	8b 00                	mov    (%eax),%eax
801028f6:	83 c8 02             	or     $0x2,%eax
801028f9:	89 c2                	mov    %eax,%edx
801028fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fe:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102903:	8b 00                	mov    (%eax),%eax
80102905:	83 e0 fb             	and    $0xfffffffb,%eax
80102908:	89 c2                	mov    %eax,%edx
8010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010290f:	83 ec 0c             	sub    $0xc,%esp
80102912:	ff 75 f4             	pushl  -0xc(%ebp)
80102915:	e8 05 23 00 00       	call   80104c1f <wakeup>
8010291a:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010291d:	a1 14 b6 10 80       	mov    0x8010b614,%eax
80102922:	85 c0                	test   %eax,%eax
80102924:	74 11                	je     80102937 <ideintr+0xc3>
    idestart(idequeue);
80102926:	a1 14 b6 10 80       	mov    0x8010b614,%eax
8010292b:	83 ec 0c             	sub    $0xc,%esp
8010292e:	50                   	push   %eax
8010292f:	e8 ae fd ff ff       	call   801026e2 <idestart>
80102934:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102937:	83 ec 0c             	sub    $0xc,%esp
8010293a:	68 e0 b5 10 80       	push   $0x8010b5e0
8010293f:	e8 7c 26 00 00       	call   80104fc0 <release>
80102944:	83 c4 10             	add    $0x10,%esp
}
80102947:	c9                   	leave  
80102948:	c3                   	ret    

80102949 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010294f:	8b 45 08             	mov    0x8(%ebp),%eax
80102952:	83 c0 0c             	add    $0xc,%eax
80102955:	83 ec 0c             	sub    $0xc,%esp
80102958:	50                   	push   %eax
80102959:	e8 63 25 00 00       	call   80104ec1 <holdingsleep>
8010295e:	83 c4 10             	add    $0x10,%esp
80102961:	85 c0                	test   %eax,%eax
80102963:	75 0d                	jne    80102972 <iderw+0x29>
    panic("iderw: buf not locked");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 82 87 10 80       	push   $0x80108782
8010296d:	e8 2e dc ff ff       	call   801005a0 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102972:	8b 45 08             	mov    0x8(%ebp),%eax
80102975:	8b 00                	mov    (%eax),%eax
80102977:	83 e0 06             	and    $0x6,%eax
8010297a:	83 f8 02             	cmp    $0x2,%eax
8010297d:	75 0d                	jne    8010298c <iderw+0x43>
    panic("iderw: nothing to do");
8010297f:	83 ec 0c             	sub    $0xc,%esp
80102982:	68 98 87 10 80       	push   $0x80108798
80102987:	e8 14 dc ff ff       	call   801005a0 <panic>
  if(b->dev != 0 && !havedisk1)
8010298c:	8b 45 08             	mov    0x8(%ebp),%eax
8010298f:	8b 40 04             	mov    0x4(%eax),%eax
80102992:	85 c0                	test   %eax,%eax
80102994:	74 16                	je     801029ac <iderw+0x63>
80102996:	a1 18 b6 10 80       	mov    0x8010b618,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	75 0d                	jne    801029ac <iderw+0x63>
    panic("iderw: ide disk 1 not present");
8010299f:	83 ec 0c             	sub    $0xc,%esp
801029a2:	68 ad 87 10 80       	push   $0x801087ad
801029a7:	e8 f4 db ff ff       	call   801005a0 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029ac:	83 ec 0c             	sub    $0xc,%esp
801029af:	68 e0 b5 10 80       	push   $0x8010b5e0
801029b4:	e8 99 25 00 00       	call   80104f52 <acquire>
801029b9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029c6:	c7 45 f4 14 b6 10 80 	movl   $0x8010b614,-0xc(%ebp)
801029cd:	eb 0b                	jmp    801029da <iderw+0x91>
801029cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d2:	8b 00                	mov    (%eax),%eax
801029d4:	83 c0 58             	add    $0x58,%eax
801029d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	8b 00                	mov    (%eax),%eax
801029df:	85 c0                	test   %eax,%eax
801029e1:	75 ec                	jne    801029cf <iderw+0x86>
    ;
  *pp = b;
801029e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e6:	8b 55 08             	mov    0x8(%ebp),%edx
801029e9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029eb:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801029f0:	3b 45 08             	cmp    0x8(%ebp),%eax
801029f3:	75 23                	jne    80102a18 <iderw+0xcf>
    idestart(b);
801029f5:	83 ec 0c             	sub    $0xc,%esp
801029f8:	ff 75 08             	pushl  0x8(%ebp)
801029fb:	e8 e2 fc ff ff       	call   801026e2 <idestart>
80102a00:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a03:	eb 13                	jmp    80102a18 <iderw+0xcf>
    sleep(b, &idelock);
80102a05:	83 ec 08             	sub    $0x8,%esp
80102a08:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a0d:	ff 75 08             	pushl  0x8(%ebp)
80102a10:	e8 24 21 00 00       	call   80104b39 <sleep>
80102a15:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	8b 00                	mov    (%eax),%eax
80102a1d:	83 e0 06             	and    $0x6,%eax
80102a20:	83 f8 02             	cmp    $0x2,%eax
80102a23:	75 e0                	jne    80102a05 <iderw+0xbc>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	68 e0 b5 10 80       	push   $0x8010b5e0
80102a2d:	e8 8e 25 00 00       	call   80104fc0 <release>
80102a32:	83 c4 10             	add    $0x10,%esp
}
80102a35:	90                   	nop
80102a36:	c9                   	leave  
80102a37:	c3                   	ret    

80102a38 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a3b:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a40:	8b 55 08             	mov    0x8(%ebp),%edx
80102a43:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a45:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a4d:	5d                   	pop    %ebp
80102a4e:	c3                   	ret    

80102a4f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a4f:	55                   	push   %ebp
80102a50:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a52:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a57:	8b 55 08             	mov    0x8(%ebp),%edx
80102a5a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a5c:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102a61:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a64:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a67:	90                   	nop
80102a68:	5d                   	pop    %ebp
80102a69:	c3                   	ret    

80102a6a <ioapicinit>:

void
ioapicinit(void)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a70:	c7 05 b4 36 11 80 00 	movl   $0xfec00000,0x801136b4
80102a77:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a7a:	6a 01                	push   $0x1
80102a7c:	e8 b7 ff ff ff       	call   80102a38 <ioapicread>
80102a81:	83 c4 04             	add    $0x4,%esp
80102a84:	c1 e8 10             	shr    $0x10,%eax
80102a87:	25 ff 00 00 00       	and    $0xff,%eax
80102a8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a8f:	6a 00                	push   $0x0
80102a91:	e8 a2 ff ff ff       	call   80102a38 <ioapicread>
80102a96:	83 c4 04             	add    $0x4,%esp
80102a99:	c1 e8 18             	shr    $0x18,%eax
80102a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a9f:	0f b6 05 e0 37 11 80 	movzbl 0x801137e0,%eax
80102aa6:	0f b6 c0             	movzbl %al,%eax
80102aa9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102aac:	74 10                	je     80102abe <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102aae:	83 ec 0c             	sub    $0xc,%esp
80102ab1:	68 cc 87 10 80       	push   $0x801087cc
80102ab6:	e8 45 d9 ff ff       	call   80100400 <cprintf>
80102abb:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ac5:	eb 3f                	jmp    80102b06 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aca:	83 c0 20             	add    $0x20,%eax
80102acd:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad2:	89 c2                	mov    %eax,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	83 c0 08             	add    $0x8,%eax
80102ada:	01 c0                	add    %eax,%eax
80102adc:	83 ec 08             	sub    $0x8,%esp
80102adf:	52                   	push   %edx
80102ae0:	50                   	push   %eax
80102ae1:	e8 69 ff ff ff       	call   80102a4f <ioapicwrite>
80102ae6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	83 c0 08             	add    $0x8,%eax
80102aef:	01 c0                	add    %eax,%eax
80102af1:	83 c0 01             	add    $0x1,%eax
80102af4:	83 ec 08             	sub    $0x8,%esp
80102af7:	6a 00                	push   $0x0
80102af9:	50                   	push   %eax
80102afa:	e8 50 ff ff ff       	call   80102a4f <ioapicwrite>
80102aff:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b02:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b0c:	7e b9                	jle    80102ac7 <ioapicinit+0x5d>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b0e:	90                   	nop
80102b0f:	c9                   	leave  
80102b10:	c3                   	ret    

80102b11 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b11:	55                   	push   %ebp
80102b12:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b14:	8b 45 08             	mov    0x8(%ebp),%eax
80102b17:	83 c0 20             	add    $0x20,%eax
80102b1a:	89 c2                	mov    %eax,%edx
80102b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1f:	83 c0 08             	add    $0x8,%eax
80102b22:	01 c0                	add    %eax,%eax
80102b24:	52                   	push   %edx
80102b25:	50                   	push   %eax
80102b26:	e8 24 ff ff ff       	call   80102a4f <ioapicwrite>
80102b2b:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b31:	c1 e0 18             	shl    $0x18,%eax
80102b34:	89 c2                	mov    %eax,%edx
80102b36:	8b 45 08             	mov    0x8(%ebp),%eax
80102b39:	83 c0 08             	add    $0x8,%eax
80102b3c:	01 c0                	add    %eax,%eax
80102b3e:	83 c0 01             	add    $0x1,%eax
80102b41:	52                   	push   %edx
80102b42:	50                   	push   %eax
80102b43:	e8 07 ff ff ff       	call   80102a4f <ioapicwrite>
80102b48:	83 c4 08             	add    $0x8,%esp
}
80102b4b:	90                   	nop
80102b4c:	c9                   	leave  
80102b4d:	c3                   	ret    

80102b4e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
80102b51:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	68 fe 87 10 80       	push   $0x801087fe
80102b5c:	68 c0 36 11 80       	push   $0x801136c0
80102b61:	e8 ca 23 00 00       	call   80104f30 <initlock>
80102b66:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b69:	c7 05 f4 36 11 80 00 	movl   $0x0,0x801136f4
80102b70:	00 00 00 
  freerange(vstart, vend);
80102b73:	83 ec 08             	sub    $0x8,%esp
80102b76:	ff 75 0c             	pushl  0xc(%ebp)
80102b79:	ff 75 08             	pushl  0x8(%ebp)
80102b7c:	e8 2a 00 00 00       	call   80102bab <freerange>
80102b81:	83 c4 10             	add    $0x10,%esp
}
80102b84:	90                   	nop
80102b85:	c9                   	leave  
80102b86:	c3                   	ret    

80102b87 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b87:	55                   	push   %ebp
80102b88:	89 e5                	mov    %esp,%ebp
80102b8a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b8d:	83 ec 08             	sub    $0x8,%esp
80102b90:	ff 75 0c             	pushl  0xc(%ebp)
80102b93:	ff 75 08             	pushl  0x8(%ebp)
80102b96:	e8 10 00 00 00       	call   80102bab <freerange>
80102b9b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b9e:	c7 05 f4 36 11 80 01 	movl   $0x1,0x801136f4
80102ba5:	00 00 00 
}
80102ba8:	90                   	nop
80102ba9:	c9                   	leave  
80102baa:	c3                   	ret    

80102bab <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bab:	55                   	push   %ebp
80102bac:	89 e5                	mov    %esp,%ebp
80102bae:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb4:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc1:	eb 15                	jmp    80102bd8 <freerange+0x2d>
    kfree(p);
80102bc3:	83 ec 0c             	sub    $0xc,%esp
80102bc6:	ff 75 f4             	pushl  -0xc(%ebp)
80102bc9:	e8 1a 00 00 00       	call   80102be8 <kfree>
80102bce:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bdb:	05 00 10 00 00       	add    $0x1000,%eax
80102be0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102be3:	76 de                	jbe    80102bc3 <freerange+0x18>
    kfree(p);
}
80102be5:	90                   	nop
80102be6:	c9                   	leave  
80102be7:	c3                   	ret    

80102be8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102be8:	55                   	push   %ebp
80102be9:	89 e5                	mov    %esp,%ebp
80102beb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bee:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf1:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bf6:	85 c0                	test   %eax,%eax
80102bf8:	75 18                	jne    80102c12 <kfree+0x2a>
80102bfa:	81 7d 08 74 69 11 80 	cmpl   $0x80116974,0x8(%ebp)
80102c01:	72 0f                	jb     80102c12 <kfree+0x2a>
80102c03:	8b 45 08             	mov    0x8(%ebp),%eax
80102c06:	05 00 00 00 80       	add    $0x80000000,%eax
80102c0b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c10:	76 0d                	jbe    80102c1f <kfree+0x37>
    panic("kfree");
80102c12:	83 ec 0c             	sub    $0xc,%esp
80102c15:	68 03 88 10 80       	push   $0x80108803
80102c1a:	e8 81 d9 ff ff       	call   801005a0 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c1f:	83 ec 04             	sub    $0x4,%esp
80102c22:	68 00 10 00 00       	push   $0x1000
80102c27:	6a 01                	push   $0x1
80102c29:	ff 75 08             	pushl  0x8(%ebp)
80102c2c:	e8 98 25 00 00       	call   801051c9 <memset>
80102c31:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c34:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c39:	85 c0                	test   %eax,%eax
80102c3b:	74 10                	je     80102c4d <kfree+0x65>
    acquire(&kmem.lock);
80102c3d:	83 ec 0c             	sub    $0xc,%esp
80102c40:	68 c0 36 11 80       	push   $0x801136c0
80102c45:	e8 08 23 00 00       	call   80104f52 <acquire>
80102c4a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c53:	8b 15 f8 36 11 80    	mov    0x801136f8,%edx
80102c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102c66:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c6b:	85 c0                	test   %eax,%eax
80102c6d:	74 10                	je     80102c7f <kfree+0x97>
    release(&kmem.lock);
80102c6f:	83 ec 0c             	sub    $0xc,%esp
80102c72:	68 c0 36 11 80       	push   $0x801136c0
80102c77:	e8 44 23 00 00       	call   80104fc0 <release>
80102c7c:	83 c4 10             	add    $0x10,%esp
}
80102c7f:	90                   	nop
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c82:	55                   	push   %ebp
80102c83:	89 e5                	mov    %esp,%ebp
80102c85:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c88:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102c8d:	85 c0                	test   %eax,%eax
80102c8f:	74 10                	je     80102ca1 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c91:	83 ec 0c             	sub    $0xc,%esp
80102c94:	68 c0 36 11 80       	push   $0x801136c0
80102c99:	e8 b4 22 00 00       	call   80104f52 <acquire>
80102c9e:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca1:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80102ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ca9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cad:	74 0a                	je     80102cb9 <kalloc+0x37>
    kmem.freelist = r->next;
80102caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb2:	8b 00                	mov    (%eax),%eax
80102cb4:	a3 f8 36 11 80       	mov    %eax,0x801136f8
  if(kmem.use_lock)
80102cb9:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102cbe:	85 c0                	test   %eax,%eax
80102cc0:	74 10                	je     80102cd2 <kalloc+0x50>
    release(&kmem.lock);
80102cc2:	83 ec 0c             	sub    $0xc,%esp
80102cc5:	68 c0 36 11 80       	push   $0x801136c0
80102cca:	e8 f1 22 00 00       	call   80104fc0 <release>
80102ccf:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cd5:	c9                   	leave  
80102cd6:	c3                   	ret    

80102cd7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cd7:	55                   	push   %ebp
80102cd8:	89 e5                	mov    %esp,%ebp
80102cda:	83 ec 14             	sub    $0x14,%esp
80102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ce8:	89 c2                	mov    %eax,%edx
80102cea:	ec                   	in     (%dx),%al
80102ceb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cee:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cf2:	c9                   	leave  
80102cf3:	c3                   	ret    

80102cf4 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cf4:	55                   	push   %ebp
80102cf5:	89 e5                	mov    %esp,%ebp
80102cf7:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cfa:	6a 64                	push   $0x64
80102cfc:	e8 d6 ff ff ff       	call   80102cd7 <inb>
80102d01:	83 c4 04             	add    $0x4,%esp
80102d04:	0f b6 c0             	movzbl %al,%eax
80102d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d0d:	83 e0 01             	and    $0x1,%eax
80102d10:	85 c0                	test   %eax,%eax
80102d12:	75 0a                	jne    80102d1e <kbdgetc+0x2a>
    return -1;
80102d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d19:	e9 23 01 00 00       	jmp    80102e41 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d1e:	6a 60                	push   $0x60
80102d20:	e8 b2 ff ff ff       	call   80102cd7 <inb>
80102d25:	83 c4 04             	add    $0x4,%esp
80102d28:	0f b6 c0             	movzbl %al,%eax
80102d2b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d2e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d35:	75 17                	jne    80102d4e <kbdgetc+0x5a>
    shift |= E0ESC;
80102d37:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d3c:	83 c8 40             	or     $0x40,%eax
80102d3f:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102d44:	b8 00 00 00 00       	mov    $0x0,%eax
80102d49:	e9 f3 00 00 00       	jmp    80102e41 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d51:	25 80 00 00 00       	and    $0x80,%eax
80102d56:	85 c0                	test   %eax,%eax
80102d58:	74 45                	je     80102d9f <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d5a:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d5f:	83 e0 40             	and    $0x40,%eax
80102d62:	85 c0                	test   %eax,%eax
80102d64:	75 08                	jne    80102d6e <kbdgetc+0x7a>
80102d66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d69:	83 e0 7f             	and    $0x7f,%eax
80102d6c:	eb 03                	jmp    80102d71 <kbdgetc+0x7d>
80102d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d71:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d77:	05 20 90 10 80       	add    $0x80109020,%eax
80102d7c:	0f b6 00             	movzbl (%eax),%eax
80102d7f:	83 c8 40             	or     $0x40,%eax
80102d82:	0f b6 c0             	movzbl %al,%eax
80102d85:	f7 d0                	not    %eax
80102d87:	89 c2                	mov    %eax,%edx
80102d89:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102d8e:	21 d0                	and    %edx,%eax
80102d90:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
    return 0;
80102d95:	b8 00 00 00 00       	mov    $0x0,%eax
80102d9a:	e9 a2 00 00 00       	jmp    80102e41 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d9f:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102da4:	83 e0 40             	and    $0x40,%eax
80102da7:	85 c0                	test   %eax,%eax
80102da9:	74 14                	je     80102dbf <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dab:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102db2:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102db7:	83 e0 bf             	and    $0xffffffbf,%eax
80102dba:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  }

  shift |= shiftcode[data];
80102dbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc2:	05 20 90 10 80       	add    $0x80109020,%eax
80102dc7:	0f b6 00             	movzbl (%eax),%eax
80102dca:	0f b6 d0             	movzbl %al,%edx
80102dcd:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dd2:	09 d0                	or     %edx,%eax
80102dd4:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  shift ^= togglecode[data];
80102dd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ddc:	05 20 91 10 80       	add    $0x80109120,%eax
80102de1:	0f b6 00             	movzbl (%eax),%eax
80102de4:	0f b6 d0             	movzbl %al,%edx
80102de7:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102dec:	31 d0                	xor    %edx,%eax
80102dee:	a3 1c b6 10 80       	mov    %eax,0x8010b61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102df3:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102df8:	83 e0 03             	and    $0x3,%eax
80102dfb:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e05:	01 d0                	add    %edx,%eax
80102e07:	0f b6 00             	movzbl (%eax),%eax
80102e0a:	0f b6 c0             	movzbl %al,%eax
80102e0d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e10:	a1 1c b6 10 80       	mov    0x8010b61c,%eax
80102e15:	83 e0 08             	and    $0x8,%eax
80102e18:	85 c0                	test   %eax,%eax
80102e1a:	74 22                	je     80102e3e <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e1c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e20:	76 0c                	jbe    80102e2e <kbdgetc+0x13a>
80102e22:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e26:	77 06                	ja     80102e2e <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e28:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e2c:	eb 10                	jmp    80102e3e <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e2e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e32:	76 0a                	jbe    80102e3e <kbdgetc+0x14a>
80102e34:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e38:	77 04                	ja     80102e3e <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e3a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e41:	c9                   	leave  
80102e42:	c3                   	ret    

80102e43 <kbdintr>:

void
kbdintr(void)
{
80102e43:	55                   	push   %ebp
80102e44:	89 e5                	mov    %esp,%ebp
80102e46:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e49:	83 ec 0c             	sub    $0xc,%esp
80102e4c:	68 f4 2c 10 80       	push   $0x80102cf4
80102e51:	e8 d6 d9 ff ff       	call   8010082c <consoleintr>
80102e56:	83 c4 10             	add    $0x10,%esp
}
80102e59:	90                   	nop
80102e5a:	c9                   	leave  
80102e5b:	c3                   	ret    

80102e5c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e5c:	55                   	push   %ebp
80102e5d:	89 e5                	mov    %esp,%ebp
80102e5f:	83 ec 14             	sub    $0x14,%esp
80102e62:	8b 45 08             	mov    0x8(%ebp),%eax
80102e65:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e69:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e6d:	89 c2                	mov    %eax,%edx
80102e6f:	ec                   	in     (%dx),%al
80102e70:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e73:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e77:	c9                   	leave  
80102e78:	c3                   	ret    

80102e79 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e79:	55                   	push   %ebp
80102e7a:	89 e5                	mov    %esp,%ebp
80102e7c:	83 ec 08             	sub    $0x8,%esp
80102e7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e85:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e89:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e8c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e90:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e94:	ee                   	out    %al,(%dx)
}
80102e95:	90                   	nop
80102e96:	c9                   	leave  
80102e97:	c3                   	ret    

80102e98 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e98:	55                   	push   %ebp
80102e99:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e9b:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ea0:	8b 55 08             	mov    0x8(%ebp),%edx
80102ea3:	c1 e2 02             	shl    $0x2,%edx
80102ea6:	01 c2                	add    %eax,%edx
80102ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eab:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ead:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102eb2:	83 c0 20             	add    $0x20,%eax
80102eb5:	8b 00                	mov    (%eax),%eax
}
80102eb7:	90                   	nop
80102eb8:	5d                   	pop    %ebp
80102eb9:	c3                   	ret    

80102eba <lapicinit>:

void
lapicinit(void)
{
80102eba:	55                   	push   %ebp
80102ebb:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ebd:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ec2:	85 c0                	test   %eax,%eax
80102ec4:	0f 84 0b 01 00 00    	je     80102fd5 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102eca:	68 3f 01 00 00       	push   $0x13f
80102ecf:	6a 3c                	push   $0x3c
80102ed1:	e8 c2 ff ff ff       	call   80102e98 <lapicw>
80102ed6:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ed9:	6a 0b                	push   $0xb
80102edb:	68 f8 00 00 00       	push   $0xf8
80102ee0:	e8 b3 ff ff ff       	call   80102e98 <lapicw>
80102ee5:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ee8:	68 20 00 02 00       	push   $0x20020
80102eed:	68 c8 00 00 00       	push   $0xc8
80102ef2:	e8 a1 ff ff ff       	call   80102e98 <lapicw>
80102ef7:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102efa:	68 80 96 98 00       	push   $0x989680
80102eff:	68 e0 00 00 00       	push   $0xe0
80102f04:	e8 8f ff ff ff       	call   80102e98 <lapicw>
80102f09:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f0c:	68 00 00 01 00       	push   $0x10000
80102f11:	68 d4 00 00 00       	push   $0xd4
80102f16:	e8 7d ff ff ff       	call   80102e98 <lapicw>
80102f1b:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f1e:	68 00 00 01 00       	push   $0x10000
80102f23:	68 d8 00 00 00       	push   $0xd8
80102f28:	e8 6b ff ff ff       	call   80102e98 <lapicw>
80102f2d:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f30:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f35:	83 c0 30             	add    $0x30,%eax
80102f38:	8b 00                	mov    (%eax),%eax
80102f3a:	c1 e8 10             	shr    $0x10,%eax
80102f3d:	0f b6 c0             	movzbl %al,%eax
80102f40:	83 f8 03             	cmp    $0x3,%eax
80102f43:	76 12                	jbe    80102f57 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f45:	68 00 00 01 00       	push   $0x10000
80102f4a:	68 d0 00 00 00       	push   $0xd0
80102f4f:	e8 44 ff ff ff       	call   80102e98 <lapicw>
80102f54:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f57:	6a 33                	push   $0x33
80102f59:	68 dc 00 00 00       	push   $0xdc
80102f5e:	e8 35 ff ff ff       	call   80102e98 <lapicw>
80102f63:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f66:	6a 00                	push   $0x0
80102f68:	68 a0 00 00 00       	push   $0xa0
80102f6d:	e8 26 ff ff ff       	call   80102e98 <lapicw>
80102f72:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f75:	6a 00                	push   $0x0
80102f77:	68 a0 00 00 00       	push   $0xa0
80102f7c:	e8 17 ff ff ff       	call   80102e98 <lapicw>
80102f81:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f84:	6a 00                	push   $0x0
80102f86:	6a 2c                	push   $0x2c
80102f88:	e8 0b ff ff ff       	call   80102e98 <lapicw>
80102f8d:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f90:	6a 00                	push   $0x0
80102f92:	68 c4 00 00 00       	push   $0xc4
80102f97:	e8 fc fe ff ff       	call   80102e98 <lapicw>
80102f9c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f9f:	68 00 85 08 00       	push   $0x88500
80102fa4:	68 c0 00 00 00       	push   $0xc0
80102fa9:	e8 ea fe ff ff       	call   80102e98 <lapicw>
80102fae:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb1:	90                   	nop
80102fb2:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fb7:	05 00 03 00 00       	add    $0x300,%eax
80102fbc:	8b 00                	mov    (%eax),%eax
80102fbe:	25 00 10 00 00       	and    $0x1000,%eax
80102fc3:	85 c0                	test   %eax,%eax
80102fc5:	75 eb                	jne    80102fb2 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fc7:	6a 00                	push   $0x0
80102fc9:	6a 20                	push   $0x20
80102fcb:	e8 c8 fe ff ff       	call   80102e98 <lapicw>
80102fd0:	83 c4 08             	add    $0x8,%esp
80102fd3:	eb 01                	jmp    80102fd6 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic)
    return;
80102fd5:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fd6:	c9                   	leave  
80102fd7:	c3                   	ret    

80102fd8 <lapicid>:

int
lapicid(void)
{
80102fd8:	55                   	push   %ebp
80102fd9:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102fdb:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	75 07                	jne    80102feb <lapicid+0x13>
    return 0;
80102fe4:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe9:	eb 0d                	jmp    80102ff8 <lapicid+0x20>
  return lapic[ID] >> 24;
80102feb:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102ff0:	83 c0 20             	add    $0x20,%eax
80102ff3:	8b 00                	mov    (%eax),%eax
80102ff5:	c1 e8 18             	shr    $0x18,%eax
}
80102ff8:	5d                   	pop    %ebp
80102ff9:	c3                   	ret    

80102ffa <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ffa:	55                   	push   %ebp
80102ffb:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102ffd:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103002:	85 c0                	test   %eax,%eax
80103004:	74 0c                	je     80103012 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103006:	6a 00                	push   $0x0
80103008:	6a 2c                	push   $0x2c
8010300a:	e8 89 fe ff ff       	call   80102e98 <lapicw>
8010300f:	83 c4 08             	add    $0x8,%esp
}
80103012:	90                   	nop
80103013:	c9                   	leave  
80103014:	c3                   	ret    

80103015 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103015:	55                   	push   %ebp
80103016:	89 e5                	mov    %esp,%ebp
}
80103018:	90                   	nop
80103019:	5d                   	pop    %ebp
8010301a:	c3                   	ret    

8010301b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 14             	sub    $0x14,%esp
80103021:	8b 45 08             	mov    0x8(%ebp),%eax
80103024:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103027:	6a 0f                	push   $0xf
80103029:	6a 70                	push   $0x70
8010302b:	e8 49 fe ff ff       	call   80102e79 <outb>
80103030:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103033:	6a 0a                	push   $0xa
80103035:	6a 71                	push   $0x71
80103037:	e8 3d fe ff ff       	call   80102e79 <outb>
8010303c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010303f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103046:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103049:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010304e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103051:	83 c0 02             	add    $0x2,%eax
80103054:	8b 55 0c             	mov    0xc(%ebp),%edx
80103057:	c1 ea 04             	shr    $0x4,%edx
8010305a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010305d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103061:	c1 e0 18             	shl    $0x18,%eax
80103064:	50                   	push   %eax
80103065:	68 c4 00 00 00       	push   $0xc4
8010306a:	e8 29 fe ff ff       	call   80102e98 <lapicw>
8010306f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103072:	68 00 c5 00 00       	push   $0xc500
80103077:	68 c0 00 00 00       	push   $0xc0
8010307c:	e8 17 fe ff ff       	call   80102e98 <lapicw>
80103081:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103084:	68 c8 00 00 00       	push   $0xc8
80103089:	e8 87 ff ff ff       	call   80103015 <microdelay>
8010308e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103091:	68 00 85 00 00       	push   $0x8500
80103096:	68 c0 00 00 00       	push   $0xc0
8010309b:	e8 f8 fd ff ff       	call   80102e98 <lapicw>
801030a0:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030a3:	6a 64                	push   $0x64
801030a5:	e8 6b ff ff ff       	call   80103015 <microdelay>
801030aa:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030b4:	eb 3d                	jmp    801030f3 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030b6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ba:	c1 e0 18             	shl    $0x18,%eax
801030bd:	50                   	push   %eax
801030be:	68 c4 00 00 00       	push   $0xc4
801030c3:	e8 d0 fd ff ff       	call   80102e98 <lapicw>
801030c8:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801030ce:	c1 e8 0c             	shr    $0xc,%eax
801030d1:	80 cc 06             	or     $0x6,%ah
801030d4:	50                   	push   %eax
801030d5:	68 c0 00 00 00       	push   $0xc0
801030da:	e8 b9 fd ff ff       	call   80102e98 <lapicw>
801030df:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030e2:	68 c8 00 00 00       	push   $0xc8
801030e7:	e8 29 ff ff ff       	call   80103015 <microdelay>
801030ec:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030f3:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030f7:	7e bd                	jle    801030b6 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030f9:	90                   	nop
801030fa:	c9                   	leave  
801030fb:	c3                   	ret    

801030fc <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030fc:	55                   	push   %ebp
801030fd:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801030ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103102:	0f b6 c0             	movzbl %al,%eax
80103105:	50                   	push   %eax
80103106:	6a 70                	push   $0x70
80103108:	e8 6c fd ff ff       	call   80102e79 <outb>
8010310d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103110:	68 c8 00 00 00       	push   $0xc8
80103115:	e8 fb fe ff ff       	call   80103015 <microdelay>
8010311a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010311d:	6a 71                	push   $0x71
8010311f:	e8 38 fd ff ff       	call   80102e5c <inb>
80103124:	83 c4 04             	add    $0x4,%esp
80103127:	0f b6 c0             	movzbl %al,%eax
}
8010312a:	c9                   	leave  
8010312b:	c3                   	ret    

8010312c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010312c:	55                   	push   %ebp
8010312d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010312f:	6a 00                	push   $0x0
80103131:	e8 c6 ff ff ff       	call   801030fc <cmos_read>
80103136:	83 c4 04             	add    $0x4,%esp
80103139:	89 c2                	mov    %eax,%edx
8010313b:	8b 45 08             	mov    0x8(%ebp),%eax
8010313e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103140:	6a 02                	push   $0x2
80103142:	e8 b5 ff ff ff       	call   801030fc <cmos_read>
80103147:	83 c4 04             	add    $0x4,%esp
8010314a:	89 c2                	mov    %eax,%edx
8010314c:	8b 45 08             	mov    0x8(%ebp),%eax
8010314f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103152:	6a 04                	push   $0x4
80103154:	e8 a3 ff ff ff       	call   801030fc <cmos_read>
80103159:	83 c4 04             	add    $0x4,%esp
8010315c:	89 c2                	mov    %eax,%edx
8010315e:	8b 45 08             	mov    0x8(%ebp),%eax
80103161:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103164:	6a 07                	push   $0x7
80103166:	e8 91 ff ff ff       	call   801030fc <cmos_read>
8010316b:	83 c4 04             	add    $0x4,%esp
8010316e:	89 c2                	mov    %eax,%edx
80103170:	8b 45 08             	mov    0x8(%ebp),%eax
80103173:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103176:	6a 08                	push   $0x8
80103178:	e8 7f ff ff ff       	call   801030fc <cmos_read>
8010317d:	83 c4 04             	add    $0x4,%esp
80103180:	89 c2                	mov    %eax,%edx
80103182:	8b 45 08             	mov    0x8(%ebp),%eax
80103185:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103188:	6a 09                	push   $0x9
8010318a:	e8 6d ff ff ff       	call   801030fc <cmos_read>
8010318f:	83 c4 04             	add    $0x4,%esp
80103192:	89 c2                	mov    %eax,%edx
80103194:	8b 45 08             	mov    0x8(%ebp),%eax
80103197:	89 50 14             	mov    %edx,0x14(%eax)
}
8010319a:	90                   	nop
8010319b:	c9                   	leave  
8010319c:	c3                   	ret    

8010319d <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319d:	55                   	push   %ebp
8010319e:	89 e5                	mov    %esp,%ebp
801031a0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a3:	6a 0b                	push   $0xb
801031a5:	e8 52 ff ff ff       	call   801030fc <cmos_read>
801031aa:	83 c4 04             	add    $0x4,%esp
801031ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b3:	83 e0 04             	and    $0x4,%eax
801031b6:	85 c0                	test   %eax,%eax
801031b8:	0f 94 c0             	sete   %al
801031bb:	0f b6 c0             	movzbl %al,%eax
801031be:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031c1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c4:	50                   	push   %eax
801031c5:	e8 62 ff ff ff       	call   8010312c <fill_rtcdate>
801031ca:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031cd:	6a 0a                	push   $0xa
801031cf:	e8 28 ff ff ff       	call   801030fc <cmos_read>
801031d4:	83 c4 04             	add    $0x4,%esp
801031d7:	25 80 00 00 00       	and    $0x80,%eax
801031dc:	85 c0                	test   %eax,%eax
801031de:	75 27                	jne    80103207 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031e0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e3:	50                   	push   %eax
801031e4:	e8 43 ff ff ff       	call   8010312c <fill_rtcdate>
801031e9:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031ec:	83 ec 04             	sub    $0x4,%esp
801031ef:	6a 18                	push   $0x18
801031f1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f4:	50                   	push   %eax
801031f5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f8:	50                   	push   %eax
801031f9:	e8 32 20 00 00       	call   80105230 <memcmp>
801031fe:	83 c4 10             	add    $0x10,%esp
80103201:	85 c0                	test   %eax,%eax
80103203:	74 05                	je     8010320a <cmostime+0x6d>
80103205:	eb ba                	jmp    801031c1 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103207:	90                   	nop
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103208:	eb b7                	jmp    801031c1 <cmostime+0x24>
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
8010320a:	90                   	nop
  }

  // convert
  if(bcd) {
8010320b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320f:	0f 84 b4 00 00 00    	je     801032c9 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103215:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103218:	c1 e8 04             	shr    $0x4,%eax
8010321b:	89 c2                	mov    %eax,%edx
8010321d:	89 d0                	mov    %edx,%eax
8010321f:	c1 e0 02             	shl    $0x2,%eax
80103222:	01 d0                	add    %edx,%eax
80103224:	01 c0                	add    %eax,%eax
80103226:	89 c2                	mov    %eax,%edx
80103228:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010322b:	83 e0 0f             	and    $0xf,%eax
8010322e:	01 d0                	add    %edx,%eax
80103230:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103233:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103236:	c1 e8 04             	shr    $0x4,%eax
80103239:	89 c2                	mov    %eax,%edx
8010323b:	89 d0                	mov    %edx,%eax
8010323d:	c1 e0 02             	shl    $0x2,%eax
80103240:	01 d0                	add    %edx,%eax
80103242:	01 c0                	add    %eax,%eax
80103244:	89 c2                	mov    %eax,%edx
80103246:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103249:	83 e0 0f             	and    $0xf,%eax
8010324c:	01 d0                	add    %edx,%eax
8010324e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103251:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103254:	c1 e8 04             	shr    $0x4,%eax
80103257:	89 c2                	mov    %eax,%edx
80103259:	89 d0                	mov    %edx,%eax
8010325b:	c1 e0 02             	shl    $0x2,%eax
8010325e:	01 d0                	add    %edx,%eax
80103260:	01 c0                	add    %eax,%eax
80103262:	89 c2                	mov    %eax,%edx
80103264:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103267:	83 e0 0f             	and    $0xf,%eax
8010326a:	01 d0                	add    %edx,%eax
8010326c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103272:	c1 e8 04             	shr    $0x4,%eax
80103275:	89 c2                	mov    %eax,%edx
80103277:	89 d0                	mov    %edx,%eax
80103279:	c1 e0 02             	shl    $0x2,%eax
8010327c:	01 d0                	add    %edx,%eax
8010327e:	01 c0                	add    %eax,%eax
80103280:	89 c2                	mov    %eax,%edx
80103282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103285:	83 e0 0f             	and    $0xf,%eax
80103288:	01 d0                	add    %edx,%eax
8010328a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103290:	c1 e8 04             	shr    $0x4,%eax
80103293:	89 c2                	mov    %eax,%edx
80103295:	89 d0                	mov    %edx,%eax
80103297:	c1 e0 02             	shl    $0x2,%eax
8010329a:	01 d0                	add    %edx,%eax
8010329c:	01 c0                	add    %eax,%eax
8010329e:	89 c2                	mov    %eax,%edx
801032a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a3:	83 e0 0f             	and    $0xf,%eax
801032a6:	01 d0                	add    %edx,%eax
801032a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ae:	c1 e8 04             	shr    $0x4,%eax
801032b1:	89 c2                	mov    %eax,%edx
801032b3:	89 d0                	mov    %edx,%eax
801032b5:	c1 e0 02             	shl    $0x2,%eax
801032b8:	01 d0                	add    %edx,%eax
801032ba:	01 c0                	add    %eax,%eax
801032bc:	89 c2                	mov    %eax,%edx
801032be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032c1:	83 e0 0f             	and    $0xf,%eax
801032c4:	01 d0                	add    %edx,%eax
801032c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c9:	8b 45 08             	mov    0x8(%ebp),%eax
801032cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cf:	89 10                	mov    %edx,(%eax)
801032d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d4:	89 50 04             	mov    %edx,0x4(%eax)
801032d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032da:	89 50 08             	mov    %edx,0x8(%eax)
801032dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032e0:	89 50 0c             	mov    %edx,0xc(%eax)
801032e3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e6:	89 50 10             	mov    %edx,0x10(%eax)
801032e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032ec:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ef:	8b 45 08             	mov    0x8(%ebp),%eax
801032f2:	8b 40 14             	mov    0x14(%eax),%eax
801032f5:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032fb:	8b 45 08             	mov    0x8(%ebp),%eax
801032fe:	89 50 14             	mov    %edx,0x14(%eax)
}
80103301:	90                   	nop
80103302:	c9                   	leave  
80103303:	c3                   	ret    

80103304 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103304:	55                   	push   %ebp
80103305:	89 e5                	mov    %esp,%ebp
80103307:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010330a:	83 ec 08             	sub    $0x8,%esp
8010330d:	68 09 88 10 80       	push   $0x80108809
80103312:	68 00 37 11 80       	push   $0x80113700
80103317:	e8 14 1c 00 00       	call   80104f30 <initlock>
8010331c:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331f:	83 ec 08             	sub    $0x8,%esp
80103322:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103325:	50                   	push   %eax
80103326:	ff 75 08             	pushl  0x8(%ebp)
80103329:	e8 a3 e0 ff ff       	call   801013d1 <readsb>
8010332e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103331:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103334:	a3 34 37 11 80       	mov    %eax,0x80113734
  log.size = sb.nlog;
80103339:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010333c:	a3 38 37 11 80       	mov    %eax,0x80113738
  log.dev = dev;
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	a3 44 37 11 80       	mov    %eax,0x80113744
  recover_from_log();
80103349:	e8 b2 01 00 00       	call   80103500 <recover_from_log>
}
8010334e:	90                   	nop
8010334f:	c9                   	leave  
80103350:	c3                   	ret    

80103351 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103351:	55                   	push   %ebp
80103352:	89 e5                	mov    %esp,%ebp
80103354:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103357:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335e:	e9 95 00 00 00       	jmp    801033f8 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103363:	8b 15 34 37 11 80    	mov    0x80113734,%edx
80103369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010336c:	01 d0                	add    %edx,%eax
8010336e:	83 c0 01             	add    $0x1,%eax
80103371:	89 c2                	mov    %eax,%edx
80103373:	a1 44 37 11 80       	mov    0x80113744,%eax
80103378:	83 ec 08             	sub    $0x8,%esp
8010337b:	52                   	push   %edx
8010337c:	50                   	push   %eax
8010337d:	e8 4c ce ff ff       	call   801001ce <bread>
80103382:	83 c4 10             	add    $0x10,%esp
80103385:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010338b:	83 c0 10             	add    $0x10,%eax
8010338e:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
80103395:	89 c2                	mov    %eax,%edx
80103397:	a1 44 37 11 80       	mov    0x80113744,%eax
8010339c:	83 ec 08             	sub    $0x8,%esp
8010339f:	52                   	push   %edx
801033a0:	50                   	push   %eax
801033a1:	e8 28 ce ff ff       	call   801001ce <bread>
801033a6:	83 c4 10             	add    $0x10,%esp
801033a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033af:	8d 50 5c             	lea    0x5c(%eax),%edx
801033b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b5:	83 c0 5c             	add    $0x5c,%eax
801033b8:	83 ec 04             	sub    $0x4,%esp
801033bb:	68 00 02 00 00       	push   $0x200
801033c0:	52                   	push   %edx
801033c1:	50                   	push   %eax
801033c2:	e8 c1 1e 00 00       	call   80105288 <memmove>
801033c7:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033ca:	83 ec 0c             	sub    $0xc,%esp
801033cd:	ff 75 ec             	pushl  -0x14(%ebp)
801033d0:	e8 32 ce ff ff       	call   80100207 <bwrite>
801033d5:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d8:	83 ec 0c             	sub    $0xc,%esp
801033db:	ff 75 f0             	pushl  -0x10(%ebp)
801033de:	e8 6d ce ff ff       	call   80100250 <brelse>
801033e3:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e6:	83 ec 0c             	sub    $0xc,%esp
801033e9:	ff 75 ec             	pushl  -0x14(%ebp)
801033ec:	e8 5f ce ff ff       	call   80100250 <brelse>
801033f1:	83 c4 10             	add    $0x10,%esp
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f8:	a1 48 37 11 80       	mov    0x80113748,%eax
801033fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103400:	0f 8f 5d ff ff ff    	jg     80103363 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103406:	90                   	nop
80103407:	c9                   	leave  
80103408:	c3                   	ret    

80103409 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103409:	55                   	push   %ebp
8010340a:	89 e5                	mov    %esp,%ebp
8010340c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340f:	a1 34 37 11 80       	mov    0x80113734,%eax
80103414:	89 c2                	mov    %eax,%edx
80103416:	a1 44 37 11 80       	mov    0x80113744,%eax
8010341b:	83 ec 08             	sub    $0x8,%esp
8010341e:	52                   	push   %edx
8010341f:	50                   	push   %eax
80103420:	e8 a9 cd ff ff       	call   801001ce <bread>
80103425:	83 c4 10             	add    $0x10,%esp
80103428:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010342b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342e:	83 c0 5c             	add    $0x5c,%eax
80103431:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103434:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103437:	8b 00                	mov    (%eax),%eax
80103439:	a3 48 37 11 80       	mov    %eax,0x80113748
  for (i = 0; i < log.lh.n; i++) {
8010343e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103445:	eb 1b                	jmp    80103462 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103451:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103454:	83 c2 10             	add    $0x10,%edx
80103457:	89 04 95 0c 37 11 80 	mov    %eax,-0x7feec8f4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010345e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103462:	a1 48 37 11 80       	mov    0x80113748,%eax
80103467:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010346a:	7f db                	jg     80103447 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010346c:	83 ec 0c             	sub    $0xc,%esp
8010346f:	ff 75 f0             	pushl  -0x10(%ebp)
80103472:	e8 d9 cd ff ff       	call   80100250 <brelse>
80103477:	83 c4 10             	add    $0x10,%esp
}
8010347a:	90                   	nop
8010347b:	c9                   	leave  
8010347c:	c3                   	ret    

8010347d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347d:	55                   	push   %ebp
8010347e:	89 e5                	mov    %esp,%ebp
80103480:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103483:	a1 34 37 11 80       	mov    0x80113734,%eax
80103488:	89 c2                	mov    %eax,%edx
8010348a:	a1 44 37 11 80       	mov    0x80113744,%eax
8010348f:	83 ec 08             	sub    $0x8,%esp
80103492:	52                   	push   %edx
80103493:	50                   	push   %eax
80103494:	e8 35 cd ff ff       	call   801001ce <bread>
80103499:	83 c4 10             	add    $0x10,%esp
8010349c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a2:	83 c0 5c             	add    $0x5c,%eax
801034a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a8:	8b 15 48 37 11 80    	mov    0x80113748,%edx
801034ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ba:	eb 1b                	jmp    801034d7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bf:	83 c0 10             	add    $0x10,%eax
801034c2:	8b 0c 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%ecx
801034c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cf:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d7:	a1 48 37 11 80       	mov    0x80113748,%eax
801034dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034df:	7f db                	jg     801034bc <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801034e1:	83 ec 0c             	sub    $0xc,%esp
801034e4:	ff 75 f0             	pushl  -0x10(%ebp)
801034e7:	e8 1b cd ff ff       	call   80100207 <bwrite>
801034ec:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ef:	83 ec 0c             	sub    $0xc,%esp
801034f2:	ff 75 f0             	pushl  -0x10(%ebp)
801034f5:	e8 56 cd ff ff       	call   80100250 <brelse>
801034fa:	83 c4 10             	add    $0x10,%esp
}
801034fd:	90                   	nop
801034fe:	c9                   	leave  
801034ff:	c3                   	ret    

80103500 <recover_from_log>:

static void
recover_from_log(void)
{
80103500:	55                   	push   %ebp
80103501:	89 e5                	mov    %esp,%ebp
80103503:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103506:	e8 fe fe ff ff       	call   80103409 <read_head>
  install_trans(); // if committed, copy from log to disk
8010350b:	e8 41 fe ff ff       	call   80103351 <install_trans>
  log.lh.n = 0;
80103510:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
80103517:	00 00 00 
  write_head(); // clear the log
8010351a:	e8 5e ff ff ff       	call   8010347d <write_head>
}
8010351f:	90                   	nop
80103520:	c9                   	leave  
80103521:	c3                   	ret    

80103522 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103522:	55                   	push   %ebp
80103523:	89 e5                	mov    %esp,%ebp
80103525:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103528:	83 ec 0c             	sub    $0xc,%esp
8010352b:	68 00 37 11 80       	push   $0x80113700
80103530:	e8 1d 1a 00 00       	call   80104f52 <acquire>
80103535:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103538:	a1 40 37 11 80       	mov    0x80113740,%eax
8010353d:	85 c0                	test   %eax,%eax
8010353f:	74 17                	je     80103558 <begin_op+0x36>
      sleep(&log, &log.lock);
80103541:	83 ec 08             	sub    $0x8,%esp
80103544:	68 00 37 11 80       	push   $0x80113700
80103549:	68 00 37 11 80       	push   $0x80113700
8010354e:	e8 e6 15 00 00       	call   80104b39 <sleep>
80103553:	83 c4 10             	add    $0x10,%esp
80103556:	eb e0                	jmp    80103538 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103558:	8b 0d 48 37 11 80    	mov    0x80113748,%ecx
8010355e:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103563:	8d 50 01             	lea    0x1(%eax),%edx
80103566:	89 d0                	mov    %edx,%eax
80103568:	c1 e0 02             	shl    $0x2,%eax
8010356b:	01 d0                	add    %edx,%eax
8010356d:	01 c0                	add    %eax,%eax
8010356f:	01 c8                	add    %ecx,%eax
80103571:	83 f8 1e             	cmp    $0x1e,%eax
80103574:	7e 17                	jle    8010358d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103576:	83 ec 08             	sub    $0x8,%esp
80103579:	68 00 37 11 80       	push   $0x80113700
8010357e:	68 00 37 11 80       	push   $0x80113700
80103583:	e8 b1 15 00 00       	call   80104b39 <sleep>
80103588:	83 c4 10             	add    $0x10,%esp
8010358b:	eb ab                	jmp    80103538 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358d:	a1 3c 37 11 80       	mov    0x8011373c,%eax
80103592:	83 c0 01             	add    $0x1,%eax
80103595:	a3 3c 37 11 80       	mov    %eax,0x8011373c
      release(&log.lock);
8010359a:	83 ec 0c             	sub    $0xc,%esp
8010359d:	68 00 37 11 80       	push   $0x80113700
801035a2:	e8 19 1a 00 00       	call   80104fc0 <release>
801035a7:	83 c4 10             	add    $0x10,%esp
      break;
801035aa:	90                   	nop
    }
  }
}
801035ab:	90                   	nop
801035ac:	c9                   	leave  
801035ad:	c3                   	ret    

801035ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ae:	55                   	push   %ebp
801035af:	89 e5                	mov    %esp,%ebp
801035b1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035bb:	83 ec 0c             	sub    $0xc,%esp
801035be:	68 00 37 11 80       	push   $0x80113700
801035c3:	e8 8a 19 00 00       	call   80104f52 <acquire>
801035c8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035cb:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801035d0:	83 e8 01             	sub    $0x1,%eax
801035d3:	a3 3c 37 11 80       	mov    %eax,0x8011373c
  if(log.committing)
801035d8:	a1 40 37 11 80       	mov    0x80113740,%eax
801035dd:	85 c0                	test   %eax,%eax
801035df:	74 0d                	je     801035ee <end_op+0x40>
    panic("log.committing");
801035e1:	83 ec 0c             	sub    $0xc,%esp
801035e4:	68 0d 88 10 80       	push   $0x8010880d
801035e9:	e8 b2 cf ff ff       	call   801005a0 <panic>
  if(log.outstanding == 0){
801035ee:	a1 3c 37 11 80       	mov    0x8011373c,%eax
801035f3:	85 c0                	test   %eax,%eax
801035f5:	75 13                	jne    8010360a <end_op+0x5c>
    do_commit = 1;
801035f7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fe:	c7 05 40 37 11 80 01 	movl   $0x1,0x80113740
80103605:	00 00 00 
80103608:	eb 10                	jmp    8010361a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010360a:	83 ec 0c             	sub    $0xc,%esp
8010360d:	68 00 37 11 80       	push   $0x80113700
80103612:	e8 08 16 00 00       	call   80104c1f <wakeup>
80103617:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	68 00 37 11 80       	push   $0x80113700
80103622:	e8 99 19 00 00       	call   80104fc0 <release>
80103627:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010362a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362e:	74 3f                	je     8010366f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103630:	e8 f5 00 00 00       	call   8010372a <commit>
    acquire(&log.lock);
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 00 37 11 80       	push   $0x80113700
8010363d:	e8 10 19 00 00       	call   80104f52 <acquire>
80103642:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103645:	c7 05 40 37 11 80 00 	movl   $0x0,0x80113740
8010364c:	00 00 00 
    wakeup(&log);
8010364f:	83 ec 0c             	sub    $0xc,%esp
80103652:	68 00 37 11 80       	push   $0x80113700
80103657:	e8 c3 15 00 00       	call   80104c1f <wakeup>
8010365c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	68 00 37 11 80       	push   $0x80113700
80103667:	e8 54 19 00 00       	call   80104fc0 <release>
8010366c:	83 c4 10             	add    $0x10,%esp
  }
}
8010366f:	90                   	nop
80103670:	c9                   	leave  
80103671:	c3                   	ret    

80103672 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103672:	55                   	push   %ebp
80103673:	89 e5                	mov    %esp,%ebp
80103675:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367f:	e9 95 00 00 00       	jmp    80103719 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103684:	8b 15 34 37 11 80    	mov    0x80113734,%edx
8010368a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368d:	01 d0                	add    %edx,%eax
8010368f:	83 c0 01             	add    $0x1,%eax
80103692:	89 c2                	mov    %eax,%edx
80103694:	a1 44 37 11 80       	mov    0x80113744,%eax
80103699:	83 ec 08             	sub    $0x8,%esp
8010369c:	52                   	push   %edx
8010369d:	50                   	push   %eax
8010369e:	e8 2b cb ff ff       	call   801001ce <bread>
801036a3:	83 c4 10             	add    $0x10,%esp
801036a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ac:	83 c0 10             	add    $0x10,%eax
801036af:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801036b6:	89 c2                	mov    %eax,%edx
801036b8:	a1 44 37 11 80       	mov    0x80113744,%eax
801036bd:	83 ec 08             	sub    $0x8,%esp
801036c0:	52                   	push   %edx
801036c1:	50                   	push   %eax
801036c2:	e8 07 cb ff ff       	call   801001ce <bread>
801036c7:	83 c4 10             	add    $0x10,%esp
801036ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036d0:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d6:	83 c0 5c             	add    $0x5c,%eax
801036d9:	83 ec 04             	sub    $0x4,%esp
801036dc:	68 00 02 00 00       	push   $0x200
801036e1:	52                   	push   %edx
801036e2:	50                   	push   %eax
801036e3:	e8 a0 1b 00 00       	call   80105288 <memmove>
801036e8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036eb:	83 ec 0c             	sub    $0xc,%esp
801036ee:	ff 75 f0             	pushl  -0x10(%ebp)
801036f1:	e8 11 cb ff ff       	call   80100207 <bwrite>
801036f6:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f9:	83 ec 0c             	sub    $0xc,%esp
801036fc:	ff 75 ec             	pushl  -0x14(%ebp)
801036ff:	e8 4c cb ff ff       	call   80100250 <brelse>
80103704:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103707:	83 ec 0c             	sub    $0xc,%esp
8010370a:	ff 75 f0             	pushl  -0x10(%ebp)
8010370d:	e8 3e cb ff ff       	call   80100250 <brelse>
80103712:	83 c4 10             	add    $0x10,%esp
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103715:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103719:	a1 48 37 11 80       	mov    0x80113748,%eax
8010371e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103721:	0f 8f 5d ff ff ff    	jg     80103684 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103727:	90                   	nop
80103728:	c9                   	leave  
80103729:	c3                   	ret    

8010372a <commit>:

static void
commit()
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103730:	a1 48 37 11 80       	mov    0x80113748,%eax
80103735:	85 c0                	test   %eax,%eax
80103737:	7e 1e                	jle    80103757 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103739:	e8 34 ff ff ff       	call   80103672 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373e:	e8 3a fd ff ff       	call   8010347d <write_head>
    install_trans(); // Now install writes to home locations
80103743:	e8 09 fc ff ff       	call   80103351 <install_trans>
    log.lh.n = 0;
80103748:	c7 05 48 37 11 80 00 	movl   $0x0,0x80113748
8010374f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103752:	e8 26 fd ff ff       	call   8010347d <write_head>
  }
}
80103757:	90                   	nop
80103758:	c9                   	leave  
80103759:	c3                   	ret    

8010375a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010375a:	55                   	push   %ebp
8010375b:	89 e5                	mov    %esp,%ebp
8010375d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103760:	a1 48 37 11 80       	mov    0x80113748,%eax
80103765:	83 f8 1d             	cmp    $0x1d,%eax
80103768:	7f 12                	jg     8010377c <log_write+0x22>
8010376a:	a1 48 37 11 80       	mov    0x80113748,%eax
8010376f:	8b 15 38 37 11 80    	mov    0x80113738,%edx
80103775:	83 ea 01             	sub    $0x1,%edx
80103778:	39 d0                	cmp    %edx,%eax
8010377a:	7c 0d                	jl     80103789 <log_write+0x2f>
    panic("too big a transaction");
8010377c:	83 ec 0c             	sub    $0xc,%esp
8010377f:	68 1c 88 10 80       	push   $0x8010881c
80103784:	e8 17 ce ff ff       	call   801005a0 <panic>
  if (log.outstanding < 1)
80103789:	a1 3c 37 11 80       	mov    0x8011373c,%eax
8010378e:	85 c0                	test   %eax,%eax
80103790:	7f 0d                	jg     8010379f <log_write+0x45>
    panic("log_write outside of trans");
80103792:	83 ec 0c             	sub    $0xc,%esp
80103795:	68 32 88 10 80       	push   $0x80108832
8010379a:	e8 01 ce ff ff       	call   801005a0 <panic>

  acquire(&log.lock);
8010379f:	83 ec 0c             	sub    $0xc,%esp
801037a2:	68 00 37 11 80       	push   $0x80113700
801037a7:	e8 a6 17 00 00       	call   80104f52 <acquire>
801037ac:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b6:	eb 1d                	jmp    801037d5 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037bb:	83 c0 10             	add    $0x10,%eax
801037be:	8b 04 85 0c 37 11 80 	mov    -0x7feec8f4(,%eax,4),%eax
801037c5:	89 c2                	mov    %eax,%edx
801037c7:	8b 45 08             	mov    0x8(%ebp),%eax
801037ca:	8b 40 08             	mov    0x8(%eax),%eax
801037cd:	39 c2                	cmp    %eax,%edx
801037cf:	74 10                	je     801037e1 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d5:	a1 48 37 11 80       	mov    0x80113748,%eax
801037da:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037dd:	7f d9                	jg     801037b8 <log_write+0x5e>
801037df:	eb 01                	jmp    801037e2 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801037e1:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e2:	8b 45 08             	mov    0x8(%ebp),%eax
801037e5:	8b 40 08             	mov    0x8(%eax),%eax
801037e8:	89 c2                	mov    %eax,%edx
801037ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ed:	83 c0 10             	add    $0x10,%eax
801037f0:	89 14 85 0c 37 11 80 	mov    %edx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
801037f7:	a1 48 37 11 80       	mov    0x80113748,%eax
801037fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ff:	75 0d                	jne    8010380e <log_write+0xb4>
    log.lh.n++;
80103801:	a1 48 37 11 80       	mov    0x80113748,%eax
80103806:	83 c0 01             	add    $0x1,%eax
80103809:	a3 48 37 11 80       	mov    %eax,0x80113748
  b->flags |= B_DIRTY; // prevent eviction
8010380e:	8b 45 08             	mov    0x8(%ebp),%eax
80103811:	8b 00                	mov    (%eax),%eax
80103813:	83 c8 04             	or     $0x4,%eax
80103816:	89 c2                	mov    %eax,%edx
80103818:	8b 45 08             	mov    0x8(%ebp),%eax
8010381b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381d:	83 ec 0c             	sub    $0xc,%esp
80103820:	68 00 37 11 80       	push   $0x80113700
80103825:	e8 96 17 00 00       	call   80104fc0 <release>
8010382a:	83 c4 10             	add    $0x10,%esp
}
8010382d:	90                   	nop
8010382e:	c9                   	leave  
8010382f:	c3                   	ret    

80103830 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103830:	55                   	push   %ebp
80103831:	89 e5                	mov    %esp,%ebp
80103833:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103836:	8b 55 08             	mov    0x8(%ebp),%edx
80103839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383f:	f0 87 02             	lock xchg %eax,(%edx)
80103842:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103848:	c9                   	leave  
80103849:	c3                   	ret    

8010384a <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010384a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384e:	83 e4 f0             	and    $0xfffffff0,%esp
80103851:	ff 71 fc             	pushl  -0x4(%ecx)
80103854:	55                   	push   %ebp
80103855:	89 e5                	mov    %esp,%ebp
80103857:	51                   	push   %ecx
80103858:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385b:	83 ec 08             	sub    $0x8,%esp
8010385e:	68 00 00 40 80       	push   $0x80400000
80103863:	68 74 69 11 80       	push   $0x80116974
80103868:	e8 e1 f2 ff ff       	call   80102b4e <kinit1>
8010386d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103870:	e8 e8 43 00 00       	call   80107c5d <kvmalloc>
  mpinit();        // detect other processors
80103875:	e8 bf 03 00 00       	call   80103c39 <mpinit>
  lapicinit();     // interrupt controller
8010387a:	e8 3b f6 ff ff       	call   80102eba <lapicinit>
  seginit();       // segment descriptors
8010387f:	e8 c4 3e 00 00       	call   80107748 <seginit>
  picinit();       // disable pic
80103884:	e8 01 05 00 00       	call   80103d8a <picinit>
  ioapicinit();    // another interrupt controller
80103889:	e8 dc f1 ff ff       	call   80102a6a <ioapicinit>
  consoleinit();   // console hardware
8010388e:	e8 b8 d2 ff ff       	call   80100b4b <consoleinit>
  uartinit();      // serial port
80103893:	e8 49 32 00 00       	call   80106ae1 <uartinit>
  pinit();         // process table
80103898:	e8 26 09 00 00       	call   801041c3 <pinit>
  shminit();       // shared memory
8010389d:	e8 48 4c 00 00       	call   801084ea <shminit>
  tvinit();        // trap vectors
801038a2:	e8 56 2d 00 00       	call   801065fd <tvinit>
  binit();         // buffer cache
801038a7:	e8 88 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038ac:	e8 11 d7 ff ff       	call   80100fc2 <fileinit>
  ideinit();       // disk 
801038b1:	e8 8b ed ff ff       	call   80102641 <ideinit>
  startothers();   // start other processors
801038b6:	e8 80 00 00 00       	call   8010393b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038bb:	83 ec 08             	sub    $0x8,%esp
801038be:	68 00 00 00 8e       	push   $0x8e000000
801038c3:	68 00 00 40 80       	push   $0x80400000
801038c8:	e8 ba f2 ff ff       	call   80102b87 <kinit2>
801038cd:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038d0:	e8 d4 0a 00 00       	call   801043a9 <userinit>
  mpmain();        // finish this processor's setup
801038d5:	e8 1a 00 00 00       	call   801038f4 <mpmain>

801038da <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038da:	55                   	push   %ebp
801038db:	89 e5                	mov    %esp,%ebp
801038dd:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e0:	e8 90 43 00 00       	call   80107c75 <switchkvm>
  seginit();
801038e5:	e8 5e 3e 00 00       	call   80107748 <seginit>
  lapicinit();
801038ea:	e8 cb f5 ff ff       	call   80102eba <lapicinit>
  mpmain();
801038ef:	e8 00 00 00 00       	call   801038f4 <mpmain>

801038f4 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038f4:	55                   	push   %ebp
801038f5:	89 e5                	mov    %esp,%ebp
801038f7:	53                   	push   %ebx
801038f8:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038fb:	e8 e1 08 00 00       	call   801041e1 <cpuid>
80103900:	89 c3                	mov    %eax,%ebx
80103902:	e8 da 08 00 00       	call   801041e1 <cpuid>
80103907:	83 ec 04             	sub    $0x4,%esp
8010390a:	53                   	push   %ebx
8010390b:	50                   	push   %eax
8010390c:	68 4d 88 10 80       	push   $0x8010884d
80103911:	e8 ea ca ff ff       	call   80100400 <cprintf>
80103916:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103919:	e8 55 2e 00 00       	call   80106773 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010391e:	e8 df 08 00 00       	call   80104202 <mycpu>
80103923:	05 a0 00 00 00       	add    $0xa0,%eax
80103928:	83 ec 08             	sub    $0x8,%esp
8010392b:	6a 01                	push   $0x1
8010392d:	50                   	push   %eax
8010392e:	e8 fd fe ff ff       	call   80103830 <xchg>
80103933:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103936:	e8 0b 10 00 00       	call   80104946 <scheduler>

8010393b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010393b:	55                   	push   %ebp
8010393c:	89 e5                	mov    %esp,%ebp
8010393e:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103941:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103948:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010394d:	83 ec 04             	sub    $0x4,%esp
80103950:	50                   	push   %eax
80103951:	68 ec b4 10 80       	push   $0x8010b4ec
80103956:	ff 75 f0             	pushl  -0x10(%ebp)
80103959:	e8 2a 19 00 00       	call   80105288 <memmove>
8010395e:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103961:	c7 45 f4 00 38 11 80 	movl   $0x80113800,-0xc(%ebp)
80103968:	eb 79                	jmp    801039e3 <startothers+0xa8>
    if(c == mycpu())  // We've started already.
8010396a:	e8 93 08 00 00       	call   80104202 <mycpu>
8010396f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103972:	74 67                	je     801039db <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103974:	e8 09 f3 ff ff       	call   80102c82 <kalloc>
80103979:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010397c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010397f:	83 e8 04             	sub    $0x4,%eax
80103982:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103985:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010398b:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010398d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103990:	83 e8 08             	sub    $0x8,%eax
80103993:	c7 00 da 38 10 80    	movl   $0x801038da,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399c:	83 e8 0c             	sub    $0xc,%eax
8010399f:	ba 00 a0 10 80       	mov    $0x8010a000,%edx
801039a4:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801039aa:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039af:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b8:	0f b6 00             	movzbl (%eax),%eax
801039bb:	0f b6 c0             	movzbl %al,%eax
801039be:	83 ec 08             	sub    $0x8,%esp
801039c1:	52                   	push   %edx
801039c2:	50                   	push   %eax
801039c3:	e8 53 f6 ff ff       	call   8010301b <lapicstartap>
801039c8:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039cb:	90                   	nop
801039cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cf:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039d5:	85 c0                	test   %eax,%eax
801039d7:	74 f3                	je     801039cc <startothers+0x91>
801039d9:	eb 01                	jmp    801039dc <startothers+0xa1>
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == mycpu())  // We've started already.
      continue;
801039db:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039dc:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039e3:	a1 80 3d 11 80       	mov    0x80113d80,%eax
801039e8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039ee:	05 00 38 11 80       	add    $0x80113800,%eax
801039f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f6:	0f 87 6e ff ff ff    	ja     8010396a <startothers+0x2f>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039fc:	90                   	nop
801039fd:	c9                   	leave  
801039fe:	c3                   	ret    

801039ff <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039ff:	55                   	push   %ebp
80103a00:	89 e5                	mov    %esp,%ebp
80103a02:	83 ec 14             	sub    $0x14,%esp
80103a05:	8b 45 08             	mov    0x8(%ebp),%eax
80103a08:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a0c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a10:	89 c2                	mov    %eax,%edx
80103a12:	ec                   	in     (%dx),%al
80103a13:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a16:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a1a:	c9                   	leave  
80103a1b:	c3                   	ret    

80103a1c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a1c:	55                   	push   %ebp
80103a1d:	89 e5                	mov    %esp,%ebp
80103a1f:	83 ec 08             	sub    $0x8,%esp
80103a22:	8b 55 08             	mov    0x8(%ebp),%edx
80103a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a28:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a2c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a2f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a33:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a37:	ee                   	out    %al,(%dx)
}
80103a38:	90                   	nop
80103a39:	c9                   	leave  
80103a3a:	c3                   	ret    

80103a3b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a3b:	55                   	push   %ebp
80103a3c:	89 e5                	mov    %esp,%ebp
80103a3e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a41:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a4f:	eb 15                	jmp    80103a66 <sum+0x2b>
    sum += addr[i];
80103a51:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a54:	8b 45 08             	mov    0x8(%ebp),%eax
80103a57:	01 d0                	add    %edx,%eax
80103a59:	0f b6 00             	movzbl (%eax),%eax
80103a5c:	0f b6 c0             	movzbl %al,%eax
80103a5f:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a62:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a69:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a6c:	7c e3                	jl     80103a51 <sum+0x16>
    sum += addr[i];
  return sum;
80103a6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a71:	c9                   	leave  
80103a72:	c3                   	ret    

80103a73 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a73:	55                   	push   %ebp
80103a74:	89 e5                	mov    %esp,%ebp
80103a76:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a79:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7c:	05 00 00 00 80       	add    $0x80000000,%eax
80103a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a84:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a8a:	01 d0                	add    %edx,%eax
80103a8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a95:	eb 36                	jmp    80103acd <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a97:	83 ec 04             	sub    $0x4,%esp
80103a9a:	6a 04                	push   $0x4
80103a9c:	68 64 88 10 80       	push   $0x80108864
80103aa1:	ff 75 f4             	pushl  -0xc(%ebp)
80103aa4:	e8 87 17 00 00       	call   80105230 <memcmp>
80103aa9:	83 c4 10             	add    $0x10,%esp
80103aac:	85 c0                	test   %eax,%eax
80103aae:	75 19                	jne    80103ac9 <mpsearch1+0x56>
80103ab0:	83 ec 08             	sub    $0x8,%esp
80103ab3:	6a 10                	push   $0x10
80103ab5:	ff 75 f4             	pushl  -0xc(%ebp)
80103ab8:	e8 7e ff ff ff       	call   80103a3b <sum>
80103abd:	83 c4 10             	add    $0x10,%esp
80103ac0:	84 c0                	test   %al,%al
80103ac2:	75 05                	jne    80103ac9 <mpsearch1+0x56>
      return (struct mp*)p;
80103ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac7:	eb 11                	jmp    80103ada <mpsearch1+0x67>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ac9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ad3:	72 c2                	jb     80103a97 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ada:	c9                   	leave  
80103adb:	c3                   	ret    

80103adc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ae2:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aec:	83 c0 0f             	add    $0xf,%eax
80103aef:	0f b6 00             	movzbl (%eax),%eax
80103af2:	0f b6 c0             	movzbl %al,%eax
80103af5:	c1 e0 08             	shl    $0x8,%eax
80103af8:	89 c2                	mov    %eax,%edx
80103afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afd:	83 c0 0e             	add    $0xe,%eax
80103b00:	0f b6 00             	movzbl (%eax),%eax
80103b03:	0f b6 c0             	movzbl %al,%eax
80103b06:	09 d0                	or     %edx,%eax
80103b08:	c1 e0 04             	shl    $0x4,%eax
80103b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b12:	74 21                	je     80103b35 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b14:	83 ec 08             	sub    $0x8,%esp
80103b17:	68 00 04 00 00       	push   $0x400
80103b1c:	ff 75 f0             	pushl  -0x10(%ebp)
80103b1f:	e8 4f ff ff ff       	call   80103a73 <mpsearch1>
80103b24:	83 c4 10             	add    $0x10,%esp
80103b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b2a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b2e:	74 51                	je     80103b81 <mpsearch+0xa5>
      return mp;
80103b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b33:	eb 61                	jmp    80103b96 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b38:	83 c0 14             	add    $0x14,%eax
80103b3b:	0f b6 00             	movzbl (%eax),%eax
80103b3e:	0f b6 c0             	movzbl %al,%eax
80103b41:	c1 e0 08             	shl    $0x8,%eax
80103b44:	89 c2                	mov    %eax,%edx
80103b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b49:	83 c0 13             	add    $0x13,%eax
80103b4c:	0f b6 00             	movzbl (%eax),%eax
80103b4f:	0f b6 c0             	movzbl %al,%eax
80103b52:	09 d0                	or     %edx,%eax
80103b54:	c1 e0 0a             	shl    $0xa,%eax
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5d:	2d 00 04 00 00       	sub    $0x400,%eax
80103b62:	83 ec 08             	sub    $0x8,%esp
80103b65:	68 00 04 00 00       	push   $0x400
80103b6a:	50                   	push   %eax
80103b6b:	e8 03 ff ff ff       	call   80103a73 <mpsearch1>
80103b70:	83 c4 10             	add    $0x10,%esp
80103b73:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b7a:	74 05                	je     80103b81 <mpsearch+0xa5>
      return mp;
80103b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b7f:	eb 15                	jmp    80103b96 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b81:	83 ec 08             	sub    $0x8,%esp
80103b84:	68 00 00 01 00       	push   $0x10000
80103b89:	68 00 00 0f 00       	push   $0xf0000
80103b8e:	e8 e0 fe ff ff       	call   80103a73 <mpsearch1>
80103b93:	83 c4 10             	add    $0x10,%esp
}
80103b96:	c9                   	leave  
80103b97:	c3                   	ret    

80103b98 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b9e:	e8 39 ff ff ff       	call   80103adc <mpsearch>
80103ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ba6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103baa:	74 0a                	je     80103bb6 <mpconfig+0x1e>
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	8b 40 04             	mov    0x4(%eax),%eax
80103bb2:	85 c0                	test   %eax,%eax
80103bb4:	75 07                	jne    80103bbd <mpconfig+0x25>
    return 0;
80103bb6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbb:	eb 7a                	jmp    80103c37 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc0:	8b 40 04             	mov    0x4(%eax),%eax
80103bc3:	05 00 00 00 80       	add    $0x80000000,%eax
80103bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bcb:	83 ec 04             	sub    $0x4,%esp
80103bce:	6a 04                	push   $0x4
80103bd0:	68 69 88 10 80       	push   $0x80108869
80103bd5:	ff 75 f0             	pushl  -0x10(%ebp)
80103bd8:	e8 53 16 00 00       	call   80105230 <memcmp>
80103bdd:	83 c4 10             	add    $0x10,%esp
80103be0:	85 c0                	test   %eax,%eax
80103be2:	74 07                	je     80103beb <mpconfig+0x53>
    return 0;
80103be4:	b8 00 00 00 00       	mov    $0x0,%eax
80103be9:	eb 4c                	jmp    80103c37 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bee:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bf2:	3c 01                	cmp    $0x1,%al
80103bf4:	74 12                	je     80103c08 <mpconfig+0x70>
80103bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bfd:	3c 04                	cmp    $0x4,%al
80103bff:	74 07                	je     80103c08 <mpconfig+0x70>
    return 0;
80103c01:	b8 00 00 00 00       	mov    $0x0,%eax
80103c06:	eb 2f                	jmp    80103c37 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c0f:	0f b7 c0             	movzwl %ax,%eax
80103c12:	83 ec 08             	sub    $0x8,%esp
80103c15:	50                   	push   %eax
80103c16:	ff 75 f0             	pushl  -0x10(%ebp)
80103c19:	e8 1d fe ff ff       	call   80103a3b <sum>
80103c1e:	83 c4 10             	add    $0x10,%esp
80103c21:	84 c0                	test   %al,%al
80103c23:	74 07                	je     80103c2c <mpconfig+0x94>
    return 0;
80103c25:	b8 00 00 00 00       	mov    $0x0,%eax
80103c2a:	eb 0b                	jmp    80103c37 <mpconfig+0x9f>
  *pmp = mp;
80103c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c32:	89 10                	mov    %edx,(%eax)
  return conf;
80103c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c37:	c9                   	leave  
80103c38:	c3                   	ret    

80103c39 <mpinit>:

void
mpinit(void)
{
80103c39:	55                   	push   %ebp
80103c3a:	89 e5                	mov    %esp,%ebp
80103c3c:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c3f:	83 ec 0c             	sub    $0xc,%esp
80103c42:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c45:	50                   	push   %eax
80103c46:	e8 4d ff ff ff       	call   80103b98 <mpconfig>
80103c4b:	83 c4 10             	add    $0x10,%esp
80103c4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c51:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c55:	75 0d                	jne    80103c64 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103c57:	83 ec 0c             	sub    $0xc,%esp
80103c5a:	68 6e 88 10 80       	push   $0x8010886e
80103c5f:	e8 3c c9 ff ff       	call   801005a0 <panic>
  ismp = 1;
80103c64:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c6e:	8b 40 24             	mov    0x24(%eax),%eax
80103c71:	a3 fc 36 11 80       	mov    %eax,0x801136fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c79:	83 c0 2c             	add    $0x2c,%eax
80103c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c82:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c86:	0f b7 d0             	movzwl %ax,%edx
80103c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c8c:	01 d0                	add    %edx,%eax
80103c8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c91:	eb 7b                	jmp    80103d0e <mpinit+0xd5>
    switch(*p){
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	0f b6 00             	movzbl (%eax),%eax
80103c99:	0f b6 c0             	movzbl %al,%eax
80103c9c:	83 f8 04             	cmp    $0x4,%eax
80103c9f:	77 65                	ja     80103d06 <mpinit+0xcd>
80103ca1:	8b 04 85 a8 88 10 80 	mov    -0x7fef7758(,%eax,4),%eax
80103ca8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103cb0:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103cb5:	83 f8 07             	cmp    $0x7,%eax
80103cb8:	7f 28                	jg     80103ce2 <mpinit+0xa9>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cba:	8b 15 80 3d 11 80    	mov    0x80113d80,%edx
80103cc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cc3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc7:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103ccd:	81 c2 00 38 11 80    	add    $0x80113800,%edx
80103cd3:	88 02                	mov    %al,(%edx)
        ncpu++;
80103cd5:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80103cda:	83 c0 01             	add    $0x1,%eax
80103cdd:	a3 80 3d 11 80       	mov    %eax,0x80113d80
      }
      p += sizeof(struct mpproc);
80103ce2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ce6:	eb 26                	jmp    80103d0e <mpinit+0xd5>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ceb:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cf1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cf5:	a2 e0 37 11 80       	mov    %al,0x801137e0
      p += sizeof(struct mpioapic);
80103cfa:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cfe:	eb 0e                	jmp    80103d0e <mpinit+0xd5>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d00:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d04:	eb 08                	jmp    80103d0e <mpinit+0xd5>
    default:
      ismp = 0;
80103d06:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d0d:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d11:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d14:	0f 82 79 ff ff ff    	jb     80103c93 <mpinit+0x5a>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d1e:	75 0d                	jne    80103d2d <mpinit+0xf4>
    panic("Didn't find a suitable machine");
80103d20:	83 ec 0c             	sub    $0xc,%esp
80103d23:	68 88 88 10 80       	push   $0x80108888
80103d28:	e8 73 c8 ff ff       	call   801005a0 <panic>

  if(mp->imcrp){
80103d2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d30:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d34:	84 c0                	test   %al,%al
80103d36:	74 30                	je     80103d68 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d38:	83 ec 08             	sub    $0x8,%esp
80103d3b:	6a 70                	push   $0x70
80103d3d:	6a 22                	push   $0x22
80103d3f:	e8 d8 fc ff ff       	call   80103a1c <outb>
80103d44:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d47:	83 ec 0c             	sub    $0xc,%esp
80103d4a:	6a 23                	push   $0x23
80103d4c:	e8 ae fc ff ff       	call   801039ff <inb>
80103d51:	83 c4 10             	add    $0x10,%esp
80103d54:	83 c8 01             	or     $0x1,%eax
80103d57:	0f b6 c0             	movzbl %al,%eax
80103d5a:	83 ec 08             	sub    $0x8,%esp
80103d5d:	50                   	push   %eax
80103d5e:	6a 23                	push   $0x23
80103d60:	e8 b7 fc ff ff       	call   80103a1c <outb>
80103d65:	83 c4 10             	add    $0x10,%esp
  }
}
80103d68:	90                   	nop
80103d69:	c9                   	leave  
80103d6a:	c3                   	ret    

80103d6b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d6b:	55                   	push   %ebp
80103d6c:	89 e5                	mov    %esp,%ebp
80103d6e:	83 ec 08             	sub    $0x8,%esp
80103d71:	8b 55 08             	mov    0x8(%ebp),%edx
80103d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d77:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d7b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d7e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d82:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d86:	ee                   	out    %al,(%dx)
}
80103d87:	90                   	nop
80103d88:	c9                   	leave  
80103d89:	c3                   	ret    

80103d8a <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d8a:	55                   	push   %ebp
80103d8b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d8d:	68 ff 00 00 00       	push   $0xff
80103d92:	6a 21                	push   $0x21
80103d94:	e8 d2 ff ff ff       	call   80103d6b <outb>
80103d99:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103d9c:	68 ff 00 00 00       	push   $0xff
80103da1:	68 a1 00 00 00       	push   $0xa1
80103da6:	e8 c0 ff ff ff       	call   80103d6b <outb>
80103dab:	83 c4 08             	add    $0x8,%esp
}
80103dae:	90                   	nop
80103daf:	c9                   	leave  
80103db0:	c3                   	ret    

80103db1 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103db1:	55                   	push   %ebp
80103db2:	89 e5                	mov    %esp,%ebp
80103db4:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103db7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dca:	8b 10                	mov    (%eax),%edx
80103dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcf:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103dd1:	e8 0a d2 ff ff       	call   80100fe0 <filealloc>
80103dd6:	89 c2                	mov    %eax,%edx
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	89 10                	mov    %edx,(%eax)
80103ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80103de0:	8b 00                	mov    (%eax),%eax
80103de2:	85 c0                	test   %eax,%eax
80103de4:	0f 84 cb 00 00 00    	je     80103eb5 <pipealloc+0x104>
80103dea:	e8 f1 d1 ff ff       	call   80100fe0 <filealloc>
80103def:	89 c2                	mov    %eax,%edx
80103df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df4:	89 10                	mov    %edx,(%eax)
80103df6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df9:	8b 00                	mov    (%eax),%eax
80103dfb:	85 c0                	test   %eax,%eax
80103dfd:	0f 84 b2 00 00 00    	je     80103eb5 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e03:	e8 7a ee ff ff       	call   80102c82 <kalloc>
80103e08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e0f:	0f 84 9f 00 00 00    	je     80103eb4 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80103e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e18:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e1f:	00 00 00 
  p->writeopen = 1;
80103e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e25:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e2c:	00 00 00 
  p->nwrite = 0;
80103e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e32:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e39:	00 00 00 
  p->nread = 0;
80103e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3f:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e46:	00 00 00 
  initlock(&p->lock, "pipe");
80103e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e4c:	83 ec 08             	sub    $0x8,%esp
80103e4f:	68 bc 88 10 80       	push   $0x801088bc
80103e54:	50                   	push   %eax
80103e55:	e8 d6 10 00 00       	call   80104f30 <initlock>
80103e5a:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e60:	8b 00                	mov    (%eax),%eax
80103e62:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e68:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6b:	8b 00                	mov    (%eax),%eax
80103e6d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e71:	8b 45 08             	mov    0x8(%ebp),%eax
80103e74:	8b 00                	mov    (%eax),%eax
80103e76:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7d:	8b 00                	mov    (%eax),%eax
80103e7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e82:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e85:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e88:	8b 00                	mov    (%eax),%eax
80103e8a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e90:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e93:	8b 00                	mov    (%eax),%eax
80103e95:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9c:	8b 00                	mov    (%eax),%eax
80103e9e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea5:	8b 00                	mov    (%eax),%eax
80103ea7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eaa:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ead:	b8 00 00 00 00       	mov    $0x0,%eax
80103eb2:	eb 4e                	jmp    80103f02 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103eb4:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103eb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eb9:	74 0e                	je     80103ec9 <pipealloc+0x118>
    kfree((char*)p);
80103ebb:	83 ec 0c             	sub    $0xc,%esp
80103ebe:	ff 75 f4             	pushl  -0xc(%ebp)
80103ec1:	e8 22 ed ff ff       	call   80102be8 <kfree>
80103ec6:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	8b 00                	mov    (%eax),%eax
80103ece:	85 c0                	test   %eax,%eax
80103ed0:	74 11                	je     80103ee3 <pipealloc+0x132>
    fileclose(*f0);
80103ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed5:	8b 00                	mov    (%eax),%eax
80103ed7:	83 ec 0c             	sub    $0xc,%esp
80103eda:	50                   	push   %eax
80103edb:	e8 be d1 ff ff       	call   8010109e <fileclose>
80103ee0:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee6:	8b 00                	mov    (%eax),%eax
80103ee8:	85 c0                	test   %eax,%eax
80103eea:	74 11                	je     80103efd <pipealloc+0x14c>
    fileclose(*f1);
80103eec:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eef:	8b 00                	mov    (%eax),%eax
80103ef1:	83 ec 0c             	sub    $0xc,%esp
80103ef4:	50                   	push   %eax
80103ef5:	e8 a4 d1 ff ff       	call   8010109e <fileclose>
80103efa:	83 c4 10             	add    $0x10,%esp
  return -1;
80103efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f02:	c9                   	leave  
80103f03:	c3                   	ret    

80103f04 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	83 ec 0c             	sub    $0xc,%esp
80103f10:	50                   	push   %eax
80103f11:	e8 3c 10 00 00       	call   80104f52 <acquire>
80103f16:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f1d:	74 23                	je     80103f42 <pipeclose+0x3e>
    p->writeopen = 0;
80103f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f22:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f29:	00 00 00 
    wakeup(&p->nread);
80103f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2f:	05 34 02 00 00       	add    $0x234,%eax
80103f34:	83 ec 0c             	sub    $0xc,%esp
80103f37:	50                   	push   %eax
80103f38:	e8 e2 0c 00 00       	call   80104c1f <wakeup>
80103f3d:	83 c4 10             	add    $0x10,%esp
80103f40:	eb 21                	jmp    80103f63 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103f42:	8b 45 08             	mov    0x8(%ebp),%eax
80103f45:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f4c:	00 00 00 
    wakeup(&p->nwrite);
80103f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f52:	05 38 02 00 00       	add    $0x238,%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 bf 0c 00 00       	call   80104c1f <wakeup>
80103f60:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f63:	8b 45 08             	mov    0x8(%ebp),%eax
80103f66:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f6c:	85 c0                	test   %eax,%eax
80103f6e:	75 2c                	jne    80103f9c <pipeclose+0x98>
80103f70:	8b 45 08             	mov    0x8(%ebp),%eax
80103f73:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f79:	85 c0                	test   %eax,%eax
80103f7b:	75 1f                	jne    80103f9c <pipeclose+0x98>
    release(&p->lock);
80103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f80:	83 ec 0c             	sub    $0xc,%esp
80103f83:	50                   	push   %eax
80103f84:	e8 37 10 00 00       	call   80104fc0 <release>
80103f89:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103f8c:	83 ec 0c             	sub    $0xc,%esp
80103f8f:	ff 75 08             	pushl  0x8(%ebp)
80103f92:	e8 51 ec ff ff       	call   80102be8 <kfree>
80103f97:	83 c4 10             	add    $0x10,%esp
80103f9a:	eb 0f                	jmp    80103fab <pipeclose+0xa7>
  } else
    release(&p->lock);
80103f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9f:	83 ec 0c             	sub    $0xc,%esp
80103fa2:	50                   	push   %eax
80103fa3:	e8 18 10 00 00       	call   80104fc0 <release>
80103fa8:	83 c4 10             	add    $0x10,%esp
}
80103fab:	90                   	nop
80103fac:	c9                   	leave  
80103fad:	c3                   	ret    

80103fae <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fae:	55                   	push   %ebp
80103faf:	89 e5                	mov    %esp,%ebp
80103fb1:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb7:	83 ec 0c             	sub    $0xc,%esp
80103fba:	50                   	push   %eax
80103fbb:	e8 92 0f 00 00       	call   80104f52 <acquire>
80103fc0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103fca:	e9 ac 00 00 00       	jmp    8010407b <pipewrite+0xcd>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fd8:	85 c0                	test   %eax,%eax
80103fda:	74 0c                	je     80103fe8 <pipewrite+0x3a>
80103fdc:	e8 99 02 00 00       	call   8010427a <myproc>
80103fe1:	8b 40 24             	mov    0x24(%eax),%eax
80103fe4:	85 c0                	test   %eax,%eax
80103fe6:	74 19                	je     80104001 <pipewrite+0x53>
        release(&p->lock);
80103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80103feb:	83 ec 0c             	sub    $0xc,%esp
80103fee:	50                   	push   %eax
80103fef:	e8 cc 0f 00 00       	call   80104fc0 <release>
80103ff4:	83 c4 10             	add    $0x10,%esp
        return -1;
80103ff7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ffc:	e9 a8 00 00 00       	jmp    801040a9 <pipewrite+0xfb>
      }
      wakeup(&p->nread);
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	05 34 02 00 00       	add    $0x234,%eax
80104009:	83 ec 0c             	sub    $0xc,%esp
8010400c:	50                   	push   %eax
8010400d:	e8 0d 0c 00 00       	call   80104c1f <wakeup>
80104012:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	8b 55 08             	mov    0x8(%ebp),%edx
8010401b:	81 c2 38 02 00 00    	add    $0x238,%edx
80104021:	83 ec 08             	sub    $0x8,%esp
80104024:	50                   	push   %eax
80104025:	52                   	push   %edx
80104026:	e8 0e 0b 00 00       	call   80104b39 <sleep>
8010402b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010402e:	8b 45 08             	mov    0x8(%ebp),%eax
80104031:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104037:	8b 45 08             	mov    0x8(%ebp),%eax
8010403a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104040:	05 00 02 00 00       	add    $0x200,%eax
80104045:	39 c2                	cmp    %eax,%edx
80104047:	74 86                	je     80103fcf <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104049:	8b 45 08             	mov    0x8(%ebp),%eax
8010404c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104052:	8d 48 01             	lea    0x1(%eax),%ecx
80104055:	8b 55 08             	mov    0x8(%ebp),%edx
80104058:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010405e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104063:	89 c1                	mov    %eax,%ecx
80104065:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104068:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406b:	01 d0                	add    %edx,%eax
8010406d:	0f b6 10             	movzbl (%eax),%edx
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104077:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010407b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104081:	7c ab                	jl     8010402e <pipewrite+0x80>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104083:	8b 45 08             	mov    0x8(%ebp),%eax
80104086:	05 34 02 00 00       	add    $0x234,%eax
8010408b:	83 ec 0c             	sub    $0xc,%esp
8010408e:	50                   	push   %eax
8010408f:	e8 8b 0b 00 00       	call   80104c1f <wakeup>
80104094:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104097:	8b 45 08             	mov    0x8(%ebp),%eax
8010409a:	83 ec 0c             	sub    $0xc,%esp
8010409d:	50                   	push   %eax
8010409e:	e8 1d 0f 00 00       	call   80104fc0 <release>
801040a3:	83 c4 10             	add    $0x10,%esp
  return n;
801040a6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040a9:	c9                   	leave  
801040aa:	c3                   	ret    

801040ab <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040ab:	55                   	push   %ebp
801040ac:	89 e5                	mov    %esp,%ebp
801040ae:	53                   	push   %ebx
801040af:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	83 ec 0c             	sub    $0xc,%esp
801040b8:	50                   	push   %eax
801040b9:	e8 94 0e 00 00       	call   80104f52 <acquire>
801040be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040c1:	eb 3e                	jmp    80104101 <piperead+0x56>
    if(myproc()->killed){
801040c3:	e8 b2 01 00 00       	call   8010427a <myproc>
801040c8:	8b 40 24             	mov    0x24(%eax),%eax
801040cb:	85 c0                	test   %eax,%eax
801040cd:	74 19                	je     801040e8 <piperead+0x3d>
      release(&p->lock);
801040cf:	8b 45 08             	mov    0x8(%ebp),%eax
801040d2:	83 ec 0c             	sub    $0xc,%esp
801040d5:	50                   	push   %eax
801040d6:	e8 e5 0e 00 00       	call   80104fc0 <release>
801040db:	83 c4 10             	add    $0x10,%esp
      return -1;
801040de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e3:	e9 bf 00 00 00       	jmp    801041a7 <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801040e8:	8b 45 08             	mov    0x8(%ebp),%eax
801040eb:	8b 55 08             	mov    0x8(%ebp),%edx
801040ee:	81 c2 34 02 00 00    	add    $0x234,%edx
801040f4:	83 ec 08             	sub    $0x8,%esp
801040f7:	50                   	push   %eax
801040f8:	52                   	push   %edx
801040f9:	e8 3b 0a 00 00       	call   80104b39 <sleep>
801040fe:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104113:	39 c2                	cmp    %eax,%edx
80104115:	75 0d                	jne    80104124 <piperead+0x79>
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104120:	85 c0                	test   %eax,%eax
80104122:	75 9f                	jne    801040c3 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104124:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010412b:	eb 49                	jmp    80104176 <piperead+0xcb>
    if(p->nread == p->nwrite)
8010412d:	8b 45 08             	mov    0x8(%ebp),%eax
80104130:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010413f:	39 c2                	cmp    %eax,%edx
80104141:	74 3d                	je     80104180 <piperead+0xd5>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104143:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104146:	8b 45 0c             	mov    0xc(%ebp),%eax
80104149:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010414c:	8b 45 08             	mov    0x8(%ebp),%eax
8010414f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104155:	8d 48 01             	lea    0x1(%eax),%ecx
80104158:	8b 55 08             	mov    0x8(%ebp),%edx
8010415b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104161:	25 ff 01 00 00       	and    $0x1ff,%eax
80104166:	89 c2                	mov    %eax,%edx
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104170:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104172:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104179:	3b 45 10             	cmp    0x10(%ebp),%eax
8010417c:	7c af                	jl     8010412d <piperead+0x82>
8010417e:	eb 01                	jmp    80104181 <piperead+0xd6>
    if(p->nread == p->nwrite)
      break;
80104180:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104181:	8b 45 08             	mov    0x8(%ebp),%eax
80104184:	05 38 02 00 00       	add    $0x238,%eax
80104189:	83 ec 0c             	sub    $0xc,%esp
8010418c:	50                   	push   %eax
8010418d:	e8 8d 0a 00 00       	call   80104c1f <wakeup>
80104192:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104195:	8b 45 08             	mov    0x8(%ebp),%eax
80104198:	83 ec 0c             	sub    $0xc,%esp
8010419b:	50                   	push   %eax
8010419c:	e8 1f 0e 00 00       	call   80104fc0 <release>
801041a1:	83 c4 10             	add    $0x10,%esp
  return i;
801041a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041aa:	c9                   	leave  
801041ab:	c3                   	ret    

801041ac <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801041ac:	55                   	push   %ebp
801041ad:	89 e5                	mov    %esp,%ebp
801041af:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041b2:	9c                   	pushf  
801041b3:	58                   	pop    %eax
801041b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041ba:	c9                   	leave  
801041bb:	c3                   	ret    

801041bc <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801041bc:	55                   	push   %ebp
801041bd:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041bf:	fb                   	sti    
}
801041c0:	90                   	nop
801041c1:	5d                   	pop    %ebp
801041c2:	c3                   	ret    

801041c3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801041c3:	55                   	push   %ebp
801041c4:	89 e5                	mov    %esp,%ebp
801041c6:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801041c9:	83 ec 08             	sub    $0x8,%esp
801041cc:	68 c4 88 10 80       	push   $0x801088c4
801041d1:	68 a0 3d 11 80       	push   $0x80113da0
801041d6:	e8 55 0d 00 00       	call   80104f30 <initlock>
801041db:	83 c4 10             	add    $0x10,%esp
}
801041de:	90                   	nop
801041df:	c9                   	leave  
801041e0:	c3                   	ret    

801041e1 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801041e1:	55                   	push   %ebp
801041e2:	89 e5                	mov    %esp,%ebp
801041e4:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801041e7:	e8 16 00 00 00       	call   80104202 <mycpu>
801041ec:	89 c2                	mov    %eax,%edx
801041ee:	b8 00 38 11 80       	mov    $0x80113800,%eax
801041f3:	29 c2                	sub    %eax,%edx
801041f5:	89 d0                	mov    %edx,%eax
801041f7:	c1 f8 04             	sar    $0x4,%eax
801041fa:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104200:	c9                   	leave  
80104201:	c3                   	ret    

80104202 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104202:	55                   	push   %ebp
80104203:	89 e5                	mov    %esp,%ebp
80104205:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104208:	e8 9f ff ff ff       	call   801041ac <readeflags>
8010420d:	25 00 02 00 00       	and    $0x200,%eax
80104212:	85 c0                	test   %eax,%eax
80104214:	74 0d                	je     80104223 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80104216:	83 ec 0c             	sub    $0xc,%esp
80104219:	68 cc 88 10 80       	push   $0x801088cc
8010421e:	e8 7d c3 ff ff       	call   801005a0 <panic>
  
  apicid = lapicid();
80104223:	e8 b0 ed ff ff       	call   80102fd8 <lapicid>
80104228:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010422b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104232:	eb 2d                	jmp    80104261 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
80104234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104237:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010423d:	05 00 38 11 80       	add    $0x80113800,%eax
80104242:	0f b6 00             	movzbl (%eax),%eax
80104245:	0f b6 c0             	movzbl %al,%eax
80104248:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010424b:	75 10                	jne    8010425d <mycpu+0x5b>
      return &cpus[i];
8010424d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104250:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104256:	05 00 38 11 80       	add    $0x80113800,%eax
8010425b:	eb 1b                	jmp    80104278 <mycpu+0x76>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010425d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104261:	a1 80 3d 11 80       	mov    0x80113d80,%eax
80104266:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104269:	7c c9                	jl     80104234 <mycpu+0x32>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	68 f2 88 10 80       	push   $0x801088f2
80104273:	e8 28 c3 ff ff       	call   801005a0 <panic>
}
80104278:	c9                   	leave  
80104279:	c3                   	ret    

8010427a <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010427a:	55                   	push   %ebp
8010427b:	89 e5                	mov    %esp,%ebp
8010427d:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104280:	e8 38 0e 00 00       	call   801050bd <pushcli>
  c = mycpu();
80104285:	e8 78 ff ff ff       	call   80104202 <mycpu>
8010428a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010428d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104290:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104296:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104299:	e8 6d 0e 00 00       	call   8010510b <popcli>
  return p;
8010429e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042a1:	c9                   	leave  
801042a2:	c3                   	ret    

801042a3 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801042a3:	55                   	push   %ebp
801042a4:	89 e5                	mov    %esp,%ebp
801042a6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801042a9:	83 ec 0c             	sub    $0xc,%esp
801042ac:	68 a0 3d 11 80       	push   $0x80113da0
801042b1:	e8 9c 0c 00 00       	call   80104f52 <acquire>
801042b6:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042b9:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801042c0:	eb 0e                	jmp    801042d0 <allocproc+0x2d>
    if(p->state == UNUSED)
801042c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c5:	8b 40 0c             	mov    0xc(%eax),%eax
801042c8:	85 c0                	test   %eax,%eax
801042ca:	74 27                	je     801042f3 <allocproc+0x50>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042cc:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042d0:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801042d7:	72 e9                	jb     801042c2 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801042d9:	83 ec 0c             	sub    $0xc,%esp
801042dc:	68 a0 3d 11 80       	push   $0x80113da0
801042e1:	e8 da 0c 00 00       	call   80104fc0 <release>
801042e6:	83 c4 10             	add    $0x10,%esp
  return 0;
801042e9:	b8 00 00 00 00       	mov    $0x0,%eax
801042ee:	e9 b4 00 00 00       	jmp    801043a7 <allocproc+0x104>

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801042f3:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801042f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f7:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801042fe:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80104303:	8d 50 01             	lea    0x1(%eax),%edx
80104306:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
8010430c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430f:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	68 a0 3d 11 80       	push   $0x80113da0
8010431a:	e8 a1 0c 00 00       	call   80104fc0 <release>
8010431f:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104322:	e8 5b e9 ff ff       	call   80102c82 <kalloc>
80104327:	89 c2                	mov    %eax,%edx
80104329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432c:	89 50 08             	mov    %edx,0x8(%eax)
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	8b 40 08             	mov    0x8(%eax),%eax
80104335:	85 c0                	test   %eax,%eax
80104337:	75 11                	jne    8010434a <allocproc+0xa7>
    p->state = UNUSED;
80104339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104343:	b8 00 00 00 00       	mov    $0x0,%eax
80104348:	eb 5d                	jmp    801043a7 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
8010434a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434d:	8b 40 08             	mov    0x8(%eax),%eax
80104350:	05 00 10 00 00       	add    $0x1000,%eax
80104355:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104358:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010435c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104362:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104365:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104369:	ba b7 65 10 80       	mov    $0x801065b7,%edx
8010436e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104371:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104373:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010437d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104383:	8b 40 1c             	mov    0x1c(%eax),%eax
80104386:	83 ec 04             	sub    $0x4,%esp
80104389:	6a 14                	push   $0x14
8010438b:	6a 00                	push   $0x0
8010438d:	50                   	push   %eax
8010438e:	e8 36 0e 00 00       	call   801051c9 <memset>
80104393:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	8b 40 1c             	mov    0x1c(%eax),%eax
8010439c:	ba f3 4a 10 80       	mov    $0x80104af3,%edx
801043a1:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801043a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043a7:	c9                   	leave  
801043a8:	c3                   	ret    

801043a9 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801043a9:	55                   	push   %ebp
801043aa:	89 e5                	mov    %esp,%ebp
801043ac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801043af:	e8 ef fe ff ff       	call   801042a3 <allocproc>
801043b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	a3 20 b6 10 80       	mov    %eax,0x8010b620
  if((p->pgdir = setupkvm()) == 0)
801043bf:	e8 00 38 00 00       	call   80107bc4 <setupkvm>
801043c4:	89 c2                	mov    %eax,%edx
801043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c9:	89 50 04             	mov    %edx,0x4(%eax)
801043cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cf:	8b 40 04             	mov    0x4(%eax),%eax
801043d2:	85 c0                	test   %eax,%eax
801043d4:	75 0d                	jne    801043e3 <userinit+0x3a>
    panic("userinit: out of memory?");
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	68 02 89 10 80       	push   $0x80108902
801043de:	e8 bd c1 ff ff       	call   801005a0 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801043e3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	8b 40 04             	mov    0x4(%eax),%eax
801043ee:	83 ec 04             	sub    $0x4,%esp
801043f1:	52                   	push   %edx
801043f2:	68 c0 b4 10 80       	push   $0x8010b4c0
801043f7:	50                   	push   %eax
801043f8:	e8 2f 3a 00 00       	call   80107e2c <inituvm>
801043fd:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104403:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440c:	8b 40 18             	mov    0x18(%eax),%eax
8010440f:	83 ec 04             	sub    $0x4,%esp
80104412:	6a 4c                	push   $0x4c
80104414:	6a 00                	push   $0x0
80104416:	50                   	push   %eax
80104417:	e8 ad 0d 00 00       	call   801051c9 <memset>
8010441c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010441f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104422:	8b 40 18             	mov    0x18(%eax),%eax
80104425:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	8b 40 18             	mov    0x18(%eax),%eax
80104431:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	8b 40 18             	mov    0x18(%eax),%eax
8010443d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104440:	8b 52 18             	mov    0x18(%edx),%edx
80104443:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104447:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010444b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444e:	8b 40 18             	mov    0x18(%eax),%eax
80104451:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104454:	8b 52 18             	mov    0x18(%edx),%edx
80104457:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010445b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	8b 40 18             	mov    0x18(%eax),%eax
80104465:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 40 18             	mov    0x18(%eax),%eax
80104472:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	8b 40 18             	mov    0x18(%eax),%eax
8010447f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	83 c0 6c             	add    $0x6c,%eax
8010448c:	83 ec 04             	sub    $0x4,%esp
8010448f:	6a 10                	push   $0x10
80104491:	68 1b 89 10 80       	push   $0x8010891b
80104496:	50                   	push   %eax
80104497:	e8 30 0f 00 00       	call   801053cc <safestrcpy>
8010449c:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010449f:	83 ec 0c             	sub    $0xc,%esp
801044a2:	68 24 89 10 80       	push   $0x80108924
801044a7:	e8 91 e0 ff ff       	call   8010253d <namei>
801044ac:	83 c4 10             	add    $0x10,%esp
801044af:	89 c2                	mov    %eax,%edx
801044b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b4:	89 50 68             	mov    %edx,0x68(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801044b7:	83 ec 0c             	sub    $0xc,%esp
801044ba:	68 a0 3d 11 80       	push   $0x80113da0
801044bf:	e8 8e 0a 00 00       	call   80104f52 <acquire>
801044c4:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801044d1:	83 ec 0c             	sub    $0xc,%esp
801044d4:	68 a0 3d 11 80       	push   $0x80113da0
801044d9:	e8 e2 0a 00 00       	call   80104fc0 <release>
801044de:	83 c4 10             	add    $0x10,%esp
}
801044e1:	90                   	nop
801044e2:	c9                   	leave  
801044e3:	c3                   	ret    

801044e4 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044e4:	55                   	push   %ebp
801044e5:	89 e5                	mov    %esp,%ebp
801044e7:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801044ea:	e8 8b fd ff ff       	call   8010427a <myproc>
801044ef:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801044f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f5:	8b 00                	mov    (%eax),%eax
801044f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801044fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044fe:	7e 2e                	jle    8010452e <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104500:	8b 55 08             	mov    0x8(%ebp),%edx
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	01 c2                	add    %eax,%edx
80104508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450b:	8b 40 04             	mov    0x4(%eax),%eax
8010450e:	83 ec 04             	sub    $0x4,%esp
80104511:	52                   	push   %edx
80104512:	ff 75 f4             	pushl  -0xc(%ebp)
80104515:	50                   	push   %eax
80104516:	e8 4e 3a 00 00       	call   80107f69 <allocuvm>
8010451b:	83 c4 10             	add    $0x10,%esp
8010451e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104521:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104525:	75 3b                	jne    80104562 <growproc+0x7e>
      return -1;
80104527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010452c:	eb 4f                	jmp    8010457d <growproc+0x99>
  } else if(n < 0){
8010452e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104532:	79 2e                	jns    80104562 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104534:	8b 55 08             	mov    0x8(%ebp),%edx
80104537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453a:	01 c2                	add    %eax,%edx
8010453c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453f:	8b 40 04             	mov    0x4(%eax),%eax
80104542:	83 ec 04             	sub    $0x4,%esp
80104545:	52                   	push   %edx
80104546:	ff 75 f4             	pushl  -0xc(%ebp)
80104549:	50                   	push   %eax
8010454a:	e8 1f 3b 00 00       	call   8010806e <deallocuvm>
8010454f:	83 c4 10             	add    $0x10,%esp
80104552:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104555:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104559:	75 07                	jne    80104562 <growproc+0x7e>
      return -1;
8010455b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104560:	eb 1b                	jmp    8010457d <growproc+0x99>
  }
  curproc->sz = sz;
80104562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104565:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104568:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010456a:	83 ec 0c             	sub    $0xc,%esp
8010456d:	ff 75 f0             	pushl  -0x10(%ebp)
80104570:	e8 19 37 00 00       	call   80107c8e <switchuvm>
80104575:	83 c4 10             	add    $0x10,%esp
  return 0;
80104578:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010457d:	c9                   	leave  
8010457e:	c3                   	ret    

8010457f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010457f:	55                   	push   %ebp
80104580:	89 e5                	mov    %esp,%ebp
80104582:	57                   	push   %edi
80104583:	56                   	push   %esi
80104584:	53                   	push   %ebx
80104585:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104588:	e8 ed fc ff ff       	call   8010427a <myproc>
8010458d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104590:	e8 0e fd ff ff       	call   801042a3 <allocproc>
80104595:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104598:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010459c:	75 0a                	jne    801045a8 <fork+0x29>
    return -1;
8010459e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a3:	e9 56 01 00 00       	jmp    801046fe <fork+0x17f>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz,curproc->tf->esp)) == 0){
801045a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045ab:	8b 40 18             	mov    0x18(%eax),%eax
801045ae:	8b 48 44             	mov    0x44(%eax),%ecx
801045b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b4:	8b 10                	mov    (%eax),%edx
801045b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b9:	8b 40 04             	mov    0x4(%eax),%eax
801045bc:	83 ec 04             	sub    $0x4,%esp
801045bf:	51                   	push   %ecx
801045c0:	52                   	push   %edx
801045c1:	50                   	push   %eax
801045c2:	e8 45 3c 00 00       	call   8010820c <copyuvm>
801045c7:	83 c4 10             	add    $0x10,%esp
801045ca:	89 c2                	mov    %eax,%edx
801045cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045cf:	89 50 04             	mov    %edx,0x4(%eax)
801045d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d5:	8b 40 04             	mov    0x4(%eax),%eax
801045d8:	85 c0                	test   %eax,%eax
801045da:	75 30                	jne    8010460c <fork+0x8d>
    kfree(np->kstack);
801045dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045df:	8b 40 08             	mov    0x8(%eax),%eax
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	50                   	push   %eax
801045e6:	e8 fd e5 ff ff       	call   80102be8 <kfree>
801045eb:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801045ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801045f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045fb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104607:	e9 f2 00 00 00       	jmp    801046fe <fork+0x17f>
  }
  np->sz = curproc->sz;
8010460c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010460f:	8b 10                	mov    (%eax),%edx
80104611:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104614:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104616:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104619:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010461c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010461f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104622:	8b 50 18             	mov    0x18(%eax),%edx
80104625:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104628:	8b 40 18             	mov    0x18(%eax),%eax
8010462b:	89 c3                	mov    %eax,%ebx
8010462d:	b8 13 00 00 00       	mov    $0x13,%eax
80104632:	89 d7                	mov    %edx,%edi
80104634:	89 de                	mov    %ebx,%esi
80104636:	89 c1                	mov    %eax,%ecx
80104638:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010463a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010463d:	8b 40 18             	mov    0x18(%eax),%eax
80104640:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104647:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010464e:	eb 3d                	jmp    8010468d <fork+0x10e>
    if(curproc->ofile[i])
80104650:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104656:	83 c2 08             	add    $0x8,%edx
80104659:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010465d:	85 c0                	test   %eax,%eax
8010465f:	74 28                	je     80104689 <fork+0x10a>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104661:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104667:	83 c2 08             	add    $0x8,%edx
8010466a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010466e:	83 ec 0c             	sub    $0xc,%esp
80104671:	50                   	push   %eax
80104672:	e8 d6 c9 ff ff       	call   8010104d <filedup>
80104677:	83 c4 10             	add    $0x10,%esp
8010467a:	89 c1                	mov    %eax,%ecx
8010467c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010467f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104682:	83 c2 08             	add    $0x8,%edx
80104685:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104689:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010468d:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104691:	7e bd                	jle    80104650 <fork+0xd1>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104693:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104696:	8b 40 68             	mov    0x68(%eax),%eax
80104699:	83 ec 0c             	sub    $0xc,%esp
8010469c:	50                   	push   %eax
8010469d:	e8 21 d3 ff ff       	call   801019c3 <idup>
801046a2:	83 c4 10             	add    $0x10,%esp
801046a5:	89 c2                	mov    %eax,%edx
801046a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046aa:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b0:	8d 50 6c             	lea    0x6c(%eax),%edx
801046b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b6:	83 c0 6c             	add    $0x6c,%eax
801046b9:	83 ec 04             	sub    $0x4,%esp
801046bc:	6a 10                	push   $0x10
801046be:	52                   	push   %edx
801046bf:	50                   	push   %eax
801046c0:	e8 07 0d 00 00       	call   801053cc <safestrcpy>
801046c5:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801046c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046cb:	8b 40 10             	mov    0x10(%eax),%eax
801046ce:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801046d1:	83 ec 0c             	sub    $0xc,%esp
801046d4:	68 a0 3d 11 80       	push   $0x80113da0
801046d9:	e8 74 08 00 00       	call   80104f52 <acquire>
801046de:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801046e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046e4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801046eb:	83 ec 0c             	sub    $0xc,%esp
801046ee:	68 a0 3d 11 80       	push   $0x80113da0
801046f3:	e8 c8 08 00 00       	call   80104fc0 <release>
801046f8:	83 c4 10             	add    $0x10,%esp

  return pid;
801046fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801046fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104701:	5b                   	pop    %ebx
80104702:	5e                   	pop    %esi
80104703:	5f                   	pop    %edi
80104704:	5d                   	pop    %ebp
80104705:	c3                   	ret    

80104706 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104706:	55                   	push   %ebp
80104707:	89 e5                	mov    %esp,%ebp
80104709:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010470c:	e8 69 fb ff ff       	call   8010427a <myproc>
80104711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104714:	a1 20 b6 10 80       	mov    0x8010b620,%eax
80104719:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010471c:	75 0d                	jne    8010472b <exit+0x25>
    panic("init exiting");
8010471e:	83 ec 0c             	sub    $0xc,%esp
80104721:	68 26 89 10 80       	push   $0x80108926
80104726:	e8 75 be ff ff       	call   801005a0 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010472b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104732:	eb 3f                	jmp    80104773 <exit+0x6d>
    if(curproc->ofile[fd]){
80104734:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104737:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010473a:	83 c2 08             	add    $0x8,%edx
8010473d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104741:	85 c0                	test   %eax,%eax
80104743:	74 2a                	je     8010476f <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104745:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104748:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010474b:	83 c2 08             	add    $0x8,%edx
8010474e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	50                   	push   %eax
80104756:	e8 43 c9 ff ff       	call   8010109e <fileclose>
8010475b:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010475e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104761:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104764:	83 c2 08             	add    $0x8,%edx
80104767:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010476e:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010476f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104773:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104777:	7e bb                	jle    80104734 <exit+0x2e>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104779:	e8 a4 ed ff ff       	call   80103522 <begin_op>
  iput(curproc->cwd);
8010477e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104781:	8b 40 68             	mov    0x68(%eax),%eax
80104784:	83 ec 0c             	sub    $0xc,%esp
80104787:	50                   	push   %eax
80104788:	e8 d1 d3 ff ff       	call   80101b5e <iput>
8010478d:	83 c4 10             	add    $0x10,%esp
  end_op();
80104790:	e8 19 ee ff ff       	call   801035ae <end_op>
  curproc->cwd = 0;
80104795:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104798:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010479f:	83 ec 0c             	sub    $0xc,%esp
801047a2:	68 a0 3d 11 80       	push   $0x80113da0
801047a7:	e8 a6 07 00 00       	call   80104f52 <acquire>
801047ac:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b2:	8b 40 14             	mov    0x14(%eax),%eax
801047b5:	83 ec 0c             	sub    $0xc,%esp
801047b8:	50                   	push   %eax
801047b9:	e8 22 04 00 00       	call   80104be0 <wakeup1>
801047be:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047c1:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
801047c8:	eb 37                	jmp    80104801 <exit+0xfb>
    if(p->parent == curproc){
801047ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cd:	8b 40 14             	mov    0x14(%eax),%eax
801047d0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801047d3:	75 28                	jne    801047fd <exit+0xf7>
      p->parent = initproc;
801047d5:	8b 15 20 b6 10 80    	mov    0x8010b620,%edx
801047db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047de:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801047e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e4:	8b 40 0c             	mov    0xc(%eax),%eax
801047e7:	83 f8 05             	cmp    $0x5,%eax
801047ea:	75 11                	jne    801047fd <exit+0xf7>
        wakeup1(initproc);
801047ec:	a1 20 b6 10 80       	mov    0x8010b620,%eax
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	50                   	push   %eax
801047f5:	e8 e6 03 00 00       	call   80104be0 <wakeup1>
801047fa:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047fd:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104801:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104808:	72 c0                	jb     801047ca <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010480a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010480d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104814:	e8 e5 01 00 00       	call   801049fe <sched>
  panic("zombie exit");
80104819:	83 ec 0c             	sub    $0xc,%esp
8010481c:	68 33 89 10 80       	push   $0x80108933
80104821:	e8 7a bd ff ff       	call   801005a0 <panic>

80104826 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104826:	55                   	push   %ebp
80104827:	89 e5                	mov    %esp,%ebp
80104829:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010482c:	e8 49 fa ff ff       	call   8010427a <myproc>
80104831:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104834:	83 ec 0c             	sub    $0xc,%esp
80104837:	68 a0 3d 11 80       	push   $0x80113da0
8010483c:	e8 11 07 00 00       	call   80104f52 <acquire>
80104841:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104844:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010484b:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104852:	e9 a1 00 00 00       	jmp    801048f8 <wait+0xd2>
      if(p->parent != curproc)
80104857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485a:	8b 40 14             	mov    0x14(%eax),%eax
8010485d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104860:	0f 85 8d 00 00 00    	jne    801048f3 <wait+0xcd>
        continue;
      havekids = 1;
80104866:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104870:	8b 40 0c             	mov    0xc(%eax),%eax
80104873:	83 f8 05             	cmp    $0x5,%eax
80104876:	75 7c                	jne    801048f4 <wait+0xce>
        // Found one.
        pid = p->pid;
80104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010487b:	8b 40 10             	mov    0x10(%eax),%eax
8010487e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	8b 40 08             	mov    0x8(%eax),%eax
80104887:	83 ec 0c             	sub    $0xc,%esp
8010488a:	50                   	push   %eax
8010488b:	e8 58 e3 ff ff       	call   80102be8 <kfree>
80104890:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104896:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010489d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a0:	8b 40 04             	mov    0x4(%eax),%eax
801048a3:	83 ec 0c             	sub    $0xc,%esp
801048a6:	50                   	push   %eax
801048a7:	e8 86 38 00 00       	call   80108132 <freevm>
801048ac:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801048b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801048c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801048ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801048d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801048de:	83 ec 0c             	sub    $0xc,%esp
801048e1:	68 a0 3d 11 80       	push   $0x80113da0
801048e6:	e8 d5 06 00 00       	call   80104fc0 <release>
801048eb:	83 c4 10             	add    $0x10,%esp
        return pid;
801048ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048f1:	eb 51                	jmp    80104944 <wait+0x11e>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
801048f3:	90                   	nop
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048f8:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801048ff:	0f 82 52 ff ff ff    	jb     80104857 <wait+0x31>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104905:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104909:	74 0a                	je     80104915 <wait+0xef>
8010490b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010490e:	8b 40 24             	mov    0x24(%eax),%eax
80104911:	85 c0                	test   %eax,%eax
80104913:	74 17                	je     8010492c <wait+0x106>
      release(&ptable.lock);
80104915:	83 ec 0c             	sub    $0xc,%esp
80104918:	68 a0 3d 11 80       	push   $0x80113da0
8010491d:	e8 9e 06 00 00       	call   80104fc0 <release>
80104922:	83 c4 10             	add    $0x10,%esp
      return -1;
80104925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010492a:	eb 18                	jmp    80104944 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010492c:	83 ec 08             	sub    $0x8,%esp
8010492f:	68 a0 3d 11 80       	push   $0x80113da0
80104934:	ff 75 ec             	pushl  -0x14(%ebp)
80104937:	e8 fd 01 00 00       	call   80104b39 <sleep>
8010493c:	83 c4 10             	add    $0x10,%esp
  }
8010493f:	e9 00 ff ff ff       	jmp    80104844 <wait+0x1e>
}
80104944:	c9                   	leave  
80104945:	c3                   	ret    

80104946 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104946:	55                   	push   %ebp
80104947:	89 e5                	mov    %esp,%ebp
80104949:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010494c:	e8 b1 f8 ff ff       	call   80104202 <mycpu>
80104951:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104957:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010495e:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104961:	e8 56 f8 ff ff       	call   801041bc <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104966:	83 ec 0c             	sub    $0xc,%esp
80104969:	68 a0 3d 11 80       	push   $0x80113da0
8010496e:	e8 df 05 00 00       	call   80104f52 <acquire>
80104973:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104976:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
8010497d:	eb 61                	jmp    801049e0 <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	8b 40 0c             	mov    0xc(%eax),%eax
80104985:	83 f8 03             	cmp    $0x3,%eax
80104988:	75 51                	jne    801049db <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010498a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104990:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104996:	83 ec 0c             	sub    $0xc,%esp
80104999:	ff 75 f4             	pushl  -0xc(%ebp)
8010499c:	e8 ed 32 00 00       	call   80107c8e <switchuvm>
801049a1:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801049a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a7:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801049ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b1:	8b 40 1c             	mov    0x1c(%eax),%eax
801049b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049b7:	83 c2 04             	add    $0x4,%edx
801049ba:	83 ec 08             	sub    $0x8,%esp
801049bd:	50                   	push   %eax
801049be:	52                   	push   %edx
801049bf:	e8 79 0a 00 00       	call   8010543d <swtch>
801049c4:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801049c7:	e8 a9 32 00 00       	call   80107c75 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801049cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049cf:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049d6:	00 00 00 
801049d9:	eb 01                	jmp    801049dc <scheduler+0x96>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801049db:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049dc:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049e0:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
801049e7:	72 96                	jb     8010497f <scheduler+0x39>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801049e9:	83 ec 0c             	sub    $0xc,%esp
801049ec:	68 a0 3d 11 80       	push   $0x80113da0
801049f1:	e8 ca 05 00 00       	call   80104fc0 <release>
801049f6:	83 c4 10             	add    $0x10,%esp

  }
801049f9:	e9 63 ff ff ff       	jmp    80104961 <scheduler+0x1b>

801049fe <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801049fe:	55                   	push   %ebp
801049ff:	89 e5                	mov    %esp,%ebp
80104a01:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104a04:	e8 71 f8 ff ff       	call   8010427a <myproc>
80104a09:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104a0c:	83 ec 0c             	sub    $0xc,%esp
80104a0f:	68 a0 3d 11 80       	push   $0x80113da0
80104a14:	e8 73 06 00 00       	call   8010508c <holding>
80104a19:	83 c4 10             	add    $0x10,%esp
80104a1c:	85 c0                	test   %eax,%eax
80104a1e:	75 0d                	jne    80104a2d <sched+0x2f>
    panic("sched ptable.lock");
80104a20:	83 ec 0c             	sub    $0xc,%esp
80104a23:	68 3f 89 10 80       	push   $0x8010893f
80104a28:	e8 73 bb ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli != 1)
80104a2d:	e8 d0 f7 ff ff       	call   80104202 <mycpu>
80104a32:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a38:	83 f8 01             	cmp    $0x1,%eax
80104a3b:	74 0d                	je     80104a4a <sched+0x4c>
    panic("sched locks");
80104a3d:	83 ec 0c             	sub    $0xc,%esp
80104a40:	68 51 89 10 80       	push   $0x80108951
80104a45:	e8 56 bb ff ff       	call   801005a0 <panic>
  if(p->state == RUNNING)
80104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104a50:	83 f8 04             	cmp    $0x4,%eax
80104a53:	75 0d                	jne    80104a62 <sched+0x64>
    panic("sched running");
80104a55:	83 ec 0c             	sub    $0xc,%esp
80104a58:	68 5d 89 10 80       	push   $0x8010895d
80104a5d:	e8 3e bb ff ff       	call   801005a0 <panic>
  if(readeflags()&FL_IF)
80104a62:	e8 45 f7 ff ff       	call   801041ac <readeflags>
80104a67:	25 00 02 00 00       	and    $0x200,%eax
80104a6c:	85 c0                	test   %eax,%eax
80104a6e:	74 0d                	je     80104a7d <sched+0x7f>
    panic("sched interruptible");
80104a70:	83 ec 0c             	sub    $0xc,%esp
80104a73:	68 6b 89 10 80       	push   $0x8010896b
80104a78:	e8 23 bb ff ff       	call   801005a0 <panic>
  intena = mycpu()->intena;
80104a7d:	e8 80 f7 ff ff       	call   80104202 <mycpu>
80104a82:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104a8b:	e8 72 f7 ff ff       	call   80104202 <mycpu>
80104a90:	8b 40 04             	mov    0x4(%eax),%eax
80104a93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a96:	83 c2 1c             	add    $0x1c,%edx
80104a99:	83 ec 08             	sub    $0x8,%esp
80104a9c:	50                   	push   %eax
80104a9d:	52                   	push   %edx
80104a9e:	e8 9a 09 00 00       	call   8010543d <swtch>
80104aa3:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104aa6:	e8 57 f7 ff ff       	call   80104202 <mycpu>
80104aab:	89 c2                	mov    %eax,%edx
80104aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab0:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
}
80104ab6:	90                   	nop
80104ab7:	c9                   	leave  
80104ab8:	c3                   	ret    

80104ab9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ab9:	55                   	push   %ebp
80104aba:	89 e5                	mov    %esp,%ebp
80104abc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104abf:	83 ec 0c             	sub    $0xc,%esp
80104ac2:	68 a0 3d 11 80       	push   $0x80113da0
80104ac7:	e8 86 04 00 00       	call   80104f52 <acquire>
80104acc:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104acf:	e8 a6 f7 ff ff       	call   8010427a <myproc>
80104ad4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104adb:	e8 1e ff ff ff       	call   801049fe <sched>
  release(&ptable.lock);
80104ae0:	83 ec 0c             	sub    $0xc,%esp
80104ae3:	68 a0 3d 11 80       	push   $0x80113da0
80104ae8:	e8 d3 04 00 00       	call   80104fc0 <release>
80104aed:	83 c4 10             	add    $0x10,%esp
}
80104af0:	90                   	nop
80104af1:	c9                   	leave  
80104af2:	c3                   	ret    

80104af3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104af3:	55                   	push   %ebp
80104af4:	89 e5                	mov    %esp,%ebp
80104af6:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104af9:	83 ec 0c             	sub    $0xc,%esp
80104afc:	68 a0 3d 11 80       	push   $0x80113da0
80104b01:	e8 ba 04 00 00       	call   80104fc0 <release>
80104b06:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104b09:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104b0e:	85 c0                	test   %eax,%eax
80104b10:	74 24                	je     80104b36 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b12:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104b19:	00 00 00 
    iinit(ROOTDEV);
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	6a 01                	push   $0x1
80104b21:	e8 65 cb ff ff       	call   8010168b <iinit>
80104b26:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	6a 01                	push   $0x1
80104b2e:	e8 d1 e7 ff ff       	call   80103304 <initlog>
80104b33:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b36:	90                   	nop
80104b37:	c9                   	leave  
80104b38:	c3                   	ret    

80104b39 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b39:	55                   	push   %ebp
80104b3a:	89 e5                	mov    %esp,%ebp
80104b3c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104b3f:	e8 36 f7 ff ff       	call   8010427a <myproc>
80104b44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104b47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b4b:	75 0d                	jne    80104b5a <sleep+0x21>
    panic("sleep");
80104b4d:	83 ec 0c             	sub    $0xc,%esp
80104b50:	68 7f 89 10 80       	push   $0x8010897f
80104b55:	e8 46 ba ff ff       	call   801005a0 <panic>

  if(lk == 0)
80104b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b5e:	75 0d                	jne    80104b6d <sleep+0x34>
    panic("sleep without lk");
80104b60:	83 ec 0c             	sub    $0xc,%esp
80104b63:	68 85 89 10 80       	push   $0x80108985
80104b68:	e8 33 ba ff ff       	call   801005a0 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b6d:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104b74:	74 1e                	je     80104b94 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b76:	83 ec 0c             	sub    $0xc,%esp
80104b79:	68 a0 3d 11 80       	push   $0x80113da0
80104b7e:	e8 cf 03 00 00       	call   80104f52 <acquire>
80104b83:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104b86:	83 ec 0c             	sub    $0xc,%esp
80104b89:	ff 75 0c             	pushl  0xc(%ebp)
80104b8c:	e8 2f 04 00 00       	call   80104fc0 <release>
80104b91:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b97:	8b 55 08             	mov    0x8(%ebp),%edx
80104b9a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104ba7:	e8 52 fe ff ff       	call   801049fe <sched>

  // Tidy up.
  p->chan = 0;
80104bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baf:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104bb6:	81 7d 0c a0 3d 11 80 	cmpl   $0x80113da0,0xc(%ebp)
80104bbd:	74 1e                	je     80104bdd <sleep+0xa4>
    release(&ptable.lock);
80104bbf:	83 ec 0c             	sub    $0xc,%esp
80104bc2:	68 a0 3d 11 80       	push   $0x80113da0
80104bc7:	e8 f4 03 00 00       	call   80104fc0 <release>
80104bcc:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104bcf:	83 ec 0c             	sub    $0xc,%esp
80104bd2:	ff 75 0c             	pushl  0xc(%ebp)
80104bd5:	e8 78 03 00 00       	call   80104f52 <acquire>
80104bda:	83 c4 10             	add    $0x10,%esp
  }
}
80104bdd:	90                   	nop
80104bde:	c9                   	leave  
80104bdf:	c3                   	ret    

80104be0 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104be0:	55                   	push   %ebp
80104be1:	89 e5                	mov    %esp,%ebp
80104be3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104be6:	c7 45 fc d4 3d 11 80 	movl   $0x80113dd4,-0x4(%ebp)
80104bed:	eb 24                	jmp    80104c13 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bf2:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf5:	83 f8 02             	cmp    $0x2,%eax
80104bf8:	75 15                	jne    80104c0f <wakeup1+0x2f>
80104bfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bfd:	8b 40 20             	mov    0x20(%eax),%eax
80104c00:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c03:	75 0a                	jne    80104c0f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c08:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c0f:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104c13:	81 7d fc d4 5d 11 80 	cmpl   $0x80115dd4,-0x4(%ebp)
80104c1a:	72 d3                	jb     80104bef <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c1c:	90                   	nop
80104c1d:	c9                   	leave  
80104c1e:	c3                   	ret    

80104c1f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c1f:	55                   	push   %ebp
80104c20:	89 e5                	mov    %esp,%ebp
80104c22:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104c25:	83 ec 0c             	sub    $0xc,%esp
80104c28:	68 a0 3d 11 80       	push   $0x80113da0
80104c2d:	e8 20 03 00 00       	call   80104f52 <acquire>
80104c32:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104c35:	83 ec 0c             	sub    $0xc,%esp
80104c38:	ff 75 08             	pushl  0x8(%ebp)
80104c3b:	e8 a0 ff ff ff       	call   80104be0 <wakeup1>
80104c40:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	68 a0 3d 11 80       	push   $0x80113da0
80104c4b:	e8 70 03 00 00       	call   80104fc0 <release>
80104c50:	83 c4 10             	add    $0x10,%esp
}
80104c53:	90                   	nop
80104c54:	c9                   	leave  
80104c55:	c3                   	ret    

80104c56 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c56:	55                   	push   %ebp
80104c57:	89 e5                	mov    %esp,%ebp
80104c59:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c5c:	83 ec 0c             	sub    $0xc,%esp
80104c5f:	68 a0 3d 11 80       	push   $0x80113da0
80104c64:	e8 e9 02 00 00       	call   80104f52 <acquire>
80104c69:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6c:	c7 45 f4 d4 3d 11 80 	movl   $0x80113dd4,-0xc(%ebp)
80104c73:	eb 45                	jmp    80104cba <kill+0x64>
    if(p->pid == pid){
80104c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c78:	8b 40 10             	mov    0x10(%eax),%eax
80104c7b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c7e:	75 36                	jne    80104cb6 <kill+0x60>
      p->killed = 1;
80104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c83:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8d:	8b 40 0c             	mov    0xc(%eax),%eax
80104c90:	83 f8 02             	cmp    $0x2,%eax
80104c93:	75 0a                	jne    80104c9f <kill+0x49>
        p->state = RUNNABLE;
80104c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c98:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c9f:	83 ec 0c             	sub    $0xc,%esp
80104ca2:	68 a0 3d 11 80       	push   $0x80113da0
80104ca7:	e8 14 03 00 00       	call   80104fc0 <release>
80104cac:	83 c4 10             	add    $0x10,%esp
      return 0;
80104caf:	b8 00 00 00 00       	mov    $0x0,%eax
80104cb4:	eb 22                	jmp    80104cd8 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb6:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104cba:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104cc1:	72 b2                	jb     80104c75 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	68 a0 3d 11 80       	push   $0x80113da0
80104ccb:	e8 f0 02 00 00       	call   80104fc0 <release>
80104cd0:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cd8:	c9                   	leave  
80104cd9:	c3                   	ret    

80104cda <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cda:	55                   	push   %ebp
80104cdb:	89 e5                	mov    %esp,%ebp
80104cdd:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce0:	c7 45 f0 d4 3d 11 80 	movl   $0x80113dd4,-0x10(%ebp)
80104ce7:	e9 d7 00 00 00       	jmp    80104dc3 <procdump+0xe9>
    if(p->state == UNUSED)
80104cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cef:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf2:	85 c0                	test   %eax,%eax
80104cf4:	0f 84 c4 00 00 00    	je     80104dbe <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104d00:	83 f8 05             	cmp    $0x5,%eax
80104d03:	77 23                	ja     80104d28 <procdump+0x4e>
80104d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d08:	8b 40 0c             	mov    0xc(%eax),%eax
80104d0b:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d12:	85 c0                	test   %eax,%eax
80104d14:	74 12                	je     80104d28 <procdump+0x4e>
      state = states[p->state];
80104d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d19:	8b 40 0c             	mov    0xc(%eax),%eax
80104d1c:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d23:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d26:	eb 07                	jmp    80104d2f <procdump+0x55>
    else
      state = "???";
80104d28:	c7 45 ec 96 89 10 80 	movl   $0x80108996,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d32:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d38:	8b 40 10             	mov    0x10(%eax),%eax
80104d3b:	52                   	push   %edx
80104d3c:	ff 75 ec             	pushl  -0x14(%ebp)
80104d3f:	50                   	push   %eax
80104d40:	68 9a 89 10 80       	push   $0x8010899a
80104d45:	e8 b6 b6 ff ff       	call   80100400 <cprintf>
80104d4a:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d50:	8b 40 0c             	mov    0xc(%eax),%eax
80104d53:	83 f8 02             	cmp    $0x2,%eax
80104d56:	75 54                	jne    80104dac <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d5e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d61:	83 c0 08             	add    $0x8,%eax
80104d64:	89 c2                	mov    %eax,%edx
80104d66:	83 ec 08             	sub    $0x8,%esp
80104d69:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104d6c:	50                   	push   %eax
80104d6d:	52                   	push   %edx
80104d6e:	e8 9f 02 00 00       	call   80105012 <getcallerpcs>
80104d73:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104d76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d7d:	eb 1c                	jmp    80104d9b <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d82:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d86:	83 ec 08             	sub    $0x8,%esp
80104d89:	50                   	push   %eax
80104d8a:	68 a3 89 10 80       	push   $0x801089a3
80104d8f:	e8 6c b6 ff ff       	call   80100400 <cprintf>
80104d94:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d9b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d9f:	7f 0b                	jg     80104dac <procdump+0xd2>
80104da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104da8:	85 c0                	test   %eax,%eax
80104daa:	75 d3                	jne    80104d7f <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104dac:	83 ec 0c             	sub    $0xc,%esp
80104daf:	68 a7 89 10 80       	push   $0x801089a7
80104db4:	e8 47 b6 ff ff       	call   80100400 <cprintf>
80104db9:	83 c4 10             	add    $0x10,%esp
80104dbc:	eb 01                	jmp    80104dbf <procdump+0xe5>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104dbe:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dbf:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104dc3:	81 7d f0 d4 5d 11 80 	cmpl   $0x80115dd4,-0x10(%ebp)
80104dca:	0f 82 1c ff ff ff    	jb     80104cec <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104dd0:	90                   	nop
80104dd1:	c9                   	leave  
80104dd2:	c3                   	ret    

80104dd3 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104dd3:	55                   	push   %ebp
80104dd4:	89 e5                	mov    %esp,%ebp
80104dd6:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddc:	83 c0 04             	add    $0x4,%eax
80104ddf:	83 ec 08             	sub    $0x8,%esp
80104de2:	68 d3 89 10 80       	push   $0x801089d3
80104de7:	50                   	push   %eax
80104de8:	e8 43 01 00 00       	call   80104f30 <initlock>
80104ded:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104df0:	8b 45 08             	mov    0x8(%ebp),%eax
80104df3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104df6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104df9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e02:	8b 45 08             	mov    0x8(%ebp),%eax
80104e05:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e0c:	90                   	nop
80104e0d:	c9                   	leave  
80104e0e:	c3                   	ret    

80104e0f <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e0f:	55                   	push   %ebp
80104e10:	89 e5                	mov    %esp,%ebp
80104e12:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e15:	8b 45 08             	mov    0x8(%ebp),%eax
80104e18:	83 c0 04             	add    $0x4,%eax
80104e1b:	83 ec 0c             	sub    $0xc,%esp
80104e1e:	50                   	push   %eax
80104e1f:	e8 2e 01 00 00       	call   80104f52 <acquire>
80104e24:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104e27:	eb 15                	jmp    80104e3e <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104e29:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2c:	83 c0 04             	add    $0x4,%eax
80104e2f:	83 ec 08             	sub    $0x8,%esp
80104e32:	50                   	push   %eax
80104e33:	ff 75 08             	pushl  0x8(%ebp)
80104e36:	e8 fe fc ff ff       	call   80104b39 <sleep>
80104e3b:	83 c4 10             	add    $0x10,%esp

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e41:	8b 00                	mov    (%eax),%eax
80104e43:	85 c0                	test   %eax,%eax
80104e45:	75 e2                	jne    80104e29 <acquiresleep+0x1a>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104e50:	e8 25 f4 ff ff       	call   8010427a <myproc>
80104e55:	8b 50 10             	mov    0x10(%eax),%edx
80104e58:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5b:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e61:	83 c0 04             	add    $0x4,%eax
80104e64:	83 ec 0c             	sub    $0xc,%esp
80104e67:	50                   	push   %eax
80104e68:	e8 53 01 00 00       	call   80104fc0 <release>
80104e6d:	83 c4 10             	add    $0x10,%esp
}
80104e70:	90                   	nop
80104e71:	c9                   	leave  
80104e72:	c3                   	ret    

80104e73 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104e73:	55                   	push   %ebp
80104e74:	89 e5                	mov    %esp,%ebp
80104e76:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e79:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7c:	83 c0 04             	add    $0x4,%eax
80104e7f:	83 ec 0c             	sub    $0xc,%esp
80104e82:	50                   	push   %eax
80104e83:	e8 ca 00 00 00       	call   80104f52 <acquire>
80104e88:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e94:	8b 45 08             	mov    0x8(%ebp),%eax
80104e97:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104e9e:	83 ec 0c             	sub    $0xc,%esp
80104ea1:	ff 75 08             	pushl  0x8(%ebp)
80104ea4:	e8 76 fd ff ff       	call   80104c1f <wakeup>
80104ea9:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104eac:	8b 45 08             	mov    0x8(%ebp),%eax
80104eaf:	83 c0 04             	add    $0x4,%eax
80104eb2:	83 ec 0c             	sub    $0xc,%esp
80104eb5:	50                   	push   %eax
80104eb6:	e8 05 01 00 00       	call   80104fc0 <release>
80104ebb:	83 c4 10             	add    $0x10,%esp
}
80104ebe:	90                   	nop
80104ebf:	c9                   	leave  
80104ec0:	c3                   	ret    

80104ec1 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104ec1:	55                   	push   %ebp
80104ec2:	89 e5                	mov    %esp,%ebp
80104ec4:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eca:	83 c0 04             	add    $0x4,%eax
80104ecd:	83 ec 0c             	sub    $0xc,%esp
80104ed0:	50                   	push   %eax
80104ed1:	e8 7c 00 00 00       	call   80104f52 <acquire>
80104ed6:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	8b 00                	mov    (%eax),%eax
80104ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	83 c0 04             	add    $0x4,%eax
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	50                   	push   %eax
80104eeb:	e8 d0 00 00 00       	call   80104fc0 <release>
80104ef0:	83 c4 10             	add    $0x10,%esp
  return r;
80104ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ef6:	c9                   	leave  
80104ef7:	c3                   	ret    

80104ef8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ef8:	55                   	push   %ebp
80104ef9:	89 e5                	mov    %esp,%ebp
80104efb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104efe:	9c                   	pushf  
80104eff:	58                   	pop    %eax
80104f00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f06:	c9                   	leave  
80104f07:	c3                   	ret    

80104f08 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104f08:	55                   	push   %ebp
80104f09:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f0b:	fa                   	cli    
}
80104f0c:	90                   	nop
80104f0d:	5d                   	pop    %ebp
80104f0e:	c3                   	ret    

80104f0f <sti>:

static inline void
sti(void)
{
80104f0f:	55                   	push   %ebp
80104f10:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f12:	fb                   	sti    
}
80104f13:	90                   	nop
80104f14:	5d                   	pop    %ebp
80104f15:	c3                   	ret    

80104f16 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104f16:	55                   	push   %ebp
80104f17:	89 e5                	mov    %esp,%ebp
80104f19:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104f1c:	8b 55 08             	mov    0x8(%ebp),%edx
80104f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f25:	f0 87 02             	lock xchg %eax,(%edx)
80104f28:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104f2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f2e:	c9                   	leave  
80104f2f:	c3                   	ret    

80104f30 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f33:	8b 45 08             	mov    0x8(%ebp),%eax
80104f36:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f39:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104f45:	8b 45 08             	mov    0x8(%ebp),%eax
80104f48:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104f4f:	90                   	nop
80104f50:	5d                   	pop    %ebp
80104f51:	c3                   	ret    

80104f52 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104f52:	55                   	push   %ebp
80104f53:	89 e5                	mov    %esp,%ebp
80104f55:	53                   	push   %ebx
80104f56:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104f59:	e8 5f 01 00 00       	call   801050bd <pushcli>
  if(holding(lk))
80104f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	50                   	push   %eax
80104f65:	e8 22 01 00 00       	call   8010508c <holding>
80104f6a:	83 c4 10             	add    $0x10,%esp
80104f6d:	85 c0                	test   %eax,%eax
80104f6f:	74 0d                	je     80104f7e <acquire+0x2c>
    panic("acquire");
80104f71:	83 ec 0c             	sub    $0xc,%esp
80104f74:	68 de 89 10 80       	push   $0x801089de
80104f79:	e8 22 b6 ff ff       	call   801005a0 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104f7e:	90                   	nop
80104f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f82:	83 ec 08             	sub    $0x8,%esp
80104f85:	6a 01                	push   $0x1
80104f87:	50                   	push   %eax
80104f88:	e8 89 ff ff ff       	call   80104f16 <xchg>
80104f8d:	83 c4 10             	add    $0x10,%esp
80104f90:	85 c0                	test   %eax,%eax
80104f92:	75 eb                	jne    80104f7f <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104f94:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104f9c:	e8 61 f2 ff ff       	call   80104202 <mycpu>
80104fa1:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	83 c0 0c             	add    $0xc,%eax
80104faa:	83 ec 08             	sub    $0x8,%esp
80104fad:	50                   	push   %eax
80104fae:	8d 45 08             	lea    0x8(%ebp),%eax
80104fb1:	50                   	push   %eax
80104fb2:	e8 5b 00 00 00       	call   80105012 <getcallerpcs>
80104fb7:	83 c4 10             	add    $0x10,%esp
}
80104fba:	90                   	nop
80104fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fbe:	c9                   	leave  
80104fbf:	c3                   	ret    

80104fc0 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
80104fc3:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104fc6:	83 ec 0c             	sub    $0xc,%esp
80104fc9:	ff 75 08             	pushl  0x8(%ebp)
80104fcc:	e8 bb 00 00 00       	call   8010508c <holding>
80104fd1:	83 c4 10             	add    $0x10,%esp
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	75 0d                	jne    80104fe5 <release+0x25>
    panic("release");
80104fd8:	83 ec 0c             	sub    $0xc,%esp
80104fdb:	68 e6 89 10 80       	push   $0x801089e6
80104fe0:	e8 bb b5 ff ff       	call   801005a0 <panic>

  lk->pcs[0] = 0;
80104fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104fef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104ff9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80105001:	8b 55 08             	mov    0x8(%ebp),%edx
80105004:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010500a:	e8 fc 00 00 00       	call   8010510b <popcli>
}
8010500f:	90                   	nop
80105010:	c9                   	leave  
80105011:	c3                   	ret    

80105012 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105012:	55                   	push   %ebp
80105013:	89 e5                	mov    %esp,%ebp
80105015:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105018:	8b 45 08             	mov    0x8(%ebp),%eax
8010501b:	83 e8 08             	sub    $0x8,%eax
8010501e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105021:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105028:	eb 38                	jmp    80105062 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010502a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010502e:	74 53                	je     80105083 <getcallerpcs+0x71>
80105030:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105037:	76 4a                	jbe    80105083 <getcallerpcs+0x71>
80105039:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010503d:	74 44                	je     80105083 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010503f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105042:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105049:	8b 45 0c             	mov    0xc(%ebp),%eax
8010504c:	01 c2                	add    %eax,%edx
8010504e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105051:	8b 40 04             	mov    0x4(%eax),%eax
80105054:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105056:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105059:	8b 00                	mov    (%eax),%eax
8010505b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010505e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105062:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105066:	7e c2                	jle    8010502a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105068:	eb 19                	jmp    80105083 <getcallerpcs+0x71>
    pcs[i] = 0;
8010506a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010506d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105074:	8b 45 0c             	mov    0xc(%ebp),%eax
80105077:	01 d0                	add    %edx,%eax
80105079:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010507f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105083:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105087:	7e e1                	jle    8010506a <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105089:	90                   	nop
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	53                   	push   %ebx
80105090:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	8b 00                	mov    (%eax),%eax
80105098:	85 c0                	test   %eax,%eax
8010509a:	74 16                	je     801050b2 <holding+0x26>
8010509c:	8b 45 08             	mov    0x8(%ebp),%eax
8010509f:	8b 58 08             	mov    0x8(%eax),%ebx
801050a2:	e8 5b f1 ff ff       	call   80104202 <mycpu>
801050a7:	39 c3                	cmp    %eax,%ebx
801050a9:	75 07                	jne    801050b2 <holding+0x26>
801050ab:	b8 01 00 00 00       	mov    $0x1,%eax
801050b0:	eb 05                	jmp    801050b7 <holding+0x2b>
801050b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050b7:	83 c4 04             	add    $0x4,%esp
801050ba:	5b                   	pop    %ebx
801050bb:	5d                   	pop    %ebp
801050bc:	c3                   	ret    

801050bd <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801050bd:	55                   	push   %ebp
801050be:	89 e5                	mov    %esp,%ebp
801050c0:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801050c3:	e8 30 fe ff ff       	call   80104ef8 <readeflags>
801050c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801050cb:	e8 38 fe ff ff       	call   80104f08 <cli>
  if(mycpu()->ncli == 0)
801050d0:	e8 2d f1 ff ff       	call   80104202 <mycpu>
801050d5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801050db:	85 c0                	test   %eax,%eax
801050dd:	75 15                	jne    801050f4 <pushcli+0x37>
    mycpu()->intena = eflags & FL_IF;
801050df:	e8 1e f1 ff ff       	call   80104202 <mycpu>
801050e4:	89 c2                	mov    %eax,%edx
801050e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e9:	25 00 02 00 00       	and    $0x200,%eax
801050ee:	89 82 a8 00 00 00    	mov    %eax,0xa8(%edx)
  mycpu()->ncli += 1;
801050f4:	e8 09 f1 ff ff       	call   80104202 <mycpu>
801050f9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801050ff:	83 c2 01             	add    $0x1,%edx
80105102:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105108:	90                   	nop
80105109:	c9                   	leave  
8010510a:	c3                   	ret    

8010510b <popcli>:

void
popcli(void)
{
8010510b:	55                   	push   %ebp
8010510c:	89 e5                	mov    %esp,%ebp
8010510e:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105111:	e8 e2 fd ff ff       	call   80104ef8 <readeflags>
80105116:	25 00 02 00 00       	and    $0x200,%eax
8010511b:	85 c0                	test   %eax,%eax
8010511d:	74 0d                	je     8010512c <popcli+0x21>
    panic("popcli - interruptible");
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	68 ee 89 10 80       	push   $0x801089ee
80105127:	e8 74 b4 ff ff       	call   801005a0 <panic>
  if(--mycpu()->ncli < 0)
8010512c:	e8 d1 f0 ff ff       	call   80104202 <mycpu>
80105131:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105137:	83 ea 01             	sub    $0x1,%edx
8010513a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105140:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105146:	85 c0                	test   %eax,%eax
80105148:	79 0d                	jns    80105157 <popcli+0x4c>
    panic("popcli");
8010514a:	83 ec 0c             	sub    $0xc,%esp
8010514d:	68 05 8a 10 80       	push   $0x80108a05
80105152:	e8 49 b4 ff ff       	call   801005a0 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105157:	e8 a6 f0 ff ff       	call   80104202 <mycpu>
8010515c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105162:	85 c0                	test   %eax,%eax
80105164:	75 14                	jne    8010517a <popcli+0x6f>
80105166:	e8 97 f0 ff ff       	call   80104202 <mycpu>
8010516b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105171:	85 c0                	test   %eax,%eax
80105173:	74 05                	je     8010517a <popcli+0x6f>
    sti();
80105175:	e8 95 fd ff ff       	call   80104f0f <sti>
}
8010517a:	90                   	nop
8010517b:	c9                   	leave  
8010517c:	c3                   	ret    

8010517d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010517d:	55                   	push   %ebp
8010517e:	89 e5                	mov    %esp,%ebp
80105180:	57                   	push   %edi
80105181:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105182:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105185:	8b 55 10             	mov    0x10(%ebp),%edx
80105188:	8b 45 0c             	mov    0xc(%ebp),%eax
8010518b:	89 cb                	mov    %ecx,%ebx
8010518d:	89 df                	mov    %ebx,%edi
8010518f:	89 d1                	mov    %edx,%ecx
80105191:	fc                   	cld    
80105192:	f3 aa                	rep stos %al,%es:(%edi)
80105194:	89 ca                	mov    %ecx,%edx
80105196:	89 fb                	mov    %edi,%ebx
80105198:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010519b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010519e:	90                   	nop
8010519f:	5b                   	pop    %ebx
801051a0:	5f                   	pop    %edi
801051a1:	5d                   	pop    %ebp
801051a2:	c3                   	ret    

801051a3 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801051a3:	55                   	push   %ebp
801051a4:	89 e5                	mov    %esp,%ebp
801051a6:	57                   	push   %edi
801051a7:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801051a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051ab:	8b 55 10             	mov    0x10(%ebp),%edx
801051ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b1:	89 cb                	mov    %ecx,%ebx
801051b3:	89 df                	mov    %ebx,%edi
801051b5:	89 d1                	mov    %edx,%ecx
801051b7:	fc                   	cld    
801051b8:	f3 ab                	rep stos %eax,%es:(%edi)
801051ba:	89 ca                	mov    %ecx,%edx
801051bc:	89 fb                	mov    %edi,%ebx
801051be:	89 5d 08             	mov    %ebx,0x8(%ebp)
801051c1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801051c4:	90                   	nop
801051c5:	5b                   	pop    %ebx
801051c6:	5f                   	pop    %edi
801051c7:	5d                   	pop    %ebp
801051c8:	c3                   	ret    

801051c9 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801051c9:	55                   	push   %ebp
801051ca:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	83 e0 03             	and    $0x3,%eax
801051d2:	85 c0                	test   %eax,%eax
801051d4:	75 43                	jne    80105219 <memset+0x50>
801051d6:	8b 45 10             	mov    0x10(%ebp),%eax
801051d9:	83 e0 03             	and    $0x3,%eax
801051dc:	85 c0                	test   %eax,%eax
801051de:	75 39                	jne    80105219 <memset+0x50>
    c &= 0xFF;
801051e0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801051e7:	8b 45 10             	mov    0x10(%ebp),%eax
801051ea:	c1 e8 02             	shr    $0x2,%eax
801051ed:	89 c1                	mov    %eax,%ecx
801051ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801051f2:	c1 e0 18             	shl    $0x18,%eax
801051f5:	89 c2                	mov    %eax,%edx
801051f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051fa:	c1 e0 10             	shl    $0x10,%eax
801051fd:	09 c2                	or     %eax,%edx
801051ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105202:	c1 e0 08             	shl    $0x8,%eax
80105205:	09 d0                	or     %edx,%eax
80105207:	0b 45 0c             	or     0xc(%ebp),%eax
8010520a:	51                   	push   %ecx
8010520b:	50                   	push   %eax
8010520c:	ff 75 08             	pushl  0x8(%ebp)
8010520f:	e8 8f ff ff ff       	call   801051a3 <stosl>
80105214:	83 c4 0c             	add    $0xc,%esp
80105217:	eb 12                	jmp    8010522b <memset+0x62>
  } else
    stosb(dst, c, n);
80105219:	8b 45 10             	mov    0x10(%ebp),%eax
8010521c:	50                   	push   %eax
8010521d:	ff 75 0c             	pushl  0xc(%ebp)
80105220:	ff 75 08             	pushl  0x8(%ebp)
80105223:	e8 55 ff ff ff       	call   8010517d <stosb>
80105228:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010522b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010522e:	c9                   	leave  
8010522f:	c3                   	ret    

80105230 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
80105233:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105236:	8b 45 08             	mov    0x8(%ebp),%eax
80105239:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010523c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010523f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105242:	eb 30                	jmp    80105274 <memcmp+0x44>
    if(*s1 != *s2)
80105244:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105247:	0f b6 10             	movzbl (%eax),%edx
8010524a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010524d:	0f b6 00             	movzbl (%eax),%eax
80105250:	38 c2                	cmp    %al,%dl
80105252:	74 18                	je     8010526c <memcmp+0x3c>
      return *s1 - *s2;
80105254:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105257:	0f b6 00             	movzbl (%eax),%eax
8010525a:	0f b6 d0             	movzbl %al,%edx
8010525d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105260:	0f b6 00             	movzbl (%eax),%eax
80105263:	0f b6 c0             	movzbl %al,%eax
80105266:	29 c2                	sub    %eax,%edx
80105268:	89 d0                	mov    %edx,%eax
8010526a:	eb 1a                	jmp    80105286 <memcmp+0x56>
    s1++, s2++;
8010526c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105270:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105274:	8b 45 10             	mov    0x10(%ebp),%eax
80105277:	8d 50 ff             	lea    -0x1(%eax),%edx
8010527a:	89 55 10             	mov    %edx,0x10(%ebp)
8010527d:	85 c0                	test   %eax,%eax
8010527f:	75 c3                	jne    80105244 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105281:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105286:	c9                   	leave  
80105287:	c3                   	ret    

80105288 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105288:	55                   	push   %ebp
80105289:	89 e5                	mov    %esp,%ebp
8010528b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010528e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105291:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105294:	8b 45 08             	mov    0x8(%ebp),%eax
80105297:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010529a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052a0:	73 54                	jae    801052f6 <memmove+0x6e>
801052a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052a5:	8b 45 10             	mov    0x10(%ebp),%eax
801052a8:	01 d0                	add    %edx,%eax
801052aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052ad:	76 47                	jbe    801052f6 <memmove+0x6e>
    s += n;
801052af:	8b 45 10             	mov    0x10(%ebp),%eax
801052b2:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801052b5:	8b 45 10             	mov    0x10(%ebp),%eax
801052b8:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801052bb:	eb 13                	jmp    801052d0 <memmove+0x48>
      *--d = *--s;
801052bd:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801052c1:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801052c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052c8:	0f b6 10             	movzbl (%eax),%edx
801052cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ce:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801052d0:	8b 45 10             	mov    0x10(%ebp),%eax
801052d3:	8d 50 ff             	lea    -0x1(%eax),%edx
801052d6:	89 55 10             	mov    %edx,0x10(%ebp)
801052d9:	85 c0                	test   %eax,%eax
801052db:	75 e0                	jne    801052bd <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801052dd:	eb 24                	jmp    80105303 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801052df:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052e2:	8d 50 01             	lea    0x1(%eax),%edx
801052e5:	89 55 f8             	mov    %edx,-0x8(%ebp)
801052e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052eb:	8d 4a 01             	lea    0x1(%edx),%ecx
801052ee:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801052f1:	0f b6 12             	movzbl (%edx),%edx
801052f4:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052f6:	8b 45 10             	mov    0x10(%ebp),%eax
801052f9:	8d 50 ff             	lea    -0x1(%eax),%edx
801052fc:	89 55 10             	mov    %edx,0x10(%ebp)
801052ff:	85 c0                	test   %eax,%eax
80105301:	75 dc                	jne    801052df <memmove+0x57>
      *d++ = *s++;

  return dst;
80105303:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105306:	c9                   	leave  
80105307:	c3                   	ret    

80105308 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105308:	55                   	push   %ebp
80105309:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010530b:	ff 75 10             	pushl  0x10(%ebp)
8010530e:	ff 75 0c             	pushl  0xc(%ebp)
80105311:	ff 75 08             	pushl  0x8(%ebp)
80105314:	e8 6f ff ff ff       	call   80105288 <memmove>
80105319:	83 c4 0c             	add    $0xc,%esp
}
8010531c:	c9                   	leave  
8010531d:	c3                   	ret    

8010531e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010531e:	55                   	push   %ebp
8010531f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105321:	eb 0c                	jmp    8010532f <strncmp+0x11>
    n--, p++, q++;
80105323:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105327:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010532b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010532f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105333:	74 1a                	je     8010534f <strncmp+0x31>
80105335:	8b 45 08             	mov    0x8(%ebp),%eax
80105338:	0f b6 00             	movzbl (%eax),%eax
8010533b:	84 c0                	test   %al,%al
8010533d:	74 10                	je     8010534f <strncmp+0x31>
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	0f b6 10             	movzbl (%eax),%edx
80105345:	8b 45 0c             	mov    0xc(%ebp),%eax
80105348:	0f b6 00             	movzbl (%eax),%eax
8010534b:	38 c2                	cmp    %al,%dl
8010534d:	74 d4                	je     80105323 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010534f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105353:	75 07                	jne    8010535c <strncmp+0x3e>
    return 0;
80105355:	b8 00 00 00 00       	mov    $0x0,%eax
8010535a:	eb 16                	jmp    80105372 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010535c:	8b 45 08             	mov    0x8(%ebp),%eax
8010535f:	0f b6 00             	movzbl (%eax),%eax
80105362:	0f b6 d0             	movzbl %al,%edx
80105365:	8b 45 0c             	mov    0xc(%ebp),%eax
80105368:	0f b6 00             	movzbl (%eax),%eax
8010536b:	0f b6 c0             	movzbl %al,%eax
8010536e:	29 c2                	sub    %eax,%edx
80105370:	89 d0                	mov    %edx,%eax
}
80105372:	5d                   	pop    %ebp
80105373:	c3                   	ret    

80105374 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105374:	55                   	push   %ebp
80105375:	89 e5                	mov    %esp,%ebp
80105377:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010537a:	8b 45 08             	mov    0x8(%ebp),%eax
8010537d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105380:	90                   	nop
80105381:	8b 45 10             	mov    0x10(%ebp),%eax
80105384:	8d 50 ff             	lea    -0x1(%eax),%edx
80105387:	89 55 10             	mov    %edx,0x10(%ebp)
8010538a:	85 c0                	test   %eax,%eax
8010538c:	7e 2c                	jle    801053ba <strncpy+0x46>
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	8d 50 01             	lea    0x1(%eax),%edx
80105394:	89 55 08             	mov    %edx,0x8(%ebp)
80105397:	8b 55 0c             	mov    0xc(%ebp),%edx
8010539a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010539d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053a0:	0f b6 12             	movzbl (%edx),%edx
801053a3:	88 10                	mov    %dl,(%eax)
801053a5:	0f b6 00             	movzbl (%eax),%eax
801053a8:	84 c0                	test   %al,%al
801053aa:	75 d5                	jne    80105381 <strncpy+0xd>
    ;
  while(n-- > 0)
801053ac:	eb 0c                	jmp    801053ba <strncpy+0x46>
    *s++ = 0;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	8d 50 01             	lea    0x1(%eax),%edx
801053b4:	89 55 08             	mov    %edx,0x8(%ebp)
801053b7:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801053ba:	8b 45 10             	mov    0x10(%ebp),%eax
801053bd:	8d 50 ff             	lea    -0x1(%eax),%edx
801053c0:	89 55 10             	mov    %edx,0x10(%ebp)
801053c3:	85 c0                	test   %eax,%eax
801053c5:	7f e7                	jg     801053ae <strncpy+0x3a>
    *s++ = 0;
  return os;
801053c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053ca:	c9                   	leave  
801053cb:	c3                   	ret    

801053cc <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801053cc:	55                   	push   %ebp
801053cd:	89 e5                	mov    %esp,%ebp
801053cf:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801053d2:	8b 45 08             	mov    0x8(%ebp),%eax
801053d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801053d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053dc:	7f 05                	jg     801053e3 <safestrcpy+0x17>
    return os;
801053de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e1:	eb 31                	jmp    80105414 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801053e3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053eb:	7e 1e                	jle    8010540b <safestrcpy+0x3f>
801053ed:	8b 45 08             	mov    0x8(%ebp),%eax
801053f0:	8d 50 01             	lea    0x1(%eax),%edx
801053f3:	89 55 08             	mov    %edx,0x8(%ebp)
801053f6:	8b 55 0c             	mov    0xc(%ebp),%edx
801053f9:	8d 4a 01             	lea    0x1(%edx),%ecx
801053fc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053ff:	0f b6 12             	movzbl (%edx),%edx
80105402:	88 10                	mov    %dl,(%eax)
80105404:	0f b6 00             	movzbl (%eax),%eax
80105407:	84 c0                	test   %al,%al
80105409:	75 d8                	jne    801053e3 <safestrcpy+0x17>
    ;
  *s = 0;
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105414:	c9                   	leave  
80105415:	c3                   	ret    

80105416 <strlen>:

int
strlen(const char *s)
{
80105416:	55                   	push   %ebp
80105417:	89 e5                	mov    %esp,%ebp
80105419:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010541c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105423:	eb 04                	jmp    80105429 <strlen+0x13>
80105425:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105429:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010542c:	8b 45 08             	mov    0x8(%ebp),%eax
8010542f:	01 d0                	add    %edx,%eax
80105431:	0f b6 00             	movzbl (%eax),%eax
80105434:	84 c0                	test   %al,%al
80105436:	75 ed                	jne    80105425 <strlen+0xf>
    ;
  return n;
80105438:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010543b:	c9                   	leave  
8010543c:	c3                   	ret    

8010543d <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010543d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105441:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105445:	55                   	push   %ebp
  pushl %ebx
80105446:	53                   	push   %ebx
  pushl %esi
80105447:	56                   	push   %esi
  pushl %edi
80105448:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105449:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010544b:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010544d:	5f                   	pop    %edi
  popl %esi
8010544e:	5e                   	pop    %esi
  popl %ebx
8010544f:	5b                   	pop    %ebx
  popl %ebp
80105450:	5d                   	pop    %ebp
  ret
80105451:	c3                   	ret    

80105452 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{ 
80105452:	55                   	push   %ebp
80105453:	89 e5                	mov    %esp,%ebp
//  struct proc *curproc = myproc();
  if(addr > STACKTOP || addr+4 > STACKTOP)
80105455:	8b 45 08             	mov    0x8(%ebp),%eax
80105458:	85 c0                	test   %eax,%eax
8010545a:	78 0a                	js     80105466 <fetchint+0x14>
8010545c:	8b 45 08             	mov    0x8(%ebp),%eax
8010545f:	83 c0 04             	add    $0x4,%eax
80105462:	85 c0                	test   %eax,%eax
80105464:	79 07                	jns    8010546d <fetchint+0x1b>
    return -1;
80105466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546b:	eb 0f                	jmp    8010547c <fetchint+0x2a>
  *ip = *(int*)(addr);
8010546d:	8b 45 08             	mov    0x8(%ebp),%eax
80105470:	8b 10                	mov    (%eax),%edx
80105472:	8b 45 0c             	mov    0xc(%ebp),%eax
80105475:	89 10                	mov    %edx,(%eax)
  return 0;
80105477:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010547c:	5d                   	pop    %ebp
8010547d:	c3                   	ret    

8010547e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010547e:	55                   	push   %ebp
8010547f:	89 e5                	mov    %esp,%ebp
80105481:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105484:	e8 f1 ed ff ff       	call   8010427a <myproc>
80105489:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr > STACKTOP)
8010548c:	8b 45 08             	mov    0x8(%ebp),%eax
8010548f:	85 c0                	test   %eax,%eax
80105491:	79 07                	jns    8010549a <fetchstr+0x1c>
    return -1;
80105493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105498:	eb 43                	jmp    801054dd <fetchstr+0x5f>
  *pp = (char*)addr;
8010549a:	8b 55 08             	mov    0x8(%ebp),%edx
8010549d:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a0:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801054a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a5:	8b 00                	mov    (%eax),%eax
801054a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801054aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ad:	8b 00                	mov    (%eax),%eax
801054af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054b2:	eb 1c                	jmp    801054d0 <fetchstr+0x52>
    if(*s == 0)
801054b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b7:	0f b6 00             	movzbl (%eax),%eax
801054ba:	84 c0                	test   %al,%al
801054bc:	75 0e                	jne    801054cc <fetchstr+0x4e>
      return s - *pp;
801054be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c4:	8b 00                	mov    (%eax),%eax
801054c6:	29 c2                	sub    %eax,%edx
801054c8:	89 d0                	mov    %edx,%eax
801054ca:	eb 11                	jmp    801054dd <fetchstr+0x5f>

  if(addr > STACKTOP)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801054cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801054d6:	72 dc                	jb     801054b4 <fetchstr+0x36>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801054d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054dd:	c9                   	leave  
801054de:	c3                   	ret    

801054df <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801054df:	55                   	push   %ebp
801054e0:	89 e5                	mov    %esp,%ebp
801054e2:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801054e5:	e8 90 ed ff ff       	call   8010427a <myproc>
801054ea:	8b 40 18             	mov    0x18(%eax),%eax
801054ed:	8b 40 44             	mov    0x44(%eax),%eax
801054f0:	8b 55 08             	mov    0x8(%ebp),%edx
801054f3:	c1 e2 02             	shl    $0x2,%edx
801054f6:	01 d0                	add    %edx,%eax
801054f8:	83 c0 04             	add    $0x4,%eax
801054fb:	83 ec 08             	sub    $0x8,%esp
801054fe:	ff 75 0c             	pushl  0xc(%ebp)
80105501:	50                   	push   %eax
80105502:	e8 4b ff ff ff       	call   80105452 <fetchint>
80105507:	83 c4 10             	add    $0x10,%esp
}
8010550a:	c9                   	leave  
8010550b:	c3                   	ret    

8010550c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010550c:	55                   	push   %ebp
8010550d:	89 e5                	mov    %esp,%ebp
8010550f:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80105512:	83 ec 08             	sub    $0x8,%esp
80105515:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105518:	50                   	push   %eax
80105519:	ff 75 08             	pushl  0x8(%ebp)
8010551c:	e8 be ff ff ff       	call   801054df <argint>
80105521:	83 c4 10             	add    $0x10,%esp
80105524:	85 c0                	test   %eax,%eax
80105526:	79 07                	jns    8010552f <argptr+0x23>
    return -1;
80105528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010552d:	eb 31                	jmp    80105560 <argptr+0x54>
  if(size < 0 || (uint)i > STACKTOP || (uint)i+size > STACKTOP)
8010552f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105533:	78 15                	js     8010554a <argptr+0x3e>
80105535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105538:	85 c0                	test   %eax,%eax
8010553a:	78 0e                	js     8010554a <argptr+0x3e>
8010553c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553f:	89 c2                	mov    %eax,%edx
80105541:	8b 45 10             	mov    0x10(%ebp),%eax
80105544:	01 d0                	add    %edx,%eax
80105546:	85 c0                	test   %eax,%eax
80105548:	79 07                	jns    80105551 <argptr+0x45>
    return -1;
8010554a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554f:	eb 0f                	jmp    80105560 <argptr+0x54>
  *pp = (char*)i;
80105551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105554:	89 c2                	mov    %eax,%edx
80105556:	8b 45 0c             	mov    0xc(%ebp),%eax
80105559:	89 10                	mov    %edx,(%eax)
  return 0;
8010555b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105560:	c9                   	leave  
80105561:	c3                   	ret    

80105562 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105562:	55                   	push   %ebp
80105563:	89 e5                	mov    %esp,%ebp
80105565:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105568:	83 ec 08             	sub    $0x8,%esp
8010556b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010556e:	50                   	push   %eax
8010556f:	ff 75 08             	pushl  0x8(%ebp)
80105572:	e8 68 ff ff ff       	call   801054df <argint>
80105577:	83 c4 10             	add    $0x10,%esp
8010557a:	85 c0                	test   %eax,%eax
8010557c:	79 07                	jns    80105585 <argstr+0x23>
    return -1;
8010557e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105583:	eb 12                	jmp    80105597 <argstr+0x35>
  return fetchstr(addr, pp);
80105585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105588:	83 ec 08             	sub    $0x8,%esp
8010558b:	ff 75 0c             	pushl  0xc(%ebp)
8010558e:	50                   	push   %eax
8010558f:	e8 ea fe ff ff       	call   8010547e <fetchstr>
80105594:	83 c4 10             	add    $0x10,%esp
}
80105597:	c9                   	leave  
80105598:	c3                   	ret    

80105599 <syscall>:
[SYS_shm_close] sys_shm_close
};

void
syscall(void)
{
80105599:	55                   	push   %ebp
8010559a:	89 e5                	mov    %esp,%ebp
8010559c:	53                   	push   %ebx
8010559d:	83 ec 14             	sub    $0x14,%esp
  int num;
  struct proc *curproc = myproc();
801055a0:	e8 d5 ec ff ff       	call   8010427a <myproc>
801055a5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801055a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ab:	8b 40 18             	mov    0x18(%eax),%eax
801055ae:	8b 40 1c             	mov    0x1c(%eax),%eax
801055b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801055b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055b8:	7e 2d                	jle    801055e7 <syscall+0x4e>
801055ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055bd:	83 f8 17             	cmp    $0x17,%eax
801055c0:	77 25                	ja     801055e7 <syscall+0x4e>
801055c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c5:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801055cc:	85 c0                	test   %eax,%eax
801055ce:	74 17                	je     801055e7 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801055d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d3:	8b 58 18             	mov    0x18(%eax),%ebx
801055d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d9:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
801055e0:	ff d0                	call   *%eax
801055e2:	89 43 1c             	mov    %eax,0x1c(%ebx)
801055e5:	eb 2b                	jmp    80105612 <syscall+0x79>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801055e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ea:	8d 50 6c             	lea    0x6c(%eax),%edx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801055ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f0:	8b 40 10             	mov    0x10(%eax),%eax
801055f3:	ff 75 f0             	pushl  -0x10(%ebp)
801055f6:	52                   	push   %edx
801055f7:	50                   	push   %eax
801055f8:	68 0c 8a 10 80       	push   $0x80108a0c
801055fd:	e8 fe ad ff ff       	call   80100400 <cprintf>
80105602:	83 c4 10             	add    $0x10,%esp
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105608:	8b 40 18             	mov    0x18(%eax),%eax
8010560b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105612:	90                   	nop
80105613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105616:	c9                   	leave  
80105617:	c3                   	ret    

80105618 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105618:	55                   	push   %ebp
80105619:	89 e5                	mov    %esp,%ebp
8010561b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010561e:	83 ec 08             	sub    $0x8,%esp
80105621:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105624:	50                   	push   %eax
80105625:	ff 75 08             	pushl  0x8(%ebp)
80105628:	e8 b2 fe ff ff       	call   801054df <argint>
8010562d:	83 c4 10             	add    $0x10,%esp
80105630:	85 c0                	test   %eax,%eax
80105632:	79 07                	jns    8010563b <argfd+0x23>
    return -1;
80105634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105639:	eb 51                	jmp    8010568c <argfd+0x74>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010563b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563e:	85 c0                	test   %eax,%eax
80105640:	78 22                	js     80105664 <argfd+0x4c>
80105642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105645:	83 f8 0f             	cmp    $0xf,%eax
80105648:	7f 1a                	jg     80105664 <argfd+0x4c>
8010564a:	e8 2b ec ff ff       	call   8010427a <myproc>
8010564f:	89 c2                	mov    %eax,%edx
80105651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105654:	83 c0 08             	add    $0x8,%eax
80105657:	8b 44 82 08          	mov    0x8(%edx,%eax,4),%eax
8010565b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010565e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105662:	75 07                	jne    8010566b <argfd+0x53>
    return -1;
80105664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105669:	eb 21                	jmp    8010568c <argfd+0x74>
  if(pfd)
8010566b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010566f:	74 08                	je     80105679 <argfd+0x61>
    *pfd = fd;
80105671:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105674:	8b 45 0c             	mov    0xc(%ebp),%eax
80105677:	89 10                	mov    %edx,(%eax)
  if(pf)
80105679:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010567d:	74 08                	je     80105687 <argfd+0x6f>
    *pf = f;
8010567f:	8b 45 10             	mov    0x10(%ebp),%eax
80105682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105685:	89 10                	mov    %edx,(%eax)
  return 0;
80105687:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010568c:	c9                   	leave  
8010568d:	c3                   	ret    

8010568e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010568e:	55                   	push   %ebp
8010568f:	89 e5                	mov    %esp,%ebp
80105691:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105694:	e8 e1 eb ff ff       	call   8010427a <myproc>
80105699:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010569c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801056a3:	eb 2a                	jmp    801056cf <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801056a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056ab:	83 c2 08             	add    $0x8,%edx
801056ae:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056b2:	85 c0                	test   %eax,%eax
801056b4:	75 15                	jne    801056cb <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801056b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056bc:	8d 4a 08             	lea    0x8(%edx),%ecx
801056bf:	8b 55 08             	mov    0x8(%ebp),%edx
801056c2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	eb 0f                	jmp    801056da <fdalloc+0x4c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801056cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801056cf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801056d3:	7e d0                	jle    801056a5 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801056d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056da:	c9                   	leave  
801056db:	c3                   	ret    

801056dc <sys_dup>:

int
sys_dup(void)
{
801056dc:	55                   	push   %ebp
801056dd:	89 e5                	mov    %esp,%ebp
801056df:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801056e2:	83 ec 04             	sub    $0x4,%esp
801056e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056e8:	50                   	push   %eax
801056e9:	6a 00                	push   $0x0
801056eb:	6a 00                	push   $0x0
801056ed:	e8 26 ff ff ff       	call   80105618 <argfd>
801056f2:	83 c4 10             	add    $0x10,%esp
801056f5:	85 c0                	test   %eax,%eax
801056f7:	79 07                	jns    80105700 <sys_dup+0x24>
    return -1;
801056f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fe:	eb 31                	jmp    80105731 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105703:	83 ec 0c             	sub    $0xc,%esp
80105706:	50                   	push   %eax
80105707:	e8 82 ff ff ff       	call   8010568e <fdalloc>
8010570c:	83 c4 10             	add    $0x10,%esp
8010570f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105712:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105716:	79 07                	jns    8010571f <sys_dup+0x43>
    return -1;
80105718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571d:	eb 12                	jmp    80105731 <sys_dup+0x55>
  filedup(f);
8010571f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105722:	83 ec 0c             	sub    $0xc,%esp
80105725:	50                   	push   %eax
80105726:	e8 22 b9 ff ff       	call   8010104d <filedup>
8010572b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010572e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105731:	c9                   	leave  
80105732:	c3                   	ret    

80105733 <sys_read>:

int
sys_read(void)
{
80105733:	55                   	push   %ebp
80105734:	89 e5                	mov    %esp,%ebp
80105736:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105739:	83 ec 04             	sub    $0x4,%esp
8010573c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010573f:	50                   	push   %eax
80105740:	6a 00                	push   $0x0
80105742:	6a 00                	push   $0x0
80105744:	e8 cf fe ff ff       	call   80105618 <argfd>
80105749:	83 c4 10             	add    $0x10,%esp
8010574c:	85 c0                	test   %eax,%eax
8010574e:	78 2e                	js     8010577e <sys_read+0x4b>
80105750:	83 ec 08             	sub    $0x8,%esp
80105753:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105756:	50                   	push   %eax
80105757:	6a 02                	push   $0x2
80105759:	e8 81 fd ff ff       	call   801054df <argint>
8010575e:	83 c4 10             	add    $0x10,%esp
80105761:	85 c0                	test   %eax,%eax
80105763:	78 19                	js     8010577e <sys_read+0x4b>
80105765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105768:	83 ec 04             	sub    $0x4,%esp
8010576b:	50                   	push   %eax
8010576c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010576f:	50                   	push   %eax
80105770:	6a 01                	push   $0x1
80105772:	e8 95 fd ff ff       	call   8010550c <argptr>
80105777:	83 c4 10             	add    $0x10,%esp
8010577a:	85 c0                	test   %eax,%eax
8010577c:	79 07                	jns    80105785 <sys_read+0x52>
    return -1;
8010577e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105783:	eb 17                	jmp    8010579c <sys_read+0x69>
  return fileread(f, p, n);
80105785:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105788:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010578b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578e:	83 ec 04             	sub    $0x4,%esp
80105791:	51                   	push   %ecx
80105792:	52                   	push   %edx
80105793:	50                   	push   %eax
80105794:	e8 44 ba ff ff       	call   801011dd <fileread>
80105799:	83 c4 10             	add    $0x10,%esp
}
8010579c:	c9                   	leave  
8010579d:	c3                   	ret    

8010579e <sys_write>:

int
sys_write(void)
{
8010579e:	55                   	push   %ebp
8010579f:	89 e5                	mov    %esp,%ebp
801057a1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057a4:	83 ec 04             	sub    $0x4,%esp
801057a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057aa:	50                   	push   %eax
801057ab:	6a 00                	push   $0x0
801057ad:	6a 00                	push   $0x0
801057af:	e8 64 fe ff ff       	call   80105618 <argfd>
801057b4:	83 c4 10             	add    $0x10,%esp
801057b7:	85 c0                	test   %eax,%eax
801057b9:	78 2e                	js     801057e9 <sys_write+0x4b>
801057bb:	83 ec 08             	sub    $0x8,%esp
801057be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057c1:	50                   	push   %eax
801057c2:	6a 02                	push   $0x2
801057c4:	e8 16 fd ff ff       	call   801054df <argint>
801057c9:	83 c4 10             	add    $0x10,%esp
801057cc:	85 c0                	test   %eax,%eax
801057ce:	78 19                	js     801057e9 <sys_write+0x4b>
801057d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d3:	83 ec 04             	sub    $0x4,%esp
801057d6:	50                   	push   %eax
801057d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057da:	50                   	push   %eax
801057db:	6a 01                	push   $0x1
801057dd:	e8 2a fd ff ff       	call   8010550c <argptr>
801057e2:	83 c4 10             	add    $0x10,%esp
801057e5:	85 c0                	test   %eax,%eax
801057e7:	79 07                	jns    801057f0 <sys_write+0x52>
    return -1;
801057e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ee:	eb 17                	jmp    80105807 <sys_write+0x69>
  return filewrite(f, p, n);
801057f0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f9:	83 ec 04             	sub    $0x4,%esp
801057fc:	51                   	push   %ecx
801057fd:	52                   	push   %edx
801057fe:	50                   	push   %eax
801057ff:	e8 91 ba ff ff       	call   80101295 <filewrite>
80105804:	83 c4 10             	add    $0x10,%esp
}
80105807:	c9                   	leave  
80105808:	c3                   	ret    

80105809 <sys_close>:

int
sys_close(void)
{
80105809:	55                   	push   %ebp
8010580a:	89 e5                	mov    %esp,%ebp
8010580c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010580f:	83 ec 04             	sub    $0x4,%esp
80105812:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105815:	50                   	push   %eax
80105816:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105819:	50                   	push   %eax
8010581a:	6a 00                	push   $0x0
8010581c:	e8 f7 fd ff ff       	call   80105618 <argfd>
80105821:	83 c4 10             	add    $0x10,%esp
80105824:	85 c0                	test   %eax,%eax
80105826:	79 07                	jns    8010582f <sys_close+0x26>
    return -1;
80105828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582d:	eb 29                	jmp    80105858 <sys_close+0x4f>
  myproc()->ofile[fd] = 0;
8010582f:	e8 46 ea ff ff       	call   8010427a <myproc>
80105834:	89 c2                	mov    %eax,%edx
80105836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105839:	83 c0 08             	add    $0x8,%eax
8010583c:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
80105843:	00 
  fileclose(f);
80105844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105847:	83 ec 0c             	sub    $0xc,%esp
8010584a:	50                   	push   %eax
8010584b:	e8 4e b8 ff ff       	call   8010109e <fileclose>
80105850:	83 c4 10             	add    $0x10,%esp
  return 0;
80105853:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105858:	c9                   	leave  
80105859:	c3                   	ret    

8010585a <sys_fstat>:

int
sys_fstat(void)
{
8010585a:	55                   	push   %ebp
8010585b:	89 e5                	mov    %esp,%ebp
8010585d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105860:	83 ec 04             	sub    $0x4,%esp
80105863:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105866:	50                   	push   %eax
80105867:	6a 00                	push   $0x0
80105869:	6a 00                	push   $0x0
8010586b:	e8 a8 fd ff ff       	call   80105618 <argfd>
80105870:	83 c4 10             	add    $0x10,%esp
80105873:	85 c0                	test   %eax,%eax
80105875:	78 17                	js     8010588e <sys_fstat+0x34>
80105877:	83 ec 04             	sub    $0x4,%esp
8010587a:	6a 14                	push   $0x14
8010587c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010587f:	50                   	push   %eax
80105880:	6a 01                	push   $0x1
80105882:	e8 85 fc ff ff       	call   8010550c <argptr>
80105887:	83 c4 10             	add    $0x10,%esp
8010588a:	85 c0                	test   %eax,%eax
8010588c:	79 07                	jns    80105895 <sys_fstat+0x3b>
    return -1;
8010588e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105893:	eb 13                	jmp    801058a8 <sys_fstat+0x4e>
  return filestat(f, st);
80105895:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589b:	83 ec 08             	sub    $0x8,%esp
8010589e:	52                   	push   %edx
8010589f:	50                   	push   %eax
801058a0:	e8 e1 b8 ff ff       	call   80101186 <filestat>
801058a5:	83 c4 10             	add    $0x10,%esp
}
801058a8:	c9                   	leave  
801058a9:	c3                   	ret    

801058aa <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801058aa:	55                   	push   %ebp
801058ab:	89 e5                	mov    %esp,%ebp
801058ad:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801058b0:	83 ec 08             	sub    $0x8,%esp
801058b3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801058b6:	50                   	push   %eax
801058b7:	6a 00                	push   $0x0
801058b9:	e8 a4 fc ff ff       	call   80105562 <argstr>
801058be:	83 c4 10             	add    $0x10,%esp
801058c1:	85 c0                	test   %eax,%eax
801058c3:	78 15                	js     801058da <sys_link+0x30>
801058c5:	83 ec 08             	sub    $0x8,%esp
801058c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058cb:	50                   	push   %eax
801058cc:	6a 01                	push   $0x1
801058ce:	e8 8f fc ff ff       	call   80105562 <argstr>
801058d3:	83 c4 10             	add    $0x10,%esp
801058d6:	85 c0                	test   %eax,%eax
801058d8:	79 0a                	jns    801058e4 <sys_link+0x3a>
    return -1;
801058da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058df:	e9 68 01 00 00       	jmp    80105a4c <sys_link+0x1a2>

  begin_op();
801058e4:	e8 39 dc ff ff       	call   80103522 <begin_op>
  if((ip = namei(old)) == 0){
801058e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058ec:	83 ec 0c             	sub    $0xc,%esp
801058ef:	50                   	push   %eax
801058f0:	e8 48 cc ff ff       	call   8010253d <namei>
801058f5:	83 c4 10             	add    $0x10,%esp
801058f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ff:	75 0f                	jne    80105910 <sys_link+0x66>
    end_op();
80105901:	e8 a8 dc ff ff       	call   801035ae <end_op>
    return -1;
80105906:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590b:	e9 3c 01 00 00       	jmp    80105a4c <sys_link+0x1a2>
  }

  ilock(ip);
80105910:	83 ec 0c             	sub    $0xc,%esp
80105913:	ff 75 f4             	pushl  -0xc(%ebp)
80105916:	e8 e2 c0 ff ff       	call   801019fd <ilock>
8010591b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010591e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105921:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105925:	66 83 f8 01          	cmp    $0x1,%ax
80105929:	75 1d                	jne    80105948 <sys_link+0x9e>
    iunlockput(ip);
8010592b:	83 ec 0c             	sub    $0xc,%esp
8010592e:	ff 75 f4             	pushl  -0xc(%ebp)
80105931:	e8 f8 c2 ff ff       	call   80101c2e <iunlockput>
80105936:	83 c4 10             	add    $0x10,%esp
    end_op();
80105939:	e8 70 dc ff ff       	call   801035ae <end_op>
    return -1;
8010593e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105943:	e9 04 01 00 00       	jmp    80105a4c <sys_link+0x1a2>
  }

  ip->nlink++;
80105948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010594f:	83 c0 01             	add    $0x1,%eax
80105952:	89 c2                	mov    %eax,%edx
80105954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105957:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010595b:	83 ec 0c             	sub    $0xc,%esp
8010595e:	ff 75 f4             	pushl  -0xc(%ebp)
80105961:	e8 ba be ff ff       	call   80101820 <iupdate>
80105966:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105969:	83 ec 0c             	sub    $0xc,%esp
8010596c:	ff 75 f4             	pushl  -0xc(%ebp)
8010596f:	e8 9c c1 ff ff       	call   80101b10 <iunlock>
80105974:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105977:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010597a:	83 ec 08             	sub    $0x8,%esp
8010597d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105980:	52                   	push   %edx
80105981:	50                   	push   %eax
80105982:	e8 d2 cb ff ff       	call   80102559 <nameiparent>
80105987:	83 c4 10             	add    $0x10,%esp
8010598a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010598d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105991:	74 71                	je     80105a04 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	ff 75 f0             	pushl  -0x10(%ebp)
80105999:	e8 5f c0 ff ff       	call   801019fd <ilock>
8010599e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	8b 10                	mov    (%eax),%edx
801059a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a9:	8b 00                	mov    (%eax),%eax
801059ab:	39 c2                	cmp    %eax,%edx
801059ad:	75 1d                	jne    801059cc <sys_link+0x122>
801059af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b2:	8b 40 04             	mov    0x4(%eax),%eax
801059b5:	83 ec 04             	sub    $0x4,%esp
801059b8:	50                   	push   %eax
801059b9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801059bc:	50                   	push   %eax
801059bd:	ff 75 f0             	pushl  -0x10(%ebp)
801059c0:	e8 dd c8 ff ff       	call   801022a2 <dirlink>
801059c5:	83 c4 10             	add    $0x10,%esp
801059c8:	85 c0                	test   %eax,%eax
801059ca:	79 10                	jns    801059dc <sys_link+0x132>
    iunlockput(dp);
801059cc:	83 ec 0c             	sub    $0xc,%esp
801059cf:	ff 75 f0             	pushl  -0x10(%ebp)
801059d2:	e8 57 c2 ff ff       	call   80101c2e <iunlockput>
801059d7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801059da:	eb 29                	jmp    80105a05 <sys_link+0x15b>
  }
  iunlockput(dp);
801059dc:	83 ec 0c             	sub    $0xc,%esp
801059df:	ff 75 f0             	pushl  -0x10(%ebp)
801059e2:	e8 47 c2 ff ff       	call   80101c2e <iunlockput>
801059e7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801059ea:	83 ec 0c             	sub    $0xc,%esp
801059ed:	ff 75 f4             	pushl  -0xc(%ebp)
801059f0:	e8 69 c1 ff ff       	call   80101b5e <iput>
801059f5:	83 c4 10             	add    $0x10,%esp

  end_op();
801059f8:	e8 b1 db ff ff       	call   801035ae <end_op>

  return 0;
801059fd:	b8 00 00 00 00       	mov    $0x0,%eax
80105a02:	eb 48                	jmp    80105a4c <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105a04:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	ff 75 f4             	pushl  -0xc(%ebp)
80105a0b:	e8 ed bf ff ff       	call   801019fd <ilock>
80105a10:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a16:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a1a:	83 e8 01             	sub    $0x1,%eax
80105a1d:	89 c2                	mov    %eax,%edx
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a26:	83 ec 0c             	sub    $0xc,%esp
80105a29:	ff 75 f4             	pushl  -0xc(%ebp)
80105a2c:	e8 ef bd ff ff       	call   80101820 <iupdate>
80105a31:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a34:	83 ec 0c             	sub    $0xc,%esp
80105a37:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3a:	e8 ef c1 ff ff       	call   80101c2e <iunlockput>
80105a3f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a42:	e8 67 db ff ff       	call   801035ae <end_op>
  return -1;
80105a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a4c:	c9                   	leave  
80105a4d:	c3                   	ret    

80105a4e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a4e:	55                   	push   %ebp
80105a4f:	89 e5                	mov    %esp,%ebp
80105a51:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a54:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a5b:	eb 40                	jmp    80105a9d <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a60:	6a 10                	push   $0x10
80105a62:	50                   	push   %eax
80105a63:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a66:	50                   	push   %eax
80105a67:	ff 75 08             	pushl  0x8(%ebp)
80105a6a:	e8 7f c4 ff ff       	call   80101eee <readi>
80105a6f:	83 c4 10             	add    $0x10,%esp
80105a72:	83 f8 10             	cmp    $0x10,%eax
80105a75:	74 0d                	je     80105a84 <isdirempty+0x36>
      panic("isdirempty: readi");
80105a77:	83 ec 0c             	sub    $0xc,%esp
80105a7a:	68 28 8a 10 80       	push   $0x80108a28
80105a7f:	e8 1c ab ff ff       	call   801005a0 <panic>
    if(de.inum != 0)
80105a84:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105a88:	66 85 c0             	test   %ax,%ax
80105a8b:	74 07                	je     80105a94 <isdirempty+0x46>
      return 0;
80105a8d:	b8 00 00 00 00       	mov    $0x0,%eax
80105a92:	eb 1b                	jmp    80105aaf <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a97:	83 c0 10             	add    $0x10,%eax
80105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80105aa0:	8b 50 58             	mov    0x58(%eax),%edx
80105aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa6:	39 c2                	cmp    %eax,%edx
80105aa8:	77 b3                	ja     80105a5d <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105aaa:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105aaf:	c9                   	leave  
80105ab0:	c3                   	ret    

80105ab1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ab1:	55                   	push   %ebp
80105ab2:	89 e5                	mov    %esp,%ebp
80105ab4:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ab7:	83 ec 08             	sub    $0x8,%esp
80105aba:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105abd:	50                   	push   %eax
80105abe:	6a 00                	push   $0x0
80105ac0:	e8 9d fa ff ff       	call   80105562 <argstr>
80105ac5:	83 c4 10             	add    $0x10,%esp
80105ac8:	85 c0                	test   %eax,%eax
80105aca:	79 0a                	jns    80105ad6 <sys_unlink+0x25>
    return -1;
80105acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad1:	e9 bc 01 00 00       	jmp    80105c92 <sys_unlink+0x1e1>

  begin_op();
80105ad6:	e8 47 da ff ff       	call   80103522 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105adb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ade:	83 ec 08             	sub    $0x8,%esp
80105ae1:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105ae4:	52                   	push   %edx
80105ae5:	50                   	push   %eax
80105ae6:	e8 6e ca ff ff       	call   80102559 <nameiparent>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af5:	75 0f                	jne    80105b06 <sys_unlink+0x55>
    end_op();
80105af7:	e8 b2 da ff ff       	call   801035ae <end_op>
    return -1;
80105afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b01:	e9 8c 01 00 00       	jmp    80105c92 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105b06:	83 ec 0c             	sub    $0xc,%esp
80105b09:	ff 75 f4             	pushl  -0xc(%ebp)
80105b0c:	e8 ec be ff ff       	call   801019fd <ilock>
80105b11:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b14:	83 ec 08             	sub    $0x8,%esp
80105b17:	68 3a 8a 10 80       	push   $0x80108a3a
80105b1c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b1f:	50                   	push   %eax
80105b20:	e8 a8 c6 ff ff       	call   801021cd <namecmp>
80105b25:	83 c4 10             	add    $0x10,%esp
80105b28:	85 c0                	test   %eax,%eax
80105b2a:	0f 84 4a 01 00 00    	je     80105c7a <sys_unlink+0x1c9>
80105b30:	83 ec 08             	sub    $0x8,%esp
80105b33:	68 3c 8a 10 80       	push   $0x80108a3c
80105b38:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b3b:	50                   	push   %eax
80105b3c:	e8 8c c6 ff ff       	call   801021cd <namecmp>
80105b41:	83 c4 10             	add    $0x10,%esp
80105b44:	85 c0                	test   %eax,%eax
80105b46:	0f 84 2e 01 00 00    	je     80105c7a <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b4c:	83 ec 04             	sub    $0x4,%esp
80105b4f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b52:	50                   	push   %eax
80105b53:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b56:	50                   	push   %eax
80105b57:	ff 75 f4             	pushl  -0xc(%ebp)
80105b5a:	e8 89 c6 ff ff       	call   801021e8 <dirlookup>
80105b5f:	83 c4 10             	add    $0x10,%esp
80105b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b69:	0f 84 0a 01 00 00    	je     80105c79 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105b6f:	83 ec 0c             	sub    $0xc,%esp
80105b72:	ff 75 f0             	pushl  -0x10(%ebp)
80105b75:	e8 83 be ff ff       	call   801019fd <ilock>
80105b7a:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b80:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b84:	66 85 c0             	test   %ax,%ax
80105b87:	7f 0d                	jg     80105b96 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105b89:	83 ec 0c             	sub    $0xc,%esp
80105b8c:	68 3f 8a 10 80       	push   $0x80108a3f
80105b91:	e8 0a aa ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b99:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b9d:	66 83 f8 01          	cmp    $0x1,%ax
80105ba1:	75 25                	jne    80105bc8 <sys_unlink+0x117>
80105ba3:	83 ec 0c             	sub    $0xc,%esp
80105ba6:	ff 75 f0             	pushl  -0x10(%ebp)
80105ba9:	e8 a0 fe ff ff       	call   80105a4e <isdirempty>
80105bae:	83 c4 10             	add    $0x10,%esp
80105bb1:	85 c0                	test   %eax,%eax
80105bb3:	75 13                	jne    80105bc8 <sys_unlink+0x117>
    iunlockput(ip);
80105bb5:	83 ec 0c             	sub    $0xc,%esp
80105bb8:	ff 75 f0             	pushl  -0x10(%ebp)
80105bbb:	e8 6e c0 ff ff       	call   80101c2e <iunlockput>
80105bc0:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105bc3:	e9 b2 00 00 00       	jmp    80105c7a <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105bc8:	83 ec 04             	sub    $0x4,%esp
80105bcb:	6a 10                	push   $0x10
80105bcd:	6a 00                	push   $0x0
80105bcf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bd2:	50                   	push   %eax
80105bd3:	e8 f1 f5 ff ff       	call   801051c9 <memset>
80105bd8:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bdb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105bde:	6a 10                	push   $0x10
80105be0:	50                   	push   %eax
80105be1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105be4:	50                   	push   %eax
80105be5:	ff 75 f4             	pushl  -0xc(%ebp)
80105be8:	e8 58 c4 ff ff       	call   80102045 <writei>
80105bed:	83 c4 10             	add    $0x10,%esp
80105bf0:	83 f8 10             	cmp    $0x10,%eax
80105bf3:	74 0d                	je     80105c02 <sys_unlink+0x151>
    panic("unlink: writei");
80105bf5:	83 ec 0c             	sub    $0xc,%esp
80105bf8:	68 51 8a 10 80       	push   $0x80108a51
80105bfd:	e8 9e a9 ff ff       	call   801005a0 <panic>
  if(ip->type == T_DIR){
80105c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c05:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c09:	66 83 f8 01          	cmp    $0x1,%ax
80105c0d:	75 21                	jne    80105c30 <sys_unlink+0x17f>
    dp->nlink--;
80105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c12:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c16:	83 e8 01             	sub    $0x1,%eax
80105c19:	89 c2                	mov    %eax,%edx
80105c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105c22:	83 ec 0c             	sub    $0xc,%esp
80105c25:	ff 75 f4             	pushl  -0xc(%ebp)
80105c28:	e8 f3 bb ff ff       	call   80101820 <iupdate>
80105c2d:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105c30:	83 ec 0c             	sub    $0xc,%esp
80105c33:	ff 75 f4             	pushl  -0xc(%ebp)
80105c36:	e8 f3 bf ff ff       	call   80101c2e <iunlockput>
80105c3b:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c41:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c45:	83 e8 01             	sub    $0x1,%eax
80105c48:	89 c2                	mov    %eax,%edx
80105c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c51:	83 ec 0c             	sub    $0xc,%esp
80105c54:	ff 75 f0             	pushl  -0x10(%ebp)
80105c57:	e8 c4 bb ff ff       	call   80101820 <iupdate>
80105c5c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c5f:	83 ec 0c             	sub    $0xc,%esp
80105c62:	ff 75 f0             	pushl  -0x10(%ebp)
80105c65:	e8 c4 bf ff ff       	call   80101c2e <iunlockput>
80105c6a:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c6d:	e8 3c d9 ff ff       	call   801035ae <end_op>

  return 0;
80105c72:	b8 00 00 00 00       	mov    $0x0,%eax
80105c77:	eb 19                	jmp    80105c92 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105c79:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105c7a:	83 ec 0c             	sub    $0xc,%esp
80105c7d:	ff 75 f4             	pushl  -0xc(%ebp)
80105c80:	e8 a9 bf ff ff       	call   80101c2e <iunlockput>
80105c85:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c88:	e8 21 d9 ff ff       	call   801035ae <end_op>
  return -1;
80105c8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c92:	c9                   	leave  
80105c93:	c3                   	ret    

80105c94 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c94:	55                   	push   %ebp
80105c95:	89 e5                	mov    %esp,%ebp
80105c97:	83 ec 38             	sub    $0x38,%esp
80105c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c9d:	8b 55 10             	mov    0x10(%ebp),%edx
80105ca0:	8b 45 14             	mov    0x14(%ebp),%eax
80105ca3:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ca7:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105cab:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105caf:	83 ec 08             	sub    $0x8,%esp
80105cb2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cb5:	50                   	push   %eax
80105cb6:	ff 75 08             	pushl  0x8(%ebp)
80105cb9:	e8 9b c8 ff ff       	call   80102559 <nameiparent>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc8:	75 0a                	jne    80105cd4 <create+0x40>
    return 0;
80105cca:	b8 00 00 00 00       	mov    $0x0,%eax
80105ccf:	e9 90 01 00 00       	jmp    80105e64 <create+0x1d0>
  ilock(dp);
80105cd4:	83 ec 0c             	sub    $0xc,%esp
80105cd7:	ff 75 f4             	pushl  -0xc(%ebp)
80105cda:	e8 1e bd ff ff       	call   801019fd <ilock>
80105cdf:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ce2:	83 ec 04             	sub    $0x4,%esp
80105ce5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ce8:	50                   	push   %eax
80105ce9:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cec:	50                   	push   %eax
80105ced:	ff 75 f4             	pushl  -0xc(%ebp)
80105cf0:	e8 f3 c4 ff ff       	call   801021e8 <dirlookup>
80105cf5:	83 c4 10             	add    $0x10,%esp
80105cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cff:	74 50                	je     80105d51 <create+0xbd>
    iunlockput(dp);
80105d01:	83 ec 0c             	sub    $0xc,%esp
80105d04:	ff 75 f4             	pushl  -0xc(%ebp)
80105d07:	e8 22 bf ff ff       	call   80101c2e <iunlockput>
80105d0c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105d0f:	83 ec 0c             	sub    $0xc,%esp
80105d12:	ff 75 f0             	pushl  -0x10(%ebp)
80105d15:	e8 e3 bc ff ff       	call   801019fd <ilock>
80105d1a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105d1d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105d22:	75 15                	jne    80105d39 <create+0xa5>
80105d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d27:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d2b:	66 83 f8 02          	cmp    $0x2,%ax
80105d2f:	75 08                	jne    80105d39 <create+0xa5>
      return ip;
80105d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d34:	e9 2b 01 00 00       	jmp    80105e64 <create+0x1d0>
    iunlockput(ip);
80105d39:	83 ec 0c             	sub    $0xc,%esp
80105d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80105d3f:	e8 ea be ff ff       	call   80101c2e <iunlockput>
80105d44:	83 c4 10             	add    $0x10,%esp
    return 0;
80105d47:	b8 00 00 00 00       	mov    $0x0,%eax
80105d4c:	e9 13 01 00 00       	jmp    80105e64 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105d51:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d58:	8b 00                	mov    (%eax),%eax
80105d5a:	83 ec 08             	sub    $0x8,%esp
80105d5d:	52                   	push   %edx
80105d5e:	50                   	push   %eax
80105d5f:	e8 e5 b9 ff ff       	call   80101749 <ialloc>
80105d64:	83 c4 10             	add    $0x10,%esp
80105d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d6e:	75 0d                	jne    80105d7d <create+0xe9>
    panic("create: ialloc");
80105d70:	83 ec 0c             	sub    $0xc,%esp
80105d73:	68 60 8a 10 80       	push   $0x80108a60
80105d78:	e8 23 a8 ff ff       	call   801005a0 <panic>

  ilock(ip);
80105d7d:	83 ec 0c             	sub    $0xc,%esp
80105d80:	ff 75 f0             	pushl  -0x10(%ebp)
80105d83:	e8 75 bc ff ff       	call   801019fd <ilock>
80105d88:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8e:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105d92:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d99:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105d9d:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da4:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105daa:	83 ec 0c             	sub    $0xc,%esp
80105dad:	ff 75 f0             	pushl  -0x10(%ebp)
80105db0:	e8 6b ba ff ff       	call   80101820 <iupdate>
80105db5:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105db8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105dbd:	75 6a                	jne    80105e29 <create+0x195>
    dp->nlink++;  // for ".."
80105dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105dc6:	83 c0 01             	add    $0x1,%eax
80105dc9:	89 c2                	mov    %eax,%edx
80105dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dce:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105dd2:	83 ec 0c             	sub    $0xc,%esp
80105dd5:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd8:	e8 43 ba ff ff       	call   80101820 <iupdate>
80105ddd:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de3:	8b 40 04             	mov    0x4(%eax),%eax
80105de6:	83 ec 04             	sub    $0x4,%esp
80105de9:	50                   	push   %eax
80105dea:	68 3a 8a 10 80       	push   $0x80108a3a
80105def:	ff 75 f0             	pushl  -0x10(%ebp)
80105df2:	e8 ab c4 ff ff       	call   801022a2 <dirlink>
80105df7:	83 c4 10             	add    $0x10,%esp
80105dfa:	85 c0                	test   %eax,%eax
80105dfc:	78 1e                	js     80105e1c <create+0x188>
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	8b 40 04             	mov    0x4(%eax),%eax
80105e04:	83 ec 04             	sub    $0x4,%esp
80105e07:	50                   	push   %eax
80105e08:	68 3c 8a 10 80       	push   $0x80108a3c
80105e0d:	ff 75 f0             	pushl  -0x10(%ebp)
80105e10:	e8 8d c4 ff ff       	call   801022a2 <dirlink>
80105e15:	83 c4 10             	add    $0x10,%esp
80105e18:	85 c0                	test   %eax,%eax
80105e1a:	79 0d                	jns    80105e29 <create+0x195>
      panic("create dots");
80105e1c:	83 ec 0c             	sub    $0xc,%esp
80105e1f:	68 6f 8a 10 80       	push   $0x80108a6f
80105e24:	e8 77 a7 ff ff       	call   801005a0 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2c:	8b 40 04             	mov    0x4(%eax),%eax
80105e2f:	83 ec 04             	sub    $0x4,%esp
80105e32:	50                   	push   %eax
80105e33:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e36:	50                   	push   %eax
80105e37:	ff 75 f4             	pushl  -0xc(%ebp)
80105e3a:	e8 63 c4 ff ff       	call   801022a2 <dirlink>
80105e3f:	83 c4 10             	add    $0x10,%esp
80105e42:	85 c0                	test   %eax,%eax
80105e44:	79 0d                	jns    80105e53 <create+0x1bf>
    panic("create: dirlink");
80105e46:	83 ec 0c             	sub    $0xc,%esp
80105e49:	68 7b 8a 10 80       	push   $0x80108a7b
80105e4e:	e8 4d a7 ff ff       	call   801005a0 <panic>

  iunlockput(dp);
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	ff 75 f4             	pushl  -0xc(%ebp)
80105e59:	e8 d0 bd ff ff       	call   80101c2e <iunlockput>
80105e5e:	83 c4 10             	add    $0x10,%esp

  return ip;
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e64:	c9                   	leave  
80105e65:	c3                   	ret    

80105e66 <sys_open>:

int
sys_open(void)
{
80105e66:	55                   	push   %ebp
80105e67:	89 e5                	mov    %esp,%ebp
80105e69:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e6c:	83 ec 08             	sub    $0x8,%esp
80105e6f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e72:	50                   	push   %eax
80105e73:	6a 00                	push   $0x0
80105e75:	e8 e8 f6 ff ff       	call   80105562 <argstr>
80105e7a:	83 c4 10             	add    $0x10,%esp
80105e7d:	85 c0                	test   %eax,%eax
80105e7f:	78 15                	js     80105e96 <sys_open+0x30>
80105e81:	83 ec 08             	sub    $0x8,%esp
80105e84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e87:	50                   	push   %eax
80105e88:	6a 01                	push   $0x1
80105e8a:	e8 50 f6 ff ff       	call   801054df <argint>
80105e8f:	83 c4 10             	add    $0x10,%esp
80105e92:	85 c0                	test   %eax,%eax
80105e94:	79 0a                	jns    80105ea0 <sys_open+0x3a>
    return -1;
80105e96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9b:	e9 61 01 00 00       	jmp    80106001 <sys_open+0x19b>

  begin_op();
80105ea0:	e8 7d d6 ff ff       	call   80103522 <begin_op>

  if(omode & O_CREATE){
80105ea5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ea8:	25 00 02 00 00       	and    $0x200,%eax
80105ead:	85 c0                	test   %eax,%eax
80105eaf:	74 2a                	je     80105edb <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105eb4:	6a 00                	push   $0x0
80105eb6:	6a 00                	push   $0x0
80105eb8:	6a 02                	push   $0x2
80105eba:	50                   	push   %eax
80105ebb:	e8 d4 fd ff ff       	call   80105c94 <create>
80105ec0:	83 c4 10             	add    $0x10,%esp
80105ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ec6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eca:	75 75                	jne    80105f41 <sys_open+0xdb>
      end_op();
80105ecc:	e8 dd d6 ff ff       	call   801035ae <end_op>
      return -1;
80105ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed6:	e9 26 01 00 00       	jmp    80106001 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105edb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ede:	83 ec 0c             	sub    $0xc,%esp
80105ee1:	50                   	push   %eax
80105ee2:	e8 56 c6 ff ff       	call   8010253d <namei>
80105ee7:	83 c4 10             	add    $0x10,%esp
80105eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ef1:	75 0f                	jne    80105f02 <sys_open+0x9c>
      end_op();
80105ef3:	e8 b6 d6 ff ff       	call   801035ae <end_op>
      return -1;
80105ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efd:	e9 ff 00 00 00       	jmp    80106001 <sys_open+0x19b>
    }
    ilock(ip);
80105f02:	83 ec 0c             	sub    $0xc,%esp
80105f05:	ff 75 f4             	pushl  -0xc(%ebp)
80105f08:	e8 f0 ba ff ff       	call   801019fd <ilock>
80105f0d:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f13:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f17:	66 83 f8 01          	cmp    $0x1,%ax
80105f1b:	75 24                	jne    80105f41 <sys_open+0xdb>
80105f1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f20:	85 c0                	test   %eax,%eax
80105f22:	74 1d                	je     80105f41 <sys_open+0xdb>
      iunlockput(ip);
80105f24:	83 ec 0c             	sub    $0xc,%esp
80105f27:	ff 75 f4             	pushl  -0xc(%ebp)
80105f2a:	e8 ff bc ff ff       	call   80101c2e <iunlockput>
80105f2f:	83 c4 10             	add    $0x10,%esp
      end_op();
80105f32:	e8 77 d6 ff ff       	call   801035ae <end_op>
      return -1;
80105f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3c:	e9 c0 00 00 00       	jmp    80106001 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105f41:	e8 9a b0 ff ff       	call   80100fe0 <filealloc>
80105f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4d:	74 17                	je     80105f66 <sys_open+0x100>
80105f4f:	83 ec 0c             	sub    $0xc,%esp
80105f52:	ff 75 f0             	pushl  -0x10(%ebp)
80105f55:	e8 34 f7 ff ff       	call   8010568e <fdalloc>
80105f5a:	83 c4 10             	add    $0x10,%esp
80105f5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f64:	79 2e                	jns    80105f94 <sys_open+0x12e>
    if(f)
80105f66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f6a:	74 0e                	je     80105f7a <sys_open+0x114>
      fileclose(f);
80105f6c:	83 ec 0c             	sub    $0xc,%esp
80105f6f:	ff 75 f0             	pushl  -0x10(%ebp)
80105f72:	e8 27 b1 ff ff       	call   8010109e <fileclose>
80105f77:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105f7a:	83 ec 0c             	sub    $0xc,%esp
80105f7d:	ff 75 f4             	pushl  -0xc(%ebp)
80105f80:	e8 a9 bc ff ff       	call   80101c2e <iunlockput>
80105f85:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f88:	e8 21 d6 ff ff       	call   801035ae <end_op>
    return -1;
80105f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f92:	eb 6d                	jmp    80106001 <sys_open+0x19b>
  }
  iunlock(ip);
80105f94:	83 ec 0c             	sub    $0xc,%esp
80105f97:	ff 75 f4             	pushl  -0xc(%ebp)
80105f9a:	e8 71 bb ff ff       	call   80101b10 <iunlock>
80105f9f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fa2:	e8 07 d6 ff ff       	call   801035ae <end_op>

  f->type = FD_INODE;
80105fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105faa:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fb6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105fc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc6:	83 e0 01             	and    $0x1,%eax
80105fc9:	85 c0                	test   %eax,%eax
80105fcb:	0f 94 c0             	sete   %al
80105fce:	89 c2                	mov    %eax,%edx
80105fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd9:	83 e0 01             	and    $0x1,%eax
80105fdc:	85 c0                	test   %eax,%eax
80105fde:	75 0a                	jne    80105fea <sys_open+0x184>
80105fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe3:	83 e0 02             	and    $0x2,%eax
80105fe6:	85 c0                	test   %eax,%eax
80105fe8:	74 07                	je     80105ff1 <sys_open+0x18b>
80105fea:	b8 01 00 00 00       	mov    $0x1,%eax
80105fef:	eb 05                	jmp    80105ff6 <sys_open+0x190>
80105ff1:	b8 00 00 00 00       	mov    $0x0,%eax
80105ff6:	89 c2                	mov    %eax,%edx
80105ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105ffe:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106001:	c9                   	leave  
80106002:	c3                   	ret    

80106003 <sys_mkdir>:

int
sys_mkdir(void)
{
80106003:	55                   	push   %ebp
80106004:	89 e5                	mov    %esp,%ebp
80106006:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106009:	e8 14 d5 ff ff       	call   80103522 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010600e:	83 ec 08             	sub    $0x8,%esp
80106011:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106014:	50                   	push   %eax
80106015:	6a 00                	push   $0x0
80106017:	e8 46 f5 ff ff       	call   80105562 <argstr>
8010601c:	83 c4 10             	add    $0x10,%esp
8010601f:	85 c0                	test   %eax,%eax
80106021:	78 1b                	js     8010603e <sys_mkdir+0x3b>
80106023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106026:	6a 00                	push   $0x0
80106028:	6a 00                	push   $0x0
8010602a:	6a 01                	push   $0x1
8010602c:	50                   	push   %eax
8010602d:	e8 62 fc ff ff       	call   80105c94 <create>
80106032:	83 c4 10             	add    $0x10,%esp
80106035:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106038:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010603c:	75 0c                	jne    8010604a <sys_mkdir+0x47>
    end_op();
8010603e:	e8 6b d5 ff ff       	call   801035ae <end_op>
    return -1;
80106043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106048:	eb 18                	jmp    80106062 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010604a:	83 ec 0c             	sub    $0xc,%esp
8010604d:	ff 75 f4             	pushl  -0xc(%ebp)
80106050:	e8 d9 bb ff ff       	call   80101c2e <iunlockput>
80106055:	83 c4 10             	add    $0x10,%esp
  end_op();
80106058:	e8 51 d5 ff ff       	call   801035ae <end_op>
  return 0;
8010605d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106062:	c9                   	leave  
80106063:	c3                   	ret    

80106064 <sys_mknod>:

int
sys_mknod(void)
{
80106064:	55                   	push   %ebp
80106065:	89 e5                	mov    %esp,%ebp
80106067:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010606a:	e8 b3 d4 ff ff       	call   80103522 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010606f:	83 ec 08             	sub    $0x8,%esp
80106072:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106075:	50                   	push   %eax
80106076:	6a 00                	push   $0x0
80106078:	e8 e5 f4 ff ff       	call   80105562 <argstr>
8010607d:	83 c4 10             	add    $0x10,%esp
80106080:	85 c0                	test   %eax,%eax
80106082:	78 4f                	js     801060d3 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106084:	83 ec 08             	sub    $0x8,%esp
80106087:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010608a:	50                   	push   %eax
8010608b:	6a 01                	push   $0x1
8010608d:	e8 4d f4 ff ff       	call   801054df <argint>
80106092:	83 c4 10             	add    $0x10,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106095:	85 c0                	test   %eax,%eax
80106097:	78 3a                	js     801060d3 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106099:	83 ec 08             	sub    $0x8,%esp
8010609c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010609f:	50                   	push   %eax
801060a0:	6a 02                	push   $0x2
801060a2:	e8 38 f4 ff ff       	call   801054df <argint>
801060a7:	83 c4 10             	add    $0x10,%esp
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801060aa:	85 c0                	test   %eax,%eax
801060ac:	78 25                	js     801060d3 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801060ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060b1:	0f bf c8             	movswl %ax,%ecx
801060b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060b7:	0f bf d0             	movswl %ax,%edx
801060ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801060bd:	51                   	push   %ecx
801060be:	52                   	push   %edx
801060bf:	6a 03                	push   $0x3
801060c1:	50                   	push   %eax
801060c2:	e8 cd fb ff ff       	call   80105c94 <create>
801060c7:	83 c4 10             	add    $0x10,%esp
801060ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d1:	75 0c                	jne    801060df <sys_mknod+0x7b>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801060d3:	e8 d6 d4 ff ff       	call   801035ae <end_op>
    return -1;
801060d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060dd:	eb 18                	jmp    801060f7 <sys_mknod+0x93>
  }
  iunlockput(ip);
801060df:	83 ec 0c             	sub    $0xc,%esp
801060e2:	ff 75 f4             	pushl  -0xc(%ebp)
801060e5:	e8 44 bb ff ff       	call   80101c2e <iunlockput>
801060ea:	83 c4 10             	add    $0x10,%esp
  end_op();
801060ed:	e8 bc d4 ff ff       	call   801035ae <end_op>
  return 0;
801060f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060f7:	c9                   	leave  
801060f8:	c3                   	ret    

801060f9 <sys_chdir>:

int
sys_chdir(void)
{
801060f9:	55                   	push   %ebp
801060fa:	89 e5                	mov    %esp,%ebp
801060fc:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801060ff:	e8 76 e1 ff ff       	call   8010427a <myproc>
80106104:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106107:	e8 16 d4 ff ff       	call   80103522 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010610c:	83 ec 08             	sub    $0x8,%esp
8010610f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106112:	50                   	push   %eax
80106113:	6a 00                	push   $0x0
80106115:	e8 48 f4 ff ff       	call   80105562 <argstr>
8010611a:	83 c4 10             	add    $0x10,%esp
8010611d:	85 c0                	test   %eax,%eax
8010611f:	78 18                	js     80106139 <sys_chdir+0x40>
80106121:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106124:	83 ec 0c             	sub    $0xc,%esp
80106127:	50                   	push   %eax
80106128:	e8 10 c4 ff ff       	call   8010253d <namei>
8010612d:	83 c4 10             	add    $0x10,%esp
80106130:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106133:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106137:	75 0c                	jne    80106145 <sys_chdir+0x4c>
    end_op();
80106139:	e8 70 d4 ff ff       	call   801035ae <end_op>
    return -1;
8010613e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106143:	eb 68                	jmp    801061ad <sys_chdir+0xb4>
  }
  ilock(ip);
80106145:	83 ec 0c             	sub    $0xc,%esp
80106148:	ff 75 f0             	pushl  -0x10(%ebp)
8010614b:	e8 ad b8 ff ff       	call   801019fd <ilock>
80106150:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106156:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010615a:	66 83 f8 01          	cmp    $0x1,%ax
8010615e:	74 1a                	je     8010617a <sys_chdir+0x81>
    iunlockput(ip);
80106160:	83 ec 0c             	sub    $0xc,%esp
80106163:	ff 75 f0             	pushl  -0x10(%ebp)
80106166:	e8 c3 ba ff ff       	call   80101c2e <iunlockput>
8010616b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010616e:	e8 3b d4 ff ff       	call   801035ae <end_op>
    return -1;
80106173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106178:	eb 33                	jmp    801061ad <sys_chdir+0xb4>
  }
  iunlock(ip);
8010617a:	83 ec 0c             	sub    $0xc,%esp
8010617d:	ff 75 f0             	pushl  -0x10(%ebp)
80106180:	e8 8b b9 ff ff       	call   80101b10 <iunlock>
80106185:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618b:	8b 40 68             	mov    0x68(%eax),%eax
8010618e:	83 ec 0c             	sub    $0xc,%esp
80106191:	50                   	push   %eax
80106192:	e8 c7 b9 ff ff       	call   80101b5e <iput>
80106197:	83 c4 10             	add    $0x10,%esp
  end_op();
8010619a:	e8 0f d4 ff ff       	call   801035ae <end_op>
  curproc->cwd = ip;
8010619f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061a5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801061a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ad:	c9                   	leave  
801061ae:	c3                   	ret    

801061af <sys_exec>:

int
sys_exec(void)
{
801061af:	55                   	push   %ebp
801061b0:	89 e5                	mov    %esp,%ebp
801061b2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801061b8:	83 ec 08             	sub    $0x8,%esp
801061bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061be:	50                   	push   %eax
801061bf:	6a 00                	push   $0x0
801061c1:	e8 9c f3 ff ff       	call   80105562 <argstr>
801061c6:	83 c4 10             	add    $0x10,%esp
801061c9:	85 c0                	test   %eax,%eax
801061cb:	78 18                	js     801061e5 <sys_exec+0x36>
801061cd:	83 ec 08             	sub    $0x8,%esp
801061d0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801061d6:	50                   	push   %eax
801061d7:	6a 01                	push   $0x1
801061d9:	e8 01 f3 ff ff       	call   801054df <argint>
801061de:	83 c4 10             	add    $0x10,%esp
801061e1:	85 c0                	test   %eax,%eax
801061e3:	79 0a                	jns    801061ef <sys_exec+0x40>
    return -1;
801061e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ea:	e9 c6 00 00 00       	jmp    801062b5 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801061ef:	83 ec 04             	sub    $0x4,%esp
801061f2:	68 80 00 00 00       	push   $0x80
801061f7:	6a 00                	push   $0x0
801061f9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061ff:	50                   	push   %eax
80106200:	e8 c4 ef ff ff       	call   801051c9 <memset>
80106205:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010620f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106212:	83 f8 1f             	cmp    $0x1f,%eax
80106215:	76 0a                	jbe    80106221 <sys_exec+0x72>
      return -1;
80106217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621c:	e9 94 00 00 00       	jmp    801062b5 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106224:	c1 e0 02             	shl    $0x2,%eax
80106227:	89 c2                	mov    %eax,%edx
80106229:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010622f:	01 c2                	add    %eax,%edx
80106231:	83 ec 08             	sub    $0x8,%esp
80106234:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010623a:	50                   	push   %eax
8010623b:	52                   	push   %edx
8010623c:	e8 11 f2 ff ff       	call   80105452 <fetchint>
80106241:	83 c4 10             	add    $0x10,%esp
80106244:	85 c0                	test   %eax,%eax
80106246:	79 07                	jns    8010624f <sys_exec+0xa0>
      return -1;
80106248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624d:	eb 66                	jmp    801062b5 <sys_exec+0x106>
    if(uarg == 0){
8010624f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106255:	85 c0                	test   %eax,%eax
80106257:	75 27                	jne    80106280 <sys_exec+0xd1>
      argv[i] = 0;
80106259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106263:	00 00 00 00 
      break;
80106267:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626b:	83 ec 08             	sub    $0x8,%esp
8010626e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106274:	52                   	push   %edx
80106275:	50                   	push   %eax
80106276:	e8 1b a9 ff ff       	call   80100b96 <exec>
8010627b:	83 c4 10             	add    $0x10,%esp
8010627e:	eb 35                	jmp    801062b5 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106280:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106286:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106289:	c1 e2 02             	shl    $0x2,%edx
8010628c:	01 c2                	add    %eax,%edx
8010628e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106294:	83 ec 08             	sub    $0x8,%esp
80106297:	52                   	push   %edx
80106298:	50                   	push   %eax
80106299:	e8 e0 f1 ff ff       	call   8010547e <fetchstr>
8010629e:	83 c4 10             	add    $0x10,%esp
801062a1:	85 c0                	test   %eax,%eax
801062a3:	79 07                	jns    801062ac <sys_exec+0xfd>
      return -1;
801062a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062aa:	eb 09                	jmp    801062b5 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801062ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801062b0:	e9 5a ff ff ff       	jmp    8010620f <sys_exec+0x60>
  return exec(path, argv);
}
801062b5:	c9                   	leave  
801062b6:	c3                   	ret    

801062b7 <sys_pipe>:

int
sys_pipe(void)
{
801062b7:	55                   	push   %ebp
801062b8:	89 e5                	mov    %esp,%ebp
801062ba:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801062bd:	83 ec 04             	sub    $0x4,%esp
801062c0:	6a 08                	push   $0x8
801062c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c5:	50                   	push   %eax
801062c6:	6a 00                	push   $0x0
801062c8:	e8 3f f2 ff ff       	call   8010550c <argptr>
801062cd:	83 c4 10             	add    $0x10,%esp
801062d0:	85 c0                	test   %eax,%eax
801062d2:	79 0a                	jns    801062de <sys_pipe+0x27>
    return -1;
801062d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d9:	e9 b0 00 00 00       	jmp    8010638e <sys_pipe+0xd7>
  if(pipealloc(&rf, &wf) < 0)
801062de:	83 ec 08             	sub    $0x8,%esp
801062e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062e4:	50                   	push   %eax
801062e5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062e8:	50                   	push   %eax
801062e9:	e8 c3 da ff ff       	call   80103db1 <pipealloc>
801062ee:	83 c4 10             	add    $0x10,%esp
801062f1:	85 c0                	test   %eax,%eax
801062f3:	79 0a                	jns    801062ff <sys_pipe+0x48>
    return -1;
801062f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fa:	e9 8f 00 00 00       	jmp    8010638e <sys_pipe+0xd7>
  fd0 = -1;
801062ff:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106306:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106309:	83 ec 0c             	sub    $0xc,%esp
8010630c:	50                   	push   %eax
8010630d:	e8 7c f3 ff ff       	call   8010568e <fdalloc>
80106312:	83 c4 10             	add    $0x10,%esp
80106315:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106318:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631c:	78 18                	js     80106336 <sys_pipe+0x7f>
8010631e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106321:	83 ec 0c             	sub    $0xc,%esp
80106324:	50                   	push   %eax
80106325:	e8 64 f3 ff ff       	call   8010568e <fdalloc>
8010632a:	83 c4 10             	add    $0x10,%esp
8010632d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106330:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106334:	79 40                	jns    80106376 <sys_pipe+0xbf>
    if(fd0 >= 0)
80106336:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010633a:	78 15                	js     80106351 <sys_pipe+0x9a>
      myproc()->ofile[fd0] = 0;
8010633c:	e8 39 df ff ff       	call   8010427a <myproc>
80106341:	89 c2                	mov    %eax,%edx
80106343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106346:	83 c0 08             	add    $0x8,%eax
80106349:	c7 44 82 08 00 00 00 	movl   $0x0,0x8(%edx,%eax,4)
80106350:	00 
    fileclose(rf);
80106351:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106354:	83 ec 0c             	sub    $0xc,%esp
80106357:	50                   	push   %eax
80106358:	e8 41 ad ff ff       	call   8010109e <fileclose>
8010635d:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106360:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106363:	83 ec 0c             	sub    $0xc,%esp
80106366:	50                   	push   %eax
80106367:	e8 32 ad ff ff       	call   8010109e <fileclose>
8010636c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010636f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106374:	eb 18                	jmp    8010638e <sys_pipe+0xd7>
  }
  fd[0] = fd0;
80106376:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106379:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010637c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010637e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106381:	8d 50 04             	lea    0x4(%eax),%edx
80106384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106387:	89 02                	mov    %eax,(%edx)
  return 0;
80106389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638e:	c9                   	leave  
8010638f:	c3                   	ret    

80106390 <sys_shm_open>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_shm_open(void) {
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	83 ec 18             	sub    $0x18,%esp
  int id;
  char **pointer;

  if(argint(0, &id) < 0)
80106396:	83 ec 08             	sub    $0x8,%esp
80106399:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010639c:	50                   	push   %eax
8010639d:	6a 00                	push   $0x0
8010639f:	e8 3b f1 ff ff       	call   801054df <argint>
801063a4:	83 c4 10             	add    $0x10,%esp
801063a7:	85 c0                	test   %eax,%eax
801063a9:	79 07                	jns    801063b2 <sys_shm_open+0x22>
    return -1;
801063ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b0:	eb 31                	jmp    801063e3 <sys_shm_open+0x53>

  if(argptr(1, (char **) (&pointer),4)<0)
801063b2:	83 ec 04             	sub    $0x4,%esp
801063b5:	6a 04                	push   $0x4
801063b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ba:	50                   	push   %eax
801063bb:	6a 01                	push   $0x1
801063bd:	e8 4a f1 ff ff       	call   8010550c <argptr>
801063c2:	83 c4 10             	add    $0x10,%esp
801063c5:	85 c0                	test   %eax,%eax
801063c7:	79 07                	jns    801063d0 <sys_shm_open+0x40>
    return -1;
801063c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ce:	eb 13                	jmp    801063e3 <sys_shm_open+0x53>
  return shm_open(id, pointer);
801063d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	83 ec 08             	sub    $0x8,%esp
801063d9:	52                   	push   %edx
801063da:	50                   	push   %eax
801063db:	e8 a0 21 00 00       	call   80108580 <shm_open>
801063e0:	83 c4 10             	add    $0x10,%esp
}
801063e3:	c9                   	leave  
801063e4:	c3                   	ret    

801063e5 <sys_shm_close>:

int sys_shm_close(void) {
801063e5:	55                   	push   %ebp
801063e6:	89 e5                	mov    %esp,%ebp
801063e8:	83 ec 18             	sub    $0x18,%esp
  int id;

  if(argint(0, &id) < 0)
801063eb:	83 ec 08             	sub    $0x8,%esp
801063ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063f1:	50                   	push   %eax
801063f2:	6a 00                	push   $0x0
801063f4:	e8 e6 f0 ff ff       	call   801054df <argint>
801063f9:	83 c4 10             	add    $0x10,%esp
801063fc:	85 c0                	test   %eax,%eax
801063fe:	79 07                	jns    80106407 <sys_shm_close+0x22>
    return -1;
80106400:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106405:	eb 0f                	jmp    80106416 <sys_shm_close+0x31>

  
  return shm_close(id);
80106407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640a:	83 ec 0c             	sub    $0xc,%esp
8010640d:	50                   	push   %eax
8010640e:	e8 77 21 00 00       	call   8010858a <shm_close>
80106413:	83 c4 10             	add    $0x10,%esp
}
80106416:	c9                   	leave  
80106417:	c3                   	ret    

80106418 <sys_fork>:

int
sys_fork(void)
{
80106418:	55                   	push   %ebp
80106419:	89 e5                	mov    %esp,%ebp
8010641b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010641e:	e8 5c e1 ff ff       	call   8010457f <fork>
}
80106423:	c9                   	leave  
80106424:	c3                   	ret    

80106425 <sys_exit>:

int
sys_exit(void)
{
80106425:	55                   	push   %ebp
80106426:	89 e5                	mov    %esp,%ebp
80106428:	83 ec 08             	sub    $0x8,%esp
  exit();
8010642b:	e8 d6 e2 ff ff       	call   80104706 <exit>
  return 0;  // not reached
80106430:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106435:	c9                   	leave  
80106436:	c3                   	ret    

80106437 <sys_wait>:

int
sys_wait(void)
{
80106437:	55                   	push   %ebp
80106438:	89 e5                	mov    %esp,%ebp
8010643a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010643d:	e8 e4 e3 ff ff       	call   80104826 <wait>
}
80106442:	c9                   	leave  
80106443:	c3                   	ret    

80106444 <sys_kill>:

int
sys_kill(void)
{
80106444:	55                   	push   %ebp
80106445:	89 e5                	mov    %esp,%ebp
80106447:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010644a:	83 ec 08             	sub    $0x8,%esp
8010644d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106450:	50                   	push   %eax
80106451:	6a 00                	push   $0x0
80106453:	e8 87 f0 ff ff       	call   801054df <argint>
80106458:	83 c4 10             	add    $0x10,%esp
8010645b:	85 c0                	test   %eax,%eax
8010645d:	79 07                	jns    80106466 <sys_kill+0x22>
    return -1;
8010645f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106464:	eb 0f                	jmp    80106475 <sys_kill+0x31>
  return kill(pid);
80106466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106469:	83 ec 0c             	sub    $0xc,%esp
8010646c:	50                   	push   %eax
8010646d:	e8 e4 e7 ff ff       	call   80104c56 <kill>
80106472:	83 c4 10             	add    $0x10,%esp
}
80106475:	c9                   	leave  
80106476:	c3                   	ret    

80106477 <sys_getpid>:

int
sys_getpid(void)
{
80106477:	55                   	push   %ebp
80106478:	89 e5                	mov    %esp,%ebp
8010647a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010647d:	e8 f8 dd ff ff       	call   8010427a <myproc>
80106482:	8b 40 10             	mov    0x10(%eax),%eax
}
80106485:	c9                   	leave  
80106486:	c3                   	ret    

80106487 <sys_sbrk>:

int
sys_sbrk(void)
{
80106487:	55                   	push   %ebp
80106488:	89 e5                	mov    %esp,%ebp
8010648a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010648d:	83 ec 08             	sub    $0x8,%esp
80106490:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106493:	50                   	push   %eax
80106494:	6a 00                	push   $0x0
80106496:	e8 44 f0 ff ff       	call   801054df <argint>
8010649b:	83 c4 10             	add    $0x10,%esp
8010649e:	85 c0                	test   %eax,%eax
801064a0:	79 07                	jns    801064a9 <sys_sbrk+0x22>
    return -1;
801064a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a7:	eb 27                	jmp    801064d0 <sys_sbrk+0x49>
  addr = myproc()->sz;
801064a9:	e8 cc dd ff ff       	call   8010427a <myproc>
801064ae:	8b 00                	mov    (%eax),%eax
801064b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b6:	83 ec 0c             	sub    $0xc,%esp
801064b9:	50                   	push   %eax
801064ba:	e8 25 e0 ff ff       	call   801044e4 <growproc>
801064bf:	83 c4 10             	add    $0x10,%esp
801064c2:	85 c0                	test   %eax,%eax
801064c4:	79 07                	jns    801064cd <sys_sbrk+0x46>
    return -1;
801064c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cb:	eb 03                	jmp    801064d0 <sys_sbrk+0x49>
  return addr;
801064cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064d0:	c9                   	leave  
801064d1:	c3                   	ret    

801064d2 <sys_sleep>:

int
sys_sleep(void)
{
801064d2:	55                   	push   %ebp
801064d3:	89 e5                	mov    %esp,%ebp
801064d5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801064d8:	83 ec 08             	sub    $0x8,%esp
801064db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064de:	50                   	push   %eax
801064df:	6a 00                	push   $0x0
801064e1:	e8 f9 ef ff ff       	call   801054df <argint>
801064e6:	83 c4 10             	add    $0x10,%esp
801064e9:	85 c0                	test   %eax,%eax
801064eb:	79 07                	jns    801064f4 <sys_sleep+0x22>
    return -1;
801064ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f2:	eb 76                	jmp    8010656a <sys_sleep+0x98>
  acquire(&tickslock);
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	68 e0 5d 11 80       	push   $0x80115de0
801064fc:	e8 51 ea ff ff       	call   80104f52 <acquire>
80106501:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106504:	a1 20 66 11 80       	mov    0x80116620,%eax
80106509:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010650c:	eb 38                	jmp    80106546 <sys_sleep+0x74>
    if(myproc()->killed){
8010650e:	e8 67 dd ff ff       	call   8010427a <myproc>
80106513:	8b 40 24             	mov    0x24(%eax),%eax
80106516:	85 c0                	test   %eax,%eax
80106518:	74 17                	je     80106531 <sys_sleep+0x5f>
      release(&tickslock);
8010651a:	83 ec 0c             	sub    $0xc,%esp
8010651d:	68 e0 5d 11 80       	push   $0x80115de0
80106522:	e8 99 ea ff ff       	call   80104fc0 <release>
80106527:	83 c4 10             	add    $0x10,%esp
      return -1;
8010652a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652f:	eb 39                	jmp    8010656a <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106531:	83 ec 08             	sub    $0x8,%esp
80106534:	68 e0 5d 11 80       	push   $0x80115de0
80106539:	68 20 66 11 80       	push   $0x80116620
8010653e:	e8 f6 e5 ff ff       	call   80104b39 <sleep>
80106543:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106546:	a1 20 66 11 80       	mov    0x80116620,%eax
8010654b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010654e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106551:	39 d0                	cmp    %edx,%eax
80106553:	72 b9                	jb     8010650e <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106555:	83 ec 0c             	sub    $0xc,%esp
80106558:	68 e0 5d 11 80       	push   $0x80115de0
8010655d:	e8 5e ea ff ff       	call   80104fc0 <release>
80106562:	83 c4 10             	add    $0x10,%esp
  return 0;
80106565:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010656a:	c9                   	leave  
8010656b:	c3                   	ret    

8010656c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010656c:	55                   	push   %ebp
8010656d:	89 e5                	mov    %esp,%ebp
8010656f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106572:	83 ec 0c             	sub    $0xc,%esp
80106575:	68 e0 5d 11 80       	push   $0x80115de0
8010657a:	e8 d3 e9 ff ff       	call   80104f52 <acquire>
8010657f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106582:	a1 20 66 11 80       	mov    0x80116620,%eax
80106587:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010658a:	83 ec 0c             	sub    $0xc,%esp
8010658d:	68 e0 5d 11 80       	push   $0x80115de0
80106592:	e8 29 ea ff ff       	call   80104fc0 <release>
80106597:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010659a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010659d:	c9                   	leave  
8010659e:	c3                   	ret    

8010659f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010659f:	1e                   	push   %ds
  pushl %es
801065a0:	06                   	push   %es
  pushl %fs
801065a1:	0f a0                	push   %fs
  pushl %gs
801065a3:	0f a8                	push   %gs
  pushal
801065a5:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801065a6:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801065aa:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801065ac:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801065ae:	54                   	push   %esp
  call trap
801065af:	e8 d7 01 00 00       	call   8010678b <trap>
  addl $4, %esp
801065b4:	83 c4 04             	add    $0x4,%esp

801065b7 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801065b7:	61                   	popa   
  popl %gs
801065b8:	0f a9                	pop    %gs
  popl %fs
801065ba:	0f a1                	pop    %fs
  popl %es
801065bc:	07                   	pop    %es
  popl %ds
801065bd:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801065be:	83 c4 08             	add    $0x8,%esp
  iret
801065c1:	cf                   	iret   

801065c2 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801065c2:	55                   	push   %ebp
801065c3:	89 e5                	mov    %esp,%ebp
801065c5:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801065c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801065cb:	83 e8 01             	sub    $0x1,%eax
801065ce:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801065d2:	8b 45 08             	mov    0x8(%ebp),%eax
801065d5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801065d9:	8b 45 08             	mov    0x8(%ebp),%eax
801065dc:	c1 e8 10             	shr    $0x10,%eax
801065df:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801065e3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801065e6:	0f 01 18             	lidtl  (%eax)
}
801065e9:	90                   	nop
801065ea:	c9                   	leave  
801065eb:	c3                   	ret    

801065ec <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801065ec:	55                   	push   %ebp
801065ed:	89 e5                	mov    %esp,%ebp
801065ef:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801065f2:	0f 20 d0             	mov    %cr2,%eax
801065f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801065f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801065fb:	c9                   	leave  
801065fc:	c3                   	ret    

801065fd <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801065fd:	55                   	push   %ebp
801065fe:	89 e5                	mov    %esp,%ebp
80106600:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106603:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010660a:	e9 c3 00 00 00       	jmp    801066d2 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010660f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106612:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106619:	89 c2                	mov    %eax,%edx
8010661b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661e:	66 89 14 c5 20 5e 11 	mov    %dx,-0x7feea1e0(,%eax,8)
80106625:	80 
80106626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106629:	66 c7 04 c5 22 5e 11 	movw   $0x8,-0x7feea1de(,%eax,8)
80106630:	80 08 00 
80106633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106636:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
8010663d:	80 
8010663e:	83 e2 e0             	and    $0xffffffe0,%edx
80106641:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664b:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106652:	80 
80106653:	83 e2 1f             	and    $0x1f,%edx
80106656:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
8010665d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106660:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106667:	80 
80106668:	83 e2 f0             	and    $0xfffffff0,%edx
8010666b:	83 ca 0e             	or     $0xe,%edx
8010666e:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106678:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
8010667f:	80 
80106680:	83 e2 ef             	and    $0xffffffef,%edx
80106683:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
8010668a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668d:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106694:	80 
80106695:	83 e2 9f             	and    $0xffffff9f,%edx
80106698:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
8010669f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a2:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
801066a9:	80 
801066aa:	83 ca 80             	or     $0xffffff80,%edx
801066ad:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
801066b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b7:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
801066be:	c1 e8 10             	shr    $0x10,%eax
801066c1:	89 c2                	mov    %eax,%edx
801066c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c6:	66 89 14 c5 26 5e 11 	mov    %dx,-0x7feea1da(,%eax,8)
801066cd:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801066ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066d2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801066d9:	0f 8e 30 ff ff ff    	jle    8010660f <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801066df:	a1 80 b1 10 80       	mov    0x8010b180,%eax
801066e4:	66 a3 20 60 11 80    	mov    %ax,0x80116020
801066ea:	66 c7 05 22 60 11 80 	movw   $0x8,0x80116022
801066f1:	08 00 
801066f3:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
801066fa:	83 e0 e0             	and    $0xffffffe0,%eax
801066fd:	a2 24 60 11 80       	mov    %al,0x80116024
80106702:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
80106709:	83 e0 1f             	and    $0x1f,%eax
8010670c:	a2 24 60 11 80       	mov    %al,0x80116024
80106711:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106718:	83 c8 0f             	or     $0xf,%eax
8010671b:	a2 25 60 11 80       	mov    %al,0x80116025
80106720:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106727:	83 e0 ef             	and    $0xffffffef,%eax
8010672a:	a2 25 60 11 80       	mov    %al,0x80116025
8010672f:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106736:	83 c8 60             	or     $0x60,%eax
80106739:	a2 25 60 11 80       	mov    %al,0x80116025
8010673e:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106745:	83 c8 80             	or     $0xffffff80,%eax
80106748:	a2 25 60 11 80       	mov    %al,0x80116025
8010674d:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106752:	c1 e8 10             	shr    $0x10,%eax
80106755:	66 a3 26 60 11 80    	mov    %ax,0x80116026

  initlock(&tickslock, "time");
8010675b:	83 ec 08             	sub    $0x8,%esp
8010675e:	68 8c 8a 10 80       	push   $0x80108a8c
80106763:	68 e0 5d 11 80       	push   $0x80115de0
80106768:	e8 c3 e7 ff ff       	call   80104f30 <initlock>
8010676d:	83 c4 10             	add    $0x10,%esp
}
80106770:	90                   	nop
80106771:	c9                   	leave  
80106772:	c3                   	ret    

80106773 <idtinit>:

void
idtinit(void)
{
80106773:	55                   	push   %ebp
80106774:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106776:	68 00 08 00 00       	push   $0x800
8010677b:	68 20 5e 11 80       	push   $0x80115e20
80106780:	e8 3d fe ff ff       	call   801065c2 <lidt>
80106785:	83 c4 08             	add    $0x8,%esp
}
80106788:	90                   	nop
80106789:	c9                   	leave  
8010678a:	c3                   	ret    

8010678b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010678b:	55                   	push   %ebp
8010678c:	89 e5                	mov    %esp,%ebp
8010678e:	57                   	push   %edi
8010678f:	56                   	push   %esi
80106790:	53                   	push   %ebx
80106791:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106794:	8b 45 08             	mov    0x8(%ebp),%eax
80106797:	8b 40 30             	mov    0x30(%eax),%eax
8010679a:	83 f8 40             	cmp    $0x40,%eax
8010679d:	75 3d                	jne    801067dc <trap+0x51>
    if(myproc()->killed)
8010679f:	e8 d6 da ff ff       	call   8010427a <myproc>
801067a4:	8b 40 24             	mov    0x24(%eax),%eax
801067a7:	85 c0                	test   %eax,%eax
801067a9:	74 05                	je     801067b0 <trap+0x25>
      exit();
801067ab:	e8 56 df ff ff       	call   80104706 <exit>
    myproc()->tf = tf;
801067b0:	e8 c5 da ff ff       	call   8010427a <myproc>
801067b5:	89 c2                	mov    %eax,%edx
801067b7:	8b 45 08             	mov    0x8(%ebp),%eax
801067ba:	89 42 18             	mov    %eax,0x18(%edx)
    syscall();
801067bd:	e8 d7 ed ff ff       	call   80105599 <syscall>
    if(myproc()->killed)
801067c2:	e8 b3 da ff ff       	call   8010427a <myproc>
801067c7:	8b 40 24             	mov    0x24(%eax),%eax
801067ca:	85 c0                	test   %eax,%eax
801067cc:	0f 84 ca 02 00 00    	je     80106a9c <trap+0x311>
      exit();
801067d2:	e8 2f df ff ff       	call   80104706 <exit>
    return;
801067d7:	e9 c0 02 00 00       	jmp    80106a9c <trap+0x311>
  }

  switch(tf->trapno){
801067dc:	8b 45 08             	mov    0x8(%ebp),%eax
801067df:	8b 40 30             	mov    0x30(%eax),%eax
801067e2:	83 e8 0e             	sub    $0xe,%eax
801067e5:	83 f8 31             	cmp    $0x31,%eax
801067e8:	0f 87 78 01 00 00    	ja     80106966 <trap+0x1db>
801067ee:	8b 04 85 6c 8b 10 80 	mov    -0x7fef7494(,%eax,4),%eax
801067f5:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801067f7:	e8 e5 d9 ff ff       	call   801041e1 <cpuid>
801067fc:	85 c0                	test   %eax,%eax
801067fe:	75 3d                	jne    8010683d <trap+0xb2>
      acquire(&tickslock);
80106800:	83 ec 0c             	sub    $0xc,%esp
80106803:	68 e0 5d 11 80       	push   $0x80115de0
80106808:	e8 45 e7 ff ff       	call   80104f52 <acquire>
8010680d:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106810:	a1 20 66 11 80       	mov    0x80116620,%eax
80106815:	83 c0 01             	add    $0x1,%eax
80106818:	a3 20 66 11 80       	mov    %eax,0x80116620
      wakeup(&ticks);
8010681d:	83 ec 0c             	sub    $0xc,%esp
80106820:	68 20 66 11 80       	push   $0x80116620
80106825:	e8 f5 e3 ff ff       	call   80104c1f <wakeup>
8010682a:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010682d:	83 ec 0c             	sub    $0xc,%esp
80106830:	68 e0 5d 11 80       	push   $0x80115de0
80106835:	e8 86 e7 ff ff       	call   80104fc0 <release>
8010683a:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010683d:	e8 b8 c7 ff ff       	call   80102ffa <lapiceoi>
    break;
80106842:	e9 d5 01 00 00       	jmp    80106a1c <trap+0x291>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106847:	e8 28 c0 ff ff       	call   80102874 <ideintr>
    lapiceoi();
8010684c:	e8 a9 c7 ff ff       	call   80102ffa <lapiceoi>
    break;
80106851:	e9 c6 01 00 00       	jmp    80106a1c <trap+0x291>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106856:	e8 e8 c5 ff ff       	call   80102e43 <kbdintr>
    lapiceoi();
8010685b:	e8 9a c7 ff ff       	call   80102ffa <lapiceoi>
    break;
80106860:	e9 b7 01 00 00       	jmp    80106a1c <trap+0x291>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106865:	e8 06 04 00 00       	call   80106c70 <uartintr>
    lapiceoi();
8010686a:	e8 8b c7 ff ff       	call   80102ffa <lapiceoi>
    break;
8010686f:	e9 a8 01 00 00       	jmp    80106a1c <trap+0x291>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106874:	8b 45 08             	mov    0x8(%ebp),%eax
80106877:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010687a:	8b 45 08             	mov    0x8(%ebp),%eax
8010687d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106881:	0f b7 d8             	movzwl %ax,%ebx
80106884:	e8 58 d9 ff ff       	call   801041e1 <cpuid>
80106889:	56                   	push   %esi
8010688a:	53                   	push   %ebx
8010688b:	50                   	push   %eax
8010688c:	68 94 8a 10 80       	push   $0x80108a94
80106891:	e8 6a 9b ff ff       	call   80100400 <cprintf>
80106896:	83 c4 10             	add    $0x10,%esp
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106899:	e8 5c c7 ff ff       	call   80102ffa <lapiceoi>
    break;
8010689e:	e9 79 01 00 00       	jmp    80106a1c <trap+0x291>
  case T_PGFLT: ;
    cprintf("attempting to grow stack\n");
801068a3:	83 ec 0c             	sub    $0xc,%esp
801068a6:	68 b8 8a 10 80       	push   $0x80108ab8
801068ab:	e8 50 9b ff ff       	call   80100400 <cprintf>
801068b0:	83 c4 10             	add    $0x10,%esp
    uint addr = rcr2();
801068b3:	e8 34 fd ff ff       	call   801065ec <rcr2>
801068b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    uint sp = myproc()->tf->esp;
801068bb:	e8 ba d9 ff ff       	call   8010427a <myproc>
801068c0:	8b 40 18             	mov    0x18(%eax),%eax
801068c3:	8b 40 44             	mov    0x44(%eax),%eax
801068c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    //check if the fault occurs from the page right under the bottom of the stack
    //if so we need to grow the stack
    if(addr > PGROUNDDOWN(sp) - PGSIZE && addr < PGROUNDDOWN(sp)){
801068c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068d1:	2d 00 10 00 00       	sub    $0x1000,%eax
801068d6:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801068d9:	0f 83 3c 01 00 00    	jae    80106a1b <trap+0x290>
801068df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068e7:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801068ea:	0f 86 2b 01 00 00    	jbe    80106a1b <trap+0x290>
	pde_t *pgdir;
	pgdir = 0;
801068f0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    cprintf("going to allocate\n");
801068f7:	83 ec 0c             	sub    $0xc,%esp
801068fa:	68 d2 8a 10 80       	push   $0x80108ad2
801068ff:	e8 fc 9a ff ff       	call   80100400 <cprintf>
80106904:	83 c4 10             	add    $0x10,%esp
	if(allocuvm(pgdir ,PGROUNDDOWN(sp) - PGSIZE, PGROUNDDOWN(sp)) == 0){
80106907:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010690a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010690f:	89 c2                	mov    %eax,%edx
80106911:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106914:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106919:	2d 00 10 00 00       	sub    $0x1000,%eax
8010691e:	83 ec 04             	sub    $0x4,%esp
80106921:	52                   	push   %edx
80106922:	50                   	push   %eax
80106923:	ff 75 dc             	pushl  -0x24(%ebp)
80106926:	e8 3e 16 00 00       	call   80107f69 <allocuvm>
8010692b:	83 c4 10             	add    $0x10,%esp
8010692e:	85 c0                	test   %eax,%eax
80106930:	75 0d                	jne    8010693f <trap+0x1b4>
		panic("fucked up");
80106932:	83 ec 0c             	sub    $0xc,%esp
80106935:	68 e5 8a 10 80       	push   $0x80108ae5
8010693a:	e8 61 9c ff ff       	call   801005a0 <panic>
	}
   	myproc()->stack_pages +=1;
8010693f:	e8 36 d9 ff ff       	call   8010427a <myproc>
80106944:	8b 50 7c             	mov    0x7c(%eax),%edx
80106947:	83 c2 01             	add    $0x1,%edx
8010694a:	89 50 7c             	mov    %edx,0x7c(%eax)
	myproc()->tf->esp = PGROUNDDOWN(sp);
8010694d:	e8 28 d9 ff ff       	call   8010427a <myproc>
80106952:	8b 40 18             	mov    0x18(%eax),%eax
80106955:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106958:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010695e:	89 50 44             	mov    %edx,0x44(%eax)
    }
    
    break;
80106961:	e9 b5 00 00 00       	jmp    80106a1b <trap+0x290>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106966:	e8 0f d9 ff ff       	call   8010427a <myproc>
8010696b:	85 c0                	test   %eax,%eax
8010696d:	74 11                	je     80106980 <trap+0x1f5>
8010696f:	8b 45 08             	mov    0x8(%ebp),%eax
80106972:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106976:	0f b7 c0             	movzwl %ax,%eax
80106979:	83 e0 03             	and    $0x3,%eax
8010697c:	85 c0                	test   %eax,%eax
8010697e:	75 3b                	jne    801069bb <trap+0x230>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106980:	e8 67 fc ff ff       	call   801065ec <rcr2>
80106985:	89 c6                	mov    %eax,%esi
80106987:	8b 45 08             	mov    0x8(%ebp),%eax
8010698a:	8b 58 38             	mov    0x38(%eax),%ebx
8010698d:	e8 4f d8 ff ff       	call   801041e1 <cpuid>
80106992:	89 c2                	mov    %eax,%edx
80106994:	8b 45 08             	mov    0x8(%ebp),%eax
80106997:	8b 40 30             	mov    0x30(%eax),%eax
8010699a:	83 ec 0c             	sub    $0xc,%esp
8010699d:	56                   	push   %esi
8010699e:	53                   	push   %ebx
8010699f:	52                   	push   %edx
801069a0:	50                   	push   %eax
801069a1:	68 f0 8a 10 80       	push   $0x80108af0
801069a6:	e8 55 9a ff ff       	call   80100400 <cprintf>
801069ab:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801069ae:	83 ec 0c             	sub    $0xc,%esp
801069b1:	68 22 8b 10 80       	push   $0x80108b22
801069b6:	e8 e5 9b ff ff       	call   801005a0 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069bb:	e8 2c fc ff ff       	call   801065ec <rcr2>
801069c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801069c3:	8b 45 08             	mov    0x8(%ebp),%eax
801069c6:	8b 78 38             	mov    0x38(%eax),%edi
801069c9:	e8 13 d8 ff ff       	call   801041e1 <cpuid>
801069ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
801069d1:	8b 45 08             	mov    0x8(%ebp),%eax
801069d4:	8b 70 34             	mov    0x34(%eax),%esi
801069d7:	8b 45 08             	mov    0x8(%ebp),%eax
801069da:	8b 58 30             	mov    0x30(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801069dd:	e8 98 d8 ff ff       	call   8010427a <myproc>
801069e2:	8d 48 6c             	lea    0x6c(%eax),%ecx
801069e5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
801069e8:	e8 8d d8 ff ff       	call   8010427a <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069ed:	8b 40 10             	mov    0x10(%eax),%eax
801069f0:	ff 75 d4             	pushl  -0x2c(%ebp)
801069f3:	57                   	push   %edi
801069f4:	ff 75 d0             	pushl  -0x30(%ebp)
801069f7:	56                   	push   %esi
801069f8:	53                   	push   %ebx
801069f9:	ff 75 cc             	pushl  -0x34(%ebp)
801069fc:	50                   	push   %eax
801069fd:	68 28 8b 10 80       	push   $0x80108b28
80106a02:	e8 f9 99 ff ff       	call   80100400 <cprintf>
80106a07:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106a0a:	e8 6b d8 ff ff       	call   8010427a <myproc>
80106a0f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a16:	eb 04                	jmp    80106a1c <trap+0x291>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a18:	90                   	nop
80106a19:	eb 01                	jmp    80106a1c <trap+0x291>
	}
   	myproc()->stack_pages +=1;
	myproc()->tf->esp = PGROUNDDOWN(sp);
    }
    
    break;
80106a1b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a1c:	e8 59 d8 ff ff       	call   8010427a <myproc>
80106a21:	85 c0                	test   %eax,%eax
80106a23:	74 23                	je     80106a48 <trap+0x2bd>
80106a25:	e8 50 d8 ff ff       	call   8010427a <myproc>
80106a2a:	8b 40 24             	mov    0x24(%eax),%eax
80106a2d:	85 c0                	test   %eax,%eax
80106a2f:	74 17                	je     80106a48 <trap+0x2bd>
80106a31:	8b 45 08             	mov    0x8(%ebp),%eax
80106a34:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a38:	0f b7 c0             	movzwl %ax,%eax
80106a3b:	83 e0 03             	and    $0x3,%eax
80106a3e:	83 f8 03             	cmp    $0x3,%eax
80106a41:	75 05                	jne    80106a48 <trap+0x2bd>
    exit();
80106a43:	e8 be dc ff ff       	call   80104706 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a48:	e8 2d d8 ff ff       	call   8010427a <myproc>
80106a4d:	85 c0                	test   %eax,%eax
80106a4f:	74 1d                	je     80106a6e <trap+0x2e3>
80106a51:	e8 24 d8 ff ff       	call   8010427a <myproc>
80106a56:	8b 40 0c             	mov    0xc(%eax),%eax
80106a59:	83 f8 04             	cmp    $0x4,%eax
80106a5c:	75 10                	jne    80106a6e <trap+0x2e3>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a61:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a64:	83 f8 20             	cmp    $0x20,%eax
80106a67:	75 05                	jne    80106a6e <trap+0x2e3>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106a69:	e8 4b e0 ff ff       	call   80104ab9 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a6e:	e8 07 d8 ff ff       	call   8010427a <myproc>
80106a73:	85 c0                	test   %eax,%eax
80106a75:	74 26                	je     80106a9d <trap+0x312>
80106a77:	e8 fe d7 ff ff       	call   8010427a <myproc>
80106a7c:	8b 40 24             	mov    0x24(%eax),%eax
80106a7f:	85 c0                	test   %eax,%eax
80106a81:	74 1a                	je     80106a9d <trap+0x312>
80106a83:	8b 45 08             	mov    0x8(%ebp),%eax
80106a86:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a8a:	0f b7 c0             	movzwl %ax,%eax
80106a8d:	83 e0 03             	and    $0x3,%eax
80106a90:	83 f8 03             	cmp    $0x3,%eax
80106a93:	75 08                	jne    80106a9d <trap+0x312>
    exit();
80106a95:	e8 6c dc ff ff       	call   80104706 <exit>
80106a9a:	eb 01                	jmp    80106a9d <trap+0x312>
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
80106a9c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106aa0:	5b                   	pop    %ebx
80106aa1:	5e                   	pop    %esi
80106aa2:	5f                   	pop    %edi
80106aa3:	5d                   	pop    %ebp
80106aa4:	c3                   	ret    

80106aa5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106aa5:	55                   	push   %ebp
80106aa6:	89 e5                	mov    %esp,%ebp
80106aa8:	83 ec 14             	sub    $0x14,%esp
80106aab:	8b 45 08             	mov    0x8(%ebp),%eax
80106aae:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ab2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106ab6:	89 c2                	mov    %eax,%edx
80106ab8:	ec                   	in     (%dx),%al
80106ab9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106abc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ac0:	c9                   	leave  
80106ac1:	c3                   	ret    

80106ac2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106ac2:	55                   	push   %ebp
80106ac3:	89 e5                	mov    %esp,%ebp
80106ac5:	83 ec 08             	sub    $0x8,%esp
80106ac8:	8b 55 08             	mov    0x8(%ebp),%edx
80106acb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ace:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106ad2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ad5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ad9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106add:	ee                   	out    %al,(%dx)
}
80106ade:	90                   	nop
80106adf:	c9                   	leave  
80106ae0:	c3                   	ret    

80106ae1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ae1:	55                   	push   %ebp
80106ae2:	89 e5                	mov    %esp,%ebp
80106ae4:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ae7:	6a 00                	push   $0x0
80106ae9:	68 fa 03 00 00       	push   $0x3fa
80106aee:	e8 cf ff ff ff       	call   80106ac2 <outb>
80106af3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106af6:	68 80 00 00 00       	push   $0x80
80106afb:	68 fb 03 00 00       	push   $0x3fb
80106b00:	e8 bd ff ff ff       	call   80106ac2 <outb>
80106b05:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b08:	6a 0c                	push   $0xc
80106b0a:	68 f8 03 00 00       	push   $0x3f8
80106b0f:	e8 ae ff ff ff       	call   80106ac2 <outb>
80106b14:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b17:	6a 00                	push   $0x0
80106b19:	68 f9 03 00 00       	push   $0x3f9
80106b1e:	e8 9f ff ff ff       	call   80106ac2 <outb>
80106b23:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b26:	6a 03                	push   $0x3
80106b28:	68 fb 03 00 00       	push   $0x3fb
80106b2d:	e8 90 ff ff ff       	call   80106ac2 <outb>
80106b32:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b35:	6a 00                	push   $0x0
80106b37:	68 fc 03 00 00       	push   $0x3fc
80106b3c:	e8 81 ff ff ff       	call   80106ac2 <outb>
80106b41:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b44:	6a 01                	push   $0x1
80106b46:	68 f9 03 00 00       	push   $0x3f9
80106b4b:	e8 72 ff ff ff       	call   80106ac2 <outb>
80106b50:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b53:	68 fd 03 00 00       	push   $0x3fd
80106b58:	e8 48 ff ff ff       	call   80106aa5 <inb>
80106b5d:	83 c4 04             	add    $0x4,%esp
80106b60:	3c ff                	cmp    $0xff,%al
80106b62:	74 61                	je     80106bc5 <uartinit+0xe4>
    return;
  uart = 1;
80106b64:	c7 05 24 b6 10 80 01 	movl   $0x1,0x8010b624
80106b6b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b6e:	68 fa 03 00 00       	push   $0x3fa
80106b73:	e8 2d ff ff ff       	call   80106aa5 <inb>
80106b78:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b7b:	68 f8 03 00 00       	push   $0x3f8
80106b80:	e8 20 ff ff ff       	call   80106aa5 <inb>
80106b85:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106b88:	83 ec 08             	sub    $0x8,%esp
80106b8b:	6a 00                	push   $0x0
80106b8d:	6a 04                	push   $0x4
80106b8f:	e8 7d bf ff ff       	call   80102b11 <ioapicenable>
80106b94:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b97:	c7 45 f4 34 8c 10 80 	movl   $0x80108c34,-0xc(%ebp)
80106b9e:	eb 19                	jmp    80106bb9 <uartinit+0xd8>
    uartputc(*p);
80106ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba3:	0f b6 00             	movzbl (%eax),%eax
80106ba6:	0f be c0             	movsbl %al,%eax
80106ba9:	83 ec 0c             	sub    $0xc,%esp
80106bac:	50                   	push   %eax
80106bad:	e8 16 00 00 00       	call   80106bc8 <uartputc>
80106bb2:	83 c4 10             	add    $0x10,%esp
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bbc:	0f b6 00             	movzbl (%eax),%eax
80106bbf:	84 c0                	test   %al,%al
80106bc1:	75 dd                	jne    80106ba0 <uartinit+0xbf>
80106bc3:	eb 01                	jmp    80106bc6 <uartinit+0xe5>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106bc5:	90                   	nop
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106bc6:	c9                   	leave  
80106bc7:	c3                   	ret    

80106bc8 <uartputc>:

void
uartputc(int c)
{
80106bc8:	55                   	push   %ebp
80106bc9:	89 e5                	mov    %esp,%ebp
80106bcb:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106bce:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106bd3:	85 c0                	test   %eax,%eax
80106bd5:	74 53                	je     80106c2a <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106bde:	eb 11                	jmp    80106bf1 <uartputc+0x29>
    microdelay(10);
80106be0:	83 ec 0c             	sub    $0xc,%esp
80106be3:	6a 0a                	push   $0xa
80106be5:	e8 2b c4 ff ff       	call   80103015 <microdelay>
80106bea:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106bf1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106bf5:	7f 1a                	jg     80106c11 <uartputc+0x49>
80106bf7:	83 ec 0c             	sub    $0xc,%esp
80106bfa:	68 fd 03 00 00       	push   $0x3fd
80106bff:	e8 a1 fe ff ff       	call   80106aa5 <inb>
80106c04:	83 c4 10             	add    $0x10,%esp
80106c07:	0f b6 c0             	movzbl %al,%eax
80106c0a:	83 e0 20             	and    $0x20,%eax
80106c0d:	85 c0                	test   %eax,%eax
80106c0f:	74 cf                	je     80106be0 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106c11:	8b 45 08             	mov    0x8(%ebp),%eax
80106c14:	0f b6 c0             	movzbl %al,%eax
80106c17:	83 ec 08             	sub    $0x8,%esp
80106c1a:	50                   	push   %eax
80106c1b:	68 f8 03 00 00       	push   $0x3f8
80106c20:	e8 9d fe ff ff       	call   80106ac2 <outb>
80106c25:	83 c4 10             	add    $0x10,%esp
80106c28:	eb 01                	jmp    80106c2b <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106c2a:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106c2b:	c9                   	leave  
80106c2c:	c3                   	ret    

80106c2d <uartgetc>:

static int
uartgetc(void)
{
80106c2d:	55                   	push   %ebp
80106c2e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c30:	a1 24 b6 10 80       	mov    0x8010b624,%eax
80106c35:	85 c0                	test   %eax,%eax
80106c37:	75 07                	jne    80106c40 <uartgetc+0x13>
    return -1;
80106c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c3e:	eb 2e                	jmp    80106c6e <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c40:	68 fd 03 00 00       	push   $0x3fd
80106c45:	e8 5b fe ff ff       	call   80106aa5 <inb>
80106c4a:	83 c4 04             	add    $0x4,%esp
80106c4d:	0f b6 c0             	movzbl %al,%eax
80106c50:	83 e0 01             	and    $0x1,%eax
80106c53:	85 c0                	test   %eax,%eax
80106c55:	75 07                	jne    80106c5e <uartgetc+0x31>
    return -1;
80106c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5c:	eb 10                	jmp    80106c6e <uartgetc+0x41>
  return inb(COM1+0);
80106c5e:	68 f8 03 00 00       	push   $0x3f8
80106c63:	e8 3d fe ff ff       	call   80106aa5 <inb>
80106c68:	83 c4 04             	add    $0x4,%esp
80106c6b:	0f b6 c0             	movzbl %al,%eax
}
80106c6e:	c9                   	leave  
80106c6f:	c3                   	ret    

80106c70 <uartintr>:

void
uartintr(void)
{
80106c70:	55                   	push   %ebp
80106c71:	89 e5                	mov    %esp,%ebp
80106c73:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c76:	83 ec 0c             	sub    $0xc,%esp
80106c79:	68 2d 6c 10 80       	push   $0x80106c2d
80106c7e:	e8 a9 9b ff ff       	call   8010082c <consoleintr>
80106c83:	83 c4 10             	add    $0x10,%esp
}
80106c86:	90                   	nop
80106c87:	c9                   	leave  
80106c88:	c3                   	ret    

80106c89 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c89:	6a 00                	push   $0x0
  pushl $0
80106c8b:	6a 00                	push   $0x0
  jmp alltraps
80106c8d:	e9 0d f9 ff ff       	jmp    8010659f <alltraps>

80106c92 <vector1>:
.globl vector1
vector1:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $1
80106c94:	6a 01                	push   $0x1
  jmp alltraps
80106c96:	e9 04 f9 ff ff       	jmp    8010659f <alltraps>

80106c9b <vector2>:
.globl vector2
vector2:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $2
80106c9d:	6a 02                	push   $0x2
  jmp alltraps
80106c9f:	e9 fb f8 ff ff       	jmp    8010659f <alltraps>

80106ca4 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ca4:	6a 00                	push   $0x0
  pushl $3
80106ca6:	6a 03                	push   $0x3
  jmp alltraps
80106ca8:	e9 f2 f8 ff ff       	jmp    8010659f <alltraps>

80106cad <vector4>:
.globl vector4
vector4:
  pushl $0
80106cad:	6a 00                	push   $0x0
  pushl $4
80106caf:	6a 04                	push   $0x4
  jmp alltraps
80106cb1:	e9 e9 f8 ff ff       	jmp    8010659f <alltraps>

80106cb6 <vector5>:
.globl vector5
vector5:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $5
80106cb8:	6a 05                	push   $0x5
  jmp alltraps
80106cba:	e9 e0 f8 ff ff       	jmp    8010659f <alltraps>

80106cbf <vector6>:
.globl vector6
vector6:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $6
80106cc1:	6a 06                	push   $0x6
  jmp alltraps
80106cc3:	e9 d7 f8 ff ff       	jmp    8010659f <alltraps>

80106cc8 <vector7>:
.globl vector7
vector7:
  pushl $0
80106cc8:	6a 00                	push   $0x0
  pushl $7
80106cca:	6a 07                	push   $0x7
  jmp alltraps
80106ccc:	e9 ce f8 ff ff       	jmp    8010659f <alltraps>

80106cd1 <vector8>:
.globl vector8
vector8:
  pushl $8
80106cd1:	6a 08                	push   $0x8
  jmp alltraps
80106cd3:	e9 c7 f8 ff ff       	jmp    8010659f <alltraps>

80106cd8 <vector9>:
.globl vector9
vector9:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $9
80106cda:	6a 09                	push   $0x9
  jmp alltraps
80106cdc:	e9 be f8 ff ff       	jmp    8010659f <alltraps>

80106ce1 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ce1:	6a 0a                	push   $0xa
  jmp alltraps
80106ce3:	e9 b7 f8 ff ff       	jmp    8010659f <alltraps>

80106ce8 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ce8:	6a 0b                	push   $0xb
  jmp alltraps
80106cea:	e9 b0 f8 ff ff       	jmp    8010659f <alltraps>

80106cef <vector12>:
.globl vector12
vector12:
  pushl $12
80106cef:	6a 0c                	push   $0xc
  jmp alltraps
80106cf1:	e9 a9 f8 ff ff       	jmp    8010659f <alltraps>

80106cf6 <vector13>:
.globl vector13
vector13:
  pushl $13
80106cf6:	6a 0d                	push   $0xd
  jmp alltraps
80106cf8:	e9 a2 f8 ff ff       	jmp    8010659f <alltraps>

80106cfd <vector14>:
.globl vector14
vector14:
  pushl $14
80106cfd:	6a 0e                	push   $0xe
  jmp alltraps
80106cff:	e9 9b f8 ff ff       	jmp    8010659f <alltraps>

80106d04 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d04:	6a 00                	push   $0x0
  pushl $15
80106d06:	6a 0f                	push   $0xf
  jmp alltraps
80106d08:	e9 92 f8 ff ff       	jmp    8010659f <alltraps>

80106d0d <vector16>:
.globl vector16
vector16:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $16
80106d0f:	6a 10                	push   $0x10
  jmp alltraps
80106d11:	e9 89 f8 ff ff       	jmp    8010659f <alltraps>

80106d16 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d16:	6a 11                	push   $0x11
  jmp alltraps
80106d18:	e9 82 f8 ff ff       	jmp    8010659f <alltraps>

80106d1d <vector18>:
.globl vector18
vector18:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $18
80106d1f:	6a 12                	push   $0x12
  jmp alltraps
80106d21:	e9 79 f8 ff ff       	jmp    8010659f <alltraps>

80106d26 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $19
80106d28:	6a 13                	push   $0x13
  jmp alltraps
80106d2a:	e9 70 f8 ff ff       	jmp    8010659f <alltraps>

80106d2f <vector20>:
.globl vector20
vector20:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $20
80106d31:	6a 14                	push   $0x14
  jmp alltraps
80106d33:	e9 67 f8 ff ff       	jmp    8010659f <alltraps>

80106d38 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $21
80106d3a:	6a 15                	push   $0x15
  jmp alltraps
80106d3c:	e9 5e f8 ff ff       	jmp    8010659f <alltraps>

80106d41 <vector22>:
.globl vector22
vector22:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $22
80106d43:	6a 16                	push   $0x16
  jmp alltraps
80106d45:	e9 55 f8 ff ff       	jmp    8010659f <alltraps>

80106d4a <vector23>:
.globl vector23
vector23:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $23
80106d4c:	6a 17                	push   $0x17
  jmp alltraps
80106d4e:	e9 4c f8 ff ff       	jmp    8010659f <alltraps>

80106d53 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $24
80106d55:	6a 18                	push   $0x18
  jmp alltraps
80106d57:	e9 43 f8 ff ff       	jmp    8010659f <alltraps>

80106d5c <vector25>:
.globl vector25
vector25:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $25
80106d5e:	6a 19                	push   $0x19
  jmp alltraps
80106d60:	e9 3a f8 ff ff       	jmp    8010659f <alltraps>

80106d65 <vector26>:
.globl vector26
vector26:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $26
80106d67:	6a 1a                	push   $0x1a
  jmp alltraps
80106d69:	e9 31 f8 ff ff       	jmp    8010659f <alltraps>

80106d6e <vector27>:
.globl vector27
vector27:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $27
80106d70:	6a 1b                	push   $0x1b
  jmp alltraps
80106d72:	e9 28 f8 ff ff       	jmp    8010659f <alltraps>

80106d77 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $28
80106d79:	6a 1c                	push   $0x1c
  jmp alltraps
80106d7b:	e9 1f f8 ff ff       	jmp    8010659f <alltraps>

80106d80 <vector29>:
.globl vector29
vector29:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $29
80106d82:	6a 1d                	push   $0x1d
  jmp alltraps
80106d84:	e9 16 f8 ff ff       	jmp    8010659f <alltraps>

80106d89 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $30
80106d8b:	6a 1e                	push   $0x1e
  jmp alltraps
80106d8d:	e9 0d f8 ff ff       	jmp    8010659f <alltraps>

80106d92 <vector31>:
.globl vector31
vector31:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $31
80106d94:	6a 1f                	push   $0x1f
  jmp alltraps
80106d96:	e9 04 f8 ff ff       	jmp    8010659f <alltraps>

80106d9b <vector32>:
.globl vector32
vector32:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $32
80106d9d:	6a 20                	push   $0x20
  jmp alltraps
80106d9f:	e9 fb f7 ff ff       	jmp    8010659f <alltraps>

80106da4 <vector33>:
.globl vector33
vector33:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $33
80106da6:	6a 21                	push   $0x21
  jmp alltraps
80106da8:	e9 f2 f7 ff ff       	jmp    8010659f <alltraps>

80106dad <vector34>:
.globl vector34
vector34:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $34
80106daf:	6a 22                	push   $0x22
  jmp alltraps
80106db1:	e9 e9 f7 ff ff       	jmp    8010659f <alltraps>

80106db6 <vector35>:
.globl vector35
vector35:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $35
80106db8:	6a 23                	push   $0x23
  jmp alltraps
80106dba:	e9 e0 f7 ff ff       	jmp    8010659f <alltraps>

80106dbf <vector36>:
.globl vector36
vector36:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $36
80106dc1:	6a 24                	push   $0x24
  jmp alltraps
80106dc3:	e9 d7 f7 ff ff       	jmp    8010659f <alltraps>

80106dc8 <vector37>:
.globl vector37
vector37:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $37
80106dca:	6a 25                	push   $0x25
  jmp alltraps
80106dcc:	e9 ce f7 ff ff       	jmp    8010659f <alltraps>

80106dd1 <vector38>:
.globl vector38
vector38:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $38
80106dd3:	6a 26                	push   $0x26
  jmp alltraps
80106dd5:	e9 c5 f7 ff ff       	jmp    8010659f <alltraps>

80106dda <vector39>:
.globl vector39
vector39:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $39
80106ddc:	6a 27                	push   $0x27
  jmp alltraps
80106dde:	e9 bc f7 ff ff       	jmp    8010659f <alltraps>

80106de3 <vector40>:
.globl vector40
vector40:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $40
80106de5:	6a 28                	push   $0x28
  jmp alltraps
80106de7:	e9 b3 f7 ff ff       	jmp    8010659f <alltraps>

80106dec <vector41>:
.globl vector41
vector41:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $41
80106dee:	6a 29                	push   $0x29
  jmp alltraps
80106df0:	e9 aa f7 ff ff       	jmp    8010659f <alltraps>

80106df5 <vector42>:
.globl vector42
vector42:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $42
80106df7:	6a 2a                	push   $0x2a
  jmp alltraps
80106df9:	e9 a1 f7 ff ff       	jmp    8010659f <alltraps>

80106dfe <vector43>:
.globl vector43
vector43:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $43
80106e00:	6a 2b                	push   $0x2b
  jmp alltraps
80106e02:	e9 98 f7 ff ff       	jmp    8010659f <alltraps>

80106e07 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $44
80106e09:	6a 2c                	push   $0x2c
  jmp alltraps
80106e0b:	e9 8f f7 ff ff       	jmp    8010659f <alltraps>

80106e10 <vector45>:
.globl vector45
vector45:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $45
80106e12:	6a 2d                	push   $0x2d
  jmp alltraps
80106e14:	e9 86 f7 ff ff       	jmp    8010659f <alltraps>

80106e19 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $46
80106e1b:	6a 2e                	push   $0x2e
  jmp alltraps
80106e1d:	e9 7d f7 ff ff       	jmp    8010659f <alltraps>

80106e22 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $47
80106e24:	6a 2f                	push   $0x2f
  jmp alltraps
80106e26:	e9 74 f7 ff ff       	jmp    8010659f <alltraps>

80106e2b <vector48>:
.globl vector48
vector48:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $48
80106e2d:	6a 30                	push   $0x30
  jmp alltraps
80106e2f:	e9 6b f7 ff ff       	jmp    8010659f <alltraps>

80106e34 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $49
80106e36:	6a 31                	push   $0x31
  jmp alltraps
80106e38:	e9 62 f7 ff ff       	jmp    8010659f <alltraps>

80106e3d <vector50>:
.globl vector50
vector50:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $50
80106e3f:	6a 32                	push   $0x32
  jmp alltraps
80106e41:	e9 59 f7 ff ff       	jmp    8010659f <alltraps>

80106e46 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $51
80106e48:	6a 33                	push   $0x33
  jmp alltraps
80106e4a:	e9 50 f7 ff ff       	jmp    8010659f <alltraps>

80106e4f <vector52>:
.globl vector52
vector52:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $52
80106e51:	6a 34                	push   $0x34
  jmp alltraps
80106e53:	e9 47 f7 ff ff       	jmp    8010659f <alltraps>

80106e58 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $53
80106e5a:	6a 35                	push   $0x35
  jmp alltraps
80106e5c:	e9 3e f7 ff ff       	jmp    8010659f <alltraps>

80106e61 <vector54>:
.globl vector54
vector54:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $54
80106e63:	6a 36                	push   $0x36
  jmp alltraps
80106e65:	e9 35 f7 ff ff       	jmp    8010659f <alltraps>

80106e6a <vector55>:
.globl vector55
vector55:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $55
80106e6c:	6a 37                	push   $0x37
  jmp alltraps
80106e6e:	e9 2c f7 ff ff       	jmp    8010659f <alltraps>

80106e73 <vector56>:
.globl vector56
vector56:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $56
80106e75:	6a 38                	push   $0x38
  jmp alltraps
80106e77:	e9 23 f7 ff ff       	jmp    8010659f <alltraps>

80106e7c <vector57>:
.globl vector57
vector57:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $57
80106e7e:	6a 39                	push   $0x39
  jmp alltraps
80106e80:	e9 1a f7 ff ff       	jmp    8010659f <alltraps>

80106e85 <vector58>:
.globl vector58
vector58:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $58
80106e87:	6a 3a                	push   $0x3a
  jmp alltraps
80106e89:	e9 11 f7 ff ff       	jmp    8010659f <alltraps>

80106e8e <vector59>:
.globl vector59
vector59:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $59
80106e90:	6a 3b                	push   $0x3b
  jmp alltraps
80106e92:	e9 08 f7 ff ff       	jmp    8010659f <alltraps>

80106e97 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $60
80106e99:	6a 3c                	push   $0x3c
  jmp alltraps
80106e9b:	e9 ff f6 ff ff       	jmp    8010659f <alltraps>

80106ea0 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $61
80106ea2:	6a 3d                	push   $0x3d
  jmp alltraps
80106ea4:	e9 f6 f6 ff ff       	jmp    8010659f <alltraps>

80106ea9 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $62
80106eab:	6a 3e                	push   $0x3e
  jmp alltraps
80106ead:	e9 ed f6 ff ff       	jmp    8010659f <alltraps>

80106eb2 <vector63>:
.globl vector63
vector63:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $63
80106eb4:	6a 3f                	push   $0x3f
  jmp alltraps
80106eb6:	e9 e4 f6 ff ff       	jmp    8010659f <alltraps>

80106ebb <vector64>:
.globl vector64
vector64:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $64
80106ebd:	6a 40                	push   $0x40
  jmp alltraps
80106ebf:	e9 db f6 ff ff       	jmp    8010659f <alltraps>

80106ec4 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $65
80106ec6:	6a 41                	push   $0x41
  jmp alltraps
80106ec8:	e9 d2 f6 ff ff       	jmp    8010659f <alltraps>

80106ecd <vector66>:
.globl vector66
vector66:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $66
80106ecf:	6a 42                	push   $0x42
  jmp alltraps
80106ed1:	e9 c9 f6 ff ff       	jmp    8010659f <alltraps>

80106ed6 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $67
80106ed8:	6a 43                	push   $0x43
  jmp alltraps
80106eda:	e9 c0 f6 ff ff       	jmp    8010659f <alltraps>

80106edf <vector68>:
.globl vector68
vector68:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $68
80106ee1:	6a 44                	push   $0x44
  jmp alltraps
80106ee3:	e9 b7 f6 ff ff       	jmp    8010659f <alltraps>

80106ee8 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $69
80106eea:	6a 45                	push   $0x45
  jmp alltraps
80106eec:	e9 ae f6 ff ff       	jmp    8010659f <alltraps>

80106ef1 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $70
80106ef3:	6a 46                	push   $0x46
  jmp alltraps
80106ef5:	e9 a5 f6 ff ff       	jmp    8010659f <alltraps>

80106efa <vector71>:
.globl vector71
vector71:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $71
80106efc:	6a 47                	push   $0x47
  jmp alltraps
80106efe:	e9 9c f6 ff ff       	jmp    8010659f <alltraps>

80106f03 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $72
80106f05:	6a 48                	push   $0x48
  jmp alltraps
80106f07:	e9 93 f6 ff ff       	jmp    8010659f <alltraps>

80106f0c <vector73>:
.globl vector73
vector73:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $73
80106f0e:	6a 49                	push   $0x49
  jmp alltraps
80106f10:	e9 8a f6 ff ff       	jmp    8010659f <alltraps>

80106f15 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $74
80106f17:	6a 4a                	push   $0x4a
  jmp alltraps
80106f19:	e9 81 f6 ff ff       	jmp    8010659f <alltraps>

80106f1e <vector75>:
.globl vector75
vector75:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $75
80106f20:	6a 4b                	push   $0x4b
  jmp alltraps
80106f22:	e9 78 f6 ff ff       	jmp    8010659f <alltraps>

80106f27 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $76
80106f29:	6a 4c                	push   $0x4c
  jmp alltraps
80106f2b:	e9 6f f6 ff ff       	jmp    8010659f <alltraps>

80106f30 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $77
80106f32:	6a 4d                	push   $0x4d
  jmp alltraps
80106f34:	e9 66 f6 ff ff       	jmp    8010659f <alltraps>

80106f39 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $78
80106f3b:	6a 4e                	push   $0x4e
  jmp alltraps
80106f3d:	e9 5d f6 ff ff       	jmp    8010659f <alltraps>

80106f42 <vector79>:
.globl vector79
vector79:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $79
80106f44:	6a 4f                	push   $0x4f
  jmp alltraps
80106f46:	e9 54 f6 ff ff       	jmp    8010659f <alltraps>

80106f4b <vector80>:
.globl vector80
vector80:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $80
80106f4d:	6a 50                	push   $0x50
  jmp alltraps
80106f4f:	e9 4b f6 ff ff       	jmp    8010659f <alltraps>

80106f54 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $81
80106f56:	6a 51                	push   $0x51
  jmp alltraps
80106f58:	e9 42 f6 ff ff       	jmp    8010659f <alltraps>

80106f5d <vector82>:
.globl vector82
vector82:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $82
80106f5f:	6a 52                	push   $0x52
  jmp alltraps
80106f61:	e9 39 f6 ff ff       	jmp    8010659f <alltraps>

80106f66 <vector83>:
.globl vector83
vector83:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $83
80106f68:	6a 53                	push   $0x53
  jmp alltraps
80106f6a:	e9 30 f6 ff ff       	jmp    8010659f <alltraps>

80106f6f <vector84>:
.globl vector84
vector84:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $84
80106f71:	6a 54                	push   $0x54
  jmp alltraps
80106f73:	e9 27 f6 ff ff       	jmp    8010659f <alltraps>

80106f78 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $85
80106f7a:	6a 55                	push   $0x55
  jmp alltraps
80106f7c:	e9 1e f6 ff ff       	jmp    8010659f <alltraps>

80106f81 <vector86>:
.globl vector86
vector86:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $86
80106f83:	6a 56                	push   $0x56
  jmp alltraps
80106f85:	e9 15 f6 ff ff       	jmp    8010659f <alltraps>

80106f8a <vector87>:
.globl vector87
vector87:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $87
80106f8c:	6a 57                	push   $0x57
  jmp alltraps
80106f8e:	e9 0c f6 ff ff       	jmp    8010659f <alltraps>

80106f93 <vector88>:
.globl vector88
vector88:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $88
80106f95:	6a 58                	push   $0x58
  jmp alltraps
80106f97:	e9 03 f6 ff ff       	jmp    8010659f <alltraps>

80106f9c <vector89>:
.globl vector89
vector89:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $89
80106f9e:	6a 59                	push   $0x59
  jmp alltraps
80106fa0:	e9 fa f5 ff ff       	jmp    8010659f <alltraps>

80106fa5 <vector90>:
.globl vector90
vector90:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $90
80106fa7:	6a 5a                	push   $0x5a
  jmp alltraps
80106fa9:	e9 f1 f5 ff ff       	jmp    8010659f <alltraps>

80106fae <vector91>:
.globl vector91
vector91:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $91
80106fb0:	6a 5b                	push   $0x5b
  jmp alltraps
80106fb2:	e9 e8 f5 ff ff       	jmp    8010659f <alltraps>

80106fb7 <vector92>:
.globl vector92
vector92:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $92
80106fb9:	6a 5c                	push   $0x5c
  jmp alltraps
80106fbb:	e9 df f5 ff ff       	jmp    8010659f <alltraps>

80106fc0 <vector93>:
.globl vector93
vector93:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $93
80106fc2:	6a 5d                	push   $0x5d
  jmp alltraps
80106fc4:	e9 d6 f5 ff ff       	jmp    8010659f <alltraps>

80106fc9 <vector94>:
.globl vector94
vector94:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $94
80106fcb:	6a 5e                	push   $0x5e
  jmp alltraps
80106fcd:	e9 cd f5 ff ff       	jmp    8010659f <alltraps>

80106fd2 <vector95>:
.globl vector95
vector95:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $95
80106fd4:	6a 5f                	push   $0x5f
  jmp alltraps
80106fd6:	e9 c4 f5 ff ff       	jmp    8010659f <alltraps>

80106fdb <vector96>:
.globl vector96
vector96:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $96
80106fdd:	6a 60                	push   $0x60
  jmp alltraps
80106fdf:	e9 bb f5 ff ff       	jmp    8010659f <alltraps>

80106fe4 <vector97>:
.globl vector97
vector97:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $97
80106fe6:	6a 61                	push   $0x61
  jmp alltraps
80106fe8:	e9 b2 f5 ff ff       	jmp    8010659f <alltraps>

80106fed <vector98>:
.globl vector98
vector98:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $98
80106fef:	6a 62                	push   $0x62
  jmp alltraps
80106ff1:	e9 a9 f5 ff ff       	jmp    8010659f <alltraps>

80106ff6 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $99
80106ff8:	6a 63                	push   $0x63
  jmp alltraps
80106ffa:	e9 a0 f5 ff ff       	jmp    8010659f <alltraps>

80106fff <vector100>:
.globl vector100
vector100:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $100
80107001:	6a 64                	push   $0x64
  jmp alltraps
80107003:	e9 97 f5 ff ff       	jmp    8010659f <alltraps>

80107008 <vector101>:
.globl vector101
vector101:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $101
8010700a:	6a 65                	push   $0x65
  jmp alltraps
8010700c:	e9 8e f5 ff ff       	jmp    8010659f <alltraps>

80107011 <vector102>:
.globl vector102
vector102:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $102
80107013:	6a 66                	push   $0x66
  jmp alltraps
80107015:	e9 85 f5 ff ff       	jmp    8010659f <alltraps>

8010701a <vector103>:
.globl vector103
vector103:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $103
8010701c:	6a 67                	push   $0x67
  jmp alltraps
8010701e:	e9 7c f5 ff ff       	jmp    8010659f <alltraps>

80107023 <vector104>:
.globl vector104
vector104:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $104
80107025:	6a 68                	push   $0x68
  jmp alltraps
80107027:	e9 73 f5 ff ff       	jmp    8010659f <alltraps>

8010702c <vector105>:
.globl vector105
vector105:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $105
8010702e:	6a 69                	push   $0x69
  jmp alltraps
80107030:	e9 6a f5 ff ff       	jmp    8010659f <alltraps>

80107035 <vector106>:
.globl vector106
vector106:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $106
80107037:	6a 6a                	push   $0x6a
  jmp alltraps
80107039:	e9 61 f5 ff ff       	jmp    8010659f <alltraps>

8010703e <vector107>:
.globl vector107
vector107:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $107
80107040:	6a 6b                	push   $0x6b
  jmp alltraps
80107042:	e9 58 f5 ff ff       	jmp    8010659f <alltraps>

80107047 <vector108>:
.globl vector108
vector108:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $108
80107049:	6a 6c                	push   $0x6c
  jmp alltraps
8010704b:	e9 4f f5 ff ff       	jmp    8010659f <alltraps>

80107050 <vector109>:
.globl vector109
vector109:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $109
80107052:	6a 6d                	push   $0x6d
  jmp alltraps
80107054:	e9 46 f5 ff ff       	jmp    8010659f <alltraps>

80107059 <vector110>:
.globl vector110
vector110:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $110
8010705b:	6a 6e                	push   $0x6e
  jmp alltraps
8010705d:	e9 3d f5 ff ff       	jmp    8010659f <alltraps>

80107062 <vector111>:
.globl vector111
vector111:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $111
80107064:	6a 6f                	push   $0x6f
  jmp alltraps
80107066:	e9 34 f5 ff ff       	jmp    8010659f <alltraps>

8010706b <vector112>:
.globl vector112
vector112:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $112
8010706d:	6a 70                	push   $0x70
  jmp alltraps
8010706f:	e9 2b f5 ff ff       	jmp    8010659f <alltraps>

80107074 <vector113>:
.globl vector113
vector113:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $113
80107076:	6a 71                	push   $0x71
  jmp alltraps
80107078:	e9 22 f5 ff ff       	jmp    8010659f <alltraps>

8010707d <vector114>:
.globl vector114
vector114:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $114
8010707f:	6a 72                	push   $0x72
  jmp alltraps
80107081:	e9 19 f5 ff ff       	jmp    8010659f <alltraps>

80107086 <vector115>:
.globl vector115
vector115:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $115
80107088:	6a 73                	push   $0x73
  jmp alltraps
8010708a:	e9 10 f5 ff ff       	jmp    8010659f <alltraps>

8010708f <vector116>:
.globl vector116
vector116:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $116
80107091:	6a 74                	push   $0x74
  jmp alltraps
80107093:	e9 07 f5 ff ff       	jmp    8010659f <alltraps>

80107098 <vector117>:
.globl vector117
vector117:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $117
8010709a:	6a 75                	push   $0x75
  jmp alltraps
8010709c:	e9 fe f4 ff ff       	jmp    8010659f <alltraps>

801070a1 <vector118>:
.globl vector118
vector118:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $118
801070a3:	6a 76                	push   $0x76
  jmp alltraps
801070a5:	e9 f5 f4 ff ff       	jmp    8010659f <alltraps>

801070aa <vector119>:
.globl vector119
vector119:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $119
801070ac:	6a 77                	push   $0x77
  jmp alltraps
801070ae:	e9 ec f4 ff ff       	jmp    8010659f <alltraps>

801070b3 <vector120>:
.globl vector120
vector120:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $120
801070b5:	6a 78                	push   $0x78
  jmp alltraps
801070b7:	e9 e3 f4 ff ff       	jmp    8010659f <alltraps>

801070bc <vector121>:
.globl vector121
vector121:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $121
801070be:	6a 79                	push   $0x79
  jmp alltraps
801070c0:	e9 da f4 ff ff       	jmp    8010659f <alltraps>

801070c5 <vector122>:
.globl vector122
vector122:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $122
801070c7:	6a 7a                	push   $0x7a
  jmp alltraps
801070c9:	e9 d1 f4 ff ff       	jmp    8010659f <alltraps>

801070ce <vector123>:
.globl vector123
vector123:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $123
801070d0:	6a 7b                	push   $0x7b
  jmp alltraps
801070d2:	e9 c8 f4 ff ff       	jmp    8010659f <alltraps>

801070d7 <vector124>:
.globl vector124
vector124:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $124
801070d9:	6a 7c                	push   $0x7c
  jmp alltraps
801070db:	e9 bf f4 ff ff       	jmp    8010659f <alltraps>

801070e0 <vector125>:
.globl vector125
vector125:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $125
801070e2:	6a 7d                	push   $0x7d
  jmp alltraps
801070e4:	e9 b6 f4 ff ff       	jmp    8010659f <alltraps>

801070e9 <vector126>:
.globl vector126
vector126:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $126
801070eb:	6a 7e                	push   $0x7e
  jmp alltraps
801070ed:	e9 ad f4 ff ff       	jmp    8010659f <alltraps>

801070f2 <vector127>:
.globl vector127
vector127:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $127
801070f4:	6a 7f                	push   $0x7f
  jmp alltraps
801070f6:	e9 a4 f4 ff ff       	jmp    8010659f <alltraps>

801070fb <vector128>:
.globl vector128
vector128:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $128
801070fd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107102:	e9 98 f4 ff ff       	jmp    8010659f <alltraps>

80107107 <vector129>:
.globl vector129
vector129:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $129
80107109:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010710e:	e9 8c f4 ff ff       	jmp    8010659f <alltraps>

80107113 <vector130>:
.globl vector130
vector130:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $130
80107115:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010711a:	e9 80 f4 ff ff       	jmp    8010659f <alltraps>

8010711f <vector131>:
.globl vector131
vector131:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $131
80107121:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107126:	e9 74 f4 ff ff       	jmp    8010659f <alltraps>

8010712b <vector132>:
.globl vector132
vector132:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $132
8010712d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107132:	e9 68 f4 ff ff       	jmp    8010659f <alltraps>

80107137 <vector133>:
.globl vector133
vector133:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $133
80107139:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010713e:	e9 5c f4 ff ff       	jmp    8010659f <alltraps>

80107143 <vector134>:
.globl vector134
vector134:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $134
80107145:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010714a:	e9 50 f4 ff ff       	jmp    8010659f <alltraps>

8010714f <vector135>:
.globl vector135
vector135:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $135
80107151:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107156:	e9 44 f4 ff ff       	jmp    8010659f <alltraps>

8010715b <vector136>:
.globl vector136
vector136:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $136
8010715d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107162:	e9 38 f4 ff ff       	jmp    8010659f <alltraps>

80107167 <vector137>:
.globl vector137
vector137:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $137
80107169:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010716e:	e9 2c f4 ff ff       	jmp    8010659f <alltraps>

80107173 <vector138>:
.globl vector138
vector138:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $138
80107175:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010717a:	e9 20 f4 ff ff       	jmp    8010659f <alltraps>

8010717f <vector139>:
.globl vector139
vector139:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $139
80107181:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107186:	e9 14 f4 ff ff       	jmp    8010659f <alltraps>

8010718b <vector140>:
.globl vector140
vector140:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $140
8010718d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107192:	e9 08 f4 ff ff       	jmp    8010659f <alltraps>

80107197 <vector141>:
.globl vector141
vector141:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $141
80107199:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010719e:	e9 fc f3 ff ff       	jmp    8010659f <alltraps>

801071a3 <vector142>:
.globl vector142
vector142:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $142
801071a5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071aa:	e9 f0 f3 ff ff       	jmp    8010659f <alltraps>

801071af <vector143>:
.globl vector143
vector143:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $143
801071b1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071b6:	e9 e4 f3 ff ff       	jmp    8010659f <alltraps>

801071bb <vector144>:
.globl vector144
vector144:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $144
801071bd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801071c2:	e9 d8 f3 ff ff       	jmp    8010659f <alltraps>

801071c7 <vector145>:
.globl vector145
vector145:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $145
801071c9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071ce:	e9 cc f3 ff ff       	jmp    8010659f <alltraps>

801071d3 <vector146>:
.globl vector146
vector146:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $146
801071d5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071da:	e9 c0 f3 ff ff       	jmp    8010659f <alltraps>

801071df <vector147>:
.globl vector147
vector147:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $147
801071e1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071e6:	e9 b4 f3 ff ff       	jmp    8010659f <alltraps>

801071eb <vector148>:
.globl vector148
vector148:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $148
801071ed:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071f2:	e9 a8 f3 ff ff       	jmp    8010659f <alltraps>

801071f7 <vector149>:
.globl vector149
vector149:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $149
801071f9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071fe:	e9 9c f3 ff ff       	jmp    8010659f <alltraps>

80107203 <vector150>:
.globl vector150
vector150:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $150
80107205:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010720a:	e9 90 f3 ff ff       	jmp    8010659f <alltraps>

8010720f <vector151>:
.globl vector151
vector151:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $151
80107211:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107216:	e9 84 f3 ff ff       	jmp    8010659f <alltraps>

8010721b <vector152>:
.globl vector152
vector152:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $152
8010721d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107222:	e9 78 f3 ff ff       	jmp    8010659f <alltraps>

80107227 <vector153>:
.globl vector153
vector153:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $153
80107229:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010722e:	e9 6c f3 ff ff       	jmp    8010659f <alltraps>

80107233 <vector154>:
.globl vector154
vector154:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $154
80107235:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010723a:	e9 60 f3 ff ff       	jmp    8010659f <alltraps>

8010723f <vector155>:
.globl vector155
vector155:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $155
80107241:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107246:	e9 54 f3 ff ff       	jmp    8010659f <alltraps>

8010724b <vector156>:
.globl vector156
vector156:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $156
8010724d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107252:	e9 48 f3 ff ff       	jmp    8010659f <alltraps>

80107257 <vector157>:
.globl vector157
vector157:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $157
80107259:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010725e:	e9 3c f3 ff ff       	jmp    8010659f <alltraps>

80107263 <vector158>:
.globl vector158
vector158:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $158
80107265:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010726a:	e9 30 f3 ff ff       	jmp    8010659f <alltraps>

8010726f <vector159>:
.globl vector159
vector159:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $159
80107271:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107276:	e9 24 f3 ff ff       	jmp    8010659f <alltraps>

8010727b <vector160>:
.globl vector160
vector160:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $160
8010727d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107282:	e9 18 f3 ff ff       	jmp    8010659f <alltraps>

80107287 <vector161>:
.globl vector161
vector161:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $161
80107289:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010728e:	e9 0c f3 ff ff       	jmp    8010659f <alltraps>

80107293 <vector162>:
.globl vector162
vector162:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $162
80107295:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010729a:	e9 00 f3 ff ff       	jmp    8010659f <alltraps>

8010729f <vector163>:
.globl vector163
vector163:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $163
801072a1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072a6:	e9 f4 f2 ff ff       	jmp    8010659f <alltraps>

801072ab <vector164>:
.globl vector164
vector164:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $164
801072ad:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072b2:	e9 e8 f2 ff ff       	jmp    8010659f <alltraps>

801072b7 <vector165>:
.globl vector165
vector165:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $165
801072b9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801072be:	e9 dc f2 ff ff       	jmp    8010659f <alltraps>

801072c3 <vector166>:
.globl vector166
vector166:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $166
801072c5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801072ca:	e9 d0 f2 ff ff       	jmp    8010659f <alltraps>

801072cf <vector167>:
.globl vector167
vector167:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $167
801072d1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801072d6:	e9 c4 f2 ff ff       	jmp    8010659f <alltraps>

801072db <vector168>:
.globl vector168
vector168:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $168
801072dd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072e2:	e9 b8 f2 ff ff       	jmp    8010659f <alltraps>

801072e7 <vector169>:
.globl vector169
vector169:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $169
801072e9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072ee:	e9 ac f2 ff ff       	jmp    8010659f <alltraps>

801072f3 <vector170>:
.globl vector170
vector170:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $170
801072f5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072fa:	e9 a0 f2 ff ff       	jmp    8010659f <alltraps>

801072ff <vector171>:
.globl vector171
vector171:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $171
80107301:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107306:	e9 94 f2 ff ff       	jmp    8010659f <alltraps>

8010730b <vector172>:
.globl vector172
vector172:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $172
8010730d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107312:	e9 88 f2 ff ff       	jmp    8010659f <alltraps>

80107317 <vector173>:
.globl vector173
vector173:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $173
80107319:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010731e:	e9 7c f2 ff ff       	jmp    8010659f <alltraps>

80107323 <vector174>:
.globl vector174
vector174:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $174
80107325:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010732a:	e9 70 f2 ff ff       	jmp    8010659f <alltraps>

8010732f <vector175>:
.globl vector175
vector175:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $175
80107331:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107336:	e9 64 f2 ff ff       	jmp    8010659f <alltraps>

8010733b <vector176>:
.globl vector176
vector176:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $176
8010733d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107342:	e9 58 f2 ff ff       	jmp    8010659f <alltraps>

80107347 <vector177>:
.globl vector177
vector177:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $177
80107349:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010734e:	e9 4c f2 ff ff       	jmp    8010659f <alltraps>

80107353 <vector178>:
.globl vector178
vector178:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $178
80107355:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010735a:	e9 40 f2 ff ff       	jmp    8010659f <alltraps>

8010735f <vector179>:
.globl vector179
vector179:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $179
80107361:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107366:	e9 34 f2 ff ff       	jmp    8010659f <alltraps>

8010736b <vector180>:
.globl vector180
vector180:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $180
8010736d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107372:	e9 28 f2 ff ff       	jmp    8010659f <alltraps>

80107377 <vector181>:
.globl vector181
vector181:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $181
80107379:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010737e:	e9 1c f2 ff ff       	jmp    8010659f <alltraps>

80107383 <vector182>:
.globl vector182
vector182:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $182
80107385:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010738a:	e9 10 f2 ff ff       	jmp    8010659f <alltraps>

8010738f <vector183>:
.globl vector183
vector183:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $183
80107391:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107396:	e9 04 f2 ff ff       	jmp    8010659f <alltraps>

8010739b <vector184>:
.globl vector184
vector184:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $184
8010739d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073a2:	e9 f8 f1 ff ff       	jmp    8010659f <alltraps>

801073a7 <vector185>:
.globl vector185
vector185:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $185
801073a9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073ae:	e9 ec f1 ff ff       	jmp    8010659f <alltraps>

801073b3 <vector186>:
.globl vector186
vector186:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $186
801073b5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073ba:	e9 e0 f1 ff ff       	jmp    8010659f <alltraps>

801073bf <vector187>:
.globl vector187
vector187:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $187
801073c1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801073c6:	e9 d4 f1 ff ff       	jmp    8010659f <alltraps>

801073cb <vector188>:
.globl vector188
vector188:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $188
801073cd:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073d2:	e9 c8 f1 ff ff       	jmp    8010659f <alltraps>

801073d7 <vector189>:
.globl vector189
vector189:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $189
801073d9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073de:	e9 bc f1 ff ff       	jmp    8010659f <alltraps>

801073e3 <vector190>:
.globl vector190
vector190:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $190
801073e5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073ea:	e9 b0 f1 ff ff       	jmp    8010659f <alltraps>

801073ef <vector191>:
.globl vector191
vector191:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $191
801073f1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073f6:	e9 a4 f1 ff ff       	jmp    8010659f <alltraps>

801073fb <vector192>:
.globl vector192
vector192:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $192
801073fd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107402:	e9 98 f1 ff ff       	jmp    8010659f <alltraps>

80107407 <vector193>:
.globl vector193
vector193:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $193
80107409:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010740e:	e9 8c f1 ff ff       	jmp    8010659f <alltraps>

80107413 <vector194>:
.globl vector194
vector194:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $194
80107415:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010741a:	e9 80 f1 ff ff       	jmp    8010659f <alltraps>

8010741f <vector195>:
.globl vector195
vector195:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $195
80107421:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107426:	e9 74 f1 ff ff       	jmp    8010659f <alltraps>

8010742b <vector196>:
.globl vector196
vector196:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $196
8010742d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107432:	e9 68 f1 ff ff       	jmp    8010659f <alltraps>

80107437 <vector197>:
.globl vector197
vector197:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $197
80107439:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010743e:	e9 5c f1 ff ff       	jmp    8010659f <alltraps>

80107443 <vector198>:
.globl vector198
vector198:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $198
80107445:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010744a:	e9 50 f1 ff ff       	jmp    8010659f <alltraps>

8010744f <vector199>:
.globl vector199
vector199:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $199
80107451:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107456:	e9 44 f1 ff ff       	jmp    8010659f <alltraps>

8010745b <vector200>:
.globl vector200
vector200:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $200
8010745d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107462:	e9 38 f1 ff ff       	jmp    8010659f <alltraps>

80107467 <vector201>:
.globl vector201
vector201:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $201
80107469:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010746e:	e9 2c f1 ff ff       	jmp    8010659f <alltraps>

80107473 <vector202>:
.globl vector202
vector202:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $202
80107475:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010747a:	e9 20 f1 ff ff       	jmp    8010659f <alltraps>

8010747f <vector203>:
.globl vector203
vector203:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $203
80107481:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107486:	e9 14 f1 ff ff       	jmp    8010659f <alltraps>

8010748b <vector204>:
.globl vector204
vector204:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $204
8010748d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107492:	e9 08 f1 ff ff       	jmp    8010659f <alltraps>

80107497 <vector205>:
.globl vector205
vector205:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $205
80107499:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010749e:	e9 fc f0 ff ff       	jmp    8010659f <alltraps>

801074a3 <vector206>:
.globl vector206
vector206:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $206
801074a5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074aa:	e9 f0 f0 ff ff       	jmp    8010659f <alltraps>

801074af <vector207>:
.globl vector207
vector207:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $207
801074b1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074b6:	e9 e4 f0 ff ff       	jmp    8010659f <alltraps>

801074bb <vector208>:
.globl vector208
vector208:
  pushl $0
801074bb:	6a 00                	push   $0x0
  pushl $208
801074bd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801074c2:	e9 d8 f0 ff ff       	jmp    8010659f <alltraps>

801074c7 <vector209>:
.globl vector209
vector209:
  pushl $0
801074c7:	6a 00                	push   $0x0
  pushl $209
801074c9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074ce:	e9 cc f0 ff ff       	jmp    8010659f <alltraps>

801074d3 <vector210>:
.globl vector210
vector210:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $210
801074d5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074da:	e9 c0 f0 ff ff       	jmp    8010659f <alltraps>

801074df <vector211>:
.globl vector211
vector211:
  pushl $0
801074df:	6a 00                	push   $0x0
  pushl $211
801074e1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074e6:	e9 b4 f0 ff ff       	jmp    8010659f <alltraps>

801074eb <vector212>:
.globl vector212
vector212:
  pushl $0
801074eb:	6a 00                	push   $0x0
  pushl $212
801074ed:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074f2:	e9 a8 f0 ff ff       	jmp    8010659f <alltraps>

801074f7 <vector213>:
.globl vector213
vector213:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $213
801074f9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074fe:	e9 9c f0 ff ff       	jmp    8010659f <alltraps>

80107503 <vector214>:
.globl vector214
vector214:
  pushl $0
80107503:	6a 00                	push   $0x0
  pushl $214
80107505:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010750a:	e9 90 f0 ff ff       	jmp    8010659f <alltraps>

8010750f <vector215>:
.globl vector215
vector215:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $215
80107511:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107516:	e9 84 f0 ff ff       	jmp    8010659f <alltraps>

8010751b <vector216>:
.globl vector216
vector216:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $216
8010751d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107522:	e9 78 f0 ff ff       	jmp    8010659f <alltraps>

80107527 <vector217>:
.globl vector217
vector217:
  pushl $0
80107527:	6a 00                	push   $0x0
  pushl $217
80107529:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010752e:	e9 6c f0 ff ff       	jmp    8010659f <alltraps>

80107533 <vector218>:
.globl vector218
vector218:
  pushl $0
80107533:	6a 00                	push   $0x0
  pushl $218
80107535:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010753a:	e9 60 f0 ff ff       	jmp    8010659f <alltraps>

8010753f <vector219>:
.globl vector219
vector219:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $219
80107541:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107546:	e9 54 f0 ff ff       	jmp    8010659f <alltraps>

8010754b <vector220>:
.globl vector220
vector220:
  pushl $0
8010754b:	6a 00                	push   $0x0
  pushl $220
8010754d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107552:	e9 48 f0 ff ff       	jmp    8010659f <alltraps>

80107557 <vector221>:
.globl vector221
vector221:
  pushl $0
80107557:	6a 00                	push   $0x0
  pushl $221
80107559:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010755e:	e9 3c f0 ff ff       	jmp    8010659f <alltraps>

80107563 <vector222>:
.globl vector222
vector222:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $222
80107565:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010756a:	e9 30 f0 ff ff       	jmp    8010659f <alltraps>

8010756f <vector223>:
.globl vector223
vector223:
  pushl $0
8010756f:	6a 00                	push   $0x0
  pushl $223
80107571:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107576:	e9 24 f0 ff ff       	jmp    8010659f <alltraps>

8010757b <vector224>:
.globl vector224
vector224:
  pushl $0
8010757b:	6a 00                	push   $0x0
  pushl $224
8010757d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107582:	e9 18 f0 ff ff       	jmp    8010659f <alltraps>

80107587 <vector225>:
.globl vector225
vector225:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $225
80107589:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010758e:	e9 0c f0 ff ff       	jmp    8010659f <alltraps>

80107593 <vector226>:
.globl vector226
vector226:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $226
80107595:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010759a:	e9 00 f0 ff ff       	jmp    8010659f <alltraps>

8010759f <vector227>:
.globl vector227
vector227:
  pushl $0
8010759f:	6a 00                	push   $0x0
  pushl $227
801075a1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075a6:	e9 f4 ef ff ff       	jmp    8010659f <alltraps>

801075ab <vector228>:
.globl vector228
vector228:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $228
801075ad:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075b2:	e9 e8 ef ff ff       	jmp    8010659f <alltraps>

801075b7 <vector229>:
.globl vector229
vector229:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $229
801075b9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801075be:	e9 dc ef ff ff       	jmp    8010659f <alltraps>

801075c3 <vector230>:
.globl vector230
vector230:
  pushl $0
801075c3:	6a 00                	push   $0x0
  pushl $230
801075c5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801075ca:	e9 d0 ef ff ff       	jmp    8010659f <alltraps>

801075cf <vector231>:
.globl vector231
vector231:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $231
801075d1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801075d6:	e9 c4 ef ff ff       	jmp    8010659f <alltraps>

801075db <vector232>:
.globl vector232
vector232:
  pushl $0
801075db:	6a 00                	push   $0x0
  pushl $232
801075dd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075e2:	e9 b8 ef ff ff       	jmp    8010659f <alltraps>

801075e7 <vector233>:
.globl vector233
vector233:
  pushl $0
801075e7:	6a 00                	push   $0x0
  pushl $233
801075e9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075ee:	e9 ac ef ff ff       	jmp    8010659f <alltraps>

801075f3 <vector234>:
.globl vector234
vector234:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $234
801075f5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075fa:	e9 a0 ef ff ff       	jmp    8010659f <alltraps>

801075ff <vector235>:
.globl vector235
vector235:
  pushl $0
801075ff:	6a 00                	push   $0x0
  pushl $235
80107601:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107606:	e9 94 ef ff ff       	jmp    8010659f <alltraps>

8010760b <vector236>:
.globl vector236
vector236:
  pushl $0
8010760b:	6a 00                	push   $0x0
  pushl $236
8010760d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107612:	e9 88 ef ff ff       	jmp    8010659f <alltraps>

80107617 <vector237>:
.globl vector237
vector237:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $237
80107619:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010761e:	e9 7c ef ff ff       	jmp    8010659f <alltraps>

80107623 <vector238>:
.globl vector238
vector238:
  pushl $0
80107623:	6a 00                	push   $0x0
  pushl $238
80107625:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010762a:	e9 70 ef ff ff       	jmp    8010659f <alltraps>

8010762f <vector239>:
.globl vector239
vector239:
  pushl $0
8010762f:	6a 00                	push   $0x0
  pushl $239
80107631:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107636:	e9 64 ef ff ff       	jmp    8010659f <alltraps>

8010763b <vector240>:
.globl vector240
vector240:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $240
8010763d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107642:	e9 58 ef ff ff       	jmp    8010659f <alltraps>

80107647 <vector241>:
.globl vector241
vector241:
  pushl $0
80107647:	6a 00                	push   $0x0
  pushl $241
80107649:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010764e:	e9 4c ef ff ff       	jmp    8010659f <alltraps>

80107653 <vector242>:
.globl vector242
vector242:
  pushl $0
80107653:	6a 00                	push   $0x0
  pushl $242
80107655:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010765a:	e9 40 ef ff ff       	jmp    8010659f <alltraps>

8010765f <vector243>:
.globl vector243
vector243:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $243
80107661:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107666:	e9 34 ef ff ff       	jmp    8010659f <alltraps>

8010766b <vector244>:
.globl vector244
vector244:
  pushl $0
8010766b:	6a 00                	push   $0x0
  pushl $244
8010766d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107672:	e9 28 ef ff ff       	jmp    8010659f <alltraps>

80107677 <vector245>:
.globl vector245
vector245:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $245
80107679:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010767e:	e9 1c ef ff ff       	jmp    8010659f <alltraps>

80107683 <vector246>:
.globl vector246
vector246:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $246
80107685:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010768a:	e9 10 ef ff ff       	jmp    8010659f <alltraps>

8010768f <vector247>:
.globl vector247
vector247:
  pushl $0
8010768f:	6a 00                	push   $0x0
  pushl $247
80107691:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107696:	e9 04 ef ff ff       	jmp    8010659f <alltraps>

8010769b <vector248>:
.globl vector248
vector248:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $248
8010769d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076a2:	e9 f8 ee ff ff       	jmp    8010659f <alltraps>

801076a7 <vector249>:
.globl vector249
vector249:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $249
801076a9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076ae:	e9 ec ee ff ff       	jmp    8010659f <alltraps>

801076b3 <vector250>:
.globl vector250
vector250:
  pushl $0
801076b3:	6a 00                	push   $0x0
  pushl $250
801076b5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076ba:	e9 e0 ee ff ff       	jmp    8010659f <alltraps>

801076bf <vector251>:
.globl vector251
vector251:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $251
801076c1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801076c6:	e9 d4 ee ff ff       	jmp    8010659f <alltraps>

801076cb <vector252>:
.globl vector252
vector252:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $252
801076cd:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076d2:	e9 c8 ee ff ff       	jmp    8010659f <alltraps>

801076d7 <vector253>:
.globl vector253
vector253:
  pushl $0
801076d7:	6a 00                	push   $0x0
  pushl $253
801076d9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076de:	e9 bc ee ff ff       	jmp    8010659f <alltraps>

801076e3 <vector254>:
.globl vector254
vector254:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $254
801076e5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076ea:	e9 b0 ee ff ff       	jmp    8010659f <alltraps>

801076ef <vector255>:
.globl vector255
vector255:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $255
801076f1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076f6:	e9 a4 ee ff ff       	jmp    8010659f <alltraps>

801076fb <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801076fb:	55                   	push   %ebp
801076fc:	89 e5                	mov    %esp,%ebp
801076fe:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107701:	8b 45 0c             	mov    0xc(%ebp),%eax
80107704:	83 e8 01             	sub    $0x1,%eax
80107707:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010770b:	8b 45 08             	mov    0x8(%ebp),%eax
8010770e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107712:	8b 45 08             	mov    0x8(%ebp),%eax
80107715:	c1 e8 10             	shr    $0x10,%eax
80107718:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010771c:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010771f:	0f 01 10             	lgdtl  (%eax)
}
80107722:	90                   	nop
80107723:	c9                   	leave  
80107724:	c3                   	ret    

80107725 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107725:	55                   	push   %ebp
80107726:	89 e5                	mov    %esp,%ebp
80107728:	83 ec 04             	sub    $0x4,%esp
8010772b:	8b 45 08             	mov    0x8(%ebp),%eax
8010772e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107732:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107736:	0f 00 d8             	ltr    %ax
}
80107739:	90                   	nop
8010773a:	c9                   	leave  
8010773b:	c3                   	ret    

8010773c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
8010773c:	55                   	push   %ebp
8010773d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010773f:	8b 45 08             	mov    0x8(%ebp),%eax
80107742:	0f 22 d8             	mov    %eax,%cr3
}
80107745:	90                   	nop
80107746:	5d                   	pop    %ebp
80107747:	c3                   	ret    

80107748 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107748:	55                   	push   %ebp
80107749:	89 e5                	mov    %esp,%ebp
8010774b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010774e:	e8 8e ca ff ff       	call   801041e1 <cpuid>
80107753:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107759:	05 00 38 11 80       	add    $0x80113800,%eax
8010775e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010776a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107776:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010777a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107781:	83 e2 f0             	and    $0xfffffff0,%edx
80107784:	83 ca 0a             	or     $0xa,%edx
80107787:	88 50 7d             	mov    %dl,0x7d(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107791:	83 ca 10             	or     $0x10,%edx
80107794:	88 50 7d             	mov    %dl,0x7d(%eax)
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010779e:	83 e2 9f             	and    $0xffffff9f,%edx
801077a1:	88 50 7d             	mov    %dl,0x7d(%eax)
801077a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077ab:	83 ca 80             	or     $0xffffff80,%edx
801077ae:	88 50 7d             	mov    %dl,0x7d(%eax)
801077b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077b8:	83 ca 0f             	or     $0xf,%edx
801077bb:	88 50 7e             	mov    %dl,0x7e(%eax)
801077be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077c5:	83 e2 ef             	and    $0xffffffef,%edx
801077c8:	88 50 7e             	mov    %dl,0x7e(%eax)
801077cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ce:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077d2:	83 e2 df             	and    $0xffffffdf,%edx
801077d5:	88 50 7e             	mov    %dl,0x7e(%eax)
801077d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077db:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077df:	83 ca 40             	or     $0x40,%edx
801077e2:	88 50 7e             	mov    %dl,0x7e(%eax)
801077e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077ec:	83 ca 80             	or     $0xffffff80,%edx
801077ef:	88 50 7e             	mov    %dl,0x7e(%eax)
801077f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f5:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fc:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107803:	ff ff 
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010780f:	00 00 
80107811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107814:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010781b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107825:	83 e2 f0             	and    $0xfffffff0,%edx
80107828:	83 ca 02             	or     $0x2,%edx
8010782b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010783b:	83 ca 10             	or     $0x10,%edx
8010783e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107847:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010784e:	83 e2 9f             	and    $0xffffff9f,%edx
80107851:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107861:	83 ca 80             	or     $0xffffff80,%edx
80107864:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010786a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107874:	83 ca 0f             	or     $0xf,%edx
80107877:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010787d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107880:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107887:	83 e2 ef             	and    $0xffffffef,%edx
8010788a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107893:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010789a:	83 e2 df             	and    $0xffffffdf,%edx
8010789d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078ad:	83 ca 40             	or     $0x40,%edx
801078b0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078c0:	83 ca 80             	or     $0xffffff80,%edx
801078c3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cc:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d6:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801078dd:	ff ff 
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801078e9:	00 00 
801078eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ee:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801078f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078ff:	83 e2 f0             	and    $0xfffffff0,%edx
80107902:	83 ca 0a             	or     $0xa,%edx
80107905:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107915:	83 ca 10             	or     $0x10,%edx
80107918:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010791e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107921:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107928:	83 ca 60             	or     $0x60,%edx
8010792b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010793b:	83 ca 80             	or     $0xffffff80,%edx
8010793e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107947:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010794e:	83 ca 0f             	or     $0xf,%edx
80107951:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107961:	83 e2 ef             	and    $0xffffffef,%edx
80107964:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010796a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107974:	83 e2 df             	and    $0xffffffdf,%edx
80107977:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010797d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107980:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107987:	83 ca 40             	or     $0x40,%edx
8010798a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107993:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010799a:	83 ca 80             	or     $0xffffff80,%edx
8010799d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801079ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079b7:	ff ff 
801079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079c3:	00 00 
801079c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079d9:	83 e2 f0             	and    $0xfffffff0,%edx
801079dc:	83 ca 02             	or     $0x2,%edx
801079df:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ef:	83 ca 10             	or     $0x10,%edx
801079f2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a02:	83 ca 60             	or     $0x60,%edx
80107a05:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a15:	83 ca 80             	or     $0xffffff80,%edx
80107a18:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a21:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a28:	83 ca 0f             	or     $0xf,%edx
80107a2b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a3b:	83 e2 ef             	and    $0xffffffef,%edx
80107a3e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a47:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a4e:	83 e2 df             	and    $0xffffffdf,%edx
80107a51:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a61:	83 ca 40             	or     $0x40,%edx
80107a64:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a74:	83 ca 80             	or     $0xffffff80,%edx
80107a77:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a80:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8a:	83 c0 70             	add    $0x70,%eax
80107a8d:	83 ec 08             	sub    $0x8,%esp
80107a90:	6a 30                	push   $0x30
80107a92:	50                   	push   %eax
80107a93:	e8 63 fc ff ff       	call   801076fb <lgdt>
80107a98:	83 c4 10             	add    $0x10,%esp
}
80107a9b:	90                   	nop
80107a9c:	c9                   	leave  
80107a9d:	c3                   	ret    

80107a9e <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a9e:	55                   	push   %ebp
80107a9f:	89 e5                	mov    %esp,%ebp
80107aa1:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa7:	c1 e8 16             	shr    $0x16,%eax
80107aaa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab4:	01 d0                	add    %edx,%eax
80107ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107abc:	8b 00                	mov    (%eax),%eax
80107abe:	83 e0 01             	and    $0x1,%eax
80107ac1:	85 c0                	test   %eax,%eax
80107ac3:	74 14                	je     80107ad9 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac8:	8b 00                	mov    (%eax),%eax
80107aca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107acf:	05 00 00 00 80       	add    $0x80000000,%eax
80107ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ad7:	eb 42                	jmp    80107b1b <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ad9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107add:	74 0e                	je     80107aed <walkpgdir+0x4f>
80107adf:	e8 9e b1 ff ff       	call   80102c82 <kalloc>
80107ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ae7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107aeb:	75 07                	jne    80107af4 <walkpgdir+0x56>
      return 0;
80107aed:	b8 00 00 00 00       	mov    $0x0,%eax
80107af2:	eb 3e                	jmp    80107b32 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107af4:	83 ec 04             	sub    $0x4,%esp
80107af7:	68 00 10 00 00       	push   $0x1000
80107afc:	6a 00                	push   $0x0
80107afe:	ff 75 f4             	pushl  -0xc(%ebp)
80107b01:	e8 c3 d6 ff ff       	call   801051c9 <memset>
80107b06:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	05 00 00 00 80       	add    $0x80000000,%eax
80107b11:	83 c8 07             	or     $0x7,%eax
80107b14:	89 c2                	mov    %eax,%edx
80107b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b19:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b1e:	c1 e8 0c             	shr    $0xc,%eax
80107b21:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b30:	01 d0                	add    %edx,%eax
}
80107b32:	c9                   	leave  
80107b33:	c3                   	ret    

80107b34 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b34:	55                   	push   %ebp
80107b35:	89 e5                	mov    %esp,%ebp
80107b37:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b45:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b48:	8b 45 10             	mov    0x10(%ebp),%eax
80107b4b:	01 d0                	add    %edx,%eax
80107b4d:	83 e8 01             	sub    $0x1,%eax
80107b50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b58:	83 ec 04             	sub    $0x4,%esp
80107b5b:	6a 01                	push   $0x1
80107b5d:	ff 75 f4             	pushl  -0xc(%ebp)
80107b60:	ff 75 08             	pushl  0x8(%ebp)
80107b63:	e8 36 ff ff ff       	call   80107a9e <walkpgdir>
80107b68:	83 c4 10             	add    $0x10,%esp
80107b6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b6e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b72:	75 07                	jne    80107b7b <mappages+0x47>
      return -1;
80107b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b79:	eb 47                	jmp    80107bc2 <mappages+0x8e>
    if(*pte & PTE_P)
80107b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b7e:	8b 00                	mov    (%eax),%eax
80107b80:	83 e0 01             	and    $0x1,%eax
80107b83:	85 c0                	test   %eax,%eax
80107b85:	74 0d                	je     80107b94 <mappages+0x60>
      panic("remap");
80107b87:	83 ec 0c             	sub    $0xc,%esp
80107b8a:	68 3c 8c 10 80       	push   $0x80108c3c
80107b8f:	e8 0c 8a ff ff       	call   801005a0 <panic>
    *pte = pa | perm | PTE_P;
80107b94:	8b 45 18             	mov    0x18(%ebp),%eax
80107b97:	0b 45 14             	or     0x14(%ebp),%eax
80107b9a:	83 c8 01             	or     $0x1,%eax
80107b9d:	89 c2                	mov    %eax,%edx
80107b9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ba2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107baa:	74 10                	je     80107bbc <mappages+0x88>
      break;
    a += PGSIZE;
80107bac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107bb3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107bba:	eb 9c                	jmp    80107b58 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107bbc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bc2:	c9                   	leave  
80107bc3:	c3                   	ret    

80107bc4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bc4:	55                   	push   %ebp
80107bc5:	89 e5                	mov    %esp,%ebp
80107bc7:	53                   	push   %ebx
80107bc8:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107bcb:	e8 b2 b0 ff ff       	call   80102c82 <kalloc>
80107bd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bd7:	75 07                	jne    80107be0 <setupkvm+0x1c>
    return 0;
80107bd9:	b8 00 00 00 00       	mov    $0x0,%eax
80107bde:	eb 78                	jmp    80107c58 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107be0:	83 ec 04             	sub    $0x4,%esp
80107be3:	68 00 10 00 00       	push   $0x1000
80107be8:	6a 00                	push   $0x0
80107bea:	ff 75 f0             	pushl  -0x10(%ebp)
80107bed:	e8 d7 d5 ff ff       	call   801051c9 <memset>
80107bf2:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107bf5:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107bfc:	eb 4e                	jmp    80107c4c <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c01:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c07:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0d:	8b 58 08             	mov    0x8(%eax),%ebx
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	8b 40 04             	mov    0x4(%eax),%eax
80107c16:	29 c3                	sub    %eax,%ebx
80107c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1b:	8b 00                	mov    (%eax),%eax
80107c1d:	83 ec 0c             	sub    $0xc,%esp
80107c20:	51                   	push   %ecx
80107c21:	52                   	push   %edx
80107c22:	53                   	push   %ebx
80107c23:	50                   	push   %eax
80107c24:	ff 75 f0             	pushl  -0x10(%ebp)
80107c27:	e8 08 ff ff ff       	call   80107b34 <mappages>
80107c2c:	83 c4 20             	add    $0x20,%esp
80107c2f:	85 c0                	test   %eax,%eax
80107c31:	79 15                	jns    80107c48 <setupkvm+0x84>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107c33:	83 ec 0c             	sub    $0xc,%esp
80107c36:	ff 75 f0             	pushl  -0x10(%ebp)
80107c39:	e8 f4 04 00 00       	call   80108132 <freevm>
80107c3e:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c41:	b8 00 00 00 00       	mov    $0x0,%eax
80107c46:	eb 10                	jmp    80107c58 <setupkvm+0x94>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c48:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c4c:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107c53:	72 a9                	jb     80107bfe <setupkvm+0x3a>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c5b:	c9                   	leave  
80107c5c:	c3                   	ret    

80107c5d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c5d:	55                   	push   %ebp
80107c5e:	89 e5                	mov    %esp,%ebp
80107c60:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c63:	e8 5c ff ff ff       	call   80107bc4 <setupkvm>
80107c68:	a3 24 66 11 80       	mov    %eax,0x80116624
  switchkvm();
80107c6d:	e8 03 00 00 00       	call   80107c75 <switchkvm>
}
80107c72:	90                   	nop
80107c73:	c9                   	leave  
80107c74:	c3                   	ret    

80107c75 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c75:	55                   	push   %ebp
80107c76:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107c78:	a1 24 66 11 80       	mov    0x80116624,%eax
80107c7d:	05 00 00 00 80       	add    $0x80000000,%eax
80107c82:	50                   	push   %eax
80107c83:	e8 b4 fa ff ff       	call   8010773c <lcr3>
80107c88:	83 c4 04             	add    $0x4,%esp
}
80107c8b:	90                   	nop
80107c8c:	c9                   	leave  
80107c8d:	c3                   	ret    

80107c8e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c8e:	55                   	push   %ebp
80107c8f:	89 e5                	mov    %esp,%ebp
80107c91:	56                   	push   %esi
80107c92:	53                   	push   %ebx
80107c93:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107c96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c9a:	75 0d                	jne    80107ca9 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107c9c:	83 ec 0c             	sub    $0xc,%esp
80107c9f:	68 42 8c 10 80       	push   $0x80108c42
80107ca4:	e8 f7 88 ff ff       	call   801005a0 <panic>
  if(p->kstack == 0)
80107ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80107cac:	8b 40 08             	mov    0x8(%eax),%eax
80107caf:	85 c0                	test   %eax,%eax
80107cb1:	75 0d                	jne    80107cc0 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107cb3:	83 ec 0c             	sub    $0xc,%esp
80107cb6:	68 58 8c 10 80       	push   $0x80108c58
80107cbb:	e8 e0 88 ff ff       	call   801005a0 <panic>
  if(p->pgdir == 0)
80107cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc3:	8b 40 04             	mov    0x4(%eax),%eax
80107cc6:	85 c0                	test   %eax,%eax
80107cc8:	75 0d                	jne    80107cd7 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107cca:	83 ec 0c             	sub    $0xc,%esp
80107ccd:	68 6d 8c 10 80       	push   $0x80108c6d
80107cd2:	e8 c9 88 ff ff       	call   801005a0 <panic>

  pushcli();
80107cd7:	e8 e1 d3 ff ff       	call   801050bd <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107cdc:	e8 21 c5 ff ff       	call   80104202 <mycpu>
80107ce1:	89 c3                	mov    %eax,%ebx
80107ce3:	e8 1a c5 ff ff       	call   80104202 <mycpu>
80107ce8:	83 c0 08             	add    $0x8,%eax
80107ceb:	89 c6                	mov    %eax,%esi
80107ced:	e8 10 c5 ff ff       	call   80104202 <mycpu>
80107cf2:	83 c0 08             	add    $0x8,%eax
80107cf5:	c1 e8 10             	shr    $0x10,%eax
80107cf8:	88 45 f7             	mov    %al,-0x9(%ebp)
80107cfb:	e8 02 c5 ff ff       	call   80104202 <mycpu>
80107d00:	83 c0 08             	add    $0x8,%eax
80107d03:	c1 e8 18             	shr    $0x18,%eax
80107d06:	89 c2                	mov    %eax,%edx
80107d08:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107d0f:	67 00 
80107d11:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107d18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107d1c:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107d22:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d29:	83 e0 f0             	and    $0xfffffff0,%eax
80107d2c:	83 c8 09             	or     $0x9,%eax
80107d2f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d35:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d3c:	83 c8 10             	or     $0x10,%eax
80107d3f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d45:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d4c:	83 e0 9f             	and    $0xffffff9f,%eax
80107d4f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d55:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d5c:	83 c8 80             	or     $0xffffff80,%eax
80107d5f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d65:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d6c:	83 e0 f0             	and    $0xfffffff0,%eax
80107d6f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d75:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d7c:	83 e0 ef             	and    $0xffffffef,%eax
80107d7f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d85:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d8c:	83 e0 df             	and    $0xffffffdf,%eax
80107d8f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d95:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d9c:	83 c8 40             	or     $0x40,%eax
80107d9f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107da5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107dac:	83 e0 7f             	and    $0x7f,%eax
80107daf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107db5:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107dbb:	e8 42 c4 ff ff       	call   80104202 <mycpu>
80107dc0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107dc7:	83 e2 ef             	and    $0xffffffef,%edx
80107dca:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107dd0:	e8 2d c4 ff ff       	call   80104202 <mycpu>
80107dd5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107ddb:	e8 22 c4 ff ff       	call   80104202 <mycpu>
80107de0:	89 c2                	mov    %eax,%edx
80107de2:	8b 45 08             	mov    0x8(%ebp),%eax
80107de5:	8b 40 08             	mov    0x8(%eax),%eax
80107de8:	05 00 10 00 00       	add    $0x1000,%eax
80107ded:	89 42 0c             	mov    %eax,0xc(%edx)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107df0:	e8 0d c4 ff ff       	call   80104202 <mycpu>
80107df5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107dfb:	83 ec 0c             	sub    $0xc,%esp
80107dfe:	6a 28                	push   $0x28
80107e00:	e8 20 f9 ff ff       	call   80107725 <ltr>
80107e05:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107e08:	8b 45 08             	mov    0x8(%ebp),%eax
80107e0b:	8b 40 04             	mov    0x4(%eax),%eax
80107e0e:	05 00 00 00 80       	add    $0x80000000,%eax
80107e13:	83 ec 0c             	sub    $0xc,%esp
80107e16:	50                   	push   %eax
80107e17:	e8 20 f9 ff ff       	call   8010773c <lcr3>
80107e1c:	83 c4 10             	add    $0x10,%esp
  popcli();
80107e1f:	e8 e7 d2 ff ff       	call   8010510b <popcli>
}
80107e24:	90                   	nop
80107e25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107e28:	5b                   	pop    %ebx
80107e29:	5e                   	pop    %esi
80107e2a:	5d                   	pop    %ebp
80107e2b:	c3                   	ret    

80107e2c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e2c:	55                   	push   %ebp
80107e2d:	89 e5                	mov    %esp,%ebp
80107e2f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107e32:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e39:	76 0d                	jbe    80107e48 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107e3b:	83 ec 0c             	sub    $0xc,%esp
80107e3e:	68 81 8c 10 80       	push   $0x80108c81
80107e43:	e8 58 87 ff ff       	call   801005a0 <panic>
  mem = kalloc();
80107e48:	e8 35 ae ff ff       	call   80102c82 <kalloc>
80107e4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e50:	83 ec 04             	sub    $0x4,%esp
80107e53:	68 00 10 00 00       	push   $0x1000
80107e58:	6a 00                	push   $0x0
80107e5a:	ff 75 f4             	pushl  -0xc(%ebp)
80107e5d:	e8 67 d3 ff ff       	call   801051c9 <memset>
80107e62:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e68:	05 00 00 00 80       	add    $0x80000000,%eax
80107e6d:	83 ec 0c             	sub    $0xc,%esp
80107e70:	6a 06                	push   $0x6
80107e72:	50                   	push   %eax
80107e73:	68 00 10 00 00       	push   $0x1000
80107e78:	6a 00                	push   $0x0
80107e7a:	ff 75 08             	pushl  0x8(%ebp)
80107e7d:	e8 b2 fc ff ff       	call   80107b34 <mappages>
80107e82:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107e85:	83 ec 04             	sub    $0x4,%esp
80107e88:	ff 75 10             	pushl  0x10(%ebp)
80107e8b:	ff 75 0c             	pushl  0xc(%ebp)
80107e8e:	ff 75 f4             	pushl  -0xc(%ebp)
80107e91:	e8 f2 d3 ff ff       	call   80105288 <memmove>
80107e96:	83 c4 10             	add    $0x10,%esp
}
80107e99:	90                   	nop
80107e9a:	c9                   	leave  
80107e9b:	c3                   	ret    

80107e9c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e9c:	55                   	push   %ebp
80107e9d:	89 e5                	mov    %esp,%ebp
80107e9f:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ea5:	25 ff 0f 00 00       	and    $0xfff,%eax
80107eaa:	85 c0                	test   %eax,%eax
80107eac:	74 0d                	je     80107ebb <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107eae:	83 ec 0c             	sub    $0xc,%esp
80107eb1:	68 9c 8c 10 80       	push   $0x80108c9c
80107eb6:	e8 e5 86 ff ff       	call   801005a0 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107ebb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ec2:	e9 8f 00 00 00       	jmp    80107f56 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecd:	01 d0                	add    %edx,%eax
80107ecf:	83 ec 04             	sub    $0x4,%esp
80107ed2:	6a 00                	push   $0x0
80107ed4:	50                   	push   %eax
80107ed5:	ff 75 08             	pushl  0x8(%ebp)
80107ed8:	e8 c1 fb ff ff       	call   80107a9e <walkpgdir>
80107edd:	83 c4 10             	add    $0x10,%esp
80107ee0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ee3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ee7:	75 0d                	jne    80107ef6 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107ee9:	83 ec 0c             	sub    $0xc,%esp
80107eec:	68 bf 8c 10 80       	push   $0x80108cbf
80107ef1:	e8 aa 86 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80107ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef9:	8b 00                	mov    (%eax),%eax
80107efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f00:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f03:	8b 45 18             	mov    0x18(%ebp),%eax
80107f06:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f09:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f0e:	77 0b                	ja     80107f1b <loaduvm+0x7f>
      n = sz - i;
80107f10:	8b 45 18             	mov    0x18(%ebp),%eax
80107f13:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f19:	eb 07                	jmp    80107f22 <loaduvm+0x86>
    else
      n = PGSIZE;
80107f1b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107f22:	8b 55 14             	mov    0x14(%ebp),%edx
80107f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f28:	01 d0                	add    %edx,%eax
80107f2a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f2d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107f33:	ff 75 f0             	pushl  -0x10(%ebp)
80107f36:	50                   	push   %eax
80107f37:	52                   	push   %edx
80107f38:	ff 75 10             	pushl  0x10(%ebp)
80107f3b:	e8 ae 9f ff ff       	call   80101eee <readi>
80107f40:	83 c4 10             	add    $0x10,%esp
80107f43:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f46:	74 07                	je     80107f4f <loaduvm+0xb3>
      return -1;
80107f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f4d:	eb 18                	jmp    80107f67 <loaduvm+0xcb>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107f4f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f59:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f5c:	0f 82 65 ff ff ff    	jb     80107ec7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f62:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f67:	c9                   	leave  
80107f68:	c3                   	ret    

80107f69 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f69:	55                   	push   %ebp
80107f6a:	89 e5                	mov    %esp,%ebp
80107f6c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f6f:	8b 45 10             	mov    0x10(%ebp),%eax
80107f72:	85 c0                	test   %eax,%eax
80107f74:	79 0a                	jns    80107f80 <allocuvm+0x17>
    return 0;
80107f76:	b8 00 00 00 00       	mov    $0x0,%eax
80107f7b:	e9 ec 00 00 00       	jmp    8010806c <allocuvm+0x103>
  if(newsz < oldsz)
80107f80:	8b 45 10             	mov    0x10(%ebp),%eax
80107f83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f86:	73 08                	jae    80107f90 <allocuvm+0x27>
    return oldsz;
80107f88:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f8b:	e9 dc 00 00 00       	jmp    8010806c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f93:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107fa0:	e9 b8 00 00 00       	jmp    8010805d <allocuvm+0xf4>
    mem = kalloc();
80107fa5:	e8 d8 ac ff ff       	call   80102c82 <kalloc>
80107faa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107fad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fb1:	75 2e                	jne    80107fe1 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107fb3:	83 ec 0c             	sub    $0xc,%esp
80107fb6:	68 dd 8c 10 80       	push   $0x80108cdd
80107fbb:	e8 40 84 ff ff       	call   80100400 <cprintf>
80107fc0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107fc3:	83 ec 04             	sub    $0x4,%esp
80107fc6:	ff 75 0c             	pushl  0xc(%ebp)
80107fc9:	ff 75 10             	pushl  0x10(%ebp)
80107fcc:	ff 75 08             	pushl  0x8(%ebp)
80107fcf:	e8 9a 00 00 00       	call   8010806e <deallocuvm>
80107fd4:	83 c4 10             	add    $0x10,%esp
      return 0;
80107fd7:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdc:	e9 8b 00 00 00       	jmp    8010806c <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107fe1:	83 ec 04             	sub    $0x4,%esp
80107fe4:	68 00 10 00 00       	push   $0x1000
80107fe9:	6a 00                	push   $0x0
80107feb:	ff 75 f0             	pushl  -0x10(%ebp)
80107fee:	e8 d6 d1 ff ff       	call   801051c9 <memset>
80107ff3:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ff9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108002:	83 ec 0c             	sub    $0xc,%esp
80108005:	6a 06                	push   $0x6
80108007:	52                   	push   %edx
80108008:	68 00 10 00 00       	push   $0x1000
8010800d:	50                   	push   %eax
8010800e:	ff 75 08             	pushl  0x8(%ebp)
80108011:	e8 1e fb ff ff       	call   80107b34 <mappages>
80108016:	83 c4 20             	add    $0x20,%esp
80108019:	85 c0                	test   %eax,%eax
8010801b:	79 39                	jns    80108056 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010801d:	83 ec 0c             	sub    $0xc,%esp
80108020:	68 f5 8c 10 80       	push   $0x80108cf5
80108025:	e8 d6 83 ff ff       	call   80100400 <cprintf>
8010802a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010802d:	83 ec 04             	sub    $0x4,%esp
80108030:	ff 75 0c             	pushl  0xc(%ebp)
80108033:	ff 75 10             	pushl  0x10(%ebp)
80108036:	ff 75 08             	pushl  0x8(%ebp)
80108039:	e8 30 00 00 00       	call   8010806e <deallocuvm>
8010803e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108041:	83 ec 0c             	sub    $0xc,%esp
80108044:	ff 75 f0             	pushl  -0x10(%ebp)
80108047:	e8 9c ab ff ff       	call   80102be8 <kfree>
8010804c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010804f:	b8 00 00 00 00       	mov    $0x0,%eax
80108054:	eb 16                	jmp    8010806c <allocuvm+0x103>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108056:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108060:	3b 45 10             	cmp    0x10(%ebp),%eax
80108063:	0f 82 3c ff ff ff    	jb     80107fa5 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108069:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010806c:	c9                   	leave  
8010806d:	c3                   	ret    

8010806e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010806e:	55                   	push   %ebp
8010806f:	89 e5                	mov    %esp,%ebp
80108071:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108074:	8b 45 10             	mov    0x10(%ebp),%eax
80108077:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010807a:	72 08                	jb     80108084 <deallocuvm+0x16>
    return oldsz;
8010807c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010807f:	e9 ac 00 00 00       	jmp    80108130 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108084:	8b 45 10             	mov    0x10(%ebp),%eax
80108087:	05 ff 0f 00 00       	add    $0xfff,%eax
8010808c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108091:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108094:	e9 88 00 00 00       	jmp    80108121 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809c:	83 ec 04             	sub    $0x4,%esp
8010809f:	6a 00                	push   $0x0
801080a1:	50                   	push   %eax
801080a2:	ff 75 08             	pushl  0x8(%ebp)
801080a5:	e8 f4 f9 ff ff       	call   80107a9e <walkpgdir>
801080aa:	83 c4 10             	add    $0x10,%esp
801080ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801080b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080b4:	75 16                	jne    801080cc <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801080b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b9:	c1 e8 16             	shr    $0x16,%eax
801080bc:	83 c0 01             	add    $0x1,%eax
801080bf:	c1 e0 16             	shl    $0x16,%eax
801080c2:	2d 00 10 00 00       	sub    $0x1000,%eax
801080c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080ca:	eb 4e                	jmp    8010811a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801080cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cf:	8b 00                	mov    (%eax),%eax
801080d1:	83 e0 01             	and    $0x1,%eax
801080d4:	85 c0                	test   %eax,%eax
801080d6:	74 42                	je     8010811a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801080d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080db:	8b 00                	mov    (%eax),%eax
801080dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080e9:	75 0d                	jne    801080f8 <deallocuvm+0x8a>
        panic("kfree");
801080eb:	83 ec 0c             	sub    $0xc,%esp
801080ee:	68 11 8d 10 80       	push   $0x80108d11
801080f3:	e8 a8 84 ff ff       	call   801005a0 <panic>
      char *v = P2V(pa);
801080f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080fb:	05 00 00 00 80       	add    $0x80000000,%eax
80108100:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108103:	83 ec 0c             	sub    $0xc,%esp
80108106:	ff 75 e8             	pushl  -0x18(%ebp)
80108109:	e8 da aa ff ff       	call   80102be8 <kfree>
8010810e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108114:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010811a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108124:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108127:	0f 82 6c ff ff ff    	jb     80108099 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010812d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108130:	c9                   	leave  
80108131:	c3                   	ret    

80108132 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108132:	55                   	push   %ebp
80108133:	89 e5                	mov    %esp,%ebp
80108135:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108138:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010813c:	75 0d                	jne    8010814b <freevm+0x19>
    panic("freevm: no pgdir");
8010813e:	83 ec 0c             	sub    $0xc,%esp
80108141:	68 17 8d 10 80       	push   $0x80108d17
80108146:	e8 55 84 ff ff       	call   801005a0 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010814b:	83 ec 04             	sub    $0x4,%esp
8010814e:	6a 00                	push   $0x0
80108150:	68 00 00 00 80       	push   $0x80000000
80108155:	ff 75 08             	pushl  0x8(%ebp)
80108158:	e8 11 ff ff ff       	call   8010806e <deallocuvm>
8010815d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108160:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108167:	eb 48                	jmp    801081b1 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108173:	8b 45 08             	mov    0x8(%ebp),%eax
80108176:	01 d0                	add    %edx,%eax
80108178:	8b 00                	mov    (%eax),%eax
8010817a:	83 e0 01             	and    $0x1,%eax
8010817d:	85 c0                	test   %eax,%eax
8010817f:	74 2c                	je     801081ad <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108184:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010818b:	8b 45 08             	mov    0x8(%ebp),%eax
8010818e:	01 d0                	add    %edx,%eax
80108190:	8b 00                	mov    (%eax),%eax
80108192:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108197:	05 00 00 00 80       	add    $0x80000000,%eax
8010819c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010819f:	83 ec 0c             	sub    $0xc,%esp
801081a2:	ff 75 f0             	pushl  -0x10(%ebp)
801081a5:	e8 3e aa ff ff       	call   80102be8 <kfree>
801081aa:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801081ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081b1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801081b8:	76 af                	jbe    80108169 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801081ba:	83 ec 0c             	sub    $0xc,%esp
801081bd:	ff 75 08             	pushl  0x8(%ebp)
801081c0:	e8 23 aa ff ff       	call   80102be8 <kfree>
801081c5:	83 c4 10             	add    $0x10,%esp
}
801081c8:	90                   	nop
801081c9:	c9                   	leave  
801081ca:	c3                   	ret    

801081cb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801081cb:	55                   	push   %ebp
801081cc:	89 e5                	mov    %esp,%ebp
801081ce:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081d1:	83 ec 04             	sub    $0x4,%esp
801081d4:	6a 00                	push   $0x0
801081d6:	ff 75 0c             	pushl  0xc(%ebp)
801081d9:	ff 75 08             	pushl  0x8(%ebp)
801081dc:	e8 bd f8 ff ff       	call   80107a9e <walkpgdir>
801081e1:	83 c4 10             	add    $0x10,%esp
801081e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081eb:	75 0d                	jne    801081fa <clearpteu+0x2f>
    panic("clearpteu");
801081ed:	83 ec 0c             	sub    $0xc,%esp
801081f0:	68 28 8d 10 80       	push   $0x80108d28
801081f5:	e8 a6 83 ff ff       	call   801005a0 <panic>
  *pte &= ~PTE_U;
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	8b 00                	mov    (%eax),%eax
801081ff:	83 e0 fb             	and    $0xfffffffb,%eax
80108202:	89 c2                	mov    %eax,%edx
80108204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108207:	89 10                	mov    %edx,(%eax)
}
80108209:	90                   	nop
8010820a:	c9                   	leave  
8010820b:	c3                   	ret    

8010820c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz, uint sp)
{
8010820c:	55                   	push   %ebp
8010820d:	89 e5                	mov    %esp,%ebp
8010820f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem, *mem1;

  if((d = setupkvm()) == 0)
80108212:	e8 ad f9 ff ff       	call   80107bc4 <setupkvm>
80108217:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010821a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010821e:	75 0a                	jne    8010822a <copyuvm+0x1e>
    return 0;
80108220:	b8 00 00 00 00       	mov    $0x0,%eax
80108225:	e9 cd 01 00 00       	jmp    801083f7 <copyuvm+0x1eb>
  
  for(i = 0; i < sz; i += PGSIZE){
8010822a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108231:	e9 bf 00 00 00       	jmp    801082f5 <copyuvm+0xe9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	83 ec 04             	sub    $0x4,%esp
8010823c:	6a 00                	push   $0x0
8010823e:	50                   	push   %eax
8010823f:	ff 75 08             	pushl  0x8(%ebp)
80108242:	e8 57 f8 ff ff       	call   80107a9e <walkpgdir>
80108247:	83 c4 10             	add    $0x10,%esp
8010824a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010824d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108251:	75 0d                	jne    80108260 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108253:	83 ec 0c             	sub    $0xc,%esp
80108256:	68 32 8d 10 80       	push   $0x80108d32
8010825b:	e8 40 83 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
80108260:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108263:	8b 00                	mov    (%eax),%eax
80108265:	83 e0 01             	and    $0x1,%eax
80108268:	85 c0                	test   %eax,%eax
8010826a:	75 0d                	jne    80108279 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010826c:	83 ec 0c             	sub    $0xc,%esp
8010826f:	68 4c 8d 10 80       	push   $0x80108d4c
80108274:	e8 27 83 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108279:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827c:	8b 00                	mov    (%eax),%eax
8010827e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108283:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108286:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108289:	8b 00                	mov    (%eax),%eax
8010828b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108290:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108293:	e8 ea a9 ff ff       	call   80102c82 <kalloc>
80108298:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010829b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010829f:	0f 84 35 01 00 00    	je     801083da <copyuvm+0x1ce>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801082a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082a8:	05 00 00 00 80       	add    $0x80000000,%eax
801082ad:	83 ec 04             	sub    $0x4,%esp
801082b0:	68 00 10 00 00       	push   $0x1000
801082b5:	50                   	push   %eax
801082b6:	ff 75 e0             	pushl  -0x20(%ebp)
801082b9:	e8 ca cf ff ff       	call   80105288 <memmove>
801082be:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801082c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801082c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082c7:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d0:	83 ec 0c             	sub    $0xc,%esp
801082d3:	52                   	push   %edx
801082d4:	51                   	push   %ecx
801082d5:	68 00 10 00 00       	push   $0x1000
801082da:	50                   	push   %eax
801082db:	ff 75 f0             	pushl  -0x10(%ebp)
801082de:	e8 51 f8 ff ff       	call   80107b34 <mappages>
801082e3:	83 c4 20             	add    $0x20,%esp
801082e6:	85 c0                	test   %eax,%eax
801082e8:	0f 88 ef 00 00 00    	js     801083dd <copyuvm+0x1d1>
  char *mem, *mem1;

  if((d = setupkvm()) == 0)
    return 0;
  
  for(i = 0; i < sz; i += PGSIZE){
801082ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082fb:	0f 82 35 ff ff ff    	jb     80108236 <copyuvm+0x2a>
      goto bad;
  }
/////////////////////////
//lab2 addition
//  uint check = STACKTOP - myproc()->stack_pages * PGSIZE;
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
80108301:	8b 45 10             	mov    0x10(%ebp),%eax
80108304:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108309:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010830c:	e9 b7 00 00 00       	jmp    801083c8 <copyuvm+0x1bc>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108314:	83 ec 04             	sub    $0x4,%esp
80108317:	6a 00                	push   $0x0
80108319:	50                   	push   %eax
8010831a:	ff 75 08             	pushl  0x8(%ebp)
8010831d:	e8 7c f7 ff ff       	call   80107a9e <walkpgdir>
80108322:	83 c4 10             	add    $0x10,%esp
80108325:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108328:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010832c:	75 0d                	jne    8010833b <copyuvm+0x12f>
      panic("copyuvm: pte should exist");
8010832e:	83 ec 0c             	sub    $0xc,%esp
80108331:	68 32 8d 10 80       	push   $0x80108d32
80108336:	e8 65 82 ff ff       	call   801005a0 <panic>
    if(!(*pte & PTE_P))
8010833b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833e:	8b 00                	mov    (%eax),%eax
80108340:	83 e0 01             	and    $0x1,%eax
80108343:	85 c0                	test   %eax,%eax
80108345:	75 0d                	jne    80108354 <copyuvm+0x148>
      panic("copyuvm: page not present");
80108347:	83 ec 0c             	sub    $0xc,%esp
8010834a:	68 4c 8d 10 80       	push   $0x80108d4c
8010834f:	e8 4c 82 ff ff       	call   801005a0 <panic>
    pa = PTE_ADDR(*pte);
80108354:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108357:	8b 00                	mov    (%eax),%eax
80108359:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108361:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108364:	8b 00                	mov    (%eax),%eax
80108366:	25 ff 0f 00 00       	and    $0xfff,%eax
8010836b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem1 = kalloc()) == 0)
8010836e:	e8 0f a9 ff ff       	call   80102c82 <kalloc>
80108373:	89 45 dc             	mov    %eax,-0x24(%ebp)
80108376:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010837a:	74 64                	je     801083e0 <copyuvm+0x1d4>
      goto bad;
    memmove(mem1, (char*)P2V(pa), PGSIZE);
8010837c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010837f:	05 00 00 00 80       	add    $0x80000000,%eax
80108384:	83 ec 04             	sub    $0x4,%esp
80108387:	68 00 10 00 00       	push   $0x1000
8010838c:	50                   	push   %eax
8010838d:	ff 75 dc             	pushl  -0x24(%ebp)
80108390:	e8 f3 ce ff ff       	call   80105288 <memmove>
80108395:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem1), flags) < 0)
80108398:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010839b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010839e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801083a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a7:	83 ec 0c             	sub    $0xc,%esp
801083aa:	52                   	push   %edx
801083ab:	51                   	push   %ecx
801083ac:	68 00 10 00 00       	push   $0x1000
801083b1:	50                   	push   %eax
801083b2:	ff 75 f0             	pushl  -0x10(%ebp)
801083b5:	e8 7a f7 ff ff       	call   80107b34 <mappages>
801083ba:	83 c4 20             	add    $0x20,%esp
801083bd:	85 c0                	test   %eax,%eax
801083bf:	78 22                	js     801083e3 <copyuvm+0x1d7>
      goto bad;
  }
/////////////////////////
//lab2 addition
//  uint check = STACKTOP - myproc()->stack_pages * PGSIZE;
  for(i = PGROUNDDOWN(sp); i < STACKTOP; i += PGSIZE){
801083c1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083c8:	81 7d f4 fe ff ff 7f 	cmpl   $0x7ffffffe,-0xc(%ebp)
801083cf:	0f 86 3c ff ff ff    	jbe    80108311 <copyuvm+0x105>
    memmove(mem1, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem1), flags) < 0)
      goto bad;
  }		
//////////////////////////
  return d;
801083d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d8:	eb 1d                	jmp    801083f7 <copyuvm+0x1eb>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801083da:	90                   	nop
801083db:	eb 07                	jmp    801083e4 <copyuvm+0x1d8>
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
801083dd:	90                   	nop
801083de:	eb 04                	jmp    801083e4 <copyuvm+0x1d8>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem1 = kalloc()) == 0)
      goto bad;
801083e0:	90                   	nop
801083e1:	eb 01                	jmp    801083e4 <copyuvm+0x1d8>
    memmove(mem1, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem1), flags) < 0)
      goto bad;
801083e3:	90                   	nop
  }		
//////////////////////////
  return d;

bad:
  freevm(d);
801083e4:	83 ec 0c             	sub    $0xc,%esp
801083e7:	ff 75 f0             	pushl  -0x10(%ebp)
801083ea:	e8 43 fd ff ff       	call   80108132 <freevm>
801083ef:	83 c4 10             	add    $0x10,%esp
  return 0;
801083f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083f7:	c9                   	leave  
801083f8:	c3                   	ret    

801083f9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083f9:	55                   	push   %ebp
801083fa:	89 e5                	mov    %esp,%ebp
801083fc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083ff:	83 ec 04             	sub    $0x4,%esp
80108402:	6a 00                	push   $0x0
80108404:	ff 75 0c             	pushl  0xc(%ebp)
80108407:	ff 75 08             	pushl  0x8(%ebp)
8010840a:	e8 8f f6 ff ff       	call   80107a9e <walkpgdir>
8010840f:	83 c4 10             	add    $0x10,%esp
80108412:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	8b 00                	mov    (%eax),%eax
8010841a:	83 e0 01             	and    $0x1,%eax
8010841d:	85 c0                	test   %eax,%eax
8010841f:	75 07                	jne    80108428 <uva2ka+0x2f>
    return 0;
80108421:	b8 00 00 00 00       	mov    $0x0,%eax
80108426:	eb 22                	jmp    8010844a <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	8b 00                	mov    (%eax),%eax
8010842d:	83 e0 04             	and    $0x4,%eax
80108430:	85 c0                	test   %eax,%eax
80108432:	75 07                	jne    8010843b <uva2ka+0x42>
    return 0;
80108434:	b8 00 00 00 00       	mov    $0x0,%eax
80108439:	eb 0f                	jmp    8010844a <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	8b 00                	mov    (%eax),%eax
80108440:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108445:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010844a:	c9                   	leave  
8010844b:	c3                   	ret    

8010844c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010844c:	55                   	push   %ebp
8010844d:	89 e5                	mov    %esp,%ebp
8010844f:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108452:	8b 45 10             	mov    0x10(%ebp),%eax
80108455:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108458:	eb 7f                	jmp    801084d9 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010845a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010845d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108462:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108468:	83 ec 08             	sub    $0x8,%esp
8010846b:	50                   	push   %eax
8010846c:	ff 75 08             	pushl  0x8(%ebp)
8010846f:	e8 85 ff ff ff       	call   801083f9 <uva2ka>
80108474:	83 c4 10             	add    $0x10,%esp
80108477:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010847a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010847e:	75 07                	jne    80108487 <copyout+0x3b>
      return -1;
80108480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108485:	eb 61                	jmp    801084e8 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010848a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010848d:	05 00 10 00 00       	add    $0x1000,%eax
80108492:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108498:	3b 45 14             	cmp    0x14(%ebp),%eax
8010849b:	76 06                	jbe    801084a3 <copyout+0x57>
      n = len;
8010849d:	8b 45 14             	mov    0x14(%ebp),%eax
801084a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801084a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
801084a9:	89 c2                	mov    %eax,%edx
801084ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084ae:	01 d0                	add    %edx,%eax
801084b0:	83 ec 04             	sub    $0x4,%esp
801084b3:	ff 75 f0             	pushl  -0x10(%ebp)
801084b6:	ff 75 f4             	pushl  -0xc(%ebp)
801084b9:	50                   	push   %eax
801084ba:	e8 c9 cd ff ff       	call   80105288 <memmove>
801084bf:	83 c4 10             	add    $0x10,%esp
    len -= n;
801084c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c5:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084cb:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084d1:	05 00 10 00 00       	add    $0x1000,%eax
801084d6:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801084d9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084dd:	0f 85 77 ff ff ff    	jne    8010845a <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801084e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084e8:	c9                   	leave  
801084e9:	c3                   	ret    

801084ea <shminit>:
    char *frame;
    int refcnt;
  } shm_pages[64];
} shm_table;

void shminit() {
801084ea:	55                   	push   %ebp
801084eb:	89 e5                	mov    %esp,%ebp
801084ed:	83 ec 18             	sub    $0x18,%esp
  int i;
  initlock(&(shm_table.lock), "SHM lock");
801084f0:	83 ec 08             	sub    $0x8,%esp
801084f3:	68 66 8d 10 80       	push   $0x80108d66
801084f8:	68 40 66 11 80       	push   $0x80116640
801084fd:	e8 2e ca ff ff       	call   80104f30 <initlock>
80108502:	83 c4 10             	add    $0x10,%esp
  acquire(&(shm_table.lock));
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	68 40 66 11 80       	push   $0x80116640
8010850d:	e8 40 ca ff ff       	call   80104f52 <acquire>
80108512:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i< 64; i++) {
80108515:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851c:	eb 49                	jmp    80108567 <shminit+0x7d>
    shm_table.shm_pages[i].id =0;
8010851e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108521:	89 d0                	mov    %edx,%eax
80108523:	01 c0                	add    %eax,%eax
80108525:	01 d0                	add    %edx,%eax
80108527:	c1 e0 02             	shl    $0x2,%eax
8010852a:	05 74 66 11 80       	add    $0x80116674,%eax
8010852f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].frame =0;
80108535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108538:	89 d0                	mov    %edx,%eax
8010853a:	01 c0                	add    %eax,%eax
8010853c:	01 d0                	add    %edx,%eax
8010853e:	c1 e0 02             	shl    $0x2,%eax
80108541:	05 78 66 11 80       	add    $0x80116678,%eax
80108546:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    shm_table.shm_pages[i].refcnt =0;
8010854c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010854f:	89 d0                	mov    %edx,%eax
80108551:	01 c0                	add    %eax,%eax
80108553:	01 d0                	add    %edx,%eax
80108555:	c1 e0 02             	shl    $0x2,%eax
80108558:	05 7c 66 11 80       	add    $0x8011667c,%eax
8010855d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

void shminit() {
  int i;
  initlock(&(shm_table.lock), "SHM lock");
  acquire(&(shm_table.lock));
  for (i = 0; i< 64; i++) {
80108563:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108567:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010856b:	7e b1                	jle    8010851e <shminit+0x34>
    shm_table.shm_pages[i].id =0;
    shm_table.shm_pages[i].frame =0;
    shm_table.shm_pages[i].refcnt =0;
  }
  release(&(shm_table.lock));
8010856d:	83 ec 0c             	sub    $0xc,%esp
80108570:	68 40 66 11 80       	push   $0x80116640
80108575:	e8 46 ca ff ff       	call   80104fc0 <release>
8010857a:	83 c4 10             	add    $0x10,%esp
}
8010857d:	90                   	nop
8010857e:	c9                   	leave  
8010857f:	c3                   	ret    

80108580 <shm_open>:

int shm_open(int id, char **pointer) {
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
//you write this




return 0; //added to remove compiler warning -- you should decide what to return
80108583:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108588:	5d                   	pop    %ebp
80108589:	c3                   	ret    

8010858a <shm_close>:


int shm_close(int id) {
8010858a:	55                   	push   %ebp
8010858b:	89 e5                	mov    %esp,%ebp
//you write this too!




return 0; //added to remove compiler warning -- you should decide what to return
8010858d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108592:	5d                   	pop    %ebp
80108593:	c3                   	ret    
