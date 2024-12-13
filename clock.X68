*---------------------------------------------------------------
* Title      : clock.x68 
* Your Name  : Ethan Ramos
* Your ID    : 1274058
* Date       : 2024/11/28

* I have exclusive control over this submission via my password. 
* By including this statement in this header, I certify that
* I have read and understood the University policy in academic
* integrity and I assert that this work is my own. I have 
* not used any unapproved external resources including LLM 
* models. Furthermore, I certify that is assignment was 
* prepared by me specifically for this course.

*---------------------------------------------------------------
    ORG    $1000
START:      
            MOVE.L  #ISR6,$78        ;put the isr6 to the correct position in the vector table
            MOVE.L  #ISR7,$7C        ;put the isr7 to the correct position in the vector table

            MOVE.B  #0,D3              ;change
            MOVE.L  #32,D0           ;task number 32
            CLR.B   D1               ;parameter: display window
            TRAP    #15              ;system call
MAIN        CMP.B   #0,D3            ;compare 0 to d3 to check if count is 0
            BNE     MAIN             ;keep polling if not ready
            
            LEA     $E0000C,A1    ;load address of 1st position of seconds display into a1
            MOVE.L  #0,D2         ;clear d2
            MOVE.B  SECONDS,D2    ;load the seconds into d2
            DIVU.W  #$0A,D2       ;divide the seconds by 10 to get the 1st digit of seconds 
            BSR     WRITECHAR     ;write the char 
            SWAP    D2            ;swap to get the reminder which is the second digit of the seconds
            LEA     $E0000E,A1    ;load address of 2nd position of seconds display into a1
            BSR     WRITECHAR     ;write the char
                        
            
            LEA     $E00006,A1   ;load address of 1st position of minutes display into a1
            MOVE.L  #0,D2        ;clear d2
            MOVE.B  MINUTES,D2   ;load minutes into d2
            DIVU.W  #10,D2       ;divide the minutes by 10 to get the 1st digit of the minutes
            BSR     WRITECHAR    ;write the char 
            SWAP    D2           ;swap to get the reminder which is the second digit of the minutes
            LEA     $E00008,A1   ;load address of 2nd position of minutes display into a1
            BSR     WRITECHAR    ;write the char
            MOVE.B  #%1000000,$E0000A   ;write a dash 
            

            
            LEA     $E00000,A1  ;load address of 1st position of hours display into a1
            MOVE.L  #0,D2       ;clear d2
            MOVE.B  HOURS,D2    ;load the hours into d2
            DIVU.W  #10,D2      ;divide the hours by 10 to get the 1st digit of the minutes
            BSR     WRITECHAR   ;write the char
            SWAP    D2          ;swap to get the reminder which is the second digit of the hours
            LEA     $E00002,A1  ;load address of 2st position of hours display into a1
            BSR     WRITECHAR         ;write the char
            MOVE.B  #%1000000,$E00004 ;write a dash 
            MOVE.B  #40,D3            ; update the counter to restart the countdown        


            
            BRA     MAIN            
;D6 for seconds D4 for minutes D5 for hours
ISR6        ORI.W   #$0700,SR          ;set priority level to 7
            MOVEM.L A1/D2,-(A7)        ;save working registers
            ANDI.W  #$FEFF,SR          ;change to priority level 6
            CMPI.B  #0,D3              ;compare the counter to 0
            BEQ     EXIT               ;if it is 0 exit to avoid subtracting 0-1
            SUB.B   #1,D3              ;decrement counter
            BEQ     CODE               ;if counter is run the code
            MOVEM.L (A7)+,A1/D2        ;restore working registers
            RTE                        
CODE        ADD.B   #1,SECONDS         ;increment seconds and check if it needs to be reset
            CMPI.B  #60,SECONDS        ;compare 60 to seconds to see if reset is needed
            BNE     MINCHECK           ;if not check minutes
            ADD.B   #1,MINUTES         ;increment minutes and check if it needs to be reset
            MOVE.B  #0,SECONDS         ;reset the seconds
MINCHECK    CMPI.B  #60,MINUTES        ;compare 60 to minutes to see if reset is needed
            BNE     HOURCHECK          ;if not check hours
            ADD.B   #1,HOURS           ;increment hours and check if it needs to be reset
            MOVE.B  #0,MINUTES         ;reset the minutes
HOURCHECK   CMPI.B  #24,HOURS          ;see if hours needs to be reset 
            BNE     EXIT               ; if not exit
            MOVE.B  #0,HOURS           ;if so reset it    
           
EXIT        MOVEM.L (A7)+,A1/D2        ;restore working registers
            RTE
            
            
WRITECHAR   CMPI.B  #0,D2 ;D2 has the value to be written into the clock either hh mm or ss
            BNE     ONE
            MOVE.B  CONVERT,(A1) ;A1 of the desired clock position to be changed
            BRA     END
ONE         CMPI.B  #1,D2       ;labels one two three... etc are each a check to see what num 0-9 is in D2
            BNE     TWO         ;the method will write that corresponding value into the clock
            MOVE.B  CONVERT+1,(A1)
            BRA     END
TWO         CMPI.B  #2,D2
            BNE     THREE
            MOVE.B  CONVERT+2,(A1)
            BRA     END
THREE       CMPI.B  #3,D2
            BNE     FOUR
            MOVE.B  CONVERT+3,(A1)
            BRA     END
FOUR        CMPI.B  #4,D2
            BNE     FIVE
            MOVE.B  CONVERT+4,(A1)
            BRA     END
FIVE        CMPI.B  #5,D2
            BNE     SIX
            MOVE.B  CONVERT+5,(A1)
            BRA     END
SIX         CMPI.B  #6,D2
            BNE     SEVEN
            MOVE.B  CONVERT+6,(A1)
            BRA     END
SEVEN       CMPI.B  #7,D2
            BNE     EIGHT
            MOVE.B  CONVERT+7,(A1)
            BRA     END
EIGHT       CMPI.B  #8,D2
            BNE     NINE
            MOVE.B  CONVERT+8,(A1)
            BRA     END
NINE        CMPI.B  #9,D2
            BNE     END
            MOVE.B  CONVERT+9,(A1)
END         RTS
;ISR 7 resets the clock to 00-00-00
ISR7        ANDI.W  #$FFFF,SR  ;set priority level to 7
            MOVE.B  #0,HOURS   ;reset the hours minutes and seconds vars
            MOVE.B  #0,MINUTES
            MOVE.B  #0,SECONDS
            MOVE.B  #0,$E00000 ;move 0 into the correct positions separated by a dash (-)
            MOVE.B  #0,$E00002
            MOVE.B  #%1000000,$E00004
            MOVE.B  #0,$E00006
            MOVE.B  #0,$E00008
            MOVE.B  #%1000000,$E0000A
            MOVE.B  #0,$E0000C
            MOVE.B  #0,$E0000E
            MOVE.B  #0,D3
            RTE

HOURS       DC.B    $0
MINUTES     DC.B    $0 
SECONDS     DC.B    $0        
CONVERT     DC.B    $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F ;values to write 0-9 into the clock

* Put variables and constants here
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
