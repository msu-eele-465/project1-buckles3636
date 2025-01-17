;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; P.Buckley, EELE-465
; Oct 6 2024
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
SetupP1:     
        bic.b   #BIT0,&P1OUT            ; Clear P1.0 output
        bis.b   #BIT0,&P1DIR            ; P1.0 output
        bic.w   #LOCKLPM5,&PM5CTL0      ; Unlock I/O pins

Mainloop:
        jmp     Timer                   ; Jump to timer subroutine
        jmp     Delay                   ; Jump to delay subroutine

;-------------------------------------------------------------------------------
; Delay Loop
;-------------------------------------------------------------------------------
Delay:    
        xor.b   #BIT0,&P1OUT            ; Toggle P1.0 every 0.5s
Wait:      
        mov.w   #25000,R15             ; Delay to R15
L1:         
        dec.w   R15                     ; Decrement R15
        jnz     L1                      ; Delay over?
        jmp     Delay                   ; Again
        NOP

;-------------------------------------------------------------------------------
; Timer Setup and loop
;-------------------------------------------------------------------------------
Timer:		
        ; Setup Timer TB0
		bis.w	#TBCLR, &TB0CTL
		bis.w	#TBSSEL__ACLK, &TB0CTL
		bis.w	#MC__UP, &TB0CTL

		; Setup Compare Register
		mov.w	#250000, &TB0CCR0

		bis.w	#CCIE, &TB0CCTL0
		bic.w	#CCIFG, &TB0CCTL0

		; Enable global interrupts
		bis.w	#GIE, SR
L2:
        jmp     L2                      ; Infinite Loop

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
ISR_TB0_CCR0:
		xor.b	#BIT0, &P1OUT               ; Toggle LED1 (P1.0)
		bic.w	#CCIFG, &TB0CCTL0           ; Clear TB1 interrupt flag
		reti


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

            .sect   ".int43"                ; Timer B0 Overflow Vector
            .short  ISR_TB0_CCR0