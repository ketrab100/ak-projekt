#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include<fcntl.h>

long reader(char*);
int main()
{
    int fd = 0;
    char name [] = "/home/bartek/Desktop/ak/ak-projekt/ean85.bmp";

    fd = open(name,O_RDWR,O_APPEND);
    char* buf = malloc(30000000);
    read(fd,buf,30000000);
    char* a = buf;
    long result = 0;
    result = reader(a);
    result/=10;
    printf("%ld", result);
}