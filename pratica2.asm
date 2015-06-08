; Controle de Temperatura
; Programador: Fco Edno
;
; Com um ADC de 8 bits na porta P2 e verificado o valor de temperatura
; de um LM35. Se o valor do adc for maior que 23 (25 C), eh acionado
; um cooler para resfriamento. A faixa de medicao esta entre [2C,150C].
; Cada grau a mais representa uma unidade binaria, isto eh, 2C = 0 e 3C = 1.

;**************************************************************
; Equates													  *
;**************************************************************
ADC		equ		p2
FAN		equ		p0.0
K		equ		232 						; Constante para verificar nivel maximo


;**************************************************************
; Main														  *
;**************************************************************

Main:	mov		r0, ADC						; Joga o valor do ADC no r0 
		mov		a, r0						; Adiciona K ao acumulador, se a carry 
		add		a, #K						; for setada, o valor maximo foi alcancado

		jc		Liga						; Verifica o estado da Carry, se setada
Desl:	clr		c							; liga o cooler, caso contrario desliga	
		setb	FAN
		jmp		Exit

Liga:	clr		c
		clr		FAN

Exit:	acall DcdADC
		acall Disp



;**************************************************************
; Sub Rotinas												  *
;**************************************************************

; -------------------------------------------------------------
; DcdADC
; -------------------------------------------------------------
; Decodifica o ADC e armazena na memoria RAM para imprimir
; Futuramente num display de 7 segmentos
; -------------------------------------------------------------
DcdADC:
		ret

; -------------------------------------------------------------
; Disp
; -------------------------------------------------------------
; Faz a leitura do valor decimal do ADC e imprime no Display  
; de 7 segmentos
; -------------------------------------------------------------
Disp:	
		ret
