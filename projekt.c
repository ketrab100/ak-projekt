#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

long reader(char*);
int main()
{
    int fd = 0;
    char name [100];
    printf("Prosze poodac nazwe pliku\n");
    scanf("%s",name);
    fd = open(name,O_RDWR,O_APPEND);
    if (fd == -1)
    {
        printf("Blad otwierania pliku\n");
        return 0;
    }
    char* buf = malloc(30000000);
    read(fd,buf,30000000);
    char* a = buf;
    long result = 0;
    result = reader(a);
    result/=10;
    if (result == 100000000)
    {
        printf("Blad!\n");
    }
    else
    {    
        printf("%ld\n", result);
    }
}