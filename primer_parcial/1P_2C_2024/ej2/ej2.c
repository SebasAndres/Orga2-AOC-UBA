#include "ej2.h"

/**
 * Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2a
 */
bool EJERCICIO_2A_HECHO = false;

/**
 * Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2b
 */
bool EJERCICIO_2B_HECHO = false;

/**
 * Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej2c
 */
bool EJERCICIO_2C_HECHO = false;

/**
 * [RECOMENDACIÓN]
 * Implementar esta función y reusarla en las versiones en C del ej2.
 * IMPLEMENTAR EL EJ2 EN C ES OPCIONAL.
 *
 * Dada la intensidad de un canal (R/G/B) aplica un ajuste de contraste de
 * acuerdo a `amount`.
 *
 * El valor resultado es `(v - 128) * amount / 32 + 128` saturado (es decir:
 * 0 para resultados menores 0 y 255 para resultados mayores 255).
 *
 * NOTA: Los resultados intermedios pueden ocupar más de un byte, se debe
 * considerar esto para evitar problemas de precisión.
 *
 * Parámetros:
 *   - v:      El valor al que aplicarle la corrección
 *   - amount: La cantidad de contraste que corresponde aplicarle
 */
uint8_t aplicar_contraste(uint8_t v, uint8_t amount) {
}

/**
 * OPCIONAL: implementar en C
 *
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
) {
}

/**
 * OPCIONAL: implementar en C
 *
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
) {
}

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
) {
}
