#include <stdio.h>
#include <math.h>

double norm(double pcur[2],double pnew[2]){
	double expr = pow(pnew[1]-pcur[1],2) + pow(pnew[0]-pcur[0],2);
	return pow(expr,0.5);
}

void changec(double *oldc,double *newc){
	oldc[0] = newc[0];
	oldc[1] = newc[1];
}

int main(void){
	int n;
	double old[2] = {0};
	double new[2] = {0};
	double distance = 0;
	
	printf("Enter The Value of n: ");
	scanf(" %d",&n);

	double c1[2],c2[2];

	//Rides scan in the lop itself? that is better
	//Follow the below loop

	//Norm cheker and coordinate ande distance updater in a loop
	for(int i=0;i<n;i++){
		changec(old,new);
		scanf(" %lf %lf %lf %lf",&c1[0],&c1[1],&c2[0],&c2[1]);
		if(norm(c1,old)<1){
			new[0] = c2[0];
			new[1] = c2[1];
			distance+=(norm(c1,old)+norm(c2,c1));
		}
		else{
			if (i==0){
				new[0] = c2[0];
				new[1] = c2[1];
				distance+=(norm(c1,old)+norm(c2,c1));
}
		}
	}

	printf("The Distance is %.2lf units.",distance);

	return 0;
}
