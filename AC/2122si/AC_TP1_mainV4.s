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
;  c) O valor -1 é apenas um valor fora do intervalo, desde que tome qualquer valor diferente do intervalo [0, 4] o identificador estaria correto.
; 
; 3.
;  a) Para implementar a constante NVOWEL_IDX podemos definir a variável com uma constante usando o ".equ NVOWEL_IDX,#valor" ou podemos simplesmente declarar a variável na secção data.
;   Usando o ".equ" não existe penalização de memória pelo que todas as instâncias de "NVOWEL_IDX" serão substituídas pelo valor atribuído.
;   Por outro lado, usando a declaração da variável ocuparemos espaço de memória e ainda terá de ser criada uma label com endereço para chamamento da mesma.
; ------------------------

; DEFINES INFORMATION
    .equ    CHAR_a, 'a' ; 0x61
    .equ    CHAR_z, 'z' ; 0x41
    .equ    CHAR_A, 'A' 
    .equ    CHAR_E, 'E' 
    .equ    CHAR_I, 'I' 
    .equ    CHAR_O, 'O' 
    .equ    CHAR_U, 'U' 
    ;.equ    CHAR_Aa, 0xFFE0 ; A-a
    .equ    CHAR_aA, 0x20 ; a-A
    .equ    CHAR_END, 0
    .equ    DIM, 3
    .equ    IDX, 0xFF ; -1
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
;   Registos: r0 = c = uc // r1 = 'a' // r2 = 'z' // r4 = ('a' - 'A')
to_upper:
    mov r1, CHAR_a              ; r1 = 'a'
    mov r2, CHAR_z              ; r2 = 'z'
    mov r3, CHAR_aA             ; r3 = ('a' - 'A')

    if_func_to_upper:
    cmp r0, r1                  ; if c >= 'a'
    blo if_func_to_upper_end
    cmp r0, r2                  ; if c <= 'z'
    bge if_func_to_upper_end
    add r0, r0, r3              ; uc = c + ('A' - 'a') -> ('a' - 'A') segundo a tabela ASCII

    if_func_to_upper_end:

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
;   Registos: r0 = a[i] // r4 = i // r5 = DIM // r6 = a
;   Registos: r1, r2 e r3 não podem ser usados porque serão estragados na função to_upper
test_upper:
    push    lr
    push    r4
    push    r5
    push    r6
    
    mov r4, #0              ; i = 0
    mov r5, DIM             ; r5 = DIM
   
    for_test_upper:
    cmp r4, r5              ; i - DIM
    bge for_test_upper_end  ; i >= DIM
    ldr r6, addr_var_char   ; r2 = a
    ldrb r0, [r6, r4]       ; r0 = a[i]
    bl  to_upper
    add r4, r4, #1          ; i++
    b   for_test_upper

    for_test_upper_end:

    pop r6
    pop r5
    pop r4
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
;   Registos: r0 = c = uc = return idx // r1 = CHAR_x
;   Dado que a função to_upper é chamada no início, não há perigo de usar os registos r1, r2
which_vowel:
    push    lr

    bl  to_upper    ; r0 já contém a letra vinda de outra função

    which_vowel_switch:
    mov r1, CHAR_A
    cmp r0, r1
    beq which_vowel_switch_A

    mov r1, CHAR_E
    cmp r0, r1
    beq which_vowel_switch_E
    
    mov r1, CHAR_I
    cmp r0, r1
    beq which_vowel_switch_I

    mov r1, CHAR_O
    cmp r0, r1
    beq which_vowel_switch_O

    mov r1, CHAR_U
    cmp r0, r1
    beq which_vowel_switch_U

    b   which_vowel_switch_default

    which_vowel_switch_A:
    mov r0, #0
    b   which_vowel_switch_end

    which_vowel_switch_E:
    mov r0, #1
    b   which_vowel_switch_end

    which_vowel_switch_I:
    mov r0, #2
    b   which_vowel_switch_end

    which_vowel_switch_O:
    mov r0, #3
    b   which_vowel_switch_end

    which_vowel_switch_U:
    mov r0, #4
    b   which_vowel_switch_end

    which_vowel_switch_default:
    mov r0, 0xFF ; -1
    movt r0, 0xFF ; -1

    which_vowel_switch_end:
    
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
;   Registos: r0 = r4 = histogram[] // r1 = r5 = str[] // r0 = idx // r6 = i // r7 = '/0' // r8 = temp (-1) // r9 = str[i] // r10 = histogram[value] 
;   Registos: r0, r1, r2, r3 terão de ser salvos porque a função to_upper há-de estragá-los
vowel_histogram:
    push    lr
    push    r4
    push    r5
    push    r6
    push    r7
    push    r8
    push    r9
    push    r10

    mov r4, r0                      ; r4 = histogram[] (histogram_addr)
    mov r5, r1                      ; r5 = str[] (str_addr)
    mov r6, #0                      ; i = 0
    mov r7, CHAR_END                ; r7 = '/0'
    mov r8, 0xFF                    ; temp = -1
    movt r8, 0xFF                   ; temp = -1

    vowel_histogram_while:
    ldr r9, [r5, r6]                ; r9 = str[i]
    cmp r7, CHAR_END                ; Comparar str[i] com '\0'
    beq vowel_histogram_while_end
    mov r0, r9                      ; idx = str[i]
    bl  which_vowel

    vowel_histogram_if:
    cmp r0, r8                      ; Comparar idx com -1
    bne vowel_histogram_if_else
    ldrb r10, [r4, NVOWEL_IDX]      ; Basta ir ao vetor na posição de NVOWEL_IDX que é sempre fixo (not a vowel)
    add r10, r10, #1                ; histogram[NVOWEL_IDX]++
    strb r10, [r4, NVOWEL_IDX]      ; Guardar na memória o valor de r10 em histogram[nvowel_idx]
    b   vowel_histogram_if_end

    vowel_histogram_if_else:
    ldrb r10, [r4, r0]               ; Aqui é necessário ir ao vetor acedendo a cada posição de IDX respetivamente (vowels a,e,i,o,u)
    add r10, r10, #1                 ; histogram[idx]++
    strb r10, [r4, r0]               ; Guardar na memória o valor de r10 em histogram[idx]
    b   vowel_histogram_if_end

    vowel_histogram_if_end:
    add r6, r6, #1                   ; i++
    b   vowel_histogram_while

    vowel_histogram_while_end:

    pop r10
    pop r9
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
    .space   SIZE
histogram2:
    .space   SIZE
histogram3:
    .space   SIZE
histogram4:
    .space   SIZE

    .section    .stack
    .space  1024
stack_top:

