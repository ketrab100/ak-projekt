.data
;wskaznik na miejsce w ktorym jest zapisany obraz
buf: .quad 0
;ilosc pixeli x
sizex: .int 0
;ilosc pixeli y
sizey: .int 0
;ilosc bajtow obrazka
size: .int 0
;czerwony
R:.int 0
;zielony
G:.int 0
;niebieski
B:.int 0
;ilosc pixeli przypadajacych na szerokosc paska
pixelsPerBar: .int 0
;bajty paddingu
paddingBytes: .int 0
;miejsce rozpoczecia kodowania pixeli
offset: .int 0
;tablica w ktorej na kolejnych pozycjach sa wartosci przeczytane z obrazka 
result: 
    .long 0,0,0,0,0,0,0,0
;wartosci kodu ean8 A
leftCode:
    .long 0b0001101,0b0011001,0b0010011,0b0111101,0b0100011,0b0110001,0b0101111,0b0111011,0b0110111,0b0001011
;wartosci kodu ean8 B
rightCode:
    .long 0b1110010,0b1100110,0b1101100,0b1000010,0b1011100,0b1001110,0b1010000,0b1000100,0b1001000,0b1110100
;odkodowany wynik
codeValue: .long 0

.text                       
.globl reader                
reader:
  push %ebp
  mov %esp, %ebp
;odczytanie ze stosu wskaznika na obraz
  movl 8(%ebp), %eax
  movl %eax, buf

  mov $0, %eax
;sprawdzenie czy dany plik ma rozszerzenie .bmp i ma format 24-bit
  mov buf, %edi
  movb 0(%edi), %al
  cmpl $0x42, %eax
  jne error
  add $1, %edi
  movb 0(%edi), %al
  cmpl $0x4D, %eax
  jne error
  mov buf, %edi
  add $0x1c, %edi
  movb 0(%edi), %al
  cmpl $0x18, %eax
  jne error

;pobranie rozmiarow obrazu
  mov buf, %edi
  add $2, %edi 
  movl 0(%edi), %eax
  movl %eax, size


  mov buf, %edi
  add $18, %edi 
  mov 0(%edi), %eax
  mov %eax, sizex

  mov buf, %edi
  add $22, %edi 
  mov 0(%edi), %eax
  mov %eax, sizey

;obliczenie bitow paddingu
    movl $3, %eax                                        
    mull sizex                                             
    movl %eax, %ecx
    clc                                                     
    movl $4, %esi
    divl %esi                                               
    mull %esi                                               
    subl %ecx, %eax                                        
    cmp $0, %eax
    je padding0
    addl $4, %eax
    movl %eax, paddingBytes
    jmp endCalcPaddingBytes
padding0:
    movl $0, paddingBytes
endCalcPaddingBytes:

;odczytanie offsetu z obrazu
    mov buf, %edi
    add $10, %edi 
    movl 0(%edi), %eax
    movl %eax, offset

;obliczenie ilosci bitow przypadajacych na szerokosc jednego paseka
;przejscie przez biale pixele az do napotkania czarnego
    movl $3, %eax
    mull sizex
    movl %eax, %ecx
    movl $2, %esi
    movl sizey, %eax
    divl %esi
    mull %ecx
    addl %eax, offset
    movl $2, %esi
    movl sizey, %eax
    divl %esi
    mull paddingBytes
    addl %eax, offset
    movl buf, %edi
    add offset, %edi
jump:
    movl buf, %eax
    add size, %eax
    add $4, %eax
    cmpl %eax, %edi
    ja error
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
;zliczenie czarnych pixeli na pierwszym pasku
countBlackPixels:
    movl buf, %eax
    add size, %eax
    add $4, %eax
    cmpl %eax, %edi
    ja error

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
;pominiecie paskow startowych
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

;dekodowanie 
decode:
    movl $8, %ecx
;dekodowanie ciagu 7 paskow - jedna cyfra
decodeOneNumber:
    movl buf, %eax
    add size, %eax
    add $4, %eax
    cmpl %eax, %edi
    ja error

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
;przeskoczenie paskow srodkowych - oddzielajacych prawa czesc od lewej
    movl pixelsPerBar, %eax
    movl $15, %esi
    push %edx
    mull %esi
    pop %edx
    movl $0, %esi
    addl %eax, %edi
    jmp decode

;zamiana ciagu binarnrgo na odpowiadajace mu cyfry w kodzie ean8 dla lewej czesci
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

;zamiana ciagu binarnrgo na odpowiadajace mu cyfry w kodzie ean8 dla prawej czesci
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

;zwracana jest wartosc odkodowanego obrazu
exit:
    mov codeValue, %eax
    pop %ebp
    ret

;w przypadku bledu zwracana jest wartosc 1000000000
error:
    mov $1000000000, %eax
    pop %ebp
    ret

