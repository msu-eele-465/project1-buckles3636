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
        jmp     Delay                   ; Jump to delay subroutine

;-------------------------------------------------------------------------------
; Delay Loop
;-------------------------------------------------------------------------------
Delay:    
        xor.b   #BIT0,&P1OUT            ; Toggle P1.0 every 0.5s
Wait:      
        mov.w   #250000,R15             ; Delay to R15
L1:         
        dec.w   R15                     ; Decrement R15
        jnz     L1                      ; Delay over?
        jmp     Delay                   ; Again
        NOP

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
