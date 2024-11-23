.section data
    %define CLIENT_T_SIZE 64

extern rand
extern printf

.section text

    ;cliente_t cliente_random(cliente_t* arreglo_clientes, size_t longitud)
    ;params:
    ;--> arreglo_clientes: [rdi]
    ;--> longitud: [rsi]
    select_random_user
        push rbp
        mov rbp, rsp

        ;preservamos registros no volatiles
        push r15
        push r14

        ;copio rdi y rsi a registros no volatiles para no perderlos
        mov r15, rdi
        mov r14, rsi

        ;rand() % longitud
        mov rdi, r14
        call rand
        mov r14, rax

        ;retornamos arreglo_clientes[rand() % longitud]
        mov rax, r15
        mov rdi, r14
        mov rax, [rax + rdi * CLIENT_T_SIZE]

        ;restauramos registros no volatiles
        pop r14
        pop r15

        ;restauramos rbp y retornamos
        pop rbp
        ret