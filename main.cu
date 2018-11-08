#include "hash.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

// #define SEQUENTIAL
#define DEBUG

// Tesla V100: 84 SMs, each with 64 INT32 cores
#define NUM_BLOCKS 84
#define NUM_THREADS 64

__managed__ int result;
__managed__ bool is_found = false;

__global__ void find_hash()
{
    if (is_found) {
        return;
    }
}

int main(int argc, char** argv)
{
    char prev_hash[65]; // SHA-256 is 64 chars long
    uint64_t target; // target value is 64 bit
    scanf("%s", prev_hash);
    scanf("%lu", &target);

#ifdef DEBUG
    puts("Input:");
    printf("%s\n", prev_hash);
    printf("%lu\n", target);
#endif

#ifdef SEQUENTIAL
    find_hash<<<1, 1>>>();
#else
    find_hash<<<NUM_BLOCKS, NUM_THREADS>>>();
#endif
    return 0;
}
