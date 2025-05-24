
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	33013103          	ld	sp,816(sp) # 8000a330 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	739040ef          	jal	80004f4e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <inc_ref>:
  return ((uint64)pa - KERNBASE) / PGSIZE;
}

void
inc_ref(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  return ((uint64)pa - KERNBASE) / PGSIZE;
    80000028:	800007b7          	lui	a5,0x80000
    8000002c:	00f504b3          	add	s1,a0,a5
    80000030:	80b1                	srli	s1,s1,0xc
    80000032:	2481                	sext.w	s1,s1
  int idx = kref_idx(pa);
  acquire(&kmem.lock);
    80000034:	0000a917          	auipc	s2,0xa
    80000038:	34c90913          	addi	s2,s2,844 # 8000a380 <kmem>
    8000003c:	854a                	mv	a0,s2
    8000003e:	173050ef          	jal	800059b0 <acquire>
  krefcnt[idx]++;
    80000042:	048a                	slli	s1,s1,0x2
    80000044:	0000a797          	auipc	a5,0xa
    80000048:	35c78793          	addi	a5,a5,860 # 8000a3a0 <krefcnt>
    8000004c:	97a6                	add	a5,a5,s1
    8000004e:	4398                	lw	a4,0(a5)
    80000050:	2705                	addiw	a4,a4,1
    80000052:	c398                	sw	a4,0(a5)
  release(&kmem.lock);
    80000054:	854a                	mv	a0,s2
    80000056:	1f3050ef          	jal	80005a48 <release>
}
    8000005a:	60e2                	ld	ra,24(sp)
    8000005c:	6442                	ld	s0,16(sp)
    8000005e:	64a2                	ld	s1,8(sp)
    80000060:	6902                	ld	s2,0(sp)
    80000062:	6105                	addi	sp,sp,32
    80000064:	8082                	ret

0000000080000066 <dec_ref>:

void
dec_ref(void *pa)
{
    80000066:	1101                	addi	sp,sp,-32
    80000068:	ec06                	sd	ra,24(sp)
    8000006a:	e822                	sd	s0,16(sp)
    8000006c:	e426                	sd	s1,8(sp)
    8000006e:	e04a                	sd	s2,0(sp)
    80000070:	1000                	addi	s0,sp,32
  return ((uint64)pa - KERNBASE) / PGSIZE;
    80000072:	800007b7          	lui	a5,0x80000
    80000076:	00f504b3          	add	s1,a0,a5
    8000007a:	80b1                	srli	s1,s1,0xc
    8000007c:	2481                	sext.w	s1,s1
  int idx = kref_idx(pa);
  acquire(&kmem.lock);
    8000007e:	0000a917          	auipc	s2,0xa
    80000082:	30290913          	addi	s2,s2,770 # 8000a380 <kmem>
    80000086:	854a                	mv	a0,s2
    80000088:	129050ef          	jal	800059b0 <acquire>
  krefcnt[idx]--;
    8000008c:	048a                	slli	s1,s1,0x2
    8000008e:	0000a797          	auipc	a5,0xa
    80000092:	31278793          	addi	a5,a5,786 # 8000a3a0 <krefcnt>
    80000096:	97a6                	add	a5,a5,s1
    80000098:	4398                	lw	a4,0(a5)
    8000009a:	377d                	addiw	a4,a4,-1
    8000009c:	c398                	sw	a4,0(a5)
  release(&kmem.lock);
    8000009e:	854a                	mv	a0,s2
    800000a0:	1a9050ef          	jal	80005a48 <release>
}
    800000a4:	60e2                	ld	ra,24(sp)
    800000a6:	6442                	ld	s0,16(sp)
    800000a8:	64a2                	ld	s1,8(sp)
    800000aa:	6902                	ld	s2,0(sp)
    800000ac:	6105                	addi	sp,sp,32
    800000ae:	8082                	ret

00000000800000b0 <kfree>:

// Free the page of physical memory pointed at by pa.
// Only actually free if its refcount drops to zero.
void
kfree(void *pa)
{
    800000b0:	1101                	addi	sp,sp,-32
    800000b2:	ec06                	sd	ra,24(sp)
    800000b4:	e822                	sd	s0,16(sp)
    800000b6:	e426                	sd	s1,8(sp)
    800000b8:	e04a                	sd	s2,0(sp)
    800000ba:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800000bc:	03451793          	slli	a5,a0,0x34
    800000c0:	e3c9                	bnez	a5,80000142 <kfree+0x92>
    800000c2:	892a                	mv	s2,a0
    800000c4:	00043797          	auipc	a5,0x43
    800000c8:	5ec78793          	addi	a5,a5,1516 # 800436b0 <end>
    800000cc:	06f56b63          	bltu	a0,a5,80000142 <kfree+0x92>
    800000d0:	47c5                	li	a5,17
    800000d2:	07ee                	slli	a5,a5,0x1b
    800000d4:	06f57763          	bgeu	a0,a5,80000142 <kfree+0x92>
  return ((uint64)pa - KERNBASE) / PGSIZE;
    800000d8:	800004b7          	lui	s1,0x80000
    800000dc:	94aa                	add	s1,s1,a0
    800000de:	80b1                	srli	s1,s1,0xc
    800000e0:	2481                	sext.w	s1,s1
    panic("kfree");

  int idx = kref_idx(pa);
  acquire(&kmem.lock);
    800000e2:	0000a517          	auipc	a0,0xa
    800000e6:	29e50513          	addi	a0,a0,670 # 8000a380 <kmem>
    800000ea:	0c7050ef          	jal	800059b0 <acquire>
  if(--krefcnt[idx] > 0){
    800000ee:	048a                	slli	s1,s1,0x2
    800000f0:	0000a797          	auipc	a5,0xa
    800000f4:	2b078793          	addi	a5,a5,688 # 8000a3a0 <krefcnt>
    800000f8:	97a6                	add	a5,a5,s1
    800000fa:	4398                	lw	a4,0(a5)
    800000fc:	377d                	addiw	a4,a4,-1
    800000fe:	0007069b          	sext.w	a3,a4
    80000102:	c398                	sw	a4,0(a5)
    80000104:	04d04563          	bgtz	a3,8000014e <kfree+0x9e>
    release(&kmem.lock);
    return; // still referenced, don't free
  }
  release(&kmem.lock);
    80000108:	0000a497          	auipc	s1,0xa
    8000010c:	27848493          	addi	s1,s1,632 # 8000a380 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	137050ef          	jal	80005a48 <release>

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000116:	6605                	lui	a2,0x1
    80000118:	4585                	li	a1,1
    8000011a:	854a                	mv	a0,s2
    8000011c:	126000ef          	jal	80000242 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000120:	8526                	mv	a0,s1
    80000122:	08f050ef          	jal	800059b0 <acquire>
  r->next = kmem.freelist;
    80000126:	6c9c                	ld	a5,24(s1)
    80000128:	00f93023          	sd	a5,0(s2)
  kmem.freelist = r;
    8000012c:	0124bc23          	sd	s2,24(s1)
  release(&kmem.lock);
    80000130:	8526                	mv	a0,s1
    80000132:	117050ef          	jal	80005a48 <release>
}
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6902                	ld	s2,0(sp)
    8000013e:	6105                	addi	sp,sp,32
    80000140:	8082                	ret
    panic("kfree");
    80000142:	00007517          	auipc	a0,0x7
    80000146:	ebe50513          	addi	a0,a0,-322 # 80007000 <etext>
    8000014a:	538050ef          	jal	80005682 <panic>
    release(&kmem.lock);
    8000014e:	0000a517          	auipc	a0,0xa
    80000152:	23250513          	addi	a0,a0,562 # 8000a380 <kmem>
    80000156:	0f3050ef          	jal	80005a48 <release>
    return; // still referenced, don't free
    8000015a:	bff1                	j	80000136 <kfree+0x86>

000000008000015c <freerange>:
{
    8000015c:	7179                	addi	sp,sp,-48
    8000015e:	f406                	sd	ra,40(sp)
    80000160:	f022                	sd	s0,32(sp)
    80000162:	ec26                	sd	s1,24(sp)
    80000164:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000166:	6785                	lui	a5,0x1
    80000168:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    8000016c:	00e504b3          	add	s1,a0,a4
    80000170:	777d                	lui	a4,0xfffff
    80000172:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000174:	94be                	add	s1,s1,a5
    80000176:	0295e263          	bltu	a1,s1,8000019a <freerange+0x3e>
    8000017a:	e84a                	sd	s2,16(sp)
    8000017c:	e44e                	sd	s3,8(sp)
    8000017e:	e052                	sd	s4,0(sp)
    80000180:	892e                	mv	s2,a1
    kfree(p);
    80000182:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000184:	6985                	lui	s3,0x1
    kfree(p);
    80000186:	01448533          	add	a0,s1,s4
    8000018a:	f27ff0ef          	jal	800000b0 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000018e:	94ce                	add	s1,s1,s3
    80000190:	fe997be3          	bgeu	s2,s1,80000186 <freerange+0x2a>
    80000194:	6942                	ld	s2,16(sp)
    80000196:	69a2                	ld	s3,8(sp)
    80000198:	6a02                	ld	s4,0(sp)
}
    8000019a:	70a2                	ld	ra,40(sp)
    8000019c:	7402                	ld	s0,32(sp)
    8000019e:	64e2                	ld	s1,24(sp)
    800001a0:	6145                	addi	sp,sp,48
    800001a2:	8082                	ret

00000000800001a4 <kinit>:
{
    800001a4:	1141                	addi	sp,sp,-16
    800001a6:	e406                	sd	ra,8(sp)
    800001a8:	e022                	sd	s0,0(sp)
    800001aa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800001ac:	00007597          	auipc	a1,0x7
    800001b0:	e6458593          	addi	a1,a1,-412 # 80007010 <etext+0x10>
    800001b4:	0000a517          	auipc	a0,0xa
    800001b8:	1cc50513          	addi	a0,a0,460 # 8000a380 <kmem>
    800001bc:	774050ef          	jal	80005930 <initlock>
  freerange(end, (void*)PHYSTOP);
    800001c0:	45c5                	li	a1,17
    800001c2:	05ee                	slli	a1,a1,0x1b
    800001c4:	00043517          	auipc	a0,0x43
    800001c8:	4ec50513          	addi	a0,a0,1260 # 800436b0 <end>
    800001cc:	f91ff0ef          	jal	8000015c <freerange>
}
    800001d0:	60a2                	ld	ra,8(sp)
    800001d2:	6402                	ld	s0,0(sp)
    800001d4:	0141                	addi	sp,sp,16
    800001d6:	8082                	ret

00000000800001d8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800001d8:	1101                	addi	sp,sp,-32
    800001da:	ec06                	sd	ra,24(sp)
    800001dc:	e822                	sd	s0,16(sp)
    800001de:	e426                	sd	s1,8(sp)
    800001e0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    800001e2:	0000a497          	auipc	s1,0xa
    800001e6:	19e48493          	addi	s1,s1,414 # 8000a380 <kmem>
    800001ea:	8526                	mv	a0,s1
    800001ec:	7c4050ef          	jal	800059b0 <acquire>
  r = kmem.freelist;
    800001f0:	6c84                	ld	s1,24(s1)
  if(r)
    800001f2:	c0a9                	beqz	s1,80000234 <kalloc+0x5c>
    kmem.freelist = r->next;
    800001f4:	609c                	ld	a5,0(s1)
    800001f6:	0000a517          	auipc	a0,0xa
    800001fa:	18a50513          	addi	a0,a0,394 # 8000a380 <kmem>
    800001fe:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000200:	049050ef          	jal	80005a48 <release>

  if(r){
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000204:	6605                	lui	a2,0x1
    80000206:	4595                	li	a1,5
    80000208:	8526                	mv	a0,s1
    8000020a:	038000ef          	jal	80000242 <memset>
  return ((uint64)pa - KERNBASE) / PGSIZE;
    8000020e:	800007b7          	lui	a5,0x80000
    80000212:	97a6                	add	a5,a5,s1
    80000214:	83b1                	srli	a5,a5,0xc
    krefcnt[kref_idx((void*)r)] = 1;
    80000216:	2781                	sext.w	a5,a5
    80000218:	078a                	slli	a5,a5,0x2
    8000021a:	0000a717          	auipc	a4,0xa
    8000021e:	18670713          	addi	a4,a4,390 # 8000a3a0 <krefcnt>
    80000222:	97ba                	add	a5,a5,a4
    80000224:	4705                	li	a4,1
    80000226:	c398                	sw	a4,0(a5)
  }
  return (void*)r;
}
    80000228:	8526                	mv	a0,s1
    8000022a:	60e2                	ld	ra,24(sp)
    8000022c:	6442                	ld	s0,16(sp)
    8000022e:	64a2                	ld	s1,8(sp)
    80000230:	6105                	addi	sp,sp,32
    80000232:	8082                	ret
  release(&kmem.lock);
    80000234:	0000a517          	auipc	a0,0xa
    80000238:	14c50513          	addi	a0,a0,332 # 8000a380 <kmem>
    8000023c:	00d050ef          	jal	80005a48 <release>
  if(r){
    80000240:	b7e5                	j	80000228 <kalloc+0x50>

0000000080000242 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000242:	1141                	addi	sp,sp,-16
    80000244:	e422                	sd	s0,8(sp)
    80000246:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000248:	ca19                	beqz	a2,8000025e <memset+0x1c>
    8000024a:	87aa                	mv	a5,a0
    8000024c:	1602                	slli	a2,a2,0x20
    8000024e:	9201                	srli	a2,a2,0x20
    80000250:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000254:	00b78023          	sb	a1,0(a5) # ffffffff80000000 <end+0xfffffffefffbc950>
  for(i = 0; i < n; i++){
    80000258:	0785                	addi	a5,a5,1
    8000025a:	fee79de3          	bne	a5,a4,80000254 <memset+0x12>
  }
  return dst;
}
    8000025e:	6422                	ld	s0,8(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret

0000000080000264 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000264:	1141                	addi	sp,sp,-16
    80000266:	e422                	sd	s0,8(sp)
    80000268:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000026a:	ca05                	beqz	a2,8000029a <memcmp+0x36>
    8000026c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000270:	1682                	slli	a3,a3,0x20
    80000272:	9281                	srli	a3,a3,0x20
    80000274:	0685                	addi	a3,a3,1
    80000276:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000278:	00054783          	lbu	a5,0(a0)
    8000027c:	0005c703          	lbu	a4,0(a1)
    80000280:	00e79863          	bne	a5,a4,80000290 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000284:	0505                	addi	a0,a0,1
    80000286:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000288:	fed518e3          	bne	a0,a3,80000278 <memcmp+0x14>
  }

  return 0;
    8000028c:	4501                	li	a0,0
    8000028e:	a019                	j	80000294 <memcmp+0x30>
      return *s1 - *s2;
    80000290:	40e7853b          	subw	a0,a5,a4
}
    80000294:	6422                	ld	s0,8(sp)
    80000296:	0141                	addi	sp,sp,16
    80000298:	8082                	ret
  return 0;
    8000029a:	4501                	li	a0,0
    8000029c:	bfe5                	j	80000294 <memcmp+0x30>

000000008000029e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000029e:	1141                	addi	sp,sp,-16
    800002a0:	e422                	sd	s0,8(sp)
    800002a2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800002a4:	c205                	beqz	a2,800002c4 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800002a6:	02a5e263          	bltu	a1,a0,800002ca <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800002aa:	1602                	slli	a2,a2,0x20
    800002ac:	9201                	srli	a2,a2,0x20
    800002ae:	00c587b3          	add	a5,a1,a2
{
    800002b2:	872a                	mv	a4,a0
      *d++ = *s++;
    800002b4:	0585                	addi	a1,a1,1
    800002b6:	0705                	addi	a4,a4,1
    800002b8:	fff5c683          	lbu	a3,-1(a1)
    800002bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800002c0:	feb79ae3          	bne	a5,a1,800002b4 <memmove+0x16>

  return dst;
}
    800002c4:	6422                	ld	s0,8(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret
  if(s < d && s + n > d){
    800002ca:	02061693          	slli	a3,a2,0x20
    800002ce:	9281                	srli	a3,a3,0x20
    800002d0:	00d58733          	add	a4,a1,a3
    800002d4:	fce57be3          	bgeu	a0,a4,800002aa <memmove+0xc>
    d += n;
    800002d8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800002da:	fff6079b          	addiw	a5,a2,-1
    800002de:	1782                	slli	a5,a5,0x20
    800002e0:	9381                	srli	a5,a5,0x20
    800002e2:	fff7c793          	not	a5,a5
    800002e6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800002e8:	177d                	addi	a4,a4,-1
    800002ea:	16fd                	addi	a3,a3,-1
    800002ec:	00074603          	lbu	a2,0(a4)
    800002f0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800002f4:	fef71ae3          	bne	a4,a5,800002e8 <memmove+0x4a>
    800002f8:	b7f1                	j	800002c4 <memmove+0x26>

00000000800002fa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800002fa:	1141                	addi	sp,sp,-16
    800002fc:	e406                	sd	ra,8(sp)
    800002fe:	e022                	sd	s0,0(sp)
    80000300:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000302:	f9dff0ef          	jal	8000029e <memmove>
}
    80000306:	60a2                	ld	ra,8(sp)
    80000308:	6402                	ld	s0,0(sp)
    8000030a:	0141                	addi	sp,sp,16
    8000030c:	8082                	ret

000000008000030e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000030e:	1141                	addi	sp,sp,-16
    80000310:	e422                	sd	s0,8(sp)
    80000312:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000314:	ce11                	beqz	a2,80000330 <strncmp+0x22>
    80000316:	00054783          	lbu	a5,0(a0)
    8000031a:	cf89                	beqz	a5,80000334 <strncmp+0x26>
    8000031c:	0005c703          	lbu	a4,0(a1)
    80000320:	00f71a63          	bne	a4,a5,80000334 <strncmp+0x26>
    n--, p++, q++;
    80000324:	367d                	addiw	a2,a2,-1
    80000326:	0505                	addi	a0,a0,1
    80000328:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000032a:	f675                	bnez	a2,80000316 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000032c:	4501                	li	a0,0
    8000032e:	a801                	j	8000033e <strncmp+0x30>
    80000330:	4501                	li	a0,0
    80000332:	a031                	j	8000033e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000334:	00054503          	lbu	a0,0(a0)
    80000338:	0005c783          	lbu	a5,0(a1)
    8000033c:	9d1d                	subw	a0,a0,a5
}
    8000033e:	6422                	ld	s0,8(sp)
    80000340:	0141                	addi	sp,sp,16
    80000342:	8082                	ret

0000000080000344 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000344:	1141                	addi	sp,sp,-16
    80000346:	e422                	sd	s0,8(sp)
    80000348:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000034a:	87aa                	mv	a5,a0
    8000034c:	86b2                	mv	a3,a2
    8000034e:	367d                	addiw	a2,a2,-1
    80000350:	02d05563          	blez	a3,8000037a <strncpy+0x36>
    80000354:	0785                	addi	a5,a5,1
    80000356:	0005c703          	lbu	a4,0(a1)
    8000035a:	fee78fa3          	sb	a4,-1(a5)
    8000035e:	0585                	addi	a1,a1,1
    80000360:	f775                	bnez	a4,8000034c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000362:	873e                	mv	a4,a5
    80000364:	9fb5                	addw	a5,a5,a3
    80000366:	37fd                	addiw	a5,a5,-1
    80000368:	00c05963          	blez	a2,8000037a <strncpy+0x36>
    *s++ = 0;
    8000036c:	0705                	addi	a4,a4,1
    8000036e:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000372:	40e786bb          	subw	a3,a5,a4
    80000376:	fed04be3          	bgtz	a3,8000036c <strncpy+0x28>
  return os;
}
    8000037a:	6422                	ld	s0,8(sp)
    8000037c:	0141                	addi	sp,sp,16
    8000037e:	8082                	ret

0000000080000380 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000380:	1141                	addi	sp,sp,-16
    80000382:	e422                	sd	s0,8(sp)
    80000384:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000386:	02c05363          	blez	a2,800003ac <safestrcpy+0x2c>
    8000038a:	fff6069b          	addiw	a3,a2,-1
    8000038e:	1682                	slli	a3,a3,0x20
    80000390:	9281                	srli	a3,a3,0x20
    80000392:	96ae                	add	a3,a3,a1
    80000394:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000396:	00d58963          	beq	a1,a3,800003a8 <safestrcpy+0x28>
    8000039a:	0585                	addi	a1,a1,1
    8000039c:	0785                	addi	a5,a5,1
    8000039e:	fff5c703          	lbu	a4,-1(a1)
    800003a2:	fee78fa3          	sb	a4,-1(a5)
    800003a6:	fb65                	bnez	a4,80000396 <safestrcpy+0x16>
    ;
  *s = 0;
    800003a8:	00078023          	sb	zero,0(a5)
  return os;
}
    800003ac:	6422                	ld	s0,8(sp)
    800003ae:	0141                	addi	sp,sp,16
    800003b0:	8082                	ret

00000000800003b2 <strlen>:

int
strlen(const char *s)
{
    800003b2:	1141                	addi	sp,sp,-16
    800003b4:	e422                	sd	s0,8(sp)
    800003b6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800003b8:	00054783          	lbu	a5,0(a0)
    800003bc:	cf91                	beqz	a5,800003d8 <strlen+0x26>
    800003be:	0505                	addi	a0,a0,1
    800003c0:	87aa                	mv	a5,a0
    800003c2:	86be                	mv	a3,a5
    800003c4:	0785                	addi	a5,a5,1
    800003c6:	fff7c703          	lbu	a4,-1(a5)
    800003ca:	ff65                	bnez	a4,800003c2 <strlen+0x10>
    800003cc:	40a6853b          	subw	a0,a3,a0
    800003d0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800003d2:	6422                	ld	s0,8(sp)
    800003d4:	0141                	addi	sp,sp,16
    800003d6:	8082                	ret
  for(n = 0; s[n]; n++)
    800003d8:	4501                	li	a0,0
    800003da:	bfe5                	j	800003d2 <strlen+0x20>

00000000800003dc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800003dc:	1141                	addi	sp,sp,-16
    800003de:	e406                	sd	ra,8(sp)
    800003e0:	e022                	sd	s0,0(sp)
    800003e2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800003e4:	311000ef          	jal	80000ef4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800003e8:	0000a717          	auipc	a4,0xa
    800003ec:	f6870713          	addi	a4,a4,-152 # 8000a350 <started>
  if(cpuid() == 0){
    800003f0:	c51d                	beqz	a0,8000041e <main+0x42>
    while(started == 0)
    800003f2:	431c                	lw	a5,0(a4)
    800003f4:	2781                	sext.w	a5,a5
    800003f6:	dff5                	beqz	a5,800003f2 <main+0x16>
      ;
    __sync_synchronize();
    800003f8:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    800003fc:	2f9000ef          	jal	80000ef4 <cpuid>
    80000400:	85aa                	mv	a1,a0
    80000402:	00007517          	auipc	a0,0x7
    80000406:	c3650513          	addi	a0,a0,-970 # 80007038 <etext+0x38>
    8000040a:	7a7040ef          	jal	800053b0 <printf>
    kvminithart();    // turn on paging
    8000040e:	080000ef          	jal	8000048e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000412:	5fe010ef          	jal	80001a10 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000416:	552040ef          	jal	80004968 <plicinithart>
  }

  scheduler();        
    8000041a:	73b000ef          	jal	80001354 <scheduler>
    consoleinit();
    8000041e:	6bd040ef          	jal	800052da <consoleinit>
    printfinit();
    80000422:	29a050ef          	jal	800056bc <printfinit>
    printf("\n");
    80000426:	00007517          	auipc	a0,0x7
    8000042a:	bf250513          	addi	a0,a0,-1038 # 80007018 <etext+0x18>
    8000042e:	783040ef          	jal	800053b0 <printf>
    printf("xv6 kernel is booting\n");
    80000432:	00007517          	auipc	a0,0x7
    80000436:	bee50513          	addi	a0,a0,-1042 # 80007020 <etext+0x20>
    8000043a:	777040ef          	jal	800053b0 <printf>
    printf("\n");
    8000043e:	00007517          	auipc	a0,0x7
    80000442:	bda50513          	addi	a0,a0,-1062 # 80007018 <etext+0x18>
    80000446:	76b040ef          	jal	800053b0 <printf>
    kinit();         // physical page allocator
    8000044a:	d5bff0ef          	jal	800001a4 <kinit>
    kvminit();       // create kernel page table
    8000044e:	2ca000ef          	jal	80000718 <kvminit>
    kvminithart();   // turn on paging
    80000452:	03c000ef          	jal	8000048e <kvminithart>
    procinit();      // process table
    80000456:	1e9000ef          	jal	80000e3e <procinit>
    trapinit();      // trap vectors
    8000045a:	592010ef          	jal	800019ec <trapinit>
    trapinithart();  // install kernel trap vector
    8000045e:	5b2010ef          	jal	80001a10 <trapinithart>
    plicinit();      // set up interrupt controller
    80000462:	4ec040ef          	jal	8000494e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000466:	502040ef          	jal	80004968 <plicinithart>
    binit();         // buffer cache
    8000046a:	4ad010ef          	jal	80002116 <binit>
    iinit();         // inode table
    8000046e:	29e020ef          	jal	8000270c <iinit>
    fileinit();      // file table
    80000472:	04a030ef          	jal	800034bc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000476:	5e2040ef          	jal	80004a58 <virtio_disk_init>
    userinit();      // first user process
    8000047a:	50f000ef          	jal	80001188 <userinit>
    __sync_synchronize();
    8000047e:	0330000f          	fence	rw,rw
    started = 1;
    80000482:	4785                	li	a5,1
    80000484:	0000a717          	auipc	a4,0xa
    80000488:	ecf72623          	sw	a5,-308(a4) # 8000a350 <started>
    8000048c:	b779                	j	8000041a <main+0x3e>

000000008000048e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000048e:	1141                	addi	sp,sp,-16
    80000490:	e422                	sd	s0,8(sp)
    80000492:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000494:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000498:	0000a797          	auipc	a5,0xa
    8000049c:	ec07b783          	ld	a5,-320(a5) # 8000a358 <kernel_pagetable>
    800004a0:	83b1                	srli	a5,a5,0xc
    800004a2:	577d                	li	a4,-1
    800004a4:	177e                	slli	a4,a4,0x3f
    800004a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800004a8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800004ac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800004b0:	6422                	ld	s0,8(sp)
    800004b2:	0141                	addi	sp,sp,16
    800004b4:	8082                	ret

00000000800004b6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800004b6:	7139                	addi	sp,sp,-64
    800004b8:	fc06                	sd	ra,56(sp)
    800004ba:	f822                	sd	s0,48(sp)
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	ec4e                	sd	s3,24(sp)
    800004c2:	e852                	sd	s4,16(sp)
    800004c4:	e456                	sd	s5,8(sp)
    800004c6:	e05a                	sd	s6,0(sp)
    800004c8:	0080                	addi	s0,sp,64
    800004ca:	84aa                	mv	s1,a0
    800004cc:	89ae                	mv	s3,a1
    800004ce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800004d0:	57fd                	li	a5,-1
    800004d2:	83e9                	srli	a5,a5,0x1a
    800004d4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800004d6:	4b31                	li	s6,12
  if(va >= MAXVA)
    800004d8:	02b7fc63          	bgeu	a5,a1,80000510 <walk+0x5a>
    panic("walk");
    800004dc:	00007517          	auipc	a0,0x7
    800004e0:	b7450513          	addi	a0,a0,-1164 # 80007050 <etext+0x50>
    800004e4:	19e050ef          	jal	80005682 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004e8:	060a8263          	beqz	s5,8000054c <walk+0x96>
    800004ec:	cedff0ef          	jal	800001d8 <kalloc>
    800004f0:	84aa                	mv	s1,a0
    800004f2:	c139                	beqz	a0,80000538 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004f4:	6605                	lui	a2,0x1
    800004f6:	4581                	li	a1,0
    800004f8:	d4bff0ef          	jal	80000242 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004fc:	00c4d793          	srli	a5,s1,0xc
    80000500:	07aa                	slli	a5,a5,0xa
    80000502:	0017e793          	ori	a5,a5,1
    80000506:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000050a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbb947>
    8000050c:	036a0063          	beq	s4,s6,8000052c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000510:	0149d933          	srl	s2,s3,s4
    80000514:	1ff97913          	andi	s2,s2,511
    80000518:	090e                	slli	s2,s2,0x3
    8000051a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000051c:	00093483          	ld	s1,0(s2)
    80000520:	0014f793          	andi	a5,s1,1
    80000524:	d3f1                	beqz	a5,800004e8 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000526:	80a9                	srli	s1,s1,0xa
    80000528:	04b2                	slli	s1,s1,0xc
    8000052a:	b7c5                	j	8000050a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    8000052c:	00c9d513          	srli	a0,s3,0xc
    80000530:	1ff57513          	andi	a0,a0,511
    80000534:	050e                	slli	a0,a0,0x3
    80000536:	9526                	add	a0,a0,s1
}
    80000538:	70e2                	ld	ra,56(sp)
    8000053a:	7442                	ld	s0,48(sp)
    8000053c:	74a2                	ld	s1,40(sp)
    8000053e:	7902                	ld	s2,32(sp)
    80000540:	69e2                	ld	s3,24(sp)
    80000542:	6a42                	ld	s4,16(sp)
    80000544:	6aa2                	ld	s5,8(sp)
    80000546:	6b02                	ld	s6,0(sp)
    80000548:	6121                	addi	sp,sp,64
    8000054a:	8082                	ret
        return 0;
    8000054c:	4501                	li	a0,0
    8000054e:	b7ed                	j	80000538 <walk+0x82>

0000000080000550 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000550:	57fd                	li	a5,-1
    80000552:	83e9                	srli	a5,a5,0x1a
    80000554:	00b7f463          	bgeu	a5,a1,8000055c <walkaddr+0xc>
    return 0;
    80000558:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000055a:	8082                	ret
{
    8000055c:	1141                	addi	sp,sp,-16
    8000055e:	e406                	sd	ra,8(sp)
    80000560:	e022                	sd	s0,0(sp)
    80000562:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000564:	4601                	li	a2,0
    80000566:	f51ff0ef          	jal	800004b6 <walk>
  if(pte == 0)
    8000056a:	c105                	beqz	a0,8000058a <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000056c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000056e:	0117f693          	andi	a3,a5,17
    80000572:	4745                	li	a4,17
    return 0;
    80000574:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000576:	00e68663          	beq	a3,a4,80000582 <walkaddr+0x32>
}
    8000057a:	60a2                	ld	ra,8(sp)
    8000057c:	6402                	ld	s0,0(sp)
    8000057e:	0141                	addi	sp,sp,16
    80000580:	8082                	ret
  pa = PTE2PA(*pte);
    80000582:	83a9                	srli	a5,a5,0xa
    80000584:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000588:	bfcd                	j	8000057a <walkaddr+0x2a>
    return 0;
    8000058a:	4501                	li	a0,0
    8000058c:	b7fd                	j	8000057a <walkaddr+0x2a>

000000008000058e <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000058e:	715d                	addi	sp,sp,-80
    80000590:	e486                	sd	ra,72(sp)
    80000592:	e0a2                	sd	s0,64(sp)
    80000594:	fc26                	sd	s1,56(sp)
    80000596:	f84a                	sd	s2,48(sp)
    80000598:	f44e                	sd	s3,40(sp)
    8000059a:	f052                	sd	s4,32(sp)
    8000059c:	ec56                	sd	s5,24(sp)
    8000059e:	e85a                	sd	s6,16(sp)
    800005a0:	e45e                	sd	s7,8(sp)
    800005a2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800005a4:	03459793          	slli	a5,a1,0x34
    800005a8:	e7a9                	bnez	a5,800005f2 <mappages+0x64>
    800005aa:	8aaa                	mv	s5,a0
    800005ac:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800005ae:	03461793          	slli	a5,a2,0x34
    800005b2:	e7b1                	bnez	a5,800005fe <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800005b4:	ca39                	beqz	a2,8000060a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800005b6:	77fd                	lui	a5,0xfffff
    800005b8:	963e                	add	a2,a2,a5
    800005ba:	00b609b3          	add	s3,a2,a1
  a = va;
    800005be:	892e                	mv	s2,a1
    800005c0:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800005c4:	6b85                	lui	s7,0x1
    800005c6:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800005ca:	4605                	li	a2,1
    800005cc:	85ca                	mv	a1,s2
    800005ce:	8556                	mv	a0,s5
    800005d0:	ee7ff0ef          	jal	800004b6 <walk>
    800005d4:	c539                	beqz	a0,80000622 <mappages+0x94>
    if(*pte & PTE_V)
    800005d6:	611c                	ld	a5,0(a0)
    800005d8:	8b85                	andi	a5,a5,1
    800005da:	ef95                	bnez	a5,80000616 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005dc:	80b1                	srli	s1,s1,0xc
    800005de:	04aa                	slli	s1,s1,0xa
    800005e0:	0164e4b3          	or	s1,s1,s6
    800005e4:	0014e493          	ori	s1,s1,1
    800005e8:	e104                	sd	s1,0(a0)
    if(a == last)
    800005ea:	05390863          	beq	s2,s3,8000063a <mappages+0xac>
    a += PGSIZE;
    800005ee:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800005f0:	bfd9                	j	800005c6 <mappages+0x38>
    panic("mappages: va not aligned");
    800005f2:	00007517          	auipc	a0,0x7
    800005f6:	a6650513          	addi	a0,a0,-1434 # 80007058 <etext+0x58>
    800005fa:	088050ef          	jal	80005682 <panic>
    panic("mappages: size not aligned");
    800005fe:	00007517          	auipc	a0,0x7
    80000602:	a7a50513          	addi	a0,a0,-1414 # 80007078 <etext+0x78>
    80000606:	07c050ef          	jal	80005682 <panic>
    panic("mappages: size");
    8000060a:	00007517          	auipc	a0,0x7
    8000060e:	a8e50513          	addi	a0,a0,-1394 # 80007098 <etext+0x98>
    80000612:	070050ef          	jal	80005682 <panic>
      panic("mappages: remap");
    80000616:	00007517          	auipc	a0,0x7
    8000061a:	a9250513          	addi	a0,a0,-1390 # 800070a8 <etext+0xa8>
    8000061e:	064050ef          	jal	80005682 <panic>
      return -1;
    80000622:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000624:	60a6                	ld	ra,72(sp)
    80000626:	6406                	ld	s0,64(sp)
    80000628:	74e2                	ld	s1,56(sp)
    8000062a:	7942                	ld	s2,48(sp)
    8000062c:	79a2                	ld	s3,40(sp)
    8000062e:	7a02                	ld	s4,32(sp)
    80000630:	6ae2                	ld	s5,24(sp)
    80000632:	6b42                	ld	s6,16(sp)
    80000634:	6ba2                	ld	s7,8(sp)
    80000636:	6161                	addi	sp,sp,80
    80000638:	8082                	ret
  return 0;
    8000063a:	4501                	li	a0,0
    8000063c:	b7e5                	j	80000624 <mappages+0x96>

000000008000063e <kvmmap>:
{
    8000063e:	1141                	addi	sp,sp,-16
    80000640:	e406                	sd	ra,8(sp)
    80000642:	e022                	sd	s0,0(sp)
    80000644:	0800                	addi	s0,sp,16
    80000646:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000648:	86b2                	mv	a3,a2
    8000064a:	863e                	mv	a2,a5
    8000064c:	f43ff0ef          	jal	8000058e <mappages>
    80000650:	e509                	bnez	a0,8000065a <kvmmap+0x1c>
}
    80000652:	60a2                	ld	ra,8(sp)
    80000654:	6402                	ld	s0,0(sp)
    80000656:	0141                	addi	sp,sp,16
    80000658:	8082                	ret
    panic("kvmmap");
    8000065a:	00007517          	auipc	a0,0x7
    8000065e:	a5e50513          	addi	a0,a0,-1442 # 800070b8 <etext+0xb8>
    80000662:	020050ef          	jal	80005682 <panic>

0000000080000666 <kvmmake>:
{
    80000666:	1101                	addi	sp,sp,-32
    80000668:	ec06                	sd	ra,24(sp)
    8000066a:	e822                	sd	s0,16(sp)
    8000066c:	e426                	sd	s1,8(sp)
    8000066e:	e04a                	sd	s2,0(sp)
    80000670:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000672:	b67ff0ef          	jal	800001d8 <kalloc>
    80000676:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000678:	6605                	lui	a2,0x1
    8000067a:	4581                	li	a1,0
    8000067c:	bc7ff0ef          	jal	80000242 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000680:	4719                	li	a4,6
    80000682:	6685                	lui	a3,0x1
    80000684:	10000637          	lui	a2,0x10000
    80000688:	100005b7          	lui	a1,0x10000
    8000068c:	8526                	mv	a0,s1
    8000068e:	fb1ff0ef          	jal	8000063e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000692:	4719                	li	a4,6
    80000694:	6685                	lui	a3,0x1
    80000696:	10001637          	lui	a2,0x10001
    8000069a:	100015b7          	lui	a1,0x10001
    8000069e:	8526                	mv	a0,s1
    800006a0:	f9fff0ef          	jal	8000063e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800006a4:	4719                	li	a4,6
    800006a6:	040006b7          	lui	a3,0x4000
    800006aa:	0c000637          	lui	a2,0xc000
    800006ae:	0c0005b7          	lui	a1,0xc000
    800006b2:	8526                	mv	a0,s1
    800006b4:	f8bff0ef          	jal	8000063e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006b8:	00007917          	auipc	s2,0x7
    800006bc:	94890913          	addi	s2,s2,-1720 # 80007000 <etext>
    800006c0:	4729                	li	a4,10
    800006c2:	80007697          	auipc	a3,0x80007
    800006c6:	93e68693          	addi	a3,a3,-1730 # 7000 <_entry-0x7fff9000>
    800006ca:	4605                	li	a2,1
    800006cc:	067e                	slli	a2,a2,0x1f
    800006ce:	85b2                	mv	a1,a2
    800006d0:	8526                	mv	a0,s1
    800006d2:	f6dff0ef          	jal	8000063e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006d6:	46c5                	li	a3,17
    800006d8:	06ee                	slli	a3,a3,0x1b
    800006da:	4719                	li	a4,6
    800006dc:	412686b3          	sub	a3,a3,s2
    800006e0:	864a                	mv	a2,s2
    800006e2:	85ca                	mv	a1,s2
    800006e4:	8526                	mv	a0,s1
    800006e6:	f59ff0ef          	jal	8000063e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006ea:	4729                	li	a4,10
    800006ec:	6685                	lui	a3,0x1
    800006ee:	00006617          	auipc	a2,0x6
    800006f2:	91260613          	addi	a2,a2,-1774 # 80006000 <_trampoline>
    800006f6:	040005b7          	lui	a1,0x4000
    800006fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800006fc:	05b2                	slli	a1,a1,0xc
    800006fe:	8526                	mv	a0,s1
    80000700:	f3fff0ef          	jal	8000063e <kvmmap>
  proc_mapstacks(kpgtbl);
    80000704:	8526                	mv	a0,s1
    80000706:	6a0000ef          	jal	80000da6 <proc_mapstacks>
}
    8000070a:	8526                	mv	a0,s1
    8000070c:	60e2                	ld	ra,24(sp)
    8000070e:	6442                	ld	s0,16(sp)
    80000710:	64a2                	ld	s1,8(sp)
    80000712:	6902                	ld	s2,0(sp)
    80000714:	6105                	addi	sp,sp,32
    80000716:	8082                	ret

0000000080000718 <kvminit>:
{
    80000718:	1141                	addi	sp,sp,-16
    8000071a:	e406                	sd	ra,8(sp)
    8000071c:	e022                	sd	s0,0(sp)
    8000071e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000720:	f47ff0ef          	jal	80000666 <kvmmake>
    80000724:	0000a797          	auipc	a5,0xa
    80000728:	c2a7ba23          	sd	a0,-972(a5) # 8000a358 <kernel_pagetable>
}
    8000072c:	60a2                	ld	ra,8(sp)
    8000072e:	6402                	ld	s0,0(sp)
    80000730:	0141                	addi	sp,sp,16
    80000732:	8082                	ret

0000000080000734 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000734:	715d                	addi	sp,sp,-80
    80000736:	e486                	sd	ra,72(sp)
    80000738:	e0a2                	sd	s0,64(sp)
    8000073a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000073c:	03459793          	slli	a5,a1,0x34
    80000740:	e39d                	bnez	a5,80000766 <uvmunmap+0x32>
    80000742:	f84a                	sd	s2,48(sp)
    80000744:	f44e                	sd	s3,40(sp)
    80000746:	f052                	sd	s4,32(sp)
    80000748:	ec56                	sd	s5,24(sp)
    8000074a:	e85a                	sd	s6,16(sp)
    8000074c:	e45e                	sd	s7,8(sp)
    8000074e:	8a2a                	mv	s4,a0
    80000750:	892e                	mv	s2,a1
    80000752:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000754:	0632                	slli	a2,a2,0xc
    80000756:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000075a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000075c:	6b05                	lui	s6,0x1
    8000075e:	0735ff63          	bgeu	a1,s3,800007dc <uvmunmap+0xa8>
    80000762:	fc26                	sd	s1,56(sp)
    80000764:	a0a9                	j	800007ae <uvmunmap+0x7a>
    80000766:	fc26                	sd	s1,56(sp)
    80000768:	f84a                	sd	s2,48(sp)
    8000076a:	f44e                	sd	s3,40(sp)
    8000076c:	f052                	sd	s4,32(sp)
    8000076e:	ec56                	sd	s5,24(sp)
    80000770:	e85a                	sd	s6,16(sp)
    80000772:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80000774:	00007517          	auipc	a0,0x7
    80000778:	94c50513          	addi	a0,a0,-1716 # 800070c0 <etext+0xc0>
    8000077c:	707040ef          	jal	80005682 <panic>
      panic("uvmunmap: walk");
    80000780:	00007517          	auipc	a0,0x7
    80000784:	95850513          	addi	a0,a0,-1704 # 800070d8 <etext+0xd8>
    80000788:	6fb040ef          	jal	80005682 <panic>
      panic("uvmunmap: not mapped");
    8000078c:	00007517          	auipc	a0,0x7
    80000790:	95c50513          	addi	a0,a0,-1700 # 800070e8 <etext+0xe8>
    80000794:	6ef040ef          	jal	80005682 <panic>
      panic("uvmunmap: not a leaf");
    80000798:	00007517          	auipc	a0,0x7
    8000079c:	96850513          	addi	a0,a0,-1688 # 80007100 <etext+0x100>
    800007a0:	6e3040ef          	jal	80005682 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800007a4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007a8:	995a                	add	s2,s2,s6
    800007aa:	03397863          	bgeu	s2,s3,800007da <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007ae:	4601                	li	a2,0
    800007b0:	85ca                	mv	a1,s2
    800007b2:	8552                	mv	a0,s4
    800007b4:	d03ff0ef          	jal	800004b6 <walk>
    800007b8:	84aa                	mv	s1,a0
    800007ba:	d179                	beqz	a0,80000780 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    800007bc:	6108                	ld	a0,0(a0)
    800007be:	00157793          	andi	a5,a0,1
    800007c2:	d7e9                	beqz	a5,8000078c <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    800007c4:	3ff57793          	andi	a5,a0,1023
    800007c8:	fd7788e3          	beq	a5,s7,80000798 <uvmunmap+0x64>
    if(do_free){
    800007cc:	fc0a8ce3          	beqz	s5,800007a4 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    800007d0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800007d2:	0532                	slli	a0,a0,0xc
    800007d4:	8ddff0ef          	jal	800000b0 <kfree>
    800007d8:	b7f1                	j	800007a4 <uvmunmap+0x70>
    800007da:	74e2                	ld	s1,56(sp)
    800007dc:	7942                	ld	s2,48(sp)
    800007de:	79a2                	ld	s3,40(sp)
    800007e0:	7a02                	ld	s4,32(sp)
    800007e2:	6ae2                	ld	s5,24(sp)
    800007e4:	6b42                	ld	s6,16(sp)
    800007e6:	6ba2                	ld	s7,8(sp)
  }
}
    800007e8:	60a6                	ld	ra,72(sp)
    800007ea:	6406                	ld	s0,64(sp)
    800007ec:	6161                	addi	sp,sp,80
    800007ee:	8082                	ret

00000000800007f0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800007fa:	9dfff0ef          	jal	800001d8 <kalloc>
    800007fe:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000800:	c509                	beqz	a0,8000080a <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000802:	6605                	lui	a2,0x1
    80000804:	4581                	li	a1,0
    80000806:	a3dff0ef          	jal	80000242 <memset>
  return pagetable;
}
    8000080a:	8526                	mv	a0,s1
    8000080c:	60e2                	ld	ra,24(sp)
    8000080e:	6442                	ld	s0,16(sp)
    80000810:	64a2                	ld	s1,8(sp)
    80000812:	6105                	addi	sp,sp,32
    80000814:	8082                	ret

0000000080000816 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000816:	7179                	addi	sp,sp,-48
    80000818:	f406                	sd	ra,40(sp)
    8000081a:	f022                	sd	s0,32(sp)
    8000081c:	ec26                	sd	s1,24(sp)
    8000081e:	e84a                	sd	s2,16(sp)
    80000820:	e44e                	sd	s3,8(sp)
    80000822:	e052                	sd	s4,0(sp)
    80000824:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000826:	6785                	lui	a5,0x1
    80000828:	04f67063          	bgeu	a2,a5,80000868 <uvmfirst+0x52>
    8000082c:	8a2a                	mv	s4,a0
    8000082e:	89ae                	mv	s3,a1
    80000830:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000832:	9a7ff0ef          	jal	800001d8 <kalloc>
    80000836:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000838:	6605                	lui	a2,0x1
    8000083a:	4581                	li	a1,0
    8000083c:	a07ff0ef          	jal	80000242 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000840:	4779                	li	a4,30
    80000842:	86ca                	mv	a3,s2
    80000844:	6605                	lui	a2,0x1
    80000846:	4581                	li	a1,0
    80000848:	8552                	mv	a0,s4
    8000084a:	d45ff0ef          	jal	8000058e <mappages>
  memmove(mem, src, sz);
    8000084e:	8626                	mv	a2,s1
    80000850:	85ce                	mv	a1,s3
    80000852:	854a                	mv	a0,s2
    80000854:	a4bff0ef          	jal	8000029e <memmove>
}
    80000858:	70a2                	ld	ra,40(sp)
    8000085a:	7402                	ld	s0,32(sp)
    8000085c:	64e2                	ld	s1,24(sp)
    8000085e:	6942                	ld	s2,16(sp)
    80000860:	69a2                	ld	s3,8(sp)
    80000862:	6a02                	ld	s4,0(sp)
    80000864:	6145                	addi	sp,sp,48
    80000866:	8082                	ret
    panic("uvmfirst: more than a page");
    80000868:	00007517          	auipc	a0,0x7
    8000086c:	8b050513          	addi	a0,a0,-1872 # 80007118 <etext+0x118>
    80000870:	613040ef          	jal	80005682 <panic>

0000000080000874 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000874:	1101                	addi	sp,sp,-32
    80000876:	ec06                	sd	ra,24(sp)
    80000878:	e822                	sd	s0,16(sp)
    8000087a:	e426                	sd	s1,8(sp)
    8000087c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000087e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80000880:	00b67d63          	bgeu	a2,a1,8000089a <uvmdealloc+0x26>
    80000884:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000886:	6785                	lui	a5,0x1
    80000888:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000088a:	00f60733          	add	a4,a2,a5
    8000088e:	76fd                	lui	a3,0xfffff
    80000890:	8f75                	and	a4,a4,a3
    80000892:	97ae                	add	a5,a5,a1
    80000894:	8ff5                	and	a5,a5,a3
    80000896:	00f76863          	bltu	a4,a5,800008a6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000089a:	8526                	mv	a0,s1
    8000089c:	60e2                	ld	ra,24(sp)
    8000089e:	6442                	ld	s0,16(sp)
    800008a0:	64a2                	ld	s1,8(sp)
    800008a2:	6105                	addi	sp,sp,32
    800008a4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008a6:	8f99                	sub	a5,a5,a4
    800008a8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008aa:	4685                	li	a3,1
    800008ac:	0007861b          	sext.w	a2,a5
    800008b0:	85ba                	mv	a1,a4
    800008b2:	e83ff0ef          	jal	80000734 <uvmunmap>
    800008b6:	b7d5                	j	8000089a <uvmdealloc+0x26>

00000000800008b8 <uvmalloc>:
  if(newsz < oldsz)
    800008b8:	08b66f63          	bltu	a2,a1,80000956 <uvmalloc+0x9e>
{
    800008bc:	7139                	addi	sp,sp,-64
    800008be:	fc06                	sd	ra,56(sp)
    800008c0:	f822                	sd	s0,48(sp)
    800008c2:	ec4e                	sd	s3,24(sp)
    800008c4:	e852                	sd	s4,16(sp)
    800008c6:	e456                	sd	s5,8(sp)
    800008c8:	0080                	addi	s0,sp,64
    800008ca:	8aaa                	mv	s5,a0
    800008cc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800008ce:	6785                	lui	a5,0x1
    800008d0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008d2:	95be                	add	a1,a1,a5
    800008d4:	77fd                	lui	a5,0xfffff
    800008d6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800008da:	08c9f063          	bgeu	s3,a2,8000095a <uvmalloc+0xa2>
    800008de:	f426                	sd	s1,40(sp)
    800008e0:	f04a                	sd	s2,32(sp)
    800008e2:	e05a                	sd	s6,0(sp)
    800008e4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800008e6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800008ea:	8efff0ef          	jal	800001d8 <kalloc>
    800008ee:	84aa                	mv	s1,a0
    if(mem == 0){
    800008f0:	c515                	beqz	a0,8000091c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800008f2:	6605                	lui	a2,0x1
    800008f4:	4581                	li	a1,0
    800008f6:	94dff0ef          	jal	80000242 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800008fa:	875a                	mv	a4,s6
    800008fc:	86a6                	mv	a3,s1
    800008fe:	6605                	lui	a2,0x1
    80000900:	85ca                	mv	a1,s2
    80000902:	8556                	mv	a0,s5
    80000904:	c8bff0ef          	jal	8000058e <mappages>
    80000908:	e915                	bnez	a0,8000093c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000090a:	6785                	lui	a5,0x1
    8000090c:	993e                	add	s2,s2,a5
    8000090e:	fd496ee3          	bltu	s2,s4,800008ea <uvmalloc+0x32>
  return newsz;
    80000912:	8552                	mv	a0,s4
    80000914:	74a2                	ld	s1,40(sp)
    80000916:	7902                	ld	s2,32(sp)
    80000918:	6b02                	ld	s6,0(sp)
    8000091a:	a811                	j	8000092e <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    8000091c:	864e                	mv	a2,s3
    8000091e:	85ca                	mv	a1,s2
    80000920:	8556                	mv	a0,s5
    80000922:	f53ff0ef          	jal	80000874 <uvmdealloc>
      return 0;
    80000926:	4501                	li	a0,0
    80000928:	74a2                	ld	s1,40(sp)
    8000092a:	7902                	ld	s2,32(sp)
    8000092c:	6b02                	ld	s6,0(sp)
}
    8000092e:	70e2                	ld	ra,56(sp)
    80000930:	7442                	ld	s0,48(sp)
    80000932:	69e2                	ld	s3,24(sp)
    80000934:	6a42                	ld	s4,16(sp)
    80000936:	6aa2                	ld	s5,8(sp)
    80000938:	6121                	addi	sp,sp,64
    8000093a:	8082                	ret
      kfree(mem);
    8000093c:	8526                	mv	a0,s1
    8000093e:	f72ff0ef          	jal	800000b0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000942:	864e                	mv	a2,s3
    80000944:	85ca                	mv	a1,s2
    80000946:	8556                	mv	a0,s5
    80000948:	f2dff0ef          	jal	80000874 <uvmdealloc>
      return 0;
    8000094c:	4501                	li	a0,0
    8000094e:	74a2                	ld	s1,40(sp)
    80000950:	7902                	ld	s2,32(sp)
    80000952:	6b02                	ld	s6,0(sp)
    80000954:	bfe9                	j	8000092e <uvmalloc+0x76>
    return oldsz;
    80000956:	852e                	mv	a0,a1
}
    80000958:	8082                	ret
  return newsz;
    8000095a:	8532                	mv	a0,a2
    8000095c:	bfc9                	j	8000092e <uvmalloc+0x76>

000000008000095e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000095e:	7179                	addi	sp,sp,-48
    80000960:	f406                	sd	ra,40(sp)
    80000962:	f022                	sd	s0,32(sp)
    80000964:	ec26                	sd	s1,24(sp)
    80000966:	e84a                	sd	s2,16(sp)
    80000968:	e44e                	sd	s3,8(sp)
    8000096a:	e052                	sd	s4,0(sp)
    8000096c:	1800                	addi	s0,sp,48
    8000096e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000970:	84aa                	mv	s1,a0
    80000972:	6905                	lui	s2,0x1
    80000974:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000976:	4985                	li	s3,1
    80000978:	a819                	j	8000098e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000097a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000097c:	00c79513          	slli	a0,a5,0xc
    80000980:	fdfff0ef          	jal	8000095e <freewalk>
      pagetable[i] = 0;
    80000984:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000988:	04a1                	addi	s1,s1,8
    8000098a:	01248f63          	beq	s1,s2,800009a8 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000098e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000990:	00f7f713          	andi	a4,a5,15
    80000994:	ff3703e3          	beq	a4,s3,8000097a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000998:	8b85                	andi	a5,a5,1
    8000099a:	d7fd                	beqz	a5,80000988 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000099c:	00006517          	auipc	a0,0x6
    800009a0:	79c50513          	addi	a0,a0,1948 # 80007138 <etext+0x138>
    800009a4:	4df040ef          	jal	80005682 <panic>
    }
  }
  kfree((void*)pagetable);
    800009a8:	8552                	mv	a0,s4
    800009aa:	f06ff0ef          	jal	800000b0 <kfree>
}
    800009ae:	70a2                	ld	ra,40(sp)
    800009b0:	7402                	ld	s0,32(sp)
    800009b2:	64e2                	ld	s1,24(sp)
    800009b4:	6942                	ld	s2,16(sp)
    800009b6:	69a2                	ld	s3,8(sp)
    800009b8:	6a02                	ld	s4,0(sp)
    800009ba:	6145                	addi	sp,sp,48
    800009bc:	8082                	ret

00000000800009be <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800009be:	1101                	addi	sp,sp,-32
    800009c0:	ec06                	sd	ra,24(sp)
    800009c2:	e822                	sd	s0,16(sp)
    800009c4:	e426                	sd	s1,8(sp)
    800009c6:	1000                	addi	s0,sp,32
    800009c8:	84aa                	mv	s1,a0
  if(sz > 0)
    800009ca:	e989                	bnez	a1,800009dc <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800009cc:	8526                	mv	a0,s1
    800009ce:	f91ff0ef          	jal	8000095e <freewalk>
}
    800009d2:	60e2                	ld	ra,24(sp)
    800009d4:	6442                	ld	s0,16(sp)
    800009d6:	64a2                	ld	s1,8(sp)
    800009d8:	6105                	addi	sp,sp,32
    800009da:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800009dc:	6785                	lui	a5,0x1
    800009de:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800009e0:	95be                	add	a1,a1,a5
    800009e2:	4685                	li	a3,1
    800009e4:	00c5d613          	srli	a2,a1,0xc
    800009e8:	4581                	li	a1,0
    800009ea:	d4bff0ef          	jal	80000734 <uvmunmap>
    800009ee:	bff9                	j	800009cc <uvmfree+0xe>

00000000800009f0 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800009f0:	7139                	addi	sp,sp,-64
    800009f2:	fc06                	sd	ra,56(sp)
    800009f4:	f822                	sd	s0,48(sp)
    800009f6:	e05a                	sd	s6,0(sp)
    800009f8:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800009fa:	ce4d                	beqz	a2,80000ab4 <uvmcopy+0xc4>
    800009fc:	f426                	sd	s1,40(sp)
    800009fe:	f04a                	sd	s2,32(sp)
    80000a00:	ec4e                	sd	s3,24(sp)
    80000a02:	e852                	sd	s4,16(sp)
    80000a04:	e456                	sd	s5,8(sp)
    80000a06:	8a2a                	mv	s4,a0
    80000a08:	89ae                	mv	s3,a1
    80000a0a:	8932                	mv	s2,a2
    80000a0c:	4481                	li	s1,0
    80000a0e:	a0a9                	j	80000a58 <uvmcopy+0x68>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    80000a10:	00006517          	auipc	a0,0x6
    80000a14:	73850513          	addi	a0,a0,1848 # 80007148 <etext+0x148>
    80000a18:	46b040ef          	jal	80005682 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    80000a1c:	00006517          	auipc	a0,0x6
    80000a20:	74c50513          	addi	a0,a0,1868 # 80007168 <etext+0x168>
    80000a24:	45f040ef          	jal	80005682 <panic>
    flags = PTE_FLAGS(*pte);

    // COW modification:
    if(flags & PTE_W){
      // Remove writable, add COW flag for both parent and child
      *pte = (*pte & ~PTE_W) | PTE_COW;
    80000a28:	efb7f793          	andi	a5,a5,-261
    80000a2c:	1007e793          	ori	a5,a5,256
    80000a30:	e11c                	sd	a5,0(a0)
      flags = (flags & ~PTE_W) | PTE_COW;
    80000a32:	2fb77713          	andi	a4,a4,763
    80000a36:	10076713          	ori	a4,a4,256
    }

    // Map child page to the same physical address, with COW flag if set
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80000a3a:	86d6                	mv	a3,s5
    80000a3c:	6605                	lui	a2,0x1
    80000a3e:	85a6                	mv	a1,s1
    80000a40:	854e                	mv	a0,s3
    80000a42:	b4dff0ef          	jal	8000058e <mappages>
    80000a46:	8b2a                	mv	s6,a0
    80000a48:	ed0d                	bnez	a0,80000a82 <uvmcopy+0x92>
      goto err;
    }

    // Increment ref count on the physical page
    inc_ref((void*)pa);
    80000a4a:	8556                	mv	a0,s5
    80000a4c:	dd0ff0ef          	jal	8000001c <inc_ref>
  for(i = 0; i < sz; i += PGSIZE){
    80000a50:	6785                	lui	a5,0x1
    80000a52:	94be                	add	s1,s1,a5
    80000a54:	0524fa63          	bgeu	s1,s2,80000aa8 <uvmcopy+0xb8>
    if((pte = walk(old, i, 0)) == 0)
    80000a58:	4601                	li	a2,0
    80000a5a:	85a6                	mv	a1,s1
    80000a5c:	8552                	mv	a0,s4
    80000a5e:	a59ff0ef          	jal	800004b6 <walk>
    80000a62:	d55d                	beqz	a0,80000a10 <uvmcopy+0x20>
    if((*pte & PTE_V) == 0)
    80000a64:	611c                	ld	a5,0(a0)
    80000a66:	0017f713          	andi	a4,a5,1
    80000a6a:	db4d                	beqz	a4,80000a1c <uvmcopy+0x2c>
    pa = PTE2PA(*pte);
    80000a6c:	00a7da93          	srli	s5,a5,0xa
    80000a70:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte);
    80000a72:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W){
    80000a76:	0047f693          	andi	a3,a5,4
    80000a7a:	f6dd                	bnez	a3,80000a28 <uvmcopy+0x38>
    flags = PTE_FLAGS(*pte);
    80000a7c:	3ff77713          	andi	a4,a4,1023
    80000a80:	bf6d                	j	80000a3a <uvmcopy+0x4a>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 0);
    80000a82:	4681                	li	a3,0
    80000a84:	00c4d613          	srli	a2,s1,0xc
    80000a88:	4581                	li	a1,0
    80000a8a:	854e                	mv	a0,s3
    80000a8c:	ca9ff0ef          	jal	80000734 <uvmunmap>
  return -1;
    80000a90:	5b7d                	li	s6,-1
    80000a92:	74a2                	ld	s1,40(sp)
    80000a94:	7902                	ld	s2,32(sp)
    80000a96:	69e2                	ld	s3,24(sp)
    80000a98:	6a42                	ld	s4,16(sp)
    80000a9a:	6aa2                	ld	s5,8(sp)
}
    80000a9c:	855a                	mv	a0,s6
    80000a9e:	70e2                	ld	ra,56(sp)
    80000aa0:	7442                	ld	s0,48(sp)
    80000aa2:	6b02                	ld	s6,0(sp)
    80000aa4:	6121                	addi	sp,sp,64
    80000aa6:	8082                	ret
    80000aa8:	74a2                	ld	s1,40(sp)
    80000aaa:	7902                	ld	s2,32(sp)
    80000aac:	69e2                	ld	s3,24(sp)
    80000aae:	6a42                	ld	s4,16(sp)
    80000ab0:	6aa2                	ld	s5,8(sp)
    80000ab2:	b7ed                	j	80000a9c <uvmcopy+0xac>
  return 0;
    80000ab4:	4b01                	li	s6,0
    80000ab6:	b7dd                	j	80000a9c <uvmcopy+0xac>

0000000080000ab8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000ac0:	4601                	li	a2,0
    80000ac2:	9f5ff0ef          	jal	800004b6 <walk>
  if(pte == 0)
    80000ac6:	c901                	beqz	a0,80000ad6 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000ac8:	611c                	ld	a5,0(a0)
    80000aca:	9bbd                	andi	a5,a5,-17
    80000acc:	e11c                	sd	a5,0(a0)
}
    80000ace:	60a2                	ld	ra,8(sp)
    80000ad0:	6402                	ld	s0,0(sp)
    80000ad2:	0141                	addi	sp,sp,16
    80000ad4:	8082                	ret
    panic("uvmclear");
    80000ad6:	00006517          	auipc	a0,0x6
    80000ada:	6b250513          	addi	a0,a0,1714 # 80007188 <etext+0x188>
    80000ade:	3a5040ef          	jal	80005682 <panic>

0000000080000ae2 <copyout>:
{
  uint64 n, va0, pa0;
  pte_t *pte;
  char *mem;

  while(len > 0){
    80000ae2:	10068f63          	beqz	a3,80000c00 <copyout+0x11e>
{
    80000ae6:	7159                	addi	sp,sp,-112
    80000ae8:	f486                	sd	ra,104(sp)
    80000aea:	f0a2                	sd	s0,96(sp)
    80000aec:	e8ca                	sd	s2,80(sp)
    80000aee:	e4ce                	sd	s3,72(sp)
    80000af0:	e0d2                	sd	s4,64(sp)
    80000af2:	fc56                	sd	s5,56(sp)
    80000af4:	f85a                	sd	s6,48(sp)
    80000af6:	1880                	addi	s0,sp,112
    80000af8:	8b2a                	mv	s6,a0
    80000afa:	89ae                	mv	s3,a1
    80000afc:	8ab2                	mv	s5,a2
    80000afe:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80000b00:	797d                	lui	s2,0xfffff
    80000b02:	0125f933          	and	s2,a1,s2
    if(va0 >= MAXVA)
    80000b06:	57fd                	li	a5,-1
    80000b08:	83e9                	srli	a5,a5,0x1a
    80000b0a:	0f27ed63          	bltu	a5,s2,80000c04 <copyout+0x122>
    80000b0e:	eca6                	sd	s1,88(sp)
    80000b10:	f45e                	sd	s7,40(sp)
    80000b12:	f062                	sd	s8,32(sp)
    80000b14:	ec66                	sd	s9,24(sp)
    80000b16:	e86a                	sd	s10,16(sp)
    80000b18:	e46e                	sd	s11,8(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80000b1a:	4c45                	li	s8,17
      return -1;

    // Handle COW: if page is marked COW and not writable, do COW split
    if((*pte & PTE_COW) && !(*pte & PTE_W)){
    80000b1c:	10000c93          	li	s9,256
    va0 = PGROUNDDOWN(dstva);
    80000b20:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80000b22:	8bbe                	mv	s7,a5
    80000b24:	a849                	j	80000bb6 <copyout+0xd4>
      pa0 = PTE2PA(*pte);
    80000b26:	83a9                	srli	a5,a5,0xa
    80000b28:	00c79493          	slli	s1,a5,0xc
      if((mem = kalloc()) == 0)
    80000b2c:	eacff0ef          	jal	800001d8 <kalloc>
    80000b30:	8daa                	mv	s11,a0
    80000b32:	10050b63          	beqz	a0,80000c48 <copyout+0x166>
        return -1;
      memmove(mem, (char*)pa0, PGSIZE);
    80000b36:	6605                	lui	a2,0x1
    80000b38:	85a6                	mv	a1,s1
    80000b3a:	f64ff0ef          	jal	8000029e <memmove>
      uvmunmap(pagetable, va0, 1, 0);
    80000b3e:	4681                	li	a3,0
    80000b40:	4605                	li	a2,1
    80000b42:	85ca                	mv	a1,s2
    80000b44:	855a                	mv	a0,s6
    80000b46:	befff0ef          	jal	80000734 <uvmunmap>
      if(mappages(pagetable, va0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U) != 0){
    80000b4a:	4779                	li	a4,30
    80000b4c:	86ee                	mv	a3,s11
    80000b4e:	6605                	lui	a2,0x1
    80000b50:	85ca                	mv	a1,s2
    80000b52:	855a                	mv	a0,s6
    80000b54:	a3bff0ef          	jal	8000058e <mappages>
    80000b58:	e115                	bnez	a0,80000b7c <copyout+0x9a>
        kfree(mem);
        return -1;
      }
      dec_ref((void*)pa0);
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	d0aff0ef          	jal	80000066 <dec_ref>
      pte = walk(pagetable, va0, 0);
    80000b60:	4601                	li	a2,0
    80000b62:	85ca                	mv	a1,s2
    80000b64:	855a                	mv	a0,s6
    80000b66:	951ff0ef          	jal	800004b6 <walk>
      if(pte == 0)
    80000b6a:	e52d                	bnez	a0,80000bd4 <copyout+0xf2>
        return -1;
    80000b6c:	557d                	li	a0,-1
    80000b6e:	64e6                	ld	s1,88(sp)
    80000b70:	7ba2                	ld	s7,40(sp)
    80000b72:	7c02                	ld	s8,32(sp)
    80000b74:	6ce2                	ld	s9,24(sp)
    80000b76:	6d42                	ld	s10,16(sp)
    80000b78:	6da2                	ld	s11,8(sp)
    80000b7a:	a075                	j	80000c26 <copyout+0x144>
        kfree(mem);
    80000b7c:	856e                	mv	a0,s11
    80000b7e:	d32ff0ef          	jal	800000b0 <kfree>
        return -1;
    80000b82:	557d                	li	a0,-1
    80000b84:	64e6                	ld	s1,88(sp)
    80000b86:	7ba2                	ld	s7,40(sp)
    80000b88:	7c02                	ld	s8,32(sp)
    80000b8a:	6ce2                	ld	s9,24(sp)
    80000b8c:	6d42                	ld	s10,16(sp)
    80000b8e:	6da2                	ld	s11,8(sp)
    80000b90:	a859                	j	80000c26 <copyout+0x144>
      return -1;

    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b92:	41298933          	sub	s2,s3,s2
    80000b96:	0004861b          	sext.w	a2,s1
    80000b9a:	85d6                	mv	a1,s5
    80000b9c:	954a                	add	a0,a0,s2
    80000b9e:	f00ff0ef          	jal	8000029e <memmove>

    len -= n;
    80000ba2:	409a0a33          	sub	s4,s4,s1
    src += n;
    80000ba6:	9aa6                	add	s5,s5,s1
    dstva += n;
    80000ba8:	99a6                	add	s3,s3,s1
  while(len > 0){
    80000baa:	040a0363          	beqz	s4,80000bf0 <copyout+0x10e>
    va0 = PGROUNDDOWN(dstva);
    80000bae:	01a9f933          	and	s2,s3,s10
    if(va0 >= MAXVA)
    80000bb2:	052beb63          	bltu	s7,s2,80000c08 <copyout+0x126>
    pte = walk(pagetable, va0, 0);
    80000bb6:	4601                	li	a2,0
    80000bb8:	85ca                	mv	a1,s2
    80000bba:	855a                	mv	a0,s6
    80000bbc:	8fbff0ef          	jal	800004b6 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80000bc0:	cd21                	beqz	a0,80000c18 <copyout+0x136>
    80000bc2:	611c                	ld	a5,0(a0)
    80000bc4:	0117f713          	andi	a4,a5,17
    80000bc8:	07871863          	bne	a4,s8,80000c38 <copyout+0x156>
    if((*pte & PTE_COW) && !(*pte & PTE_W)){
    80000bcc:	1047f713          	andi	a4,a5,260
    80000bd0:	f5970be3          	beq	a4,s9,80000b26 <copyout+0x44>
    pa0 = PTE2PA(*pte);
    80000bd4:	611c                	ld	a5,0(a0)
    80000bd6:	00a7d513          	srli	a0,a5,0xa
    80000bda:	0532                	slli	a0,a0,0xc
    if((*pte & PTE_W) == 0)
    80000bdc:	8b91                	andi	a5,a5,4
    80000bde:	cfad                	beqz	a5,80000c58 <copyout+0x176>
    n = PGSIZE - (dstva - va0);
    80000be0:	6485                	lui	s1,0x1
    80000be2:	94ca                	add	s1,s1,s2
    80000be4:	413484b3          	sub	s1,s1,s3
    if(n > len)
    80000be8:	fa9a75e3          	bgeu	s4,s1,80000b92 <copyout+0xb0>
    80000bec:	84d2                	mv	s1,s4
    80000bee:	b755                	j	80000b92 <copyout+0xb0>
  }
  return 0;
    80000bf0:	4501                	li	a0,0
    80000bf2:	64e6                	ld	s1,88(sp)
    80000bf4:	7ba2                	ld	s7,40(sp)
    80000bf6:	7c02                	ld	s8,32(sp)
    80000bf8:	6ce2                	ld	s9,24(sp)
    80000bfa:	6d42                	ld	s10,16(sp)
    80000bfc:	6da2                	ld	s11,8(sp)
    80000bfe:	a025                	j	80000c26 <copyout+0x144>
    80000c00:	4501                	li	a0,0
}
    80000c02:	8082                	ret
      return -1;
    80000c04:	557d                	li	a0,-1
    80000c06:	a005                	j	80000c26 <copyout+0x144>
    80000c08:	557d                	li	a0,-1
    80000c0a:	64e6                	ld	s1,88(sp)
    80000c0c:	7ba2                	ld	s7,40(sp)
    80000c0e:	7c02                	ld	s8,32(sp)
    80000c10:	6ce2                	ld	s9,24(sp)
    80000c12:	6d42                	ld	s10,16(sp)
    80000c14:	6da2                	ld	s11,8(sp)
    80000c16:	a801                	j	80000c26 <copyout+0x144>
      return -1;
    80000c18:	557d                	li	a0,-1
    80000c1a:	64e6                	ld	s1,88(sp)
    80000c1c:	7ba2                	ld	s7,40(sp)
    80000c1e:	7c02                	ld	s8,32(sp)
    80000c20:	6ce2                	ld	s9,24(sp)
    80000c22:	6d42                	ld	s10,16(sp)
    80000c24:	6da2                	ld	s11,8(sp)
}
    80000c26:	70a6                	ld	ra,104(sp)
    80000c28:	7406                	ld	s0,96(sp)
    80000c2a:	6946                	ld	s2,80(sp)
    80000c2c:	69a6                	ld	s3,72(sp)
    80000c2e:	6a06                	ld	s4,64(sp)
    80000c30:	7ae2                	ld	s5,56(sp)
    80000c32:	7b42                	ld	s6,48(sp)
    80000c34:	6165                	addi	sp,sp,112
    80000c36:	8082                	ret
      return -1;
    80000c38:	557d                	li	a0,-1
    80000c3a:	64e6                	ld	s1,88(sp)
    80000c3c:	7ba2                	ld	s7,40(sp)
    80000c3e:	7c02                	ld	s8,32(sp)
    80000c40:	6ce2                	ld	s9,24(sp)
    80000c42:	6d42                	ld	s10,16(sp)
    80000c44:	6da2                	ld	s11,8(sp)
    80000c46:	b7c5                	j	80000c26 <copyout+0x144>
        return -1;
    80000c48:	557d                	li	a0,-1
    80000c4a:	64e6                	ld	s1,88(sp)
    80000c4c:	7ba2                	ld	s7,40(sp)
    80000c4e:	7c02                	ld	s8,32(sp)
    80000c50:	6ce2                	ld	s9,24(sp)
    80000c52:	6d42                	ld	s10,16(sp)
    80000c54:	6da2                	ld	s11,8(sp)
    80000c56:	bfc1                	j	80000c26 <copyout+0x144>
      return -1;
    80000c58:	557d                	li	a0,-1
    80000c5a:	64e6                	ld	s1,88(sp)
    80000c5c:	7ba2                	ld	s7,40(sp)
    80000c5e:	7c02                	ld	s8,32(sp)
    80000c60:	6ce2                	ld	s9,24(sp)
    80000c62:	6d42                	ld	s10,16(sp)
    80000c64:	6da2                	ld	s11,8(sp)
    80000c66:	b7c1                	j	80000c26 <copyout+0x144>

0000000080000c68 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c68:	c6a5                	beqz	a3,80000cd0 <copyin+0x68>
{
    80000c6a:	715d                	addi	sp,sp,-80
    80000c6c:	e486                	sd	ra,72(sp)
    80000c6e:	e0a2                	sd	s0,64(sp)
    80000c70:	fc26                	sd	s1,56(sp)
    80000c72:	f84a                	sd	s2,48(sp)
    80000c74:	f44e                	sd	s3,40(sp)
    80000c76:	f052                	sd	s4,32(sp)
    80000c78:	ec56                	sd	s5,24(sp)
    80000c7a:	e85a                	sd	s6,16(sp)
    80000c7c:	e45e                	sd	s7,8(sp)
    80000c7e:	e062                	sd	s8,0(sp)
    80000c80:	0880                	addi	s0,sp,80
    80000c82:	8b2a                	mv	s6,a0
    80000c84:	8a2e                	mv	s4,a1
    80000c86:	8c32                	mv	s8,a2
    80000c88:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000c8a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c8c:	6a85                	lui	s5,0x1
    80000c8e:	a00d                	j	80000cb0 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c90:	018505b3          	add	a1,a0,s8
    80000c94:	0004861b          	sext.w	a2,s1
    80000c98:	412585b3          	sub	a1,a1,s2
    80000c9c:	8552                	mv	a0,s4
    80000c9e:	e00ff0ef          	jal	8000029e <memmove>

    len -= n;
    80000ca2:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000ca6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000ca8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000cac:	02098063          	beqz	s3,80000ccc <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000cb0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cb4:	85ca                	mv	a1,s2
    80000cb6:	855a                	mv	a0,s6
    80000cb8:	899ff0ef          	jal	80000550 <walkaddr>
    if(pa0 == 0)
    80000cbc:	cd01                	beqz	a0,80000cd4 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000cbe:	418904b3          	sub	s1,s2,s8
    80000cc2:	94d6                	add	s1,s1,s5
    if(n > len)
    80000cc4:	fc99f6e3          	bgeu	s3,s1,80000c90 <copyin+0x28>
    80000cc8:	84ce                	mv	s1,s3
    80000cca:	b7d9                	j	80000c90 <copyin+0x28>
  }
  return 0;
    80000ccc:	4501                	li	a0,0
    80000cce:	a021                	j	80000cd6 <copyin+0x6e>
    80000cd0:	4501                	li	a0,0
}
    80000cd2:	8082                	ret
      return -1;
    80000cd4:	557d                	li	a0,-1
}
    80000cd6:	60a6                	ld	ra,72(sp)
    80000cd8:	6406                	ld	s0,64(sp)
    80000cda:	74e2                	ld	s1,56(sp)
    80000cdc:	7942                	ld	s2,48(sp)
    80000cde:	79a2                	ld	s3,40(sp)
    80000ce0:	7a02                	ld	s4,32(sp)
    80000ce2:	6ae2                	ld	s5,24(sp)
    80000ce4:	6b42                	ld	s6,16(sp)
    80000ce6:	6ba2                	ld	s7,8(sp)
    80000ce8:	6c02                	ld	s8,0(sp)
    80000cea:	6161                	addi	sp,sp,80
    80000cec:	8082                	ret

0000000080000cee <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000cee:	c6dd                	beqz	a3,80000d9c <copyinstr+0xae>
{
    80000cf0:	715d                	addi	sp,sp,-80
    80000cf2:	e486                	sd	ra,72(sp)
    80000cf4:	e0a2                	sd	s0,64(sp)
    80000cf6:	fc26                	sd	s1,56(sp)
    80000cf8:	f84a                	sd	s2,48(sp)
    80000cfa:	f44e                	sd	s3,40(sp)
    80000cfc:	f052                	sd	s4,32(sp)
    80000cfe:	ec56                	sd	s5,24(sp)
    80000d00:	e85a                	sd	s6,16(sp)
    80000d02:	e45e                	sd	s7,8(sp)
    80000d04:	0880                	addi	s0,sp,80
    80000d06:	8a2a                	mv	s4,a0
    80000d08:	8b2e                	mv	s6,a1
    80000d0a:	8bb2                	mv	s7,a2
    80000d0c:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000d0e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d10:	6985                	lui	s3,0x1
    80000d12:	a825                	j	80000d4a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000d14:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d18:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000d1a:	37fd                	addiw	a5,a5,-1
    80000d1c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000d20:	60a6                	ld	ra,72(sp)
    80000d22:	6406                	ld	s0,64(sp)
    80000d24:	74e2                	ld	s1,56(sp)
    80000d26:	7942                	ld	s2,48(sp)
    80000d28:	79a2                	ld	s3,40(sp)
    80000d2a:	7a02                	ld	s4,32(sp)
    80000d2c:	6ae2                	ld	s5,24(sp)
    80000d2e:	6b42                	ld	s6,16(sp)
    80000d30:	6ba2                	ld	s7,8(sp)
    80000d32:	6161                	addi	sp,sp,80
    80000d34:	8082                	ret
    80000d36:	fff90713          	addi	a4,s2,-1 # ffffffffffffefff <end+0xffffffff7ffbb94f>
    80000d3a:	9742                	add	a4,a4,a6
      --max;
    80000d3c:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000d40:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000d44:	04e58463          	beq	a1,a4,80000d8c <copyinstr+0x9e>
{
    80000d48:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000d4a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000d4e:	85a6                	mv	a1,s1
    80000d50:	8552                	mv	a0,s4
    80000d52:	ffeff0ef          	jal	80000550 <walkaddr>
    if(pa0 == 0)
    80000d56:	cd0d                	beqz	a0,80000d90 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000d58:	417486b3          	sub	a3,s1,s7
    80000d5c:	96ce                	add	a3,a3,s3
    if(n > max)
    80000d5e:	00d97363          	bgeu	s2,a3,80000d64 <copyinstr+0x76>
    80000d62:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80000d64:	955e                	add	a0,a0,s7
    80000d66:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80000d68:	c695                	beqz	a3,80000d94 <copyinstr+0xa6>
    80000d6a:	87da                	mv	a5,s6
    80000d6c:	885a                	mv	a6,s6
      if(*p == '\0'){
    80000d6e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80000d72:	96da                	add	a3,a3,s6
    80000d74:	85be                	mv	a1,a5
      if(*p == '\0'){
    80000d76:	00f60733          	add	a4,a2,a5
    80000d7a:	00074703          	lbu	a4,0(a4)
    80000d7e:	db59                	beqz	a4,80000d14 <copyinstr+0x26>
        *dst = *p;
    80000d80:	00e78023          	sb	a4,0(a5)
      dst++;
    80000d84:	0785                	addi	a5,a5,1
    while(n > 0){
    80000d86:	fed797e3          	bne	a5,a3,80000d74 <copyinstr+0x86>
    80000d8a:	b775                	j	80000d36 <copyinstr+0x48>
    80000d8c:	4781                	li	a5,0
    80000d8e:	b771                	j	80000d1a <copyinstr+0x2c>
      return -1;
    80000d90:	557d                	li	a0,-1
    80000d92:	b779                	j	80000d20 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80000d94:	6b85                	lui	s7,0x1
    80000d96:	9ba6                	add	s7,s7,s1
    80000d98:	87da                	mv	a5,s6
    80000d9a:	b77d                	j	80000d48 <copyinstr+0x5a>
  int got_null = 0;
    80000d9c:	4781                	li	a5,0
  if(got_null){
    80000d9e:	37fd                	addiw	a5,a5,-1
    80000da0:	0007851b          	sext.w	a0,a5
}
    80000da4:	8082                	ret

0000000080000da6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000da6:	7139                	addi	sp,sp,-64
    80000da8:	fc06                	sd	ra,56(sp)
    80000daa:	f822                	sd	s0,48(sp)
    80000dac:	f426                	sd	s1,40(sp)
    80000dae:	f04a                	sd	s2,32(sp)
    80000db0:	ec4e                	sd	s3,24(sp)
    80000db2:	e852                	sd	s4,16(sp)
    80000db4:	e456                	sd	s5,8(sp)
    80000db6:	e05a                	sd	s6,0(sp)
    80000db8:	0080                	addi	s0,sp,64
    80000dba:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dbc:	0002a497          	auipc	s1,0x2a
    80000dc0:	a1448493          	addi	s1,s1,-1516 # 8002a7d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000dc4:	8b26                	mv	s6,s1
    80000dc6:	04fa5937          	lui	s2,0x4fa5
    80000dca:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000dce:	0932                	slli	s2,s2,0xc
    80000dd0:	fa590913          	addi	s2,s2,-91
    80000dd4:	0932                	slli	s2,s2,0xc
    80000dd6:	fa590913          	addi	s2,s2,-91
    80000dda:	0932                	slli	s2,s2,0xc
    80000ddc:	fa590913          	addi	s2,s2,-91
    80000de0:	040009b7          	lui	s3,0x4000
    80000de4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000de6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000de8:	0002fa97          	auipc	s5,0x2f
    80000dec:	3e8a8a93          	addi	s5,s5,1000 # 800301d0 <tickslock>
    char *pa = kalloc();
    80000df0:	be8ff0ef          	jal	800001d8 <kalloc>
    80000df4:	862a                	mv	a2,a0
    if(pa == 0)
    80000df6:	cd15                	beqz	a0,80000e32 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000df8:	416485b3          	sub	a1,s1,s6
    80000dfc:	858d                	srai	a1,a1,0x3
    80000dfe:	032585b3          	mul	a1,a1,s2
    80000e02:	2585                	addiw	a1,a1,1
    80000e04:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e08:	4719                	li	a4,6
    80000e0a:	6685                	lui	a3,0x1
    80000e0c:	40b985b3          	sub	a1,s3,a1
    80000e10:	8552                	mv	a0,s4
    80000e12:	82dff0ef          	jal	8000063e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e16:	16848493          	addi	s1,s1,360
    80000e1a:	fd549be3          	bne	s1,s5,80000df0 <proc_mapstacks+0x4a>
  }
}
    80000e1e:	70e2                	ld	ra,56(sp)
    80000e20:	7442                	ld	s0,48(sp)
    80000e22:	74a2                	ld	s1,40(sp)
    80000e24:	7902                	ld	s2,32(sp)
    80000e26:	69e2                	ld	s3,24(sp)
    80000e28:	6a42                	ld	s4,16(sp)
    80000e2a:	6aa2                	ld	s5,8(sp)
    80000e2c:	6b02                	ld	s6,0(sp)
    80000e2e:	6121                	addi	sp,sp,64
    80000e30:	8082                	ret
      panic("kalloc");
    80000e32:	00006517          	auipc	a0,0x6
    80000e36:	36650513          	addi	a0,a0,870 # 80007198 <etext+0x198>
    80000e3a:	049040ef          	jal	80005682 <panic>

0000000080000e3e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000e3e:	7139                	addi	sp,sp,-64
    80000e40:	fc06                	sd	ra,56(sp)
    80000e42:	f822                	sd	s0,48(sp)
    80000e44:	f426                	sd	s1,40(sp)
    80000e46:	f04a                	sd	s2,32(sp)
    80000e48:	ec4e                	sd	s3,24(sp)
    80000e4a:	e852                	sd	s4,16(sp)
    80000e4c:	e456                	sd	s5,8(sp)
    80000e4e:	e05a                	sd	s6,0(sp)
    80000e50:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000e52:	00006597          	auipc	a1,0x6
    80000e56:	34e58593          	addi	a1,a1,846 # 800071a0 <etext+0x1a0>
    80000e5a:	00029517          	auipc	a0,0x29
    80000e5e:	54650513          	addi	a0,a0,1350 # 8002a3a0 <pid_lock>
    80000e62:	2cf040ef          	jal	80005930 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000e66:	00006597          	auipc	a1,0x6
    80000e6a:	34258593          	addi	a1,a1,834 # 800071a8 <etext+0x1a8>
    80000e6e:	00029517          	auipc	a0,0x29
    80000e72:	54a50513          	addi	a0,a0,1354 # 8002a3b8 <wait_lock>
    80000e76:	2bb040ef          	jal	80005930 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e7a:	0002a497          	auipc	s1,0x2a
    80000e7e:	95648493          	addi	s1,s1,-1706 # 8002a7d0 <proc>
      initlock(&p->lock, "proc");
    80000e82:	00006b17          	auipc	s6,0x6
    80000e86:	336b0b13          	addi	s6,s6,822 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000e8a:	8aa6                	mv	s5,s1
    80000e8c:	04fa5937          	lui	s2,0x4fa5
    80000e90:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000e94:	0932                	slli	s2,s2,0xc
    80000e96:	fa590913          	addi	s2,s2,-91
    80000e9a:	0932                	slli	s2,s2,0xc
    80000e9c:	fa590913          	addi	s2,s2,-91
    80000ea0:	0932                	slli	s2,s2,0xc
    80000ea2:	fa590913          	addi	s2,s2,-91
    80000ea6:	040009b7          	lui	s3,0x4000
    80000eaa:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000eac:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eae:	0002fa17          	auipc	s4,0x2f
    80000eb2:	322a0a13          	addi	s4,s4,802 # 800301d0 <tickslock>
      initlock(&p->lock, "proc");
    80000eb6:	85da                	mv	a1,s6
    80000eb8:	8526                	mv	a0,s1
    80000eba:	277040ef          	jal	80005930 <initlock>
      p->state = UNUSED;
    80000ebe:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000ec2:	415487b3          	sub	a5,s1,s5
    80000ec6:	878d                	srai	a5,a5,0x3
    80000ec8:	032787b3          	mul	a5,a5,s2
    80000ecc:	2785                	addiw	a5,a5,1
    80000ece:	00d7979b          	slliw	a5,a5,0xd
    80000ed2:	40f987b3          	sub	a5,s3,a5
    80000ed6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ed8:	16848493          	addi	s1,s1,360
    80000edc:	fd449de3          	bne	s1,s4,80000eb6 <procinit+0x78>
  }
}
    80000ee0:	70e2                	ld	ra,56(sp)
    80000ee2:	7442                	ld	s0,48(sp)
    80000ee4:	74a2                	ld	s1,40(sp)
    80000ee6:	7902                	ld	s2,32(sp)
    80000ee8:	69e2                	ld	s3,24(sp)
    80000eea:	6a42                	ld	s4,16(sp)
    80000eec:	6aa2                	ld	s5,8(sp)
    80000eee:	6b02                	ld	s6,0(sp)
    80000ef0:	6121                	addi	sp,sp,64
    80000ef2:	8082                	ret

0000000080000ef4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000ef4:	1141                	addi	sp,sp,-16
    80000ef6:	e422                	sd	s0,8(sp)
    80000ef8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000efa:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000efc:	2501                	sext.w	a0,a0
    80000efe:	6422                	ld	s0,8(sp)
    80000f00:	0141                	addi	sp,sp,16
    80000f02:	8082                	ret

0000000080000f04 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e422                	sd	s0,8(sp)
    80000f08:	0800                	addi	s0,sp,16
    80000f0a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f0c:	2781                	sext.w	a5,a5
    80000f0e:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f10:	00029517          	auipc	a0,0x29
    80000f14:	4c050513          	addi	a0,a0,1216 # 8002a3d0 <cpus>
    80000f18:	953e                	add	a0,a0,a5
    80000f1a:	6422                	ld	s0,8(sp)
    80000f1c:	0141                	addi	sp,sp,16
    80000f1e:	8082                	ret

0000000080000f20 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000f20:	1101                	addi	sp,sp,-32
    80000f22:	ec06                	sd	ra,24(sp)
    80000f24:	e822                	sd	s0,16(sp)
    80000f26:	e426                	sd	s1,8(sp)
    80000f28:	1000                	addi	s0,sp,32
  push_off();
    80000f2a:	247040ef          	jal	80005970 <push_off>
    80000f2e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000f30:	2781                	sext.w	a5,a5
    80000f32:	079e                	slli	a5,a5,0x7
    80000f34:	00029717          	auipc	a4,0x29
    80000f38:	46c70713          	addi	a4,a4,1132 # 8002a3a0 <pid_lock>
    80000f3c:	97ba                	add	a5,a5,a4
    80000f3e:	7b84                	ld	s1,48(a5)
  pop_off();
    80000f40:	2b5040ef          	jal	800059f4 <pop_off>
  return p;
}
    80000f44:	8526                	mv	a0,s1
    80000f46:	60e2                	ld	ra,24(sp)
    80000f48:	6442                	ld	s0,16(sp)
    80000f4a:	64a2                	ld	s1,8(sp)
    80000f4c:	6105                	addi	sp,sp,32
    80000f4e:	8082                	ret

0000000080000f50 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000f50:	1141                	addi	sp,sp,-16
    80000f52:	e406                	sd	ra,8(sp)
    80000f54:	e022                	sd	s0,0(sp)
    80000f56:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000f58:	fc9ff0ef          	jal	80000f20 <myproc>
    80000f5c:	2ed040ef          	jal	80005a48 <release>

  if (first) {
    80000f60:	00009797          	auipc	a5,0x9
    80000f64:	3807a783          	lw	a5,896(a5) # 8000a2e0 <first.1>
    80000f68:	e799                	bnez	a5,80000f76 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000f6a:	2bf000ef          	jal	80001a28 <usertrapret>
}
    80000f6e:	60a2                	ld	ra,8(sp)
    80000f70:	6402                	ld	s0,0(sp)
    80000f72:	0141                	addi	sp,sp,16
    80000f74:	8082                	ret
    fsinit(ROOTDEV);
    80000f76:	4505                	li	a0,1
    80000f78:	728010ef          	jal	800026a0 <fsinit>
    first = 0;
    80000f7c:	00009797          	auipc	a5,0x9
    80000f80:	3607a223          	sw	zero,868(a5) # 8000a2e0 <first.1>
    __sync_synchronize();
    80000f84:	0330000f          	fence	rw,rw
    80000f88:	b7cd                	j	80000f6a <forkret+0x1a>

0000000080000f8a <allocpid>:
{
    80000f8a:	1101                	addi	sp,sp,-32
    80000f8c:	ec06                	sd	ra,24(sp)
    80000f8e:	e822                	sd	s0,16(sp)
    80000f90:	e426                	sd	s1,8(sp)
    80000f92:	e04a                	sd	s2,0(sp)
    80000f94:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f96:	00029917          	auipc	s2,0x29
    80000f9a:	40a90913          	addi	s2,s2,1034 # 8002a3a0 <pid_lock>
    80000f9e:	854a                	mv	a0,s2
    80000fa0:	211040ef          	jal	800059b0 <acquire>
  pid = nextpid;
    80000fa4:	00009797          	auipc	a5,0x9
    80000fa8:	34078793          	addi	a5,a5,832 # 8000a2e4 <nextpid>
    80000fac:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000fae:	0014871b          	addiw	a4,s1,1
    80000fb2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000fb4:	854a                	mv	a0,s2
    80000fb6:	293040ef          	jal	80005a48 <release>
}
    80000fba:	8526                	mv	a0,s1
    80000fbc:	60e2                	ld	ra,24(sp)
    80000fbe:	6442                	ld	s0,16(sp)
    80000fc0:	64a2                	ld	s1,8(sp)
    80000fc2:	6902                	ld	s2,0(sp)
    80000fc4:	6105                	addi	sp,sp,32
    80000fc6:	8082                	ret

0000000080000fc8 <proc_pagetable>:
{
    80000fc8:	1101                	addi	sp,sp,-32
    80000fca:	ec06                	sd	ra,24(sp)
    80000fcc:	e822                	sd	s0,16(sp)
    80000fce:	e426                	sd	s1,8(sp)
    80000fd0:	e04a                	sd	s2,0(sp)
    80000fd2:	1000                	addi	s0,sp,32
    80000fd4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000fd6:	81bff0ef          	jal	800007f0 <uvmcreate>
    80000fda:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000fdc:	cd05                	beqz	a0,80001014 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000fde:	4729                	li	a4,10
    80000fe0:	00005697          	auipc	a3,0x5
    80000fe4:	02068693          	addi	a3,a3,32 # 80006000 <_trampoline>
    80000fe8:	6605                	lui	a2,0x1
    80000fea:	040005b7          	lui	a1,0x4000
    80000fee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ff0:	05b2                	slli	a1,a1,0xc
    80000ff2:	d9cff0ef          	jal	8000058e <mappages>
    80000ff6:	02054663          	bltz	a0,80001022 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000ffa:	4719                	li	a4,6
    80000ffc:	05893683          	ld	a3,88(s2)
    80001000:	6605                	lui	a2,0x1
    80001002:	020005b7          	lui	a1,0x2000
    80001006:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001008:	05b6                	slli	a1,a1,0xd
    8000100a:	8526                	mv	a0,s1
    8000100c:	d82ff0ef          	jal	8000058e <mappages>
    80001010:	00054f63          	bltz	a0,8000102e <proc_pagetable+0x66>
}
    80001014:	8526                	mv	a0,s1
    80001016:	60e2                	ld	ra,24(sp)
    80001018:	6442                	ld	s0,16(sp)
    8000101a:	64a2                	ld	s1,8(sp)
    8000101c:	6902                	ld	s2,0(sp)
    8000101e:	6105                	addi	sp,sp,32
    80001020:	8082                	ret
    uvmfree(pagetable, 0);
    80001022:	4581                	li	a1,0
    80001024:	8526                	mv	a0,s1
    80001026:	999ff0ef          	jal	800009be <uvmfree>
    return 0;
    8000102a:	4481                	li	s1,0
    8000102c:	b7e5                	j	80001014 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000102e:	4681                	li	a3,0
    80001030:	4605                	li	a2,1
    80001032:	040005b7          	lui	a1,0x4000
    80001036:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001038:	05b2                	slli	a1,a1,0xc
    8000103a:	8526                	mv	a0,s1
    8000103c:	ef8ff0ef          	jal	80000734 <uvmunmap>
    uvmfree(pagetable, 0);
    80001040:	4581                	li	a1,0
    80001042:	8526                	mv	a0,s1
    80001044:	97bff0ef          	jal	800009be <uvmfree>
    return 0;
    80001048:	4481                	li	s1,0
    8000104a:	b7e9                	j	80001014 <proc_pagetable+0x4c>

000000008000104c <proc_freepagetable>:
{
    8000104c:	1101                	addi	sp,sp,-32
    8000104e:	ec06                	sd	ra,24(sp)
    80001050:	e822                	sd	s0,16(sp)
    80001052:	e426                	sd	s1,8(sp)
    80001054:	e04a                	sd	s2,0(sp)
    80001056:	1000                	addi	s0,sp,32
    80001058:	84aa                	mv	s1,a0
    8000105a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000105c:	4681                	li	a3,0
    8000105e:	4605                	li	a2,1
    80001060:	040005b7          	lui	a1,0x4000
    80001064:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001066:	05b2                	slli	a1,a1,0xc
    80001068:	eccff0ef          	jal	80000734 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000106c:	4681                	li	a3,0
    8000106e:	4605                	li	a2,1
    80001070:	020005b7          	lui	a1,0x2000
    80001074:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001076:	05b6                	slli	a1,a1,0xd
    80001078:	8526                	mv	a0,s1
    8000107a:	ebaff0ef          	jal	80000734 <uvmunmap>
  uvmfree(pagetable, sz);
    8000107e:	85ca                	mv	a1,s2
    80001080:	8526                	mv	a0,s1
    80001082:	93dff0ef          	jal	800009be <uvmfree>
}
    80001086:	60e2                	ld	ra,24(sp)
    80001088:	6442                	ld	s0,16(sp)
    8000108a:	64a2                	ld	s1,8(sp)
    8000108c:	6902                	ld	s2,0(sp)
    8000108e:	6105                	addi	sp,sp,32
    80001090:	8082                	ret

0000000080001092 <freeproc>:
{
    80001092:	1101                	addi	sp,sp,-32
    80001094:	ec06                	sd	ra,24(sp)
    80001096:	e822                	sd	s0,16(sp)
    80001098:	e426                	sd	s1,8(sp)
    8000109a:	1000                	addi	s0,sp,32
    8000109c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000109e:	6d28                	ld	a0,88(a0)
    800010a0:	c119                	beqz	a0,800010a6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800010a2:	80eff0ef          	jal	800000b0 <kfree>
  p->trapframe = 0;
    800010a6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800010aa:	68a8                	ld	a0,80(s1)
    800010ac:	c501                	beqz	a0,800010b4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800010ae:	64ac                	ld	a1,72(s1)
    800010b0:	f9dff0ef          	jal	8000104c <proc_freepagetable>
  p->pagetable = 0;
    800010b4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800010b8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800010bc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800010c0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800010c4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800010c8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800010cc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800010d0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800010d4:	0004ac23          	sw	zero,24(s1)
}
    800010d8:	60e2                	ld	ra,24(sp)
    800010da:	6442                	ld	s0,16(sp)
    800010dc:	64a2                	ld	s1,8(sp)
    800010de:	6105                	addi	sp,sp,32
    800010e0:	8082                	ret

00000000800010e2 <allocproc>:
{
    800010e2:	1101                	addi	sp,sp,-32
    800010e4:	ec06                	sd	ra,24(sp)
    800010e6:	e822                	sd	s0,16(sp)
    800010e8:	e426                	sd	s1,8(sp)
    800010ea:	e04a                	sd	s2,0(sp)
    800010ec:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ee:	00029497          	auipc	s1,0x29
    800010f2:	6e248493          	addi	s1,s1,1762 # 8002a7d0 <proc>
    800010f6:	0002f917          	auipc	s2,0x2f
    800010fa:	0da90913          	addi	s2,s2,218 # 800301d0 <tickslock>
    acquire(&p->lock);
    800010fe:	8526                	mv	a0,s1
    80001100:	0b1040ef          	jal	800059b0 <acquire>
    if(p->state == UNUSED) {
    80001104:	4c9c                	lw	a5,24(s1)
    80001106:	cb91                	beqz	a5,8000111a <allocproc+0x38>
      release(&p->lock);
    80001108:	8526                	mv	a0,s1
    8000110a:	13f040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000110e:	16848493          	addi	s1,s1,360
    80001112:	ff2496e3          	bne	s1,s2,800010fe <allocproc+0x1c>
  return 0;
    80001116:	4481                	li	s1,0
    80001118:	a089                	j	8000115a <allocproc+0x78>
  p->pid = allocpid();
    8000111a:	e71ff0ef          	jal	80000f8a <allocpid>
    8000111e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001120:	4785                	li	a5,1
    80001122:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001124:	8b4ff0ef          	jal	800001d8 <kalloc>
    80001128:	892a                	mv	s2,a0
    8000112a:	eca8                	sd	a0,88(s1)
    8000112c:	cd15                	beqz	a0,80001168 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    8000112e:	8526                	mv	a0,s1
    80001130:	e99ff0ef          	jal	80000fc8 <proc_pagetable>
    80001134:	892a                	mv	s2,a0
    80001136:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001138:	c121                	beqz	a0,80001178 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    8000113a:	07000613          	li	a2,112
    8000113e:	4581                	li	a1,0
    80001140:	06048513          	addi	a0,s1,96
    80001144:	8feff0ef          	jal	80000242 <memset>
  p->context.ra = (uint64)forkret;
    80001148:	00000797          	auipc	a5,0x0
    8000114c:	e0878793          	addi	a5,a5,-504 # 80000f50 <forkret>
    80001150:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001152:	60bc                	ld	a5,64(s1)
    80001154:	6705                	lui	a4,0x1
    80001156:	97ba                	add	a5,a5,a4
    80001158:	f4bc                	sd	a5,104(s1)
}
    8000115a:	8526                	mv	a0,s1
    8000115c:	60e2                	ld	ra,24(sp)
    8000115e:	6442                	ld	s0,16(sp)
    80001160:	64a2                	ld	s1,8(sp)
    80001162:	6902                	ld	s2,0(sp)
    80001164:	6105                	addi	sp,sp,32
    80001166:	8082                	ret
    freeproc(p);
    80001168:	8526                	mv	a0,s1
    8000116a:	f29ff0ef          	jal	80001092 <freeproc>
    release(&p->lock);
    8000116e:	8526                	mv	a0,s1
    80001170:	0d9040ef          	jal	80005a48 <release>
    return 0;
    80001174:	84ca                	mv	s1,s2
    80001176:	b7d5                	j	8000115a <allocproc+0x78>
    freeproc(p);
    80001178:	8526                	mv	a0,s1
    8000117a:	f19ff0ef          	jal	80001092 <freeproc>
    release(&p->lock);
    8000117e:	8526                	mv	a0,s1
    80001180:	0c9040ef          	jal	80005a48 <release>
    return 0;
    80001184:	84ca                	mv	s1,s2
    80001186:	bfd1                	j	8000115a <allocproc+0x78>

0000000080001188 <userinit>:
{
    80001188:	1101                	addi	sp,sp,-32
    8000118a:	ec06                	sd	ra,24(sp)
    8000118c:	e822                	sd	s0,16(sp)
    8000118e:	e426                	sd	s1,8(sp)
    80001190:	1000                	addi	s0,sp,32
  p = allocproc();
    80001192:	f51ff0ef          	jal	800010e2 <allocproc>
    80001196:	84aa                	mv	s1,a0
  initproc = p;
    80001198:	00009797          	auipc	a5,0x9
    8000119c:	1ca7b423          	sd	a0,456(a5) # 8000a360 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800011a0:	03400613          	li	a2,52
    800011a4:	00009597          	auipc	a1,0x9
    800011a8:	14c58593          	addi	a1,a1,332 # 8000a2f0 <initcode>
    800011ac:	6928                	ld	a0,80(a0)
    800011ae:	e68ff0ef          	jal	80000816 <uvmfirst>
  p->sz = PGSIZE;
    800011b2:	6785                	lui	a5,0x1
    800011b4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800011b6:	6cb8                	ld	a4,88(s1)
    800011b8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800011bc:	6cb8                	ld	a4,88(s1)
    800011be:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800011c0:	4641                	li	a2,16
    800011c2:	00006597          	auipc	a1,0x6
    800011c6:	ffe58593          	addi	a1,a1,-2 # 800071c0 <etext+0x1c0>
    800011ca:	15848513          	addi	a0,s1,344
    800011ce:	9b2ff0ef          	jal	80000380 <safestrcpy>
  p->cwd = namei("/");
    800011d2:	00006517          	auipc	a0,0x6
    800011d6:	ffe50513          	addi	a0,a0,-2 # 800071d0 <etext+0x1d0>
    800011da:	5d5010ef          	jal	80002fae <namei>
    800011de:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011e2:	478d                	li	a5,3
    800011e4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011e6:	8526                	mv	a0,s1
    800011e8:	061040ef          	jal	80005a48 <release>
}
    800011ec:	60e2                	ld	ra,24(sp)
    800011ee:	6442                	ld	s0,16(sp)
    800011f0:	64a2                	ld	s1,8(sp)
    800011f2:	6105                	addi	sp,sp,32
    800011f4:	8082                	ret

00000000800011f6 <growproc>:
{
    800011f6:	1101                	addi	sp,sp,-32
    800011f8:	ec06                	sd	ra,24(sp)
    800011fa:	e822                	sd	s0,16(sp)
    800011fc:	e426                	sd	s1,8(sp)
    800011fe:	e04a                	sd	s2,0(sp)
    80001200:	1000                	addi	s0,sp,32
    80001202:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001204:	d1dff0ef          	jal	80000f20 <myproc>
    80001208:	84aa                	mv	s1,a0
  sz = p->sz;
    8000120a:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000120c:	01204c63          	bgtz	s2,80001224 <growproc+0x2e>
  } else if(n < 0){
    80001210:	02094463          	bltz	s2,80001238 <growproc+0x42>
  p->sz = sz;
    80001214:	e4ac                	sd	a1,72(s1)
  return 0;
    80001216:	4501                	li	a0,0
}
    80001218:	60e2                	ld	ra,24(sp)
    8000121a:	6442                	ld	s0,16(sp)
    8000121c:	64a2                	ld	s1,8(sp)
    8000121e:	6902                	ld	s2,0(sp)
    80001220:	6105                	addi	sp,sp,32
    80001222:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001224:	4691                	li	a3,4
    80001226:	00b90633          	add	a2,s2,a1
    8000122a:	6928                	ld	a0,80(a0)
    8000122c:	e8cff0ef          	jal	800008b8 <uvmalloc>
    80001230:	85aa                	mv	a1,a0
    80001232:	f16d                	bnez	a0,80001214 <growproc+0x1e>
      return -1;
    80001234:	557d                	li	a0,-1
    80001236:	b7cd                	j	80001218 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001238:	00b90633          	add	a2,s2,a1
    8000123c:	6928                	ld	a0,80(a0)
    8000123e:	e36ff0ef          	jal	80000874 <uvmdealloc>
    80001242:	85aa                	mv	a1,a0
    80001244:	bfc1                	j	80001214 <growproc+0x1e>

0000000080001246 <fork>:
{
    80001246:	7139                	addi	sp,sp,-64
    80001248:	fc06                	sd	ra,56(sp)
    8000124a:	f822                	sd	s0,48(sp)
    8000124c:	f04a                	sd	s2,32(sp)
    8000124e:	e456                	sd	s5,8(sp)
    80001250:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001252:	ccfff0ef          	jal	80000f20 <myproc>
    80001256:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001258:	e8bff0ef          	jal	800010e2 <allocproc>
    8000125c:	0e050a63          	beqz	a0,80001350 <fork+0x10a>
    80001260:	e852                	sd	s4,16(sp)
    80001262:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001264:	048ab603          	ld	a2,72(s5)
    80001268:	692c                	ld	a1,80(a0)
    8000126a:	050ab503          	ld	a0,80(s5)
    8000126e:	f82ff0ef          	jal	800009f0 <uvmcopy>
    80001272:	04054a63          	bltz	a0,800012c6 <fork+0x80>
    80001276:	f426                	sd	s1,40(sp)
    80001278:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000127a:	048ab783          	ld	a5,72(s5)
    8000127e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001282:	058ab683          	ld	a3,88(s5)
    80001286:	87b6                	mv	a5,a3
    80001288:	058a3703          	ld	a4,88(s4)
    8000128c:	12068693          	addi	a3,a3,288
    80001290:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001294:	6788                	ld	a0,8(a5)
    80001296:	6b8c                	ld	a1,16(a5)
    80001298:	6f90                	ld	a2,24(a5)
    8000129a:	01073023          	sd	a6,0(a4)
    8000129e:	e708                	sd	a0,8(a4)
    800012a0:	eb0c                	sd	a1,16(a4)
    800012a2:	ef10                	sd	a2,24(a4)
    800012a4:	02078793          	addi	a5,a5,32
    800012a8:	02070713          	addi	a4,a4,32
    800012ac:	fed792e3          	bne	a5,a3,80001290 <fork+0x4a>
  np->trapframe->a0 = 0;
    800012b0:	058a3783          	ld	a5,88(s4)
    800012b4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800012b8:	0d0a8493          	addi	s1,s5,208
    800012bc:	0d0a0913          	addi	s2,s4,208
    800012c0:	150a8993          	addi	s3,s5,336
    800012c4:	a831                	j	800012e0 <fork+0x9a>
    freeproc(np);
    800012c6:	8552                	mv	a0,s4
    800012c8:	dcbff0ef          	jal	80001092 <freeproc>
    release(&np->lock);
    800012cc:	8552                	mv	a0,s4
    800012ce:	77a040ef          	jal	80005a48 <release>
    return -1;
    800012d2:	597d                	li	s2,-1
    800012d4:	6a42                	ld	s4,16(sp)
    800012d6:	a0b5                	j	80001342 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    800012d8:	04a1                	addi	s1,s1,8
    800012da:	0921                	addi	s2,s2,8
    800012dc:	01348963          	beq	s1,s3,800012ee <fork+0xa8>
    if(p->ofile[i])
    800012e0:	6088                	ld	a0,0(s1)
    800012e2:	d97d                	beqz	a0,800012d8 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    800012e4:	25a020ef          	jal	8000353e <filedup>
    800012e8:	00a93023          	sd	a0,0(s2)
    800012ec:	b7f5                	j	800012d8 <fork+0x92>
  np->cwd = idup(p->cwd);
    800012ee:	150ab503          	ld	a0,336(s5)
    800012f2:	5ac010ef          	jal	8000289e <idup>
    800012f6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012fa:	4641                	li	a2,16
    800012fc:	158a8593          	addi	a1,s5,344
    80001300:	158a0513          	addi	a0,s4,344
    80001304:	87cff0ef          	jal	80000380 <safestrcpy>
  pid = np->pid;
    80001308:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    8000130c:	8552                	mv	a0,s4
    8000130e:	73a040ef          	jal	80005a48 <release>
  acquire(&wait_lock);
    80001312:	00029497          	auipc	s1,0x29
    80001316:	0a648493          	addi	s1,s1,166 # 8002a3b8 <wait_lock>
    8000131a:	8526                	mv	a0,s1
    8000131c:	694040ef          	jal	800059b0 <acquire>
  np->parent = p;
    80001320:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001324:	8526                	mv	a0,s1
    80001326:	722040ef          	jal	80005a48 <release>
  acquire(&np->lock);
    8000132a:	8552                	mv	a0,s4
    8000132c:	684040ef          	jal	800059b0 <acquire>
  np->state = RUNNABLE;
    80001330:	478d                	li	a5,3
    80001332:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001336:	8552                	mv	a0,s4
    80001338:	710040ef          	jal	80005a48 <release>
  return pid;
    8000133c:	74a2                	ld	s1,40(sp)
    8000133e:	69e2                	ld	s3,24(sp)
    80001340:	6a42                	ld	s4,16(sp)
}
    80001342:	854a                	mv	a0,s2
    80001344:	70e2                	ld	ra,56(sp)
    80001346:	7442                	ld	s0,48(sp)
    80001348:	7902                	ld	s2,32(sp)
    8000134a:	6aa2                	ld	s5,8(sp)
    8000134c:	6121                	addi	sp,sp,64
    8000134e:	8082                	ret
    return -1;
    80001350:	597d                	li	s2,-1
    80001352:	bfc5                	j	80001342 <fork+0xfc>

0000000080001354 <scheduler>:
{
    80001354:	715d                	addi	sp,sp,-80
    80001356:	e486                	sd	ra,72(sp)
    80001358:	e0a2                	sd	s0,64(sp)
    8000135a:	fc26                	sd	s1,56(sp)
    8000135c:	f84a                	sd	s2,48(sp)
    8000135e:	f44e                	sd	s3,40(sp)
    80001360:	f052                	sd	s4,32(sp)
    80001362:	ec56                	sd	s5,24(sp)
    80001364:	e85a                	sd	s6,16(sp)
    80001366:	e45e                	sd	s7,8(sp)
    80001368:	e062                	sd	s8,0(sp)
    8000136a:	0880                	addi	s0,sp,80
    8000136c:	8792                	mv	a5,tp
  int id = r_tp();
    8000136e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001370:	00779b13          	slli	s6,a5,0x7
    80001374:	00029717          	auipc	a4,0x29
    80001378:	02c70713          	addi	a4,a4,44 # 8002a3a0 <pid_lock>
    8000137c:	975a                	add	a4,a4,s6
    8000137e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001382:	00029717          	auipc	a4,0x29
    80001386:	05670713          	addi	a4,a4,86 # 8002a3d8 <cpus+0x8>
    8000138a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000138c:	4c11                	li	s8,4
        c->proc = p;
    8000138e:	079e                	slli	a5,a5,0x7
    80001390:	00029a17          	auipc	s4,0x29
    80001394:	010a0a13          	addi	s4,s4,16 # 8002a3a0 <pid_lock>
    80001398:	9a3e                	add	s4,s4,a5
        found = 1;
    8000139a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000139c:	0002f997          	auipc	s3,0x2f
    800013a0:	e3498993          	addi	s3,s3,-460 # 800301d0 <tickslock>
    800013a4:	a0a9                	j	800013ee <scheduler+0x9a>
      release(&p->lock);
    800013a6:	8526                	mv	a0,s1
    800013a8:	6a0040ef          	jal	80005a48 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013ac:	16848493          	addi	s1,s1,360
    800013b0:	03348563          	beq	s1,s3,800013da <scheduler+0x86>
      acquire(&p->lock);
    800013b4:	8526                	mv	a0,s1
    800013b6:	5fa040ef          	jal	800059b0 <acquire>
      if(p->state == RUNNABLE) {
    800013ba:	4c9c                	lw	a5,24(s1)
    800013bc:	ff2795e3          	bne	a5,s2,800013a6 <scheduler+0x52>
        p->state = RUNNING;
    800013c0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800013c4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013c8:	06048593          	addi	a1,s1,96
    800013cc:	855a                	mv	a0,s6
    800013ce:	5b4000ef          	jal	80001982 <swtch>
        c->proc = 0;
    800013d2:	020a3823          	sd	zero,48(s4)
        found = 1;
    800013d6:	8ade                	mv	s5,s7
    800013d8:	b7f9                	j	800013a6 <scheduler+0x52>
    if(found == 0) {
    800013da:	000a9a63          	bnez	s5,800013ee <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013e2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013e6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800013ea:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013f2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013f6:	10079073          	csrw	sstatus,a5
    int found = 0;
    800013fa:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800013fc:	00029497          	auipc	s1,0x29
    80001400:	3d448493          	addi	s1,s1,980 # 8002a7d0 <proc>
      if(p->state == RUNNABLE) {
    80001404:	490d                	li	s2,3
    80001406:	b77d                	j	800013b4 <scheduler+0x60>

0000000080001408 <sched>:
{
    80001408:	7179                	addi	sp,sp,-48
    8000140a:	f406                	sd	ra,40(sp)
    8000140c:	f022                	sd	s0,32(sp)
    8000140e:	ec26                	sd	s1,24(sp)
    80001410:	e84a                	sd	s2,16(sp)
    80001412:	e44e                	sd	s3,8(sp)
    80001414:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001416:	b0bff0ef          	jal	80000f20 <myproc>
    8000141a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000141c:	52a040ef          	jal	80005946 <holding>
    80001420:	c92d                	beqz	a0,80001492 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001422:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001424:	2781                	sext.w	a5,a5
    80001426:	079e                	slli	a5,a5,0x7
    80001428:	00029717          	auipc	a4,0x29
    8000142c:	f7870713          	addi	a4,a4,-136 # 8002a3a0 <pid_lock>
    80001430:	97ba                	add	a5,a5,a4
    80001432:	0a87a703          	lw	a4,168(a5)
    80001436:	4785                	li	a5,1
    80001438:	06f71363          	bne	a4,a5,8000149e <sched+0x96>
  if(p->state == RUNNING)
    8000143c:	4c98                	lw	a4,24(s1)
    8000143e:	4791                	li	a5,4
    80001440:	06f70563          	beq	a4,a5,800014aa <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001444:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001448:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000144a:	e7b5                	bnez	a5,800014b6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000144c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000144e:	00029917          	auipc	s2,0x29
    80001452:	f5290913          	addi	s2,s2,-174 # 8002a3a0 <pid_lock>
    80001456:	2781                	sext.w	a5,a5
    80001458:	079e                	slli	a5,a5,0x7
    8000145a:	97ca                	add	a5,a5,s2
    8000145c:	0ac7a983          	lw	s3,172(a5)
    80001460:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001462:	2781                	sext.w	a5,a5
    80001464:	079e                	slli	a5,a5,0x7
    80001466:	00029597          	auipc	a1,0x29
    8000146a:	f7258593          	addi	a1,a1,-142 # 8002a3d8 <cpus+0x8>
    8000146e:	95be                	add	a1,a1,a5
    80001470:	06048513          	addi	a0,s1,96
    80001474:	50e000ef          	jal	80001982 <swtch>
    80001478:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000147a:	2781                	sext.w	a5,a5
    8000147c:	079e                	slli	a5,a5,0x7
    8000147e:	993e                	add	s2,s2,a5
    80001480:	0b392623          	sw	s3,172(s2)
}
    80001484:	70a2                	ld	ra,40(sp)
    80001486:	7402                	ld	s0,32(sp)
    80001488:	64e2                	ld	s1,24(sp)
    8000148a:	6942                	ld	s2,16(sp)
    8000148c:	69a2                	ld	s3,8(sp)
    8000148e:	6145                	addi	sp,sp,48
    80001490:	8082                	ret
    panic("sched p->lock");
    80001492:	00006517          	auipc	a0,0x6
    80001496:	d4650513          	addi	a0,a0,-698 # 800071d8 <etext+0x1d8>
    8000149a:	1e8040ef          	jal	80005682 <panic>
    panic("sched locks");
    8000149e:	00006517          	auipc	a0,0x6
    800014a2:	d4a50513          	addi	a0,a0,-694 # 800071e8 <etext+0x1e8>
    800014a6:	1dc040ef          	jal	80005682 <panic>
    panic("sched running");
    800014aa:	00006517          	auipc	a0,0x6
    800014ae:	d4e50513          	addi	a0,a0,-690 # 800071f8 <etext+0x1f8>
    800014b2:	1d0040ef          	jal	80005682 <panic>
    panic("sched interruptible");
    800014b6:	00006517          	auipc	a0,0x6
    800014ba:	d5250513          	addi	a0,a0,-686 # 80007208 <etext+0x208>
    800014be:	1c4040ef          	jal	80005682 <panic>

00000000800014c2 <yield>:
{
    800014c2:	1101                	addi	sp,sp,-32
    800014c4:	ec06                	sd	ra,24(sp)
    800014c6:	e822                	sd	s0,16(sp)
    800014c8:	e426                	sd	s1,8(sp)
    800014ca:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014cc:	a55ff0ef          	jal	80000f20 <myproc>
    800014d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800014d2:	4de040ef          	jal	800059b0 <acquire>
  p->state = RUNNABLE;
    800014d6:	478d                	li	a5,3
    800014d8:	cc9c                	sw	a5,24(s1)
  sched();
    800014da:	f2fff0ef          	jal	80001408 <sched>
  release(&p->lock);
    800014de:	8526                	mv	a0,s1
    800014e0:	568040ef          	jal	80005a48 <release>
}
    800014e4:	60e2                	ld	ra,24(sp)
    800014e6:	6442                	ld	s0,16(sp)
    800014e8:	64a2                	ld	s1,8(sp)
    800014ea:	6105                	addi	sp,sp,32
    800014ec:	8082                	ret

00000000800014ee <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800014ee:	7179                	addi	sp,sp,-48
    800014f0:	f406                	sd	ra,40(sp)
    800014f2:	f022                	sd	s0,32(sp)
    800014f4:	ec26                	sd	s1,24(sp)
    800014f6:	e84a                	sd	s2,16(sp)
    800014f8:	e44e                	sd	s3,8(sp)
    800014fa:	1800                	addi	s0,sp,48
    800014fc:	89aa                	mv	s3,a0
    800014fe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001500:	a21ff0ef          	jal	80000f20 <myproc>
    80001504:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001506:	4aa040ef          	jal	800059b0 <acquire>
  release(lk);
    8000150a:	854a                	mv	a0,s2
    8000150c:	53c040ef          	jal	80005a48 <release>

  // Go to sleep.
  p->chan = chan;
    80001510:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001514:	4789                	li	a5,2
    80001516:	cc9c                	sw	a5,24(s1)

  sched();
    80001518:	ef1ff0ef          	jal	80001408 <sched>

  // Tidy up.
  p->chan = 0;
    8000151c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001520:	8526                	mv	a0,s1
    80001522:	526040ef          	jal	80005a48 <release>
  acquire(lk);
    80001526:	854a                	mv	a0,s2
    80001528:	488040ef          	jal	800059b0 <acquire>
}
    8000152c:	70a2                	ld	ra,40(sp)
    8000152e:	7402                	ld	s0,32(sp)
    80001530:	64e2                	ld	s1,24(sp)
    80001532:	6942                	ld	s2,16(sp)
    80001534:	69a2                	ld	s3,8(sp)
    80001536:	6145                	addi	sp,sp,48
    80001538:	8082                	ret

000000008000153a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000153a:	7139                	addi	sp,sp,-64
    8000153c:	fc06                	sd	ra,56(sp)
    8000153e:	f822                	sd	s0,48(sp)
    80001540:	f426                	sd	s1,40(sp)
    80001542:	f04a                	sd	s2,32(sp)
    80001544:	ec4e                	sd	s3,24(sp)
    80001546:	e852                	sd	s4,16(sp)
    80001548:	e456                	sd	s5,8(sp)
    8000154a:	0080                	addi	s0,sp,64
    8000154c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000154e:	00029497          	auipc	s1,0x29
    80001552:	28248493          	addi	s1,s1,642 # 8002a7d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001556:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001558:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000155a:	0002f917          	auipc	s2,0x2f
    8000155e:	c7690913          	addi	s2,s2,-906 # 800301d0 <tickslock>
    80001562:	a801                	j	80001572 <wakeup+0x38>
      }
      release(&p->lock);
    80001564:	8526                	mv	a0,s1
    80001566:	4e2040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000156a:	16848493          	addi	s1,s1,360
    8000156e:	03248263          	beq	s1,s2,80001592 <wakeup+0x58>
    if(p != myproc()){
    80001572:	9afff0ef          	jal	80000f20 <myproc>
    80001576:	fea48ae3          	beq	s1,a0,8000156a <wakeup+0x30>
      acquire(&p->lock);
    8000157a:	8526                	mv	a0,s1
    8000157c:	434040ef          	jal	800059b0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001580:	4c9c                	lw	a5,24(s1)
    80001582:	ff3791e3          	bne	a5,s3,80001564 <wakeup+0x2a>
    80001586:	709c                	ld	a5,32(s1)
    80001588:	fd479ee3          	bne	a5,s4,80001564 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000158c:	0154ac23          	sw	s5,24(s1)
    80001590:	bfd1                	j	80001564 <wakeup+0x2a>
    }
  }
}
    80001592:	70e2                	ld	ra,56(sp)
    80001594:	7442                	ld	s0,48(sp)
    80001596:	74a2                	ld	s1,40(sp)
    80001598:	7902                	ld	s2,32(sp)
    8000159a:	69e2                	ld	s3,24(sp)
    8000159c:	6a42                	ld	s4,16(sp)
    8000159e:	6aa2                	ld	s5,8(sp)
    800015a0:	6121                	addi	sp,sp,64
    800015a2:	8082                	ret

00000000800015a4 <reparent>:
{
    800015a4:	7179                	addi	sp,sp,-48
    800015a6:	f406                	sd	ra,40(sp)
    800015a8:	f022                	sd	s0,32(sp)
    800015aa:	ec26                	sd	s1,24(sp)
    800015ac:	e84a                	sd	s2,16(sp)
    800015ae:	e44e                	sd	s3,8(sp)
    800015b0:	e052                	sd	s4,0(sp)
    800015b2:	1800                	addi	s0,sp,48
    800015b4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015b6:	00029497          	auipc	s1,0x29
    800015ba:	21a48493          	addi	s1,s1,538 # 8002a7d0 <proc>
      pp->parent = initproc;
    800015be:	00009a17          	auipc	s4,0x9
    800015c2:	da2a0a13          	addi	s4,s4,-606 # 8000a360 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015c6:	0002f997          	auipc	s3,0x2f
    800015ca:	c0a98993          	addi	s3,s3,-1014 # 800301d0 <tickslock>
    800015ce:	a029                	j	800015d8 <reparent+0x34>
    800015d0:	16848493          	addi	s1,s1,360
    800015d4:	01348b63          	beq	s1,s3,800015ea <reparent+0x46>
    if(pp->parent == p){
    800015d8:	7c9c                	ld	a5,56(s1)
    800015da:	ff279be3          	bne	a5,s2,800015d0 <reparent+0x2c>
      pp->parent = initproc;
    800015de:	000a3503          	ld	a0,0(s4)
    800015e2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800015e4:	f57ff0ef          	jal	8000153a <wakeup>
    800015e8:	b7e5                	j	800015d0 <reparent+0x2c>
}
    800015ea:	70a2                	ld	ra,40(sp)
    800015ec:	7402                	ld	s0,32(sp)
    800015ee:	64e2                	ld	s1,24(sp)
    800015f0:	6942                	ld	s2,16(sp)
    800015f2:	69a2                	ld	s3,8(sp)
    800015f4:	6a02                	ld	s4,0(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret

00000000800015fa <exit>:
{
    800015fa:	7179                	addi	sp,sp,-48
    800015fc:	f406                	sd	ra,40(sp)
    800015fe:	f022                	sd	s0,32(sp)
    80001600:	ec26                	sd	s1,24(sp)
    80001602:	e84a                	sd	s2,16(sp)
    80001604:	e44e                	sd	s3,8(sp)
    80001606:	e052                	sd	s4,0(sp)
    80001608:	1800                	addi	s0,sp,48
    8000160a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000160c:	915ff0ef          	jal	80000f20 <myproc>
    80001610:	89aa                	mv	s3,a0
  if(p == initproc)
    80001612:	00009797          	auipc	a5,0x9
    80001616:	d4e7b783          	ld	a5,-690(a5) # 8000a360 <initproc>
    8000161a:	0d050493          	addi	s1,a0,208
    8000161e:	15050913          	addi	s2,a0,336
    80001622:	00a79f63          	bne	a5,a0,80001640 <exit+0x46>
    panic("init exiting");
    80001626:	00006517          	auipc	a0,0x6
    8000162a:	bfa50513          	addi	a0,a0,-1030 # 80007220 <etext+0x220>
    8000162e:	054040ef          	jal	80005682 <panic>
      fileclose(f);
    80001632:	753010ef          	jal	80003584 <fileclose>
      p->ofile[fd] = 0;
    80001636:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000163a:	04a1                	addi	s1,s1,8
    8000163c:	01248563          	beq	s1,s2,80001646 <exit+0x4c>
    if(p->ofile[fd]){
    80001640:	6088                	ld	a0,0(s1)
    80001642:	f965                	bnez	a0,80001632 <exit+0x38>
    80001644:	bfdd                	j	8000163a <exit+0x40>
  begin_op();
    80001646:	325010ef          	jal	8000316a <begin_op>
  iput(p->cwd);
    8000164a:	1509b503          	ld	a0,336(s3)
    8000164e:	408010ef          	jal	80002a56 <iput>
  end_op();
    80001652:	383010ef          	jal	800031d4 <end_op>
  p->cwd = 0;
    80001656:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000165a:	00029497          	auipc	s1,0x29
    8000165e:	d5e48493          	addi	s1,s1,-674 # 8002a3b8 <wait_lock>
    80001662:	8526                	mv	a0,s1
    80001664:	34c040ef          	jal	800059b0 <acquire>
  reparent(p);
    80001668:	854e                	mv	a0,s3
    8000166a:	f3bff0ef          	jal	800015a4 <reparent>
  wakeup(p->parent);
    8000166e:	0389b503          	ld	a0,56(s3)
    80001672:	ec9ff0ef          	jal	8000153a <wakeup>
  acquire(&p->lock);
    80001676:	854e                	mv	a0,s3
    80001678:	338040ef          	jal	800059b0 <acquire>
  p->xstate = status;
    8000167c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001680:	4795                	li	a5,5
    80001682:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001686:	8526                	mv	a0,s1
    80001688:	3c0040ef          	jal	80005a48 <release>
  sched();
    8000168c:	d7dff0ef          	jal	80001408 <sched>
  panic("zombie exit");
    80001690:	00006517          	auipc	a0,0x6
    80001694:	ba050513          	addi	a0,a0,-1120 # 80007230 <etext+0x230>
    80001698:	7eb030ef          	jal	80005682 <panic>

000000008000169c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000169c:	7179                	addi	sp,sp,-48
    8000169e:	f406                	sd	ra,40(sp)
    800016a0:	f022                	sd	s0,32(sp)
    800016a2:	ec26                	sd	s1,24(sp)
    800016a4:	e84a                	sd	s2,16(sp)
    800016a6:	e44e                	sd	s3,8(sp)
    800016a8:	1800                	addi	s0,sp,48
    800016aa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800016ac:	00029497          	auipc	s1,0x29
    800016b0:	12448493          	addi	s1,s1,292 # 8002a7d0 <proc>
    800016b4:	0002f997          	auipc	s3,0x2f
    800016b8:	b1c98993          	addi	s3,s3,-1252 # 800301d0 <tickslock>
    acquire(&p->lock);
    800016bc:	8526                	mv	a0,s1
    800016be:	2f2040ef          	jal	800059b0 <acquire>
    if(p->pid == pid){
    800016c2:	589c                	lw	a5,48(s1)
    800016c4:	01278b63          	beq	a5,s2,800016da <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800016c8:	8526                	mv	a0,s1
    800016ca:	37e040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800016ce:	16848493          	addi	s1,s1,360
    800016d2:	ff3495e3          	bne	s1,s3,800016bc <kill+0x20>
  }
  return -1;
    800016d6:	557d                	li	a0,-1
    800016d8:	a819                	j	800016ee <kill+0x52>
      p->killed = 1;
    800016da:	4785                	li	a5,1
    800016dc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800016de:	4c98                	lw	a4,24(s1)
    800016e0:	4789                	li	a5,2
    800016e2:	00f70d63          	beq	a4,a5,800016fc <kill+0x60>
      release(&p->lock);
    800016e6:	8526                	mv	a0,s1
    800016e8:	360040ef          	jal	80005a48 <release>
      return 0;
    800016ec:	4501                	li	a0,0
}
    800016ee:	70a2                	ld	ra,40(sp)
    800016f0:	7402                	ld	s0,32(sp)
    800016f2:	64e2                	ld	s1,24(sp)
    800016f4:	6942                	ld	s2,16(sp)
    800016f6:	69a2                	ld	s3,8(sp)
    800016f8:	6145                	addi	sp,sp,48
    800016fa:	8082                	ret
        p->state = RUNNABLE;
    800016fc:	478d                	li	a5,3
    800016fe:	cc9c                	sw	a5,24(s1)
    80001700:	b7dd                	j	800016e6 <kill+0x4a>

0000000080001702 <setkilled>:

void
setkilled(struct proc *p)
{
    80001702:	1101                	addi	sp,sp,-32
    80001704:	ec06                	sd	ra,24(sp)
    80001706:	e822                	sd	s0,16(sp)
    80001708:	e426                	sd	s1,8(sp)
    8000170a:	1000                	addi	s0,sp,32
    8000170c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000170e:	2a2040ef          	jal	800059b0 <acquire>
  p->killed = 1;
    80001712:	4785                	li	a5,1
    80001714:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001716:	8526                	mv	a0,s1
    80001718:	330040ef          	jal	80005a48 <release>
}
    8000171c:	60e2                	ld	ra,24(sp)
    8000171e:	6442                	ld	s0,16(sp)
    80001720:	64a2                	ld	s1,8(sp)
    80001722:	6105                	addi	sp,sp,32
    80001724:	8082                	ret

0000000080001726 <killed>:

int
killed(struct proc *p)
{
    80001726:	1101                	addi	sp,sp,-32
    80001728:	ec06                	sd	ra,24(sp)
    8000172a:	e822                	sd	s0,16(sp)
    8000172c:	e426                	sd	s1,8(sp)
    8000172e:	e04a                	sd	s2,0(sp)
    80001730:	1000                	addi	s0,sp,32
    80001732:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001734:	27c040ef          	jal	800059b0 <acquire>
  k = p->killed;
    80001738:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000173c:	8526                	mv	a0,s1
    8000173e:	30a040ef          	jal	80005a48 <release>
  return k;
}
    80001742:	854a                	mv	a0,s2
    80001744:	60e2                	ld	ra,24(sp)
    80001746:	6442                	ld	s0,16(sp)
    80001748:	64a2                	ld	s1,8(sp)
    8000174a:	6902                	ld	s2,0(sp)
    8000174c:	6105                	addi	sp,sp,32
    8000174e:	8082                	ret

0000000080001750 <wait>:
{
    80001750:	715d                	addi	sp,sp,-80
    80001752:	e486                	sd	ra,72(sp)
    80001754:	e0a2                	sd	s0,64(sp)
    80001756:	fc26                	sd	s1,56(sp)
    80001758:	f84a                	sd	s2,48(sp)
    8000175a:	f44e                	sd	s3,40(sp)
    8000175c:	f052                	sd	s4,32(sp)
    8000175e:	ec56                	sd	s5,24(sp)
    80001760:	e85a                	sd	s6,16(sp)
    80001762:	e45e                	sd	s7,8(sp)
    80001764:	e062                	sd	s8,0(sp)
    80001766:	0880                	addi	s0,sp,80
    80001768:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000176a:	fb6ff0ef          	jal	80000f20 <myproc>
    8000176e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001770:	00029517          	auipc	a0,0x29
    80001774:	c4850513          	addi	a0,a0,-952 # 8002a3b8 <wait_lock>
    80001778:	238040ef          	jal	800059b0 <acquire>
    havekids = 0;
    8000177c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000177e:	4a15                	li	s4,5
        havekids = 1;
    80001780:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001782:	0002f997          	auipc	s3,0x2f
    80001786:	a4e98993          	addi	s3,s3,-1458 # 800301d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000178a:	00029c17          	auipc	s8,0x29
    8000178e:	c2ec0c13          	addi	s8,s8,-978 # 8002a3b8 <wait_lock>
    80001792:	a871                	j	8000182e <wait+0xde>
          pid = pp->pid;
    80001794:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001798:	000b0c63          	beqz	s6,800017b0 <wait+0x60>
    8000179c:	4691                	li	a3,4
    8000179e:	02c48613          	addi	a2,s1,44
    800017a2:	85da                	mv	a1,s6
    800017a4:	05093503          	ld	a0,80(s2)
    800017a8:	b3aff0ef          	jal	80000ae2 <copyout>
    800017ac:	02054b63          	bltz	a0,800017e2 <wait+0x92>
          freeproc(pp);
    800017b0:	8526                	mv	a0,s1
    800017b2:	8e1ff0ef          	jal	80001092 <freeproc>
          release(&pp->lock);
    800017b6:	8526                	mv	a0,s1
    800017b8:	290040ef          	jal	80005a48 <release>
          release(&wait_lock);
    800017bc:	00029517          	auipc	a0,0x29
    800017c0:	bfc50513          	addi	a0,a0,-1028 # 8002a3b8 <wait_lock>
    800017c4:	284040ef          	jal	80005a48 <release>
}
    800017c8:	854e                	mv	a0,s3
    800017ca:	60a6                	ld	ra,72(sp)
    800017cc:	6406                	ld	s0,64(sp)
    800017ce:	74e2                	ld	s1,56(sp)
    800017d0:	7942                	ld	s2,48(sp)
    800017d2:	79a2                	ld	s3,40(sp)
    800017d4:	7a02                	ld	s4,32(sp)
    800017d6:	6ae2                	ld	s5,24(sp)
    800017d8:	6b42                	ld	s6,16(sp)
    800017da:	6ba2                	ld	s7,8(sp)
    800017dc:	6c02                	ld	s8,0(sp)
    800017de:	6161                	addi	sp,sp,80
    800017e0:	8082                	ret
            release(&pp->lock);
    800017e2:	8526                	mv	a0,s1
    800017e4:	264040ef          	jal	80005a48 <release>
            release(&wait_lock);
    800017e8:	00029517          	auipc	a0,0x29
    800017ec:	bd050513          	addi	a0,a0,-1072 # 8002a3b8 <wait_lock>
    800017f0:	258040ef          	jal	80005a48 <release>
            return -1;
    800017f4:	59fd                	li	s3,-1
    800017f6:	bfc9                	j	800017c8 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800017f8:	16848493          	addi	s1,s1,360
    800017fc:	03348063          	beq	s1,s3,8000181c <wait+0xcc>
      if(pp->parent == p){
    80001800:	7c9c                	ld	a5,56(s1)
    80001802:	ff279be3          	bne	a5,s2,800017f8 <wait+0xa8>
        acquire(&pp->lock);
    80001806:	8526                	mv	a0,s1
    80001808:	1a8040ef          	jal	800059b0 <acquire>
        if(pp->state == ZOMBIE){
    8000180c:	4c9c                	lw	a5,24(s1)
    8000180e:	f94783e3          	beq	a5,s4,80001794 <wait+0x44>
        release(&pp->lock);
    80001812:	8526                	mv	a0,s1
    80001814:	234040ef          	jal	80005a48 <release>
        havekids = 1;
    80001818:	8756                	mv	a4,s5
    8000181a:	bff9                	j	800017f8 <wait+0xa8>
    if(!havekids || killed(p)){
    8000181c:	cf19                	beqz	a4,8000183a <wait+0xea>
    8000181e:	854a                	mv	a0,s2
    80001820:	f07ff0ef          	jal	80001726 <killed>
    80001824:	e919                	bnez	a0,8000183a <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001826:	85e2                	mv	a1,s8
    80001828:	854a                	mv	a0,s2
    8000182a:	cc5ff0ef          	jal	800014ee <sleep>
    havekids = 0;
    8000182e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001830:	00029497          	auipc	s1,0x29
    80001834:	fa048493          	addi	s1,s1,-96 # 8002a7d0 <proc>
    80001838:	b7e1                	j	80001800 <wait+0xb0>
      release(&wait_lock);
    8000183a:	00029517          	auipc	a0,0x29
    8000183e:	b7e50513          	addi	a0,a0,-1154 # 8002a3b8 <wait_lock>
    80001842:	206040ef          	jal	80005a48 <release>
      return -1;
    80001846:	59fd                	li	s3,-1
    80001848:	b741                	j	800017c8 <wait+0x78>

000000008000184a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000184a:	7179                	addi	sp,sp,-48
    8000184c:	f406                	sd	ra,40(sp)
    8000184e:	f022                	sd	s0,32(sp)
    80001850:	ec26                	sd	s1,24(sp)
    80001852:	e84a                	sd	s2,16(sp)
    80001854:	e44e                	sd	s3,8(sp)
    80001856:	e052                	sd	s4,0(sp)
    80001858:	1800                	addi	s0,sp,48
    8000185a:	84aa                	mv	s1,a0
    8000185c:	892e                	mv	s2,a1
    8000185e:	89b2                	mv	s3,a2
    80001860:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001862:	ebeff0ef          	jal	80000f20 <myproc>
  if(user_dst){
    80001866:	cc99                	beqz	s1,80001884 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001868:	86d2                	mv	a3,s4
    8000186a:	864e                	mv	a2,s3
    8000186c:	85ca                	mv	a1,s2
    8000186e:	6928                	ld	a0,80(a0)
    80001870:	a72ff0ef          	jal	80000ae2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001874:	70a2                	ld	ra,40(sp)
    80001876:	7402                	ld	s0,32(sp)
    80001878:	64e2                	ld	s1,24(sp)
    8000187a:	6942                	ld	s2,16(sp)
    8000187c:	69a2                	ld	s3,8(sp)
    8000187e:	6a02                	ld	s4,0(sp)
    80001880:	6145                	addi	sp,sp,48
    80001882:	8082                	ret
    memmove((char *)dst, src, len);
    80001884:	000a061b          	sext.w	a2,s4
    80001888:	85ce                	mv	a1,s3
    8000188a:	854a                	mv	a0,s2
    8000188c:	a13fe0ef          	jal	8000029e <memmove>
    return 0;
    80001890:	8526                	mv	a0,s1
    80001892:	b7cd                	j	80001874 <either_copyout+0x2a>

0000000080001894 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001894:	7179                	addi	sp,sp,-48
    80001896:	f406                	sd	ra,40(sp)
    80001898:	f022                	sd	s0,32(sp)
    8000189a:	ec26                	sd	s1,24(sp)
    8000189c:	e84a                	sd	s2,16(sp)
    8000189e:	e44e                	sd	s3,8(sp)
    800018a0:	e052                	sd	s4,0(sp)
    800018a2:	1800                	addi	s0,sp,48
    800018a4:	892a                	mv	s2,a0
    800018a6:	84ae                	mv	s1,a1
    800018a8:	89b2                	mv	s3,a2
    800018aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800018ac:	e74ff0ef          	jal	80000f20 <myproc>
  if(user_src){
    800018b0:	cc99                	beqz	s1,800018ce <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800018b2:	86d2                	mv	a3,s4
    800018b4:	864e                	mv	a2,s3
    800018b6:	85ca                	mv	a1,s2
    800018b8:	6928                	ld	a0,80(a0)
    800018ba:	baeff0ef          	jal	80000c68 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800018be:	70a2                	ld	ra,40(sp)
    800018c0:	7402                	ld	s0,32(sp)
    800018c2:	64e2                	ld	s1,24(sp)
    800018c4:	6942                	ld	s2,16(sp)
    800018c6:	69a2                	ld	s3,8(sp)
    800018c8:	6a02                	ld	s4,0(sp)
    800018ca:	6145                	addi	sp,sp,48
    800018cc:	8082                	ret
    memmove(dst, (char*)src, len);
    800018ce:	000a061b          	sext.w	a2,s4
    800018d2:	85ce                	mv	a1,s3
    800018d4:	854a                	mv	a0,s2
    800018d6:	9c9fe0ef          	jal	8000029e <memmove>
    return 0;
    800018da:	8526                	mv	a0,s1
    800018dc:	b7cd                	j	800018be <either_copyin+0x2a>

00000000800018de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800018de:	715d                	addi	sp,sp,-80
    800018e0:	e486                	sd	ra,72(sp)
    800018e2:	e0a2                	sd	s0,64(sp)
    800018e4:	fc26                	sd	s1,56(sp)
    800018e6:	f84a                	sd	s2,48(sp)
    800018e8:	f44e                	sd	s3,40(sp)
    800018ea:	f052                	sd	s4,32(sp)
    800018ec:	ec56                	sd	s5,24(sp)
    800018ee:	e85a                	sd	s6,16(sp)
    800018f0:	e45e                	sd	s7,8(sp)
    800018f2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800018f4:	00005517          	auipc	a0,0x5
    800018f8:	72450513          	addi	a0,a0,1828 # 80007018 <etext+0x18>
    800018fc:	2b5030ef          	jal	800053b0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001900:	00029497          	auipc	s1,0x29
    80001904:	02848493          	addi	s1,s1,40 # 8002a928 <proc+0x158>
    80001908:	0002f917          	auipc	s2,0x2f
    8000190c:	a2090913          	addi	s2,s2,-1504 # 80030328 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001910:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001912:	00006997          	auipc	s3,0x6
    80001916:	92e98993          	addi	s3,s3,-1746 # 80007240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000191a:	00006a97          	auipc	s5,0x6
    8000191e:	92ea8a93          	addi	s5,s5,-1746 # 80007248 <etext+0x248>
    printf("\n");
    80001922:	00005a17          	auipc	s4,0x5
    80001926:	6f6a0a13          	addi	s4,s4,1782 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000192a:	00006b97          	auipc	s7,0x6
    8000192e:	ee6b8b93          	addi	s7,s7,-282 # 80007810 <states.0>
    80001932:	a829                	j	8000194c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001934:	ed86a583          	lw	a1,-296(a3)
    80001938:	8556                	mv	a0,s5
    8000193a:	277030ef          	jal	800053b0 <printf>
    printf("\n");
    8000193e:	8552                	mv	a0,s4
    80001940:	271030ef          	jal	800053b0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001944:	16848493          	addi	s1,s1,360
    80001948:	03248263          	beq	s1,s2,8000196c <procdump+0x8e>
    if(p->state == UNUSED)
    8000194c:	86a6                	mv	a3,s1
    8000194e:	ec04a783          	lw	a5,-320(s1)
    80001952:	dbed                	beqz	a5,80001944 <procdump+0x66>
      state = "???";
    80001954:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001956:	fcfb6fe3          	bltu	s6,a5,80001934 <procdump+0x56>
    8000195a:	02079713          	slli	a4,a5,0x20
    8000195e:	01d75793          	srli	a5,a4,0x1d
    80001962:	97de                	add	a5,a5,s7
    80001964:	6390                	ld	a2,0(a5)
    80001966:	f679                	bnez	a2,80001934 <procdump+0x56>
      state = "???";
    80001968:	864e                	mv	a2,s3
    8000196a:	b7e9                	j	80001934 <procdump+0x56>
  }
}
    8000196c:	60a6                	ld	ra,72(sp)
    8000196e:	6406                	ld	s0,64(sp)
    80001970:	74e2                	ld	s1,56(sp)
    80001972:	7942                	ld	s2,48(sp)
    80001974:	79a2                	ld	s3,40(sp)
    80001976:	7a02                	ld	s4,32(sp)
    80001978:	6ae2                	ld	s5,24(sp)
    8000197a:	6b42                	ld	s6,16(sp)
    8000197c:	6ba2                	ld	s7,8(sp)
    8000197e:	6161                	addi	sp,sp,80
    80001980:	8082                	ret

0000000080001982 <swtch>:
    80001982:	00153023          	sd	ra,0(a0)
    80001986:	00253423          	sd	sp,8(a0)
    8000198a:	e900                	sd	s0,16(a0)
    8000198c:	ed04                	sd	s1,24(a0)
    8000198e:	03253023          	sd	s2,32(a0)
    80001992:	03353423          	sd	s3,40(a0)
    80001996:	03453823          	sd	s4,48(a0)
    8000199a:	03553c23          	sd	s5,56(a0)
    8000199e:	05653023          	sd	s6,64(a0)
    800019a2:	05753423          	sd	s7,72(a0)
    800019a6:	05853823          	sd	s8,80(a0)
    800019aa:	05953c23          	sd	s9,88(a0)
    800019ae:	07a53023          	sd	s10,96(a0)
    800019b2:	07b53423          	sd	s11,104(a0)
    800019b6:	0005b083          	ld	ra,0(a1)
    800019ba:	0085b103          	ld	sp,8(a1)
    800019be:	6980                	ld	s0,16(a1)
    800019c0:	6d84                	ld	s1,24(a1)
    800019c2:	0205b903          	ld	s2,32(a1)
    800019c6:	0285b983          	ld	s3,40(a1)
    800019ca:	0305ba03          	ld	s4,48(a1)
    800019ce:	0385ba83          	ld	s5,56(a1)
    800019d2:	0405bb03          	ld	s6,64(a1)
    800019d6:	0485bb83          	ld	s7,72(a1)
    800019da:	0505bc03          	ld	s8,80(a1)
    800019de:	0585bc83          	ld	s9,88(a1)
    800019e2:	0605bd03          	ld	s10,96(a1)
    800019e6:	0685bd83          	ld	s11,104(a1)
    800019ea:	8082                	ret

00000000800019ec <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800019f4:	00006597          	auipc	a1,0x6
    800019f8:	89458593          	addi	a1,a1,-1900 # 80007288 <etext+0x288>
    800019fc:	0002e517          	auipc	a0,0x2e
    80001a00:	7d450513          	addi	a0,a0,2004 # 800301d0 <tickslock>
    80001a04:	72d030ef          	jal	80005930 <initlock>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret

0000000080001a10 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001a10:	1141                	addi	sp,sp,-16
    80001a12:	e422                	sd	s0,8(sp)
    80001a14:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a16:	00003797          	auipc	a5,0x3
    80001a1a:	eda78793          	addi	a5,a5,-294 # 800048f0 <kernelvec>
    80001a1e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001a22:	6422                	ld	s0,8(sp)
    80001a24:	0141                	addi	sp,sp,16
    80001a26:	8082                	ret

0000000080001a28 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001a28:	1141                	addi	sp,sp,-16
    80001a2a:	e406                	sd	ra,8(sp)
    80001a2c:	e022                	sd	s0,0(sp)
    80001a2e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001a30:	cf0ff0ef          	jal	80000f20 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001a38:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a3a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001a3e:	00004697          	auipc	a3,0x4
    80001a42:	5c268693          	addi	a3,a3,1474 # 80006000 <_trampoline>
    80001a46:	00004717          	auipc	a4,0x4
    80001a4a:	5ba70713          	addi	a4,a4,1466 # 80006000 <_trampoline>
    80001a4e:	8f15                	sub	a4,a4,a3
    80001a50:	040007b7          	lui	a5,0x4000
    80001a54:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001a56:	07b2                	slli	a5,a5,0xc
    80001a58:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a5a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001a5e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001a60:	18002673          	csrr	a2,satp
    80001a64:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001a66:	6d30                	ld	a2,88(a0)
    80001a68:	6138                	ld	a4,64(a0)
    80001a6a:	6585                	lui	a1,0x1
    80001a6c:	972e                	add	a4,a4,a1
    80001a6e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001a70:	6d38                	ld	a4,88(a0)
    80001a72:	00000617          	auipc	a2,0x0
    80001a76:	11060613          	addi	a2,a2,272 # 80001b82 <usertrap>
    80001a7a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001a7c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a7e:	8612                	mv	a2,tp
    80001a80:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a82:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001a86:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001a8a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a8e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001a92:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001a94:	6f18                	ld	a4,24(a4)
    80001a96:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a9a:	6928                	ld	a0,80(a0)
    80001a9c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a9e:	00004717          	auipc	a4,0x4
    80001aa2:	5fe70713          	addi	a4,a4,1534 # 8000609c <userret>
    80001aa6:	8f15                	sub	a4,a4,a3
    80001aa8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001aaa:	577d                	li	a4,-1
    80001aac:	177e                	slli	a4,a4,0x3f
    80001aae:	8d59                	or	a0,a0,a4
    80001ab0:	9782                	jalr	a5
}
    80001ab2:	60a2                	ld	ra,8(sp)
    80001ab4:	6402                	ld	s0,0(sp)
    80001ab6:	0141                	addi	sp,sp,16
    80001ab8:	8082                	ret

0000000080001aba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001aba:	1101                	addi	sp,sp,-32
    80001abc:	ec06                	sd	ra,24(sp)
    80001abe:	e822                	sd	s0,16(sp)
    80001ac0:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001ac2:	c32ff0ef          	jal	80000ef4 <cpuid>
    80001ac6:	cd11                	beqz	a0,80001ae2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001ac8:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001acc:	000f4737          	lui	a4,0xf4
    80001ad0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001ad4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001ad6:	14d79073          	csrw	stimecmp,a5
}
    80001ada:	60e2                	ld	ra,24(sp)
    80001adc:	6442                	ld	s0,16(sp)
    80001ade:	6105                	addi	sp,sp,32
    80001ae0:	8082                	ret
    80001ae2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001ae4:	0002e497          	auipc	s1,0x2e
    80001ae8:	6ec48493          	addi	s1,s1,1772 # 800301d0 <tickslock>
    80001aec:	8526                	mv	a0,s1
    80001aee:	6c3030ef          	jal	800059b0 <acquire>
    ticks++;
    80001af2:	00009517          	auipc	a0,0x9
    80001af6:	87650513          	addi	a0,a0,-1930 # 8000a368 <ticks>
    80001afa:	411c                	lw	a5,0(a0)
    80001afc:	2785                	addiw	a5,a5,1
    80001afe:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001b00:	a3bff0ef          	jal	8000153a <wakeup>
    release(&tickslock);
    80001b04:	8526                	mv	a0,s1
    80001b06:	743030ef          	jal	80005a48 <release>
    80001b0a:	64a2                	ld	s1,8(sp)
    80001b0c:	bf75                	j	80001ac8 <clockintr+0xe>

0000000080001b0e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b16:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001b1a:	57fd                	li	a5,-1
    80001b1c:	17fe                	slli	a5,a5,0x3f
    80001b1e:	07a5                	addi	a5,a5,9
    80001b20:	00f70c63          	beq	a4,a5,80001b38 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001b24:	57fd                	li	a5,-1
    80001b26:	17fe                	slli	a5,a5,0x3f
    80001b28:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001b2a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001b2c:	04f70763          	beq	a4,a5,80001b7a <devintr+0x6c>
  }
}
    80001b30:	60e2                	ld	ra,24(sp)
    80001b32:	6442                	ld	s0,16(sp)
    80001b34:	6105                	addi	sp,sp,32
    80001b36:	8082                	ret
    80001b38:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001b3a:	663020ef          	jal	8000499c <plic_claim>
    80001b3e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001b40:	47a9                	li	a5,10
    80001b42:	00f50963          	beq	a0,a5,80001b54 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001b46:	4785                	li	a5,1
    80001b48:	00f50963          	beq	a0,a5,80001b5a <devintr+0x4c>
    return 1;
    80001b4c:	4505                	li	a0,1
    } else if(irq){
    80001b4e:	e889                	bnez	s1,80001b60 <devintr+0x52>
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	bff9                	j	80001b30 <devintr+0x22>
      uartintr();
    80001b54:	5a1030ef          	jal	800058f4 <uartintr>
    if(irq)
    80001b58:	a819                	j	80001b6e <devintr+0x60>
      virtio_disk_intr();
    80001b5a:	308030ef          	jal	80004e62 <virtio_disk_intr>
    if(irq)
    80001b5e:	a801                	j	80001b6e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001b60:	85a6                	mv	a1,s1
    80001b62:	00005517          	auipc	a0,0x5
    80001b66:	72e50513          	addi	a0,a0,1838 # 80007290 <etext+0x290>
    80001b6a:	047030ef          	jal	800053b0 <printf>
      plic_complete(irq);
    80001b6e:	8526                	mv	a0,s1
    80001b70:	64d020ef          	jal	800049bc <plic_complete>
    return 1;
    80001b74:	4505                	li	a0,1
    80001b76:	64a2                	ld	s1,8(sp)
    80001b78:	bf65                	j	80001b30 <devintr+0x22>
    clockintr();
    80001b7a:	f41ff0ef          	jal	80001aba <clockintr>
    return 2;
    80001b7e:	4509                	li	a0,2
    80001b80:	bf45                	j	80001b30 <devintr+0x22>

0000000080001b82 <usertrap>:
{
    80001b82:	7179                	addi	sp,sp,-48
    80001b84:	f406                	sd	ra,40(sp)
    80001b86:	f022                	sd	s0,32(sp)
    80001b88:	ec26                	sd	s1,24(sp)
    80001b8a:	e84a                	sd	s2,16(sp)
    80001b8c:	e44e                	sd	s3,8(sp)
    80001b8e:	e052                	sd	s4,0(sp)
    80001b90:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b92:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001b96:	1007f793          	andi	a5,a5,256
    80001b9a:	e7b5                	bnez	a5,80001c06 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b9c:	00003797          	auipc	a5,0x3
    80001ba0:	d5478793          	addi	a5,a5,-684 # 800048f0 <kernelvec>
    80001ba4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ba8:	b78ff0ef          	jal	80000f20 <myproc>
    80001bac:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001bae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bb0:	14102773          	csrr	a4,sepc
    80001bb4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bb6:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bba:	14302a73          	csrr	s4,stval
  if(scause == 8){
    80001bbe:	47a1                	li	a5,8
    80001bc0:	04f98963          	beq	s3,a5,80001c12 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001bc4:	f4bff0ef          	jal	80001b0e <devintr>
    80001bc8:	892a                	mv	s2,a0
    80001bca:	14051363          	bnez	a0,80001d10 <usertrap+0x18e>
  } else if(scause == 13 || scause == 15) { // load/store page fault
    80001bce:	ffd9f793          	andi	a5,s3,-3
    80001bd2:	4735                	li	a4,13
    80001bd4:	08e78163          	beq	a5,a4,80001c56 <usertrap+0xd4>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bd8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001bdc:	5890                	lw	a2,48(s1)
    80001bde:	00005517          	auipc	a0,0x5
    80001be2:	79250513          	addi	a0,a0,1938 # 80007370 <etext+0x370>
    80001be6:	7ca030ef          	jal	800053b0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bea:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bee:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001bf2:	00005517          	auipc	a0,0x5
    80001bf6:	7ae50513          	addi	a0,a0,1966 # 800073a0 <etext+0x3a0>
    80001bfa:	7b6030ef          	jal	800053b0 <printf>
    setkilled(p);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	b03ff0ef          	jal	80001702 <setkilled>
    80001c04:	a035                	j	80001c30 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001c06:	00005517          	auipc	a0,0x5
    80001c0a:	6aa50513          	addi	a0,a0,1706 # 800072b0 <etext+0x2b0>
    80001c0e:	275030ef          	jal	80005682 <panic>
    if(killed(p))
    80001c12:	b15ff0ef          	jal	80001726 <killed>
    80001c16:	ed05                	bnez	a0,80001c4e <usertrap+0xcc>
    p->trapframe->epc += 4;
    80001c18:	6cb8                	ld	a4,88(s1)
    80001c1a:	6f1c                	ld	a5,24(a4)
    80001c1c:	0791                	addi	a5,a5,4
    80001c1e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c24:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c28:	10079073          	csrw	sstatus,a5
    syscall();
    80001c2c:	2e4000ef          	jal	80001f10 <syscall>
  if(killed(p))
    80001c30:	8526                	mv	a0,s1
    80001c32:	af5ff0ef          	jal	80001726 <killed>
    80001c36:	0e051263          	bnez	a0,80001d1a <usertrap+0x198>
  usertrapret();
    80001c3a:	defff0ef          	jal	80001a28 <usertrapret>
}
    80001c3e:	70a2                	ld	ra,40(sp)
    80001c40:	7402                	ld	s0,32(sp)
    80001c42:	64e2                	ld	s1,24(sp)
    80001c44:	6942                	ld	s2,16(sp)
    80001c46:	69a2                	ld	s3,8(sp)
    80001c48:	6a02                	ld	s4,0(sp)
    80001c4a:	6145                	addi	sp,sp,48
    80001c4c:	8082                	ret
      exit(-1);
    80001c4e:	557d                	li	a0,-1
    80001c50:	9abff0ef          	jal	800015fa <exit>
    80001c54:	b7d1                	j	80001c18 <usertrap+0x96>
    pte_t *pte = walk(p->pagetable, stval, 0);
    80001c56:	4601                	li	a2,0
    80001c58:	85d2                	mv	a1,s4
    80001c5a:	68a8                	ld	a0,80(s1)
    80001c5c:	85bfe0ef          	jal	800004b6 <walk>
    if(pte == 0 || !(*pte & PTE_V) || !(*pte & PTE_U)) {
    80001c60:	c901                	beqz	a0,80001c70 <usertrap+0xee>
    80001c62:	00053903          	ld	s2,0(a0)
    80001c66:	01197713          	andi	a4,s2,17
    80001c6a:	47c5                	li	a5,17
    80001c6c:	00f70e63          	beq	a4,a5,80001c88 <usertrap+0x106>
      printf("usertrap(): page fault: invalid addr 0x%lx pid=%d\n", stval, p->pid);
    80001c70:	5890                	lw	a2,48(s1)
    80001c72:	85d2                	mv	a1,s4
    80001c74:	00005517          	auipc	a0,0x5
    80001c78:	65c50513          	addi	a0,a0,1628 # 800072d0 <etext+0x2d0>
    80001c7c:	734030ef          	jal	800053b0 <printf>
      setkilled(p);
    80001c80:	8526                	mv	a0,s1
    80001c82:	a81ff0ef          	jal	80001702 <setkilled>
    80001c86:	b76d                	j	80001c30 <usertrap+0xae>
    } else if((*pte & PTE_COW) && (scause == 15)) { // only on write fault
    80001c88:	10097793          	andi	a5,s2,256
    80001c8c:	c781                	beqz	a5,80001c94 <usertrap+0x112>
    80001c8e:	47bd                	li	a5,15
    80001c90:	00f98f63          	beq	s3,a5,80001cae <usertrap+0x12c>
      printf("usertrap(): unexpected page fault addr 0x%lx, scause=0x%lx, pte=0x%lx\n", stval, scause, *pte);
    80001c94:	86ca                	mv	a3,s2
    80001c96:	864e                	mv	a2,s3
    80001c98:	85d2                	mv	a1,s4
    80001c9a:	00005517          	auipc	a0,0x5
    80001c9e:	68e50513          	addi	a0,a0,1678 # 80007328 <etext+0x328>
    80001ca2:	70e030ef          	jal	800053b0 <printf>
      setkilled(p);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	a5bff0ef          	jal	80001702 <setkilled>
    80001cac:	b751                	j	80001c30 <usertrap+0xae>
      if((mem = kalloc()) == 0){
    80001cae:	d2afe0ef          	jal	800001d8 <kalloc>
    80001cb2:	89aa                	mv	s3,a0
    80001cb4:	c121                	beqz	a0,80001cf4 <usertrap+0x172>
      uint64 pa = PTE2PA(*pte);
    80001cb6:	00a95913          	srli	s2,s2,0xa
    80001cba:	0932                	slli	s2,s2,0xc
        memmove(mem, (char*)pa, PGSIZE);
    80001cbc:	6605                	lui	a2,0x1
    80001cbe:	85ca                	mv	a1,s2
    80001cc0:	ddefe0ef          	jal	8000029e <memmove>
        uvmunmap(p->pagetable, PGROUNDDOWN(stval), 1, 0); // don't free old page yet!
    80001cc4:	77fd                	lui	a5,0xfffff
    80001cc6:	00fa7a33          	and	s4,s4,a5
    80001cca:	4681                	li	a3,0
    80001ccc:	4605                	li	a2,1
    80001cce:	85d2                	mv	a1,s4
    80001cd0:	68a8                	ld	a0,80(s1)
    80001cd2:	a63fe0ef          	jal	80000734 <uvmunmap>
        if(mappages(p->pagetable, PGROUNDDOWN(stval), PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001cd6:	4779                	li	a4,30
    80001cd8:	86ce                	mv	a3,s3
    80001cda:	6605                	lui	a2,0x1
    80001cdc:	85d2                	mv	a1,s4
    80001cde:	68a8                	ld	a0,80(s1)
    80001ce0:	8affe0ef          	jal	8000058e <mappages>
    80001ce4:	c115                	beqz	a0,80001d08 <usertrap+0x186>
          kfree(mem);
    80001ce6:	854e                	mv	a0,s3
    80001ce8:	bc8fe0ef          	jal	800000b0 <kfree>
          setkilled(p);
    80001cec:	8526                	mv	a0,s1
    80001cee:	a15ff0ef          	jal	80001702 <setkilled>
    80001cf2:	bf3d                	j	80001c30 <usertrap+0xae>
        printf("usertrap(): COW alloc failed\n");
    80001cf4:	00005517          	auipc	a0,0x5
    80001cf8:	61450513          	addi	a0,a0,1556 # 80007308 <etext+0x308>
    80001cfc:	6b4030ef          	jal	800053b0 <printf>
        setkilled(p);
    80001d00:	8526                	mv	a0,s1
    80001d02:	a01ff0ef          	jal	80001702 <setkilled>
    80001d06:	b72d                	j	80001c30 <usertrap+0xae>
          kfree((void*)pa); // CORRECT
    80001d08:	854a                	mv	a0,s2
    80001d0a:	ba6fe0ef          	jal	800000b0 <kfree>
    80001d0e:	b70d                	j	80001c30 <usertrap+0xae>
  if(killed(p))
    80001d10:	8526                	mv	a0,s1
    80001d12:	a15ff0ef          	jal	80001726 <killed>
    80001d16:	c511                	beqz	a0,80001d22 <usertrap+0x1a0>
    80001d18:	a011                	j	80001d1c <usertrap+0x19a>
    80001d1a:	4901                	li	s2,0
    exit(-1);
    80001d1c:	557d                	li	a0,-1
    80001d1e:	8ddff0ef          	jal	800015fa <exit>
  if(which_dev == 2)
    80001d22:	4789                	li	a5,2
    80001d24:	f0f91be3          	bne	s2,a5,80001c3a <usertrap+0xb8>
    yield();
    80001d28:	f9aff0ef          	jal	800014c2 <yield>
    80001d2c:	b739                	j	80001c3a <usertrap+0xb8>

0000000080001d2e <kerneltrap>:
{
    80001d2e:	7179                	addi	sp,sp,-48
    80001d30:	f406                	sd	ra,40(sp)
    80001d32:	f022                	sd	s0,32(sp)
    80001d34:	ec26                	sd	s1,24(sp)
    80001d36:	e84a                	sd	s2,16(sp)
    80001d38:	e44e                	sd	s3,8(sp)
    80001d3a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d3c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d40:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d44:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001d48:	1004f793          	andi	a5,s1,256
    80001d4c:	c795                	beqz	a5,80001d78 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d52:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001d54:	eb85                	bnez	a5,80001d84 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001d56:	db9ff0ef          	jal	80001b0e <devintr>
    80001d5a:	c91d                	beqz	a0,80001d90 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001d5c:	4789                	li	a5,2
    80001d5e:	04f50a63          	beq	a0,a5,80001db2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d62:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d66:	10049073          	csrw	sstatus,s1
}
    80001d6a:	70a2                	ld	ra,40(sp)
    80001d6c:	7402                	ld	s0,32(sp)
    80001d6e:	64e2                	ld	s1,24(sp)
    80001d70:	6942                	ld	s2,16(sp)
    80001d72:	69a2                	ld	s3,8(sp)
    80001d74:	6145                	addi	sp,sp,48
    80001d76:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001d78:	00005517          	auipc	a0,0x5
    80001d7c:	65050513          	addi	a0,a0,1616 # 800073c8 <etext+0x3c8>
    80001d80:	103030ef          	jal	80005682 <panic>
    panic("kerneltrap: interrupts enabled");
    80001d84:	00005517          	auipc	a0,0x5
    80001d88:	66c50513          	addi	a0,a0,1644 # 800073f0 <etext+0x3f0>
    80001d8c:	0f7030ef          	jal	80005682 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d90:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d94:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001d98:	85ce                	mv	a1,s3
    80001d9a:	00005517          	auipc	a0,0x5
    80001d9e:	67650513          	addi	a0,a0,1654 # 80007410 <etext+0x410>
    80001da2:	60e030ef          	jal	800053b0 <printf>
    panic("kerneltrap");
    80001da6:	00005517          	auipc	a0,0x5
    80001daa:	69250513          	addi	a0,a0,1682 # 80007438 <etext+0x438>
    80001dae:	0d5030ef          	jal	80005682 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001db2:	96eff0ef          	jal	80000f20 <myproc>
    80001db6:	d555                	beqz	a0,80001d62 <kerneltrap+0x34>
    yield();
    80001db8:	f0aff0ef          	jal	800014c2 <yield>
    80001dbc:	b75d                	j	80001d62 <kerneltrap+0x34>

0000000080001dbe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001dbe:	1101                	addi	sp,sp,-32
    80001dc0:	ec06                	sd	ra,24(sp)
    80001dc2:	e822                	sd	s0,16(sp)
    80001dc4:	e426                	sd	s1,8(sp)
    80001dc6:	1000                	addi	s0,sp,32
    80001dc8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dca:	956ff0ef          	jal	80000f20 <myproc>
  switch (n) {
    80001dce:	4795                	li	a5,5
    80001dd0:	0497e163          	bltu	a5,s1,80001e12 <argraw+0x54>
    80001dd4:	048a                	slli	s1,s1,0x2
    80001dd6:	00006717          	auipc	a4,0x6
    80001dda:	a6a70713          	addi	a4,a4,-1430 # 80007840 <states.0+0x30>
    80001dde:	94ba                	add	s1,s1,a4
    80001de0:	409c                	lw	a5,0(s1)
    80001de2:	97ba                	add	a5,a5,a4
    80001de4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001de6:	6d3c                	ld	a5,88(a0)
    80001de8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret
    return p->trapframe->a1;
    80001df4:	6d3c                	ld	a5,88(a0)
    80001df6:	7fa8                	ld	a0,120(a5)
    80001df8:	bfcd                	j	80001dea <argraw+0x2c>
    return p->trapframe->a2;
    80001dfa:	6d3c                	ld	a5,88(a0)
    80001dfc:	63c8                	ld	a0,128(a5)
    80001dfe:	b7f5                	j	80001dea <argraw+0x2c>
    return p->trapframe->a3;
    80001e00:	6d3c                	ld	a5,88(a0)
    80001e02:	67c8                	ld	a0,136(a5)
    80001e04:	b7dd                	j	80001dea <argraw+0x2c>
    return p->trapframe->a4;
    80001e06:	6d3c                	ld	a5,88(a0)
    80001e08:	6bc8                	ld	a0,144(a5)
    80001e0a:	b7c5                	j	80001dea <argraw+0x2c>
    return p->trapframe->a5;
    80001e0c:	6d3c                	ld	a5,88(a0)
    80001e0e:	6fc8                	ld	a0,152(a5)
    80001e10:	bfe9                	j	80001dea <argraw+0x2c>
  panic("argraw");
    80001e12:	00005517          	auipc	a0,0x5
    80001e16:	63650513          	addi	a0,a0,1590 # 80007448 <etext+0x448>
    80001e1a:	069030ef          	jal	80005682 <panic>

0000000080001e1e <fetchaddr>:
{
    80001e1e:	1101                	addi	sp,sp,-32
    80001e20:	ec06                	sd	ra,24(sp)
    80001e22:	e822                	sd	s0,16(sp)
    80001e24:	e426                	sd	s1,8(sp)
    80001e26:	e04a                	sd	s2,0(sp)
    80001e28:	1000                	addi	s0,sp,32
    80001e2a:	84aa                	mv	s1,a0
    80001e2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e2e:	8f2ff0ef          	jal	80000f20 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001e32:	653c                	ld	a5,72(a0)
    80001e34:	02f4f663          	bgeu	s1,a5,80001e60 <fetchaddr+0x42>
    80001e38:	00848713          	addi	a4,s1,8
    80001e3c:	02e7e463          	bltu	a5,a4,80001e64 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001e40:	46a1                	li	a3,8
    80001e42:	8626                	mv	a2,s1
    80001e44:	85ca                	mv	a1,s2
    80001e46:	6928                	ld	a0,80(a0)
    80001e48:	e21fe0ef          	jal	80000c68 <copyin>
    80001e4c:	00a03533          	snez	a0,a0
    80001e50:	40a00533          	neg	a0,a0
}
    80001e54:	60e2                	ld	ra,24(sp)
    80001e56:	6442                	ld	s0,16(sp)
    80001e58:	64a2                	ld	s1,8(sp)
    80001e5a:	6902                	ld	s2,0(sp)
    80001e5c:	6105                	addi	sp,sp,32
    80001e5e:	8082                	ret
    return -1;
    80001e60:	557d                	li	a0,-1
    80001e62:	bfcd                	j	80001e54 <fetchaddr+0x36>
    80001e64:	557d                	li	a0,-1
    80001e66:	b7fd                	j	80001e54 <fetchaddr+0x36>

0000000080001e68 <fetchstr>:
{
    80001e68:	7179                	addi	sp,sp,-48
    80001e6a:	f406                	sd	ra,40(sp)
    80001e6c:	f022                	sd	s0,32(sp)
    80001e6e:	ec26                	sd	s1,24(sp)
    80001e70:	e84a                	sd	s2,16(sp)
    80001e72:	e44e                	sd	s3,8(sp)
    80001e74:	1800                	addi	s0,sp,48
    80001e76:	892a                	mv	s2,a0
    80001e78:	84ae                	mv	s1,a1
    80001e7a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001e7c:	8a4ff0ef          	jal	80000f20 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001e80:	86ce                	mv	a3,s3
    80001e82:	864a                	mv	a2,s2
    80001e84:	85a6                	mv	a1,s1
    80001e86:	6928                	ld	a0,80(a0)
    80001e88:	e67fe0ef          	jal	80000cee <copyinstr>
    80001e8c:	00054c63          	bltz	a0,80001ea4 <fetchstr+0x3c>
  return strlen(buf);
    80001e90:	8526                	mv	a0,s1
    80001e92:	d20fe0ef          	jal	800003b2 <strlen>
}
    80001e96:	70a2                	ld	ra,40(sp)
    80001e98:	7402                	ld	s0,32(sp)
    80001e9a:	64e2                	ld	s1,24(sp)
    80001e9c:	6942                	ld	s2,16(sp)
    80001e9e:	69a2                	ld	s3,8(sp)
    80001ea0:	6145                	addi	sp,sp,48
    80001ea2:	8082                	ret
    return -1;
    80001ea4:	557d                	li	a0,-1
    80001ea6:	bfc5                	j	80001e96 <fetchstr+0x2e>

0000000080001ea8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	1000                	addi	s0,sp,32
    80001eb2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001eb4:	f0bff0ef          	jal	80001dbe <argraw>
    80001eb8:	c088                	sw	a0,0(s1)
}
    80001eba:	60e2                	ld	ra,24(sp)
    80001ebc:	6442                	ld	s0,16(sp)
    80001ebe:	64a2                	ld	s1,8(sp)
    80001ec0:	6105                	addi	sp,sp,32
    80001ec2:	8082                	ret

0000000080001ec4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001ec4:	1101                	addi	sp,sp,-32
    80001ec6:	ec06                	sd	ra,24(sp)
    80001ec8:	e822                	sd	s0,16(sp)
    80001eca:	e426                	sd	s1,8(sp)
    80001ecc:	1000                	addi	s0,sp,32
    80001ece:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ed0:	eefff0ef          	jal	80001dbe <argraw>
    80001ed4:	e088                	sd	a0,0(s1)
}
    80001ed6:	60e2                	ld	ra,24(sp)
    80001ed8:	6442                	ld	s0,16(sp)
    80001eda:	64a2                	ld	s1,8(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret

0000000080001ee0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001ee0:	7179                	addi	sp,sp,-48
    80001ee2:	f406                	sd	ra,40(sp)
    80001ee4:	f022                	sd	s0,32(sp)
    80001ee6:	ec26                	sd	s1,24(sp)
    80001ee8:	e84a                	sd	s2,16(sp)
    80001eea:	1800                	addi	s0,sp,48
    80001eec:	84ae                	mv	s1,a1
    80001eee:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001ef0:	fd840593          	addi	a1,s0,-40
    80001ef4:	fd1ff0ef          	jal	80001ec4 <argaddr>
  return fetchstr(addr, buf, max);
    80001ef8:	864a                	mv	a2,s2
    80001efa:	85a6                	mv	a1,s1
    80001efc:	fd843503          	ld	a0,-40(s0)
    80001f00:	f69ff0ef          	jal	80001e68 <fetchstr>
}
    80001f04:	70a2                	ld	ra,40(sp)
    80001f06:	7402                	ld	s0,32(sp)
    80001f08:	64e2                	ld	s1,24(sp)
    80001f0a:	6942                	ld	s2,16(sp)
    80001f0c:	6145                	addi	sp,sp,48
    80001f0e:	8082                	ret

0000000080001f10 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80001f10:	1101                	addi	sp,sp,-32
    80001f12:	ec06                	sd	ra,24(sp)
    80001f14:	e822                	sd	s0,16(sp)
    80001f16:	e426                	sd	s1,8(sp)
    80001f18:	e04a                	sd	s2,0(sp)
    80001f1a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001f1c:	804ff0ef          	jal	80000f20 <myproc>
    80001f20:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001f22:	05853903          	ld	s2,88(a0)
    80001f26:	0a893783          	ld	a5,168(s2)
    80001f2a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001f2e:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffbb94f>
    80001f30:	4751                	li	a4,20
    80001f32:	00f76f63          	bltu	a4,a5,80001f50 <syscall+0x40>
    80001f36:	00369713          	slli	a4,a3,0x3
    80001f3a:	00006797          	auipc	a5,0x6
    80001f3e:	91e78793          	addi	a5,a5,-1762 # 80007858 <syscalls>
    80001f42:	97ba                	add	a5,a5,a4
    80001f44:	639c                	ld	a5,0(a5)
    80001f46:	c789                	beqz	a5,80001f50 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001f48:	9782                	jalr	a5
    80001f4a:	06a93823          	sd	a0,112(s2)
    80001f4e:	a829                	j	80001f68 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001f50:	15848613          	addi	a2,s1,344
    80001f54:	588c                	lw	a1,48(s1)
    80001f56:	00005517          	auipc	a0,0x5
    80001f5a:	4fa50513          	addi	a0,a0,1274 # 80007450 <etext+0x450>
    80001f5e:	452030ef          	jal	800053b0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001f62:	6cbc                	ld	a5,88(s1)
    80001f64:	577d                	li	a4,-1
    80001f66:	fbb8                	sd	a4,112(a5)
  }
}
    80001f68:	60e2                	ld	ra,24(sp)
    80001f6a:	6442                	ld	s0,16(sp)
    80001f6c:	64a2                	ld	s1,8(sp)
    80001f6e:	6902                	ld	s2,0(sp)
    80001f70:	6105                	addi	sp,sp,32
    80001f72:	8082                	ret

0000000080001f74 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001f74:	1101                	addi	sp,sp,-32
    80001f76:	ec06                	sd	ra,24(sp)
    80001f78:	e822                	sd	s0,16(sp)
    80001f7a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001f7c:	fec40593          	addi	a1,s0,-20
    80001f80:	4501                	li	a0,0
    80001f82:	f27ff0ef          	jal	80001ea8 <argint>
  exit(n);
    80001f86:	fec42503          	lw	a0,-20(s0)
    80001f8a:	e70ff0ef          	jal	800015fa <exit>
  return 0;  // not reached
}
    80001f8e:	4501                	li	a0,0
    80001f90:	60e2                	ld	ra,24(sp)
    80001f92:	6442                	ld	s0,16(sp)
    80001f94:	6105                	addi	sp,sp,32
    80001f96:	8082                	ret

0000000080001f98 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001f98:	1141                	addi	sp,sp,-16
    80001f9a:	e406                	sd	ra,8(sp)
    80001f9c:	e022                	sd	s0,0(sp)
    80001f9e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001fa0:	f81fe0ef          	jal	80000f20 <myproc>
}
    80001fa4:	5908                	lw	a0,48(a0)
    80001fa6:	60a2                	ld	ra,8(sp)
    80001fa8:	6402                	ld	s0,0(sp)
    80001faa:	0141                	addi	sp,sp,16
    80001fac:	8082                	ret

0000000080001fae <sys_fork>:

uint64
sys_fork(void)
{
    80001fae:	1141                	addi	sp,sp,-16
    80001fb0:	e406                	sd	ra,8(sp)
    80001fb2:	e022                	sd	s0,0(sp)
    80001fb4:	0800                	addi	s0,sp,16
  return fork();
    80001fb6:	a90ff0ef          	jal	80001246 <fork>
}
    80001fba:	60a2                	ld	ra,8(sp)
    80001fbc:	6402                	ld	s0,0(sp)
    80001fbe:	0141                	addi	sp,sp,16
    80001fc0:	8082                	ret

0000000080001fc2 <sys_wait>:

uint64
sys_wait(void)
{
    80001fc2:	1101                	addi	sp,sp,-32
    80001fc4:	ec06                	sd	ra,24(sp)
    80001fc6:	e822                	sd	s0,16(sp)
    80001fc8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001fca:	fe840593          	addi	a1,s0,-24
    80001fce:	4501                	li	a0,0
    80001fd0:	ef5ff0ef          	jal	80001ec4 <argaddr>
  return wait(p);
    80001fd4:	fe843503          	ld	a0,-24(s0)
    80001fd8:	f78ff0ef          	jal	80001750 <wait>
}
    80001fdc:	60e2                	ld	ra,24(sp)
    80001fde:	6442                	ld	s0,16(sp)
    80001fe0:	6105                	addi	sp,sp,32
    80001fe2:	8082                	ret

0000000080001fe4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001fe4:	7179                	addi	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001fee:	fdc40593          	addi	a1,s0,-36
    80001ff2:	4501                	li	a0,0
    80001ff4:	eb5ff0ef          	jal	80001ea8 <argint>
  addr = myproc()->sz;
    80001ff8:	f29fe0ef          	jal	80000f20 <myproc>
    80001ffc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001ffe:	fdc42503          	lw	a0,-36(s0)
    80002002:	9f4ff0ef          	jal	800011f6 <growproc>
    80002006:	00054863          	bltz	a0,80002016 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000200a:	8526                	mv	a0,s1
    8000200c:	70a2                	ld	ra,40(sp)
    8000200e:	7402                	ld	s0,32(sp)
    80002010:	64e2                	ld	s1,24(sp)
    80002012:	6145                	addi	sp,sp,48
    80002014:	8082                	ret
    return -1;
    80002016:	54fd                	li	s1,-1
    80002018:	bfcd                	j	8000200a <sys_sbrk+0x26>

000000008000201a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000201a:	7139                	addi	sp,sp,-64
    8000201c:	fc06                	sd	ra,56(sp)
    8000201e:	f822                	sd	s0,48(sp)
    80002020:	f04a                	sd	s2,32(sp)
    80002022:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002024:	fcc40593          	addi	a1,s0,-52
    80002028:	4501                	li	a0,0
    8000202a:	e7fff0ef          	jal	80001ea8 <argint>
  if(n < 0)
    8000202e:	fcc42783          	lw	a5,-52(s0)
    80002032:	0607c763          	bltz	a5,800020a0 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002036:	0002e517          	auipc	a0,0x2e
    8000203a:	19a50513          	addi	a0,a0,410 # 800301d0 <tickslock>
    8000203e:	173030ef          	jal	800059b0 <acquire>
  ticks0 = ticks;
    80002042:	00008917          	auipc	s2,0x8
    80002046:	32692903          	lw	s2,806(s2) # 8000a368 <ticks>
  while(ticks - ticks0 < n){
    8000204a:	fcc42783          	lw	a5,-52(s0)
    8000204e:	cf8d                	beqz	a5,80002088 <sys_sleep+0x6e>
    80002050:	f426                	sd	s1,40(sp)
    80002052:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002054:	0002e997          	auipc	s3,0x2e
    80002058:	17c98993          	addi	s3,s3,380 # 800301d0 <tickslock>
    8000205c:	00008497          	auipc	s1,0x8
    80002060:	30c48493          	addi	s1,s1,780 # 8000a368 <ticks>
    if(killed(myproc())){
    80002064:	ebdfe0ef          	jal	80000f20 <myproc>
    80002068:	ebeff0ef          	jal	80001726 <killed>
    8000206c:	ed0d                	bnez	a0,800020a6 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000206e:	85ce                	mv	a1,s3
    80002070:	8526                	mv	a0,s1
    80002072:	c7cff0ef          	jal	800014ee <sleep>
  while(ticks - ticks0 < n){
    80002076:	409c                	lw	a5,0(s1)
    80002078:	412787bb          	subw	a5,a5,s2
    8000207c:	fcc42703          	lw	a4,-52(s0)
    80002080:	fee7e2e3          	bltu	a5,a4,80002064 <sys_sleep+0x4a>
    80002084:	74a2                	ld	s1,40(sp)
    80002086:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002088:	0002e517          	auipc	a0,0x2e
    8000208c:	14850513          	addi	a0,a0,328 # 800301d0 <tickslock>
    80002090:	1b9030ef          	jal	80005a48 <release>
  return 0;
    80002094:	4501                	li	a0,0
}
    80002096:	70e2                	ld	ra,56(sp)
    80002098:	7442                	ld	s0,48(sp)
    8000209a:	7902                	ld	s2,32(sp)
    8000209c:	6121                	addi	sp,sp,64
    8000209e:	8082                	ret
    n = 0;
    800020a0:	fc042623          	sw	zero,-52(s0)
    800020a4:	bf49                	j	80002036 <sys_sleep+0x1c>
      release(&tickslock);
    800020a6:	0002e517          	auipc	a0,0x2e
    800020aa:	12a50513          	addi	a0,a0,298 # 800301d0 <tickslock>
    800020ae:	19b030ef          	jal	80005a48 <release>
      return -1;
    800020b2:	557d                	li	a0,-1
    800020b4:	74a2                	ld	s1,40(sp)
    800020b6:	69e2                	ld	s3,24(sp)
    800020b8:	bff9                	j	80002096 <sys_sleep+0x7c>

00000000800020ba <sys_kill>:

uint64
sys_kill(void)
{
    800020ba:	1101                	addi	sp,sp,-32
    800020bc:	ec06                	sd	ra,24(sp)
    800020be:	e822                	sd	s0,16(sp)
    800020c0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800020c2:	fec40593          	addi	a1,s0,-20
    800020c6:	4501                	li	a0,0
    800020c8:	de1ff0ef          	jal	80001ea8 <argint>
  return kill(pid);
    800020cc:	fec42503          	lw	a0,-20(s0)
    800020d0:	dccff0ef          	jal	8000169c <kill>
}
    800020d4:	60e2                	ld	ra,24(sp)
    800020d6:	6442                	ld	s0,16(sp)
    800020d8:	6105                	addi	sp,sp,32
    800020da:	8082                	ret

00000000800020dc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800020dc:	1101                	addi	sp,sp,-32
    800020de:	ec06                	sd	ra,24(sp)
    800020e0:	e822                	sd	s0,16(sp)
    800020e2:	e426                	sd	s1,8(sp)
    800020e4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800020e6:	0002e517          	auipc	a0,0x2e
    800020ea:	0ea50513          	addi	a0,a0,234 # 800301d0 <tickslock>
    800020ee:	0c3030ef          	jal	800059b0 <acquire>
  xticks = ticks;
    800020f2:	00008497          	auipc	s1,0x8
    800020f6:	2764a483          	lw	s1,630(s1) # 8000a368 <ticks>
  release(&tickslock);
    800020fa:	0002e517          	auipc	a0,0x2e
    800020fe:	0d650513          	addi	a0,a0,214 # 800301d0 <tickslock>
    80002102:	147030ef          	jal	80005a48 <release>
  return xticks;
}
    80002106:	02049513          	slli	a0,s1,0x20
    8000210a:	9101                	srli	a0,a0,0x20
    8000210c:	60e2                	ld	ra,24(sp)
    8000210e:	6442                	ld	s0,16(sp)
    80002110:	64a2                	ld	s1,8(sp)
    80002112:	6105                	addi	sp,sp,32
    80002114:	8082                	ret

0000000080002116 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002116:	7179                	addi	sp,sp,-48
    80002118:	f406                	sd	ra,40(sp)
    8000211a:	f022                	sd	s0,32(sp)
    8000211c:	ec26                	sd	s1,24(sp)
    8000211e:	e84a                	sd	s2,16(sp)
    80002120:	e44e                	sd	s3,8(sp)
    80002122:	e052                	sd	s4,0(sp)
    80002124:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002126:	00005597          	auipc	a1,0x5
    8000212a:	34a58593          	addi	a1,a1,842 # 80007470 <etext+0x470>
    8000212e:	0002e517          	auipc	a0,0x2e
    80002132:	0ba50513          	addi	a0,a0,186 # 800301e8 <bcache>
    80002136:	7fa030ef          	jal	80005930 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000213a:	00036797          	auipc	a5,0x36
    8000213e:	0ae78793          	addi	a5,a5,174 # 800381e8 <bcache+0x8000>
    80002142:	00036717          	auipc	a4,0x36
    80002146:	30e70713          	addi	a4,a4,782 # 80038450 <bcache+0x8268>
    8000214a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000214e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002152:	0002e497          	auipc	s1,0x2e
    80002156:	0ae48493          	addi	s1,s1,174 # 80030200 <bcache+0x18>
    b->next = bcache.head.next;
    8000215a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000215c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000215e:	00005a17          	auipc	s4,0x5
    80002162:	31aa0a13          	addi	s4,s4,794 # 80007478 <etext+0x478>
    b->next = bcache.head.next;
    80002166:	2b893783          	ld	a5,696(s2)
    8000216a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000216c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002170:	85d2                	mv	a1,s4
    80002172:	01048513          	addi	a0,s1,16
    80002176:	248010ef          	jal	800033be <initsleeplock>
    bcache.head.next->prev = b;
    8000217a:	2b893783          	ld	a5,696(s2)
    8000217e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002180:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002184:	45848493          	addi	s1,s1,1112
    80002188:	fd349fe3          	bne	s1,s3,80002166 <binit+0x50>
  }
}
    8000218c:	70a2                	ld	ra,40(sp)
    8000218e:	7402                	ld	s0,32(sp)
    80002190:	64e2                	ld	s1,24(sp)
    80002192:	6942                	ld	s2,16(sp)
    80002194:	69a2                	ld	s3,8(sp)
    80002196:	6a02                	ld	s4,0(sp)
    80002198:	6145                	addi	sp,sp,48
    8000219a:	8082                	ret

000000008000219c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000219c:	7179                	addi	sp,sp,-48
    8000219e:	f406                	sd	ra,40(sp)
    800021a0:	f022                	sd	s0,32(sp)
    800021a2:	ec26                	sd	s1,24(sp)
    800021a4:	e84a                	sd	s2,16(sp)
    800021a6:	e44e                	sd	s3,8(sp)
    800021a8:	1800                	addi	s0,sp,48
    800021aa:	892a                	mv	s2,a0
    800021ac:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800021ae:	0002e517          	auipc	a0,0x2e
    800021b2:	03a50513          	addi	a0,a0,58 # 800301e8 <bcache>
    800021b6:	7fa030ef          	jal	800059b0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800021ba:	00036497          	auipc	s1,0x36
    800021be:	2e64b483          	ld	s1,742(s1) # 800384a0 <bcache+0x82b8>
    800021c2:	00036797          	auipc	a5,0x36
    800021c6:	28e78793          	addi	a5,a5,654 # 80038450 <bcache+0x8268>
    800021ca:	02f48b63          	beq	s1,a5,80002200 <bread+0x64>
    800021ce:	873e                	mv	a4,a5
    800021d0:	a021                	j	800021d8 <bread+0x3c>
    800021d2:	68a4                	ld	s1,80(s1)
    800021d4:	02e48663          	beq	s1,a4,80002200 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800021d8:	449c                	lw	a5,8(s1)
    800021da:	ff279ce3          	bne	a5,s2,800021d2 <bread+0x36>
    800021de:	44dc                	lw	a5,12(s1)
    800021e0:	ff3799e3          	bne	a5,s3,800021d2 <bread+0x36>
      b->refcnt++;
    800021e4:	40bc                	lw	a5,64(s1)
    800021e6:	2785                	addiw	a5,a5,1
    800021e8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800021ea:	0002e517          	auipc	a0,0x2e
    800021ee:	ffe50513          	addi	a0,a0,-2 # 800301e8 <bcache>
    800021f2:	057030ef          	jal	80005a48 <release>
      acquiresleep(&b->lock);
    800021f6:	01048513          	addi	a0,s1,16
    800021fa:	1fa010ef          	jal	800033f4 <acquiresleep>
      return b;
    800021fe:	a889                	j	80002250 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002200:	00036497          	auipc	s1,0x36
    80002204:	2984b483          	ld	s1,664(s1) # 80038498 <bcache+0x82b0>
    80002208:	00036797          	auipc	a5,0x36
    8000220c:	24878793          	addi	a5,a5,584 # 80038450 <bcache+0x8268>
    80002210:	00f48863          	beq	s1,a5,80002220 <bread+0x84>
    80002214:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002216:	40bc                	lw	a5,64(s1)
    80002218:	cb91                	beqz	a5,8000222c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000221a:	64a4                	ld	s1,72(s1)
    8000221c:	fee49de3          	bne	s1,a4,80002216 <bread+0x7a>
  panic("bget: no buffers");
    80002220:	00005517          	auipc	a0,0x5
    80002224:	26050513          	addi	a0,a0,608 # 80007480 <etext+0x480>
    80002228:	45a030ef          	jal	80005682 <panic>
      b->dev = dev;
    8000222c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002230:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002234:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002238:	4785                	li	a5,1
    8000223a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000223c:	0002e517          	auipc	a0,0x2e
    80002240:	fac50513          	addi	a0,a0,-84 # 800301e8 <bcache>
    80002244:	005030ef          	jal	80005a48 <release>
      acquiresleep(&b->lock);
    80002248:	01048513          	addi	a0,s1,16
    8000224c:	1a8010ef          	jal	800033f4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002250:	409c                	lw	a5,0(s1)
    80002252:	cb89                	beqz	a5,80002264 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002254:	8526                	mv	a0,s1
    80002256:	70a2                	ld	ra,40(sp)
    80002258:	7402                	ld	s0,32(sp)
    8000225a:	64e2                	ld	s1,24(sp)
    8000225c:	6942                	ld	s2,16(sp)
    8000225e:	69a2                	ld	s3,8(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret
    virtio_disk_rw(b, 0);
    80002264:	4581                	li	a1,0
    80002266:	8526                	mv	a0,s1
    80002268:	1e9020ef          	jal	80004c50 <virtio_disk_rw>
    b->valid = 1;
    8000226c:	4785                	li	a5,1
    8000226e:	c09c                	sw	a5,0(s1)
  return b;
    80002270:	b7d5                	j	80002254 <bread+0xb8>

0000000080002272 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002272:	1101                	addi	sp,sp,-32
    80002274:	ec06                	sd	ra,24(sp)
    80002276:	e822                	sd	s0,16(sp)
    80002278:	e426                	sd	s1,8(sp)
    8000227a:	1000                	addi	s0,sp,32
    8000227c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000227e:	0541                	addi	a0,a0,16
    80002280:	1f2010ef          	jal	80003472 <holdingsleep>
    80002284:	c911                	beqz	a0,80002298 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002286:	4585                	li	a1,1
    80002288:	8526                	mv	a0,s1
    8000228a:	1c7020ef          	jal	80004c50 <virtio_disk_rw>
}
    8000228e:	60e2                	ld	ra,24(sp)
    80002290:	6442                	ld	s0,16(sp)
    80002292:	64a2                	ld	s1,8(sp)
    80002294:	6105                	addi	sp,sp,32
    80002296:	8082                	ret
    panic("bwrite");
    80002298:	00005517          	auipc	a0,0x5
    8000229c:	20050513          	addi	a0,a0,512 # 80007498 <etext+0x498>
    800022a0:	3e2030ef          	jal	80005682 <panic>

00000000800022a4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800022a4:	1101                	addi	sp,sp,-32
    800022a6:	ec06                	sd	ra,24(sp)
    800022a8:	e822                	sd	s0,16(sp)
    800022aa:	e426                	sd	s1,8(sp)
    800022ac:	e04a                	sd	s2,0(sp)
    800022ae:	1000                	addi	s0,sp,32
    800022b0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022b2:	01050913          	addi	s2,a0,16
    800022b6:	854a                	mv	a0,s2
    800022b8:	1ba010ef          	jal	80003472 <holdingsleep>
    800022bc:	c135                	beqz	a0,80002320 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800022be:	854a                	mv	a0,s2
    800022c0:	17a010ef          	jal	8000343a <releasesleep>

  acquire(&bcache.lock);
    800022c4:	0002e517          	auipc	a0,0x2e
    800022c8:	f2450513          	addi	a0,a0,-220 # 800301e8 <bcache>
    800022cc:	6e4030ef          	jal	800059b0 <acquire>
  b->refcnt--;
    800022d0:	40bc                	lw	a5,64(s1)
    800022d2:	37fd                	addiw	a5,a5,-1
    800022d4:	0007871b          	sext.w	a4,a5
    800022d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800022da:	e71d                	bnez	a4,80002308 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800022dc:	68b8                	ld	a4,80(s1)
    800022de:	64bc                	ld	a5,72(s1)
    800022e0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800022e2:	68b8                	ld	a4,80(s1)
    800022e4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800022e6:	00036797          	auipc	a5,0x36
    800022ea:	f0278793          	addi	a5,a5,-254 # 800381e8 <bcache+0x8000>
    800022ee:	2b87b703          	ld	a4,696(a5)
    800022f2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800022f4:	00036717          	auipc	a4,0x36
    800022f8:	15c70713          	addi	a4,a4,348 # 80038450 <bcache+0x8268>
    800022fc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800022fe:	2b87b703          	ld	a4,696(a5)
    80002302:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002304:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002308:	0002e517          	auipc	a0,0x2e
    8000230c:	ee050513          	addi	a0,a0,-288 # 800301e8 <bcache>
    80002310:	738030ef          	jal	80005a48 <release>
}
    80002314:	60e2                	ld	ra,24(sp)
    80002316:	6442                	ld	s0,16(sp)
    80002318:	64a2                	ld	s1,8(sp)
    8000231a:	6902                	ld	s2,0(sp)
    8000231c:	6105                	addi	sp,sp,32
    8000231e:	8082                	ret
    panic("brelse");
    80002320:	00005517          	auipc	a0,0x5
    80002324:	18050513          	addi	a0,a0,384 # 800074a0 <etext+0x4a0>
    80002328:	35a030ef          	jal	80005682 <panic>

000000008000232c <bpin>:

void
bpin(struct buf *b) {
    8000232c:	1101                	addi	sp,sp,-32
    8000232e:	ec06                	sd	ra,24(sp)
    80002330:	e822                	sd	s0,16(sp)
    80002332:	e426                	sd	s1,8(sp)
    80002334:	1000                	addi	s0,sp,32
    80002336:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002338:	0002e517          	auipc	a0,0x2e
    8000233c:	eb050513          	addi	a0,a0,-336 # 800301e8 <bcache>
    80002340:	670030ef          	jal	800059b0 <acquire>
  b->refcnt++;
    80002344:	40bc                	lw	a5,64(s1)
    80002346:	2785                	addiw	a5,a5,1
    80002348:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000234a:	0002e517          	auipc	a0,0x2e
    8000234e:	e9e50513          	addi	a0,a0,-354 # 800301e8 <bcache>
    80002352:	6f6030ef          	jal	80005a48 <release>
}
    80002356:	60e2                	ld	ra,24(sp)
    80002358:	6442                	ld	s0,16(sp)
    8000235a:	64a2                	ld	s1,8(sp)
    8000235c:	6105                	addi	sp,sp,32
    8000235e:	8082                	ret

0000000080002360 <bunpin>:

void
bunpin(struct buf *b) {
    80002360:	1101                	addi	sp,sp,-32
    80002362:	ec06                	sd	ra,24(sp)
    80002364:	e822                	sd	s0,16(sp)
    80002366:	e426                	sd	s1,8(sp)
    80002368:	1000                	addi	s0,sp,32
    8000236a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000236c:	0002e517          	auipc	a0,0x2e
    80002370:	e7c50513          	addi	a0,a0,-388 # 800301e8 <bcache>
    80002374:	63c030ef          	jal	800059b0 <acquire>
  b->refcnt--;
    80002378:	40bc                	lw	a5,64(s1)
    8000237a:	37fd                	addiw	a5,a5,-1
    8000237c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000237e:	0002e517          	auipc	a0,0x2e
    80002382:	e6a50513          	addi	a0,a0,-406 # 800301e8 <bcache>
    80002386:	6c2030ef          	jal	80005a48 <release>
}
    8000238a:	60e2                	ld	ra,24(sp)
    8000238c:	6442                	ld	s0,16(sp)
    8000238e:	64a2                	ld	s1,8(sp)
    80002390:	6105                	addi	sp,sp,32
    80002392:	8082                	ret

0000000080002394 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002394:	1101                	addi	sp,sp,-32
    80002396:	ec06                	sd	ra,24(sp)
    80002398:	e822                	sd	s0,16(sp)
    8000239a:	e426                	sd	s1,8(sp)
    8000239c:	e04a                	sd	s2,0(sp)
    8000239e:	1000                	addi	s0,sp,32
    800023a0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800023a2:	00d5d59b          	srliw	a1,a1,0xd
    800023a6:	00036797          	auipc	a5,0x36
    800023aa:	51e7a783          	lw	a5,1310(a5) # 800388c4 <sb+0x1c>
    800023ae:	9dbd                	addw	a1,a1,a5
    800023b0:	dedff0ef          	jal	8000219c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800023b4:	0074f713          	andi	a4,s1,7
    800023b8:	4785                	li	a5,1
    800023ba:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800023be:	14ce                	slli	s1,s1,0x33
    800023c0:	90d9                	srli	s1,s1,0x36
    800023c2:	00950733          	add	a4,a0,s1
    800023c6:	05874703          	lbu	a4,88(a4)
    800023ca:	00e7f6b3          	and	a3,a5,a4
    800023ce:	c29d                	beqz	a3,800023f4 <bfree+0x60>
    800023d0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800023d2:	94aa                	add	s1,s1,a0
    800023d4:	fff7c793          	not	a5,a5
    800023d8:	8f7d                	and	a4,a4,a5
    800023da:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800023de:	711000ef          	jal	800032ee <log_write>
  brelse(bp);
    800023e2:	854a                	mv	a0,s2
    800023e4:	ec1ff0ef          	jal	800022a4 <brelse>
}
    800023e8:	60e2                	ld	ra,24(sp)
    800023ea:	6442                	ld	s0,16(sp)
    800023ec:	64a2                	ld	s1,8(sp)
    800023ee:	6902                	ld	s2,0(sp)
    800023f0:	6105                	addi	sp,sp,32
    800023f2:	8082                	ret
    panic("freeing free block");
    800023f4:	00005517          	auipc	a0,0x5
    800023f8:	0b450513          	addi	a0,a0,180 # 800074a8 <etext+0x4a8>
    800023fc:	286030ef          	jal	80005682 <panic>

0000000080002400 <balloc>:
{
    80002400:	711d                	addi	sp,sp,-96
    80002402:	ec86                	sd	ra,88(sp)
    80002404:	e8a2                	sd	s0,80(sp)
    80002406:	e4a6                	sd	s1,72(sp)
    80002408:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000240a:	00036797          	auipc	a5,0x36
    8000240e:	4a27a783          	lw	a5,1186(a5) # 800388ac <sb+0x4>
    80002412:	0e078f63          	beqz	a5,80002510 <balloc+0x110>
    80002416:	e0ca                	sd	s2,64(sp)
    80002418:	fc4e                	sd	s3,56(sp)
    8000241a:	f852                	sd	s4,48(sp)
    8000241c:	f456                	sd	s5,40(sp)
    8000241e:	f05a                	sd	s6,32(sp)
    80002420:	ec5e                	sd	s7,24(sp)
    80002422:	e862                	sd	s8,16(sp)
    80002424:	e466                	sd	s9,8(sp)
    80002426:	8baa                	mv	s7,a0
    80002428:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000242a:	00036b17          	auipc	s6,0x36
    8000242e:	47eb0b13          	addi	s6,s6,1150 # 800388a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002432:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002434:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002436:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002438:	6c89                	lui	s9,0x2
    8000243a:	a0b5                	j	800024a6 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000243c:	97ca                	add	a5,a5,s2
    8000243e:	8e55                	or	a2,a2,a3
    80002440:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002444:	854a                	mv	a0,s2
    80002446:	6a9000ef          	jal	800032ee <log_write>
        brelse(bp);
    8000244a:	854a                	mv	a0,s2
    8000244c:	e59ff0ef          	jal	800022a4 <brelse>
  bp = bread(dev, bno);
    80002450:	85a6                	mv	a1,s1
    80002452:	855e                	mv	a0,s7
    80002454:	d49ff0ef          	jal	8000219c <bread>
    80002458:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000245a:	40000613          	li	a2,1024
    8000245e:	4581                	li	a1,0
    80002460:	05850513          	addi	a0,a0,88
    80002464:	ddffd0ef          	jal	80000242 <memset>
  log_write(bp);
    80002468:	854a                	mv	a0,s2
    8000246a:	685000ef          	jal	800032ee <log_write>
  brelse(bp);
    8000246e:	854a                	mv	a0,s2
    80002470:	e35ff0ef          	jal	800022a4 <brelse>
}
    80002474:	6906                	ld	s2,64(sp)
    80002476:	79e2                	ld	s3,56(sp)
    80002478:	7a42                	ld	s4,48(sp)
    8000247a:	7aa2                	ld	s5,40(sp)
    8000247c:	7b02                	ld	s6,32(sp)
    8000247e:	6be2                	ld	s7,24(sp)
    80002480:	6c42                	ld	s8,16(sp)
    80002482:	6ca2                	ld	s9,8(sp)
}
    80002484:	8526                	mv	a0,s1
    80002486:	60e6                	ld	ra,88(sp)
    80002488:	6446                	ld	s0,80(sp)
    8000248a:	64a6                	ld	s1,72(sp)
    8000248c:	6125                	addi	sp,sp,96
    8000248e:	8082                	ret
    brelse(bp);
    80002490:	854a                	mv	a0,s2
    80002492:	e13ff0ef          	jal	800022a4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002496:	015c87bb          	addw	a5,s9,s5
    8000249a:	00078a9b          	sext.w	s5,a5
    8000249e:	004b2703          	lw	a4,4(s6)
    800024a2:	04eaff63          	bgeu	s5,a4,80002500 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800024a6:	41fad79b          	sraiw	a5,s5,0x1f
    800024aa:	0137d79b          	srliw	a5,a5,0x13
    800024ae:	015787bb          	addw	a5,a5,s5
    800024b2:	40d7d79b          	sraiw	a5,a5,0xd
    800024b6:	01cb2583          	lw	a1,28(s6)
    800024ba:	9dbd                	addw	a1,a1,a5
    800024bc:	855e                	mv	a0,s7
    800024be:	cdfff0ef          	jal	8000219c <bread>
    800024c2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024c4:	004b2503          	lw	a0,4(s6)
    800024c8:	000a849b          	sext.w	s1,s5
    800024cc:	8762                	mv	a4,s8
    800024ce:	fca4f1e3          	bgeu	s1,a0,80002490 <balloc+0x90>
      m = 1 << (bi % 8);
    800024d2:	00777693          	andi	a3,a4,7
    800024d6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800024da:	41f7579b          	sraiw	a5,a4,0x1f
    800024de:	01d7d79b          	srliw	a5,a5,0x1d
    800024e2:	9fb9                	addw	a5,a5,a4
    800024e4:	4037d79b          	sraiw	a5,a5,0x3
    800024e8:	00f90633          	add	a2,s2,a5
    800024ec:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800024f0:	00c6f5b3          	and	a1,a3,a2
    800024f4:	d5a1                	beqz	a1,8000243c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024f6:	2705                	addiw	a4,a4,1
    800024f8:	2485                	addiw	s1,s1,1
    800024fa:	fd471ae3          	bne	a4,s4,800024ce <balloc+0xce>
    800024fe:	bf49                	j	80002490 <balloc+0x90>
    80002500:	6906                	ld	s2,64(sp)
    80002502:	79e2                	ld	s3,56(sp)
    80002504:	7a42                	ld	s4,48(sp)
    80002506:	7aa2                	ld	s5,40(sp)
    80002508:	7b02                	ld	s6,32(sp)
    8000250a:	6be2                	ld	s7,24(sp)
    8000250c:	6c42                	ld	s8,16(sp)
    8000250e:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002510:	00005517          	auipc	a0,0x5
    80002514:	fb050513          	addi	a0,a0,-80 # 800074c0 <etext+0x4c0>
    80002518:	699020ef          	jal	800053b0 <printf>
  return 0;
    8000251c:	4481                	li	s1,0
    8000251e:	b79d                	j	80002484 <balloc+0x84>

0000000080002520 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002520:	7179                	addi	sp,sp,-48
    80002522:	f406                	sd	ra,40(sp)
    80002524:	f022                	sd	s0,32(sp)
    80002526:	ec26                	sd	s1,24(sp)
    80002528:	e84a                	sd	s2,16(sp)
    8000252a:	e44e                	sd	s3,8(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002530:	47ad                	li	a5,11
    80002532:	02b7e663          	bltu	a5,a1,8000255e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002536:	02059793          	slli	a5,a1,0x20
    8000253a:	01e7d593          	srli	a1,a5,0x1e
    8000253e:	00b504b3          	add	s1,a0,a1
    80002542:	0504a903          	lw	s2,80(s1)
    80002546:	06091a63          	bnez	s2,800025ba <bmap+0x9a>
      addr = balloc(ip->dev);
    8000254a:	4108                	lw	a0,0(a0)
    8000254c:	eb5ff0ef          	jal	80002400 <balloc>
    80002550:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002554:	06090363          	beqz	s2,800025ba <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002558:	0524a823          	sw	s2,80(s1)
    8000255c:	a8b9                	j	800025ba <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000255e:	ff45849b          	addiw	s1,a1,-12
    80002562:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002566:	0ff00793          	li	a5,255
    8000256a:	06e7ee63          	bltu	a5,a4,800025e6 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000256e:	08052903          	lw	s2,128(a0)
    80002572:	00091d63          	bnez	s2,8000258c <bmap+0x6c>
      addr = balloc(ip->dev);
    80002576:	4108                	lw	a0,0(a0)
    80002578:	e89ff0ef          	jal	80002400 <balloc>
    8000257c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002580:	02090d63          	beqz	s2,800025ba <bmap+0x9a>
    80002584:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002586:	0929a023          	sw	s2,128(s3)
    8000258a:	a011                	j	8000258e <bmap+0x6e>
    8000258c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000258e:	85ca                	mv	a1,s2
    80002590:	0009a503          	lw	a0,0(s3)
    80002594:	c09ff0ef          	jal	8000219c <bread>
    80002598:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000259a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000259e:	02049713          	slli	a4,s1,0x20
    800025a2:	01e75593          	srli	a1,a4,0x1e
    800025a6:	00b784b3          	add	s1,a5,a1
    800025aa:	0004a903          	lw	s2,0(s1)
    800025ae:	00090e63          	beqz	s2,800025ca <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800025b2:	8552                	mv	a0,s4
    800025b4:	cf1ff0ef          	jal	800022a4 <brelse>
    return addr;
    800025b8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800025ba:	854a                	mv	a0,s2
    800025bc:	70a2                	ld	ra,40(sp)
    800025be:	7402                	ld	s0,32(sp)
    800025c0:	64e2                	ld	s1,24(sp)
    800025c2:	6942                	ld	s2,16(sp)
    800025c4:	69a2                	ld	s3,8(sp)
    800025c6:	6145                	addi	sp,sp,48
    800025c8:	8082                	ret
      addr = balloc(ip->dev);
    800025ca:	0009a503          	lw	a0,0(s3)
    800025ce:	e33ff0ef          	jal	80002400 <balloc>
    800025d2:	0005091b          	sext.w	s2,a0
      if(addr){
    800025d6:	fc090ee3          	beqz	s2,800025b2 <bmap+0x92>
        a[bn] = addr;
    800025da:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800025de:	8552                	mv	a0,s4
    800025e0:	50f000ef          	jal	800032ee <log_write>
    800025e4:	b7f9                	j	800025b2 <bmap+0x92>
    800025e6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800025e8:	00005517          	auipc	a0,0x5
    800025ec:	ef050513          	addi	a0,a0,-272 # 800074d8 <etext+0x4d8>
    800025f0:	092030ef          	jal	80005682 <panic>

00000000800025f4 <iget>:
{
    800025f4:	7179                	addi	sp,sp,-48
    800025f6:	f406                	sd	ra,40(sp)
    800025f8:	f022                	sd	s0,32(sp)
    800025fa:	ec26                	sd	s1,24(sp)
    800025fc:	e84a                	sd	s2,16(sp)
    800025fe:	e44e                	sd	s3,8(sp)
    80002600:	e052                	sd	s4,0(sp)
    80002602:	1800                	addi	s0,sp,48
    80002604:	89aa                	mv	s3,a0
    80002606:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002608:	00036517          	auipc	a0,0x36
    8000260c:	2c050513          	addi	a0,a0,704 # 800388c8 <itable>
    80002610:	3a0030ef          	jal	800059b0 <acquire>
  empty = 0;
    80002614:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002616:	00036497          	auipc	s1,0x36
    8000261a:	2ca48493          	addi	s1,s1,714 # 800388e0 <itable+0x18>
    8000261e:	00038697          	auipc	a3,0x38
    80002622:	d5268693          	addi	a3,a3,-686 # 8003a370 <log>
    80002626:	a039                	j	80002634 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002628:	02090963          	beqz	s2,8000265a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000262c:	08848493          	addi	s1,s1,136
    80002630:	02d48863          	beq	s1,a3,80002660 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002634:	449c                	lw	a5,8(s1)
    80002636:	fef059e3          	blez	a5,80002628 <iget+0x34>
    8000263a:	4098                	lw	a4,0(s1)
    8000263c:	ff3716e3          	bne	a4,s3,80002628 <iget+0x34>
    80002640:	40d8                	lw	a4,4(s1)
    80002642:	ff4713e3          	bne	a4,s4,80002628 <iget+0x34>
      ip->ref++;
    80002646:	2785                	addiw	a5,a5,1
    80002648:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000264a:	00036517          	auipc	a0,0x36
    8000264e:	27e50513          	addi	a0,a0,638 # 800388c8 <itable>
    80002652:	3f6030ef          	jal	80005a48 <release>
      return ip;
    80002656:	8926                	mv	s2,s1
    80002658:	a02d                	j	80002682 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000265a:	fbe9                	bnez	a5,8000262c <iget+0x38>
      empty = ip;
    8000265c:	8926                	mv	s2,s1
    8000265e:	b7f9                	j	8000262c <iget+0x38>
  if(empty == 0)
    80002660:	02090a63          	beqz	s2,80002694 <iget+0xa0>
  ip->dev = dev;
    80002664:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002668:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000266c:	4785                	li	a5,1
    8000266e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002672:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002676:	00036517          	auipc	a0,0x36
    8000267a:	25250513          	addi	a0,a0,594 # 800388c8 <itable>
    8000267e:	3ca030ef          	jal	80005a48 <release>
}
    80002682:	854a                	mv	a0,s2
    80002684:	70a2                	ld	ra,40(sp)
    80002686:	7402                	ld	s0,32(sp)
    80002688:	64e2                	ld	s1,24(sp)
    8000268a:	6942                	ld	s2,16(sp)
    8000268c:	69a2                	ld	s3,8(sp)
    8000268e:	6a02                	ld	s4,0(sp)
    80002690:	6145                	addi	sp,sp,48
    80002692:	8082                	ret
    panic("iget: no inodes");
    80002694:	00005517          	auipc	a0,0x5
    80002698:	e5c50513          	addi	a0,a0,-420 # 800074f0 <etext+0x4f0>
    8000269c:	7e7020ef          	jal	80005682 <panic>

00000000800026a0 <fsinit>:
fsinit(int dev) {
    800026a0:	7179                	addi	sp,sp,-48
    800026a2:	f406                	sd	ra,40(sp)
    800026a4:	f022                	sd	s0,32(sp)
    800026a6:	ec26                	sd	s1,24(sp)
    800026a8:	e84a                	sd	s2,16(sp)
    800026aa:	e44e                	sd	s3,8(sp)
    800026ac:	1800                	addi	s0,sp,48
    800026ae:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800026b0:	4585                	li	a1,1
    800026b2:	aebff0ef          	jal	8000219c <bread>
    800026b6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800026b8:	00036997          	auipc	s3,0x36
    800026bc:	1f098993          	addi	s3,s3,496 # 800388a8 <sb>
    800026c0:	02000613          	li	a2,32
    800026c4:	05850593          	addi	a1,a0,88
    800026c8:	854e                	mv	a0,s3
    800026ca:	bd5fd0ef          	jal	8000029e <memmove>
  brelse(bp);
    800026ce:	8526                	mv	a0,s1
    800026d0:	bd5ff0ef          	jal	800022a4 <brelse>
  if(sb.magic != FSMAGIC)
    800026d4:	0009a703          	lw	a4,0(s3)
    800026d8:	102037b7          	lui	a5,0x10203
    800026dc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800026e0:	02f71063          	bne	a4,a5,80002700 <fsinit+0x60>
  initlog(dev, &sb);
    800026e4:	00036597          	auipc	a1,0x36
    800026e8:	1c458593          	addi	a1,a1,452 # 800388a8 <sb>
    800026ec:	854a                	mv	a0,s2
    800026ee:	1f9000ef          	jal	800030e6 <initlog>
}
    800026f2:	70a2                	ld	ra,40(sp)
    800026f4:	7402                	ld	s0,32(sp)
    800026f6:	64e2                	ld	s1,24(sp)
    800026f8:	6942                	ld	s2,16(sp)
    800026fa:	69a2                	ld	s3,8(sp)
    800026fc:	6145                	addi	sp,sp,48
    800026fe:	8082                	ret
    panic("invalid file system");
    80002700:	00005517          	auipc	a0,0x5
    80002704:	e0050513          	addi	a0,a0,-512 # 80007500 <etext+0x500>
    80002708:	77b020ef          	jal	80005682 <panic>

000000008000270c <iinit>:
{
    8000270c:	7179                	addi	sp,sp,-48
    8000270e:	f406                	sd	ra,40(sp)
    80002710:	f022                	sd	s0,32(sp)
    80002712:	ec26                	sd	s1,24(sp)
    80002714:	e84a                	sd	s2,16(sp)
    80002716:	e44e                	sd	s3,8(sp)
    80002718:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000271a:	00005597          	auipc	a1,0x5
    8000271e:	dfe58593          	addi	a1,a1,-514 # 80007518 <etext+0x518>
    80002722:	00036517          	auipc	a0,0x36
    80002726:	1a650513          	addi	a0,a0,422 # 800388c8 <itable>
    8000272a:	206030ef          	jal	80005930 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000272e:	00036497          	auipc	s1,0x36
    80002732:	1c248493          	addi	s1,s1,450 # 800388f0 <itable+0x28>
    80002736:	00038997          	auipc	s3,0x38
    8000273a:	c4a98993          	addi	s3,s3,-950 # 8003a380 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000273e:	00005917          	auipc	s2,0x5
    80002742:	de290913          	addi	s2,s2,-542 # 80007520 <etext+0x520>
    80002746:	85ca                	mv	a1,s2
    80002748:	8526                	mv	a0,s1
    8000274a:	475000ef          	jal	800033be <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000274e:	08848493          	addi	s1,s1,136
    80002752:	ff349ae3          	bne	s1,s3,80002746 <iinit+0x3a>
}
    80002756:	70a2                	ld	ra,40(sp)
    80002758:	7402                	ld	s0,32(sp)
    8000275a:	64e2                	ld	s1,24(sp)
    8000275c:	6942                	ld	s2,16(sp)
    8000275e:	69a2                	ld	s3,8(sp)
    80002760:	6145                	addi	sp,sp,48
    80002762:	8082                	ret

0000000080002764 <ialloc>:
{
    80002764:	7139                	addi	sp,sp,-64
    80002766:	fc06                	sd	ra,56(sp)
    80002768:	f822                	sd	s0,48(sp)
    8000276a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000276c:	00036717          	auipc	a4,0x36
    80002770:	14872703          	lw	a4,328(a4) # 800388b4 <sb+0xc>
    80002774:	4785                	li	a5,1
    80002776:	06e7f063          	bgeu	a5,a4,800027d6 <ialloc+0x72>
    8000277a:	f426                	sd	s1,40(sp)
    8000277c:	f04a                	sd	s2,32(sp)
    8000277e:	ec4e                	sd	s3,24(sp)
    80002780:	e852                	sd	s4,16(sp)
    80002782:	e456                	sd	s5,8(sp)
    80002784:	e05a                	sd	s6,0(sp)
    80002786:	8aaa                	mv	s5,a0
    80002788:	8b2e                	mv	s6,a1
    8000278a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000278c:	00036a17          	auipc	s4,0x36
    80002790:	11ca0a13          	addi	s4,s4,284 # 800388a8 <sb>
    80002794:	00495593          	srli	a1,s2,0x4
    80002798:	018a2783          	lw	a5,24(s4)
    8000279c:	9dbd                	addw	a1,a1,a5
    8000279e:	8556                	mv	a0,s5
    800027a0:	9fdff0ef          	jal	8000219c <bread>
    800027a4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800027a6:	05850993          	addi	s3,a0,88
    800027aa:	00f97793          	andi	a5,s2,15
    800027ae:	079a                	slli	a5,a5,0x6
    800027b0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800027b2:	00099783          	lh	a5,0(s3)
    800027b6:	cb9d                	beqz	a5,800027ec <ialloc+0x88>
    brelse(bp);
    800027b8:	aedff0ef          	jal	800022a4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800027bc:	0905                	addi	s2,s2,1
    800027be:	00ca2703          	lw	a4,12(s4)
    800027c2:	0009079b          	sext.w	a5,s2
    800027c6:	fce7e7e3          	bltu	a5,a4,80002794 <ialloc+0x30>
    800027ca:	74a2                	ld	s1,40(sp)
    800027cc:	7902                	ld	s2,32(sp)
    800027ce:	69e2                	ld	s3,24(sp)
    800027d0:	6a42                	ld	s4,16(sp)
    800027d2:	6aa2                	ld	s5,8(sp)
    800027d4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800027d6:	00005517          	auipc	a0,0x5
    800027da:	d5250513          	addi	a0,a0,-686 # 80007528 <etext+0x528>
    800027de:	3d3020ef          	jal	800053b0 <printf>
  return 0;
    800027e2:	4501                	li	a0,0
}
    800027e4:	70e2                	ld	ra,56(sp)
    800027e6:	7442                	ld	s0,48(sp)
    800027e8:	6121                	addi	sp,sp,64
    800027ea:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027ec:	04000613          	li	a2,64
    800027f0:	4581                	li	a1,0
    800027f2:	854e                	mv	a0,s3
    800027f4:	a4ffd0ef          	jal	80000242 <memset>
      dip->type = type;
    800027f8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027fc:	8526                	mv	a0,s1
    800027fe:	2f1000ef          	jal	800032ee <log_write>
      brelse(bp);
    80002802:	8526                	mv	a0,s1
    80002804:	aa1ff0ef          	jal	800022a4 <brelse>
      return iget(dev, inum);
    80002808:	0009059b          	sext.w	a1,s2
    8000280c:	8556                	mv	a0,s5
    8000280e:	de7ff0ef          	jal	800025f4 <iget>
    80002812:	74a2                	ld	s1,40(sp)
    80002814:	7902                	ld	s2,32(sp)
    80002816:	69e2                	ld	s3,24(sp)
    80002818:	6a42                	ld	s4,16(sp)
    8000281a:	6aa2                	ld	s5,8(sp)
    8000281c:	6b02                	ld	s6,0(sp)
    8000281e:	b7d9                	j	800027e4 <ialloc+0x80>

0000000080002820 <iupdate>:
{
    80002820:	1101                	addi	sp,sp,-32
    80002822:	ec06                	sd	ra,24(sp)
    80002824:	e822                	sd	s0,16(sp)
    80002826:	e426                	sd	s1,8(sp)
    80002828:	e04a                	sd	s2,0(sp)
    8000282a:	1000                	addi	s0,sp,32
    8000282c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000282e:	415c                	lw	a5,4(a0)
    80002830:	0047d79b          	srliw	a5,a5,0x4
    80002834:	00036597          	auipc	a1,0x36
    80002838:	08c5a583          	lw	a1,140(a1) # 800388c0 <sb+0x18>
    8000283c:	9dbd                	addw	a1,a1,a5
    8000283e:	4108                	lw	a0,0(a0)
    80002840:	95dff0ef          	jal	8000219c <bread>
    80002844:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002846:	05850793          	addi	a5,a0,88
    8000284a:	40d8                	lw	a4,4(s1)
    8000284c:	8b3d                	andi	a4,a4,15
    8000284e:	071a                	slli	a4,a4,0x6
    80002850:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002852:	04449703          	lh	a4,68(s1)
    80002856:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000285a:	04649703          	lh	a4,70(s1)
    8000285e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002862:	04849703          	lh	a4,72(s1)
    80002866:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000286a:	04a49703          	lh	a4,74(s1)
    8000286e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002872:	44f8                	lw	a4,76(s1)
    80002874:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002876:	03400613          	li	a2,52
    8000287a:	05048593          	addi	a1,s1,80
    8000287e:	00c78513          	addi	a0,a5,12
    80002882:	a1dfd0ef          	jal	8000029e <memmove>
  log_write(bp);
    80002886:	854a                	mv	a0,s2
    80002888:	267000ef          	jal	800032ee <log_write>
  brelse(bp);
    8000288c:	854a                	mv	a0,s2
    8000288e:	a17ff0ef          	jal	800022a4 <brelse>
}
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6902                	ld	s2,0(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret

000000008000289e <idup>:
{
    8000289e:	1101                	addi	sp,sp,-32
    800028a0:	ec06                	sd	ra,24(sp)
    800028a2:	e822                	sd	s0,16(sp)
    800028a4:	e426                	sd	s1,8(sp)
    800028a6:	1000                	addi	s0,sp,32
    800028a8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800028aa:	00036517          	auipc	a0,0x36
    800028ae:	01e50513          	addi	a0,a0,30 # 800388c8 <itable>
    800028b2:	0fe030ef          	jal	800059b0 <acquire>
  ip->ref++;
    800028b6:	449c                	lw	a5,8(s1)
    800028b8:	2785                	addiw	a5,a5,1
    800028ba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028bc:	00036517          	auipc	a0,0x36
    800028c0:	00c50513          	addi	a0,a0,12 # 800388c8 <itable>
    800028c4:	184030ef          	jal	80005a48 <release>
}
    800028c8:	8526                	mv	a0,s1
    800028ca:	60e2                	ld	ra,24(sp)
    800028cc:	6442                	ld	s0,16(sp)
    800028ce:	64a2                	ld	s1,8(sp)
    800028d0:	6105                	addi	sp,sp,32
    800028d2:	8082                	ret

00000000800028d4 <ilock>:
{
    800028d4:	1101                	addi	sp,sp,-32
    800028d6:	ec06                	sd	ra,24(sp)
    800028d8:	e822                	sd	s0,16(sp)
    800028da:	e426                	sd	s1,8(sp)
    800028dc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028de:	cd19                	beqz	a0,800028fc <ilock+0x28>
    800028e0:	84aa                	mv	s1,a0
    800028e2:	451c                	lw	a5,8(a0)
    800028e4:	00f05c63          	blez	a5,800028fc <ilock+0x28>
  acquiresleep(&ip->lock);
    800028e8:	0541                	addi	a0,a0,16
    800028ea:	30b000ef          	jal	800033f4 <acquiresleep>
  if(ip->valid == 0){
    800028ee:	40bc                	lw	a5,64(s1)
    800028f0:	cf89                	beqz	a5,8000290a <ilock+0x36>
}
    800028f2:	60e2                	ld	ra,24(sp)
    800028f4:	6442                	ld	s0,16(sp)
    800028f6:	64a2                	ld	s1,8(sp)
    800028f8:	6105                	addi	sp,sp,32
    800028fa:	8082                	ret
    800028fc:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800028fe:	00005517          	auipc	a0,0x5
    80002902:	c4250513          	addi	a0,a0,-958 # 80007540 <etext+0x540>
    80002906:	57d020ef          	jal	80005682 <panic>
    8000290a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000290c:	40dc                	lw	a5,4(s1)
    8000290e:	0047d79b          	srliw	a5,a5,0x4
    80002912:	00036597          	auipc	a1,0x36
    80002916:	fae5a583          	lw	a1,-82(a1) # 800388c0 <sb+0x18>
    8000291a:	9dbd                	addw	a1,a1,a5
    8000291c:	4088                	lw	a0,0(s1)
    8000291e:	87fff0ef          	jal	8000219c <bread>
    80002922:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002924:	05850593          	addi	a1,a0,88
    80002928:	40dc                	lw	a5,4(s1)
    8000292a:	8bbd                	andi	a5,a5,15
    8000292c:	079a                	slli	a5,a5,0x6
    8000292e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002930:	00059783          	lh	a5,0(a1)
    80002934:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002938:	00259783          	lh	a5,2(a1)
    8000293c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002940:	00459783          	lh	a5,4(a1)
    80002944:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002948:	00659783          	lh	a5,6(a1)
    8000294c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002950:	459c                	lw	a5,8(a1)
    80002952:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002954:	03400613          	li	a2,52
    80002958:	05b1                	addi	a1,a1,12
    8000295a:	05048513          	addi	a0,s1,80
    8000295e:	941fd0ef          	jal	8000029e <memmove>
    brelse(bp);
    80002962:	854a                	mv	a0,s2
    80002964:	941ff0ef          	jal	800022a4 <brelse>
    ip->valid = 1;
    80002968:	4785                	li	a5,1
    8000296a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000296c:	04449783          	lh	a5,68(s1)
    80002970:	c399                	beqz	a5,80002976 <ilock+0xa2>
    80002972:	6902                	ld	s2,0(sp)
    80002974:	bfbd                	j	800028f2 <ilock+0x1e>
      panic("ilock: no type");
    80002976:	00005517          	auipc	a0,0x5
    8000297a:	bd250513          	addi	a0,a0,-1070 # 80007548 <etext+0x548>
    8000297e:	505020ef          	jal	80005682 <panic>

0000000080002982 <iunlock>:
{
    80002982:	1101                	addi	sp,sp,-32
    80002984:	ec06                	sd	ra,24(sp)
    80002986:	e822                	sd	s0,16(sp)
    80002988:	e426                	sd	s1,8(sp)
    8000298a:	e04a                	sd	s2,0(sp)
    8000298c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000298e:	c505                	beqz	a0,800029b6 <iunlock+0x34>
    80002990:	84aa                	mv	s1,a0
    80002992:	01050913          	addi	s2,a0,16
    80002996:	854a                	mv	a0,s2
    80002998:	2db000ef          	jal	80003472 <holdingsleep>
    8000299c:	cd09                	beqz	a0,800029b6 <iunlock+0x34>
    8000299e:	449c                	lw	a5,8(s1)
    800029a0:	00f05b63          	blez	a5,800029b6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800029a4:	854a                	mv	a0,s2
    800029a6:	295000ef          	jal	8000343a <releasesleep>
}
    800029aa:	60e2                	ld	ra,24(sp)
    800029ac:	6442                	ld	s0,16(sp)
    800029ae:	64a2                	ld	s1,8(sp)
    800029b0:	6902                	ld	s2,0(sp)
    800029b2:	6105                	addi	sp,sp,32
    800029b4:	8082                	ret
    panic("iunlock");
    800029b6:	00005517          	auipc	a0,0x5
    800029ba:	ba250513          	addi	a0,a0,-1118 # 80007558 <etext+0x558>
    800029be:	4c5020ef          	jal	80005682 <panic>

00000000800029c2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800029c2:	7179                	addi	sp,sp,-48
    800029c4:	f406                	sd	ra,40(sp)
    800029c6:	f022                	sd	s0,32(sp)
    800029c8:	ec26                	sd	s1,24(sp)
    800029ca:	e84a                	sd	s2,16(sp)
    800029cc:	e44e                	sd	s3,8(sp)
    800029ce:	1800                	addi	s0,sp,48
    800029d0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029d2:	05050493          	addi	s1,a0,80
    800029d6:	08050913          	addi	s2,a0,128
    800029da:	a021                	j	800029e2 <itrunc+0x20>
    800029dc:	0491                	addi	s1,s1,4
    800029de:	01248b63          	beq	s1,s2,800029f4 <itrunc+0x32>
    if(ip->addrs[i]){
    800029e2:	408c                	lw	a1,0(s1)
    800029e4:	dde5                	beqz	a1,800029dc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800029e6:	0009a503          	lw	a0,0(s3)
    800029ea:	9abff0ef          	jal	80002394 <bfree>
      ip->addrs[i] = 0;
    800029ee:	0004a023          	sw	zero,0(s1)
    800029f2:	b7ed                	j	800029dc <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029f4:	0809a583          	lw	a1,128(s3)
    800029f8:	ed89                	bnez	a1,80002a12 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029fa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029fe:	854e                	mv	a0,s3
    80002a00:	e21ff0ef          	jal	80002820 <iupdate>
}
    80002a04:	70a2                	ld	ra,40(sp)
    80002a06:	7402                	ld	s0,32(sp)
    80002a08:	64e2                	ld	s1,24(sp)
    80002a0a:	6942                	ld	s2,16(sp)
    80002a0c:	69a2                	ld	s3,8(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    80002a12:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002a14:	0009a503          	lw	a0,0(s3)
    80002a18:	f84ff0ef          	jal	8000219c <bread>
    80002a1c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002a1e:	05850493          	addi	s1,a0,88
    80002a22:	45850913          	addi	s2,a0,1112
    80002a26:	a021                	j	80002a2e <itrunc+0x6c>
    80002a28:	0491                	addi	s1,s1,4
    80002a2a:	01248963          	beq	s1,s2,80002a3c <itrunc+0x7a>
      if(a[j])
    80002a2e:	408c                	lw	a1,0(s1)
    80002a30:	dde5                	beqz	a1,80002a28 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002a32:	0009a503          	lw	a0,0(s3)
    80002a36:	95fff0ef          	jal	80002394 <bfree>
    80002a3a:	b7fd                	j	80002a28 <itrunc+0x66>
    brelse(bp);
    80002a3c:	8552                	mv	a0,s4
    80002a3e:	867ff0ef          	jal	800022a4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a42:	0809a583          	lw	a1,128(s3)
    80002a46:	0009a503          	lw	a0,0(s3)
    80002a4a:	94bff0ef          	jal	80002394 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a4e:	0809a023          	sw	zero,128(s3)
    80002a52:	6a02                	ld	s4,0(sp)
    80002a54:	b75d                	j	800029fa <itrunc+0x38>

0000000080002a56 <iput>:
{
    80002a56:	1101                	addi	sp,sp,-32
    80002a58:	ec06                	sd	ra,24(sp)
    80002a5a:	e822                	sd	s0,16(sp)
    80002a5c:	e426                	sd	s1,8(sp)
    80002a5e:	1000                	addi	s0,sp,32
    80002a60:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a62:	00036517          	auipc	a0,0x36
    80002a66:	e6650513          	addi	a0,a0,-410 # 800388c8 <itable>
    80002a6a:	747020ef          	jal	800059b0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a6e:	4498                	lw	a4,8(s1)
    80002a70:	4785                	li	a5,1
    80002a72:	02f70063          	beq	a4,a5,80002a92 <iput+0x3c>
  ip->ref--;
    80002a76:	449c                	lw	a5,8(s1)
    80002a78:	37fd                	addiw	a5,a5,-1
    80002a7a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a7c:	00036517          	auipc	a0,0x36
    80002a80:	e4c50513          	addi	a0,a0,-436 # 800388c8 <itable>
    80002a84:	7c5020ef          	jal	80005a48 <release>
}
    80002a88:	60e2                	ld	ra,24(sp)
    80002a8a:	6442                	ld	s0,16(sp)
    80002a8c:	64a2                	ld	s1,8(sp)
    80002a8e:	6105                	addi	sp,sp,32
    80002a90:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a92:	40bc                	lw	a5,64(s1)
    80002a94:	d3ed                	beqz	a5,80002a76 <iput+0x20>
    80002a96:	04a49783          	lh	a5,74(s1)
    80002a9a:	fff1                	bnez	a5,80002a76 <iput+0x20>
    80002a9c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002a9e:	01048913          	addi	s2,s1,16
    80002aa2:	854a                	mv	a0,s2
    80002aa4:	151000ef          	jal	800033f4 <acquiresleep>
    release(&itable.lock);
    80002aa8:	00036517          	auipc	a0,0x36
    80002aac:	e2050513          	addi	a0,a0,-480 # 800388c8 <itable>
    80002ab0:	799020ef          	jal	80005a48 <release>
    itrunc(ip);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	f0dff0ef          	jal	800029c2 <itrunc>
    ip->type = 0;
    80002aba:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002abe:	8526                	mv	a0,s1
    80002ac0:	d61ff0ef          	jal	80002820 <iupdate>
    ip->valid = 0;
    80002ac4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002ac8:	854a                	mv	a0,s2
    80002aca:	171000ef          	jal	8000343a <releasesleep>
    acquire(&itable.lock);
    80002ace:	00036517          	auipc	a0,0x36
    80002ad2:	dfa50513          	addi	a0,a0,-518 # 800388c8 <itable>
    80002ad6:	6db020ef          	jal	800059b0 <acquire>
    80002ada:	6902                	ld	s2,0(sp)
    80002adc:	bf69                	j	80002a76 <iput+0x20>

0000000080002ade <iunlockput>:
{
    80002ade:	1101                	addi	sp,sp,-32
    80002ae0:	ec06                	sd	ra,24(sp)
    80002ae2:	e822                	sd	s0,16(sp)
    80002ae4:	e426                	sd	s1,8(sp)
    80002ae6:	1000                	addi	s0,sp,32
    80002ae8:	84aa                	mv	s1,a0
  iunlock(ip);
    80002aea:	e99ff0ef          	jal	80002982 <iunlock>
  iput(ip);
    80002aee:	8526                	mv	a0,s1
    80002af0:	f67ff0ef          	jal	80002a56 <iput>
}
    80002af4:	60e2                	ld	ra,24(sp)
    80002af6:	6442                	ld	s0,16(sp)
    80002af8:	64a2                	ld	s1,8(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret

0000000080002afe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002afe:	1141                	addi	sp,sp,-16
    80002b00:	e422                	sd	s0,8(sp)
    80002b02:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002b04:	411c                	lw	a5,0(a0)
    80002b06:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002b08:	415c                	lw	a5,4(a0)
    80002b0a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002b0c:	04451783          	lh	a5,68(a0)
    80002b10:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002b14:	04a51783          	lh	a5,74(a0)
    80002b18:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002b1c:	04c56783          	lwu	a5,76(a0)
    80002b20:	e99c                	sd	a5,16(a1)
}
    80002b22:	6422                	ld	s0,8(sp)
    80002b24:	0141                	addi	sp,sp,16
    80002b26:	8082                	ret

0000000080002b28 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b28:	457c                	lw	a5,76(a0)
    80002b2a:	0ed7eb63          	bltu	a5,a3,80002c20 <readi+0xf8>
{
    80002b2e:	7159                	addi	sp,sp,-112
    80002b30:	f486                	sd	ra,104(sp)
    80002b32:	f0a2                	sd	s0,96(sp)
    80002b34:	eca6                	sd	s1,88(sp)
    80002b36:	e0d2                	sd	s4,64(sp)
    80002b38:	fc56                	sd	s5,56(sp)
    80002b3a:	f85a                	sd	s6,48(sp)
    80002b3c:	f45e                	sd	s7,40(sp)
    80002b3e:	1880                	addi	s0,sp,112
    80002b40:	8b2a                	mv	s6,a0
    80002b42:	8bae                	mv	s7,a1
    80002b44:	8a32                	mv	s4,a2
    80002b46:	84b6                	mv	s1,a3
    80002b48:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002b4a:	9f35                	addw	a4,a4,a3
    return 0;
    80002b4c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002b4e:	0cd76063          	bltu	a4,a3,80002c0e <readi+0xe6>
    80002b52:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002b54:	00e7f463          	bgeu	a5,a4,80002b5c <readi+0x34>
    n = ip->size - off;
    80002b58:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b5c:	080a8f63          	beqz	s5,80002bfa <readi+0xd2>
    80002b60:	e8ca                	sd	s2,80(sp)
    80002b62:	f062                	sd	s8,32(sp)
    80002b64:	ec66                	sd	s9,24(sp)
    80002b66:	e86a                	sd	s10,16(sp)
    80002b68:	e46e                	sd	s11,8(sp)
    80002b6a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b6c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002b70:	5c7d                	li	s8,-1
    80002b72:	a80d                	j	80002ba4 <readi+0x7c>
    80002b74:	020d1d93          	slli	s11,s10,0x20
    80002b78:	020ddd93          	srli	s11,s11,0x20
    80002b7c:	05890613          	addi	a2,s2,88
    80002b80:	86ee                	mv	a3,s11
    80002b82:	963a                	add	a2,a2,a4
    80002b84:	85d2                	mv	a1,s4
    80002b86:	855e                	mv	a0,s7
    80002b88:	cc3fe0ef          	jal	8000184a <either_copyout>
    80002b8c:	05850763          	beq	a0,s8,80002bda <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002b90:	854a                	mv	a0,s2
    80002b92:	f12ff0ef          	jal	800022a4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b96:	013d09bb          	addw	s3,s10,s3
    80002b9a:	009d04bb          	addw	s1,s10,s1
    80002b9e:	9a6e                	add	s4,s4,s11
    80002ba0:	0559f763          	bgeu	s3,s5,80002bee <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002ba4:	00a4d59b          	srliw	a1,s1,0xa
    80002ba8:	855a                	mv	a0,s6
    80002baa:	977ff0ef          	jal	80002520 <bmap>
    80002bae:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002bb2:	c5b1                	beqz	a1,80002bfe <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002bb4:	000b2503          	lw	a0,0(s6)
    80002bb8:	de4ff0ef          	jal	8000219c <bread>
    80002bbc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002bbe:	3ff4f713          	andi	a4,s1,1023
    80002bc2:	40ec87bb          	subw	a5,s9,a4
    80002bc6:	413a86bb          	subw	a3,s5,s3
    80002bca:	8d3e                	mv	s10,a5
    80002bcc:	2781                	sext.w	a5,a5
    80002bce:	0006861b          	sext.w	a2,a3
    80002bd2:	faf671e3          	bgeu	a2,a5,80002b74 <readi+0x4c>
    80002bd6:	8d36                	mv	s10,a3
    80002bd8:	bf71                	j	80002b74 <readi+0x4c>
      brelse(bp);
    80002bda:	854a                	mv	a0,s2
    80002bdc:	ec8ff0ef          	jal	800022a4 <brelse>
      tot = -1;
    80002be0:	59fd                	li	s3,-1
      break;
    80002be2:	6946                	ld	s2,80(sp)
    80002be4:	7c02                	ld	s8,32(sp)
    80002be6:	6ce2                	ld	s9,24(sp)
    80002be8:	6d42                	ld	s10,16(sp)
    80002bea:	6da2                	ld	s11,8(sp)
    80002bec:	a831                	j	80002c08 <readi+0xe0>
    80002bee:	6946                	ld	s2,80(sp)
    80002bf0:	7c02                	ld	s8,32(sp)
    80002bf2:	6ce2                	ld	s9,24(sp)
    80002bf4:	6d42                	ld	s10,16(sp)
    80002bf6:	6da2                	ld	s11,8(sp)
    80002bf8:	a801                	j	80002c08 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002bfa:	89d6                	mv	s3,s5
    80002bfc:	a031                	j	80002c08 <readi+0xe0>
    80002bfe:	6946                	ld	s2,80(sp)
    80002c00:	7c02                	ld	s8,32(sp)
    80002c02:	6ce2                	ld	s9,24(sp)
    80002c04:	6d42                	ld	s10,16(sp)
    80002c06:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002c08:	0009851b          	sext.w	a0,s3
    80002c0c:	69a6                	ld	s3,72(sp)
}
    80002c0e:	70a6                	ld	ra,104(sp)
    80002c10:	7406                	ld	s0,96(sp)
    80002c12:	64e6                	ld	s1,88(sp)
    80002c14:	6a06                	ld	s4,64(sp)
    80002c16:	7ae2                	ld	s5,56(sp)
    80002c18:	7b42                	ld	s6,48(sp)
    80002c1a:	7ba2                	ld	s7,40(sp)
    80002c1c:	6165                	addi	sp,sp,112
    80002c1e:	8082                	ret
    return 0;
    80002c20:	4501                	li	a0,0
}
    80002c22:	8082                	ret

0000000080002c24 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c24:	457c                	lw	a5,76(a0)
    80002c26:	10d7e063          	bltu	a5,a3,80002d26 <writei+0x102>
{
    80002c2a:	7159                	addi	sp,sp,-112
    80002c2c:	f486                	sd	ra,104(sp)
    80002c2e:	f0a2                	sd	s0,96(sp)
    80002c30:	e8ca                	sd	s2,80(sp)
    80002c32:	e0d2                	sd	s4,64(sp)
    80002c34:	fc56                	sd	s5,56(sp)
    80002c36:	f85a                	sd	s6,48(sp)
    80002c38:	f45e                	sd	s7,40(sp)
    80002c3a:	1880                	addi	s0,sp,112
    80002c3c:	8aaa                	mv	s5,a0
    80002c3e:	8bae                	mv	s7,a1
    80002c40:	8a32                	mv	s4,a2
    80002c42:	8936                	mv	s2,a3
    80002c44:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002c46:	00e687bb          	addw	a5,a3,a4
    80002c4a:	0ed7e063          	bltu	a5,a3,80002d2a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002c4e:	00043737          	lui	a4,0x43
    80002c52:	0cf76e63          	bltu	a4,a5,80002d2e <writei+0x10a>
    80002c56:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c58:	0a0b0f63          	beqz	s6,80002d16 <writei+0xf2>
    80002c5c:	eca6                	sd	s1,88(sp)
    80002c5e:	f062                	sd	s8,32(sp)
    80002c60:	ec66                	sd	s9,24(sp)
    80002c62:	e86a                	sd	s10,16(sp)
    80002c64:	e46e                	sd	s11,8(sp)
    80002c66:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c68:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002c6c:	5c7d                	li	s8,-1
    80002c6e:	a825                	j	80002ca6 <writei+0x82>
    80002c70:	020d1d93          	slli	s11,s10,0x20
    80002c74:	020ddd93          	srli	s11,s11,0x20
    80002c78:	05848513          	addi	a0,s1,88
    80002c7c:	86ee                	mv	a3,s11
    80002c7e:	8652                	mv	a2,s4
    80002c80:	85de                	mv	a1,s7
    80002c82:	953a                	add	a0,a0,a4
    80002c84:	c11fe0ef          	jal	80001894 <either_copyin>
    80002c88:	05850a63          	beq	a0,s8,80002cdc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002c8c:	8526                	mv	a0,s1
    80002c8e:	660000ef          	jal	800032ee <log_write>
    brelse(bp);
    80002c92:	8526                	mv	a0,s1
    80002c94:	e10ff0ef          	jal	800022a4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c98:	013d09bb          	addw	s3,s10,s3
    80002c9c:	012d093b          	addw	s2,s10,s2
    80002ca0:	9a6e                	add	s4,s4,s11
    80002ca2:	0569f063          	bgeu	s3,s6,80002ce2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002ca6:	00a9559b          	srliw	a1,s2,0xa
    80002caa:	8556                	mv	a0,s5
    80002cac:	875ff0ef          	jal	80002520 <bmap>
    80002cb0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002cb4:	c59d                	beqz	a1,80002ce2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002cb6:	000aa503          	lw	a0,0(s5)
    80002cba:	ce2ff0ef          	jal	8000219c <bread>
    80002cbe:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cc0:	3ff97713          	andi	a4,s2,1023
    80002cc4:	40ec87bb          	subw	a5,s9,a4
    80002cc8:	413b06bb          	subw	a3,s6,s3
    80002ccc:	8d3e                	mv	s10,a5
    80002cce:	2781                	sext.w	a5,a5
    80002cd0:	0006861b          	sext.w	a2,a3
    80002cd4:	f8f67ee3          	bgeu	a2,a5,80002c70 <writei+0x4c>
    80002cd8:	8d36                	mv	s10,a3
    80002cda:	bf59                	j	80002c70 <writei+0x4c>
      brelse(bp);
    80002cdc:	8526                	mv	a0,s1
    80002cde:	dc6ff0ef          	jal	800022a4 <brelse>
  }

  if(off > ip->size)
    80002ce2:	04caa783          	lw	a5,76(s5)
    80002ce6:	0327fa63          	bgeu	a5,s2,80002d1a <writei+0xf6>
    ip->size = off;
    80002cea:	052aa623          	sw	s2,76(s5)
    80002cee:	64e6                	ld	s1,88(sp)
    80002cf0:	7c02                	ld	s8,32(sp)
    80002cf2:	6ce2                	ld	s9,24(sp)
    80002cf4:	6d42                	ld	s10,16(sp)
    80002cf6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002cf8:	8556                	mv	a0,s5
    80002cfa:	b27ff0ef          	jal	80002820 <iupdate>

  return tot;
    80002cfe:	0009851b          	sext.w	a0,s3
    80002d02:	69a6                	ld	s3,72(sp)
}
    80002d04:	70a6                	ld	ra,104(sp)
    80002d06:	7406                	ld	s0,96(sp)
    80002d08:	6946                	ld	s2,80(sp)
    80002d0a:	6a06                	ld	s4,64(sp)
    80002d0c:	7ae2                	ld	s5,56(sp)
    80002d0e:	7b42                	ld	s6,48(sp)
    80002d10:	7ba2                	ld	s7,40(sp)
    80002d12:	6165                	addi	sp,sp,112
    80002d14:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d16:	89da                	mv	s3,s6
    80002d18:	b7c5                	j	80002cf8 <writei+0xd4>
    80002d1a:	64e6                	ld	s1,88(sp)
    80002d1c:	7c02                	ld	s8,32(sp)
    80002d1e:	6ce2                	ld	s9,24(sp)
    80002d20:	6d42                	ld	s10,16(sp)
    80002d22:	6da2                	ld	s11,8(sp)
    80002d24:	bfd1                	j	80002cf8 <writei+0xd4>
    return -1;
    80002d26:	557d                	li	a0,-1
}
    80002d28:	8082                	ret
    return -1;
    80002d2a:	557d                	li	a0,-1
    80002d2c:	bfe1                	j	80002d04 <writei+0xe0>
    return -1;
    80002d2e:	557d                	li	a0,-1
    80002d30:	bfd1                	j	80002d04 <writei+0xe0>

0000000080002d32 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002d32:	1141                	addi	sp,sp,-16
    80002d34:	e406                	sd	ra,8(sp)
    80002d36:	e022                	sd	s0,0(sp)
    80002d38:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002d3a:	4639                	li	a2,14
    80002d3c:	dd2fd0ef          	jal	8000030e <strncmp>
}
    80002d40:	60a2                	ld	ra,8(sp)
    80002d42:	6402                	ld	s0,0(sp)
    80002d44:	0141                	addi	sp,sp,16
    80002d46:	8082                	ret

0000000080002d48 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002d48:	7139                	addi	sp,sp,-64
    80002d4a:	fc06                	sd	ra,56(sp)
    80002d4c:	f822                	sd	s0,48(sp)
    80002d4e:	f426                	sd	s1,40(sp)
    80002d50:	f04a                	sd	s2,32(sp)
    80002d52:	ec4e                	sd	s3,24(sp)
    80002d54:	e852                	sd	s4,16(sp)
    80002d56:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002d58:	04451703          	lh	a4,68(a0)
    80002d5c:	4785                	li	a5,1
    80002d5e:	00f71a63          	bne	a4,a5,80002d72 <dirlookup+0x2a>
    80002d62:	892a                	mv	s2,a0
    80002d64:	89ae                	mv	s3,a1
    80002d66:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d68:	457c                	lw	a5,76(a0)
    80002d6a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002d6c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d6e:	e39d                	bnez	a5,80002d94 <dirlookup+0x4c>
    80002d70:	a095                	j	80002dd4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002d72:	00004517          	auipc	a0,0x4
    80002d76:	7ee50513          	addi	a0,a0,2030 # 80007560 <etext+0x560>
    80002d7a:	109020ef          	jal	80005682 <panic>
      panic("dirlookup read");
    80002d7e:	00004517          	auipc	a0,0x4
    80002d82:	7fa50513          	addi	a0,a0,2042 # 80007578 <etext+0x578>
    80002d86:	0fd020ef          	jal	80005682 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d8a:	24c1                	addiw	s1,s1,16
    80002d8c:	04c92783          	lw	a5,76(s2)
    80002d90:	04f4f163          	bgeu	s1,a5,80002dd2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d94:	4741                	li	a4,16
    80002d96:	86a6                	mv	a3,s1
    80002d98:	fc040613          	addi	a2,s0,-64
    80002d9c:	4581                	li	a1,0
    80002d9e:	854a                	mv	a0,s2
    80002da0:	d89ff0ef          	jal	80002b28 <readi>
    80002da4:	47c1                	li	a5,16
    80002da6:	fcf51ce3          	bne	a0,a5,80002d7e <dirlookup+0x36>
    if(de.inum == 0)
    80002daa:	fc045783          	lhu	a5,-64(s0)
    80002dae:	dff1                	beqz	a5,80002d8a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002db0:	fc240593          	addi	a1,s0,-62
    80002db4:	854e                	mv	a0,s3
    80002db6:	f7dff0ef          	jal	80002d32 <namecmp>
    80002dba:	f961                	bnez	a0,80002d8a <dirlookup+0x42>
      if(poff)
    80002dbc:	000a0463          	beqz	s4,80002dc4 <dirlookup+0x7c>
        *poff = off;
    80002dc0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002dc4:	fc045583          	lhu	a1,-64(s0)
    80002dc8:	00092503          	lw	a0,0(s2)
    80002dcc:	829ff0ef          	jal	800025f4 <iget>
    80002dd0:	a011                	j	80002dd4 <dirlookup+0x8c>
  return 0;
    80002dd2:	4501                	li	a0,0
}
    80002dd4:	70e2                	ld	ra,56(sp)
    80002dd6:	7442                	ld	s0,48(sp)
    80002dd8:	74a2                	ld	s1,40(sp)
    80002dda:	7902                	ld	s2,32(sp)
    80002ddc:	69e2                	ld	s3,24(sp)
    80002dde:	6a42                	ld	s4,16(sp)
    80002de0:	6121                	addi	sp,sp,64
    80002de2:	8082                	ret

0000000080002de4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002de4:	711d                	addi	sp,sp,-96
    80002de6:	ec86                	sd	ra,88(sp)
    80002de8:	e8a2                	sd	s0,80(sp)
    80002dea:	e4a6                	sd	s1,72(sp)
    80002dec:	e0ca                	sd	s2,64(sp)
    80002dee:	fc4e                	sd	s3,56(sp)
    80002df0:	f852                	sd	s4,48(sp)
    80002df2:	f456                	sd	s5,40(sp)
    80002df4:	f05a                	sd	s6,32(sp)
    80002df6:	ec5e                	sd	s7,24(sp)
    80002df8:	e862                	sd	s8,16(sp)
    80002dfa:	e466                	sd	s9,8(sp)
    80002dfc:	1080                	addi	s0,sp,96
    80002dfe:	84aa                	mv	s1,a0
    80002e00:	8b2e                	mv	s6,a1
    80002e02:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002e04:	00054703          	lbu	a4,0(a0)
    80002e08:	02f00793          	li	a5,47
    80002e0c:	00f70e63          	beq	a4,a5,80002e28 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002e10:	910fe0ef          	jal	80000f20 <myproc>
    80002e14:	15053503          	ld	a0,336(a0)
    80002e18:	a87ff0ef          	jal	8000289e <idup>
    80002e1c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002e1e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002e22:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002e24:	4b85                	li	s7,1
    80002e26:	a871                	j	80002ec2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002e28:	4585                	li	a1,1
    80002e2a:	4505                	li	a0,1
    80002e2c:	fc8ff0ef          	jal	800025f4 <iget>
    80002e30:	8a2a                	mv	s4,a0
    80002e32:	b7f5                	j	80002e1e <namex+0x3a>
      iunlockput(ip);
    80002e34:	8552                	mv	a0,s4
    80002e36:	ca9ff0ef          	jal	80002ade <iunlockput>
      return 0;
    80002e3a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002e3c:	8552                	mv	a0,s4
    80002e3e:	60e6                	ld	ra,88(sp)
    80002e40:	6446                	ld	s0,80(sp)
    80002e42:	64a6                	ld	s1,72(sp)
    80002e44:	6906                	ld	s2,64(sp)
    80002e46:	79e2                	ld	s3,56(sp)
    80002e48:	7a42                	ld	s4,48(sp)
    80002e4a:	7aa2                	ld	s5,40(sp)
    80002e4c:	7b02                	ld	s6,32(sp)
    80002e4e:	6be2                	ld	s7,24(sp)
    80002e50:	6c42                	ld	s8,16(sp)
    80002e52:	6ca2                	ld	s9,8(sp)
    80002e54:	6125                	addi	sp,sp,96
    80002e56:	8082                	ret
      iunlock(ip);
    80002e58:	8552                	mv	a0,s4
    80002e5a:	b29ff0ef          	jal	80002982 <iunlock>
      return ip;
    80002e5e:	bff9                	j	80002e3c <namex+0x58>
      iunlockput(ip);
    80002e60:	8552                	mv	a0,s4
    80002e62:	c7dff0ef          	jal	80002ade <iunlockput>
      return 0;
    80002e66:	8a4e                	mv	s4,s3
    80002e68:	bfd1                	j	80002e3c <namex+0x58>
  len = path - s;
    80002e6a:	40998633          	sub	a2,s3,s1
    80002e6e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002e72:	099c5063          	bge	s8,s9,80002ef2 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002e76:	4639                	li	a2,14
    80002e78:	85a6                	mv	a1,s1
    80002e7a:	8556                	mv	a0,s5
    80002e7c:	c22fd0ef          	jal	8000029e <memmove>
    80002e80:	84ce                	mv	s1,s3
  while(*path == '/')
    80002e82:	0004c783          	lbu	a5,0(s1)
    80002e86:	01279763          	bne	a5,s2,80002e94 <namex+0xb0>
    path++;
    80002e8a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e8c:	0004c783          	lbu	a5,0(s1)
    80002e90:	ff278de3          	beq	a5,s2,80002e8a <namex+0xa6>
    ilock(ip);
    80002e94:	8552                	mv	a0,s4
    80002e96:	a3fff0ef          	jal	800028d4 <ilock>
    if(ip->type != T_DIR){
    80002e9a:	044a1783          	lh	a5,68(s4)
    80002e9e:	f9779be3          	bne	a5,s7,80002e34 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002ea2:	000b0563          	beqz	s6,80002eac <namex+0xc8>
    80002ea6:	0004c783          	lbu	a5,0(s1)
    80002eaa:	d7dd                	beqz	a5,80002e58 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002eac:	4601                	li	a2,0
    80002eae:	85d6                	mv	a1,s5
    80002eb0:	8552                	mv	a0,s4
    80002eb2:	e97ff0ef          	jal	80002d48 <dirlookup>
    80002eb6:	89aa                	mv	s3,a0
    80002eb8:	d545                	beqz	a0,80002e60 <namex+0x7c>
    iunlockput(ip);
    80002eba:	8552                	mv	a0,s4
    80002ebc:	c23ff0ef          	jal	80002ade <iunlockput>
    ip = next;
    80002ec0:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002ec2:	0004c783          	lbu	a5,0(s1)
    80002ec6:	01279763          	bne	a5,s2,80002ed4 <namex+0xf0>
    path++;
    80002eca:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002ecc:	0004c783          	lbu	a5,0(s1)
    80002ed0:	ff278de3          	beq	a5,s2,80002eca <namex+0xe6>
  if(*path == 0)
    80002ed4:	cb8d                	beqz	a5,80002f06 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002ed6:	0004c783          	lbu	a5,0(s1)
    80002eda:	89a6                	mv	s3,s1
  len = path - s;
    80002edc:	4c81                	li	s9,0
    80002ede:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002ee0:	01278963          	beq	a5,s2,80002ef2 <namex+0x10e>
    80002ee4:	d3d9                	beqz	a5,80002e6a <namex+0x86>
    path++;
    80002ee6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002ee8:	0009c783          	lbu	a5,0(s3)
    80002eec:	ff279ce3          	bne	a5,s2,80002ee4 <namex+0x100>
    80002ef0:	bfad                	j	80002e6a <namex+0x86>
    memmove(name, s, len);
    80002ef2:	2601                	sext.w	a2,a2
    80002ef4:	85a6                	mv	a1,s1
    80002ef6:	8556                	mv	a0,s5
    80002ef8:	ba6fd0ef          	jal	8000029e <memmove>
    name[len] = 0;
    80002efc:	9cd6                	add	s9,s9,s5
    80002efe:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002f02:	84ce                	mv	s1,s3
    80002f04:	bfbd                	j	80002e82 <namex+0x9e>
  if(nameiparent){
    80002f06:	f20b0be3          	beqz	s6,80002e3c <namex+0x58>
    iput(ip);
    80002f0a:	8552                	mv	a0,s4
    80002f0c:	b4bff0ef          	jal	80002a56 <iput>
    return 0;
    80002f10:	4a01                	li	s4,0
    80002f12:	b72d                	j	80002e3c <namex+0x58>

0000000080002f14 <dirlink>:
{
    80002f14:	7139                	addi	sp,sp,-64
    80002f16:	fc06                	sd	ra,56(sp)
    80002f18:	f822                	sd	s0,48(sp)
    80002f1a:	f04a                	sd	s2,32(sp)
    80002f1c:	ec4e                	sd	s3,24(sp)
    80002f1e:	e852                	sd	s4,16(sp)
    80002f20:	0080                	addi	s0,sp,64
    80002f22:	892a                	mv	s2,a0
    80002f24:	8a2e                	mv	s4,a1
    80002f26:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002f28:	4601                	li	a2,0
    80002f2a:	e1fff0ef          	jal	80002d48 <dirlookup>
    80002f2e:	e535                	bnez	a0,80002f9a <dirlink+0x86>
    80002f30:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f32:	04c92483          	lw	s1,76(s2)
    80002f36:	c48d                	beqz	s1,80002f60 <dirlink+0x4c>
    80002f38:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f3a:	4741                	li	a4,16
    80002f3c:	86a6                	mv	a3,s1
    80002f3e:	fc040613          	addi	a2,s0,-64
    80002f42:	4581                	li	a1,0
    80002f44:	854a                	mv	a0,s2
    80002f46:	be3ff0ef          	jal	80002b28 <readi>
    80002f4a:	47c1                	li	a5,16
    80002f4c:	04f51b63          	bne	a0,a5,80002fa2 <dirlink+0x8e>
    if(de.inum == 0)
    80002f50:	fc045783          	lhu	a5,-64(s0)
    80002f54:	c791                	beqz	a5,80002f60 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f56:	24c1                	addiw	s1,s1,16
    80002f58:	04c92783          	lw	a5,76(s2)
    80002f5c:	fcf4efe3          	bltu	s1,a5,80002f3a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002f60:	4639                	li	a2,14
    80002f62:	85d2                	mv	a1,s4
    80002f64:	fc240513          	addi	a0,s0,-62
    80002f68:	bdcfd0ef          	jal	80000344 <strncpy>
  de.inum = inum;
    80002f6c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f70:	4741                	li	a4,16
    80002f72:	86a6                	mv	a3,s1
    80002f74:	fc040613          	addi	a2,s0,-64
    80002f78:	4581                	li	a1,0
    80002f7a:	854a                	mv	a0,s2
    80002f7c:	ca9ff0ef          	jal	80002c24 <writei>
    80002f80:	1541                	addi	a0,a0,-16
    80002f82:	00a03533          	snez	a0,a0
    80002f86:	40a00533          	neg	a0,a0
    80002f8a:	74a2                	ld	s1,40(sp)
}
    80002f8c:	70e2                	ld	ra,56(sp)
    80002f8e:	7442                	ld	s0,48(sp)
    80002f90:	7902                	ld	s2,32(sp)
    80002f92:	69e2                	ld	s3,24(sp)
    80002f94:	6a42                	ld	s4,16(sp)
    80002f96:	6121                	addi	sp,sp,64
    80002f98:	8082                	ret
    iput(ip);
    80002f9a:	abdff0ef          	jal	80002a56 <iput>
    return -1;
    80002f9e:	557d                	li	a0,-1
    80002fa0:	b7f5                	j	80002f8c <dirlink+0x78>
      panic("dirlink read");
    80002fa2:	00004517          	auipc	a0,0x4
    80002fa6:	5e650513          	addi	a0,a0,1510 # 80007588 <etext+0x588>
    80002faa:	6d8020ef          	jal	80005682 <panic>

0000000080002fae <namei>:

struct inode*
namei(char *path)
{
    80002fae:	1101                	addi	sp,sp,-32
    80002fb0:	ec06                	sd	ra,24(sp)
    80002fb2:	e822                	sd	s0,16(sp)
    80002fb4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002fb6:	fe040613          	addi	a2,s0,-32
    80002fba:	4581                	li	a1,0
    80002fbc:	e29ff0ef          	jal	80002de4 <namex>
}
    80002fc0:	60e2                	ld	ra,24(sp)
    80002fc2:	6442                	ld	s0,16(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret

0000000080002fc8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002fc8:	1141                	addi	sp,sp,-16
    80002fca:	e406                	sd	ra,8(sp)
    80002fcc:	e022                	sd	s0,0(sp)
    80002fce:	0800                	addi	s0,sp,16
    80002fd0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002fd2:	4585                	li	a1,1
    80002fd4:	e11ff0ef          	jal	80002de4 <namex>
}
    80002fd8:	60a2                	ld	ra,8(sp)
    80002fda:	6402                	ld	s0,0(sp)
    80002fdc:	0141                	addi	sp,sp,16
    80002fde:	8082                	ret

0000000080002fe0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	e426                	sd	s1,8(sp)
    80002fe8:	e04a                	sd	s2,0(sp)
    80002fea:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002fec:	00037917          	auipc	s2,0x37
    80002ff0:	38490913          	addi	s2,s2,900 # 8003a370 <log>
    80002ff4:	01892583          	lw	a1,24(s2)
    80002ff8:	02892503          	lw	a0,40(s2)
    80002ffc:	9a0ff0ef          	jal	8000219c <bread>
    80003000:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003002:	02c92603          	lw	a2,44(s2)
    80003006:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003008:	00c05f63          	blez	a2,80003026 <write_head+0x46>
    8000300c:	00037717          	auipc	a4,0x37
    80003010:	39470713          	addi	a4,a4,916 # 8003a3a0 <log+0x30>
    80003014:	87aa                	mv	a5,a0
    80003016:	060a                	slli	a2,a2,0x2
    80003018:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000301a:	4314                	lw	a3,0(a4)
    8000301c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000301e:	0711                	addi	a4,a4,4
    80003020:	0791                	addi	a5,a5,4
    80003022:	fec79ce3          	bne	a5,a2,8000301a <write_head+0x3a>
  }
  bwrite(buf);
    80003026:	8526                	mv	a0,s1
    80003028:	a4aff0ef          	jal	80002272 <bwrite>
  brelse(buf);
    8000302c:	8526                	mv	a0,s1
    8000302e:	a76ff0ef          	jal	800022a4 <brelse>
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6902                	ld	s2,0(sp)
    8000303a:	6105                	addi	sp,sp,32
    8000303c:	8082                	ret

000000008000303e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000303e:	00037797          	auipc	a5,0x37
    80003042:	35e7a783          	lw	a5,862(a5) # 8003a39c <log+0x2c>
    80003046:	08f05f63          	blez	a5,800030e4 <install_trans+0xa6>
{
    8000304a:	7139                	addi	sp,sp,-64
    8000304c:	fc06                	sd	ra,56(sp)
    8000304e:	f822                	sd	s0,48(sp)
    80003050:	f426                	sd	s1,40(sp)
    80003052:	f04a                	sd	s2,32(sp)
    80003054:	ec4e                	sd	s3,24(sp)
    80003056:	e852                	sd	s4,16(sp)
    80003058:	e456                	sd	s5,8(sp)
    8000305a:	e05a                	sd	s6,0(sp)
    8000305c:	0080                	addi	s0,sp,64
    8000305e:	8b2a                	mv	s6,a0
    80003060:	00037a97          	auipc	s5,0x37
    80003064:	340a8a93          	addi	s5,s5,832 # 8003a3a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003068:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000306a:	00037997          	auipc	s3,0x37
    8000306e:	30698993          	addi	s3,s3,774 # 8003a370 <log>
    80003072:	a829                	j	8000308c <install_trans+0x4e>
    brelse(lbuf);
    80003074:	854a                	mv	a0,s2
    80003076:	a2eff0ef          	jal	800022a4 <brelse>
    brelse(dbuf);
    8000307a:	8526                	mv	a0,s1
    8000307c:	a28ff0ef          	jal	800022a4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003080:	2a05                	addiw	s4,s4,1
    80003082:	0a91                	addi	s5,s5,4
    80003084:	02c9a783          	lw	a5,44(s3)
    80003088:	04fa5463          	bge	s4,a5,800030d0 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000308c:	0189a583          	lw	a1,24(s3)
    80003090:	014585bb          	addw	a1,a1,s4
    80003094:	2585                	addiw	a1,a1,1
    80003096:	0289a503          	lw	a0,40(s3)
    8000309a:	902ff0ef          	jal	8000219c <bread>
    8000309e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800030a0:	000aa583          	lw	a1,0(s5)
    800030a4:	0289a503          	lw	a0,40(s3)
    800030a8:	8f4ff0ef          	jal	8000219c <bread>
    800030ac:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800030ae:	40000613          	li	a2,1024
    800030b2:	05890593          	addi	a1,s2,88
    800030b6:	05850513          	addi	a0,a0,88
    800030ba:	9e4fd0ef          	jal	8000029e <memmove>
    bwrite(dbuf);  // write dst to disk
    800030be:	8526                	mv	a0,s1
    800030c0:	9b2ff0ef          	jal	80002272 <bwrite>
    if(recovering == 0)
    800030c4:	fa0b18e3          	bnez	s6,80003074 <install_trans+0x36>
      bunpin(dbuf);
    800030c8:	8526                	mv	a0,s1
    800030ca:	a96ff0ef          	jal	80002360 <bunpin>
    800030ce:	b75d                	j	80003074 <install_trans+0x36>
}
    800030d0:	70e2                	ld	ra,56(sp)
    800030d2:	7442                	ld	s0,48(sp)
    800030d4:	74a2                	ld	s1,40(sp)
    800030d6:	7902                	ld	s2,32(sp)
    800030d8:	69e2                	ld	s3,24(sp)
    800030da:	6a42                	ld	s4,16(sp)
    800030dc:	6aa2                	ld	s5,8(sp)
    800030de:	6b02                	ld	s6,0(sp)
    800030e0:	6121                	addi	sp,sp,64
    800030e2:	8082                	ret
    800030e4:	8082                	ret

00000000800030e6 <initlog>:
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	e44e                	sd	s3,8(sp)
    800030f2:	1800                	addi	s0,sp,48
    800030f4:	892a                	mv	s2,a0
    800030f6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800030f8:	00037497          	auipc	s1,0x37
    800030fc:	27848493          	addi	s1,s1,632 # 8003a370 <log>
    80003100:	00004597          	auipc	a1,0x4
    80003104:	49858593          	addi	a1,a1,1176 # 80007598 <etext+0x598>
    80003108:	8526                	mv	a0,s1
    8000310a:	027020ef          	jal	80005930 <initlock>
  log.start = sb->logstart;
    8000310e:	0149a583          	lw	a1,20(s3)
    80003112:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003114:	0109a783          	lw	a5,16(s3)
    80003118:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000311a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000311e:	854a                	mv	a0,s2
    80003120:	87cff0ef          	jal	8000219c <bread>
  log.lh.n = lh->n;
    80003124:	4d30                	lw	a2,88(a0)
    80003126:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003128:	00c05f63          	blez	a2,80003146 <initlog+0x60>
    8000312c:	87aa                	mv	a5,a0
    8000312e:	00037717          	auipc	a4,0x37
    80003132:	27270713          	addi	a4,a4,626 # 8003a3a0 <log+0x30>
    80003136:	060a                	slli	a2,a2,0x2
    80003138:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000313a:	4ff4                	lw	a3,92(a5)
    8000313c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000313e:	0791                	addi	a5,a5,4
    80003140:	0711                	addi	a4,a4,4
    80003142:	fec79ce3          	bne	a5,a2,8000313a <initlog+0x54>
  brelse(buf);
    80003146:	95eff0ef          	jal	800022a4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000314a:	4505                	li	a0,1
    8000314c:	ef3ff0ef          	jal	8000303e <install_trans>
  log.lh.n = 0;
    80003150:	00037797          	auipc	a5,0x37
    80003154:	2407a623          	sw	zero,588(a5) # 8003a39c <log+0x2c>
  write_head(); // clear the log
    80003158:	e89ff0ef          	jal	80002fe0 <write_head>
}
    8000315c:	70a2                	ld	ra,40(sp)
    8000315e:	7402                	ld	s0,32(sp)
    80003160:	64e2                	ld	s1,24(sp)
    80003162:	6942                	ld	s2,16(sp)
    80003164:	69a2                	ld	s3,8(sp)
    80003166:	6145                	addi	sp,sp,48
    80003168:	8082                	ret

000000008000316a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000316a:	1101                	addi	sp,sp,-32
    8000316c:	ec06                	sd	ra,24(sp)
    8000316e:	e822                	sd	s0,16(sp)
    80003170:	e426                	sd	s1,8(sp)
    80003172:	e04a                	sd	s2,0(sp)
    80003174:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003176:	00037517          	auipc	a0,0x37
    8000317a:	1fa50513          	addi	a0,a0,506 # 8003a370 <log>
    8000317e:	033020ef          	jal	800059b0 <acquire>
  while(1){
    if(log.committing){
    80003182:	00037497          	auipc	s1,0x37
    80003186:	1ee48493          	addi	s1,s1,494 # 8003a370 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000318a:	4979                	li	s2,30
    8000318c:	a029                	j	80003196 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000318e:	85a6                	mv	a1,s1
    80003190:	8526                	mv	a0,s1
    80003192:	b5cfe0ef          	jal	800014ee <sleep>
    if(log.committing){
    80003196:	50dc                	lw	a5,36(s1)
    80003198:	fbfd                	bnez	a5,8000318e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000319a:	5098                	lw	a4,32(s1)
    8000319c:	2705                	addiw	a4,a4,1
    8000319e:	0027179b          	slliw	a5,a4,0x2
    800031a2:	9fb9                	addw	a5,a5,a4
    800031a4:	0017979b          	slliw	a5,a5,0x1
    800031a8:	54d4                	lw	a3,44(s1)
    800031aa:	9fb5                	addw	a5,a5,a3
    800031ac:	00f95763          	bge	s2,a5,800031ba <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800031b0:	85a6                	mv	a1,s1
    800031b2:	8526                	mv	a0,s1
    800031b4:	b3afe0ef          	jal	800014ee <sleep>
    800031b8:	bff9                	j	80003196 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800031ba:	00037517          	auipc	a0,0x37
    800031be:	1b650513          	addi	a0,a0,438 # 8003a370 <log>
    800031c2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800031c4:	085020ef          	jal	80005a48 <release>
      break;
    }
  }
}
    800031c8:	60e2                	ld	ra,24(sp)
    800031ca:	6442                	ld	s0,16(sp)
    800031cc:	64a2                	ld	s1,8(sp)
    800031ce:	6902                	ld	s2,0(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret

00000000800031d4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800031d4:	7139                	addi	sp,sp,-64
    800031d6:	fc06                	sd	ra,56(sp)
    800031d8:	f822                	sd	s0,48(sp)
    800031da:	f426                	sd	s1,40(sp)
    800031dc:	f04a                	sd	s2,32(sp)
    800031de:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800031e0:	00037497          	auipc	s1,0x37
    800031e4:	19048493          	addi	s1,s1,400 # 8003a370 <log>
    800031e8:	8526                	mv	a0,s1
    800031ea:	7c6020ef          	jal	800059b0 <acquire>
  log.outstanding -= 1;
    800031ee:	509c                	lw	a5,32(s1)
    800031f0:	37fd                	addiw	a5,a5,-1
    800031f2:	0007891b          	sext.w	s2,a5
    800031f6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800031f8:	50dc                	lw	a5,36(s1)
    800031fa:	ef9d                	bnez	a5,80003238 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800031fc:	04091763          	bnez	s2,8000324a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003200:	00037497          	auipc	s1,0x37
    80003204:	17048493          	addi	s1,s1,368 # 8003a370 <log>
    80003208:	4785                	li	a5,1
    8000320a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000320c:	8526                	mv	a0,s1
    8000320e:	03b020ef          	jal	80005a48 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003212:	54dc                	lw	a5,44(s1)
    80003214:	04f04b63          	bgtz	a5,8000326a <end_op+0x96>
    acquire(&log.lock);
    80003218:	00037497          	auipc	s1,0x37
    8000321c:	15848493          	addi	s1,s1,344 # 8003a370 <log>
    80003220:	8526                	mv	a0,s1
    80003222:	78e020ef          	jal	800059b0 <acquire>
    log.committing = 0;
    80003226:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000322a:	8526                	mv	a0,s1
    8000322c:	b0efe0ef          	jal	8000153a <wakeup>
    release(&log.lock);
    80003230:	8526                	mv	a0,s1
    80003232:	017020ef          	jal	80005a48 <release>
}
    80003236:	a025                	j	8000325e <end_op+0x8a>
    80003238:	ec4e                	sd	s3,24(sp)
    8000323a:	e852                	sd	s4,16(sp)
    8000323c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000323e:	00004517          	auipc	a0,0x4
    80003242:	36250513          	addi	a0,a0,866 # 800075a0 <etext+0x5a0>
    80003246:	43c020ef          	jal	80005682 <panic>
    wakeup(&log);
    8000324a:	00037497          	auipc	s1,0x37
    8000324e:	12648493          	addi	s1,s1,294 # 8003a370 <log>
    80003252:	8526                	mv	a0,s1
    80003254:	ae6fe0ef          	jal	8000153a <wakeup>
  release(&log.lock);
    80003258:	8526                	mv	a0,s1
    8000325a:	7ee020ef          	jal	80005a48 <release>
}
    8000325e:	70e2                	ld	ra,56(sp)
    80003260:	7442                	ld	s0,48(sp)
    80003262:	74a2                	ld	s1,40(sp)
    80003264:	7902                	ld	s2,32(sp)
    80003266:	6121                	addi	sp,sp,64
    80003268:	8082                	ret
    8000326a:	ec4e                	sd	s3,24(sp)
    8000326c:	e852                	sd	s4,16(sp)
    8000326e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003270:	00037a97          	auipc	s5,0x37
    80003274:	130a8a93          	addi	s5,s5,304 # 8003a3a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003278:	00037a17          	auipc	s4,0x37
    8000327c:	0f8a0a13          	addi	s4,s4,248 # 8003a370 <log>
    80003280:	018a2583          	lw	a1,24(s4)
    80003284:	012585bb          	addw	a1,a1,s2
    80003288:	2585                	addiw	a1,a1,1
    8000328a:	028a2503          	lw	a0,40(s4)
    8000328e:	f0ffe0ef          	jal	8000219c <bread>
    80003292:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003294:	000aa583          	lw	a1,0(s5)
    80003298:	028a2503          	lw	a0,40(s4)
    8000329c:	f01fe0ef          	jal	8000219c <bread>
    800032a0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800032a2:	40000613          	li	a2,1024
    800032a6:	05850593          	addi	a1,a0,88
    800032aa:	05848513          	addi	a0,s1,88
    800032ae:	ff1fc0ef          	jal	8000029e <memmove>
    bwrite(to);  // write the log
    800032b2:	8526                	mv	a0,s1
    800032b4:	fbffe0ef          	jal	80002272 <bwrite>
    brelse(from);
    800032b8:	854e                	mv	a0,s3
    800032ba:	febfe0ef          	jal	800022a4 <brelse>
    brelse(to);
    800032be:	8526                	mv	a0,s1
    800032c0:	fe5fe0ef          	jal	800022a4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800032c4:	2905                	addiw	s2,s2,1
    800032c6:	0a91                	addi	s5,s5,4
    800032c8:	02ca2783          	lw	a5,44(s4)
    800032cc:	faf94ae3          	blt	s2,a5,80003280 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800032d0:	d11ff0ef          	jal	80002fe0 <write_head>
    install_trans(0); // Now install writes to home locations
    800032d4:	4501                	li	a0,0
    800032d6:	d69ff0ef          	jal	8000303e <install_trans>
    log.lh.n = 0;
    800032da:	00037797          	auipc	a5,0x37
    800032de:	0c07a123          	sw	zero,194(a5) # 8003a39c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800032e2:	cffff0ef          	jal	80002fe0 <write_head>
    800032e6:	69e2                	ld	s3,24(sp)
    800032e8:	6a42                	ld	s4,16(sp)
    800032ea:	6aa2                	ld	s5,8(sp)
    800032ec:	b735                	j	80003218 <end_op+0x44>

00000000800032ee <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	e426                	sd	s1,8(sp)
    800032f6:	e04a                	sd	s2,0(sp)
    800032f8:	1000                	addi	s0,sp,32
    800032fa:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800032fc:	00037917          	auipc	s2,0x37
    80003300:	07490913          	addi	s2,s2,116 # 8003a370 <log>
    80003304:	854a                	mv	a0,s2
    80003306:	6aa020ef          	jal	800059b0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000330a:	02c92603          	lw	a2,44(s2)
    8000330e:	47f5                	li	a5,29
    80003310:	06c7c363          	blt	a5,a2,80003376 <log_write+0x88>
    80003314:	00037797          	auipc	a5,0x37
    80003318:	0787a783          	lw	a5,120(a5) # 8003a38c <log+0x1c>
    8000331c:	37fd                	addiw	a5,a5,-1
    8000331e:	04f65c63          	bge	a2,a5,80003376 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003322:	00037797          	auipc	a5,0x37
    80003326:	06e7a783          	lw	a5,110(a5) # 8003a390 <log+0x20>
    8000332a:	04f05c63          	blez	a5,80003382 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000332e:	4781                	li	a5,0
    80003330:	04c05f63          	blez	a2,8000338e <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003334:	44cc                	lw	a1,12(s1)
    80003336:	00037717          	auipc	a4,0x37
    8000333a:	06a70713          	addi	a4,a4,106 # 8003a3a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000333e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003340:	4314                	lw	a3,0(a4)
    80003342:	04b68663          	beq	a3,a1,8000338e <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003346:	2785                	addiw	a5,a5,1
    80003348:	0711                	addi	a4,a4,4
    8000334a:	fef61be3          	bne	a2,a5,80003340 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000334e:	0621                	addi	a2,a2,8
    80003350:	060a                	slli	a2,a2,0x2
    80003352:	00037797          	auipc	a5,0x37
    80003356:	01e78793          	addi	a5,a5,30 # 8003a370 <log>
    8000335a:	97b2                	add	a5,a5,a2
    8000335c:	44d8                	lw	a4,12(s1)
    8000335e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003360:	8526                	mv	a0,s1
    80003362:	fcbfe0ef          	jal	8000232c <bpin>
    log.lh.n++;
    80003366:	00037717          	auipc	a4,0x37
    8000336a:	00a70713          	addi	a4,a4,10 # 8003a370 <log>
    8000336e:	575c                	lw	a5,44(a4)
    80003370:	2785                	addiw	a5,a5,1
    80003372:	d75c                	sw	a5,44(a4)
    80003374:	a80d                	j	800033a6 <log_write+0xb8>
    panic("too big a transaction");
    80003376:	00004517          	auipc	a0,0x4
    8000337a:	23a50513          	addi	a0,a0,570 # 800075b0 <etext+0x5b0>
    8000337e:	304020ef          	jal	80005682 <panic>
    panic("log_write outside of trans");
    80003382:	00004517          	auipc	a0,0x4
    80003386:	24650513          	addi	a0,a0,582 # 800075c8 <etext+0x5c8>
    8000338a:	2f8020ef          	jal	80005682 <panic>
  log.lh.block[i] = b->blockno;
    8000338e:	00878693          	addi	a3,a5,8
    80003392:	068a                	slli	a3,a3,0x2
    80003394:	00037717          	auipc	a4,0x37
    80003398:	fdc70713          	addi	a4,a4,-36 # 8003a370 <log>
    8000339c:	9736                	add	a4,a4,a3
    8000339e:	44d4                	lw	a3,12(s1)
    800033a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800033a2:	faf60fe3          	beq	a2,a5,80003360 <log_write+0x72>
  }
  release(&log.lock);
    800033a6:	00037517          	auipc	a0,0x37
    800033aa:	fca50513          	addi	a0,a0,-54 # 8003a370 <log>
    800033ae:	69a020ef          	jal	80005a48 <release>
}
    800033b2:	60e2                	ld	ra,24(sp)
    800033b4:	6442                	ld	s0,16(sp)
    800033b6:	64a2                	ld	s1,8(sp)
    800033b8:	6902                	ld	s2,0(sp)
    800033ba:	6105                	addi	sp,sp,32
    800033bc:	8082                	ret

00000000800033be <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800033be:	1101                	addi	sp,sp,-32
    800033c0:	ec06                	sd	ra,24(sp)
    800033c2:	e822                	sd	s0,16(sp)
    800033c4:	e426                	sd	s1,8(sp)
    800033c6:	e04a                	sd	s2,0(sp)
    800033c8:	1000                	addi	s0,sp,32
    800033ca:	84aa                	mv	s1,a0
    800033cc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800033ce:	00004597          	auipc	a1,0x4
    800033d2:	21a58593          	addi	a1,a1,538 # 800075e8 <etext+0x5e8>
    800033d6:	0521                	addi	a0,a0,8
    800033d8:	558020ef          	jal	80005930 <initlock>
  lk->name = name;
    800033dc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800033e0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800033e4:	0204a423          	sw	zero,40(s1)
}
    800033e8:	60e2                	ld	ra,24(sp)
    800033ea:	6442                	ld	s0,16(sp)
    800033ec:	64a2                	ld	s1,8(sp)
    800033ee:	6902                	ld	s2,0(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret

00000000800033f4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	e04a                	sd	s2,0(sp)
    800033fe:	1000                	addi	s0,sp,32
    80003400:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003402:	00850913          	addi	s2,a0,8
    80003406:	854a                	mv	a0,s2
    80003408:	5a8020ef          	jal	800059b0 <acquire>
  while (lk->locked) {
    8000340c:	409c                	lw	a5,0(s1)
    8000340e:	c799                	beqz	a5,8000341c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003410:	85ca                	mv	a1,s2
    80003412:	8526                	mv	a0,s1
    80003414:	8dafe0ef          	jal	800014ee <sleep>
  while (lk->locked) {
    80003418:	409c                	lw	a5,0(s1)
    8000341a:	fbfd                	bnez	a5,80003410 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000341c:	4785                	li	a5,1
    8000341e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003420:	b01fd0ef          	jal	80000f20 <myproc>
    80003424:	591c                	lw	a5,48(a0)
    80003426:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003428:	854a                	mv	a0,s2
    8000342a:	61e020ef          	jal	80005a48 <release>
}
    8000342e:	60e2                	ld	ra,24(sp)
    80003430:	6442                	ld	s0,16(sp)
    80003432:	64a2                	ld	s1,8(sp)
    80003434:	6902                	ld	s2,0(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret

000000008000343a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000343a:	1101                	addi	sp,sp,-32
    8000343c:	ec06                	sd	ra,24(sp)
    8000343e:	e822                	sd	s0,16(sp)
    80003440:	e426                	sd	s1,8(sp)
    80003442:	e04a                	sd	s2,0(sp)
    80003444:	1000                	addi	s0,sp,32
    80003446:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003448:	00850913          	addi	s2,a0,8
    8000344c:	854a                	mv	a0,s2
    8000344e:	562020ef          	jal	800059b0 <acquire>
  lk->locked = 0;
    80003452:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003456:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000345a:	8526                	mv	a0,s1
    8000345c:	8defe0ef          	jal	8000153a <wakeup>
  release(&lk->lk);
    80003460:	854a                	mv	a0,s2
    80003462:	5e6020ef          	jal	80005a48 <release>
}
    80003466:	60e2                	ld	ra,24(sp)
    80003468:	6442                	ld	s0,16(sp)
    8000346a:	64a2                	ld	s1,8(sp)
    8000346c:	6902                	ld	s2,0(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret

0000000080003472 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	1800                	addi	s0,sp,48
    8000347e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003480:	00850913          	addi	s2,a0,8
    80003484:	854a                	mv	a0,s2
    80003486:	52a020ef          	jal	800059b0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000348a:	409c                	lw	a5,0(s1)
    8000348c:	ef81                	bnez	a5,800034a4 <holdingsleep+0x32>
    8000348e:	4481                	li	s1,0
  release(&lk->lk);
    80003490:	854a                	mv	a0,s2
    80003492:	5b6020ef          	jal	80005a48 <release>
  return r;
}
    80003496:	8526                	mv	a0,s1
    80003498:	70a2                	ld	ra,40(sp)
    8000349a:	7402                	ld	s0,32(sp)
    8000349c:	64e2                	ld	s1,24(sp)
    8000349e:	6942                	ld	s2,16(sp)
    800034a0:	6145                	addi	sp,sp,48
    800034a2:	8082                	ret
    800034a4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800034a6:	0284a983          	lw	s3,40(s1)
    800034aa:	a77fd0ef          	jal	80000f20 <myproc>
    800034ae:	5904                	lw	s1,48(a0)
    800034b0:	413484b3          	sub	s1,s1,s3
    800034b4:	0014b493          	seqz	s1,s1
    800034b8:	69a2                	ld	s3,8(sp)
    800034ba:	bfd9                	j	80003490 <holdingsleep+0x1e>

00000000800034bc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800034bc:	1141                	addi	sp,sp,-16
    800034be:	e406                	sd	ra,8(sp)
    800034c0:	e022                	sd	s0,0(sp)
    800034c2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800034c4:	00004597          	auipc	a1,0x4
    800034c8:	13458593          	addi	a1,a1,308 # 800075f8 <etext+0x5f8>
    800034cc:	00037517          	auipc	a0,0x37
    800034d0:	fec50513          	addi	a0,a0,-20 # 8003a4b8 <ftable>
    800034d4:	45c020ef          	jal	80005930 <initlock>
}
    800034d8:	60a2                	ld	ra,8(sp)
    800034da:	6402                	ld	s0,0(sp)
    800034dc:	0141                	addi	sp,sp,16
    800034de:	8082                	ret

00000000800034e0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800034ea:	00037517          	auipc	a0,0x37
    800034ee:	fce50513          	addi	a0,a0,-50 # 8003a4b8 <ftable>
    800034f2:	4be020ef          	jal	800059b0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034f6:	00037497          	auipc	s1,0x37
    800034fa:	fda48493          	addi	s1,s1,-38 # 8003a4d0 <ftable+0x18>
    800034fe:	00038717          	auipc	a4,0x38
    80003502:	f7270713          	addi	a4,a4,-142 # 8003b470 <disk>
    if(f->ref == 0){
    80003506:	40dc                	lw	a5,4(s1)
    80003508:	cf89                	beqz	a5,80003522 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000350a:	02848493          	addi	s1,s1,40
    8000350e:	fee49ce3          	bne	s1,a4,80003506 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003512:	00037517          	auipc	a0,0x37
    80003516:	fa650513          	addi	a0,a0,-90 # 8003a4b8 <ftable>
    8000351a:	52e020ef          	jal	80005a48 <release>
  return 0;
    8000351e:	4481                	li	s1,0
    80003520:	a809                	j	80003532 <filealloc+0x52>
      f->ref = 1;
    80003522:	4785                	li	a5,1
    80003524:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003526:	00037517          	auipc	a0,0x37
    8000352a:	f9250513          	addi	a0,a0,-110 # 8003a4b8 <ftable>
    8000352e:	51a020ef          	jal	80005a48 <release>
}
    80003532:	8526                	mv	a0,s1
    80003534:	60e2                	ld	ra,24(sp)
    80003536:	6442                	ld	s0,16(sp)
    80003538:	64a2                	ld	s1,8(sp)
    8000353a:	6105                	addi	sp,sp,32
    8000353c:	8082                	ret

000000008000353e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000353e:	1101                	addi	sp,sp,-32
    80003540:	ec06                	sd	ra,24(sp)
    80003542:	e822                	sd	s0,16(sp)
    80003544:	e426                	sd	s1,8(sp)
    80003546:	1000                	addi	s0,sp,32
    80003548:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000354a:	00037517          	auipc	a0,0x37
    8000354e:	f6e50513          	addi	a0,a0,-146 # 8003a4b8 <ftable>
    80003552:	45e020ef          	jal	800059b0 <acquire>
  if(f->ref < 1)
    80003556:	40dc                	lw	a5,4(s1)
    80003558:	02f05063          	blez	a5,80003578 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000355c:	2785                	addiw	a5,a5,1
    8000355e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003560:	00037517          	auipc	a0,0x37
    80003564:	f5850513          	addi	a0,a0,-168 # 8003a4b8 <ftable>
    80003568:	4e0020ef          	jal	80005a48 <release>
  return f;
}
    8000356c:	8526                	mv	a0,s1
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6105                	addi	sp,sp,32
    80003576:	8082                	ret
    panic("filedup");
    80003578:	00004517          	auipc	a0,0x4
    8000357c:	08850513          	addi	a0,a0,136 # 80007600 <etext+0x600>
    80003580:	102020ef          	jal	80005682 <panic>

0000000080003584 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003584:	7139                	addi	sp,sp,-64
    80003586:	fc06                	sd	ra,56(sp)
    80003588:	f822                	sd	s0,48(sp)
    8000358a:	f426                	sd	s1,40(sp)
    8000358c:	0080                	addi	s0,sp,64
    8000358e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003590:	00037517          	auipc	a0,0x37
    80003594:	f2850513          	addi	a0,a0,-216 # 8003a4b8 <ftable>
    80003598:	418020ef          	jal	800059b0 <acquire>
  if(f->ref < 1)
    8000359c:	40dc                	lw	a5,4(s1)
    8000359e:	04f05a63          	blez	a5,800035f2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800035a2:	37fd                	addiw	a5,a5,-1
    800035a4:	0007871b          	sext.w	a4,a5
    800035a8:	c0dc                	sw	a5,4(s1)
    800035aa:	04e04e63          	bgtz	a4,80003606 <fileclose+0x82>
    800035ae:	f04a                	sd	s2,32(sp)
    800035b0:	ec4e                	sd	s3,24(sp)
    800035b2:	e852                	sd	s4,16(sp)
    800035b4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800035b6:	0004a903          	lw	s2,0(s1)
    800035ba:	0094ca83          	lbu	s5,9(s1)
    800035be:	0104ba03          	ld	s4,16(s1)
    800035c2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800035c6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800035ca:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800035ce:	00037517          	auipc	a0,0x37
    800035d2:	eea50513          	addi	a0,a0,-278 # 8003a4b8 <ftable>
    800035d6:	472020ef          	jal	80005a48 <release>

  if(ff.type == FD_PIPE){
    800035da:	4785                	li	a5,1
    800035dc:	04f90063          	beq	s2,a5,8000361c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800035e0:	3979                	addiw	s2,s2,-2
    800035e2:	4785                	li	a5,1
    800035e4:	0527f563          	bgeu	a5,s2,8000362e <fileclose+0xaa>
    800035e8:	7902                	ld	s2,32(sp)
    800035ea:	69e2                	ld	s3,24(sp)
    800035ec:	6a42                	ld	s4,16(sp)
    800035ee:	6aa2                	ld	s5,8(sp)
    800035f0:	a00d                	j	80003612 <fileclose+0x8e>
    800035f2:	f04a                	sd	s2,32(sp)
    800035f4:	ec4e                	sd	s3,24(sp)
    800035f6:	e852                	sd	s4,16(sp)
    800035f8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800035fa:	00004517          	auipc	a0,0x4
    800035fe:	00e50513          	addi	a0,a0,14 # 80007608 <etext+0x608>
    80003602:	080020ef          	jal	80005682 <panic>
    release(&ftable.lock);
    80003606:	00037517          	auipc	a0,0x37
    8000360a:	eb250513          	addi	a0,a0,-334 # 8003a4b8 <ftable>
    8000360e:	43a020ef          	jal	80005a48 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003612:	70e2                	ld	ra,56(sp)
    80003614:	7442                	ld	s0,48(sp)
    80003616:	74a2                	ld	s1,40(sp)
    80003618:	6121                	addi	sp,sp,64
    8000361a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000361c:	85d6                	mv	a1,s5
    8000361e:	8552                	mv	a0,s4
    80003620:	336000ef          	jal	80003956 <pipeclose>
    80003624:	7902                	ld	s2,32(sp)
    80003626:	69e2                	ld	s3,24(sp)
    80003628:	6a42                	ld	s4,16(sp)
    8000362a:	6aa2                	ld	s5,8(sp)
    8000362c:	b7dd                	j	80003612 <fileclose+0x8e>
    begin_op();
    8000362e:	b3dff0ef          	jal	8000316a <begin_op>
    iput(ff.ip);
    80003632:	854e                	mv	a0,s3
    80003634:	c22ff0ef          	jal	80002a56 <iput>
    end_op();
    80003638:	b9dff0ef          	jal	800031d4 <end_op>
    8000363c:	7902                	ld	s2,32(sp)
    8000363e:	69e2                	ld	s3,24(sp)
    80003640:	6a42                	ld	s4,16(sp)
    80003642:	6aa2                	ld	s5,8(sp)
    80003644:	b7f9                	j	80003612 <fileclose+0x8e>

0000000080003646 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003646:	715d                	addi	sp,sp,-80
    80003648:	e486                	sd	ra,72(sp)
    8000364a:	e0a2                	sd	s0,64(sp)
    8000364c:	fc26                	sd	s1,56(sp)
    8000364e:	f44e                	sd	s3,40(sp)
    80003650:	0880                	addi	s0,sp,80
    80003652:	84aa                	mv	s1,a0
    80003654:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003656:	8cbfd0ef          	jal	80000f20 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000365a:	409c                	lw	a5,0(s1)
    8000365c:	37f9                	addiw	a5,a5,-2
    8000365e:	4705                	li	a4,1
    80003660:	04f76063          	bltu	a4,a5,800036a0 <filestat+0x5a>
    80003664:	f84a                	sd	s2,48(sp)
    80003666:	892a                	mv	s2,a0
    ilock(f->ip);
    80003668:	6c88                	ld	a0,24(s1)
    8000366a:	a6aff0ef          	jal	800028d4 <ilock>
    stati(f->ip, &st);
    8000366e:	fb840593          	addi	a1,s0,-72
    80003672:	6c88                	ld	a0,24(s1)
    80003674:	c8aff0ef          	jal	80002afe <stati>
    iunlock(f->ip);
    80003678:	6c88                	ld	a0,24(s1)
    8000367a:	b08ff0ef          	jal	80002982 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000367e:	46e1                	li	a3,24
    80003680:	fb840613          	addi	a2,s0,-72
    80003684:	85ce                	mv	a1,s3
    80003686:	05093503          	ld	a0,80(s2)
    8000368a:	c58fd0ef          	jal	80000ae2 <copyout>
    8000368e:	41f5551b          	sraiw	a0,a0,0x1f
    80003692:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003694:	60a6                	ld	ra,72(sp)
    80003696:	6406                	ld	s0,64(sp)
    80003698:	74e2                	ld	s1,56(sp)
    8000369a:	79a2                	ld	s3,40(sp)
    8000369c:	6161                	addi	sp,sp,80
    8000369e:	8082                	ret
  return -1;
    800036a0:	557d                	li	a0,-1
    800036a2:	bfcd                	j	80003694 <filestat+0x4e>

00000000800036a4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	e84a                	sd	s2,16(sp)
    800036ac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800036ae:	00854783          	lbu	a5,8(a0)
    800036b2:	cfd1                	beqz	a5,8000374e <fileread+0xaa>
    800036b4:	ec26                	sd	s1,24(sp)
    800036b6:	e44e                	sd	s3,8(sp)
    800036b8:	84aa                	mv	s1,a0
    800036ba:	89ae                	mv	s3,a1
    800036bc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800036be:	411c                	lw	a5,0(a0)
    800036c0:	4705                	li	a4,1
    800036c2:	04e78363          	beq	a5,a4,80003708 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800036c6:	470d                	li	a4,3
    800036c8:	04e78763          	beq	a5,a4,80003716 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800036cc:	4709                	li	a4,2
    800036ce:	06e79a63          	bne	a5,a4,80003742 <fileread+0x9e>
    ilock(f->ip);
    800036d2:	6d08                	ld	a0,24(a0)
    800036d4:	a00ff0ef          	jal	800028d4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800036d8:	874a                	mv	a4,s2
    800036da:	5094                	lw	a3,32(s1)
    800036dc:	864e                	mv	a2,s3
    800036de:	4585                	li	a1,1
    800036e0:	6c88                	ld	a0,24(s1)
    800036e2:	c46ff0ef          	jal	80002b28 <readi>
    800036e6:	892a                	mv	s2,a0
    800036e8:	00a05563          	blez	a0,800036f2 <fileread+0x4e>
      f->off += r;
    800036ec:	509c                	lw	a5,32(s1)
    800036ee:	9fa9                	addw	a5,a5,a0
    800036f0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800036f2:	6c88                	ld	a0,24(s1)
    800036f4:	a8eff0ef          	jal	80002982 <iunlock>
    800036f8:	64e2                	ld	s1,24(sp)
    800036fa:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800036fc:	854a                	mv	a0,s2
    800036fe:	70a2                	ld	ra,40(sp)
    80003700:	7402                	ld	s0,32(sp)
    80003702:	6942                	ld	s2,16(sp)
    80003704:	6145                	addi	sp,sp,48
    80003706:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003708:	6908                	ld	a0,16(a0)
    8000370a:	388000ef          	jal	80003a92 <piperead>
    8000370e:	892a                	mv	s2,a0
    80003710:	64e2                	ld	s1,24(sp)
    80003712:	69a2                	ld	s3,8(sp)
    80003714:	b7e5                	j	800036fc <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003716:	02451783          	lh	a5,36(a0)
    8000371a:	03079693          	slli	a3,a5,0x30
    8000371e:	92c1                	srli	a3,a3,0x30
    80003720:	4725                	li	a4,9
    80003722:	02d76863          	bltu	a4,a3,80003752 <fileread+0xae>
    80003726:	0792                	slli	a5,a5,0x4
    80003728:	00037717          	auipc	a4,0x37
    8000372c:	cf070713          	addi	a4,a4,-784 # 8003a418 <devsw>
    80003730:	97ba                	add	a5,a5,a4
    80003732:	639c                	ld	a5,0(a5)
    80003734:	c39d                	beqz	a5,8000375a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003736:	4505                	li	a0,1
    80003738:	9782                	jalr	a5
    8000373a:	892a                	mv	s2,a0
    8000373c:	64e2                	ld	s1,24(sp)
    8000373e:	69a2                	ld	s3,8(sp)
    80003740:	bf75                	j	800036fc <fileread+0x58>
    panic("fileread");
    80003742:	00004517          	auipc	a0,0x4
    80003746:	ed650513          	addi	a0,a0,-298 # 80007618 <etext+0x618>
    8000374a:	739010ef          	jal	80005682 <panic>
    return -1;
    8000374e:	597d                	li	s2,-1
    80003750:	b775                	j	800036fc <fileread+0x58>
      return -1;
    80003752:	597d                	li	s2,-1
    80003754:	64e2                	ld	s1,24(sp)
    80003756:	69a2                	ld	s3,8(sp)
    80003758:	b755                	j	800036fc <fileread+0x58>
    8000375a:	597d                	li	s2,-1
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	69a2                	ld	s3,8(sp)
    80003760:	bf71                	j	800036fc <fileread+0x58>

0000000080003762 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003762:	00954783          	lbu	a5,9(a0)
    80003766:	10078b63          	beqz	a5,8000387c <filewrite+0x11a>
{
    8000376a:	715d                	addi	sp,sp,-80
    8000376c:	e486                	sd	ra,72(sp)
    8000376e:	e0a2                	sd	s0,64(sp)
    80003770:	f84a                	sd	s2,48(sp)
    80003772:	f052                	sd	s4,32(sp)
    80003774:	e85a                	sd	s6,16(sp)
    80003776:	0880                	addi	s0,sp,80
    80003778:	892a                	mv	s2,a0
    8000377a:	8b2e                	mv	s6,a1
    8000377c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000377e:	411c                	lw	a5,0(a0)
    80003780:	4705                	li	a4,1
    80003782:	02e78763          	beq	a5,a4,800037b0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003786:	470d                	li	a4,3
    80003788:	02e78863          	beq	a5,a4,800037b8 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000378c:	4709                	li	a4,2
    8000378e:	0ce79c63          	bne	a5,a4,80003866 <filewrite+0x104>
    80003792:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003794:	0ac05863          	blez	a2,80003844 <filewrite+0xe2>
    80003798:	fc26                	sd	s1,56(sp)
    8000379a:	ec56                	sd	s5,24(sp)
    8000379c:	e45e                	sd	s7,8(sp)
    8000379e:	e062                	sd	s8,0(sp)
    int i = 0;
    800037a0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800037a2:	6b85                	lui	s7,0x1
    800037a4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800037a8:	6c05                	lui	s8,0x1
    800037aa:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800037ae:	a8b5                	j	8000382a <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800037b0:	6908                	ld	a0,16(a0)
    800037b2:	1fc000ef          	jal	800039ae <pipewrite>
    800037b6:	a04d                	j	80003858 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800037b8:	02451783          	lh	a5,36(a0)
    800037bc:	03079693          	slli	a3,a5,0x30
    800037c0:	92c1                	srli	a3,a3,0x30
    800037c2:	4725                	li	a4,9
    800037c4:	0ad76e63          	bltu	a4,a3,80003880 <filewrite+0x11e>
    800037c8:	0792                	slli	a5,a5,0x4
    800037ca:	00037717          	auipc	a4,0x37
    800037ce:	c4e70713          	addi	a4,a4,-946 # 8003a418 <devsw>
    800037d2:	97ba                	add	a5,a5,a4
    800037d4:	679c                	ld	a5,8(a5)
    800037d6:	c7dd                	beqz	a5,80003884 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800037d8:	4505                	li	a0,1
    800037da:	9782                	jalr	a5
    800037dc:	a8b5                	j	80003858 <filewrite+0xf6>
      if(n1 > max)
    800037de:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800037e2:	989ff0ef          	jal	8000316a <begin_op>
      ilock(f->ip);
    800037e6:	01893503          	ld	a0,24(s2)
    800037ea:	8eaff0ef          	jal	800028d4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800037ee:	8756                	mv	a4,s5
    800037f0:	02092683          	lw	a3,32(s2)
    800037f4:	01698633          	add	a2,s3,s6
    800037f8:	4585                	li	a1,1
    800037fa:	01893503          	ld	a0,24(s2)
    800037fe:	c26ff0ef          	jal	80002c24 <writei>
    80003802:	84aa                	mv	s1,a0
    80003804:	00a05763          	blez	a0,80003812 <filewrite+0xb0>
        f->off += r;
    80003808:	02092783          	lw	a5,32(s2)
    8000380c:	9fa9                	addw	a5,a5,a0
    8000380e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003812:	01893503          	ld	a0,24(s2)
    80003816:	96cff0ef          	jal	80002982 <iunlock>
      end_op();
    8000381a:	9bbff0ef          	jal	800031d4 <end_op>

      if(r != n1){
    8000381e:	029a9563          	bne	s5,s1,80003848 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003822:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003826:	0149da63          	bge	s3,s4,8000383a <filewrite+0xd8>
      int n1 = n - i;
    8000382a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000382e:	0004879b          	sext.w	a5,s1
    80003832:	fafbd6e3          	bge	s7,a5,800037de <filewrite+0x7c>
    80003836:	84e2                	mv	s1,s8
    80003838:	b75d                	j	800037de <filewrite+0x7c>
    8000383a:	74e2                	ld	s1,56(sp)
    8000383c:	6ae2                	ld	s5,24(sp)
    8000383e:	6ba2                	ld	s7,8(sp)
    80003840:	6c02                	ld	s8,0(sp)
    80003842:	a039                	j	80003850 <filewrite+0xee>
    int i = 0;
    80003844:	4981                	li	s3,0
    80003846:	a029                	j	80003850 <filewrite+0xee>
    80003848:	74e2                	ld	s1,56(sp)
    8000384a:	6ae2                	ld	s5,24(sp)
    8000384c:	6ba2                	ld	s7,8(sp)
    8000384e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003850:	033a1c63          	bne	s4,s3,80003888 <filewrite+0x126>
    80003854:	8552                	mv	a0,s4
    80003856:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003858:	60a6                	ld	ra,72(sp)
    8000385a:	6406                	ld	s0,64(sp)
    8000385c:	7942                	ld	s2,48(sp)
    8000385e:	7a02                	ld	s4,32(sp)
    80003860:	6b42                	ld	s6,16(sp)
    80003862:	6161                	addi	sp,sp,80
    80003864:	8082                	ret
    80003866:	fc26                	sd	s1,56(sp)
    80003868:	f44e                	sd	s3,40(sp)
    8000386a:	ec56                	sd	s5,24(sp)
    8000386c:	e45e                	sd	s7,8(sp)
    8000386e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003870:	00004517          	auipc	a0,0x4
    80003874:	db850513          	addi	a0,a0,-584 # 80007628 <etext+0x628>
    80003878:	60b010ef          	jal	80005682 <panic>
    return -1;
    8000387c:	557d                	li	a0,-1
}
    8000387e:	8082                	ret
      return -1;
    80003880:	557d                	li	a0,-1
    80003882:	bfd9                	j	80003858 <filewrite+0xf6>
    80003884:	557d                	li	a0,-1
    80003886:	bfc9                	j	80003858 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80003888:	557d                	li	a0,-1
    8000388a:	79a2                	ld	s3,40(sp)
    8000388c:	b7f1                	j	80003858 <filewrite+0xf6>

000000008000388e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000388e:	7179                	addi	sp,sp,-48
    80003890:	f406                	sd	ra,40(sp)
    80003892:	f022                	sd	s0,32(sp)
    80003894:	ec26                	sd	s1,24(sp)
    80003896:	e052                	sd	s4,0(sp)
    80003898:	1800                	addi	s0,sp,48
    8000389a:	84aa                	mv	s1,a0
    8000389c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000389e:	0005b023          	sd	zero,0(a1)
    800038a2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800038a6:	c3bff0ef          	jal	800034e0 <filealloc>
    800038aa:	e088                	sd	a0,0(s1)
    800038ac:	c549                	beqz	a0,80003936 <pipealloc+0xa8>
    800038ae:	c33ff0ef          	jal	800034e0 <filealloc>
    800038b2:	00aa3023          	sd	a0,0(s4)
    800038b6:	cd25                	beqz	a0,8000392e <pipealloc+0xa0>
    800038b8:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800038ba:	91ffc0ef          	jal	800001d8 <kalloc>
    800038be:	892a                	mv	s2,a0
    800038c0:	c12d                	beqz	a0,80003922 <pipealloc+0x94>
    800038c2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800038c4:	4985                	li	s3,1
    800038c6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800038ca:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800038ce:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800038d2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800038d6:	00004597          	auipc	a1,0x4
    800038da:	d6258593          	addi	a1,a1,-670 # 80007638 <etext+0x638>
    800038de:	052020ef          	jal	80005930 <initlock>
  (*f0)->type = FD_PIPE;
    800038e2:	609c                	ld	a5,0(s1)
    800038e4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800038e8:	609c                	ld	a5,0(s1)
    800038ea:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800038ee:	609c                	ld	a5,0(s1)
    800038f0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800038f4:	609c                	ld	a5,0(s1)
    800038f6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800038fa:	000a3783          	ld	a5,0(s4)
    800038fe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003902:	000a3783          	ld	a5,0(s4)
    80003906:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000390a:	000a3783          	ld	a5,0(s4)
    8000390e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003912:	000a3783          	ld	a5,0(s4)
    80003916:	0127b823          	sd	s2,16(a5)
  return 0;
    8000391a:	4501                	li	a0,0
    8000391c:	6942                	ld	s2,16(sp)
    8000391e:	69a2                	ld	s3,8(sp)
    80003920:	a01d                	j	80003946 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003922:	6088                	ld	a0,0(s1)
    80003924:	c119                	beqz	a0,8000392a <pipealloc+0x9c>
    80003926:	6942                	ld	s2,16(sp)
    80003928:	a029                	j	80003932 <pipealloc+0xa4>
    8000392a:	6942                	ld	s2,16(sp)
    8000392c:	a029                	j	80003936 <pipealloc+0xa8>
    8000392e:	6088                	ld	a0,0(s1)
    80003930:	c10d                	beqz	a0,80003952 <pipealloc+0xc4>
    fileclose(*f0);
    80003932:	c53ff0ef          	jal	80003584 <fileclose>
  if(*f1)
    80003936:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000393a:	557d                	li	a0,-1
  if(*f1)
    8000393c:	c789                	beqz	a5,80003946 <pipealloc+0xb8>
    fileclose(*f1);
    8000393e:	853e                	mv	a0,a5
    80003940:	c45ff0ef          	jal	80003584 <fileclose>
  return -1;
    80003944:	557d                	li	a0,-1
}
    80003946:	70a2                	ld	ra,40(sp)
    80003948:	7402                	ld	s0,32(sp)
    8000394a:	64e2                	ld	s1,24(sp)
    8000394c:	6a02                	ld	s4,0(sp)
    8000394e:	6145                	addi	sp,sp,48
    80003950:	8082                	ret
  return -1;
    80003952:	557d                	li	a0,-1
    80003954:	bfcd                	j	80003946 <pipealloc+0xb8>

0000000080003956 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003956:	1101                	addi	sp,sp,-32
    80003958:	ec06                	sd	ra,24(sp)
    8000395a:	e822                	sd	s0,16(sp)
    8000395c:	e426                	sd	s1,8(sp)
    8000395e:	e04a                	sd	s2,0(sp)
    80003960:	1000                	addi	s0,sp,32
    80003962:	84aa                	mv	s1,a0
    80003964:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003966:	04a020ef          	jal	800059b0 <acquire>
  if(writable){
    8000396a:	02090763          	beqz	s2,80003998 <pipeclose+0x42>
    pi->writeopen = 0;
    8000396e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003972:	21848513          	addi	a0,s1,536
    80003976:	bc5fd0ef          	jal	8000153a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000397a:	2204b783          	ld	a5,544(s1)
    8000397e:	e785                	bnez	a5,800039a6 <pipeclose+0x50>
    release(&pi->lock);
    80003980:	8526                	mv	a0,s1
    80003982:	0c6020ef          	jal	80005a48 <release>
    kfree((char*)pi);
    80003986:	8526                	mv	a0,s1
    80003988:	f28fc0ef          	jal	800000b0 <kfree>
  } else
    release(&pi->lock);
}
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6902                	ld	s2,0(sp)
    80003994:	6105                	addi	sp,sp,32
    80003996:	8082                	ret
    pi->readopen = 0;
    80003998:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000399c:	21c48513          	addi	a0,s1,540
    800039a0:	b9bfd0ef          	jal	8000153a <wakeup>
    800039a4:	bfd9                	j	8000397a <pipeclose+0x24>
    release(&pi->lock);
    800039a6:	8526                	mv	a0,s1
    800039a8:	0a0020ef          	jal	80005a48 <release>
}
    800039ac:	b7c5                	j	8000398c <pipeclose+0x36>

00000000800039ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800039ae:	711d                	addi	sp,sp,-96
    800039b0:	ec86                	sd	ra,88(sp)
    800039b2:	e8a2                	sd	s0,80(sp)
    800039b4:	e4a6                	sd	s1,72(sp)
    800039b6:	e0ca                	sd	s2,64(sp)
    800039b8:	fc4e                	sd	s3,56(sp)
    800039ba:	f852                	sd	s4,48(sp)
    800039bc:	f456                	sd	s5,40(sp)
    800039be:	1080                	addi	s0,sp,96
    800039c0:	84aa                	mv	s1,a0
    800039c2:	8aae                	mv	s5,a1
    800039c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800039c6:	d5afd0ef          	jal	80000f20 <myproc>
    800039ca:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800039cc:	8526                	mv	a0,s1
    800039ce:	7e3010ef          	jal	800059b0 <acquire>
  while(i < n){
    800039d2:	0b405a63          	blez	s4,80003a86 <pipewrite+0xd8>
    800039d6:	f05a                	sd	s6,32(sp)
    800039d8:	ec5e                	sd	s7,24(sp)
    800039da:	e862                	sd	s8,16(sp)
  int i = 0;
    800039dc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800039de:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800039e0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800039e4:	21c48b93          	addi	s7,s1,540
    800039e8:	a81d                	j	80003a1e <pipewrite+0x70>
      release(&pi->lock);
    800039ea:	8526                	mv	a0,s1
    800039ec:	05c020ef          	jal	80005a48 <release>
      return -1;
    800039f0:	597d                	li	s2,-1
    800039f2:	7b02                	ld	s6,32(sp)
    800039f4:	6be2                	ld	s7,24(sp)
    800039f6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800039f8:	854a                	mv	a0,s2
    800039fa:	60e6                	ld	ra,88(sp)
    800039fc:	6446                	ld	s0,80(sp)
    800039fe:	64a6                	ld	s1,72(sp)
    80003a00:	6906                	ld	s2,64(sp)
    80003a02:	79e2                	ld	s3,56(sp)
    80003a04:	7a42                	ld	s4,48(sp)
    80003a06:	7aa2                	ld	s5,40(sp)
    80003a08:	6125                	addi	sp,sp,96
    80003a0a:	8082                	ret
      wakeup(&pi->nread);
    80003a0c:	8562                	mv	a0,s8
    80003a0e:	b2dfd0ef          	jal	8000153a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003a12:	85a6                	mv	a1,s1
    80003a14:	855e                	mv	a0,s7
    80003a16:	ad9fd0ef          	jal	800014ee <sleep>
  while(i < n){
    80003a1a:	05495b63          	bge	s2,s4,80003a70 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003a1e:	2204a783          	lw	a5,544(s1)
    80003a22:	d7e1                	beqz	a5,800039ea <pipewrite+0x3c>
    80003a24:	854e                	mv	a0,s3
    80003a26:	d01fd0ef          	jal	80001726 <killed>
    80003a2a:	f161                	bnez	a0,800039ea <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003a2c:	2184a783          	lw	a5,536(s1)
    80003a30:	21c4a703          	lw	a4,540(s1)
    80003a34:	2007879b          	addiw	a5,a5,512
    80003a38:	fcf70ae3          	beq	a4,a5,80003a0c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003a3c:	4685                	li	a3,1
    80003a3e:	01590633          	add	a2,s2,s5
    80003a42:	faf40593          	addi	a1,s0,-81
    80003a46:	0509b503          	ld	a0,80(s3)
    80003a4a:	a1efd0ef          	jal	80000c68 <copyin>
    80003a4e:	03650e63          	beq	a0,s6,80003a8a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003a52:	21c4a783          	lw	a5,540(s1)
    80003a56:	0017871b          	addiw	a4,a5,1
    80003a5a:	20e4ae23          	sw	a4,540(s1)
    80003a5e:	1ff7f793          	andi	a5,a5,511
    80003a62:	97a6                	add	a5,a5,s1
    80003a64:	faf44703          	lbu	a4,-81(s0)
    80003a68:	00e78c23          	sb	a4,24(a5)
      i++;
    80003a6c:	2905                	addiw	s2,s2,1
    80003a6e:	b775                	j	80003a1a <pipewrite+0x6c>
    80003a70:	7b02                	ld	s6,32(sp)
    80003a72:	6be2                	ld	s7,24(sp)
    80003a74:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003a76:	21848513          	addi	a0,s1,536
    80003a7a:	ac1fd0ef          	jal	8000153a <wakeup>
  release(&pi->lock);
    80003a7e:	8526                	mv	a0,s1
    80003a80:	7c9010ef          	jal	80005a48 <release>
  return i;
    80003a84:	bf95                	j	800039f8 <pipewrite+0x4a>
  int i = 0;
    80003a86:	4901                	li	s2,0
    80003a88:	b7fd                	j	80003a76 <pipewrite+0xc8>
    80003a8a:	7b02                	ld	s6,32(sp)
    80003a8c:	6be2                	ld	s7,24(sp)
    80003a8e:	6c42                	ld	s8,16(sp)
    80003a90:	b7dd                	j	80003a76 <pipewrite+0xc8>

0000000080003a92 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003a92:	715d                	addi	sp,sp,-80
    80003a94:	e486                	sd	ra,72(sp)
    80003a96:	e0a2                	sd	s0,64(sp)
    80003a98:	fc26                	sd	s1,56(sp)
    80003a9a:	f84a                	sd	s2,48(sp)
    80003a9c:	f44e                	sd	s3,40(sp)
    80003a9e:	f052                	sd	s4,32(sp)
    80003aa0:	ec56                	sd	s5,24(sp)
    80003aa2:	0880                	addi	s0,sp,80
    80003aa4:	84aa                	mv	s1,a0
    80003aa6:	892e                	mv	s2,a1
    80003aa8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003aaa:	c76fd0ef          	jal	80000f20 <myproc>
    80003aae:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	6ff010ef          	jal	800059b0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ab6:	2184a703          	lw	a4,536(s1)
    80003aba:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003abe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ac2:	02f71563          	bne	a4,a5,80003aec <piperead+0x5a>
    80003ac6:	2244a783          	lw	a5,548(s1)
    80003aca:	cb85                	beqz	a5,80003afa <piperead+0x68>
    if(killed(pr)){
    80003acc:	8552                	mv	a0,s4
    80003ace:	c59fd0ef          	jal	80001726 <killed>
    80003ad2:	ed19                	bnez	a0,80003af0 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003ad4:	85a6                	mv	a1,s1
    80003ad6:	854e                	mv	a0,s3
    80003ad8:	a17fd0ef          	jal	800014ee <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003adc:	2184a703          	lw	a4,536(s1)
    80003ae0:	21c4a783          	lw	a5,540(s1)
    80003ae4:	fef701e3          	beq	a4,a5,80003ac6 <piperead+0x34>
    80003ae8:	e85a                	sd	s6,16(sp)
    80003aea:	a809                	j	80003afc <piperead+0x6a>
    80003aec:	e85a                	sd	s6,16(sp)
    80003aee:	a039                	j	80003afc <piperead+0x6a>
      release(&pi->lock);
    80003af0:	8526                	mv	a0,s1
    80003af2:	757010ef          	jal	80005a48 <release>
      return -1;
    80003af6:	59fd                	li	s3,-1
    80003af8:	a8b1                	j	80003b54 <piperead+0xc2>
    80003afa:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003afc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003afe:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b00:	05505263          	blez	s5,80003b44 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003b04:	2184a783          	lw	a5,536(s1)
    80003b08:	21c4a703          	lw	a4,540(s1)
    80003b0c:	02f70c63          	beq	a4,a5,80003b44 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003b10:	0017871b          	addiw	a4,a5,1
    80003b14:	20e4ac23          	sw	a4,536(s1)
    80003b18:	1ff7f793          	andi	a5,a5,511
    80003b1c:	97a6                	add	a5,a5,s1
    80003b1e:	0187c783          	lbu	a5,24(a5)
    80003b22:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b26:	4685                	li	a3,1
    80003b28:	fbf40613          	addi	a2,s0,-65
    80003b2c:	85ca                	mv	a1,s2
    80003b2e:	050a3503          	ld	a0,80(s4)
    80003b32:	fb1fc0ef          	jal	80000ae2 <copyout>
    80003b36:	01650763          	beq	a0,s6,80003b44 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b3a:	2985                	addiw	s3,s3,1
    80003b3c:	0905                	addi	s2,s2,1
    80003b3e:	fd3a93e3          	bne	s5,s3,80003b04 <piperead+0x72>
    80003b42:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003b44:	21c48513          	addi	a0,s1,540
    80003b48:	9f3fd0ef          	jal	8000153a <wakeup>
  release(&pi->lock);
    80003b4c:	8526                	mv	a0,s1
    80003b4e:	6fb010ef          	jal	80005a48 <release>
    80003b52:	6b42                	ld	s6,16(sp)
  return i;
}
    80003b54:	854e                	mv	a0,s3
    80003b56:	60a6                	ld	ra,72(sp)
    80003b58:	6406                	ld	s0,64(sp)
    80003b5a:	74e2                	ld	s1,56(sp)
    80003b5c:	7942                	ld	s2,48(sp)
    80003b5e:	79a2                	ld	s3,40(sp)
    80003b60:	7a02                	ld	s4,32(sp)
    80003b62:	6ae2                	ld	s5,24(sp)
    80003b64:	6161                	addi	sp,sp,80
    80003b66:	8082                	ret

0000000080003b68 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003b68:	1141                	addi	sp,sp,-16
    80003b6a:	e422                	sd	s0,8(sp)
    80003b6c:	0800                	addi	s0,sp,16
    80003b6e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003b70:	8905                	andi	a0,a0,1
    80003b72:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003b74:	8b89                	andi	a5,a5,2
    80003b76:	c399                	beqz	a5,80003b7c <flags2perm+0x14>
      perm |= PTE_W;
    80003b78:	00456513          	ori	a0,a0,4
    return perm;
}
    80003b7c:	6422                	ld	s0,8(sp)
    80003b7e:	0141                	addi	sp,sp,16
    80003b80:	8082                	ret

0000000080003b82 <exec>:

int
exec(char *path, char **argv)
{
    80003b82:	df010113          	addi	sp,sp,-528
    80003b86:	20113423          	sd	ra,520(sp)
    80003b8a:	20813023          	sd	s0,512(sp)
    80003b8e:	ffa6                	sd	s1,504(sp)
    80003b90:	fbca                	sd	s2,496(sp)
    80003b92:	0c00                	addi	s0,sp,528
    80003b94:	892a                	mv	s2,a0
    80003b96:	dea43c23          	sd	a0,-520(s0)
    80003b9a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003b9e:	b82fd0ef          	jal	80000f20 <myproc>
    80003ba2:	84aa                	mv	s1,a0

  begin_op();
    80003ba4:	dc6ff0ef          	jal	8000316a <begin_op>

  if((ip = namei(path)) == 0){
    80003ba8:	854a                	mv	a0,s2
    80003baa:	c04ff0ef          	jal	80002fae <namei>
    80003bae:	c931                	beqz	a0,80003c02 <exec+0x80>
    80003bb0:	f3d2                	sd	s4,480(sp)
    80003bb2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003bb4:	d21fe0ef          	jal	800028d4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003bb8:	04000713          	li	a4,64
    80003bbc:	4681                	li	a3,0
    80003bbe:	e5040613          	addi	a2,s0,-432
    80003bc2:	4581                	li	a1,0
    80003bc4:	8552                	mv	a0,s4
    80003bc6:	f63fe0ef          	jal	80002b28 <readi>
    80003bca:	04000793          	li	a5,64
    80003bce:	00f51a63          	bne	a0,a5,80003be2 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003bd2:	e5042703          	lw	a4,-432(s0)
    80003bd6:	464c47b7          	lui	a5,0x464c4
    80003bda:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003bde:	02f70663          	beq	a4,a5,80003c0a <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003be2:	8552                	mv	a0,s4
    80003be4:	efbfe0ef          	jal	80002ade <iunlockput>
    end_op();
    80003be8:	decff0ef          	jal	800031d4 <end_op>
  }
  return -1;
    80003bec:	557d                	li	a0,-1
    80003bee:	7a1e                	ld	s4,480(sp)
}
    80003bf0:	20813083          	ld	ra,520(sp)
    80003bf4:	20013403          	ld	s0,512(sp)
    80003bf8:	74fe                	ld	s1,504(sp)
    80003bfa:	795e                	ld	s2,496(sp)
    80003bfc:	21010113          	addi	sp,sp,528
    80003c00:	8082                	ret
    end_op();
    80003c02:	dd2ff0ef          	jal	800031d4 <end_op>
    return -1;
    80003c06:	557d                	li	a0,-1
    80003c08:	b7e5                	j	80003bf0 <exec+0x6e>
    80003c0a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	bbafd0ef          	jal	80000fc8 <proc_pagetable>
    80003c12:	8b2a                	mv	s6,a0
    80003c14:	2c050b63          	beqz	a0,80003eea <exec+0x368>
    80003c18:	f7ce                	sd	s3,488(sp)
    80003c1a:	efd6                	sd	s5,472(sp)
    80003c1c:	e7de                	sd	s7,456(sp)
    80003c1e:	e3e2                	sd	s8,448(sp)
    80003c20:	ff66                	sd	s9,440(sp)
    80003c22:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c24:	e7042d03          	lw	s10,-400(s0)
    80003c28:	e8845783          	lhu	a5,-376(s0)
    80003c2c:	12078963          	beqz	a5,80003d5e <exec+0x1dc>
    80003c30:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c32:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c34:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003c36:	6c85                	lui	s9,0x1
    80003c38:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003c3c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003c40:	6a85                	lui	s5,0x1
    80003c42:	a085                	j	80003ca2 <exec+0x120>
      panic("loadseg: address should exist");
    80003c44:	00004517          	auipc	a0,0x4
    80003c48:	9fc50513          	addi	a0,a0,-1540 # 80007640 <etext+0x640>
    80003c4c:	237010ef          	jal	80005682 <panic>
    if(sz - i < PGSIZE)
    80003c50:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003c52:	8726                	mv	a4,s1
    80003c54:	012c06bb          	addw	a3,s8,s2
    80003c58:	4581                	li	a1,0
    80003c5a:	8552                	mv	a0,s4
    80003c5c:	ecdfe0ef          	jal	80002b28 <readi>
    80003c60:	2501                	sext.w	a0,a0
    80003c62:	24a49a63          	bne	s1,a0,80003eb6 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003c66:	012a893b          	addw	s2,s5,s2
    80003c6a:	03397363          	bgeu	s2,s3,80003c90 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003c6e:	02091593          	slli	a1,s2,0x20
    80003c72:	9181                	srli	a1,a1,0x20
    80003c74:	95de                	add	a1,a1,s7
    80003c76:	855a                	mv	a0,s6
    80003c78:	8d9fc0ef          	jal	80000550 <walkaddr>
    80003c7c:	862a                	mv	a2,a0
    if(pa == 0)
    80003c7e:	d179                	beqz	a0,80003c44 <exec+0xc2>
    if(sz - i < PGSIZE)
    80003c80:	412984bb          	subw	s1,s3,s2
    80003c84:	0004879b          	sext.w	a5,s1
    80003c88:	fcfcf4e3          	bgeu	s9,a5,80003c50 <exec+0xce>
    80003c8c:	84d6                	mv	s1,s5
    80003c8e:	b7c9                	j	80003c50 <exec+0xce>
    sz = sz1;
    80003c90:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c94:	2d85                	addiw	s11,s11,1
    80003c96:	038d0d1b          	addiw	s10,s10,56 # fffffffffffff038 <end+0xffffffff7ffbb988>
    80003c9a:	e8845783          	lhu	a5,-376(s0)
    80003c9e:	08fdd063          	bge	s11,a5,80003d1e <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003ca2:	2d01                	sext.w	s10,s10
    80003ca4:	03800713          	li	a4,56
    80003ca8:	86ea                	mv	a3,s10
    80003caa:	e1840613          	addi	a2,s0,-488
    80003cae:	4581                	li	a1,0
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	e77fe0ef          	jal	80002b28 <readi>
    80003cb6:	03800793          	li	a5,56
    80003cba:	1cf51663          	bne	a0,a5,80003e86 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003cbe:	e1842783          	lw	a5,-488(s0)
    80003cc2:	4705                	li	a4,1
    80003cc4:	fce798e3          	bne	a5,a4,80003c94 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80003cc8:	e4043483          	ld	s1,-448(s0)
    80003ccc:	e3843783          	ld	a5,-456(s0)
    80003cd0:	1af4ef63          	bltu	s1,a5,80003e8e <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003cd4:	e2843783          	ld	a5,-472(s0)
    80003cd8:	94be                	add	s1,s1,a5
    80003cda:	1af4ee63          	bltu	s1,a5,80003e96 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003cde:	df043703          	ld	a4,-528(s0)
    80003ce2:	8ff9                	and	a5,a5,a4
    80003ce4:	1a079d63          	bnez	a5,80003e9e <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003ce8:	e1c42503          	lw	a0,-484(s0)
    80003cec:	e7dff0ef          	jal	80003b68 <flags2perm>
    80003cf0:	86aa                	mv	a3,a0
    80003cf2:	8626                	mv	a2,s1
    80003cf4:	85ca                	mv	a1,s2
    80003cf6:	855a                	mv	a0,s6
    80003cf8:	bc1fc0ef          	jal	800008b8 <uvmalloc>
    80003cfc:	e0a43423          	sd	a0,-504(s0)
    80003d00:	1a050363          	beqz	a0,80003ea6 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003d04:	e2843b83          	ld	s7,-472(s0)
    80003d08:	e2042c03          	lw	s8,-480(s0)
    80003d0c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003d10:	00098463          	beqz	s3,80003d18 <exec+0x196>
    80003d14:	4901                	li	s2,0
    80003d16:	bfa1                	j	80003c6e <exec+0xec>
    sz = sz1;
    80003d18:	e0843903          	ld	s2,-504(s0)
    80003d1c:	bfa5                	j	80003c94 <exec+0x112>
    80003d1e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003d20:	8552                	mv	a0,s4
    80003d22:	dbdfe0ef          	jal	80002ade <iunlockput>
  end_op();
    80003d26:	caeff0ef          	jal	800031d4 <end_op>
  p = myproc();
    80003d2a:	9f6fd0ef          	jal	80000f20 <myproc>
    80003d2e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003d30:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003d34:	6985                	lui	s3,0x1
    80003d36:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003d38:	99ca                	add	s3,s3,s2
    80003d3a:	77fd                	lui	a5,0xfffff
    80003d3c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d40:	4691                	li	a3,4
    80003d42:	6609                	lui	a2,0x2
    80003d44:	964e                	add	a2,a2,s3
    80003d46:	85ce                	mv	a1,s3
    80003d48:	855a                	mv	a0,s6
    80003d4a:	b6ffc0ef          	jal	800008b8 <uvmalloc>
    80003d4e:	892a                	mv	s2,a0
    80003d50:	e0a43423          	sd	a0,-504(s0)
    80003d54:	e519                	bnez	a0,80003d62 <exec+0x1e0>
  if(pagetable)
    80003d56:	e1343423          	sd	s3,-504(s0)
    80003d5a:	4a01                	li	s4,0
    80003d5c:	aab1                	j	80003eb8 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d5e:	4901                	li	s2,0
    80003d60:	b7c1                	j	80003d20 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003d62:	75f9                	lui	a1,0xffffe
    80003d64:	95aa                	add	a1,a1,a0
    80003d66:	855a                	mv	a0,s6
    80003d68:	d51fc0ef          	jal	80000ab8 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003d6c:	7bfd                	lui	s7,0xfffff
    80003d6e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003d70:	e0043783          	ld	a5,-512(s0)
    80003d74:	6388                	ld	a0,0(a5)
    80003d76:	cd39                	beqz	a0,80003dd4 <exec+0x252>
    80003d78:	e9040993          	addi	s3,s0,-368
    80003d7c:	f9040c13          	addi	s8,s0,-112
    80003d80:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003d82:	e30fc0ef          	jal	800003b2 <strlen>
    80003d86:	0015079b          	addiw	a5,a0,1
    80003d8a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003d8e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003d92:	11796e63          	bltu	s2,s7,80003eae <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003d96:	e0043d03          	ld	s10,-512(s0)
    80003d9a:	000d3a03          	ld	s4,0(s10)
    80003d9e:	8552                	mv	a0,s4
    80003da0:	e12fc0ef          	jal	800003b2 <strlen>
    80003da4:	0015069b          	addiw	a3,a0,1
    80003da8:	8652                	mv	a2,s4
    80003daa:	85ca                	mv	a1,s2
    80003dac:	855a                	mv	a0,s6
    80003dae:	d35fc0ef          	jal	80000ae2 <copyout>
    80003db2:	10054063          	bltz	a0,80003eb2 <exec+0x330>
    ustack[argc] = sp;
    80003db6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003dba:	0485                	addi	s1,s1,1
    80003dbc:	008d0793          	addi	a5,s10,8
    80003dc0:	e0f43023          	sd	a5,-512(s0)
    80003dc4:	008d3503          	ld	a0,8(s10)
    80003dc8:	c909                	beqz	a0,80003dda <exec+0x258>
    if(argc >= MAXARG)
    80003dca:	09a1                	addi	s3,s3,8
    80003dcc:	fb899be3          	bne	s3,s8,80003d82 <exec+0x200>
  ip = 0;
    80003dd0:	4a01                	li	s4,0
    80003dd2:	a0dd                	j	80003eb8 <exec+0x336>
  sp = sz;
    80003dd4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003dd8:	4481                	li	s1,0
  ustack[argc] = 0;
    80003dda:	00349793          	slli	a5,s1,0x3
    80003dde:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffbb8e0>
    80003de2:	97a2                	add	a5,a5,s0
    80003de4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003de8:	00148693          	addi	a3,s1,1
    80003dec:	068e                	slli	a3,a3,0x3
    80003dee:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003df2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003df6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003dfa:	f5796ee3          	bltu	s2,s7,80003d56 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003dfe:	e9040613          	addi	a2,s0,-368
    80003e02:	85ca                	mv	a1,s2
    80003e04:	855a                	mv	a0,s6
    80003e06:	cddfc0ef          	jal	80000ae2 <copyout>
    80003e0a:	0e054263          	bltz	a0,80003eee <exec+0x36c>
  p->trapframe->a1 = sp;
    80003e0e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003e12:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003e16:	df843783          	ld	a5,-520(s0)
    80003e1a:	0007c703          	lbu	a4,0(a5)
    80003e1e:	cf11                	beqz	a4,80003e3a <exec+0x2b8>
    80003e20:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003e22:	02f00693          	li	a3,47
    80003e26:	a039                	j	80003e34 <exec+0x2b2>
      last = s+1;
    80003e28:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003e2c:	0785                	addi	a5,a5,1
    80003e2e:	fff7c703          	lbu	a4,-1(a5)
    80003e32:	c701                	beqz	a4,80003e3a <exec+0x2b8>
    if(*s == '/')
    80003e34:	fed71ce3          	bne	a4,a3,80003e2c <exec+0x2aa>
    80003e38:	bfc5                	j	80003e28 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e3a:	4641                	li	a2,16
    80003e3c:	df843583          	ld	a1,-520(s0)
    80003e40:	158a8513          	addi	a0,s5,344
    80003e44:	d3cfc0ef          	jal	80000380 <safestrcpy>
  oldpagetable = p->pagetable;
    80003e48:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003e4c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003e50:	e0843783          	ld	a5,-504(s0)
    80003e54:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e58:	058ab783          	ld	a5,88(s5)
    80003e5c:	e6843703          	ld	a4,-408(s0)
    80003e60:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003e62:	058ab783          	ld	a5,88(s5)
    80003e66:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003e6a:	85e6                	mv	a1,s9
    80003e6c:	9e0fd0ef          	jal	8000104c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003e70:	0004851b          	sext.w	a0,s1
    80003e74:	79be                	ld	s3,488(sp)
    80003e76:	7a1e                	ld	s4,480(sp)
    80003e78:	6afe                	ld	s5,472(sp)
    80003e7a:	6b5e                	ld	s6,464(sp)
    80003e7c:	6bbe                	ld	s7,456(sp)
    80003e7e:	6c1e                	ld	s8,448(sp)
    80003e80:	7cfa                	ld	s9,440(sp)
    80003e82:	7d5a                	ld	s10,432(sp)
    80003e84:	b3b5                	j	80003bf0 <exec+0x6e>
    80003e86:	e1243423          	sd	s2,-504(s0)
    80003e8a:	7dba                	ld	s11,424(sp)
    80003e8c:	a035                	j	80003eb8 <exec+0x336>
    80003e8e:	e1243423          	sd	s2,-504(s0)
    80003e92:	7dba                	ld	s11,424(sp)
    80003e94:	a015                	j	80003eb8 <exec+0x336>
    80003e96:	e1243423          	sd	s2,-504(s0)
    80003e9a:	7dba                	ld	s11,424(sp)
    80003e9c:	a831                	j	80003eb8 <exec+0x336>
    80003e9e:	e1243423          	sd	s2,-504(s0)
    80003ea2:	7dba                	ld	s11,424(sp)
    80003ea4:	a811                	j	80003eb8 <exec+0x336>
    80003ea6:	e1243423          	sd	s2,-504(s0)
    80003eaa:	7dba                	ld	s11,424(sp)
    80003eac:	a031                	j	80003eb8 <exec+0x336>
  ip = 0;
    80003eae:	4a01                	li	s4,0
    80003eb0:	a021                	j	80003eb8 <exec+0x336>
    80003eb2:	4a01                	li	s4,0
  if(pagetable)
    80003eb4:	a011                	j	80003eb8 <exec+0x336>
    80003eb6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003eb8:	e0843583          	ld	a1,-504(s0)
    80003ebc:	855a                	mv	a0,s6
    80003ebe:	98efd0ef          	jal	8000104c <proc_freepagetable>
  return -1;
    80003ec2:	557d                	li	a0,-1
  if(ip){
    80003ec4:	000a1b63          	bnez	s4,80003eda <exec+0x358>
    80003ec8:	79be                	ld	s3,488(sp)
    80003eca:	7a1e                	ld	s4,480(sp)
    80003ecc:	6afe                	ld	s5,472(sp)
    80003ece:	6b5e                	ld	s6,464(sp)
    80003ed0:	6bbe                	ld	s7,456(sp)
    80003ed2:	6c1e                	ld	s8,448(sp)
    80003ed4:	7cfa                	ld	s9,440(sp)
    80003ed6:	7d5a                	ld	s10,432(sp)
    80003ed8:	bb21                	j	80003bf0 <exec+0x6e>
    80003eda:	79be                	ld	s3,488(sp)
    80003edc:	6afe                	ld	s5,472(sp)
    80003ede:	6b5e                	ld	s6,464(sp)
    80003ee0:	6bbe                	ld	s7,456(sp)
    80003ee2:	6c1e                	ld	s8,448(sp)
    80003ee4:	7cfa                	ld	s9,440(sp)
    80003ee6:	7d5a                	ld	s10,432(sp)
    80003ee8:	b9ed                	j	80003be2 <exec+0x60>
    80003eea:	6b5e                	ld	s6,464(sp)
    80003eec:	b9dd                	j	80003be2 <exec+0x60>
  sz = sz1;
    80003eee:	e0843983          	ld	s3,-504(s0)
    80003ef2:	b595                	j	80003d56 <exec+0x1d4>

0000000080003ef4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003ef4:	7179                	addi	sp,sp,-48
    80003ef6:	f406                	sd	ra,40(sp)
    80003ef8:	f022                	sd	s0,32(sp)
    80003efa:	ec26                	sd	s1,24(sp)
    80003efc:	e84a                	sd	s2,16(sp)
    80003efe:	1800                	addi	s0,sp,48
    80003f00:	892e                	mv	s2,a1
    80003f02:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003f04:	fdc40593          	addi	a1,s0,-36
    80003f08:	fa1fd0ef          	jal	80001ea8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003f0c:	fdc42703          	lw	a4,-36(s0)
    80003f10:	47bd                	li	a5,15
    80003f12:	02e7e963          	bltu	a5,a4,80003f44 <argfd+0x50>
    80003f16:	80afd0ef          	jal	80000f20 <myproc>
    80003f1a:	fdc42703          	lw	a4,-36(s0)
    80003f1e:	01a70793          	addi	a5,a4,26
    80003f22:	078e                	slli	a5,a5,0x3
    80003f24:	953e                	add	a0,a0,a5
    80003f26:	611c                	ld	a5,0(a0)
    80003f28:	c385                	beqz	a5,80003f48 <argfd+0x54>
    return -1;
  if(pfd)
    80003f2a:	00090463          	beqz	s2,80003f32 <argfd+0x3e>
    *pfd = fd;
    80003f2e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003f32:	4501                	li	a0,0
  if(pf)
    80003f34:	c091                	beqz	s1,80003f38 <argfd+0x44>
    *pf = f;
    80003f36:	e09c                	sd	a5,0(s1)
}
    80003f38:	70a2                	ld	ra,40(sp)
    80003f3a:	7402                	ld	s0,32(sp)
    80003f3c:	64e2                	ld	s1,24(sp)
    80003f3e:	6942                	ld	s2,16(sp)
    80003f40:	6145                	addi	sp,sp,48
    80003f42:	8082                	ret
    return -1;
    80003f44:	557d                	li	a0,-1
    80003f46:	bfcd                	j	80003f38 <argfd+0x44>
    80003f48:	557d                	li	a0,-1
    80003f4a:	b7fd                	j	80003f38 <argfd+0x44>

0000000080003f4c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003f4c:	1101                	addi	sp,sp,-32
    80003f4e:	ec06                	sd	ra,24(sp)
    80003f50:	e822                	sd	s0,16(sp)
    80003f52:	e426                	sd	s1,8(sp)
    80003f54:	1000                	addi	s0,sp,32
    80003f56:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003f58:	fc9fc0ef          	jal	80000f20 <myproc>
    80003f5c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003f5e:	0d050793          	addi	a5,a0,208
    80003f62:	4501                	li	a0,0
    80003f64:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003f66:	6398                	ld	a4,0(a5)
    80003f68:	cb19                	beqz	a4,80003f7e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003f6a:	2505                	addiw	a0,a0,1
    80003f6c:	07a1                	addi	a5,a5,8
    80003f6e:	fed51ce3          	bne	a0,a3,80003f66 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003f72:	557d                	li	a0,-1
}
    80003f74:	60e2                	ld	ra,24(sp)
    80003f76:	6442                	ld	s0,16(sp)
    80003f78:	64a2                	ld	s1,8(sp)
    80003f7a:	6105                	addi	sp,sp,32
    80003f7c:	8082                	ret
      p->ofile[fd] = f;
    80003f7e:	01a50793          	addi	a5,a0,26
    80003f82:	078e                	slli	a5,a5,0x3
    80003f84:	963e                	add	a2,a2,a5
    80003f86:	e204                	sd	s1,0(a2)
      return fd;
    80003f88:	b7f5                	j	80003f74 <fdalloc+0x28>

0000000080003f8a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003f8a:	715d                	addi	sp,sp,-80
    80003f8c:	e486                	sd	ra,72(sp)
    80003f8e:	e0a2                	sd	s0,64(sp)
    80003f90:	fc26                	sd	s1,56(sp)
    80003f92:	f84a                	sd	s2,48(sp)
    80003f94:	f44e                	sd	s3,40(sp)
    80003f96:	ec56                	sd	s5,24(sp)
    80003f98:	e85a                	sd	s6,16(sp)
    80003f9a:	0880                	addi	s0,sp,80
    80003f9c:	8b2e                	mv	s6,a1
    80003f9e:	89b2                	mv	s3,a2
    80003fa0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003fa2:	fb040593          	addi	a1,s0,-80
    80003fa6:	822ff0ef          	jal	80002fc8 <nameiparent>
    80003faa:	84aa                	mv	s1,a0
    80003fac:	10050a63          	beqz	a0,800040c0 <create+0x136>
    return 0;

  ilock(dp);
    80003fb0:	925fe0ef          	jal	800028d4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fb4:	4601                	li	a2,0
    80003fb6:	fb040593          	addi	a1,s0,-80
    80003fba:	8526                	mv	a0,s1
    80003fbc:	d8dfe0ef          	jal	80002d48 <dirlookup>
    80003fc0:	8aaa                	mv	s5,a0
    80003fc2:	c129                	beqz	a0,80004004 <create+0x7a>
    iunlockput(dp);
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	b19fe0ef          	jal	80002ade <iunlockput>
    ilock(ip);
    80003fca:	8556                	mv	a0,s5
    80003fcc:	909fe0ef          	jal	800028d4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003fd0:	4789                	li	a5,2
    80003fd2:	02fb1463          	bne	s6,a5,80003ffa <create+0x70>
    80003fd6:	044ad783          	lhu	a5,68(s5)
    80003fda:	37f9                	addiw	a5,a5,-2
    80003fdc:	17c2                	slli	a5,a5,0x30
    80003fde:	93c1                	srli	a5,a5,0x30
    80003fe0:	4705                	li	a4,1
    80003fe2:	00f76c63          	bltu	a4,a5,80003ffa <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003fe6:	8556                	mv	a0,s5
    80003fe8:	60a6                	ld	ra,72(sp)
    80003fea:	6406                	ld	s0,64(sp)
    80003fec:	74e2                	ld	s1,56(sp)
    80003fee:	7942                	ld	s2,48(sp)
    80003ff0:	79a2                	ld	s3,40(sp)
    80003ff2:	6ae2                	ld	s5,24(sp)
    80003ff4:	6b42                	ld	s6,16(sp)
    80003ff6:	6161                	addi	sp,sp,80
    80003ff8:	8082                	ret
    iunlockput(ip);
    80003ffa:	8556                	mv	a0,s5
    80003ffc:	ae3fe0ef          	jal	80002ade <iunlockput>
    return 0;
    80004000:	4a81                	li	s5,0
    80004002:	b7d5                	j	80003fe6 <create+0x5c>
    80004004:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004006:	85da                	mv	a1,s6
    80004008:	4088                	lw	a0,0(s1)
    8000400a:	f5afe0ef          	jal	80002764 <ialloc>
    8000400e:	8a2a                	mv	s4,a0
    80004010:	cd15                	beqz	a0,8000404c <create+0xc2>
  ilock(ip);
    80004012:	8c3fe0ef          	jal	800028d4 <ilock>
  ip->major = major;
    80004016:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000401a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000401e:	4905                	li	s2,1
    80004020:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004024:	8552                	mv	a0,s4
    80004026:	ffafe0ef          	jal	80002820 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000402a:	032b0763          	beq	s6,s2,80004058 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000402e:	004a2603          	lw	a2,4(s4)
    80004032:	fb040593          	addi	a1,s0,-80
    80004036:	8526                	mv	a0,s1
    80004038:	eddfe0ef          	jal	80002f14 <dirlink>
    8000403c:	06054563          	bltz	a0,800040a6 <create+0x11c>
  iunlockput(dp);
    80004040:	8526                	mv	a0,s1
    80004042:	a9dfe0ef          	jal	80002ade <iunlockput>
  return ip;
    80004046:	8ad2                	mv	s5,s4
    80004048:	7a02                	ld	s4,32(sp)
    8000404a:	bf71                	j	80003fe6 <create+0x5c>
    iunlockput(dp);
    8000404c:	8526                	mv	a0,s1
    8000404e:	a91fe0ef          	jal	80002ade <iunlockput>
    return 0;
    80004052:	8ad2                	mv	s5,s4
    80004054:	7a02                	ld	s4,32(sp)
    80004056:	bf41                	j	80003fe6 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004058:	004a2603          	lw	a2,4(s4)
    8000405c:	00003597          	auipc	a1,0x3
    80004060:	60458593          	addi	a1,a1,1540 # 80007660 <etext+0x660>
    80004064:	8552                	mv	a0,s4
    80004066:	eaffe0ef          	jal	80002f14 <dirlink>
    8000406a:	02054e63          	bltz	a0,800040a6 <create+0x11c>
    8000406e:	40d0                	lw	a2,4(s1)
    80004070:	00003597          	auipc	a1,0x3
    80004074:	5f858593          	addi	a1,a1,1528 # 80007668 <etext+0x668>
    80004078:	8552                	mv	a0,s4
    8000407a:	e9bfe0ef          	jal	80002f14 <dirlink>
    8000407e:	02054463          	bltz	a0,800040a6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004082:	004a2603          	lw	a2,4(s4)
    80004086:	fb040593          	addi	a1,s0,-80
    8000408a:	8526                	mv	a0,s1
    8000408c:	e89fe0ef          	jal	80002f14 <dirlink>
    80004090:	00054b63          	bltz	a0,800040a6 <create+0x11c>
    dp->nlink++;  // for ".."
    80004094:	04a4d783          	lhu	a5,74(s1)
    80004098:	2785                	addiw	a5,a5,1
    8000409a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000409e:	8526                	mv	a0,s1
    800040a0:	f80fe0ef          	jal	80002820 <iupdate>
    800040a4:	bf71                	j	80004040 <create+0xb6>
  ip->nlink = 0;
    800040a6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800040aa:	8552                	mv	a0,s4
    800040ac:	f74fe0ef          	jal	80002820 <iupdate>
  iunlockput(ip);
    800040b0:	8552                	mv	a0,s4
    800040b2:	a2dfe0ef          	jal	80002ade <iunlockput>
  iunlockput(dp);
    800040b6:	8526                	mv	a0,s1
    800040b8:	a27fe0ef          	jal	80002ade <iunlockput>
  return 0;
    800040bc:	7a02                	ld	s4,32(sp)
    800040be:	b725                	j	80003fe6 <create+0x5c>
    return 0;
    800040c0:	8aaa                	mv	s5,a0
    800040c2:	b715                	j	80003fe6 <create+0x5c>

00000000800040c4 <sys_dup>:
{
    800040c4:	7179                	addi	sp,sp,-48
    800040c6:	f406                	sd	ra,40(sp)
    800040c8:	f022                	sd	s0,32(sp)
    800040ca:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800040cc:	fd840613          	addi	a2,s0,-40
    800040d0:	4581                	li	a1,0
    800040d2:	4501                	li	a0,0
    800040d4:	e21ff0ef          	jal	80003ef4 <argfd>
    return -1;
    800040d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800040da:	02054363          	bltz	a0,80004100 <sys_dup+0x3c>
    800040de:	ec26                	sd	s1,24(sp)
    800040e0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800040e2:	fd843903          	ld	s2,-40(s0)
    800040e6:	854a                	mv	a0,s2
    800040e8:	e65ff0ef          	jal	80003f4c <fdalloc>
    800040ec:	84aa                	mv	s1,a0
    return -1;
    800040ee:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800040f0:	00054d63          	bltz	a0,8000410a <sys_dup+0x46>
  filedup(f);
    800040f4:	854a                	mv	a0,s2
    800040f6:	c48ff0ef          	jal	8000353e <filedup>
  return fd;
    800040fa:	87a6                	mv	a5,s1
    800040fc:	64e2                	ld	s1,24(sp)
    800040fe:	6942                	ld	s2,16(sp)
}
    80004100:	853e                	mv	a0,a5
    80004102:	70a2                	ld	ra,40(sp)
    80004104:	7402                	ld	s0,32(sp)
    80004106:	6145                	addi	sp,sp,48
    80004108:	8082                	ret
    8000410a:	64e2                	ld	s1,24(sp)
    8000410c:	6942                	ld	s2,16(sp)
    8000410e:	bfcd                	j	80004100 <sys_dup+0x3c>

0000000080004110 <sys_read>:
{
    80004110:	7179                	addi	sp,sp,-48
    80004112:	f406                	sd	ra,40(sp)
    80004114:	f022                	sd	s0,32(sp)
    80004116:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004118:	fd840593          	addi	a1,s0,-40
    8000411c:	4505                	li	a0,1
    8000411e:	da7fd0ef          	jal	80001ec4 <argaddr>
  argint(2, &n);
    80004122:	fe440593          	addi	a1,s0,-28
    80004126:	4509                	li	a0,2
    80004128:	d81fd0ef          	jal	80001ea8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000412c:	fe840613          	addi	a2,s0,-24
    80004130:	4581                	li	a1,0
    80004132:	4501                	li	a0,0
    80004134:	dc1ff0ef          	jal	80003ef4 <argfd>
    80004138:	87aa                	mv	a5,a0
    return -1;
    8000413a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000413c:	0007ca63          	bltz	a5,80004150 <sys_read+0x40>
  return fileread(f, p, n);
    80004140:	fe442603          	lw	a2,-28(s0)
    80004144:	fd843583          	ld	a1,-40(s0)
    80004148:	fe843503          	ld	a0,-24(s0)
    8000414c:	d58ff0ef          	jal	800036a4 <fileread>
}
    80004150:	70a2                	ld	ra,40(sp)
    80004152:	7402                	ld	s0,32(sp)
    80004154:	6145                	addi	sp,sp,48
    80004156:	8082                	ret

0000000080004158 <sys_write>:
{
    80004158:	7179                	addi	sp,sp,-48
    8000415a:	f406                	sd	ra,40(sp)
    8000415c:	f022                	sd	s0,32(sp)
    8000415e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004160:	fd840593          	addi	a1,s0,-40
    80004164:	4505                	li	a0,1
    80004166:	d5ffd0ef          	jal	80001ec4 <argaddr>
  argint(2, &n);
    8000416a:	fe440593          	addi	a1,s0,-28
    8000416e:	4509                	li	a0,2
    80004170:	d39fd0ef          	jal	80001ea8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004174:	fe840613          	addi	a2,s0,-24
    80004178:	4581                	li	a1,0
    8000417a:	4501                	li	a0,0
    8000417c:	d79ff0ef          	jal	80003ef4 <argfd>
    80004180:	87aa                	mv	a5,a0
    return -1;
    80004182:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004184:	0007ca63          	bltz	a5,80004198 <sys_write+0x40>
  return filewrite(f, p, n);
    80004188:	fe442603          	lw	a2,-28(s0)
    8000418c:	fd843583          	ld	a1,-40(s0)
    80004190:	fe843503          	ld	a0,-24(s0)
    80004194:	dceff0ef          	jal	80003762 <filewrite>
}
    80004198:	70a2                	ld	ra,40(sp)
    8000419a:	7402                	ld	s0,32(sp)
    8000419c:	6145                	addi	sp,sp,48
    8000419e:	8082                	ret

00000000800041a0 <sys_close>:
{
    800041a0:	1101                	addi	sp,sp,-32
    800041a2:	ec06                	sd	ra,24(sp)
    800041a4:	e822                	sd	s0,16(sp)
    800041a6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800041a8:	fe040613          	addi	a2,s0,-32
    800041ac:	fec40593          	addi	a1,s0,-20
    800041b0:	4501                	li	a0,0
    800041b2:	d43ff0ef          	jal	80003ef4 <argfd>
    return -1;
    800041b6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800041b8:	02054063          	bltz	a0,800041d8 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800041bc:	d65fc0ef          	jal	80000f20 <myproc>
    800041c0:	fec42783          	lw	a5,-20(s0)
    800041c4:	07e9                	addi	a5,a5,26
    800041c6:	078e                	slli	a5,a5,0x3
    800041c8:	953e                	add	a0,a0,a5
    800041ca:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800041ce:	fe043503          	ld	a0,-32(s0)
    800041d2:	bb2ff0ef          	jal	80003584 <fileclose>
  return 0;
    800041d6:	4781                	li	a5,0
}
    800041d8:	853e                	mv	a0,a5
    800041da:	60e2                	ld	ra,24(sp)
    800041dc:	6442                	ld	s0,16(sp)
    800041de:	6105                	addi	sp,sp,32
    800041e0:	8082                	ret

00000000800041e2 <sys_fstat>:
{
    800041e2:	1101                	addi	sp,sp,-32
    800041e4:	ec06                	sd	ra,24(sp)
    800041e6:	e822                	sd	s0,16(sp)
    800041e8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800041ea:	fe040593          	addi	a1,s0,-32
    800041ee:	4505                	li	a0,1
    800041f0:	cd5fd0ef          	jal	80001ec4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800041f4:	fe840613          	addi	a2,s0,-24
    800041f8:	4581                	li	a1,0
    800041fa:	4501                	li	a0,0
    800041fc:	cf9ff0ef          	jal	80003ef4 <argfd>
    80004200:	87aa                	mv	a5,a0
    return -1;
    80004202:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004204:	0007c863          	bltz	a5,80004214 <sys_fstat+0x32>
  return filestat(f, st);
    80004208:	fe043583          	ld	a1,-32(s0)
    8000420c:	fe843503          	ld	a0,-24(s0)
    80004210:	c36ff0ef          	jal	80003646 <filestat>
}
    80004214:	60e2                	ld	ra,24(sp)
    80004216:	6442                	ld	s0,16(sp)
    80004218:	6105                	addi	sp,sp,32
    8000421a:	8082                	ret

000000008000421c <sys_link>:
{
    8000421c:	7169                	addi	sp,sp,-304
    8000421e:	f606                	sd	ra,296(sp)
    80004220:	f222                	sd	s0,288(sp)
    80004222:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004224:	08000613          	li	a2,128
    80004228:	ed040593          	addi	a1,s0,-304
    8000422c:	4501                	li	a0,0
    8000422e:	cb3fd0ef          	jal	80001ee0 <argstr>
    return -1;
    80004232:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004234:	0c054e63          	bltz	a0,80004310 <sys_link+0xf4>
    80004238:	08000613          	li	a2,128
    8000423c:	f5040593          	addi	a1,s0,-176
    80004240:	4505                	li	a0,1
    80004242:	c9ffd0ef          	jal	80001ee0 <argstr>
    return -1;
    80004246:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004248:	0c054463          	bltz	a0,80004310 <sys_link+0xf4>
    8000424c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000424e:	f1dfe0ef          	jal	8000316a <begin_op>
  if((ip = namei(old)) == 0){
    80004252:	ed040513          	addi	a0,s0,-304
    80004256:	d59fe0ef          	jal	80002fae <namei>
    8000425a:	84aa                	mv	s1,a0
    8000425c:	c53d                	beqz	a0,800042ca <sys_link+0xae>
  ilock(ip);
    8000425e:	e76fe0ef          	jal	800028d4 <ilock>
  if(ip->type == T_DIR){
    80004262:	04449703          	lh	a4,68(s1)
    80004266:	4785                	li	a5,1
    80004268:	06f70663          	beq	a4,a5,800042d4 <sys_link+0xb8>
    8000426c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000426e:	04a4d783          	lhu	a5,74(s1)
    80004272:	2785                	addiw	a5,a5,1
    80004274:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004278:	8526                	mv	a0,s1
    8000427a:	da6fe0ef          	jal	80002820 <iupdate>
  iunlock(ip);
    8000427e:	8526                	mv	a0,s1
    80004280:	f02fe0ef          	jal	80002982 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004284:	fd040593          	addi	a1,s0,-48
    80004288:	f5040513          	addi	a0,s0,-176
    8000428c:	d3dfe0ef          	jal	80002fc8 <nameiparent>
    80004290:	892a                	mv	s2,a0
    80004292:	cd21                	beqz	a0,800042ea <sys_link+0xce>
  ilock(dp);
    80004294:	e40fe0ef          	jal	800028d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004298:	00092703          	lw	a4,0(s2)
    8000429c:	409c                	lw	a5,0(s1)
    8000429e:	04f71363          	bne	a4,a5,800042e4 <sys_link+0xc8>
    800042a2:	40d0                	lw	a2,4(s1)
    800042a4:	fd040593          	addi	a1,s0,-48
    800042a8:	854a                	mv	a0,s2
    800042aa:	c6bfe0ef          	jal	80002f14 <dirlink>
    800042ae:	02054b63          	bltz	a0,800042e4 <sys_link+0xc8>
  iunlockput(dp);
    800042b2:	854a                	mv	a0,s2
    800042b4:	82bfe0ef          	jal	80002ade <iunlockput>
  iput(ip);
    800042b8:	8526                	mv	a0,s1
    800042ba:	f9cfe0ef          	jal	80002a56 <iput>
  end_op();
    800042be:	f17fe0ef          	jal	800031d4 <end_op>
  return 0;
    800042c2:	4781                	li	a5,0
    800042c4:	64f2                	ld	s1,280(sp)
    800042c6:	6952                	ld	s2,272(sp)
    800042c8:	a0a1                	j	80004310 <sys_link+0xf4>
    end_op();
    800042ca:	f0bfe0ef          	jal	800031d4 <end_op>
    return -1;
    800042ce:	57fd                	li	a5,-1
    800042d0:	64f2                	ld	s1,280(sp)
    800042d2:	a83d                	j	80004310 <sys_link+0xf4>
    iunlockput(ip);
    800042d4:	8526                	mv	a0,s1
    800042d6:	809fe0ef          	jal	80002ade <iunlockput>
    end_op();
    800042da:	efbfe0ef          	jal	800031d4 <end_op>
    return -1;
    800042de:	57fd                	li	a5,-1
    800042e0:	64f2                	ld	s1,280(sp)
    800042e2:	a03d                	j	80004310 <sys_link+0xf4>
    iunlockput(dp);
    800042e4:	854a                	mv	a0,s2
    800042e6:	ff8fe0ef          	jal	80002ade <iunlockput>
  ilock(ip);
    800042ea:	8526                	mv	a0,s1
    800042ec:	de8fe0ef          	jal	800028d4 <ilock>
  ip->nlink--;
    800042f0:	04a4d783          	lhu	a5,74(s1)
    800042f4:	37fd                	addiw	a5,a5,-1
    800042f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800042fa:	8526                	mv	a0,s1
    800042fc:	d24fe0ef          	jal	80002820 <iupdate>
  iunlockput(ip);
    80004300:	8526                	mv	a0,s1
    80004302:	fdcfe0ef          	jal	80002ade <iunlockput>
  end_op();
    80004306:	ecffe0ef          	jal	800031d4 <end_op>
  return -1;
    8000430a:	57fd                	li	a5,-1
    8000430c:	64f2                	ld	s1,280(sp)
    8000430e:	6952                	ld	s2,272(sp)
}
    80004310:	853e                	mv	a0,a5
    80004312:	70b2                	ld	ra,296(sp)
    80004314:	7412                	ld	s0,288(sp)
    80004316:	6155                	addi	sp,sp,304
    80004318:	8082                	ret

000000008000431a <sys_unlink>:
{
    8000431a:	7151                	addi	sp,sp,-240
    8000431c:	f586                	sd	ra,232(sp)
    8000431e:	f1a2                	sd	s0,224(sp)
    80004320:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004322:	08000613          	li	a2,128
    80004326:	f3040593          	addi	a1,s0,-208
    8000432a:	4501                	li	a0,0
    8000432c:	bb5fd0ef          	jal	80001ee0 <argstr>
    80004330:	16054063          	bltz	a0,80004490 <sys_unlink+0x176>
    80004334:	eda6                	sd	s1,216(sp)
  begin_op();
    80004336:	e35fe0ef          	jal	8000316a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000433a:	fb040593          	addi	a1,s0,-80
    8000433e:	f3040513          	addi	a0,s0,-208
    80004342:	c87fe0ef          	jal	80002fc8 <nameiparent>
    80004346:	84aa                	mv	s1,a0
    80004348:	c945                	beqz	a0,800043f8 <sys_unlink+0xde>
  ilock(dp);
    8000434a:	d8afe0ef          	jal	800028d4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000434e:	00003597          	auipc	a1,0x3
    80004352:	31258593          	addi	a1,a1,786 # 80007660 <etext+0x660>
    80004356:	fb040513          	addi	a0,s0,-80
    8000435a:	9d9fe0ef          	jal	80002d32 <namecmp>
    8000435e:	10050e63          	beqz	a0,8000447a <sys_unlink+0x160>
    80004362:	00003597          	auipc	a1,0x3
    80004366:	30658593          	addi	a1,a1,774 # 80007668 <etext+0x668>
    8000436a:	fb040513          	addi	a0,s0,-80
    8000436e:	9c5fe0ef          	jal	80002d32 <namecmp>
    80004372:	10050463          	beqz	a0,8000447a <sys_unlink+0x160>
    80004376:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004378:	f2c40613          	addi	a2,s0,-212
    8000437c:	fb040593          	addi	a1,s0,-80
    80004380:	8526                	mv	a0,s1
    80004382:	9c7fe0ef          	jal	80002d48 <dirlookup>
    80004386:	892a                	mv	s2,a0
    80004388:	0e050863          	beqz	a0,80004478 <sys_unlink+0x15e>
  ilock(ip);
    8000438c:	d48fe0ef          	jal	800028d4 <ilock>
  if(ip->nlink < 1)
    80004390:	04a91783          	lh	a5,74(s2)
    80004394:	06f05763          	blez	a5,80004402 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004398:	04491703          	lh	a4,68(s2)
    8000439c:	4785                	li	a5,1
    8000439e:	06f70963          	beq	a4,a5,80004410 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800043a2:	4641                	li	a2,16
    800043a4:	4581                	li	a1,0
    800043a6:	fc040513          	addi	a0,s0,-64
    800043aa:	e99fb0ef          	jal	80000242 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043ae:	4741                	li	a4,16
    800043b0:	f2c42683          	lw	a3,-212(s0)
    800043b4:	fc040613          	addi	a2,s0,-64
    800043b8:	4581                	li	a1,0
    800043ba:	8526                	mv	a0,s1
    800043bc:	869fe0ef          	jal	80002c24 <writei>
    800043c0:	47c1                	li	a5,16
    800043c2:	08f51b63          	bne	a0,a5,80004458 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800043c6:	04491703          	lh	a4,68(s2)
    800043ca:	4785                	li	a5,1
    800043cc:	08f70d63          	beq	a4,a5,80004466 <sys_unlink+0x14c>
  iunlockput(dp);
    800043d0:	8526                	mv	a0,s1
    800043d2:	f0cfe0ef          	jal	80002ade <iunlockput>
  ip->nlink--;
    800043d6:	04a95783          	lhu	a5,74(s2)
    800043da:	37fd                	addiw	a5,a5,-1
    800043dc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800043e0:	854a                	mv	a0,s2
    800043e2:	c3efe0ef          	jal	80002820 <iupdate>
  iunlockput(ip);
    800043e6:	854a                	mv	a0,s2
    800043e8:	ef6fe0ef          	jal	80002ade <iunlockput>
  end_op();
    800043ec:	de9fe0ef          	jal	800031d4 <end_op>
  return 0;
    800043f0:	4501                	li	a0,0
    800043f2:	64ee                	ld	s1,216(sp)
    800043f4:	694e                	ld	s2,208(sp)
    800043f6:	a849                	j	80004488 <sys_unlink+0x16e>
    end_op();
    800043f8:	dddfe0ef          	jal	800031d4 <end_op>
    return -1;
    800043fc:	557d                	li	a0,-1
    800043fe:	64ee                	ld	s1,216(sp)
    80004400:	a061                	j	80004488 <sys_unlink+0x16e>
    80004402:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004404:	00003517          	auipc	a0,0x3
    80004408:	26c50513          	addi	a0,a0,620 # 80007670 <etext+0x670>
    8000440c:	276010ef          	jal	80005682 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004410:	04c92703          	lw	a4,76(s2)
    80004414:	02000793          	li	a5,32
    80004418:	f8e7f5e3          	bgeu	a5,a4,800043a2 <sys_unlink+0x88>
    8000441c:	e5ce                	sd	s3,200(sp)
    8000441e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004422:	4741                	li	a4,16
    80004424:	86ce                	mv	a3,s3
    80004426:	f1840613          	addi	a2,s0,-232
    8000442a:	4581                	li	a1,0
    8000442c:	854a                	mv	a0,s2
    8000442e:	efafe0ef          	jal	80002b28 <readi>
    80004432:	47c1                	li	a5,16
    80004434:	00f51c63          	bne	a0,a5,8000444c <sys_unlink+0x132>
    if(de.inum != 0)
    80004438:	f1845783          	lhu	a5,-232(s0)
    8000443c:	efa1                	bnez	a5,80004494 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000443e:	29c1                	addiw	s3,s3,16
    80004440:	04c92783          	lw	a5,76(s2)
    80004444:	fcf9efe3          	bltu	s3,a5,80004422 <sys_unlink+0x108>
    80004448:	69ae                	ld	s3,200(sp)
    8000444a:	bfa1                	j	800043a2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000444c:	00003517          	auipc	a0,0x3
    80004450:	23c50513          	addi	a0,a0,572 # 80007688 <etext+0x688>
    80004454:	22e010ef          	jal	80005682 <panic>
    80004458:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000445a:	00003517          	auipc	a0,0x3
    8000445e:	24650513          	addi	a0,a0,582 # 800076a0 <etext+0x6a0>
    80004462:	220010ef          	jal	80005682 <panic>
    dp->nlink--;
    80004466:	04a4d783          	lhu	a5,74(s1)
    8000446a:	37fd                	addiw	a5,a5,-1
    8000446c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004470:	8526                	mv	a0,s1
    80004472:	baefe0ef          	jal	80002820 <iupdate>
    80004476:	bfa9                	j	800043d0 <sys_unlink+0xb6>
    80004478:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000447a:	8526                	mv	a0,s1
    8000447c:	e62fe0ef          	jal	80002ade <iunlockput>
  end_op();
    80004480:	d55fe0ef          	jal	800031d4 <end_op>
  return -1;
    80004484:	557d                	li	a0,-1
    80004486:	64ee                	ld	s1,216(sp)
}
    80004488:	70ae                	ld	ra,232(sp)
    8000448a:	740e                	ld	s0,224(sp)
    8000448c:	616d                	addi	sp,sp,240
    8000448e:	8082                	ret
    return -1;
    80004490:	557d                	li	a0,-1
    80004492:	bfdd                	j	80004488 <sys_unlink+0x16e>
    iunlockput(ip);
    80004494:	854a                	mv	a0,s2
    80004496:	e48fe0ef          	jal	80002ade <iunlockput>
    goto bad;
    8000449a:	694e                	ld	s2,208(sp)
    8000449c:	69ae                	ld	s3,200(sp)
    8000449e:	bff1                	j	8000447a <sys_unlink+0x160>

00000000800044a0 <sys_open>:

uint64
sys_open(void)
{
    800044a0:	7131                	addi	sp,sp,-192
    800044a2:	fd06                	sd	ra,184(sp)
    800044a4:	f922                	sd	s0,176(sp)
    800044a6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800044a8:	f4c40593          	addi	a1,s0,-180
    800044ac:	4505                	li	a0,1
    800044ae:	9fbfd0ef          	jal	80001ea8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044b2:	08000613          	li	a2,128
    800044b6:	f5040593          	addi	a1,s0,-176
    800044ba:	4501                	li	a0,0
    800044bc:	a25fd0ef          	jal	80001ee0 <argstr>
    800044c0:	87aa                	mv	a5,a0
    return -1;
    800044c2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044c4:	0a07c263          	bltz	a5,80004568 <sys_open+0xc8>
    800044c8:	f526                	sd	s1,168(sp)

  begin_op();
    800044ca:	ca1fe0ef          	jal	8000316a <begin_op>

  if(omode & O_CREATE){
    800044ce:	f4c42783          	lw	a5,-180(s0)
    800044d2:	2007f793          	andi	a5,a5,512
    800044d6:	c3d5                	beqz	a5,8000457a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800044d8:	4681                	li	a3,0
    800044da:	4601                	li	a2,0
    800044dc:	4589                	li	a1,2
    800044de:	f5040513          	addi	a0,s0,-176
    800044e2:	aa9ff0ef          	jal	80003f8a <create>
    800044e6:	84aa                	mv	s1,a0
    if(ip == 0){
    800044e8:	c541                	beqz	a0,80004570 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800044ea:	04449703          	lh	a4,68(s1)
    800044ee:	478d                	li	a5,3
    800044f0:	00f71763          	bne	a4,a5,800044fe <sys_open+0x5e>
    800044f4:	0464d703          	lhu	a4,70(s1)
    800044f8:	47a5                	li	a5,9
    800044fa:	0ae7ed63          	bltu	a5,a4,800045b4 <sys_open+0x114>
    800044fe:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004500:	fe1fe0ef          	jal	800034e0 <filealloc>
    80004504:	892a                	mv	s2,a0
    80004506:	c179                	beqz	a0,800045cc <sys_open+0x12c>
    80004508:	ed4e                	sd	s3,152(sp)
    8000450a:	a43ff0ef          	jal	80003f4c <fdalloc>
    8000450e:	89aa                	mv	s3,a0
    80004510:	0a054a63          	bltz	a0,800045c4 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004514:	04449703          	lh	a4,68(s1)
    80004518:	478d                	li	a5,3
    8000451a:	0cf70263          	beq	a4,a5,800045de <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000451e:	4789                	li	a5,2
    80004520:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004524:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004528:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000452c:	f4c42783          	lw	a5,-180(s0)
    80004530:	0017c713          	xori	a4,a5,1
    80004534:	8b05                	andi	a4,a4,1
    80004536:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000453a:	0037f713          	andi	a4,a5,3
    8000453e:	00e03733          	snez	a4,a4
    80004542:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004546:	4007f793          	andi	a5,a5,1024
    8000454a:	c791                	beqz	a5,80004556 <sys_open+0xb6>
    8000454c:	04449703          	lh	a4,68(s1)
    80004550:	4789                	li	a5,2
    80004552:	08f70d63          	beq	a4,a5,800045ec <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004556:	8526                	mv	a0,s1
    80004558:	c2afe0ef          	jal	80002982 <iunlock>
  end_op();
    8000455c:	c79fe0ef          	jal	800031d4 <end_op>

  return fd;
    80004560:	854e                	mv	a0,s3
    80004562:	74aa                	ld	s1,168(sp)
    80004564:	790a                	ld	s2,160(sp)
    80004566:	69ea                	ld	s3,152(sp)
}
    80004568:	70ea                	ld	ra,184(sp)
    8000456a:	744a                	ld	s0,176(sp)
    8000456c:	6129                	addi	sp,sp,192
    8000456e:	8082                	ret
      end_op();
    80004570:	c65fe0ef          	jal	800031d4 <end_op>
      return -1;
    80004574:	557d                	li	a0,-1
    80004576:	74aa                	ld	s1,168(sp)
    80004578:	bfc5                	j	80004568 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000457a:	f5040513          	addi	a0,s0,-176
    8000457e:	a31fe0ef          	jal	80002fae <namei>
    80004582:	84aa                	mv	s1,a0
    80004584:	c11d                	beqz	a0,800045aa <sys_open+0x10a>
    ilock(ip);
    80004586:	b4efe0ef          	jal	800028d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000458a:	04449703          	lh	a4,68(s1)
    8000458e:	4785                	li	a5,1
    80004590:	f4f71de3          	bne	a4,a5,800044ea <sys_open+0x4a>
    80004594:	f4c42783          	lw	a5,-180(s0)
    80004598:	d3bd                	beqz	a5,800044fe <sys_open+0x5e>
      iunlockput(ip);
    8000459a:	8526                	mv	a0,s1
    8000459c:	d42fe0ef          	jal	80002ade <iunlockput>
      end_op();
    800045a0:	c35fe0ef          	jal	800031d4 <end_op>
      return -1;
    800045a4:	557d                	li	a0,-1
    800045a6:	74aa                	ld	s1,168(sp)
    800045a8:	b7c1                	j	80004568 <sys_open+0xc8>
      end_op();
    800045aa:	c2bfe0ef          	jal	800031d4 <end_op>
      return -1;
    800045ae:	557d                	li	a0,-1
    800045b0:	74aa                	ld	s1,168(sp)
    800045b2:	bf5d                	j	80004568 <sys_open+0xc8>
    iunlockput(ip);
    800045b4:	8526                	mv	a0,s1
    800045b6:	d28fe0ef          	jal	80002ade <iunlockput>
    end_op();
    800045ba:	c1bfe0ef          	jal	800031d4 <end_op>
    return -1;
    800045be:	557d                	li	a0,-1
    800045c0:	74aa                	ld	s1,168(sp)
    800045c2:	b75d                	j	80004568 <sys_open+0xc8>
      fileclose(f);
    800045c4:	854a                	mv	a0,s2
    800045c6:	fbffe0ef          	jal	80003584 <fileclose>
    800045ca:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800045cc:	8526                	mv	a0,s1
    800045ce:	d10fe0ef          	jal	80002ade <iunlockput>
    end_op();
    800045d2:	c03fe0ef          	jal	800031d4 <end_op>
    return -1;
    800045d6:	557d                	li	a0,-1
    800045d8:	74aa                	ld	s1,168(sp)
    800045da:	790a                	ld	s2,160(sp)
    800045dc:	b771                	j	80004568 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800045de:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800045e2:	04649783          	lh	a5,70(s1)
    800045e6:	02f91223          	sh	a5,36(s2)
    800045ea:	bf3d                	j	80004528 <sys_open+0x88>
    itrunc(ip);
    800045ec:	8526                	mv	a0,s1
    800045ee:	bd4fe0ef          	jal	800029c2 <itrunc>
    800045f2:	b795                	j	80004556 <sys_open+0xb6>

00000000800045f4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800045f4:	7175                	addi	sp,sp,-144
    800045f6:	e506                	sd	ra,136(sp)
    800045f8:	e122                	sd	s0,128(sp)
    800045fa:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800045fc:	b6ffe0ef          	jal	8000316a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004600:	08000613          	li	a2,128
    80004604:	f7040593          	addi	a1,s0,-144
    80004608:	4501                	li	a0,0
    8000460a:	8d7fd0ef          	jal	80001ee0 <argstr>
    8000460e:	02054363          	bltz	a0,80004634 <sys_mkdir+0x40>
    80004612:	4681                	li	a3,0
    80004614:	4601                	li	a2,0
    80004616:	4585                	li	a1,1
    80004618:	f7040513          	addi	a0,s0,-144
    8000461c:	96fff0ef          	jal	80003f8a <create>
    80004620:	c911                	beqz	a0,80004634 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004622:	cbcfe0ef          	jal	80002ade <iunlockput>
  end_op();
    80004626:	baffe0ef          	jal	800031d4 <end_op>
  return 0;
    8000462a:	4501                	li	a0,0
}
    8000462c:	60aa                	ld	ra,136(sp)
    8000462e:	640a                	ld	s0,128(sp)
    80004630:	6149                	addi	sp,sp,144
    80004632:	8082                	ret
    end_op();
    80004634:	ba1fe0ef          	jal	800031d4 <end_op>
    return -1;
    80004638:	557d                	li	a0,-1
    8000463a:	bfcd                	j	8000462c <sys_mkdir+0x38>

000000008000463c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000463c:	7135                	addi	sp,sp,-160
    8000463e:	ed06                	sd	ra,152(sp)
    80004640:	e922                	sd	s0,144(sp)
    80004642:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004644:	b27fe0ef          	jal	8000316a <begin_op>
  argint(1, &major);
    80004648:	f6c40593          	addi	a1,s0,-148
    8000464c:	4505                	li	a0,1
    8000464e:	85bfd0ef          	jal	80001ea8 <argint>
  argint(2, &minor);
    80004652:	f6840593          	addi	a1,s0,-152
    80004656:	4509                	li	a0,2
    80004658:	851fd0ef          	jal	80001ea8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000465c:	08000613          	li	a2,128
    80004660:	f7040593          	addi	a1,s0,-144
    80004664:	4501                	li	a0,0
    80004666:	87bfd0ef          	jal	80001ee0 <argstr>
    8000466a:	02054563          	bltz	a0,80004694 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000466e:	f6841683          	lh	a3,-152(s0)
    80004672:	f6c41603          	lh	a2,-148(s0)
    80004676:	458d                	li	a1,3
    80004678:	f7040513          	addi	a0,s0,-144
    8000467c:	90fff0ef          	jal	80003f8a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004680:	c911                	beqz	a0,80004694 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004682:	c5cfe0ef          	jal	80002ade <iunlockput>
  end_op();
    80004686:	b4ffe0ef          	jal	800031d4 <end_op>
  return 0;
    8000468a:	4501                	li	a0,0
}
    8000468c:	60ea                	ld	ra,152(sp)
    8000468e:	644a                	ld	s0,144(sp)
    80004690:	610d                	addi	sp,sp,160
    80004692:	8082                	ret
    end_op();
    80004694:	b41fe0ef          	jal	800031d4 <end_op>
    return -1;
    80004698:	557d                	li	a0,-1
    8000469a:	bfcd                	j	8000468c <sys_mknod+0x50>

000000008000469c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000469c:	7135                	addi	sp,sp,-160
    8000469e:	ed06                	sd	ra,152(sp)
    800046a0:	e922                	sd	s0,144(sp)
    800046a2:	e14a                	sd	s2,128(sp)
    800046a4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800046a6:	87bfc0ef          	jal	80000f20 <myproc>
    800046aa:	892a                	mv	s2,a0
  
  begin_op();
    800046ac:	abffe0ef          	jal	8000316a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800046b0:	08000613          	li	a2,128
    800046b4:	f6040593          	addi	a1,s0,-160
    800046b8:	4501                	li	a0,0
    800046ba:	827fd0ef          	jal	80001ee0 <argstr>
    800046be:	04054363          	bltz	a0,80004704 <sys_chdir+0x68>
    800046c2:	e526                	sd	s1,136(sp)
    800046c4:	f6040513          	addi	a0,s0,-160
    800046c8:	8e7fe0ef          	jal	80002fae <namei>
    800046cc:	84aa                	mv	s1,a0
    800046ce:	c915                	beqz	a0,80004702 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800046d0:	a04fe0ef          	jal	800028d4 <ilock>
  if(ip->type != T_DIR){
    800046d4:	04449703          	lh	a4,68(s1)
    800046d8:	4785                	li	a5,1
    800046da:	02f71963          	bne	a4,a5,8000470c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800046de:	8526                	mv	a0,s1
    800046e0:	aa2fe0ef          	jal	80002982 <iunlock>
  iput(p->cwd);
    800046e4:	15093503          	ld	a0,336(s2)
    800046e8:	b6efe0ef          	jal	80002a56 <iput>
  end_op();
    800046ec:	ae9fe0ef          	jal	800031d4 <end_op>
  p->cwd = ip;
    800046f0:	14993823          	sd	s1,336(s2)
  return 0;
    800046f4:	4501                	li	a0,0
    800046f6:	64aa                	ld	s1,136(sp)
}
    800046f8:	60ea                	ld	ra,152(sp)
    800046fa:	644a                	ld	s0,144(sp)
    800046fc:	690a                	ld	s2,128(sp)
    800046fe:	610d                	addi	sp,sp,160
    80004700:	8082                	ret
    80004702:	64aa                	ld	s1,136(sp)
    end_op();
    80004704:	ad1fe0ef          	jal	800031d4 <end_op>
    return -1;
    80004708:	557d                	li	a0,-1
    8000470a:	b7fd                	j	800046f8 <sys_chdir+0x5c>
    iunlockput(ip);
    8000470c:	8526                	mv	a0,s1
    8000470e:	bd0fe0ef          	jal	80002ade <iunlockput>
    end_op();
    80004712:	ac3fe0ef          	jal	800031d4 <end_op>
    return -1;
    80004716:	557d                	li	a0,-1
    80004718:	64aa                	ld	s1,136(sp)
    8000471a:	bff9                	j	800046f8 <sys_chdir+0x5c>

000000008000471c <sys_exec>:

uint64
sys_exec(void)
{
    8000471c:	7121                	addi	sp,sp,-448
    8000471e:	ff06                	sd	ra,440(sp)
    80004720:	fb22                	sd	s0,432(sp)
    80004722:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004724:	e4840593          	addi	a1,s0,-440
    80004728:	4505                	li	a0,1
    8000472a:	f9afd0ef          	jal	80001ec4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000472e:	08000613          	li	a2,128
    80004732:	f5040593          	addi	a1,s0,-176
    80004736:	4501                	li	a0,0
    80004738:	fa8fd0ef          	jal	80001ee0 <argstr>
    8000473c:	87aa                	mv	a5,a0
    return -1;
    8000473e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004740:	0c07c463          	bltz	a5,80004808 <sys_exec+0xec>
    80004744:	f726                	sd	s1,424(sp)
    80004746:	f34a                	sd	s2,416(sp)
    80004748:	ef4e                	sd	s3,408(sp)
    8000474a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000474c:	10000613          	li	a2,256
    80004750:	4581                	li	a1,0
    80004752:	e5040513          	addi	a0,s0,-432
    80004756:	aedfb0ef          	jal	80000242 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000475a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000475e:	89a6                	mv	s3,s1
    80004760:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004762:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004766:	00391513          	slli	a0,s2,0x3
    8000476a:	e4040593          	addi	a1,s0,-448
    8000476e:	e4843783          	ld	a5,-440(s0)
    80004772:	953e                	add	a0,a0,a5
    80004774:	eaafd0ef          	jal	80001e1e <fetchaddr>
    80004778:	02054663          	bltz	a0,800047a4 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000477c:	e4043783          	ld	a5,-448(s0)
    80004780:	c3a9                	beqz	a5,800047c2 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004782:	a57fb0ef          	jal	800001d8 <kalloc>
    80004786:	85aa                	mv	a1,a0
    80004788:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000478c:	cd01                	beqz	a0,800047a4 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000478e:	6605                	lui	a2,0x1
    80004790:	e4043503          	ld	a0,-448(s0)
    80004794:	ed4fd0ef          	jal	80001e68 <fetchstr>
    80004798:	00054663          	bltz	a0,800047a4 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000479c:	0905                	addi	s2,s2,1
    8000479e:	09a1                	addi	s3,s3,8
    800047a0:	fd4913e3          	bne	s2,s4,80004766 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047a4:	f5040913          	addi	s2,s0,-176
    800047a8:	6088                	ld	a0,0(s1)
    800047aa:	c931                	beqz	a0,800047fe <sys_exec+0xe2>
    kfree(argv[i]);
    800047ac:	905fb0ef          	jal	800000b0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047b0:	04a1                	addi	s1,s1,8
    800047b2:	ff249be3          	bne	s1,s2,800047a8 <sys_exec+0x8c>
  return -1;
    800047b6:	557d                	li	a0,-1
    800047b8:	74ba                	ld	s1,424(sp)
    800047ba:	791a                	ld	s2,416(sp)
    800047bc:	69fa                	ld	s3,408(sp)
    800047be:	6a5a                	ld	s4,400(sp)
    800047c0:	a0a1                	j	80004808 <sys_exec+0xec>
      argv[i] = 0;
    800047c2:	0009079b          	sext.w	a5,s2
    800047c6:	078e                	slli	a5,a5,0x3
    800047c8:	fd078793          	addi	a5,a5,-48
    800047cc:	97a2                	add	a5,a5,s0
    800047ce:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800047d2:	e5040593          	addi	a1,s0,-432
    800047d6:	f5040513          	addi	a0,s0,-176
    800047da:	ba8ff0ef          	jal	80003b82 <exec>
    800047de:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047e0:	f5040993          	addi	s3,s0,-176
    800047e4:	6088                	ld	a0,0(s1)
    800047e6:	c511                	beqz	a0,800047f2 <sys_exec+0xd6>
    kfree(argv[i]);
    800047e8:	8c9fb0ef          	jal	800000b0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047ec:	04a1                	addi	s1,s1,8
    800047ee:	ff349be3          	bne	s1,s3,800047e4 <sys_exec+0xc8>
  return ret;
    800047f2:	854a                	mv	a0,s2
    800047f4:	74ba                	ld	s1,424(sp)
    800047f6:	791a                	ld	s2,416(sp)
    800047f8:	69fa                	ld	s3,408(sp)
    800047fa:	6a5a                	ld	s4,400(sp)
    800047fc:	a031                	j	80004808 <sys_exec+0xec>
  return -1;
    800047fe:	557d                	li	a0,-1
    80004800:	74ba                	ld	s1,424(sp)
    80004802:	791a                	ld	s2,416(sp)
    80004804:	69fa                	ld	s3,408(sp)
    80004806:	6a5a                	ld	s4,400(sp)
}
    80004808:	70fa                	ld	ra,440(sp)
    8000480a:	745a                	ld	s0,432(sp)
    8000480c:	6139                	addi	sp,sp,448
    8000480e:	8082                	ret

0000000080004810 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004810:	7139                	addi	sp,sp,-64
    80004812:	fc06                	sd	ra,56(sp)
    80004814:	f822                	sd	s0,48(sp)
    80004816:	f426                	sd	s1,40(sp)
    80004818:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000481a:	f06fc0ef          	jal	80000f20 <myproc>
    8000481e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004820:	fd840593          	addi	a1,s0,-40
    80004824:	4501                	li	a0,0
    80004826:	e9efd0ef          	jal	80001ec4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000482a:	fc840593          	addi	a1,s0,-56
    8000482e:	fd040513          	addi	a0,s0,-48
    80004832:	85cff0ef          	jal	8000388e <pipealloc>
    return -1;
    80004836:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004838:	0a054463          	bltz	a0,800048e0 <sys_pipe+0xd0>
  fd0 = -1;
    8000483c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004840:	fd043503          	ld	a0,-48(s0)
    80004844:	f08ff0ef          	jal	80003f4c <fdalloc>
    80004848:	fca42223          	sw	a0,-60(s0)
    8000484c:	08054163          	bltz	a0,800048ce <sys_pipe+0xbe>
    80004850:	fc843503          	ld	a0,-56(s0)
    80004854:	ef8ff0ef          	jal	80003f4c <fdalloc>
    80004858:	fca42023          	sw	a0,-64(s0)
    8000485c:	06054063          	bltz	a0,800048bc <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004860:	4691                	li	a3,4
    80004862:	fc440613          	addi	a2,s0,-60
    80004866:	fd843583          	ld	a1,-40(s0)
    8000486a:	68a8                	ld	a0,80(s1)
    8000486c:	a76fc0ef          	jal	80000ae2 <copyout>
    80004870:	00054e63          	bltz	a0,8000488c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004874:	4691                	li	a3,4
    80004876:	fc040613          	addi	a2,s0,-64
    8000487a:	fd843583          	ld	a1,-40(s0)
    8000487e:	0591                	addi	a1,a1,4
    80004880:	68a8                	ld	a0,80(s1)
    80004882:	a60fc0ef          	jal	80000ae2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004886:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004888:	04055c63          	bgez	a0,800048e0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000488c:	fc442783          	lw	a5,-60(s0)
    80004890:	07e9                	addi	a5,a5,26
    80004892:	078e                	slli	a5,a5,0x3
    80004894:	97a6                	add	a5,a5,s1
    80004896:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000489a:	fc042783          	lw	a5,-64(s0)
    8000489e:	07e9                	addi	a5,a5,26
    800048a0:	078e                	slli	a5,a5,0x3
    800048a2:	94be                	add	s1,s1,a5
    800048a4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800048a8:	fd043503          	ld	a0,-48(s0)
    800048ac:	cd9fe0ef          	jal	80003584 <fileclose>
    fileclose(wf);
    800048b0:	fc843503          	ld	a0,-56(s0)
    800048b4:	cd1fe0ef          	jal	80003584 <fileclose>
    return -1;
    800048b8:	57fd                	li	a5,-1
    800048ba:	a01d                	j	800048e0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800048bc:	fc442783          	lw	a5,-60(s0)
    800048c0:	0007c763          	bltz	a5,800048ce <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800048c4:	07e9                	addi	a5,a5,26
    800048c6:	078e                	slli	a5,a5,0x3
    800048c8:	97a6                	add	a5,a5,s1
    800048ca:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800048ce:	fd043503          	ld	a0,-48(s0)
    800048d2:	cb3fe0ef          	jal	80003584 <fileclose>
    fileclose(wf);
    800048d6:	fc843503          	ld	a0,-56(s0)
    800048da:	cabfe0ef          	jal	80003584 <fileclose>
    return -1;
    800048de:	57fd                	li	a5,-1
}
    800048e0:	853e                	mv	a0,a5
    800048e2:	70e2                	ld	ra,56(sp)
    800048e4:	7442                	ld	s0,48(sp)
    800048e6:	74a2                	ld	s1,40(sp)
    800048e8:	6121                	addi	sp,sp,64
    800048ea:	8082                	ret
    800048ec:	0000                	unimp
	...

00000000800048f0 <kernelvec>:
    800048f0:	7111                	addi	sp,sp,-256
    800048f2:	e006                	sd	ra,0(sp)
    800048f4:	e40a                	sd	sp,8(sp)
    800048f6:	e80e                	sd	gp,16(sp)
    800048f8:	ec12                	sd	tp,24(sp)
    800048fa:	f016                	sd	t0,32(sp)
    800048fc:	f41a                	sd	t1,40(sp)
    800048fe:	f81e                	sd	t2,48(sp)
    80004900:	e4aa                	sd	a0,72(sp)
    80004902:	e8ae                	sd	a1,80(sp)
    80004904:	ecb2                	sd	a2,88(sp)
    80004906:	f0b6                	sd	a3,96(sp)
    80004908:	f4ba                	sd	a4,104(sp)
    8000490a:	f8be                	sd	a5,112(sp)
    8000490c:	fcc2                	sd	a6,120(sp)
    8000490e:	e146                	sd	a7,128(sp)
    80004910:	edf2                	sd	t3,216(sp)
    80004912:	f1f6                	sd	t4,224(sp)
    80004914:	f5fa                	sd	t5,232(sp)
    80004916:	f9fe                	sd	t6,240(sp)
    80004918:	c16fd0ef          	jal	80001d2e <kerneltrap>
    8000491c:	6082                	ld	ra,0(sp)
    8000491e:	6122                	ld	sp,8(sp)
    80004920:	61c2                	ld	gp,16(sp)
    80004922:	7282                	ld	t0,32(sp)
    80004924:	7322                	ld	t1,40(sp)
    80004926:	73c2                	ld	t2,48(sp)
    80004928:	6526                	ld	a0,72(sp)
    8000492a:	65c6                	ld	a1,80(sp)
    8000492c:	6666                	ld	a2,88(sp)
    8000492e:	7686                	ld	a3,96(sp)
    80004930:	7726                	ld	a4,104(sp)
    80004932:	77c6                	ld	a5,112(sp)
    80004934:	7866                	ld	a6,120(sp)
    80004936:	688a                	ld	a7,128(sp)
    80004938:	6e6e                	ld	t3,216(sp)
    8000493a:	7e8e                	ld	t4,224(sp)
    8000493c:	7f2e                	ld	t5,232(sp)
    8000493e:	7fce                	ld	t6,240(sp)
    80004940:	6111                	addi	sp,sp,256
    80004942:	10200073          	sret
	...

000000008000494e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000494e:	1141                	addi	sp,sp,-16
    80004950:	e422                	sd	s0,8(sp)
    80004952:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004954:	0c0007b7          	lui	a5,0xc000
    80004958:	4705                	li	a4,1
    8000495a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000495c:	0c0007b7          	lui	a5,0xc000
    80004960:	c3d8                	sw	a4,4(a5)
}
    80004962:	6422                	ld	s0,8(sp)
    80004964:	0141                	addi	sp,sp,16
    80004966:	8082                	ret

0000000080004968 <plicinithart>:

void
plicinithart(void)
{
    80004968:	1141                	addi	sp,sp,-16
    8000496a:	e406                	sd	ra,8(sp)
    8000496c:	e022                	sd	s0,0(sp)
    8000496e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004970:	d84fc0ef          	jal	80000ef4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004974:	0085171b          	slliw	a4,a0,0x8
    80004978:	0c0027b7          	lui	a5,0xc002
    8000497c:	97ba                	add	a5,a5,a4
    8000497e:	40200713          	li	a4,1026
    80004982:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004986:	00d5151b          	slliw	a0,a0,0xd
    8000498a:	0c2017b7          	lui	a5,0xc201
    8000498e:	97aa                	add	a5,a5,a0
    80004990:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004994:	60a2                	ld	ra,8(sp)
    80004996:	6402                	ld	s0,0(sp)
    80004998:	0141                	addi	sp,sp,16
    8000499a:	8082                	ret

000000008000499c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000499c:	1141                	addi	sp,sp,-16
    8000499e:	e406                	sd	ra,8(sp)
    800049a0:	e022                	sd	s0,0(sp)
    800049a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800049a4:	d50fc0ef          	jal	80000ef4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800049a8:	00d5151b          	slliw	a0,a0,0xd
    800049ac:	0c2017b7          	lui	a5,0xc201
    800049b0:	97aa                	add	a5,a5,a0
  return irq;
}
    800049b2:	43c8                	lw	a0,4(a5)
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800049bc:	1101                	addi	sp,sp,-32
    800049be:	ec06                	sd	ra,24(sp)
    800049c0:	e822                	sd	s0,16(sp)
    800049c2:	e426                	sd	s1,8(sp)
    800049c4:	1000                	addi	s0,sp,32
    800049c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800049c8:	d2cfc0ef          	jal	80000ef4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800049cc:	00d5151b          	slliw	a0,a0,0xd
    800049d0:	0c2017b7          	lui	a5,0xc201
    800049d4:	97aa                	add	a5,a5,a0
    800049d6:	c3c4                	sw	s1,4(a5)
}
    800049d8:	60e2                	ld	ra,24(sp)
    800049da:	6442                	ld	s0,16(sp)
    800049dc:	64a2                	ld	s1,8(sp)
    800049de:	6105                	addi	sp,sp,32
    800049e0:	8082                	ret

00000000800049e2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800049e2:	1141                	addi	sp,sp,-16
    800049e4:	e406                	sd	ra,8(sp)
    800049e6:	e022                	sd	s0,0(sp)
    800049e8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800049ea:	479d                	li	a5,7
    800049ec:	04a7ca63          	blt	a5,a0,80004a40 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800049f0:	00037797          	auipc	a5,0x37
    800049f4:	a8078793          	addi	a5,a5,-1408 # 8003b470 <disk>
    800049f8:	97aa                	add	a5,a5,a0
    800049fa:	0187c783          	lbu	a5,24(a5)
    800049fe:	e7b9                	bnez	a5,80004a4c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004a00:	00451693          	slli	a3,a0,0x4
    80004a04:	00037797          	auipc	a5,0x37
    80004a08:	a6c78793          	addi	a5,a5,-1428 # 8003b470 <disk>
    80004a0c:	6398                	ld	a4,0(a5)
    80004a0e:	9736                	add	a4,a4,a3
    80004a10:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004a14:	6398                	ld	a4,0(a5)
    80004a16:	9736                	add	a4,a4,a3
    80004a18:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004a1c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004a20:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004a24:	97aa                	add	a5,a5,a0
    80004a26:	4705                	li	a4,1
    80004a28:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004a2c:	00037517          	auipc	a0,0x37
    80004a30:	a5c50513          	addi	a0,a0,-1444 # 8003b488 <disk+0x18>
    80004a34:	b07fc0ef          	jal	8000153a <wakeup>
}
    80004a38:	60a2                	ld	ra,8(sp)
    80004a3a:	6402                	ld	s0,0(sp)
    80004a3c:	0141                	addi	sp,sp,16
    80004a3e:	8082                	ret
    panic("free_desc 1");
    80004a40:	00003517          	auipc	a0,0x3
    80004a44:	c7050513          	addi	a0,a0,-912 # 800076b0 <etext+0x6b0>
    80004a48:	43b000ef          	jal	80005682 <panic>
    panic("free_desc 2");
    80004a4c:	00003517          	auipc	a0,0x3
    80004a50:	c7450513          	addi	a0,a0,-908 # 800076c0 <etext+0x6c0>
    80004a54:	42f000ef          	jal	80005682 <panic>

0000000080004a58 <virtio_disk_init>:
{
    80004a58:	1101                	addi	sp,sp,-32
    80004a5a:	ec06                	sd	ra,24(sp)
    80004a5c:	e822                	sd	s0,16(sp)
    80004a5e:	e426                	sd	s1,8(sp)
    80004a60:	e04a                	sd	s2,0(sp)
    80004a62:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004a64:	00003597          	auipc	a1,0x3
    80004a68:	c6c58593          	addi	a1,a1,-916 # 800076d0 <etext+0x6d0>
    80004a6c:	00037517          	auipc	a0,0x37
    80004a70:	b2c50513          	addi	a0,a0,-1236 # 8003b598 <disk+0x128>
    80004a74:	6bd000ef          	jal	80005930 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a78:	100017b7          	lui	a5,0x10001
    80004a7c:	4398                	lw	a4,0(a5)
    80004a7e:	2701                	sext.w	a4,a4
    80004a80:	747277b7          	lui	a5,0x74727
    80004a84:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004a88:	18f71063          	bne	a4,a5,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004a8c:	100017b7          	lui	a5,0x10001
    80004a90:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004a92:	439c                	lw	a5,0(a5)
    80004a94:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a96:	4709                	li	a4,2
    80004a98:	16e79863          	bne	a5,a4,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004a9c:	100017b7          	lui	a5,0x10001
    80004aa0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004aa2:	439c                	lw	a5,0(a5)
    80004aa4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004aa6:	16e79163          	bne	a5,a4,80004c08 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004aaa:	100017b7          	lui	a5,0x10001
    80004aae:	47d8                	lw	a4,12(a5)
    80004ab0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004ab2:	554d47b7          	lui	a5,0x554d4
    80004ab6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004aba:	14f71763          	bne	a4,a5,80004c08 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004abe:	100017b7          	lui	a5,0x10001
    80004ac2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ac6:	4705                	li	a4,1
    80004ac8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004aca:	470d                	li	a4,3
    80004acc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004ace:	10001737          	lui	a4,0x10001
    80004ad2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004ad4:	c7ffe737          	lui	a4,0xc7ffe
    80004ad8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb0af>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004adc:	8ef9                	and	a3,a3,a4
    80004ade:	10001737          	lui	a4,0x10001
    80004ae2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae4:	472d                	li	a4,11
    80004ae6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004aec:	439c                	lw	a5,0(a5)
    80004aee:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004af2:	8ba1                	andi	a5,a5,8
    80004af4:	12078063          	beqz	a5,80004c14 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004af8:	100017b7          	lui	a5,0x10001
    80004afc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004b00:	100017b7          	lui	a5,0x10001
    80004b04:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004b08:	439c                	lw	a5,0(a5)
    80004b0a:	2781                	sext.w	a5,a5
    80004b0c:	10079a63          	bnez	a5,80004c20 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004b10:	100017b7          	lui	a5,0x10001
    80004b14:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004b18:	439c                	lw	a5,0(a5)
    80004b1a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004b1c:	10078863          	beqz	a5,80004c2c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004b20:	471d                	li	a4,7
    80004b22:	10f77b63          	bgeu	a4,a5,80004c38 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004b26:	eb2fb0ef          	jal	800001d8 <kalloc>
    80004b2a:	00037497          	auipc	s1,0x37
    80004b2e:	94648493          	addi	s1,s1,-1722 # 8003b470 <disk>
    80004b32:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004b34:	ea4fb0ef          	jal	800001d8 <kalloc>
    80004b38:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004b3a:	e9efb0ef          	jal	800001d8 <kalloc>
    80004b3e:	87aa                	mv	a5,a0
    80004b40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004b42:	6088                	ld	a0,0(s1)
    80004b44:	10050063          	beqz	a0,80004c44 <virtio_disk_init+0x1ec>
    80004b48:	00037717          	auipc	a4,0x37
    80004b4c:	93073703          	ld	a4,-1744(a4) # 8003b478 <disk+0x8>
    80004b50:	0e070a63          	beqz	a4,80004c44 <virtio_disk_init+0x1ec>
    80004b54:	0e078863          	beqz	a5,80004c44 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004b58:	6605                	lui	a2,0x1
    80004b5a:	4581                	li	a1,0
    80004b5c:	ee6fb0ef          	jal	80000242 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004b60:	00037497          	auipc	s1,0x37
    80004b64:	91048493          	addi	s1,s1,-1776 # 8003b470 <disk>
    80004b68:	6605                	lui	a2,0x1
    80004b6a:	4581                	li	a1,0
    80004b6c:	6488                	ld	a0,8(s1)
    80004b6e:	ed4fb0ef          	jal	80000242 <memset>
  memset(disk.used, 0, PGSIZE);
    80004b72:	6605                	lui	a2,0x1
    80004b74:	4581                	li	a1,0
    80004b76:	6888                	ld	a0,16(s1)
    80004b78:	ecafb0ef          	jal	80000242 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004b7c:	100017b7          	lui	a5,0x10001
    80004b80:	4721                	li	a4,8
    80004b82:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004b84:	4098                	lw	a4,0(s1)
    80004b86:	100017b7          	lui	a5,0x10001
    80004b8a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004b8e:	40d8                	lw	a4,4(s1)
    80004b90:	100017b7          	lui	a5,0x10001
    80004b94:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004b98:	649c                	ld	a5,8(s1)
    80004b9a:	0007869b          	sext.w	a3,a5
    80004b9e:	10001737          	lui	a4,0x10001
    80004ba2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004ba6:	9781                	srai	a5,a5,0x20
    80004ba8:	10001737          	lui	a4,0x10001
    80004bac:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004bb0:	689c                	ld	a5,16(s1)
    80004bb2:	0007869b          	sext.w	a3,a5
    80004bb6:	10001737          	lui	a4,0x10001
    80004bba:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004bbe:	9781                	srai	a5,a5,0x20
    80004bc0:	10001737          	lui	a4,0x10001
    80004bc4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004bc8:	10001737          	lui	a4,0x10001
    80004bcc:	4785                	li	a5,1
    80004bce:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004bd0:	00f48c23          	sb	a5,24(s1)
    80004bd4:	00f48ca3          	sb	a5,25(s1)
    80004bd8:	00f48d23          	sb	a5,26(s1)
    80004bdc:	00f48da3          	sb	a5,27(s1)
    80004be0:	00f48e23          	sb	a5,28(s1)
    80004be4:	00f48ea3          	sb	a5,29(s1)
    80004be8:	00f48f23          	sb	a5,30(s1)
    80004bec:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004bf0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004bf4:	100017b7          	lui	a5,0x10001
    80004bf8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004bfc:	60e2                	ld	ra,24(sp)
    80004bfe:	6442                	ld	s0,16(sp)
    80004c00:	64a2                	ld	s1,8(sp)
    80004c02:	6902                	ld	s2,0(sp)
    80004c04:	6105                	addi	sp,sp,32
    80004c06:	8082                	ret
    panic("could not find virtio disk");
    80004c08:	00003517          	auipc	a0,0x3
    80004c0c:	ad850513          	addi	a0,a0,-1320 # 800076e0 <etext+0x6e0>
    80004c10:	273000ef          	jal	80005682 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004c14:	00003517          	auipc	a0,0x3
    80004c18:	aec50513          	addi	a0,a0,-1300 # 80007700 <etext+0x700>
    80004c1c:	267000ef          	jal	80005682 <panic>
    panic("virtio disk should not be ready");
    80004c20:	00003517          	auipc	a0,0x3
    80004c24:	b0050513          	addi	a0,a0,-1280 # 80007720 <etext+0x720>
    80004c28:	25b000ef          	jal	80005682 <panic>
    panic("virtio disk has no queue 0");
    80004c2c:	00003517          	auipc	a0,0x3
    80004c30:	b1450513          	addi	a0,a0,-1260 # 80007740 <etext+0x740>
    80004c34:	24f000ef          	jal	80005682 <panic>
    panic("virtio disk max queue too short");
    80004c38:	00003517          	auipc	a0,0x3
    80004c3c:	b2850513          	addi	a0,a0,-1240 # 80007760 <etext+0x760>
    80004c40:	243000ef          	jal	80005682 <panic>
    panic("virtio disk kalloc");
    80004c44:	00003517          	auipc	a0,0x3
    80004c48:	b3c50513          	addi	a0,a0,-1220 # 80007780 <etext+0x780>
    80004c4c:	237000ef          	jal	80005682 <panic>

0000000080004c50 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004c50:	7159                	addi	sp,sp,-112
    80004c52:	f486                	sd	ra,104(sp)
    80004c54:	f0a2                	sd	s0,96(sp)
    80004c56:	eca6                	sd	s1,88(sp)
    80004c58:	e8ca                	sd	s2,80(sp)
    80004c5a:	e4ce                	sd	s3,72(sp)
    80004c5c:	e0d2                	sd	s4,64(sp)
    80004c5e:	fc56                	sd	s5,56(sp)
    80004c60:	f85a                	sd	s6,48(sp)
    80004c62:	f45e                	sd	s7,40(sp)
    80004c64:	f062                	sd	s8,32(sp)
    80004c66:	ec66                	sd	s9,24(sp)
    80004c68:	1880                	addi	s0,sp,112
    80004c6a:	8a2a                	mv	s4,a0
    80004c6c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004c6e:	00c52c83          	lw	s9,12(a0)
    80004c72:	001c9c9b          	slliw	s9,s9,0x1
    80004c76:	1c82                	slli	s9,s9,0x20
    80004c78:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004c7c:	00037517          	auipc	a0,0x37
    80004c80:	91c50513          	addi	a0,a0,-1764 # 8003b598 <disk+0x128>
    80004c84:	52d000ef          	jal	800059b0 <acquire>
  for(int i = 0; i < 3; i++){
    80004c88:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004c8a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004c8c:	00036b17          	auipc	s6,0x36
    80004c90:	7e4b0b13          	addi	s6,s6,2020 # 8003b470 <disk>
  for(int i = 0; i < 3; i++){
    80004c94:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c96:	00037c17          	auipc	s8,0x37
    80004c9a:	902c0c13          	addi	s8,s8,-1790 # 8003b598 <disk+0x128>
    80004c9e:	a8b9                	j	80004cfc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004ca0:	00fb0733          	add	a4,s6,a5
    80004ca4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004ca8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004caa:	0207c563          	bltz	a5,80004cd4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004cae:	2905                	addiw	s2,s2,1
    80004cb0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004cb2:	05590963          	beq	s2,s5,80004d04 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004cb6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004cb8:	00036717          	auipc	a4,0x36
    80004cbc:	7b870713          	addi	a4,a4,1976 # 8003b470 <disk>
    80004cc0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004cc2:	01874683          	lbu	a3,24(a4)
    80004cc6:	fee9                	bnez	a3,80004ca0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004cc8:	2785                	addiw	a5,a5,1
    80004cca:	0705                	addi	a4,a4,1
    80004ccc:	fe979be3          	bne	a5,s1,80004cc2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004cd0:	57fd                	li	a5,-1
    80004cd2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004cd4:	01205d63          	blez	s2,80004cee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004cd8:	f9042503          	lw	a0,-112(s0)
    80004cdc:	d07ff0ef          	jal	800049e2 <free_desc>
      for(int j = 0; j < i; j++)
    80004ce0:	4785                	li	a5,1
    80004ce2:	0127d663          	bge	a5,s2,80004cee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004ce6:	f9442503          	lw	a0,-108(s0)
    80004cea:	cf9ff0ef          	jal	800049e2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004cee:	85e2                	mv	a1,s8
    80004cf0:	00036517          	auipc	a0,0x36
    80004cf4:	79850513          	addi	a0,a0,1944 # 8003b488 <disk+0x18>
    80004cf8:	ff6fc0ef          	jal	800014ee <sleep>
  for(int i = 0; i < 3; i++){
    80004cfc:	f9040613          	addi	a2,s0,-112
    80004d00:	894e                	mv	s2,s3
    80004d02:	bf55                	j	80004cb6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d04:	f9042503          	lw	a0,-112(s0)
    80004d08:	00451693          	slli	a3,a0,0x4

  if(write)
    80004d0c:	00036797          	auipc	a5,0x36
    80004d10:	76478793          	addi	a5,a5,1892 # 8003b470 <disk>
    80004d14:	00a50713          	addi	a4,a0,10
    80004d18:	0712                	slli	a4,a4,0x4
    80004d1a:	973e                	add	a4,a4,a5
    80004d1c:	01703633          	snez	a2,s7
    80004d20:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004d22:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004d26:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d2a:	6398                	ld	a4,0(a5)
    80004d2c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d2e:	0a868613          	addi	a2,a3,168
    80004d32:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d34:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004d36:	6390                	ld	a2,0(a5)
    80004d38:	00d605b3          	add	a1,a2,a3
    80004d3c:	4741                	li	a4,16
    80004d3e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004d40:	4805                	li	a6,1
    80004d42:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004d46:	f9442703          	lw	a4,-108(s0)
    80004d4a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004d4e:	0712                	slli	a4,a4,0x4
    80004d50:	963a                	add	a2,a2,a4
    80004d52:	058a0593          	addi	a1,s4,88
    80004d56:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004d58:	0007b883          	ld	a7,0(a5)
    80004d5c:	9746                	add	a4,a4,a7
    80004d5e:	40000613          	li	a2,1024
    80004d62:	c710                	sw	a2,8(a4)
  if(write)
    80004d64:	001bb613          	seqz	a2,s7
    80004d68:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004d6c:	00166613          	ori	a2,a2,1
    80004d70:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004d74:	f9842583          	lw	a1,-104(s0)
    80004d78:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004d7c:	00250613          	addi	a2,a0,2
    80004d80:	0612                	slli	a2,a2,0x4
    80004d82:	963e                	add	a2,a2,a5
    80004d84:	577d                	li	a4,-1
    80004d86:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004d8a:	0592                	slli	a1,a1,0x4
    80004d8c:	98ae                	add	a7,a7,a1
    80004d8e:	03068713          	addi	a4,a3,48
    80004d92:	973e                	add	a4,a4,a5
    80004d94:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004d98:	6398                	ld	a4,0(a5)
    80004d9a:	972e                	add	a4,a4,a1
    80004d9c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004da0:	4689                	li	a3,2
    80004da2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004da6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004daa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004dae:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004db2:	6794                	ld	a3,8(a5)
    80004db4:	0026d703          	lhu	a4,2(a3)
    80004db8:	8b1d                	andi	a4,a4,7
    80004dba:	0706                	slli	a4,a4,0x1
    80004dbc:	96ba                	add	a3,a3,a4
    80004dbe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004dc2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004dc6:	6798                	ld	a4,8(a5)
    80004dc8:	00275783          	lhu	a5,2(a4)
    80004dcc:	2785                	addiw	a5,a5,1
    80004dce:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004dd2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004dd6:	100017b7          	lui	a5,0x10001
    80004dda:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004dde:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004de2:	00036917          	auipc	s2,0x36
    80004de6:	7b690913          	addi	s2,s2,1974 # 8003b598 <disk+0x128>
  while(b->disk == 1) {
    80004dea:	4485                	li	s1,1
    80004dec:	01079a63          	bne	a5,a6,80004e00 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004df0:	85ca                	mv	a1,s2
    80004df2:	8552                	mv	a0,s4
    80004df4:	efafc0ef          	jal	800014ee <sleep>
  while(b->disk == 1) {
    80004df8:	004a2783          	lw	a5,4(s4)
    80004dfc:	fe978ae3          	beq	a5,s1,80004df0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004e00:	f9042903          	lw	s2,-112(s0)
    80004e04:	00290713          	addi	a4,s2,2
    80004e08:	0712                	slli	a4,a4,0x4
    80004e0a:	00036797          	auipc	a5,0x36
    80004e0e:	66678793          	addi	a5,a5,1638 # 8003b470 <disk>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004e18:	00036997          	auipc	s3,0x36
    80004e1c:	65898993          	addi	s3,s3,1624 # 8003b470 <disk>
    80004e20:	00491713          	slli	a4,s2,0x4
    80004e24:	0009b783          	ld	a5,0(s3)
    80004e28:	97ba                	add	a5,a5,a4
    80004e2a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004e2e:	854a                	mv	a0,s2
    80004e30:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004e34:	bafff0ef          	jal	800049e2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004e38:	8885                	andi	s1,s1,1
    80004e3a:	f0fd                	bnez	s1,80004e20 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004e3c:	00036517          	auipc	a0,0x36
    80004e40:	75c50513          	addi	a0,a0,1884 # 8003b598 <disk+0x128>
    80004e44:	405000ef          	jal	80005a48 <release>
}
    80004e48:	70a6                	ld	ra,104(sp)
    80004e4a:	7406                	ld	s0,96(sp)
    80004e4c:	64e6                	ld	s1,88(sp)
    80004e4e:	6946                	ld	s2,80(sp)
    80004e50:	69a6                	ld	s3,72(sp)
    80004e52:	6a06                	ld	s4,64(sp)
    80004e54:	7ae2                	ld	s5,56(sp)
    80004e56:	7b42                	ld	s6,48(sp)
    80004e58:	7ba2                	ld	s7,40(sp)
    80004e5a:	7c02                	ld	s8,32(sp)
    80004e5c:	6ce2                	ld	s9,24(sp)
    80004e5e:	6165                	addi	sp,sp,112
    80004e60:	8082                	ret

0000000080004e62 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004e62:	1101                	addi	sp,sp,-32
    80004e64:	ec06                	sd	ra,24(sp)
    80004e66:	e822                	sd	s0,16(sp)
    80004e68:	e426                	sd	s1,8(sp)
    80004e6a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004e6c:	00036497          	auipc	s1,0x36
    80004e70:	60448493          	addi	s1,s1,1540 # 8003b470 <disk>
    80004e74:	00036517          	auipc	a0,0x36
    80004e78:	72450513          	addi	a0,a0,1828 # 8003b598 <disk+0x128>
    80004e7c:	335000ef          	jal	800059b0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004e80:	100017b7          	lui	a5,0x10001
    80004e84:	53b8                	lw	a4,96(a5)
    80004e86:	8b0d                	andi	a4,a4,3
    80004e88:	100017b7          	lui	a5,0x10001
    80004e8c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004e8e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004e92:	689c                	ld	a5,16(s1)
    80004e94:	0204d703          	lhu	a4,32(s1)
    80004e98:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004e9c:	04f70663          	beq	a4,a5,80004ee8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004ea0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004ea4:	6898                	ld	a4,16(s1)
    80004ea6:	0204d783          	lhu	a5,32(s1)
    80004eaa:	8b9d                	andi	a5,a5,7
    80004eac:	078e                	slli	a5,a5,0x3
    80004eae:	97ba                	add	a5,a5,a4
    80004eb0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004eb2:	00278713          	addi	a4,a5,2
    80004eb6:	0712                	slli	a4,a4,0x4
    80004eb8:	9726                	add	a4,a4,s1
    80004eba:	01074703          	lbu	a4,16(a4)
    80004ebe:	e321                	bnez	a4,80004efe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004ec0:	0789                	addi	a5,a5,2
    80004ec2:	0792                	slli	a5,a5,0x4
    80004ec4:	97a6                	add	a5,a5,s1
    80004ec6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004ec8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004ecc:	e6efc0ef          	jal	8000153a <wakeup>

    disk.used_idx += 1;
    80004ed0:	0204d783          	lhu	a5,32(s1)
    80004ed4:	2785                	addiw	a5,a5,1
    80004ed6:	17c2                	slli	a5,a5,0x30
    80004ed8:	93c1                	srli	a5,a5,0x30
    80004eda:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004ede:	6898                	ld	a4,16(s1)
    80004ee0:	00275703          	lhu	a4,2(a4)
    80004ee4:	faf71ee3          	bne	a4,a5,80004ea0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004ee8:	00036517          	auipc	a0,0x36
    80004eec:	6b050513          	addi	a0,a0,1712 # 8003b598 <disk+0x128>
    80004ef0:	359000ef          	jal	80005a48 <release>
}
    80004ef4:	60e2                	ld	ra,24(sp)
    80004ef6:	6442                	ld	s0,16(sp)
    80004ef8:	64a2                	ld	s1,8(sp)
    80004efa:	6105                	addi	sp,sp,32
    80004efc:	8082                	ret
      panic("virtio_disk_intr status");
    80004efe:	00003517          	auipc	a0,0x3
    80004f02:	89a50513          	addi	a0,a0,-1894 # 80007798 <etext+0x798>
    80004f06:	77c000ef          	jal	80005682 <panic>

0000000080004f0a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004f0a:	1141                	addi	sp,sp,-16
    80004f0c:	e422                	sd	s0,8(sp)
    80004f0e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004f10:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004f14:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004f18:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004f1c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004f20:	577d                	li	a4,-1
    80004f22:	177e                	slli	a4,a4,0x3f
    80004f24:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004f26:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004f2a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004f2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004f32:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004f36:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004f3a:	000f4737          	lui	a4,0xf4
    80004f3e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004f42:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004f44:	14d79073          	csrw	stimecmp,a5
}
    80004f48:	6422                	ld	s0,8(sp)
    80004f4a:	0141                	addi	sp,sp,16
    80004f4c:	8082                	ret

0000000080004f4e <start>:
{
    80004f4e:	1141                	addi	sp,sp,-16
    80004f50:	e406                	sd	ra,8(sp)
    80004f52:	e022                	sd	s0,0(sp)
    80004f54:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004f56:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004f5a:	7779                	lui	a4,0xffffe
    80004f5c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb14f>
    80004f60:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004f62:	6705                	lui	a4,0x1
    80004f64:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004f68:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004f6a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004f6e:	ffffb797          	auipc	a5,0xffffb
    80004f72:	46e78793          	addi	a5,a5,1134 # 800003dc <main>
    80004f76:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004f7a:	4781                	li	a5,0
    80004f7c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004f80:	67c1                	lui	a5,0x10
    80004f82:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004f84:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004f88:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004f8c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004f90:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004f94:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004f98:	57fd                	li	a5,-1
    80004f9a:	83a9                	srli	a5,a5,0xa
    80004f9c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004fa0:	47bd                	li	a5,15
    80004fa2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004fa6:	f65ff0ef          	jal	80004f0a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004faa:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004fae:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004fb0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004fb2:	30200073          	mret
}
    80004fb6:	60a2                	ld	ra,8(sp)
    80004fb8:	6402                	ld	s0,0(sp)
    80004fba:	0141                	addi	sp,sp,16
    80004fbc:	8082                	ret

0000000080004fbe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004fbe:	715d                	addi	sp,sp,-80
    80004fc0:	e486                	sd	ra,72(sp)
    80004fc2:	e0a2                	sd	s0,64(sp)
    80004fc4:	f84a                	sd	s2,48(sp)
    80004fc6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004fc8:	04c05263          	blez	a2,8000500c <consolewrite+0x4e>
    80004fcc:	fc26                	sd	s1,56(sp)
    80004fce:	f44e                	sd	s3,40(sp)
    80004fd0:	f052                	sd	s4,32(sp)
    80004fd2:	ec56                	sd	s5,24(sp)
    80004fd4:	8a2a                	mv	s4,a0
    80004fd6:	84ae                	mv	s1,a1
    80004fd8:	89b2                	mv	s3,a2
    80004fda:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004fdc:	5afd                	li	s5,-1
    80004fde:	4685                	li	a3,1
    80004fe0:	8626                	mv	a2,s1
    80004fe2:	85d2                	mv	a1,s4
    80004fe4:	fbf40513          	addi	a0,s0,-65
    80004fe8:	8adfc0ef          	jal	80001894 <either_copyin>
    80004fec:	03550263          	beq	a0,s5,80005010 <consolewrite+0x52>
      break;
    uartputc(c);
    80004ff0:	fbf44503          	lbu	a0,-65(s0)
    80004ff4:	035000ef          	jal	80005828 <uartputc>
  for(i = 0; i < n; i++){
    80004ff8:	2905                	addiw	s2,s2,1
    80004ffa:	0485                	addi	s1,s1,1
    80004ffc:	ff2991e3          	bne	s3,s2,80004fde <consolewrite+0x20>
    80005000:	894e                	mv	s2,s3
    80005002:	74e2                	ld	s1,56(sp)
    80005004:	79a2                	ld	s3,40(sp)
    80005006:	7a02                	ld	s4,32(sp)
    80005008:	6ae2                	ld	s5,24(sp)
    8000500a:	a039                	j	80005018 <consolewrite+0x5a>
    8000500c:	4901                	li	s2,0
    8000500e:	a029                	j	80005018 <consolewrite+0x5a>
    80005010:	74e2                	ld	s1,56(sp)
    80005012:	79a2                	ld	s3,40(sp)
    80005014:	7a02                	ld	s4,32(sp)
    80005016:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80005018:	854a                	mv	a0,s2
    8000501a:	60a6                	ld	ra,72(sp)
    8000501c:	6406                	ld	s0,64(sp)
    8000501e:	7942                	ld	s2,48(sp)
    80005020:	6161                	addi	sp,sp,80
    80005022:	8082                	ret

0000000080005024 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005024:	711d                	addi	sp,sp,-96
    80005026:	ec86                	sd	ra,88(sp)
    80005028:	e8a2                	sd	s0,80(sp)
    8000502a:	e4a6                	sd	s1,72(sp)
    8000502c:	e0ca                	sd	s2,64(sp)
    8000502e:	fc4e                	sd	s3,56(sp)
    80005030:	f852                	sd	s4,48(sp)
    80005032:	f456                	sd	s5,40(sp)
    80005034:	f05a                	sd	s6,32(sp)
    80005036:	1080                	addi	s0,sp,96
    80005038:	8aaa                	mv	s5,a0
    8000503a:	8a2e                	mv	s4,a1
    8000503c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000503e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005042:	0003e517          	auipc	a0,0x3e
    80005046:	56e50513          	addi	a0,a0,1390 # 800435b0 <cons>
    8000504a:	167000ef          	jal	800059b0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000504e:	0003e497          	auipc	s1,0x3e
    80005052:	56248493          	addi	s1,s1,1378 # 800435b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005056:	0003e917          	auipc	s2,0x3e
    8000505a:	5f290913          	addi	s2,s2,1522 # 80043648 <cons+0x98>
  while(n > 0){
    8000505e:	0b305d63          	blez	s3,80005118 <consoleread+0xf4>
    while(cons.r == cons.w){
    80005062:	0984a783          	lw	a5,152(s1)
    80005066:	09c4a703          	lw	a4,156(s1)
    8000506a:	0af71263          	bne	a4,a5,8000510e <consoleread+0xea>
      if(killed(myproc())){
    8000506e:	eb3fb0ef          	jal	80000f20 <myproc>
    80005072:	eb4fc0ef          	jal	80001726 <killed>
    80005076:	e12d                	bnez	a0,800050d8 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80005078:	85a6                	mv	a1,s1
    8000507a:	854a                	mv	a0,s2
    8000507c:	c72fc0ef          	jal	800014ee <sleep>
    while(cons.r == cons.w){
    80005080:	0984a783          	lw	a5,152(s1)
    80005084:	09c4a703          	lw	a4,156(s1)
    80005088:	fef703e3          	beq	a4,a5,8000506e <consoleread+0x4a>
    8000508c:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    8000508e:	0003e717          	auipc	a4,0x3e
    80005092:	52270713          	addi	a4,a4,1314 # 800435b0 <cons>
    80005096:	0017869b          	addiw	a3,a5,1
    8000509a:	08d72c23          	sw	a3,152(a4)
    8000509e:	07f7f693          	andi	a3,a5,127
    800050a2:	9736                	add	a4,a4,a3
    800050a4:	01874703          	lbu	a4,24(a4)
    800050a8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800050ac:	4691                	li	a3,4
    800050ae:	04db8663          	beq	s7,a3,800050fa <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800050b2:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800050b6:	4685                	li	a3,1
    800050b8:	faf40613          	addi	a2,s0,-81
    800050bc:	85d2                	mv	a1,s4
    800050be:	8556                	mv	a0,s5
    800050c0:	f8afc0ef          	jal	8000184a <either_copyout>
    800050c4:	57fd                	li	a5,-1
    800050c6:	04f50863          	beq	a0,a5,80005116 <consoleread+0xf2>
      break;

    dst++;
    800050ca:	0a05                	addi	s4,s4,1
    --n;
    800050cc:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800050ce:	47a9                	li	a5,10
    800050d0:	04fb8d63          	beq	s7,a5,8000512a <consoleread+0x106>
    800050d4:	6be2                	ld	s7,24(sp)
    800050d6:	b761                	j	8000505e <consoleread+0x3a>
        release(&cons.lock);
    800050d8:	0003e517          	auipc	a0,0x3e
    800050dc:	4d850513          	addi	a0,a0,1240 # 800435b0 <cons>
    800050e0:	169000ef          	jal	80005a48 <release>
        return -1;
    800050e4:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800050e6:	60e6                	ld	ra,88(sp)
    800050e8:	6446                	ld	s0,80(sp)
    800050ea:	64a6                	ld	s1,72(sp)
    800050ec:	6906                	ld	s2,64(sp)
    800050ee:	79e2                	ld	s3,56(sp)
    800050f0:	7a42                	ld	s4,48(sp)
    800050f2:	7aa2                	ld	s5,40(sp)
    800050f4:	7b02                	ld	s6,32(sp)
    800050f6:	6125                	addi	sp,sp,96
    800050f8:	8082                	ret
      if(n < target){
    800050fa:	0009871b          	sext.w	a4,s3
    800050fe:	01677a63          	bgeu	a4,s6,80005112 <consoleread+0xee>
        cons.r--;
    80005102:	0003e717          	auipc	a4,0x3e
    80005106:	54f72323          	sw	a5,1350(a4) # 80043648 <cons+0x98>
    8000510a:	6be2                	ld	s7,24(sp)
    8000510c:	a031                	j	80005118 <consoleread+0xf4>
    8000510e:	ec5e                	sd	s7,24(sp)
    80005110:	bfbd                	j	8000508e <consoleread+0x6a>
    80005112:	6be2                	ld	s7,24(sp)
    80005114:	a011                	j	80005118 <consoleread+0xf4>
    80005116:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005118:	0003e517          	auipc	a0,0x3e
    8000511c:	49850513          	addi	a0,a0,1176 # 800435b0 <cons>
    80005120:	129000ef          	jal	80005a48 <release>
  return target - n;
    80005124:	413b053b          	subw	a0,s6,s3
    80005128:	bf7d                	j	800050e6 <consoleread+0xc2>
    8000512a:	6be2                	ld	s7,24(sp)
    8000512c:	b7f5                	j	80005118 <consoleread+0xf4>

000000008000512e <consputc>:
{
    8000512e:	1141                	addi	sp,sp,-16
    80005130:	e406                	sd	ra,8(sp)
    80005132:	e022                	sd	s0,0(sp)
    80005134:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005136:	10000793          	li	a5,256
    8000513a:	00f50863          	beq	a0,a5,8000514a <consputc+0x1c>
    uartputc_sync(c);
    8000513e:	604000ef          	jal	80005742 <uartputc_sync>
}
    80005142:	60a2                	ld	ra,8(sp)
    80005144:	6402                	ld	s0,0(sp)
    80005146:	0141                	addi	sp,sp,16
    80005148:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000514a:	4521                	li	a0,8
    8000514c:	5f6000ef          	jal	80005742 <uartputc_sync>
    80005150:	02000513          	li	a0,32
    80005154:	5ee000ef          	jal	80005742 <uartputc_sync>
    80005158:	4521                	li	a0,8
    8000515a:	5e8000ef          	jal	80005742 <uartputc_sync>
    8000515e:	b7d5                	j	80005142 <consputc+0x14>

0000000080005160 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005160:	1101                	addi	sp,sp,-32
    80005162:	ec06                	sd	ra,24(sp)
    80005164:	e822                	sd	s0,16(sp)
    80005166:	e426                	sd	s1,8(sp)
    80005168:	1000                	addi	s0,sp,32
    8000516a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000516c:	0003e517          	auipc	a0,0x3e
    80005170:	44450513          	addi	a0,a0,1092 # 800435b0 <cons>
    80005174:	03d000ef          	jal	800059b0 <acquire>

  switch(c){
    80005178:	47d5                	li	a5,21
    8000517a:	08f48f63          	beq	s1,a5,80005218 <consoleintr+0xb8>
    8000517e:	0297c563          	blt	a5,s1,800051a8 <consoleintr+0x48>
    80005182:	47a1                	li	a5,8
    80005184:	0ef48463          	beq	s1,a5,8000526c <consoleintr+0x10c>
    80005188:	47c1                	li	a5,16
    8000518a:	10f49563          	bne	s1,a5,80005294 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    8000518e:	f50fc0ef          	jal	800018de <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005192:	0003e517          	auipc	a0,0x3e
    80005196:	41e50513          	addi	a0,a0,1054 # 800435b0 <cons>
    8000519a:	0af000ef          	jal	80005a48 <release>
}
    8000519e:	60e2                	ld	ra,24(sp)
    800051a0:	6442                	ld	s0,16(sp)
    800051a2:	64a2                	ld	s1,8(sp)
    800051a4:	6105                	addi	sp,sp,32
    800051a6:	8082                	ret
  switch(c){
    800051a8:	07f00793          	li	a5,127
    800051ac:	0cf48063          	beq	s1,a5,8000526c <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051b0:	0003e717          	auipc	a4,0x3e
    800051b4:	40070713          	addi	a4,a4,1024 # 800435b0 <cons>
    800051b8:	0a072783          	lw	a5,160(a4)
    800051bc:	09872703          	lw	a4,152(a4)
    800051c0:	9f99                	subw	a5,a5,a4
    800051c2:	07f00713          	li	a4,127
    800051c6:	fcf766e3          	bltu	a4,a5,80005192 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800051ca:	47b5                	li	a5,13
    800051cc:	0cf48763          	beq	s1,a5,8000529a <consoleintr+0x13a>
      consputc(c);
    800051d0:	8526                	mv	a0,s1
    800051d2:	f5dff0ef          	jal	8000512e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051d6:	0003e797          	auipc	a5,0x3e
    800051da:	3da78793          	addi	a5,a5,986 # 800435b0 <cons>
    800051de:	0a07a683          	lw	a3,160(a5)
    800051e2:	0016871b          	addiw	a4,a3,1
    800051e6:	0007061b          	sext.w	a2,a4
    800051ea:	0ae7a023          	sw	a4,160(a5)
    800051ee:	07f6f693          	andi	a3,a3,127
    800051f2:	97b6                	add	a5,a5,a3
    800051f4:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800051f8:	47a9                	li	a5,10
    800051fa:	0cf48563          	beq	s1,a5,800052c4 <consoleintr+0x164>
    800051fe:	4791                	li	a5,4
    80005200:	0cf48263          	beq	s1,a5,800052c4 <consoleintr+0x164>
    80005204:	0003e797          	auipc	a5,0x3e
    80005208:	4447a783          	lw	a5,1092(a5) # 80043648 <cons+0x98>
    8000520c:	9f1d                	subw	a4,a4,a5
    8000520e:	08000793          	li	a5,128
    80005212:	f8f710e3          	bne	a4,a5,80005192 <consoleintr+0x32>
    80005216:	a07d                	j	800052c4 <consoleintr+0x164>
    80005218:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000521a:	0003e717          	auipc	a4,0x3e
    8000521e:	39670713          	addi	a4,a4,918 # 800435b0 <cons>
    80005222:	0a072783          	lw	a5,160(a4)
    80005226:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000522a:	0003e497          	auipc	s1,0x3e
    8000522e:	38648493          	addi	s1,s1,902 # 800435b0 <cons>
    while(cons.e != cons.w &&
    80005232:	4929                	li	s2,10
    80005234:	02f70863          	beq	a4,a5,80005264 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005238:	37fd                	addiw	a5,a5,-1
    8000523a:	07f7f713          	andi	a4,a5,127
    8000523e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005240:	01874703          	lbu	a4,24(a4)
    80005244:	03270263          	beq	a4,s2,80005268 <consoleintr+0x108>
      cons.e--;
    80005248:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000524c:	10000513          	li	a0,256
    80005250:	edfff0ef          	jal	8000512e <consputc>
    while(cons.e != cons.w &&
    80005254:	0a04a783          	lw	a5,160(s1)
    80005258:	09c4a703          	lw	a4,156(s1)
    8000525c:	fcf71ee3          	bne	a4,a5,80005238 <consoleintr+0xd8>
    80005260:	6902                	ld	s2,0(sp)
    80005262:	bf05                	j	80005192 <consoleintr+0x32>
    80005264:	6902                	ld	s2,0(sp)
    80005266:	b735                	j	80005192 <consoleintr+0x32>
    80005268:	6902                	ld	s2,0(sp)
    8000526a:	b725                	j	80005192 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000526c:	0003e717          	auipc	a4,0x3e
    80005270:	34470713          	addi	a4,a4,836 # 800435b0 <cons>
    80005274:	0a072783          	lw	a5,160(a4)
    80005278:	09c72703          	lw	a4,156(a4)
    8000527c:	f0f70be3          	beq	a4,a5,80005192 <consoleintr+0x32>
      cons.e--;
    80005280:	37fd                	addiw	a5,a5,-1
    80005282:	0003e717          	auipc	a4,0x3e
    80005286:	3cf72723          	sw	a5,974(a4) # 80043650 <cons+0xa0>
      consputc(BACKSPACE);
    8000528a:	10000513          	li	a0,256
    8000528e:	ea1ff0ef          	jal	8000512e <consputc>
    80005292:	b701                	j	80005192 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005294:	ee048fe3          	beqz	s1,80005192 <consoleintr+0x32>
    80005298:	bf21                	j	800051b0 <consoleintr+0x50>
      consputc(c);
    8000529a:	4529                	li	a0,10
    8000529c:	e93ff0ef          	jal	8000512e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800052a0:	0003e797          	auipc	a5,0x3e
    800052a4:	31078793          	addi	a5,a5,784 # 800435b0 <cons>
    800052a8:	0a07a703          	lw	a4,160(a5)
    800052ac:	0017069b          	addiw	a3,a4,1
    800052b0:	0006861b          	sext.w	a2,a3
    800052b4:	0ad7a023          	sw	a3,160(a5)
    800052b8:	07f77713          	andi	a4,a4,127
    800052bc:	97ba                	add	a5,a5,a4
    800052be:	4729                	li	a4,10
    800052c0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800052c4:	0003e797          	auipc	a5,0x3e
    800052c8:	38c7a423          	sw	a2,904(a5) # 8004364c <cons+0x9c>
        wakeup(&cons.r);
    800052cc:	0003e517          	auipc	a0,0x3e
    800052d0:	37c50513          	addi	a0,a0,892 # 80043648 <cons+0x98>
    800052d4:	a66fc0ef          	jal	8000153a <wakeup>
    800052d8:	bd6d                	j	80005192 <consoleintr+0x32>

00000000800052da <consoleinit>:

void
consoleinit(void)
{
    800052da:	1141                	addi	sp,sp,-16
    800052dc:	e406                	sd	ra,8(sp)
    800052de:	e022                	sd	s0,0(sp)
    800052e0:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800052e2:	00002597          	auipc	a1,0x2
    800052e6:	4ce58593          	addi	a1,a1,1230 # 800077b0 <etext+0x7b0>
    800052ea:	0003e517          	auipc	a0,0x3e
    800052ee:	2c650513          	addi	a0,a0,710 # 800435b0 <cons>
    800052f2:	63e000ef          	jal	80005930 <initlock>

  uartinit();
    800052f6:	3f4000ef          	jal	800056ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800052fa:	00035797          	auipc	a5,0x35
    800052fe:	11e78793          	addi	a5,a5,286 # 8003a418 <devsw>
    80005302:	00000717          	auipc	a4,0x0
    80005306:	d2270713          	addi	a4,a4,-734 # 80005024 <consoleread>
    8000530a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000530c:	00000717          	auipc	a4,0x0
    80005310:	cb270713          	addi	a4,a4,-846 # 80004fbe <consolewrite>
    80005314:	ef98                	sd	a4,24(a5)
}
    80005316:	60a2                	ld	ra,8(sp)
    80005318:	6402                	ld	s0,0(sp)
    8000531a:	0141                	addi	sp,sp,16
    8000531c:	8082                	ret

000000008000531e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000531e:	7179                	addi	sp,sp,-48
    80005320:	f406                	sd	ra,40(sp)
    80005322:	f022                	sd	s0,32(sp)
    80005324:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005326:	c219                	beqz	a2,8000532c <printint+0xe>
    80005328:	08054063          	bltz	a0,800053a8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000532c:	4881                	li	a7,0
    8000532e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005332:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005334:	00002617          	auipc	a2,0x2
    80005338:	5d460613          	addi	a2,a2,1492 # 80007908 <digits>
    8000533c:	883e                	mv	a6,a5
    8000533e:	2785                	addiw	a5,a5,1
    80005340:	02b57733          	remu	a4,a0,a1
    80005344:	9732                	add	a4,a4,a2
    80005346:	00074703          	lbu	a4,0(a4)
    8000534a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000534e:	872a                	mv	a4,a0
    80005350:	02b55533          	divu	a0,a0,a1
    80005354:	0685                	addi	a3,a3,1
    80005356:	feb773e3          	bgeu	a4,a1,8000533c <printint+0x1e>

  if(sign)
    8000535a:	00088a63          	beqz	a7,8000536e <printint+0x50>
    buf[i++] = '-';
    8000535e:	1781                	addi	a5,a5,-32
    80005360:	97a2                	add	a5,a5,s0
    80005362:	02d00713          	li	a4,45
    80005366:	fee78823          	sb	a4,-16(a5)
    8000536a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000536e:	02f05963          	blez	a5,800053a0 <printint+0x82>
    80005372:	ec26                	sd	s1,24(sp)
    80005374:	e84a                	sd	s2,16(sp)
    80005376:	fd040713          	addi	a4,s0,-48
    8000537a:	00f704b3          	add	s1,a4,a5
    8000537e:	fff70913          	addi	s2,a4,-1
    80005382:	993e                	add	s2,s2,a5
    80005384:	37fd                	addiw	a5,a5,-1
    80005386:	1782                	slli	a5,a5,0x20
    80005388:	9381                	srli	a5,a5,0x20
    8000538a:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000538e:	fff4c503          	lbu	a0,-1(s1)
    80005392:	d9dff0ef          	jal	8000512e <consputc>
  while(--i >= 0)
    80005396:	14fd                	addi	s1,s1,-1
    80005398:	ff249be3          	bne	s1,s2,8000538e <printint+0x70>
    8000539c:	64e2                	ld	s1,24(sp)
    8000539e:	6942                	ld	s2,16(sp)
}
    800053a0:	70a2                	ld	ra,40(sp)
    800053a2:	7402                	ld	s0,32(sp)
    800053a4:	6145                	addi	sp,sp,48
    800053a6:	8082                	ret
    x = -xx;
    800053a8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800053ac:	4885                	li	a7,1
    x = -xx;
    800053ae:	b741                	j	8000532e <printint+0x10>

00000000800053b0 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800053b0:	7155                	addi	sp,sp,-208
    800053b2:	e506                	sd	ra,136(sp)
    800053b4:	e122                	sd	s0,128(sp)
    800053b6:	f0d2                	sd	s4,96(sp)
    800053b8:	0900                	addi	s0,sp,144
    800053ba:	8a2a                	mv	s4,a0
    800053bc:	e40c                	sd	a1,8(s0)
    800053be:	e810                	sd	a2,16(s0)
    800053c0:	ec14                	sd	a3,24(s0)
    800053c2:	f018                	sd	a4,32(s0)
    800053c4:	f41c                	sd	a5,40(s0)
    800053c6:	03043823          	sd	a6,48(s0)
    800053ca:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800053ce:	0003e797          	auipc	a5,0x3e
    800053d2:	2a27a783          	lw	a5,674(a5) # 80043670 <pr+0x18>
    800053d6:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800053da:	e3a1                	bnez	a5,8000541a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800053dc:	00840793          	addi	a5,s0,8
    800053e0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800053e4:	00054503          	lbu	a0,0(a0)
    800053e8:	26050763          	beqz	a0,80005656 <printf+0x2a6>
    800053ec:	fca6                	sd	s1,120(sp)
    800053ee:	f8ca                	sd	s2,112(sp)
    800053f0:	f4ce                	sd	s3,104(sp)
    800053f2:	ecd6                	sd	s5,88(sp)
    800053f4:	e8da                	sd	s6,80(sp)
    800053f6:	e0e2                	sd	s8,64(sp)
    800053f8:	fc66                	sd	s9,56(sp)
    800053fa:	f86a                	sd	s10,48(sp)
    800053fc:	f46e                	sd	s11,40(sp)
    800053fe:	4981                	li	s3,0
    if(cx != '%'){
    80005400:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005404:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005408:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000540c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005410:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005414:	07000d93          	li	s11,112
    80005418:	a815                	j	8000544c <printf+0x9c>
    acquire(&pr.lock);
    8000541a:	0003e517          	auipc	a0,0x3e
    8000541e:	23e50513          	addi	a0,a0,574 # 80043658 <pr>
    80005422:	58e000ef          	jal	800059b0 <acquire>
  va_start(ap, fmt);
    80005426:	00840793          	addi	a5,s0,8
    8000542a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000542e:	000a4503          	lbu	a0,0(s4)
    80005432:	fd4d                	bnez	a0,800053ec <printf+0x3c>
    80005434:	a481                	j	80005674 <printf+0x2c4>
      consputc(cx);
    80005436:	cf9ff0ef          	jal	8000512e <consputc>
      continue;
    8000543a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000543c:	0014899b          	addiw	s3,s1,1
    80005440:	013a07b3          	add	a5,s4,s3
    80005444:	0007c503          	lbu	a0,0(a5)
    80005448:	1e050b63          	beqz	a0,8000563e <printf+0x28e>
    if(cx != '%'){
    8000544c:	ff5515e3          	bne	a0,s5,80005436 <printf+0x86>
    i++;
    80005450:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005454:	009a07b3          	add	a5,s4,s1
    80005458:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000545c:	1e090163          	beqz	s2,8000563e <printf+0x28e>
    80005460:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005464:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80005466:	c789                	beqz	a5,80005470 <printf+0xc0>
    80005468:	009a0733          	add	a4,s4,s1
    8000546c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005470:	03690763          	beq	s2,s6,8000549e <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80005474:	05890163          	beq	s2,s8,800054b6 <printf+0x106>
    } else if(c0 == 'u'){
    80005478:	0d990b63          	beq	s2,s9,8000554e <printf+0x19e>
    } else if(c0 == 'x'){
    8000547c:	13a90163          	beq	s2,s10,8000559e <printf+0x1ee>
    } else if(c0 == 'p'){
    80005480:	13b90b63          	beq	s2,s11,800055b6 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80005484:	07300793          	li	a5,115
    80005488:	16f90a63          	beq	s2,a5,800055fc <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000548c:	1b590463          	beq	s2,s5,80005634 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80005490:	8556                	mv	a0,s5
    80005492:	c9dff0ef          	jal	8000512e <consputc>
      consputc(c0);
    80005496:	854a                	mv	a0,s2
    80005498:	c97ff0ef          	jal	8000512e <consputc>
    8000549c:	b745                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    8000549e:	f8843783          	ld	a5,-120(s0)
    800054a2:	00878713          	addi	a4,a5,8
    800054a6:	f8e43423          	sd	a4,-120(s0)
    800054aa:	4605                	li	a2,1
    800054ac:	45a9                	li	a1,10
    800054ae:	4388                	lw	a0,0(a5)
    800054b0:	e6fff0ef          	jal	8000531e <printint>
    800054b4:	b761                	j	8000543c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800054b6:	03678663          	beq	a5,s6,800054e2 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054ba:	05878263          	beq	a5,s8,800054fe <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800054be:	0b978463          	beq	a5,s9,80005566 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800054c2:	fda797e3          	bne	a5,s10,80005490 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800054c6:	f8843783          	ld	a5,-120(s0)
    800054ca:	00878713          	addi	a4,a5,8
    800054ce:	f8e43423          	sd	a4,-120(s0)
    800054d2:	4601                	li	a2,0
    800054d4:	45c1                	li	a1,16
    800054d6:	6388                	ld	a0,0(a5)
    800054d8:	e47ff0ef          	jal	8000531e <printint>
      i += 1;
    800054dc:	0029849b          	addiw	s1,s3,2
    800054e0:	bfb1                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800054e2:	f8843783          	ld	a5,-120(s0)
    800054e6:	00878713          	addi	a4,a5,8
    800054ea:	f8e43423          	sd	a4,-120(s0)
    800054ee:	4605                	li	a2,1
    800054f0:	45a9                	li	a1,10
    800054f2:	6388                	ld	a0,0(a5)
    800054f4:	e2bff0ef          	jal	8000531e <printint>
      i += 1;
    800054f8:	0029849b          	addiw	s1,s3,2
    800054fc:	b781                	j	8000543c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054fe:	06400793          	li	a5,100
    80005502:	02f68863          	beq	a3,a5,80005532 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005506:	07500793          	li	a5,117
    8000550a:	06f68c63          	beq	a3,a5,80005582 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000550e:	07800793          	li	a5,120
    80005512:	f6f69fe3          	bne	a3,a5,80005490 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005516:	f8843783          	ld	a5,-120(s0)
    8000551a:	00878713          	addi	a4,a5,8
    8000551e:	f8e43423          	sd	a4,-120(s0)
    80005522:	4601                	li	a2,0
    80005524:	45c1                	li	a1,16
    80005526:	6388                	ld	a0,0(a5)
    80005528:	df7ff0ef          	jal	8000531e <printint>
      i += 2;
    8000552c:	0039849b          	addiw	s1,s3,3
    80005530:	b731                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005532:	f8843783          	ld	a5,-120(s0)
    80005536:	00878713          	addi	a4,a5,8
    8000553a:	f8e43423          	sd	a4,-120(s0)
    8000553e:	4605                	li	a2,1
    80005540:	45a9                	li	a1,10
    80005542:	6388                	ld	a0,0(a5)
    80005544:	ddbff0ef          	jal	8000531e <printint>
      i += 2;
    80005548:	0039849b          	addiw	s1,s3,3
    8000554c:	bdc5                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000554e:	f8843783          	ld	a5,-120(s0)
    80005552:	00878713          	addi	a4,a5,8
    80005556:	f8e43423          	sd	a4,-120(s0)
    8000555a:	4601                	li	a2,0
    8000555c:	45a9                	li	a1,10
    8000555e:	4388                	lw	a0,0(a5)
    80005560:	dbfff0ef          	jal	8000531e <printint>
    80005564:	bde1                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005566:	f8843783          	ld	a5,-120(s0)
    8000556a:	00878713          	addi	a4,a5,8
    8000556e:	f8e43423          	sd	a4,-120(s0)
    80005572:	4601                	li	a2,0
    80005574:	45a9                	li	a1,10
    80005576:	6388                	ld	a0,0(a5)
    80005578:	da7ff0ef          	jal	8000531e <printint>
      i += 1;
    8000557c:	0029849b          	addiw	s1,s3,2
    80005580:	bd75                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005582:	f8843783          	ld	a5,-120(s0)
    80005586:	00878713          	addi	a4,a5,8
    8000558a:	f8e43423          	sd	a4,-120(s0)
    8000558e:	4601                	li	a2,0
    80005590:	45a9                	li	a1,10
    80005592:	6388                	ld	a0,0(a5)
    80005594:	d8bff0ef          	jal	8000531e <printint>
      i += 2;
    80005598:	0039849b          	addiw	s1,s3,3
    8000559c:	b545                	j	8000543c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    8000559e:	f8843783          	ld	a5,-120(s0)
    800055a2:	00878713          	addi	a4,a5,8
    800055a6:	f8e43423          	sd	a4,-120(s0)
    800055aa:	4601                	li	a2,0
    800055ac:	45c1                	li	a1,16
    800055ae:	4388                	lw	a0,0(a5)
    800055b0:	d6fff0ef          	jal	8000531e <printint>
    800055b4:	b561                	j	8000543c <printf+0x8c>
    800055b6:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800055b8:	f8843783          	ld	a5,-120(s0)
    800055bc:	00878713          	addi	a4,a5,8
    800055c0:	f8e43423          	sd	a4,-120(s0)
    800055c4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800055c8:	03000513          	li	a0,48
    800055cc:	b63ff0ef          	jal	8000512e <consputc>
  consputc('x');
    800055d0:	07800513          	li	a0,120
    800055d4:	b5bff0ef          	jal	8000512e <consputc>
    800055d8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800055da:	00002b97          	auipc	s7,0x2
    800055de:	32eb8b93          	addi	s7,s7,814 # 80007908 <digits>
    800055e2:	03c9d793          	srli	a5,s3,0x3c
    800055e6:	97de                	add	a5,a5,s7
    800055e8:	0007c503          	lbu	a0,0(a5)
    800055ec:	b43ff0ef          	jal	8000512e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800055f0:	0992                	slli	s3,s3,0x4
    800055f2:	397d                	addiw	s2,s2,-1
    800055f4:	fe0917e3          	bnez	s2,800055e2 <printf+0x232>
    800055f8:	6ba6                	ld	s7,72(sp)
    800055fa:	b589                	j	8000543c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    800055fc:	f8843783          	ld	a5,-120(s0)
    80005600:	00878713          	addi	a4,a5,8
    80005604:	f8e43423          	sd	a4,-120(s0)
    80005608:	0007b903          	ld	s2,0(a5)
    8000560c:	00090d63          	beqz	s2,80005626 <printf+0x276>
      for(; *s; s++)
    80005610:	00094503          	lbu	a0,0(s2)
    80005614:	e20504e3          	beqz	a0,8000543c <printf+0x8c>
        consputc(*s);
    80005618:	b17ff0ef          	jal	8000512e <consputc>
      for(; *s; s++)
    8000561c:	0905                	addi	s2,s2,1
    8000561e:	00094503          	lbu	a0,0(s2)
    80005622:	f97d                	bnez	a0,80005618 <printf+0x268>
    80005624:	bd21                	j	8000543c <printf+0x8c>
        s = "(null)";
    80005626:	00002917          	auipc	s2,0x2
    8000562a:	19290913          	addi	s2,s2,402 # 800077b8 <etext+0x7b8>
      for(; *s; s++)
    8000562e:	02800513          	li	a0,40
    80005632:	b7dd                	j	80005618 <printf+0x268>
      consputc('%');
    80005634:	02500513          	li	a0,37
    80005638:	af7ff0ef          	jal	8000512e <consputc>
    8000563c:	b501                	j	8000543c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000563e:	f7843783          	ld	a5,-136(s0)
    80005642:	e385                	bnez	a5,80005662 <printf+0x2b2>
    80005644:	74e6                	ld	s1,120(sp)
    80005646:	7946                	ld	s2,112(sp)
    80005648:	79a6                	ld	s3,104(sp)
    8000564a:	6ae6                	ld	s5,88(sp)
    8000564c:	6b46                	ld	s6,80(sp)
    8000564e:	6c06                	ld	s8,64(sp)
    80005650:	7ce2                	ld	s9,56(sp)
    80005652:	7d42                	ld	s10,48(sp)
    80005654:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80005656:	4501                	li	a0,0
    80005658:	60aa                	ld	ra,136(sp)
    8000565a:	640a                	ld	s0,128(sp)
    8000565c:	7a06                	ld	s4,96(sp)
    8000565e:	6169                	addi	sp,sp,208
    80005660:	8082                	ret
    80005662:	74e6                	ld	s1,120(sp)
    80005664:	7946                	ld	s2,112(sp)
    80005666:	79a6                	ld	s3,104(sp)
    80005668:	6ae6                	ld	s5,88(sp)
    8000566a:	6b46                	ld	s6,80(sp)
    8000566c:	6c06                	ld	s8,64(sp)
    8000566e:	7ce2                	ld	s9,56(sp)
    80005670:	7d42                	ld	s10,48(sp)
    80005672:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80005674:	0003e517          	auipc	a0,0x3e
    80005678:	fe450513          	addi	a0,a0,-28 # 80043658 <pr>
    8000567c:	3cc000ef          	jal	80005a48 <release>
    80005680:	bfd9                	j	80005656 <printf+0x2a6>

0000000080005682 <panic>:

void
panic(char *s)
{
    80005682:	1101                	addi	sp,sp,-32
    80005684:	ec06                	sd	ra,24(sp)
    80005686:	e822                	sd	s0,16(sp)
    80005688:	e426                	sd	s1,8(sp)
    8000568a:	1000                	addi	s0,sp,32
    8000568c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000568e:	0003e797          	auipc	a5,0x3e
    80005692:	fe07a123          	sw	zero,-30(a5) # 80043670 <pr+0x18>
  printf("panic: ");
    80005696:	00002517          	auipc	a0,0x2
    8000569a:	12a50513          	addi	a0,a0,298 # 800077c0 <etext+0x7c0>
    8000569e:	d13ff0ef          	jal	800053b0 <printf>
  printf("%s\n", s);
    800056a2:	85a6                	mv	a1,s1
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	12450513          	addi	a0,a0,292 # 800077c8 <etext+0x7c8>
    800056ac:	d05ff0ef          	jal	800053b0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800056b0:	4785                	li	a5,1
    800056b2:	00005717          	auipc	a4,0x5
    800056b6:	caf72d23          	sw	a5,-838(a4) # 8000a36c <panicked>
  for(;;)
    800056ba:	a001                	j	800056ba <panic+0x38>

00000000800056bc <printfinit>:
    ;
}

void
printfinit(void)
{
    800056bc:	1101                	addi	sp,sp,-32
    800056be:	ec06                	sd	ra,24(sp)
    800056c0:	e822                	sd	s0,16(sp)
    800056c2:	e426                	sd	s1,8(sp)
    800056c4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800056c6:	0003e497          	auipc	s1,0x3e
    800056ca:	f9248493          	addi	s1,s1,-110 # 80043658 <pr>
    800056ce:	00002597          	auipc	a1,0x2
    800056d2:	10258593          	addi	a1,a1,258 # 800077d0 <etext+0x7d0>
    800056d6:	8526                	mv	a0,s1
    800056d8:	258000ef          	jal	80005930 <initlock>
  pr.locking = 1;
    800056dc:	4785                	li	a5,1
    800056de:	cc9c                	sw	a5,24(s1)
}
    800056e0:	60e2                	ld	ra,24(sp)
    800056e2:	6442                	ld	s0,16(sp)
    800056e4:	64a2                	ld	s1,8(sp)
    800056e6:	6105                	addi	sp,sp,32
    800056e8:	8082                	ret

00000000800056ea <uartinit>:

void uartstart();

void
uartinit(void)
{
    800056ea:	1141                	addi	sp,sp,-16
    800056ec:	e406                	sd	ra,8(sp)
    800056ee:	e022                	sd	s0,0(sp)
    800056f0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800056f2:	100007b7          	lui	a5,0x10000
    800056f6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800056fa:	10000737          	lui	a4,0x10000
    800056fe:	f8000693          	li	a3,-128
    80005702:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005706:	468d                	li	a3,3
    80005708:	10000637          	lui	a2,0x10000
    8000570c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005710:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005714:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005718:	10000737          	lui	a4,0x10000
    8000571c:	461d                	li	a2,7
    8000571e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005722:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005726:	00002597          	auipc	a1,0x2
    8000572a:	0b258593          	addi	a1,a1,178 # 800077d8 <etext+0x7d8>
    8000572e:	0003e517          	auipc	a0,0x3e
    80005732:	f4a50513          	addi	a0,a0,-182 # 80043678 <uart_tx_lock>
    80005736:	1fa000ef          	jal	80005930 <initlock>
}
    8000573a:	60a2                	ld	ra,8(sp)
    8000573c:	6402                	ld	s0,0(sp)
    8000573e:	0141                	addi	sp,sp,16
    80005740:	8082                	ret

0000000080005742 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005742:	1101                	addi	sp,sp,-32
    80005744:	ec06                	sd	ra,24(sp)
    80005746:	e822                	sd	s0,16(sp)
    80005748:	e426                	sd	s1,8(sp)
    8000574a:	1000                	addi	s0,sp,32
    8000574c:	84aa                	mv	s1,a0
  push_off();
    8000574e:	222000ef          	jal	80005970 <push_off>

  if(panicked){
    80005752:	00005797          	auipc	a5,0x5
    80005756:	c1a7a783          	lw	a5,-998(a5) # 8000a36c <panicked>
    8000575a:	e795                	bnez	a5,80005786 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000575c:	10000737          	lui	a4,0x10000
    80005760:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005762:	00074783          	lbu	a5,0(a4)
    80005766:	0207f793          	andi	a5,a5,32
    8000576a:	dfe5                	beqz	a5,80005762 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000576c:	0ff4f513          	zext.b	a0,s1
    80005770:	100007b7          	lui	a5,0x10000
    80005774:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005778:	27c000ef          	jal	800059f4 <pop_off>
}
    8000577c:	60e2                	ld	ra,24(sp)
    8000577e:	6442                	ld	s0,16(sp)
    80005780:	64a2                	ld	s1,8(sp)
    80005782:	6105                	addi	sp,sp,32
    80005784:	8082                	ret
    for(;;)
    80005786:	a001                	j	80005786 <uartputc_sync+0x44>

0000000080005788 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005788:	00005797          	auipc	a5,0x5
    8000578c:	be87b783          	ld	a5,-1048(a5) # 8000a370 <uart_tx_r>
    80005790:	00005717          	auipc	a4,0x5
    80005794:	be873703          	ld	a4,-1048(a4) # 8000a378 <uart_tx_w>
    80005798:	08f70263          	beq	a4,a5,8000581c <uartstart+0x94>
{
    8000579c:	7139                	addi	sp,sp,-64
    8000579e:	fc06                	sd	ra,56(sp)
    800057a0:	f822                	sd	s0,48(sp)
    800057a2:	f426                	sd	s1,40(sp)
    800057a4:	f04a                	sd	s2,32(sp)
    800057a6:	ec4e                	sd	s3,24(sp)
    800057a8:	e852                	sd	s4,16(sp)
    800057aa:	e456                	sd	s5,8(sp)
    800057ac:	e05a                	sd	s6,0(sp)
    800057ae:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800057b0:	10000937          	lui	s2,0x10000
    800057b4:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800057b6:	0003ea97          	auipc	s5,0x3e
    800057ba:	ec2a8a93          	addi	s5,s5,-318 # 80043678 <uart_tx_lock>
    uart_tx_r += 1;
    800057be:	00005497          	auipc	s1,0x5
    800057c2:	bb248493          	addi	s1,s1,-1102 # 8000a370 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800057c6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800057ca:	00005997          	auipc	s3,0x5
    800057ce:	bae98993          	addi	s3,s3,-1106 # 8000a378 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800057d2:	00094703          	lbu	a4,0(s2)
    800057d6:	02077713          	andi	a4,a4,32
    800057da:	c71d                	beqz	a4,80005808 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800057dc:	01f7f713          	andi	a4,a5,31
    800057e0:	9756                	add	a4,a4,s5
    800057e2:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800057e6:	0785                	addi	a5,a5,1
    800057e8:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800057ea:	8526                	mv	a0,s1
    800057ec:	d4ffb0ef          	jal	8000153a <wakeup>
    WriteReg(THR, c);
    800057f0:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800057f4:	609c                	ld	a5,0(s1)
    800057f6:	0009b703          	ld	a4,0(s3)
    800057fa:	fcf71ce3          	bne	a4,a5,800057d2 <uartstart+0x4a>
      ReadReg(ISR);
    800057fe:	100007b7          	lui	a5,0x10000
    80005802:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005804:	0007c783          	lbu	a5,0(a5)
  }
}
    80005808:	70e2                	ld	ra,56(sp)
    8000580a:	7442                	ld	s0,48(sp)
    8000580c:	74a2                	ld	s1,40(sp)
    8000580e:	7902                	ld	s2,32(sp)
    80005810:	69e2                	ld	s3,24(sp)
    80005812:	6a42                	ld	s4,16(sp)
    80005814:	6aa2                	ld	s5,8(sp)
    80005816:	6b02                	ld	s6,0(sp)
    80005818:	6121                	addi	sp,sp,64
    8000581a:	8082                	ret
      ReadReg(ISR);
    8000581c:	100007b7          	lui	a5,0x10000
    80005820:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005822:	0007c783          	lbu	a5,0(a5)
      return;
    80005826:	8082                	ret

0000000080005828 <uartputc>:
{
    80005828:	7179                	addi	sp,sp,-48
    8000582a:	f406                	sd	ra,40(sp)
    8000582c:	f022                	sd	s0,32(sp)
    8000582e:	ec26                	sd	s1,24(sp)
    80005830:	e84a                	sd	s2,16(sp)
    80005832:	e44e                	sd	s3,8(sp)
    80005834:	e052                	sd	s4,0(sp)
    80005836:	1800                	addi	s0,sp,48
    80005838:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000583a:	0003e517          	auipc	a0,0x3e
    8000583e:	e3e50513          	addi	a0,a0,-450 # 80043678 <uart_tx_lock>
    80005842:	16e000ef          	jal	800059b0 <acquire>
  if(panicked){
    80005846:	00005797          	auipc	a5,0x5
    8000584a:	b267a783          	lw	a5,-1242(a5) # 8000a36c <panicked>
    8000584e:	efbd                	bnez	a5,800058cc <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005850:	00005717          	auipc	a4,0x5
    80005854:	b2873703          	ld	a4,-1240(a4) # 8000a378 <uart_tx_w>
    80005858:	00005797          	auipc	a5,0x5
    8000585c:	b187b783          	ld	a5,-1256(a5) # 8000a370 <uart_tx_r>
    80005860:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005864:	0003e997          	auipc	s3,0x3e
    80005868:	e1498993          	addi	s3,s3,-492 # 80043678 <uart_tx_lock>
    8000586c:	00005497          	auipc	s1,0x5
    80005870:	b0448493          	addi	s1,s1,-1276 # 8000a370 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005874:	00005917          	auipc	s2,0x5
    80005878:	b0490913          	addi	s2,s2,-1276 # 8000a378 <uart_tx_w>
    8000587c:	00e79d63          	bne	a5,a4,80005896 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005880:	85ce                	mv	a1,s3
    80005882:	8526                	mv	a0,s1
    80005884:	c6bfb0ef          	jal	800014ee <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005888:	00093703          	ld	a4,0(s2)
    8000588c:	609c                	ld	a5,0(s1)
    8000588e:	02078793          	addi	a5,a5,32
    80005892:	fee787e3          	beq	a5,a4,80005880 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80005896:	0003e497          	auipc	s1,0x3e
    8000589a:	de248493          	addi	s1,s1,-542 # 80043678 <uart_tx_lock>
    8000589e:	01f77793          	andi	a5,a4,31
    800058a2:	97a6                	add	a5,a5,s1
    800058a4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800058a8:	0705                	addi	a4,a4,1
    800058aa:	00005797          	auipc	a5,0x5
    800058ae:	ace7b723          	sd	a4,-1330(a5) # 8000a378 <uart_tx_w>
  uartstart();
    800058b2:	ed7ff0ef          	jal	80005788 <uartstart>
  release(&uart_tx_lock);
    800058b6:	8526                	mv	a0,s1
    800058b8:	190000ef          	jal	80005a48 <release>
}
    800058bc:	70a2                	ld	ra,40(sp)
    800058be:	7402                	ld	s0,32(sp)
    800058c0:	64e2                	ld	s1,24(sp)
    800058c2:	6942                	ld	s2,16(sp)
    800058c4:	69a2                	ld	s3,8(sp)
    800058c6:	6a02                	ld	s4,0(sp)
    800058c8:	6145                	addi	sp,sp,48
    800058ca:	8082                	ret
    for(;;)
    800058cc:	a001                	j	800058cc <uartputc+0xa4>

00000000800058ce <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800058ce:	1141                	addi	sp,sp,-16
    800058d0:	e422                	sd	s0,8(sp)
    800058d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800058d4:	100007b7          	lui	a5,0x10000
    800058d8:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800058da:	0007c783          	lbu	a5,0(a5)
    800058de:	8b85                	andi	a5,a5,1
    800058e0:	cb81                	beqz	a5,800058f0 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800058e2:	100007b7          	lui	a5,0x10000
    800058e6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800058ea:	6422                	ld	s0,8(sp)
    800058ec:	0141                	addi	sp,sp,16
    800058ee:	8082                	ret
    return -1;
    800058f0:	557d                	li	a0,-1
    800058f2:	bfe5                	j	800058ea <uartgetc+0x1c>

00000000800058f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800058f4:	1101                	addi	sp,sp,-32
    800058f6:	ec06                	sd	ra,24(sp)
    800058f8:	e822                	sd	s0,16(sp)
    800058fa:	e426                	sd	s1,8(sp)
    800058fc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800058fe:	54fd                	li	s1,-1
    80005900:	a019                	j	80005906 <uartintr+0x12>
      break;
    consoleintr(c);
    80005902:	85fff0ef          	jal	80005160 <consoleintr>
    int c = uartgetc();
    80005906:	fc9ff0ef          	jal	800058ce <uartgetc>
    if(c == -1)
    8000590a:	fe951ce3          	bne	a0,s1,80005902 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000590e:	0003e497          	auipc	s1,0x3e
    80005912:	d6a48493          	addi	s1,s1,-662 # 80043678 <uart_tx_lock>
    80005916:	8526                	mv	a0,s1
    80005918:	098000ef          	jal	800059b0 <acquire>
  uartstart();
    8000591c:	e6dff0ef          	jal	80005788 <uartstart>
  release(&uart_tx_lock);
    80005920:	8526                	mv	a0,s1
    80005922:	126000ef          	jal	80005a48 <release>
}
    80005926:	60e2                	ld	ra,24(sp)
    80005928:	6442                	ld	s0,16(sp)
    8000592a:	64a2                	ld	s1,8(sp)
    8000592c:	6105                	addi	sp,sp,32
    8000592e:	8082                	ret

0000000080005930 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005930:	1141                	addi	sp,sp,-16
    80005932:	e422                	sd	s0,8(sp)
    80005934:	0800                	addi	s0,sp,16
  lk->name = name;
    80005936:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005938:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000593c:	00053823          	sd	zero,16(a0)
}
    80005940:	6422                	ld	s0,8(sp)
    80005942:	0141                	addi	sp,sp,16
    80005944:	8082                	ret

0000000080005946 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005946:	411c                	lw	a5,0(a0)
    80005948:	e399                	bnez	a5,8000594e <holding+0x8>
    8000594a:	4501                	li	a0,0
  return r;
}
    8000594c:	8082                	ret
{
    8000594e:	1101                	addi	sp,sp,-32
    80005950:	ec06                	sd	ra,24(sp)
    80005952:	e822                	sd	s0,16(sp)
    80005954:	e426                	sd	s1,8(sp)
    80005956:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005958:	6904                	ld	s1,16(a0)
    8000595a:	daafb0ef          	jal	80000f04 <mycpu>
    8000595e:	40a48533          	sub	a0,s1,a0
    80005962:	00153513          	seqz	a0,a0
}
    80005966:	60e2                	ld	ra,24(sp)
    80005968:	6442                	ld	s0,16(sp)
    8000596a:	64a2                	ld	s1,8(sp)
    8000596c:	6105                	addi	sp,sp,32
    8000596e:	8082                	ret

0000000080005970 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005970:	1101                	addi	sp,sp,-32
    80005972:	ec06                	sd	ra,24(sp)
    80005974:	e822                	sd	s0,16(sp)
    80005976:	e426                	sd	s1,8(sp)
    80005978:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000597a:	100024f3          	csrr	s1,sstatus
    8000597e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005982:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005984:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005988:	d7cfb0ef          	jal	80000f04 <mycpu>
    8000598c:	5d3c                	lw	a5,120(a0)
    8000598e:	cb99                	beqz	a5,800059a4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005990:	d74fb0ef          	jal	80000f04 <mycpu>
    80005994:	5d3c                	lw	a5,120(a0)
    80005996:	2785                	addiw	a5,a5,1
    80005998:	dd3c                	sw	a5,120(a0)
}
    8000599a:	60e2                	ld	ra,24(sp)
    8000599c:	6442                	ld	s0,16(sp)
    8000599e:	64a2                	ld	s1,8(sp)
    800059a0:	6105                	addi	sp,sp,32
    800059a2:	8082                	ret
    mycpu()->intena = old;
    800059a4:	d60fb0ef          	jal	80000f04 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800059a8:	8085                	srli	s1,s1,0x1
    800059aa:	8885                	andi	s1,s1,1
    800059ac:	dd64                	sw	s1,124(a0)
    800059ae:	b7cd                	j	80005990 <push_off+0x20>

00000000800059b0 <acquire>:
{
    800059b0:	1101                	addi	sp,sp,-32
    800059b2:	ec06                	sd	ra,24(sp)
    800059b4:	e822                	sd	s0,16(sp)
    800059b6:	e426                	sd	s1,8(sp)
    800059b8:	1000                	addi	s0,sp,32
    800059ba:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800059bc:	fb5ff0ef          	jal	80005970 <push_off>
  if(holding(lk))
    800059c0:	8526                	mv	a0,s1
    800059c2:	f85ff0ef          	jal	80005946 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059c6:	4705                	li	a4,1
  if(holding(lk))
    800059c8:	e105                	bnez	a0,800059e8 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059ca:	87ba                	mv	a5,a4
    800059cc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800059d0:	2781                	sext.w	a5,a5
    800059d2:	ffe5                	bnez	a5,800059ca <acquire+0x1a>
  __sync_synchronize();
    800059d4:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800059d8:	d2cfb0ef          	jal	80000f04 <mycpu>
    800059dc:	e888                	sd	a0,16(s1)
}
    800059de:	60e2                	ld	ra,24(sp)
    800059e0:	6442                	ld	s0,16(sp)
    800059e2:	64a2                	ld	s1,8(sp)
    800059e4:	6105                	addi	sp,sp,32
    800059e6:	8082                	ret
    panic("acquire");
    800059e8:	00002517          	auipc	a0,0x2
    800059ec:	df850513          	addi	a0,a0,-520 # 800077e0 <etext+0x7e0>
    800059f0:	c93ff0ef          	jal	80005682 <panic>

00000000800059f4 <pop_off>:

void
pop_off(void)
{
    800059f4:	1141                	addi	sp,sp,-16
    800059f6:	e406                	sd	ra,8(sp)
    800059f8:	e022                	sd	s0,0(sp)
    800059fa:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800059fc:	d08fb0ef          	jal	80000f04 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005a04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005a06:	e78d                	bnez	a5,80005a30 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005a08:	5d3c                	lw	a5,120(a0)
    80005a0a:	02f05963          	blez	a5,80005a3c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005a0e:	37fd                	addiw	a5,a5,-1
    80005a10:	0007871b          	sext.w	a4,a5
    80005a14:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005a16:	eb09                	bnez	a4,80005a28 <pop_off+0x34>
    80005a18:	5d7c                	lw	a5,124(a0)
    80005a1a:	c799                	beqz	a5,80005a28 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005a20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005a24:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005a28:	60a2                	ld	ra,8(sp)
    80005a2a:	6402                	ld	s0,0(sp)
    80005a2c:	0141                	addi	sp,sp,16
    80005a2e:	8082                	ret
    panic("pop_off - interruptible");
    80005a30:	00002517          	auipc	a0,0x2
    80005a34:	db850513          	addi	a0,a0,-584 # 800077e8 <etext+0x7e8>
    80005a38:	c4bff0ef          	jal	80005682 <panic>
    panic("pop_off");
    80005a3c:	00002517          	auipc	a0,0x2
    80005a40:	dc450513          	addi	a0,a0,-572 # 80007800 <etext+0x800>
    80005a44:	c3fff0ef          	jal	80005682 <panic>

0000000080005a48 <release>:
{
    80005a48:	1101                	addi	sp,sp,-32
    80005a4a:	ec06                	sd	ra,24(sp)
    80005a4c:	e822                	sd	s0,16(sp)
    80005a4e:	e426                	sd	s1,8(sp)
    80005a50:	1000                	addi	s0,sp,32
    80005a52:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005a54:	ef3ff0ef          	jal	80005946 <holding>
    80005a58:	c105                	beqz	a0,80005a78 <release+0x30>
  lk->cpu = 0;
    80005a5a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005a5e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005a62:	0310000f          	fence	rw,w
    80005a66:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005a6a:	f8bff0ef          	jal	800059f4 <pop_off>
}
    80005a6e:	60e2                	ld	ra,24(sp)
    80005a70:	6442                	ld	s0,16(sp)
    80005a72:	64a2                	ld	s1,8(sp)
    80005a74:	6105                	addi	sp,sp,32
    80005a76:	8082                	ret
    panic("release");
    80005a78:	00002517          	auipc	a0,0x2
    80005a7c:	d9050513          	addi	a0,a0,-624 # 80007808 <etext+0x808>
    80005a80:	c03ff0ef          	jal	80005682 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
