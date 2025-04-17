section .data
	af_inet equ 2
	sock_stream equ 1
	o_rdonly equ 0

	socket equ 41
	bind equ 49
	listen equ 50
	accept equ 43
	read equ 0
	write equ 1
	open equ 2
	exit equ 60
	close equ 3

	address:
		dw af_inet
		dw 0x901f ; Port 8080 in network byte order
		dd 0
		dq 0

	buffer times 256 db 0
	buffer2 times 256 db 0
	path db 'index.html', 0

section .text
	global _start

_start:
	; Create socket
	MOV RDI, af_inet
	MOV RSI, sock_stream
	MOV RDX, 0
	MOV RAX, socket
	SYSCALL

	MOV r12, RAX

	; Bind socket
	MOV RDI, r12
	LEA RSI, [address]
	MOV RDX, 16
	MOV RAX, bind
	SYSCALL

	; Listen on socket
	MOV RDI, r12
	MOV RSI, 10
	MOV RAX, listen
	SYSCALL

accept_loop:
	; Accept connection
	MOV RDI, r12
	MOV RSI, 0
	MOV RDX, 0
	MOV RAX, accept
	SYSCALL

	MOV r13, RAX  ; Save client socket fd

	; Read from client
	MOV RDI, r13
	LEA RSI, [buffer]
	MOV RDX, 256
	MOV RAX, read
	SYSCALL

	; Open file
	LEA RDI, [path]
	MOV RSI, o_rdonly
	MOV RAX, open
	SYSCALL

	MOV r14, RAX  ; Save file

	; Read from file
	MOV RDI, r14
	LEA RSI, [buffer2]
	MOV RDX, 256
	MOV RAX, read
	SYSCALL

	; Write to client
	MOV RDI, r13
	LEA RSI, [buffer2]
	MOV RDX, 256
	MOV RAX, write
	SYSCALL

	; Close client socket
	MOV RDI, r13
	MOV RAX, close
	SYSCALL

	; Close file
	MOV RDI, r14
	MOV RAX, close
	SYSCALL

	JMP accept_loop

	; Exit program
	MOV RDI, 0
	MOV RAX, exit
	SYSCALL
