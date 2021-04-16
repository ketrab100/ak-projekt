.data
name: .string "1A5B8F"
name1: .string "GGG"
newline: .string "\n"
.bss
vale: .short

.text                       
.globl _start                
_start:

    movl $0, %edi

    movb name, %ah
    movb %ah, vale
    movb name, %al
    movb %al, vale(,2)



    movl $4, %eax
    movl $1, %ebx
    movl $vale,%ecx
    movl $8, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $newline,%ecx
    movl $1, %edx
    int $0x80

 # exit(0)
    movl    $1, %eax  
    movl    $0, %ebx   
    int     $0x80   
