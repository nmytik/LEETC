; ------------------------
; Trabalho prático 1
; Grupo: 12
; Alunos:
;   A46948 - Nuno Brito
;   A48863 - Rafael Romão
;   A47272 - João Brito
; ------------------------

; ------------------------
; Respostas
; 1.
;  a) Para implementar a variável UC, o registo R1 é o mais indicado. Usar registos de R4 a R12 é necessário recorrer à pilha, gastando memória desnecessariamente.
;  c) Cada instrução do P16 ocupa 16 bits. A função, implementada da maneira que está, usa 14 instruções, ou seja, 224 bits. São 28 bytes ocupados.
; 
; 2.
;  a) A afirmação é verdadeira pois apenas precisamos de recorrer à pilha se usarmos registos para além do R3 (R4 a R12).
;  c) TODO
; 
; 3.
;  a) Para implementar a constante NVOWEL_IDX podemos definir a variável com uma constante usando o ".equ NVOWEL_IDX,#valor" ou podemos simplesmente declarar a variável na secção data.
;   Usando o ".equ" não existe penalização de memória pelo que todas as instâncias de "NVOWEL_IDX" serão substituídas pelo valor atribuído.
;   Por outro lado, usando a declaração da variável ocuparemos espaço de memória e ainda terá de ser criada uma label com endereço para chamamento da mesma.
; ------------------------

; DEFINES INFORMATION
    .equ    CHAR_a, 'a' ; 0x0061
    .equ    CHAR_z, 'z' ; 0x0041
    .equ    CHAR_A, 'A' 
    .equ    CHAR_E, 'E' 
    .equ    CHAR_I, 'I' 
    .equ    CHAR_O, 'O' 
    .equ    CHAR_U, 'U' 
    .equ    CHAR_Aa, 0xFFE0 ; A-a
    .equ    CHAR_aA, 0x0020 ; a-A
    .equ    CHAR_END, 0
    .equ    DIM, 3
    .equ    IDX, -1
    .equ    NVOWEL_IDX, 5
    .equ    SIZE, 6

; SECTION STARTUP    
    .section startup
        b   _start
        b   .

_start:
    ldr sp, addr_stack
    bl  main
    b   .

addr_stack:
    .word stack_top

; MAIN PROGRAM
    .text
main:
    push lr
    
    ;vowel_histogram (histogram1, text1);
    ldr r0, histogram1_address
    ldr r1, text1_address
    bl  vowel_histogram
    
    ;vowel_histogram (histogram2, text2);
    ldr r0, histogram2_address
    ldr r1, text1_address
    bl  vowel_histogram

    ;vowel_histogram (histogram3, text3);
    ldr r0, histogram3_address
    ldr r1, text1_address
    bl  vowel_histogram

    ;vowel_histogram (histogram4, text4);
    ldr r0, histogram4_address
    ldr r1, text1_address
    bl  vowel_histogram

    pop pc  

histogram1_address:
    .word   histogram1
histogram2_address:
    .word   histogram2
histogram3_address:
    .word   histogram3
histogram4_address:
    .word   histogram4

text1_address:
    .word   text1
text2_address:
    .word   text2
text3_address:
    .word   text3
text4_address:
    .word   text4


; Função to_upper
; char to_upper (char c){
;     char uc = c;
;     if (c >= 'a' && c <= 'z'){
;         uc = c + ('A' - 'a');
;     }
;     return uc;
; }
;   Registos: r0 = c // r1 = uc // r0 = return uc // r2 = 'a' // r3 = 'z' // r4 = 'A'
to_upper:
    push    r4

    mov r1, r0       ; uc = c
    mov r2, CHAR_a   ; r4 = 'a'
    mov r3, CHAR_z   ; r3 = 'z'
    mov r4, CHAR_A   ; rj = 'A'

    ; chars -> uint
    if_func_to_upper:
    cmp r0, r2       ; if c >= 'a'
    blo if_func_to_upper_end
    cmp r0, r3       ; if c <= 'z'
    bge if_func_to_upper_end
    sub r1, r4, r2   ; 'A' - 'a'
    add r1, r1, r0   ; uc = c + ('A' - 'a')

    if_func_to_upper_end:
    mov r0, r1       ; return uc

    pop r4
    mov pc, lr

; Permite testar a função to_upper.
; Testes a realizar:
;    - Letra minúscula
;    - Letra maíuscula
;    - Número
;char test_upper{
;    for (i=0, i<DIM, i++) {
;        to_upper (a[i]);
;    }
;}
;   Registos: r0 = a[i] // r1 = i // r2 = a
test_upper:
    push    lr
    
    mov r1, #0             ; i = 0
   
    for_test_upper:
    cmp r1, r2              ; i - DIM
    bge for_test_upper_end  ; i >= DIM
    ldr r2, addr_var_char   ; r2 = a
    ldrb r0, [r2, r1]       ; r0 = a[i]
    bl  to_upper
    add r1, r1, #1          ; i++
    b   for_test_upper

    for_test_upper_end:

    pop pc

addr_var_char:
    .word   var_char

; Função which_vowel
;int8_t which_vowel (char c){
;    int8_t idx;
;    char uc = to_upper (c);
;    switch (uc){
;        case 'A': idx=0; break;
;        case 'E': idx=1; break;
;        case 'I': idx=2; break;
;        case 'O': idx=3; break;
;        case 'U': idx=4; break;
;        default: idx = -1;
;    }
;    return idx;
;}
;   Registos: r0 = c // r1 = idx // r0 = return idx // r2 = uc // r3 = CHAR_x
which_vowel:
    push    lr

    bl  to_upper    ; r0 já contém a letra vinda do main
    mov r1, IDX     ; r1 = IDX (-1)
    mov r2, r0      ; uc = to_upper(c)

    which_vowel_switch:
    mov r3, CHAR_A
    cmp r2, r3
    beq which_vowel_switch_A

    mov r3, CHAR_E
    cmp r2, r3
    beq which_vowel_switch_E
    
    mov r3, CHAR_I
    cmp r2, r3
    beq which_vowel_switch_I

    mov r3, CHAR_O
    cmp r2, r3
    beq which_vowel_switch_O

    mov r3, CHAR_U
    cmp r2, r3
    beq which_vowel_switch_U

    b   which_vowel_switch_default

    which_vowel_switch_A:
    mov r1, #0
    b   which_vowel_switch_end

    which_vowel_switch_E:
    mov r1, #1
    b   which_vowel_switch_end

    which_vowel_switch_I:
    mov r1, #2
    b   which_vowel_switch_end

    which_vowel_switch_O:
    mov r1, #3
    b   which_vowel_switch_end

    which_vowel_switch_U:
    mov r1, #4
    b   which_vowel_switch_end

    which_vowel_switch_default:
    mov r1, #-1

    which_vowel_switch_end:
    mov r0, r1
    
    pop pc

; Função vowel_histogram
;#define NVOWEL_IDX 5
;
;void vowel_histogram(uint16_t histogram[], char str[]){
;    uint16_t i = 0;
;    int8_t idx;
;    while (str[i] != '\0'){
;        idx = which_vowel (str[i]);
;        if (idx == -1){
;            histogram[NVOWEL_IDX]++;
;        }else{
;            histogram[idx]++;
;        }
;        i++;
;    }
;}
;   Registos: r0 = histogram[] original // r1 = str[] original // r1 = histogram[] // r2 = str[] // r3 = i // r4 = idx // r5 = str[i] // r6 = histogram[val] // r7 = '/0' // r8 = temp
vowel_histogram:
    push    lr
    push    r4
    push    r5
    push    r6
    push    r7
    push    r8

    mov r2, r1                      ; r2 = str_addr
    mov r1, r0                      ; r1 = histogram_addr (teremos de usar r0 como argumento para a função which_vowel)
    mov r7, CHAR_END 
    mov r8, #-1

    mov r3, #0                      ; i = 0
    mov r4, IDX                     ; r4 = idx

    vowel_histogram_while:
    ldr r5, [r2, r3]                ; r5 = str[i]
    cmp r5, CHAR_END
    beq vowel_histogram_while_end
    mov r0, r5                      ; r0 = str[i]
    bl  which_vowel
    mov r4,r0                       ; idx = which_vowel (str[i])

    vowel_histogram_if:
    cmp r4, r8
    bne vowel_histogram_if_else
    ldrb r6, [r1, #NVOWEL_IDX]      ; Basta ir ao vetor na posição de NVOWEL_IDX que é sempre fixo (not a vowel)
    add r6, r6, #1                  ; histogram[NVOWEL_IDX]++
    strb r6, [r1, #NVOWEL_IDX]      ; Guardar na memória o valor de r6 em histogram[nvowel_idx]
    b   vowel_histogram_if_end

    vowel_histogram_if_else:
    ldrb r6, [r1, r4]               ; Aqui é necessário ir ao vetor acedendo a cada posição de IDX respetivamente (vowels a,e,i,o,u)
    add r6, r6, #1                  ; histogram[idx]++
    strb r6, [r1, r4]               ; Guardar na memória o valor de r6 em histogram[idx]
    b   vowel_histogram_if_end

    vowel_histogram_if_end:
    add r3, r3, #1                  ; i++
    b   vowel_histogram_while

    vowel_histogram_while_end:

    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop pc

; DATA INFORMATION
    .data
var_char:
    .ascii  "b","B","1"
text1:
    .asciz  "aeiou"
text2:
    .asciz  "a eE iIi oOoO uUuUu"
text3:
    .asciz  "Hello World, 2021!"
text4:
    .asciz  "The quick brown fox jumps over the lazy dog "
histogram1:
    .byte   SIZE
histogram2:
    .byte   SIZE
histogram3:
    .byte   SIZE
histogram4:
    .byte   SIZE

    .section    .stack
    .space  1024
stack_top:

