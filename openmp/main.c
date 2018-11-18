#include "hash.h"
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* Magical endian switching macros */
#define BSWAP32(val) (((((val) >> 24) & 0xFF)) | ((((val) >> 16) & 0xFF) << 8) | ((((val) >> 8) & 0xFF) << 16) | (((val)&0xFF) << 24))
#define BSWAP64(val) (((((val) >> 56) & 0xFF)) | ((((val) >> 48) & 0xFF) << 8) | ((((val) >> 40) & 0xFF) << 16) | ((((val) >> 32) & 0xFF) << 24) | ((((val) >> 24) & 0xFF) << 32) | ((((val) >> 16) & 0xFF) << 40) | ((((val) >> 8) & 0xFF) << 48) | ((((val)) & 0xFF) << 56))

// #define DEBUG
// #define VERBOSE

/* Size of each field in input in bytes */
#define TIME_SIZE 4
#define DIGEST_SIZE 32
#define NUSNET_ID_SIZE 8
#define NONCE_SIZE 8

/* STATES */
uint64_t nonce_found;
uint8_t result[DIGEST_SIZE];
volatile int is_found = 0;
int num_threads;

/* FOR CONSTRUCTING INPUT */
#define NUSNET_ID "E0014691"
uint32_t cur_time_be;
uint8_t digest[DIGEST_SIZE];
char nusnet_id[NUSNET_ID_SIZE + 1] = NUSNET_ID;
uint64_t target; // target value is 64 bit

void construct_input(uint8_t input[52], uint64_t nonce)
{
    size_t cur = 0;
    uint64_t nonce_be = BSWAP64(nonce);

    // Fill in the timestamp
    memcpy(input, &cur_time_be, TIME_SIZE);
    cur += TIME_SIZE;
    // Fill in previous digest
    memcpy((uint8_t*)input + cur, digest, DIGEST_SIZE);
    cur += DIGEST_SIZE;
    // Fill in NUSNET ID
    memcpy((uint8_t*)input + cur, nusnet_id, NUSNET_ID_SIZE);
    cur += NUSNET_ID_SIZE;
    // Fill in nonce
    memcpy((uint8_t*)input + cur, &nonce_be, NONCE_SIZE);
}

void update_input(uint8_t input[52], uint64_t nonce)
{
    size_t cur = TIME_SIZE + DIGEST_SIZE + NUSNET_ID_SIZE;
    uint64_t nonce_be = BSWAP64(nonce);
    memcpy((uint8_t*)input + cur, &nonce_be, NONCE_SIZE);
}

void find_hash()
{
    uint8_t input[52], hash[52];
    uint64_t to_compare;
    uint64_t nonce;
#pragma omp parallel private(input, hash, to_compare, nonce)
    {
        nonce = omp_get_thread_num();
        construct_input(input, nonce);
        while (!is_found) {
            sha256(hash, input, 52);
            memcpy(&to_compare, hash, sizeof(uint64_t));
            if (to_compare < target) {
#pragma omp critical
                {
                    if (!is_found) {
                        is_found = 1;
                        nonce_found = nonce;
                        memcpy(result, hash, DIGEST_SIZE);
                    }
                }
            }
            nonce += num_threads;
            update_input(input, nonce);
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

void print_digest(uint8_t digest[DIGEST_SIZE])
{
    int i;
    for (i = 0; i < DIGEST_SIZE; i++) {
        printf("%02x", digest[i]);
    }
    printf("\n");
}

int main(int argc, char** argv)
{
    char prev_hash[65]; // SHA-256 is 64 chars long
    uint32_t cur_time = time(NULL);

    if (argc != 2) {
        printf("Usage:\n%s num_threads", argv[0]);
        return 1;
    }

    num_threads = atoi(argv[1]);
    omp_set_dynamic(0);
    omp_set_num_threads(num_threads);

    cur_time_be = BSWAP32(cur_time);

    scanf("%s", prev_hash);
    scanf("%llu", &target);
    process_digest(prev_hash, digest);

#ifdef DEBUG
    puts("Input:");
    printf("%s\n", prev_hash);
    printf("%llu\n", target);
#endif

    find_hash();

    puts(NUSNET_ID);
    printf("%u\n", cur_time);
    printf("%llu\n", nonce_found);
    print_digest(result);
    return 0;
}
