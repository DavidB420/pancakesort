use32
org 50000h
%include 'nxapi.inc'

;Initialize terminal display
call sys_term_setupScreen

;Print welcome prompt
mov esi,welcomeString
call sys_term_printString

;Get input
mov ecx,10
mov ebx,0
looper:
mov esi,prompt
call sys_term_printString
mov edi,buffer
mov al,50
call sys_term_getString
mov esi,buffer
mov edi,numberArr
call stringtoint
mov edi,numberArr
add edi,ebx
stosd
add ebx,4
call cleanbuffer
loop looper

;Sort using pancake algorithm
mov esi,numberArr
call pancakesort

;Output sorted values
mov esi,values
call sys_term_printString

mov esi,numberArr
mov ecx,10
outputloop:
push ecx
lodsd
call inttostr
mov al,' '
call sys_term_printChar
pop ecx
loop outputloop

;Wait for user to press key
mov esi,waitforkey
call sys_term_printString

keywait:
call sys_term_getkey
cmp byte [keydata],0
je keywait

ret

buffer times 50 db 0
welcomeString db 'Welcome to Pancake Sorting program!',0x0d,0
values db 0x0d, 'Sorted Values: ', 0
waitforkey db 0x0d, 'Press any key continue...', 0
prompt db 'Enter number: ',0
numberArr times 10 dd 0
multiplier dd 0
tmp dd 0

cleanbuffer:
push ecx
push eax
push edi
mov ecx,50
mov eax,0
mov edi,buffer
repe stosb
pop edi
pop eax
pop ecx
ret

pancakesort:
pushad
mov ecx,10
pancakeloop:
cmp ecx,1
jl donepancakeloop
mov esi,numberArr
mov edx,ecx
call findmax
mov esi,numberArr
mov edx,eax
call flip
mov esi,numberArr
mov edx,ecx
dec edx
call flip
skipflip:
dec ecx
jmp pancakeloop
donepancakeloop:
popad
ret

flip:
pushad
mov ebx,0
fliploop:
cmp ebx,edx
jg donefliploop
shl ebx,2
shl edx,2
mov eax,dword [esi+ebx]
mov dword [temp],eax
mov eax,dword [esi+edx]
mov dword [esi+ebx],eax
mov eax,dword [temp]
mov dword [esi+edx],eax
shr ebx,2
shr edx,2
inc ebx
dec edx
jmp fliploop
donefliploop:
popad
ret
temp dd 0

findmax:
pushad
mov ecx,0
mov edi,esi
dec edx
mov eax,0
mov ebx,0
findmaxloop:
cmp ecx,edx
jg donefindmaxloop
lodsd
sub esi,4
mov ebx,dword [edi]
cmp eax,ebx
jl skipsetebx
mov edi,esi
mov dword [tmp],ecx
skipsetebx:
add esi,4
inc ecx
jmp findmaxloop
donefindmaxloop:
popad
mov eax,dword [tmp]
ret

getStringlength:
pusha
mov ebx,eax
mov ecx,0
more:
cmp byte [ebx],0
je donelength
inc ebx
inc ecx
jmp more
donelength:
mov dword [tmp],ecx
popa
mov eax,dword [tmp]
ret

stringtoint:
pushad
mov eax,esi
call getStringlength
add esi,eax
dec esi
mov ecx,eax
xor ebx,ebx
xor eax,eax
mov dword [multiplier],1
loopconvert:
mov eax,0
mov byte al,[esi]
sub al,30h
mul dword [multiplier]
add ebx,eax
push eax
mov dword eax,[multiplier]
mov dx,10
mul dx
mov dword [multiplier],eax
pop eax
dec ecx
cmp ecx,0
je finish
dec esi
jmp loopconvert
finish:
mov dword [tmp],ebx
popad
mov dword eax,[tmp]
ret

inttostr:
pushad
mov ecx,0
mov ebx,10
pushit:
xor edx,edx
div ebx
inc ecx
push edx
test eax,eax
jnz pushit
popit:
pop edx
add dl,30h
pusha
mov dh,0
mov ax,dx
call sys_term_printChar
popa
inc edi
dec ecx
jnz popit
popad
ret