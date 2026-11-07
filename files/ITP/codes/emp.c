#include <stdio.h>

void expon(unsigned long int *num, int powe){
	unsigned long int temp = *num;
	for(int i=1;i<powe;i++){
		*num *= temp;
	}
}

int main(void){
	unsigned long int numb = 2;
	expon(&numb,49);
	unsigned long int exp = numb -1;
	unsigned long int gran = 0;
	scanf(" %lu",&gran);

	if(gran<exp){
		printf("NO \n");
	}
	else{
		printf("YES \n");
		printf("%lu\n",gran-exp);
	}
}
