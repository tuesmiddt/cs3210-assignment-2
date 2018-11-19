#ifndef HASH_DEFINED
#define HASH_DEFINED

#include <stddef.h>
#include <stdint.h>

void sha256(uint8_t hash[32], const uint8_t* input, size_t len);

#endif
