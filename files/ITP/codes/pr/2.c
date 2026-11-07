#include <stdio.h>

int main() {
    int n;
    double d,temp[n];
    scanf(" %d",&n);
    for(int i =0;i<n;i++) scanf(" %lf",&temp[i]);
    scanf(" %lf",&d);
    
    int breaker = -1;
    
    for (int i = 1; i<n;i++){
        if(temp[i]-temp[i-1]>d){ 
		breaker = i+1; 
		break;
	}
    }
    
    printf("%d \n",breaker);
    
    return 0;
}
