.data
buf: .quad 0
sizex: .int 0
sizey: .int 0
R:.int 0
G:.int 0
B:.int 0
pixelsPerBar: .int 0
paddingBytes: .int 0
offset: .int 0
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
  
  movl 8(%ebp), %eax
  movl %eax, buf

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
    movl $4, %esi
    divl %esi                                               # eax/=4
    mull %esi                                               # eax*=4 
    subl %ecx, %eax                                         # ecx -= eax  (3*sizex-[3*sizex/4*4] == 3*sizex%4)
    cmp $0, %eax
    je padding0
    addl $4, %eax
    movl %eax, paddingBytes
    jmp endCalcPaddingBytes
padding0:
    movl $0, paddingBytes
endCalcPaddingBytes:

# get offset
    mov buf, %edi
    add $10, %edi 
    movl 0(%edi), %eax
    movl %eax, offset

# get pixelsPerBar

    movl $3, %eax
    mull sizex
    movl %eax, %ecx # ilosc bajtow w jednym wierszu w rejestrze C
    movl $2, %esi
    movl sizey, %eax
    divl %esi # wysokosci polowy obrazka w rejestrze A
    mull %ecx

    addl %eax, offset

    movl $2, %esi
    movl sizey, %eax
    divl %esi # wysokosci polowy obrazka w rejestrze A
    mull paddingBytes

    addl %eax, offset

    movl buf, %edi
    add offset, %edi
jump:
    movl $0, %eax
    movb 0(%edi), %al
    mov %al , R
    inc %edi
    movl $0, %eax
    movb 0(%edi), %al
    mov %al , G
    inc %edi
    movl $0, %eax
    movb 0(%edi), %al
    mov %al , B
    inc %edi

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
    movb 0(%edi), %al
    mov %al , R
    inc %edi
    movl $0, %eax
    movb 0(%edi), %al
    mov %al , G
    inc %edi
    movl $0, %eax
    movb 0(%edi), %al
    mov %al , B
    inc %edi

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
    subl $3, %edi
    # pominiecie paskow startowych
    movl pixelsPerBar, %eax
    movl $3, %esi
    mull %esi
    addl %eax, %edi 

    movl pixelsPerBar, %eax
    movl $3, %esi
    mull %esi
    addl %eax, %edi



    movl $0, %esi
    movl $0, %edx

decode:
    movl $8, %ecx
decodeOneNumber:

    dec %ecx
    mov $0, %eax
    cmpl %ecx, %eax
    je next1

    movl $0, %eax
    movb 0(%edi), %al
    mov %al , R
    inc %edi

    movl $0, %eax
    movb 0(%edi), %al
    mov %al , G
    inc %edi

    movl $0, %eax
    movb 0(%edi), %al
    mov %al , B
    inc %edi

    subl $3, %edi
    
    movl pixelsPerBar, %eax
    push %esi
    movl $3, %esi
    push %edx
    mull %esi
    pop %edx
    pop %esi
    addl %eax, %edi


    movl $100, %eax
    shll $1, %esi
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
    or $0b1, %esi
    jmp decodeOneNumber

next1:
    mov %esi, result(,%edx,4)
    inc %edx
    mov $0, %esi

    mov $4, %eax
    cmp %edx, %eax
    je skip

    mov $8, %eax
    cmp %edx, %eax
    je saveResult
    jmp decode

skip:
    movl pixelsPerBar, %eax
    movl $15, %esi
    push %edx
    mull %esi
    pop %edx
    movl $0, %esi
    addl %eax, %edi
    jmp decode

    
saveResult:
    mov $0, %esi

loop1:
    mov $0,%edx

loop:
    mov result(,%esi,4), %eax
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
    inc %esi
    movl $4, %eax
    cmpl %esi, %eax
    je saveResult1
    jmp loop1

saveResult1:

loop3:
    mov $0,%edx

loop2:
    mov result(,%esi,4), %eax
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
    inc %esi
    movl $8, %eax
    cmpl %esi, %eax
    je exit
    jmp loop3
exit:
    mov codeValue, %eax
    pop %ebp
    ret

