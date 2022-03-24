; Cadeira: Arquitetura de Computadores
; Semestre: 2122sv

; Grupo: 4

; Número    Aluno
; A33312    Nelio Nunes
; A46948    Nuno Brito
; A46950    Nelson Lopes

;----------------------------------------------------------------
;   Respostas
;
;   1b.
;
;   2a.
;   2b.
;
;   3a.
;   3b.
;----------------------------------------------------------------

;----------------------------------------------------------------
;   Defines
;----------------------------------------------------------------
    .equ    ARRAY_SIZE, 12
    .equ    INT8_MAX,   0xFF    ; 255
    .equ    INT16_MIN,  0x8000  ; -32768
    .equ    INT16_MAX,  0x7FFF  ; 32767

;----------------------------------------------------------------
;   Startup
;----------------------------------------------------------------
    .section    startup
    b   _start
    b   .

_start:
    ldr sp, addr_stack
    bl  main
    b   .

addr_stack:
    .word   stack_top

;----------------------------------------------------------------
;   Função: main
;----------------------------------------------------------------
;   int8_t  avg1, avg2;
;
;       void main(void){
;           avg1 = average(array1, ARRAY_SIZE);
;           avg2 = average(array2, ARRAY_SIZE);
;           while(1);
;       }
;----------------------------------------------------------------
;   Registos: r0 - array1, array2 // r1 - ARRAY_SIZE
;             r4 - avg1 // r5 - avg2
;----------------------------------------------------------------
    .text
main:
    push lr

    ldr r0, array1_addr ; Carregar endereço do array1
    mov r1, ARRAY_SIZE
    bl  function_average
    mov r4, r0  ; avg1 = average

    ldr r0, array2_addr ; Carregar endereço do array2
    mov r1, ARRAY_SIZE
    bl  function_average
    mov r5, r0  ; avg2 = average

    b   .   ; // while(1);
    
    pop pc

array1_addr:
    .word   array1
array2_addr:
    .word   array2

;----------------------------------------------------------------
;   Função: average
;----------------------------------------------------------------
;    int8_t average (int8_t a[], uint16_t n){
;        int8_t avg = INT8_MAX;
;        uint16_t uacc, uavg;
;        uint8_t neg;
;
;        int16_t acc = summation(a, n);
;        if(acc != INT16_MAX){
;            if(acc < 0){
;                neg = 1;
;                uacc = - acc;
;            }else{
;                neg = 0;
;                uacc = acc;
;            }
;            uavg = udiv(uacc, n);
;            if (neg == 1){
;                avg = -uavg;
;            }else{
;                avg = uavg;
;            }
;        }
;        return avg;
;    }
;----------------------------------------------------------------
;   Registos: r0 - a[] // r1 - n
;----------------------------------------------------------------
function_average:
    push lr

    pop pc  ; Função não folha

;----------------------------------------------------------------
;   Função: summation
;----------------------------------------------------------------
;    int16_t summation(int8_t a[], uint16_t n){
;        uint8_t error = 0;
;        int16_t acc = 0;
;
;        for(uint16_t i = 0; i < n && error == 0; i++){
;            int16_t e = a[i];
;            if ((e < INT16_MIN - acc) || (e > INT16_MAX - acc)){
;                error = 1;
;            }else{
;                acc = acc + e;
;            }
;        }
;        if ( error == 1 ) {
;            acc = INT16_MAX ;
;        }
;        return acc ;
;    }
;----------------------------------------------------------------
;   Registos: r0 - a[] // r1 - n
;----------------------------------------------------------------
function_summation:

    mov pc, lr  ; Função folha

;----------------------------------------------------------------
;   Função: udiv
;----------------------------------------------------------------
;    uint16_t udiv(uint16_t D, uint16_t d){
;        int32_t q = D;
;        uint32_t shf_d = ((uint32_t) d) << 16;
;
;        for(uint8_t i = 0; i < 16; i++){
;            q <<= 1;
;            q -= shf_d;
;            if(q < 0){
;                q += shf_d;
;            }else{
;                q |= 1;
;            }
;        }
;        return q;
;    }
;----------------------------------------------------------------
;   Registos: r0 - D // r1 - d
;----------------------------------------------------------------
function_udiv:

    mov pc, lr  ; Função folha

;----------------------------------------------------------------
;   Variáveis 
;----------------------------------------------------------------
    .data

array_1:
    .byte   24, 25, 29, 34, 38, 40, 41, 41, 39, 35, 30, 26

array_2:
    .byte   -25, -22, -17, -5, 5, 11, 12, 9, 3, -7, -19, -24

;----------------------------------------------------------------
;   Stack_top 
;----------------------------------------------------------------
    .section    .stack
    .space      1024
stack_top:

;----------------------------------------------------------------
;   Compilar sem erros [LINHA NOVA NO FIM]
;----------------------------------------------------------------

