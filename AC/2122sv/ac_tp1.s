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
;   1b. Cada instrução do P16 ocupa 16 bits. A função em questão, está a utilizar 36 instruções logo a quantidade de memória ocupada em bits é dada por:
;		36*16 bits = 576 bits ou 576/8 = 72 bytes.
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
    .equ    INT8_MAX,   0x7F    ; 127       -> int8_t
    .equ    INT16_MIN,  0x8000  ; -32768    -> int16_t
    .equ    INT16_MAX,  0x7FFF  ; 32767     -> int16_t

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
;   Registos: r0 - array1, array2
;             r1 - ARRAY_SIZE
;             r4 - avg1
;             r5 - avg2
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
;                uacc = -acc;
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
;   Registos: r0 - a[]
;             r1 - n
;             r4 - avg
;             r5 - acc
;             r6 - neg
;             r7 - temp
;----------------------------------------------------------------
function_average:
    push lr
    push r4
    mov r8, r1 ; r8 = n -> preservar para a função udiv
    bl  function_summation

    if_function_average_acc:
        

    mov r1, r8 ; restaurar n para r1
    bl  function_udiv
    mov r2, #INT8_MAX



    ldr r7, INT16_MAX_Value_addr
    ldr r7, [r7, #0]


    
    pop pc  ; Função não folha

INT16_MAX_Value_addr:
    .word   INT16_MAX_Value
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
;   Registos: r0 - a[]
;             r1 - n
;             r2 - error
;             r3 - acc
;             r4 - i
;             r5 - e
;             r6 - temp
;----------------------------------------------------------------
function_summation:
	push r4
	push r5
	push r6
    mov r2, #0
    mov r3, #0
    mov r4, #0  ; i = 0

    for_function_summation:
        cmp r4, r1
        bhs for_function_summation_end
        sub r2, r2, #0
        bne for_function_summation_end

        ldrb r5, [r0, r4]   ; e = a[i]
        
        if_function_summation_infor:
            mov r6, #INT16_MIN&0xFF ; Mover a parte baixa do registo - Instrução mov é a 8 bits, é necessário mover a parte baixa e depois a parte alta dado que a constante é a 16 bits.
			mov r6, #INT16_MIN>>8&0xFF ; Mover a parte alta.
            sub r6, r6, r3
            cmp r5, r6
            blt if_function_summation_infor_condtrue    ; Para fazer o OR na função
            mov r6, #INT16_MAX&0xFF ; Igual à linha 187
			mov r6, #INT16_MAX>>8&0xFF ; Igual à linha 188
            sub r6, r6, r3
            cmp r6, r5  ; Trocar os operandos porque não existe menor ou igual no P16
            bhs else_function_summation_infor

            if_function_summation_infor_condtrue:
                mov r2, #1
                b   if_function_summation_infor_end

        else_function_summation_infor:
            add r3, r3, r5
        
        if_function_summation_infor_end:
        add r4, r4, #1
        b   for_function_summation

    for_function_summation_end:
    if_function_summation_err:
       mov  r6, #1
       cmp  r2, r6
       bne  if_function_summation_err_end
       mov  r3, #INT16_MAX&&0xFF ; Igual à linha 187 
	   mov  r3, #INT16_MAX>>8&0xFF ; Igual à linha 188
	   
    if_function_summation_err_end:
    mov r0, r3  ; returning acc
	pop r4
	pop r5
	pop r6
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
;   Registos: r0 - D // r1 - d // r2:r3 - q // r4:r5 - shf_d // r6 - i // r7 - temp // r8 - temp2
;----------------------------------------------------------------
function_udiv:
	push r4
	push r5
	push r6
	push r7
	push r8
	mov r2,r0    ; int32_t q = D;
	mov r4,r1   ; d = d * 16     ; uint32_t shf_d = ((uint32_t) d) << 16
	mov r6,#0
	mov r7,#16
	for_udiv:
		cmp r6,r7 	; i - 16
		bhs for_udiv_end ; i >= 16
		lsl r2,r2,#1 ; q <<= 1 --> q = q * 2 LSL porque não é preciso ter em consideração o sinal
		lsl r3,r3,#1
		mov r8,#0
        adc r3,r3,r8 ; 
		sub r2,r2,r4 ; q = q - shf_d
		if_udiv:
			mov r7,#0 
			cmp r2,r7 ; q - 0
			bhs else_udiv  ; q >= 0
			add r2,r2,r4 ; q = q + shf_d
		else_udiv: 
			orr r2,r2,#1 ; q |= 1
		if_udiv_end:
		add r6,r6,#1 ; i++
		b for_udiv
	for_udiv_end:
	mov r0,r2    ; return q
	mov r1,r3	
	pop r4
	pop r5
	pop r6
	pop r7
	pop r8
	mov pc, lr  ; Função folha

;----------------------------------------------------------------
;   Variáveis 
;----------------------------------------------------------------
    .data

array_1:
    .byte   24, 25, 29, 34, 38, 40, 41, 41, 39, 35, 30, 26

array_2:
    .byte   -25, -22, -17, -5, 5, 11, 12, 9, 3, -7, -19, -24

INT16_MAX_Value:
    .word   INT16_MAX

;----------------------------------------------------------------
;   Stack_top 
;----------------------------------------------------------------
    .section    .stack
    .space      1024
stack_top:

;----------------------------------------------------------------
;   Compilar sem erros [LINHA NOVA NO FIM]
;----------------------------------------------------------------

