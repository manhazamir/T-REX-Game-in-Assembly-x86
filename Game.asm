[org 0x0100]

jmp start

hur: dw 2238
hur2: dw 2078
hur3: dw 2158
hur4: dw 2100
tickcount: dw 0
oldisr: dd 0
sc: db 'score:'
gg: db 'GAME OVER!'
dinoflag: db 0
gameflag: db 0
ignoreflag: db 0
dinoOnjumpflag: db 0
starspos: dw 166

;-----------Clear Screen----------
clrscr:
	push es
	push ax
	push di
	mov ax, 0xb800
	mov es, ax
	mov di, 0

	nextloc:
		mov word[es:di], 0x0720
		add di, 2
		cmp di, 4000
		jne nextloc

	pop di
	pop ax
	pop es
	ret


;------------Build Dino-----------
builddino:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di

	mov ax, 0xb800
	mov es, ax
	mov al, 80
	mul byte [bp+4]
	add ax, [bp+6]
	shl ax, 1
	mov di, ax

	mov ax, 0x0C02		
	cmp word[es:di], 0x0EDB
	je dinocrack
	
	mov word[es:di], ax
	add di, 160
	mov ax, 0x0C1E	
	cmp word[es:di], 0x0EDB
	je dinocrack
	
	mov word[es:di], ax
	add di, 160
	mov ax, 0x0C13		
	cmp word[es:di], 0x0EDB
	je dinocrack
	mov word[es:di], ax


	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 4

dinocrack:				;Call if dino collided on jump
mov word[cs:dinoOnjumpflag], 1
call Gameover
jmp dinoOnjump


;----------Remove Dino----------------
spacedino:
	push bp
	mov bp, sp
	push es
	push ax
	push cx
	push si
	push di

	mov ax, 0xb800
	mov es, ax
	mov al, 80
	mul byte [bp+4]
	add ax, [bp+6]
	shl ax, 1
	mov di, ax
	
	mov ax, 0x0720		;Head
	
	cmp word[es:di], 0x0EDB
	je xx
	
	mov word[es:di], ax
xx:
	add di, 160
	mov ax, 0x0720		;Body
	cmp word[es:di], 0x0EDB
	je xx1
	mov word[es:di], ax
xx1:
	add di, 160
	mov ax, 0x0720		;Legs
	cmp word[es:di], 0x0EDB
	je xx2	
	mov word[es:di], ax
xx2:
	
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 4
	
;------------Jump Dino----------------

jumpdino:
push bp
mov bp,sp
pusha
push es
mov ax, 0xb800
mov es, ax 
mov cx,5
mov bx, 11
up:
push 3
push bx
call spacedino


dec bx
push 3
push bx
call builddino


mov dx, 0xfffe

j1:
dec dx
cmp dx,0
jne j1
loop up

mov cx,0xfffe
stay:
loop stay

mov cx, 5
mov bx, 6

down:
push 3
push bx
call spacedino


inc bx
push 3
push bx
call builddino


mov dx, 0xfffe
j2:
dec dx
cmp dx, 0
jne j2
loop down

pop es
popa
pop bp
ret

;-----------Graphics------------------
stars:
    push bp
	mov bp,sp
	pusha	
    mov ax, 0xb800
	mov es, ax
	mov al,0x2A
	cmp word[bp+4],0
	jne other
	mov ah,0x0F
	jmp firstloc
	other:
	mov ah,0x00
	firstloc:
	mov di,[starspos]
	mov [es:di],ax
    	
	add di,30
	mov [es:di],ax
	add di,50
	mov [es:di],ax
	add di,130
	mov [es:di],ax
	add di,70
	mov [es:di],ax
	add di,200
	mov [es:di],ax
	add di,20
	mov [es:di],ax
	add di,76
	mov [es:di],ax
	add di,50
	mov [es:di],ax
	add di,150
	mov [es:di],ax
	add di,40
	mov [es:di],ax
	sub di,120
	mov [es:di],ax
	add di,184
	mov [es:di],ax
	add di,130
	mov [es:di],ax
	add di,70
	mov [es:di],ax
	
	popa
	pop bp
	ret 2

movestars:
	push 1
	call stars

	sub word [cs:starspos], 2
	cmp word[cs:starspos],160
	jne skipc
	add word [cs:starspos],160
	skipc:	
	push 0
	call stars
	ret

;-----------Print Score Number--------

printnum: push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax 
 
 mov ax, [bp+4] 
 mov bx, 10 
 mov cx, 0 
nextdigit: mov dx, 0 
 div bx 
 add dl, 0x30 
 push dx 
 inc cx 
 cmp ax, 0 
 jnz nextdigit 

 mov di, 140 
nextpos: pop dx 
 mov dh, 0x07 
 mov [es:di], dx 
 add di, 2 
 loop nextpos 
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
 ret 2


;---------Print Path-----------

printpath:
pusha
push es
mov ax,0xb800
mov es,ax
mov di, 160*14
mov al, 0x5E
mov ah, 0Ah		
mov cx,80
rep stosw
pop es
popa
ret

;--------Print Game Over---------

Gameover:
pusha
mov ax, 0xb800
mov es, ax

mov word[cs:gameflag], 1
mov di, 1504
mov si, gg
mov cx, 10
ggprint:
lodsb
mov ah,0Ch
stosw
loop ggprint

popa
ret



;------------Shapes for Hurdles---------------

;-----Shape #1----------
shape1:
pusha
mov ax, 0xb800
mov es, ax

mov ax, 0x0EDB
mov di, [hur4]

mov cx, 2
cont2:
mov si, di
add si,2
s9:
mov word[es:si], 0x0720
sub si, 160
loop s9

mov cx, 2
l12:
stosw
sub di, 2
sub di,160
loop l12

mov di, [hur4]		;2238
cmp di, 2080
jne changepop2

mov cx, 3
s8:
mov word[es:di], 0x0720
sub di, 160
loop s8

mov di, 2238
changepop2:
sub di, 2
mov word[hur4], di
popa
ret

;-----Shape #2----------

shape2:
push es
push ax
push cx
push si
push di
mov ax, 0xb800
mov es, ax

mov di, [hur2]

cmp di, 2078
je print2
mov si, di
add si,2
mov word[es:si], 0x0720

print2:
mov word[es:di], 0x0EDB
mov word[es:di-2], 0x0EDB
cmp di, 1920
jne pop1
mov word[es:di], 0x0720
sub di,2
mov word[es:di], 0x0720
mov di, 2080
pop1:
sub di,2
mov word[hur2], di
pop di
pop si
pop cx
pop ax
pop es
ret


;-----Shape #3----------
shape3:
pusha
mov ax, 0xb800
mov es, ax

mov ax, 0x0EDB
mov di, [hur3]

mov cx, 3

mov si, di
add si,2
s1:
mov word[es:si], 0x0720
sub si, 160
loop s1

mov cx, 3
l11:
stosw
sub di, 2
sub di,160
loop l11

mov di, [hur3]		;2158
cmp di, 2080
jne changepop

mov cx, 3
s2:
mov word[es:di], 0x0720
sub di, 160
loop s2

mov di, 2238
changepop:
sub di, 2
mov word[hur3], di
popa
ret


;--------Print and Move Hurdle---------

movehurdle:
push bp
mov bp,sp
push es
push ax
push cx
push si
push di

mov ax, 0xb800
mov es, ax

mov di, [bp+4]
cmp di, 2238
je print
mov si, di
add si, 2
mov word[es:si], 0x0720

print:
mov word[es:di], 0x0EDB
mov word[es:di-2], 0x0EDB


keepmoving:
cmp di, 2080
jne pops
mov word[es:di], 0x0720
sub di,2
mov word[es:di], 0x0720
add di, 2

pops:
sub di, 2
mov word[bp+4], di
pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 

;------------keyboard interrupt service routine------------

kbisr:
pusha
push es
mov ax, 0xb800
mov es, ax 
in al, 0x60 
cmp al, 0x39 			;Space Scan Code
jne nextcmp 
mov word [dinoflag],1	;Jump flag on

nextcmp:
cmp al,01
jne nomatch

nomatch:
mov al, 0x20
out 0x20, al 
pop es
popa
iret

;--------Check Collision-----------

checkcollision:
cmp word[hur], 2086
je check1

cmp word[hur3], 2086
je check1
jmp exit1
check1:
call Gameover
jmp loop1
	
	
;---------timer interrupt service routine---------
timer:
	push ax
	inc word[cs: tickcount]
    push word[cs:tickcount]
	call printnum
	call printpath
	call movestars
	
	cmp word[cs:tickcount], 50
	jl continue

	push word[hur]
	call movehurdle
	pop word[hur]
	call shape2
	call shape3	
	
	cmp word[hur], 2078
	jne continue
 	mov word[hur], 2238
	
	
continue:
cmp word[cs:dinoflag], 0	
je checkcollision

dinoOnjump:
cmp word[es:dinoOnjumpflag], 1
je loop1


exit1:
	mov al, 0x20
	out 0x20, al

	pop ax
	iret


;-------------Main------------

start:

	call clrscr
	
	;-----Making Dino-----------

    mov ax, 3
	push ax
	mov ax, 11
	push ax
	call builddino

	mov ax,0xb800
	mov es,ax
	
	;-----Print String-----------
	mov di, 122
	mov si, sc
	mov cx, 6
	scprint:
	lodsb
	mov ah,07h
	stosw
	loop scprint

;Timer+Keyboard Interrupts Start

wow:
xor ax, ax
mov es, ax ; point es to IVT base


mov ax, [es:8*4]
mov [oldisr], ax ; save offset of old routine
mov ax, [es:8*4+2]
mov [oldisr+2], ax ; save segment of old routine
cli 
mov word [es:8*4], timer; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+2
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2
sti
 
loop1:
cmp word[gameflag], 1
je theend

cmp word[dinoflag], 1
jne l2
call jumpdino 
mov word[dinoflag], 0
l2:
cmp word [ignoreflag],1
jne loop1
jmp wow


theend:
mov ax, 0x4c00
int 21h