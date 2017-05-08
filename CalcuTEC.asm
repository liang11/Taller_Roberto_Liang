%include 'io.mac'
%include 'macros.asm'

.DATA
	bienvenido	db	'¡Bienvenido a la calculadora más crack del TEC!',10,13,0
	sim			db	10,13,'$ ',0
	msg_error	db	'Expresion Invalida!',0
	operacion	db	'(6+2)*3/2+2-4',0;'(6+2)*3/2-4',0

.UDATA
	;operacion	resb	16
	posfijo		resb	32
	boolean		resb	1
	aux			resd	1
	var			resb	1
	resultado	resd	16
	basura		resd	3

.CODE
	.STARTUP
		call limpiarRegistros		;limpio los registros
		PutStr bienvenido			;imprimo msg de bienvenida
		nwln				
		PutStr sim					;imprimo simbolo de $
		;GetStr operacion			;espero el inout del usuario y lo guardo en operacion 
		
		generarPosfijo:
			mov bl, [operacion+edx];muevo al ebx el 1er caracter de operacion
			cmp bl, 0				;comparo si se termino el string
			je terminar
			inc edx					;incremento contador para leer prox caracter de operacion
			cmp bl, '('
			je meterPila
			cmp bl, ')'
			je vaciarPila
			call verificarOperacion	;verifico si es una operacion valida
			cmp byte[boolean], 1
			je verificarPila
			call verificarNumero	;verifico si es un numero
			cmp byte[boolean], 1
			je meterPosfijo
			call verificarLetra		;verifico si es una letra
			cmp byte[boolean], 1
			je meterPosfijo
			jmp error
			
		verificarPila:
			cmp ecx, 0
			je meterPila
			mov [aux], eax	
			Pop eax
			Push eax
			cmp bl, '+'
			je verificarSumaResta
			cmp bl, '-'
			je verificarSumaResta
			cmp bl, '*'
			je verificarMultDiv
			cmp bl, '/'
			je verificarMultDiv
		
		verificarSumaResta: 
			cmp al, '('
			je meterPila
			cmp al, '+'
			je cambiarTope
			cmp al, '-'
			je cambiarTope
			cmp al, '*'
			je cambiarTope
			cmp al, '/'
			je cambiarTope
		
		verificarMultDiv:
			cmp al, '('
			je meterPila
			cmp al, '+'
			je meterPila
			cmp al, '-'
			je meterPila
			cmp al, '*'
			je cambiarTope
			cmp al, '/'
			je cambiarTope
			
		meterPila:
			PutCh 'M'
			Push ebx
			inc ecx
			mov eax, [aux]
			jmp generarPosfijo
			
		cambiarTope:
			Pop eax
			Push ebx
			mov ebx, [aux]
			mov [posfijo+ebx], al
			inc ebx
			mov eax, ebx
			jmp generarPosfijo
			
		
		meterPosfijo:
			PutCh 'P'
			mov [posfijo+eax], bl
			inc eax
			mov [aux], eax
			jmp generarPosfijo
			
		vaciarPila:
			cmp ecx, 0
			jne ciclo
			jmp generarPosfijo
			ciclo:
				Pop ebx
				cmp bl, '('
				je disminuir
				mov [posfijo+eax], bl
				inc eax
				mov [aux], eax
				loop ciclo
				jmp generarPosfijo
			disminuir:
				dec ecx
				jmp generarPosfijo
		
		error:
			nwln
			PutStr msg_error
			
		terminar:
			nwln
			cmp ecx, 0
			jne vaciarPila
			PutStr posfijo
			dec edx
			jmp llenarPila
			
		llenarPila:
			mov bl, [posfijo+edx]
			cmp bl, 0
			je resolver
			dec edx
			call esNumero
			cmp byte[boolean], 1
			je implicito
			Push ebx
			inc ecx
			jmp llenarPila
			implicito:
				sub ebx, 30h
				Push ebx
				jmp llenarPila
		
		resolver:
			cmp ecx, 0
			je mostrarResultado
			Pop eax
			Pop ebx
			Pop edx
			cmp bl, '+'
			je sumar
			cmp bl, '-'
			je restar
			cmp bl, '/'
			je dividir
			cmp bl, '*'
			je multiplicar
			
		sumar:
			PutCh 'S'
			add eax, ebx
			Push eax
			dec ecx
		
		restar:
		PutCh 'R'
			sub eax, ebx
			Push eax
			dec ecx
			
		dividir:
		PutCh 'D'
			div ebx
			Push eax
			dec ecx
			
		multiplicar:
		PutCh 'M'
			mul ebx
			Push eax
			dec ecx
	
		mostrarResultado: ;;;;;;;;;;;;;;;;;;;;;;;;check aqui!
			Pop eax
			mov [var], eax
			PutCh al
			adios:
			.EXIT
					
;=======================================================================
;=======================================================================
limpiarRegistros:
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

verificarOperacion: 
	cmp bl, 30h
	jge noOperacion
	cmp bl, '+'
	je suma
	cmp bl, '-'
	je resta
	cmp bl, '/'
	je esOperacion
	cmp bl, '*'
	je esOperacion
	noOperacion:
		mov byte[boolean], 0
		ret
	esOperacion:
		mov byte[boolean], 1
		PutCh 'O'
		ret
	suma:
		mov bl, [operacion+edx]
		inc edx
		cmp bl, '+'
		je suma
		cmp bl, '-'
		je resta
		dec edx
		mov bl, '+'
		jmp esOperacion
	resta:
		mov bl, [operacion+edx]
		inc edx
		cmp bl, '+'
		je suma
		cmp bl, '-'
		je suma
		dec edx
		mov bl, '-'
		jmp esOperacion
	
verificarNumero:
	cmp bl, 2Fh
	jle noNumero
	cmp bl, 3Ah
	jge noNumero
	esNumero:
		mov byte[boolean], 1
		PutCh 'N'
		ret
	noNumero:
		mov byte[boolean], 0
		ret
	
verificarLetra:
	cmp bl, 60h
	jle noLetra
	cmp bl, 7Bh
	jge noLetra
	esLetra:
		mov byte[boolean], 1
		PutCh 'L'
		ret
	noLetra:
		mov byte[boolean], 0
		ret
	
	
;HexToInt var,32
	;mov eax,var
	;PutStr eax
