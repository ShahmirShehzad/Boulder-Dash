;---------------------------->21L-5471
;---------------------------->Shahmir Shehzad


[org 0x0100]

jmp start

filename: db 30
	    db 0
	    times 30 db 0
filedata: times 2000 db 0
filesize: dw 0
filehandle: dd 0
filedata2: times 2000 db 0
filesize2: dw 0
filehandle2: dd 0
filedata3: times 2000 db 0
filesize3: dw 0
filehandle3: dd 0
defaultfile: db 'cave1.txt',0
attr: db 00h
msg1: db 'Enter filename$'
msg2:	db 'Incorrect filename$'
msg3:	db 'File size not 1600 bytes$'
msg4:	db 'File not found$'
msg5: db 'File size not 1600 bytes$'						;declarations
msg6: db 'File found and opened$'
msg7: db 'File size is okay$'
msg8: db 'File read$'
msg9:	db 'File not read$'
msg10: db 'Boulder Dash$'
msg11: db 'Arrow keys: Move$'
msg12: db 'Esc: Quit$'
msg13: db 'Score:$'
msg14: db 'Level:$'
msg15: db 'Game starting....$'
msg16: db 'Game over....$'
msg17: db 'Start game (press any key to begin)$'
msg18: db 'Exit game (press esc)$'
msg19: db 'Do you want to restart game ?$'
msg20: db 'File closed$'
msg21: db 'File not closed$'
msg22: db 'Level completed$'
msg23: db 'Your score is:$'
msg24: db 'File name not entered$'
msg25: db 'Default filename being used$'
msg26: db 'Lives :$'
errorFlag: db 0
Eflag: db 0
Rflag: db 0
Lflag: db 0
Uflag : db 0
Dflag: db 0
startFlag: db 0
restartFlag: db 0
skipFlag: db 0
score: dw 0
level: dw 1
lives: dw 2
bell: db 7, '$'
filename2: db 'cave2.txt', 0
filename3: db 'cave3.txt', 0
nextlvlFlag: db 0
maxLevel: dw 3

filename_empty:	mov ah, 09h
			mov dx, msg24
			int 21h				;print file empty msg

			mov ah, 0
			int 16h

			mov ah, 02h
			mov dl, 0ah
			int 21h

			mov ah, 09h
			mov dx, msg25
			int 21h

			mov ah, 02h
			mov dl, 0ah
			int 21h

			ret

file_notfound:	mov ah, 09h
			mov dx, msg4
			int 21h				;print file not found msg

			mov ah, 0
			int 16h

			mov byte[errorFlag], 1
			jmp returnUserInput

file_found:		mov ah, 09h
			mov dx, msg6			;print file found msg
			int 21h

			jmp reading


file_sizeOkay:	mov ah, 02h
			mov dl, 0ah
			int 21h
		
			mov ah, 09h
			mov dx, msg7
			int 21h
		
			mov ah, 02h
			mov dl, 0ah				;move cursor to newline
			int 21h

			mov ah, 3eh
			int 21h				;check if file has closed


			jc filenotclosed
			jnc fileclosed


fileclosed:		mov ah, 09h
			mov dx, msg20
			int 21h

			mov ah, 0						; print file read successfully msg
			int 16h

			jmp returnUserInput

filenotclosed:	mov ah, 09h
			mov dx, msg21
			int 21h

			mov ah, 0				
			int 21h

			mov byte[errorFlag], 1
			jmp returnUserInput

file_sizeNotOkay:	mov ah, 02h
			mov dl, 0ah
			int 21h
		
			mov ah, 0					;print file size not okay msg
			int 16h
		
			mov ah, 09h
			mov bx, [filehandle]
			mov dx, msg5
			int 21h

			mov byte[errorFlag], 1
			jmp returnUserInput

file_size:		cmp word[si], 0x640
			jne file_sizeNotOkay				;check file size and jump accordingly
			jmp file_sizeOkay					; 0x640 = 1600 bytes

file_read:		mov ah, 09h
			mov dx, msg8
			int 21h

			jmp file_size

file_notread:	mov ah, 09h
			mov dx, msg9
			int 21h

			mov ah, 0
			int 21h

			mov byte[errorFlag], 1
			jmp returnUserInput

clrscr:	push ax
		push es
		push di

		mov ax, 0xb800
		mov es, ax
		mov di, 0

next_cell:	mov word[es:di], 0x720						;clear screen function
		add di, 2
		cmp di, 4000
		jne next_cell

		pop di
		pop es
		pop ax
		ret

startscr:	push ax
		push es
		push di

		mov ax, 0xb800
		mov es, ax
		mov di, 0

next_strcell:	mov word[es:di], 0x0920						;clear screen function
		add di, 2
		cmp di, 4000
		jne next_strcell

		pop di
		pop es
		pop ax
		ret

userInput:	mov ah, 01h
		mov cx, 2607h                     ;hiding cursor
		int 10h

nameoutput:	push cs
		pop ds
		mov ah, 09h
		mov dx, msg1				;print enter filename msg
		int 21h
		
		mov ah, 02h
		mov dl, 0ah					;move cursor to new line
		int 21h

nameinput:	mov ah, 0ah
		mov dx, filename					;take user input and store in filename buffer
		int 21h

		mov ah, 02h
		mov dl, 0ah						;move cursor to new line
		int 21h
		
		mov ah, 0						;wait for key press
		int 16h

		mov si, filename
		inc si
		cmp byte[si], 0
		je near loadDefault
		mov dl, [si]
		mov dh, 0						;move 0 to end of input string stored in buffer
		inc dx
		add si, dx
		mov byte[si], 0
		
		mov ax, 0
		mov bx, 0
		mov cx, 0
		mov dx, 0

		mov ah, 3dh
		mov dx, filename+2				;move starting address of actual string in buffer to dx and open file
		int 21h

		mov bx, ax						; store file handle(ptr) in bx
		;mov [filehandle], bx 

		jc file_notfound					; depending on if file could be opened or not. cf will be set and jump made acc.
		jnc file_found

loadnextlvl1:	mov ax, 0
			mov bx, 0
			mov cx, 0
			mov dx, 0

		mov al, 0
		 mov ah, 3dh
		mov dx, filename2
		int 21h

		mov bx, ax
		mov [filehandle2], bx

		mov ah, 02h
		mov dl, 0ah					;set cursor to new line
		int 21h
		
		mov ah, 0
		int 16h					;wait for key press

		mov ah, 3fh
		mov cx, 2000				;read data from opened file
		mov dx, filedata2
		int 21h

		mov si, filesize2				;move actual bytes read to filesize in si
		mov [si], ax

		ret

loadnextlvl2:	mov ax, 0
			mov bx, 0
			mov cx, 0
			mov dx, 0

		mov al, 0
		 mov ah, 3dh
		mov dx, filename3
		int 21h

		mov bx, ax
		mov [filehandle3], bx

		mov ah, 02h
		mov dl, 0ah					;set cursor to new line
		int 21h
		
		mov ah, 0
		int 16h					;wait for key press

		mov ah, 3fh
		mov cx, 2000				;read data from opened file
		mov dx, filedata3
		int 21h

		mov si, filesize3				;move actual bytes read to filesize in si
		mov [si], ax

		ret

loadDefault: call filename_empty

		mov al, 0
		 mov ah, 3dh
		mov dx, defaultfile
		int 21h

		mov bx, ax

		jc file_notfound					; depending on if file could be opened or not. cf will be set and jump made acc.
		jnc file_found


reading:	mov ah, 02h
		mov dl, 0ah					;set cursor to new line
		int 21h
		
		mov ah, 0
		int 16h					;wait for key press

		mov ah, 3fh
		mov cx, 2000				;read data from opened file
		mov dx, filedata
		int 21h

		mov si, filesize				;move actual bytes read to filesize in si
		mov [si], ax

		jc file_notread				; depending on if file was read or not, cf will be set and jump made acc
		jnc file_read


print_file:	cmp byte[level], 2				; make comparisons and print according to level that has to be loaded
		je print_file2
		cmp byte[level], 3
		je print_file3
		call clrscr
		;jmp end
		;push bp					;call clear screen
		;mov bp, sp

		mov ax, 0xb800
		mov es, ax					; move di to starting point(row 3 and column 1, cell 241)
		mov di, 482
		
		mov bx, filedata
		mov si, filesize				;move filedata address to bx, filesize to cx
		mov cx, [si]
		jmp check_X

print_file2: call clrscr
		;jmp end
		;push bp					;call clear screen
		;mov bp, sp

		mov ax, 0xb800
		mov es, ax					; move di to starting point(row 3 and column 1, cell 241)
		mov di, 482
		
		mov bx, filedata2
		mov si, filesize2				;move filedata address to bx, filesize to cx
		mov cx, [si]
		jmp check_X

print_file3: call clrscr
		;jmp end
		;push bp					;call clear screen
		;mov bp, sp

		mov ax, 0xb800
		mov es, ax					; move di to starting point(row 3 and column 1, cell 241)
		mov di, 482
		
		mov bx, filedata3
		mov si, filesize3				;move filedata address to bx, filesize to cx
		mov cx, [si]

check_X: 	cmp byte[bx], 'x'				;start comparing and printing acc to file data
		jne check_B						; if data = x then print 7ab1 else skip and compare to next possible data type
		

		mov word[es:di], 0x7ab1				;print
		add di, 2

		inc bx						;inc di and pointer(bx). Dec cx as one element read and printed from file
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

check_B:	cmp byte[bx], 'B'
		jne check_W

		mov word[es:di], 0x3e09				; if next data = B then print 3e09 and inc/dec acc. Else move to next comparison
		add di, 2

		inc bx
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

check_W:	cmp byte[bx], 'W'
		jne check_D

		mov word[es:di], 0x66DB				; if next data = W then print 66db and inc/dec acc. Else move to next comparison
		add di, 2

		inc bx
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

check_D:	cmp byte[bx], 'D'
		jne check_T

		mov word[es:di], 0x7f04				; if next data = D then print 7f04 and inc/dec acc. Else move to next comparison
		add di, 2

		inc bx
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

check_T:	cmp byte[bx], 'T'
		jne check_R

		mov word[es:di], 0x4f7F				; if next data = T then print 4f7f and inc/dec acc. Else move to next comparison
		add di, 2

		inc bx
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

check_R:	cmp byte[bx], 'R'
		jne skipPrint

		;mov [currPos], di
		mov word[es:di], 0x8502				; if next data = R then print 3502 and inc/dec acc. Else move to next comparison
		add di, 2

		inc bx
		dec cx

		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

skipPrint:	inc bx
		dec cx
		add di, 2						; if all possible comparisons fail then just increment pointers and dont print
		jnz check_X					;till cx != 0 continue else jump to next label
		jmp returnPrintfile

printborders:	mov ax, 0xb800
			mov es, ax					;initialize for prinitng borders
			mov di, 320
			mov cx, 80					; set di to 320 byte (cell 150 / row 2 col 0) . cx to 80

printtop:	mov word[es:di], 0x66DB
		add di, 2						; print borders at top , repeat 80 times (1 full row)
		loop printtop

		mov di, 3680
		mov cx, 80						; initialize di to 3680 ( cell 1840 / row 24 col 0) , cx to 80

printbottom:	mov word[es:di], 0x66DB
			add di, 2
			loop printbottom				; print full row

		mov di, 320
		mov cx, 22

printleft:	mov word[es:di], 0x66DB				; intialize di to 320 ( row 2 col 0) , cx to 22
		add di, 160							; add 60 to di as printing vertically
		loop printleft


		mov di, 478					; initialize di to 478 ( row 2 col 79)
		mov cx, 22

printright:	mov word[es:di], 0x66DB
		add di, 160						; print vertically
		loop printright
		ret

printgameinfo:	mov dh, 0
			mov dl, 34
			mov bh, 0				; move cursor to row 0 col 34
			mov ah, 02h
			int 10h

			mov dx, msg10				; print msg
			mov ah, 09h
			int 21h

			mov dh, 1
			mov dl, 0				; move cursor to row 1 col 3
			mov bh, 0
			mov ah, 02h
			int 10h

			mov dx, msg11
			mov ah, 09h				; print msg
			int 21h

			mov dh, 1
			mov dl, 71
			mov bh, 0
			mov ah, 02h					; move cursor to row 1 col 68
			int 10h

			mov dx, msg12
			mov ah, 09h					; print msg
			int 21h

			mov dh, 24
			mov dl, 3					; move cursor to row 24 col 3
			mov bh, 0
			mov ah, 02h
			int 10h

			mov dx, msg13
			mov ah, 09h					; print msg
			int 21h

			mov dh, 24
			mov dl, 68
			mov bh, 0					; move cursor to row 24 col 68
			mov ah, 02h
			int 10h

			mov dx, msg14					; print msg
			mov ah, 09h
			int 21h

			mov dh, 24
			mov dl, 34
			mov bh, 0					; move cursor to row 24 col 34
			mov ah, 02h
			int 10h

			mov dx, msg26					; print msg
			mov ah, 09h
			int 21h

			mov ah, 01h
			mov cx, 2607h                     ;hiding cursor
			int 10h

			call printScore
			call printlevel				;printing score,level and lives
			call printLive

			ret
		
exit_game:		mov ah, 0
			int 16h
			cmp ah, 1				; wait for key stroke . if its esc (scancode 1) jump to end else wait
			jne near restartGame
			mov byte[restartFlag], 1
			call clrscr						; clear screen upon exiting
			mov byte[Eflag], 0
			ret

exitgame:	;call printendScreen
		;call restartGame
		call clrscr
		mov byte[Eflag], 0
		jmp end

returnUserInput:	ret					;return from userinput subroutine

returnPrintfile:	ret					;return from printfile subroutine

printstartScreen:	call startscr			;print start screen

			mov dh, 3
			mov dl, 32
			mov bh, 0				; move cursor to row 3 col 32
			mov ah, 02h
			int 10h

			mov dx, msg10				; print msg
			mov ah, 09h
			int 21h

			mov dh, 12
			mov dl, 24
			mov bh, 0				; move cursor to row 12 col 24
			mov ah, 02h
			int 10h

			mov dx, msg17				; print msg
			mov ah, 09h
			int 21h
	
			mov dh, 14
			mov dl, 24
			mov bh, 0				; move cursor to row 14 col 24
			mov ah, 02h
			int 10h

			mov dx, msg18				; print msg
			mov ah, 09h
			int 21h

			mov dh, 24
			mov dl, 79
			mov bh, 0				; move cursor to row 24 col 79
			mov ah, 02h
			int 10h

			mov ah, 0
			int 16h

			cmp ah, 1
			je near setstartFlag		;set startflag

			mov ah, 02h
			mov dl, 0ah				;move cursor to newline
			int 21h

			call clrscr				;clear screen
			
			mov dh, 12
			mov dl, 24
			mov bh, 0				; move cursor to row 12 col 24
			mov ah, 02h
			int 10h

			mov dx, msg15				; print msg
			mov ah, 09h
			int 21h

			mov cx, 30h
			mov dx, 9680h				;add 2.5sec delay
			mov ah, 86h
			int 15h

			ret

printendScreen:	call clrscr				;clear screen
			
			mov dh, 12
			mov dl, 24
			mov bh, 0				; move cursor to row 12 col 24
			mov ah, 02h
			int 10h

			mov dx, msg16				; print msg
			mov ah, 09h
			int 21h

			mov dh, 13
			mov dl, 24
			mov bh, 0				; move cursor to row 13 col 24
			mov ah, 02h
			int 10h

			mov dx, msg23				; print msg
			mov ah, 09h
			int 21h

			call printFinalscore			; print final score along with msg

			mov ah, 0
			int 16h				; wait for any key stroke

			mov ah, 02h
			mov dl, 0ah				; move cursor to newline
			int 21h

			ret

restartGame:	call clrscr
			mov word[score], 0			; upon restarting game reset variable to default values
			mov word[lives], 2
			mov word[level], 1

			mov dh, 10
			mov dl, 20
			mov bh, 0				; move cursor to row 10 col 20
			mov ah, 02h
			int 10h

			mov dx, msg19				; print msg
			mov ah, 09h
			int 21h
			
			mov dh, 12
			mov dl, 24
			mov bh, 0				; move cursor to row 12 col 24
			mov ah, 02h
			int 10h

			mov dx, msg17				; print msg
			mov ah, 09h
			int 21h
	
			mov dh, 14
			mov dl, 24
			mov bh, 0				; move cursor to row 14 col 24
			mov ah, 02h
			int 10h

			mov dx, msg18				; print msg
			mov ah, 09h
			int 21h

			mov ah, 0				; wait for key stroke
			int 16h

			cmp ah, 1					;;;;;;;
			je setRestartflag

			mov byte[restartFlag], 0			; reset restart flag to allow for next restart if user wishes
			call clrscr
			
			ret

setRestartflag: mov byte[restartFlag], 1

			call clrscr
			mov ah, 02h						;set restartflag
			mov dl, 0ah
			int 21h

			ret

setstartFlag:	mov byte[startFlag], 1

			call clrscr
			mov ah, 02h						;set start flag
			mov dl, 0ah
			int 21h

			ret

movement:	mov ax, 0xb800
		mov es, ax					; move di to starting point(row 3 and column 1, cell 241)
		mov di, 0
		mov cx, 3998				; recheckR will find R (di offset) by reading display memory
		
		call recheckR
		jmp checkKeypress				;check keypress will run in loop and wait for keypresses and respond accordingly
		ret

recheckR:	cmp word[es:di], 0x8502
		je near returnmovement
		jmp skipR

skipR:	sub cx, 2
		add di, 2						;find R (di offset) in a loop
		jnz recheckR					
		ret

checkKeypress:	mov ah, 0
			int 16h
			cmp ah, 1
			je setEscflag
			cmp ah, 0x48
			je setUpflag
			cmp ah, 0x4b
			je setLeftflag
			cmp ah, 0x4d				;wait for keypress
			je setRightflag
			cmp ah, 0x50
			je setDownflag
			jmp checkKeypress

setEscflag:	call exitgame				;exit game on esc press

setUpflag:	mov byte[Uflag], 1
		call moveUp
		jmp checkKeypress

setDownflag: mov byte[Dflag], 1
		call moveDown				;set flags upon press of different arrow press presses
		jmp checkKeypress

setRightflag: mov byte[Rflag], 1
		  call moveRight
		  jmp checkKeypress

setLeftflag: mov byte[Lflag], 1
		 call moveLeft
		 jmp checkKeypress

moveUp:	mov bx, di
		sub bx, 160
		call checkBoulderUp3
		call checkWallUp
		call checkBoulderUp1
		call checkDiamond
		call checkTarget					;here comparison will be made by checking if move to next location (offset bx)
		cmp byte[skipFlag], 1			; is legal or not. if it is rockford will be moved and values will update 
		je skipUp						;if not skipflag will be set and no movement will happen
		add bx, 160
		sub di, 160
		mov word[es:di], 0x8502				
		mov word[es:bx], 0x0720					; in case movement is legal offset di will be updated and flags will be reset
		mov byte[skipFlag], 0
		mov byte[Uflag], 0
		mov bx, di
		sub bx, 160
		call checkBoulderUp2			;additional check made here for UP movement as there can be boulder after 1 up move
		ret

skipUp:	;call bellSound
		mov byte[skipFlag], 0
		mov byte[Uflag], 0			;make bell sound on illegal move and reset flags
		ret

checkWallUp:	cmp word[es:bx], 0x66db
		je noMoveup					;no movement if wall is there
		ret

checkBoulderUp1:	cmp word[es:bx], 0x3e09
			je boulderCrush				;if boulder is there then jmp to bouldercrush
			ret

boulderCrush:	cmp byte[Uflag], 1
			jne noMoveup
			mov word[es:di], 0x8502			
			mov word[es:bx], 0x8e09			

			mov cx, 12h
			mov dx, 9680h				;delay to allow user to know why game is ending by blinking of boulder and rockford
			mov ah, 86h
			int 15h

			;call printendScreen
			sub word[lives], 1				;decrease rockford live by 1 and start level again
			cmp word[lives], 0
			je near exitgame_
			jmp Live

noMoveup:	call bellSound
		mov byte[skipFlag], 1				;make bellsound on illegal move and set skip flag
		ret

checkBoulderUp2:	cmp word[es:bx], 0x3e09
			jne returncheckBoulderUp
			mov word[es:di], 0x8502
			mov word[es:bx], 0x8e09			

			mov cx, 12h
			mov dx, 9680h
			mov ah, 86h				;additional check to see if boulder is above after 1 up move
			int 15h

			;call printendScreen
			sub word[lives], 1
			cmp word[lives], 0
			je near exitgame_
			jmp Live

checkBoulderUp3:	cmp word[es:bx], 0x3e09
			jne returncheckBoulderUp
			mov word[es:di], 0x8502
			mov word[es:bx], 0x8e09			

			mov cx, 12h
			mov dx, 9680h
			mov ah, 86h					;here check is made if boulder is directly above R when game is starting
			int 15h

			;call printendScreen
			sub word[lives], 1
			cmp word[lives], 0
			je near exitgame_
			jmp Live

returncheckBoulderUp:	ret

checkTarget:	cmp word[es:bx], 0x4f7f
			je levelComplete
			ret

levelComplete:	add word[level], 1
			mov word[es:di], 0x8502			;if target is reached display message and show final score
			mov word[es:bx], 0xcf7f			

			mov cx, [maxLevel]
			cmp word[level], cx
			jg near exitgame_				;check if maxLevel has been completed. if yes print exit screen
			mov cx, 12h
			mov dx, 9680h
			mov ah, 86h
			int 15h

			call levelCompleteMsg
			mov byte[nextlvlFlag], 1
			mov word[score], 0
			cmp word[level], 2				;make right jump under start label to correct level can be loaded and printed
			je near nextlvl1
			cmp word[level], 3
			je near nextlvl2


levelCompleteMsg:	call clrscr

			mov dh, 12
			mov dl, 24
			mov bh, 0				; move cursor to row 0 col 34
			mov ah, 02h
			int 10h

			mov dx, msg22				; print msg
			mov ah, 09h
			int 21h

			mov dh, 13
			mov dl, 24
			mov bh, 0				; move cursor to row 0 col 34
			mov ah, 02h
			int 10h

			mov dx, msg23				; print msg
			mov ah, 09h
			int 21h

			call printFinalscore

			mov cx, 30h
			mov dx, 9680h
			mov ah, 86h				;print final score and msg
			int 15h

			;mov ah, 0
			;int 21h

			mov byte[errorFlag], 0
			mov byte[startFlag], 0
			
			ret
			;jmp exitgame_

checkDiamond:	cmp word[es:bx], 0x7f04
			je incrementScore
			ret

incrementScore:	add word[score], 1
			mov word[es:di], 0x720				; if there is diamond, inc score by 1 and move R
			call printScore
			;call printgameinfo
			ret

printLive:		mov cx, 0
			mov dx, 0
			mov ax, 0
			mov bx, 0

			mov dh, 24					; print no. of lives
			mov dl, 41
			mov bh, 0				; move cursor to row 24 col 41
			mov ah, 02h
			int 10h

			mov cx, 0
			mov dx, 0
			mov ax, [lives]
			mov bx, 0

			jmp l1

printScore:		mov cx, 0
			mov dx, 0
			mov ax, 0
			mov bx, 0

			mov dh, 24					; print score
			mov dl, 12
			mov bh, 0				; move cursor to row 24 col 12
			mov ah, 02h
			int 10h

			mov cx, 0
			mov dx, 0
			mov ax, [score]
			mov bx, 0

			jmp l1

printlevel:		mov cx, 0
			mov dx, 0
			mov ax, 0
			mov bx, 0

			mov dh, 24					; print level
			mov dl, 76
			mov bh, 0				; move cursor to row 24 col 76
			mov ah, 02h
			int 10h

			mov cx, 0
			mov dx, 0
			mov ax, [level]
			mov bx, 0
			jmp l1

printFinalscore:	mov cx, 0
			mov dx, 0
			mov ax, 0
			mov bx, 0

			mov dh, 13					;print final score on level complete screen
			mov dl, 41
			mov bh, 0				; move cursor to row 13 col 41
			mov ah, 02h
			int 10h

			mov cx, 0
			mov dx, 0
			mov ax, [score]
			mov bx, 0
			jmp l1
			
l1:		cmp ax, 0
		je p1
		mov bx, 10
		div bx
		push dx
		inc cx					; common print function to convert numbers to ascii so they can be displayed
		xor dx, dx
		jmp l1

p1:		cmp cx, 0
		je exitPrint
		pop dx
		add dx, 48
		mov ah, 02h
		int 21h

		dec cx
		jmp p1

exitPrint:	ret

moveDown:	mov bx, di
		add bx, 160
		call checkWallDown
		call checkBoulderDown
		call checkDiamond
		call checkTarget					;checks for illegal move downwards
		cmp byte[skipFlag], 1
		je skipDown
		sub bx, 160
		add di, 160
		mov word[es:di], 0x8502
		mov word[es:bx], 0x0720					; if checks pass then update di value and move R
		mov byte[skipFlag], 0
		mov byte[Dflag], 0
		ret

skipDown:	mov byte[skipFlag], 0
		mov byte[Dflag], 0
		ret

checkWallDown:	cmp word[es:bx], 0x66db
		je noMoveDown					; check for Wall and boulder and make no move
		ret

checkBoulderDown:	cmp word[es:bx], 0x3e09
			je noMoveDown
			ret

noMoveDown:	call bellSound					; bell sound on illegal move
		mov byte[skipFlag], 1
		ret

returncheckBoulderDown:	ret


moveRight:	mov bx, di
		add bx, 2
		call checkWallRight
		call checkBoulderRight1
		call checkDiamond
		call checkTarget
		cmp byte[skipFlag], 1
		je skipUp
		sub bx, 2
		add di, 2						; checks for illegal move towards right
		mov word[es:di], 0x8502
		mov word[es:bx], 0x0720
		mov byte[skipFlag], 0
		mov byte[Rflag], 0
		mov bx, di					; if checks pass then update DI and move R
		sub bx, 160
		call checkBoulderRight2
		ret

skipRight:	mov byte[skipFlag], 0
		mov byte[Rflag], 0
		ret

checkWallRight:	cmp word[es:bx], 0x66db
			je noMoveRight
			ret

checkBoulderRight1:	cmp word[es:bx], 0x3e09
				je noMoveRight			; check for Wall and boulder (directly in path)
				ret

checkBoulderRight2:	cmp word[es:bx], 0x3e09
				jne returncheckBoulderRight

				mov word[es:di], 0x8502			; check for boulder above R
				mov word[es:bx], 0x8e09
			
			mov cx, 12h
			mov dx, 9680h
			mov ah, 86h
			int 15h

			;call printendScreen
			sub word[lives], 1
			cmp word[lives], 0
			je near exitgame_
			jmp Live

noMoveRight:	call bellSound				; bell sound on illegal move and no movement will happen
			mov byte[skipFlag], 1
			ret

returncheckBoulderRight:	ret

moveLeft:	mov bx, di
		sub bx, 2
		call checkWallLeft
		call checkBoulderLeft1
		call checkDiamond
		call checkTarget
		cmp byte[skipFlag], 1
		je skipUp
		add bx, 2					; same checks as done for right side
		sub di, 2
		mov word[es:di], 0x8502
		mov word[es:bx], 0x0720
		mov byte[skipFlag], 0
		mov byte[Lflag], 0
		mov bx, di
		sub bx, 160
		call checkBoulderLeft2
		ret

skipLeft:	mov byte[skipFlag], 0
		mov byte[Lflag], 0
		ret

checkWallLeft:	cmp word[es:bx], 0x66db
			je noMoveLeft				; same logic as right side
			ret

checkBoulderLeft1:	cmp word[es:bx], 0x3e09
				je noMoveLeft
				ret

checkBoulderLeft2:	cmp word[es:bx], 0x3e09
				jne returncheckBoulderLeft

			mov word[es:di], 0x8502
			mov word[es:bx], 0x8e09
			
			mov cx, 12h
			mov dx, 9680h
			mov ah, 86h
			int 15h

			;call printendScreen
			sub word[lives], 1
			cmp word[lives], 0
			je near exitgame_
			jmp Live

noMoveLeft:		call bellSound
			mov byte[skipFlag], 1
			ret

returncheckBoulderLeft:	ret

bellSound:	mov cx, 0
		mov dx, 0
		mov ax, 0
		mov bx, 0

		mov dh, 0
		mov dl, 22
		mov bh, 0				; move cursor to row 0 col 22 
		mov ah, 02h
		int 10h
		
		mov ax, 0
		mov dx, 0
		mov dx, bell			; print bell to product sound on illegal moves
		mov ah, 09h
		int 21h
		ret
	

returnmovement:	ret

;--------------------------------- START ---------------------------->
;---------------------------------		--------------------------->

start:	call userInput
		cmp byte[errorFlag], 1
		je end
restart:	call printstartScreen
		cmp byte[startFlag], 1
		je exitgame
Live:		mov word[score], 0				; flags will determine if user has asked for that particular task
		call print_file			;e.g if restartflag is 1 then it means user pressed relevant key on restart screen
		call printborders				; and so game will be restarted
		call printgameinfo
		call movement
nextlvl1:	mov byte[nextlvlFlag], 1
		call loadnextlvl1
		jmp Live
nextlvl2:	mov byte[nextlvlFlag], 1
		call loadnextlvl2
		jmp Live
exitgame_:	mov byte[nextlvlFlag], 0
		sub byte[level], 1
		call printendScreen				;resetting flags in case game is restarted
		call restartGame
		cmp byte[restartFlag], 0
		je restart

end:
mov ax, 0x4c00
int 0x21