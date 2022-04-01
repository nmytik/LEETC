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
;   2a. INT16_MIN e INT16_MAX são variáveis a 16 bits com sinal, portanto os seus valores mínimos e máximo são dados por, respetivamente, -32768 e 32767.
;   2b. Existem duas formas de maneira a que os seus valores sejam facilmente editáveis, por definção em .equ e por declaração de valor em memória.
;       Ambos os métodos recorrem ao mesmo número de ciclos de processamento para registar os valores, embora pelo método de definção por .equ seja mais
; rápido que recorrer à memória tendo em conta a velocidade de acesso dos registos é superior. No caso deste programa optou-se por legibilidade do código
; dado que apesar de usarem a mesma quantidade ciclos de processamento, apenas são precisas duas linhas de código para o acesso à memória.
;
;   3a. É sempre preferível usar um registo que não recorra ao stack de forma a melhor o desempenho. Neste programa e dependendo do sítio onde é atribuído
; o registo avg, é possível fazer com os dois registos. Se a implementação do código em assembly for traduzido literalmente do troço de código em C, será
; melhor atribuir avg ao registo R5 porque logo de seguida é chamada uma função que poderá estragar R2. Por outro lado, se atribuirmos a variável avg a R2
; antes da linha 30 do código, então será possível usar esse registo sem qualquer preocupação dado que não há nenhum chamemento de função até ao fim da
; função average.
;   3b. INT8_MAX é uma variável a 8 bits com sinal e por isso o seu valor máximo é de 127.
;----------------------------------------------------------------

;----------------------------------------------------------------
;   Defines
;----------------------------------------------------------------
    .equ    ARRAY_SIZE, 12
    .equ    INT8_MAX,   0x7F    ; 127       -> int8_t
    .equ    INT16_MIN,  0x8000  ; -32768    -> int16_t
    .equ    INT16_MAX,  0x7FFF  ; 32767     -> int16_t
    .equ    INDEX_0             ; Posição 0 do array (usado no LDR do INT16)

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
;             r4 - avg1, array2
;----------------------------------------------------------------
;   Situação: Resolvido
;----------------------------------------------------------------
    .section    text
main:
    push lr
    push r4

    ; avg1 = average e guardar valor na memória
    ldr r0, array1_addr         ; Carregar endereço do array1
    mov r1, ARRAY_SIZE
    bl  function_average
    mov r4, r0                  ; avg1 = average
    ldr r0, avg1_addr
    strb r4, [r0, #INDEX_0]

    ; avg2 = average e guardar valor na memória
    ldr r0, array2_addr         ; Carregar endereço do array2
    mov r1, ARRAY_SIZE
    bl  function_average
    mov r4, r0                  ; avg2 = average
    ldr r0, avg2_addr
    strb  r4, [r0, #INDEX_0]

    b   .                       ; // while(1);
    
    pop r4
    pop pc

array1_addr:
    .word   array1
array2_addr:
    .word   array2
avg1_addr:
    .word   avg1
avg2_addr:
    .word   avg2

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

    ; INT16_MAX_Value_addr colocado mais abaixo, usado também na função summation

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
;   Situação: Resolvido
;----------------------------------------------------------------
function_summation:
	push r4
	push r5
	push r6

    mov r2, #0                                          ; error = 0
    mov r3, #0                                          ; acc = 0
    mov r4, #0                                          ; i = 0

    for_function_summation:
        cmp r4, r1
        bhs for_function_summation_end
        sub r2, r2, #0
        bne for_function_summation_end

        ldrb r5, [r0, r4]                               ; e = a[i]
        
        if_function_summation_infor:
            ldr r6, INT16_MAX_Value_addr                ; Carregar valor de 16 para um registo
            ldr r6, [r6, #INDEX_0]
                                                        ; Alternativa:
                                                        ; mov r6, #INT16_MIN&0xFF    ; Mover parte baixa.
			                                            ; mov r6, #INT16_MIN>>8&0xFF ; Mover parte alta.
            sub r6, r6, r3                              ; INT16 - acc
            cmp r5, r6
            blt if_function_summation_infor_condtrue    ; Para fazer o OR na função
            ldr r6, INT16_MAX_Value_addr
            ldr r6, [r6, #INDEX_0]
            sub r6, r6, r3
            cmp r6, r5                                  ; Trocar os operandos porque não existe <= no P16
            bhs else_function_summation_infor

            if_function_summation_infor_condtrue:
                mov r2, #1                              ; error = 1
                b   if_function_summation_infor_end

        else_function_summation_infor:
            add r3, r3, r5                              ; acc = acc + e
        
        if_function_summation_infor_end:
        add r4, r4, #1                                  ; i++
        b   for_function_summation

    for_function_summation_end:
    if_function_summation_err:
       mov  r6, #1
       cmp  r2, r6
       bne  if_function_summation_err_end
       ldr  r6, INT16_MAX_Value_addr
       ldr  r3, [r6, #INDEX_0]
	   
    if_function_summation_err_end:
    mov r0, r3                                          ; Retornar acc

	pop r4
	pop r5
	pop r6
    mov pc, lr  ; Função folha

INT16_MAX_Value_addr:
    .word   INT16_MAX_Value

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
;   Variáveis Definidas
;----------------------------------------------------------------
    .section    data

array_1:
    .byte   24, 25, 29, 34, 38, 40, 41, 41, 39, 35, 30, 26

array_2:
    .byte   -25, -22, -17, -5, 5, 11, 12, 9, 3, -7, -19, -24

INT16_MIN_Value:
    .word   INT16_MIN

INT16_MAX_Value:
    .word   INT16_MAX

;----------------------------------------------------------------
;   Variáveis Indefinidas
;----------------------------------------------------------------
    .section    bss

avg1:
    .space  1   ; Variável de 8 bits, só precisa de 1 byte de espaço

avg2:
    .space  1   ; Variável de 8 bits, só precisa de 1 byte de espaço

;----------------------------------------------------------------
;   Stack_top 
;----------------------------------------------------------------
    .section    .stack
    .space      1024
stack_top:

;----------------------------------------------------------------
;   Compilar sem erros [LINHA NOVA NO FIM]
;----------------------------------------------------------------

