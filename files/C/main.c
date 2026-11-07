#include <stdio.h>

int main() {
    // Fill adjacent memory with recognizable dummy characters first 
    // so we can see the memory bleed over.
    char padding[10] = "XXXXXXXXXX"; 
    
    // Declare a small array of exactly 5 chars, and DO NOT null-terminate it
    char arr[5];

    // Manually stuff all 5 slots with letters (leaving NO room for '\0')
    scanf(" %5s",arr);

    // DANGER: arr has no '\0'. 
    // printf("%s" will keep reading past index 4 into the padding/stack memory!
    printf("Output without null-terminator: %s\n", arr);

    return 0;
}
