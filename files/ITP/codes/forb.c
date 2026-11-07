#include <stdio.h>
#include <math.h>

int expscale(int num) {
    if (num <= 0) return 0;
    int i = 0;
    while (num >= 10) {
        num /= 10;
        i++;
    }
    return i+1;
}

int forbn(int *array, int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) {
        int prod = 1;
        for (int j = 0; j < size; j++) {
            prod *= array[i];
        }
        sum += prod;
    }
    return sum;
}

int main(void){
	int num;
	scanf(" %d",&num);
	int temp = num;
	int n = expscale(num);
	int digs[n];
	for (int i=0;i<n;i++){
		if (i!=n){
		digs[i] = num / ((int)pow(10,n-1-i)) ;
		num=  num % ((int)pow(10,n-1-i)) ;
		}
	}
	for (int i=0;i<n;i++) printf("%d",digs[i]);
	
	printf("\n");

	if (temp == forbn(digs,n)) printf("TRUE \n");
	else printf("FALSE \n");
}
