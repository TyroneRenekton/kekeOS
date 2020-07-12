; main leader program
; 
; LOADER_BASE_ADDR equ 0xA00
; LOADER_START_SECTOR equ 0x2

%include "boot.inc"

SECTION MBR vstart=0x7c00
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov sp, 0x7c00
	mov ax, 0xb800
	mov gs, ax

;use int 0x06, to clear screen

;AH, the function code, 0x06
;AL, line number, if value=0, means all

;BH, line property
;(CL, CH), left up (x, y)
;(DL, DH), right down (x, y)

; no return

	mov ax, 0x600
	mov bx, 0x700
	mov cx, 0
	;VGA text mode, a line can contains 80 char, and total 25 lines, 
	; so 0x18=24, 0x4f=79
	mov dx, 0x184f

	int 0x10

	mov byte [gs:0x00], '1'
	mov byte [gs:0x01], 0xA4

	mov byte [gs:0x02], ' '
	mov byte [gs:0x03], 0xA4

	mov byte [gs:0x04], 'M'
	mov byte [gs:0x05], 0xA4

	mov byte [gs:0x06], 'B'
	mov byte [gs:0x07], 0xA4

	mov byte [gs:0x08], 'R'
	mov byte [gs:0x09], 0xA4

	mov eax, LOADER_START_SECTOR
	mov bx, LOADER_BASE_ADDR
	mov cx, 4
	call rd_disk_m_16	; positive near invoke, 16 byte

	jmp LOADER_BASE_ADDR

rd_disk_m_16:
	mov esi, eax
	mov di, cx
	
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	
	mov eax, esi
	
	mov dx, 0x1f3
	out dx, al
	
	mov cl, 8
	shr eax, cl
	mov dx, 0x1f4
	out dx, al

	shr eax, cl
	mov dx, 0x1f5
	out dx, al

	shr eax, cl
	and al, 0x0f
	or al, 0xe0
	mov dx, 0x1f6
	out dx, al

	mov dx, 0x1f7
	mov al, 0x20
	out dx, al

.not_ready:
	nop

	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz .not_ready

	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
	mov dx, 0x1f0

.go_on_read:
	in ax, dx
	mov [bx], ax
	add bx, 2
	loop .go_on_read
	ret

	times 510-($-$$) db 0
	db 0x55, 0xaa
