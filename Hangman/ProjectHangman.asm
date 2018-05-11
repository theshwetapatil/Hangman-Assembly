# Hangman.asm : Defines the hangman game.
# Assembly Game: Hangman
# Gameplay features: string matching, winner-loser detection
# Author: Shweta Patil
# Copyright: Shweta Patil © 2018

	.data
label:	.asciiz	"\nPress any key : "
line:	.asciiz	"Hangman!!!  "	   
line0:	.ascii	"\n…ÕÕÕÕÕÕÕÕ∏"
	.ascii	"\n∫                "
	.ascii	"\n∫                    "
	.ascii	"\n∫                            "
	.ascii	"\n∫                           "
	.ascii	"\n∫                            "
	.ascii	"\n∫                       "
	.asciiz	"\n                         "
body_parts:	.byte	9,2,1,9,3,179,8,3,95,10,3,95,9,4,179,9,5,179
		.byte	7,4,47,11,4,92,6,5,42,12,5,42,8,6,47,10,6,92,7,7,74,11,7,76,0
prompt:	.asciiz	"\nPlay again??? : "
puzzle:	.asciiz "\nGuess the puzzle : "
alpha:	.asciiz	"\nabcdefghijklmnopqrstuvwxyz"
in:	.space	20
win:	.asciiz	"\n Winner!!!"
loose:	.asciiz	"\n Looser!!!\nThe original word is : "
	
ronlytxt	.word
file.bufsize 	= 	1024 	 
file 	.struct 	  	 
descriptor 	.word 	0 	#desscriptor returned from open
name 	.word 	0 	#pointer to file name string
count 	.word 	0 	#count of the bytes in the buffer
pointer 	.word 	0 	#pointer to the next character in the buffer
buffer 	.space 	file.bufsize 	#actual file buffer
  	.data 	  	# end-of-struct


#begin File flag constants -----------------------
# copied directly out of VC++ 8 fcntl.h header with minor mods
# to use these, ori these values together into the $a1 register
# e.g., to create a new file and open it write-only,
# with text translation off:
#	li	$a1, _O_CREAT+_O_BINARY
#
#	This is the equivalent of the C code:
#	a1 = _O_CREAT | _O_BINARY
#
_O_RDONLY	= 0x0000 # /* open for reading only */
_O_WRONLY	= 0x0001 # /* open for writing only */
_O_RDWR	= 0x0002 # /* open for reading and writing */
_O_APPEND	= 0x0008 # /* writes done at eof */
_O_REWRITABLE	= 0x0090 # // without this file becomes read-only.
_O_CREAT	= 0x0100	#/* create and open file */
_O_TRUNC	= 0x0200	#/* open and truncate */
_O_EXCL	= 0x0400	#/* open only if file doesn't already exist */
#/* O_TEXT files have <cr><lf> sequences translated to <lf> on read()'s,
#** and <lf> sequences translated to <cr><lf> on write()'s*/
_O_TEXT 	= 0x4000	#/* file mode is text (translated) */
_O_BINARY	= 0x8000	#/* file mode is binary (untranslated) */
_O_WTEXT	= 0x10000 #/* file mode is UTF16 (translated) */
_O_U16TEXT	= 0x20000 #/* file mode is UTF16 no BOM (translated) */
_O_U8TEXT	= 0x40000 #/* file mode is UTF8	no BOM (translated) */
#end File flag constants 	
	.code
#begin file.open
file.open:
	#open a file for writing
	sw	$a0,file.name($a3)      
	li	$a1,_O_TEXT        
	li	$a2,0
	syscall	$open          
	sw	$v0,file.descriptor($a3) #end
#begin	file.fillBuffer	
file.fillBuffer:
	lw	$a0,file.descriptor($a3)
	addi	$a1,$a3,file.buffer
	sw	$a1,file.pointer($a3)
	li	$a2,file.bufsize
	syscall	$read
	sw	$v0,file.count($a3)
	jr	$ra	#end
#begin	file.close
file.close:
	#close file
	lw	$a0,file.descriptor($a3)      
	syscall	$close           
	jr	$ra	#end
#begin
#	arguments	a0	pointer to dest buf
#		a1	size of user buf
#		a3	pointer to the file	
file.readln:
	lw	$t0,file.pointer($a3)
	lw	$t1,file.count($a3)
	li	$t2,10
	mov	$v0,$0
	b	5f
do:	lbu	$t3,0($t0)
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	beq	$t3,$t2,9f
	sb	$t3,($a0)
	addi	$a0,$a0,1
	addi	$a1,$a1,-1
	addi	$v0,$v0,1
	beqz	$a1,9f
5:	bgtz	$t1,do
	addi	$sp,$sp,-20
	sw	$ra,0($sp)
	sw	$v0,4($sp)
	sw	$a0,8($sp)
	sw	$a1,12($sp)
	jal	file.fillBuffer
	lw	$t0,file.pointer($a3)
	lw	$t1,file.count($a3)
	lw	$ra,0($sp)
	lw	$v0,4($sp)
	lw	$a0,8($sp)
	lw	$a1,12($sp)
	addi	$sp,$sp,20
	bgtz	$t1,do
9:	sb	$0,($a0)
	sw	$t0,file.pointer($a3)
	sw	$t1,file.count($a3)
	jr	$ra	#end

	.data
filename:	.asciiz	"srk&rk.txt"
	.align	2
lines	=	67
w:	.space	41
	.align	2
file1	.space	file		#size of entire file


	.code
	.globl main
	#begin get the string
main:	mov	$a0,$0
	mov	$a1,$0
	syscall	$xy
	la	$a0,line
	syscall	$print_string
	#end

	#begin random number generator
go:	syscall	$random
	mov	$t3,$v0
	li	$t0,67
	remu	$v0,$v0,$t0
	addi	$v0,$v0,1
	#end
	
	#begin file handling
next:	mov	$s1,$v0
	la	$a0,filename
	la	$a3,file1   
	jal	file.open
3:	la	$a0,w
	li	$a1,40
	jal	file.readln
	mov	$s5,$v0
	addi	$s1,$s1,-1
	bgtz	$s1,3b
	la	$a0,w
	jal	file.close	
	#end		
	
	#begin draw hangman
	la	$a0,line0
	syscall	$print_string
	mov	$s0,$0	
	la	$a0,label
	syscall	$print_string
	#end	
	
	#begin Guess character
	la	$a0,puzzle
	syscall	$print_string
	
	addi	$t6,$0,45
	addi	$t8,$0,58
	mov	$t3,$s5
	la	$s1,w
for:	lbu 	$a0,0($s1)
	addi 	$s1,$s1,1
	beq	$a0,$t6,pr
	beq	$a0,$t8,pr
	addi	$a0,$0,'_
pr:	syscall	$print_char
	li	$a0,32
	syscall	$print_char
	addi	$t3,$t3,-1
	bnez	$t3,for
	li	$t6,20
repeat:	li	$a0,32
	syscall	$print_char
	addi	$t6,$t6,-1
	bnez	$t6,repeat
		
	la	$a0,alpha
	syscall	$print_string
	
	li	$a0,19
	li	$a1,10
	syscall	$xy
st:	syscall	$read_char
	mov	$s4,$v0
	addi	$a0,$s4,0-'a
	li	$a1,11
	syscall	$xy
	li	$a0,32
	beq	$a0,$v0,st
	syscall	$print_char	
	
	#compare character with the string
	la	$s1,w
	mov	$t9,$0
loop1:	lbu 	$a0,0($s1)
	addi 	$s1,$s1,1
	beqz	$a0,6f
	
	bne 	$a0,$s4,loop1		#character match
	#add character to the puzzle
	la	$t6,w
	sub	$a0,$s1,$t6
	sll	$a0,$a0,1
	addi	$a0,$a0,17
	li	$a1,10
	syscall	$xy
	mov	$a0,$s4
	syscall	$print_char
	addi	$t9,$t9,1
	b	loop1
	
6:	bnez	$t9,2f
	
	#add body part
	la	$a0,body_parts
	sll	$t1,$s0,1
	add	$t1,$t1,$s0
	addu	$t1,$a0,$t1
	lb	$a0,($t1)
	#beqz	$a0,exit
	lb	$a1,1($t1)
	syscall	$xy
	lb	$a0,2($t1)
	syscall	$print_char
	lb	$v0,3($t1)
	addi	$s0,$s0,1
	beqz	$v0,8f
		
	#winner
2:	sub	$s5,$s5,$t9
	bnez	$s5,st
	li	$a1,13
	syscall	$xy
	la	$a0,win
	syscall	$print_string
	b	4f

	#looser
8:	mov	$t7,$a0	#t7=0=HANGED
	li	$a1,13
	syscall	$xy
	la	$a0,loose
	syscall	$print_string
	la	$a0,w
	syscall	$print_string	
	#end
	
4:	la	$a0,prompt
	syscall	$print_string
	syscall	$read_char
	li	$t5,89
	beq	$v0,$t5,main
	li	$t5,121
	beq	$v0,$t5,main
	
	syscall	$exit
		