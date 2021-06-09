#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include<fcntl.h>

int reader(char*);
int main()
{
    int fd = 0;
    char name [] = "/home/bartek/Desktop/ak/ak-projekt/ean-81.bmp";

    fd = open(name,O_RDWR,O_APPEND);
    char* buf = malloc(30000000);
    read(fd,buf,0x86);
    int result;
    result = reader(buf);
    printf("%d", result);
}