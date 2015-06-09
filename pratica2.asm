; Controle de Temperatura
; Programador: Fco Edno
;
; Com um ADC de 8 bits na porta P2 e verificado o valor de temperatura
; de um LM35. Se o valor do adc for maior que 23 (25 C), eh acionado
; um cooler para resfriamento. A faixa de medicao esta entre [2C,150C].
; Cada grau a mais representa uma unidade binaria, isto eh, 2C = 0 e 3C = 1.
;
; ADC: P2, FAN: P0.0, Display: P3 e P1.
;
; -------------------------------------------------------------
; Mapa dos registradores:
; -------------------------------------------------------------
; R0: ADC Puro
; R1: Temperatura em Graus
; R2: Primeiro digito BCD da temperatura
; R3: Segundo digito BCD da temperatura
; R4: Terceiro digito BCD da temperatura
; -------------------------------------------------------------

;**************************************************************
; Equates													  *
;**************************************************************
ADC		equ		p2
FAN		equ		p0.0

DP1		equ		p3							; Display de 7 segmentos 1
DP2		equ		p1							; Display de 7 segmentos 2

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

Exit:	acall	DcdADC
		acall	Disp

		ajmp	Main

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
		mov		a, r0						; Para obter o decimal equivalente simplesmente
		add		a, #2						; Somo 2 ao valor obtido do ADC.
		mov		r1,a

		mov		a, r1
		mov		b, #100
		div		ab
		mov		r2,a

		mov		a, b
		mov		b, #10
		div		ab
		mov		r3,a
		mov		r4,b

		ret

; -------------------------------------------------------------
; Disp
; -------------------------------------------------------------
; Faz a leitura do valor decimal do ADC e imprime no Display  
; de 7 segmentos
; -------------------------------------------------------------
Disp:	
		mov		a, r3
		acall	LKDisp
		mov		DP1, a

		mov		a, r4
		acall	LKDisp
		mov		DP2, a

		ret

; -------------------------------------------------------------
; LKDisp
; -------------------------------------------------------------
; Lookup-Table para decodificacao de displays de 7 segmentos
; -------------------------------------------------------------
LKDisp: mov		dptr, #TABLE
		movc	a, @a+dptr	
		ret

TABLE:	DB	81h, 0cfh, 92h, 86h, 0cch, 0a4h, 0a0h, 8fh, 80h, 8ch


;**************************************************************
		end
;**************************************************************
