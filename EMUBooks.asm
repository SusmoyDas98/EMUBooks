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

                                
 
; ---- FOR TAKING A LONG STRING AS INPUT ----

INPUT_LONG_STRING MACRO  BUFFER 
    LEA DX, BUFFER 
    MOV AH, 10
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
                         
                        
   
; ---- LOGIN PAGE CREDENTIALS ----

LOGIN_SIGNUP_PAGE_CREDENTIALS MACRO           
    
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
        INPUT_LOOP_BEGIN:
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
            MOV CX, 0
            CALL LOAD_LOGIN_BOX  
            JMP CHECKER_END
    
            IS_2:    
            MOV CX, 0
            CALL LOAD_SIGNUP_BOX     
            JMP CHECKER_END
            
            ERROR_CALL:
                ERROR_INPUT  
        
        LOOP   INPUT_LOOP_BEGIN       
        PRINT_STRING RESTART   
        
        
    
        CHECKER_END:   
        MOV CX, 0
        ENDM
                                              
                           
                           
; ---- LOGIN BOX CREDENTIALS ---- 

LOGIN_BOX_CREDENTIALS MACRO 
    ;LOCAL LOGIN_INPUT_LOOP_BEGIN, INPT_0, INPT_1, LOGIN_SUCCESSFUL,   LOGIN_ERROR_CALL       ,LOGIN_LIMIT_FINISHED , LOGIN_BOX_END   
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING EMAIL              
    INPUT_LONG_STRING EMAIL_BUFFER
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING PASSWORD              
    INPUT_LONG_STRING PASSWORD_BUFFER
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING SPACED_DASHES
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING COFIRM_BUTTON
    NEW_LINE 
    NEW_LINE 
    
    PRINT_STRING  GO_BACK_BUTTON
    NEW_LINE 
    NEW_LINE
                        
     PRINT_STRING SPACED_DASHES
    NEW_LINE
    NEW_LINE
    
    MOV BX , ITERATOR
     LOGIN_INPUT_LOOP_BEGIN:
        CMP BX, 0
        JE   LOGIN_LIMIT_FINISHED  
                 
        PRINT_STRING GIVE_INPUT 
        PRINT_DIGIT BX
        PRINT_STRING MAX_ALLOWED_ATTEMPT
        
        INPUT_INT        
        
        SUB AL, 48     
        
        CMP AL, 0        
        
        JE  INPT_0
        CMP AL, 1
        JE INPT_1
        
        JMP LOGIN_ERROR_CALL
        
        INPT_0:
         ;
        JMP ROOT_PAGE     
        
        
       INPT_1:            
        CALL CHECK_LOGIN_USER
        CMP USER_FOUND, 1
        JE LOGIN_SUCCESSFUL
        
        NEW_LINE
        PRINT_STRING LOGIN_FAILED
        NEW_LINE
        
        DEC BX
        JMP LOGIN_INPUT_LOOP_BEGIN
        
        LOGIN_SUCCESSFUL:
            NEW_LINE
            PRINT_STRING LOGIN_SUCCESS
            NEW_LINE
            MOV LOGGED_IN, 1
            JMP LOGIN_BOX_END
            
        ;JMP LOGIN_BOX_END
        
         LOGIN_ERROR_CALL:
            ERROR_INPUT          
            DEC BX
            JMP LOGIN_INPUT_LOOP_BEGIN
 

        LOGIN_LIMIT_FINISHED:
            PRINT_STRING RESTART   
            JMP ROOT_PAGE
         ;CALL LOAD_LOGIN_SIGNUP_PAGE  
    
        LOGIN_BOX_END:       
        
ENDM           



; ---- SIGN UP BOX CREDENTIALS ---- 

SIGNUP_BOX_CREDENTIALS MACRO              
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING EMAIL              
    INPUT_LONG_STRING EMAIL_BUFFER
    NEW_LINE
    NEW_LINE
    
    PRINT_STRING PASSWORD              
    INPUT_LONG_STRING PASSWORD_BUFFER
    NEW_LINE
    NEW_LINE     
    
    PRINT_STRING COFIRM_BUTTON
    NEW_LINE 
    NEW_LINE 
    
    PRINT_STRING  GO_BACK_BUTTON
    NEW_LINE 
    NEW_LINE            
    
     PRINT_STRING SPACED_DASHES
    NEW_LINE
    NEW_LINE
    
    MOV BX , ITERATOR
    SIGNUP_INPUT_LOOP_BEGIN:        
        CMP SIGN_UP_DONE, 1
        JNE NO_GO_BACK_ACTIVATED    
                NEW_LINE
                PRINT_STRING GIVE_INPUT_NO_BRACKS        
                INPUT_INT 
                SUB AL, 48
                CMP AL, 0
                JE  ROOT_PAGE
                DEC BX
                JMP SIGNUP_INPUT_LOOP_BEGIN
                
                
                
        NO_GO_BACK_ACTIVATED:
        CMP BX, 0
        JE   SIGNUP_LIMIT_FINISHED      
             
        PRINT_STRING GIVE_INPUT 
        PRINT_DIGIT BX
        PRINT_STRING MAX_ALLOWED_ATTEMPT
        
        INPUT_INT 
        SUB AL, 48
        CMP AL, 0
        JE  INPUT_0
        CMP AL, 1
        JE INPUT_1
        
        JMP SIGNUP_ERROR_CALL
        
        INPUT_0:
         ;CALL LOAD_LOGIN_SIGNUP_PAGE 
        JMP ROOT_PAGE     
        
        
        INPUT_1:
        MOV AH , 2                 
        CALL STORE_SIGNUP_USER
        
        NEW_LINE 
        PRINT_STRING SIGNUP_SUCCESS    
        MOV SIGN_UP_DONE, 1
        NEW_LINE
        
        ;JMP SIGNUP_BOX_END        
        
        PRINT_STRING GO_BACK_BUTTON
        NEW_LINE

        JMP  SIGNUP_INPUT_LOOP_BEGIN
        
        
        ;DEC BX           
        ;JMP SIGNUP_INPUT_LOOP_BEGIN
        ;JMP LOGIN_BOX_END
        
        SIGNUP_ERROR_CALL:
            ERROR_INPUT          
            DEC BX
            JMP SIGNUP_INPUT_LOOP_BEGIN
 

        SIGNUP_LIMIT_FINISHED:
            PRINT_STRING RESTART   
            JMP ROOT_PAGE
         ;CALL LOAD_LOGIN_SIGNUP_PAGE  
    
        SIGNUP_BOX_END:       
        
ENDM           
    
 
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
GIVE_INPUT_NO_BRACKS DB " GIVE  INPUT : $"

SPACES DB "          $"              
GIVE_INPUT DB " GIVE INPUT ($"            
MAX_ALLOWED_ATTEMPT DB " ATTEMPTS REMAINING TILL SITE GETS LOCKED): $"     

RESTART DB " REFRESH THE SITE $"

INVALID_INPUT DB "  INVALID INPUT  $"      

ITERATOR DW 5  

; ---- LOGIN SIGNUP PAGE VARIABLES ----

LOGIN_SIGNUP_PAGE_TITLE DB "LOGIN OR SIGN UP $"                     
LOGIN_NOTICE DB ">>>>    PRESS 1 TO LOGIN $"
SIGNUP_NOTICE DB ">>>>    PRESS 2 TO SIGN UP $"     
LOGIN_SIGNUP_OPTIONS_APPEAR DB ?                     
LOGIN_PAGE_TITLE DB " LOG  IN $"
SIGNUP_PAGE_TITLE DB " SIGN UP $"          


; ---- LOGIN, SIGNUP BOX VARIABLES ----                          


EMAIL DB ">>>> EMAIL (Max 100 Characters Allowed) : $ "
EMAIL_MAX_ALLOWED_SIZE DB 100 

EMAIL_BUFFER DB 100 
             DB ? 
             DB 100 DUP(?)

PASSWORD DB ">>>> PASSWORD (Max 100 Characters Allowed) : $ "
PASSWORD_MAX_ALLOWED_SIZE DB 100                                 
             
PASSWORD_BUFFER DB 100 
                DB ? 
                DB 100 DUP(?)                  
 
BRACU_DOMAIN DB "@g.bracu.ac.bd"
 
COFIRM_BUTTON DB ">>>> PRESS 1 TO CONFIRM $"
GO_BACK_BUTTON DB ">>>> PRESS 0 TO CANCEL AND GO BACK $"

USER_FOUND DB 0  
SIGN_UP_DONE DB 0

LOGIN_SUCCESS DB " LOGIN SUCCESSFUL $"    
LOGIN_FAILED DB " INVALID EMAIL OR PASSWORD $"

SIGNUP_SUCCESS DB " SIGN UP SUCCESSFUL $"
                                                 

; ---- STORAGES ----
TOTAL_USERS DB 0
EMAIL_STORAGE DB 100 DUP(100 DUP(?))
PASSWORD_STORAGE DB 100 DUP(100 DUP(?))     
IS_BRACU DB 100 DUP(0)



.CODE
MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here   
ROOT_PAGE:
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
    CALL LOAD_LOGIN_SIGNUP_PAGE 

    WEBSITE:
RET
PAGE_LOADER ENDP

LOAD_LOGIN_SIGNUP_PAGE PROC
    CLEAR_SCREEN
    PAGE_TITLE LOGIN_SIGNUP_PAGE_TITLE       
    LOGIN_SIGNUP_PAGE_CREDENTIALS     
    ;CLEAR_SCREEN
    RET
LOAD_LOGIN_SIGNUP_PAGE ENDP  


 
LOAD_LOGIN_BOX PROC
    CLEAR_SCREEN   
    
    ;LEA SI, 
    PAGE_TITLE LOGIN_PAGE_TITLE               
    LOGIN_BOX_CREDENTIALS
    RET
LOAD_LOGIN_BOX ENDP   



LOAD_SIGNUP_BOX PROC
    CLEAR_SCREEN   
    
    ;LEA SI, 
    PAGE_TITLE SIGNUP_PAGE_TITLE               
    SIGNUP_BOX_CREDENTIALS
    RET
LOAD_SIGNUP_BOX ENDP        



CHECK_BRACU_EMAIL PROC
    MOV AL, 0
    MOV BL, EMAIL_BUFFER + 1
    CMP BL, 14 ; 13 => LENGTH OF g.bracu.ac.bd
    JNE NOT_BRACU
    
    LEA SI, EMAIL_BUFFER ; START OF THE EMAIL 
    INC SI                                    
    
    MOV AL, EMAIL_BUFFER + 1 ; MOVING TO THE LAST 13 CHARACTERS
    SUB AL, 14
                                            
    MOV AH, 0
    ADD SI, AX
    
    LEA DI, BRACU_DOMAIN
    MOV CX, 14
    
   CHECK_DOMAIN:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE NOT_BRACU
    
    INC SI
    INC DI 
    
    LOOP CHECK_DOMAIN
    
    MOV AL, 1
    RET
   NOT_BRACU:
    MOV AL, 0
    RET

CHECK_BRACU_EMAIL ENDP



STORE_SIGNUP_USER PROC
    
    ; TOTAL NUMBER OF USERS
    MOV AL, TOTAL_USERS
    MOV AH, 0
     
    MOV BL, 100
    MUL BL
 
    MOV DI, AX
    
    ; STORING EMAIL
    
    LEA SI, EMAIL_BUFFER
    INC SI
    
    MOV CL, EMAIL_BUFFER + 1
    MOV CH, 0
    
    STORE_EMAIL:
    CMP CX, 0
    JE EMAIL_DONE
    
    MOV AL, [SI]
    MOV EMAIL_STORAGE[DI], AL
    
    INC SI
    INC DI
    
    DEC CX
    JMP STORE_EMAIL
    
    EMAIL_DONE:
    
    MOV AL, TOTAL_USERS
    MOV AH, 0
    
    MOV BL, 100
    MUL BL
    
    MOV DI, AX
    
    ; STORING PASSWORD 
    
    LEA SI, PASSWORD_BUFFER
    
    INC SI
    
    MOV CL, PASSWORD_BUFFER + 1
    MOV CH, 0
    
    STORE_PASSWORD:
    CMP CX, 0
    JE PASSWORD_DONE
    
    MOV AL, [SI]
    MOV PASSWORD_STORAGE[DI], AL
    
    INC SI
    INC DI
    
    DEC CX
    
    JMP STORE_PASSWORD
    
    PASSWORD_DONE:
    CALL CHECK_BRACU_EMAIL
    
    MOV BL, TOTAL_USERS
    MOV BH, 0
    
    MOV IS_BRACU[BX], AL
    
    ;ADDING NEW USER
    
    INC TOTAL_USERS
 
    
    RET
STORE_SIGNUP_USER ENDP          



CHECK_LOGIN_USER  PROC                
    MOV USER_FOUND ,0
    MOV BL, 0
    MOV BH, 0
    
    CHECK_USER_LOOP:
        ; CHECKING IF ANY USER AVAILABLE
        CMP BL, TOTAL_USERS
        JE LOGIN_NOT_FOUND
        
        ; FINDING STORAGE POSITION
        
        MOV AL,BL
        MOV AH, 0
        
        MOV DL, 100
        MUL DL
        
        MOV DI, AX
        
        ; CHECKING EMAIL
        
        LEA SI, EMAIL_BUFFER
        INC SI
        
        MOV CL, EMAIL_BUFFER + 1
        
        MOV CH, 0
        
     CHECK_EMAIL:
        CMP CX, 0
        JE EMAIL_CHECK_DONE
        
        MOV AL, [SI]
        CMP AL, EMAIL_STORAGE[DI]
        JNE NEXT_USER
        
        INC SI
        INC DI
        
        DEC CX
        JMP CHECK_EMAIL
        
     EMAIL_CHECK_DONE:
        ; FINDING PASSWORD AND STORAGE POSITION
        
        MOV AL, BL
        MOV AH, 0
        
        MOV DL, 100
        MUL DL
        
        MOV DI, AX
        
        ; CHEKING PASSWORD 
        
        LEA SI, PASSWORD_BUFFER
        INC SI
        
        MOV CL,PASSWORD_BUFFER + 1
        MOV CH, 0
        
     CHECK_PASSWORD:
        CMP CX, 0
        JE LOGIN_FOUND          
        
        MOV AL, [SI]
        CMP AL, PASSWORD_STORAGE[DI]
        JNE NEXT_USER
        
        INC SI
        INC DI
        
        DEC  CX
        
        JMP CHECK_PASSWORD
        
     LOGIN_FOUND:
        MOV USER_FOUND ,1 
        RET
        
     NEXT_USER:
        INC BL
        JMP CHECK_USER_LOOP
        
     LOGIN_NOT_FOUND:
        MOV USER_FOUND, 0  
        
    
    RET
CHECK_LOGIN_USER ENDP

    END MAIN
