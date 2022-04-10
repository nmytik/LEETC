; Cadeira: Arquitetura de Computadores
; Semestre: 2122sv

; Grupo: 4

; Número    Aluno
; A33312    Nelio Nunes
; A46948    Nuno Brito
; A46950    Nelson Lopes

;----------------------------------------------------------------
;   Situação Final: COMPILADO
;----------------------------------------------------------------
;   Respostas
;
;   1b. Cada instrução do P16 ocupa 16 bits. A função em questão, está a utilizar 36 instruções logo a quantidade de memória ocupada em bytes é dada por:
;       40*2 = 80 bytes, dado que 16 bits = 2 bytes.
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
; antes da linha 30 do código, então será possível usar esse registo sem qualquer preocupação dado que não há nenhum chamamento de função até ao fim da
; função average.
;   3b. INT8_MAX é uma variável a 8 bits com sinal e por isso o seu valor máximo é de 127.
;----------------------------------------------------------------
;
;   No decorrer deste programa foram utilizados diversos métodos e conceitos abordados pelo docente Jorge Fonseca até ao momento.
;
;----------------------------------------------------------------

;----------------------------------------------------------------
;   Defines
;----------------------------------------------------------------
    .equ    ARRAY_SIZE, 12
    .equ    INT8_MAX,   0x7F    ; 127       -> int8_t
    .equ    INT16_MIN,  0x8000  ; -32768    -> int16_t
    .equ    INT16_MAX,  0x7FFF  ; 32767     -> int16_t
    .equ    MASK_01,    0x0001  ; Máscara para OR bit a bit com 1

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
;             r2 - avg1, avg2
;----------------------------------------------------------------
;   Situação: Resolvido [&Verificado]
;----------------------------------------------------------------
    .section    text
main:
    push lr

    ; avg1
    ldr r0, array1_addr   ; Carregar endereço do array1
    mov r1, ARRAY_SIZE    ; r1 = array_size
    bl  function_average
    mov r2, r0            ; avg1 = average
    ldr r0, avg1_addr     ; Endereço da variável global avg1
    strb r2, [r0, #0]     ; Armazenar valor 

    ; avg2
    ldr r0, array2_addr   ; Carregar endereço do array2
    mov r1, ARRAY_SIZE
    bl  function_average
    mov r2, r0            ; avg2 = average
    ldr r0, avg2_addr
    strb r2, [r0, #0]

    b   .                 ; // while(1);
    
    pop pc

array1_addr:
    .word   array_1
array2_addr:
    .word   array_2
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
;             r2 - uavg, avg
;             r3 - temp, INT16_MAX
;             r4 - uacc, acc
;             r5 - neg
;----------------------------------------------------------------
;   Situação: Resolvido [&Verificado]
;----------------------------------------------------------------
function_average:
    push lr
    push r4
    push r5

    bl function_summation
    mov r2, #INT8_MAX                         ; Caso o beq seja verdadeiro, avg já está no sítio correto

    if_function_average:
        mov r4, r0                            ; acc = return do summation
        mov r3,  #INT16_MAX & 0xFF            ; Carrega parte byte baixo
        movt r3, #INT16_MAX >> 8 & 0xFF       ; Carrega parte byte alto
        cmp r4, r3                            ; Compara acc=return do summation com int16_max
        beq if_end_function_average           ; Caso seja igual, salta para o fim, porque o resultado vai sair fora de dominio (?)

        if_acc_function_average:    
            mov r3, #0                        ; Carrega r3 com 0
            cmp r4, r3                        ; Compara return do summation com 0
            bge if_acc_else_function_average  ; Caso seja menor que 0 (negativo), continua, caso contrario, salta para if_end_2
            mov r5, #1                        ; Coloca o r6 (neg) a 1, indicando que o resultado da soma é negativo.
            sub r4, r3, r4                    ; uacc = 0 - acc
            b if_acc_end_function_average     ; Após terminar divisão, salta para if_3

        if_acc_else_function_average:
            mov r5, #0                        ; Coloca neg a 0 (indicando que a soma é positiva, logo pode enviar )

        if_acc_end_function_average:
        mov r0, r4                            ; r0 = acc. r1 não foi estragado
        bl function_udiv                      ; Chama a função udiv para fazer a divisão com numero positivo
        mov r2, r0                            ; r2 = avg
        
        if_neg_function_average:
            mov r3, #1
            cmp r5, r3                        ; r5-r3 (neg - 1)
            bne if_neg_end_function_average   ; Testa se neg é 0 (positivo). se positivo, salta para if_end_3, se negativo, continua
            mvn r2, r2                        ; Taz o complementar do resultado da média, uma vez que o return do summation era negativo, a media tambem será
            add r2, r2, #1                    ; Termina o complementar

        if_neg_end_function_average:
    if_end_function_average:
    
    mov r0, r2                                ; Return avg

    pop r5
    pop r4
    pop pc

;----------------------------------------------------------------
;   Função: summation
;----------------------------------------------------------------
;    int16_t summation(int8_t a[], uint16_t n){
;        uint8_t error = 0;
;        int16_t acc = 0;
;
;        for(uint16_t i = 0; i < n && error == 0; i++){
;            int16_t e = a[i];
;            // OLD: if ((e < INT16_MIN - acc) || (e > INT16_MAX - acc)){
;            if ((acc < 0 && e < INT16_MIN - acc) || (acc > 0 && e > INT16_MAX - acc)){
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
;   Situação: Resolvido [&Verificado]
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
        bhs for_end_function_summation
        sub r2, r2, #0
        bne for_end_function_summation

        ldrb r5, [r0, r4]                               ; e = a[i]
        movt r5, #0                                     ; Meter a parte alta a zeros porque "e" é int16
        
        if_function_summation_infor:
            sub r3, r3, #0                              ; acc < 0
            bge cond2_function_summation_infor
            ldr r6, INT16_MIN_Value_addr                ; Carregar valor de 16 para um registo
            ldr r6, [r6, #0]
            sub r6, r6, r3                              ; INT16 - acc
            cmp r5, r6
            blt infor_condtrue_function_summation       ; Para fazer o OR na função

            cond2_function_summation_infor:
                mov r6, #0
                cmp r6, r3                              ; acc > 0
                bge else_infor_function_summation
                ldr r6, INT16_MAX_Value_addr
                ldr r6, [r6, #0]
                sub r6, r6, r3
                cmp r6, r5                              ; Trocar os operandos porque não existe <= no P16
                bge else_infor_function_summation

            infor_condtrue_function_summation:
                mov r2, #1                              ; error = 1
                b   if_infor_end_function_summation

        else_infor_function_summation:
            add r3, r3, r5                              ; acc = acc + e
        
        if_infor_end_function_summation:
        add r4, r4, #1                                  ; i++
        b   for_end_function_summation

    for_end_function_summation:
    if_err_function_summation:
       mov  r6, #1
       cmp  r2, r6                                      ; Comparar error com 1
       bne  if_err_end_function_summation
       ldr  r6, INT16_MAX_Value_addr
       ldr  r3, [r6, #0]
       
    if_err_end_function_summation:
    mov r0, r3                                          ; Retornar acc

    pop r6
    pop r5
    pop r4
    mov pc, lr                                          ; Função folha

INT16_MAX_Value_addr:
    .word   INT16_MAX_Value
INT16_MIN_Value_addr:
    .word   INT16_MIN_Value

;----------------------------------------------------------------
;   Função: udiv
;----------------------------------------------------------------
;    uint16_t udiv(uint16_t D, uint16_t d){
;        int32_t q = D;
;        uint32_t shf_d = ((uint32_t) d) << 16;
;
;        for(uint8_t i = 0; i < 16; i++){
;            q <<= 1
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
;   Registos: r0 - D
;             r1 - d
;             [r3:r2] - q
;             [r5:r4] - shf_d
;             r6 - i
;             r7 - 16
;             r8 - temp
;----------------------------------------------------------------
;   Situação: Resolvido [&Verificado]
;----------------------------------------------------------------
function_udiv:
    push lr
    push r4
    push r5
    push r6
    push r7
    push r8

    mov  r2, r0                                 ; Move D para a parte baixa do registo r3:r2 ; int32_t q = D;
    movt r3, #0                                 ; Preenche a zeros a parte alta do registo r3:r2
    mov  r5, r1                                 ; Mover r1 para a parte alta do registo r5:r4 <=> <<16 
    movt r4, #0                                 ; Preenche a zeros a parte baixa do registo r5:r4

    mov r6, #0                                  ; i = 0
    mov r7, #16                                 ; r7 = 16

    for_udiv:
        cmp r6, r7                              ; i - 16
        bhs for_end_udiv                        ; i >= 16
        lsl r3, r3, #1                          ; Fazer o shift primeiro na parte alta
        lsl r2, r2, #1                          ; Fazer o shift da parte baixa
        mov r8, #0  
        adc r3, r3, r8                          ; Adicionar a carry à parte alta do registo
        sub r2, r2, r4                          ; q = q - shf_d
        sbc r3, r3, r5                          

        if_udiv: 
            cmp r3, r8
            bge else_udiv                       ; q >= 0 salta fora
            add r2, r2, r4                      ; q = q + shf_d
            adc r3, r3, r5                      ; Soma as partes altas com o carry (se existir)
            b   if_end_udiv

        else_udiv: 
            mov r8,  #MASK_01 & 0xFF            ; Carrega parte byte baixo
            movt r8, #MASK_01 >> 8 & 0xFF       ; Carrega parte byte alto
            orr  r2, r2, r8                     ; q |= 1
            ;orr  r3, r3, r8                     ; q |= 1 Sendo OR com 1, não necessita fazer OR da parte alta ***

        if_end_udiv:
        add r6, r6, #1                          ; i++
        b for_udiv

    for_end_udiv:
    mov  r0, r2                                 ; Return q - Retorna a parte baixa do registo

    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    mov pc, lr                                  ; Função folha

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
    .space      32
stack_top:

;----------------------------------------------------------------
;   Compilar sem erros [LINHA NOVA NO FIM]
;----------------------------------------------------------------

