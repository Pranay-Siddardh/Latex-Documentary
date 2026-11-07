#include <stdio.h>

int max(int a,int b){
    return (a>b)?a :b ;
}

int syscat(int num){
    if (num<130&&num>100) return 0;
    else if (num>129&&num<140) return 1;
    else if (num>139&&num<160) return  2;
    else return 3;
}

int diacat(int num){
    if (num<85&&num>70) return 0;
    else if (num>84&&num<90) return 1;
    else if (num>89&&num<100) return  2;
    else return 3;
}

int main(void) {
    int sbp, dbp;
    int syssev,dissev;
    printf("Two integers:\n");
    scanf(" %d %d",&sbp,&dbp);
    int serious = max(syscat(sbp),diacat(dbp));
    
    if (serious==0) printf("Optimal");
    else if (serious==1) printf("High-normal");
    else if (serious==2) printf("Stage 1 hypertension");
    else if (serious==3) printf("Stage 2 hypertension");
    
    
    return 0;
}
