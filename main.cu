#include "hash.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

// #define SEQUENTIAL
// #define DEBUG

// Tesla V100: 84 SMs, each with 64 INT32 cores
#define NUM_BLOCKS 84
#define NUM_THREADS 64
#define OFFSET_STEP ((NUM_BLOCKS) * (NUM_THREADS))

/* Size of each field in input in bytes */
#define TIME_SIZE 4
#define DIGEST_SIZE 32
#define NUSNET_ID_SIZE 8
#define NONCE_SIZE 8

/* STATES */
__managed__ uint64_t offset = 0;
__managed__ uint64_t nonce_found;
__managed__ uint8_t result[DIGEST_SIZE];
__managed__ int is_found = 0;

/* FOR CONSTRUCTING INPUT */
#define NUSNET_ID "E0014691"
__constant__ uint32_t cur_time;
__constant__ uint8_t digest[DIGEST_SIZE];
__constant__ char nusnet_id[NUSNET_ID_SIZE + 1] = NUSNET_ID;
__constant__ uint64_t target; // target value is 64 bit

__device__ void construct_input(uint8_t __restrict__ input[52], uint64_t* __restrict__ nonce)
{
    size_t cur = 0;
    // Fill in the timestamp
    memcpy(input, &cur_time, TIME_SIZE);
    cur += TIME_SIZE;
    // Fill in previous digest
    memcpy((uint8_t*)input + cur, digest, DIGEST_SIZE);
    cur += DIGEST_SIZE;
    // Fill in NUSNET ID
    memcpy((uint8_t*)input + cur, nusnet_id, NUSNET_ID_SIZE);
    cur += NUSNET_ID_SIZE;
    // Fill in nonce
    memcpy((uint8_t*)input + cur, nonce, NONCE_SIZE);
}

__global__ void find_hash()
{
    int prev_is_found;
    uint8_t input[52], hash[32];
    uint64_t to_compare;
    uint64_t nonce = offset + blockIdx.x * NUM_THREADS + threadIdx.x;
    if (is_found) {
        return;
    }
    construct_input(input, &nonce);
    sha256(hash, input, 52);
    memcpy(&to_compare, hash, sizeof(uint64_t));
    if (to_compare < target) {
        // Test-and-set to prevent race condition of multiple writes
        prev_is_found = atomicExch(&is_found, 1);
        if (!prev_is_found) {
            nonce_found = nonce;
            memcpy(result, hash, DIGEST_SIZE);
        }
    }
}

void process_digest(char prev_hash[65], uint8_t digest[DIGEST_SIZE])
{
    int i;
    char cur_byte_string[3];
    // Set last element to null
    cur_byte_string[2] = 0;
    for (i = 0; i < DIGEST_SIZE; i++) {
        cur_byte_string[0] = prev_hash[i * 2];
        cur_byte_string[1] = prev_hash[(i * 2) + 1];
        digest[i] = strtol(cur_byte_string, NULL, 16);
    }
}

void print_digest(uint8_t __restrict__ digest[DIGEST_SIZE])
{
    int i;
    for (i = 0; i < DIGEST_SIZE; i++) {
        printf("%x", digest[i]);
    }
    printf("\n");
}

int main(int argc, char** argv)
{
    char prev_hash[65]; // SHA-256 is 64 chars long
    uint64_t target_local;
    uint32_t cur_time_local = time(NULL);

    scanf("%s", prev_hash);
    scanf("%lu", &target_local);
    process_digest(prev_hash, digest);

    cudaMemcpyToSymbol(cur_time, &cur_time_local, sizeof(uint32_t));
    cudaMemcpyToSymbol(target, &target_local, sizeof(uint64_t));

#ifdef DEBUG
    puts("Input:");
    printf("%s\n", prev_hash);
    printf("%lu\n", target_local);
#endif

    while (!is_found) {
#ifdef DEBUG
        printf("Trying offset %lu\n", offset);
#endif
#ifdef SEQUENTIAL
        find_hash<<<1, 1>>>();
        offset++;
#else
        find_hash<<<NUM_BLOCKS, NUM_THREADS>>>();
        offset += OFFSET_STEP;
#endif
        cudaDeviceSynchronize();
    }

    puts(NUSNET_ID);
    printf("%u\n", cur_time_local);
    printf("%lu\n", nonce_found);
    print_digest(result);
    return 0;
}
