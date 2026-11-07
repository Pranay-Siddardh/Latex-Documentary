#include <stdio.h>

double func(double inp,int terms){
	double sum = 0;
	for (int i=1;i<terms+1;i++){
		double prodt = -1;
		for(int j=0;j<i;j++){
			prodt*=-inp;
		}
		prodt/=i;
		sum+=prodt;
	}


	return sum;
}

int main(void){	
	double input;
	int ter;
	scanf(" %lf %d",&input,&ter);
	printf("%.4lf\n",func(input,ter));
	return 0;
}
