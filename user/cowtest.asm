
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <simpletest>:
// allocate more than half of physical memory,
// then fork. this will fail in the default
// kernel, which does not support copy-on-write.
void
simpletest()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = (phys_size / 3) * 2;

  printf("simple: ");
   e:	00001517          	auipc	a0,0x1
  12:	ca250513          	addi	a0,a0,-862 # cb0 <malloc+0x100>
  16:	2e7000ef          	jal	afc <printf>
  
  char *p = sbrk(sz);
  1a:	05555537          	lui	a0,0x5555
  1e:	55450513          	addi	a0,a0,1364 # 5555554 <base+0x554f544>
  22:	74a000ef          	jal	76c <sbrk>
  if(p == (char*)0xffffffffffffffffL){
  26:	57fd                	li	a5,-1
  28:	04f50b63          	beq	a0,a5,7e <simpletest+0x7e>
  2c:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  for(char *q = p; q < p + sz; q += 4096){
  2e:	05556937          	lui	s2,0x5556
  32:	992a                	add	s2,s2,a0
  34:	6985                	lui	s3,0x1
    *(int*)q = getpid();
  36:	72e000ef          	jal	764 <getpid>
  3a:	c088                	sw	a0,0(s1)
  for(char *q = p; q < p + sz; q += 4096){
  3c:	94ce                	add	s1,s1,s3
  3e:	ff249ce3          	bne	s1,s2,36 <simpletest+0x36>
  }

  int pid = fork();
  42:	69a000ef          	jal	6dc <fork>
  if(pid < 0){
  46:	04054963          	bltz	a0,98 <simpletest+0x98>
    printf("fork() failed\n");
    exit(-1);
  }

  if(pid == 0)
  4a:	c125                	beqz	a0,aa <simpletest+0xaa>
    exit(0);

  wait(0);
  4c:	4501                	li	a0,0
  4e:	69e000ef          	jal	6ec <wait>

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
  52:	faaab537          	lui	a0,0xfaaab
  56:	aac50513          	addi	a0,a0,-1364 # fffffffffaaaaaac <base+0xfffffffffaaa4a9c>
  5a:	712000ef          	jal	76c <sbrk>
  5e:	57fd                	li	a5,-1
  60:	04f50763          	beq	a0,a5,ae <simpletest+0xae>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
  64:	00001517          	auipc	a0,0x1
  68:	c9c50513          	addi	a0,a0,-868 # d00 <malloc+0x150>
  6c:	291000ef          	jal	afc <printf>
}
  70:	70a2                	ld	ra,40(sp)
  72:	7402                	ld	s0,32(sp)
  74:	64e2                	ld	s1,24(sp)
  76:	6942                	ld	s2,16(sp)
  78:	69a2                	ld	s3,8(sp)
  7a:	6145                	addi	sp,sp,48
  7c:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
  7e:	055555b7          	lui	a1,0x5555
  82:	55458593          	addi	a1,a1,1364 # 5555554 <base+0x554f544>
  86:	00001517          	auipc	a0,0x1
  8a:	c3a50513          	addi	a0,a0,-966 # cc0 <malloc+0x110>
  8e:	26f000ef          	jal	afc <printf>
    exit(-1);
  92:	557d                	li	a0,-1
  94:	650000ef          	jal	6e4 <exit>
    printf("fork() failed\n");
  98:	00001517          	auipc	a0,0x1
  9c:	c4050513          	addi	a0,a0,-960 # cd8 <malloc+0x128>
  a0:	25d000ef          	jal	afc <printf>
    exit(-1);
  a4:	557d                	li	a0,-1
  a6:	63e000ef          	jal	6e4 <exit>
    exit(0);
  aa:	63a000ef          	jal	6e4 <exit>
    printf("sbrk(-%d) failed\n", sz);
  ae:	055555b7          	lui	a1,0x5555
  b2:	55458593          	addi	a1,a1,1364 # 5555554 <base+0x554f544>
  b6:	00001517          	auipc	a0,0x1
  ba:	c3250513          	addi	a0,a0,-974 # ce8 <malloc+0x138>
  be:	23f000ef          	jal	afc <printf>
    exit(-1);
  c2:	557d                	li	a0,-1
  c4:	620000ef          	jal	6e4 <exit>

00000000000000c8 <threetest>:
// this causes more than half of physical memory
// to be allocated, so it also checks whether
// copied pages are freed.
void
threetest()
{
  c8:	7179                	addi	sp,sp,-48
  ca:	f406                	sd	ra,40(sp)
  cc:	f022                	sd	s0,32(sp)
  ce:	ec26                	sd	s1,24(sp)
  d0:	e84a                	sd	s2,16(sp)
  d2:	e44e                	sd	s3,8(sp)
  d4:	e052                	sd	s4,0(sp)
  d6:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = phys_size / 4;
  int pid1, pid2;

  printf("three: ");
  d8:	00001517          	auipc	a0,0x1
  dc:	c3050513          	addi	a0,a0,-976 # d08 <malloc+0x158>
  e0:	21d000ef          	jal	afc <printf>
  
  char *p = sbrk(sz);
  e4:	02000537          	lui	a0,0x2000
  e8:	684000ef          	jal	76c <sbrk>
  if(p == (char*)0xffffffffffffffffL){
  ec:	57fd                	li	a5,-1
  ee:	06f50963          	beq	a0,a5,160 <threetest+0x98>
  f2:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  pid1 = fork();
  f4:	5e8000ef          	jal	6dc <fork>
  if(pid1 < 0){
  f8:	06054f63          	bltz	a0,176 <threetest+0xae>
    printf("fork failed\n");
    exit(-1);
  }
  if(pid1 == 0){
  fc:	c551                	beqz	a0,188 <threetest+0xc0>
      *(int*)q = 9999;
    }
    exit(0);
  }

  for(char *q = p; q < p + sz; q += 4096){
  fe:	020009b7          	lui	s3,0x2000
 102:	99a6                	add	s3,s3,s1
 104:	8926                	mv	s2,s1
 106:	6a05                	lui	s4,0x1
    *(int*)q = getpid();
 108:	65c000ef          	jal	764 <getpid>
 10c:	00a92023          	sw	a0,0(s2) # 5556000 <base+0x554fff0>
  for(char *q = p; q < p + sz; q += 4096){
 110:	9952                	add	s2,s2,s4
 112:	ff391be3          	bne	s2,s3,108 <threetest+0x40>
  }

  wait(0);
 116:	4501                	li	a0,0
 118:	5d4000ef          	jal	6ec <wait>

  sleep(1);
 11c:	4505                	li	a0,1
 11e:	656000ef          	jal	774 <sleep>

  for(char *q = p; q < p + sz; q += 4096){
 122:	6a05                	lui	s4,0x1
    if(*(int*)q != getpid()){
 124:	0004a903          	lw	s2,0(s1)
 128:	63c000ef          	jal	764 <getpid>
 12c:	0ca91c63          	bne	s2,a0,204 <threetest+0x13c>
  for(char *q = p; q < p + sz; q += 4096){
 130:	94d2                	add	s1,s1,s4
 132:	ff3499e3          	bne	s1,s3,124 <threetest+0x5c>
      printf("wrong content\n");
      exit(-1);
    }
  }

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
 136:	fe000537          	lui	a0,0xfe000
 13a:	632000ef          	jal	76c <sbrk>
 13e:	57fd                	li	a5,-1
 140:	0cf50b63          	beq	a0,a5,216 <threetest+0x14e>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
 144:	00001517          	auipc	a0,0x1
 148:	bbc50513          	addi	a0,a0,-1092 # d00 <malloc+0x150>
 14c:	1b1000ef          	jal	afc <printf>
}
 150:	70a2                	ld	ra,40(sp)
 152:	7402                	ld	s0,32(sp)
 154:	64e2                	ld	s1,24(sp)
 156:	6942                	ld	s2,16(sp)
 158:	69a2                	ld	s3,8(sp)
 15a:	6a02                	ld	s4,0(sp)
 15c:	6145                	addi	sp,sp,48
 15e:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
 160:	020005b7          	lui	a1,0x2000
 164:	00001517          	auipc	a0,0x1
 168:	b5c50513          	addi	a0,a0,-1188 # cc0 <malloc+0x110>
 16c:	191000ef          	jal	afc <printf>
    exit(-1);
 170:	557d                	li	a0,-1
 172:	572000ef          	jal	6e4 <exit>
    printf("fork failed\n");
 176:	00001517          	auipc	a0,0x1
 17a:	b9a50513          	addi	a0,a0,-1126 # d10 <malloc+0x160>
 17e:	17f000ef          	jal	afc <printf>
    exit(-1);
 182:	557d                	li	a0,-1
 184:	560000ef          	jal	6e4 <exit>
    pid2 = fork();
 188:	554000ef          	jal	6dc <fork>
    if(pid2 < 0){
 18c:	02054c63          	bltz	a0,1c4 <threetest+0xfc>
    if(pid2 == 0){
 190:	e139                	bnez	a0,1d6 <threetest+0x10e>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 192:	0199a9b7          	lui	s3,0x199a
 196:	99a6                	add	s3,s3,s1
 198:	8926                	mv	s2,s1
 19a:	6a05                	lui	s4,0x1
        *(int*)q = getpid();
 19c:	5c8000ef          	jal	764 <getpid>
 1a0:	00a92023          	sw	a0,0(s2)
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 1a4:	9952                	add	s2,s2,s4
 1a6:	ff391be3          	bne	s2,s3,19c <threetest+0xd4>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 1aa:	6a05                	lui	s4,0x1
        if(*(int*)q != getpid()){
 1ac:	0004a903          	lw	s2,0(s1)
 1b0:	5b4000ef          	jal	764 <getpid>
 1b4:	02a91f63          	bne	s2,a0,1f2 <threetest+0x12a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 1b8:	94d2                	add	s1,s1,s4
 1ba:	ff3499e3          	bne	s1,s3,1ac <threetest+0xe4>
      exit(-1);
 1be:	557d                	li	a0,-1
 1c0:	524000ef          	jal	6e4 <exit>
      printf("fork failed");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	b5c50513          	addi	a0,a0,-1188 # d20 <malloc+0x170>
 1cc:	131000ef          	jal	afc <printf>
      exit(-1);
 1d0:	557d                	li	a0,-1
 1d2:	512000ef          	jal	6e4 <exit>
    for(char *q = p; q < p + (sz/2); q += 4096){
 1d6:	01000737          	lui	a4,0x1000
 1da:	9726                	add	a4,a4,s1
      *(int*)q = 9999;
 1dc:	6789                	lui	a5,0x2
 1de:	70f78793          	addi	a5,a5,1807 # 270f <junk3+0x6ff>
    for(char *q = p; q < p + (sz/2); q += 4096){
 1e2:	6685                	lui	a3,0x1
      *(int*)q = 9999;
 1e4:	c09c                	sw	a5,0(s1)
    for(char *q = p; q < p + (sz/2); q += 4096){
 1e6:	94b6                	add	s1,s1,a3
 1e8:	fee49ee3          	bne	s1,a4,1e4 <threetest+0x11c>
    exit(0);
 1ec:	4501                	li	a0,0
 1ee:	4f6000ef          	jal	6e4 <exit>
          printf("wrong content\n");
 1f2:	00001517          	auipc	a0,0x1
 1f6:	b3e50513          	addi	a0,a0,-1218 # d30 <malloc+0x180>
 1fa:	103000ef          	jal	afc <printf>
          exit(-1);
 1fe:	557d                	li	a0,-1
 200:	4e4000ef          	jal	6e4 <exit>
      printf("wrong content\n");
 204:	00001517          	auipc	a0,0x1
 208:	b2c50513          	addi	a0,a0,-1236 # d30 <malloc+0x180>
 20c:	0f1000ef          	jal	afc <printf>
      exit(-1);
 210:	557d                	li	a0,-1
 212:	4d2000ef          	jal	6e4 <exit>
    printf("sbrk(-%d) failed\n", sz);
 216:	020005b7          	lui	a1,0x2000
 21a:	00001517          	auipc	a0,0x1
 21e:	ace50513          	addi	a0,a0,-1330 # ce8 <malloc+0x138>
 222:	0db000ef          	jal	afc <printf>
    exit(-1);
 226:	557d                	li	a0,-1
 228:	4bc000ef          	jal	6e4 <exit>

000000000000022c <filetest>:
char junk3[4096];

// test whether copyout() simulates COW faults.
void
filetest()
{
 22c:	7179                	addi	sp,sp,-48
 22e:	f406                	sd	ra,40(sp)
 230:	f022                	sd	s0,32(sp)
 232:	ec26                	sd	s1,24(sp)
 234:	e84a                	sd	s2,16(sp)
 236:	1800                	addi	s0,sp,48
  printf("file: ");
 238:	00001517          	auipc	a0,0x1
 23c:	b0850513          	addi	a0,a0,-1272 # d40 <malloc+0x190>
 240:	0bd000ef          	jal	afc <printf>
  
  buf[0] = 99;
 244:	06300793          	li	a5,99
 248:	00003717          	auipc	a4,0x3
 24c:	dcf70423          	sb	a5,-568(a4) # 3010 <buf>

  for(int i = 0; i < 4; i++){
 250:	fc042c23          	sw	zero,-40(s0)
    if(pipe(fds) != 0){
 254:	00002497          	auipc	s1,0x2
 258:	dac48493          	addi	s1,s1,-596 # 2000 <fds>
  for(int i = 0; i < 4; i++){
 25c:	490d                	li	s2,3
    if(pipe(fds) != 0){
 25e:	8526                	mv	a0,s1
 260:	494000ef          	jal	6f4 <pipe>
 264:	e92d                	bnez	a0,2d6 <filetest+0xaa>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 266:	476000ef          	jal	6dc <fork>
    if(pid < 0){
 26a:	06054f63          	bltz	a0,2e8 <filetest+0xbc>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
 26e:	c551                	beqz	a0,2fa <filetest+0xce>
        printf("error: read the wrong value\n");
        exit(1);
      }
      exit(0);
    }
    if(write(fds[1], &i, sizeof(i)) != sizeof(i)){
 270:	4611                	li	a2,4
 272:	fd840593          	addi	a1,s0,-40
 276:	40c8                	lw	a0,4(s1)
 278:	48c000ef          	jal	704 <write>
 27c:	4791                	li	a5,4
 27e:	0cf51f63          	bne	a0,a5,35c <filetest+0x130>
  for(int i = 0; i < 4; i++){
 282:	fd842783          	lw	a5,-40(s0)
 286:	2785                	addiw	a5,a5,1
 288:	0007871b          	sext.w	a4,a5
 28c:	fcf42c23          	sw	a5,-40(s0)
 290:	fce957e3          	bge	s2,a4,25e <filetest+0x32>
      printf("error: write failed\n");
      exit(-1);
    }
  }

  int xstatus = 0;
 294:	fc042e23          	sw	zero,-36(s0)
 298:	4491                	li	s1,4
  for(int i = 0; i < 4; i++) {
    wait(&xstatus);
 29a:	fdc40513          	addi	a0,s0,-36
 29e:	44e000ef          	jal	6ec <wait>
    if(xstatus != 0) {
 2a2:	fdc42783          	lw	a5,-36(s0)
 2a6:	0c079463          	bnez	a5,36e <filetest+0x142>
  for(int i = 0; i < 4; i++) {
 2aa:	34fd                	addiw	s1,s1,-1
 2ac:	f4fd                	bnez	s1,29a <filetest+0x6e>
      exit(1);
    }
  }

  if(buf[0] != 99){
 2ae:	00003717          	auipc	a4,0x3
 2b2:	d6274703          	lbu	a4,-670(a4) # 3010 <buf>
 2b6:	06300793          	li	a5,99
 2ba:	0af71d63          	bne	a4,a5,374 <filetest+0x148>
    printf("error: child overwrote parent\n");
    exit(1);
  }

  printf("ok\n");
 2be:	00001517          	auipc	a0,0x1
 2c2:	a4250513          	addi	a0,a0,-1470 # d00 <malloc+0x150>
 2c6:	037000ef          	jal	afc <printf>
}
 2ca:	70a2                	ld	ra,40(sp)
 2cc:	7402                	ld	s0,32(sp)
 2ce:	64e2                	ld	s1,24(sp)
 2d0:	6942                	ld	s2,16(sp)
 2d2:	6145                	addi	sp,sp,48
 2d4:	8082                	ret
      printf("pipe() failed\n");
 2d6:	00001517          	auipc	a0,0x1
 2da:	a7250513          	addi	a0,a0,-1422 # d48 <malloc+0x198>
 2de:	01f000ef          	jal	afc <printf>
      exit(-1);
 2e2:	557d                	li	a0,-1
 2e4:	400000ef          	jal	6e4 <exit>
      printf("fork failed\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	a2850513          	addi	a0,a0,-1496 # d10 <malloc+0x160>
 2f0:	00d000ef          	jal	afc <printf>
      exit(-1);
 2f4:	557d                	li	a0,-1
 2f6:	3ee000ef          	jal	6e4 <exit>
      sleep(1);
 2fa:	4505                	li	a0,1
 2fc:	478000ef          	jal	774 <sleep>
      if(read(fds[0], buf, sizeof(i)) != sizeof(i)){
 300:	4611                	li	a2,4
 302:	00003597          	auipc	a1,0x3
 306:	d0e58593          	addi	a1,a1,-754 # 3010 <buf>
 30a:	00002517          	auipc	a0,0x2
 30e:	cf652503          	lw	a0,-778(a0) # 2000 <fds>
 312:	3ea000ef          	jal	6fc <read>
 316:	4791                	li	a5,4
 318:	02f51663          	bne	a0,a5,344 <filetest+0x118>
      sleep(1);
 31c:	4505                	li	a0,1
 31e:	456000ef          	jal	774 <sleep>
      if(j != i){
 322:	fd842703          	lw	a4,-40(s0)
 326:	00003797          	auipc	a5,0x3
 32a:	cea7a783          	lw	a5,-790(a5) # 3010 <buf>
 32e:	02f70463          	beq	a4,a5,356 <filetest+0x12a>
        printf("error: read the wrong value\n");
 332:	00001517          	auipc	a0,0x1
 336:	a3e50513          	addi	a0,a0,-1474 # d70 <malloc+0x1c0>
 33a:	7c2000ef          	jal	afc <printf>
        exit(1);
 33e:	4505                	li	a0,1
 340:	3a4000ef          	jal	6e4 <exit>
        printf("error: read failed\n");
 344:	00001517          	auipc	a0,0x1
 348:	a1450513          	addi	a0,a0,-1516 # d58 <malloc+0x1a8>
 34c:	7b0000ef          	jal	afc <printf>
        exit(1);
 350:	4505                	li	a0,1
 352:	392000ef          	jal	6e4 <exit>
      exit(0);
 356:	4501                	li	a0,0
 358:	38c000ef          	jal	6e4 <exit>
      printf("error: write failed\n");
 35c:	00001517          	auipc	a0,0x1
 360:	a3450513          	addi	a0,a0,-1484 # d90 <malloc+0x1e0>
 364:	798000ef          	jal	afc <printf>
      exit(-1);
 368:	557d                	li	a0,-1
 36a:	37a000ef          	jal	6e4 <exit>
      exit(1);
 36e:	4505                	li	a0,1
 370:	374000ef          	jal	6e4 <exit>
    printf("error: child overwrote parent\n");
 374:	00001517          	auipc	a0,0x1
 378:	a3450513          	addi	a0,a0,-1484 # da8 <malloc+0x1f8>
 37c:	780000ef          	jal	afc <printf>
    exit(1);
 380:	4505                	li	a0,1
 382:	362000ef          	jal	6e4 <exit>

0000000000000386 <forkforktest>:
//
// try to expose races in page reference counting.
//
void
forkforktest()
{
 386:	7179                	addi	sp,sp,-48
 388:	f406                	sd	ra,40(sp)
 38a:	f022                	sd	s0,32(sp)
 38c:	ec26                	sd	s1,24(sp)
 38e:	e84a                	sd	s2,16(sp)
 390:	1800                	addi	s0,sp,48
  printf("forkfork: ");
 392:	00001517          	auipc	a0,0x1
 396:	a3650513          	addi	a0,a0,-1482 # dc8 <malloc+0x218>
 39a:	762000ef          	jal	afc <printf>

  int sz = 256 * 4096;
  char *p = sbrk(sz);
 39e:	00100537          	lui	a0,0x100
 3a2:	3ca000ef          	jal	76c <sbrk>
 3a6:	892a                	mv	s2,a0
  memset(p, 27, sz);
 3a8:	00100637          	lui	a2,0x100
 3ac:	45ed                	li	a1,27
 3ae:	150000ef          	jal	4fe <memset>
 3b2:	06400493          	li	s1,100

  int children = 3;

  for(int iter = 0; iter < 100; iter++){
    for(int nc = 0; nc < children; nc++){
      if(fork() == 0){
 3b6:	326000ef          	jal	6dc <fork>
 3ba:	c135                	beqz	a0,41e <forkforktest+0x98>
 3bc:	320000ef          	jal	6dc <fork>
 3c0:	cd39                	beqz	a0,41e <forkforktest+0x98>
 3c2:	31a000ef          	jal	6dc <fork>
 3c6:	cd21                	beqz	a0,41e <forkforktest+0x98>
      }
    }

    for(int nc = 0; nc < children; nc++){
      int st;
      wait(&st);
 3c8:	fdc40513          	addi	a0,s0,-36
 3cc:	320000ef          	jal	6ec <wait>
 3d0:	fdc40513          	addi	a0,s0,-36
 3d4:	318000ef          	jal	6ec <wait>
 3d8:	fdc40513          	addi	a0,s0,-36
 3dc:	310000ef          	jal	6ec <wait>
  for(int iter = 0; iter < 100; iter++){
 3e0:	34fd                	addiw	s1,s1,-1
 3e2:	f8f1                	bnez	s1,3b6 <forkforktest+0x30>
    }
  }

  sleep(5);
 3e4:	4515                	li	a0,5
 3e6:	38e000ef          	jal	774 <sleep>
  for(int i = 0; i < sz; i += 4096){
 3ea:	87ca                	mv	a5,s2
 3ec:	00100737          	lui	a4,0x100
 3f0:	00e906b3          	add	a3,s2,a4
    if(p[i] != 27){
 3f4:	45ed                	li	a1,27
  for(int i = 0; i < sz; i += 4096){
 3f6:	6605                	lui	a2,0x1
    if(p[i] != 27){
 3f8:	0007c703          	lbu	a4,0(a5)
 3fc:	02b71b63          	bne	a4,a1,432 <forkforktest+0xac>
  for(int i = 0; i < sz; i += 4096){
 400:	97b2                	add	a5,a5,a2
 402:	fed79be3          	bne	a5,a3,3f8 <forkforktest+0x72>
      printf("error: parent's memory was modified!\n");
      exit(1);
    }
  }

  printf("ok\n");
 406:	00001517          	auipc	a0,0x1
 40a:	8fa50513          	addi	a0,a0,-1798 # d00 <malloc+0x150>
 40e:	6ee000ef          	jal	afc <printf>
}
 412:	70a2                	ld	ra,40(sp)
 414:	7402                	ld	s0,32(sp)
 416:	64e2                	ld	s1,24(sp)
 418:	6942                	ld	s2,16(sp)
 41a:	6145                	addi	sp,sp,48
 41c:	8082                	ret
        sleep(2);
 41e:	4509                	li	a0,2
 420:	354000ef          	jal	774 <sleep>
        fork();
 424:	2b8000ef          	jal	6dc <fork>
        fork();
 428:	2b4000ef          	jal	6dc <fork>
        exit(0);
 42c:	4501                	li	a0,0
 42e:	2b6000ef          	jal	6e4 <exit>
      printf("error: parent's memory was modified!\n");
 432:	00001517          	auipc	a0,0x1
 436:	9a650513          	addi	a0,a0,-1626 # dd8 <malloc+0x228>
 43a:	6c2000ef          	jal	afc <printf>
      exit(1);
 43e:	4505                	li	a0,1
 440:	2a4000ef          	jal	6e4 <exit>

0000000000000444 <main>:

int
main(int argc, char *argv[])
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  simpletest();
 44c:	bb5ff0ef          	jal	0 <simpletest>

  // check that the first simpletest() freed the physical memory.
  simpletest();
 450:	bb1ff0ef          	jal	0 <simpletest>

  threetest();
 454:	c75ff0ef          	jal	c8 <threetest>
  threetest();
 458:	c71ff0ef          	jal	c8 <threetest>
  threetest();
 45c:	c6dff0ef          	jal	c8 <threetest>

  filetest();
 460:	dcdff0ef          	jal	22c <filetest>

  forkforktest();
 464:	f23ff0ef          	jal	386 <forkforktest>

  printf("ALL COW TESTS PASSED\n");
 468:	00001517          	auipc	a0,0x1
 46c:	99850513          	addi	a0,a0,-1640 # e00 <malloc+0x250>
 470:	68c000ef          	jal	afc <printf>

  exit(0);
 474:	4501                	li	a0,0
 476:	26e000ef          	jal	6e4 <exit>

000000000000047a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 47a:	1141                	addi	sp,sp,-16
 47c:	e406                	sd	ra,8(sp)
 47e:	e022                	sd	s0,0(sp)
 480:	0800                	addi	s0,sp,16
  extern int main();
  main();
 482:	fc3ff0ef          	jal	444 <main>
  exit(0);
 486:	4501                	li	a0,0
 488:	25c000ef          	jal	6e4 <exit>

000000000000048c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 48c:	1141                	addi	sp,sp,-16
 48e:	e422                	sd	s0,8(sp)
 490:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 492:	87aa                	mv	a5,a0
 494:	0585                	addi	a1,a1,1
 496:	0785                	addi	a5,a5,1
 498:	fff5c703          	lbu	a4,-1(a1)
 49c:	fee78fa3          	sb	a4,-1(a5)
 4a0:	fb75                	bnez	a4,494 <strcpy+0x8>
    ;
  return os;
}
 4a2:	6422                	ld	s0,8(sp)
 4a4:	0141                	addi	sp,sp,16
 4a6:	8082                	ret

00000000000004a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e422                	sd	s0,8(sp)
 4ac:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4ae:	00054783          	lbu	a5,0(a0)
 4b2:	cb91                	beqz	a5,4c6 <strcmp+0x1e>
 4b4:	0005c703          	lbu	a4,0(a1)
 4b8:	00f71763          	bne	a4,a5,4c6 <strcmp+0x1e>
    p++, q++;
 4bc:	0505                	addi	a0,a0,1
 4be:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4c0:	00054783          	lbu	a5,0(a0)
 4c4:	fbe5                	bnez	a5,4b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4c6:	0005c503          	lbu	a0,0(a1)
}
 4ca:	40a7853b          	subw	a0,a5,a0
 4ce:	6422                	ld	s0,8(sp)
 4d0:	0141                	addi	sp,sp,16
 4d2:	8082                	ret

00000000000004d4 <strlen>:

uint
strlen(const char *s)
{
 4d4:	1141                	addi	sp,sp,-16
 4d6:	e422                	sd	s0,8(sp)
 4d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4da:	00054783          	lbu	a5,0(a0)
 4de:	cf91                	beqz	a5,4fa <strlen+0x26>
 4e0:	0505                	addi	a0,a0,1
 4e2:	87aa                	mv	a5,a0
 4e4:	86be                	mv	a3,a5
 4e6:	0785                	addi	a5,a5,1
 4e8:	fff7c703          	lbu	a4,-1(a5)
 4ec:	ff65                	bnez	a4,4e4 <strlen+0x10>
 4ee:	40a6853b          	subw	a0,a3,a0
 4f2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 4f4:	6422                	ld	s0,8(sp)
 4f6:	0141                	addi	sp,sp,16
 4f8:	8082                	ret
  for(n = 0; s[n]; n++)
 4fa:	4501                	li	a0,0
 4fc:	bfe5                	j	4f4 <strlen+0x20>

00000000000004fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 4fe:	1141                	addi	sp,sp,-16
 500:	e422                	sd	s0,8(sp)
 502:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 504:	ca19                	beqz	a2,51a <memset+0x1c>
 506:	87aa                	mv	a5,a0
 508:	1602                	slli	a2,a2,0x20
 50a:	9201                	srli	a2,a2,0x20
 50c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 510:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 514:	0785                	addi	a5,a5,1
 516:	fee79de3          	bne	a5,a4,510 <memset+0x12>
  }
  return dst;
}
 51a:	6422                	ld	s0,8(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret

0000000000000520 <strchr>:

char*
strchr(const char *s, char c)
{
 520:	1141                	addi	sp,sp,-16
 522:	e422                	sd	s0,8(sp)
 524:	0800                	addi	s0,sp,16
  for(; *s; s++)
 526:	00054783          	lbu	a5,0(a0)
 52a:	cb99                	beqz	a5,540 <strchr+0x20>
    if(*s == c)
 52c:	00f58763          	beq	a1,a5,53a <strchr+0x1a>
  for(; *s; s++)
 530:	0505                	addi	a0,a0,1
 532:	00054783          	lbu	a5,0(a0)
 536:	fbfd                	bnez	a5,52c <strchr+0xc>
      return (char*)s;
  return 0;
 538:	4501                	li	a0,0
}
 53a:	6422                	ld	s0,8(sp)
 53c:	0141                	addi	sp,sp,16
 53e:	8082                	ret
  return 0;
 540:	4501                	li	a0,0
 542:	bfe5                	j	53a <strchr+0x1a>

0000000000000544 <gets>:

char*
gets(char *buf, int max)
{
 544:	711d                	addi	sp,sp,-96
 546:	ec86                	sd	ra,88(sp)
 548:	e8a2                	sd	s0,80(sp)
 54a:	e4a6                	sd	s1,72(sp)
 54c:	e0ca                	sd	s2,64(sp)
 54e:	fc4e                	sd	s3,56(sp)
 550:	f852                	sd	s4,48(sp)
 552:	f456                	sd	s5,40(sp)
 554:	f05a                	sd	s6,32(sp)
 556:	ec5e                	sd	s7,24(sp)
 558:	1080                	addi	s0,sp,96
 55a:	8baa                	mv	s7,a0
 55c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 55e:	892a                	mv	s2,a0
 560:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 562:	4aa9                	li	s5,10
 564:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 566:	89a6                	mv	s3,s1
 568:	2485                	addiw	s1,s1,1
 56a:	0344d663          	bge	s1,s4,596 <gets+0x52>
    cc = read(0, &c, 1);
 56e:	4605                	li	a2,1
 570:	faf40593          	addi	a1,s0,-81
 574:	4501                	li	a0,0
 576:	186000ef          	jal	6fc <read>
    if(cc < 1)
 57a:	00a05e63          	blez	a0,596 <gets+0x52>
    buf[i++] = c;
 57e:	faf44783          	lbu	a5,-81(s0)
 582:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 586:	01578763          	beq	a5,s5,594 <gets+0x50>
 58a:	0905                	addi	s2,s2,1
 58c:	fd679de3          	bne	a5,s6,566 <gets+0x22>
    buf[i++] = c;
 590:	89a6                	mv	s3,s1
 592:	a011                	j	596 <gets+0x52>
 594:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 596:	99de                	add	s3,s3,s7
 598:	00098023          	sb	zero,0(s3) # 199a000 <base+0x1993ff0>
  return buf;
}
 59c:	855e                	mv	a0,s7
 59e:	60e6                	ld	ra,88(sp)
 5a0:	6446                	ld	s0,80(sp)
 5a2:	64a6                	ld	s1,72(sp)
 5a4:	6906                	ld	s2,64(sp)
 5a6:	79e2                	ld	s3,56(sp)
 5a8:	7a42                	ld	s4,48(sp)
 5aa:	7aa2                	ld	s5,40(sp)
 5ac:	7b02                	ld	s6,32(sp)
 5ae:	6be2                	ld	s7,24(sp)
 5b0:	6125                	addi	sp,sp,96
 5b2:	8082                	ret

00000000000005b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 5b4:	1101                	addi	sp,sp,-32
 5b6:	ec06                	sd	ra,24(sp)
 5b8:	e822                	sd	s0,16(sp)
 5ba:	e04a                	sd	s2,0(sp)
 5bc:	1000                	addi	s0,sp,32
 5be:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5c0:	4581                	li	a1,0
 5c2:	162000ef          	jal	724 <open>
  if(fd < 0)
 5c6:	02054263          	bltz	a0,5ea <stat+0x36>
 5ca:	e426                	sd	s1,8(sp)
 5cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5ce:	85ca                	mv	a1,s2
 5d0:	16c000ef          	jal	73c <fstat>
 5d4:	892a                	mv	s2,a0
  close(fd);
 5d6:	8526                	mv	a0,s1
 5d8:	134000ef          	jal	70c <close>
  return r;
 5dc:	64a2                	ld	s1,8(sp)
}
 5de:	854a                	mv	a0,s2
 5e0:	60e2                	ld	ra,24(sp)
 5e2:	6442                	ld	s0,16(sp)
 5e4:	6902                	ld	s2,0(sp)
 5e6:	6105                	addi	sp,sp,32
 5e8:	8082                	ret
    return -1;
 5ea:	597d                	li	s2,-1
 5ec:	bfcd                	j	5de <stat+0x2a>

00000000000005ee <atoi>:

int
atoi(const char *s)
{
 5ee:	1141                	addi	sp,sp,-16
 5f0:	e422                	sd	s0,8(sp)
 5f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5f4:	00054683          	lbu	a3,0(a0)
 5f8:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x1b0>
 5fc:	0ff7f793          	zext.b	a5,a5
 600:	4625                	li	a2,9
 602:	02f66863          	bltu	a2,a5,632 <atoi+0x44>
 606:	872a                	mv	a4,a0
  n = 0;
 608:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 60a:	0705                	addi	a4,a4,1 # 100001 <base+0xf9ff1>
 60c:	0025179b          	slliw	a5,a0,0x2
 610:	9fa9                	addw	a5,a5,a0
 612:	0017979b          	slliw	a5,a5,0x1
 616:	9fb5                	addw	a5,a5,a3
 618:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 61c:	00074683          	lbu	a3,0(a4)
 620:	fd06879b          	addiw	a5,a3,-48
 624:	0ff7f793          	zext.b	a5,a5
 628:	fef671e3          	bgeu	a2,a5,60a <atoi+0x1c>
  return n;
}
 62c:	6422                	ld	s0,8(sp)
 62e:	0141                	addi	sp,sp,16
 630:	8082                	ret
  n = 0;
 632:	4501                	li	a0,0
 634:	bfe5                	j	62c <atoi+0x3e>

0000000000000636 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 636:	1141                	addi	sp,sp,-16
 638:	e422                	sd	s0,8(sp)
 63a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 63c:	02b57463          	bgeu	a0,a1,664 <memmove+0x2e>
    while(n-- > 0)
 640:	00c05f63          	blez	a2,65e <memmove+0x28>
 644:	1602                	slli	a2,a2,0x20
 646:	9201                	srli	a2,a2,0x20
 648:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 64c:	872a                	mv	a4,a0
      *dst++ = *src++;
 64e:	0585                	addi	a1,a1,1
 650:	0705                	addi	a4,a4,1
 652:	fff5c683          	lbu	a3,-1(a1)
 656:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 65a:	fef71ae3          	bne	a4,a5,64e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 65e:	6422                	ld	s0,8(sp)
 660:	0141                	addi	sp,sp,16
 662:	8082                	ret
    dst += n;
 664:	00c50733          	add	a4,a0,a2
    src += n;
 668:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 66a:	fec05ae3          	blez	a2,65e <memmove+0x28>
 66e:	fff6079b          	addiw	a5,a2,-1 # fff <digits+0x1df>
 672:	1782                	slli	a5,a5,0x20
 674:	9381                	srli	a5,a5,0x20
 676:	fff7c793          	not	a5,a5
 67a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 67c:	15fd                	addi	a1,a1,-1
 67e:	177d                	addi	a4,a4,-1
 680:	0005c683          	lbu	a3,0(a1)
 684:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 688:	fee79ae3          	bne	a5,a4,67c <memmove+0x46>
 68c:	bfc9                	j	65e <memmove+0x28>

000000000000068e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 68e:	1141                	addi	sp,sp,-16
 690:	e422                	sd	s0,8(sp)
 692:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 694:	ca05                	beqz	a2,6c4 <memcmp+0x36>
 696:	fff6069b          	addiw	a3,a2,-1
 69a:	1682                	slli	a3,a3,0x20
 69c:	9281                	srli	a3,a3,0x20
 69e:	0685                	addi	a3,a3,1
 6a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6a2:	00054783          	lbu	a5,0(a0)
 6a6:	0005c703          	lbu	a4,0(a1)
 6aa:	00e79863          	bne	a5,a4,6ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6ae:	0505                	addi	a0,a0,1
    p2++;
 6b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6b2:	fed518e3          	bne	a0,a3,6a2 <memcmp+0x14>
  }
  return 0;
 6b6:	4501                	li	a0,0
 6b8:	a019                	j	6be <memcmp+0x30>
      return *p1 - *p2;
 6ba:	40e7853b          	subw	a0,a5,a4
}
 6be:	6422                	ld	s0,8(sp)
 6c0:	0141                	addi	sp,sp,16
 6c2:	8082                	ret
  return 0;
 6c4:	4501                	li	a0,0
 6c6:	bfe5                	j	6be <memcmp+0x30>

00000000000006c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6c8:	1141                	addi	sp,sp,-16
 6ca:	e406                	sd	ra,8(sp)
 6cc:	e022                	sd	s0,0(sp)
 6ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6d0:	f67ff0ef          	jal	636 <memmove>
}
 6d4:	60a2                	ld	ra,8(sp)
 6d6:	6402                	ld	s0,0(sp)
 6d8:	0141                	addi	sp,sp,16
 6da:	8082                	ret

00000000000006dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6dc:	4885                	li	a7,1
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6e4:	4889                	li	a7,2
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 6ec:	488d                	li	a7,3
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6f4:	4891                	li	a7,4
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <read>:
.global read
read:
 li a7, SYS_read
 6fc:	4895                	li	a7,5
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <write>:
.global write
write:
 li a7, SYS_write
 704:	48c1                	li	a7,16
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <close>:
.global close
close:
 li a7, SYS_close
 70c:	48d5                	li	a7,21
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <kill>:
.global kill
kill:
 li a7, SYS_kill
 714:	4899                	li	a7,6
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <exec>:
.global exec
exec:
 li a7, SYS_exec
 71c:	489d                	li	a7,7
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <open>:
.global open
open:
 li a7, SYS_open
 724:	48bd                	li	a7,15
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 72c:	48c5                	li	a7,17
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 734:	48c9                	li	a7,18
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 73c:	48a1                	li	a7,8
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <link>:
.global link
link:
 li a7, SYS_link
 744:	48cd                	li	a7,19
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 74c:	48d1                	li	a7,20
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 754:	48a5                	li	a7,9
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <dup>:
.global dup
dup:
 li a7, SYS_dup
 75c:	48a9                	li	a7,10
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 764:	48ad                	li	a7,11
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 76c:	48b1                	li	a7,12
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 774:	48b5                	li	a7,13
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 77c:	48b9                	li	a7,14
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 784:	1101                	addi	sp,sp,-32
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 790:	4605                	li	a2,1
 792:	fef40593          	addi	a1,s0,-17
 796:	f6fff0ef          	jal	704 <write>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6105                	addi	sp,sp,32
 7a0:	8082                	ret

00000000000007a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7a2:	7139                	addi	sp,sp,-64
 7a4:	fc06                	sd	ra,56(sp)
 7a6:	f822                	sd	s0,48(sp)
 7a8:	f426                	sd	s1,40(sp)
 7aa:	0080                	addi	s0,sp,64
 7ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7ae:	c299                	beqz	a3,7b4 <printint+0x12>
 7b0:	0805c963          	bltz	a1,842 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7b4:	2581                	sext.w	a1,a1
  neg = 0;
 7b6:	4881                	li	a7,0
 7b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7be:	2601                	sext.w	a2,a2
 7c0:	00000517          	auipc	a0,0x0
 7c4:	66050513          	addi	a0,a0,1632 # e20 <digits>
 7c8:	883a                	mv	a6,a4
 7ca:	2705                	addiw	a4,a4,1
 7cc:	02c5f7bb          	remuw	a5,a1,a2
 7d0:	1782                	slli	a5,a5,0x20
 7d2:	9381                	srli	a5,a5,0x20
 7d4:	97aa                	add	a5,a5,a0
 7d6:	0007c783          	lbu	a5,0(a5)
 7da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7de:	0005879b          	sext.w	a5,a1
 7e2:	02c5d5bb          	divuw	a1,a1,a2
 7e6:	0685                	addi	a3,a3,1
 7e8:	fec7f0e3          	bgeu	a5,a2,7c8 <printint+0x26>
  if(neg)
 7ec:	00088c63          	beqz	a7,804 <printint+0x62>
    buf[i++] = '-';
 7f0:	fd070793          	addi	a5,a4,-48
 7f4:	00878733          	add	a4,a5,s0
 7f8:	02d00793          	li	a5,45
 7fc:	fef70823          	sb	a5,-16(a4)
 800:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 804:	02e05a63          	blez	a4,838 <printint+0x96>
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	fc040793          	addi	a5,s0,-64
 810:	00e78933          	add	s2,a5,a4
 814:	fff78993          	addi	s3,a5,-1
 818:	99ba                	add	s3,s3,a4
 81a:	377d                	addiw	a4,a4,-1
 81c:	1702                	slli	a4,a4,0x20
 81e:	9301                	srli	a4,a4,0x20
 820:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 824:	fff94583          	lbu	a1,-1(s2)
 828:	8526                	mv	a0,s1
 82a:	f5bff0ef          	jal	784 <putc>
  while(--i >= 0)
 82e:	197d                	addi	s2,s2,-1
 830:	ff391ae3          	bne	s2,s3,824 <printint+0x82>
 834:	7902                	ld	s2,32(sp)
 836:	69e2                	ld	s3,24(sp)
}
 838:	70e2                	ld	ra,56(sp)
 83a:	7442                	ld	s0,48(sp)
 83c:	74a2                	ld	s1,40(sp)
 83e:	6121                	addi	sp,sp,64
 840:	8082                	ret
    x = -xx;
 842:	40b005bb          	negw	a1,a1
    neg = 1;
 846:	4885                	li	a7,1
    x = -xx;
 848:	bf85                	j	7b8 <printint+0x16>

000000000000084a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 84a:	711d                	addi	sp,sp,-96
 84c:	ec86                	sd	ra,88(sp)
 84e:	e8a2                	sd	s0,80(sp)
 850:	e0ca                	sd	s2,64(sp)
 852:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 854:	0005c903          	lbu	s2,0(a1)
 858:	26090863          	beqz	s2,ac8 <vprintf+0x27e>
 85c:	e4a6                	sd	s1,72(sp)
 85e:	fc4e                	sd	s3,56(sp)
 860:	f852                	sd	s4,48(sp)
 862:	f456                	sd	s5,40(sp)
 864:	f05a                	sd	s6,32(sp)
 866:	ec5e                	sd	s7,24(sp)
 868:	e862                	sd	s8,16(sp)
 86a:	e466                	sd	s9,8(sp)
 86c:	8b2a                	mv	s6,a0
 86e:	8a2e                	mv	s4,a1
 870:	8bb2                	mv	s7,a2
  state = 0;
 872:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 874:	4481                	li	s1,0
 876:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 878:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 87c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 880:	06c00c93          	li	s9,108
 884:	a005                	j	8a4 <vprintf+0x5a>
        putc(fd, c0);
 886:	85ca                	mv	a1,s2
 888:	855a                	mv	a0,s6
 88a:	efbff0ef          	jal	784 <putc>
 88e:	a019                	j	894 <vprintf+0x4a>
    } else if(state == '%'){
 890:	03598263          	beq	s3,s5,8b4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 894:	2485                	addiw	s1,s1,1
 896:	8726                	mv	a4,s1
 898:	009a07b3          	add	a5,s4,s1
 89c:	0007c903          	lbu	s2,0(a5)
 8a0:	20090c63          	beqz	s2,ab8 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 8a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8a8:	fe0994e3          	bnez	s3,890 <vprintf+0x46>
      if(c0 == '%'){
 8ac:	fd579de3          	bne	a5,s5,886 <vprintf+0x3c>
        state = '%';
 8b0:	89be                	mv	s3,a5
 8b2:	b7cd                	j	894 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 8b4:	00ea06b3          	add	a3,s4,a4
 8b8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 8bc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 8be:	c681                	beqz	a3,8c6 <vprintf+0x7c>
 8c0:	9752                	add	a4,a4,s4
 8c2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 8c6:	03878f63          	beq	a5,s8,904 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 8ca:	05978963          	beq	a5,s9,91c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 8ce:	07500713          	li	a4,117
 8d2:	0ee78363          	beq	a5,a4,9b8 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 8d6:	07800713          	li	a4,120
 8da:	12e78563          	beq	a5,a4,a04 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 8de:	07000713          	li	a4,112
 8e2:	14e78a63          	beq	a5,a4,a36 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 8e6:	07300713          	li	a4,115
 8ea:	18e78a63          	beq	a5,a4,a7e <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 8ee:	02500713          	li	a4,37
 8f2:	04e79563          	bne	a5,a4,93c <vprintf+0xf2>
        putc(fd, '%');
 8f6:	02500593          	li	a1,37
 8fa:	855a                	mv	a0,s6
 8fc:	e89ff0ef          	jal	784 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 900:	4981                	li	s3,0
 902:	bf49                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 904:	008b8913          	addi	s2,s7,8
 908:	4685                	li	a3,1
 90a:	4629                	li	a2,10
 90c:	000ba583          	lw	a1,0(s7)
 910:	855a                	mv	a0,s6
 912:	e91ff0ef          	jal	7a2 <printint>
 916:	8bca                	mv	s7,s2
      state = 0;
 918:	4981                	li	s3,0
 91a:	bfad                	j	894 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 91c:	06400793          	li	a5,100
 920:	02f68963          	beq	a3,a5,952 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 924:	06c00793          	li	a5,108
 928:	04f68263          	beq	a3,a5,96c <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 92c:	07500793          	li	a5,117
 930:	0af68063          	beq	a3,a5,9d0 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 934:	07800793          	li	a5,120
 938:	0ef68263          	beq	a3,a5,a1c <vprintf+0x1d2>
        putc(fd, '%');
 93c:	02500593          	li	a1,37
 940:	855a                	mv	a0,s6
 942:	e43ff0ef          	jal	784 <putc>
        putc(fd, c0);
 946:	85ca                	mv	a1,s2
 948:	855a                	mv	a0,s6
 94a:	e3bff0ef          	jal	784 <putc>
      state = 0;
 94e:	4981                	li	s3,0
 950:	b791                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 952:	008b8913          	addi	s2,s7,8
 956:	4685                	li	a3,1
 958:	4629                	li	a2,10
 95a:	000ba583          	lw	a1,0(s7)
 95e:	855a                	mv	a0,s6
 960:	e43ff0ef          	jal	7a2 <printint>
        i += 1;
 964:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 966:	8bca                	mv	s7,s2
      state = 0;
 968:	4981                	li	s3,0
        i += 1;
 96a:	b72d                	j	894 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 96c:	06400793          	li	a5,100
 970:	02f60763          	beq	a2,a5,99e <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 974:	07500793          	li	a5,117
 978:	06f60963          	beq	a2,a5,9ea <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 97c:	07800793          	li	a5,120
 980:	faf61ee3          	bne	a2,a5,93c <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 984:	008b8913          	addi	s2,s7,8
 988:	4681                	li	a3,0
 98a:	4641                	li	a2,16
 98c:	000ba583          	lw	a1,0(s7)
 990:	855a                	mv	a0,s6
 992:	e11ff0ef          	jal	7a2 <printint>
        i += 2;
 996:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 998:	8bca                	mv	s7,s2
      state = 0;
 99a:	4981                	li	s3,0
        i += 2;
 99c:	bde5                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 99e:	008b8913          	addi	s2,s7,8
 9a2:	4685                	li	a3,1
 9a4:	4629                	li	a2,10
 9a6:	000ba583          	lw	a1,0(s7)
 9aa:	855a                	mv	a0,s6
 9ac:	df7ff0ef          	jal	7a2 <printint>
        i += 2;
 9b0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 9b2:	8bca                	mv	s7,s2
      state = 0;
 9b4:	4981                	li	s3,0
        i += 2;
 9b6:	bdf9                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 9b8:	008b8913          	addi	s2,s7,8
 9bc:	4681                	li	a3,0
 9be:	4629                	li	a2,10
 9c0:	000ba583          	lw	a1,0(s7)
 9c4:	855a                	mv	a0,s6
 9c6:	dddff0ef          	jal	7a2 <printint>
 9ca:	8bca                	mv	s7,s2
      state = 0;
 9cc:	4981                	li	s3,0
 9ce:	b5d9                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9d0:	008b8913          	addi	s2,s7,8
 9d4:	4681                	li	a3,0
 9d6:	4629                	li	a2,10
 9d8:	000ba583          	lw	a1,0(s7)
 9dc:	855a                	mv	a0,s6
 9de:	dc5ff0ef          	jal	7a2 <printint>
        i += 1;
 9e2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 9e4:	8bca                	mv	s7,s2
      state = 0;
 9e6:	4981                	li	s3,0
        i += 1;
 9e8:	b575                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ea:	008b8913          	addi	s2,s7,8
 9ee:	4681                	li	a3,0
 9f0:	4629                	li	a2,10
 9f2:	000ba583          	lw	a1,0(s7)
 9f6:	855a                	mv	a0,s6
 9f8:	dabff0ef          	jal	7a2 <printint>
        i += 2;
 9fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 9fe:	8bca                	mv	s7,s2
      state = 0;
 a00:	4981                	li	s3,0
        i += 2;
 a02:	bd49                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 a04:	008b8913          	addi	s2,s7,8
 a08:	4681                	li	a3,0
 a0a:	4641                	li	a2,16
 a0c:	000ba583          	lw	a1,0(s7)
 a10:	855a                	mv	a0,s6
 a12:	d91ff0ef          	jal	7a2 <printint>
 a16:	8bca                	mv	s7,s2
      state = 0;
 a18:	4981                	li	s3,0
 a1a:	bdad                	j	894 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a1c:	008b8913          	addi	s2,s7,8
 a20:	4681                	li	a3,0
 a22:	4641                	li	a2,16
 a24:	000ba583          	lw	a1,0(s7)
 a28:	855a                	mv	a0,s6
 a2a:	d79ff0ef          	jal	7a2 <printint>
        i += 1;
 a2e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a30:	8bca                	mv	s7,s2
      state = 0;
 a32:	4981                	li	s3,0
        i += 1;
 a34:	b585                	j	894 <vprintf+0x4a>
 a36:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 a38:	008b8d13          	addi	s10,s7,8
 a3c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a40:	03000593          	li	a1,48
 a44:	855a                	mv	a0,s6
 a46:	d3fff0ef          	jal	784 <putc>
  putc(fd, 'x');
 a4a:	07800593          	li	a1,120
 a4e:	855a                	mv	a0,s6
 a50:	d35ff0ef          	jal	784 <putc>
 a54:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a56:	00000b97          	auipc	s7,0x0
 a5a:	3cab8b93          	addi	s7,s7,970 # e20 <digits>
 a5e:	03c9d793          	srli	a5,s3,0x3c
 a62:	97de                	add	a5,a5,s7
 a64:	0007c583          	lbu	a1,0(a5)
 a68:	855a                	mv	a0,s6
 a6a:	d1bff0ef          	jal	784 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a6e:	0992                	slli	s3,s3,0x4
 a70:	397d                	addiw	s2,s2,-1
 a72:	fe0916e3          	bnez	s2,a5e <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 a76:	8bea                	mv	s7,s10
      state = 0;
 a78:	4981                	li	s3,0
 a7a:	6d02                	ld	s10,0(sp)
 a7c:	bd21                	j	894 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 a7e:	008b8993          	addi	s3,s7,8
 a82:	000bb903          	ld	s2,0(s7)
 a86:	00090f63          	beqz	s2,aa4 <vprintf+0x25a>
        for(; *s; s++)
 a8a:	00094583          	lbu	a1,0(s2)
 a8e:	c195                	beqz	a1,ab2 <vprintf+0x268>
          putc(fd, *s);
 a90:	855a                	mv	a0,s6
 a92:	cf3ff0ef          	jal	784 <putc>
        for(; *s; s++)
 a96:	0905                	addi	s2,s2,1
 a98:	00094583          	lbu	a1,0(s2)
 a9c:	f9f5                	bnez	a1,a90 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 a9e:	8bce                	mv	s7,s3
      state = 0;
 aa0:	4981                	li	s3,0
 aa2:	bbcd                	j	894 <vprintf+0x4a>
          s = "(null)";
 aa4:	00000917          	auipc	s2,0x0
 aa8:	37490913          	addi	s2,s2,884 # e18 <malloc+0x268>
        for(; *s; s++)
 aac:	02800593          	li	a1,40
 ab0:	b7c5                	j	a90 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 ab2:	8bce                	mv	s7,s3
      state = 0;
 ab4:	4981                	li	s3,0
 ab6:	bbf9                	j	894 <vprintf+0x4a>
 ab8:	64a6                	ld	s1,72(sp)
 aba:	79e2                	ld	s3,56(sp)
 abc:	7a42                	ld	s4,48(sp)
 abe:	7aa2                	ld	s5,40(sp)
 ac0:	7b02                	ld	s6,32(sp)
 ac2:	6be2                	ld	s7,24(sp)
 ac4:	6c42                	ld	s8,16(sp)
 ac6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 ac8:	60e6                	ld	ra,88(sp)
 aca:	6446                	ld	s0,80(sp)
 acc:	6906                	ld	s2,64(sp)
 ace:	6125                	addi	sp,sp,96
 ad0:	8082                	ret

0000000000000ad2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ad2:	715d                	addi	sp,sp,-80
 ad4:	ec06                	sd	ra,24(sp)
 ad6:	e822                	sd	s0,16(sp)
 ad8:	1000                	addi	s0,sp,32
 ada:	e010                	sd	a2,0(s0)
 adc:	e414                	sd	a3,8(s0)
 ade:	e818                	sd	a4,16(s0)
 ae0:	ec1c                	sd	a5,24(s0)
 ae2:	03043023          	sd	a6,32(s0)
 ae6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 aea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 aee:	8622                	mv	a2,s0
 af0:	d5bff0ef          	jal	84a <vprintf>
}
 af4:	60e2                	ld	ra,24(sp)
 af6:	6442                	ld	s0,16(sp)
 af8:	6161                	addi	sp,sp,80
 afa:	8082                	ret

0000000000000afc <printf>:

void
printf(const char *fmt, ...)
{
 afc:	711d                	addi	sp,sp,-96
 afe:	ec06                	sd	ra,24(sp)
 b00:	e822                	sd	s0,16(sp)
 b02:	1000                	addi	s0,sp,32
 b04:	e40c                	sd	a1,8(s0)
 b06:	e810                	sd	a2,16(s0)
 b08:	ec14                	sd	a3,24(s0)
 b0a:	f018                	sd	a4,32(s0)
 b0c:	f41c                	sd	a5,40(s0)
 b0e:	03043823          	sd	a6,48(s0)
 b12:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b16:	00840613          	addi	a2,s0,8
 b1a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b1e:	85aa                	mv	a1,a0
 b20:	4505                	li	a0,1
 b22:	d29ff0ef          	jal	84a <vprintf>
}
 b26:	60e2                	ld	ra,24(sp)
 b28:	6442                	ld	s0,16(sp)
 b2a:	6125                	addi	sp,sp,96
 b2c:	8082                	ret

0000000000000b2e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b2e:	1141                	addi	sp,sp,-16
 b30:	e422                	sd	s0,8(sp)
 b32:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b34:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b38:	00001797          	auipc	a5,0x1
 b3c:	4d07b783          	ld	a5,1232(a5) # 2008 <freep>
 b40:	a02d                	j	b6a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b42:	4618                	lw	a4,8(a2)
 b44:	9f2d                	addw	a4,a4,a1
 b46:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b4a:	6398                	ld	a4,0(a5)
 b4c:	6310                	ld	a2,0(a4)
 b4e:	a83d                	j	b8c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b50:	ff852703          	lw	a4,-8(a0)
 b54:	9f31                	addw	a4,a4,a2
 b56:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b58:	ff053683          	ld	a3,-16(a0)
 b5c:	a091                	j	ba0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b5e:	6398                	ld	a4,0(a5)
 b60:	00e7e463          	bltu	a5,a4,b68 <free+0x3a>
 b64:	00e6ea63          	bltu	a3,a4,b78 <free+0x4a>
{
 b68:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b6a:	fed7fae3          	bgeu	a5,a3,b5e <free+0x30>
 b6e:	6398                	ld	a4,0(a5)
 b70:	00e6e463          	bltu	a3,a4,b78 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b74:	fee7eae3          	bltu	a5,a4,b68 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 b78:	ff852583          	lw	a1,-8(a0)
 b7c:	6390                	ld	a2,0(a5)
 b7e:	02059813          	slli	a6,a1,0x20
 b82:	01c85713          	srli	a4,a6,0x1c
 b86:	9736                	add	a4,a4,a3
 b88:	fae60de3          	beq	a2,a4,b42 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b8c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b90:	4790                	lw	a2,8(a5)
 b92:	02061593          	slli	a1,a2,0x20
 b96:	01c5d713          	srli	a4,a1,0x1c
 b9a:	973e                	add	a4,a4,a5
 b9c:	fae68ae3          	beq	a3,a4,b50 <free+0x22>
    p->s.ptr = bp->s.ptr;
 ba0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ba2:	00001717          	auipc	a4,0x1
 ba6:	46f73323          	sd	a5,1126(a4) # 2008 <freep>
}
 baa:	6422                	ld	s0,8(sp)
 bac:	0141                	addi	sp,sp,16
 bae:	8082                	ret

0000000000000bb0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bb0:	7139                	addi	sp,sp,-64
 bb2:	fc06                	sd	ra,56(sp)
 bb4:	f822                	sd	s0,48(sp)
 bb6:	f426                	sd	s1,40(sp)
 bb8:	ec4e                	sd	s3,24(sp)
 bba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bbc:	02051493          	slli	s1,a0,0x20
 bc0:	9081                	srli	s1,s1,0x20
 bc2:	04bd                	addi	s1,s1,15
 bc4:	8091                	srli	s1,s1,0x4
 bc6:	0014899b          	addiw	s3,s1,1
 bca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bcc:	00001517          	auipc	a0,0x1
 bd0:	43c53503          	ld	a0,1084(a0) # 2008 <freep>
 bd4:	c915                	beqz	a0,c08 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bd8:	4798                	lw	a4,8(a5)
 bda:	08977a63          	bgeu	a4,s1,c6e <malloc+0xbe>
 bde:	f04a                	sd	s2,32(sp)
 be0:	e852                	sd	s4,16(sp)
 be2:	e456                	sd	s5,8(sp)
 be4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 be6:	8a4e                	mv	s4,s3
 be8:	0009871b          	sext.w	a4,s3
 bec:	6685                	lui	a3,0x1
 bee:	00d77363          	bgeu	a4,a3,bf4 <malloc+0x44>
 bf2:	6a05                	lui	s4,0x1
 bf4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bf8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bfc:	00001917          	auipc	s2,0x1
 c00:	40c90913          	addi	s2,s2,1036 # 2008 <freep>
  if(p == (char*)-1)
 c04:	5afd                	li	s5,-1
 c06:	a081                	j	c46 <malloc+0x96>
 c08:	f04a                	sd	s2,32(sp)
 c0a:	e852                	sd	s4,16(sp)
 c0c:	e456                	sd	s5,8(sp)
 c0e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c10:	00005797          	auipc	a5,0x5
 c14:	40078793          	addi	a5,a5,1024 # 6010 <base>
 c18:	00001717          	auipc	a4,0x1
 c1c:	3ef73823          	sd	a5,1008(a4) # 2008 <freep>
 c20:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c22:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c26:	b7c1                	j	be6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 c28:	6398                	ld	a4,0(a5)
 c2a:	e118                	sd	a4,0(a0)
 c2c:	a8a9                	j	c86 <malloc+0xd6>
  hp->s.size = nu;
 c2e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c32:	0541                	addi	a0,a0,16
 c34:	efbff0ef          	jal	b2e <free>
  return freep;
 c38:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c3c:	c12d                	beqz	a0,c9e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c40:	4798                	lw	a4,8(a5)
 c42:	02977263          	bgeu	a4,s1,c66 <malloc+0xb6>
    if(p == freep)
 c46:	00093703          	ld	a4,0(s2)
 c4a:	853e                	mv	a0,a5
 c4c:	fef719e3          	bne	a4,a5,c3e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 c50:	8552                	mv	a0,s4
 c52:	b1bff0ef          	jal	76c <sbrk>
  if(p == (char*)-1)
 c56:	fd551ce3          	bne	a0,s5,c2e <malloc+0x7e>
        return 0;
 c5a:	4501                	li	a0,0
 c5c:	7902                	ld	s2,32(sp)
 c5e:	6a42                	ld	s4,16(sp)
 c60:	6aa2                	ld	s5,8(sp)
 c62:	6b02                	ld	s6,0(sp)
 c64:	a03d                	j	c92 <malloc+0xe2>
 c66:	7902                	ld	s2,32(sp)
 c68:	6a42                	ld	s4,16(sp)
 c6a:	6aa2                	ld	s5,8(sp)
 c6c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 c6e:	fae48de3          	beq	s1,a4,c28 <malloc+0x78>
        p->s.size -= nunits;
 c72:	4137073b          	subw	a4,a4,s3
 c76:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c78:	02071693          	slli	a3,a4,0x20
 c7c:	01c6d713          	srli	a4,a3,0x1c
 c80:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c82:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c86:	00001717          	auipc	a4,0x1
 c8a:	38a73123          	sd	a0,898(a4) # 2008 <freep>
      return (void*)(p + 1);
 c8e:	01078513          	addi	a0,a5,16
  }
}
 c92:	70e2                	ld	ra,56(sp)
 c94:	7442                	ld	s0,48(sp)
 c96:	74a2                	ld	s1,40(sp)
 c98:	69e2                	ld	s3,24(sp)
 c9a:	6121                	addi	sp,sp,64
 c9c:	8082                	ret
 c9e:	7902                	ld	s2,32(sp)
 ca0:	6a42                	ld	s4,16(sp)
 ca2:	6aa2                	ld	s5,8(sp)
 ca4:	6b02                	ld	s6,0(sp)
 ca6:	b7f5                	j	c92 <malloc+0xe2>
