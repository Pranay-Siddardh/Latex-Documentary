#include <stdio.h>

int main(void){
	int num = 0;
	int rot = 0;
	scanf(" %d %d",&num,&rot);

	char array[num+1];

	for (int i =0;i<num;i++){
		array[(i+rot)%num] = i+1+48;
	}
	array[num] = '\0';
	printf("%s \n",array);

}
