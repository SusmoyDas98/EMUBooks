.MODEL SMALL 

                                     
                                     
; --- FOR PRINTING A STRING ---

PRINT_STRING MACRO STRING 
    MOV AH, 9
    LEA DX, STRING      
    INT 21H
ENDM
                                     
                               
 
; ---- CLEARING THE ENTIRE SCREEN ----

CLEAR_SCREEN MACRO
    MOV AH, 6
    MOV AL, 0
    MOV BH, 7
    MOV CX, 0
    MOV DX, 6223
    INT 10H
    
    MOV AH, 2
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10H
    
ENDM
    

; ---- FOR PRINTING ANY PAGE TITLE ----

PAGE_TITLE MACRO TITLE
                 
    PRINT_STRING TITLE_BARS    
    
    NEW_LINE
                    
    PRINT_STRING SPACES
    
    PRINT_STRING TITLE 
    
    NEW_LINE
    
    PRINT_STRING TITLE_BARS       
    
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


                      
; ---- FOR PRINTING ANYTHING OF WORD LENGTH ----

PRINT_DIGIT MACRO SOMETHING 
    
    MOV AX, SOMETHING
    ADD AL, 48
    MOV DL, AL 
    MOV AH, 2
    INT 21H

ENDM
                                    
                                    
                                    
; ----INPUT AN INT VAL ----

INPUT_INT MACRO  
        ;MOV DL, VAL
        MOV AH, 1
        INT 21H
ENDM

            
            
; ---- ERROR_INPUT (ALSO TAKES ANOTHER INPUT) ----

ERROR_INPUT MACRO    
    NEW_LINE
    PRINT_STRING SPACED_DASHES     
    
    NEW_LINE
    PRINT_STRING SPACES
    PRINT_STRING END_MARK       
    PRINT_STRING INVALID_INPUT
    PRINT_STRING END_MARK 
    NEW_LINE                           
                          
    PRINT_STRING SPACED_DASHES        
    NEW_LINE         
 
ENDM
                         
                         
 
LOGIN_BOX MACRO
ENDM

SIGNUP_BOX MACRO
ENDM 

   
   
; ---- LOGIN PAGE CREDENTIALS ----

LOGIN_PAGE_CREDENTIALS MACRO           
    
    ;CMP LOGIN_SIGNUP_OPTIONS_APPEAR, 0      
    ;JE SPECIFIC_OPITONS
    
        NEW_LINE
        NEW_LINE
        PRINT_STRING LOGIN_NOTICE
        NEW_LINE
        NEW_LINE 
        PRINT_STRING SIGNUP_NOTICE
        NEW_LINE
        NEW_LINE             
        NEW_LINE    
        
        MOV CX, 5
        INPUT_LOP_BEGIN:
            PRINT_STRING    GIVE_INPUT
            PRINT_DIGIT CX                
            PRINT_STRING  MAX_ALLOWED_ATTEMPT
            INPUT_INT                  
            SUB AL, 48
            CMP AL, 1
            JE IS_1
            CMP AL, 2
            JE IS_2
            
            JMP ERROR_CALL

            IS_1:
            LOGIN_BOX  
            JMP CHECKER_END
    
            IS_2:
            SIGNUP_BOX     
            JMP CHECKER_END
            
            ERROR_CALL:
                ERROR_INPUT  
        
        LOOP   INPUT_LOP_BEGIN       
        PRINT_STRING RESTART
        
    
        CHECKER_END:
        ENDM


.STACK 100H

.DATA

; declare variables here       
  
FALSE DB 0
TRUE DB 1        
LOGGED_IN DB 0                         

TITLE_BARS DB "========================================$"            
SPACED_DASHES DB "- - - - - - - - - - - - - - - - - - - - -$"
END_MARK DB "|$"

SPACES DB "          $"              
GIVE_INPUT DB " GIVE INPUT ($"            
MAX_ALLOWED_ATTEMPT DB " ATTEMPTS REMAINING): $"     

RESTART DB " REFRESH THE SITE $"

INVALID_INPUT DB "  INVALID INPUT  $"        

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
    ;CLEAR_SCREEN
    RET
LOAD_LOGIN_PAGE ENDP
    END MAIN
