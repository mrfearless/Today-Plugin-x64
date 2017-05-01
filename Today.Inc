;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2015
;
; Today.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include CommCtrl.inc
include shellapi.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include masm64.inc
includelib masm64.lib

include DateTime_x64.inc
includelib DateTime_x64.lib


Today                   PROTO :QWORD
FindTodayIndexInList    PROTO :QWORD, :QWORD, :QWORD, :QWORD
IsTodayIsEntryUnique    PROTO :QWORD, :QWORD

; Misc functions
TD_LoadMenuIcon         PROTO :QWORD, :QWORD


DAYINFO                 STRUCT
    DayDate             DB 2 DUP (0)
    DayName             DB 132 DUP (0)
    DayIcon             DQ 0
DAYINFO                 ENDS



.CONST
MAX_TODAYIS_ENTRIES EQU 16

CRLF                TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

; Images & Icons
;---------------------------------------------------
ICO_TODAY           EQU 90  ;Main icon
ICO_X64DBG          EQU 97

; Menu Images: PNG format
IMG_MENU_TODAY      EQU 94 ; main today 16x16 icon in png format
IMG_MENU_CHECK      EQU 95 ; Checkmark (tick)
IMG_MENU_NOCHECK    EQU 96 ; No checkmark, just blank space
IMG_MENU_LTLI       EQU 92 ; Let the light in about menu

; Plugin Menu IDs
MENU_TODAY          EQU 1
MENU_OPTIONS        EQU 2
MENU_TOGGLE_TITLE   EQU 3
MENU_TOGGLE_ICON    EQU 4
MENU_SHOW_TRAYICON  EQU 5
MENU_PERSIST_ICON   EQU 6
MENU_ABOUT          EQU 7


IDD_PluginDlg       EQU 1000
IDC_PLUGINDLG_OK    EQU 1001

TRAYICON            EQU 20


.DATA
align 01
szToday             DB "Today",0
szTodayTrayInfo     DB "Today x64dbg plugin by mrfearless",0
szTodayMsgTitle     DB "Today x64dbg plugin",0
szTodayMsgText      DB "Written in x64 assembler by fearless - www.github.com/mrfearless",0
szTodayis           DB "Today is...",0
szOptions           DB "Options",0
szToggleTitle       DB "Change main title",0
szToggleIcon        DB "Change main icon",0
szShowTrayIcon      DB "Tray icon && balloon",0
szPersistIconDebug  DB "Persist icon change",0
szAbout             DB "About",0


szTodayLoaded       DB "Today loaded.",CRLF
szTodayUnloaded     DB "Today unloaded.",CRLF
szTodayInfo         DB 13,10         
                    DB "Today x64dbg plugin by fearless 2017 - www.LetTheLight.in",13,10
                    DB 13,10
                    DB "Today Features & Usage:",13,10
                    DB " - Lists days of interest: national, commemorative, awareness or international observance days",13,10
                    DB " - Change x64dbg title and/or icon for specific days",13,10  
                    IFDEF TRAYBALLOON
                    DB " - Show tray icon and balloon notification to highlight specific day",13,10
                    ENDIF
                    DB " - Option to allow icon change to persist whilst debugging (reverts to default icon otherwise)",13,10
                    DB 13,10,0


;---------------------------
; Ini settings
;---------------------------
szIni               DB "ini",0
TodayIni            DB MAX_PATH DUP (0)
szModuleFilename    DB MAX_PATH DUP (0)
szCheckToggleTitle  DB "ToggleTitle",0
szCheckToggleIcon   DB "ToggleIcon",0
szCheckPersistIcon  DB "PersistIcon",0
szCheckTrayIconBalloon DB "TrayIconBalloon",0
g_TodayToggleTitle  DQ 1
g_TodayToggleIcon   DQ 1
g_ShowTrayIcon      DQ 0
g_PersistIcon       DQ 0
g_MainIconChanged   DQ 0


;---------------------------
; Date / Time settings
;---------------------------
;dwTestDate          DD 18d,03d,2017d
;dbTestDate          DB 18d,03d,17d,20d
szDateTimeTitle     DB 32 DUP (0)
szDateTime          DB 32 DUP (0)

szTitle             DB 164 DUP (0)
szx64dbgTitle       DB "x64dbg - ",0
szTitleDateBreak    DB ": ",0
szTodayIsNothing    DB "Today is a normal day. Have a great day.",13,10,13,10,0 

szTodayIsNormal     DB ", have a great day.",13,10,13,10,0

szTodayIsTrayHead1  DB "Today is the ",0
szTodayIsHead1      DB 13,10
                    DB "Today is the ",0
szTodayIsBody       DB ":",13,10,13,10,0                    

szTodayIsHeading    DB 13,10
                    DB "Today is: ",13,10,13,10,0

szTrayTitle         DB 256 DUP (0)
szTrayMessage       DB 4096 DUP (0)


szTodayIsLineMsg    DB 512 DUP (0)
szTodayIsEntryMark  DB " * ",0
szTodayIsTrayEntry  DB "- ",0
szCRLF              DB 13d,10d,0


IconArray           DQ MAX_TODAYIS_ENTRIES DUP (0)
dqTotalTodayIs      DQ 0

TodayIs             DAYINFO MAX_TODAYIS_ENTRIES DUP (<>)
szMainTitle         DB 256 DUP (0)


hImgCheck           ICONDATA <> ; IMG_MENU_CHECK
hImgNoCheck         ICONDATA <> ; IMG_MENU_NOCHECK

hTI                 DQ 0
hTM                 DQ 0


.DATA?
align 08
hInstance           DQ ?
hMenuOptions        DQ ?
hx64dbgicon         DQ ?
hWndx64dbg          DQ ?


















