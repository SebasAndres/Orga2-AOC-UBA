.section data
    %define SIZE_OF_STR_ARRAY_T 16
    %define STR_ARRAY_T_SIZE 0
    %define STR_ARRAY_T_CAPACITY 4
    %define STR_ARRAY_T_DATA 8
    %define SIZE_POINTER 8

.section text 

    ;str_array_t* strArrayNew(uint8_t capacity)
    ;Crea un array de strings nuevo con capacidad indicada por capacity.
    ;params:
    ;   rdi: uint8_t capacity
    strArrayNew:
        ;prologo
        push rbp
        mov rbp, rsp

        ;preservamos registros no volatiles
        push r14   ; desalineado
        push r13 ; alineado

        ;copio rdi a registros no volatiles para no perderlo
        mov r14, rdi

        ;pedimos memoria para data
        ;data = malloc(capacity * SIZE_POINTER)
        mov rax, SIZE_POINTER
        mul r14
        mov rdi, rax
        call malloc
        mov r13, rax

        ;pedimos memoria para el struct
        ;res = malloc(SIZE_OF_STR_ARRAY_T)
        mov rdi, SIZE_OF_STR_ARRAY_T
        call malloc

        ;inicializamos el struct
        mov byte [rax+STR_ARRAY_T_SIZE], 0 ;res->size = 0
        mov [rax+STR_ARRAY_T_CAPACITY], r14 ;res->capacity = capacity
        mov [rax+STR_ARRAY_T_DATA], r13 ;res->data = data

        ;restauramos los registros
        pop r13
        pop r14
        pop rbp

        ;fin
        ret

    ;uint8_t strArrayGetSize(str_array_t* a)
    ;Obtiene la cantidad de elementos ocupados del arreglo
    ;params:
    ;   rdi: str_array_t* a
    strArrayGetSize:
        push rbp
        mov rbp, rsp

        xor rax, rax
        mov byte al, [rdi+STR_ARRAY_T_SIZE]

        pop rbp
        ret

    ;char* strArrayGet(str_array_t* a, uint8_t i)
    ;Obtiene el i-esimo elemento del arreglo, si i se encuentra fuera de rango, retorna NULL.
    ;params:
    ;   rdi: str_array_t* a
    ;   rsi: uint8_t i
    strArrayGet:
        push rbp
        mov rbp, rsp

        ;if (i > a->size) return NULL
        cmp rsi, [rdi+STR_ARRAY_T_SIZE]
        ja .out_of_range
        
        ;res = a->data[i]
        mov rax, [rdi+STR_ARRAY_T_DATA+rsi*SIZE_POINTER]        

        .out_of_range:
            mov rax, 0
            jmp .end

        .end:
            pop rbp
            ret

    ;char* strArrayRemove(str_array_t* a, uint8_t i)
    ;Quita el i-esimo elemento del arreglo, si i se encuentra fuera de rango, retorna NULL.
    ;El arreglo es reacomodado de forma que ese elemento indicado sea quitado y retornado.
    ;params:
    ;   rdi: str_array_t* a
    ;   rsi: uint8_t i
    strArrayRemove:
        push rbp
        mov rbp, rsp

        ;if (i > a->size) return NULL
        cmp rsi, [rdi+STR_ARRAY_T_SIZE]
        ja .out_of_range

        ;res = a->data[i]
        mov rax, [rdi+STR_ARRAY_T_DATA+rsi*SIZE_POINTER]

        ;a->size--
        dec byte [rdi+STR_ARRAY_T_SIZE]

        ;a->data[i] = a->data[a->size]
        mov rdx, [rdi+STR_ARRAY_T_SIZE]
        mov rax, [rdi+STR_ARRAY_T_DATA+rdx*SIZE_POINTER]
        mov [rdi+STR_ARRAY_T_DATA+rsi*SIZE_POINTER], rax

        ;a->data[a->size] = NULL
        mov qword [rdi+STR_ARRAY_T_DATA+rdx*SIZE_POINTER], 0

        .out_of_range:
            jmp .end

        .end:
            pop rbp
            ret