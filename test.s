.data
name: .string "./b.bmp"
fd: .int 0
buf: .string "0"
len: .long 0x86
sizex: .int 0
sizey: .int 0
.text                       
.globl _start                
_start:
# open file
    movl $5, %eax # sys_open
    movl $name, %ebx
    movl $0, %ecx # access: read-only
    movl $0777, %edx # read, write and execute by all
    int $0x80

# get file descriptor
    movl %eax, fd

# read from file
    movl $3, %eax # sys_read
    movl fd, %ebx
    movl $buf, %ecx
    movl $len, %edx
    int $0x80

# close file
    movl $6, %eax # sys_close
    movl $name, %ebx
    int $0x80

# print
   movl $4, %eax
   movl $1, %ebx
   movl $buf,%ecx
   movl len, %edx
   int $0x80

# get size
  movl $18, %edi 
  movl buf(,%edi,1), %eax
  movl %eax, sizex
  movl $22, %edi 
  movl buf(,%edi,1), %eax
  movl %eax, sizey




 # exit(0)
    movl    $1, %eax  
    movl    $0, %ebx   
    int     $0x80     

