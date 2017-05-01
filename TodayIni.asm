;include advapi32.inc
includelib advapi32.lib
includelib kernel32.lib


;RtlMoveMemory                     PROTO :QWORD, :QWORD, :QWORD
utoa_ex                           PROTO :QWORD, :QWORD, :DWORD, :DWORD, :DWORD

IniGetTodayToggleTitle            PROTO
IniSetTodayToggleTitle            PROTO :QWORD
IniGetTodayToggleIcon             PROTO
IniSetTodayToggleIcon             PROTO :QWORD
IniGetShowTrayIconBalloon         PROTO
IniSetShowTrayIconBalloon         PROTO :QWORD
IniGetPersistIcon                 PROTO
IniSetPersistIcon                 PROTO :QWORD

.CONST


.DATA
hextbl  db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

.DATA?


.CODE
;**************************************************************************
;
;**************************************************************************
IniGetTodayToggleTitle PROC FRAME
    Invoke GetPrivateProfileInt, Addr szToday, Addr szCheckToggleTitle, 1, Addr TodayIni
    ret
IniGetTodayToggleTitle ENDP

;**************************************************************************
;
;**************************************************************************
IniSetTodayToggleTitle PROC FRAME dqValue:QWORD
    LOCAL szValue[16]:BYTE
    Invoke utoa_ex, dqValue, Addr szValue, 10d, FALSE, FALSE
    Invoke WritePrivateProfileString, Addr szToday, Addr szCheckToggleTitle, Addr szValue, Addr TodayIni
    mov rax, dqValue
    ret
IniSetTodayToggleTitle ENDP

;**************************************************************************
;
;**************************************************************************
IniGetTodayToggleIcon PROC FRAME
    Invoke GetPrivateProfileInt, Addr szToday, Addr szCheckToggleIcon, 1, Addr TodayIni
    ret
IniGetTodayToggleIcon ENDP

;**************************************************************************
;
;**************************************************************************
IniSetTodayToggleIcon PROC FRAME dqValue:QWORD
    LOCAL szValue[16]:BYTE
    Invoke utoa_ex, dqValue, Addr szValue, 10d, FALSE, FALSE
    Invoke WritePrivateProfileString, Addr szToday, Addr szCheckToggleIcon, Addr szValue, Addr TodayIni
    mov rax, dqValue
    ret
IniSetTodayToggleIcon ENDP


;**************************************************************************
;
;**************************************************************************
IniGetShowTrayIconBalloon PROC FRAME
    Invoke GetPrivateProfileInt, Addr szToday, Addr szCheckTrayIconBalloon, 0, Addr TodayIni
    ret
IniGetShowTrayIconBalloon ENDP

;**************************************************************************
;
;**************************************************************************
IniSetShowTrayIconBalloon PROC FRAME dqValue:QWORD
    LOCAL szValue[16]:BYTE
    Invoke utoa_ex, dqValue, Addr szValue, 10d, FALSE, FALSE
    Invoke WritePrivateProfileString, Addr szToday, Addr szCheckTrayIconBalloon, Addr szValue, Addr TodayIni
    mov rax, dqValue
    ret
IniSetShowTrayIconBalloon ENDP


;**************************************************************************
;
;**************************************************************************
IniGetPersistIcon PROC FRAME
    Invoke GetPrivateProfileInt, Addr szToday, Addr szCheckPersistIcon, 0, Addr TodayIni
    ret
IniGetPersistIcon ENDP

;**************************************************************************
;
;**************************************************************************
IniSetPersistIcon PROC FRAME dqValue:QWORD
    LOCAL szValue[16]:BYTE
    Invoke utoa_ex, dqValue, Addr szValue, 10d, FALSE, FALSE  
    Invoke WritePrivateProfileString, Addr szToday, Addr szCheckPersistIcon, Addr szValue, Addr TodayIni
    mov rax, dqValue
    ret
IniSetPersistIcon ENDP


;**************************************************************************
;
;**************************************************************************
utoa_ex PROC FRAME USES rbx value:QWORD, buffer:QWORD, radix:DWORD, sign:DWORD, addzero:DWORD
    LOCAL tmpbuf[34]:BYTE 
    mov rbx,rdx      ;buffer
    mov r10,rdx      ;buffer
    .if (!rcx)
        mov rax,rdx
        mov byte ptr[rax],'0'
        jmp done
    .endif 
    .if (r9b)
        mov byte ptr [rdx],2Dh           
        lea r10,[rdx+1]       
        neg rcx
    .endif
    lea r9, tmpbuf[33]                     
    mov byte ptr tmpbuf[33],0
    lea r11, hextbl
    .repeat
        xor edx,edx                      ;clear rdx               
        mov rax,rcx                      ;value into rax
        dec r9                           ;make space for next char
        div r8                           ;div value with radix (2, 8, 10, 16)
        mov rcx,rax                      ;mod is in rdx, save result back in rcx
        movzx eax,byte ptr [rdx+r11]     ;put char from hextbl pointed by rdx
        mov byte ptr [r9], al            ;store char from al to tmpbuf pointed by r9
    .until (!rcx)                        ;repeat if rcx not clear
    .if (addzero && al > '9')            ;add a leading '0' if first digit is alpha
        mov word ptr[r10],'x0'
        add r10, 2
        ;mov byte ptr[r10],'0'
        ;inc r10
    .endif
    lea r8, tmpbuf[34]                   ;start of the buffer in r8
    sub r8, r9                           ;that will give a count of chars to be copied
    invoke RtlMoveMemory, r10, r9, r8    ;call routine to copy
    mov rax,rbx                          ;return the address of the buffer in rax
done: ret
utoa_ex ENDP




