.MODEL SMALL 

                                     
                                     
; --- FOR PRINTING A STRING ---

PRINT_STRING MACRO STRING 
    MOV AH, 9
    LEA DX, STRING      
    INT 21H
ENDM
                                     
                            

; ---- FOR PRINTING ANY PAGE TITLE ----

PAGE_TITLE MACRO TITLE
                 
    PRINT_STRING BARS    
    
    NEW_LINE
                    
    PRINT_STRING SPACES
    
    PRINT_STRING TITLE 
    
    NEW_LINE
    
    PRINT_STRING BARS       
    
    NEW_LINE

ENDM                           


                      
; ---- JUMPING TO A NEW LINE ----

NEW_LINE MACRO 
    
    ; LINE FEED 
    MOV AH, 2
    MOV DL, 10
    INT 21H
    
    ; CARRIAGE RETURN 
    MOV AH, 2
    MOV DL, 13
    INT 21H
ENDM                              


                      
; ---- FOR PRINTING ANYTHING OF BYTE LENGTH (SINGLE CHARACTER) ----

PRINT_BYTE MACRO SOMETHING 
    
    MOV AH,2
    MOV DL, SOMETHING 
    INT 21H

ENDM
                                    
                                    
                                    
; ----INPUT AN INT VAL ----

INPUT_INT MACRO 
        MOV AH, 1
        INT 21H
ENDM



LOGIN_SIGNUP_CHECKER MACRO VAL
    MOV BL, VAL
ENDM
   
   
; ---- LOGIN PAGE CREDENTIALS ----

LOGIN_PAGE_CREDENTIALS MACRO           
    
    CMP LOGIN_SIGNUP_OPTIONS_APPEAR, 0      
    JE SPECIFIC_OPITONS
    
        NEW_LINE
        NEW_LINE
        PRINT_STRING LOGIN_NOTICE
        NEW_LINE
        NEW_LINE 
        PRINT_STRING SIGNUP_NOTICE
        NEW_LINE
        NEW_LINE             
        NEW_LINE
        PRINT_STRING    YOUR_INPUT                
        INPUT_INT
        LOGIN_SIGNUP_CHECKER AL
    
    SPECIFIC_OPITONS:    
       ; CMP LOGIN_OPTION_ONLY,
;        CMP SIGNUP_OPTION_ONLY
        
    
    
ENDM


.STACK 100H

.DATA

; declare variables here       
  
FALSE DB 0
TRUE DB 1        
LOGGED_IN DB 0                         

BARS DB "========================================$"            
SPACES DB "          $"              
YOUR_INPUT DB "GIVE INPUT: $"

; ---- LOGIN PAGE CREDENTIALS ----

LOGIN_PAGE_TITLE DB "LOGIN OR SIGN UP $"                     
LOGIN_NOTICE DB ">>>>    PRESS 1 TO LOGIN $"
SIGNUP_NOTICE DB ">>>>    PRESS 2 TO SIGN UP $"     
LOGIN_SIGNUP_OPTIONS_APPEAR DB ?

.CODE
MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here
CALL PAGE_LOADER


 



 

;exit to DOS
               
MOV AX,4C00H
INT 21H

MAIN ENDP                   

PAGE_LOADER PROC     
    ; ---- CHECK WHETHER THE USER IS LOGGED IN OR NOT ----         
    MOV AL, TRUE
    CMP LOGGED_IN, AL
    JE WEBSITE               
    MOV LOGIN_SIGNUP_OPTIONS_APPEAR, AL
    CALL LOAD_LOGIN_PAGE 

    WEBSITE:
RET
PAGE_LOADER ENDP

LOAD_LOGIN_PAGE PROC
    PAGE_TITLE LOGIN_PAGE_TITLE       
    LOGIN_PAGE_CREDENTIALS
    RET
LOAD_LOGIN_PAGE ENDP
    END MAIN
