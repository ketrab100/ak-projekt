.data
name: .string "./d.bmp"
fd: .int 0
buf: .string "0"
len: .long 0x86
sizex: .int 0
sizey: .int 0
paddingBytes: .int 0
R:.int 0
G:.int 0
B:.int 0
DIBHeaderSize: .int 0
pixelsPerBar: .int 0
offset: .int 0
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
# calcPaddingBytes
    movl $3, %eax # 3 bajty na pixel
    mull sizex
    clc
subl4:
    subl $4, %eax
    cmpl $0, %eax
    je next1
    jc next
    jmp subl4
next:
    movl $-1 , %ebx
    mull %ebx
    movl %eax, paddingBytes
next1:
    movl %eax, paddingBytes
# get DIBHeaderSize
    movl $14, %edi 
    movl buf(,%edi,1), %eax
    movl %eax, DIBHeaderSize

# get pixelsPerBar
    movl DIBHeaderSize, %eax
    addl $14, %eax
    movl %eax, offset
    movl $3, %eax
    mull sizex
    movl %eax, %ecx # ilosc bajtow w jednym wierszu w rejestrze C
    movl $2, %eax
    movl sizey, %ebx
    divl %ebx # wysokosci polowy obrazka w rejestrze D
    movl %edx, %eax
    movl %edx, %ebx
    mull %ecx
    addl %eax, offset
    movl %ebx, %eax 
    mull paddingBytes
    addl %eax, offset
    movl offset, %edi
jump:
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , R
    inc %edi
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , G
    inc %edi
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , B
    inc %edi

    movl $0, %eax
checkR:
    cmpl R, %eax
    je checkG
    jmp jump
checkG:
    cmpl G, %eax
    je checkB
    jmp jump
checkB:
    cmpl B, %eax
    je countBlackPixels
    jmp jump

countBlackPixels:
    movl pixelsPerBar, %eax
    inc %eax
    movl %eax, pixelsPerBar 

    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , R
    inc %edi
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , G
    inc %edi
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , B
    inc %edi

    movl $0, %eax
checkR1:
    cmpl R, %eax
    je checkG1
    jmp end
checkG1:
    cmpl G, %eax
    je checkB1
    jmp end
checkB1:
    cmpl B, %eax
    je countBlackPixels
    jmp end

end:

 # exit(0)
    movl    $1, %eax  
    movl    $0, %ebx   
    int     $0x80     

