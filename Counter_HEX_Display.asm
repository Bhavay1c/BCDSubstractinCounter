; Counter_HEX_Display.asm
;
; Author:               Bhavay Garg, Himanshu Shrestha, Mohammed Yagoub
; Modified by:          Bhavay Garg, Himanshu Shrestha, Mohammed Yagoub
; Student Number(s):    Bhavay Garg-041102440,Himanshu Shrestha-041105548,
;                         Mohammed Yagoub- 041043160
; Lab Section(s):       Section 302
; Course:               CST8216 Winter 2024
; Date:                  28 March 2024
;
; Description:   This counter is a "down counter", which continually counts
;                in BCD from START_COUNT to END_COUNT as defined in the
;                program's equ statements, the provided flowchart and video,
;                until Stop is pressed on the simulator, or Reset is pressed
;                on the Dragron12 Plus Hardware Training board, as follows
;
; Other info:   The speed of the counter is adjusted by changing DVALUE,
;               which changes the delay of displaying values in
;               the Delay Subroutine Value. Any delays > 255 ms will require
;               addition lines of code to obtain the required delay
;
;               ldaa    #DVALUE         ; delay for DVALUE milliseconds
;               jsr     Delay_ms
;
;               The counter will use the Hex Displays to display the count.
;
;               The count must be in a single register Accumulator A.
;
;               The range of the count can be altered by stopping the program,
;               changing the START_COUNT and END_COUNT values, re-assembling
;               and loading/running the program in the Simulator again.
;
;               START_COUNT must be >=99 and END_COUNT must be <= 00
;
;               While the START_COUNT and END_COUNT values have been initialized
;               for you, in order to be considered for full marks, your code
;               must permit the count range of the counter to be altered by
;               changing only the values of START_COUNT and END_COUNT and
;               the counter must be capable of counting in the range
;               of $99 BCD down to $00 BCD.
;
;               Note that there is no requirement for error checking that the
;               START_COUNT < END_COUNT.
;

; ***** DO NOT CHANGE ANY CODE BETWEEN THESE MARKERS *****
; Library Routines used in this software - you must load API.s19 into the
; Simulator to use the following subroutines
;
Config_Hex_Displays         equ        $2117
Delay_Ms                    equ        $211F
Hex_Display                 equ        $2139
Extract_Msb                 equ        $2144
Extract_Lsb                 equ        $2149

; Program Constants
STACK           equ     $2000
                                ; Port P (PPT) Display Selection Values
DIGIT3_PP0      equ     %1110   ; Left-most display LSB
DIGIT2_PP1      equ     %1101   ; 2nd from Left-most display MSB

                org     $1000
; ***** END OF DO NOT CHANGE ANY CODE BETWEEN THESE MARKERS *****

; Delay Subroutine Value
DVALUE  equ     #250          ; Delay value (base 10) 0 - 255 ms
                                ; 125 = 1/8 second <- good for Dragon12 Board

; Changing these values will change the Starting and Ending count
START_COUNT        equ     $15    ; Starting count
END_COUNT       equ     $0    ; Ending count.

        org     $2000           ; program code starting address
Start   lds     #STACK          ; stack location

        jsr     Config_HEX_Displays ; Use the Hex Displays to display the count

; Continually Count starting at START_COUNT down to END_COUNT to START_COUNT etc.

SCount   ldaa    #START_COUNT   ; Counter starting at START_COUNT

Loop    psha                   ; Store A onto the stack to save it
        jsr     Extract_Msb   ; Extract the mostSignificantByte in accumalator a
        ldab    #DIGIT3_PP0   ; Load B with left-most display to show MSB
        jsr     Hex_Display   ; Display the most significant byte
        ldaa    #DVALUE       ; Load A with Delay Value
        jsr     Delay_Ms      ; Delay the counter by Dvalue ms

        ldaa    0,sp          ; Load the return address as above jsr changed a
        jsr     Extract_Lsb   ; Extract the least significant byte
        ldab    #DIGIT2_PP1  ; Load B with 2nd LSB
        jsr     Hex_Display   ; Display the least significant byte
        ldaa    #DVALUE       ; Load A with Delay Value
        jsr     Delay_Ms      ; Delay the counter by DVALUE ms

        pula                 ;get the count from stack beacuse above code modified it

        cmpa    #END_COUNT    ; compare to see if end BCD
        beq     Reset_Count   ; If end count is reached, reset count
        suba    #$1            ; if not Subtract 1 from A

        psha                   ; push a onto the stack to save it
        jsr     Extract_Lsb   ; get hold off lsb in accumalator a to check bcd
        ; if the lsb val > 9 then not valid bcd then adjustment needed
        cmpa    #$09           ; compare with $09
        bgt     BCD_Adj         ;if >9 then call jsr BCD_Adj
        pula                    ; if not then give a the actual counter
        ; bcd substraction is valid


        bra     Loop          ; Do the count again

Reset_Count:
        ldaa    #START_COUNT  ; Reset count to START_COUNT
        bra     Loop          ; Repeat the counting loop


BCD_Adj:
        pula                  ; get the original counetr to change the values
        suba    #$06          ; sub 6 to make it valid bcd
       ; e.g 10 bcd - 1 gives f or all (1111) in this sub 6 get 1001 which is 9
       ; other words valid bcd similarly whether it is 90 bcd -1 is 8F not good

        bra     Loop