#include<stdio.h>
#include<time.h>
#include<signal.h>

// found it here: http://cc.byexamples.com/2007/05/25/nanosleep-is-better-than-sleep-and-usleep/
 
void sigfunc(int sig_no)
{
 
}
 
int __nsleep(const struct timespec *req, struct timespec *rem)
{
    struct timespec temp_rem;
    if(nanosleep(req,rem)==-1)
        __nsleep(rem,&temp_rem);
    else
        return 1;
}
 
int msleep(unsigned long milisec)
{
    struct timespec req={0},rem={0};
    time_t sec=(int)(milisec/1000);
    milisec=milisec-(sec*1000);
    req.tv_sec=sec;
    req.tv_nsec=milisec*1000000L;
    __nsleep(&req,&rem);
    return 1;
}
 
int main()
{
    struct sigaction sa={0};
    sa.sa_handler=&sigfunc;
    sigaction(SIGINT, &sa,NULL);
 
    int a=0;
    scanf("%d",&a);
 
    for (;;)
    {
        printf("testing...\n");
        if (a==1)
            msleep(1000);
        else
            usleep(1000000);
    }
    return 1;
}