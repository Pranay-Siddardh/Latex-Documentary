#include <stdio.h>

int main(void){
	int n=0;
	scanf(" %d",&n);

	int nm[2];
	int count=0;

	int num[n-2];

	for(int i=0;i<n-2;i++){
		scanf(" %d",&num[i]); 
	}

	for(int i=1;i<n+1;i++){
		int there =0;

		for(int j=0; j<n;j++){
			if (num[j] == i) there = 1;
		}

		if(!there){
			count++;
			nm[count-1] = i;
		}
	}
	printf("%d %d",nm[0],nm[1]);	
}
