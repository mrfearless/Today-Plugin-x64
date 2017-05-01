;=========================================================================================
;
; LICENSE
;
; LTLI DateTime Library x64 v1.0.0.0
;
; Copyright (c) 2017 by KSR aka fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
;
; This software is provided 'as-is', without any express or implied warranty. In no
; event will the author be held liable for any damages arising from the use of this
; software.
;
; Permission is granted to anyone to use this software for any non-commercial program.
; If you use the library in an application, an acknowledgement in the application or
; documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave the
; original copyright notices intact and not misrepresent the origin of the software.
; It is not allowed to claim you wrote the original software. Modified files must have
; a clear notice that the files are modified, and not in the original state. This includes
; the name of the person(s) who modified the code. 
;
; If you want to distribute or redistribute any portion of this package, you will need
; to include the full package in it's original state, including this license and all
; the copyrights. 
;
; While distributing this package (in it's original state) is allowed, it is not allowed
; to charge anything for this. You may not sell or include the package in any commercial
; package without having permission of the author. Neither is it allowed to redistribute
; any of the package's components with commercial applications.
;
;=========================================================================================

;-----------------------------------------------------------------------------------------
; DateTime Prototypes
;-----------------------------------------------------------------------------------------
DTGetDateTime                   PROTO :QWORD, :QWORD
DTDateFormat                    PROTO :QWORD, :QWORD, :QWORD
DTDateToDwordDateTime           PROTO :QWORD, :QWORD
DTDwordDateToJulian             PROTO :QWORD
DTDateToJulianMillisec          PROTO :QWORD, :QWORD
DTDwordTimeToMillisec           PROTO :QWORD
DTDwordDateTimeToJulianMillisec	PROTO :QWORD, :QWORD
DTDatesDifference               PROTO :QWORD, :QWORD, :QWORD
DTDatesTimesDifference          PROTO :QWORD, :QWORD, :QWORD
_StripDateTimeString			PROTO :QWORD, :QWORD

;-----------------------------------------------------------------------------------------
; DateTime Structures
;-----------------------------------------------------------------------------------------


.CONST
;-----------------------------------------------------------------------------------------
; UPDATECHECKER - DateTime LIB CONSTANTS
;-----------------------------------------------------------------------------------------
; Constants: CC=Century, YY=Year, MM=Month, DD=Day, HH=Hours, MM=Minutes, DOW=Day Of Week 

; Reverse Date Formats
CCYYMMDDHHMMSSMS                EQU 1  ; Example 1974/03/27 14:53:01:00
CCYYMMDDHHMMSS                  EQU 2  ; Example 1974/03/27 14:53:01
CCYYMMDDHHMM                    EQU 3  ; Example 1974/03/27 14:53
CCYYMMDDHH                      EQU 4  ; Example 1974/03/27 14:53
CCYYMMDD                        EQU 5  ; Example 1974/03/27
CCYYMM                          EQU 6  ; Example 1974/03
YEAR                            EQU 7  ; Example 1974

; British Date Formats
DDMMCCYYHHMMSSMS                EQU 8  ; Example 27/03/1974 14:53:01:00
DDMMCCYYHHMMSS                  EQU 9  ; Example 27/03/1974 14:53:01
DDMMCCYYHHMM                    EQU 10  ; Example 27/03/1974 14:53
DDMMCCYY                        EQU 11 ; Example 27/03/1974
DDMM                            EQU 12 ; Example 27/03
DAY                             EQU 13 ; Example 27
 
; American Date Formats
MMDDCCYYHHMMSSMS                EQU 14 ; Example 03/27/1974 14:53:01:00
MMDDCCYYHHMMSS                  EQU 15 ; Example 03/27/1974 14:53:01				
MMDDCCYYHHMM                    EQU 16 ; Example 03/27/1974 14:53					
MMDDCCYY                        EQU 17 ; Example 03/27/1974						
MMDD                            EQU 18 ; Example 03/27			
MONTH                           EQU 19 ; Example 03

; Reverse Without Century Date Formats
YYMMDDHHMMSSMS                  EQU 20 ; Example 74/03/27 14:53:01:00
YYMMDDHHMMSS                    EQU 21 ; Example 74/03/27 14:53:01
YYMMDDHHMM                      EQU 22 ; Example 74/03/27 14:53
YYMMDD                          EQU 23 ; Example 74/03/27
YYMM                            EQU 24 ; Example 74/03
YY                              EQU 25 ; Example 74

; Other Date Formats
MMDDYY                          EQU 26 ; Example 03/27/74
DDMMYY                          EQU 27 ; Example 27/03/74
DAYOFWEEK                       EQU 28 ; Example Monday

; Time Formats
HHMMSSMS                        EQU 29 ; Example 14:53:01
HHMMSS                          EQU 30 ; Example 14:53:01		
HHMM                            EQU 31 ; Example 14:53
HH                              EQU 32 ; Example 14


LONGDDMMYY                      EQU 33
LONGMMDDYY                      EQU 34
LONGDDMM                        EQU 35
LONGMMDD                        EQU 36


; Useful Named Constants
TODAY                           EQU DDMMCCYYHHMMSS
NOW                             EQU DDMMCCYYHHMMSS
TIME                            EQU HHMM

; Named Date Constants
AMERICAN                        EQU MMDDYY
BRITISH                         EQU DDMMYY
FRENCH                          EQU DDMMYY
JAPAN                           EQU YYMMDD
TAIWAN                          EQU YYMMDD
MDY                             EQU MMDDYY
DMY                             EQU DDMMYY	
YMD                             EQU YYMMDD




















































