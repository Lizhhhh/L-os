; haribote-ipl
; TAB=4

		ORG		0x7c00			; 程序从哪里装入

; 以下是对标准FAT12格式软盘的描述

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; 可以自由书写引导扇形区的名称 (8字节)
		DW		512				; 1扇区的大小 (必须做成512)
		DB 		1 				; 集群大小 (必须设置在一个扇区)
		DW		1				; FAT从哪里开始 (一般从第一个部分开始)
		DB		2				; FAT的个数 (必须是2)
		DW		224				; 根目录区域的大小 (一般为224条目)
		DW 		2880			; 这个驱动器的大小 (必须是2880扇区)
		DB		0xf0			; 媒体类型 (必须是0xf0)
		DW		9				; FAT区域的长度 (必须设置为9个扇区)
		DW		18				; 1卡车有几个扇区 (必须是18)
		DW		2				; 头数 (必须为2)
		DD		0				; 因为不使用分区, 这里一定0
		DD 		2880			; 再写一次这个驱动器的大小
		DB		0,0,0x29		; 预先设置值
		DD		0xffffffff		; 音量序列号
		DB		"HARIBOTEOS "	; 磁盘名称 (11字节)
		DB		"FAT12   "		; 格式名称 (8字节)
		RESB	18				; 暂且空开18字节

; 程序主体

entry:
		MOV		AX,0			; 寄存器初始化
		MOV 	SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 读磁盘

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0 (正面)
		MOV 	CL,2			; 扇区2
readloop:						; 清零失败寄存器
		MOV 	SI,0			; 记录失败次数的寄存器

; 重新尝试
retry:
		MOV 	AH,0x02			; AH=0x02 : 读入磁盘(柱面0,磁头0,扇区2)
		MOV 	AL,1			; 1个扇区
		MOV 	BX,0
		MOV		DL,0x00			; A驱动器
		INT		0X13			; 调用磁盘BIOS	
		JNC		next			; 没出错的话跳转到next
		ADD 	SI,1			; 出错了,SI加1
		CMP		SI,5			; 比较SI与5
		JAE		error			; SI >=5时, 跳转到error
		; 复位软盘状态
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JMP 	entry
	
; 读取下一个扇区
; CL:扇区号, ES:读入的地址
next:
		; 把内存地址后移0x200
		MOV		AX,ES			
		ADD		AX,0x0020
		MOV 	ES,AX			; ES无法直接加 0x020
		ADD		CL,1			; 往CL里加1
		
		; 比较CL与18,如果小于18则跳转到readloop
		CMP		CL,18			
		JBE		readloop


fin:	
		HLT						; 让CPU停止, 等待指令
		JMP		fin				; 无限循环
		
error:	
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1
		CMP		AL,0
		
		JE		fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; 换行2次
		DB		"load error"	;
		DB		0x0a			; 换行
		DB		0
		
		RESB	0x7dfe-$		; 用0x00将代码不全至 0x7dfe-$
		
		DB		0x55, 0xaa