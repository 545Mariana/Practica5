.include "gpio.inc" @ Includes definitions from gpio.inc file
.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"

setup:
        @Prologo
        push {r7, lr}
        sub sp, sp, #8
        add r7, sp, #0

        # Habilitando reloj en puerto B
        ldr     r0, =RCC_APB2ENR @ move 0x40021018 to r0
        mov     r1, 0x8 @ carga 8 en r1 para habilitar el reloj en el puerto C (bit IOPC)
        str     r1, [r0] @ M[RCC_APB2ENR] 

        # restablecer pin 0 a 7 en GPIOB_CRL
        ldr     r0, =GPIOB_CRL @ mueve la dirección del registro GPIOC_CRL a r0
        ldr     r1, =0x33344433 @ Esta constante señala el estado de reinicio
        str     r1, [r0] @ M[GPIOC_CRL] obtiene 0x33344433 

        # configurar el pin 8 a 15 
        ldr     r0, =GPIOB_CRH @ mueve la dirección del registro GPIOC_CRH a r0
        ldr     r1, =0x33388334 @ Salida push-pull, velocidad máxima 50 MHz
        str     r1, [r0] @ M[GPIOC_CRH] Obtiene 0x44444444

        # configurar B11 y B12 pull-down input
        ldr     r0, =GPIOB_ODR
        mov     r1, #0
        str     r1, [r0]

        # contador = 0
        mov     r0, #0
        str     r0,[r7]


loop:
        bl Boton1
        str     r0, [r7, #4]
        bl Boton2
        str     r0, [r7, #8]
        @Cargar valores de botones
        ldr     r0, [r7, #4]
        ldr     r1, [r7, #8]

        @Comparacion de botones 
        @Boton  1
        cmp     r0, #0
        bne     L1

        @Boton 2
        cmp     r1, #0
        bne     L2

        @Reinicio contador
        ldr     r0, [r7]
        mov     r0, #0           @ enciende PINES
        str     r0, [r7]
        b       L3
        @sumar 1
L2:     ldr     r0,[r7]
        add     r0, #1
        str     r0,[r7]
        b       L3       
L1:     cmp     r1, #0
        bne     L3
        # resta al contador 
        ldr r0, [r7]
        sub r0, #1
        str r0, [r7]
L3:        #Encendido de leds
        ldr     r0, =GPIOB_ODR  @ output
        mov     r3, #0
        str     r3, [r0]
        ldr     r1, [r7]        @ contador 
        str     r1, [r0]
        
        b       loop


 

#Funcion de Boton 

Boton1:
        @prologo
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp, #0
        
        @ Funcion read button B11

        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        and     r0, 0x800
        lsr     r0, #11

        @if(button is not pressed)

        cmp     r0, #0 @if (si r' es igual a cero, encienda) DUDA
        bne     E1 
        
        @Return false
        mov     r0, #0
        @epilogo
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx      lr

        #contador = 0
E1:     mov     r0, #0
        str     r0, [r7]
        
        #for (i=0; i< 10; i++)
        mov     r0, #0          @ i = 0;
        str     r0, [r7, #4]
        b       E2
E3:     
        mov     r0, #200
        @funcion que hace esperar 5 ms
        bl      delay          

        @Leer button Input
        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        and     r0, 0x800
        lsl     r0, #11
        
        #if(button is not pressed) Compara bit del boton con 1
        cmp     r0, #0
        bne     E4
        #Contador = 0
        ldr     r0, [r7]
        mov     r0, #0
        str     r0, [r7]

        #else contador = contador + 1
E4:     ldr     r0, [r7]      @contador = contador + 1
        add     r0, #1
        str     r0, [r7]

        #if (counter >=4)
        ldr     r0, [r7]
        cmp     r0, #4
        blt     E5

        @return true
        mov     r0, #1
        #epilogo
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx      lr

        # i++
E5:     ldr     r0,[r7, #4]
        add     r0, #1
        str     r0,[r7, #4]
        # i<10
E2:     ldr     r0,[r7, #4]
        cmp     r0, #10
        blt     E3

        @return false
        mov     r0, #0
        #epilogo
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx      lr

Boton2:
        @prologo
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp, #0
        
        @ Funcion read button B12
        
        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        and     r0, 0x1000
        lsr     r0, #12

        #if(button is not pressed)

        cmp     r0, #0 @if (si r' es igual a cero, encienda) DUDA
        bne     F1 
        
        #Return false
        mov     r0, #0
        @epilogo DUDA
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx      lr

        #contador = 0
F1:     ldr     r0, [r7]
        mov     r0, #0
        str     r0, [r7]
        
        #for (i=0; i< 10; i++)
        mov     r0, #0          @ i = 0;
        str     r0, [r7, #4]
        b       F2
F3:     mov     r0, #300
        @funcion que hace esperar 5 ms
        bl      delay          

        @Leer button Input
        ldr     r0, =GPIOB_IDR
        ldr     r0, [r0]
        and     r0, 0x1000
        lsl     r0, #12
        
        #if(button is not pressed) Compara bit del boton con 1
        cmp     r0, #0
        bne     F4
        #Contador = 0
        ldr     r0, [r7]
        mov     r0, #0
        str     r0, [r7]

        #else contador = contador + 1
F4:     ldr     r0, [r7]      @contador = contador + 1
        add     r0, #1
        str     r0, [r7]

        #if (counter >=4)
        ldr     r0, [r7]
        cmp     r0, #4
        blt     F5

        @return true
        mov     r0, #1
        #epilogo
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx      lr

        # i++
F5:    ldr     r0,[r7, #4]
        add     r0, #1
        str     r0,[r7, #4]
        @ i<10  
F2:     ldr     r0,[r7, #4]
        mov     r1, #10
        cmp     r0, r1
        blt     F3

        @return false
        mov     r0, #0

        @epilogo
        adds    r7, r7, #8
        mov	sp, r7
        pop     {r7, lr}
        bx      lr


# This functions delays the program execution n milliseconds (ms)
# Argument:
#     - r0: number of ms
# local variables:
#     - iterator i
#     - iterator j
#     - ticks
delay:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Body function
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
# for (i=0;i<ms;i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       A3
# for (j = 0; j < tick; j++)
A4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       A5
A6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
A5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     A6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
A3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     A4
        # Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr

        
        