#include <stdio.h>

int main (void)
{
    int i = 0;

    int R2 = 5;
    int mem[5] = {5, 4, 3, 2, 1};

    int R0;
    int R1;
    whileLoop:
    
    R0 = 0;
    R1 = 1;
    
    beginLoop:
    if (R1 == R2) goto endLoop; 
    
        if (mem[R0] > mem[R1])
        {
            int R3; 
            R3 = mem[R1];
            mem[R1] = mem[R0];
            mem[R0] = R3;
            goto whileLoop;
        }
        R0++;
        R1++;
    goto beginLoop;
    endLoop:

    for (i = 0; i < 5; i++) {
        printf("Element %d: %d\n", i, mem[i]);
    }

    return 0;
}
