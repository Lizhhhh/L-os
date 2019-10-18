; hello-os
; TAB=4

		ORG		0x7c00		; 指明程序的装载地址
		
; 以下的记述用于标准FAT12格式的软盘

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"
		DW		512	
		DB		1
		DW		1
		DB		2
		DW		224
		DW		2880
		DB		0xf0
		DW		9
		DW		18
		DW		2
		DD		0
		DD		2880
		DB		0,0,0x29
		DD		0xffffffff
		DB		"HELLP-OS   "
		DB		"FAT12   "	
		RESB	18

; 程序核心

entry:
		MOV	AX,0		;	初始化寄存器
		MOV	SS,AX
		MOV SP,0x7c00
		MOV DS,AX
		MOV ES,AX
		
		MOV SI,msg
putloop:
		MOV AL,[SI]
		ADD SI,1		; 给SI加1
		CMP	AL,0
		
		JE	fin
		MOV	AH,0x0e		; 显示一个文字
		MOV	BX,15		; 指定字符颜色
		INT 0X10		; 调用显卡BIOS
		JMP putloop
fin:
		HLT				; 让CPU停止, 等待指令
		JMP	fin			; 无限循环
		
msg:
		DB	0X0a, 0x0a	; 换行2次
		DB  "How are you?"
		DB	0x0a		; 换行2次
		DB	0
		