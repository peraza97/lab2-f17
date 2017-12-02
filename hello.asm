
_hello:     file format elf32-i386


Disassembly of section .text:

00001000 <print>:
#include "types.h"
#include "user.h"

void print(){
    1000:	55                   	push   %ebp
    1001:	89 e5                	mov    %esp,%ebp
    1003:	83 ec 18             	sub    $0x18,%esp
    int a,b,c,d;
    a = 1;
    1006:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    b = 1;
    100d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    c = 1;
    1014:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    d = 1;
    101b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    printf(1,"hello world%d%d%d%d\n",a,b,c,d);
    1022:	83 ec 08             	sub    $0x8,%esp
    1025:	ff 75 e8             	pushl  -0x18(%ebp)
    1028:	ff 75 ec             	pushl  -0x14(%ebp)
    102b:	ff 75 f0             	pushl  -0x10(%ebp)
    102e:	ff 75 f4             	pushl  -0xc(%ebp)
    1031:	68 46 18 00 00       	push   $0x1846
    1036:	6a 01                	push   $0x1
    1038:	e8 04 04 00 00       	call   1441 <printf>
    103d:	83 c4 20             	add    $0x20,%esp
    print();
    1040:	e8 bb ff ff ff       	call   1000 <print>
    
}
    1045:	90                   	nop
    1046:	c9                   	leave  
    1047:	c3                   	ret    

00001048 <main>:

int main(int argc, char *argv[]){
    1048:	8d 4c 24 04          	lea    0x4(%esp),%ecx
    104c:	83 e4 f0             	and    $0xfffffff0,%esp
    104f:	ff 71 fc             	pushl  -0x4(%ecx)
    1052:	55                   	push   %ebp
    1053:	89 e5                	mov    %esp,%ebp
    1055:	51                   	push   %ecx
    1056:	83 ec 04             	sub    $0x4,%esp
    print();
    1059:	e8 a2 ff ff ff       	call   1000 <print>
    exit();
    105e:	e8 57 02 00 00       	call   12ba <exit>

00001063 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1063:	55                   	push   %ebp
    1064:	89 e5                	mov    %esp,%ebp
    1066:	57                   	push   %edi
    1067:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1068:	8b 4d 08             	mov    0x8(%ebp),%ecx
    106b:	8b 55 10             	mov    0x10(%ebp),%edx
    106e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1071:	89 cb                	mov    %ecx,%ebx
    1073:	89 df                	mov    %ebx,%edi
    1075:	89 d1                	mov    %edx,%ecx
    1077:	fc                   	cld    
    1078:	f3 aa                	rep stos %al,%es:(%edi)
    107a:	89 ca                	mov    %ecx,%edx
    107c:	89 fb                	mov    %edi,%ebx
    107e:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1081:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1084:	90                   	nop
    1085:	5b                   	pop    %ebx
    1086:	5f                   	pop    %edi
    1087:	5d                   	pop    %ebp
    1088:	c3                   	ret    

00001089 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1089:	55                   	push   %ebp
    108a:	89 e5                	mov    %esp,%ebp
    108c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    108f:	8b 45 08             	mov    0x8(%ebp),%eax
    1092:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1095:	90                   	nop
    1096:	8b 45 08             	mov    0x8(%ebp),%eax
    1099:	8d 50 01             	lea    0x1(%eax),%edx
    109c:	89 55 08             	mov    %edx,0x8(%ebp)
    109f:	8b 55 0c             	mov    0xc(%ebp),%edx
    10a2:	8d 4a 01             	lea    0x1(%edx),%ecx
    10a5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    10a8:	0f b6 12             	movzbl (%edx),%edx
    10ab:	88 10                	mov    %dl,(%eax)
    10ad:	0f b6 00             	movzbl (%eax),%eax
    10b0:	84 c0                	test   %al,%al
    10b2:	75 e2                	jne    1096 <strcpy+0xd>
    ;
  return os;
    10b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10b7:	c9                   	leave  
    10b8:	c3                   	ret    

000010b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    10b9:	55                   	push   %ebp
    10ba:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    10bc:	eb 08                	jmp    10c6 <strcmp+0xd>
    p++, q++;
    10be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    10c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    10c6:	8b 45 08             	mov    0x8(%ebp),%eax
    10c9:	0f b6 00             	movzbl (%eax),%eax
    10cc:	84 c0                	test   %al,%al
    10ce:	74 10                	je     10e0 <strcmp+0x27>
    10d0:	8b 45 08             	mov    0x8(%ebp),%eax
    10d3:	0f b6 10             	movzbl (%eax),%edx
    10d6:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d9:	0f b6 00             	movzbl (%eax),%eax
    10dc:	38 c2                	cmp    %al,%dl
    10de:	74 de                	je     10be <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    10e0:	8b 45 08             	mov    0x8(%ebp),%eax
    10e3:	0f b6 00             	movzbl (%eax),%eax
    10e6:	0f b6 d0             	movzbl %al,%edx
    10e9:	8b 45 0c             	mov    0xc(%ebp),%eax
    10ec:	0f b6 00             	movzbl (%eax),%eax
    10ef:	0f b6 c0             	movzbl %al,%eax
    10f2:	29 c2                	sub    %eax,%edx
    10f4:	89 d0                	mov    %edx,%eax
}
    10f6:	5d                   	pop    %ebp
    10f7:	c3                   	ret    

000010f8 <strlen>:

uint
strlen(char *s)
{
    10f8:	55                   	push   %ebp
    10f9:	89 e5                	mov    %esp,%ebp
    10fb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1105:	eb 04                	jmp    110b <strlen+0x13>
    1107:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    110b:	8b 55 fc             	mov    -0x4(%ebp),%edx
    110e:	8b 45 08             	mov    0x8(%ebp),%eax
    1111:	01 d0                	add    %edx,%eax
    1113:	0f b6 00             	movzbl (%eax),%eax
    1116:	84 c0                	test   %al,%al
    1118:	75 ed                	jne    1107 <strlen+0xf>
    ;
  return n;
    111a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    111d:	c9                   	leave  
    111e:	c3                   	ret    

0000111f <memset>:

void*
memset(void *dst, int c, uint n)
{
    111f:	55                   	push   %ebp
    1120:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    1122:	8b 45 10             	mov    0x10(%ebp),%eax
    1125:	50                   	push   %eax
    1126:	ff 75 0c             	pushl  0xc(%ebp)
    1129:	ff 75 08             	pushl  0x8(%ebp)
    112c:	e8 32 ff ff ff       	call   1063 <stosb>
    1131:	83 c4 0c             	add    $0xc,%esp
  return dst;
    1134:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1137:	c9                   	leave  
    1138:	c3                   	ret    

00001139 <strchr>:

char*
strchr(const char *s, char c)
{
    1139:	55                   	push   %ebp
    113a:	89 e5                	mov    %esp,%ebp
    113c:	83 ec 04             	sub    $0x4,%esp
    113f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1142:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1145:	eb 14                	jmp    115b <strchr+0x22>
    if(*s == c)
    1147:	8b 45 08             	mov    0x8(%ebp),%eax
    114a:	0f b6 00             	movzbl (%eax),%eax
    114d:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1150:	75 05                	jne    1157 <strchr+0x1e>
      return (char*)s;
    1152:	8b 45 08             	mov    0x8(%ebp),%eax
    1155:	eb 13                	jmp    116a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1157:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    115b:	8b 45 08             	mov    0x8(%ebp),%eax
    115e:	0f b6 00             	movzbl (%eax),%eax
    1161:	84 c0                	test   %al,%al
    1163:	75 e2                	jne    1147 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1165:	b8 00 00 00 00       	mov    $0x0,%eax
}
    116a:	c9                   	leave  
    116b:	c3                   	ret    

0000116c <gets>:

char*
gets(char *buf, int max)
{
    116c:	55                   	push   %ebp
    116d:	89 e5                	mov    %esp,%ebp
    116f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1172:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1179:	eb 42                	jmp    11bd <gets+0x51>
    cc = read(0, &c, 1);
    117b:	83 ec 04             	sub    $0x4,%esp
    117e:	6a 01                	push   $0x1
    1180:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1183:	50                   	push   %eax
    1184:	6a 00                	push   $0x0
    1186:	e8 47 01 00 00       	call   12d2 <read>
    118b:	83 c4 10             	add    $0x10,%esp
    118e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1191:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1195:	7e 33                	jle    11ca <gets+0x5e>
      break;
    buf[i++] = c;
    1197:	8b 45 f4             	mov    -0xc(%ebp),%eax
    119a:	8d 50 01             	lea    0x1(%eax),%edx
    119d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    11a0:	89 c2                	mov    %eax,%edx
    11a2:	8b 45 08             	mov    0x8(%ebp),%eax
    11a5:	01 c2                	add    %eax,%edx
    11a7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11ab:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    11ad:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11b1:	3c 0a                	cmp    $0xa,%al
    11b3:	74 16                	je     11cb <gets+0x5f>
    11b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    11b9:	3c 0d                	cmp    $0xd,%al
    11bb:	74 0e                	je     11cb <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    11bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11c0:	83 c0 01             	add    $0x1,%eax
    11c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
    11c6:	7c b3                	jl     117b <gets+0xf>
    11c8:	eb 01                	jmp    11cb <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    11ca:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    11cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11ce:	8b 45 08             	mov    0x8(%ebp),%eax
    11d1:	01 d0                	add    %edx,%eax
    11d3:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    11d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11d9:	c9                   	leave  
    11da:	c3                   	ret    

000011db <stat>:

int
stat(char *n, struct stat *st)
{
    11db:	55                   	push   %ebp
    11dc:	89 e5                	mov    %esp,%ebp
    11de:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    11e1:	83 ec 08             	sub    $0x8,%esp
    11e4:	6a 00                	push   $0x0
    11e6:	ff 75 08             	pushl  0x8(%ebp)
    11e9:	e8 0c 01 00 00       	call   12fa <open>
    11ee:	83 c4 10             	add    $0x10,%esp
    11f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11f8:	79 07                	jns    1201 <stat+0x26>
    return -1;
    11fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11ff:	eb 25                	jmp    1226 <stat+0x4b>
  r = fstat(fd, st);
    1201:	83 ec 08             	sub    $0x8,%esp
    1204:	ff 75 0c             	pushl  0xc(%ebp)
    1207:	ff 75 f4             	pushl  -0xc(%ebp)
    120a:	e8 03 01 00 00       	call   1312 <fstat>
    120f:	83 c4 10             	add    $0x10,%esp
    1212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1215:	83 ec 0c             	sub    $0xc,%esp
    1218:	ff 75 f4             	pushl  -0xc(%ebp)
    121b:	e8 c2 00 00 00       	call   12e2 <close>
    1220:	83 c4 10             	add    $0x10,%esp
  return r;
    1223:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1226:	c9                   	leave  
    1227:	c3                   	ret    

00001228 <atoi>:

int
atoi(const char *s)
{
    1228:	55                   	push   %ebp
    1229:	89 e5                	mov    %esp,%ebp
    122b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    122e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1235:	eb 25                	jmp    125c <atoi+0x34>
    n = n*10 + *s++ - '0';
    1237:	8b 55 fc             	mov    -0x4(%ebp),%edx
    123a:	89 d0                	mov    %edx,%eax
    123c:	c1 e0 02             	shl    $0x2,%eax
    123f:	01 d0                	add    %edx,%eax
    1241:	01 c0                	add    %eax,%eax
    1243:	89 c1                	mov    %eax,%ecx
    1245:	8b 45 08             	mov    0x8(%ebp),%eax
    1248:	8d 50 01             	lea    0x1(%eax),%edx
    124b:	89 55 08             	mov    %edx,0x8(%ebp)
    124e:	0f b6 00             	movzbl (%eax),%eax
    1251:	0f be c0             	movsbl %al,%eax
    1254:	01 c8                	add    %ecx,%eax
    1256:	83 e8 30             	sub    $0x30,%eax
    1259:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    125c:	8b 45 08             	mov    0x8(%ebp),%eax
    125f:	0f b6 00             	movzbl (%eax),%eax
    1262:	3c 2f                	cmp    $0x2f,%al
    1264:	7e 0a                	jle    1270 <atoi+0x48>
    1266:	8b 45 08             	mov    0x8(%ebp),%eax
    1269:	0f b6 00             	movzbl (%eax),%eax
    126c:	3c 39                	cmp    $0x39,%al
    126e:	7e c7                	jle    1237 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1273:	c9                   	leave  
    1274:	c3                   	ret    

00001275 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1275:	55                   	push   %ebp
    1276:	89 e5                	mov    %esp,%ebp
    1278:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    127b:	8b 45 08             	mov    0x8(%ebp),%eax
    127e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1281:	8b 45 0c             	mov    0xc(%ebp),%eax
    1284:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1287:	eb 17                	jmp    12a0 <memmove+0x2b>
    *dst++ = *src++;
    1289:	8b 45 fc             	mov    -0x4(%ebp),%eax
    128c:	8d 50 01             	lea    0x1(%eax),%edx
    128f:	89 55 fc             	mov    %edx,-0x4(%ebp)
    1292:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1295:	8d 4a 01             	lea    0x1(%edx),%ecx
    1298:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    129b:	0f b6 12             	movzbl (%edx),%edx
    129e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    12a0:	8b 45 10             	mov    0x10(%ebp),%eax
    12a3:	8d 50 ff             	lea    -0x1(%eax),%edx
    12a6:	89 55 10             	mov    %edx,0x10(%ebp)
    12a9:	85 c0                	test   %eax,%eax
    12ab:	7f dc                	jg     1289 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    12ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12b0:	c9                   	leave  
    12b1:	c3                   	ret    

000012b2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    12b2:	b8 01 00 00 00       	mov    $0x1,%eax
    12b7:	cd 40                	int    $0x40
    12b9:	c3                   	ret    

000012ba <exit>:
SYSCALL(exit)
    12ba:	b8 02 00 00 00       	mov    $0x2,%eax
    12bf:	cd 40                	int    $0x40
    12c1:	c3                   	ret    

000012c2 <wait>:
SYSCALL(wait)
    12c2:	b8 03 00 00 00       	mov    $0x3,%eax
    12c7:	cd 40                	int    $0x40
    12c9:	c3                   	ret    

000012ca <pipe>:
SYSCALL(pipe)
    12ca:	b8 04 00 00 00       	mov    $0x4,%eax
    12cf:	cd 40                	int    $0x40
    12d1:	c3                   	ret    

000012d2 <read>:
SYSCALL(read)
    12d2:	b8 05 00 00 00       	mov    $0x5,%eax
    12d7:	cd 40                	int    $0x40
    12d9:	c3                   	ret    

000012da <write>:
SYSCALL(write)
    12da:	b8 10 00 00 00       	mov    $0x10,%eax
    12df:	cd 40                	int    $0x40
    12e1:	c3                   	ret    

000012e2 <close>:
SYSCALL(close)
    12e2:	b8 15 00 00 00       	mov    $0x15,%eax
    12e7:	cd 40                	int    $0x40
    12e9:	c3                   	ret    

000012ea <kill>:
SYSCALL(kill)
    12ea:	b8 06 00 00 00       	mov    $0x6,%eax
    12ef:	cd 40                	int    $0x40
    12f1:	c3                   	ret    

000012f2 <exec>:
SYSCALL(exec)
    12f2:	b8 07 00 00 00       	mov    $0x7,%eax
    12f7:	cd 40                	int    $0x40
    12f9:	c3                   	ret    

000012fa <open>:
SYSCALL(open)
    12fa:	b8 0f 00 00 00       	mov    $0xf,%eax
    12ff:	cd 40                	int    $0x40
    1301:	c3                   	ret    

00001302 <mknod>:
SYSCALL(mknod)
    1302:	b8 11 00 00 00       	mov    $0x11,%eax
    1307:	cd 40                	int    $0x40
    1309:	c3                   	ret    

0000130a <unlink>:
SYSCALL(unlink)
    130a:	b8 12 00 00 00       	mov    $0x12,%eax
    130f:	cd 40                	int    $0x40
    1311:	c3                   	ret    

00001312 <fstat>:
SYSCALL(fstat)
    1312:	b8 08 00 00 00       	mov    $0x8,%eax
    1317:	cd 40                	int    $0x40
    1319:	c3                   	ret    

0000131a <link>:
SYSCALL(link)
    131a:	b8 13 00 00 00       	mov    $0x13,%eax
    131f:	cd 40                	int    $0x40
    1321:	c3                   	ret    

00001322 <mkdir>:
SYSCALL(mkdir)
    1322:	b8 14 00 00 00       	mov    $0x14,%eax
    1327:	cd 40                	int    $0x40
    1329:	c3                   	ret    

0000132a <chdir>:
SYSCALL(chdir)
    132a:	b8 09 00 00 00       	mov    $0x9,%eax
    132f:	cd 40                	int    $0x40
    1331:	c3                   	ret    

00001332 <dup>:
SYSCALL(dup)
    1332:	b8 0a 00 00 00       	mov    $0xa,%eax
    1337:	cd 40                	int    $0x40
    1339:	c3                   	ret    

0000133a <getpid>:
SYSCALL(getpid)
    133a:	b8 0b 00 00 00       	mov    $0xb,%eax
    133f:	cd 40                	int    $0x40
    1341:	c3                   	ret    

00001342 <sbrk>:
SYSCALL(sbrk)
    1342:	b8 0c 00 00 00       	mov    $0xc,%eax
    1347:	cd 40                	int    $0x40
    1349:	c3                   	ret    

0000134a <sleep>:
SYSCALL(sleep)
    134a:	b8 0d 00 00 00       	mov    $0xd,%eax
    134f:	cd 40                	int    $0x40
    1351:	c3                   	ret    

00001352 <uptime>:
SYSCALL(uptime)
    1352:	b8 0e 00 00 00       	mov    $0xe,%eax
    1357:	cd 40                	int    $0x40
    1359:	c3                   	ret    

0000135a <shm_open>:
SYSCALL(shm_open)
    135a:	b8 16 00 00 00       	mov    $0x16,%eax
    135f:	cd 40                	int    $0x40
    1361:	c3                   	ret    

00001362 <shm_close>:
SYSCALL(shm_close)	
    1362:	b8 17 00 00 00       	mov    $0x17,%eax
    1367:	cd 40                	int    $0x40
    1369:	c3                   	ret    

0000136a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    136a:	55                   	push   %ebp
    136b:	89 e5                	mov    %esp,%ebp
    136d:	83 ec 18             	sub    $0x18,%esp
    1370:	8b 45 0c             	mov    0xc(%ebp),%eax
    1373:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1376:	83 ec 04             	sub    $0x4,%esp
    1379:	6a 01                	push   $0x1
    137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
    137e:	50                   	push   %eax
    137f:	ff 75 08             	pushl  0x8(%ebp)
    1382:	e8 53 ff ff ff       	call   12da <write>
    1387:	83 c4 10             	add    $0x10,%esp
}
    138a:	90                   	nop
    138b:	c9                   	leave  
    138c:	c3                   	ret    

0000138d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    138d:	55                   	push   %ebp
    138e:	89 e5                	mov    %esp,%ebp
    1390:	53                   	push   %ebx
    1391:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1394:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    139b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    139f:	74 17                	je     13b8 <printint+0x2b>
    13a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    13a5:	79 11                	jns    13b8 <printint+0x2b>
    neg = 1;
    13a7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    13ae:	8b 45 0c             	mov    0xc(%ebp),%eax
    13b1:	f7 d8                	neg    %eax
    13b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13b6:	eb 06                	jmp    13be <printint+0x31>
  } else {
    x = xx;
    13b8:	8b 45 0c             	mov    0xc(%ebp),%eax
    13bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    13be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    13c5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    13c8:	8d 41 01             	lea    0x1(%ecx),%eax
    13cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13d4:	ba 00 00 00 00       	mov    $0x0,%edx
    13d9:	f7 f3                	div    %ebx
    13db:	89 d0                	mov    %edx,%eax
    13dd:	0f b6 80 2c 1b 00 00 	movzbl 0x1b2c(%eax),%eax
    13e4:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    13e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    13eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13ee:	ba 00 00 00 00       	mov    $0x0,%edx
    13f3:	f7 f3                	div    %ebx
    13f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13fc:	75 c7                	jne    13c5 <printint+0x38>
  if(neg)
    13fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1402:	74 2d                	je     1431 <printint+0xa4>
    buf[i++] = '-';
    1404:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1407:	8d 50 01             	lea    0x1(%eax),%edx
    140a:	89 55 f4             	mov    %edx,-0xc(%ebp)
    140d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1412:	eb 1d                	jmp    1431 <printint+0xa4>
    putc(fd, buf[i]);
    1414:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1417:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141a:	01 d0                	add    %edx,%eax
    141c:	0f b6 00             	movzbl (%eax),%eax
    141f:	0f be c0             	movsbl %al,%eax
    1422:	83 ec 08             	sub    $0x8,%esp
    1425:	50                   	push   %eax
    1426:	ff 75 08             	pushl  0x8(%ebp)
    1429:	e8 3c ff ff ff       	call   136a <putc>
    142e:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1431:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1435:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1439:	79 d9                	jns    1414 <printint+0x87>
    putc(fd, buf[i]);
}
    143b:	90                   	nop
    143c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    143f:	c9                   	leave  
    1440:	c3                   	ret    

00001441 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1441:	55                   	push   %ebp
    1442:	89 e5                	mov    %esp,%ebp
    1444:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1447:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    144e:	8d 45 0c             	lea    0xc(%ebp),%eax
    1451:	83 c0 04             	add    $0x4,%eax
    1454:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1457:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    145e:	e9 59 01 00 00       	jmp    15bc <printf+0x17b>
    c = fmt[i] & 0xff;
    1463:	8b 55 0c             	mov    0xc(%ebp),%edx
    1466:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1469:	01 d0                	add    %edx,%eax
    146b:	0f b6 00             	movzbl (%eax),%eax
    146e:	0f be c0             	movsbl %al,%eax
    1471:	25 ff 00 00 00       	and    $0xff,%eax
    1476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1479:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    147d:	75 2c                	jne    14ab <printf+0x6a>
      if(c == '%'){
    147f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1483:	75 0c                	jne    1491 <printf+0x50>
        state = '%';
    1485:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    148c:	e9 27 01 00 00       	jmp    15b8 <printf+0x177>
      } else {
        putc(fd, c);
    1491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1494:	0f be c0             	movsbl %al,%eax
    1497:	83 ec 08             	sub    $0x8,%esp
    149a:	50                   	push   %eax
    149b:	ff 75 08             	pushl  0x8(%ebp)
    149e:	e8 c7 fe ff ff       	call   136a <putc>
    14a3:	83 c4 10             	add    $0x10,%esp
    14a6:	e9 0d 01 00 00       	jmp    15b8 <printf+0x177>
      }
    } else if(state == '%'){
    14ab:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    14af:	0f 85 03 01 00 00    	jne    15b8 <printf+0x177>
      if(c == 'd'){
    14b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    14b9:	75 1e                	jne    14d9 <printf+0x98>
        printint(fd, *ap, 10, 1);
    14bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14be:	8b 00                	mov    (%eax),%eax
    14c0:	6a 01                	push   $0x1
    14c2:	6a 0a                	push   $0xa
    14c4:	50                   	push   %eax
    14c5:	ff 75 08             	pushl  0x8(%ebp)
    14c8:	e8 c0 fe ff ff       	call   138d <printint>
    14cd:	83 c4 10             	add    $0x10,%esp
        ap++;
    14d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14d4:	e9 d8 00 00 00       	jmp    15b1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    14d9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14dd:	74 06                	je     14e5 <printf+0xa4>
    14df:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14e3:	75 1e                	jne    1503 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    14e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14e8:	8b 00                	mov    (%eax),%eax
    14ea:	6a 00                	push   $0x0
    14ec:	6a 10                	push   $0x10
    14ee:	50                   	push   %eax
    14ef:	ff 75 08             	pushl  0x8(%ebp)
    14f2:	e8 96 fe ff ff       	call   138d <printint>
    14f7:	83 c4 10             	add    $0x10,%esp
        ap++;
    14fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14fe:	e9 ae 00 00 00       	jmp    15b1 <printf+0x170>
      } else if(c == 's'){
    1503:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1507:	75 43                	jne    154c <printf+0x10b>
        s = (char*)*ap;
    1509:	8b 45 e8             	mov    -0x18(%ebp),%eax
    150c:	8b 00                	mov    (%eax),%eax
    150e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1511:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1515:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1519:	75 25                	jne    1540 <printf+0xff>
          s = "(null)";
    151b:	c7 45 f4 5b 18 00 00 	movl   $0x185b,-0xc(%ebp)
        while(*s != 0){
    1522:	eb 1c                	jmp    1540 <printf+0xff>
          putc(fd, *s);
    1524:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1527:	0f b6 00             	movzbl (%eax),%eax
    152a:	0f be c0             	movsbl %al,%eax
    152d:	83 ec 08             	sub    $0x8,%esp
    1530:	50                   	push   %eax
    1531:	ff 75 08             	pushl  0x8(%ebp)
    1534:	e8 31 fe ff ff       	call   136a <putc>
    1539:	83 c4 10             	add    $0x10,%esp
          s++;
    153c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1540:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1543:	0f b6 00             	movzbl (%eax),%eax
    1546:	84 c0                	test   %al,%al
    1548:	75 da                	jne    1524 <printf+0xe3>
    154a:	eb 65                	jmp    15b1 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    154c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1550:	75 1d                	jne    156f <printf+0x12e>
        putc(fd, *ap);
    1552:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1555:	8b 00                	mov    (%eax),%eax
    1557:	0f be c0             	movsbl %al,%eax
    155a:	83 ec 08             	sub    $0x8,%esp
    155d:	50                   	push   %eax
    155e:	ff 75 08             	pushl  0x8(%ebp)
    1561:	e8 04 fe ff ff       	call   136a <putc>
    1566:	83 c4 10             	add    $0x10,%esp
        ap++;
    1569:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    156d:	eb 42                	jmp    15b1 <printf+0x170>
      } else if(c == '%'){
    156f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1573:	75 17                	jne    158c <printf+0x14b>
        putc(fd, c);
    1575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1578:	0f be c0             	movsbl %al,%eax
    157b:	83 ec 08             	sub    $0x8,%esp
    157e:	50                   	push   %eax
    157f:	ff 75 08             	pushl  0x8(%ebp)
    1582:	e8 e3 fd ff ff       	call   136a <putc>
    1587:	83 c4 10             	add    $0x10,%esp
    158a:	eb 25                	jmp    15b1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    158c:	83 ec 08             	sub    $0x8,%esp
    158f:	6a 25                	push   $0x25
    1591:	ff 75 08             	pushl  0x8(%ebp)
    1594:	e8 d1 fd ff ff       	call   136a <putc>
    1599:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    159c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    159f:	0f be c0             	movsbl %al,%eax
    15a2:	83 ec 08             	sub    $0x8,%esp
    15a5:	50                   	push   %eax
    15a6:	ff 75 08             	pushl  0x8(%ebp)
    15a9:	e8 bc fd ff ff       	call   136a <putc>
    15ae:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    15b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15b8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15bc:	8b 55 0c             	mov    0xc(%ebp),%edx
    15bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15c2:	01 d0                	add    %edx,%eax
    15c4:	0f b6 00             	movzbl (%eax),%eax
    15c7:	84 c0                	test   %al,%al
    15c9:	0f 85 94 fe ff ff    	jne    1463 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15cf:	90                   	nop
    15d0:	c9                   	leave  
    15d1:	c3                   	ret    

000015d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15d2:	55                   	push   %ebp
    15d3:	89 e5                	mov    %esp,%ebp
    15d5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15d8:	8b 45 08             	mov    0x8(%ebp),%eax
    15db:	83 e8 08             	sub    $0x8,%eax
    15de:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15e1:	a1 48 1b 00 00       	mov    0x1b48,%eax
    15e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15e9:	eb 24                	jmp    160f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ee:	8b 00                	mov    (%eax),%eax
    15f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15f3:	77 12                	ja     1607 <free+0x35>
    15f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15fb:	77 24                	ja     1621 <free+0x4f>
    15fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1600:	8b 00                	mov    (%eax),%eax
    1602:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1605:	77 1a                	ja     1621 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1607:	8b 45 fc             	mov    -0x4(%ebp),%eax
    160a:	8b 00                	mov    (%eax),%eax
    160c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    160f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1612:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1615:	76 d4                	jbe    15eb <free+0x19>
    1617:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161a:	8b 00                	mov    (%eax),%eax
    161c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    161f:	76 ca                	jbe    15eb <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1621:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1624:	8b 40 04             	mov    0x4(%eax),%eax
    1627:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    162e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1631:	01 c2                	add    %eax,%edx
    1633:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1636:	8b 00                	mov    (%eax),%eax
    1638:	39 c2                	cmp    %eax,%edx
    163a:	75 24                	jne    1660 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    163c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    163f:	8b 50 04             	mov    0x4(%eax),%edx
    1642:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1645:	8b 00                	mov    (%eax),%eax
    1647:	8b 40 04             	mov    0x4(%eax),%eax
    164a:	01 c2                	add    %eax,%edx
    164c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1652:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1655:	8b 00                	mov    (%eax),%eax
    1657:	8b 10                	mov    (%eax),%edx
    1659:	8b 45 f8             	mov    -0x8(%ebp),%eax
    165c:	89 10                	mov    %edx,(%eax)
    165e:	eb 0a                	jmp    166a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1660:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1663:	8b 10                	mov    (%eax),%edx
    1665:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1668:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    166a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166d:	8b 40 04             	mov    0x4(%eax),%eax
    1670:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1677:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167a:	01 d0                	add    %edx,%eax
    167c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    167f:	75 20                	jne    16a1 <free+0xcf>
    p->s.size += bp->s.size;
    1681:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1684:	8b 50 04             	mov    0x4(%eax),%edx
    1687:	8b 45 f8             	mov    -0x8(%ebp),%eax
    168a:	8b 40 04             	mov    0x4(%eax),%eax
    168d:	01 c2                	add    %eax,%edx
    168f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1692:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1695:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1698:	8b 10                	mov    (%eax),%edx
    169a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169d:	89 10                	mov    %edx,(%eax)
    169f:	eb 08                	jmp    16a9 <free+0xd7>
  } else
    p->s.ptr = bp;
    16a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a4:	8b 55 f8             	mov    -0x8(%ebp),%edx
    16a7:	89 10                	mov    %edx,(%eax)
  freep = p;
    16a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ac:	a3 48 1b 00 00       	mov    %eax,0x1b48
}
    16b1:	90                   	nop
    16b2:	c9                   	leave  
    16b3:	c3                   	ret    

000016b4 <morecore>:

static Header*
morecore(uint nu)
{
    16b4:	55                   	push   %ebp
    16b5:	89 e5                	mov    %esp,%ebp
    16b7:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    16ba:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16c1:	77 07                	ja     16ca <morecore+0x16>
    nu = 4096;
    16c3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16ca:	8b 45 08             	mov    0x8(%ebp),%eax
    16cd:	c1 e0 03             	shl    $0x3,%eax
    16d0:	83 ec 0c             	sub    $0xc,%esp
    16d3:	50                   	push   %eax
    16d4:	e8 69 fc ff ff       	call   1342 <sbrk>
    16d9:	83 c4 10             	add    $0x10,%esp
    16dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16df:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16e3:	75 07                	jne    16ec <morecore+0x38>
    return 0;
    16e5:	b8 00 00 00 00       	mov    $0x0,%eax
    16ea:	eb 26                	jmp    1712 <morecore+0x5e>
  hp = (Header*)p;
    16ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16f5:	8b 55 08             	mov    0x8(%ebp),%edx
    16f8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16fe:	83 c0 08             	add    $0x8,%eax
    1701:	83 ec 0c             	sub    $0xc,%esp
    1704:	50                   	push   %eax
    1705:	e8 c8 fe ff ff       	call   15d2 <free>
    170a:	83 c4 10             	add    $0x10,%esp
  return freep;
    170d:	a1 48 1b 00 00       	mov    0x1b48,%eax
}
    1712:	c9                   	leave  
    1713:	c3                   	ret    

00001714 <malloc>:

void*
malloc(uint nbytes)
{
    1714:	55                   	push   %ebp
    1715:	89 e5                	mov    %esp,%ebp
    1717:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    171a:	8b 45 08             	mov    0x8(%ebp),%eax
    171d:	83 c0 07             	add    $0x7,%eax
    1720:	c1 e8 03             	shr    $0x3,%eax
    1723:	83 c0 01             	add    $0x1,%eax
    1726:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1729:	a1 48 1b 00 00       	mov    0x1b48,%eax
    172e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1731:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1735:	75 23                	jne    175a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1737:	c7 45 f0 40 1b 00 00 	movl   $0x1b40,-0x10(%ebp)
    173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1741:	a3 48 1b 00 00       	mov    %eax,0x1b48
    1746:	a1 48 1b 00 00       	mov    0x1b48,%eax
    174b:	a3 40 1b 00 00       	mov    %eax,0x1b40
    base.s.size = 0;
    1750:	c7 05 44 1b 00 00 00 	movl   $0x0,0x1b44
    1757:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    175d:	8b 00                	mov    (%eax),%eax
    175f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1762:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1765:	8b 40 04             	mov    0x4(%eax),%eax
    1768:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    176b:	72 4d                	jb     17ba <malloc+0xa6>
      if(p->s.size == nunits)
    176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1770:	8b 40 04             	mov    0x4(%eax),%eax
    1773:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1776:	75 0c                	jne    1784 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1778:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177b:	8b 10                	mov    (%eax),%edx
    177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1780:	89 10                	mov    %edx,(%eax)
    1782:	eb 26                	jmp    17aa <malloc+0x96>
      else {
        p->s.size -= nunits;
    1784:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1787:	8b 40 04             	mov    0x4(%eax),%eax
    178a:	2b 45 ec             	sub    -0x14(%ebp),%eax
    178d:	89 c2                	mov    %eax,%edx
    178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1792:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1795:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1798:	8b 40 04             	mov    0x4(%eax),%eax
    179b:	c1 e0 03             	shl    $0x3,%eax
    179e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    17a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
    17a7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    17aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ad:	a3 48 1b 00 00       	mov    %eax,0x1b48
      return (void*)(p + 1);
    17b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b5:	83 c0 08             	add    $0x8,%eax
    17b8:	eb 3b                	jmp    17f5 <malloc+0xe1>
    }
    if(p == freep)
    17ba:	a1 48 1b 00 00       	mov    0x1b48,%eax
    17bf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    17c2:	75 1e                	jne    17e2 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    17c4:	83 ec 0c             	sub    $0xc,%esp
    17c7:	ff 75 ec             	pushl  -0x14(%ebp)
    17ca:	e8 e5 fe ff ff       	call   16b4 <morecore>
    17cf:	83 c4 10             	add    $0x10,%esp
    17d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17d9:	75 07                	jne    17e2 <malloc+0xce>
        return 0;
    17db:	b8 00 00 00 00       	mov    $0x0,%eax
    17e0:	eb 13                	jmp    17f5 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17eb:	8b 00                	mov    (%eax),%eax
    17ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17f0:	e9 6d ff ff ff       	jmp    1762 <malloc+0x4e>
}
    17f5:	c9                   	leave  
    17f6:	c3                   	ret    

000017f7 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
    17f7:	55                   	push   %ebp
    17f8:	89 e5                	mov    %esp,%ebp
    17fa:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
    17fd:	8b 55 08             	mov    0x8(%ebp),%edx
    1800:	8b 45 0c             	mov    0xc(%ebp),%eax
    1803:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1806:	f0 87 02             	lock xchg %eax,(%edx)
    1809:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
    180c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    180f:	c9                   	leave  
    1810:	c3                   	ret    

00001811 <uacquire>:
#include "uspinlock.h"
#include "x86.h"

void
uacquire(struct uspinlock *lk)
{
    1811:	55                   	push   %ebp
    1812:	89 e5                	mov    %esp,%ebp
  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
    1814:	90                   	nop
    1815:	8b 45 08             	mov    0x8(%ebp),%eax
    1818:	6a 01                	push   $0x1
    181a:	50                   	push   %eax
    181b:	e8 d7 ff ff ff       	call   17f7 <xchg>
    1820:	83 c4 08             	add    $0x8,%esp
    1823:	85 c0                	test   %eax,%eax
    1825:	75 ee                	jne    1815 <uacquire+0x4>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
    1827:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
}
    182c:	90                   	nop
    182d:	c9                   	leave  
    182e:	c3                   	ret    

0000182f <urelease>:

void urelease (struct uspinlock *lk) {
    182f:	55                   	push   %ebp
    1830:	89 e5                	mov    %esp,%ebp
  __sync_synchronize();
    1832:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
    1837:	8b 45 08             	mov    0x8(%ebp),%eax
    183a:	8b 55 08             	mov    0x8(%ebp),%edx
    183d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
    1843:	90                   	nop
    1844:	5d                   	pop    %ebp
    1845:	c3                   	ret    
