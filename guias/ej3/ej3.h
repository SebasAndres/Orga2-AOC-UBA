#include <stdint.h>

#define NAME_LEN 21

typedef struct cliente_str {
    char nombre[NAME_LEN];   //21B
    char apellido[NAME_LEN]; // 21B
    uint64_t compra;         // 8B
    uint32_t dni;            // 4B
} cliente_t;

typedef struct __attribute__((__packed__)) packed_cliente_str {
    char nombre[NAME_LEN]; // 21B
    char apellido[NAME_LEN]; // 21B
    uint64_t compra; // 
    uint32_t dni;
} __attribute__((packed)) packed_cliente_t;