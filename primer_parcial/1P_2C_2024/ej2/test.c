#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "ej2.h"

/**
 * Forma de especificarle a `load_image` que no nos importa la cantidad de
 * canales de una imagen.
 */
#define ANY_CHANNEL_COUNT 0
/**
 * Cantidad de canales en una máscara de control
 */
#define MASK_CHANNEL_COUNT 1
/**
 * Cantidad de canales en una imagen RGBA
 */
#define RGBA_CHANNEL_COUNT 4

/**
 * Una imagen.
 *
 * Campos:
 *   - width:                  El ancho de la imagen. Es positivo.
 *   - height:                 El alto de la imagen. Es positivo.
 *   - original_channel_count: La cantidad de canales de la imagen fuente.
 *   - channel_count:          La cantidad de canales (de 8 bits) cargados a
 *                             memoria.
 *   - data:                   Un buffer de (width * height * channel_count)
 *                             bytes que tiene los píxeles de la imagen.
 */
typedef struct img {
	int width;
	int height;
	int original_channel_count;
	int channel_count;
	uint8_t* data;
} img_t;

/**
 * Carga una imagen.
 *
 * Parámetros:
 *   - filepath:         Ruta del sistema de archivos en dónde se encuentra la
 *                       imagen.
 *   - desired_channels: Cantidad de canales a esperar encontrar en la imagen.
 *                       Cero representa _"no sé"_.
 */
static img_t load_image(const char* filepath, int desired_channels) {
	img_t result;
	result.data = stbi_load(
		filepath,
		&result.width,
		&result.height,
		&result.original_channel_count,
		desired_channels
	);
	result.channel_count = desired_channels;
	return result;
}

/**
 * Tamaño máximo soportado para rutas del sistema de archivos
 */
#define MAX_FILEPATH_SIZE 127

/**
 * Cuenta cuántos tests corrieron exitosamente.
 */
uint64_t successful_tests = 0;
/**
 * Cuenta cuántos tests test fallaron.
 */
uint64_t failed_tests = 0;

/**
 * El mensaje [DONE] escrito en verde.
 */
#define DONE "[\033[32;1mDONE\033[0m] "

/**
 * El mensaje [FAIL] escrito en rojo.
 */
#define FAIL "[\033[31;1mFAIL\033[0m] "

/**
 * El mensaje [SKIP] escrito en magenta.
 */
#define SKIP "[\033[95;1mSKIP\033[0m] "

/**
 * Compara un resultado con la imagen esperada. Devuelve `true` si encuentra
 * diferencias.
 *
 * Parámetros:
 *   - name:        Nombre del test.
 *   - buffer:      Resultado a comparar.
 *   - buffer_size: Tamaño en bytes del resultado a comparar.
 */
bool has_differences(const char* filepath, void* buffer, uint64_t buffer_size) {
	bool result = false;
	int tolerance = 1;

	img_t expected = load_image(filepath, ANY_CHANNEL_COUNT);
	uint64_t expected_data_size = expected.width * expected.height * expected.original_channel_count;

	if (buffer_size != expected_data_size) {
		result = true;
	} else {
		rgba_t* expected_img = (rgba_t*) expected.data;
		rgba_t* actual_img = buffer;
		for (int32_t i = 0; i < expected.height * expected.width; i++) {
			bool red_differs   = tolerance < abs(expected_img[i].r - actual_img[i].r);
			bool green_differs = tolerance < abs(expected_img[i].g - actual_img[i].g);
			bool blue_differs  = tolerance < abs(expected_img[i].b - actual_img[i].b);
			bool alpha_differs = tolerance < abs(expected_img[i].a - actual_img[i].a);
			if (red_differs || green_differs || blue_differs || alpha_differs) {
				result = true;
				break;
			}
		}
	}

	stbi_image_free(expected.data);
	return result;
}

/**
 * Corre un test del ejercicio 2.
 *
 * Parámetros:
 *   - filepath_expected: Ruta en dónde se encuentra la imagen de referencia.
 *   - filepath_dst:  Ruta en dónde escribir la imagen resultante.
 *   - filepath_src:  Ruta a la imagen de entrada.
 *   - filepath_mask: Ruta a la máscara de control.
 *   - amount:       Intensidad del filtro.
 */
void do_test_a(
	const char* filepath_expected,
	const char* filepath_dst,
	const char* filepath_src,
	uint8_t amount
) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_2A_HECHO) {
		printf(SKIP "El ejercicio 2A no está hecho aún.\n");
		return;
	}

	img_t src = load_image(filepath_src, RGBA_CHANNEL_COUNT);

	uint32_t width = src.width;
	uint32_t height = src.height;
	uint64_t out_size = width * height * sizeof(rgba_t);
	rgba_t* dst = malloc(out_size);
	ej2a(
		dst,
		(rgba_t*) src.data,
		width, height,
		amount
	);
	stbi_write_png(
		filepath_dst,
		width, height,
		RGBA_CHANNEL_COUNT,
		dst,
		width * sizeof(rgba_t)
	);
	if (has_differences(filepath_expected, dst, out_size)) {
		printf(FAIL "do_test(\"%s\", \"%s\", %d)\n", filepath_dst, filepath_src, amount);
		printf(FAIL "  Se encontraron diferencias:\n");
		printf(FAIL "    Imagen de entrada: %s\n", filepath_src);
		printf(FAIL "    Imagen de salida: %s\n", filepath_dst);
		printf(FAIL "    Imagen de salida esperada: %s\n", filepath_expected);
		printf(FAIL "\n");
		failed_tests++;
	} else {
		printf(DONE "do_test(\"%s\", \"%s\", %d)\n", filepath_dst, filepath_src, amount);
		successful_tests++;
	}

	free(dst);
	stbi_image_free(src.data);
}

/**
 * Corre un test del ejercicio 2.
 *
 * Parámetros:
 *   - filepath_expected: Ruta en dónde se encuentra la imagen de referencia.
 *   - filepath_dst:  Ruta en dónde escribir la imagen resultante.
 *   - filepath_src:  Ruta a la imagen de entrada.
 *   - filepath_mask: Ruta a la máscara de control.
 *   - amopunt:       Intensidad del filtro.
 */
void do_test_b(
	const char* filepath_expected,
	const char* filepath_dst,
	const char* filepath_src,
	const char* filepath_mask,
	uint8_t amount
) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_2B_HECHO) {
		printf(SKIP "El ejercicio 2B no está hecho aún.\n");
		return;
	}

	img_t src = load_image(filepath_src, RGBA_CHANNEL_COUNT);
	img_t mask = load_image(filepath_mask, MASK_CHANNEL_COUNT);

	assert(src.width == mask.width);
	assert(src.height == mask.height);

	uint32_t width = src.width;
	uint32_t height = src.height;
	uint64_t out_size = width * height * sizeof(rgba_t);
	rgba_t* dst = malloc(out_size);
	ej2b(
		dst,
		(rgba_t*) src.data,
		width, height,
		amount,
		mask.data
	);
	stbi_write_png(
		filepath_dst,
		width, height,
		RGBA_CHANNEL_COUNT,
		dst,
		width * sizeof(rgba_t)
	);
	if (has_differences(filepath_expected, dst, out_size)) {
		printf(FAIL "do_test(\"%s\", \"%s\", \"%s\", %d)\n", filepath_dst, filepath_src, filepath_mask, amount);
		printf(FAIL "  Se encontraron diferencias:\n");
		printf(FAIL "    Imagen de entrada: %s\n", filepath_src);
		printf(FAIL "    Máscara de control: %s\n", filepath_mask);
		printf(FAIL "    Imagen de salida: %s\n", filepath_dst);
		printf(FAIL "    Imagen de salida esperada: %s\n", filepath_expected);
		printf(FAIL "\n");
		failed_tests++;
	} else {
		printf(DONE "do_test(\"%s\", \"%s\", \"%s\", %d)\n", filepath_dst, filepath_src, filepath_mask, amount);
		successful_tests++;
	}

	free(dst);
	stbi_image_free(src.data);
	stbi_image_free(mask.data);
}

/**
 * Corre un test del ejercicio 2.
 *
 * Parámetros:
 *   - filepath_expected: Ruta en dónde se encuentra la imagen de referencia.
 *   - filepath_dst:  Ruta en dónde escribir la imagen resultante.
 *   - filepath_src:  Ruta a la imagen de entrada.
 *   - filepath_mask: Ruta a la máscara de control.
 *   - amopunt:       Intensidad del filtro.
 */
void do_test_c(
	const char* filepath_expected,
	const char* filepath_dst,
	const char* filepath_src,
	const char* filepath_mask
) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_2B_HECHO) {
		printf(SKIP "El ejercicio 2C no está hecho aún.\n");
		return;
	}

	img_t src = load_image(filepath_src, RGBA_CHANNEL_COUNT);
	img_t mask = load_image(filepath_mask, MASK_CHANNEL_COUNT);

	assert(src.width == mask.width);
	assert(src.height == mask.height);

	uint32_t width = src.width;
	uint32_t height = src.height;
	uint64_t out_size = width * height * sizeof(rgba_t);
	rgba_t* dst = malloc(out_size);
	ej2c(
		dst,
		(rgba_t*) src.data,
		width, height,
		mask.data
	);
	stbi_write_png(
		filepath_dst,
		width, height,
		RGBA_CHANNEL_COUNT,
		dst,
		width * sizeof(rgba_t)
	);
	if (has_differences(filepath_expected, dst, out_size)) {
		printf(FAIL "do_test(\"%s\", \"%s\", \"%s\")\n", filepath_dst, filepath_src, filepath_mask);
		printf(FAIL "  Se encontraron diferencias:\n");
		printf(FAIL "    Imagen de entrada: %s\n", filepath_src);
		printf(FAIL "    Máscara de control: %s\n", filepath_mask);
		printf(FAIL "    Imagen de salida: %s\n", filepath_dst);
		printf(FAIL "    Imagen de salida esperada: %s\n", filepath_expected);
		printf(FAIL "\n");
		failed_tests++;
	} else {
		printf(DONE "do_test(\"%s\", \"%s\", \"%s\")\n", filepath_dst, filepath_src, filepath_mask);
		successful_tests++;
	}

	free(dst);
	stbi_image_free(src.data);
	stbi_image_free(mask.data);
}

/**
 * Evalúa los tests del ejercicio 2A. Este ejercicio requiere implementar
 * `ej2`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_2A_HECHO`.
 */
void test_ej2a(void) {
}

/**
 * Corre los tests de este ejercicio.
 *
 * Las variables `EJERCICIO_2A_HECHO` y `EJERCICIO_2B_HECHO` controlan qué
 * testsuites se van a correr. Ponerlas como `false` indica que el ejercicio no
 * está implementado y por lo tanto no querés que se corran los tests
 * asociados a él.
 *
 * Recordá que el ejercicio 2A se puede implementar independientemente del 2B.
 *
 * Si algún test falla el programa va a terminar con un código de error.
 */
int main(int argc, char* argv[]) {
	uint64_t failed_at_start;

	/* 2A */
	failed_at_start = failed_tests;
	if (!EJERCICIO_2A_HECHO) {
		printf(SKIP "El ejercicio 2A no está hecho aún.\n");
	} else {
		do_test_a("expected/a-1-calandria-sin-contraste.png",       "outputs/a-1-calandria-sin-contraste.png",       "img/calandria.jpg",   0);
		do_test_a("expected/a-2-carancho-poco-contraste.png",       "outputs/a-2-carancho-poco-contraste.png",       "img/carancho.jpg",   16);
		do_test_a("expected/a-3-chimango-normal.png",               "outputs/a-3-chimango-normal.png",               "img/chimango.jpg",   32);
		do_test_a("expected/a-4-cotorra-bastante-contraste.png",    "outputs/a-4-cotorra-bastante-contraste.png",    "img/cotorra.jpg",    64);
		do_test_a("expected/a-5-dardo-mucho-contraste.png",         "outputs/a-5-dardo-mucho-contraste.png",         "img/dardo.jpg",     160);

		if (failed_at_start < failed_tests) {
			printf(FAIL "El ejercicio 2A tuvo tests que fallaron.\n");
		}
	}

	/* 2B */
	failed_at_start = failed_tests;
	if (!EJERCICIO_2B_HECHO) {
		printf(SKIP "El ejercicio 2B no está hecho aún.\n");
	} else {
		do_test_b("expected/b-1-ganso-mas-contraste.png",           "outputs/b-1-ganso-mas-contraste.png",           "img/ganso.jpg",     "img/mask.png", 64);
		do_test_b("expected/b-2-palomas-menos-contraste.png",       "outputs/b-2-palomas-menos-contraste.png",       "img/palomas.jpg",   "img/mask.png",  8);

		if (failed_at_start < failed_tests) {
			printf(FAIL "El ejercicio 2B tuvo tests que fallaron.\n");
		}
	}

	/* 2C */
	failed_at_start = failed_tests;
	if (!EJERCICIO_2A_HECHO) {
		printf(SKIP "El ejercicio 2C no está hecho aún.\n");
	} else {
		do_test_c("expected/c-1-pirincho-con-mascara-compleja.png", "outputs/c-1-pirincho-con-mascara-compleja.png", "img/pirincho.jpg",  "img/complex-mask.png");

		if (failed_at_start < failed_tests) {
			printf(FAIL "El ejercicio 2C tuvo tests que fallaron.\n");
		}
	}

	printf(
		"\nSe corrieron %ld tests. %ld corrieron exitosamente. %ld fallaron.\n",
		failed_tests + successful_tests, successful_tests, failed_tests
	);

	if (failed_tests) {
		return 1;
	} else {
		return 0;
	}
}
