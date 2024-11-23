#pragma once
#include <stdbool.h>
#include <stdint.h>

/**
 * Un píxel RGBA.
 *
 * Campos:
 *   - r: La cantidad de rojo en el píxel. Va de 0 a 255.
 *   - g: La cantidad de verde en el píxel. Va de 0 a 255.
 *   - b: La cantidad de azul en el píxel. Va de 0 a 255.
 *   - a: La transparencia del píxel. Va de 0 a 255.
 */
typedef struct rgba_pixfmt {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
} rgba_t;

/**
 * Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2a
 */
extern bool EJERCICIO_2A_HECHO;

/**
 * Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2b
 */
extern bool EJERCICIO_2B_HECHO;

/**
 * Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2c
 */
extern bool EJERCICIO_2C_HECHO;

/**
 * Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
 * provista. La intensidad de contraste a aplicar está dada por el valor de
 * `amount`.
 *
 * Parámetros:
 *   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
 *   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
 *   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
 *   - height: El alto en píxeles de `dst`, `src` y `mask`.
 *   - amount: El nivel de intensidad a aplicar.
 */
void ej2a(
	rgba_t* dst,
	rgba_t* src,
	uint32_t width, uint32_t height,
    uint8_t amount
);

/**
 * Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
 * provista. La intensidad de contraste a aplicar está dada por el valor de
 * `amount`, si el valor de `mask` para un píxel no es 255 entonces no se debe
 * aplicar el filtro en ese píxel.
 *
 * Parámetros:
 *   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
 *   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
 *   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
 *   - height: El alto en píxeles de `dst`, `src` y `mask`.
 *   - amount: El nivel de intensidad a aplicar.
 *   - mask:   Una máscara que regula por cada píxel si el filtro debe o no ser
 *             aplicado. Los valores de esta máscara son siempre 0 o 255.
 */
void ej2b(
	rgba_t* dst,
	rgba_t* src,
	uint32_t width, uint32_t height,
    uint8_t amount,
    uint8_t* mask
);

/**
 * [IMPLEMENTACIÓN OPCIONAL]
 * El enunciado sólo solicita "la idea" de este ejercicio.
 *
 * Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
 * provista. La intensidad de contraste a aplicar está dada por el valor de
 * `control` para cada píxel.
 *
 * Parámetros:
 *   - dst:     La imagen destino. Es RGBA (8 bits sin signo por canal).
 *   - src:     La imagen origen. Es RGBA (8 bits sin signo por canal).
 *   - width:   El ancho en píxeles de `dst`, `src` y `mask`.
 *   - height:  El alto en píxeles de `dst`, `src` y `mask`.
 *   - control: Una imagen que que regula el nivel de intensidad del filtro en
 *              cada píxel. Es en escala de grises a 8 bits por canal.
 */
void ej2c(
	rgba_t* dst,
	rgba_t* src,
	uint32_t width, uint32_t height,
    uint8_t* control
);