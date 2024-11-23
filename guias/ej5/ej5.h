#include <stdint.h>

typedef struct str_array {
    uint8_t size;
    uint8_t capacity;
    char** data;
} str_array_t;