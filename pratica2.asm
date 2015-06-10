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
; R5: Rotina de Delay
; R6: Rotina de Delay
; R7: Contador na rotina de envio para o shift register
; -------------------------------------------------------------

;**************************************************************
; Equates													  *
;**************************************************************
ADC		equ		p2
FAN		equ		p0.0

DP1		equ		p3							; Display de 7 segmentos 1
DP2		equ		p1							; Display de 7 segmentos 2

K		equ		232 						; Constante para verificar nivel maximo

; -------------------------------------------------------------
; Shift registers
; -------------------------------------------------------------
SHD		equ		p0.1
SHCK	equ		p0.2
SHLTCH	equ		p0.3
SH2LTCH	equ		p0.4

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
		acall	LKDisp						; Bota no acumulador a decodificacao do BCD
		cpl		a

		clr		SHLTCH						; Da pulso baixo para desabilitar saida no SHIFT
		acall	SHSend
		setb	SHLTCH						; Pulso alto para habilitar a saida no SHIFT

		mov		a, r4
		acall	LKDisp
		cpl		a

		clr		SH2LTCH
		acall	SHSend
		setb	SH2LTCH

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

; -------------------------------------------------------------
; SHSend
; -------------------------------------------------------------
; Envia para o display a codificacao pelo shiftregister
; -------------------------------------------------------------
SHSend:	

		mov		r7, #8						; Contador

Again:	mov		c, acc.7					; Envia serialmente o MSB do Acc
		mov		SHD, c
		acall	CKPulse

		rl		a							; Rotaciona o Acc para continuar o envio
		djnz	r7, Again


		ret

; -------------------------------------------------------------
; CKPulse
; -------------------------------------------------------------
; Da um pulso de clock. Rotina utilizada no envio de dados
; Seriais para o registrador de deslocamento.
; -------------------------------------------------------------
CKPulse:
		setb	SHCK
		;acall	Delay
		clr		SHCK

		ret

; -------------------------------------------------------------
; Delay
; -------------------------------------------------------------
; Delay para o pulso de clock. Provavelmente desnecessario
; -------------------------------------------------------------
Delay:	mov		r5, #255
		mov		r6, #255

;**************************************************************
		end
;**************************************************************
