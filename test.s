.data									                    # data section
name: .string "./d.bmp"							            # path to bmp file (this folder d.bmp)
fd: .int 0								                    # filedecryptor
buf: .string "0"							                # bufor = string ="0"
len: .long 0x86                                             # lenght of file
sizex: .int 0                                               # number of pixels in x axis
sizey: .int 0                                               # number of pixels in y axis
paddingBytes: .int 0                                        # number of padding bytes
R:.int 0                                                    # R=0
G:.int 0                                                    # G=0
B:.int 0                                                    # B=0
DIBHeaderSize: .int 0                                       #DIBHeader lenght
pixelsPerBar: .int 0                                        #pixelsPerBar
offset: .int 0                                              #offset
.text                                                       #"code" section                  
.globl _start                
_start:
# open file
    movl $5, %eax                                           # sys_open
    movl $name, %ebx                                        #name to ebx
    movl $0, %ecx                                           # access: read-only
    movl $0777, %edx                                        # read, write and execute by all
    int $0x80                                               # system call

# get file descriptor
    movl %eax, fd                                           #save filedecryptor to fd (eax value to fd)

# read from file
    movl $3, %eax                                           # sys_read
    movl fd, %ebx                                           # filedecryptor to ebx
    movl $buf, %ecx                                         # buf to ecx (ecx = .string "0")
    movl $len, %edx                                         # lenght of file to edx
    int $0x80                                               # system call

# close file
    movl $6, %eax                                           # sys_close
    movl $name, %ebx                                        # name to ebx
    int $0x80                                               # system call

# print
   movl $4, %eax                                            # 4 to eax
   movl $1, %ebx                                            # 1 to ebx
   movl $buf,%ecx                                           # buf to ecx
   movl len, %edx                                           # len to edx
   int $0x80                                                # system call

# get size
  movl $18, %edi                                            # 18 to edi (byte number 18)
  movl buf(,%edi,1), %eax                                   # get value of sizex from file, then save to eax
  movl %eax, sizex                                          # eax to sizex
  movl $22, %edi                                            # 22 to edi (byte number 22)
  movl buf(,%edi,1), %eax                                   # get value of sizey from file then save to eax
  movl %eax, sizey                                          # eax to sizey

# calcPaddingBytes
    movl $3, %eax                                           # 3 to eax (3 bytes per color)
    mull sizex                                              # eax *= sizex
    movl %eax, %ecx                                         # eax to ecx
    clc                                                     # clear carry flag
    movl $4, %ebx                                           # 4 to ebx
    divl %ebx                                               # eax/=4
    mull %ebx                                               # eax*=4 
    subl %ecx, %eax                                         # eax -= ecx  ([3*sizex/4*4] - sizex*3 == 3*sizex%4-4)
    cmp $0, %eax                                            # if eax==0
    je padding0                                             # go to padding 0
    addl $4, %eax                                           # eax+=4
    movl %eax, paddingBytes                                 # paddingBytes=eax
    jmp endCalcPaddingBytes                                 # go to endCalcPaddingBytes
padding0:                                                   
    movl $0, paddingBytes                                   # 0 to paddingBytes
endCalcPaddingBytes:

# get DIBHeaderSize
    movl $14, %edi                                          # 14 to edi (byte number 14)
    movl buf(,%edi,1), %eax                                 # get value of DIBHeaderSize from file, then save to eax
    movl %eax, DIBHeaderSize                                # save eax to DIBHeaderSize

# get pixelsPerBar
    movl DIBHeaderSize, %eax                                # DIBHeaderSize to eax
    addl $14, %eax                                          # add 14 to eax (header is always 14)
    movl %eax, offset                                       # beginning of pixels

    movl $3, %eax                                           # 3 to eax (3 bytes per color)
    mull sizex                                              # eax = number of bytes per row
    movl %eax, %ecx                                         # eax to ecx
    movl $2, %ebx                                           # 2 to ebx
    movl sizey, %eax                                        # sizey to eax
    divl %ebx                                               # eax over ebx - middle row (number of pixels/2), saved in eax
    mull %ecx                                               # eax times ecx - number of starting byte of middle row

    addl %eax, offset                                       # offset+=eax - total offset

    movl $2, %ebx                                           # 2 to ebx
    movl sizey, %eax                                        # sizey to eax
    divl %ebx                                               # eax over ebx - middle row (number of pixels/2), saved in eax
    mull paddingBytes                                       # eax*=paddingBytes

    addl %eax, offset                                       # offset+=eax
    movl offset, %edi                                       # offset to edi

jump:                                                       # check next pixel
    movl $0, %eax                                           # 0 to eax
    movb buf(,%edi,1), %al                                  # get first byte value of edi from file to al
    mov %al , R                                             # save al to R
    inc %edi                                                # edi++ (adds one byte)
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , G
    inc %edi
    movl $0, %eax
    movb buf(,%edi,1), %al
    mov %al , B
    inc %edi

    movl $0, %eax                                           # 0 to eax
checkR:
    cmpl R, %eax                                            # if R==eax
    je checkG                                               # checkG
    jmp jump                                                # else go to jump
checkG:
    cmpl G, %eax
    je checkB
    jmp jump
checkB:
    cmpl B, %eax                                            # if B==eax
    je countBlackPixels                                     # countBlackPixels
    jmp jump                                                # else go to jump

countBlackPixels:                                           # increases current black pixel count
    movl pixelsPerBar, %eax                                 # pixelsPerBar to eax
    inc %eax                                                # eax++
    movl %eax, pixelsPerBar                                 # eax to pixelsPerBar

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
    jmp next
checkG1:
    cmpl G, %eax
    je checkB1
    jmp next
checkB1:
    cmpl B, %eax
    je countBlackPixels
    jmp next

next:

 # exit(0)
    movl    $1, %eax  
    movl    $0, %ebx   
    int     $0x80     

