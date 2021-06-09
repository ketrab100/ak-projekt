.data
name: .string "./ean-81.bmp"
fd: .int 0
buf: .space 30000000
len: .long 0x86
sizex: .int 0
sizey: .int 0
R:.int 0
G:.int 0
B:.int 0
DIBHeaderSize: .int 0
pixelsPerBar: .int 0
paddingBytes: .int 0
offset: .int 0
currentOffset: .int 0
result: 
    .long 0,0,0,0,0,0,0,0
    result_len = (.-result)

leftCode:
    .long 0b0001101,0b0011001,0b0010011,0b0111101,0b0100011,0b0110001,0b0101111,0b0111011,0b0110111,0b0001011

rightCode:
    .long 0b1110010,0b1100110,0b1101100,0b1000010,0b1011100,0b1001110,0b1010000,0b1000100,0b1001000,0b1110100

codeValue: .long 0
.text                       
.globl reader                
reader:
  push %ebp
  mov %esp, %ebp
  
  mov 8(%ebp), %ebx
  mov %ebx, buf

# get size
  mov buf, %edi
  add $18, %edi 
  mov 0(%edi), %eax
  movl %eax, sizex

  mov buf, %edi
  add $22, %edi 
  mov 0(%edi), %eax
  movl %eax, sizey

# calcPaddingBytes
    movl $3, %eax                                           # 3 to eax (3 bytes per color)
    mull sizex                                              # eax *= sizex
    movl %eax, %ecx
    clc                                                     # clear carry flag
    movl $4, %ebx
    divl %ebx                                               # eax/=4
    mull %ebx                                               # eax*=4 
    subl %ecx, %eax                                         # ecx -= eax  (3*sizex-[3*sizex/4*4] == 3*sizex%4)
    cmp $0, %eax
    je padding0
    addl $4, %eax
    movl %eax, paddingBytes
    jmp endCalcPaddingBytes
padding0:
    movl $0, paddingBytes
endCalcPaddingBytes:

# get DIBHeaderSize
	mov buf, %edi
    add $14, %edi 
    movl 0(%edi), %eax
    movl %eax, DIBHeaderSize

# get pixelsPerBar
    movl DIBHeaderSize, %eax
    addl $14, %eax
    movl %eax, offset

    movl $3, %eax
    mull sizex
    movl %eax, %ecx # ilosc bajtow w jednym wierszu w rejestrze C
    movl $2, %ebx
    movl sizey, %eax
    divl %ebx # wysokosci polowy obrazka w rejestrze A
    mull %ecx

    addl %eax, offset

    movl $2, %ebx
    movl sizey, %eax
    divl %ebx # wysokosci polowy obrazka w rejestrze A
    mull paddingBytes

    addl %eax, offset

    movl offset, %esi
jump:
    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , R
    inc %esi
    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , G
    inc %esi
    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , B
    inc %esi

    movl $100, %eax
checkR:
    cmpl R, %eax
    ja checkG
    jmp jump
checkG:
    cmpl G, %eax
    ja checkB
    jmp jump
checkB:
    cmpl B, %eax
    ja countBlackPixels
    jmp jump

countBlackPixels:
    movl pixelsPerBar, %eax
    inc %eax
    movl %eax, pixelsPerBar 

    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , R
    inc %esi
    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , G
    inc %esi
    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , B
    inc %esi

    movl $100, %eax
checkR1:
    cmpl R, %eax
    ja checkG1
    jmp next
checkG1:
    cmpl G, %eax
    ja checkB1
    jmp next
checkB1:
    cmpl B, %eax
    ja countBlackPixels
    jmp next
next:
    subl $3, %esi
    # pominiecie paskow startowych
    movl pixelsPerBar, %eax
    movl $3, %ebx
    mull %ebx
    addl %eax, %esi 

    movl pixelsPerBar, %eax
    movl $3, %ebx
    mull %ebx
    addl %eax, %esi



    movl $0, %ebx
    movl $0, %edx

decode:
    movl $8, %ecx
decodeOneNumber:

    dec %ecx
    mov $0, %eax
    cmpl %ecx, %eax
    je next1

    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , R
    inc %esi

    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , G
    inc %esi

    movl $0, %eax
    mov buf, %edi
    mov %esi, currentOffset
    add currentOffset, %edi
    movb 0(%edi), %al
    mov %al , B
    inc %esi

    subl $3, %esi
    
    movl pixelsPerBar, %eax
    push %ebx
    movl $3, %ebx
    push %edx
    mull %ebx
    pop %edx
    pop %ebx
    addl %eax, %esi


    movl $100, %eax
    shll $1, %ebx
checkR2:
    cmpl R, %eax
    ja checkG2
    jmp decodeOneNumber
checkG2:
    cmpl G, %eax
    ja checkB2
    jmp decodeOneNumber
checkB2:
    cmpl B, %eax
    ja blackBar
    jmp decodeOneNumber

blackBar:
    or $0b1, %ebx
    jmp decodeOneNumber

next1:
    mov %ebx, result(,%edx,4)
    inc %edx
    mov $0, %ebx

    mov $4, %eax
    cmp %edx, %eax
    je skip

    mov $8, %eax
    cmp %edx, %eax
    je saveResult
    jmp decode

skip:
    movl pixelsPerBar, %eax
    movl $15, %ebx
    push %edx
    mull %ebx
    pop %edx
    movl $0, %ebx
    addl %eax, %esi
    jmp decode

    
saveResult:
    mov $0, %ebx

loop1:
    mov $0,%edx

loop:
    mov result(,%ebx,4), %eax
    cmpl %eax, leftCode(,%edx,4)
    je convert
    inc %edx
    jmp loop
convert:
    addl %edx, codeValue
    movl codeValue, %eax
    movl $10, %ecx
    push %edx
    mull %ecx
    pop %edx
    movl %eax, codeValue
    inc %ebx
    movl $4, %eax
    cmpl %ebx, %eax
    je saveResult1
    jmp loop1

saveResult1:

loop3:
    mov $0,%edx

loop2:
    mov result(,%ebx,4), %eax
    cmpl %eax, rightCode(,%edx,4)
    je convert1
    inc %edx
    jmp loop2
convert1:
    addl %edx, codeValue
    movl codeValue, %eax
    movl $10, %ecx
    push %edx
    mull %ecx
    pop %edx
    movl %eax, codeValue
    inc %ebx
    movl $8, %eax
    cmpl %ebx, %eax
    je exit
    jmp loop3
exit:
	movl $1, %eax
    pop %ebp
    ret
