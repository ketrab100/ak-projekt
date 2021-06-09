#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include<fcntl.h>

long reader(char*);
int main()
{
    int fd = 0;
    char name [] = "/home/bartek/Desktop/ak/ak-projekt/ean-81.bmp";

    fd = open(name,O_RDWR,O_APPEND);
    char* buf = malloc(30000000);
    read(fd,buf,30000000);
    long result = 0;
    result = reader(buf);
    printf("%ld", result);
}