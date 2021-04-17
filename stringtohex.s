.data
name: .string "1A5B8F"
newline: .string "\n"
message: .string "lala\n"
black2s: .string "FFFFEEFF"
black2: .int 0x46
.bss
vale: .short

.text                       
.globl _start                
_start:

   mov $0,%esi
   lala:
   inc %esi
   mov $0 ,%eax
   mov $0 ,%ebx



    movl $4, %eax
    movl $1, %ebx
    movl $message,%ecx
    movl $5, %edx
    int $0x80

   mov black2, %ebx
   movb black2s(,%esi,1), %al

   cmp %eax, %ebx
   je lala 



    mov %eax , %ecx
    movl $4, %eax
    movl $1, %ebx
    //movl $black2s,%ecx
    movl $2, %edx
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



