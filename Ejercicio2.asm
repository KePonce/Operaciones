EJECUTAR macro    														;INICIA EL PROGRAMA
Programa:
	mov ax, @data														;se obtiene la direccion del segmento de datos y lo colocamos en AX
	mov ds, ax															;muevo lo que tiene ax a ds, es decir la direccion de inicio de datos se lo colocamos al semgnto de datos	
	mov es,	ax															;muevo lo que tiene ax a es, es decir la direccion de inicio de datos se lo colocamos al semgnto extra	
endm

FIN  macro																;FINALIZA EL PROGRAMA
	mov ah,00h															;Para establecer el modo de video y borra la pantalla
	mov al,03h															;modo
	int 10h																;Interrupción de video
	
	mov ah,4ch
	int 21h 
	end Programa
endm

fondo macro																;CAMBIA EL COLOR DE LA PANTALLA
	mov ax,0600h
	mov bh,1fh
	mov cx,0000
	mov dx,184fh
	int 10h
endm

VERSTR macro msj														;Muestra las cadenas de texto o de numeros
 mov ah,09
 lea dx,msj
 int 21h
endm

ir macro renglon,columna												;Cambia de posición el cursor para escribir
 mov ah,02
 mov bh,00
 mov dh,renglon
 mov dl,columna
 int 10h
endm

capcharv macro															;Obtiene un caracter desde el teclado y lo muestra, para posteriormente analizarlo
	mov ah,01
	int 21h
endm


ponercar macro caracter													;Muestra 1 caracter
	mov ah,02
	mov dl,caracter
	int 21h
endm





RC   EQU 10
LONG EQU 10
.MODEL SMALL
.STACK
.DATA
	STR10 db 'Menu… Escoja una opcion $'
	STR11 db '1) Adicion $'
	STR12 db '2) Sustraccion $'
	STR13 db '3) Multiplicacion $'
	STR14 db '4) Divicion $'
	STR15 db '5) Salir $'
	STR16 db 'Opcion: $'
	STR17 db 'Primer cifra: $'
	STR18 db 'Segunda cifra: $'
	STR100 db 'Resultado: $'
	STRSALTO db 10, 13, ' $'
	opcion db 1 dup ('$')
	error1 db 'Opcion no valida vuelve a elegir opcion. $'
	error2 db 'Debe elegir solo digitos (0,…,9). $'
	error3 db 'Debe presionar enter. $'
	MSJ1 DB 'ESCRIBE EL PRIMER  NUMERO : $' 
	MSJ2 DB 'ESCRIBE EL SEGUNDO NUMERO :  $'
	NUM1 DB 10 DUP (0)
	NUM2 DB 10 DUP (0)
	NUM1AUX DB 10 DUP (0)
	NUM2AUX DB 10 DUP (0)
	CONTROL1 DB 0
	CONTROL2 DB 0
	residuo dw 0
	CUCO1  DW 0
	CUCO2  DW 0
	DIEZ   DW 1
	DIEZ1  DW 1
	NUM1BIN DW 10 dup (0)
	NUM2BIN DW 10 dup (0)
	SUMABIN DW 10 dup (0)
	RESULTSUM DB 10 DUP(' ')
.CODE

proc muestraMenu far
	fondo 
	ir 7,10
	verSTR STR10															;Muestra el menu y espera a recibir la opcion seleccionada
	
	prin:
	ir 9,10
	verSTR STR11
	ir 10,10
	verSTR STR12
	ir 11,10
	verSTR STR13
	ir 12,10
	verSTR STR14
	ir 13,10
	verSTR STR15
	ir 15,10
	verSTR STR16
	capcharv
	mov opcion,al
 
	cmp al,31h																		;Verifica que se ingresó un número del 1 al 5 para seleccionar una opción
	je cap
	cmp al,32h
	je cap
	cmp al,33h
	je cap
	cmp al,34h
	je cap
	cmp al,35h
	je cap
  
	er1: 																				;Sino se selecciono una opcion muestra un error
	fondo
	ir 4,20
	verSTR error1
	jmp prin																			;Vuelve a imprimir  el menu y esperar que se ingrese una opcion
 
	cap:
	ret
endp

IngresoN1 proc far					;Ingreso del primer numero
	ir 8,10
	VERSTR MSJ1
	MOV BX,0
	CICLO1: 
	PONERCAR 8
	SIGUE1:
	CAPcharv
	CMP AL,13
	JE ORDENAR
	CMP AL,30H
	JL CICLO1
	CMP AL,39H
	JA CICLO1
	MOV NUM1AUX[BX],AL
	INC BX 
	INC CONTROL1
	INC CUCO1
	CMP CONTROL1,10
	JNE SIGUE1
	ORDENAR:
	MOV AX,CUCO1
	MOV BX,LONG
	SUB BX,AX 
	MOV SI,0 
	CICLO2:  
	MOV CL,NUM1AUX[SI]
	MOV NUM1[BX],CL
	INC SI
	INC BX
	CMP BX,10
	JNE CICLO2
 ret
endp

IngresoN2 proc far												;Ingreso del segundo numero	
	ir 9,10
	VERSTR MSJ2
	MOV BX,0
	CICLO3: 
	PONERCAR 8
	SIGUE2:
	CAPcharv
    CMP AL,13													;Deja de guardar hasta que se ingrese "ENTER"
	JE ORDENAR1
	CMP AL,30H
	JL CICLO3
	CMP AL,39H															;Verifica que el numero sea un digito
	JA CICLO3
	MOV NUM2AUX[BX],AL
	INC BX 
	INC CONTROL2
	INC CUCO2
	CMP CONTROL2,10
	JNE SIGUE2
	ORDENAR1:
	MOV AX,CUCO2
	MOV BX,LONG
	SUB BX,AX
	MOV SI,0 
	CICLO4:  
	MOV CL,NUM2AUX[SI]
	MOV NUM2[BX],CL
	INC SI
	INC BX
	CMP BX,10
	JNE CICLO4 
ret
endp
 

convert1 proc far										;Convierte el numero 1 en numero binario
	MOV AX,0
	MOV BX,10
	MOV CX,10
	LEA SI,NUM1+9
	MARCA:
	MOV AL,[SI]
	AND AX,000FH
	MUL DIEZ
	ADD NUM1BIN,AX
	MOV AX,DIEZ
	MUL BX
	MOV DIEZ,AX
	DEC SI
	LOOP MARCA
	RET
ENDP

convert2 proc far
	MOV AX,0
	MOV BX,10
	MOV CX,10
	LEA SI,NUM2+9
	MARCA1:
	MOV AL,[SI]
	AND AX,000FH
	MUL DIEZ1
	ADD NUM2BIN,AX
	MOV AX,DIEZ1
	MUL BX
	MOV DIEZ1,AX
	DEC SI
	LOOP MARCA1
	RET
ENDP

SUMA MACRO a,b,total
	PUSH   AX
	MOV    AX,a
	ADD    AX,b
	MOV    total,AX
	POP    AX
 ENDM

RESTA MACRO a,b,total
	PUSH   AX
	MOV    AX,a
	SUB    AX,b
	MOV    total,AX
	POP    AX
ENDM

convbinascii proc far												;Para convertir el numero binario a numero decimal en su representación ascii
	MOV CX, 0010
	LEA SI, RESULTSUM+9
	MOV AX, SUMABIN
	CICLO6:
	CMP AX,CX
	JB  CICLO7
	XOR DX,DX
	DIV CX
	OR DL,30H
	MOV [SI],DL
	DEC SI
	JMP CICLO6
	CICLO7:
	OR AL,30H
	MOV [SI],AL
	ret
endp

multi proc far
	MOV Ax,num1bin
	MUL num2bin
	MOV sumabin,ax
	RET
endp

divide proc far
	mov ax,num1bin
	mov residuo,ax
	mov bx,num2bin
	mov si,0
	ciclo35:
	cmp residuo,bx
	jb termina1
	PUSH   AX
	MOV    AX,residuo
	SUB    AX,num2bin
	MOV    residuo,AX
	inc si
	POP    AX
	jmp ciclo35
	termina1:
	mov  sumabin,si
	ret
	endp
	ciclo40:
	cmp  di,num2bin
	je  termina2
	MOV  Ax,num1bin
	MUL  sumabin
	MOV  sumabin,ax
	inc  di
	jmp ciclo40
	termina2:
	RET
endp

proceso1 proc far									;Dirigue al usuario al ingreso de numeros para realizar la opcion que desea
	cmp opcion,31h
	je adicion
	cmp opcion,32h
	je sustraccion
	cmp opcion,33h
	je multiplicacion
	cmp opcion,34h
	je division
	cmp opcion,35h
	je FIN
	
	adicion:
	suma num1bin,num2bin,sumabin
	jmp hecho
	
	sustraccion:
	resta num1bin,num2bin,sumabin
	jmp hecho
	
	multiplicacion:
	call multi
	jmp hecho
	
	division:
	call divide
	jmp hecho
	
	jmp hecho
	
	hecho:
	ret
endp

proceso2 proc far
	CALL CONVBINASCII								;Muestra el resultado					
 
	ir 11,10
	verSTR STR100

	mov di, 0
	ImprimirResultado:														;para conocer el largo de la cadena
	cmp di, 10
	je seguir
	mov dl, offset resultsum[di]												;se obtiene la direccion de inicio de la cadena la letra B, y se coloca en dl para mostrarse
	mov ah, 02h
	int 21h
	inc di
	jmp ImprimirResultado
	
	seguir:
	;verSTR STRSalto
	mov ah, 08h
	int 21h
	mov ah,00h															;Para establecer el modo de video y borra la pantalla
	mov al,03h															;modo
	int 10h																;Interrupción de video
	;ir  22,10
	;verSTR STR50
	;ir 23,10
	;verSTR STR60
	;ir 15,10
	;capcharv
	;mov opcion,al
	mov ah,4Ch																								
	int 21h	 
ret
endp

;Inicia el programa
EJECUTAR
	comien:
	call muestraMenu
	cmp opcion,115
	je saldeaqui
	fondo
	CALL IngresoN1
	CALL IngresoN2
	CALL CONVERT1
	CALL CONVERT2
	regresa:
	call proceso1 
	call proceso2
	cmp  opcion,118
	je comien
	cmp  opcion,115
	jne regresa 
	ir 24,10
saldeaqui:
FIN