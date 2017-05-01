;=====================================================================================
; x64dbg Plugin SDK for Assembler x64 - fearless 2017
;
; Today.asm
;
;-------------------------------------------------------------------------------------
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

;TRAYBALLOON EQU 1

DEBUG64 EQU 1

IFDEF DEBUG64
    PRESERVEXMMREGS equ 1
    includelib \HJWasm\lib\x64\Debug64.lib
    DBG64LIB equ 1
    DEBUGEXE textequ <'\HJwasm\bin\DbgWin.exe'>
    include \HJWasm\include\debug64.inc
    .DATA
    RDBG_DbgWin	DB DEBUGEXE,0
    .CODE
ENDIF

Include x64dbgpluginsdk.inc               ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

Include Today.inc                   ; plugin's include file
include TodayIni.asm
include dayinfo.asm
include fooddays.asm


pluginit	        PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO                   ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
align 01
PLUGIN_NAME         DB "Today",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
align 08

PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DQ ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hInst:HINSTANCE, fdwReason:DWORD, lpvReserved:LPVOID
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov rax, hInst
        mov hInstance, rax
    .ENDIF
    mov rax,TRUE
    ret
DllMain Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp64 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC FRAME USES RBX initStruct:QWORD
    mov rbx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [rbx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [rbx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [rbx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov rbx, initStruct
    mov eax, [rbx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here
    ; Construct plugin's .ini file from module filename
    Invoke GetModuleFileName, 0, Addr szModuleFilename, SIZEOF szModuleFilename
    Invoke GetModuleFileName, hInstance, Addr TodayIni, SIZEOF TodayIni
    Invoke szLen, Addr TodayIni
    lea rbx, TodayIni
    add rbx, rax
    sub rbx, 4 ; move back past 'dp64' extention
    mov byte ptr [rbx], 0 ; null so we can use lstrcat
    Invoke szCatStr, rbx, Addr szIni ; add 'ini' to end of string instead   

	mov rax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp64 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC FRAME
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke GuiAddLogMessage, Addr szTodayUnloaded
    
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC FRAME USES RBX setupStruct:QWORD
    LOCAL hIconData:ICONDATA
    LOCAL hIconDataOptions:ICONDATA
    
    mov rbx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov rax, [rbx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, rax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax

    Invoke GuiGetWindowHandle
    mov hwndDlg, rax
    mov hWndx64dbg, rax    
    
    ; Do any setup here: add menus, menu items, callback and commands etc
    Invoke _plugin_menuaddentry, hMenu, MENU_TODAY, Addr szTodayis

    Invoke _plugin_menuadd, hMenu, Addr szOptions
    mov hMenuOptions, rax
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_TOGGLE_TITLE, Addr szToggleTitle
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_TOGGLE_ICON, Addr szToggleIcon
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_SHOW_TRAYICON, Addr szShowTrayIcon
    Invoke _plugin_menuaddentry, hMenuOptions, MENU_PERSIST_ICON, Addr szPersistIconDebug

    Invoke _plugin_menuaddseparator, hMenu
    Invoke _plugin_menuaddentry, hMenu, MENU_ABOUT, Addr szAbout

    Invoke TD_LoadMenuIcon, IMG_MENU_LTLI, Addr hIconData
    .IF rax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_ABOUT, Addr hIconData
    .ENDIF

    Invoke TD_LoadMenuIcon, IMG_MENU_CHECK, Addr hImgCheck
    Invoke TD_LoadMenuIcon, IMG_MENU_NOCHECK, Addr hImgNoCheck
    Invoke TD_LoadMenuIcon, IMG_MENU_TODAY, Addr hIconData
    .IF rax == TRUE
        Invoke _plugin_menuseticon, hMenu, Addr hIconData
        Invoke _plugin_menuseticon, hMenuOptions, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_TODAY, Addr hIconData
    .ENDIF

    Invoke IniGetTodayToggleTitle
    mov g_TodayToggleTitle, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_TITLE, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_TITLE, Addr hImgNoCheck
    .ENDIF
    
    Invoke IniGetTodayToggleIcon
    mov g_TodayToggleIcon, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_ICON, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_ICON, Addr hImgNoCheck
    .ENDIF

    Invoke IniGetPersistIcon
    mov g_PersistIcon, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_PERSIST_ICON, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_PERSIST_ICON, Addr hImgNoCheck
    .ENDIF
    
    IFDEF TRAYBALLOON
    Invoke IniGetShowTrayIconBalloon
    mov g_ShowTrayIcon, rax
    .IF rax == 1
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SHOW_TRAYICON, Addr hImgCheck
    .ELSE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SHOW_TRAYICON, Addr hImgNoCheck
    .ENDIF
    ENDIF

    Invoke LoadIcon, hInstance, ICO_X64DBG
    mov hx64dbgicon, rax
    
    Invoke GuiAddLogMessage, Addr szTodayInfo
    
    Invoke Today, TRUE
    
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    LOCAL hIcon:DWORD
    
    
    mov rbx, cbInfo
    mov eax, [rbx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_TODAY
        Invoke Today, FALSE
        mov g_MainIconChanged, 1
        
    .ELSEIF eax == MENU_TOGGLE_TITLE
        Invoke IniGetTodayToggleTitle
        .IF rax == 1
            mov g_TodayToggleTitle, 0
            Invoke IniSetTodayToggleTitle, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_TITLE, Addr hImgNoCheck
        .ELSE
            mov g_TodayToggleTitle, 1
            Invoke IniSetTodayToggleTitle, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_TITLE, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_TOGGLE_ICON
        Invoke IniGetTodayToggleIcon
        .IF rax == 1
            mov g_TodayToggleIcon, 0
            Invoke IniSetTodayToggleIcon, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_ICON, Addr hImgNoCheck
            
            ; reset icon back to x64dbg one
            Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hx64dbgicon
            mov g_MainIconChanged, 0
            
        .ELSE
            mov g_TodayToggleIcon, 1
            Invoke IniSetTodayToggleIcon, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_TOGGLE_ICON, Addr hImgCheck
        .ENDIF

    .ELSEIF eax == MENU_PERSIST_ICON
        Invoke IniGetPersistIcon
        .IF rax == 1
            mov g_PersistIcon, 0
            Invoke IniSetPersistIcon, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_PERSIST_ICON, Addr hImgNoCheck
        .ELSE
            mov g_PersistIcon, 1
            Invoke IniSetPersistIcon, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_PERSIST_ICON, Addr hImgCheck
        .ENDIF
    IFDEF TRAYBALLOON
    .ELSEIF eax == MENU_SHOW_TRAYICON
        Invoke IniGetShowTrayIconBalloon
        .IF rax == 1
            mov g_ShowTrayIcon, 0
            Invoke IniSetShowTrayIconBalloon, 0
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_SHOW_TRAYICON, Addr hImgNoCheck
        .ELSE
            mov g_ShowTrayIcon, 1
            Invoke IniSetShowTrayIconBalloon, 1
            Invoke _plugin_menuentryseticon, pluginHandle, MENU_SHOW_TRAYICON, Addr hImgCheck
        .ENDIF
    ENDIF
    
    .ELSEIF eax == MENU_ABOUT
        Invoke MessageBox, hwndDlg, Addr szTodayMsgText, Addr szTodayMsgTitle, MB_OK


    .ENDIF
    
    mov rax, TRUE
    
    ret

CBMENUENTRY endp



;=====================================================================================
; CBRESUMEDEBUG
;-------------------------------------------------------------------------------------
CBRESUMEDEBUG PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    .IF g_MainIconChanged == 1 && g_PersistIcon == 0
        ; reset icon back to x64dbg one
        Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hx64dbgicon
        mov g_MainIconChanged, 0
    .ENDIF

    mov rax, TRUE
    ret
CBRESUMEDEBUG ENDP


;=====================================================================================
; CBSTEPPED
;-------------------------------------------------------------------------------------
CBSTEPPED PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    .IF g_MainIconChanged == 1 && g_PersistIcon == 0
        ; reset icon back to x64dbg one
        Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hx64dbgicon
        mov g_MainIconChanged, 0
    .ENDIF

    mov rax, TRUE
    ret
CBSTEPPED ENDP


;=====================================================================================
; CBINITDEBUG
;-------------------------------------------------------------------------------------
CBINITDEBUG PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    .IF g_MainIconChanged == 1 && g_PersistIcon == 0
        ; reset icon back to x64dbg one
        Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hx64dbgicon
        mov g_MainIconChanged, 0
    .ENDIF

    mov rax, TRUE
    ret
CBINITDEBUG ENDP


;=====================================================================================
; CBATTACH
;-------------------------------------------------------------------------------------
CBATTACH PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    .IF g_MainIconChanged == 1 && g_PersistIcon == 0
        ; reset icon back to x64dbg one
        Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hx64dbgicon
        mov g_MainIconChanged, 0
    .ENDIF
    
    mov rax, TRUE
    ret
CBATTACH ENDP


;=====================================================================================
; Today 
;-------------------------------------------------------------------------------------
Today PROC FRAME USES RBX bInitFlag:QWORD
    LOCAL dqCurrentIndex:QWORD
    LOCAL dqTodayInfoAddress:QWORD
    LOCAL dqTodayDate:QWORD
    LOCAL pTodayIsData:QWORD
    LOCAL lpszTodayEntry:QWORD
    LOCAL nIcons:QWORD
    LOCAL dqIcon:QWORD
    LOCAL hIcon:QWORD

    
    Invoke RtlZeroMemory, Addr szTodayIsLineMsg, SIZEOF szTodayIsLineMsg
    
    mov dqTodayInfoAddress, 0
    mov dqTodayDate, 0
    mov nIcons, 0
    
    Invoke DTGetDateTime, Addr szDateTimeTitle, LONGDDMM
    Invoke DTGetDateTime, Addr szDateTime, MMDD
    
    xor rax, rax
    Invoke DTDateToDwordDateTime, Addr szDateTime, MMDD
    bswap eax
    shr eax, 16d
    ;PrintDec eax
    mov dqTodayDate, rax
    IFDEF DEBUG32
    PrintDec dqTodayDate
    ENDIF
    ;lea eax, dbTestDate
    ;mov ebx, [eax]
    ;PrintDec ebx
    
    ;lea eax, dwTestDate
    ;mov ebx, [eax]
    ;PrintDec ebx
    
    
    lea rax, TodayIs
    mov pTodayIsData, rax
    
    mov dqCurrentIndex, -1
    mov rax, 0
    .WHILE rax != -1
        IFDEF DEBUG32
        PrintText 'ALL DAYS'
        ENDIF
        Invoke FindTodayIndexInList, dqTodayDate, Addr AllDays, dqCurrentIndex, Addr dqTodayInfoAddress
        mov dqCurrentIndex, rax
        .IF rax != -1
            mov rax, dqTotalTodayIs
            .IF rax < MAX_TODAYIS_ENTRIES
                .IF rax > 0
                    Invoke IsTodayIsEntryUnique, dqTodayInfoAddress, Addr TodayIs
                    .IF rax == TRUE
                        Invoke RtlMoveMemory, pTodayIsData, dqTodayInfoAddress, SIZEOF DAYINFO
                        add pTodayIsData, SIZEOF DAYINFO
                        inc dqTotalTodayIs
                    .ELSE
                        IFDEF DEBUG32
                        PrintText 'Duplicate'
                        ENDIF
                    .ENDIF
                .ELSE
                    Invoke RtlMoveMemory, pTodayIsData, dqTodayInfoAddress, SIZEOF DAYINFO
                    add pTodayIsData, SIZEOF DAYINFO
                    inc dqTotalTodayIs
                .ENDIF
            .ENDIF
        .ENDIF
        mov rax, dqCurrentIndex
    .ENDW
    IFDEF DEBUG32
    PrintDec dqTotalTodayIs
    ENDIF
    
 
    
    mov dqCurrentIndex, -1
    mov rax, 0
    .WHILE rax != -1
        IFDEF DEBUG32
        PrintText 'FOOD_DAYS'
        ENDIF
        Invoke FindTodayIndexInList, dqTodayDate, Addr FOOD_DAYS , dqCurrentIndex, Addr dqTodayInfoAddress
        mov dqCurrentIndex, rax
        .IF rax != -1
            mov rax, dqTotalTodayIs
            .IF rax < MAX_TODAYIS_ENTRIES
                .IF rax > 0
                    Invoke IsTodayIsEntryUnique, dqTodayInfoAddress, Addr TodayIs
                    .IF rax == TRUE
                        Invoke RtlMoveMemory, pTodayIsData, dqTodayInfoAddress, SIZEOF DAYINFO
                        add pTodayIsData, SIZEOF DAYINFO
                        inc dqTotalTodayIs
                    .ELSE
                        IFDEF DEBUG32
                        PrintText 'Duplicate'
                        ENDIF
                    .ENDIF
                .ELSE
                    Invoke RtlMoveMemory, pTodayIsData, dqTodayInfoAddress, SIZEOF DAYINFO
                    add pTodayIsData, SIZEOF DAYINFO
                    inc dqTotalTodayIs
                .ENDIF
            .ENDIF
        .ENDIF
        mov rax, dqCurrentIndex
    .ENDW
    IFDEF DEBUG32
    PrintDec dqTotalTodayIs
    ENDIF
;    
    ;mov eax, dwTotalTodayIs
    ;mov ebx, SIZEOF DAYINFO
    ;mul ebx
    
    lea rbx, TodayIs
    mov pTodayIsData, rbx
    ;DbgDump ebx, eax
    
    
    .IF dqTotalTodayIs > 0
    
        ;Invoke szCopy, Addr szTodayIsHeading, Addr szTodayIsLineMsg
        Invoke szCopy, Addr szTodayIsHead1, Addr szTodayIsLineMsg
        Invoke szCatStr, Addr szTodayIsLineMsg, Addr szDateTimeTitle
        Invoke szCatStr, Addr szTodayIsLineMsg, Addr szTodayIsBody
        Invoke GuiAddLogMessage, Addr szTodayIsLineMsg

        Invoke szCopy, Addr szTodayIsTrayHead1, Addr szTrayTitle
        Invoke szCatStr, Addr szTrayTitle, Addr szDateTimeTitle
     
        Invoke RtlZeroMemory, Addr szTrayMessage, SIZEOF szTrayMessage
     
        mov dqCurrentIndex, 0
        mov rax, dqCurrentIndex
        .WHILE rax < dqTotalTodayIs
            mov rbx, pTodayIsData
            
            mov rax, [rbx].DAYINFO.DayIcon
            mov dqIcon, rax
            .IF rax != 0
                mov rax, nIcons
                mov rbx, 8d
                mul rbx
                lea rbx, IconArray
                add rbx, rax
                mov rax, pTodayIsData
                mov [rbx], rax
                inc nIcons
            .ENDIF
            
            mov rbx, pTodayIsData
            lea rax, [rbx].DAYINFO.DayName
            mov lpszTodayEntry, rax
            
            Invoke szCopy, Addr szTodayIsEntryMark, Addr szTodayIsLineMsg
            Invoke szCatStr, Addr szTodayIsLineMsg, lpszTodayEntry
            Invoke szCatStr, Addr szTodayIsLineMsg, Addr szCRLF
            Invoke GuiAddLogMessage, Addr szTodayIsLineMsg
            
            Invoke szCatStr, Addr szTrayMessage, Addr szTodayIsTrayEntry
            Invoke szCatStr, Addr szTrayMessage, lpszTodayEntry
            Invoke szCatStr, Addr szTrayMessage, Addr szCRLF


            add pTodayIsData, SIZEOF DAYINFO 
            inc dqCurrentIndex
            mov rax, dqCurrentIndex
        .ENDW
        
        Invoke szCopy, Addr szCRLF, Addr szTodayIsLineMsg     
        Invoke GuiAddLogMessage, Addr szTodayIsLineMsg
        

        
    .ELSE
    
        Invoke szCopy, Addr szTodayIsHead1, Addr szTodayIsLineMsg
        Invoke szCatStr, Addr szTodayIsLineMsg, Addr szDateTimeTitle    
        Invoke szCatStr, Addr szTodayIsLineMsg, Addr szTodayIsNormal
        ;Invoke szCopy, Addr szTodayIsNothing, Addr szTodayIsLineMsg
        Invoke GuiAddLogMessage, Addr szTodayIsLineMsg
        
    .ENDIF
    
    ;PrintDec nIcons
    .IF nIcons > 0

        .IF nIcons > 1
            invoke GetTickCount
            invoke nseed, rax
            invoke nrandom, nIcons
            mov rbx, 8
            mul rbx
            lea rbx, IconArray
            add rbx, rax
            mov rax, [rbx]
        .ELSE
            lea rbx, IconArray
            mov rax, [rbx]
        .ENDIF
        
        mov pTodayIsData, rax
        mov rbx, rax
        mov rax, [rbx].DAYINFO.DayIcon        
        mov dqIcon, rax
        
        .IF g_TodayToggleIcon == 1    
            Invoke LoadIcon, hInstance, dqIcon
            mov hIcon, rax
            
            Invoke SendMessage, hWndx64dbg, WM_SETICON, ICON_SMALL, hIcon
            
            mov g_MainIconChanged, 1
            
        .ENDIF

        .IF g_TodayToggleTitle == 1
            mov rbx, pTodayIsData
            lea rax, [rbx].DAYINFO.DayName
            mov lpszTodayEntry, rax
            
            Invoke DTGetDateTime, Addr szDateTimeTitle, LONGDDMM

            Invoke szCopy, Addr szx64dbgTitle, Addr szTitle
            Invoke szCatStr, Addr szTitle, Addr szDateTimeTitle
            Invoke szCatStr, Addr szTitle, Addr szTitleDateBreak
            Invoke szCatStr, Addr szTitle, lpszTodayEntry
            Invoke SetWindowText, hWndx64dbg, Addr szTitle

        .ENDIF
        
        .IF bInitFlag == TRUE
            IFDEF TRAYBALLOON
            .IF g_ShowTrayIcon == 1
                mov rbx, pTodayIsData
                lea rax, [rbx].DAYINFO.DayName
                mov lpszTodayEntry, rax
                ;Invoke TrayIconCreate, NULL, TRAYICON, hx64dbgicon, NULL ;hWndx64dbg Addr szTodayTrayInfo
                ;mov hTI, rax
                ;Invoke TrayIconShowNotification, hTI, lpszTodayEntry, Addr szTrayTitle, 5000, TMNI_INFO
                
            .ENDIF
            ENDIF
        .ENDIF
        
    .ENDIF
    
    ret
Today ENDP


;-------------------------------------------------------------------------------------
; Finds todays date in list and returns an index to that entry, or -1 if no more found
; index can be passed into dwStartIndex to continue searching from that point on for
; other calls. 
;-------------------------------------------------------------------------------------
FindTodayIndexInList PROC FRAME USES RBX dqDate:QWORD, lpdqList:QWORD, dqStartIndex:QWORD, lpIndexAddress:QWORD
    LOCAL dqCurrentIndex:QWORD
    LOCAL pDayInfoData:QWORD
    

    .IF lpdqList == NULL
        .IF lpIndexAddress != NULL
            mov rbx, lpIndexAddress
            mov rax, 0
            mov [rbx], rax
        .ENDIF
        mov rax, -1
        ret
    .ENDIF
    
    .IF dqDate == NULL
        .IF lpIndexAddress != NULL
            mov rbx, lpIndexAddress
            mov rax, 0
            mov [rbx], rax
        .ENDIF
        mov rax, -1
        ret
    .ENDIF
    
    .IF dqStartIndex == -1
        mov dqCurrentIndex, 0
        mov rax, lpdqList
        mov pDayInfoData, rax
    .ELSE
        mov rax, dqStartIndex
        inc rax
        mov dqCurrentIndex, rax
        mov rbx, SIZEOF DAYINFO
        mul rbx
        add rax, lpdqList
        mov pDayInfoData, rax
    .ENDIF
    
    .WHILE TRUE
        
        mov rbx, pDayInfoData
        movzx rax, word ptr [rbx].DAYINFO.DayDate
        .IF rax == 0
            .IF lpIndexAddress != NULL
                mov rbx, lpIndexAddress
                mov rax, 0
                mov [rbx], rax
            .ENDIF        
            mov rax, -1
            ret
        .ENDIF
        
        ;PrintDec eax
        ;PrintDec dwDate
        
        .IF rax == dqDate
            .IF lpIndexAddress != NULL
                mov rbx, lpIndexAddress
                mov rax, pDayInfoData
                mov [rbx], rax
            .ELSE
                mov rax, -1
                ret
            .ENDIF
            mov rax, dqCurrentIndex
            ret
        .ENDIF
        
        add pDayInfoData, SIZEOF DAYINFO
        inc dqCurrentIndex
    .ENDW


    ret
FindTodayIndexInList ENDP


;-------------------------------------------------------------------------------------
; Returns TRUE or FALSE
;-------------------------------------------------------------------------------------
IsTodayIsEntryUnique PROC FRAME USES RBX RCX RDX lpIndexAddress:QWORD, lpTodayIs:QWORD
    LOCAL dqCurrentIndex:QWORD
    LOCAL pTodayIsData:QWORD
    LOCAL lpString1:QWORD
    LOCAL lpString2:QWORD
    
    mov rax, lpTodayIs 
    mov pTodayIsData, rax
    
    mov dqCurrentIndex, 0
    mov rax, 0
    
    .WHILE rax < MAX_TODAYIS_ENTRIES
        mov rbx, pTodayIsData
        lea rax, [rbx].DAYINFO.DayName
        mov lpString1, rax
        mov rdx, lpIndexAddress
        lea rcx, [rdx].DAYINFO.DayName
        mov lpString2, rcx
        Invoke szCmp, lpString1, lpString2
        .IF rax == 0 ; no match
        
        .ELSE
            mov rax, FALSE
            ret
        .ENDIF
        
        add pTodayIsData, SIZEOF DAYINFO
        inc dqCurrentIndex
        mov rax, dqCurrentIndex
    .ENDW
    
    mov rax, TRUE
    
    ret

IsTodayIsEntryUnique ENDP



;=====================================================================================
; TD_LoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
TD_LoadMenuIcon PROC FRAME USES RBX dqImageResourceID:QWORD, lpIconData:QWORD
    LOCAL hRes:QWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dqImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInstance, hRes
        .IF rax != 0
            mov rbx, lpIconData
            mov [rbx].ICONDATA.size_, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov rbx, lpIconData
                    mov [rbx].ICONDATA.data, rax
                    mov rax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, FALSE
    .ENDIF    
    ret

TD_LoadMenuIcon ENDP


END DllMain
















