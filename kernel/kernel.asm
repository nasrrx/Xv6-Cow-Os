
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	34013103          	ld	sp,832(sp) # 8000a340 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000038:	35c90913          	addi	s2,s2,860 # 8000a390 <kmem>
    8000003c:	854a                	mv	a0,s2
    8000003e:	173050ef          	jal	800059b0 <acquire>
  krefcnt[idx]++;
    80000042:	048a                	slli	s1,s1,0x2
    80000044:	0000a797          	auipc	a5,0xa
    80000048:	36c78793          	addi	a5,a5,876 # 8000a3b0 <krefcnt>
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
    80000082:	31290913          	addi	s2,s2,786 # 8000a390 <kmem>
    80000086:	854a                	mv	a0,s2
    80000088:	129050ef          	jal	800059b0 <acquire>
  krefcnt[idx]--;
    8000008c:	048a                	slli	s1,s1,0x2
    8000008e:	0000a797          	auipc	a5,0xa
    80000092:	32278793          	addi	a5,a5,802 # 8000a3b0 <krefcnt>
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
    800000c8:	5fc78793          	addi	a5,a5,1532 # 800436c0 <end>
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
    800000e6:	2ae50513          	addi	a0,a0,686 # 8000a390 <kmem>
    800000ea:	0c7050ef          	jal	800059b0 <acquire>
  if(--krefcnt[idx] > 0){
    800000ee:	048a                	slli	s1,s1,0x2
    800000f0:	0000a797          	auipc	a5,0xa
    800000f4:	2c078793          	addi	a5,a5,704 # 8000a3b0 <krefcnt>
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
    8000010c:	28848493          	addi	s1,s1,648 # 8000a390 <kmem>
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
    80000152:	24250513          	addi	a0,a0,578 # 8000a390 <kmem>
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
    800001b8:	1dc50513          	addi	a0,a0,476 # 8000a390 <kmem>
    800001bc:	774050ef          	jal	80005930 <initlock>
  freerange(end, (void*)PHYSTOP);
    800001c0:	45c5                	li	a1,17
    800001c2:	05ee                	slli	a1,a1,0x1b
    800001c4:	00043517          	auipc	a0,0x43
    800001c8:	4fc50513          	addi	a0,a0,1276 # 800436c0 <end>
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
    800001e6:	1ae48493          	addi	s1,s1,430 # 8000a390 <kmem>
    800001ea:	8526                	mv	a0,s1
    800001ec:	7c4050ef          	jal	800059b0 <acquire>
  r = kmem.freelist;
    800001f0:	6c84                	ld	s1,24(s1)
  if(r)
    800001f2:	c0a9                	beqz	s1,80000234 <kalloc+0x5c>
    kmem.freelist = r->next;
    800001f4:	609c                	ld	a5,0(s1)
    800001f6:	0000a517          	auipc	a0,0xa
    800001fa:	19a50513          	addi	a0,a0,410 # 8000a390 <kmem>
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
    8000021e:	19670713          	addi	a4,a4,406 # 8000a3b0 <krefcnt>
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
    80000238:	15c50513          	addi	a0,a0,348 # 8000a390 <kmem>
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
    80000254:	00b78023          	sb	a1,0(a5) # ffffffff80000000 <end+0xfffffffefffbc940>
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
    800003e4:	30d000ef          	jal	80000ef0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800003e8:	0000a717          	auipc	a4,0xa
    800003ec:	f7870713          	addi	a4,a4,-136 # 8000a360 <started>
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
    800003fc:	2f5000ef          	jal	80000ef0 <cpuid>
    80000400:	85aa                	mv	a1,a0
    80000402:	00007517          	auipc	a0,0x7
    80000406:	c3650513          	addi	a0,a0,-970 # 80007038 <etext+0x38>
    8000040a:	7a7040ef          	jal	800053b0 <printf>
    kvminithart();    // turn on paging
    8000040e:	080000ef          	jal	8000048e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000412:	5fa010ef          	jal	80001a0c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000416:	552040ef          	jal	80004968 <plicinithart>
  }

  scheduler();        
    8000041a:	737000ef          	jal	80001350 <scheduler>
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
    8000044e:	2c6000ef          	jal	80000714 <kvminit>
    kvminithart();   // turn on paging
    80000452:	03c000ef          	jal	8000048e <kvminithart>
    procinit();      // process table
    80000456:	1e5000ef          	jal	80000e3a <procinit>
    trapinit();      // trap vectors
    8000045a:	58e010ef          	jal	800019e8 <trapinit>
    trapinithart();  // install kernel trap vector
    8000045e:	5ae010ef          	jal	80001a0c <trapinithart>
    plicinit();      // set up interrupt controller
    80000462:	4ec040ef          	jal	8000494e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000466:	502040ef          	jal	80004968 <plicinithart>
    binit();         // buffer cache
    8000046a:	4a9010ef          	jal	80002112 <binit>
    iinit();         // inode table
    8000046e:	29a020ef          	jal	80002708 <iinit>
    fileinit();      // file table
    80000472:	046030ef          	jal	800034b8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000476:	5e2040ef          	jal	80004a58 <virtio_disk_init>
    userinit();      // first user process
    8000047a:	50b000ef          	jal	80001184 <userinit>
    __sync_synchronize();
    8000047e:	0330000f          	fence	rw,rw
    started = 1;
    80000482:	4785                	li	a5,1
    80000484:	0000a717          	auipc	a4,0xa
    80000488:	ecf72e23          	sw	a5,-292(a4) # 8000a360 <started>
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
    8000049c:	ed07b783          	ld	a5,-304(a5) # 8000a368 <kernel_pagetable>
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
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA){
    800004b6:	57fd                	li	a5,-1
    800004b8:	83e9                	srli	a5,a5,0x1a
    800004ba:	08b7e563          	bltu	a5,a1,80000544 <walk+0x8e>
{
    800004be:	7139                	addi	sp,sp,-64
    800004c0:	fc06                	sd	ra,56(sp)
    800004c2:	f822                	sd	s0,48(sp)
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	f04a                	sd	s2,32(sp)
    800004c8:	ec4e                	sd	s3,24(sp)
    800004ca:	e852                	sd	s4,16(sp)
    800004cc:	e456                	sd	s5,8(sp)
    800004ce:	e05a                	sd	s6,0(sp)
    800004d0:	0080                	addi	s0,sp,64
    800004d2:	84aa                	mv	s1,a0
    800004d4:	89ae                	mv	s3,a1
    800004d6:	8ab2                	mv	s5,a2
    800004d8:	4a79                	li	s4,30
    // panic("walk");
    return 0;}

  for(int level = 2; level > 0; level--) {
    800004da:	4b31                	li	s6,12
    800004dc:	a02d                	j	80000506 <walk+0x50>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004de:	060a8563          	beqz	s5,80000548 <walk+0x92>
    800004e2:	cf7ff0ef          	jal	800001d8 <kalloc>
    800004e6:	84aa                	mv	s1,a0
    800004e8:	c521                	beqz	a0,80000530 <walk+0x7a>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004ea:	6605                	lui	a2,0x1
    800004ec:	4581                	li	a1,0
    800004ee:	d55ff0ef          	jal	80000242 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004f2:	00c4d793          	srli	a5,s1,0xc
    800004f6:	07aa                	slli	a5,a5,0xa
    800004f8:	0017e793          	ori	a5,a5,1
    800004fc:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000500:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbb937>
    80000502:	036a0063          	beq	s4,s6,80000522 <walk+0x6c>
    pte_t *pte = &pagetable[PX(level, va)];
    80000506:	0149d933          	srl	s2,s3,s4
    8000050a:	1ff97913          	andi	s2,s2,511
    8000050e:	090e                	slli	s2,s2,0x3
    80000510:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000512:	00093483          	ld	s1,0(s2)
    80000516:	0014f793          	andi	a5,s1,1
    8000051a:	d3f1                	beqz	a5,800004de <walk+0x28>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000051c:	80a9                	srli	s1,s1,0xa
    8000051e:	04b2                	slli	s1,s1,0xc
    80000520:	b7c5                	j	80000500 <walk+0x4a>
    }
  }
  return &pagetable[PX(0, va)];
    80000522:	00c9d993          	srli	s3,s3,0xc
    80000526:	1ff9f993          	andi	s3,s3,511
    8000052a:	098e                	slli	s3,s3,0x3
    8000052c:	01348533          	add	a0,s1,s3
}
    80000530:	70e2                	ld	ra,56(sp)
    80000532:	7442                	ld	s0,48(sp)
    80000534:	74a2                	ld	s1,40(sp)
    80000536:	7902                	ld	s2,32(sp)
    80000538:	69e2                	ld	s3,24(sp)
    8000053a:	6a42                	ld	s4,16(sp)
    8000053c:	6aa2                	ld	s5,8(sp)
    8000053e:	6b02                	ld	s6,0(sp)
    80000540:	6121                	addi	sp,sp,64
    80000542:	8082                	ret
    return 0;}
    80000544:	4501                	li	a0,0
}
    80000546:	8082                	ret
        return 0;
    80000548:	4501                	li	a0,0
    8000054a:	b7dd                	j	80000530 <walk+0x7a>

000000008000054c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000054c:	57fd                	li	a5,-1
    8000054e:	83e9                	srli	a5,a5,0x1a
    80000550:	00b7f463          	bgeu	a5,a1,80000558 <walkaddr+0xc>
    return 0;
    80000554:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000556:	8082                	ret
{
    80000558:	1141                	addi	sp,sp,-16
    8000055a:	e406                	sd	ra,8(sp)
    8000055c:	e022                	sd	s0,0(sp)
    8000055e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000560:	4601                	li	a2,0
    80000562:	f55ff0ef          	jal	800004b6 <walk>
  if(pte == 0)
    80000566:	c105                	beqz	a0,80000586 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000568:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000056a:	0117f693          	andi	a3,a5,17
    8000056e:	4745                	li	a4,17
    return 0;
    80000570:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000572:	00e68663          	beq	a3,a4,8000057e <walkaddr+0x32>
}
    80000576:	60a2                	ld	ra,8(sp)
    80000578:	6402                	ld	s0,0(sp)
    8000057a:	0141                	addi	sp,sp,16
    8000057c:	8082                	ret
  pa = PTE2PA(*pte);
    8000057e:	83a9                	srli	a5,a5,0xa
    80000580:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000584:	bfcd                	j	80000576 <walkaddr+0x2a>
    return 0;
    80000586:	4501                	li	a0,0
    80000588:	b7fd                	j	80000576 <walkaddr+0x2a>

000000008000058a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000058a:	715d                	addi	sp,sp,-80
    8000058c:	e486                	sd	ra,72(sp)
    8000058e:	e0a2                	sd	s0,64(sp)
    80000590:	fc26                	sd	s1,56(sp)
    80000592:	f84a                	sd	s2,48(sp)
    80000594:	f44e                	sd	s3,40(sp)
    80000596:	f052                	sd	s4,32(sp)
    80000598:	ec56                	sd	s5,24(sp)
    8000059a:	e85a                	sd	s6,16(sp)
    8000059c:	e45e                	sd	s7,8(sp)
    8000059e:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800005a0:	03459793          	slli	a5,a1,0x34
    800005a4:	e7a9                	bnez	a5,800005ee <mappages+0x64>
    800005a6:	8aaa                	mv	s5,a0
    800005a8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800005aa:	03461793          	slli	a5,a2,0x34
    800005ae:	e7b1                	bnez	a5,800005fa <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800005b0:	ca39                	beqz	a2,80000606 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800005b2:	77fd                	lui	a5,0xfffff
    800005b4:	963e                	add	a2,a2,a5
    800005b6:	00b609b3          	add	s3,a2,a1
  a = va;
    800005ba:	892e                	mv	s2,a1
    800005bc:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800005c0:	6b85                	lui	s7,0x1
    800005c2:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800005c6:	4605                	li	a2,1
    800005c8:	85ca                	mv	a1,s2
    800005ca:	8556                	mv	a0,s5
    800005cc:	eebff0ef          	jal	800004b6 <walk>
    800005d0:	c539                	beqz	a0,8000061e <mappages+0x94>
    if(*pte & PTE_V)
    800005d2:	611c                	ld	a5,0(a0)
    800005d4:	8b85                	andi	a5,a5,1
    800005d6:	ef95                	bnez	a5,80000612 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005d8:	80b1                	srli	s1,s1,0xc
    800005da:	04aa                	slli	s1,s1,0xa
    800005dc:	0164e4b3          	or	s1,s1,s6
    800005e0:	0014e493          	ori	s1,s1,1
    800005e4:	e104                	sd	s1,0(a0)
    if(a == last)
    800005e6:	05390863          	beq	s2,s3,80000636 <mappages+0xac>
    a += PGSIZE;
    800005ea:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800005ec:	bfd9                	j	800005c2 <mappages+0x38>
    panic("mappages: va not aligned");
    800005ee:	00007517          	auipc	a0,0x7
    800005f2:	a6250513          	addi	a0,a0,-1438 # 80007050 <etext+0x50>
    800005f6:	08c050ef          	jal	80005682 <panic>
    panic("mappages: size not aligned");
    800005fa:	00007517          	auipc	a0,0x7
    800005fe:	a7650513          	addi	a0,a0,-1418 # 80007070 <etext+0x70>
    80000602:	080050ef          	jal	80005682 <panic>
    panic("mappages: size");
    80000606:	00007517          	auipc	a0,0x7
    8000060a:	a8a50513          	addi	a0,a0,-1398 # 80007090 <etext+0x90>
    8000060e:	074050ef          	jal	80005682 <panic>
      panic("mappages: remap");
    80000612:	00007517          	auipc	a0,0x7
    80000616:	a8e50513          	addi	a0,a0,-1394 # 800070a0 <etext+0xa0>
    8000061a:	068050ef          	jal	80005682 <panic>
      return -1;
    8000061e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000620:	60a6                	ld	ra,72(sp)
    80000622:	6406                	ld	s0,64(sp)
    80000624:	74e2                	ld	s1,56(sp)
    80000626:	7942                	ld	s2,48(sp)
    80000628:	79a2                	ld	s3,40(sp)
    8000062a:	7a02                	ld	s4,32(sp)
    8000062c:	6ae2                	ld	s5,24(sp)
    8000062e:	6b42                	ld	s6,16(sp)
    80000630:	6ba2                	ld	s7,8(sp)
    80000632:	6161                	addi	sp,sp,80
    80000634:	8082                	ret
  return 0;
    80000636:	4501                	li	a0,0
    80000638:	b7e5                	j	80000620 <mappages+0x96>

000000008000063a <kvmmap>:
{
    8000063a:	1141                	addi	sp,sp,-16
    8000063c:	e406                	sd	ra,8(sp)
    8000063e:	e022                	sd	s0,0(sp)
    80000640:	0800                	addi	s0,sp,16
    80000642:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000644:	86b2                	mv	a3,a2
    80000646:	863e                	mv	a2,a5
    80000648:	f43ff0ef          	jal	8000058a <mappages>
    8000064c:	e509                	bnez	a0,80000656 <kvmmap+0x1c>
}
    8000064e:	60a2                	ld	ra,8(sp)
    80000650:	6402                	ld	s0,0(sp)
    80000652:	0141                	addi	sp,sp,16
    80000654:	8082                	ret
    panic("kvmmap");
    80000656:	00007517          	auipc	a0,0x7
    8000065a:	a5a50513          	addi	a0,a0,-1446 # 800070b0 <etext+0xb0>
    8000065e:	024050ef          	jal	80005682 <panic>

0000000080000662 <kvmmake>:
{
    80000662:	1101                	addi	sp,sp,-32
    80000664:	ec06                	sd	ra,24(sp)
    80000666:	e822                	sd	s0,16(sp)
    80000668:	e426                	sd	s1,8(sp)
    8000066a:	e04a                	sd	s2,0(sp)
    8000066c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000066e:	b6bff0ef          	jal	800001d8 <kalloc>
    80000672:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000674:	6605                	lui	a2,0x1
    80000676:	4581                	li	a1,0
    80000678:	bcbff0ef          	jal	80000242 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000067c:	4719                	li	a4,6
    8000067e:	6685                	lui	a3,0x1
    80000680:	10000637          	lui	a2,0x10000
    80000684:	100005b7          	lui	a1,0x10000
    80000688:	8526                	mv	a0,s1
    8000068a:	fb1ff0ef          	jal	8000063a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000068e:	4719                	li	a4,6
    80000690:	6685                	lui	a3,0x1
    80000692:	10001637          	lui	a2,0x10001
    80000696:	100015b7          	lui	a1,0x10001
    8000069a:	8526                	mv	a0,s1
    8000069c:	f9fff0ef          	jal	8000063a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800006a0:	4719                	li	a4,6
    800006a2:	040006b7          	lui	a3,0x4000
    800006a6:	0c000637          	lui	a2,0xc000
    800006aa:	0c0005b7          	lui	a1,0xc000
    800006ae:	8526                	mv	a0,s1
    800006b0:	f8bff0ef          	jal	8000063a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006b4:	00007917          	auipc	s2,0x7
    800006b8:	94c90913          	addi	s2,s2,-1716 # 80007000 <etext>
    800006bc:	4729                	li	a4,10
    800006be:	80007697          	auipc	a3,0x80007
    800006c2:	94268693          	addi	a3,a3,-1726 # 7000 <_entry-0x7fff9000>
    800006c6:	4605                	li	a2,1
    800006c8:	067e                	slli	a2,a2,0x1f
    800006ca:	85b2                	mv	a1,a2
    800006cc:	8526                	mv	a0,s1
    800006ce:	f6dff0ef          	jal	8000063a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006d2:	46c5                	li	a3,17
    800006d4:	06ee                	slli	a3,a3,0x1b
    800006d6:	4719                	li	a4,6
    800006d8:	412686b3          	sub	a3,a3,s2
    800006dc:	864a                	mv	a2,s2
    800006de:	85ca                	mv	a1,s2
    800006e0:	8526                	mv	a0,s1
    800006e2:	f59ff0ef          	jal	8000063a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006e6:	4729                	li	a4,10
    800006e8:	6685                	lui	a3,0x1
    800006ea:	00006617          	auipc	a2,0x6
    800006ee:	91660613          	addi	a2,a2,-1770 # 80006000 <_trampoline>
    800006f2:	040005b7          	lui	a1,0x4000
    800006f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800006f8:	05b2                	slli	a1,a1,0xc
    800006fa:	8526                	mv	a0,s1
    800006fc:	f3fff0ef          	jal	8000063a <kvmmap>
  proc_mapstacks(kpgtbl);
    80000700:	8526                	mv	a0,s1
    80000702:	6a0000ef          	jal	80000da2 <proc_mapstacks>
}
    80000706:	8526                	mv	a0,s1
    80000708:	60e2                	ld	ra,24(sp)
    8000070a:	6442                	ld	s0,16(sp)
    8000070c:	64a2                	ld	s1,8(sp)
    8000070e:	6902                	ld	s2,0(sp)
    80000710:	6105                	addi	sp,sp,32
    80000712:	8082                	ret

0000000080000714 <kvminit>:
{
    80000714:	1141                	addi	sp,sp,-16
    80000716:	e406                	sd	ra,8(sp)
    80000718:	e022                	sd	s0,0(sp)
    8000071a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000071c:	f47ff0ef          	jal	80000662 <kvmmake>
    80000720:	0000a797          	auipc	a5,0xa
    80000724:	c4a7b423          	sd	a0,-952(a5) # 8000a368 <kernel_pagetable>
}
    80000728:	60a2                	ld	ra,8(sp)
    8000072a:	6402                	ld	s0,0(sp)
    8000072c:	0141                	addi	sp,sp,16
    8000072e:	8082                	ret

0000000080000730 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000730:	715d                	addi	sp,sp,-80
    80000732:	e486                	sd	ra,72(sp)
    80000734:	e0a2                	sd	s0,64(sp)
    80000736:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000738:	03459793          	slli	a5,a1,0x34
    8000073c:	e39d                	bnez	a5,80000762 <uvmunmap+0x32>
    8000073e:	f84a                	sd	s2,48(sp)
    80000740:	f44e                	sd	s3,40(sp)
    80000742:	f052                	sd	s4,32(sp)
    80000744:	ec56                	sd	s5,24(sp)
    80000746:	e85a                	sd	s6,16(sp)
    80000748:	e45e                	sd	s7,8(sp)
    8000074a:	8a2a                	mv	s4,a0
    8000074c:	892e                	mv	s2,a1
    8000074e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000750:	0632                	slli	a2,a2,0xc
    80000752:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000756:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000758:	6b05                	lui	s6,0x1
    8000075a:	0735ff63          	bgeu	a1,s3,800007d8 <uvmunmap+0xa8>
    8000075e:	fc26                	sd	s1,56(sp)
    80000760:	a0a9                	j	800007aa <uvmunmap+0x7a>
    80000762:	fc26                	sd	s1,56(sp)
    80000764:	f84a                	sd	s2,48(sp)
    80000766:	f44e                	sd	s3,40(sp)
    80000768:	f052                	sd	s4,32(sp)
    8000076a:	ec56                	sd	s5,24(sp)
    8000076c:	e85a                	sd	s6,16(sp)
    8000076e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80000770:	00007517          	auipc	a0,0x7
    80000774:	94850513          	addi	a0,a0,-1720 # 800070b8 <etext+0xb8>
    80000778:	70b040ef          	jal	80005682 <panic>
      panic("uvmunmap: walk");
    8000077c:	00007517          	auipc	a0,0x7
    80000780:	95450513          	addi	a0,a0,-1708 # 800070d0 <etext+0xd0>
    80000784:	6ff040ef          	jal	80005682 <panic>
      panic("uvmunmap: not mapped");
    80000788:	00007517          	auipc	a0,0x7
    8000078c:	95850513          	addi	a0,a0,-1704 # 800070e0 <etext+0xe0>
    80000790:	6f3040ef          	jal	80005682 <panic>
      panic("uvmunmap: not a leaf");
    80000794:	00007517          	auipc	a0,0x7
    80000798:	96450513          	addi	a0,a0,-1692 # 800070f8 <etext+0xf8>
    8000079c:	6e7040ef          	jal	80005682 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800007a0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007a4:	995a                	add	s2,s2,s6
    800007a6:	03397863          	bgeu	s2,s3,800007d6 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007aa:	4601                	li	a2,0
    800007ac:	85ca                	mv	a1,s2
    800007ae:	8552                	mv	a0,s4
    800007b0:	d07ff0ef          	jal	800004b6 <walk>
    800007b4:	84aa                	mv	s1,a0
    800007b6:	d179                	beqz	a0,8000077c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    800007b8:	6108                	ld	a0,0(a0)
    800007ba:	00157793          	andi	a5,a0,1
    800007be:	d7e9                	beqz	a5,80000788 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    800007c0:	3ff57793          	andi	a5,a0,1023
    800007c4:	fd7788e3          	beq	a5,s7,80000794 <uvmunmap+0x64>
    if(do_free){
    800007c8:	fc0a8ce3          	beqz	s5,800007a0 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    800007cc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800007ce:	0532                	slli	a0,a0,0xc
    800007d0:	8e1ff0ef          	jal	800000b0 <kfree>
    800007d4:	b7f1                	j	800007a0 <uvmunmap+0x70>
    800007d6:	74e2                	ld	s1,56(sp)
    800007d8:	7942                	ld	s2,48(sp)
    800007da:	79a2                	ld	s3,40(sp)
    800007dc:	7a02                	ld	s4,32(sp)
    800007de:	6ae2                	ld	s5,24(sp)
    800007e0:	6b42                	ld	s6,16(sp)
    800007e2:	6ba2                	ld	s7,8(sp)
  }
}
    800007e4:	60a6                	ld	ra,72(sp)
    800007e6:	6406                	ld	s0,64(sp)
    800007e8:	6161                	addi	sp,sp,80
    800007ea:	8082                	ret

00000000800007ec <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800007f6:	9e3ff0ef          	jal	800001d8 <kalloc>
    800007fa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800007fc:	c509                	beqz	a0,80000806 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800007fe:	6605                	lui	a2,0x1
    80000800:	4581                	li	a1,0
    80000802:	a41ff0ef          	jal	80000242 <memset>
  return pagetable;
}
    80000806:	8526                	mv	a0,s1
    80000808:	60e2                	ld	ra,24(sp)
    8000080a:	6442                	ld	s0,16(sp)
    8000080c:	64a2                	ld	s1,8(sp)
    8000080e:	6105                	addi	sp,sp,32
    80000810:	8082                	ret

0000000080000812 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000812:	7179                	addi	sp,sp,-48
    80000814:	f406                	sd	ra,40(sp)
    80000816:	f022                	sd	s0,32(sp)
    80000818:	ec26                	sd	s1,24(sp)
    8000081a:	e84a                	sd	s2,16(sp)
    8000081c:	e44e                	sd	s3,8(sp)
    8000081e:	e052                	sd	s4,0(sp)
    80000820:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000822:	6785                	lui	a5,0x1
    80000824:	04f67063          	bgeu	a2,a5,80000864 <uvmfirst+0x52>
    80000828:	8a2a                	mv	s4,a0
    8000082a:	89ae                	mv	s3,a1
    8000082c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000082e:	9abff0ef          	jal	800001d8 <kalloc>
    80000832:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000834:	6605                	lui	a2,0x1
    80000836:	4581                	li	a1,0
    80000838:	a0bff0ef          	jal	80000242 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000083c:	4779                	li	a4,30
    8000083e:	86ca                	mv	a3,s2
    80000840:	6605                	lui	a2,0x1
    80000842:	4581                	li	a1,0
    80000844:	8552                	mv	a0,s4
    80000846:	d45ff0ef          	jal	8000058a <mappages>
  memmove(mem, src, sz);
    8000084a:	8626                	mv	a2,s1
    8000084c:	85ce                	mv	a1,s3
    8000084e:	854a                	mv	a0,s2
    80000850:	a4fff0ef          	jal	8000029e <memmove>
}
    80000854:	70a2                	ld	ra,40(sp)
    80000856:	7402                	ld	s0,32(sp)
    80000858:	64e2                	ld	s1,24(sp)
    8000085a:	6942                	ld	s2,16(sp)
    8000085c:	69a2                	ld	s3,8(sp)
    8000085e:	6a02                	ld	s4,0(sp)
    80000860:	6145                	addi	sp,sp,48
    80000862:	8082                	ret
    panic("uvmfirst: more than a page");
    80000864:	00007517          	auipc	a0,0x7
    80000868:	8ac50513          	addi	a0,a0,-1876 # 80007110 <etext+0x110>
    8000086c:	617040ef          	jal	80005682 <panic>

0000000080000870 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000870:	1101                	addi	sp,sp,-32
    80000872:	ec06                	sd	ra,24(sp)
    80000874:	e822                	sd	s0,16(sp)
    80000876:	e426                	sd	s1,8(sp)
    80000878:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000087a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000087c:	00b67d63          	bgeu	a2,a1,80000896 <uvmdealloc+0x26>
    80000880:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000882:	6785                	lui	a5,0x1
    80000884:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000886:	00f60733          	add	a4,a2,a5
    8000088a:	76fd                	lui	a3,0xfffff
    8000088c:	8f75                	and	a4,a4,a3
    8000088e:	97ae                	add	a5,a5,a1
    80000890:	8ff5                	and	a5,a5,a3
    80000892:	00f76863          	bltu	a4,a5,800008a2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000896:	8526                	mv	a0,s1
    80000898:	60e2                	ld	ra,24(sp)
    8000089a:	6442                	ld	s0,16(sp)
    8000089c:	64a2                	ld	s1,8(sp)
    8000089e:	6105                	addi	sp,sp,32
    800008a0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008a2:	8f99                	sub	a5,a5,a4
    800008a4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008a6:	4685                	li	a3,1
    800008a8:	0007861b          	sext.w	a2,a5
    800008ac:	85ba                	mv	a1,a4
    800008ae:	e83ff0ef          	jal	80000730 <uvmunmap>
    800008b2:	b7d5                	j	80000896 <uvmdealloc+0x26>

00000000800008b4 <uvmalloc>:
  if(newsz < oldsz)
    800008b4:	08b66f63          	bltu	a2,a1,80000952 <uvmalloc+0x9e>
{
    800008b8:	7139                	addi	sp,sp,-64
    800008ba:	fc06                	sd	ra,56(sp)
    800008bc:	f822                	sd	s0,48(sp)
    800008be:	ec4e                	sd	s3,24(sp)
    800008c0:	e852                	sd	s4,16(sp)
    800008c2:	e456                	sd	s5,8(sp)
    800008c4:	0080                	addi	s0,sp,64
    800008c6:	8aaa                	mv	s5,a0
    800008c8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800008ca:	6785                	lui	a5,0x1
    800008cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008ce:	95be                	add	a1,a1,a5
    800008d0:	77fd                	lui	a5,0xfffff
    800008d2:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800008d6:	08c9f063          	bgeu	s3,a2,80000956 <uvmalloc+0xa2>
    800008da:	f426                	sd	s1,40(sp)
    800008dc:	f04a                	sd	s2,32(sp)
    800008de:	e05a                	sd	s6,0(sp)
    800008e0:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800008e2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800008e6:	8f3ff0ef          	jal	800001d8 <kalloc>
    800008ea:	84aa                	mv	s1,a0
    if(mem == 0){
    800008ec:	c515                	beqz	a0,80000918 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800008ee:	6605                	lui	a2,0x1
    800008f0:	4581                	li	a1,0
    800008f2:	951ff0ef          	jal	80000242 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800008f6:	875a                	mv	a4,s6
    800008f8:	86a6                	mv	a3,s1
    800008fa:	6605                	lui	a2,0x1
    800008fc:	85ca                	mv	a1,s2
    800008fe:	8556                	mv	a0,s5
    80000900:	c8bff0ef          	jal	8000058a <mappages>
    80000904:	e915                	bnez	a0,80000938 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000906:	6785                	lui	a5,0x1
    80000908:	993e                	add	s2,s2,a5
    8000090a:	fd496ee3          	bltu	s2,s4,800008e6 <uvmalloc+0x32>
  return newsz;
    8000090e:	8552                	mv	a0,s4
    80000910:	74a2                	ld	s1,40(sp)
    80000912:	7902                	ld	s2,32(sp)
    80000914:	6b02                	ld	s6,0(sp)
    80000916:	a811                	j	8000092a <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80000918:	864e                	mv	a2,s3
    8000091a:	85ca                	mv	a1,s2
    8000091c:	8556                	mv	a0,s5
    8000091e:	f53ff0ef          	jal	80000870 <uvmdealloc>
      return 0;
    80000922:	4501                	li	a0,0
    80000924:	74a2                	ld	s1,40(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6b02                	ld	s6,0(sp)
}
    8000092a:	70e2                	ld	ra,56(sp)
    8000092c:	7442                	ld	s0,48(sp)
    8000092e:	69e2                	ld	s3,24(sp)
    80000930:	6a42                	ld	s4,16(sp)
    80000932:	6aa2                	ld	s5,8(sp)
    80000934:	6121                	addi	sp,sp,64
    80000936:	8082                	ret
      kfree(mem);
    80000938:	8526                	mv	a0,s1
    8000093a:	f76ff0ef          	jal	800000b0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000093e:	864e                	mv	a2,s3
    80000940:	85ca                	mv	a1,s2
    80000942:	8556                	mv	a0,s5
    80000944:	f2dff0ef          	jal	80000870 <uvmdealloc>
      return 0;
    80000948:	4501                	li	a0,0
    8000094a:	74a2                	ld	s1,40(sp)
    8000094c:	7902                	ld	s2,32(sp)
    8000094e:	6b02                	ld	s6,0(sp)
    80000950:	bfe9                	j	8000092a <uvmalloc+0x76>
    return oldsz;
    80000952:	852e                	mv	a0,a1
}
    80000954:	8082                	ret
  return newsz;
    80000956:	8532                	mv	a0,a2
    80000958:	bfc9                	j	8000092a <uvmalloc+0x76>

000000008000095a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000095a:	7179                	addi	sp,sp,-48
    8000095c:	f406                	sd	ra,40(sp)
    8000095e:	f022                	sd	s0,32(sp)
    80000960:	ec26                	sd	s1,24(sp)
    80000962:	e84a                	sd	s2,16(sp)
    80000964:	e44e                	sd	s3,8(sp)
    80000966:	e052                	sd	s4,0(sp)
    80000968:	1800                	addi	s0,sp,48
    8000096a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000096c:	84aa                	mv	s1,a0
    8000096e:	6905                	lui	s2,0x1
    80000970:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000972:	4985                	li	s3,1
    80000974:	a819                	j	8000098a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000976:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000978:	00c79513          	slli	a0,a5,0xc
    8000097c:	fdfff0ef          	jal	8000095a <freewalk>
      pagetable[i] = 0;
    80000980:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000984:	04a1                	addi	s1,s1,8
    80000986:	01248f63          	beq	s1,s2,800009a4 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000098a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000098c:	00f7f713          	andi	a4,a5,15
    80000990:	ff3703e3          	beq	a4,s3,80000976 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000994:	8b85                	andi	a5,a5,1
    80000996:	d7fd                	beqz	a5,80000984 <freewalk+0x2a>
      panic("freewalk: leaf");
    80000998:	00006517          	auipc	a0,0x6
    8000099c:	79850513          	addi	a0,a0,1944 # 80007130 <etext+0x130>
    800009a0:	4e3040ef          	jal	80005682 <panic>
    }
  }
  kfree((void*)pagetable);
    800009a4:	8552                	mv	a0,s4
    800009a6:	f0aff0ef          	jal	800000b0 <kfree>
}
    800009aa:	70a2                	ld	ra,40(sp)
    800009ac:	7402                	ld	s0,32(sp)
    800009ae:	64e2                	ld	s1,24(sp)
    800009b0:	6942                	ld	s2,16(sp)
    800009b2:	69a2                	ld	s3,8(sp)
    800009b4:	6a02                	ld	s4,0(sp)
    800009b6:	6145                	addi	sp,sp,48
    800009b8:	8082                	ret

00000000800009ba <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800009ba:	1101                	addi	sp,sp,-32
    800009bc:	ec06                	sd	ra,24(sp)
    800009be:	e822                	sd	s0,16(sp)
    800009c0:	e426                	sd	s1,8(sp)
    800009c2:	1000                	addi	s0,sp,32
    800009c4:	84aa                	mv	s1,a0
  if(sz > 0)
    800009c6:	e989                	bnez	a1,800009d8 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800009c8:	8526                	mv	a0,s1
    800009ca:	f91ff0ef          	jal	8000095a <freewalk>
}
    800009ce:	60e2                	ld	ra,24(sp)
    800009d0:	6442                	ld	s0,16(sp)
    800009d2:	64a2                	ld	s1,8(sp)
    800009d4:	6105                	addi	sp,sp,32
    800009d6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800009d8:	6785                	lui	a5,0x1
    800009da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800009dc:	95be                	add	a1,a1,a5
    800009de:	4685                	li	a3,1
    800009e0:	00c5d613          	srli	a2,a1,0xc
    800009e4:	4581                	li	a1,0
    800009e6:	d4bff0ef          	jal	80000730 <uvmunmap>
    800009ea:	bff9                	j	800009c8 <uvmfree+0xe>

00000000800009ec <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800009ec:	7139                	addi	sp,sp,-64
    800009ee:	fc06                	sd	ra,56(sp)
    800009f0:	f822                	sd	s0,48(sp)
    800009f2:	e05a                	sd	s6,0(sp)
    800009f4:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800009f6:	ce4d                	beqz	a2,80000ab0 <uvmcopy+0xc4>
    800009f8:	f426                	sd	s1,40(sp)
    800009fa:	f04a                	sd	s2,32(sp)
    800009fc:	ec4e                	sd	s3,24(sp)
    800009fe:	e852                	sd	s4,16(sp)
    80000a00:	e456                	sd	s5,8(sp)
    80000a02:	8a2a                	mv	s4,a0
    80000a04:	89ae                	mv	s3,a1
    80000a06:	8932                	mv	s2,a2
    80000a08:	4481                	li	s1,0
    80000a0a:	a0a9                	j	80000a54 <uvmcopy+0x68>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    80000a0c:	00006517          	auipc	a0,0x6
    80000a10:	73450513          	addi	a0,a0,1844 # 80007140 <etext+0x140>
    80000a14:	46f040ef          	jal	80005682 <panic>
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    80000a18:	00006517          	auipc	a0,0x6
    80000a1c:	74850513          	addi	a0,a0,1864 # 80007160 <etext+0x160>
    80000a20:	463040ef          	jal	80005682 <panic>
    flags = PTE_FLAGS(*pte);

    // COW modification:
    if(flags & PTE_W){
      // Remove writable, add COW flag for both parent and child
      *pte = (*pte & ~PTE_W) | PTE_COW;
    80000a24:	efb7f793          	andi	a5,a5,-261
    80000a28:	1007e793          	ori	a5,a5,256
    80000a2c:	e11c                	sd	a5,0(a0)
      flags = (flags & ~PTE_W) | PTE_COW;
    80000a2e:	2fb77713          	andi	a4,a4,763
    80000a32:	10076713          	ori	a4,a4,256
    }

    // Map child page to the same physical address, with COW flag if set
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80000a36:	86d6                	mv	a3,s5
    80000a38:	6605                	lui	a2,0x1
    80000a3a:	85a6                	mv	a1,s1
    80000a3c:	854e                	mv	a0,s3
    80000a3e:	b4dff0ef          	jal	8000058a <mappages>
    80000a42:	8b2a                	mv	s6,a0
    80000a44:	ed0d                	bnez	a0,80000a7e <uvmcopy+0x92>
      goto err;
    }

    // Increment ref count on the physical page
    inc_ref((void*)pa);
    80000a46:	8556                	mv	a0,s5
    80000a48:	dd4ff0ef          	jal	8000001c <inc_ref>
  for(i = 0; i < sz; i += PGSIZE){
    80000a4c:	6785                	lui	a5,0x1
    80000a4e:	94be                	add	s1,s1,a5
    80000a50:	0524fa63          	bgeu	s1,s2,80000aa4 <uvmcopy+0xb8>
    if((pte = walk(old, i, 0)) == 0)
    80000a54:	4601                	li	a2,0
    80000a56:	85a6                	mv	a1,s1
    80000a58:	8552                	mv	a0,s4
    80000a5a:	a5dff0ef          	jal	800004b6 <walk>
    80000a5e:	d55d                	beqz	a0,80000a0c <uvmcopy+0x20>
    if((*pte & PTE_V) == 0)
    80000a60:	611c                	ld	a5,0(a0)
    80000a62:	0017f713          	andi	a4,a5,1
    80000a66:	db4d                	beqz	a4,80000a18 <uvmcopy+0x2c>
    pa = PTE2PA(*pte);
    80000a68:	00a7da93          	srli	s5,a5,0xa
    80000a6c:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte);
    80000a6e:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W){
    80000a72:	0047f693          	andi	a3,a5,4
    80000a76:	f6dd                	bnez	a3,80000a24 <uvmcopy+0x38>
    flags = PTE_FLAGS(*pte);
    80000a78:	3ff77713          	andi	a4,a4,1023
    80000a7c:	bf6d                	j	80000a36 <uvmcopy+0x4a>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 0);
    80000a7e:	4681                	li	a3,0
    80000a80:	00c4d613          	srli	a2,s1,0xc
    80000a84:	4581                	li	a1,0
    80000a86:	854e                	mv	a0,s3
    80000a88:	ca9ff0ef          	jal	80000730 <uvmunmap>
  return -1;
    80000a8c:	5b7d                	li	s6,-1
    80000a8e:	74a2                	ld	s1,40(sp)
    80000a90:	7902                	ld	s2,32(sp)
    80000a92:	69e2                	ld	s3,24(sp)
    80000a94:	6a42                	ld	s4,16(sp)
    80000a96:	6aa2                	ld	s5,8(sp)
}
    80000a98:	855a                	mv	a0,s6
    80000a9a:	70e2                	ld	ra,56(sp)
    80000a9c:	7442                	ld	s0,48(sp)
    80000a9e:	6b02                	ld	s6,0(sp)
    80000aa0:	6121                	addi	sp,sp,64
    80000aa2:	8082                	ret
    80000aa4:	74a2                	ld	s1,40(sp)
    80000aa6:	7902                	ld	s2,32(sp)
    80000aa8:	69e2                	ld	s3,24(sp)
    80000aaa:	6a42                	ld	s4,16(sp)
    80000aac:	6aa2                	ld	s5,8(sp)
    80000aae:	b7ed                	j	80000a98 <uvmcopy+0xac>
  return 0;
    80000ab0:	4b01                	li	s6,0
    80000ab2:	b7dd                	j	80000a98 <uvmcopy+0xac>

0000000080000ab4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000ab4:	1141                	addi	sp,sp,-16
    80000ab6:	e406                	sd	ra,8(sp)
    80000ab8:	e022                	sd	s0,0(sp)
    80000aba:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000abc:	4601                	li	a2,0
    80000abe:	9f9ff0ef          	jal	800004b6 <walk>
  if(pte == 0)
    80000ac2:	c901                	beqz	a0,80000ad2 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000ac4:	611c                	ld	a5,0(a0)
    80000ac6:	9bbd                	andi	a5,a5,-17
    80000ac8:	e11c                	sd	a5,0(a0)
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret
    panic("uvmclear");
    80000ad2:	00006517          	auipc	a0,0x6
    80000ad6:	6ae50513          	addi	a0,a0,1710 # 80007180 <etext+0x180>
    80000ada:	3a9040ef          	jal	80005682 <panic>

0000000080000ade <copyout>:
{
  uint64 n, va0, pa0;
  pte_t *pte;
  char *mem;

  while(len > 0){
    80000ade:	10068f63          	beqz	a3,80000bfc <copyout+0x11e>
{
    80000ae2:	7159                	addi	sp,sp,-112
    80000ae4:	f486                	sd	ra,104(sp)
    80000ae6:	f0a2                	sd	s0,96(sp)
    80000ae8:	e8ca                	sd	s2,80(sp)
    80000aea:	e4ce                	sd	s3,72(sp)
    80000aec:	e0d2                	sd	s4,64(sp)
    80000aee:	fc56                	sd	s5,56(sp)
    80000af0:	f85a                	sd	s6,48(sp)
    80000af2:	1880                	addi	s0,sp,112
    80000af4:	8b2a                	mv	s6,a0
    80000af6:	89ae                	mv	s3,a1
    80000af8:	8ab2                	mv	s5,a2
    80000afa:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80000afc:	797d                	lui	s2,0xfffff
    80000afe:	0125f933          	and	s2,a1,s2
    if(va0 >= MAXVA)
    80000b02:	57fd                	li	a5,-1
    80000b04:	83e9                	srli	a5,a5,0x1a
    80000b06:	0f27ed63          	bltu	a5,s2,80000c00 <copyout+0x122>
    80000b0a:	eca6                	sd	s1,88(sp)
    80000b0c:	f45e                	sd	s7,40(sp)
    80000b0e:	f062                	sd	s8,32(sp)
    80000b10:	ec66                	sd	s9,24(sp)
    80000b12:	e86a                	sd	s10,16(sp)
    80000b14:	e46e                	sd	s11,8(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80000b16:	4c45                	li	s8,17
      return -1;

    // Handle COW: if page is marked COW and not writable, do COW split
    if((*pte & PTE_COW) && !(*pte & PTE_W)){
    80000b18:	10000c93          	li	s9,256
    va0 = PGROUNDDOWN(dstva);
    80000b1c:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80000b1e:	8bbe                	mv	s7,a5
    80000b20:	a849                	j	80000bb2 <copyout+0xd4>
      pa0 = PTE2PA(*pte);
    80000b22:	83a9                	srli	a5,a5,0xa
    80000b24:	00c79493          	slli	s1,a5,0xc
      if((mem = kalloc()) == 0)
    80000b28:	eb0ff0ef          	jal	800001d8 <kalloc>
    80000b2c:	8daa                	mv	s11,a0
    80000b2e:	10050b63          	beqz	a0,80000c44 <copyout+0x166>
        return -1;
      memmove(mem, (char*)pa0, PGSIZE);
    80000b32:	6605                	lui	a2,0x1
    80000b34:	85a6                	mv	a1,s1
    80000b36:	f68ff0ef          	jal	8000029e <memmove>
      uvmunmap(pagetable, va0, 1, 0);
    80000b3a:	4681                	li	a3,0
    80000b3c:	4605                	li	a2,1
    80000b3e:	85ca                	mv	a1,s2
    80000b40:	855a                	mv	a0,s6
    80000b42:	befff0ef          	jal	80000730 <uvmunmap>
      if(mappages(pagetable, va0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U) != 0){
    80000b46:	4779                	li	a4,30
    80000b48:	86ee                	mv	a3,s11
    80000b4a:	6605                	lui	a2,0x1
    80000b4c:	85ca                	mv	a1,s2
    80000b4e:	855a                	mv	a0,s6
    80000b50:	a3bff0ef          	jal	8000058a <mappages>
    80000b54:	e115                	bnez	a0,80000b78 <copyout+0x9a>
        kfree(mem);
        return -1;
      }
      kfree((void*)pa0);
    80000b56:	8526                	mv	a0,s1
    80000b58:	d58ff0ef          	jal	800000b0 <kfree>
      pte = walk(pagetable, va0, 0);
    80000b5c:	4601                	li	a2,0
    80000b5e:	85ca                	mv	a1,s2
    80000b60:	855a                	mv	a0,s6
    80000b62:	955ff0ef          	jal	800004b6 <walk>
      if(pte == 0)
    80000b66:	e52d                	bnez	a0,80000bd0 <copyout+0xf2>
        return -1;
    80000b68:	557d                	li	a0,-1
    80000b6a:	64e6                	ld	s1,88(sp)
    80000b6c:	7ba2                	ld	s7,40(sp)
    80000b6e:	7c02                	ld	s8,32(sp)
    80000b70:	6ce2                	ld	s9,24(sp)
    80000b72:	6d42                	ld	s10,16(sp)
    80000b74:	6da2                	ld	s11,8(sp)
    80000b76:	a075                	j	80000c22 <copyout+0x144>
        kfree(mem);
    80000b78:	856e                	mv	a0,s11
    80000b7a:	d36ff0ef          	jal	800000b0 <kfree>
        return -1;
    80000b7e:	557d                	li	a0,-1
    80000b80:	64e6                	ld	s1,88(sp)
    80000b82:	7ba2                	ld	s7,40(sp)
    80000b84:	7c02                	ld	s8,32(sp)
    80000b86:	6ce2                	ld	s9,24(sp)
    80000b88:	6d42                	ld	s10,16(sp)
    80000b8a:	6da2                	ld	s11,8(sp)
    80000b8c:	a859                	j	80000c22 <copyout+0x144>
      return -1;

    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b8e:	41298933          	sub	s2,s3,s2
    80000b92:	0004861b          	sext.w	a2,s1
    80000b96:	85d6                	mv	a1,s5
    80000b98:	954a                	add	a0,a0,s2
    80000b9a:	f04ff0ef          	jal	8000029e <memmove>

    len -= n;
    80000b9e:	409a0a33          	sub	s4,s4,s1
    src += n;
    80000ba2:	9aa6                	add	s5,s5,s1
    dstva += n;
    80000ba4:	99a6                	add	s3,s3,s1
  while(len > 0){
    80000ba6:	040a0363          	beqz	s4,80000bec <copyout+0x10e>
    va0 = PGROUNDDOWN(dstva);
    80000baa:	01a9f933          	and	s2,s3,s10
    if(va0 >= MAXVA)
    80000bae:	052beb63          	bltu	s7,s2,80000c04 <copyout+0x126>
    pte = walk(pagetable, va0, 0);
    80000bb2:	4601                	li	a2,0
    80000bb4:	85ca                	mv	a1,s2
    80000bb6:	855a                	mv	a0,s6
    80000bb8:	8ffff0ef          	jal	800004b6 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80000bbc:	cd21                	beqz	a0,80000c14 <copyout+0x136>
    80000bbe:	611c                	ld	a5,0(a0)
    80000bc0:	0117f713          	andi	a4,a5,17
    80000bc4:	07871863          	bne	a4,s8,80000c34 <copyout+0x156>
    if((*pte & PTE_COW) && !(*pte & PTE_W)){
    80000bc8:	1047f713          	andi	a4,a5,260
    80000bcc:	f5970be3          	beq	a4,s9,80000b22 <copyout+0x44>
    pa0 = PTE2PA(*pte);
    80000bd0:	611c                	ld	a5,0(a0)
    80000bd2:	00a7d513          	srli	a0,a5,0xa
    80000bd6:	0532                	slli	a0,a0,0xc
    if((*pte & PTE_W) == 0)
    80000bd8:	8b91                	andi	a5,a5,4
    80000bda:	cfad                	beqz	a5,80000c54 <copyout+0x176>
    n = PGSIZE - (dstva - va0);
    80000bdc:	6485                	lui	s1,0x1
    80000bde:	94ca                	add	s1,s1,s2
    80000be0:	413484b3          	sub	s1,s1,s3
    if(n > len)
    80000be4:	fa9a75e3          	bgeu	s4,s1,80000b8e <copyout+0xb0>
    80000be8:	84d2                	mv	s1,s4
    80000bea:	b755                	j	80000b8e <copyout+0xb0>
  }
  return 0;
    80000bec:	4501                	li	a0,0
    80000bee:	64e6                	ld	s1,88(sp)
    80000bf0:	7ba2                	ld	s7,40(sp)
    80000bf2:	7c02                	ld	s8,32(sp)
    80000bf4:	6ce2                	ld	s9,24(sp)
    80000bf6:	6d42                	ld	s10,16(sp)
    80000bf8:	6da2                	ld	s11,8(sp)
    80000bfa:	a025                	j	80000c22 <copyout+0x144>
    80000bfc:	4501                	li	a0,0
}
    80000bfe:	8082                	ret
      return -1;
    80000c00:	557d                	li	a0,-1
    80000c02:	a005                	j	80000c22 <copyout+0x144>
    80000c04:	557d                	li	a0,-1
    80000c06:	64e6                	ld	s1,88(sp)
    80000c08:	7ba2                	ld	s7,40(sp)
    80000c0a:	7c02                	ld	s8,32(sp)
    80000c0c:	6ce2                	ld	s9,24(sp)
    80000c0e:	6d42                	ld	s10,16(sp)
    80000c10:	6da2                	ld	s11,8(sp)
    80000c12:	a801                	j	80000c22 <copyout+0x144>
      return -1;
    80000c14:	557d                	li	a0,-1
    80000c16:	64e6                	ld	s1,88(sp)
    80000c18:	7ba2                	ld	s7,40(sp)
    80000c1a:	7c02                	ld	s8,32(sp)
    80000c1c:	6ce2                	ld	s9,24(sp)
    80000c1e:	6d42                	ld	s10,16(sp)
    80000c20:	6da2                	ld	s11,8(sp)
}
    80000c22:	70a6                	ld	ra,104(sp)
    80000c24:	7406                	ld	s0,96(sp)
    80000c26:	6946                	ld	s2,80(sp)
    80000c28:	69a6                	ld	s3,72(sp)
    80000c2a:	6a06                	ld	s4,64(sp)
    80000c2c:	7ae2                	ld	s5,56(sp)
    80000c2e:	7b42                	ld	s6,48(sp)
    80000c30:	6165                	addi	sp,sp,112
    80000c32:	8082                	ret
      return -1;
    80000c34:	557d                	li	a0,-1
    80000c36:	64e6                	ld	s1,88(sp)
    80000c38:	7ba2                	ld	s7,40(sp)
    80000c3a:	7c02                	ld	s8,32(sp)
    80000c3c:	6ce2                	ld	s9,24(sp)
    80000c3e:	6d42                	ld	s10,16(sp)
    80000c40:	6da2                	ld	s11,8(sp)
    80000c42:	b7c5                	j	80000c22 <copyout+0x144>
        return -1;
    80000c44:	557d                	li	a0,-1
    80000c46:	64e6                	ld	s1,88(sp)
    80000c48:	7ba2                	ld	s7,40(sp)
    80000c4a:	7c02                	ld	s8,32(sp)
    80000c4c:	6ce2                	ld	s9,24(sp)
    80000c4e:	6d42                	ld	s10,16(sp)
    80000c50:	6da2                	ld	s11,8(sp)
    80000c52:	bfc1                	j	80000c22 <copyout+0x144>
      return -1;
    80000c54:	557d                	li	a0,-1
    80000c56:	64e6                	ld	s1,88(sp)
    80000c58:	7ba2                	ld	s7,40(sp)
    80000c5a:	7c02                	ld	s8,32(sp)
    80000c5c:	6ce2                	ld	s9,24(sp)
    80000c5e:	6d42                	ld	s10,16(sp)
    80000c60:	6da2                	ld	s11,8(sp)
    80000c62:	b7c1                	j	80000c22 <copyout+0x144>

0000000080000c64 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c64:	c6a5                	beqz	a3,80000ccc <copyin+0x68>
{
    80000c66:	715d                	addi	sp,sp,-80
    80000c68:	e486                	sd	ra,72(sp)
    80000c6a:	e0a2                	sd	s0,64(sp)
    80000c6c:	fc26                	sd	s1,56(sp)
    80000c6e:	f84a                	sd	s2,48(sp)
    80000c70:	f44e                	sd	s3,40(sp)
    80000c72:	f052                	sd	s4,32(sp)
    80000c74:	ec56                	sd	s5,24(sp)
    80000c76:	e85a                	sd	s6,16(sp)
    80000c78:	e45e                	sd	s7,8(sp)
    80000c7a:	e062                	sd	s8,0(sp)
    80000c7c:	0880                	addi	s0,sp,80
    80000c7e:	8b2a                	mv	s6,a0
    80000c80:	8a2e                	mv	s4,a1
    80000c82:	8c32                	mv	s8,a2
    80000c84:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000c86:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c88:	6a85                	lui	s5,0x1
    80000c8a:	a00d                	j	80000cac <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c8c:	018505b3          	add	a1,a0,s8
    80000c90:	0004861b          	sext.w	a2,s1
    80000c94:	412585b3          	sub	a1,a1,s2
    80000c98:	8552                	mv	a0,s4
    80000c9a:	e04ff0ef          	jal	8000029e <memmove>

    len -= n;
    80000c9e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000ca2:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000ca4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000ca8:	02098063          	beqz	s3,80000cc8 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000cac:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cb0:	85ca                	mv	a1,s2
    80000cb2:	855a                	mv	a0,s6
    80000cb4:	899ff0ef          	jal	8000054c <walkaddr>
    if(pa0 == 0)
    80000cb8:	cd01                	beqz	a0,80000cd0 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000cba:	418904b3          	sub	s1,s2,s8
    80000cbe:	94d6                	add	s1,s1,s5
    if(n > len)
    80000cc0:	fc99f6e3          	bgeu	s3,s1,80000c8c <copyin+0x28>
    80000cc4:	84ce                	mv	s1,s3
    80000cc6:	b7d9                	j	80000c8c <copyin+0x28>
  }
  return 0;
    80000cc8:	4501                	li	a0,0
    80000cca:	a021                	j	80000cd2 <copyin+0x6e>
    80000ccc:	4501                	li	a0,0
}
    80000cce:	8082                	ret
      return -1;
    80000cd0:	557d                	li	a0,-1
}
    80000cd2:	60a6                	ld	ra,72(sp)
    80000cd4:	6406                	ld	s0,64(sp)
    80000cd6:	74e2                	ld	s1,56(sp)
    80000cd8:	7942                	ld	s2,48(sp)
    80000cda:	79a2                	ld	s3,40(sp)
    80000cdc:	7a02                	ld	s4,32(sp)
    80000cde:	6ae2                	ld	s5,24(sp)
    80000ce0:	6b42                	ld	s6,16(sp)
    80000ce2:	6ba2                	ld	s7,8(sp)
    80000ce4:	6c02                	ld	s8,0(sp)
    80000ce6:	6161                	addi	sp,sp,80
    80000ce8:	8082                	ret

0000000080000cea <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000cea:	c6dd                	beqz	a3,80000d98 <copyinstr+0xae>
{
    80000cec:	715d                	addi	sp,sp,-80
    80000cee:	e486                	sd	ra,72(sp)
    80000cf0:	e0a2                	sd	s0,64(sp)
    80000cf2:	fc26                	sd	s1,56(sp)
    80000cf4:	f84a                	sd	s2,48(sp)
    80000cf6:	f44e                	sd	s3,40(sp)
    80000cf8:	f052                	sd	s4,32(sp)
    80000cfa:	ec56                	sd	s5,24(sp)
    80000cfc:	e85a                	sd	s6,16(sp)
    80000cfe:	e45e                	sd	s7,8(sp)
    80000d00:	0880                	addi	s0,sp,80
    80000d02:	8a2a                	mv	s4,a0
    80000d04:	8b2e                	mv	s6,a1
    80000d06:	8bb2                	mv	s7,a2
    80000d08:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000d0a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d0c:	6985                	lui	s3,0x1
    80000d0e:	a825                	j	80000d46 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000d10:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d14:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000d16:	37fd                	addiw	a5,a5,-1
    80000d18:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000d1c:	60a6                	ld	ra,72(sp)
    80000d1e:	6406                	ld	s0,64(sp)
    80000d20:	74e2                	ld	s1,56(sp)
    80000d22:	7942                	ld	s2,48(sp)
    80000d24:	79a2                	ld	s3,40(sp)
    80000d26:	7a02                	ld	s4,32(sp)
    80000d28:	6ae2                	ld	s5,24(sp)
    80000d2a:	6b42                	ld	s6,16(sp)
    80000d2c:	6ba2                	ld	s7,8(sp)
    80000d2e:	6161                	addi	sp,sp,80
    80000d30:	8082                	ret
    80000d32:	fff90713          	addi	a4,s2,-1 # ffffffffffffefff <end+0xffffffff7ffbb93f>
    80000d36:	9742                	add	a4,a4,a6
      --max;
    80000d38:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000d3c:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000d40:	04e58463          	beq	a1,a4,80000d88 <copyinstr+0x9e>
{
    80000d44:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000d46:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000d4a:	85a6                	mv	a1,s1
    80000d4c:	8552                	mv	a0,s4
    80000d4e:	ffeff0ef          	jal	8000054c <walkaddr>
    if(pa0 == 0)
    80000d52:	cd0d                	beqz	a0,80000d8c <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000d54:	417486b3          	sub	a3,s1,s7
    80000d58:	96ce                	add	a3,a3,s3
    if(n > max)
    80000d5a:	00d97363          	bgeu	s2,a3,80000d60 <copyinstr+0x76>
    80000d5e:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80000d60:	955e                	add	a0,a0,s7
    80000d62:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80000d64:	c695                	beqz	a3,80000d90 <copyinstr+0xa6>
    80000d66:	87da                	mv	a5,s6
    80000d68:	885a                	mv	a6,s6
      if(*p == '\0'){
    80000d6a:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80000d6e:	96da                	add	a3,a3,s6
    80000d70:	85be                	mv	a1,a5
      if(*p == '\0'){
    80000d72:	00f60733          	add	a4,a2,a5
    80000d76:	00074703          	lbu	a4,0(a4)
    80000d7a:	db59                	beqz	a4,80000d10 <copyinstr+0x26>
        *dst = *p;
    80000d7c:	00e78023          	sb	a4,0(a5)
      dst++;
    80000d80:	0785                	addi	a5,a5,1
    while(n > 0){
    80000d82:	fed797e3          	bne	a5,a3,80000d70 <copyinstr+0x86>
    80000d86:	b775                	j	80000d32 <copyinstr+0x48>
    80000d88:	4781                	li	a5,0
    80000d8a:	b771                	j	80000d16 <copyinstr+0x2c>
      return -1;
    80000d8c:	557d                	li	a0,-1
    80000d8e:	b779                	j	80000d1c <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80000d90:	6b85                	lui	s7,0x1
    80000d92:	9ba6                	add	s7,s7,s1
    80000d94:	87da                	mv	a5,s6
    80000d96:	b77d                	j	80000d44 <copyinstr+0x5a>
  int got_null = 0;
    80000d98:	4781                	li	a5,0
  if(got_null){
    80000d9a:	37fd                	addiw	a5,a5,-1
    80000d9c:	0007851b          	sext.w	a0,a5
}
    80000da0:	8082                	ret

0000000080000da2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000da2:	7139                	addi	sp,sp,-64
    80000da4:	fc06                	sd	ra,56(sp)
    80000da6:	f822                	sd	s0,48(sp)
    80000da8:	f426                	sd	s1,40(sp)
    80000daa:	f04a                	sd	s2,32(sp)
    80000dac:	ec4e                	sd	s3,24(sp)
    80000dae:	e852                	sd	s4,16(sp)
    80000db0:	e456                	sd	s5,8(sp)
    80000db2:	e05a                	sd	s6,0(sp)
    80000db4:	0080                	addi	s0,sp,64
    80000db6:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000db8:	0002a497          	auipc	s1,0x2a
    80000dbc:	a2848493          	addi	s1,s1,-1496 # 8002a7e0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000dc0:	8b26                	mv	s6,s1
    80000dc2:	04fa5937          	lui	s2,0x4fa5
    80000dc6:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000dca:	0932                	slli	s2,s2,0xc
    80000dcc:	fa590913          	addi	s2,s2,-91
    80000dd0:	0932                	slli	s2,s2,0xc
    80000dd2:	fa590913          	addi	s2,s2,-91
    80000dd6:	0932                	slli	s2,s2,0xc
    80000dd8:	fa590913          	addi	s2,s2,-91
    80000ddc:	040009b7          	lui	s3,0x4000
    80000de0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000de2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000de4:	0002fa97          	auipc	s5,0x2f
    80000de8:	3fca8a93          	addi	s5,s5,1020 # 800301e0 <tickslock>
    char *pa = kalloc();
    80000dec:	becff0ef          	jal	800001d8 <kalloc>
    80000df0:	862a                	mv	a2,a0
    if(pa == 0)
    80000df2:	cd15                	beqz	a0,80000e2e <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000df4:	416485b3          	sub	a1,s1,s6
    80000df8:	858d                	srai	a1,a1,0x3
    80000dfa:	032585b3          	mul	a1,a1,s2
    80000dfe:	2585                	addiw	a1,a1,1
    80000e00:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e04:	4719                	li	a4,6
    80000e06:	6685                	lui	a3,0x1
    80000e08:	40b985b3          	sub	a1,s3,a1
    80000e0c:	8552                	mv	a0,s4
    80000e0e:	82dff0ef          	jal	8000063a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e12:	16848493          	addi	s1,s1,360
    80000e16:	fd549be3          	bne	s1,s5,80000dec <proc_mapstacks+0x4a>
  }
}
    80000e1a:	70e2                	ld	ra,56(sp)
    80000e1c:	7442                	ld	s0,48(sp)
    80000e1e:	74a2                	ld	s1,40(sp)
    80000e20:	7902                	ld	s2,32(sp)
    80000e22:	69e2                	ld	s3,24(sp)
    80000e24:	6a42                	ld	s4,16(sp)
    80000e26:	6aa2                	ld	s5,8(sp)
    80000e28:	6b02                	ld	s6,0(sp)
    80000e2a:	6121                	addi	sp,sp,64
    80000e2c:	8082                	ret
      panic("kalloc");
    80000e2e:	00006517          	auipc	a0,0x6
    80000e32:	36250513          	addi	a0,a0,866 # 80007190 <etext+0x190>
    80000e36:	04d040ef          	jal	80005682 <panic>

0000000080000e3a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000e3a:	7139                	addi	sp,sp,-64
    80000e3c:	fc06                	sd	ra,56(sp)
    80000e3e:	f822                	sd	s0,48(sp)
    80000e40:	f426                	sd	s1,40(sp)
    80000e42:	f04a                	sd	s2,32(sp)
    80000e44:	ec4e                	sd	s3,24(sp)
    80000e46:	e852                	sd	s4,16(sp)
    80000e48:	e456                	sd	s5,8(sp)
    80000e4a:	e05a                	sd	s6,0(sp)
    80000e4c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000e4e:	00006597          	auipc	a1,0x6
    80000e52:	34a58593          	addi	a1,a1,842 # 80007198 <etext+0x198>
    80000e56:	00029517          	auipc	a0,0x29
    80000e5a:	55a50513          	addi	a0,a0,1370 # 8002a3b0 <pid_lock>
    80000e5e:	2d3040ef          	jal	80005930 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000e62:	00006597          	auipc	a1,0x6
    80000e66:	33e58593          	addi	a1,a1,830 # 800071a0 <etext+0x1a0>
    80000e6a:	00029517          	auipc	a0,0x29
    80000e6e:	55e50513          	addi	a0,a0,1374 # 8002a3c8 <wait_lock>
    80000e72:	2bf040ef          	jal	80005930 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e76:	0002a497          	auipc	s1,0x2a
    80000e7a:	96a48493          	addi	s1,s1,-1686 # 8002a7e0 <proc>
      initlock(&p->lock, "proc");
    80000e7e:	00006b17          	auipc	s6,0x6
    80000e82:	332b0b13          	addi	s6,s6,818 # 800071b0 <etext+0x1b0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000e86:	8aa6                	mv	s5,s1
    80000e88:	04fa5937          	lui	s2,0x4fa5
    80000e8c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000e90:	0932                	slli	s2,s2,0xc
    80000e92:	fa590913          	addi	s2,s2,-91
    80000e96:	0932                	slli	s2,s2,0xc
    80000e98:	fa590913          	addi	s2,s2,-91
    80000e9c:	0932                	slli	s2,s2,0xc
    80000e9e:	fa590913          	addi	s2,s2,-91
    80000ea2:	040009b7          	lui	s3,0x4000
    80000ea6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000ea8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eaa:	0002fa17          	auipc	s4,0x2f
    80000eae:	336a0a13          	addi	s4,s4,822 # 800301e0 <tickslock>
      initlock(&p->lock, "proc");
    80000eb2:	85da                	mv	a1,s6
    80000eb4:	8526                	mv	a0,s1
    80000eb6:	27b040ef          	jal	80005930 <initlock>
      p->state = UNUSED;
    80000eba:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000ebe:	415487b3          	sub	a5,s1,s5
    80000ec2:	878d                	srai	a5,a5,0x3
    80000ec4:	032787b3          	mul	a5,a5,s2
    80000ec8:	2785                	addiw	a5,a5,1
    80000eca:	00d7979b          	slliw	a5,a5,0xd
    80000ece:	40f987b3          	sub	a5,s3,a5
    80000ed2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ed4:	16848493          	addi	s1,s1,360
    80000ed8:	fd449de3          	bne	s1,s4,80000eb2 <procinit+0x78>
  }
}
    80000edc:	70e2                	ld	ra,56(sp)
    80000ede:	7442                	ld	s0,48(sp)
    80000ee0:	74a2                	ld	s1,40(sp)
    80000ee2:	7902                	ld	s2,32(sp)
    80000ee4:	69e2                	ld	s3,24(sp)
    80000ee6:	6a42                	ld	s4,16(sp)
    80000ee8:	6aa2                	ld	s5,8(sp)
    80000eea:	6b02                	ld	s6,0(sp)
    80000eec:	6121                	addi	sp,sp,64
    80000eee:	8082                	ret

0000000080000ef0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000ef0:	1141                	addi	sp,sp,-16
    80000ef2:	e422                	sd	s0,8(sp)
    80000ef4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000ef6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000ef8:	2501                	sext.w	a0,a0
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret

0000000080000f00 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000f00:	1141                	addi	sp,sp,-16
    80000f02:	e422                	sd	s0,8(sp)
    80000f04:	0800                	addi	s0,sp,16
    80000f06:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f08:	2781                	sext.w	a5,a5
    80000f0a:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f0c:	00029517          	auipc	a0,0x29
    80000f10:	4d450513          	addi	a0,a0,1236 # 8002a3e0 <cpus>
    80000f14:	953e                	add	a0,a0,a5
    80000f16:	6422                	ld	s0,8(sp)
    80000f18:	0141                	addi	sp,sp,16
    80000f1a:	8082                	ret

0000000080000f1c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000f1c:	1101                	addi	sp,sp,-32
    80000f1e:	ec06                	sd	ra,24(sp)
    80000f20:	e822                	sd	s0,16(sp)
    80000f22:	e426                	sd	s1,8(sp)
    80000f24:	1000                	addi	s0,sp,32
  push_off();
    80000f26:	24b040ef          	jal	80005970 <push_off>
    80000f2a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000f2c:	2781                	sext.w	a5,a5
    80000f2e:	079e                	slli	a5,a5,0x7
    80000f30:	00029717          	auipc	a4,0x29
    80000f34:	48070713          	addi	a4,a4,1152 # 8002a3b0 <pid_lock>
    80000f38:	97ba                	add	a5,a5,a4
    80000f3a:	7b84                	ld	s1,48(a5)
  pop_off();
    80000f3c:	2b9040ef          	jal	800059f4 <pop_off>
  return p;
}
    80000f40:	8526                	mv	a0,s1
    80000f42:	60e2                	ld	ra,24(sp)
    80000f44:	6442                	ld	s0,16(sp)
    80000f46:	64a2                	ld	s1,8(sp)
    80000f48:	6105                	addi	sp,sp,32
    80000f4a:	8082                	ret

0000000080000f4c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000f4c:	1141                	addi	sp,sp,-16
    80000f4e:	e406                	sd	ra,8(sp)
    80000f50:	e022                	sd	s0,0(sp)
    80000f52:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000f54:	fc9ff0ef          	jal	80000f1c <myproc>
    80000f58:	2f1040ef          	jal	80005a48 <release>

  if (first) {
    80000f5c:	00009797          	auipc	a5,0x9
    80000f60:	3947a783          	lw	a5,916(a5) # 8000a2f0 <first.1>
    80000f64:	e799                	bnez	a5,80000f72 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000f66:	2bf000ef          	jal	80001a24 <usertrapret>
}
    80000f6a:	60a2                	ld	ra,8(sp)
    80000f6c:	6402                	ld	s0,0(sp)
    80000f6e:	0141                	addi	sp,sp,16
    80000f70:	8082                	ret
    fsinit(ROOTDEV);
    80000f72:	4505                	li	a0,1
    80000f74:	728010ef          	jal	8000269c <fsinit>
    first = 0;
    80000f78:	00009797          	auipc	a5,0x9
    80000f7c:	3607ac23          	sw	zero,888(a5) # 8000a2f0 <first.1>
    __sync_synchronize();
    80000f80:	0330000f          	fence	rw,rw
    80000f84:	b7cd                	j	80000f66 <forkret+0x1a>

0000000080000f86 <allocpid>:
{
    80000f86:	1101                	addi	sp,sp,-32
    80000f88:	ec06                	sd	ra,24(sp)
    80000f8a:	e822                	sd	s0,16(sp)
    80000f8c:	e426                	sd	s1,8(sp)
    80000f8e:	e04a                	sd	s2,0(sp)
    80000f90:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f92:	00029917          	auipc	s2,0x29
    80000f96:	41e90913          	addi	s2,s2,1054 # 8002a3b0 <pid_lock>
    80000f9a:	854a                	mv	a0,s2
    80000f9c:	215040ef          	jal	800059b0 <acquire>
  pid = nextpid;
    80000fa0:	00009797          	auipc	a5,0x9
    80000fa4:	35478793          	addi	a5,a5,852 # 8000a2f4 <nextpid>
    80000fa8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000faa:	0014871b          	addiw	a4,s1,1
    80000fae:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000fb0:	854a                	mv	a0,s2
    80000fb2:	297040ef          	jal	80005a48 <release>
}
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	60e2                	ld	ra,24(sp)
    80000fba:	6442                	ld	s0,16(sp)
    80000fbc:	64a2                	ld	s1,8(sp)
    80000fbe:	6902                	ld	s2,0(sp)
    80000fc0:	6105                	addi	sp,sp,32
    80000fc2:	8082                	ret

0000000080000fc4 <proc_pagetable>:
{
    80000fc4:	1101                	addi	sp,sp,-32
    80000fc6:	ec06                	sd	ra,24(sp)
    80000fc8:	e822                	sd	s0,16(sp)
    80000fca:	e426                	sd	s1,8(sp)
    80000fcc:	e04a                	sd	s2,0(sp)
    80000fce:	1000                	addi	s0,sp,32
    80000fd0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000fd2:	81bff0ef          	jal	800007ec <uvmcreate>
    80000fd6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000fd8:	cd05                	beqz	a0,80001010 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000fda:	4729                	li	a4,10
    80000fdc:	00005697          	auipc	a3,0x5
    80000fe0:	02468693          	addi	a3,a3,36 # 80006000 <_trampoline>
    80000fe4:	6605                	lui	a2,0x1
    80000fe6:	040005b7          	lui	a1,0x4000
    80000fea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000fec:	05b2                	slli	a1,a1,0xc
    80000fee:	d9cff0ef          	jal	8000058a <mappages>
    80000ff2:	02054663          	bltz	a0,8000101e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000ff6:	4719                	li	a4,6
    80000ff8:	05893683          	ld	a3,88(s2)
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	020005b7          	lui	a1,0x2000
    80001002:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001004:	05b6                	slli	a1,a1,0xd
    80001006:	8526                	mv	a0,s1
    80001008:	d82ff0ef          	jal	8000058a <mappages>
    8000100c:	00054f63          	bltz	a0,8000102a <proc_pagetable+0x66>
}
    80001010:	8526                	mv	a0,s1
    80001012:	60e2                	ld	ra,24(sp)
    80001014:	6442                	ld	s0,16(sp)
    80001016:	64a2                	ld	s1,8(sp)
    80001018:	6902                	ld	s2,0(sp)
    8000101a:	6105                	addi	sp,sp,32
    8000101c:	8082                	ret
    uvmfree(pagetable, 0);
    8000101e:	4581                	li	a1,0
    80001020:	8526                	mv	a0,s1
    80001022:	999ff0ef          	jal	800009ba <uvmfree>
    return 0;
    80001026:	4481                	li	s1,0
    80001028:	b7e5                	j	80001010 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000102a:	4681                	li	a3,0
    8000102c:	4605                	li	a2,1
    8000102e:	040005b7          	lui	a1,0x4000
    80001032:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001034:	05b2                	slli	a1,a1,0xc
    80001036:	8526                	mv	a0,s1
    80001038:	ef8ff0ef          	jal	80000730 <uvmunmap>
    uvmfree(pagetable, 0);
    8000103c:	4581                	li	a1,0
    8000103e:	8526                	mv	a0,s1
    80001040:	97bff0ef          	jal	800009ba <uvmfree>
    return 0;
    80001044:	4481                	li	s1,0
    80001046:	b7e9                	j	80001010 <proc_pagetable+0x4c>

0000000080001048 <proc_freepagetable>:
{
    80001048:	1101                	addi	sp,sp,-32
    8000104a:	ec06                	sd	ra,24(sp)
    8000104c:	e822                	sd	s0,16(sp)
    8000104e:	e426                	sd	s1,8(sp)
    80001050:	e04a                	sd	s2,0(sp)
    80001052:	1000                	addi	s0,sp,32
    80001054:	84aa                	mv	s1,a0
    80001056:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001058:	4681                	li	a3,0
    8000105a:	4605                	li	a2,1
    8000105c:	040005b7          	lui	a1,0x4000
    80001060:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001062:	05b2                	slli	a1,a1,0xc
    80001064:	eccff0ef          	jal	80000730 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001068:	4681                	li	a3,0
    8000106a:	4605                	li	a2,1
    8000106c:	020005b7          	lui	a1,0x2000
    80001070:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001072:	05b6                	slli	a1,a1,0xd
    80001074:	8526                	mv	a0,s1
    80001076:	ebaff0ef          	jal	80000730 <uvmunmap>
  uvmfree(pagetable, sz);
    8000107a:	85ca                	mv	a1,s2
    8000107c:	8526                	mv	a0,s1
    8000107e:	93dff0ef          	jal	800009ba <uvmfree>
}
    80001082:	60e2                	ld	ra,24(sp)
    80001084:	6442                	ld	s0,16(sp)
    80001086:	64a2                	ld	s1,8(sp)
    80001088:	6902                	ld	s2,0(sp)
    8000108a:	6105                	addi	sp,sp,32
    8000108c:	8082                	ret

000000008000108e <freeproc>:
{
    8000108e:	1101                	addi	sp,sp,-32
    80001090:	ec06                	sd	ra,24(sp)
    80001092:	e822                	sd	s0,16(sp)
    80001094:	e426                	sd	s1,8(sp)
    80001096:	1000                	addi	s0,sp,32
    80001098:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000109a:	6d28                	ld	a0,88(a0)
    8000109c:	c119                	beqz	a0,800010a2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    8000109e:	812ff0ef          	jal	800000b0 <kfree>
  p->trapframe = 0;
    800010a2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800010a6:	68a8                	ld	a0,80(s1)
    800010a8:	c501                	beqz	a0,800010b0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800010aa:	64ac                	ld	a1,72(s1)
    800010ac:	f9dff0ef          	jal	80001048 <proc_freepagetable>
  p->pagetable = 0;
    800010b0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800010b4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800010b8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800010bc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800010c0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800010c4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800010c8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800010cc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800010d0:	0004ac23          	sw	zero,24(s1)
}
    800010d4:	60e2                	ld	ra,24(sp)
    800010d6:	6442                	ld	s0,16(sp)
    800010d8:	64a2                	ld	s1,8(sp)
    800010da:	6105                	addi	sp,sp,32
    800010dc:	8082                	ret

00000000800010de <allocproc>:
{
    800010de:	1101                	addi	sp,sp,-32
    800010e0:	ec06                	sd	ra,24(sp)
    800010e2:	e822                	sd	s0,16(sp)
    800010e4:	e426                	sd	s1,8(sp)
    800010e6:	e04a                	sd	s2,0(sp)
    800010e8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ea:	00029497          	auipc	s1,0x29
    800010ee:	6f648493          	addi	s1,s1,1782 # 8002a7e0 <proc>
    800010f2:	0002f917          	auipc	s2,0x2f
    800010f6:	0ee90913          	addi	s2,s2,238 # 800301e0 <tickslock>
    acquire(&p->lock);
    800010fa:	8526                	mv	a0,s1
    800010fc:	0b5040ef          	jal	800059b0 <acquire>
    if(p->state == UNUSED) {
    80001100:	4c9c                	lw	a5,24(s1)
    80001102:	cb91                	beqz	a5,80001116 <allocproc+0x38>
      release(&p->lock);
    80001104:	8526                	mv	a0,s1
    80001106:	143040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000110a:	16848493          	addi	s1,s1,360
    8000110e:	ff2496e3          	bne	s1,s2,800010fa <allocproc+0x1c>
  return 0;
    80001112:	4481                	li	s1,0
    80001114:	a089                	j	80001156 <allocproc+0x78>
  p->pid = allocpid();
    80001116:	e71ff0ef          	jal	80000f86 <allocpid>
    8000111a:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000111c:	4785                	li	a5,1
    8000111e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001120:	8b8ff0ef          	jal	800001d8 <kalloc>
    80001124:	892a                	mv	s2,a0
    80001126:	eca8                	sd	a0,88(s1)
    80001128:	cd15                	beqz	a0,80001164 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    8000112a:	8526                	mv	a0,s1
    8000112c:	e99ff0ef          	jal	80000fc4 <proc_pagetable>
    80001130:	892a                	mv	s2,a0
    80001132:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001134:	c121                	beqz	a0,80001174 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001136:	07000613          	li	a2,112
    8000113a:	4581                	li	a1,0
    8000113c:	06048513          	addi	a0,s1,96
    80001140:	902ff0ef          	jal	80000242 <memset>
  p->context.ra = (uint64)forkret;
    80001144:	00000797          	auipc	a5,0x0
    80001148:	e0878793          	addi	a5,a5,-504 # 80000f4c <forkret>
    8000114c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000114e:	60bc                	ld	a5,64(s1)
    80001150:	6705                	lui	a4,0x1
    80001152:	97ba                	add	a5,a5,a4
    80001154:	f4bc                	sd	a5,104(s1)
}
    80001156:	8526                	mv	a0,s1
    80001158:	60e2                	ld	ra,24(sp)
    8000115a:	6442                	ld	s0,16(sp)
    8000115c:	64a2                	ld	s1,8(sp)
    8000115e:	6902                	ld	s2,0(sp)
    80001160:	6105                	addi	sp,sp,32
    80001162:	8082                	ret
    freeproc(p);
    80001164:	8526                	mv	a0,s1
    80001166:	f29ff0ef          	jal	8000108e <freeproc>
    release(&p->lock);
    8000116a:	8526                	mv	a0,s1
    8000116c:	0dd040ef          	jal	80005a48 <release>
    return 0;
    80001170:	84ca                	mv	s1,s2
    80001172:	b7d5                	j	80001156 <allocproc+0x78>
    freeproc(p);
    80001174:	8526                	mv	a0,s1
    80001176:	f19ff0ef          	jal	8000108e <freeproc>
    release(&p->lock);
    8000117a:	8526                	mv	a0,s1
    8000117c:	0cd040ef          	jal	80005a48 <release>
    return 0;
    80001180:	84ca                	mv	s1,s2
    80001182:	bfd1                	j	80001156 <allocproc+0x78>

0000000080001184 <userinit>:
{
    80001184:	1101                	addi	sp,sp,-32
    80001186:	ec06                	sd	ra,24(sp)
    80001188:	e822                	sd	s0,16(sp)
    8000118a:	e426                	sd	s1,8(sp)
    8000118c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000118e:	f51ff0ef          	jal	800010de <allocproc>
    80001192:	84aa                	mv	s1,a0
  initproc = p;
    80001194:	00009797          	auipc	a5,0x9
    80001198:	1ca7be23          	sd	a0,476(a5) # 8000a370 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000119c:	03400613          	li	a2,52
    800011a0:	00009597          	auipc	a1,0x9
    800011a4:	16058593          	addi	a1,a1,352 # 8000a300 <initcode>
    800011a8:	6928                	ld	a0,80(a0)
    800011aa:	e68ff0ef          	jal	80000812 <uvmfirst>
  p->sz = PGSIZE;
    800011ae:	6785                	lui	a5,0x1
    800011b0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800011b2:	6cb8                	ld	a4,88(s1)
    800011b4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800011b8:	6cb8                	ld	a4,88(s1)
    800011ba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800011bc:	4641                	li	a2,16
    800011be:	00006597          	auipc	a1,0x6
    800011c2:	ffa58593          	addi	a1,a1,-6 # 800071b8 <etext+0x1b8>
    800011c6:	15848513          	addi	a0,s1,344
    800011ca:	9b6ff0ef          	jal	80000380 <safestrcpy>
  p->cwd = namei("/");
    800011ce:	00006517          	auipc	a0,0x6
    800011d2:	ffa50513          	addi	a0,a0,-6 # 800071c8 <etext+0x1c8>
    800011d6:	5d5010ef          	jal	80002faa <namei>
    800011da:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011de:	478d                	li	a5,3
    800011e0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011e2:	8526                	mv	a0,s1
    800011e4:	065040ef          	jal	80005a48 <release>
}
    800011e8:	60e2                	ld	ra,24(sp)
    800011ea:	6442                	ld	s0,16(sp)
    800011ec:	64a2                	ld	s1,8(sp)
    800011ee:	6105                	addi	sp,sp,32
    800011f0:	8082                	ret

00000000800011f2 <growproc>:
{
    800011f2:	1101                	addi	sp,sp,-32
    800011f4:	ec06                	sd	ra,24(sp)
    800011f6:	e822                	sd	s0,16(sp)
    800011f8:	e426                	sd	s1,8(sp)
    800011fa:	e04a                	sd	s2,0(sp)
    800011fc:	1000                	addi	s0,sp,32
    800011fe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001200:	d1dff0ef          	jal	80000f1c <myproc>
    80001204:	84aa                	mv	s1,a0
  sz = p->sz;
    80001206:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001208:	01204c63          	bgtz	s2,80001220 <growproc+0x2e>
  } else if(n < 0){
    8000120c:	02094463          	bltz	s2,80001234 <growproc+0x42>
  p->sz = sz;
    80001210:	e4ac                	sd	a1,72(s1)
  return 0;
    80001212:	4501                	li	a0,0
}
    80001214:	60e2                	ld	ra,24(sp)
    80001216:	6442                	ld	s0,16(sp)
    80001218:	64a2                	ld	s1,8(sp)
    8000121a:	6902                	ld	s2,0(sp)
    8000121c:	6105                	addi	sp,sp,32
    8000121e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001220:	4691                	li	a3,4
    80001222:	00b90633          	add	a2,s2,a1
    80001226:	6928                	ld	a0,80(a0)
    80001228:	e8cff0ef          	jal	800008b4 <uvmalloc>
    8000122c:	85aa                	mv	a1,a0
    8000122e:	f16d                	bnez	a0,80001210 <growproc+0x1e>
      return -1;
    80001230:	557d                	li	a0,-1
    80001232:	b7cd                	j	80001214 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001234:	00b90633          	add	a2,s2,a1
    80001238:	6928                	ld	a0,80(a0)
    8000123a:	e36ff0ef          	jal	80000870 <uvmdealloc>
    8000123e:	85aa                	mv	a1,a0
    80001240:	bfc1                	j	80001210 <growproc+0x1e>

0000000080001242 <fork>:
{
    80001242:	7139                	addi	sp,sp,-64
    80001244:	fc06                	sd	ra,56(sp)
    80001246:	f822                	sd	s0,48(sp)
    80001248:	f04a                	sd	s2,32(sp)
    8000124a:	e456                	sd	s5,8(sp)
    8000124c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000124e:	ccfff0ef          	jal	80000f1c <myproc>
    80001252:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001254:	e8bff0ef          	jal	800010de <allocproc>
    80001258:	0e050a63          	beqz	a0,8000134c <fork+0x10a>
    8000125c:	e852                	sd	s4,16(sp)
    8000125e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001260:	048ab603          	ld	a2,72(s5)
    80001264:	692c                	ld	a1,80(a0)
    80001266:	050ab503          	ld	a0,80(s5)
    8000126a:	f82ff0ef          	jal	800009ec <uvmcopy>
    8000126e:	04054a63          	bltz	a0,800012c2 <fork+0x80>
    80001272:	f426                	sd	s1,40(sp)
    80001274:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001276:	048ab783          	ld	a5,72(s5)
    8000127a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000127e:	058ab683          	ld	a3,88(s5)
    80001282:	87b6                	mv	a5,a3
    80001284:	058a3703          	ld	a4,88(s4)
    80001288:	12068693          	addi	a3,a3,288
    8000128c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001290:	6788                	ld	a0,8(a5)
    80001292:	6b8c                	ld	a1,16(a5)
    80001294:	6f90                	ld	a2,24(a5)
    80001296:	01073023          	sd	a6,0(a4)
    8000129a:	e708                	sd	a0,8(a4)
    8000129c:	eb0c                	sd	a1,16(a4)
    8000129e:	ef10                	sd	a2,24(a4)
    800012a0:	02078793          	addi	a5,a5,32
    800012a4:	02070713          	addi	a4,a4,32
    800012a8:	fed792e3          	bne	a5,a3,8000128c <fork+0x4a>
  np->trapframe->a0 = 0;
    800012ac:	058a3783          	ld	a5,88(s4)
    800012b0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800012b4:	0d0a8493          	addi	s1,s5,208
    800012b8:	0d0a0913          	addi	s2,s4,208
    800012bc:	150a8993          	addi	s3,s5,336
    800012c0:	a831                	j	800012dc <fork+0x9a>
    freeproc(np);
    800012c2:	8552                	mv	a0,s4
    800012c4:	dcbff0ef          	jal	8000108e <freeproc>
    release(&np->lock);
    800012c8:	8552                	mv	a0,s4
    800012ca:	77e040ef          	jal	80005a48 <release>
    return -1;
    800012ce:	597d                	li	s2,-1
    800012d0:	6a42                	ld	s4,16(sp)
    800012d2:	a0b5                	j	8000133e <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    800012d4:	04a1                	addi	s1,s1,8
    800012d6:	0921                	addi	s2,s2,8
    800012d8:	01348963          	beq	s1,s3,800012ea <fork+0xa8>
    if(p->ofile[i])
    800012dc:	6088                	ld	a0,0(s1)
    800012de:	d97d                	beqz	a0,800012d4 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    800012e0:	25a020ef          	jal	8000353a <filedup>
    800012e4:	00a93023          	sd	a0,0(s2)
    800012e8:	b7f5                	j	800012d4 <fork+0x92>
  np->cwd = idup(p->cwd);
    800012ea:	150ab503          	ld	a0,336(s5)
    800012ee:	5ac010ef          	jal	8000289a <idup>
    800012f2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012f6:	4641                	li	a2,16
    800012f8:	158a8593          	addi	a1,s5,344
    800012fc:	158a0513          	addi	a0,s4,344
    80001300:	880ff0ef          	jal	80000380 <safestrcpy>
  pid = np->pid;
    80001304:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001308:	8552                	mv	a0,s4
    8000130a:	73e040ef          	jal	80005a48 <release>
  acquire(&wait_lock);
    8000130e:	00029497          	auipc	s1,0x29
    80001312:	0ba48493          	addi	s1,s1,186 # 8002a3c8 <wait_lock>
    80001316:	8526                	mv	a0,s1
    80001318:	698040ef          	jal	800059b0 <acquire>
  np->parent = p;
    8000131c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001320:	8526                	mv	a0,s1
    80001322:	726040ef          	jal	80005a48 <release>
  acquire(&np->lock);
    80001326:	8552                	mv	a0,s4
    80001328:	688040ef          	jal	800059b0 <acquire>
  np->state = RUNNABLE;
    8000132c:	478d                	li	a5,3
    8000132e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001332:	8552                	mv	a0,s4
    80001334:	714040ef          	jal	80005a48 <release>
  return pid;
    80001338:	74a2                	ld	s1,40(sp)
    8000133a:	69e2                	ld	s3,24(sp)
    8000133c:	6a42                	ld	s4,16(sp)
}
    8000133e:	854a                	mv	a0,s2
    80001340:	70e2                	ld	ra,56(sp)
    80001342:	7442                	ld	s0,48(sp)
    80001344:	7902                	ld	s2,32(sp)
    80001346:	6aa2                	ld	s5,8(sp)
    80001348:	6121                	addi	sp,sp,64
    8000134a:	8082                	ret
    return -1;
    8000134c:	597d                	li	s2,-1
    8000134e:	bfc5                	j	8000133e <fork+0xfc>

0000000080001350 <scheduler>:
{
    80001350:	715d                	addi	sp,sp,-80
    80001352:	e486                	sd	ra,72(sp)
    80001354:	e0a2                	sd	s0,64(sp)
    80001356:	fc26                	sd	s1,56(sp)
    80001358:	f84a                	sd	s2,48(sp)
    8000135a:	f44e                	sd	s3,40(sp)
    8000135c:	f052                	sd	s4,32(sp)
    8000135e:	ec56                	sd	s5,24(sp)
    80001360:	e85a                	sd	s6,16(sp)
    80001362:	e45e                	sd	s7,8(sp)
    80001364:	e062                	sd	s8,0(sp)
    80001366:	0880                	addi	s0,sp,80
    80001368:	8792                	mv	a5,tp
  int id = r_tp();
    8000136a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000136c:	00779b13          	slli	s6,a5,0x7
    80001370:	00029717          	auipc	a4,0x29
    80001374:	04070713          	addi	a4,a4,64 # 8002a3b0 <pid_lock>
    80001378:	975a                	add	a4,a4,s6
    8000137a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000137e:	00029717          	auipc	a4,0x29
    80001382:	06a70713          	addi	a4,a4,106 # 8002a3e8 <cpus+0x8>
    80001386:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001388:	4c11                	li	s8,4
        c->proc = p;
    8000138a:	079e                	slli	a5,a5,0x7
    8000138c:	00029a17          	auipc	s4,0x29
    80001390:	024a0a13          	addi	s4,s4,36 # 8002a3b0 <pid_lock>
    80001394:	9a3e                	add	s4,s4,a5
        found = 1;
    80001396:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001398:	0002f997          	auipc	s3,0x2f
    8000139c:	e4898993          	addi	s3,s3,-440 # 800301e0 <tickslock>
    800013a0:	a0a9                	j	800013ea <scheduler+0x9a>
      release(&p->lock);
    800013a2:	8526                	mv	a0,s1
    800013a4:	6a4040ef          	jal	80005a48 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013a8:	16848493          	addi	s1,s1,360
    800013ac:	03348563          	beq	s1,s3,800013d6 <scheduler+0x86>
      acquire(&p->lock);
    800013b0:	8526                	mv	a0,s1
    800013b2:	5fe040ef          	jal	800059b0 <acquire>
      if(p->state == RUNNABLE) {
    800013b6:	4c9c                	lw	a5,24(s1)
    800013b8:	ff2795e3          	bne	a5,s2,800013a2 <scheduler+0x52>
        p->state = RUNNING;
    800013bc:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800013c0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013c4:	06048593          	addi	a1,s1,96
    800013c8:	855a                	mv	a0,s6
    800013ca:	5b4000ef          	jal	8000197e <swtch>
        c->proc = 0;
    800013ce:	020a3823          	sd	zero,48(s4)
        found = 1;
    800013d2:	8ade                	mv	s5,s7
    800013d4:	b7f9                	j	800013a2 <scheduler+0x52>
    if(found == 0) {
    800013d6:	000a9a63          	bnez	s5,800013ea <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013de:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013e2:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800013e6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013f2:	10079073          	csrw	sstatus,a5
    int found = 0;
    800013f6:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800013f8:	00029497          	auipc	s1,0x29
    800013fc:	3e848493          	addi	s1,s1,1000 # 8002a7e0 <proc>
      if(p->state == RUNNABLE) {
    80001400:	490d                	li	s2,3
    80001402:	b77d                	j	800013b0 <scheduler+0x60>

0000000080001404 <sched>:
{
    80001404:	7179                	addi	sp,sp,-48
    80001406:	f406                	sd	ra,40(sp)
    80001408:	f022                	sd	s0,32(sp)
    8000140a:	ec26                	sd	s1,24(sp)
    8000140c:	e84a                	sd	s2,16(sp)
    8000140e:	e44e                	sd	s3,8(sp)
    80001410:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001412:	b0bff0ef          	jal	80000f1c <myproc>
    80001416:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001418:	52e040ef          	jal	80005946 <holding>
    8000141c:	c92d                	beqz	a0,8000148e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000141e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001420:	2781                	sext.w	a5,a5
    80001422:	079e                	slli	a5,a5,0x7
    80001424:	00029717          	auipc	a4,0x29
    80001428:	f8c70713          	addi	a4,a4,-116 # 8002a3b0 <pid_lock>
    8000142c:	97ba                	add	a5,a5,a4
    8000142e:	0a87a703          	lw	a4,168(a5)
    80001432:	4785                	li	a5,1
    80001434:	06f71363          	bne	a4,a5,8000149a <sched+0x96>
  if(p->state == RUNNING)
    80001438:	4c98                	lw	a4,24(s1)
    8000143a:	4791                	li	a5,4
    8000143c:	06f70563          	beq	a4,a5,800014a6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001440:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001444:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001446:	e7b5                	bnez	a5,800014b2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001448:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000144a:	00029917          	auipc	s2,0x29
    8000144e:	f6690913          	addi	s2,s2,-154 # 8002a3b0 <pid_lock>
    80001452:	2781                	sext.w	a5,a5
    80001454:	079e                	slli	a5,a5,0x7
    80001456:	97ca                	add	a5,a5,s2
    80001458:	0ac7a983          	lw	s3,172(a5)
    8000145c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000145e:	2781                	sext.w	a5,a5
    80001460:	079e                	slli	a5,a5,0x7
    80001462:	00029597          	auipc	a1,0x29
    80001466:	f8658593          	addi	a1,a1,-122 # 8002a3e8 <cpus+0x8>
    8000146a:	95be                	add	a1,a1,a5
    8000146c:	06048513          	addi	a0,s1,96
    80001470:	50e000ef          	jal	8000197e <swtch>
    80001474:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001476:	2781                	sext.w	a5,a5
    80001478:	079e                	slli	a5,a5,0x7
    8000147a:	993e                	add	s2,s2,a5
    8000147c:	0b392623          	sw	s3,172(s2)
}
    80001480:	70a2                	ld	ra,40(sp)
    80001482:	7402                	ld	s0,32(sp)
    80001484:	64e2                	ld	s1,24(sp)
    80001486:	6942                	ld	s2,16(sp)
    80001488:	69a2                	ld	s3,8(sp)
    8000148a:	6145                	addi	sp,sp,48
    8000148c:	8082                	ret
    panic("sched p->lock");
    8000148e:	00006517          	auipc	a0,0x6
    80001492:	d4250513          	addi	a0,a0,-702 # 800071d0 <etext+0x1d0>
    80001496:	1ec040ef          	jal	80005682 <panic>
    panic("sched locks");
    8000149a:	00006517          	auipc	a0,0x6
    8000149e:	d4650513          	addi	a0,a0,-698 # 800071e0 <etext+0x1e0>
    800014a2:	1e0040ef          	jal	80005682 <panic>
    panic("sched running");
    800014a6:	00006517          	auipc	a0,0x6
    800014aa:	d4a50513          	addi	a0,a0,-694 # 800071f0 <etext+0x1f0>
    800014ae:	1d4040ef          	jal	80005682 <panic>
    panic("sched interruptible");
    800014b2:	00006517          	auipc	a0,0x6
    800014b6:	d4e50513          	addi	a0,a0,-690 # 80007200 <etext+0x200>
    800014ba:	1c8040ef          	jal	80005682 <panic>

00000000800014be <yield>:
{
    800014be:	1101                	addi	sp,sp,-32
    800014c0:	ec06                	sd	ra,24(sp)
    800014c2:	e822                	sd	s0,16(sp)
    800014c4:	e426                	sd	s1,8(sp)
    800014c6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014c8:	a55ff0ef          	jal	80000f1c <myproc>
    800014cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800014ce:	4e2040ef          	jal	800059b0 <acquire>
  p->state = RUNNABLE;
    800014d2:	478d                	li	a5,3
    800014d4:	cc9c                	sw	a5,24(s1)
  sched();
    800014d6:	f2fff0ef          	jal	80001404 <sched>
  release(&p->lock);
    800014da:	8526                	mv	a0,s1
    800014dc:	56c040ef          	jal	80005a48 <release>
}
    800014e0:	60e2                	ld	ra,24(sp)
    800014e2:	6442                	ld	s0,16(sp)
    800014e4:	64a2                	ld	s1,8(sp)
    800014e6:	6105                	addi	sp,sp,32
    800014e8:	8082                	ret

00000000800014ea <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800014ea:	7179                	addi	sp,sp,-48
    800014ec:	f406                	sd	ra,40(sp)
    800014ee:	f022                	sd	s0,32(sp)
    800014f0:	ec26                	sd	s1,24(sp)
    800014f2:	e84a                	sd	s2,16(sp)
    800014f4:	e44e                	sd	s3,8(sp)
    800014f6:	1800                	addi	s0,sp,48
    800014f8:	89aa                	mv	s3,a0
    800014fa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800014fc:	a21ff0ef          	jal	80000f1c <myproc>
    80001500:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001502:	4ae040ef          	jal	800059b0 <acquire>
  release(lk);
    80001506:	854a                	mv	a0,s2
    80001508:	540040ef          	jal	80005a48 <release>

  // Go to sleep.
  p->chan = chan;
    8000150c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001510:	4789                	li	a5,2
    80001512:	cc9c                	sw	a5,24(s1)

  sched();
    80001514:	ef1ff0ef          	jal	80001404 <sched>

  // Tidy up.
  p->chan = 0;
    80001518:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000151c:	8526                	mv	a0,s1
    8000151e:	52a040ef          	jal	80005a48 <release>
  acquire(lk);
    80001522:	854a                	mv	a0,s2
    80001524:	48c040ef          	jal	800059b0 <acquire>
}
    80001528:	70a2                	ld	ra,40(sp)
    8000152a:	7402                	ld	s0,32(sp)
    8000152c:	64e2                	ld	s1,24(sp)
    8000152e:	6942                	ld	s2,16(sp)
    80001530:	69a2                	ld	s3,8(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001536:	7139                	addi	sp,sp,-64
    80001538:	fc06                	sd	ra,56(sp)
    8000153a:	f822                	sd	s0,48(sp)
    8000153c:	f426                	sd	s1,40(sp)
    8000153e:	f04a                	sd	s2,32(sp)
    80001540:	ec4e                	sd	s3,24(sp)
    80001542:	e852                	sd	s4,16(sp)
    80001544:	e456                	sd	s5,8(sp)
    80001546:	0080                	addi	s0,sp,64
    80001548:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000154a:	00029497          	auipc	s1,0x29
    8000154e:	29648493          	addi	s1,s1,662 # 8002a7e0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001552:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001554:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001556:	0002f917          	auipc	s2,0x2f
    8000155a:	c8a90913          	addi	s2,s2,-886 # 800301e0 <tickslock>
    8000155e:	a801                	j	8000156e <wakeup+0x38>
      }
      release(&p->lock);
    80001560:	8526                	mv	a0,s1
    80001562:	4e6040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001566:	16848493          	addi	s1,s1,360
    8000156a:	03248263          	beq	s1,s2,8000158e <wakeup+0x58>
    if(p != myproc()){
    8000156e:	9afff0ef          	jal	80000f1c <myproc>
    80001572:	fea48ae3          	beq	s1,a0,80001566 <wakeup+0x30>
      acquire(&p->lock);
    80001576:	8526                	mv	a0,s1
    80001578:	438040ef          	jal	800059b0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000157c:	4c9c                	lw	a5,24(s1)
    8000157e:	ff3791e3          	bne	a5,s3,80001560 <wakeup+0x2a>
    80001582:	709c                	ld	a5,32(s1)
    80001584:	fd479ee3          	bne	a5,s4,80001560 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001588:	0154ac23          	sw	s5,24(s1)
    8000158c:	bfd1                	j	80001560 <wakeup+0x2a>
    }
  }
}
    8000158e:	70e2                	ld	ra,56(sp)
    80001590:	7442                	ld	s0,48(sp)
    80001592:	74a2                	ld	s1,40(sp)
    80001594:	7902                	ld	s2,32(sp)
    80001596:	69e2                	ld	s3,24(sp)
    80001598:	6a42                	ld	s4,16(sp)
    8000159a:	6aa2                	ld	s5,8(sp)
    8000159c:	6121                	addi	sp,sp,64
    8000159e:	8082                	ret

00000000800015a0 <reparent>:
{
    800015a0:	7179                	addi	sp,sp,-48
    800015a2:	f406                	sd	ra,40(sp)
    800015a4:	f022                	sd	s0,32(sp)
    800015a6:	ec26                	sd	s1,24(sp)
    800015a8:	e84a                	sd	s2,16(sp)
    800015aa:	e44e                	sd	s3,8(sp)
    800015ac:	e052                	sd	s4,0(sp)
    800015ae:	1800                	addi	s0,sp,48
    800015b0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015b2:	00029497          	auipc	s1,0x29
    800015b6:	22e48493          	addi	s1,s1,558 # 8002a7e0 <proc>
      pp->parent = initproc;
    800015ba:	00009a17          	auipc	s4,0x9
    800015be:	db6a0a13          	addi	s4,s4,-586 # 8000a370 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015c2:	0002f997          	auipc	s3,0x2f
    800015c6:	c1e98993          	addi	s3,s3,-994 # 800301e0 <tickslock>
    800015ca:	a029                	j	800015d4 <reparent+0x34>
    800015cc:	16848493          	addi	s1,s1,360
    800015d0:	01348b63          	beq	s1,s3,800015e6 <reparent+0x46>
    if(pp->parent == p){
    800015d4:	7c9c                	ld	a5,56(s1)
    800015d6:	ff279be3          	bne	a5,s2,800015cc <reparent+0x2c>
      pp->parent = initproc;
    800015da:	000a3503          	ld	a0,0(s4)
    800015de:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800015e0:	f57ff0ef          	jal	80001536 <wakeup>
    800015e4:	b7e5                	j	800015cc <reparent+0x2c>
}
    800015e6:	70a2                	ld	ra,40(sp)
    800015e8:	7402                	ld	s0,32(sp)
    800015ea:	64e2                	ld	s1,24(sp)
    800015ec:	6942                	ld	s2,16(sp)
    800015ee:	69a2                	ld	s3,8(sp)
    800015f0:	6a02                	ld	s4,0(sp)
    800015f2:	6145                	addi	sp,sp,48
    800015f4:	8082                	ret

00000000800015f6 <exit>:
{
    800015f6:	7179                	addi	sp,sp,-48
    800015f8:	f406                	sd	ra,40(sp)
    800015fa:	f022                	sd	s0,32(sp)
    800015fc:	ec26                	sd	s1,24(sp)
    800015fe:	e84a                	sd	s2,16(sp)
    80001600:	e44e                	sd	s3,8(sp)
    80001602:	e052                	sd	s4,0(sp)
    80001604:	1800                	addi	s0,sp,48
    80001606:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001608:	915ff0ef          	jal	80000f1c <myproc>
    8000160c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000160e:	00009797          	auipc	a5,0x9
    80001612:	d627b783          	ld	a5,-670(a5) # 8000a370 <initproc>
    80001616:	0d050493          	addi	s1,a0,208
    8000161a:	15050913          	addi	s2,a0,336
    8000161e:	00a79f63          	bne	a5,a0,8000163c <exit+0x46>
    panic("init exiting");
    80001622:	00006517          	auipc	a0,0x6
    80001626:	bf650513          	addi	a0,a0,-1034 # 80007218 <etext+0x218>
    8000162a:	058040ef          	jal	80005682 <panic>
      fileclose(f);
    8000162e:	753010ef          	jal	80003580 <fileclose>
      p->ofile[fd] = 0;
    80001632:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001636:	04a1                	addi	s1,s1,8
    80001638:	01248563          	beq	s1,s2,80001642 <exit+0x4c>
    if(p->ofile[fd]){
    8000163c:	6088                	ld	a0,0(s1)
    8000163e:	f965                	bnez	a0,8000162e <exit+0x38>
    80001640:	bfdd                	j	80001636 <exit+0x40>
  begin_op();
    80001642:	325010ef          	jal	80003166 <begin_op>
  iput(p->cwd);
    80001646:	1509b503          	ld	a0,336(s3)
    8000164a:	408010ef          	jal	80002a52 <iput>
  end_op();
    8000164e:	383010ef          	jal	800031d0 <end_op>
  p->cwd = 0;
    80001652:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001656:	00029497          	auipc	s1,0x29
    8000165a:	d7248493          	addi	s1,s1,-654 # 8002a3c8 <wait_lock>
    8000165e:	8526                	mv	a0,s1
    80001660:	350040ef          	jal	800059b0 <acquire>
  reparent(p);
    80001664:	854e                	mv	a0,s3
    80001666:	f3bff0ef          	jal	800015a0 <reparent>
  wakeup(p->parent);
    8000166a:	0389b503          	ld	a0,56(s3)
    8000166e:	ec9ff0ef          	jal	80001536 <wakeup>
  acquire(&p->lock);
    80001672:	854e                	mv	a0,s3
    80001674:	33c040ef          	jal	800059b0 <acquire>
  p->xstate = status;
    80001678:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000167c:	4795                	li	a5,5
    8000167e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001682:	8526                	mv	a0,s1
    80001684:	3c4040ef          	jal	80005a48 <release>
  sched();
    80001688:	d7dff0ef          	jal	80001404 <sched>
  panic("zombie exit");
    8000168c:	00006517          	auipc	a0,0x6
    80001690:	b9c50513          	addi	a0,a0,-1124 # 80007228 <etext+0x228>
    80001694:	7ef030ef          	jal	80005682 <panic>

0000000080001698 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001698:	7179                	addi	sp,sp,-48
    8000169a:	f406                	sd	ra,40(sp)
    8000169c:	f022                	sd	s0,32(sp)
    8000169e:	ec26                	sd	s1,24(sp)
    800016a0:	e84a                	sd	s2,16(sp)
    800016a2:	e44e                	sd	s3,8(sp)
    800016a4:	1800                	addi	s0,sp,48
    800016a6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800016a8:	00029497          	auipc	s1,0x29
    800016ac:	13848493          	addi	s1,s1,312 # 8002a7e0 <proc>
    800016b0:	0002f997          	auipc	s3,0x2f
    800016b4:	b3098993          	addi	s3,s3,-1232 # 800301e0 <tickslock>
    acquire(&p->lock);
    800016b8:	8526                	mv	a0,s1
    800016ba:	2f6040ef          	jal	800059b0 <acquire>
    if(p->pid == pid){
    800016be:	589c                	lw	a5,48(s1)
    800016c0:	01278b63          	beq	a5,s2,800016d6 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800016c4:	8526                	mv	a0,s1
    800016c6:	382040ef          	jal	80005a48 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800016ca:	16848493          	addi	s1,s1,360
    800016ce:	ff3495e3          	bne	s1,s3,800016b8 <kill+0x20>
  }
  return -1;
    800016d2:	557d                	li	a0,-1
    800016d4:	a819                	j	800016ea <kill+0x52>
      p->killed = 1;
    800016d6:	4785                	li	a5,1
    800016d8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800016da:	4c98                	lw	a4,24(s1)
    800016dc:	4789                	li	a5,2
    800016de:	00f70d63          	beq	a4,a5,800016f8 <kill+0x60>
      release(&p->lock);
    800016e2:	8526                	mv	a0,s1
    800016e4:	364040ef          	jal	80005a48 <release>
      return 0;
    800016e8:	4501                	li	a0,0
}
    800016ea:	70a2                	ld	ra,40(sp)
    800016ec:	7402                	ld	s0,32(sp)
    800016ee:	64e2                	ld	s1,24(sp)
    800016f0:	6942                	ld	s2,16(sp)
    800016f2:	69a2                	ld	s3,8(sp)
    800016f4:	6145                	addi	sp,sp,48
    800016f6:	8082                	ret
        p->state = RUNNABLE;
    800016f8:	478d                	li	a5,3
    800016fa:	cc9c                	sw	a5,24(s1)
    800016fc:	b7dd                	j	800016e2 <kill+0x4a>

00000000800016fe <setkilled>:

void
setkilled(struct proc *p)
{
    800016fe:	1101                	addi	sp,sp,-32
    80001700:	ec06                	sd	ra,24(sp)
    80001702:	e822                	sd	s0,16(sp)
    80001704:	e426                	sd	s1,8(sp)
    80001706:	1000                	addi	s0,sp,32
    80001708:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000170a:	2a6040ef          	jal	800059b0 <acquire>
  p->killed = 1;
    8000170e:	4785                	li	a5,1
    80001710:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001712:	8526                	mv	a0,s1
    80001714:	334040ef          	jal	80005a48 <release>
}
    80001718:	60e2                	ld	ra,24(sp)
    8000171a:	6442                	ld	s0,16(sp)
    8000171c:	64a2                	ld	s1,8(sp)
    8000171e:	6105                	addi	sp,sp,32
    80001720:	8082                	ret

0000000080001722 <killed>:

int
killed(struct proc *p)
{
    80001722:	1101                	addi	sp,sp,-32
    80001724:	ec06                	sd	ra,24(sp)
    80001726:	e822                	sd	s0,16(sp)
    80001728:	e426                	sd	s1,8(sp)
    8000172a:	e04a                	sd	s2,0(sp)
    8000172c:	1000                	addi	s0,sp,32
    8000172e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001730:	280040ef          	jal	800059b0 <acquire>
  k = p->killed;
    80001734:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001738:	8526                	mv	a0,s1
    8000173a:	30e040ef          	jal	80005a48 <release>
  return k;
}
    8000173e:	854a                	mv	a0,s2
    80001740:	60e2                	ld	ra,24(sp)
    80001742:	6442                	ld	s0,16(sp)
    80001744:	64a2                	ld	s1,8(sp)
    80001746:	6902                	ld	s2,0(sp)
    80001748:	6105                	addi	sp,sp,32
    8000174a:	8082                	ret

000000008000174c <wait>:
{
    8000174c:	715d                	addi	sp,sp,-80
    8000174e:	e486                	sd	ra,72(sp)
    80001750:	e0a2                	sd	s0,64(sp)
    80001752:	fc26                	sd	s1,56(sp)
    80001754:	f84a                	sd	s2,48(sp)
    80001756:	f44e                	sd	s3,40(sp)
    80001758:	f052                	sd	s4,32(sp)
    8000175a:	ec56                	sd	s5,24(sp)
    8000175c:	e85a                	sd	s6,16(sp)
    8000175e:	e45e                	sd	s7,8(sp)
    80001760:	e062                	sd	s8,0(sp)
    80001762:	0880                	addi	s0,sp,80
    80001764:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001766:	fb6ff0ef          	jal	80000f1c <myproc>
    8000176a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000176c:	00029517          	auipc	a0,0x29
    80001770:	c5c50513          	addi	a0,a0,-932 # 8002a3c8 <wait_lock>
    80001774:	23c040ef          	jal	800059b0 <acquire>
    havekids = 0;
    80001778:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000177a:	4a15                	li	s4,5
        havekids = 1;
    8000177c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000177e:	0002f997          	auipc	s3,0x2f
    80001782:	a6298993          	addi	s3,s3,-1438 # 800301e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001786:	00029c17          	auipc	s8,0x29
    8000178a:	c42c0c13          	addi	s8,s8,-958 # 8002a3c8 <wait_lock>
    8000178e:	a871                	j	8000182a <wait+0xde>
          pid = pp->pid;
    80001790:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001794:	000b0c63          	beqz	s6,800017ac <wait+0x60>
    80001798:	4691                	li	a3,4
    8000179a:	02c48613          	addi	a2,s1,44
    8000179e:	85da                	mv	a1,s6
    800017a0:	05093503          	ld	a0,80(s2)
    800017a4:	b3aff0ef          	jal	80000ade <copyout>
    800017a8:	02054b63          	bltz	a0,800017de <wait+0x92>
          freeproc(pp);
    800017ac:	8526                	mv	a0,s1
    800017ae:	8e1ff0ef          	jal	8000108e <freeproc>
          release(&pp->lock);
    800017b2:	8526                	mv	a0,s1
    800017b4:	294040ef          	jal	80005a48 <release>
          release(&wait_lock);
    800017b8:	00029517          	auipc	a0,0x29
    800017bc:	c1050513          	addi	a0,a0,-1008 # 8002a3c8 <wait_lock>
    800017c0:	288040ef          	jal	80005a48 <release>
}
    800017c4:	854e                	mv	a0,s3
    800017c6:	60a6                	ld	ra,72(sp)
    800017c8:	6406                	ld	s0,64(sp)
    800017ca:	74e2                	ld	s1,56(sp)
    800017cc:	7942                	ld	s2,48(sp)
    800017ce:	79a2                	ld	s3,40(sp)
    800017d0:	7a02                	ld	s4,32(sp)
    800017d2:	6ae2                	ld	s5,24(sp)
    800017d4:	6b42                	ld	s6,16(sp)
    800017d6:	6ba2                	ld	s7,8(sp)
    800017d8:	6c02                	ld	s8,0(sp)
    800017da:	6161                	addi	sp,sp,80
    800017dc:	8082                	ret
            release(&pp->lock);
    800017de:	8526                	mv	a0,s1
    800017e0:	268040ef          	jal	80005a48 <release>
            release(&wait_lock);
    800017e4:	00029517          	auipc	a0,0x29
    800017e8:	be450513          	addi	a0,a0,-1052 # 8002a3c8 <wait_lock>
    800017ec:	25c040ef          	jal	80005a48 <release>
            return -1;
    800017f0:	59fd                	li	s3,-1
    800017f2:	bfc9                	j	800017c4 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800017f4:	16848493          	addi	s1,s1,360
    800017f8:	03348063          	beq	s1,s3,80001818 <wait+0xcc>
      if(pp->parent == p){
    800017fc:	7c9c                	ld	a5,56(s1)
    800017fe:	ff279be3          	bne	a5,s2,800017f4 <wait+0xa8>
        acquire(&pp->lock);
    80001802:	8526                	mv	a0,s1
    80001804:	1ac040ef          	jal	800059b0 <acquire>
        if(pp->state == ZOMBIE){
    80001808:	4c9c                	lw	a5,24(s1)
    8000180a:	f94783e3          	beq	a5,s4,80001790 <wait+0x44>
        release(&pp->lock);
    8000180e:	8526                	mv	a0,s1
    80001810:	238040ef          	jal	80005a48 <release>
        havekids = 1;
    80001814:	8756                	mv	a4,s5
    80001816:	bff9                	j	800017f4 <wait+0xa8>
    if(!havekids || killed(p)){
    80001818:	cf19                	beqz	a4,80001836 <wait+0xea>
    8000181a:	854a                	mv	a0,s2
    8000181c:	f07ff0ef          	jal	80001722 <killed>
    80001820:	e919                	bnez	a0,80001836 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001822:	85e2                	mv	a1,s8
    80001824:	854a                	mv	a0,s2
    80001826:	cc5ff0ef          	jal	800014ea <sleep>
    havekids = 0;
    8000182a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000182c:	00029497          	auipc	s1,0x29
    80001830:	fb448493          	addi	s1,s1,-76 # 8002a7e0 <proc>
    80001834:	b7e1                	j	800017fc <wait+0xb0>
      release(&wait_lock);
    80001836:	00029517          	auipc	a0,0x29
    8000183a:	b9250513          	addi	a0,a0,-1134 # 8002a3c8 <wait_lock>
    8000183e:	20a040ef          	jal	80005a48 <release>
      return -1;
    80001842:	59fd                	li	s3,-1
    80001844:	b741                	j	800017c4 <wait+0x78>

0000000080001846 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001846:	7179                	addi	sp,sp,-48
    80001848:	f406                	sd	ra,40(sp)
    8000184a:	f022                	sd	s0,32(sp)
    8000184c:	ec26                	sd	s1,24(sp)
    8000184e:	e84a                	sd	s2,16(sp)
    80001850:	e44e                	sd	s3,8(sp)
    80001852:	e052                	sd	s4,0(sp)
    80001854:	1800                	addi	s0,sp,48
    80001856:	84aa                	mv	s1,a0
    80001858:	892e                	mv	s2,a1
    8000185a:	89b2                	mv	s3,a2
    8000185c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000185e:	ebeff0ef          	jal	80000f1c <myproc>
  if(user_dst){
    80001862:	cc99                	beqz	s1,80001880 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001864:	86d2                	mv	a3,s4
    80001866:	864e                	mv	a2,s3
    80001868:	85ca                	mv	a1,s2
    8000186a:	6928                	ld	a0,80(a0)
    8000186c:	a72ff0ef          	jal	80000ade <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001870:	70a2                	ld	ra,40(sp)
    80001872:	7402                	ld	s0,32(sp)
    80001874:	64e2                	ld	s1,24(sp)
    80001876:	6942                	ld	s2,16(sp)
    80001878:	69a2                	ld	s3,8(sp)
    8000187a:	6a02                	ld	s4,0(sp)
    8000187c:	6145                	addi	sp,sp,48
    8000187e:	8082                	ret
    memmove((char *)dst, src, len);
    80001880:	000a061b          	sext.w	a2,s4
    80001884:	85ce                	mv	a1,s3
    80001886:	854a                	mv	a0,s2
    80001888:	a17fe0ef          	jal	8000029e <memmove>
    return 0;
    8000188c:	8526                	mv	a0,s1
    8000188e:	b7cd                	j	80001870 <either_copyout+0x2a>

0000000080001890 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001890:	7179                	addi	sp,sp,-48
    80001892:	f406                	sd	ra,40(sp)
    80001894:	f022                	sd	s0,32(sp)
    80001896:	ec26                	sd	s1,24(sp)
    80001898:	e84a                	sd	s2,16(sp)
    8000189a:	e44e                	sd	s3,8(sp)
    8000189c:	e052                	sd	s4,0(sp)
    8000189e:	1800                	addi	s0,sp,48
    800018a0:	892a                	mv	s2,a0
    800018a2:	84ae                	mv	s1,a1
    800018a4:	89b2                	mv	s3,a2
    800018a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800018a8:	e74ff0ef          	jal	80000f1c <myproc>
  if(user_src){
    800018ac:	cc99                	beqz	s1,800018ca <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800018ae:	86d2                	mv	a3,s4
    800018b0:	864e                	mv	a2,s3
    800018b2:	85ca                	mv	a1,s2
    800018b4:	6928                	ld	a0,80(a0)
    800018b6:	baeff0ef          	jal	80000c64 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800018ba:	70a2                	ld	ra,40(sp)
    800018bc:	7402                	ld	s0,32(sp)
    800018be:	64e2                	ld	s1,24(sp)
    800018c0:	6942                	ld	s2,16(sp)
    800018c2:	69a2                	ld	s3,8(sp)
    800018c4:	6a02                	ld	s4,0(sp)
    800018c6:	6145                	addi	sp,sp,48
    800018c8:	8082                	ret
    memmove(dst, (char*)src, len);
    800018ca:	000a061b          	sext.w	a2,s4
    800018ce:	85ce                	mv	a1,s3
    800018d0:	854a                	mv	a0,s2
    800018d2:	9cdfe0ef          	jal	8000029e <memmove>
    return 0;
    800018d6:	8526                	mv	a0,s1
    800018d8:	b7cd                	j	800018ba <either_copyin+0x2a>

00000000800018da <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800018da:	715d                	addi	sp,sp,-80
    800018dc:	e486                	sd	ra,72(sp)
    800018de:	e0a2                	sd	s0,64(sp)
    800018e0:	fc26                	sd	s1,56(sp)
    800018e2:	f84a                	sd	s2,48(sp)
    800018e4:	f44e                	sd	s3,40(sp)
    800018e6:	f052                	sd	s4,32(sp)
    800018e8:	ec56                	sd	s5,24(sp)
    800018ea:	e85a                	sd	s6,16(sp)
    800018ec:	e45e                	sd	s7,8(sp)
    800018ee:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800018f0:	00005517          	auipc	a0,0x5
    800018f4:	72850513          	addi	a0,a0,1832 # 80007018 <etext+0x18>
    800018f8:	2b9030ef          	jal	800053b0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018fc:	00029497          	auipc	s1,0x29
    80001900:	03c48493          	addi	s1,s1,60 # 8002a938 <proc+0x158>
    80001904:	0002f917          	auipc	s2,0x2f
    80001908:	a3490913          	addi	s2,s2,-1484 # 80030338 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000190c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000190e:	00006997          	auipc	s3,0x6
    80001912:	92a98993          	addi	s3,s3,-1750 # 80007238 <etext+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    80001916:	00006a97          	auipc	s5,0x6
    8000191a:	92aa8a93          	addi	s5,s5,-1750 # 80007240 <etext+0x240>
    printf("\n");
    8000191e:	00005a17          	auipc	s4,0x5
    80001922:	6faa0a13          	addi	s4,s4,1786 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001926:	00006b97          	auipc	s7,0x6
    8000192a:	ee2b8b93          	addi	s7,s7,-286 # 80007808 <states.0>
    8000192e:	a829                	j	80001948 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001930:	ed86a583          	lw	a1,-296(a3)
    80001934:	8556                	mv	a0,s5
    80001936:	27b030ef          	jal	800053b0 <printf>
    printf("\n");
    8000193a:	8552                	mv	a0,s4
    8000193c:	275030ef          	jal	800053b0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001940:	16848493          	addi	s1,s1,360
    80001944:	03248263          	beq	s1,s2,80001968 <procdump+0x8e>
    if(p->state == UNUSED)
    80001948:	86a6                	mv	a3,s1
    8000194a:	ec04a783          	lw	a5,-320(s1)
    8000194e:	dbed                	beqz	a5,80001940 <procdump+0x66>
      state = "???";
    80001950:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001952:	fcfb6fe3          	bltu	s6,a5,80001930 <procdump+0x56>
    80001956:	02079713          	slli	a4,a5,0x20
    8000195a:	01d75793          	srli	a5,a4,0x1d
    8000195e:	97de                	add	a5,a5,s7
    80001960:	6390                	ld	a2,0(a5)
    80001962:	f679                	bnez	a2,80001930 <procdump+0x56>
      state = "???";
    80001964:	864e                	mv	a2,s3
    80001966:	b7e9                	j	80001930 <procdump+0x56>
  }
}
    80001968:	60a6                	ld	ra,72(sp)
    8000196a:	6406                	ld	s0,64(sp)
    8000196c:	74e2                	ld	s1,56(sp)
    8000196e:	7942                	ld	s2,48(sp)
    80001970:	79a2                	ld	s3,40(sp)
    80001972:	7a02                	ld	s4,32(sp)
    80001974:	6ae2                	ld	s5,24(sp)
    80001976:	6b42                	ld	s6,16(sp)
    80001978:	6ba2                	ld	s7,8(sp)
    8000197a:	6161                	addi	sp,sp,80
    8000197c:	8082                	ret

000000008000197e <swtch>:
    8000197e:	00153023          	sd	ra,0(a0)
    80001982:	00253423          	sd	sp,8(a0)
    80001986:	e900                	sd	s0,16(a0)
    80001988:	ed04                	sd	s1,24(a0)
    8000198a:	03253023          	sd	s2,32(a0)
    8000198e:	03353423          	sd	s3,40(a0)
    80001992:	03453823          	sd	s4,48(a0)
    80001996:	03553c23          	sd	s5,56(a0)
    8000199a:	05653023          	sd	s6,64(a0)
    8000199e:	05753423          	sd	s7,72(a0)
    800019a2:	05853823          	sd	s8,80(a0)
    800019a6:	05953c23          	sd	s9,88(a0)
    800019aa:	07a53023          	sd	s10,96(a0)
    800019ae:	07b53423          	sd	s11,104(a0)
    800019b2:	0005b083          	ld	ra,0(a1)
    800019b6:	0085b103          	ld	sp,8(a1)
    800019ba:	6980                	ld	s0,16(a1)
    800019bc:	6d84                	ld	s1,24(a1)
    800019be:	0205b903          	ld	s2,32(a1)
    800019c2:	0285b983          	ld	s3,40(a1)
    800019c6:	0305ba03          	ld	s4,48(a1)
    800019ca:	0385ba83          	ld	s5,56(a1)
    800019ce:	0405bb03          	ld	s6,64(a1)
    800019d2:	0485bb83          	ld	s7,72(a1)
    800019d6:	0505bc03          	ld	s8,80(a1)
    800019da:	0585bc83          	ld	s9,88(a1)
    800019de:	0605bd03          	ld	s10,96(a1)
    800019e2:	0685bd83          	ld	s11,104(a1)
    800019e6:	8082                	ret

00000000800019e8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800019e8:	1141                	addi	sp,sp,-16
    800019ea:	e406                	sd	ra,8(sp)
    800019ec:	e022                	sd	s0,0(sp)
    800019ee:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800019f0:	00006597          	auipc	a1,0x6
    800019f4:	89058593          	addi	a1,a1,-1904 # 80007280 <etext+0x280>
    800019f8:	0002e517          	auipc	a0,0x2e
    800019fc:	7e850513          	addi	a0,a0,2024 # 800301e0 <tickslock>
    80001a00:	731030ef          	jal	80005930 <initlock>
}
    80001a04:	60a2                	ld	ra,8(sp)
    80001a06:	6402                	ld	s0,0(sp)
    80001a08:	0141                	addi	sp,sp,16
    80001a0a:	8082                	ret

0000000080001a0c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001a0c:	1141                	addi	sp,sp,-16
    80001a0e:	e422                	sd	s0,8(sp)
    80001a10:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a12:	00003797          	auipc	a5,0x3
    80001a16:	ede78793          	addi	a5,a5,-290 # 800048f0 <kernelvec>
    80001a1a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001a1e:	6422                	ld	s0,8(sp)
    80001a20:	0141                	addi	sp,sp,16
    80001a22:	8082                	ret

0000000080001a24 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001a24:	1141                	addi	sp,sp,-16
    80001a26:	e406                	sd	ra,8(sp)
    80001a28:	e022                	sd	s0,0(sp)
    80001a2a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001a2c:	cf0ff0ef          	jal	80000f1c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001a34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a36:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001a3a:	00004697          	auipc	a3,0x4
    80001a3e:	5c668693          	addi	a3,a3,1478 # 80006000 <_trampoline>
    80001a42:	00004717          	auipc	a4,0x4
    80001a46:	5be70713          	addi	a4,a4,1470 # 80006000 <_trampoline>
    80001a4a:	8f15                	sub	a4,a4,a3
    80001a4c:	040007b7          	lui	a5,0x4000
    80001a50:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001a52:	07b2                	slli	a5,a5,0xc
    80001a54:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a56:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001a5a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001a5c:	18002673          	csrr	a2,satp
    80001a60:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001a62:	6d30                	ld	a2,88(a0)
    80001a64:	6138                	ld	a4,64(a0)
    80001a66:	6585                	lui	a1,0x1
    80001a68:	972e                	add	a4,a4,a1
    80001a6a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001a6c:	6d38                	ld	a4,88(a0)
    80001a6e:	00000617          	auipc	a2,0x0
    80001a72:	11060613          	addi	a2,a2,272 # 80001b7e <usertrap>
    80001a76:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001a78:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a7a:	8612                	mv	a2,tp
    80001a7c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a7e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001a82:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001a86:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a8a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001a8e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001a90:	6f18                	ld	a4,24(a4)
    80001a92:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a96:	6928                	ld	a0,80(a0)
    80001a98:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a9a:	00004717          	auipc	a4,0x4
    80001a9e:	60270713          	addi	a4,a4,1538 # 8000609c <userret>
    80001aa2:	8f15                	sub	a4,a4,a3
    80001aa4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001aa6:	577d                	li	a4,-1
    80001aa8:	177e                	slli	a4,a4,0x3f
    80001aaa:	8d59                	or	a0,a0,a4
    80001aac:	9782                	jalr	a5
}
    80001aae:	60a2                	ld	ra,8(sp)
    80001ab0:	6402                	ld	s0,0(sp)
    80001ab2:	0141                	addi	sp,sp,16
    80001ab4:	8082                	ret

0000000080001ab6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001abe:	c32ff0ef          	jal	80000ef0 <cpuid>
    80001ac2:	cd11                	beqz	a0,80001ade <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001ac4:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001ac8:	000f4737          	lui	a4,0xf4
    80001acc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001ad0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001ad2:	14d79073          	csrw	stimecmp,a5
}
    80001ad6:	60e2                	ld	ra,24(sp)
    80001ad8:	6442                	ld	s0,16(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret
    80001ade:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001ae0:	0002e497          	auipc	s1,0x2e
    80001ae4:	70048493          	addi	s1,s1,1792 # 800301e0 <tickslock>
    80001ae8:	8526                	mv	a0,s1
    80001aea:	6c7030ef          	jal	800059b0 <acquire>
    ticks++;
    80001aee:	00009517          	auipc	a0,0x9
    80001af2:	88a50513          	addi	a0,a0,-1910 # 8000a378 <ticks>
    80001af6:	411c                	lw	a5,0(a0)
    80001af8:	2785                	addiw	a5,a5,1
    80001afa:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001afc:	a3bff0ef          	jal	80001536 <wakeup>
    release(&tickslock);
    80001b00:	8526                	mv	a0,s1
    80001b02:	747030ef          	jal	80005a48 <release>
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	bf75                	j	80001ac4 <clockintr+0xe>

0000000080001b0a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b12:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001b16:	57fd                	li	a5,-1
    80001b18:	17fe                	slli	a5,a5,0x3f
    80001b1a:	07a5                	addi	a5,a5,9
    80001b1c:	00f70c63          	beq	a4,a5,80001b34 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001b20:	57fd                	li	a5,-1
    80001b22:	17fe                	slli	a5,a5,0x3f
    80001b24:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001b26:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001b28:	04f70763          	beq	a4,a5,80001b76 <devintr+0x6c>
  }
}
    80001b2c:	60e2                	ld	ra,24(sp)
    80001b2e:	6442                	ld	s0,16(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret
    80001b34:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001b36:	667020ef          	jal	8000499c <plic_claim>
    80001b3a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001b3c:	47a9                	li	a5,10
    80001b3e:	00f50963          	beq	a0,a5,80001b50 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001b42:	4785                	li	a5,1
    80001b44:	00f50963          	beq	a0,a5,80001b56 <devintr+0x4c>
    return 1;
    80001b48:	4505                	li	a0,1
    } else if(irq){
    80001b4a:	e889                	bnez	s1,80001b5c <devintr+0x52>
    80001b4c:	64a2                	ld	s1,8(sp)
    80001b4e:	bff9                	j	80001b2c <devintr+0x22>
      uartintr();
    80001b50:	5a5030ef          	jal	800058f4 <uartintr>
    if(irq)
    80001b54:	a819                	j	80001b6a <devintr+0x60>
      virtio_disk_intr();
    80001b56:	30c030ef          	jal	80004e62 <virtio_disk_intr>
    if(irq)
    80001b5a:	a801                	j	80001b6a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001b5c:	85a6                	mv	a1,s1
    80001b5e:	00005517          	auipc	a0,0x5
    80001b62:	72a50513          	addi	a0,a0,1834 # 80007288 <etext+0x288>
    80001b66:	04b030ef          	jal	800053b0 <printf>
      plic_complete(irq);
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	651020ef          	jal	800049bc <plic_complete>
    return 1;
    80001b70:	4505                	li	a0,1
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	bf65                	j	80001b2c <devintr+0x22>
    clockintr();
    80001b76:	f41ff0ef          	jal	80001ab6 <clockintr>
    return 2;
    80001b7a:	4509                	li	a0,2
    80001b7c:	bf45                	j	80001b2c <devintr+0x22>

0000000080001b7e <usertrap>:
{
    80001b7e:	7179                	addi	sp,sp,-48
    80001b80:	f406                	sd	ra,40(sp)
    80001b82:	f022                	sd	s0,32(sp)
    80001b84:	ec26                	sd	s1,24(sp)
    80001b86:	e84a                	sd	s2,16(sp)
    80001b88:	e44e                	sd	s3,8(sp)
    80001b8a:	e052                	sd	s4,0(sp)
    80001b8c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b8e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001b92:	1007f793          	andi	a5,a5,256
    80001b96:	e7b5                	bnez	a5,80001c02 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b98:	00003797          	auipc	a5,0x3
    80001b9c:	d5878793          	addi	a5,a5,-680 # 800048f0 <kernelvec>
    80001ba0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ba4:	b78ff0ef          	jal	80000f1c <myproc>
    80001ba8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001baa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bac:	14102773          	csrr	a4,sepc
    80001bb0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bb2:	142029f3          	csrr	s3,scause
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bb6:	14302a73          	csrr	s4,stval
  if(scause == 8){
    80001bba:	47a1                	li	a5,8
    80001bbc:	04f98963          	beq	s3,a5,80001c0e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001bc0:	f4bff0ef          	jal	80001b0a <devintr>
    80001bc4:	892a                	mv	s2,a0
    80001bc6:	14051363          	bnez	a0,80001d0c <usertrap+0x18e>
  } else if(scause == 13 || scause == 15) { // load/store page fault
    80001bca:	ffd9f793          	andi	a5,s3,-3
    80001bce:	4735                	li	a4,13
    80001bd0:	08e78163          	beq	a5,a4,80001c52 <usertrap+0xd4>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bd4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001bd8:	5890                	lw	a2,48(s1)
    80001bda:	00005517          	auipc	a0,0x5
    80001bde:	78e50513          	addi	a0,a0,1934 # 80007368 <etext+0x368>
    80001be2:	7ce030ef          	jal	800053b0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001be6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bea:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001bee:	00005517          	auipc	a0,0x5
    80001bf2:	7aa50513          	addi	a0,a0,1962 # 80007398 <etext+0x398>
    80001bf6:	7ba030ef          	jal	800053b0 <printf>
    setkilled(p);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	b03ff0ef          	jal	800016fe <setkilled>
    80001c00:	a035                	j	80001c2c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001c02:	00005517          	auipc	a0,0x5
    80001c06:	6a650513          	addi	a0,a0,1702 # 800072a8 <etext+0x2a8>
    80001c0a:	279030ef          	jal	80005682 <panic>
    if(killed(p))
    80001c0e:	b15ff0ef          	jal	80001722 <killed>
    80001c12:	ed05                	bnez	a0,80001c4a <usertrap+0xcc>
    p->trapframe->epc += 4;
    80001c14:	6cb8                	ld	a4,88(s1)
    80001c16:	6f1c                	ld	a5,24(a4)
    80001c18:	0791                	addi	a5,a5,4
    80001c1a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001c20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c24:	10079073          	csrw	sstatus,a5
    syscall();
    80001c28:	2e4000ef          	jal	80001f0c <syscall>
  if(killed(p))
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	af5ff0ef          	jal	80001722 <killed>
    80001c32:	0e051263          	bnez	a0,80001d16 <usertrap+0x198>
  usertrapret();
    80001c36:	defff0ef          	jal	80001a24 <usertrapret>
}
    80001c3a:	70a2                	ld	ra,40(sp)
    80001c3c:	7402                	ld	s0,32(sp)
    80001c3e:	64e2                	ld	s1,24(sp)
    80001c40:	6942                	ld	s2,16(sp)
    80001c42:	69a2                	ld	s3,8(sp)
    80001c44:	6a02                	ld	s4,0(sp)
    80001c46:	6145                	addi	sp,sp,48
    80001c48:	8082                	ret
      exit(-1);
    80001c4a:	557d                	li	a0,-1
    80001c4c:	9abff0ef          	jal	800015f6 <exit>
    80001c50:	b7d1                	j	80001c14 <usertrap+0x96>
    pte_t *pte = walk(p->pagetable, stval, 0);
    80001c52:	4601                	li	a2,0
    80001c54:	85d2                	mv	a1,s4
    80001c56:	68a8                	ld	a0,80(s1)
    80001c58:	85ffe0ef          	jal	800004b6 <walk>
    if(pte == 0 || !(*pte & PTE_V) || !(*pte & PTE_U)) {
    80001c5c:	c901                	beqz	a0,80001c6c <usertrap+0xee>
    80001c5e:	00053903          	ld	s2,0(a0)
    80001c62:	01197713          	andi	a4,s2,17
    80001c66:	47c5                	li	a5,17
    80001c68:	00f70e63          	beq	a4,a5,80001c84 <usertrap+0x106>
      printf("usertrap(): page fault: invalid addr 0x%lx pid=%d\n", stval, p->pid);
    80001c6c:	5890                	lw	a2,48(s1)
    80001c6e:	85d2                	mv	a1,s4
    80001c70:	00005517          	auipc	a0,0x5
    80001c74:	65850513          	addi	a0,a0,1624 # 800072c8 <etext+0x2c8>
    80001c78:	738030ef          	jal	800053b0 <printf>
      setkilled(p);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	a81ff0ef          	jal	800016fe <setkilled>
    80001c82:	b76d                	j	80001c2c <usertrap+0xae>
    } else if((*pte & PTE_COW) && (scause == 15)) { // only on write fault
    80001c84:	10097793          	andi	a5,s2,256
    80001c88:	c781                	beqz	a5,80001c90 <usertrap+0x112>
    80001c8a:	47bd                	li	a5,15
    80001c8c:	00f98f63          	beq	s3,a5,80001caa <usertrap+0x12c>
      printf("usertrap(): unexpected page fault addr 0x%lx, scause=0x%lx, pte=0x%lx\n", stval, scause, *pte);
    80001c90:	86ca                	mv	a3,s2
    80001c92:	864e                	mv	a2,s3
    80001c94:	85d2                	mv	a1,s4
    80001c96:	00005517          	auipc	a0,0x5
    80001c9a:	68a50513          	addi	a0,a0,1674 # 80007320 <etext+0x320>
    80001c9e:	712030ef          	jal	800053b0 <printf>
      setkilled(p);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	a5bff0ef          	jal	800016fe <setkilled>
    80001ca8:	b751                	j	80001c2c <usertrap+0xae>
      if((mem = kalloc()) == 0){
    80001caa:	d2efe0ef          	jal	800001d8 <kalloc>
    80001cae:	89aa                	mv	s3,a0
    80001cb0:	c121                	beqz	a0,80001cf0 <usertrap+0x172>
      uint64 pa = PTE2PA(*pte);
    80001cb2:	00a95913          	srli	s2,s2,0xa
    80001cb6:	0932                	slli	s2,s2,0xc
        memmove(mem, (char*)pa, PGSIZE);
    80001cb8:	6605                	lui	a2,0x1
    80001cba:	85ca                	mv	a1,s2
    80001cbc:	de2fe0ef          	jal	8000029e <memmove>
        uvmunmap(p->pagetable, PGROUNDDOWN(stval), 1, 0); // don't free old page yet!
    80001cc0:	77fd                	lui	a5,0xfffff
    80001cc2:	00fa7a33          	and	s4,s4,a5
    80001cc6:	4681                	li	a3,0
    80001cc8:	4605                	li	a2,1
    80001cca:	85d2                	mv	a1,s4
    80001ccc:	68a8                	ld	a0,80(s1)
    80001cce:	a63fe0ef          	jal	80000730 <uvmunmap>
        if(mappages(p->pagetable, PGROUNDDOWN(stval), PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001cd2:	4779                	li	a4,30
    80001cd4:	86ce                	mv	a3,s3
    80001cd6:	6605                	lui	a2,0x1
    80001cd8:	85d2                	mv	a1,s4
    80001cda:	68a8                	ld	a0,80(s1)
    80001cdc:	8affe0ef          	jal	8000058a <mappages>
    80001ce0:	c115                	beqz	a0,80001d04 <usertrap+0x186>
          kfree(mem);
    80001ce2:	854e                	mv	a0,s3
    80001ce4:	bccfe0ef          	jal	800000b0 <kfree>
          setkilled(p);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	a15ff0ef          	jal	800016fe <setkilled>
    80001cee:	bf3d                	j	80001c2c <usertrap+0xae>
        printf("usertrap(): COW alloc failed\n");
    80001cf0:	00005517          	auipc	a0,0x5
    80001cf4:	61050513          	addi	a0,a0,1552 # 80007300 <etext+0x300>
    80001cf8:	6b8030ef          	jal	800053b0 <printf>
        setkilled(p);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	a01ff0ef          	jal	800016fe <setkilled>
    80001d02:	b72d                	j	80001c2c <usertrap+0xae>
          kfree((void*)pa); // CORRECT
    80001d04:	854a                	mv	a0,s2
    80001d06:	baafe0ef          	jal	800000b0 <kfree>
    80001d0a:	b70d                	j	80001c2c <usertrap+0xae>
  if(killed(p))
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	a15ff0ef          	jal	80001722 <killed>
    80001d12:	c511                	beqz	a0,80001d1e <usertrap+0x1a0>
    80001d14:	a011                	j	80001d18 <usertrap+0x19a>
    80001d16:	4901                	li	s2,0
    exit(-1);
    80001d18:	557d                	li	a0,-1
    80001d1a:	8ddff0ef          	jal	800015f6 <exit>
  if(which_dev == 2)
    80001d1e:	4789                	li	a5,2
    80001d20:	f0f91be3          	bne	s2,a5,80001c36 <usertrap+0xb8>
    yield();
    80001d24:	f9aff0ef          	jal	800014be <yield>
    80001d28:	b739                	j	80001c36 <usertrap+0xb8>

0000000080001d2a <kerneltrap>:
{
    80001d2a:	7179                	addi	sp,sp,-48
    80001d2c:	f406                	sd	ra,40(sp)
    80001d2e:	f022                	sd	s0,32(sp)
    80001d30:	ec26                	sd	s1,24(sp)
    80001d32:	e84a                	sd	s2,16(sp)
    80001d34:	e44e                	sd	s3,8(sp)
    80001d36:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d38:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d3c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d40:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001d44:	1004f793          	andi	a5,s1,256
    80001d48:	c795                	beqz	a5,80001d74 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d4e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001d50:	eb85                	bnez	a5,80001d80 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001d52:	db9ff0ef          	jal	80001b0a <devintr>
    80001d56:	c91d                	beqz	a0,80001d8c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001d58:	4789                	li	a5,2
    80001d5a:	04f50a63          	beq	a0,a5,80001dae <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d5e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d62:	10049073          	csrw	sstatus,s1
}
    80001d66:	70a2                	ld	ra,40(sp)
    80001d68:	7402                	ld	s0,32(sp)
    80001d6a:	64e2                	ld	s1,24(sp)
    80001d6c:	6942                	ld	s2,16(sp)
    80001d6e:	69a2                	ld	s3,8(sp)
    80001d70:	6145                	addi	sp,sp,48
    80001d72:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001d74:	00005517          	auipc	a0,0x5
    80001d78:	64c50513          	addi	a0,a0,1612 # 800073c0 <etext+0x3c0>
    80001d7c:	107030ef          	jal	80005682 <panic>
    panic("kerneltrap: interrupts enabled");
    80001d80:	00005517          	auipc	a0,0x5
    80001d84:	66850513          	addi	a0,a0,1640 # 800073e8 <etext+0x3e8>
    80001d88:	0fb030ef          	jal	80005682 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d8c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d90:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001d94:	85ce                	mv	a1,s3
    80001d96:	00005517          	auipc	a0,0x5
    80001d9a:	67250513          	addi	a0,a0,1650 # 80007408 <etext+0x408>
    80001d9e:	612030ef          	jal	800053b0 <printf>
    panic("kerneltrap");
    80001da2:	00005517          	auipc	a0,0x5
    80001da6:	68e50513          	addi	a0,a0,1678 # 80007430 <etext+0x430>
    80001daa:	0d9030ef          	jal	80005682 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001dae:	96eff0ef          	jal	80000f1c <myproc>
    80001db2:	d555                	beqz	a0,80001d5e <kerneltrap+0x34>
    yield();
    80001db4:	f0aff0ef          	jal	800014be <yield>
    80001db8:	b75d                	j	80001d5e <kerneltrap+0x34>

0000000080001dba <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001dba:	1101                	addi	sp,sp,-32
    80001dbc:	ec06                	sd	ra,24(sp)
    80001dbe:	e822                	sd	s0,16(sp)
    80001dc0:	e426                	sd	s1,8(sp)
    80001dc2:	1000                	addi	s0,sp,32
    80001dc4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dc6:	956ff0ef          	jal	80000f1c <myproc>
  switch (n) {
    80001dca:	4795                	li	a5,5
    80001dcc:	0497e163          	bltu	a5,s1,80001e0e <argraw+0x54>
    80001dd0:	048a                	slli	s1,s1,0x2
    80001dd2:	00006717          	auipc	a4,0x6
    80001dd6:	a6670713          	addi	a4,a4,-1434 # 80007838 <states.0+0x30>
    80001dda:	94ba                	add	s1,s1,a4
    80001ddc:	409c                	lw	a5,0(s1)
    80001dde:	97ba                	add	a5,a5,a4
    80001de0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001de2:	6d3c                	ld	a5,88(a0)
    80001de4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001de6:	60e2                	ld	ra,24(sp)
    80001de8:	6442                	ld	s0,16(sp)
    80001dea:	64a2                	ld	s1,8(sp)
    80001dec:	6105                	addi	sp,sp,32
    80001dee:	8082                	ret
    return p->trapframe->a1;
    80001df0:	6d3c                	ld	a5,88(a0)
    80001df2:	7fa8                	ld	a0,120(a5)
    80001df4:	bfcd                	j	80001de6 <argraw+0x2c>
    return p->trapframe->a2;
    80001df6:	6d3c                	ld	a5,88(a0)
    80001df8:	63c8                	ld	a0,128(a5)
    80001dfa:	b7f5                	j	80001de6 <argraw+0x2c>
    return p->trapframe->a3;
    80001dfc:	6d3c                	ld	a5,88(a0)
    80001dfe:	67c8                	ld	a0,136(a5)
    80001e00:	b7dd                	j	80001de6 <argraw+0x2c>
    return p->trapframe->a4;
    80001e02:	6d3c                	ld	a5,88(a0)
    80001e04:	6bc8                	ld	a0,144(a5)
    80001e06:	b7c5                	j	80001de6 <argraw+0x2c>
    return p->trapframe->a5;
    80001e08:	6d3c                	ld	a5,88(a0)
    80001e0a:	6fc8                	ld	a0,152(a5)
    80001e0c:	bfe9                	j	80001de6 <argraw+0x2c>
  panic("argraw");
    80001e0e:	00005517          	auipc	a0,0x5
    80001e12:	63250513          	addi	a0,a0,1586 # 80007440 <etext+0x440>
    80001e16:	06d030ef          	jal	80005682 <panic>

0000000080001e1a <fetchaddr>:
{
    80001e1a:	1101                	addi	sp,sp,-32
    80001e1c:	ec06                	sd	ra,24(sp)
    80001e1e:	e822                	sd	s0,16(sp)
    80001e20:	e426                	sd	s1,8(sp)
    80001e22:	e04a                	sd	s2,0(sp)
    80001e24:	1000                	addi	s0,sp,32
    80001e26:	84aa                	mv	s1,a0
    80001e28:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e2a:	8f2ff0ef          	jal	80000f1c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001e2e:	653c                	ld	a5,72(a0)
    80001e30:	02f4f663          	bgeu	s1,a5,80001e5c <fetchaddr+0x42>
    80001e34:	00848713          	addi	a4,s1,8
    80001e38:	02e7e463          	bltu	a5,a4,80001e60 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001e3c:	46a1                	li	a3,8
    80001e3e:	8626                	mv	a2,s1
    80001e40:	85ca                	mv	a1,s2
    80001e42:	6928                	ld	a0,80(a0)
    80001e44:	e21fe0ef          	jal	80000c64 <copyin>
    80001e48:	00a03533          	snez	a0,a0
    80001e4c:	40a00533          	neg	a0,a0
}
    80001e50:	60e2                	ld	ra,24(sp)
    80001e52:	6442                	ld	s0,16(sp)
    80001e54:	64a2                	ld	s1,8(sp)
    80001e56:	6902                	ld	s2,0(sp)
    80001e58:	6105                	addi	sp,sp,32
    80001e5a:	8082                	ret
    return -1;
    80001e5c:	557d                	li	a0,-1
    80001e5e:	bfcd                	j	80001e50 <fetchaddr+0x36>
    80001e60:	557d                	li	a0,-1
    80001e62:	b7fd                	j	80001e50 <fetchaddr+0x36>

0000000080001e64 <fetchstr>:
{
    80001e64:	7179                	addi	sp,sp,-48
    80001e66:	f406                	sd	ra,40(sp)
    80001e68:	f022                	sd	s0,32(sp)
    80001e6a:	ec26                	sd	s1,24(sp)
    80001e6c:	e84a                	sd	s2,16(sp)
    80001e6e:	e44e                	sd	s3,8(sp)
    80001e70:	1800                	addi	s0,sp,48
    80001e72:	892a                	mv	s2,a0
    80001e74:	84ae                	mv	s1,a1
    80001e76:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001e78:	8a4ff0ef          	jal	80000f1c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001e7c:	86ce                	mv	a3,s3
    80001e7e:	864a                	mv	a2,s2
    80001e80:	85a6                	mv	a1,s1
    80001e82:	6928                	ld	a0,80(a0)
    80001e84:	e67fe0ef          	jal	80000cea <copyinstr>
    80001e88:	00054c63          	bltz	a0,80001ea0 <fetchstr+0x3c>
  return strlen(buf);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	d24fe0ef          	jal	800003b2 <strlen>
}
    80001e92:	70a2                	ld	ra,40(sp)
    80001e94:	7402                	ld	s0,32(sp)
    80001e96:	64e2                	ld	s1,24(sp)
    80001e98:	6942                	ld	s2,16(sp)
    80001e9a:	69a2                	ld	s3,8(sp)
    80001e9c:	6145                	addi	sp,sp,48
    80001e9e:	8082                	ret
    return -1;
    80001ea0:	557d                	li	a0,-1
    80001ea2:	bfc5                	j	80001e92 <fetchstr+0x2e>

0000000080001ea4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001ea4:	1101                	addi	sp,sp,-32
    80001ea6:	ec06                	sd	ra,24(sp)
    80001ea8:	e822                	sd	s0,16(sp)
    80001eaa:	e426                	sd	s1,8(sp)
    80001eac:	1000                	addi	s0,sp,32
    80001eae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001eb0:	f0bff0ef          	jal	80001dba <argraw>
    80001eb4:	c088                	sw	a0,0(s1)
}
    80001eb6:	60e2                	ld	ra,24(sp)
    80001eb8:	6442                	ld	s0,16(sp)
    80001eba:	64a2                	ld	s1,8(sp)
    80001ebc:	6105                	addi	sp,sp,32
    80001ebe:	8082                	ret

0000000080001ec0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001ec0:	1101                	addi	sp,sp,-32
    80001ec2:	ec06                	sd	ra,24(sp)
    80001ec4:	e822                	sd	s0,16(sp)
    80001ec6:	e426                	sd	s1,8(sp)
    80001ec8:	1000                	addi	s0,sp,32
    80001eca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ecc:	eefff0ef          	jal	80001dba <argraw>
    80001ed0:	e088                	sd	a0,0(s1)
}
    80001ed2:	60e2                	ld	ra,24(sp)
    80001ed4:	6442                	ld	s0,16(sp)
    80001ed6:	64a2                	ld	s1,8(sp)
    80001ed8:	6105                	addi	sp,sp,32
    80001eda:	8082                	ret

0000000080001edc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001edc:	7179                	addi	sp,sp,-48
    80001ede:	f406                	sd	ra,40(sp)
    80001ee0:	f022                	sd	s0,32(sp)
    80001ee2:	ec26                	sd	s1,24(sp)
    80001ee4:	e84a                	sd	s2,16(sp)
    80001ee6:	1800                	addi	s0,sp,48
    80001ee8:	84ae                	mv	s1,a1
    80001eea:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001eec:	fd840593          	addi	a1,s0,-40
    80001ef0:	fd1ff0ef          	jal	80001ec0 <argaddr>
  return fetchstr(addr, buf, max);
    80001ef4:	864a                	mv	a2,s2
    80001ef6:	85a6                	mv	a1,s1
    80001ef8:	fd843503          	ld	a0,-40(s0)
    80001efc:	f69ff0ef          	jal	80001e64 <fetchstr>
}
    80001f00:	70a2                	ld	ra,40(sp)
    80001f02:	7402                	ld	s0,32(sp)
    80001f04:	64e2                	ld	s1,24(sp)
    80001f06:	6942                	ld	s2,16(sp)
    80001f08:	6145                	addi	sp,sp,48
    80001f0a:	8082                	ret

0000000080001f0c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80001f0c:	1101                	addi	sp,sp,-32
    80001f0e:	ec06                	sd	ra,24(sp)
    80001f10:	e822                	sd	s0,16(sp)
    80001f12:	e426                	sd	s1,8(sp)
    80001f14:	e04a                	sd	s2,0(sp)
    80001f16:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001f18:	804ff0ef          	jal	80000f1c <myproc>
    80001f1c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001f1e:	05853903          	ld	s2,88(a0)
    80001f22:	0a893783          	ld	a5,168(s2)
    80001f26:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001f2a:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffbb93f>
    80001f2c:	4751                	li	a4,20
    80001f2e:	00f76f63          	bltu	a4,a5,80001f4c <syscall+0x40>
    80001f32:	00369713          	slli	a4,a3,0x3
    80001f36:	00006797          	auipc	a5,0x6
    80001f3a:	91a78793          	addi	a5,a5,-1766 # 80007850 <syscalls>
    80001f3e:	97ba                	add	a5,a5,a4
    80001f40:	639c                	ld	a5,0(a5)
    80001f42:	c789                	beqz	a5,80001f4c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001f44:	9782                	jalr	a5
    80001f46:	06a93823          	sd	a0,112(s2)
    80001f4a:	a829                	j	80001f64 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001f4c:	15848613          	addi	a2,s1,344
    80001f50:	588c                	lw	a1,48(s1)
    80001f52:	00005517          	auipc	a0,0x5
    80001f56:	4f650513          	addi	a0,a0,1270 # 80007448 <etext+0x448>
    80001f5a:	456030ef          	jal	800053b0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001f5e:	6cbc                	ld	a5,88(s1)
    80001f60:	577d                	li	a4,-1
    80001f62:	fbb8                	sd	a4,112(a5)
  }
}
    80001f64:	60e2                	ld	ra,24(sp)
    80001f66:	6442                	ld	s0,16(sp)
    80001f68:	64a2                	ld	s1,8(sp)
    80001f6a:	6902                	ld	s2,0(sp)
    80001f6c:	6105                	addi	sp,sp,32
    80001f6e:	8082                	ret

0000000080001f70 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001f70:	1101                	addi	sp,sp,-32
    80001f72:	ec06                	sd	ra,24(sp)
    80001f74:	e822                	sd	s0,16(sp)
    80001f76:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001f78:	fec40593          	addi	a1,s0,-20
    80001f7c:	4501                	li	a0,0
    80001f7e:	f27ff0ef          	jal	80001ea4 <argint>
  exit(n);
    80001f82:	fec42503          	lw	a0,-20(s0)
    80001f86:	e70ff0ef          	jal	800015f6 <exit>
  return 0;  // not reached
}
    80001f8a:	4501                	li	a0,0
    80001f8c:	60e2                	ld	ra,24(sp)
    80001f8e:	6442                	ld	s0,16(sp)
    80001f90:	6105                	addi	sp,sp,32
    80001f92:	8082                	ret

0000000080001f94 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001f94:	1141                	addi	sp,sp,-16
    80001f96:	e406                	sd	ra,8(sp)
    80001f98:	e022                	sd	s0,0(sp)
    80001f9a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001f9c:	f81fe0ef          	jal	80000f1c <myproc>
}
    80001fa0:	5908                	lw	a0,48(a0)
    80001fa2:	60a2                	ld	ra,8(sp)
    80001fa4:	6402                	ld	s0,0(sp)
    80001fa6:	0141                	addi	sp,sp,16
    80001fa8:	8082                	ret

0000000080001faa <sys_fork>:

uint64
sys_fork(void)
{
    80001faa:	1141                	addi	sp,sp,-16
    80001fac:	e406                	sd	ra,8(sp)
    80001fae:	e022                	sd	s0,0(sp)
    80001fb0:	0800                	addi	s0,sp,16
  return fork();
    80001fb2:	a90ff0ef          	jal	80001242 <fork>
}
    80001fb6:	60a2                	ld	ra,8(sp)
    80001fb8:	6402                	ld	s0,0(sp)
    80001fba:	0141                	addi	sp,sp,16
    80001fbc:	8082                	ret

0000000080001fbe <sys_wait>:

uint64
sys_wait(void)
{
    80001fbe:	1101                	addi	sp,sp,-32
    80001fc0:	ec06                	sd	ra,24(sp)
    80001fc2:	e822                	sd	s0,16(sp)
    80001fc4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001fc6:	fe840593          	addi	a1,s0,-24
    80001fca:	4501                	li	a0,0
    80001fcc:	ef5ff0ef          	jal	80001ec0 <argaddr>
  return wait(p);
    80001fd0:	fe843503          	ld	a0,-24(s0)
    80001fd4:	f78ff0ef          	jal	8000174c <wait>
}
    80001fd8:	60e2                	ld	ra,24(sp)
    80001fda:	6442                	ld	s0,16(sp)
    80001fdc:	6105                	addi	sp,sp,32
    80001fde:	8082                	ret

0000000080001fe0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001fe0:	7179                	addi	sp,sp,-48
    80001fe2:	f406                	sd	ra,40(sp)
    80001fe4:	f022                	sd	s0,32(sp)
    80001fe6:	ec26                	sd	s1,24(sp)
    80001fe8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001fea:	fdc40593          	addi	a1,s0,-36
    80001fee:	4501                	li	a0,0
    80001ff0:	eb5ff0ef          	jal	80001ea4 <argint>
  addr = myproc()->sz;
    80001ff4:	f29fe0ef          	jal	80000f1c <myproc>
    80001ff8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001ffa:	fdc42503          	lw	a0,-36(s0)
    80001ffe:	9f4ff0ef          	jal	800011f2 <growproc>
    80002002:	00054863          	bltz	a0,80002012 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002006:	8526                	mv	a0,s1
    80002008:	70a2                	ld	ra,40(sp)
    8000200a:	7402                	ld	s0,32(sp)
    8000200c:	64e2                	ld	s1,24(sp)
    8000200e:	6145                	addi	sp,sp,48
    80002010:	8082                	ret
    return -1;
    80002012:	54fd                	li	s1,-1
    80002014:	bfcd                	j	80002006 <sys_sbrk+0x26>

0000000080002016 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002016:	7139                	addi	sp,sp,-64
    80002018:	fc06                	sd	ra,56(sp)
    8000201a:	f822                	sd	s0,48(sp)
    8000201c:	f04a                	sd	s2,32(sp)
    8000201e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002020:	fcc40593          	addi	a1,s0,-52
    80002024:	4501                	li	a0,0
    80002026:	e7fff0ef          	jal	80001ea4 <argint>
  if(n < 0)
    8000202a:	fcc42783          	lw	a5,-52(s0)
    8000202e:	0607c763          	bltz	a5,8000209c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002032:	0002e517          	auipc	a0,0x2e
    80002036:	1ae50513          	addi	a0,a0,430 # 800301e0 <tickslock>
    8000203a:	177030ef          	jal	800059b0 <acquire>
  ticks0 = ticks;
    8000203e:	00008917          	auipc	s2,0x8
    80002042:	33a92903          	lw	s2,826(s2) # 8000a378 <ticks>
  while(ticks - ticks0 < n){
    80002046:	fcc42783          	lw	a5,-52(s0)
    8000204a:	cf8d                	beqz	a5,80002084 <sys_sleep+0x6e>
    8000204c:	f426                	sd	s1,40(sp)
    8000204e:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002050:	0002e997          	auipc	s3,0x2e
    80002054:	19098993          	addi	s3,s3,400 # 800301e0 <tickslock>
    80002058:	00008497          	auipc	s1,0x8
    8000205c:	32048493          	addi	s1,s1,800 # 8000a378 <ticks>
    if(killed(myproc())){
    80002060:	ebdfe0ef          	jal	80000f1c <myproc>
    80002064:	ebeff0ef          	jal	80001722 <killed>
    80002068:	ed0d                	bnez	a0,800020a2 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000206a:	85ce                	mv	a1,s3
    8000206c:	8526                	mv	a0,s1
    8000206e:	c7cff0ef          	jal	800014ea <sleep>
  while(ticks - ticks0 < n){
    80002072:	409c                	lw	a5,0(s1)
    80002074:	412787bb          	subw	a5,a5,s2
    80002078:	fcc42703          	lw	a4,-52(s0)
    8000207c:	fee7e2e3          	bltu	a5,a4,80002060 <sys_sleep+0x4a>
    80002080:	74a2                	ld	s1,40(sp)
    80002082:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002084:	0002e517          	auipc	a0,0x2e
    80002088:	15c50513          	addi	a0,a0,348 # 800301e0 <tickslock>
    8000208c:	1bd030ef          	jal	80005a48 <release>
  return 0;
    80002090:	4501                	li	a0,0
}
    80002092:	70e2                	ld	ra,56(sp)
    80002094:	7442                	ld	s0,48(sp)
    80002096:	7902                	ld	s2,32(sp)
    80002098:	6121                	addi	sp,sp,64
    8000209a:	8082                	ret
    n = 0;
    8000209c:	fc042623          	sw	zero,-52(s0)
    800020a0:	bf49                	j	80002032 <sys_sleep+0x1c>
      release(&tickslock);
    800020a2:	0002e517          	auipc	a0,0x2e
    800020a6:	13e50513          	addi	a0,a0,318 # 800301e0 <tickslock>
    800020aa:	19f030ef          	jal	80005a48 <release>
      return -1;
    800020ae:	557d                	li	a0,-1
    800020b0:	74a2                	ld	s1,40(sp)
    800020b2:	69e2                	ld	s3,24(sp)
    800020b4:	bff9                	j	80002092 <sys_sleep+0x7c>

00000000800020b6 <sys_kill>:

uint64
sys_kill(void)
{
    800020b6:	1101                	addi	sp,sp,-32
    800020b8:	ec06                	sd	ra,24(sp)
    800020ba:	e822                	sd	s0,16(sp)
    800020bc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800020be:	fec40593          	addi	a1,s0,-20
    800020c2:	4501                	li	a0,0
    800020c4:	de1ff0ef          	jal	80001ea4 <argint>
  return kill(pid);
    800020c8:	fec42503          	lw	a0,-20(s0)
    800020cc:	dccff0ef          	jal	80001698 <kill>
}
    800020d0:	60e2                	ld	ra,24(sp)
    800020d2:	6442                	ld	s0,16(sp)
    800020d4:	6105                	addi	sp,sp,32
    800020d6:	8082                	ret

00000000800020d8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800020d8:	1101                	addi	sp,sp,-32
    800020da:	ec06                	sd	ra,24(sp)
    800020dc:	e822                	sd	s0,16(sp)
    800020de:	e426                	sd	s1,8(sp)
    800020e0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800020e2:	0002e517          	auipc	a0,0x2e
    800020e6:	0fe50513          	addi	a0,a0,254 # 800301e0 <tickslock>
    800020ea:	0c7030ef          	jal	800059b0 <acquire>
  xticks = ticks;
    800020ee:	00008497          	auipc	s1,0x8
    800020f2:	28a4a483          	lw	s1,650(s1) # 8000a378 <ticks>
  release(&tickslock);
    800020f6:	0002e517          	auipc	a0,0x2e
    800020fa:	0ea50513          	addi	a0,a0,234 # 800301e0 <tickslock>
    800020fe:	14b030ef          	jal	80005a48 <release>
  return xticks;
}
    80002102:	02049513          	slli	a0,s1,0x20
    80002106:	9101                	srli	a0,a0,0x20
    80002108:	60e2                	ld	ra,24(sp)
    8000210a:	6442                	ld	s0,16(sp)
    8000210c:	64a2                	ld	s1,8(sp)
    8000210e:	6105                	addi	sp,sp,32
    80002110:	8082                	ret

0000000080002112 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002112:	7179                	addi	sp,sp,-48
    80002114:	f406                	sd	ra,40(sp)
    80002116:	f022                	sd	s0,32(sp)
    80002118:	ec26                	sd	s1,24(sp)
    8000211a:	e84a                	sd	s2,16(sp)
    8000211c:	e44e                	sd	s3,8(sp)
    8000211e:	e052                	sd	s4,0(sp)
    80002120:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002122:	00005597          	auipc	a1,0x5
    80002126:	34658593          	addi	a1,a1,838 # 80007468 <etext+0x468>
    8000212a:	0002e517          	auipc	a0,0x2e
    8000212e:	0ce50513          	addi	a0,a0,206 # 800301f8 <bcache>
    80002132:	7fe030ef          	jal	80005930 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002136:	00036797          	auipc	a5,0x36
    8000213a:	0c278793          	addi	a5,a5,194 # 800381f8 <bcache+0x8000>
    8000213e:	00036717          	auipc	a4,0x36
    80002142:	32270713          	addi	a4,a4,802 # 80038460 <bcache+0x8268>
    80002146:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000214a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000214e:	0002e497          	auipc	s1,0x2e
    80002152:	0c248493          	addi	s1,s1,194 # 80030210 <bcache+0x18>
    b->next = bcache.head.next;
    80002156:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002158:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000215a:	00005a17          	auipc	s4,0x5
    8000215e:	316a0a13          	addi	s4,s4,790 # 80007470 <etext+0x470>
    b->next = bcache.head.next;
    80002162:	2b893783          	ld	a5,696(s2)
    80002166:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002168:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000216c:	85d2                	mv	a1,s4
    8000216e:	01048513          	addi	a0,s1,16
    80002172:	248010ef          	jal	800033ba <initsleeplock>
    bcache.head.next->prev = b;
    80002176:	2b893783          	ld	a5,696(s2)
    8000217a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000217c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002180:	45848493          	addi	s1,s1,1112
    80002184:	fd349fe3          	bne	s1,s3,80002162 <binit+0x50>
  }
}
    80002188:	70a2                	ld	ra,40(sp)
    8000218a:	7402                	ld	s0,32(sp)
    8000218c:	64e2                	ld	s1,24(sp)
    8000218e:	6942                	ld	s2,16(sp)
    80002190:	69a2                	ld	s3,8(sp)
    80002192:	6a02                	ld	s4,0(sp)
    80002194:	6145                	addi	sp,sp,48
    80002196:	8082                	ret

0000000080002198 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002198:	7179                	addi	sp,sp,-48
    8000219a:	f406                	sd	ra,40(sp)
    8000219c:	f022                	sd	s0,32(sp)
    8000219e:	ec26                	sd	s1,24(sp)
    800021a0:	e84a                	sd	s2,16(sp)
    800021a2:	e44e                	sd	s3,8(sp)
    800021a4:	1800                	addi	s0,sp,48
    800021a6:	892a                	mv	s2,a0
    800021a8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800021aa:	0002e517          	auipc	a0,0x2e
    800021ae:	04e50513          	addi	a0,a0,78 # 800301f8 <bcache>
    800021b2:	7fe030ef          	jal	800059b0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800021b6:	00036497          	auipc	s1,0x36
    800021ba:	2fa4b483          	ld	s1,762(s1) # 800384b0 <bcache+0x82b8>
    800021be:	00036797          	auipc	a5,0x36
    800021c2:	2a278793          	addi	a5,a5,674 # 80038460 <bcache+0x8268>
    800021c6:	02f48b63          	beq	s1,a5,800021fc <bread+0x64>
    800021ca:	873e                	mv	a4,a5
    800021cc:	a021                	j	800021d4 <bread+0x3c>
    800021ce:	68a4                	ld	s1,80(s1)
    800021d0:	02e48663          	beq	s1,a4,800021fc <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800021d4:	449c                	lw	a5,8(s1)
    800021d6:	ff279ce3          	bne	a5,s2,800021ce <bread+0x36>
    800021da:	44dc                	lw	a5,12(s1)
    800021dc:	ff3799e3          	bne	a5,s3,800021ce <bread+0x36>
      b->refcnt++;
    800021e0:	40bc                	lw	a5,64(s1)
    800021e2:	2785                	addiw	a5,a5,1
    800021e4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800021e6:	0002e517          	auipc	a0,0x2e
    800021ea:	01250513          	addi	a0,a0,18 # 800301f8 <bcache>
    800021ee:	05b030ef          	jal	80005a48 <release>
      acquiresleep(&b->lock);
    800021f2:	01048513          	addi	a0,s1,16
    800021f6:	1fa010ef          	jal	800033f0 <acquiresleep>
      return b;
    800021fa:	a889                	j	8000224c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800021fc:	00036497          	auipc	s1,0x36
    80002200:	2ac4b483          	ld	s1,684(s1) # 800384a8 <bcache+0x82b0>
    80002204:	00036797          	auipc	a5,0x36
    80002208:	25c78793          	addi	a5,a5,604 # 80038460 <bcache+0x8268>
    8000220c:	00f48863          	beq	s1,a5,8000221c <bread+0x84>
    80002210:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002212:	40bc                	lw	a5,64(s1)
    80002214:	cb91                	beqz	a5,80002228 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002216:	64a4                	ld	s1,72(s1)
    80002218:	fee49de3          	bne	s1,a4,80002212 <bread+0x7a>
  panic("bget: no buffers");
    8000221c:	00005517          	auipc	a0,0x5
    80002220:	25c50513          	addi	a0,a0,604 # 80007478 <etext+0x478>
    80002224:	45e030ef          	jal	80005682 <panic>
      b->dev = dev;
    80002228:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000222c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002230:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002234:	4785                	li	a5,1
    80002236:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002238:	0002e517          	auipc	a0,0x2e
    8000223c:	fc050513          	addi	a0,a0,-64 # 800301f8 <bcache>
    80002240:	009030ef          	jal	80005a48 <release>
      acquiresleep(&b->lock);
    80002244:	01048513          	addi	a0,s1,16
    80002248:	1a8010ef          	jal	800033f0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000224c:	409c                	lw	a5,0(s1)
    8000224e:	cb89                	beqz	a5,80002260 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002250:	8526                	mv	a0,s1
    80002252:	70a2                	ld	ra,40(sp)
    80002254:	7402                	ld	s0,32(sp)
    80002256:	64e2                	ld	s1,24(sp)
    80002258:	6942                	ld	s2,16(sp)
    8000225a:	69a2                	ld	s3,8(sp)
    8000225c:	6145                	addi	sp,sp,48
    8000225e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002260:	4581                	li	a1,0
    80002262:	8526                	mv	a0,s1
    80002264:	1ed020ef          	jal	80004c50 <virtio_disk_rw>
    b->valid = 1;
    80002268:	4785                	li	a5,1
    8000226a:	c09c                	sw	a5,0(s1)
  return b;
    8000226c:	b7d5                	j	80002250 <bread+0xb8>

000000008000226e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000226e:	1101                	addi	sp,sp,-32
    80002270:	ec06                	sd	ra,24(sp)
    80002272:	e822                	sd	s0,16(sp)
    80002274:	e426                	sd	s1,8(sp)
    80002276:	1000                	addi	s0,sp,32
    80002278:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000227a:	0541                	addi	a0,a0,16
    8000227c:	1f2010ef          	jal	8000346e <holdingsleep>
    80002280:	c911                	beqz	a0,80002294 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002282:	4585                	li	a1,1
    80002284:	8526                	mv	a0,s1
    80002286:	1cb020ef          	jal	80004c50 <virtio_disk_rw>
}
    8000228a:	60e2                	ld	ra,24(sp)
    8000228c:	6442                	ld	s0,16(sp)
    8000228e:	64a2                	ld	s1,8(sp)
    80002290:	6105                	addi	sp,sp,32
    80002292:	8082                	ret
    panic("bwrite");
    80002294:	00005517          	auipc	a0,0x5
    80002298:	1fc50513          	addi	a0,a0,508 # 80007490 <etext+0x490>
    8000229c:	3e6030ef          	jal	80005682 <panic>

00000000800022a0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800022a0:	1101                	addi	sp,sp,-32
    800022a2:	ec06                	sd	ra,24(sp)
    800022a4:	e822                	sd	s0,16(sp)
    800022a6:	e426                	sd	s1,8(sp)
    800022a8:	e04a                	sd	s2,0(sp)
    800022aa:	1000                	addi	s0,sp,32
    800022ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022ae:	01050913          	addi	s2,a0,16
    800022b2:	854a                	mv	a0,s2
    800022b4:	1ba010ef          	jal	8000346e <holdingsleep>
    800022b8:	c135                	beqz	a0,8000231c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800022ba:	854a                	mv	a0,s2
    800022bc:	17a010ef          	jal	80003436 <releasesleep>

  acquire(&bcache.lock);
    800022c0:	0002e517          	auipc	a0,0x2e
    800022c4:	f3850513          	addi	a0,a0,-200 # 800301f8 <bcache>
    800022c8:	6e8030ef          	jal	800059b0 <acquire>
  b->refcnt--;
    800022cc:	40bc                	lw	a5,64(s1)
    800022ce:	37fd                	addiw	a5,a5,-1
    800022d0:	0007871b          	sext.w	a4,a5
    800022d4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800022d6:	e71d                	bnez	a4,80002304 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800022d8:	68b8                	ld	a4,80(s1)
    800022da:	64bc                	ld	a5,72(s1)
    800022dc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800022de:	68b8                	ld	a4,80(s1)
    800022e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800022e2:	00036797          	auipc	a5,0x36
    800022e6:	f1678793          	addi	a5,a5,-234 # 800381f8 <bcache+0x8000>
    800022ea:	2b87b703          	ld	a4,696(a5)
    800022ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800022f0:	00036717          	auipc	a4,0x36
    800022f4:	17070713          	addi	a4,a4,368 # 80038460 <bcache+0x8268>
    800022f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800022fa:	2b87b703          	ld	a4,696(a5)
    800022fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002300:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002304:	0002e517          	auipc	a0,0x2e
    80002308:	ef450513          	addi	a0,a0,-268 # 800301f8 <bcache>
    8000230c:	73c030ef          	jal	80005a48 <release>
}
    80002310:	60e2                	ld	ra,24(sp)
    80002312:	6442                	ld	s0,16(sp)
    80002314:	64a2                	ld	s1,8(sp)
    80002316:	6902                	ld	s2,0(sp)
    80002318:	6105                	addi	sp,sp,32
    8000231a:	8082                	ret
    panic("brelse");
    8000231c:	00005517          	auipc	a0,0x5
    80002320:	17c50513          	addi	a0,a0,380 # 80007498 <etext+0x498>
    80002324:	35e030ef          	jal	80005682 <panic>

0000000080002328 <bpin>:

void
bpin(struct buf *b) {
    80002328:	1101                	addi	sp,sp,-32
    8000232a:	ec06                	sd	ra,24(sp)
    8000232c:	e822                	sd	s0,16(sp)
    8000232e:	e426                	sd	s1,8(sp)
    80002330:	1000                	addi	s0,sp,32
    80002332:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002334:	0002e517          	auipc	a0,0x2e
    80002338:	ec450513          	addi	a0,a0,-316 # 800301f8 <bcache>
    8000233c:	674030ef          	jal	800059b0 <acquire>
  b->refcnt++;
    80002340:	40bc                	lw	a5,64(s1)
    80002342:	2785                	addiw	a5,a5,1
    80002344:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002346:	0002e517          	auipc	a0,0x2e
    8000234a:	eb250513          	addi	a0,a0,-334 # 800301f8 <bcache>
    8000234e:	6fa030ef          	jal	80005a48 <release>
}
    80002352:	60e2                	ld	ra,24(sp)
    80002354:	6442                	ld	s0,16(sp)
    80002356:	64a2                	ld	s1,8(sp)
    80002358:	6105                	addi	sp,sp,32
    8000235a:	8082                	ret

000000008000235c <bunpin>:

void
bunpin(struct buf *b) {
    8000235c:	1101                	addi	sp,sp,-32
    8000235e:	ec06                	sd	ra,24(sp)
    80002360:	e822                	sd	s0,16(sp)
    80002362:	e426                	sd	s1,8(sp)
    80002364:	1000                	addi	s0,sp,32
    80002366:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002368:	0002e517          	auipc	a0,0x2e
    8000236c:	e9050513          	addi	a0,a0,-368 # 800301f8 <bcache>
    80002370:	640030ef          	jal	800059b0 <acquire>
  b->refcnt--;
    80002374:	40bc                	lw	a5,64(s1)
    80002376:	37fd                	addiw	a5,a5,-1
    80002378:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000237a:	0002e517          	auipc	a0,0x2e
    8000237e:	e7e50513          	addi	a0,a0,-386 # 800301f8 <bcache>
    80002382:	6c6030ef          	jal	80005a48 <release>
}
    80002386:	60e2                	ld	ra,24(sp)
    80002388:	6442                	ld	s0,16(sp)
    8000238a:	64a2                	ld	s1,8(sp)
    8000238c:	6105                	addi	sp,sp,32
    8000238e:	8082                	ret

0000000080002390 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002390:	1101                	addi	sp,sp,-32
    80002392:	ec06                	sd	ra,24(sp)
    80002394:	e822                	sd	s0,16(sp)
    80002396:	e426                	sd	s1,8(sp)
    80002398:	e04a                	sd	s2,0(sp)
    8000239a:	1000                	addi	s0,sp,32
    8000239c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000239e:	00d5d59b          	srliw	a1,a1,0xd
    800023a2:	00036797          	auipc	a5,0x36
    800023a6:	5327a783          	lw	a5,1330(a5) # 800388d4 <sb+0x1c>
    800023aa:	9dbd                	addw	a1,a1,a5
    800023ac:	dedff0ef          	jal	80002198 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800023b0:	0074f713          	andi	a4,s1,7
    800023b4:	4785                	li	a5,1
    800023b6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800023ba:	14ce                	slli	s1,s1,0x33
    800023bc:	90d9                	srli	s1,s1,0x36
    800023be:	00950733          	add	a4,a0,s1
    800023c2:	05874703          	lbu	a4,88(a4)
    800023c6:	00e7f6b3          	and	a3,a5,a4
    800023ca:	c29d                	beqz	a3,800023f0 <bfree+0x60>
    800023cc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800023ce:	94aa                	add	s1,s1,a0
    800023d0:	fff7c793          	not	a5,a5
    800023d4:	8f7d                	and	a4,a4,a5
    800023d6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800023da:	711000ef          	jal	800032ea <log_write>
  brelse(bp);
    800023de:	854a                	mv	a0,s2
    800023e0:	ec1ff0ef          	jal	800022a0 <brelse>
}
    800023e4:	60e2                	ld	ra,24(sp)
    800023e6:	6442                	ld	s0,16(sp)
    800023e8:	64a2                	ld	s1,8(sp)
    800023ea:	6902                	ld	s2,0(sp)
    800023ec:	6105                	addi	sp,sp,32
    800023ee:	8082                	ret
    panic("freeing free block");
    800023f0:	00005517          	auipc	a0,0x5
    800023f4:	0b050513          	addi	a0,a0,176 # 800074a0 <etext+0x4a0>
    800023f8:	28a030ef          	jal	80005682 <panic>

00000000800023fc <balloc>:
{
    800023fc:	711d                	addi	sp,sp,-96
    800023fe:	ec86                	sd	ra,88(sp)
    80002400:	e8a2                	sd	s0,80(sp)
    80002402:	e4a6                	sd	s1,72(sp)
    80002404:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002406:	00036797          	auipc	a5,0x36
    8000240a:	4b67a783          	lw	a5,1206(a5) # 800388bc <sb+0x4>
    8000240e:	0e078f63          	beqz	a5,8000250c <balloc+0x110>
    80002412:	e0ca                	sd	s2,64(sp)
    80002414:	fc4e                	sd	s3,56(sp)
    80002416:	f852                	sd	s4,48(sp)
    80002418:	f456                	sd	s5,40(sp)
    8000241a:	f05a                	sd	s6,32(sp)
    8000241c:	ec5e                	sd	s7,24(sp)
    8000241e:	e862                	sd	s8,16(sp)
    80002420:	e466                	sd	s9,8(sp)
    80002422:	8baa                	mv	s7,a0
    80002424:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002426:	00036b17          	auipc	s6,0x36
    8000242a:	492b0b13          	addi	s6,s6,1170 # 800388b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000242e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002430:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002432:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002434:	6c89                	lui	s9,0x2
    80002436:	a0b5                	j	800024a2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002438:	97ca                	add	a5,a5,s2
    8000243a:	8e55                	or	a2,a2,a3
    8000243c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002440:	854a                	mv	a0,s2
    80002442:	6a9000ef          	jal	800032ea <log_write>
        brelse(bp);
    80002446:	854a                	mv	a0,s2
    80002448:	e59ff0ef          	jal	800022a0 <brelse>
  bp = bread(dev, bno);
    8000244c:	85a6                	mv	a1,s1
    8000244e:	855e                	mv	a0,s7
    80002450:	d49ff0ef          	jal	80002198 <bread>
    80002454:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002456:	40000613          	li	a2,1024
    8000245a:	4581                	li	a1,0
    8000245c:	05850513          	addi	a0,a0,88
    80002460:	de3fd0ef          	jal	80000242 <memset>
  log_write(bp);
    80002464:	854a                	mv	a0,s2
    80002466:	685000ef          	jal	800032ea <log_write>
  brelse(bp);
    8000246a:	854a                	mv	a0,s2
    8000246c:	e35ff0ef          	jal	800022a0 <brelse>
}
    80002470:	6906                	ld	s2,64(sp)
    80002472:	79e2                	ld	s3,56(sp)
    80002474:	7a42                	ld	s4,48(sp)
    80002476:	7aa2                	ld	s5,40(sp)
    80002478:	7b02                	ld	s6,32(sp)
    8000247a:	6be2                	ld	s7,24(sp)
    8000247c:	6c42                	ld	s8,16(sp)
    8000247e:	6ca2                	ld	s9,8(sp)
}
    80002480:	8526                	mv	a0,s1
    80002482:	60e6                	ld	ra,88(sp)
    80002484:	6446                	ld	s0,80(sp)
    80002486:	64a6                	ld	s1,72(sp)
    80002488:	6125                	addi	sp,sp,96
    8000248a:	8082                	ret
    brelse(bp);
    8000248c:	854a                	mv	a0,s2
    8000248e:	e13ff0ef          	jal	800022a0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002492:	015c87bb          	addw	a5,s9,s5
    80002496:	00078a9b          	sext.w	s5,a5
    8000249a:	004b2703          	lw	a4,4(s6)
    8000249e:	04eaff63          	bgeu	s5,a4,800024fc <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800024a2:	41fad79b          	sraiw	a5,s5,0x1f
    800024a6:	0137d79b          	srliw	a5,a5,0x13
    800024aa:	015787bb          	addw	a5,a5,s5
    800024ae:	40d7d79b          	sraiw	a5,a5,0xd
    800024b2:	01cb2583          	lw	a1,28(s6)
    800024b6:	9dbd                	addw	a1,a1,a5
    800024b8:	855e                	mv	a0,s7
    800024ba:	cdfff0ef          	jal	80002198 <bread>
    800024be:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024c0:	004b2503          	lw	a0,4(s6)
    800024c4:	000a849b          	sext.w	s1,s5
    800024c8:	8762                	mv	a4,s8
    800024ca:	fca4f1e3          	bgeu	s1,a0,8000248c <balloc+0x90>
      m = 1 << (bi % 8);
    800024ce:	00777693          	andi	a3,a4,7
    800024d2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800024d6:	41f7579b          	sraiw	a5,a4,0x1f
    800024da:	01d7d79b          	srliw	a5,a5,0x1d
    800024de:	9fb9                	addw	a5,a5,a4
    800024e0:	4037d79b          	sraiw	a5,a5,0x3
    800024e4:	00f90633          	add	a2,s2,a5
    800024e8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800024ec:	00c6f5b3          	and	a1,a3,a2
    800024f0:	d5a1                	beqz	a1,80002438 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024f2:	2705                	addiw	a4,a4,1
    800024f4:	2485                	addiw	s1,s1,1
    800024f6:	fd471ae3          	bne	a4,s4,800024ca <balloc+0xce>
    800024fa:	bf49                	j	8000248c <balloc+0x90>
    800024fc:	6906                	ld	s2,64(sp)
    800024fe:	79e2                	ld	s3,56(sp)
    80002500:	7a42                	ld	s4,48(sp)
    80002502:	7aa2                	ld	s5,40(sp)
    80002504:	7b02                	ld	s6,32(sp)
    80002506:	6be2                	ld	s7,24(sp)
    80002508:	6c42                	ld	s8,16(sp)
    8000250a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000250c:	00005517          	auipc	a0,0x5
    80002510:	fac50513          	addi	a0,a0,-84 # 800074b8 <etext+0x4b8>
    80002514:	69d020ef          	jal	800053b0 <printf>
  return 0;
    80002518:	4481                	li	s1,0
    8000251a:	b79d                	j	80002480 <balloc+0x84>

000000008000251c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000251c:	7179                	addi	sp,sp,-48
    8000251e:	f406                	sd	ra,40(sp)
    80002520:	f022                	sd	s0,32(sp)
    80002522:	ec26                	sd	s1,24(sp)
    80002524:	e84a                	sd	s2,16(sp)
    80002526:	e44e                	sd	s3,8(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000252c:	47ad                	li	a5,11
    8000252e:	02b7e663          	bltu	a5,a1,8000255a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002532:	02059793          	slli	a5,a1,0x20
    80002536:	01e7d593          	srli	a1,a5,0x1e
    8000253a:	00b504b3          	add	s1,a0,a1
    8000253e:	0504a903          	lw	s2,80(s1)
    80002542:	06091a63          	bnez	s2,800025b6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002546:	4108                	lw	a0,0(a0)
    80002548:	eb5ff0ef          	jal	800023fc <balloc>
    8000254c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002550:	06090363          	beqz	s2,800025b6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002554:	0524a823          	sw	s2,80(s1)
    80002558:	a8b9                	j	800025b6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000255a:	ff45849b          	addiw	s1,a1,-12
    8000255e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002562:	0ff00793          	li	a5,255
    80002566:	06e7ee63          	bltu	a5,a4,800025e2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000256a:	08052903          	lw	s2,128(a0)
    8000256e:	00091d63          	bnez	s2,80002588 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002572:	4108                	lw	a0,0(a0)
    80002574:	e89ff0ef          	jal	800023fc <balloc>
    80002578:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000257c:	02090d63          	beqz	s2,800025b6 <bmap+0x9a>
    80002580:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002582:	0929a023          	sw	s2,128(s3)
    80002586:	a011                	j	8000258a <bmap+0x6e>
    80002588:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000258a:	85ca                	mv	a1,s2
    8000258c:	0009a503          	lw	a0,0(s3)
    80002590:	c09ff0ef          	jal	80002198 <bread>
    80002594:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002596:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000259a:	02049713          	slli	a4,s1,0x20
    8000259e:	01e75593          	srli	a1,a4,0x1e
    800025a2:	00b784b3          	add	s1,a5,a1
    800025a6:	0004a903          	lw	s2,0(s1)
    800025aa:	00090e63          	beqz	s2,800025c6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800025ae:	8552                	mv	a0,s4
    800025b0:	cf1ff0ef          	jal	800022a0 <brelse>
    return addr;
    800025b4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800025b6:	854a                	mv	a0,s2
    800025b8:	70a2                	ld	ra,40(sp)
    800025ba:	7402                	ld	s0,32(sp)
    800025bc:	64e2                	ld	s1,24(sp)
    800025be:	6942                	ld	s2,16(sp)
    800025c0:	69a2                	ld	s3,8(sp)
    800025c2:	6145                	addi	sp,sp,48
    800025c4:	8082                	ret
      addr = balloc(ip->dev);
    800025c6:	0009a503          	lw	a0,0(s3)
    800025ca:	e33ff0ef          	jal	800023fc <balloc>
    800025ce:	0005091b          	sext.w	s2,a0
      if(addr){
    800025d2:	fc090ee3          	beqz	s2,800025ae <bmap+0x92>
        a[bn] = addr;
    800025d6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800025da:	8552                	mv	a0,s4
    800025dc:	50f000ef          	jal	800032ea <log_write>
    800025e0:	b7f9                	j	800025ae <bmap+0x92>
    800025e2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800025e4:	00005517          	auipc	a0,0x5
    800025e8:	eec50513          	addi	a0,a0,-276 # 800074d0 <etext+0x4d0>
    800025ec:	096030ef          	jal	80005682 <panic>

00000000800025f0 <iget>:
{
    800025f0:	7179                	addi	sp,sp,-48
    800025f2:	f406                	sd	ra,40(sp)
    800025f4:	f022                	sd	s0,32(sp)
    800025f6:	ec26                	sd	s1,24(sp)
    800025f8:	e84a                	sd	s2,16(sp)
    800025fa:	e44e                	sd	s3,8(sp)
    800025fc:	e052                	sd	s4,0(sp)
    800025fe:	1800                	addi	s0,sp,48
    80002600:	89aa                	mv	s3,a0
    80002602:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002604:	00036517          	auipc	a0,0x36
    80002608:	2d450513          	addi	a0,a0,724 # 800388d8 <itable>
    8000260c:	3a4030ef          	jal	800059b0 <acquire>
  empty = 0;
    80002610:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002612:	00036497          	auipc	s1,0x36
    80002616:	2de48493          	addi	s1,s1,734 # 800388f0 <itable+0x18>
    8000261a:	00038697          	auipc	a3,0x38
    8000261e:	d6668693          	addi	a3,a3,-666 # 8003a380 <log>
    80002622:	a039                	j	80002630 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002624:	02090963          	beqz	s2,80002656 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002628:	08848493          	addi	s1,s1,136
    8000262c:	02d48863          	beq	s1,a3,8000265c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002630:	449c                	lw	a5,8(s1)
    80002632:	fef059e3          	blez	a5,80002624 <iget+0x34>
    80002636:	4098                	lw	a4,0(s1)
    80002638:	ff3716e3          	bne	a4,s3,80002624 <iget+0x34>
    8000263c:	40d8                	lw	a4,4(s1)
    8000263e:	ff4713e3          	bne	a4,s4,80002624 <iget+0x34>
      ip->ref++;
    80002642:	2785                	addiw	a5,a5,1
    80002644:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002646:	00036517          	auipc	a0,0x36
    8000264a:	29250513          	addi	a0,a0,658 # 800388d8 <itable>
    8000264e:	3fa030ef          	jal	80005a48 <release>
      return ip;
    80002652:	8926                	mv	s2,s1
    80002654:	a02d                	j	8000267e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002656:	fbe9                	bnez	a5,80002628 <iget+0x38>
      empty = ip;
    80002658:	8926                	mv	s2,s1
    8000265a:	b7f9                	j	80002628 <iget+0x38>
  if(empty == 0)
    8000265c:	02090a63          	beqz	s2,80002690 <iget+0xa0>
  ip->dev = dev;
    80002660:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002664:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002668:	4785                	li	a5,1
    8000266a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000266e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002672:	00036517          	auipc	a0,0x36
    80002676:	26650513          	addi	a0,a0,614 # 800388d8 <itable>
    8000267a:	3ce030ef          	jal	80005a48 <release>
}
    8000267e:	854a                	mv	a0,s2
    80002680:	70a2                	ld	ra,40(sp)
    80002682:	7402                	ld	s0,32(sp)
    80002684:	64e2                	ld	s1,24(sp)
    80002686:	6942                	ld	s2,16(sp)
    80002688:	69a2                	ld	s3,8(sp)
    8000268a:	6a02                	ld	s4,0(sp)
    8000268c:	6145                	addi	sp,sp,48
    8000268e:	8082                	ret
    panic("iget: no inodes");
    80002690:	00005517          	auipc	a0,0x5
    80002694:	e5850513          	addi	a0,a0,-424 # 800074e8 <etext+0x4e8>
    80002698:	7eb020ef          	jal	80005682 <panic>

000000008000269c <fsinit>:
fsinit(int dev) {
    8000269c:	7179                	addi	sp,sp,-48
    8000269e:	f406                	sd	ra,40(sp)
    800026a0:	f022                	sd	s0,32(sp)
    800026a2:	ec26                	sd	s1,24(sp)
    800026a4:	e84a                	sd	s2,16(sp)
    800026a6:	e44e                	sd	s3,8(sp)
    800026a8:	1800                	addi	s0,sp,48
    800026aa:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800026ac:	4585                	li	a1,1
    800026ae:	aebff0ef          	jal	80002198 <bread>
    800026b2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800026b4:	00036997          	auipc	s3,0x36
    800026b8:	20498993          	addi	s3,s3,516 # 800388b8 <sb>
    800026bc:	02000613          	li	a2,32
    800026c0:	05850593          	addi	a1,a0,88
    800026c4:	854e                	mv	a0,s3
    800026c6:	bd9fd0ef          	jal	8000029e <memmove>
  brelse(bp);
    800026ca:	8526                	mv	a0,s1
    800026cc:	bd5ff0ef          	jal	800022a0 <brelse>
  if(sb.magic != FSMAGIC)
    800026d0:	0009a703          	lw	a4,0(s3)
    800026d4:	102037b7          	lui	a5,0x10203
    800026d8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800026dc:	02f71063          	bne	a4,a5,800026fc <fsinit+0x60>
  initlog(dev, &sb);
    800026e0:	00036597          	auipc	a1,0x36
    800026e4:	1d858593          	addi	a1,a1,472 # 800388b8 <sb>
    800026e8:	854a                	mv	a0,s2
    800026ea:	1f9000ef          	jal	800030e2 <initlog>
}
    800026ee:	70a2                	ld	ra,40(sp)
    800026f0:	7402                	ld	s0,32(sp)
    800026f2:	64e2                	ld	s1,24(sp)
    800026f4:	6942                	ld	s2,16(sp)
    800026f6:	69a2                	ld	s3,8(sp)
    800026f8:	6145                	addi	sp,sp,48
    800026fa:	8082                	ret
    panic("invalid file system");
    800026fc:	00005517          	auipc	a0,0x5
    80002700:	dfc50513          	addi	a0,a0,-516 # 800074f8 <etext+0x4f8>
    80002704:	77f020ef          	jal	80005682 <panic>

0000000080002708 <iinit>:
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	e44e                	sd	s3,8(sp)
    80002714:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002716:	00005597          	auipc	a1,0x5
    8000271a:	dfa58593          	addi	a1,a1,-518 # 80007510 <etext+0x510>
    8000271e:	00036517          	auipc	a0,0x36
    80002722:	1ba50513          	addi	a0,a0,442 # 800388d8 <itable>
    80002726:	20a030ef          	jal	80005930 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000272a:	00036497          	auipc	s1,0x36
    8000272e:	1d648493          	addi	s1,s1,470 # 80038900 <itable+0x28>
    80002732:	00038997          	auipc	s3,0x38
    80002736:	c5e98993          	addi	s3,s3,-930 # 8003a390 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000273a:	00005917          	auipc	s2,0x5
    8000273e:	dde90913          	addi	s2,s2,-546 # 80007518 <etext+0x518>
    80002742:	85ca                	mv	a1,s2
    80002744:	8526                	mv	a0,s1
    80002746:	475000ef          	jal	800033ba <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000274a:	08848493          	addi	s1,s1,136
    8000274e:	ff349ae3          	bne	s1,s3,80002742 <iinit+0x3a>
}
    80002752:	70a2                	ld	ra,40(sp)
    80002754:	7402                	ld	s0,32(sp)
    80002756:	64e2                	ld	s1,24(sp)
    80002758:	6942                	ld	s2,16(sp)
    8000275a:	69a2                	ld	s3,8(sp)
    8000275c:	6145                	addi	sp,sp,48
    8000275e:	8082                	ret

0000000080002760 <ialloc>:
{
    80002760:	7139                	addi	sp,sp,-64
    80002762:	fc06                	sd	ra,56(sp)
    80002764:	f822                	sd	s0,48(sp)
    80002766:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002768:	00036717          	auipc	a4,0x36
    8000276c:	15c72703          	lw	a4,348(a4) # 800388c4 <sb+0xc>
    80002770:	4785                	li	a5,1
    80002772:	06e7f063          	bgeu	a5,a4,800027d2 <ialloc+0x72>
    80002776:	f426                	sd	s1,40(sp)
    80002778:	f04a                	sd	s2,32(sp)
    8000277a:	ec4e                	sd	s3,24(sp)
    8000277c:	e852                	sd	s4,16(sp)
    8000277e:	e456                	sd	s5,8(sp)
    80002780:	e05a                	sd	s6,0(sp)
    80002782:	8aaa                	mv	s5,a0
    80002784:	8b2e                	mv	s6,a1
    80002786:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002788:	00036a17          	auipc	s4,0x36
    8000278c:	130a0a13          	addi	s4,s4,304 # 800388b8 <sb>
    80002790:	00495593          	srli	a1,s2,0x4
    80002794:	018a2783          	lw	a5,24(s4)
    80002798:	9dbd                	addw	a1,a1,a5
    8000279a:	8556                	mv	a0,s5
    8000279c:	9fdff0ef          	jal	80002198 <bread>
    800027a0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800027a2:	05850993          	addi	s3,a0,88
    800027a6:	00f97793          	andi	a5,s2,15
    800027aa:	079a                	slli	a5,a5,0x6
    800027ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800027ae:	00099783          	lh	a5,0(s3)
    800027b2:	cb9d                	beqz	a5,800027e8 <ialloc+0x88>
    brelse(bp);
    800027b4:	aedff0ef          	jal	800022a0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800027b8:	0905                	addi	s2,s2,1
    800027ba:	00ca2703          	lw	a4,12(s4)
    800027be:	0009079b          	sext.w	a5,s2
    800027c2:	fce7e7e3          	bltu	a5,a4,80002790 <ialloc+0x30>
    800027c6:	74a2                	ld	s1,40(sp)
    800027c8:	7902                	ld	s2,32(sp)
    800027ca:	69e2                	ld	s3,24(sp)
    800027cc:	6a42                	ld	s4,16(sp)
    800027ce:	6aa2                	ld	s5,8(sp)
    800027d0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800027d2:	00005517          	auipc	a0,0x5
    800027d6:	d4e50513          	addi	a0,a0,-690 # 80007520 <etext+0x520>
    800027da:	3d7020ef          	jal	800053b0 <printf>
  return 0;
    800027de:	4501                	li	a0,0
}
    800027e0:	70e2                	ld	ra,56(sp)
    800027e2:	7442                	ld	s0,48(sp)
    800027e4:	6121                	addi	sp,sp,64
    800027e6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027e8:	04000613          	li	a2,64
    800027ec:	4581                	li	a1,0
    800027ee:	854e                	mv	a0,s3
    800027f0:	a53fd0ef          	jal	80000242 <memset>
      dip->type = type;
    800027f4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027f8:	8526                	mv	a0,s1
    800027fa:	2f1000ef          	jal	800032ea <log_write>
      brelse(bp);
    800027fe:	8526                	mv	a0,s1
    80002800:	aa1ff0ef          	jal	800022a0 <brelse>
      return iget(dev, inum);
    80002804:	0009059b          	sext.w	a1,s2
    80002808:	8556                	mv	a0,s5
    8000280a:	de7ff0ef          	jal	800025f0 <iget>
    8000280e:	74a2                	ld	s1,40(sp)
    80002810:	7902                	ld	s2,32(sp)
    80002812:	69e2                	ld	s3,24(sp)
    80002814:	6a42                	ld	s4,16(sp)
    80002816:	6aa2                	ld	s5,8(sp)
    80002818:	6b02                	ld	s6,0(sp)
    8000281a:	b7d9                	j	800027e0 <ialloc+0x80>

000000008000281c <iupdate>:
{
    8000281c:	1101                	addi	sp,sp,-32
    8000281e:	ec06                	sd	ra,24(sp)
    80002820:	e822                	sd	s0,16(sp)
    80002822:	e426                	sd	s1,8(sp)
    80002824:	e04a                	sd	s2,0(sp)
    80002826:	1000                	addi	s0,sp,32
    80002828:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000282a:	415c                	lw	a5,4(a0)
    8000282c:	0047d79b          	srliw	a5,a5,0x4
    80002830:	00036597          	auipc	a1,0x36
    80002834:	0a05a583          	lw	a1,160(a1) # 800388d0 <sb+0x18>
    80002838:	9dbd                	addw	a1,a1,a5
    8000283a:	4108                	lw	a0,0(a0)
    8000283c:	95dff0ef          	jal	80002198 <bread>
    80002840:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002842:	05850793          	addi	a5,a0,88
    80002846:	40d8                	lw	a4,4(s1)
    80002848:	8b3d                	andi	a4,a4,15
    8000284a:	071a                	slli	a4,a4,0x6
    8000284c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000284e:	04449703          	lh	a4,68(s1)
    80002852:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002856:	04649703          	lh	a4,70(s1)
    8000285a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000285e:	04849703          	lh	a4,72(s1)
    80002862:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002866:	04a49703          	lh	a4,74(s1)
    8000286a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000286e:	44f8                	lw	a4,76(s1)
    80002870:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002872:	03400613          	li	a2,52
    80002876:	05048593          	addi	a1,s1,80
    8000287a:	00c78513          	addi	a0,a5,12
    8000287e:	a21fd0ef          	jal	8000029e <memmove>
  log_write(bp);
    80002882:	854a                	mv	a0,s2
    80002884:	267000ef          	jal	800032ea <log_write>
  brelse(bp);
    80002888:	854a                	mv	a0,s2
    8000288a:	a17ff0ef          	jal	800022a0 <brelse>
}
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6902                	ld	s2,0(sp)
    80002896:	6105                	addi	sp,sp,32
    80002898:	8082                	ret

000000008000289a <idup>:
{
    8000289a:	1101                	addi	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	e426                	sd	s1,8(sp)
    800028a2:	1000                	addi	s0,sp,32
    800028a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800028a6:	00036517          	auipc	a0,0x36
    800028aa:	03250513          	addi	a0,a0,50 # 800388d8 <itable>
    800028ae:	102030ef          	jal	800059b0 <acquire>
  ip->ref++;
    800028b2:	449c                	lw	a5,8(s1)
    800028b4:	2785                	addiw	a5,a5,1
    800028b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028b8:	00036517          	auipc	a0,0x36
    800028bc:	02050513          	addi	a0,a0,32 # 800388d8 <itable>
    800028c0:	188030ef          	jal	80005a48 <release>
}
    800028c4:	8526                	mv	a0,s1
    800028c6:	60e2                	ld	ra,24(sp)
    800028c8:	6442                	ld	s0,16(sp)
    800028ca:	64a2                	ld	s1,8(sp)
    800028cc:	6105                	addi	sp,sp,32
    800028ce:	8082                	ret

00000000800028d0 <ilock>:
{
    800028d0:	1101                	addi	sp,sp,-32
    800028d2:	ec06                	sd	ra,24(sp)
    800028d4:	e822                	sd	s0,16(sp)
    800028d6:	e426                	sd	s1,8(sp)
    800028d8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028da:	cd19                	beqz	a0,800028f8 <ilock+0x28>
    800028dc:	84aa                	mv	s1,a0
    800028de:	451c                	lw	a5,8(a0)
    800028e0:	00f05c63          	blez	a5,800028f8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800028e4:	0541                	addi	a0,a0,16
    800028e6:	30b000ef          	jal	800033f0 <acquiresleep>
  if(ip->valid == 0){
    800028ea:	40bc                	lw	a5,64(s1)
    800028ec:	cf89                	beqz	a5,80002906 <ilock+0x36>
}
    800028ee:	60e2                	ld	ra,24(sp)
    800028f0:	6442                	ld	s0,16(sp)
    800028f2:	64a2                	ld	s1,8(sp)
    800028f4:	6105                	addi	sp,sp,32
    800028f6:	8082                	ret
    800028f8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800028fa:	00005517          	auipc	a0,0x5
    800028fe:	c3e50513          	addi	a0,a0,-962 # 80007538 <etext+0x538>
    80002902:	581020ef          	jal	80005682 <panic>
    80002906:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002908:	40dc                	lw	a5,4(s1)
    8000290a:	0047d79b          	srliw	a5,a5,0x4
    8000290e:	00036597          	auipc	a1,0x36
    80002912:	fc25a583          	lw	a1,-62(a1) # 800388d0 <sb+0x18>
    80002916:	9dbd                	addw	a1,a1,a5
    80002918:	4088                	lw	a0,0(s1)
    8000291a:	87fff0ef          	jal	80002198 <bread>
    8000291e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002920:	05850593          	addi	a1,a0,88
    80002924:	40dc                	lw	a5,4(s1)
    80002926:	8bbd                	andi	a5,a5,15
    80002928:	079a                	slli	a5,a5,0x6
    8000292a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000292c:	00059783          	lh	a5,0(a1)
    80002930:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002934:	00259783          	lh	a5,2(a1)
    80002938:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000293c:	00459783          	lh	a5,4(a1)
    80002940:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002944:	00659783          	lh	a5,6(a1)
    80002948:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000294c:	459c                	lw	a5,8(a1)
    8000294e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002950:	03400613          	li	a2,52
    80002954:	05b1                	addi	a1,a1,12
    80002956:	05048513          	addi	a0,s1,80
    8000295a:	945fd0ef          	jal	8000029e <memmove>
    brelse(bp);
    8000295e:	854a                	mv	a0,s2
    80002960:	941ff0ef          	jal	800022a0 <brelse>
    ip->valid = 1;
    80002964:	4785                	li	a5,1
    80002966:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002968:	04449783          	lh	a5,68(s1)
    8000296c:	c399                	beqz	a5,80002972 <ilock+0xa2>
    8000296e:	6902                	ld	s2,0(sp)
    80002970:	bfbd                	j	800028ee <ilock+0x1e>
      panic("ilock: no type");
    80002972:	00005517          	auipc	a0,0x5
    80002976:	bce50513          	addi	a0,a0,-1074 # 80007540 <etext+0x540>
    8000297a:	509020ef          	jal	80005682 <panic>

000000008000297e <iunlock>:
{
    8000297e:	1101                	addi	sp,sp,-32
    80002980:	ec06                	sd	ra,24(sp)
    80002982:	e822                	sd	s0,16(sp)
    80002984:	e426                	sd	s1,8(sp)
    80002986:	e04a                	sd	s2,0(sp)
    80002988:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000298a:	c505                	beqz	a0,800029b2 <iunlock+0x34>
    8000298c:	84aa                	mv	s1,a0
    8000298e:	01050913          	addi	s2,a0,16
    80002992:	854a                	mv	a0,s2
    80002994:	2db000ef          	jal	8000346e <holdingsleep>
    80002998:	cd09                	beqz	a0,800029b2 <iunlock+0x34>
    8000299a:	449c                	lw	a5,8(s1)
    8000299c:	00f05b63          	blez	a5,800029b2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800029a0:	854a                	mv	a0,s2
    800029a2:	295000ef          	jal	80003436 <releasesleep>
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6902                	ld	s2,0(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
    panic("iunlock");
    800029b2:	00005517          	auipc	a0,0x5
    800029b6:	b9e50513          	addi	a0,a0,-1122 # 80007550 <etext+0x550>
    800029ba:	4c9020ef          	jal	80005682 <panic>

00000000800029be <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800029be:	7179                	addi	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	e84a                	sd	s2,16(sp)
    800029c8:	e44e                	sd	s3,8(sp)
    800029ca:	1800                	addi	s0,sp,48
    800029cc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029ce:	05050493          	addi	s1,a0,80
    800029d2:	08050913          	addi	s2,a0,128
    800029d6:	a021                	j	800029de <itrunc+0x20>
    800029d8:	0491                	addi	s1,s1,4
    800029da:	01248b63          	beq	s1,s2,800029f0 <itrunc+0x32>
    if(ip->addrs[i]){
    800029de:	408c                	lw	a1,0(s1)
    800029e0:	dde5                	beqz	a1,800029d8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800029e2:	0009a503          	lw	a0,0(s3)
    800029e6:	9abff0ef          	jal	80002390 <bfree>
      ip->addrs[i] = 0;
    800029ea:	0004a023          	sw	zero,0(s1)
    800029ee:	b7ed                	j	800029d8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029f0:	0809a583          	lw	a1,128(s3)
    800029f4:	ed89                	bnez	a1,80002a0e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029f6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029fa:	854e                	mv	a0,s3
    800029fc:	e21ff0ef          	jal	8000281c <iupdate>
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6145                	addi	sp,sp,48
    80002a0c:	8082                	ret
    80002a0e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002a10:	0009a503          	lw	a0,0(s3)
    80002a14:	f84ff0ef          	jal	80002198 <bread>
    80002a18:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002a1a:	05850493          	addi	s1,a0,88
    80002a1e:	45850913          	addi	s2,a0,1112
    80002a22:	a021                	j	80002a2a <itrunc+0x6c>
    80002a24:	0491                	addi	s1,s1,4
    80002a26:	01248963          	beq	s1,s2,80002a38 <itrunc+0x7a>
      if(a[j])
    80002a2a:	408c                	lw	a1,0(s1)
    80002a2c:	dde5                	beqz	a1,80002a24 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002a2e:	0009a503          	lw	a0,0(s3)
    80002a32:	95fff0ef          	jal	80002390 <bfree>
    80002a36:	b7fd                	j	80002a24 <itrunc+0x66>
    brelse(bp);
    80002a38:	8552                	mv	a0,s4
    80002a3a:	867ff0ef          	jal	800022a0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a3e:	0809a583          	lw	a1,128(s3)
    80002a42:	0009a503          	lw	a0,0(s3)
    80002a46:	94bff0ef          	jal	80002390 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a4a:	0809a023          	sw	zero,128(s3)
    80002a4e:	6a02                	ld	s4,0(sp)
    80002a50:	b75d                	j	800029f6 <itrunc+0x38>

0000000080002a52 <iput>:
{
    80002a52:	1101                	addi	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	e426                	sd	s1,8(sp)
    80002a5a:	1000                	addi	s0,sp,32
    80002a5c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a5e:	00036517          	auipc	a0,0x36
    80002a62:	e7a50513          	addi	a0,a0,-390 # 800388d8 <itable>
    80002a66:	74b020ef          	jal	800059b0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a6a:	4498                	lw	a4,8(s1)
    80002a6c:	4785                	li	a5,1
    80002a6e:	02f70063          	beq	a4,a5,80002a8e <iput+0x3c>
  ip->ref--;
    80002a72:	449c                	lw	a5,8(s1)
    80002a74:	37fd                	addiw	a5,a5,-1
    80002a76:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a78:	00036517          	auipc	a0,0x36
    80002a7c:	e6050513          	addi	a0,a0,-416 # 800388d8 <itable>
    80002a80:	7c9020ef          	jal	80005a48 <release>
}
    80002a84:	60e2                	ld	ra,24(sp)
    80002a86:	6442                	ld	s0,16(sp)
    80002a88:	64a2                	ld	s1,8(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a8e:	40bc                	lw	a5,64(s1)
    80002a90:	d3ed                	beqz	a5,80002a72 <iput+0x20>
    80002a92:	04a49783          	lh	a5,74(s1)
    80002a96:	fff1                	bnez	a5,80002a72 <iput+0x20>
    80002a98:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002a9a:	01048913          	addi	s2,s1,16
    80002a9e:	854a                	mv	a0,s2
    80002aa0:	151000ef          	jal	800033f0 <acquiresleep>
    release(&itable.lock);
    80002aa4:	00036517          	auipc	a0,0x36
    80002aa8:	e3450513          	addi	a0,a0,-460 # 800388d8 <itable>
    80002aac:	79d020ef          	jal	80005a48 <release>
    itrunc(ip);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	f0dff0ef          	jal	800029be <itrunc>
    ip->type = 0;
    80002ab6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002aba:	8526                	mv	a0,s1
    80002abc:	d61ff0ef          	jal	8000281c <iupdate>
    ip->valid = 0;
    80002ac0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002ac4:	854a                	mv	a0,s2
    80002ac6:	171000ef          	jal	80003436 <releasesleep>
    acquire(&itable.lock);
    80002aca:	00036517          	auipc	a0,0x36
    80002ace:	e0e50513          	addi	a0,a0,-498 # 800388d8 <itable>
    80002ad2:	6df020ef          	jal	800059b0 <acquire>
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	bf69                	j	80002a72 <iput+0x20>

0000000080002ada <iunlockput>:
{
    80002ada:	1101                	addi	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	1000                	addi	s0,sp,32
    80002ae4:	84aa                	mv	s1,a0
  iunlock(ip);
    80002ae6:	e99ff0ef          	jal	8000297e <iunlock>
  iput(ip);
    80002aea:	8526                	mv	a0,s1
    80002aec:	f67ff0ef          	jal	80002a52 <iput>
}
    80002af0:	60e2                	ld	ra,24(sp)
    80002af2:	6442                	ld	s0,16(sp)
    80002af4:	64a2                	ld	s1,8(sp)
    80002af6:	6105                	addi	sp,sp,32
    80002af8:	8082                	ret

0000000080002afa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002afa:	1141                	addi	sp,sp,-16
    80002afc:	e422                	sd	s0,8(sp)
    80002afe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002b00:	411c                	lw	a5,0(a0)
    80002b02:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002b04:	415c                	lw	a5,4(a0)
    80002b06:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002b08:	04451783          	lh	a5,68(a0)
    80002b0c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002b10:	04a51783          	lh	a5,74(a0)
    80002b14:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002b18:	04c56783          	lwu	a5,76(a0)
    80002b1c:	e99c                	sd	a5,16(a1)
}
    80002b1e:	6422                	ld	s0,8(sp)
    80002b20:	0141                	addi	sp,sp,16
    80002b22:	8082                	ret

0000000080002b24 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b24:	457c                	lw	a5,76(a0)
    80002b26:	0ed7eb63          	bltu	a5,a3,80002c1c <readi+0xf8>
{
    80002b2a:	7159                	addi	sp,sp,-112
    80002b2c:	f486                	sd	ra,104(sp)
    80002b2e:	f0a2                	sd	s0,96(sp)
    80002b30:	eca6                	sd	s1,88(sp)
    80002b32:	e0d2                	sd	s4,64(sp)
    80002b34:	fc56                	sd	s5,56(sp)
    80002b36:	f85a                	sd	s6,48(sp)
    80002b38:	f45e                	sd	s7,40(sp)
    80002b3a:	1880                	addi	s0,sp,112
    80002b3c:	8b2a                	mv	s6,a0
    80002b3e:	8bae                	mv	s7,a1
    80002b40:	8a32                	mv	s4,a2
    80002b42:	84b6                	mv	s1,a3
    80002b44:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002b46:	9f35                	addw	a4,a4,a3
    return 0;
    80002b48:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002b4a:	0cd76063          	bltu	a4,a3,80002c0a <readi+0xe6>
    80002b4e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002b50:	00e7f463          	bgeu	a5,a4,80002b58 <readi+0x34>
    n = ip->size - off;
    80002b54:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b58:	080a8f63          	beqz	s5,80002bf6 <readi+0xd2>
    80002b5c:	e8ca                	sd	s2,80(sp)
    80002b5e:	f062                	sd	s8,32(sp)
    80002b60:	ec66                	sd	s9,24(sp)
    80002b62:	e86a                	sd	s10,16(sp)
    80002b64:	e46e                	sd	s11,8(sp)
    80002b66:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b68:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002b6c:	5c7d                	li	s8,-1
    80002b6e:	a80d                	j	80002ba0 <readi+0x7c>
    80002b70:	020d1d93          	slli	s11,s10,0x20
    80002b74:	020ddd93          	srli	s11,s11,0x20
    80002b78:	05890613          	addi	a2,s2,88
    80002b7c:	86ee                	mv	a3,s11
    80002b7e:	963a                	add	a2,a2,a4
    80002b80:	85d2                	mv	a1,s4
    80002b82:	855e                	mv	a0,s7
    80002b84:	cc3fe0ef          	jal	80001846 <either_copyout>
    80002b88:	05850763          	beq	a0,s8,80002bd6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002b8c:	854a                	mv	a0,s2
    80002b8e:	f12ff0ef          	jal	800022a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b92:	013d09bb          	addw	s3,s10,s3
    80002b96:	009d04bb          	addw	s1,s10,s1
    80002b9a:	9a6e                	add	s4,s4,s11
    80002b9c:	0559f763          	bgeu	s3,s5,80002bea <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002ba0:	00a4d59b          	srliw	a1,s1,0xa
    80002ba4:	855a                	mv	a0,s6
    80002ba6:	977ff0ef          	jal	8000251c <bmap>
    80002baa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002bae:	c5b1                	beqz	a1,80002bfa <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002bb0:	000b2503          	lw	a0,0(s6)
    80002bb4:	de4ff0ef          	jal	80002198 <bread>
    80002bb8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002bba:	3ff4f713          	andi	a4,s1,1023
    80002bbe:	40ec87bb          	subw	a5,s9,a4
    80002bc2:	413a86bb          	subw	a3,s5,s3
    80002bc6:	8d3e                	mv	s10,a5
    80002bc8:	2781                	sext.w	a5,a5
    80002bca:	0006861b          	sext.w	a2,a3
    80002bce:	faf671e3          	bgeu	a2,a5,80002b70 <readi+0x4c>
    80002bd2:	8d36                	mv	s10,a3
    80002bd4:	bf71                	j	80002b70 <readi+0x4c>
      brelse(bp);
    80002bd6:	854a                	mv	a0,s2
    80002bd8:	ec8ff0ef          	jal	800022a0 <brelse>
      tot = -1;
    80002bdc:	59fd                	li	s3,-1
      break;
    80002bde:	6946                	ld	s2,80(sp)
    80002be0:	7c02                	ld	s8,32(sp)
    80002be2:	6ce2                	ld	s9,24(sp)
    80002be4:	6d42                	ld	s10,16(sp)
    80002be6:	6da2                	ld	s11,8(sp)
    80002be8:	a831                	j	80002c04 <readi+0xe0>
    80002bea:	6946                	ld	s2,80(sp)
    80002bec:	7c02                	ld	s8,32(sp)
    80002bee:	6ce2                	ld	s9,24(sp)
    80002bf0:	6d42                	ld	s10,16(sp)
    80002bf2:	6da2                	ld	s11,8(sp)
    80002bf4:	a801                	j	80002c04 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002bf6:	89d6                	mv	s3,s5
    80002bf8:	a031                	j	80002c04 <readi+0xe0>
    80002bfa:	6946                	ld	s2,80(sp)
    80002bfc:	7c02                	ld	s8,32(sp)
    80002bfe:	6ce2                	ld	s9,24(sp)
    80002c00:	6d42                	ld	s10,16(sp)
    80002c02:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002c04:	0009851b          	sext.w	a0,s3
    80002c08:	69a6                	ld	s3,72(sp)
}
    80002c0a:	70a6                	ld	ra,104(sp)
    80002c0c:	7406                	ld	s0,96(sp)
    80002c0e:	64e6                	ld	s1,88(sp)
    80002c10:	6a06                	ld	s4,64(sp)
    80002c12:	7ae2                	ld	s5,56(sp)
    80002c14:	7b42                	ld	s6,48(sp)
    80002c16:	7ba2                	ld	s7,40(sp)
    80002c18:	6165                	addi	sp,sp,112
    80002c1a:	8082                	ret
    return 0;
    80002c1c:	4501                	li	a0,0
}
    80002c1e:	8082                	ret

0000000080002c20 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c20:	457c                	lw	a5,76(a0)
    80002c22:	10d7e063          	bltu	a5,a3,80002d22 <writei+0x102>
{
    80002c26:	7159                	addi	sp,sp,-112
    80002c28:	f486                	sd	ra,104(sp)
    80002c2a:	f0a2                	sd	s0,96(sp)
    80002c2c:	e8ca                	sd	s2,80(sp)
    80002c2e:	e0d2                	sd	s4,64(sp)
    80002c30:	fc56                	sd	s5,56(sp)
    80002c32:	f85a                	sd	s6,48(sp)
    80002c34:	f45e                	sd	s7,40(sp)
    80002c36:	1880                	addi	s0,sp,112
    80002c38:	8aaa                	mv	s5,a0
    80002c3a:	8bae                	mv	s7,a1
    80002c3c:	8a32                	mv	s4,a2
    80002c3e:	8936                	mv	s2,a3
    80002c40:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002c42:	00e687bb          	addw	a5,a3,a4
    80002c46:	0ed7e063          	bltu	a5,a3,80002d26 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002c4a:	00043737          	lui	a4,0x43
    80002c4e:	0cf76e63          	bltu	a4,a5,80002d2a <writei+0x10a>
    80002c52:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c54:	0a0b0f63          	beqz	s6,80002d12 <writei+0xf2>
    80002c58:	eca6                	sd	s1,88(sp)
    80002c5a:	f062                	sd	s8,32(sp)
    80002c5c:	ec66                	sd	s9,24(sp)
    80002c5e:	e86a                	sd	s10,16(sp)
    80002c60:	e46e                	sd	s11,8(sp)
    80002c62:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c64:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002c68:	5c7d                	li	s8,-1
    80002c6a:	a825                	j	80002ca2 <writei+0x82>
    80002c6c:	020d1d93          	slli	s11,s10,0x20
    80002c70:	020ddd93          	srli	s11,s11,0x20
    80002c74:	05848513          	addi	a0,s1,88
    80002c78:	86ee                	mv	a3,s11
    80002c7a:	8652                	mv	a2,s4
    80002c7c:	85de                	mv	a1,s7
    80002c7e:	953a                	add	a0,a0,a4
    80002c80:	c11fe0ef          	jal	80001890 <either_copyin>
    80002c84:	05850a63          	beq	a0,s8,80002cd8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002c88:	8526                	mv	a0,s1
    80002c8a:	660000ef          	jal	800032ea <log_write>
    brelse(bp);
    80002c8e:	8526                	mv	a0,s1
    80002c90:	e10ff0ef          	jal	800022a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c94:	013d09bb          	addw	s3,s10,s3
    80002c98:	012d093b          	addw	s2,s10,s2
    80002c9c:	9a6e                	add	s4,s4,s11
    80002c9e:	0569f063          	bgeu	s3,s6,80002cde <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002ca2:	00a9559b          	srliw	a1,s2,0xa
    80002ca6:	8556                	mv	a0,s5
    80002ca8:	875ff0ef          	jal	8000251c <bmap>
    80002cac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002cb0:	c59d                	beqz	a1,80002cde <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002cb2:	000aa503          	lw	a0,0(s5)
    80002cb6:	ce2ff0ef          	jal	80002198 <bread>
    80002cba:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cbc:	3ff97713          	andi	a4,s2,1023
    80002cc0:	40ec87bb          	subw	a5,s9,a4
    80002cc4:	413b06bb          	subw	a3,s6,s3
    80002cc8:	8d3e                	mv	s10,a5
    80002cca:	2781                	sext.w	a5,a5
    80002ccc:	0006861b          	sext.w	a2,a3
    80002cd0:	f8f67ee3          	bgeu	a2,a5,80002c6c <writei+0x4c>
    80002cd4:	8d36                	mv	s10,a3
    80002cd6:	bf59                	j	80002c6c <writei+0x4c>
      brelse(bp);
    80002cd8:	8526                	mv	a0,s1
    80002cda:	dc6ff0ef          	jal	800022a0 <brelse>
  }

  if(off > ip->size)
    80002cde:	04caa783          	lw	a5,76(s5)
    80002ce2:	0327fa63          	bgeu	a5,s2,80002d16 <writei+0xf6>
    ip->size = off;
    80002ce6:	052aa623          	sw	s2,76(s5)
    80002cea:	64e6                	ld	s1,88(sp)
    80002cec:	7c02                	ld	s8,32(sp)
    80002cee:	6ce2                	ld	s9,24(sp)
    80002cf0:	6d42                	ld	s10,16(sp)
    80002cf2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002cf4:	8556                	mv	a0,s5
    80002cf6:	b27ff0ef          	jal	8000281c <iupdate>

  return tot;
    80002cfa:	0009851b          	sext.w	a0,s3
    80002cfe:	69a6                	ld	s3,72(sp)
}
    80002d00:	70a6                	ld	ra,104(sp)
    80002d02:	7406                	ld	s0,96(sp)
    80002d04:	6946                	ld	s2,80(sp)
    80002d06:	6a06                	ld	s4,64(sp)
    80002d08:	7ae2                	ld	s5,56(sp)
    80002d0a:	7b42                	ld	s6,48(sp)
    80002d0c:	7ba2                	ld	s7,40(sp)
    80002d0e:	6165                	addi	sp,sp,112
    80002d10:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d12:	89da                	mv	s3,s6
    80002d14:	b7c5                	j	80002cf4 <writei+0xd4>
    80002d16:	64e6                	ld	s1,88(sp)
    80002d18:	7c02                	ld	s8,32(sp)
    80002d1a:	6ce2                	ld	s9,24(sp)
    80002d1c:	6d42                	ld	s10,16(sp)
    80002d1e:	6da2                	ld	s11,8(sp)
    80002d20:	bfd1                	j	80002cf4 <writei+0xd4>
    return -1;
    80002d22:	557d                	li	a0,-1
}
    80002d24:	8082                	ret
    return -1;
    80002d26:	557d                	li	a0,-1
    80002d28:	bfe1                	j	80002d00 <writei+0xe0>
    return -1;
    80002d2a:	557d                	li	a0,-1
    80002d2c:	bfd1                	j	80002d00 <writei+0xe0>

0000000080002d2e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002d2e:	1141                	addi	sp,sp,-16
    80002d30:	e406                	sd	ra,8(sp)
    80002d32:	e022                	sd	s0,0(sp)
    80002d34:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002d36:	4639                	li	a2,14
    80002d38:	dd6fd0ef          	jal	8000030e <strncmp>
}
    80002d3c:	60a2                	ld	ra,8(sp)
    80002d3e:	6402                	ld	s0,0(sp)
    80002d40:	0141                	addi	sp,sp,16
    80002d42:	8082                	ret

0000000080002d44 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002d44:	7139                	addi	sp,sp,-64
    80002d46:	fc06                	sd	ra,56(sp)
    80002d48:	f822                	sd	s0,48(sp)
    80002d4a:	f426                	sd	s1,40(sp)
    80002d4c:	f04a                	sd	s2,32(sp)
    80002d4e:	ec4e                	sd	s3,24(sp)
    80002d50:	e852                	sd	s4,16(sp)
    80002d52:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002d54:	04451703          	lh	a4,68(a0)
    80002d58:	4785                	li	a5,1
    80002d5a:	00f71a63          	bne	a4,a5,80002d6e <dirlookup+0x2a>
    80002d5e:	892a                	mv	s2,a0
    80002d60:	89ae                	mv	s3,a1
    80002d62:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d64:	457c                	lw	a5,76(a0)
    80002d66:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002d68:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d6a:	e39d                	bnez	a5,80002d90 <dirlookup+0x4c>
    80002d6c:	a095                	j	80002dd0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002d6e:	00004517          	auipc	a0,0x4
    80002d72:	7ea50513          	addi	a0,a0,2026 # 80007558 <etext+0x558>
    80002d76:	10d020ef          	jal	80005682 <panic>
      panic("dirlookup read");
    80002d7a:	00004517          	auipc	a0,0x4
    80002d7e:	7f650513          	addi	a0,a0,2038 # 80007570 <etext+0x570>
    80002d82:	101020ef          	jal	80005682 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d86:	24c1                	addiw	s1,s1,16
    80002d88:	04c92783          	lw	a5,76(s2)
    80002d8c:	04f4f163          	bgeu	s1,a5,80002dce <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d90:	4741                	li	a4,16
    80002d92:	86a6                	mv	a3,s1
    80002d94:	fc040613          	addi	a2,s0,-64
    80002d98:	4581                	li	a1,0
    80002d9a:	854a                	mv	a0,s2
    80002d9c:	d89ff0ef          	jal	80002b24 <readi>
    80002da0:	47c1                	li	a5,16
    80002da2:	fcf51ce3          	bne	a0,a5,80002d7a <dirlookup+0x36>
    if(de.inum == 0)
    80002da6:	fc045783          	lhu	a5,-64(s0)
    80002daa:	dff1                	beqz	a5,80002d86 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002dac:	fc240593          	addi	a1,s0,-62
    80002db0:	854e                	mv	a0,s3
    80002db2:	f7dff0ef          	jal	80002d2e <namecmp>
    80002db6:	f961                	bnez	a0,80002d86 <dirlookup+0x42>
      if(poff)
    80002db8:	000a0463          	beqz	s4,80002dc0 <dirlookup+0x7c>
        *poff = off;
    80002dbc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002dc0:	fc045583          	lhu	a1,-64(s0)
    80002dc4:	00092503          	lw	a0,0(s2)
    80002dc8:	829ff0ef          	jal	800025f0 <iget>
    80002dcc:	a011                	j	80002dd0 <dirlookup+0x8c>
  return 0;
    80002dce:	4501                	li	a0,0
}
    80002dd0:	70e2                	ld	ra,56(sp)
    80002dd2:	7442                	ld	s0,48(sp)
    80002dd4:	74a2                	ld	s1,40(sp)
    80002dd6:	7902                	ld	s2,32(sp)
    80002dd8:	69e2                	ld	s3,24(sp)
    80002dda:	6a42                	ld	s4,16(sp)
    80002ddc:	6121                	addi	sp,sp,64
    80002dde:	8082                	ret

0000000080002de0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002de0:	711d                	addi	sp,sp,-96
    80002de2:	ec86                	sd	ra,88(sp)
    80002de4:	e8a2                	sd	s0,80(sp)
    80002de6:	e4a6                	sd	s1,72(sp)
    80002de8:	e0ca                	sd	s2,64(sp)
    80002dea:	fc4e                	sd	s3,56(sp)
    80002dec:	f852                	sd	s4,48(sp)
    80002dee:	f456                	sd	s5,40(sp)
    80002df0:	f05a                	sd	s6,32(sp)
    80002df2:	ec5e                	sd	s7,24(sp)
    80002df4:	e862                	sd	s8,16(sp)
    80002df6:	e466                	sd	s9,8(sp)
    80002df8:	1080                	addi	s0,sp,96
    80002dfa:	84aa                	mv	s1,a0
    80002dfc:	8b2e                	mv	s6,a1
    80002dfe:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002e00:	00054703          	lbu	a4,0(a0)
    80002e04:	02f00793          	li	a5,47
    80002e08:	00f70e63          	beq	a4,a5,80002e24 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002e0c:	910fe0ef          	jal	80000f1c <myproc>
    80002e10:	15053503          	ld	a0,336(a0)
    80002e14:	a87ff0ef          	jal	8000289a <idup>
    80002e18:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002e1a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002e1e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002e20:	4b85                	li	s7,1
    80002e22:	a871                	j	80002ebe <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002e24:	4585                	li	a1,1
    80002e26:	4505                	li	a0,1
    80002e28:	fc8ff0ef          	jal	800025f0 <iget>
    80002e2c:	8a2a                	mv	s4,a0
    80002e2e:	b7f5                	j	80002e1a <namex+0x3a>
      iunlockput(ip);
    80002e30:	8552                	mv	a0,s4
    80002e32:	ca9ff0ef          	jal	80002ada <iunlockput>
      return 0;
    80002e36:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002e38:	8552                	mv	a0,s4
    80002e3a:	60e6                	ld	ra,88(sp)
    80002e3c:	6446                	ld	s0,80(sp)
    80002e3e:	64a6                	ld	s1,72(sp)
    80002e40:	6906                	ld	s2,64(sp)
    80002e42:	79e2                	ld	s3,56(sp)
    80002e44:	7a42                	ld	s4,48(sp)
    80002e46:	7aa2                	ld	s5,40(sp)
    80002e48:	7b02                	ld	s6,32(sp)
    80002e4a:	6be2                	ld	s7,24(sp)
    80002e4c:	6c42                	ld	s8,16(sp)
    80002e4e:	6ca2                	ld	s9,8(sp)
    80002e50:	6125                	addi	sp,sp,96
    80002e52:	8082                	ret
      iunlock(ip);
    80002e54:	8552                	mv	a0,s4
    80002e56:	b29ff0ef          	jal	8000297e <iunlock>
      return ip;
    80002e5a:	bff9                	j	80002e38 <namex+0x58>
      iunlockput(ip);
    80002e5c:	8552                	mv	a0,s4
    80002e5e:	c7dff0ef          	jal	80002ada <iunlockput>
      return 0;
    80002e62:	8a4e                	mv	s4,s3
    80002e64:	bfd1                	j	80002e38 <namex+0x58>
  len = path - s;
    80002e66:	40998633          	sub	a2,s3,s1
    80002e6a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002e6e:	099c5063          	bge	s8,s9,80002eee <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002e72:	4639                	li	a2,14
    80002e74:	85a6                	mv	a1,s1
    80002e76:	8556                	mv	a0,s5
    80002e78:	c26fd0ef          	jal	8000029e <memmove>
    80002e7c:	84ce                	mv	s1,s3
  while(*path == '/')
    80002e7e:	0004c783          	lbu	a5,0(s1)
    80002e82:	01279763          	bne	a5,s2,80002e90 <namex+0xb0>
    path++;
    80002e86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e88:	0004c783          	lbu	a5,0(s1)
    80002e8c:	ff278de3          	beq	a5,s2,80002e86 <namex+0xa6>
    ilock(ip);
    80002e90:	8552                	mv	a0,s4
    80002e92:	a3fff0ef          	jal	800028d0 <ilock>
    if(ip->type != T_DIR){
    80002e96:	044a1783          	lh	a5,68(s4)
    80002e9a:	f9779be3          	bne	a5,s7,80002e30 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002e9e:	000b0563          	beqz	s6,80002ea8 <namex+0xc8>
    80002ea2:	0004c783          	lbu	a5,0(s1)
    80002ea6:	d7dd                	beqz	a5,80002e54 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002ea8:	4601                	li	a2,0
    80002eaa:	85d6                	mv	a1,s5
    80002eac:	8552                	mv	a0,s4
    80002eae:	e97ff0ef          	jal	80002d44 <dirlookup>
    80002eb2:	89aa                	mv	s3,a0
    80002eb4:	d545                	beqz	a0,80002e5c <namex+0x7c>
    iunlockput(ip);
    80002eb6:	8552                	mv	a0,s4
    80002eb8:	c23ff0ef          	jal	80002ada <iunlockput>
    ip = next;
    80002ebc:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002ebe:	0004c783          	lbu	a5,0(s1)
    80002ec2:	01279763          	bne	a5,s2,80002ed0 <namex+0xf0>
    path++;
    80002ec6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002ec8:	0004c783          	lbu	a5,0(s1)
    80002ecc:	ff278de3          	beq	a5,s2,80002ec6 <namex+0xe6>
  if(*path == 0)
    80002ed0:	cb8d                	beqz	a5,80002f02 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002ed2:	0004c783          	lbu	a5,0(s1)
    80002ed6:	89a6                	mv	s3,s1
  len = path - s;
    80002ed8:	4c81                	li	s9,0
    80002eda:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002edc:	01278963          	beq	a5,s2,80002eee <namex+0x10e>
    80002ee0:	d3d9                	beqz	a5,80002e66 <namex+0x86>
    path++;
    80002ee2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002ee4:	0009c783          	lbu	a5,0(s3)
    80002ee8:	ff279ce3          	bne	a5,s2,80002ee0 <namex+0x100>
    80002eec:	bfad                	j	80002e66 <namex+0x86>
    memmove(name, s, len);
    80002eee:	2601                	sext.w	a2,a2
    80002ef0:	85a6                	mv	a1,s1
    80002ef2:	8556                	mv	a0,s5
    80002ef4:	baafd0ef          	jal	8000029e <memmove>
    name[len] = 0;
    80002ef8:	9cd6                	add	s9,s9,s5
    80002efa:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002efe:	84ce                	mv	s1,s3
    80002f00:	bfbd                	j	80002e7e <namex+0x9e>
  if(nameiparent){
    80002f02:	f20b0be3          	beqz	s6,80002e38 <namex+0x58>
    iput(ip);
    80002f06:	8552                	mv	a0,s4
    80002f08:	b4bff0ef          	jal	80002a52 <iput>
    return 0;
    80002f0c:	4a01                	li	s4,0
    80002f0e:	b72d                	j	80002e38 <namex+0x58>

0000000080002f10 <dirlink>:
{
    80002f10:	7139                	addi	sp,sp,-64
    80002f12:	fc06                	sd	ra,56(sp)
    80002f14:	f822                	sd	s0,48(sp)
    80002f16:	f04a                	sd	s2,32(sp)
    80002f18:	ec4e                	sd	s3,24(sp)
    80002f1a:	e852                	sd	s4,16(sp)
    80002f1c:	0080                	addi	s0,sp,64
    80002f1e:	892a                	mv	s2,a0
    80002f20:	8a2e                	mv	s4,a1
    80002f22:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002f24:	4601                	li	a2,0
    80002f26:	e1fff0ef          	jal	80002d44 <dirlookup>
    80002f2a:	e535                	bnez	a0,80002f96 <dirlink+0x86>
    80002f2c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f2e:	04c92483          	lw	s1,76(s2)
    80002f32:	c48d                	beqz	s1,80002f5c <dirlink+0x4c>
    80002f34:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f36:	4741                	li	a4,16
    80002f38:	86a6                	mv	a3,s1
    80002f3a:	fc040613          	addi	a2,s0,-64
    80002f3e:	4581                	li	a1,0
    80002f40:	854a                	mv	a0,s2
    80002f42:	be3ff0ef          	jal	80002b24 <readi>
    80002f46:	47c1                	li	a5,16
    80002f48:	04f51b63          	bne	a0,a5,80002f9e <dirlink+0x8e>
    if(de.inum == 0)
    80002f4c:	fc045783          	lhu	a5,-64(s0)
    80002f50:	c791                	beqz	a5,80002f5c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f52:	24c1                	addiw	s1,s1,16
    80002f54:	04c92783          	lw	a5,76(s2)
    80002f58:	fcf4efe3          	bltu	s1,a5,80002f36 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002f5c:	4639                	li	a2,14
    80002f5e:	85d2                	mv	a1,s4
    80002f60:	fc240513          	addi	a0,s0,-62
    80002f64:	be0fd0ef          	jal	80000344 <strncpy>
  de.inum = inum;
    80002f68:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f6c:	4741                	li	a4,16
    80002f6e:	86a6                	mv	a3,s1
    80002f70:	fc040613          	addi	a2,s0,-64
    80002f74:	4581                	li	a1,0
    80002f76:	854a                	mv	a0,s2
    80002f78:	ca9ff0ef          	jal	80002c20 <writei>
    80002f7c:	1541                	addi	a0,a0,-16
    80002f7e:	00a03533          	snez	a0,a0
    80002f82:	40a00533          	neg	a0,a0
    80002f86:	74a2                	ld	s1,40(sp)
}
    80002f88:	70e2                	ld	ra,56(sp)
    80002f8a:	7442                	ld	s0,48(sp)
    80002f8c:	7902                	ld	s2,32(sp)
    80002f8e:	69e2                	ld	s3,24(sp)
    80002f90:	6a42                	ld	s4,16(sp)
    80002f92:	6121                	addi	sp,sp,64
    80002f94:	8082                	ret
    iput(ip);
    80002f96:	abdff0ef          	jal	80002a52 <iput>
    return -1;
    80002f9a:	557d                	li	a0,-1
    80002f9c:	b7f5                	j	80002f88 <dirlink+0x78>
      panic("dirlink read");
    80002f9e:	00004517          	auipc	a0,0x4
    80002fa2:	5e250513          	addi	a0,a0,1506 # 80007580 <etext+0x580>
    80002fa6:	6dc020ef          	jal	80005682 <panic>

0000000080002faa <namei>:

struct inode*
namei(char *path)
{
    80002faa:	1101                	addi	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002fb2:	fe040613          	addi	a2,s0,-32
    80002fb6:	4581                	li	a1,0
    80002fb8:	e29ff0ef          	jal	80002de0 <namex>
}
    80002fbc:	60e2                	ld	ra,24(sp)
    80002fbe:	6442                	ld	s0,16(sp)
    80002fc0:	6105                	addi	sp,sp,32
    80002fc2:	8082                	ret

0000000080002fc4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002fc4:	1141                	addi	sp,sp,-16
    80002fc6:	e406                	sd	ra,8(sp)
    80002fc8:	e022                	sd	s0,0(sp)
    80002fca:	0800                	addi	s0,sp,16
    80002fcc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002fce:	4585                	li	a1,1
    80002fd0:	e11ff0ef          	jal	80002de0 <namex>
}
    80002fd4:	60a2                	ld	ra,8(sp)
    80002fd6:	6402                	ld	s0,0(sp)
    80002fd8:	0141                	addi	sp,sp,16
    80002fda:	8082                	ret

0000000080002fdc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002fdc:	1101                	addi	sp,sp,-32
    80002fde:	ec06                	sd	ra,24(sp)
    80002fe0:	e822                	sd	s0,16(sp)
    80002fe2:	e426                	sd	s1,8(sp)
    80002fe4:	e04a                	sd	s2,0(sp)
    80002fe6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002fe8:	00037917          	auipc	s2,0x37
    80002fec:	39890913          	addi	s2,s2,920 # 8003a380 <log>
    80002ff0:	01892583          	lw	a1,24(s2)
    80002ff4:	02892503          	lw	a0,40(s2)
    80002ff8:	9a0ff0ef          	jal	80002198 <bread>
    80002ffc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002ffe:	02c92603          	lw	a2,44(s2)
    80003002:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003004:	00c05f63          	blez	a2,80003022 <write_head+0x46>
    80003008:	00037717          	auipc	a4,0x37
    8000300c:	3a870713          	addi	a4,a4,936 # 8003a3b0 <log+0x30>
    80003010:	87aa                	mv	a5,a0
    80003012:	060a                	slli	a2,a2,0x2
    80003014:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003016:	4314                	lw	a3,0(a4)
    80003018:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000301a:	0711                	addi	a4,a4,4
    8000301c:	0791                	addi	a5,a5,4
    8000301e:	fec79ce3          	bne	a5,a2,80003016 <write_head+0x3a>
  }
  bwrite(buf);
    80003022:	8526                	mv	a0,s1
    80003024:	a4aff0ef          	jal	8000226e <bwrite>
  brelse(buf);
    80003028:	8526                	mv	a0,s1
    8000302a:	a76ff0ef          	jal	800022a0 <brelse>
}
    8000302e:	60e2                	ld	ra,24(sp)
    80003030:	6442                	ld	s0,16(sp)
    80003032:	64a2                	ld	s1,8(sp)
    80003034:	6902                	ld	s2,0(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000303a:	00037797          	auipc	a5,0x37
    8000303e:	3727a783          	lw	a5,882(a5) # 8003a3ac <log+0x2c>
    80003042:	08f05f63          	blez	a5,800030e0 <install_trans+0xa6>
{
    80003046:	7139                	addi	sp,sp,-64
    80003048:	fc06                	sd	ra,56(sp)
    8000304a:	f822                	sd	s0,48(sp)
    8000304c:	f426                	sd	s1,40(sp)
    8000304e:	f04a                	sd	s2,32(sp)
    80003050:	ec4e                	sd	s3,24(sp)
    80003052:	e852                	sd	s4,16(sp)
    80003054:	e456                	sd	s5,8(sp)
    80003056:	e05a                	sd	s6,0(sp)
    80003058:	0080                	addi	s0,sp,64
    8000305a:	8b2a                	mv	s6,a0
    8000305c:	00037a97          	auipc	s5,0x37
    80003060:	354a8a93          	addi	s5,s5,852 # 8003a3b0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003064:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003066:	00037997          	auipc	s3,0x37
    8000306a:	31a98993          	addi	s3,s3,794 # 8003a380 <log>
    8000306e:	a829                	j	80003088 <install_trans+0x4e>
    brelse(lbuf);
    80003070:	854a                	mv	a0,s2
    80003072:	a2eff0ef          	jal	800022a0 <brelse>
    brelse(dbuf);
    80003076:	8526                	mv	a0,s1
    80003078:	a28ff0ef          	jal	800022a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000307c:	2a05                	addiw	s4,s4,1
    8000307e:	0a91                	addi	s5,s5,4
    80003080:	02c9a783          	lw	a5,44(s3)
    80003084:	04fa5463          	bge	s4,a5,800030cc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003088:	0189a583          	lw	a1,24(s3)
    8000308c:	014585bb          	addw	a1,a1,s4
    80003090:	2585                	addiw	a1,a1,1
    80003092:	0289a503          	lw	a0,40(s3)
    80003096:	902ff0ef          	jal	80002198 <bread>
    8000309a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000309c:	000aa583          	lw	a1,0(s5)
    800030a0:	0289a503          	lw	a0,40(s3)
    800030a4:	8f4ff0ef          	jal	80002198 <bread>
    800030a8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800030aa:	40000613          	li	a2,1024
    800030ae:	05890593          	addi	a1,s2,88
    800030b2:	05850513          	addi	a0,a0,88
    800030b6:	9e8fd0ef          	jal	8000029e <memmove>
    bwrite(dbuf);  // write dst to disk
    800030ba:	8526                	mv	a0,s1
    800030bc:	9b2ff0ef          	jal	8000226e <bwrite>
    if(recovering == 0)
    800030c0:	fa0b18e3          	bnez	s6,80003070 <install_trans+0x36>
      bunpin(dbuf);
    800030c4:	8526                	mv	a0,s1
    800030c6:	a96ff0ef          	jal	8000235c <bunpin>
    800030ca:	b75d                	j	80003070 <install_trans+0x36>
}
    800030cc:	70e2                	ld	ra,56(sp)
    800030ce:	7442                	ld	s0,48(sp)
    800030d0:	74a2                	ld	s1,40(sp)
    800030d2:	7902                	ld	s2,32(sp)
    800030d4:	69e2                	ld	s3,24(sp)
    800030d6:	6a42                	ld	s4,16(sp)
    800030d8:	6aa2                	ld	s5,8(sp)
    800030da:	6b02                	ld	s6,0(sp)
    800030dc:	6121                	addi	sp,sp,64
    800030de:	8082                	ret
    800030e0:	8082                	ret

00000000800030e2 <initlog>:
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	1800                	addi	s0,sp,48
    800030f0:	892a                	mv	s2,a0
    800030f2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800030f4:	00037497          	auipc	s1,0x37
    800030f8:	28c48493          	addi	s1,s1,652 # 8003a380 <log>
    800030fc:	00004597          	auipc	a1,0x4
    80003100:	49458593          	addi	a1,a1,1172 # 80007590 <etext+0x590>
    80003104:	8526                	mv	a0,s1
    80003106:	02b020ef          	jal	80005930 <initlock>
  log.start = sb->logstart;
    8000310a:	0149a583          	lw	a1,20(s3)
    8000310e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003110:	0109a783          	lw	a5,16(s3)
    80003114:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003116:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000311a:	854a                	mv	a0,s2
    8000311c:	87cff0ef          	jal	80002198 <bread>
  log.lh.n = lh->n;
    80003120:	4d30                	lw	a2,88(a0)
    80003122:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003124:	00c05f63          	blez	a2,80003142 <initlog+0x60>
    80003128:	87aa                	mv	a5,a0
    8000312a:	00037717          	auipc	a4,0x37
    8000312e:	28670713          	addi	a4,a4,646 # 8003a3b0 <log+0x30>
    80003132:	060a                	slli	a2,a2,0x2
    80003134:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003136:	4ff4                	lw	a3,92(a5)
    80003138:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000313a:	0791                	addi	a5,a5,4
    8000313c:	0711                	addi	a4,a4,4
    8000313e:	fec79ce3          	bne	a5,a2,80003136 <initlog+0x54>
  brelse(buf);
    80003142:	95eff0ef          	jal	800022a0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003146:	4505                	li	a0,1
    80003148:	ef3ff0ef          	jal	8000303a <install_trans>
  log.lh.n = 0;
    8000314c:	00037797          	auipc	a5,0x37
    80003150:	2607a023          	sw	zero,608(a5) # 8003a3ac <log+0x2c>
  write_head(); // clear the log
    80003154:	e89ff0ef          	jal	80002fdc <write_head>
}
    80003158:	70a2                	ld	ra,40(sp)
    8000315a:	7402                	ld	s0,32(sp)
    8000315c:	64e2                	ld	s1,24(sp)
    8000315e:	6942                	ld	s2,16(sp)
    80003160:	69a2                	ld	s3,8(sp)
    80003162:	6145                	addi	sp,sp,48
    80003164:	8082                	ret

0000000080003166 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003166:	1101                	addi	sp,sp,-32
    80003168:	ec06                	sd	ra,24(sp)
    8000316a:	e822                	sd	s0,16(sp)
    8000316c:	e426                	sd	s1,8(sp)
    8000316e:	e04a                	sd	s2,0(sp)
    80003170:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003172:	00037517          	auipc	a0,0x37
    80003176:	20e50513          	addi	a0,a0,526 # 8003a380 <log>
    8000317a:	037020ef          	jal	800059b0 <acquire>
  while(1){
    if(log.committing){
    8000317e:	00037497          	auipc	s1,0x37
    80003182:	20248493          	addi	s1,s1,514 # 8003a380 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003186:	4979                	li	s2,30
    80003188:	a029                	j	80003192 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000318a:	85a6                	mv	a1,s1
    8000318c:	8526                	mv	a0,s1
    8000318e:	b5cfe0ef          	jal	800014ea <sleep>
    if(log.committing){
    80003192:	50dc                	lw	a5,36(s1)
    80003194:	fbfd                	bnez	a5,8000318a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003196:	5098                	lw	a4,32(s1)
    80003198:	2705                	addiw	a4,a4,1
    8000319a:	0027179b          	slliw	a5,a4,0x2
    8000319e:	9fb9                	addw	a5,a5,a4
    800031a0:	0017979b          	slliw	a5,a5,0x1
    800031a4:	54d4                	lw	a3,44(s1)
    800031a6:	9fb5                	addw	a5,a5,a3
    800031a8:	00f95763          	bge	s2,a5,800031b6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800031ac:	85a6                	mv	a1,s1
    800031ae:	8526                	mv	a0,s1
    800031b0:	b3afe0ef          	jal	800014ea <sleep>
    800031b4:	bff9                	j	80003192 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800031b6:	00037517          	auipc	a0,0x37
    800031ba:	1ca50513          	addi	a0,a0,458 # 8003a380 <log>
    800031be:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800031c0:	089020ef          	jal	80005a48 <release>
      break;
    }
  }
}
    800031c4:	60e2                	ld	ra,24(sp)
    800031c6:	6442                	ld	s0,16(sp)
    800031c8:	64a2                	ld	s1,8(sp)
    800031ca:	6902                	ld	s2,0(sp)
    800031cc:	6105                	addi	sp,sp,32
    800031ce:	8082                	ret

00000000800031d0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800031d0:	7139                	addi	sp,sp,-64
    800031d2:	fc06                	sd	ra,56(sp)
    800031d4:	f822                	sd	s0,48(sp)
    800031d6:	f426                	sd	s1,40(sp)
    800031d8:	f04a                	sd	s2,32(sp)
    800031da:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800031dc:	00037497          	auipc	s1,0x37
    800031e0:	1a448493          	addi	s1,s1,420 # 8003a380 <log>
    800031e4:	8526                	mv	a0,s1
    800031e6:	7ca020ef          	jal	800059b0 <acquire>
  log.outstanding -= 1;
    800031ea:	509c                	lw	a5,32(s1)
    800031ec:	37fd                	addiw	a5,a5,-1
    800031ee:	0007891b          	sext.w	s2,a5
    800031f2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800031f4:	50dc                	lw	a5,36(s1)
    800031f6:	ef9d                	bnez	a5,80003234 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800031f8:	04091763          	bnez	s2,80003246 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800031fc:	00037497          	auipc	s1,0x37
    80003200:	18448493          	addi	s1,s1,388 # 8003a380 <log>
    80003204:	4785                	li	a5,1
    80003206:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003208:	8526                	mv	a0,s1
    8000320a:	03f020ef          	jal	80005a48 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000320e:	54dc                	lw	a5,44(s1)
    80003210:	04f04b63          	bgtz	a5,80003266 <end_op+0x96>
    acquire(&log.lock);
    80003214:	00037497          	auipc	s1,0x37
    80003218:	16c48493          	addi	s1,s1,364 # 8003a380 <log>
    8000321c:	8526                	mv	a0,s1
    8000321e:	792020ef          	jal	800059b0 <acquire>
    log.committing = 0;
    80003222:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003226:	8526                	mv	a0,s1
    80003228:	b0efe0ef          	jal	80001536 <wakeup>
    release(&log.lock);
    8000322c:	8526                	mv	a0,s1
    8000322e:	01b020ef          	jal	80005a48 <release>
}
    80003232:	a025                	j	8000325a <end_op+0x8a>
    80003234:	ec4e                	sd	s3,24(sp)
    80003236:	e852                	sd	s4,16(sp)
    80003238:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000323a:	00004517          	auipc	a0,0x4
    8000323e:	35e50513          	addi	a0,a0,862 # 80007598 <etext+0x598>
    80003242:	440020ef          	jal	80005682 <panic>
    wakeup(&log);
    80003246:	00037497          	auipc	s1,0x37
    8000324a:	13a48493          	addi	s1,s1,314 # 8003a380 <log>
    8000324e:	8526                	mv	a0,s1
    80003250:	ae6fe0ef          	jal	80001536 <wakeup>
  release(&log.lock);
    80003254:	8526                	mv	a0,s1
    80003256:	7f2020ef          	jal	80005a48 <release>
}
    8000325a:	70e2                	ld	ra,56(sp)
    8000325c:	7442                	ld	s0,48(sp)
    8000325e:	74a2                	ld	s1,40(sp)
    80003260:	7902                	ld	s2,32(sp)
    80003262:	6121                	addi	sp,sp,64
    80003264:	8082                	ret
    80003266:	ec4e                	sd	s3,24(sp)
    80003268:	e852                	sd	s4,16(sp)
    8000326a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000326c:	00037a97          	auipc	s5,0x37
    80003270:	144a8a93          	addi	s5,s5,324 # 8003a3b0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003274:	00037a17          	auipc	s4,0x37
    80003278:	10ca0a13          	addi	s4,s4,268 # 8003a380 <log>
    8000327c:	018a2583          	lw	a1,24(s4)
    80003280:	012585bb          	addw	a1,a1,s2
    80003284:	2585                	addiw	a1,a1,1
    80003286:	028a2503          	lw	a0,40(s4)
    8000328a:	f0ffe0ef          	jal	80002198 <bread>
    8000328e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003290:	000aa583          	lw	a1,0(s5)
    80003294:	028a2503          	lw	a0,40(s4)
    80003298:	f01fe0ef          	jal	80002198 <bread>
    8000329c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000329e:	40000613          	li	a2,1024
    800032a2:	05850593          	addi	a1,a0,88
    800032a6:	05848513          	addi	a0,s1,88
    800032aa:	ff5fc0ef          	jal	8000029e <memmove>
    bwrite(to);  // write the log
    800032ae:	8526                	mv	a0,s1
    800032b0:	fbffe0ef          	jal	8000226e <bwrite>
    brelse(from);
    800032b4:	854e                	mv	a0,s3
    800032b6:	febfe0ef          	jal	800022a0 <brelse>
    brelse(to);
    800032ba:	8526                	mv	a0,s1
    800032bc:	fe5fe0ef          	jal	800022a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800032c0:	2905                	addiw	s2,s2,1
    800032c2:	0a91                	addi	s5,s5,4
    800032c4:	02ca2783          	lw	a5,44(s4)
    800032c8:	faf94ae3          	blt	s2,a5,8000327c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800032cc:	d11ff0ef          	jal	80002fdc <write_head>
    install_trans(0); // Now install writes to home locations
    800032d0:	4501                	li	a0,0
    800032d2:	d69ff0ef          	jal	8000303a <install_trans>
    log.lh.n = 0;
    800032d6:	00037797          	auipc	a5,0x37
    800032da:	0c07ab23          	sw	zero,214(a5) # 8003a3ac <log+0x2c>
    write_head();    // Erase the transaction from the log
    800032de:	cffff0ef          	jal	80002fdc <write_head>
    800032e2:	69e2                	ld	s3,24(sp)
    800032e4:	6a42                	ld	s4,16(sp)
    800032e6:	6aa2                	ld	s5,8(sp)
    800032e8:	b735                	j	80003214 <end_op+0x44>

00000000800032ea <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800032ea:	1101                	addi	sp,sp,-32
    800032ec:	ec06                	sd	ra,24(sp)
    800032ee:	e822                	sd	s0,16(sp)
    800032f0:	e426                	sd	s1,8(sp)
    800032f2:	e04a                	sd	s2,0(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800032f8:	00037917          	auipc	s2,0x37
    800032fc:	08890913          	addi	s2,s2,136 # 8003a380 <log>
    80003300:	854a                	mv	a0,s2
    80003302:	6ae020ef          	jal	800059b0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003306:	02c92603          	lw	a2,44(s2)
    8000330a:	47f5                	li	a5,29
    8000330c:	06c7c363          	blt	a5,a2,80003372 <log_write+0x88>
    80003310:	00037797          	auipc	a5,0x37
    80003314:	08c7a783          	lw	a5,140(a5) # 8003a39c <log+0x1c>
    80003318:	37fd                	addiw	a5,a5,-1
    8000331a:	04f65c63          	bge	a2,a5,80003372 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000331e:	00037797          	auipc	a5,0x37
    80003322:	0827a783          	lw	a5,130(a5) # 8003a3a0 <log+0x20>
    80003326:	04f05c63          	blez	a5,8000337e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000332a:	4781                	li	a5,0
    8000332c:	04c05f63          	blez	a2,8000338a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003330:	44cc                	lw	a1,12(s1)
    80003332:	00037717          	auipc	a4,0x37
    80003336:	07e70713          	addi	a4,a4,126 # 8003a3b0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000333a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000333c:	4314                	lw	a3,0(a4)
    8000333e:	04b68663          	beq	a3,a1,8000338a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003342:	2785                	addiw	a5,a5,1
    80003344:	0711                	addi	a4,a4,4
    80003346:	fef61be3          	bne	a2,a5,8000333c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000334a:	0621                	addi	a2,a2,8
    8000334c:	060a                	slli	a2,a2,0x2
    8000334e:	00037797          	auipc	a5,0x37
    80003352:	03278793          	addi	a5,a5,50 # 8003a380 <log>
    80003356:	97b2                	add	a5,a5,a2
    80003358:	44d8                	lw	a4,12(s1)
    8000335a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000335c:	8526                	mv	a0,s1
    8000335e:	fcbfe0ef          	jal	80002328 <bpin>
    log.lh.n++;
    80003362:	00037717          	auipc	a4,0x37
    80003366:	01e70713          	addi	a4,a4,30 # 8003a380 <log>
    8000336a:	575c                	lw	a5,44(a4)
    8000336c:	2785                	addiw	a5,a5,1
    8000336e:	d75c                	sw	a5,44(a4)
    80003370:	a80d                	j	800033a2 <log_write+0xb8>
    panic("too big a transaction");
    80003372:	00004517          	auipc	a0,0x4
    80003376:	23650513          	addi	a0,a0,566 # 800075a8 <etext+0x5a8>
    8000337a:	308020ef          	jal	80005682 <panic>
    panic("log_write outside of trans");
    8000337e:	00004517          	auipc	a0,0x4
    80003382:	24250513          	addi	a0,a0,578 # 800075c0 <etext+0x5c0>
    80003386:	2fc020ef          	jal	80005682 <panic>
  log.lh.block[i] = b->blockno;
    8000338a:	00878693          	addi	a3,a5,8
    8000338e:	068a                	slli	a3,a3,0x2
    80003390:	00037717          	auipc	a4,0x37
    80003394:	ff070713          	addi	a4,a4,-16 # 8003a380 <log>
    80003398:	9736                	add	a4,a4,a3
    8000339a:	44d4                	lw	a3,12(s1)
    8000339c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000339e:	faf60fe3          	beq	a2,a5,8000335c <log_write+0x72>
  }
  release(&log.lock);
    800033a2:	00037517          	auipc	a0,0x37
    800033a6:	fde50513          	addi	a0,a0,-34 # 8003a380 <log>
    800033aa:	69e020ef          	jal	80005a48 <release>
}
    800033ae:	60e2                	ld	ra,24(sp)
    800033b0:	6442                	ld	s0,16(sp)
    800033b2:	64a2                	ld	s1,8(sp)
    800033b4:	6902                	ld	s2,0(sp)
    800033b6:	6105                	addi	sp,sp,32
    800033b8:	8082                	ret

00000000800033ba <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800033ba:	1101                	addi	sp,sp,-32
    800033bc:	ec06                	sd	ra,24(sp)
    800033be:	e822                	sd	s0,16(sp)
    800033c0:	e426                	sd	s1,8(sp)
    800033c2:	e04a                	sd	s2,0(sp)
    800033c4:	1000                	addi	s0,sp,32
    800033c6:	84aa                	mv	s1,a0
    800033c8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800033ca:	00004597          	auipc	a1,0x4
    800033ce:	21658593          	addi	a1,a1,534 # 800075e0 <etext+0x5e0>
    800033d2:	0521                	addi	a0,a0,8
    800033d4:	55c020ef          	jal	80005930 <initlock>
  lk->name = name;
    800033d8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800033dc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800033e0:	0204a423          	sw	zero,40(s1)
}
    800033e4:	60e2                	ld	ra,24(sp)
    800033e6:	6442                	ld	s0,16(sp)
    800033e8:	64a2                	ld	s1,8(sp)
    800033ea:	6902                	ld	s2,0(sp)
    800033ec:	6105                	addi	sp,sp,32
    800033ee:	8082                	ret

00000000800033f0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	e426                	sd	s1,8(sp)
    800033f8:	e04a                	sd	s2,0(sp)
    800033fa:	1000                	addi	s0,sp,32
    800033fc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800033fe:	00850913          	addi	s2,a0,8
    80003402:	854a                	mv	a0,s2
    80003404:	5ac020ef          	jal	800059b0 <acquire>
  while (lk->locked) {
    80003408:	409c                	lw	a5,0(s1)
    8000340a:	c799                	beqz	a5,80003418 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000340c:	85ca                	mv	a1,s2
    8000340e:	8526                	mv	a0,s1
    80003410:	8dafe0ef          	jal	800014ea <sleep>
  while (lk->locked) {
    80003414:	409c                	lw	a5,0(s1)
    80003416:	fbfd                	bnez	a5,8000340c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003418:	4785                	li	a5,1
    8000341a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000341c:	b01fd0ef          	jal	80000f1c <myproc>
    80003420:	591c                	lw	a5,48(a0)
    80003422:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003424:	854a                	mv	a0,s2
    80003426:	622020ef          	jal	80005a48 <release>
}
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	64a2                	ld	s1,8(sp)
    80003430:	6902                	ld	s2,0(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret

0000000080003436 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003436:	1101                	addi	sp,sp,-32
    80003438:	ec06                	sd	ra,24(sp)
    8000343a:	e822                	sd	s0,16(sp)
    8000343c:	e426                	sd	s1,8(sp)
    8000343e:	e04a                	sd	s2,0(sp)
    80003440:	1000                	addi	s0,sp,32
    80003442:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003444:	00850913          	addi	s2,a0,8
    80003448:	854a                	mv	a0,s2
    8000344a:	566020ef          	jal	800059b0 <acquire>
  lk->locked = 0;
    8000344e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003452:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003456:	8526                	mv	a0,s1
    80003458:	8defe0ef          	jal	80001536 <wakeup>
  release(&lk->lk);
    8000345c:	854a                	mv	a0,s2
    8000345e:	5ea020ef          	jal	80005a48 <release>
}
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6902                	ld	s2,0(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret

000000008000346e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000346e:	7179                	addi	sp,sp,-48
    80003470:	f406                	sd	ra,40(sp)
    80003472:	f022                	sd	s0,32(sp)
    80003474:	ec26                	sd	s1,24(sp)
    80003476:	e84a                	sd	s2,16(sp)
    80003478:	1800                	addi	s0,sp,48
    8000347a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000347c:	00850913          	addi	s2,a0,8
    80003480:	854a                	mv	a0,s2
    80003482:	52e020ef          	jal	800059b0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003486:	409c                	lw	a5,0(s1)
    80003488:	ef81                	bnez	a5,800034a0 <holdingsleep+0x32>
    8000348a:	4481                	li	s1,0
  release(&lk->lk);
    8000348c:	854a                	mv	a0,s2
    8000348e:	5ba020ef          	jal	80005a48 <release>
  return r;
}
    80003492:	8526                	mv	a0,s1
    80003494:	70a2                	ld	ra,40(sp)
    80003496:	7402                	ld	s0,32(sp)
    80003498:	64e2                	ld	s1,24(sp)
    8000349a:	6942                	ld	s2,16(sp)
    8000349c:	6145                	addi	sp,sp,48
    8000349e:	8082                	ret
    800034a0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800034a2:	0284a983          	lw	s3,40(s1)
    800034a6:	a77fd0ef          	jal	80000f1c <myproc>
    800034aa:	5904                	lw	s1,48(a0)
    800034ac:	413484b3          	sub	s1,s1,s3
    800034b0:	0014b493          	seqz	s1,s1
    800034b4:	69a2                	ld	s3,8(sp)
    800034b6:	bfd9                	j	8000348c <holdingsleep+0x1e>

00000000800034b8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800034b8:	1141                	addi	sp,sp,-16
    800034ba:	e406                	sd	ra,8(sp)
    800034bc:	e022                	sd	s0,0(sp)
    800034be:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800034c0:	00004597          	auipc	a1,0x4
    800034c4:	13058593          	addi	a1,a1,304 # 800075f0 <etext+0x5f0>
    800034c8:	00037517          	auipc	a0,0x37
    800034cc:	00050513          	mv	a0,a0
    800034d0:	460020ef          	jal	80005930 <initlock>
}
    800034d4:	60a2                	ld	ra,8(sp)
    800034d6:	6402                	ld	s0,0(sp)
    800034d8:	0141                	addi	sp,sp,16
    800034da:	8082                	ret

00000000800034dc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800034dc:	1101                	addi	sp,sp,-32
    800034de:	ec06                	sd	ra,24(sp)
    800034e0:	e822                	sd	s0,16(sp)
    800034e2:	e426                	sd	s1,8(sp)
    800034e4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800034e6:	00037517          	auipc	a0,0x37
    800034ea:	fe250513          	addi	a0,a0,-30 # 8003a4c8 <ftable>
    800034ee:	4c2020ef          	jal	800059b0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034f2:	00037497          	auipc	s1,0x37
    800034f6:	fee48493          	addi	s1,s1,-18 # 8003a4e0 <ftable+0x18>
    800034fa:	00038717          	auipc	a4,0x38
    800034fe:	f8670713          	addi	a4,a4,-122 # 8003b480 <disk>
    if(f->ref == 0){
    80003502:	40dc                	lw	a5,4(s1)
    80003504:	cf89                	beqz	a5,8000351e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003506:	02848493          	addi	s1,s1,40
    8000350a:	fee49ce3          	bne	s1,a4,80003502 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000350e:	00037517          	auipc	a0,0x37
    80003512:	fba50513          	addi	a0,a0,-70 # 8003a4c8 <ftable>
    80003516:	532020ef          	jal	80005a48 <release>
  return 0;
    8000351a:	4481                	li	s1,0
    8000351c:	a809                	j	8000352e <filealloc+0x52>
      f->ref = 1;
    8000351e:	4785                	li	a5,1
    80003520:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003522:	00037517          	auipc	a0,0x37
    80003526:	fa650513          	addi	a0,a0,-90 # 8003a4c8 <ftable>
    8000352a:	51e020ef          	jal	80005a48 <release>
}
    8000352e:	8526                	mv	a0,s1
    80003530:	60e2                	ld	ra,24(sp)
    80003532:	6442                	ld	s0,16(sp)
    80003534:	64a2                	ld	s1,8(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret

000000008000353a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	e426                	sd	s1,8(sp)
    80003542:	1000                	addi	s0,sp,32
    80003544:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003546:	00037517          	auipc	a0,0x37
    8000354a:	f8250513          	addi	a0,a0,-126 # 8003a4c8 <ftable>
    8000354e:	462020ef          	jal	800059b0 <acquire>
  if(f->ref < 1)
    80003552:	40dc                	lw	a5,4(s1)
    80003554:	02f05063          	blez	a5,80003574 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003558:	2785                	addiw	a5,a5,1
    8000355a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000355c:	00037517          	auipc	a0,0x37
    80003560:	f6c50513          	addi	a0,a0,-148 # 8003a4c8 <ftable>
    80003564:	4e4020ef          	jal	80005a48 <release>
  return f;
}
    80003568:	8526                	mv	a0,s1
    8000356a:	60e2                	ld	ra,24(sp)
    8000356c:	6442                	ld	s0,16(sp)
    8000356e:	64a2                	ld	s1,8(sp)
    80003570:	6105                	addi	sp,sp,32
    80003572:	8082                	ret
    panic("filedup");
    80003574:	00004517          	auipc	a0,0x4
    80003578:	08450513          	addi	a0,a0,132 # 800075f8 <etext+0x5f8>
    8000357c:	106020ef          	jal	80005682 <panic>

0000000080003580 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003580:	7139                	addi	sp,sp,-64
    80003582:	fc06                	sd	ra,56(sp)
    80003584:	f822                	sd	s0,48(sp)
    80003586:	f426                	sd	s1,40(sp)
    80003588:	0080                	addi	s0,sp,64
    8000358a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000358c:	00037517          	auipc	a0,0x37
    80003590:	f3c50513          	addi	a0,a0,-196 # 8003a4c8 <ftable>
    80003594:	41c020ef          	jal	800059b0 <acquire>
  if(f->ref < 1)
    80003598:	40dc                	lw	a5,4(s1)
    8000359a:	04f05a63          	blez	a5,800035ee <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000359e:	37fd                	addiw	a5,a5,-1
    800035a0:	0007871b          	sext.w	a4,a5
    800035a4:	c0dc                	sw	a5,4(s1)
    800035a6:	04e04e63          	bgtz	a4,80003602 <fileclose+0x82>
    800035aa:	f04a                	sd	s2,32(sp)
    800035ac:	ec4e                	sd	s3,24(sp)
    800035ae:	e852                	sd	s4,16(sp)
    800035b0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800035b2:	0004a903          	lw	s2,0(s1)
    800035b6:	0094ca83          	lbu	s5,9(s1)
    800035ba:	0104ba03          	ld	s4,16(s1)
    800035be:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800035c2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800035c6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800035ca:	00037517          	auipc	a0,0x37
    800035ce:	efe50513          	addi	a0,a0,-258 # 8003a4c8 <ftable>
    800035d2:	476020ef          	jal	80005a48 <release>

  if(ff.type == FD_PIPE){
    800035d6:	4785                	li	a5,1
    800035d8:	04f90063          	beq	s2,a5,80003618 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800035dc:	3979                	addiw	s2,s2,-2
    800035de:	4785                	li	a5,1
    800035e0:	0527f563          	bgeu	a5,s2,8000362a <fileclose+0xaa>
    800035e4:	7902                	ld	s2,32(sp)
    800035e6:	69e2                	ld	s3,24(sp)
    800035e8:	6a42                	ld	s4,16(sp)
    800035ea:	6aa2                	ld	s5,8(sp)
    800035ec:	a00d                	j	8000360e <fileclose+0x8e>
    800035ee:	f04a                	sd	s2,32(sp)
    800035f0:	ec4e                	sd	s3,24(sp)
    800035f2:	e852                	sd	s4,16(sp)
    800035f4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800035f6:	00004517          	auipc	a0,0x4
    800035fa:	00a50513          	addi	a0,a0,10 # 80007600 <etext+0x600>
    800035fe:	084020ef          	jal	80005682 <panic>
    release(&ftable.lock);
    80003602:	00037517          	auipc	a0,0x37
    80003606:	ec650513          	addi	a0,a0,-314 # 8003a4c8 <ftable>
    8000360a:	43e020ef          	jal	80005a48 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000360e:	70e2                	ld	ra,56(sp)
    80003610:	7442                	ld	s0,48(sp)
    80003612:	74a2                	ld	s1,40(sp)
    80003614:	6121                	addi	sp,sp,64
    80003616:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003618:	85d6                	mv	a1,s5
    8000361a:	8552                	mv	a0,s4
    8000361c:	336000ef          	jal	80003952 <pipeclose>
    80003620:	7902                	ld	s2,32(sp)
    80003622:	69e2                	ld	s3,24(sp)
    80003624:	6a42                	ld	s4,16(sp)
    80003626:	6aa2                	ld	s5,8(sp)
    80003628:	b7dd                	j	8000360e <fileclose+0x8e>
    begin_op();
    8000362a:	b3dff0ef          	jal	80003166 <begin_op>
    iput(ff.ip);
    8000362e:	854e                	mv	a0,s3
    80003630:	c22ff0ef          	jal	80002a52 <iput>
    end_op();
    80003634:	b9dff0ef          	jal	800031d0 <end_op>
    80003638:	7902                	ld	s2,32(sp)
    8000363a:	69e2                	ld	s3,24(sp)
    8000363c:	6a42                	ld	s4,16(sp)
    8000363e:	6aa2                	ld	s5,8(sp)
    80003640:	b7f9                	j	8000360e <fileclose+0x8e>

0000000080003642 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003642:	715d                	addi	sp,sp,-80
    80003644:	e486                	sd	ra,72(sp)
    80003646:	e0a2                	sd	s0,64(sp)
    80003648:	fc26                	sd	s1,56(sp)
    8000364a:	f44e                	sd	s3,40(sp)
    8000364c:	0880                	addi	s0,sp,80
    8000364e:	84aa                	mv	s1,a0
    80003650:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003652:	8cbfd0ef          	jal	80000f1c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003656:	409c                	lw	a5,0(s1)
    80003658:	37f9                	addiw	a5,a5,-2
    8000365a:	4705                	li	a4,1
    8000365c:	04f76063          	bltu	a4,a5,8000369c <filestat+0x5a>
    80003660:	f84a                	sd	s2,48(sp)
    80003662:	892a                	mv	s2,a0
    ilock(f->ip);
    80003664:	6c88                	ld	a0,24(s1)
    80003666:	a6aff0ef          	jal	800028d0 <ilock>
    stati(f->ip, &st);
    8000366a:	fb840593          	addi	a1,s0,-72
    8000366e:	6c88                	ld	a0,24(s1)
    80003670:	c8aff0ef          	jal	80002afa <stati>
    iunlock(f->ip);
    80003674:	6c88                	ld	a0,24(s1)
    80003676:	b08ff0ef          	jal	8000297e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000367a:	46e1                	li	a3,24
    8000367c:	fb840613          	addi	a2,s0,-72
    80003680:	85ce                	mv	a1,s3
    80003682:	05093503          	ld	a0,80(s2)
    80003686:	c58fd0ef          	jal	80000ade <copyout>
    8000368a:	41f5551b          	sraiw	a0,a0,0x1f
    8000368e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003690:	60a6                	ld	ra,72(sp)
    80003692:	6406                	ld	s0,64(sp)
    80003694:	74e2                	ld	s1,56(sp)
    80003696:	79a2                	ld	s3,40(sp)
    80003698:	6161                	addi	sp,sp,80
    8000369a:	8082                	ret
  return -1;
    8000369c:	557d                	li	a0,-1
    8000369e:	bfcd                	j	80003690 <filestat+0x4e>

00000000800036a0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800036a0:	7179                	addi	sp,sp,-48
    800036a2:	f406                	sd	ra,40(sp)
    800036a4:	f022                	sd	s0,32(sp)
    800036a6:	e84a                	sd	s2,16(sp)
    800036a8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800036aa:	00854783          	lbu	a5,8(a0)
    800036ae:	cfd1                	beqz	a5,8000374a <fileread+0xaa>
    800036b0:	ec26                	sd	s1,24(sp)
    800036b2:	e44e                	sd	s3,8(sp)
    800036b4:	84aa                	mv	s1,a0
    800036b6:	89ae                	mv	s3,a1
    800036b8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800036ba:	411c                	lw	a5,0(a0)
    800036bc:	4705                	li	a4,1
    800036be:	04e78363          	beq	a5,a4,80003704 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800036c2:	470d                	li	a4,3
    800036c4:	04e78763          	beq	a5,a4,80003712 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800036c8:	4709                	li	a4,2
    800036ca:	06e79a63          	bne	a5,a4,8000373e <fileread+0x9e>
    ilock(f->ip);
    800036ce:	6d08                	ld	a0,24(a0)
    800036d0:	a00ff0ef          	jal	800028d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800036d4:	874a                	mv	a4,s2
    800036d6:	5094                	lw	a3,32(s1)
    800036d8:	864e                	mv	a2,s3
    800036da:	4585                	li	a1,1
    800036dc:	6c88                	ld	a0,24(s1)
    800036de:	c46ff0ef          	jal	80002b24 <readi>
    800036e2:	892a                	mv	s2,a0
    800036e4:	00a05563          	blez	a0,800036ee <fileread+0x4e>
      f->off += r;
    800036e8:	509c                	lw	a5,32(s1)
    800036ea:	9fa9                	addw	a5,a5,a0
    800036ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800036ee:	6c88                	ld	a0,24(s1)
    800036f0:	a8eff0ef          	jal	8000297e <iunlock>
    800036f4:	64e2                	ld	s1,24(sp)
    800036f6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800036f8:	854a                	mv	a0,s2
    800036fa:	70a2                	ld	ra,40(sp)
    800036fc:	7402                	ld	s0,32(sp)
    800036fe:	6942                	ld	s2,16(sp)
    80003700:	6145                	addi	sp,sp,48
    80003702:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003704:	6908                	ld	a0,16(a0)
    80003706:	388000ef          	jal	80003a8e <piperead>
    8000370a:	892a                	mv	s2,a0
    8000370c:	64e2                	ld	s1,24(sp)
    8000370e:	69a2                	ld	s3,8(sp)
    80003710:	b7e5                	j	800036f8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003712:	02451783          	lh	a5,36(a0)
    80003716:	03079693          	slli	a3,a5,0x30
    8000371a:	92c1                	srli	a3,a3,0x30
    8000371c:	4725                	li	a4,9
    8000371e:	02d76863          	bltu	a4,a3,8000374e <fileread+0xae>
    80003722:	0792                	slli	a5,a5,0x4
    80003724:	00037717          	auipc	a4,0x37
    80003728:	d0470713          	addi	a4,a4,-764 # 8003a428 <devsw>
    8000372c:	97ba                	add	a5,a5,a4
    8000372e:	639c                	ld	a5,0(a5)
    80003730:	c39d                	beqz	a5,80003756 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003732:	4505                	li	a0,1
    80003734:	9782                	jalr	a5
    80003736:	892a                	mv	s2,a0
    80003738:	64e2                	ld	s1,24(sp)
    8000373a:	69a2                	ld	s3,8(sp)
    8000373c:	bf75                	j	800036f8 <fileread+0x58>
    panic("fileread");
    8000373e:	00004517          	auipc	a0,0x4
    80003742:	ed250513          	addi	a0,a0,-302 # 80007610 <etext+0x610>
    80003746:	73d010ef          	jal	80005682 <panic>
    return -1;
    8000374a:	597d                	li	s2,-1
    8000374c:	b775                	j	800036f8 <fileread+0x58>
      return -1;
    8000374e:	597d                	li	s2,-1
    80003750:	64e2                	ld	s1,24(sp)
    80003752:	69a2                	ld	s3,8(sp)
    80003754:	b755                	j	800036f8 <fileread+0x58>
    80003756:	597d                	li	s2,-1
    80003758:	64e2                	ld	s1,24(sp)
    8000375a:	69a2                	ld	s3,8(sp)
    8000375c:	bf71                	j	800036f8 <fileread+0x58>

000000008000375e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000375e:	00954783          	lbu	a5,9(a0)
    80003762:	10078b63          	beqz	a5,80003878 <filewrite+0x11a>
{
    80003766:	715d                	addi	sp,sp,-80
    80003768:	e486                	sd	ra,72(sp)
    8000376a:	e0a2                	sd	s0,64(sp)
    8000376c:	f84a                	sd	s2,48(sp)
    8000376e:	f052                	sd	s4,32(sp)
    80003770:	e85a                	sd	s6,16(sp)
    80003772:	0880                	addi	s0,sp,80
    80003774:	892a                	mv	s2,a0
    80003776:	8b2e                	mv	s6,a1
    80003778:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000377a:	411c                	lw	a5,0(a0)
    8000377c:	4705                	li	a4,1
    8000377e:	02e78763          	beq	a5,a4,800037ac <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003782:	470d                	li	a4,3
    80003784:	02e78863          	beq	a5,a4,800037b4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003788:	4709                	li	a4,2
    8000378a:	0ce79c63          	bne	a5,a4,80003862 <filewrite+0x104>
    8000378e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003790:	0ac05863          	blez	a2,80003840 <filewrite+0xe2>
    80003794:	fc26                	sd	s1,56(sp)
    80003796:	ec56                	sd	s5,24(sp)
    80003798:	e45e                	sd	s7,8(sp)
    8000379a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000379c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000379e:	6b85                	lui	s7,0x1
    800037a0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800037a4:	6c05                	lui	s8,0x1
    800037a6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800037aa:	a8b5                	j	80003826 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800037ac:	6908                	ld	a0,16(a0)
    800037ae:	1fc000ef          	jal	800039aa <pipewrite>
    800037b2:	a04d                	j	80003854 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800037b4:	02451783          	lh	a5,36(a0)
    800037b8:	03079693          	slli	a3,a5,0x30
    800037bc:	92c1                	srli	a3,a3,0x30
    800037be:	4725                	li	a4,9
    800037c0:	0ad76e63          	bltu	a4,a3,8000387c <filewrite+0x11e>
    800037c4:	0792                	slli	a5,a5,0x4
    800037c6:	00037717          	auipc	a4,0x37
    800037ca:	c6270713          	addi	a4,a4,-926 # 8003a428 <devsw>
    800037ce:	97ba                	add	a5,a5,a4
    800037d0:	679c                	ld	a5,8(a5)
    800037d2:	c7dd                	beqz	a5,80003880 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800037d4:	4505                	li	a0,1
    800037d6:	9782                	jalr	a5
    800037d8:	a8b5                	j	80003854 <filewrite+0xf6>
      if(n1 > max)
    800037da:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800037de:	989ff0ef          	jal	80003166 <begin_op>
      ilock(f->ip);
    800037e2:	01893503          	ld	a0,24(s2)
    800037e6:	8eaff0ef          	jal	800028d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800037ea:	8756                	mv	a4,s5
    800037ec:	02092683          	lw	a3,32(s2)
    800037f0:	01698633          	add	a2,s3,s6
    800037f4:	4585                	li	a1,1
    800037f6:	01893503          	ld	a0,24(s2)
    800037fa:	c26ff0ef          	jal	80002c20 <writei>
    800037fe:	84aa                	mv	s1,a0
    80003800:	00a05763          	blez	a0,8000380e <filewrite+0xb0>
        f->off += r;
    80003804:	02092783          	lw	a5,32(s2)
    80003808:	9fa9                	addw	a5,a5,a0
    8000380a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000380e:	01893503          	ld	a0,24(s2)
    80003812:	96cff0ef          	jal	8000297e <iunlock>
      end_op();
    80003816:	9bbff0ef          	jal	800031d0 <end_op>

      if(r != n1){
    8000381a:	029a9563          	bne	s5,s1,80003844 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000381e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003822:	0149da63          	bge	s3,s4,80003836 <filewrite+0xd8>
      int n1 = n - i;
    80003826:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000382a:	0004879b          	sext.w	a5,s1
    8000382e:	fafbd6e3          	bge	s7,a5,800037da <filewrite+0x7c>
    80003832:	84e2                	mv	s1,s8
    80003834:	b75d                	j	800037da <filewrite+0x7c>
    80003836:	74e2                	ld	s1,56(sp)
    80003838:	6ae2                	ld	s5,24(sp)
    8000383a:	6ba2                	ld	s7,8(sp)
    8000383c:	6c02                	ld	s8,0(sp)
    8000383e:	a039                	j	8000384c <filewrite+0xee>
    int i = 0;
    80003840:	4981                	li	s3,0
    80003842:	a029                	j	8000384c <filewrite+0xee>
    80003844:	74e2                	ld	s1,56(sp)
    80003846:	6ae2                	ld	s5,24(sp)
    80003848:	6ba2                	ld	s7,8(sp)
    8000384a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000384c:	033a1c63          	bne	s4,s3,80003884 <filewrite+0x126>
    80003850:	8552                	mv	a0,s4
    80003852:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003854:	60a6                	ld	ra,72(sp)
    80003856:	6406                	ld	s0,64(sp)
    80003858:	7942                	ld	s2,48(sp)
    8000385a:	7a02                	ld	s4,32(sp)
    8000385c:	6b42                	ld	s6,16(sp)
    8000385e:	6161                	addi	sp,sp,80
    80003860:	8082                	ret
    80003862:	fc26                	sd	s1,56(sp)
    80003864:	f44e                	sd	s3,40(sp)
    80003866:	ec56                	sd	s5,24(sp)
    80003868:	e45e                	sd	s7,8(sp)
    8000386a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000386c:	00004517          	auipc	a0,0x4
    80003870:	db450513          	addi	a0,a0,-588 # 80007620 <etext+0x620>
    80003874:	60f010ef          	jal	80005682 <panic>
    return -1;
    80003878:	557d                	li	a0,-1
}
    8000387a:	8082                	ret
      return -1;
    8000387c:	557d                	li	a0,-1
    8000387e:	bfd9                	j	80003854 <filewrite+0xf6>
    80003880:	557d                	li	a0,-1
    80003882:	bfc9                	j	80003854 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80003884:	557d                	li	a0,-1
    80003886:	79a2                	ld	s3,40(sp)
    80003888:	b7f1                	j	80003854 <filewrite+0xf6>

000000008000388a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000388a:	7179                	addi	sp,sp,-48
    8000388c:	f406                	sd	ra,40(sp)
    8000388e:	f022                	sd	s0,32(sp)
    80003890:	ec26                	sd	s1,24(sp)
    80003892:	e052                	sd	s4,0(sp)
    80003894:	1800                	addi	s0,sp,48
    80003896:	84aa                	mv	s1,a0
    80003898:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000389a:	0005b023          	sd	zero,0(a1)
    8000389e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800038a2:	c3bff0ef          	jal	800034dc <filealloc>
    800038a6:	e088                	sd	a0,0(s1)
    800038a8:	c549                	beqz	a0,80003932 <pipealloc+0xa8>
    800038aa:	c33ff0ef          	jal	800034dc <filealloc>
    800038ae:	00aa3023          	sd	a0,0(s4)
    800038b2:	cd25                	beqz	a0,8000392a <pipealloc+0xa0>
    800038b4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800038b6:	923fc0ef          	jal	800001d8 <kalloc>
    800038ba:	892a                	mv	s2,a0
    800038bc:	c12d                	beqz	a0,8000391e <pipealloc+0x94>
    800038be:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800038c0:	4985                	li	s3,1
    800038c2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800038c6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800038ca:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800038ce:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800038d2:	00004597          	auipc	a1,0x4
    800038d6:	d5e58593          	addi	a1,a1,-674 # 80007630 <etext+0x630>
    800038da:	056020ef          	jal	80005930 <initlock>
  (*f0)->type = FD_PIPE;
    800038de:	609c                	ld	a5,0(s1)
    800038e0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800038e4:	609c                	ld	a5,0(s1)
    800038e6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800038ea:	609c                	ld	a5,0(s1)
    800038ec:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800038f0:	609c                	ld	a5,0(s1)
    800038f2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800038f6:	000a3783          	ld	a5,0(s4)
    800038fa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800038fe:	000a3783          	ld	a5,0(s4)
    80003902:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003906:	000a3783          	ld	a5,0(s4)
    8000390a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000390e:	000a3783          	ld	a5,0(s4)
    80003912:	0127b823          	sd	s2,16(a5)
  return 0;
    80003916:	4501                	li	a0,0
    80003918:	6942                	ld	s2,16(sp)
    8000391a:	69a2                	ld	s3,8(sp)
    8000391c:	a01d                	j	80003942 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000391e:	6088                	ld	a0,0(s1)
    80003920:	c119                	beqz	a0,80003926 <pipealloc+0x9c>
    80003922:	6942                	ld	s2,16(sp)
    80003924:	a029                	j	8000392e <pipealloc+0xa4>
    80003926:	6942                	ld	s2,16(sp)
    80003928:	a029                	j	80003932 <pipealloc+0xa8>
    8000392a:	6088                	ld	a0,0(s1)
    8000392c:	c10d                	beqz	a0,8000394e <pipealloc+0xc4>
    fileclose(*f0);
    8000392e:	c53ff0ef          	jal	80003580 <fileclose>
  if(*f1)
    80003932:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003936:	557d                	li	a0,-1
  if(*f1)
    80003938:	c789                	beqz	a5,80003942 <pipealloc+0xb8>
    fileclose(*f1);
    8000393a:	853e                	mv	a0,a5
    8000393c:	c45ff0ef          	jal	80003580 <fileclose>
  return -1;
    80003940:	557d                	li	a0,-1
}
    80003942:	70a2                	ld	ra,40(sp)
    80003944:	7402                	ld	s0,32(sp)
    80003946:	64e2                	ld	s1,24(sp)
    80003948:	6a02                	ld	s4,0(sp)
    8000394a:	6145                	addi	sp,sp,48
    8000394c:	8082                	ret
  return -1;
    8000394e:	557d                	li	a0,-1
    80003950:	bfcd                	j	80003942 <pipealloc+0xb8>

0000000080003952 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003952:	1101                	addi	sp,sp,-32
    80003954:	ec06                	sd	ra,24(sp)
    80003956:	e822                	sd	s0,16(sp)
    80003958:	e426                	sd	s1,8(sp)
    8000395a:	e04a                	sd	s2,0(sp)
    8000395c:	1000                	addi	s0,sp,32
    8000395e:	84aa                	mv	s1,a0
    80003960:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003962:	04e020ef          	jal	800059b0 <acquire>
  if(writable){
    80003966:	02090763          	beqz	s2,80003994 <pipeclose+0x42>
    pi->writeopen = 0;
    8000396a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000396e:	21848513          	addi	a0,s1,536
    80003972:	bc5fd0ef          	jal	80001536 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003976:	2204b783          	ld	a5,544(s1)
    8000397a:	e785                	bnez	a5,800039a2 <pipeclose+0x50>
    release(&pi->lock);
    8000397c:	8526                	mv	a0,s1
    8000397e:	0ca020ef          	jal	80005a48 <release>
    kfree((char*)pi);
    80003982:	8526                	mv	a0,s1
    80003984:	f2cfc0ef          	jal	800000b0 <kfree>
  } else
    release(&pi->lock);
}
    80003988:	60e2                	ld	ra,24(sp)
    8000398a:	6442                	ld	s0,16(sp)
    8000398c:	64a2                	ld	s1,8(sp)
    8000398e:	6902                	ld	s2,0(sp)
    80003990:	6105                	addi	sp,sp,32
    80003992:	8082                	ret
    pi->readopen = 0;
    80003994:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003998:	21c48513          	addi	a0,s1,540
    8000399c:	b9bfd0ef          	jal	80001536 <wakeup>
    800039a0:	bfd9                	j	80003976 <pipeclose+0x24>
    release(&pi->lock);
    800039a2:	8526                	mv	a0,s1
    800039a4:	0a4020ef          	jal	80005a48 <release>
}
    800039a8:	b7c5                	j	80003988 <pipeclose+0x36>

00000000800039aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800039aa:	711d                	addi	sp,sp,-96
    800039ac:	ec86                	sd	ra,88(sp)
    800039ae:	e8a2                	sd	s0,80(sp)
    800039b0:	e4a6                	sd	s1,72(sp)
    800039b2:	e0ca                	sd	s2,64(sp)
    800039b4:	fc4e                	sd	s3,56(sp)
    800039b6:	f852                	sd	s4,48(sp)
    800039b8:	f456                	sd	s5,40(sp)
    800039ba:	1080                	addi	s0,sp,96
    800039bc:	84aa                	mv	s1,a0
    800039be:	8aae                	mv	s5,a1
    800039c0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800039c2:	d5afd0ef          	jal	80000f1c <myproc>
    800039c6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800039c8:	8526                	mv	a0,s1
    800039ca:	7e7010ef          	jal	800059b0 <acquire>
  while(i < n){
    800039ce:	0b405a63          	blez	s4,80003a82 <pipewrite+0xd8>
    800039d2:	f05a                	sd	s6,32(sp)
    800039d4:	ec5e                	sd	s7,24(sp)
    800039d6:	e862                	sd	s8,16(sp)
  int i = 0;
    800039d8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800039da:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800039dc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800039e0:	21c48b93          	addi	s7,s1,540
    800039e4:	a81d                	j	80003a1a <pipewrite+0x70>
      release(&pi->lock);
    800039e6:	8526                	mv	a0,s1
    800039e8:	060020ef          	jal	80005a48 <release>
      return -1;
    800039ec:	597d                	li	s2,-1
    800039ee:	7b02                	ld	s6,32(sp)
    800039f0:	6be2                	ld	s7,24(sp)
    800039f2:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800039f4:	854a                	mv	a0,s2
    800039f6:	60e6                	ld	ra,88(sp)
    800039f8:	6446                	ld	s0,80(sp)
    800039fa:	64a6                	ld	s1,72(sp)
    800039fc:	6906                	ld	s2,64(sp)
    800039fe:	79e2                	ld	s3,56(sp)
    80003a00:	7a42                	ld	s4,48(sp)
    80003a02:	7aa2                	ld	s5,40(sp)
    80003a04:	6125                	addi	sp,sp,96
    80003a06:	8082                	ret
      wakeup(&pi->nread);
    80003a08:	8562                	mv	a0,s8
    80003a0a:	b2dfd0ef          	jal	80001536 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	855e                	mv	a0,s7
    80003a12:	ad9fd0ef          	jal	800014ea <sleep>
  while(i < n){
    80003a16:	05495b63          	bge	s2,s4,80003a6c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003a1a:	2204a783          	lw	a5,544(s1)
    80003a1e:	d7e1                	beqz	a5,800039e6 <pipewrite+0x3c>
    80003a20:	854e                	mv	a0,s3
    80003a22:	d01fd0ef          	jal	80001722 <killed>
    80003a26:	f161                	bnez	a0,800039e6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003a28:	2184a783          	lw	a5,536(s1)
    80003a2c:	21c4a703          	lw	a4,540(s1)
    80003a30:	2007879b          	addiw	a5,a5,512
    80003a34:	fcf70ae3          	beq	a4,a5,80003a08 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003a38:	4685                	li	a3,1
    80003a3a:	01590633          	add	a2,s2,s5
    80003a3e:	faf40593          	addi	a1,s0,-81
    80003a42:	0509b503          	ld	a0,80(s3)
    80003a46:	a1efd0ef          	jal	80000c64 <copyin>
    80003a4a:	03650e63          	beq	a0,s6,80003a86 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003a4e:	21c4a783          	lw	a5,540(s1)
    80003a52:	0017871b          	addiw	a4,a5,1
    80003a56:	20e4ae23          	sw	a4,540(s1)
    80003a5a:	1ff7f793          	andi	a5,a5,511
    80003a5e:	97a6                	add	a5,a5,s1
    80003a60:	faf44703          	lbu	a4,-81(s0)
    80003a64:	00e78c23          	sb	a4,24(a5)
      i++;
    80003a68:	2905                	addiw	s2,s2,1
    80003a6a:	b775                	j	80003a16 <pipewrite+0x6c>
    80003a6c:	7b02                	ld	s6,32(sp)
    80003a6e:	6be2                	ld	s7,24(sp)
    80003a70:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003a72:	21848513          	addi	a0,s1,536
    80003a76:	ac1fd0ef          	jal	80001536 <wakeup>
  release(&pi->lock);
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	7cd010ef          	jal	80005a48 <release>
  return i;
    80003a80:	bf95                	j	800039f4 <pipewrite+0x4a>
  int i = 0;
    80003a82:	4901                	li	s2,0
    80003a84:	b7fd                	j	80003a72 <pipewrite+0xc8>
    80003a86:	7b02                	ld	s6,32(sp)
    80003a88:	6be2                	ld	s7,24(sp)
    80003a8a:	6c42                	ld	s8,16(sp)
    80003a8c:	b7dd                	j	80003a72 <pipewrite+0xc8>

0000000080003a8e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003a8e:	715d                	addi	sp,sp,-80
    80003a90:	e486                	sd	ra,72(sp)
    80003a92:	e0a2                	sd	s0,64(sp)
    80003a94:	fc26                	sd	s1,56(sp)
    80003a96:	f84a                	sd	s2,48(sp)
    80003a98:	f44e                	sd	s3,40(sp)
    80003a9a:	f052                	sd	s4,32(sp)
    80003a9c:	ec56                	sd	s5,24(sp)
    80003a9e:	0880                	addi	s0,sp,80
    80003aa0:	84aa                	mv	s1,a0
    80003aa2:	892e                	mv	s2,a1
    80003aa4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003aa6:	c76fd0ef          	jal	80000f1c <myproc>
    80003aaa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003aac:	8526                	mv	a0,s1
    80003aae:	703010ef          	jal	800059b0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ab2:	2184a703          	lw	a4,536(s1)
    80003ab6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003aba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003abe:	02f71563          	bne	a4,a5,80003ae8 <piperead+0x5a>
    80003ac2:	2244a783          	lw	a5,548(s1)
    80003ac6:	cb85                	beqz	a5,80003af6 <piperead+0x68>
    if(killed(pr)){
    80003ac8:	8552                	mv	a0,s4
    80003aca:	c59fd0ef          	jal	80001722 <killed>
    80003ace:	ed19                	bnez	a0,80003aec <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003ad0:	85a6                	mv	a1,s1
    80003ad2:	854e                	mv	a0,s3
    80003ad4:	a17fd0ef          	jal	800014ea <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ad8:	2184a703          	lw	a4,536(s1)
    80003adc:	21c4a783          	lw	a5,540(s1)
    80003ae0:	fef701e3          	beq	a4,a5,80003ac2 <piperead+0x34>
    80003ae4:	e85a                	sd	s6,16(sp)
    80003ae6:	a809                	j	80003af8 <piperead+0x6a>
    80003ae8:	e85a                	sd	s6,16(sp)
    80003aea:	a039                	j	80003af8 <piperead+0x6a>
      release(&pi->lock);
    80003aec:	8526                	mv	a0,s1
    80003aee:	75b010ef          	jal	80005a48 <release>
      return -1;
    80003af2:	59fd                	li	s3,-1
    80003af4:	a8b1                	j	80003b50 <piperead+0xc2>
    80003af6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003af8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003afa:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003afc:	05505263          	blez	s5,80003b40 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003b00:	2184a783          	lw	a5,536(s1)
    80003b04:	21c4a703          	lw	a4,540(s1)
    80003b08:	02f70c63          	beq	a4,a5,80003b40 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003b0c:	0017871b          	addiw	a4,a5,1
    80003b10:	20e4ac23          	sw	a4,536(s1)
    80003b14:	1ff7f793          	andi	a5,a5,511
    80003b18:	97a6                	add	a5,a5,s1
    80003b1a:	0187c783          	lbu	a5,24(a5)
    80003b1e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b22:	4685                	li	a3,1
    80003b24:	fbf40613          	addi	a2,s0,-65
    80003b28:	85ca                	mv	a1,s2
    80003b2a:	050a3503          	ld	a0,80(s4)
    80003b2e:	fb1fc0ef          	jal	80000ade <copyout>
    80003b32:	01650763          	beq	a0,s6,80003b40 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b36:	2985                	addiw	s3,s3,1
    80003b38:	0905                	addi	s2,s2,1
    80003b3a:	fd3a93e3          	bne	s5,s3,80003b00 <piperead+0x72>
    80003b3e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003b40:	21c48513          	addi	a0,s1,540
    80003b44:	9f3fd0ef          	jal	80001536 <wakeup>
  release(&pi->lock);
    80003b48:	8526                	mv	a0,s1
    80003b4a:	6ff010ef          	jal	80005a48 <release>
    80003b4e:	6b42                	ld	s6,16(sp)
  return i;
}
    80003b50:	854e                	mv	a0,s3
    80003b52:	60a6                	ld	ra,72(sp)
    80003b54:	6406                	ld	s0,64(sp)
    80003b56:	74e2                	ld	s1,56(sp)
    80003b58:	7942                	ld	s2,48(sp)
    80003b5a:	79a2                	ld	s3,40(sp)
    80003b5c:	7a02                	ld	s4,32(sp)
    80003b5e:	6ae2                	ld	s5,24(sp)
    80003b60:	6161                	addi	sp,sp,80
    80003b62:	8082                	ret

0000000080003b64 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003b64:	1141                	addi	sp,sp,-16
    80003b66:	e422                	sd	s0,8(sp)
    80003b68:	0800                	addi	s0,sp,16
    80003b6a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003b6c:	8905                	andi	a0,a0,1
    80003b6e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003b70:	8b89                	andi	a5,a5,2
    80003b72:	c399                	beqz	a5,80003b78 <flags2perm+0x14>
      perm |= PTE_W;
    80003b74:	00456513          	ori	a0,a0,4
    return perm;
}
    80003b78:	6422                	ld	s0,8(sp)
    80003b7a:	0141                	addi	sp,sp,16
    80003b7c:	8082                	ret

0000000080003b7e <exec>:

int
exec(char *path, char **argv)
{
    80003b7e:	df010113          	addi	sp,sp,-528
    80003b82:	20113423          	sd	ra,520(sp)
    80003b86:	20813023          	sd	s0,512(sp)
    80003b8a:	ffa6                	sd	s1,504(sp)
    80003b8c:	fbca                	sd	s2,496(sp)
    80003b8e:	0c00                	addi	s0,sp,528
    80003b90:	892a                	mv	s2,a0
    80003b92:	dea43c23          	sd	a0,-520(s0)
    80003b96:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003b9a:	b82fd0ef          	jal	80000f1c <myproc>
    80003b9e:	84aa                	mv	s1,a0

  begin_op();
    80003ba0:	dc6ff0ef          	jal	80003166 <begin_op>

  if((ip = namei(path)) == 0){
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	c04ff0ef          	jal	80002faa <namei>
    80003baa:	c931                	beqz	a0,80003bfe <exec+0x80>
    80003bac:	f3d2                	sd	s4,480(sp)
    80003bae:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003bb0:	d21fe0ef          	jal	800028d0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003bb4:	04000713          	li	a4,64
    80003bb8:	4681                	li	a3,0
    80003bba:	e5040613          	addi	a2,s0,-432
    80003bbe:	4581                	li	a1,0
    80003bc0:	8552                	mv	a0,s4
    80003bc2:	f63fe0ef          	jal	80002b24 <readi>
    80003bc6:	04000793          	li	a5,64
    80003bca:	00f51a63          	bne	a0,a5,80003bde <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003bce:	e5042703          	lw	a4,-432(s0)
    80003bd2:	464c47b7          	lui	a5,0x464c4
    80003bd6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003bda:	02f70663          	beq	a4,a5,80003c06 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003bde:	8552                	mv	a0,s4
    80003be0:	efbfe0ef          	jal	80002ada <iunlockput>
    end_op();
    80003be4:	decff0ef          	jal	800031d0 <end_op>
  }
  return -1;
    80003be8:	557d                	li	a0,-1
    80003bea:	7a1e                	ld	s4,480(sp)
}
    80003bec:	20813083          	ld	ra,520(sp)
    80003bf0:	20013403          	ld	s0,512(sp)
    80003bf4:	74fe                	ld	s1,504(sp)
    80003bf6:	795e                	ld	s2,496(sp)
    80003bf8:	21010113          	addi	sp,sp,528
    80003bfc:	8082                	ret
    end_op();
    80003bfe:	dd2ff0ef          	jal	800031d0 <end_op>
    return -1;
    80003c02:	557d                	li	a0,-1
    80003c04:	b7e5                	j	80003bec <exec+0x6e>
    80003c06:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003c08:	8526                	mv	a0,s1
    80003c0a:	bbafd0ef          	jal	80000fc4 <proc_pagetable>
    80003c0e:	8b2a                	mv	s6,a0
    80003c10:	2c050b63          	beqz	a0,80003ee6 <exec+0x368>
    80003c14:	f7ce                	sd	s3,488(sp)
    80003c16:	efd6                	sd	s5,472(sp)
    80003c18:	e7de                	sd	s7,456(sp)
    80003c1a:	e3e2                	sd	s8,448(sp)
    80003c1c:	ff66                	sd	s9,440(sp)
    80003c1e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c20:	e7042d03          	lw	s10,-400(s0)
    80003c24:	e8845783          	lhu	a5,-376(s0)
    80003c28:	12078963          	beqz	a5,80003d5a <exec+0x1dc>
    80003c2c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c2e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c30:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003c32:	6c85                	lui	s9,0x1
    80003c34:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003c38:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003c3c:	6a85                	lui	s5,0x1
    80003c3e:	a085                	j	80003c9e <exec+0x120>
      panic("loadseg: address should exist");
    80003c40:	00004517          	auipc	a0,0x4
    80003c44:	9f850513          	addi	a0,a0,-1544 # 80007638 <etext+0x638>
    80003c48:	23b010ef          	jal	80005682 <panic>
    if(sz - i < PGSIZE)
    80003c4c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003c4e:	8726                	mv	a4,s1
    80003c50:	012c06bb          	addw	a3,s8,s2
    80003c54:	4581                	li	a1,0
    80003c56:	8552                	mv	a0,s4
    80003c58:	ecdfe0ef          	jal	80002b24 <readi>
    80003c5c:	2501                	sext.w	a0,a0
    80003c5e:	24a49a63          	bne	s1,a0,80003eb2 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003c62:	012a893b          	addw	s2,s5,s2
    80003c66:	03397363          	bgeu	s2,s3,80003c8c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003c6a:	02091593          	slli	a1,s2,0x20
    80003c6e:	9181                	srli	a1,a1,0x20
    80003c70:	95de                	add	a1,a1,s7
    80003c72:	855a                	mv	a0,s6
    80003c74:	8d9fc0ef          	jal	8000054c <walkaddr>
    80003c78:	862a                	mv	a2,a0
    if(pa == 0)
    80003c7a:	d179                	beqz	a0,80003c40 <exec+0xc2>
    if(sz - i < PGSIZE)
    80003c7c:	412984bb          	subw	s1,s3,s2
    80003c80:	0004879b          	sext.w	a5,s1
    80003c84:	fcfcf4e3          	bgeu	s9,a5,80003c4c <exec+0xce>
    80003c88:	84d6                	mv	s1,s5
    80003c8a:	b7c9                	j	80003c4c <exec+0xce>
    sz = sz1;
    80003c8c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c90:	2d85                	addiw	s11,s11,1
    80003c92:	038d0d1b          	addiw	s10,s10,56 # fffffffffffff038 <end+0xffffffff7ffbb978>
    80003c96:	e8845783          	lhu	a5,-376(s0)
    80003c9a:	08fdd063          	bge	s11,a5,80003d1a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003c9e:	2d01                	sext.w	s10,s10
    80003ca0:	03800713          	li	a4,56
    80003ca4:	86ea                	mv	a3,s10
    80003ca6:	e1840613          	addi	a2,s0,-488
    80003caa:	4581                	li	a1,0
    80003cac:	8552                	mv	a0,s4
    80003cae:	e77fe0ef          	jal	80002b24 <readi>
    80003cb2:	03800793          	li	a5,56
    80003cb6:	1cf51663          	bne	a0,a5,80003e82 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003cba:	e1842783          	lw	a5,-488(s0)
    80003cbe:	4705                	li	a4,1
    80003cc0:	fce798e3          	bne	a5,a4,80003c90 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80003cc4:	e4043483          	ld	s1,-448(s0)
    80003cc8:	e3843783          	ld	a5,-456(s0)
    80003ccc:	1af4ef63          	bltu	s1,a5,80003e8a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003cd0:	e2843783          	ld	a5,-472(s0)
    80003cd4:	94be                	add	s1,s1,a5
    80003cd6:	1af4ee63          	bltu	s1,a5,80003e92 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003cda:	df043703          	ld	a4,-528(s0)
    80003cde:	8ff9                	and	a5,a5,a4
    80003ce0:	1a079d63          	bnez	a5,80003e9a <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003ce4:	e1c42503          	lw	a0,-484(s0)
    80003ce8:	e7dff0ef          	jal	80003b64 <flags2perm>
    80003cec:	86aa                	mv	a3,a0
    80003cee:	8626                	mv	a2,s1
    80003cf0:	85ca                	mv	a1,s2
    80003cf2:	855a                	mv	a0,s6
    80003cf4:	bc1fc0ef          	jal	800008b4 <uvmalloc>
    80003cf8:	e0a43423          	sd	a0,-504(s0)
    80003cfc:	1a050363          	beqz	a0,80003ea2 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003d00:	e2843b83          	ld	s7,-472(s0)
    80003d04:	e2042c03          	lw	s8,-480(s0)
    80003d08:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003d0c:	00098463          	beqz	s3,80003d14 <exec+0x196>
    80003d10:	4901                	li	s2,0
    80003d12:	bfa1                	j	80003c6a <exec+0xec>
    sz = sz1;
    80003d14:	e0843903          	ld	s2,-504(s0)
    80003d18:	bfa5                	j	80003c90 <exec+0x112>
    80003d1a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003d1c:	8552                	mv	a0,s4
    80003d1e:	dbdfe0ef          	jal	80002ada <iunlockput>
  end_op();
    80003d22:	caeff0ef          	jal	800031d0 <end_op>
  p = myproc();
    80003d26:	9f6fd0ef          	jal	80000f1c <myproc>
    80003d2a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003d2c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003d30:	6985                	lui	s3,0x1
    80003d32:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003d34:	99ca                	add	s3,s3,s2
    80003d36:	77fd                	lui	a5,0xfffff
    80003d38:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003d3c:	4691                	li	a3,4
    80003d3e:	6609                	lui	a2,0x2
    80003d40:	964e                	add	a2,a2,s3
    80003d42:	85ce                	mv	a1,s3
    80003d44:	855a                	mv	a0,s6
    80003d46:	b6ffc0ef          	jal	800008b4 <uvmalloc>
    80003d4a:	892a                	mv	s2,a0
    80003d4c:	e0a43423          	sd	a0,-504(s0)
    80003d50:	e519                	bnez	a0,80003d5e <exec+0x1e0>
  if(pagetable)
    80003d52:	e1343423          	sd	s3,-504(s0)
    80003d56:	4a01                	li	s4,0
    80003d58:	aab1                	j	80003eb4 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d5a:	4901                	li	s2,0
    80003d5c:	b7c1                	j	80003d1c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003d5e:	75f9                	lui	a1,0xffffe
    80003d60:	95aa                	add	a1,a1,a0
    80003d62:	855a                	mv	a0,s6
    80003d64:	d51fc0ef          	jal	80000ab4 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003d68:	7bfd                	lui	s7,0xfffff
    80003d6a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003d6c:	e0043783          	ld	a5,-512(s0)
    80003d70:	6388                	ld	a0,0(a5)
    80003d72:	cd39                	beqz	a0,80003dd0 <exec+0x252>
    80003d74:	e9040993          	addi	s3,s0,-368
    80003d78:	f9040c13          	addi	s8,s0,-112
    80003d7c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003d7e:	e34fc0ef          	jal	800003b2 <strlen>
    80003d82:	0015079b          	addiw	a5,a0,1
    80003d86:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003d8a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003d8e:	11796e63          	bltu	s2,s7,80003eaa <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003d92:	e0043d03          	ld	s10,-512(s0)
    80003d96:	000d3a03          	ld	s4,0(s10)
    80003d9a:	8552                	mv	a0,s4
    80003d9c:	e16fc0ef          	jal	800003b2 <strlen>
    80003da0:	0015069b          	addiw	a3,a0,1
    80003da4:	8652                	mv	a2,s4
    80003da6:	85ca                	mv	a1,s2
    80003da8:	855a                	mv	a0,s6
    80003daa:	d35fc0ef          	jal	80000ade <copyout>
    80003dae:	10054063          	bltz	a0,80003eae <exec+0x330>
    ustack[argc] = sp;
    80003db2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003db6:	0485                	addi	s1,s1,1
    80003db8:	008d0793          	addi	a5,s10,8
    80003dbc:	e0f43023          	sd	a5,-512(s0)
    80003dc0:	008d3503          	ld	a0,8(s10)
    80003dc4:	c909                	beqz	a0,80003dd6 <exec+0x258>
    if(argc >= MAXARG)
    80003dc6:	09a1                	addi	s3,s3,8
    80003dc8:	fb899be3          	bne	s3,s8,80003d7e <exec+0x200>
  ip = 0;
    80003dcc:	4a01                	li	s4,0
    80003dce:	a0dd                	j	80003eb4 <exec+0x336>
  sp = sz;
    80003dd0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003dd4:	4481                	li	s1,0
  ustack[argc] = 0;
    80003dd6:	00349793          	slli	a5,s1,0x3
    80003dda:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffbb8d0>
    80003dde:	97a2                	add	a5,a5,s0
    80003de0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003de4:	00148693          	addi	a3,s1,1
    80003de8:	068e                	slli	a3,a3,0x3
    80003dea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003dee:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003df2:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003df6:	f5796ee3          	bltu	s2,s7,80003d52 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003dfa:	e9040613          	addi	a2,s0,-368
    80003dfe:	85ca                	mv	a1,s2
    80003e00:	855a                	mv	a0,s6
    80003e02:	cddfc0ef          	jal	80000ade <copyout>
    80003e06:	0e054263          	bltz	a0,80003eea <exec+0x36c>
  p->trapframe->a1 = sp;
    80003e0a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003e0e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003e12:	df843783          	ld	a5,-520(s0)
    80003e16:	0007c703          	lbu	a4,0(a5)
    80003e1a:	cf11                	beqz	a4,80003e36 <exec+0x2b8>
    80003e1c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003e1e:	02f00693          	li	a3,47
    80003e22:	a039                	j	80003e30 <exec+0x2b2>
      last = s+1;
    80003e24:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003e28:	0785                	addi	a5,a5,1
    80003e2a:	fff7c703          	lbu	a4,-1(a5)
    80003e2e:	c701                	beqz	a4,80003e36 <exec+0x2b8>
    if(*s == '/')
    80003e30:	fed71ce3          	bne	a4,a3,80003e28 <exec+0x2aa>
    80003e34:	bfc5                	j	80003e24 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e36:	4641                	li	a2,16
    80003e38:	df843583          	ld	a1,-520(s0)
    80003e3c:	158a8513          	addi	a0,s5,344
    80003e40:	d40fc0ef          	jal	80000380 <safestrcpy>
  oldpagetable = p->pagetable;
    80003e44:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003e48:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003e4c:	e0843783          	ld	a5,-504(s0)
    80003e50:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e54:	058ab783          	ld	a5,88(s5)
    80003e58:	e6843703          	ld	a4,-408(s0)
    80003e5c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003e5e:	058ab783          	ld	a5,88(s5)
    80003e62:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003e66:	85e6                	mv	a1,s9
    80003e68:	9e0fd0ef          	jal	80001048 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003e6c:	0004851b          	sext.w	a0,s1
    80003e70:	79be                	ld	s3,488(sp)
    80003e72:	7a1e                	ld	s4,480(sp)
    80003e74:	6afe                	ld	s5,472(sp)
    80003e76:	6b5e                	ld	s6,464(sp)
    80003e78:	6bbe                	ld	s7,456(sp)
    80003e7a:	6c1e                	ld	s8,448(sp)
    80003e7c:	7cfa                	ld	s9,440(sp)
    80003e7e:	7d5a                	ld	s10,432(sp)
    80003e80:	b3b5                	j	80003bec <exec+0x6e>
    80003e82:	e1243423          	sd	s2,-504(s0)
    80003e86:	7dba                	ld	s11,424(sp)
    80003e88:	a035                	j	80003eb4 <exec+0x336>
    80003e8a:	e1243423          	sd	s2,-504(s0)
    80003e8e:	7dba                	ld	s11,424(sp)
    80003e90:	a015                	j	80003eb4 <exec+0x336>
    80003e92:	e1243423          	sd	s2,-504(s0)
    80003e96:	7dba                	ld	s11,424(sp)
    80003e98:	a831                	j	80003eb4 <exec+0x336>
    80003e9a:	e1243423          	sd	s2,-504(s0)
    80003e9e:	7dba                	ld	s11,424(sp)
    80003ea0:	a811                	j	80003eb4 <exec+0x336>
    80003ea2:	e1243423          	sd	s2,-504(s0)
    80003ea6:	7dba                	ld	s11,424(sp)
    80003ea8:	a031                	j	80003eb4 <exec+0x336>
  ip = 0;
    80003eaa:	4a01                	li	s4,0
    80003eac:	a021                	j	80003eb4 <exec+0x336>
    80003eae:	4a01                	li	s4,0
  if(pagetable)
    80003eb0:	a011                	j	80003eb4 <exec+0x336>
    80003eb2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003eb4:	e0843583          	ld	a1,-504(s0)
    80003eb8:	855a                	mv	a0,s6
    80003eba:	98efd0ef          	jal	80001048 <proc_freepagetable>
  return -1;
    80003ebe:	557d                	li	a0,-1
  if(ip){
    80003ec0:	000a1b63          	bnez	s4,80003ed6 <exec+0x358>
    80003ec4:	79be                	ld	s3,488(sp)
    80003ec6:	7a1e                	ld	s4,480(sp)
    80003ec8:	6afe                	ld	s5,472(sp)
    80003eca:	6b5e                	ld	s6,464(sp)
    80003ecc:	6bbe                	ld	s7,456(sp)
    80003ece:	6c1e                	ld	s8,448(sp)
    80003ed0:	7cfa                	ld	s9,440(sp)
    80003ed2:	7d5a                	ld	s10,432(sp)
    80003ed4:	bb21                	j	80003bec <exec+0x6e>
    80003ed6:	79be                	ld	s3,488(sp)
    80003ed8:	6afe                	ld	s5,472(sp)
    80003eda:	6b5e                	ld	s6,464(sp)
    80003edc:	6bbe                	ld	s7,456(sp)
    80003ede:	6c1e                	ld	s8,448(sp)
    80003ee0:	7cfa                	ld	s9,440(sp)
    80003ee2:	7d5a                	ld	s10,432(sp)
    80003ee4:	b9ed                	j	80003bde <exec+0x60>
    80003ee6:	6b5e                	ld	s6,464(sp)
    80003ee8:	b9dd                	j	80003bde <exec+0x60>
  sz = sz1;
    80003eea:	e0843983          	ld	s3,-504(s0)
    80003eee:	b595                	j	80003d52 <exec+0x1d4>

0000000080003ef0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003ef0:	7179                	addi	sp,sp,-48
    80003ef2:	f406                	sd	ra,40(sp)
    80003ef4:	f022                	sd	s0,32(sp)
    80003ef6:	ec26                	sd	s1,24(sp)
    80003ef8:	e84a                	sd	s2,16(sp)
    80003efa:	1800                	addi	s0,sp,48
    80003efc:	892e                	mv	s2,a1
    80003efe:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003f00:	fdc40593          	addi	a1,s0,-36
    80003f04:	fa1fd0ef          	jal	80001ea4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003f08:	fdc42703          	lw	a4,-36(s0)
    80003f0c:	47bd                	li	a5,15
    80003f0e:	02e7e963          	bltu	a5,a4,80003f40 <argfd+0x50>
    80003f12:	80afd0ef          	jal	80000f1c <myproc>
    80003f16:	fdc42703          	lw	a4,-36(s0)
    80003f1a:	01a70793          	addi	a5,a4,26
    80003f1e:	078e                	slli	a5,a5,0x3
    80003f20:	953e                	add	a0,a0,a5
    80003f22:	611c                	ld	a5,0(a0)
    80003f24:	c385                	beqz	a5,80003f44 <argfd+0x54>
    return -1;
  if(pfd)
    80003f26:	00090463          	beqz	s2,80003f2e <argfd+0x3e>
    *pfd = fd;
    80003f2a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003f2e:	4501                	li	a0,0
  if(pf)
    80003f30:	c091                	beqz	s1,80003f34 <argfd+0x44>
    *pf = f;
    80003f32:	e09c                	sd	a5,0(s1)
}
    80003f34:	70a2                	ld	ra,40(sp)
    80003f36:	7402                	ld	s0,32(sp)
    80003f38:	64e2                	ld	s1,24(sp)
    80003f3a:	6942                	ld	s2,16(sp)
    80003f3c:	6145                	addi	sp,sp,48
    80003f3e:	8082                	ret
    return -1;
    80003f40:	557d                	li	a0,-1
    80003f42:	bfcd                	j	80003f34 <argfd+0x44>
    80003f44:	557d                	li	a0,-1
    80003f46:	b7fd                	j	80003f34 <argfd+0x44>

0000000080003f48 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003f48:	1101                	addi	sp,sp,-32
    80003f4a:	ec06                	sd	ra,24(sp)
    80003f4c:	e822                	sd	s0,16(sp)
    80003f4e:	e426                	sd	s1,8(sp)
    80003f50:	1000                	addi	s0,sp,32
    80003f52:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003f54:	fc9fc0ef          	jal	80000f1c <myproc>
    80003f58:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003f5a:	0d050793          	addi	a5,a0,208
    80003f5e:	4501                	li	a0,0
    80003f60:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003f62:	6398                	ld	a4,0(a5)
    80003f64:	cb19                	beqz	a4,80003f7a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003f66:	2505                	addiw	a0,a0,1
    80003f68:	07a1                	addi	a5,a5,8
    80003f6a:	fed51ce3          	bne	a0,a3,80003f62 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003f6e:	557d                	li	a0,-1
}
    80003f70:	60e2                	ld	ra,24(sp)
    80003f72:	6442                	ld	s0,16(sp)
    80003f74:	64a2                	ld	s1,8(sp)
    80003f76:	6105                	addi	sp,sp,32
    80003f78:	8082                	ret
      p->ofile[fd] = f;
    80003f7a:	01a50793          	addi	a5,a0,26
    80003f7e:	078e                	slli	a5,a5,0x3
    80003f80:	963e                	add	a2,a2,a5
    80003f82:	e204                	sd	s1,0(a2)
      return fd;
    80003f84:	b7f5                	j	80003f70 <fdalloc+0x28>

0000000080003f86 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003f86:	715d                	addi	sp,sp,-80
    80003f88:	e486                	sd	ra,72(sp)
    80003f8a:	e0a2                	sd	s0,64(sp)
    80003f8c:	fc26                	sd	s1,56(sp)
    80003f8e:	f84a                	sd	s2,48(sp)
    80003f90:	f44e                	sd	s3,40(sp)
    80003f92:	ec56                	sd	s5,24(sp)
    80003f94:	e85a                	sd	s6,16(sp)
    80003f96:	0880                	addi	s0,sp,80
    80003f98:	8b2e                	mv	s6,a1
    80003f9a:	89b2                	mv	s3,a2
    80003f9c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003f9e:	fb040593          	addi	a1,s0,-80
    80003fa2:	822ff0ef          	jal	80002fc4 <nameiparent>
    80003fa6:	84aa                	mv	s1,a0
    80003fa8:	10050a63          	beqz	a0,800040bc <create+0x136>
    return 0;

  ilock(dp);
    80003fac:	925fe0ef          	jal	800028d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fb0:	4601                	li	a2,0
    80003fb2:	fb040593          	addi	a1,s0,-80
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	d8dfe0ef          	jal	80002d44 <dirlookup>
    80003fbc:	8aaa                	mv	s5,a0
    80003fbe:	c129                	beqz	a0,80004000 <create+0x7a>
    iunlockput(dp);
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	b19fe0ef          	jal	80002ada <iunlockput>
    ilock(ip);
    80003fc6:	8556                	mv	a0,s5
    80003fc8:	909fe0ef          	jal	800028d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003fcc:	4789                	li	a5,2
    80003fce:	02fb1463          	bne	s6,a5,80003ff6 <create+0x70>
    80003fd2:	044ad783          	lhu	a5,68(s5)
    80003fd6:	37f9                	addiw	a5,a5,-2
    80003fd8:	17c2                	slli	a5,a5,0x30
    80003fda:	93c1                	srli	a5,a5,0x30
    80003fdc:	4705                	li	a4,1
    80003fde:	00f76c63          	bltu	a4,a5,80003ff6 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003fe2:	8556                	mv	a0,s5
    80003fe4:	60a6                	ld	ra,72(sp)
    80003fe6:	6406                	ld	s0,64(sp)
    80003fe8:	74e2                	ld	s1,56(sp)
    80003fea:	7942                	ld	s2,48(sp)
    80003fec:	79a2                	ld	s3,40(sp)
    80003fee:	6ae2                	ld	s5,24(sp)
    80003ff0:	6b42                	ld	s6,16(sp)
    80003ff2:	6161                	addi	sp,sp,80
    80003ff4:	8082                	ret
    iunlockput(ip);
    80003ff6:	8556                	mv	a0,s5
    80003ff8:	ae3fe0ef          	jal	80002ada <iunlockput>
    return 0;
    80003ffc:	4a81                	li	s5,0
    80003ffe:	b7d5                	j	80003fe2 <create+0x5c>
    80004000:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004002:	85da                	mv	a1,s6
    80004004:	4088                	lw	a0,0(s1)
    80004006:	f5afe0ef          	jal	80002760 <ialloc>
    8000400a:	8a2a                	mv	s4,a0
    8000400c:	cd15                	beqz	a0,80004048 <create+0xc2>
  ilock(ip);
    8000400e:	8c3fe0ef          	jal	800028d0 <ilock>
  ip->major = major;
    80004012:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004016:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000401a:	4905                	li	s2,1
    8000401c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004020:	8552                	mv	a0,s4
    80004022:	ffafe0ef          	jal	8000281c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004026:	032b0763          	beq	s6,s2,80004054 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000402a:	004a2603          	lw	a2,4(s4)
    8000402e:	fb040593          	addi	a1,s0,-80
    80004032:	8526                	mv	a0,s1
    80004034:	eddfe0ef          	jal	80002f10 <dirlink>
    80004038:	06054563          	bltz	a0,800040a2 <create+0x11c>
  iunlockput(dp);
    8000403c:	8526                	mv	a0,s1
    8000403e:	a9dfe0ef          	jal	80002ada <iunlockput>
  return ip;
    80004042:	8ad2                	mv	s5,s4
    80004044:	7a02                	ld	s4,32(sp)
    80004046:	bf71                	j	80003fe2 <create+0x5c>
    iunlockput(dp);
    80004048:	8526                	mv	a0,s1
    8000404a:	a91fe0ef          	jal	80002ada <iunlockput>
    return 0;
    8000404e:	8ad2                	mv	s5,s4
    80004050:	7a02                	ld	s4,32(sp)
    80004052:	bf41                	j	80003fe2 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004054:	004a2603          	lw	a2,4(s4)
    80004058:	00003597          	auipc	a1,0x3
    8000405c:	60058593          	addi	a1,a1,1536 # 80007658 <etext+0x658>
    80004060:	8552                	mv	a0,s4
    80004062:	eaffe0ef          	jal	80002f10 <dirlink>
    80004066:	02054e63          	bltz	a0,800040a2 <create+0x11c>
    8000406a:	40d0                	lw	a2,4(s1)
    8000406c:	00003597          	auipc	a1,0x3
    80004070:	5f458593          	addi	a1,a1,1524 # 80007660 <etext+0x660>
    80004074:	8552                	mv	a0,s4
    80004076:	e9bfe0ef          	jal	80002f10 <dirlink>
    8000407a:	02054463          	bltz	a0,800040a2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000407e:	004a2603          	lw	a2,4(s4)
    80004082:	fb040593          	addi	a1,s0,-80
    80004086:	8526                	mv	a0,s1
    80004088:	e89fe0ef          	jal	80002f10 <dirlink>
    8000408c:	00054b63          	bltz	a0,800040a2 <create+0x11c>
    dp->nlink++;  // for ".."
    80004090:	04a4d783          	lhu	a5,74(s1)
    80004094:	2785                	addiw	a5,a5,1
    80004096:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000409a:	8526                	mv	a0,s1
    8000409c:	f80fe0ef          	jal	8000281c <iupdate>
    800040a0:	bf71                	j	8000403c <create+0xb6>
  ip->nlink = 0;
    800040a2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800040a6:	8552                	mv	a0,s4
    800040a8:	f74fe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800040ac:	8552                	mv	a0,s4
    800040ae:	a2dfe0ef          	jal	80002ada <iunlockput>
  iunlockput(dp);
    800040b2:	8526                	mv	a0,s1
    800040b4:	a27fe0ef          	jal	80002ada <iunlockput>
  return 0;
    800040b8:	7a02                	ld	s4,32(sp)
    800040ba:	b725                	j	80003fe2 <create+0x5c>
    return 0;
    800040bc:	8aaa                	mv	s5,a0
    800040be:	b715                	j	80003fe2 <create+0x5c>

00000000800040c0 <sys_dup>:
{
    800040c0:	7179                	addi	sp,sp,-48
    800040c2:	f406                	sd	ra,40(sp)
    800040c4:	f022                	sd	s0,32(sp)
    800040c6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800040c8:	fd840613          	addi	a2,s0,-40
    800040cc:	4581                	li	a1,0
    800040ce:	4501                	li	a0,0
    800040d0:	e21ff0ef          	jal	80003ef0 <argfd>
    return -1;
    800040d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800040d6:	02054363          	bltz	a0,800040fc <sys_dup+0x3c>
    800040da:	ec26                	sd	s1,24(sp)
    800040dc:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800040de:	fd843903          	ld	s2,-40(s0)
    800040e2:	854a                	mv	a0,s2
    800040e4:	e65ff0ef          	jal	80003f48 <fdalloc>
    800040e8:	84aa                	mv	s1,a0
    return -1;
    800040ea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800040ec:	00054d63          	bltz	a0,80004106 <sys_dup+0x46>
  filedup(f);
    800040f0:	854a                	mv	a0,s2
    800040f2:	c48ff0ef          	jal	8000353a <filedup>
  return fd;
    800040f6:	87a6                	mv	a5,s1
    800040f8:	64e2                	ld	s1,24(sp)
    800040fa:	6942                	ld	s2,16(sp)
}
    800040fc:	853e                	mv	a0,a5
    800040fe:	70a2                	ld	ra,40(sp)
    80004100:	7402                	ld	s0,32(sp)
    80004102:	6145                	addi	sp,sp,48
    80004104:	8082                	ret
    80004106:	64e2                	ld	s1,24(sp)
    80004108:	6942                	ld	s2,16(sp)
    8000410a:	bfcd                	j	800040fc <sys_dup+0x3c>

000000008000410c <sys_read>:
{
    8000410c:	7179                	addi	sp,sp,-48
    8000410e:	f406                	sd	ra,40(sp)
    80004110:	f022                	sd	s0,32(sp)
    80004112:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004114:	fd840593          	addi	a1,s0,-40
    80004118:	4505                	li	a0,1
    8000411a:	da7fd0ef          	jal	80001ec0 <argaddr>
  argint(2, &n);
    8000411e:	fe440593          	addi	a1,s0,-28
    80004122:	4509                	li	a0,2
    80004124:	d81fd0ef          	jal	80001ea4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004128:	fe840613          	addi	a2,s0,-24
    8000412c:	4581                	li	a1,0
    8000412e:	4501                	li	a0,0
    80004130:	dc1ff0ef          	jal	80003ef0 <argfd>
    80004134:	87aa                	mv	a5,a0
    return -1;
    80004136:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004138:	0007ca63          	bltz	a5,8000414c <sys_read+0x40>
  return fileread(f, p, n);
    8000413c:	fe442603          	lw	a2,-28(s0)
    80004140:	fd843583          	ld	a1,-40(s0)
    80004144:	fe843503          	ld	a0,-24(s0)
    80004148:	d58ff0ef          	jal	800036a0 <fileread>
}
    8000414c:	70a2                	ld	ra,40(sp)
    8000414e:	7402                	ld	s0,32(sp)
    80004150:	6145                	addi	sp,sp,48
    80004152:	8082                	ret

0000000080004154 <sys_write>:
{
    80004154:	7179                	addi	sp,sp,-48
    80004156:	f406                	sd	ra,40(sp)
    80004158:	f022                	sd	s0,32(sp)
    8000415a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000415c:	fd840593          	addi	a1,s0,-40
    80004160:	4505                	li	a0,1
    80004162:	d5ffd0ef          	jal	80001ec0 <argaddr>
  argint(2, &n);
    80004166:	fe440593          	addi	a1,s0,-28
    8000416a:	4509                	li	a0,2
    8000416c:	d39fd0ef          	jal	80001ea4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004170:	fe840613          	addi	a2,s0,-24
    80004174:	4581                	li	a1,0
    80004176:	4501                	li	a0,0
    80004178:	d79ff0ef          	jal	80003ef0 <argfd>
    8000417c:	87aa                	mv	a5,a0
    return -1;
    8000417e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004180:	0007ca63          	bltz	a5,80004194 <sys_write+0x40>
  return filewrite(f, p, n);
    80004184:	fe442603          	lw	a2,-28(s0)
    80004188:	fd843583          	ld	a1,-40(s0)
    8000418c:	fe843503          	ld	a0,-24(s0)
    80004190:	dceff0ef          	jal	8000375e <filewrite>
}
    80004194:	70a2                	ld	ra,40(sp)
    80004196:	7402                	ld	s0,32(sp)
    80004198:	6145                	addi	sp,sp,48
    8000419a:	8082                	ret

000000008000419c <sys_close>:
{
    8000419c:	1101                	addi	sp,sp,-32
    8000419e:	ec06                	sd	ra,24(sp)
    800041a0:	e822                	sd	s0,16(sp)
    800041a2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800041a4:	fe040613          	addi	a2,s0,-32
    800041a8:	fec40593          	addi	a1,s0,-20
    800041ac:	4501                	li	a0,0
    800041ae:	d43ff0ef          	jal	80003ef0 <argfd>
    return -1;
    800041b2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800041b4:	02054063          	bltz	a0,800041d4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800041b8:	d65fc0ef          	jal	80000f1c <myproc>
    800041bc:	fec42783          	lw	a5,-20(s0)
    800041c0:	07e9                	addi	a5,a5,26
    800041c2:	078e                	slli	a5,a5,0x3
    800041c4:	953e                	add	a0,a0,a5
    800041c6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800041ca:	fe043503          	ld	a0,-32(s0)
    800041ce:	bb2ff0ef          	jal	80003580 <fileclose>
  return 0;
    800041d2:	4781                	li	a5,0
}
    800041d4:	853e                	mv	a0,a5
    800041d6:	60e2                	ld	ra,24(sp)
    800041d8:	6442                	ld	s0,16(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <sys_fstat>:
{
    800041de:	1101                	addi	sp,sp,-32
    800041e0:	ec06                	sd	ra,24(sp)
    800041e2:	e822                	sd	s0,16(sp)
    800041e4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800041e6:	fe040593          	addi	a1,s0,-32
    800041ea:	4505                	li	a0,1
    800041ec:	cd5fd0ef          	jal	80001ec0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800041f0:	fe840613          	addi	a2,s0,-24
    800041f4:	4581                	li	a1,0
    800041f6:	4501                	li	a0,0
    800041f8:	cf9ff0ef          	jal	80003ef0 <argfd>
    800041fc:	87aa                	mv	a5,a0
    return -1;
    800041fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004200:	0007c863          	bltz	a5,80004210 <sys_fstat+0x32>
  return filestat(f, st);
    80004204:	fe043583          	ld	a1,-32(s0)
    80004208:	fe843503          	ld	a0,-24(s0)
    8000420c:	c36ff0ef          	jal	80003642 <filestat>
}
    80004210:	60e2                	ld	ra,24(sp)
    80004212:	6442                	ld	s0,16(sp)
    80004214:	6105                	addi	sp,sp,32
    80004216:	8082                	ret

0000000080004218 <sys_link>:
{
    80004218:	7169                	addi	sp,sp,-304
    8000421a:	f606                	sd	ra,296(sp)
    8000421c:	f222                	sd	s0,288(sp)
    8000421e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004220:	08000613          	li	a2,128
    80004224:	ed040593          	addi	a1,s0,-304
    80004228:	4501                	li	a0,0
    8000422a:	cb3fd0ef          	jal	80001edc <argstr>
    return -1;
    8000422e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004230:	0c054e63          	bltz	a0,8000430c <sys_link+0xf4>
    80004234:	08000613          	li	a2,128
    80004238:	f5040593          	addi	a1,s0,-176
    8000423c:	4505                	li	a0,1
    8000423e:	c9ffd0ef          	jal	80001edc <argstr>
    return -1;
    80004242:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004244:	0c054463          	bltz	a0,8000430c <sys_link+0xf4>
    80004248:	ee26                	sd	s1,280(sp)
  begin_op();
    8000424a:	f1dfe0ef          	jal	80003166 <begin_op>
  if((ip = namei(old)) == 0){
    8000424e:	ed040513          	addi	a0,s0,-304
    80004252:	d59fe0ef          	jal	80002faa <namei>
    80004256:	84aa                	mv	s1,a0
    80004258:	c53d                	beqz	a0,800042c6 <sys_link+0xae>
  ilock(ip);
    8000425a:	e76fe0ef          	jal	800028d0 <ilock>
  if(ip->type == T_DIR){
    8000425e:	04449703          	lh	a4,68(s1)
    80004262:	4785                	li	a5,1
    80004264:	06f70663          	beq	a4,a5,800042d0 <sys_link+0xb8>
    80004268:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000426a:	04a4d783          	lhu	a5,74(s1)
    8000426e:	2785                	addiw	a5,a5,1
    80004270:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004274:	8526                	mv	a0,s1
    80004276:	da6fe0ef          	jal	8000281c <iupdate>
  iunlock(ip);
    8000427a:	8526                	mv	a0,s1
    8000427c:	f02fe0ef          	jal	8000297e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004280:	fd040593          	addi	a1,s0,-48
    80004284:	f5040513          	addi	a0,s0,-176
    80004288:	d3dfe0ef          	jal	80002fc4 <nameiparent>
    8000428c:	892a                	mv	s2,a0
    8000428e:	cd21                	beqz	a0,800042e6 <sys_link+0xce>
  ilock(dp);
    80004290:	e40fe0ef          	jal	800028d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004294:	00092703          	lw	a4,0(s2)
    80004298:	409c                	lw	a5,0(s1)
    8000429a:	04f71363          	bne	a4,a5,800042e0 <sys_link+0xc8>
    8000429e:	40d0                	lw	a2,4(s1)
    800042a0:	fd040593          	addi	a1,s0,-48
    800042a4:	854a                	mv	a0,s2
    800042a6:	c6bfe0ef          	jal	80002f10 <dirlink>
    800042aa:	02054b63          	bltz	a0,800042e0 <sys_link+0xc8>
  iunlockput(dp);
    800042ae:	854a                	mv	a0,s2
    800042b0:	82bfe0ef          	jal	80002ada <iunlockput>
  iput(ip);
    800042b4:	8526                	mv	a0,s1
    800042b6:	f9cfe0ef          	jal	80002a52 <iput>
  end_op();
    800042ba:	f17fe0ef          	jal	800031d0 <end_op>
  return 0;
    800042be:	4781                	li	a5,0
    800042c0:	64f2                	ld	s1,280(sp)
    800042c2:	6952                	ld	s2,272(sp)
    800042c4:	a0a1                	j	8000430c <sys_link+0xf4>
    end_op();
    800042c6:	f0bfe0ef          	jal	800031d0 <end_op>
    return -1;
    800042ca:	57fd                	li	a5,-1
    800042cc:	64f2                	ld	s1,280(sp)
    800042ce:	a83d                	j	8000430c <sys_link+0xf4>
    iunlockput(ip);
    800042d0:	8526                	mv	a0,s1
    800042d2:	809fe0ef          	jal	80002ada <iunlockput>
    end_op();
    800042d6:	efbfe0ef          	jal	800031d0 <end_op>
    return -1;
    800042da:	57fd                	li	a5,-1
    800042dc:	64f2                	ld	s1,280(sp)
    800042de:	a03d                	j	8000430c <sys_link+0xf4>
    iunlockput(dp);
    800042e0:	854a                	mv	a0,s2
    800042e2:	ff8fe0ef          	jal	80002ada <iunlockput>
  ilock(ip);
    800042e6:	8526                	mv	a0,s1
    800042e8:	de8fe0ef          	jal	800028d0 <ilock>
  ip->nlink--;
    800042ec:	04a4d783          	lhu	a5,74(s1)
    800042f0:	37fd                	addiw	a5,a5,-1
    800042f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800042f6:	8526                	mv	a0,s1
    800042f8:	d24fe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800042fc:	8526                	mv	a0,s1
    800042fe:	fdcfe0ef          	jal	80002ada <iunlockput>
  end_op();
    80004302:	ecffe0ef          	jal	800031d0 <end_op>
  return -1;
    80004306:	57fd                	li	a5,-1
    80004308:	64f2                	ld	s1,280(sp)
    8000430a:	6952                	ld	s2,272(sp)
}
    8000430c:	853e                	mv	a0,a5
    8000430e:	70b2                	ld	ra,296(sp)
    80004310:	7412                	ld	s0,288(sp)
    80004312:	6155                	addi	sp,sp,304
    80004314:	8082                	ret

0000000080004316 <sys_unlink>:
{
    80004316:	7151                	addi	sp,sp,-240
    80004318:	f586                	sd	ra,232(sp)
    8000431a:	f1a2                	sd	s0,224(sp)
    8000431c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000431e:	08000613          	li	a2,128
    80004322:	f3040593          	addi	a1,s0,-208
    80004326:	4501                	li	a0,0
    80004328:	bb5fd0ef          	jal	80001edc <argstr>
    8000432c:	16054063          	bltz	a0,8000448c <sys_unlink+0x176>
    80004330:	eda6                	sd	s1,216(sp)
  begin_op();
    80004332:	e35fe0ef          	jal	80003166 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004336:	fb040593          	addi	a1,s0,-80
    8000433a:	f3040513          	addi	a0,s0,-208
    8000433e:	c87fe0ef          	jal	80002fc4 <nameiparent>
    80004342:	84aa                	mv	s1,a0
    80004344:	c945                	beqz	a0,800043f4 <sys_unlink+0xde>
  ilock(dp);
    80004346:	d8afe0ef          	jal	800028d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000434a:	00003597          	auipc	a1,0x3
    8000434e:	30e58593          	addi	a1,a1,782 # 80007658 <etext+0x658>
    80004352:	fb040513          	addi	a0,s0,-80
    80004356:	9d9fe0ef          	jal	80002d2e <namecmp>
    8000435a:	10050e63          	beqz	a0,80004476 <sys_unlink+0x160>
    8000435e:	00003597          	auipc	a1,0x3
    80004362:	30258593          	addi	a1,a1,770 # 80007660 <etext+0x660>
    80004366:	fb040513          	addi	a0,s0,-80
    8000436a:	9c5fe0ef          	jal	80002d2e <namecmp>
    8000436e:	10050463          	beqz	a0,80004476 <sys_unlink+0x160>
    80004372:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004374:	f2c40613          	addi	a2,s0,-212
    80004378:	fb040593          	addi	a1,s0,-80
    8000437c:	8526                	mv	a0,s1
    8000437e:	9c7fe0ef          	jal	80002d44 <dirlookup>
    80004382:	892a                	mv	s2,a0
    80004384:	0e050863          	beqz	a0,80004474 <sys_unlink+0x15e>
  ilock(ip);
    80004388:	d48fe0ef          	jal	800028d0 <ilock>
  if(ip->nlink < 1)
    8000438c:	04a91783          	lh	a5,74(s2)
    80004390:	06f05763          	blez	a5,800043fe <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004394:	04491703          	lh	a4,68(s2)
    80004398:	4785                	li	a5,1
    8000439a:	06f70963          	beq	a4,a5,8000440c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    8000439e:	4641                	li	a2,16
    800043a0:	4581                	li	a1,0
    800043a2:	fc040513          	addi	a0,s0,-64
    800043a6:	e9dfb0ef          	jal	80000242 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043aa:	4741                	li	a4,16
    800043ac:	f2c42683          	lw	a3,-212(s0)
    800043b0:	fc040613          	addi	a2,s0,-64
    800043b4:	4581                	li	a1,0
    800043b6:	8526                	mv	a0,s1
    800043b8:	869fe0ef          	jal	80002c20 <writei>
    800043bc:	47c1                	li	a5,16
    800043be:	08f51b63          	bne	a0,a5,80004454 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800043c2:	04491703          	lh	a4,68(s2)
    800043c6:	4785                	li	a5,1
    800043c8:	08f70d63          	beq	a4,a5,80004462 <sys_unlink+0x14c>
  iunlockput(dp);
    800043cc:	8526                	mv	a0,s1
    800043ce:	f0cfe0ef          	jal	80002ada <iunlockput>
  ip->nlink--;
    800043d2:	04a95783          	lhu	a5,74(s2)
    800043d6:	37fd                	addiw	a5,a5,-1
    800043d8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800043dc:	854a                	mv	a0,s2
    800043de:	c3efe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800043e2:	854a                	mv	a0,s2
    800043e4:	ef6fe0ef          	jal	80002ada <iunlockput>
  end_op();
    800043e8:	de9fe0ef          	jal	800031d0 <end_op>
  return 0;
    800043ec:	4501                	li	a0,0
    800043ee:	64ee                	ld	s1,216(sp)
    800043f0:	694e                	ld	s2,208(sp)
    800043f2:	a849                	j	80004484 <sys_unlink+0x16e>
    end_op();
    800043f4:	dddfe0ef          	jal	800031d0 <end_op>
    return -1;
    800043f8:	557d                	li	a0,-1
    800043fa:	64ee                	ld	s1,216(sp)
    800043fc:	a061                	j	80004484 <sys_unlink+0x16e>
    800043fe:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004400:	00003517          	auipc	a0,0x3
    80004404:	26850513          	addi	a0,a0,616 # 80007668 <etext+0x668>
    80004408:	27a010ef          	jal	80005682 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000440c:	04c92703          	lw	a4,76(s2)
    80004410:	02000793          	li	a5,32
    80004414:	f8e7f5e3          	bgeu	a5,a4,8000439e <sys_unlink+0x88>
    80004418:	e5ce                	sd	s3,200(sp)
    8000441a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000441e:	4741                	li	a4,16
    80004420:	86ce                	mv	a3,s3
    80004422:	f1840613          	addi	a2,s0,-232
    80004426:	4581                	li	a1,0
    80004428:	854a                	mv	a0,s2
    8000442a:	efafe0ef          	jal	80002b24 <readi>
    8000442e:	47c1                	li	a5,16
    80004430:	00f51c63          	bne	a0,a5,80004448 <sys_unlink+0x132>
    if(de.inum != 0)
    80004434:	f1845783          	lhu	a5,-232(s0)
    80004438:	efa1                	bnez	a5,80004490 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000443a:	29c1                	addiw	s3,s3,16
    8000443c:	04c92783          	lw	a5,76(s2)
    80004440:	fcf9efe3          	bltu	s3,a5,8000441e <sys_unlink+0x108>
    80004444:	69ae                	ld	s3,200(sp)
    80004446:	bfa1                	j	8000439e <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004448:	00003517          	auipc	a0,0x3
    8000444c:	23850513          	addi	a0,a0,568 # 80007680 <etext+0x680>
    80004450:	232010ef          	jal	80005682 <panic>
    80004454:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004456:	00003517          	auipc	a0,0x3
    8000445a:	24250513          	addi	a0,a0,578 # 80007698 <etext+0x698>
    8000445e:	224010ef          	jal	80005682 <panic>
    dp->nlink--;
    80004462:	04a4d783          	lhu	a5,74(s1)
    80004466:	37fd                	addiw	a5,a5,-1
    80004468:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000446c:	8526                	mv	a0,s1
    8000446e:	baefe0ef          	jal	8000281c <iupdate>
    80004472:	bfa9                	j	800043cc <sys_unlink+0xb6>
    80004474:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004476:	8526                	mv	a0,s1
    80004478:	e62fe0ef          	jal	80002ada <iunlockput>
  end_op();
    8000447c:	d55fe0ef          	jal	800031d0 <end_op>
  return -1;
    80004480:	557d                	li	a0,-1
    80004482:	64ee                	ld	s1,216(sp)
}
    80004484:	70ae                	ld	ra,232(sp)
    80004486:	740e                	ld	s0,224(sp)
    80004488:	616d                	addi	sp,sp,240
    8000448a:	8082                	ret
    return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	bfdd                	j	80004484 <sys_unlink+0x16e>
    iunlockput(ip);
    80004490:	854a                	mv	a0,s2
    80004492:	e48fe0ef          	jal	80002ada <iunlockput>
    goto bad;
    80004496:	694e                	ld	s2,208(sp)
    80004498:	69ae                	ld	s3,200(sp)
    8000449a:	bff1                	j	80004476 <sys_unlink+0x160>

000000008000449c <sys_open>:

uint64
sys_open(void)
{
    8000449c:	7131                	addi	sp,sp,-192
    8000449e:	fd06                	sd	ra,184(sp)
    800044a0:	f922                	sd	s0,176(sp)
    800044a2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800044a4:	f4c40593          	addi	a1,s0,-180
    800044a8:	4505                	li	a0,1
    800044aa:	9fbfd0ef          	jal	80001ea4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044ae:	08000613          	li	a2,128
    800044b2:	f5040593          	addi	a1,s0,-176
    800044b6:	4501                	li	a0,0
    800044b8:	a25fd0ef          	jal	80001edc <argstr>
    800044bc:	87aa                	mv	a5,a0
    return -1;
    800044be:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044c0:	0a07c263          	bltz	a5,80004564 <sys_open+0xc8>
    800044c4:	f526                	sd	s1,168(sp)

  begin_op();
    800044c6:	ca1fe0ef          	jal	80003166 <begin_op>

  if(omode & O_CREATE){
    800044ca:	f4c42783          	lw	a5,-180(s0)
    800044ce:	2007f793          	andi	a5,a5,512
    800044d2:	c3d5                	beqz	a5,80004576 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800044d4:	4681                	li	a3,0
    800044d6:	4601                	li	a2,0
    800044d8:	4589                	li	a1,2
    800044da:	f5040513          	addi	a0,s0,-176
    800044de:	aa9ff0ef          	jal	80003f86 <create>
    800044e2:	84aa                	mv	s1,a0
    if(ip == 0){
    800044e4:	c541                	beqz	a0,8000456c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800044e6:	04449703          	lh	a4,68(s1)
    800044ea:	478d                	li	a5,3
    800044ec:	00f71763          	bne	a4,a5,800044fa <sys_open+0x5e>
    800044f0:	0464d703          	lhu	a4,70(s1)
    800044f4:	47a5                	li	a5,9
    800044f6:	0ae7ed63          	bltu	a5,a4,800045b0 <sys_open+0x114>
    800044fa:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800044fc:	fe1fe0ef          	jal	800034dc <filealloc>
    80004500:	892a                	mv	s2,a0
    80004502:	c179                	beqz	a0,800045c8 <sys_open+0x12c>
    80004504:	ed4e                	sd	s3,152(sp)
    80004506:	a43ff0ef          	jal	80003f48 <fdalloc>
    8000450a:	89aa                	mv	s3,a0
    8000450c:	0a054a63          	bltz	a0,800045c0 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004510:	04449703          	lh	a4,68(s1)
    80004514:	478d                	li	a5,3
    80004516:	0cf70263          	beq	a4,a5,800045da <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000451a:	4789                	li	a5,2
    8000451c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004520:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004524:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004528:	f4c42783          	lw	a5,-180(s0)
    8000452c:	0017c713          	xori	a4,a5,1
    80004530:	8b05                	andi	a4,a4,1
    80004532:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004536:	0037f713          	andi	a4,a5,3
    8000453a:	00e03733          	snez	a4,a4
    8000453e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004542:	4007f793          	andi	a5,a5,1024
    80004546:	c791                	beqz	a5,80004552 <sys_open+0xb6>
    80004548:	04449703          	lh	a4,68(s1)
    8000454c:	4789                	li	a5,2
    8000454e:	08f70d63          	beq	a4,a5,800045e8 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004552:	8526                	mv	a0,s1
    80004554:	c2afe0ef          	jal	8000297e <iunlock>
  end_op();
    80004558:	c79fe0ef          	jal	800031d0 <end_op>

  return fd;
    8000455c:	854e                	mv	a0,s3
    8000455e:	74aa                	ld	s1,168(sp)
    80004560:	790a                	ld	s2,160(sp)
    80004562:	69ea                	ld	s3,152(sp)
}
    80004564:	70ea                	ld	ra,184(sp)
    80004566:	744a                	ld	s0,176(sp)
    80004568:	6129                	addi	sp,sp,192
    8000456a:	8082                	ret
      end_op();
    8000456c:	c65fe0ef          	jal	800031d0 <end_op>
      return -1;
    80004570:	557d                	li	a0,-1
    80004572:	74aa                	ld	s1,168(sp)
    80004574:	bfc5                	j	80004564 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004576:	f5040513          	addi	a0,s0,-176
    8000457a:	a31fe0ef          	jal	80002faa <namei>
    8000457e:	84aa                	mv	s1,a0
    80004580:	c11d                	beqz	a0,800045a6 <sys_open+0x10a>
    ilock(ip);
    80004582:	b4efe0ef          	jal	800028d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004586:	04449703          	lh	a4,68(s1)
    8000458a:	4785                	li	a5,1
    8000458c:	f4f71de3          	bne	a4,a5,800044e6 <sys_open+0x4a>
    80004590:	f4c42783          	lw	a5,-180(s0)
    80004594:	d3bd                	beqz	a5,800044fa <sys_open+0x5e>
      iunlockput(ip);
    80004596:	8526                	mv	a0,s1
    80004598:	d42fe0ef          	jal	80002ada <iunlockput>
      end_op();
    8000459c:	c35fe0ef          	jal	800031d0 <end_op>
      return -1;
    800045a0:	557d                	li	a0,-1
    800045a2:	74aa                	ld	s1,168(sp)
    800045a4:	b7c1                	j	80004564 <sys_open+0xc8>
      end_op();
    800045a6:	c2bfe0ef          	jal	800031d0 <end_op>
      return -1;
    800045aa:	557d                	li	a0,-1
    800045ac:	74aa                	ld	s1,168(sp)
    800045ae:	bf5d                	j	80004564 <sys_open+0xc8>
    iunlockput(ip);
    800045b0:	8526                	mv	a0,s1
    800045b2:	d28fe0ef          	jal	80002ada <iunlockput>
    end_op();
    800045b6:	c1bfe0ef          	jal	800031d0 <end_op>
    return -1;
    800045ba:	557d                	li	a0,-1
    800045bc:	74aa                	ld	s1,168(sp)
    800045be:	b75d                	j	80004564 <sys_open+0xc8>
      fileclose(f);
    800045c0:	854a                	mv	a0,s2
    800045c2:	fbffe0ef          	jal	80003580 <fileclose>
    800045c6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800045c8:	8526                	mv	a0,s1
    800045ca:	d10fe0ef          	jal	80002ada <iunlockput>
    end_op();
    800045ce:	c03fe0ef          	jal	800031d0 <end_op>
    return -1;
    800045d2:	557d                	li	a0,-1
    800045d4:	74aa                	ld	s1,168(sp)
    800045d6:	790a                	ld	s2,160(sp)
    800045d8:	b771                	j	80004564 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800045da:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800045de:	04649783          	lh	a5,70(s1)
    800045e2:	02f91223          	sh	a5,36(s2)
    800045e6:	bf3d                	j	80004524 <sys_open+0x88>
    itrunc(ip);
    800045e8:	8526                	mv	a0,s1
    800045ea:	bd4fe0ef          	jal	800029be <itrunc>
    800045ee:	b795                	j	80004552 <sys_open+0xb6>

00000000800045f0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800045f0:	7175                	addi	sp,sp,-144
    800045f2:	e506                	sd	ra,136(sp)
    800045f4:	e122                	sd	s0,128(sp)
    800045f6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800045f8:	b6ffe0ef          	jal	80003166 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800045fc:	08000613          	li	a2,128
    80004600:	f7040593          	addi	a1,s0,-144
    80004604:	4501                	li	a0,0
    80004606:	8d7fd0ef          	jal	80001edc <argstr>
    8000460a:	02054363          	bltz	a0,80004630 <sys_mkdir+0x40>
    8000460e:	4681                	li	a3,0
    80004610:	4601                	li	a2,0
    80004612:	4585                	li	a1,1
    80004614:	f7040513          	addi	a0,s0,-144
    80004618:	96fff0ef          	jal	80003f86 <create>
    8000461c:	c911                	beqz	a0,80004630 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000461e:	cbcfe0ef          	jal	80002ada <iunlockput>
  end_op();
    80004622:	baffe0ef          	jal	800031d0 <end_op>
  return 0;
    80004626:	4501                	li	a0,0
}
    80004628:	60aa                	ld	ra,136(sp)
    8000462a:	640a                	ld	s0,128(sp)
    8000462c:	6149                	addi	sp,sp,144
    8000462e:	8082                	ret
    end_op();
    80004630:	ba1fe0ef          	jal	800031d0 <end_op>
    return -1;
    80004634:	557d                	li	a0,-1
    80004636:	bfcd                	j	80004628 <sys_mkdir+0x38>

0000000080004638 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004638:	7135                	addi	sp,sp,-160
    8000463a:	ed06                	sd	ra,152(sp)
    8000463c:	e922                	sd	s0,144(sp)
    8000463e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004640:	b27fe0ef          	jal	80003166 <begin_op>
  argint(1, &major);
    80004644:	f6c40593          	addi	a1,s0,-148
    80004648:	4505                	li	a0,1
    8000464a:	85bfd0ef          	jal	80001ea4 <argint>
  argint(2, &minor);
    8000464e:	f6840593          	addi	a1,s0,-152
    80004652:	4509                	li	a0,2
    80004654:	851fd0ef          	jal	80001ea4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004658:	08000613          	li	a2,128
    8000465c:	f7040593          	addi	a1,s0,-144
    80004660:	4501                	li	a0,0
    80004662:	87bfd0ef          	jal	80001edc <argstr>
    80004666:	02054563          	bltz	a0,80004690 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000466a:	f6841683          	lh	a3,-152(s0)
    8000466e:	f6c41603          	lh	a2,-148(s0)
    80004672:	458d                	li	a1,3
    80004674:	f7040513          	addi	a0,s0,-144
    80004678:	90fff0ef          	jal	80003f86 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000467c:	c911                	beqz	a0,80004690 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000467e:	c5cfe0ef          	jal	80002ada <iunlockput>
  end_op();
    80004682:	b4ffe0ef          	jal	800031d0 <end_op>
  return 0;
    80004686:	4501                	li	a0,0
}
    80004688:	60ea                	ld	ra,152(sp)
    8000468a:	644a                	ld	s0,144(sp)
    8000468c:	610d                	addi	sp,sp,160
    8000468e:	8082                	ret
    end_op();
    80004690:	b41fe0ef          	jal	800031d0 <end_op>
    return -1;
    80004694:	557d                	li	a0,-1
    80004696:	bfcd                	j	80004688 <sys_mknod+0x50>

0000000080004698 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004698:	7135                	addi	sp,sp,-160
    8000469a:	ed06                	sd	ra,152(sp)
    8000469c:	e922                	sd	s0,144(sp)
    8000469e:	e14a                	sd	s2,128(sp)
    800046a0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800046a2:	87bfc0ef          	jal	80000f1c <myproc>
    800046a6:	892a                	mv	s2,a0
  
  begin_op();
    800046a8:	abffe0ef          	jal	80003166 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800046ac:	08000613          	li	a2,128
    800046b0:	f6040593          	addi	a1,s0,-160
    800046b4:	4501                	li	a0,0
    800046b6:	827fd0ef          	jal	80001edc <argstr>
    800046ba:	04054363          	bltz	a0,80004700 <sys_chdir+0x68>
    800046be:	e526                	sd	s1,136(sp)
    800046c0:	f6040513          	addi	a0,s0,-160
    800046c4:	8e7fe0ef          	jal	80002faa <namei>
    800046c8:	84aa                	mv	s1,a0
    800046ca:	c915                	beqz	a0,800046fe <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800046cc:	a04fe0ef          	jal	800028d0 <ilock>
  if(ip->type != T_DIR){
    800046d0:	04449703          	lh	a4,68(s1)
    800046d4:	4785                	li	a5,1
    800046d6:	02f71963          	bne	a4,a5,80004708 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800046da:	8526                	mv	a0,s1
    800046dc:	aa2fe0ef          	jal	8000297e <iunlock>
  iput(p->cwd);
    800046e0:	15093503          	ld	a0,336(s2)
    800046e4:	b6efe0ef          	jal	80002a52 <iput>
  end_op();
    800046e8:	ae9fe0ef          	jal	800031d0 <end_op>
  p->cwd = ip;
    800046ec:	14993823          	sd	s1,336(s2)
  return 0;
    800046f0:	4501                	li	a0,0
    800046f2:	64aa                	ld	s1,136(sp)
}
    800046f4:	60ea                	ld	ra,152(sp)
    800046f6:	644a                	ld	s0,144(sp)
    800046f8:	690a                	ld	s2,128(sp)
    800046fa:	610d                	addi	sp,sp,160
    800046fc:	8082                	ret
    800046fe:	64aa                	ld	s1,136(sp)
    end_op();
    80004700:	ad1fe0ef          	jal	800031d0 <end_op>
    return -1;
    80004704:	557d                	li	a0,-1
    80004706:	b7fd                	j	800046f4 <sys_chdir+0x5c>
    iunlockput(ip);
    80004708:	8526                	mv	a0,s1
    8000470a:	bd0fe0ef          	jal	80002ada <iunlockput>
    end_op();
    8000470e:	ac3fe0ef          	jal	800031d0 <end_op>
    return -1;
    80004712:	557d                	li	a0,-1
    80004714:	64aa                	ld	s1,136(sp)
    80004716:	bff9                	j	800046f4 <sys_chdir+0x5c>

0000000080004718 <sys_exec>:

uint64
sys_exec(void)
{
    80004718:	7121                	addi	sp,sp,-448
    8000471a:	ff06                	sd	ra,440(sp)
    8000471c:	fb22                	sd	s0,432(sp)
    8000471e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004720:	e4840593          	addi	a1,s0,-440
    80004724:	4505                	li	a0,1
    80004726:	f9afd0ef          	jal	80001ec0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000472a:	08000613          	li	a2,128
    8000472e:	f5040593          	addi	a1,s0,-176
    80004732:	4501                	li	a0,0
    80004734:	fa8fd0ef          	jal	80001edc <argstr>
    80004738:	87aa                	mv	a5,a0
    return -1;
    8000473a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000473c:	0c07c463          	bltz	a5,80004804 <sys_exec+0xec>
    80004740:	f726                	sd	s1,424(sp)
    80004742:	f34a                	sd	s2,416(sp)
    80004744:	ef4e                	sd	s3,408(sp)
    80004746:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004748:	10000613          	li	a2,256
    8000474c:	4581                	li	a1,0
    8000474e:	e5040513          	addi	a0,s0,-432
    80004752:	af1fb0ef          	jal	80000242 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004756:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000475a:	89a6                	mv	s3,s1
    8000475c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000475e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004762:	00391513          	slli	a0,s2,0x3
    80004766:	e4040593          	addi	a1,s0,-448
    8000476a:	e4843783          	ld	a5,-440(s0)
    8000476e:	953e                	add	a0,a0,a5
    80004770:	eaafd0ef          	jal	80001e1a <fetchaddr>
    80004774:	02054663          	bltz	a0,800047a0 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004778:	e4043783          	ld	a5,-448(s0)
    8000477c:	c3a9                	beqz	a5,800047be <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000477e:	a5bfb0ef          	jal	800001d8 <kalloc>
    80004782:	85aa                	mv	a1,a0
    80004784:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004788:	cd01                	beqz	a0,800047a0 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000478a:	6605                	lui	a2,0x1
    8000478c:	e4043503          	ld	a0,-448(s0)
    80004790:	ed4fd0ef          	jal	80001e64 <fetchstr>
    80004794:	00054663          	bltz	a0,800047a0 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004798:	0905                	addi	s2,s2,1
    8000479a:	09a1                	addi	s3,s3,8
    8000479c:	fd4913e3          	bne	s2,s4,80004762 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047a0:	f5040913          	addi	s2,s0,-176
    800047a4:	6088                	ld	a0,0(s1)
    800047a6:	c931                	beqz	a0,800047fa <sys_exec+0xe2>
    kfree(argv[i]);
    800047a8:	909fb0ef          	jal	800000b0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047ac:	04a1                	addi	s1,s1,8
    800047ae:	ff249be3          	bne	s1,s2,800047a4 <sys_exec+0x8c>
  return -1;
    800047b2:	557d                	li	a0,-1
    800047b4:	74ba                	ld	s1,424(sp)
    800047b6:	791a                	ld	s2,416(sp)
    800047b8:	69fa                	ld	s3,408(sp)
    800047ba:	6a5a                	ld	s4,400(sp)
    800047bc:	a0a1                	j	80004804 <sys_exec+0xec>
      argv[i] = 0;
    800047be:	0009079b          	sext.w	a5,s2
    800047c2:	078e                	slli	a5,a5,0x3
    800047c4:	fd078793          	addi	a5,a5,-48
    800047c8:	97a2                	add	a5,a5,s0
    800047ca:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800047ce:	e5040593          	addi	a1,s0,-432
    800047d2:	f5040513          	addi	a0,s0,-176
    800047d6:	ba8ff0ef          	jal	80003b7e <exec>
    800047da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047dc:	f5040993          	addi	s3,s0,-176
    800047e0:	6088                	ld	a0,0(s1)
    800047e2:	c511                	beqz	a0,800047ee <sys_exec+0xd6>
    kfree(argv[i]);
    800047e4:	8cdfb0ef          	jal	800000b0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047e8:	04a1                	addi	s1,s1,8
    800047ea:	ff349be3          	bne	s1,s3,800047e0 <sys_exec+0xc8>
  return ret;
    800047ee:	854a                	mv	a0,s2
    800047f0:	74ba                	ld	s1,424(sp)
    800047f2:	791a                	ld	s2,416(sp)
    800047f4:	69fa                	ld	s3,408(sp)
    800047f6:	6a5a                	ld	s4,400(sp)
    800047f8:	a031                	j	80004804 <sys_exec+0xec>
  return -1;
    800047fa:	557d                	li	a0,-1
    800047fc:	74ba                	ld	s1,424(sp)
    800047fe:	791a                	ld	s2,416(sp)
    80004800:	69fa                	ld	s3,408(sp)
    80004802:	6a5a                	ld	s4,400(sp)
}
    80004804:	70fa                	ld	ra,440(sp)
    80004806:	745a                	ld	s0,432(sp)
    80004808:	6139                	addi	sp,sp,448
    8000480a:	8082                	ret

000000008000480c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000480c:	7139                	addi	sp,sp,-64
    8000480e:	fc06                	sd	ra,56(sp)
    80004810:	f822                	sd	s0,48(sp)
    80004812:	f426                	sd	s1,40(sp)
    80004814:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004816:	f06fc0ef          	jal	80000f1c <myproc>
    8000481a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000481c:	fd840593          	addi	a1,s0,-40
    80004820:	4501                	li	a0,0
    80004822:	e9efd0ef          	jal	80001ec0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004826:	fc840593          	addi	a1,s0,-56
    8000482a:	fd040513          	addi	a0,s0,-48
    8000482e:	85cff0ef          	jal	8000388a <pipealloc>
    return -1;
    80004832:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004834:	0a054463          	bltz	a0,800048dc <sys_pipe+0xd0>
  fd0 = -1;
    80004838:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000483c:	fd043503          	ld	a0,-48(s0)
    80004840:	f08ff0ef          	jal	80003f48 <fdalloc>
    80004844:	fca42223          	sw	a0,-60(s0)
    80004848:	08054163          	bltz	a0,800048ca <sys_pipe+0xbe>
    8000484c:	fc843503          	ld	a0,-56(s0)
    80004850:	ef8ff0ef          	jal	80003f48 <fdalloc>
    80004854:	fca42023          	sw	a0,-64(s0)
    80004858:	06054063          	bltz	a0,800048b8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000485c:	4691                	li	a3,4
    8000485e:	fc440613          	addi	a2,s0,-60
    80004862:	fd843583          	ld	a1,-40(s0)
    80004866:	68a8                	ld	a0,80(s1)
    80004868:	a76fc0ef          	jal	80000ade <copyout>
    8000486c:	00054e63          	bltz	a0,80004888 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004870:	4691                	li	a3,4
    80004872:	fc040613          	addi	a2,s0,-64
    80004876:	fd843583          	ld	a1,-40(s0)
    8000487a:	0591                	addi	a1,a1,4
    8000487c:	68a8                	ld	a0,80(s1)
    8000487e:	a60fc0ef          	jal	80000ade <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004882:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004884:	04055c63          	bgez	a0,800048dc <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004888:	fc442783          	lw	a5,-60(s0)
    8000488c:	07e9                	addi	a5,a5,26
    8000488e:	078e                	slli	a5,a5,0x3
    80004890:	97a6                	add	a5,a5,s1
    80004892:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004896:	fc042783          	lw	a5,-64(s0)
    8000489a:	07e9                	addi	a5,a5,26
    8000489c:	078e                	slli	a5,a5,0x3
    8000489e:	94be                	add	s1,s1,a5
    800048a0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800048a4:	fd043503          	ld	a0,-48(s0)
    800048a8:	cd9fe0ef          	jal	80003580 <fileclose>
    fileclose(wf);
    800048ac:	fc843503          	ld	a0,-56(s0)
    800048b0:	cd1fe0ef          	jal	80003580 <fileclose>
    return -1;
    800048b4:	57fd                	li	a5,-1
    800048b6:	a01d                	j	800048dc <sys_pipe+0xd0>
    if(fd0 >= 0)
    800048b8:	fc442783          	lw	a5,-60(s0)
    800048bc:	0007c763          	bltz	a5,800048ca <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800048c0:	07e9                	addi	a5,a5,26
    800048c2:	078e                	slli	a5,a5,0x3
    800048c4:	97a6                	add	a5,a5,s1
    800048c6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800048ca:	fd043503          	ld	a0,-48(s0)
    800048ce:	cb3fe0ef          	jal	80003580 <fileclose>
    fileclose(wf);
    800048d2:	fc843503          	ld	a0,-56(s0)
    800048d6:	cabfe0ef          	jal	80003580 <fileclose>
    return -1;
    800048da:	57fd                	li	a5,-1
}
    800048dc:	853e                	mv	a0,a5
    800048de:	70e2                	ld	ra,56(sp)
    800048e0:	7442                	ld	s0,48(sp)
    800048e2:	74a2                	ld	s1,40(sp)
    800048e4:	6121                	addi	sp,sp,64
    800048e6:	8082                	ret
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
    80004918:	c12fd0ef          	jal	80001d2a <kerneltrap>
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
    80004970:	d80fc0ef          	jal	80000ef0 <cpuid>
  
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
    800049a4:	d4cfc0ef          	jal	80000ef0 <cpuid>
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
    800049c8:	d28fc0ef          	jal	80000ef0 <cpuid>
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
    800049f4:	a9078793          	addi	a5,a5,-1392 # 8003b480 <disk>
    800049f8:	97aa                	add	a5,a5,a0
    800049fa:	0187c783          	lbu	a5,24(a5)
    800049fe:	e7b9                	bnez	a5,80004a4c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004a00:	00451693          	slli	a3,a0,0x4
    80004a04:	00037797          	auipc	a5,0x37
    80004a08:	a7c78793          	addi	a5,a5,-1412 # 8003b480 <disk>
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
    80004a30:	a6c50513          	addi	a0,a0,-1428 # 8003b498 <disk+0x18>
    80004a34:	b03fc0ef          	jal	80001536 <wakeup>
}
    80004a38:	60a2                	ld	ra,8(sp)
    80004a3a:	6402                	ld	s0,0(sp)
    80004a3c:	0141                	addi	sp,sp,16
    80004a3e:	8082                	ret
    panic("free_desc 1");
    80004a40:	00003517          	auipc	a0,0x3
    80004a44:	c6850513          	addi	a0,a0,-920 # 800076a8 <etext+0x6a8>
    80004a48:	43b000ef          	jal	80005682 <panic>
    panic("free_desc 2");
    80004a4c:	00003517          	auipc	a0,0x3
    80004a50:	c6c50513          	addi	a0,a0,-916 # 800076b8 <etext+0x6b8>
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
    80004a68:	c6458593          	addi	a1,a1,-924 # 800076c8 <etext+0x6c8>
    80004a6c:	00037517          	auipc	a0,0x37
    80004a70:	b3c50513          	addi	a0,a0,-1220 # 8003b5a8 <disk+0x128>
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
    80004ad8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb09f>
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
    80004b2e:	95648493          	addi	s1,s1,-1706 # 8003b480 <disk>
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
    80004b4c:	94073703          	ld	a4,-1728(a4) # 8003b488 <disk+0x8>
    80004b50:	0e070a63          	beqz	a4,80004c44 <virtio_disk_init+0x1ec>
    80004b54:	0e078863          	beqz	a5,80004c44 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004b58:	6605                	lui	a2,0x1
    80004b5a:	4581                	li	a1,0
    80004b5c:	ee6fb0ef          	jal	80000242 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004b60:	00037497          	auipc	s1,0x37
    80004b64:	92048493          	addi	s1,s1,-1760 # 8003b480 <disk>
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
    80004c0c:	ad050513          	addi	a0,a0,-1328 # 800076d8 <etext+0x6d8>
    80004c10:	273000ef          	jal	80005682 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004c14:	00003517          	auipc	a0,0x3
    80004c18:	ae450513          	addi	a0,a0,-1308 # 800076f8 <etext+0x6f8>
    80004c1c:	267000ef          	jal	80005682 <panic>
    panic("virtio disk should not be ready");
    80004c20:	00003517          	auipc	a0,0x3
    80004c24:	af850513          	addi	a0,a0,-1288 # 80007718 <etext+0x718>
    80004c28:	25b000ef          	jal	80005682 <panic>
    panic("virtio disk has no queue 0");
    80004c2c:	00003517          	auipc	a0,0x3
    80004c30:	b0c50513          	addi	a0,a0,-1268 # 80007738 <etext+0x738>
    80004c34:	24f000ef          	jal	80005682 <panic>
    panic("virtio disk max queue too short");
    80004c38:	00003517          	auipc	a0,0x3
    80004c3c:	b2050513          	addi	a0,a0,-1248 # 80007758 <etext+0x758>
    80004c40:	243000ef          	jal	80005682 <panic>
    panic("virtio disk kalloc");
    80004c44:	00003517          	auipc	a0,0x3
    80004c48:	b3450513          	addi	a0,a0,-1228 # 80007778 <etext+0x778>
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
    80004c80:	92c50513          	addi	a0,a0,-1748 # 8003b5a8 <disk+0x128>
    80004c84:	52d000ef          	jal	800059b0 <acquire>
  for(int i = 0; i < 3; i++){
    80004c88:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004c8a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004c8c:	00036b17          	auipc	s6,0x36
    80004c90:	7f4b0b13          	addi	s6,s6,2036 # 8003b480 <disk>
  for(int i = 0; i < 3; i++){
    80004c94:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c96:	00037c17          	auipc	s8,0x37
    80004c9a:	912c0c13          	addi	s8,s8,-1774 # 8003b5a8 <disk+0x128>
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
    80004cbc:	7c870713          	addi	a4,a4,1992 # 8003b480 <disk>
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
    80004cf4:	7a850513          	addi	a0,a0,1960 # 8003b498 <disk+0x18>
    80004cf8:	ff2fc0ef          	jal	800014ea <sleep>
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
    80004d10:	77478793          	addi	a5,a5,1908 # 8003b480 <disk>
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
    80004de6:	7c690913          	addi	s2,s2,1990 # 8003b5a8 <disk+0x128>
  while(b->disk == 1) {
    80004dea:	4485                	li	s1,1
    80004dec:	01079a63          	bne	a5,a6,80004e00 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004df0:	85ca                	mv	a1,s2
    80004df2:	8552                	mv	a0,s4
    80004df4:	ef6fc0ef          	jal	800014ea <sleep>
  while(b->disk == 1) {
    80004df8:	004a2783          	lw	a5,4(s4)
    80004dfc:	fe978ae3          	beq	a5,s1,80004df0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004e00:	f9042903          	lw	s2,-112(s0)
    80004e04:	00290713          	addi	a4,s2,2
    80004e08:	0712                	slli	a4,a4,0x4
    80004e0a:	00036797          	auipc	a5,0x36
    80004e0e:	67678793          	addi	a5,a5,1654 # 8003b480 <disk>
    80004e12:	97ba                	add	a5,a5,a4
    80004e14:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004e18:	00036997          	auipc	s3,0x36
    80004e1c:	66898993          	addi	s3,s3,1640 # 8003b480 <disk>
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
    80004e40:	76c50513          	addi	a0,a0,1900 # 8003b5a8 <disk+0x128>
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
    80004e70:	61448493          	addi	s1,s1,1556 # 8003b480 <disk>
    80004e74:	00036517          	auipc	a0,0x36
    80004e78:	73450513          	addi	a0,a0,1844 # 8003b5a8 <disk+0x128>
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
    80004ecc:	e6afc0ef          	jal	80001536 <wakeup>

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
    80004eec:	6c050513          	addi	a0,a0,1728 # 8003b5a8 <disk+0x128>
    80004ef0:	359000ef          	jal	80005a48 <release>
}
    80004ef4:	60e2                	ld	ra,24(sp)
    80004ef6:	6442                	ld	s0,16(sp)
    80004ef8:	64a2                	ld	s1,8(sp)
    80004efa:	6105                	addi	sp,sp,32
    80004efc:	8082                	ret
      panic("virtio_disk_intr status");
    80004efe:	00003517          	auipc	a0,0x3
    80004f02:	89250513          	addi	a0,a0,-1902 # 80007790 <etext+0x790>
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
    80004f5c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb13f>
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
    80004fe8:	8a9fc0ef          	jal	80001890 <either_copyin>
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
    80005046:	57e50513          	addi	a0,a0,1406 # 800435c0 <cons>
    8000504a:	167000ef          	jal	800059b0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000504e:	0003e497          	auipc	s1,0x3e
    80005052:	57248493          	addi	s1,s1,1394 # 800435c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005056:	0003e917          	auipc	s2,0x3e
    8000505a:	60290913          	addi	s2,s2,1538 # 80043658 <cons+0x98>
  while(n > 0){
    8000505e:	0b305d63          	blez	s3,80005118 <consoleread+0xf4>
    while(cons.r == cons.w){
    80005062:	0984a783          	lw	a5,152(s1)
    80005066:	09c4a703          	lw	a4,156(s1)
    8000506a:	0af71263          	bne	a4,a5,8000510e <consoleread+0xea>
      if(killed(myproc())){
    8000506e:	eaffb0ef          	jal	80000f1c <myproc>
    80005072:	eb0fc0ef          	jal	80001722 <killed>
    80005076:	e12d                	bnez	a0,800050d8 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80005078:	85a6                	mv	a1,s1
    8000507a:	854a                	mv	a0,s2
    8000507c:	c6efc0ef          	jal	800014ea <sleep>
    while(cons.r == cons.w){
    80005080:	0984a783          	lw	a5,152(s1)
    80005084:	09c4a703          	lw	a4,156(s1)
    80005088:	fef703e3          	beq	a4,a5,8000506e <consoleread+0x4a>
    8000508c:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    8000508e:	0003e717          	auipc	a4,0x3e
    80005092:	53270713          	addi	a4,a4,1330 # 800435c0 <cons>
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
    800050c0:	f86fc0ef          	jal	80001846 <either_copyout>
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
    800050dc:	4e850513          	addi	a0,a0,1256 # 800435c0 <cons>
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
    80005106:	54f72b23          	sw	a5,1366(a4) # 80043658 <cons+0x98>
    8000510a:	6be2                	ld	s7,24(sp)
    8000510c:	a031                	j	80005118 <consoleread+0xf4>
    8000510e:	ec5e                	sd	s7,24(sp)
    80005110:	bfbd                	j	8000508e <consoleread+0x6a>
    80005112:	6be2                	ld	s7,24(sp)
    80005114:	a011                	j	80005118 <consoleread+0xf4>
    80005116:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005118:	0003e517          	auipc	a0,0x3e
    8000511c:	4a850513          	addi	a0,a0,1192 # 800435c0 <cons>
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
    80005170:	45450513          	addi	a0,a0,1108 # 800435c0 <cons>
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
    8000518e:	f4cfc0ef          	jal	800018da <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005192:	0003e517          	auipc	a0,0x3e
    80005196:	42e50513          	addi	a0,a0,1070 # 800435c0 <cons>
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
    800051b4:	41070713          	addi	a4,a4,1040 # 800435c0 <cons>
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
    800051da:	3ea78793          	addi	a5,a5,1002 # 800435c0 <cons>
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
    80005208:	4547a783          	lw	a5,1108(a5) # 80043658 <cons+0x98>
    8000520c:	9f1d                	subw	a4,a4,a5
    8000520e:	08000793          	li	a5,128
    80005212:	f8f710e3          	bne	a4,a5,80005192 <consoleintr+0x32>
    80005216:	a07d                	j	800052c4 <consoleintr+0x164>
    80005218:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000521a:	0003e717          	auipc	a4,0x3e
    8000521e:	3a670713          	addi	a4,a4,934 # 800435c0 <cons>
    80005222:	0a072783          	lw	a5,160(a4)
    80005226:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000522a:	0003e497          	auipc	s1,0x3e
    8000522e:	39648493          	addi	s1,s1,918 # 800435c0 <cons>
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
    80005270:	35470713          	addi	a4,a4,852 # 800435c0 <cons>
    80005274:	0a072783          	lw	a5,160(a4)
    80005278:	09c72703          	lw	a4,156(a4)
    8000527c:	f0f70be3          	beq	a4,a5,80005192 <consoleintr+0x32>
      cons.e--;
    80005280:	37fd                	addiw	a5,a5,-1
    80005282:	0003e717          	auipc	a4,0x3e
    80005286:	3cf72f23          	sw	a5,990(a4) # 80043660 <cons+0xa0>
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
    800052a4:	32078793          	addi	a5,a5,800 # 800435c0 <cons>
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
    800052c8:	38c7ac23          	sw	a2,920(a5) # 8004365c <cons+0x9c>
        wakeup(&cons.r);
    800052cc:	0003e517          	auipc	a0,0x3e
    800052d0:	38c50513          	addi	a0,a0,908 # 80043658 <cons+0x98>
    800052d4:	a62fc0ef          	jal	80001536 <wakeup>
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
    800052e6:	4c658593          	addi	a1,a1,1222 # 800077a8 <etext+0x7a8>
    800052ea:	0003e517          	auipc	a0,0x3e
    800052ee:	2d650513          	addi	a0,a0,726 # 800435c0 <cons>
    800052f2:	63e000ef          	jal	80005930 <initlock>

  uartinit();
    800052f6:	3f4000ef          	jal	800056ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800052fa:	00035797          	auipc	a5,0x35
    800052fe:	12e78793          	addi	a5,a5,302 # 8003a428 <devsw>
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
    80005338:	5cc60613          	addi	a2,a2,1484 # 80007900 <digits>
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
    800053d2:	2b27a783          	lw	a5,690(a5) # 80043680 <pr+0x18>
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
    8000541e:	24e50513          	addi	a0,a0,590 # 80043668 <pr>
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
    800055de:	326b8b93          	addi	s7,s7,806 # 80007900 <digits>
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
    8000562a:	18a90913          	addi	s2,s2,394 # 800077b0 <etext+0x7b0>
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
    80005678:	ff450513          	addi	a0,a0,-12 # 80043668 <pr>
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
    80005692:	fe07a923          	sw	zero,-14(a5) # 80043680 <pr+0x18>
  printf("panic: ");
    80005696:	00002517          	auipc	a0,0x2
    8000569a:	12250513          	addi	a0,a0,290 # 800077b8 <etext+0x7b8>
    8000569e:	d13ff0ef          	jal	800053b0 <printf>
  printf("%s\n", s);
    800056a2:	85a6                	mv	a1,s1
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	11c50513          	addi	a0,a0,284 # 800077c0 <etext+0x7c0>
    800056ac:	d05ff0ef          	jal	800053b0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800056b0:	4785                	li	a5,1
    800056b2:	00005717          	auipc	a4,0x5
    800056b6:	ccf72523          	sw	a5,-822(a4) # 8000a37c <panicked>
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
    800056ca:	fa248493          	addi	s1,s1,-94 # 80043668 <pr>
    800056ce:	00002597          	auipc	a1,0x2
    800056d2:	0fa58593          	addi	a1,a1,250 # 800077c8 <etext+0x7c8>
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
    8000572a:	0aa58593          	addi	a1,a1,170 # 800077d0 <etext+0x7d0>
    8000572e:	0003e517          	auipc	a0,0x3e
    80005732:	f5a50513          	addi	a0,a0,-166 # 80043688 <uart_tx_lock>
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
    80005756:	c2a7a783          	lw	a5,-982(a5) # 8000a37c <panicked>
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
    8000578c:	bf87b783          	ld	a5,-1032(a5) # 8000a380 <uart_tx_r>
    80005790:	00005717          	auipc	a4,0x5
    80005794:	bf873703          	ld	a4,-1032(a4) # 8000a388 <uart_tx_w>
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
    800057ba:	ed2a8a93          	addi	s5,s5,-302 # 80043688 <uart_tx_lock>
    uart_tx_r += 1;
    800057be:	00005497          	auipc	s1,0x5
    800057c2:	bc248493          	addi	s1,s1,-1086 # 8000a380 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800057c6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800057ca:	00005997          	auipc	s3,0x5
    800057ce:	bbe98993          	addi	s3,s3,-1090 # 8000a388 <uart_tx_w>
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
    800057ec:	d4bfb0ef          	jal	80001536 <wakeup>
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
    8000583e:	e4e50513          	addi	a0,a0,-434 # 80043688 <uart_tx_lock>
    80005842:	16e000ef          	jal	800059b0 <acquire>
  if(panicked){
    80005846:	00005797          	auipc	a5,0x5
    8000584a:	b367a783          	lw	a5,-1226(a5) # 8000a37c <panicked>
    8000584e:	efbd                	bnez	a5,800058cc <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005850:	00005717          	auipc	a4,0x5
    80005854:	b3873703          	ld	a4,-1224(a4) # 8000a388 <uart_tx_w>
    80005858:	00005797          	auipc	a5,0x5
    8000585c:	b287b783          	ld	a5,-1240(a5) # 8000a380 <uart_tx_r>
    80005860:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005864:	0003e997          	auipc	s3,0x3e
    80005868:	e2498993          	addi	s3,s3,-476 # 80043688 <uart_tx_lock>
    8000586c:	00005497          	auipc	s1,0x5
    80005870:	b1448493          	addi	s1,s1,-1260 # 8000a380 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005874:	00005917          	auipc	s2,0x5
    80005878:	b1490913          	addi	s2,s2,-1260 # 8000a388 <uart_tx_w>
    8000587c:	00e79d63          	bne	a5,a4,80005896 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005880:	85ce                	mv	a1,s3
    80005882:	8526                	mv	a0,s1
    80005884:	c67fb0ef          	jal	800014ea <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005888:	00093703          	ld	a4,0(s2)
    8000588c:	609c                	ld	a5,0(s1)
    8000588e:	02078793          	addi	a5,a5,32
    80005892:	fee787e3          	beq	a5,a4,80005880 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80005896:	0003e497          	auipc	s1,0x3e
    8000589a:	df248493          	addi	s1,s1,-526 # 80043688 <uart_tx_lock>
    8000589e:	01f77793          	andi	a5,a4,31
    800058a2:	97a6                	add	a5,a5,s1
    800058a4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800058a8:	0705                	addi	a4,a4,1
    800058aa:	00005797          	auipc	a5,0x5
    800058ae:	ace7bf23          	sd	a4,-1314(a5) # 8000a388 <uart_tx_w>
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
    80005912:	d7a48493          	addi	s1,s1,-646 # 80043688 <uart_tx_lock>
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
    8000595a:	da6fb0ef          	jal	80000f00 <mycpu>
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
    80005988:	d78fb0ef          	jal	80000f00 <mycpu>
    8000598c:	5d3c                	lw	a5,120(a0)
    8000598e:	cb99                	beqz	a5,800059a4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005990:	d70fb0ef          	jal	80000f00 <mycpu>
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
    800059a4:	d5cfb0ef          	jal	80000f00 <mycpu>
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
    800059d8:	d28fb0ef          	jal	80000f00 <mycpu>
    800059dc:	e888                	sd	a0,16(s1)
}
    800059de:	60e2                	ld	ra,24(sp)
    800059e0:	6442                	ld	s0,16(sp)
    800059e2:	64a2                	ld	s1,8(sp)
    800059e4:	6105                	addi	sp,sp,32
    800059e6:	8082                	ret
    panic("acquire");
    800059e8:	00002517          	auipc	a0,0x2
    800059ec:	df050513          	addi	a0,a0,-528 # 800077d8 <etext+0x7d8>
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
    800059fc:	d04fb0ef          	jal	80000f00 <mycpu>
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
    80005a34:	db050513          	addi	a0,a0,-592 # 800077e0 <etext+0x7e0>
    80005a38:	c4bff0ef          	jal	80005682 <panic>
    panic("pop_off");
    80005a3c:	00002517          	auipc	a0,0x2
    80005a40:	dbc50513          	addi	a0,a0,-580 # 800077f8 <etext+0x7f8>
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
    80005a7c:	d8850513          	addi	a0,a0,-632 # 80007800 <etext+0x800>
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
