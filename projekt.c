#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

extern long reader(char*);
int main()
{
    int fd = 0;
    char name [] = "/home/bartek/Desktop/ak/ak-projekt/ean-81.bmp";

    fd = open(name,O_RDWR,O_APPEND);
    char* buf = malloc(30000000);
    read(fd,buf,30000000);
    long a;
    a = reader(buf);

    if (a == 3125687201)
    {
        printf("lala");
    }
    write(STDERR_FILENO,&a,sizeof(a)-1);
    free(buf);
    return 0;
}