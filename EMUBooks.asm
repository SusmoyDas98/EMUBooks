.MODEL SMALL 

pause_continue macro
    CALL WAIT_FOR_ZERO
endm

; --- FOR PRINTING A STRING --- lagbe na

PRINT_STRING MACRO STRING
    MOV AH, 9
    LEA DX, STRING
    INT 21H
ENDM


; ---- CLEARING THE ENTIRE SCREEN ---- lagbe na

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


; ---- FOR PRINTING ANY PAGE TITLE ----  lagbe na

PAGE_TITLE MACRO TITLE
    PRINT_STRING TITLE_BARS
    GAP
    PRINT_STRING SPACES
    PRINT_STRING TITLE
    GAP
    PRINT_STRING TITLE_BARS
    GAP
ENDM


; ---- JUMPING TO A NEW LINE ---- lagbe na(NEW_LINE)

GAP MACRO
    MOV AH, 2
    MOV DL, 10
    INT 21H

    MOV AH, 2
    MOV DL, 13
    INT 21H
ENDM


; ---- FOR PRINTING ANYTHING OF BYTE LENGTH (SINGLE CHARACTER) ---- lagbe na

PRINT_BYTE MACRO SOMETHING
    MOV AH, 2
    MOV DL, SOMETHING
    INT 21H
ENDM


; ---- FOR TAKING A LONG STRING AS INPUT ---- lagbe na

INPUT_LONG_STRING MACRO BUFFER
    LEA DX, BUFFER
    MOV AH, 10
    INT 21H
ENDM


; ---- INPUT AN INT VAL (SINGLE KEY, ECHOED) ---- lagbe na

INPUT_INT MACRO
LOCAL INPUT_INT_RETRY
INPUT_INT_RETRY:
    MOV AH, 1
    INT 21H
    CMP AL, '0'
    JB INPUT_INT_RETRY
    CMP AL, '9'
    JA INPUT_INT_RETRY
ENDM


; ---- ERROR_INPUT (SIMPLE INVALID-INPUT NOTICE) ---- lagbe na

ERROR_INPUT MACRO
    GAP
    PRINT_STRING SPACED_DASHES
    GAP
    PRINT_STRING SPACES
    PRINT_STRING END_MARK
    PRINT_STRING INVALID_INPUT
    PRINT_STRING END_MARK
    GAP
    PRINT_STRING SPACED_DASHES
    GAP
ENDM


; ---- NEW_LINE (ALIAS FOR GAP, USED BY THE LOGIN/SIGNUP MACROS) ----

NEW_LINE MACRO
    GAP
ENDM


; ---- FOR PRINTING ANYTHING OF WORD LENGTH (USED IN "ATTEMPTS REMAINING" PROMPTS) ----

PRINT_DIGIT MACRO SOMETHING
    MOV AX, SOMETHING
    ADD AL, 48
    MOV DL, AL
    MOV AH, 2
    INT 21H
ENDM


; ---- LOGIN OR SIGNUP CHOICE PAGE ----

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


; ---- LOGIN BOX (SHARED BY BOTH ADMIN AND REGULAR USER) ----

LOGIN_BOX_CREDENTIALS MACRO
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
        MOV SP, INITIAL_SP
        JMP ROOT_PAGE
        
       INPT_1:
        CALL CHECK_LOGIN_USER
        CMP USER_FOUND, 1
        JE LOGIN_SUCCESSFUL
        
        NEW_LINE
        NEW_LINE
        PRINT_STRING SPACED_DASHES
        NEW_LINE
        PRINT_STRING LOGIN_FAILED
        NEW_LINE
        PRINT_STRING SPACED_DASHES
        NEW_LINE
        NEW_LINE
        
         PRINT_STRING RESTART
         JMP LOGIN_BOX_END
        
        DEC BX
        JMP LOGIN_INPUT_LOOP_BEGIN
        
        LOGIN_SUCCESSFUL:
            NEW_LINE
            NEW_LINE
            PRINT_STRING SPACED_DASHES
            NEW_LINE
            PRINT_STRING LOGIN_SUCCESS
            NEW_LINE
            PRINT_STRING SPACED_DASHES
            NEW_LINE
            NEW_LINE
            MOV LOGGED_IN, 1
            CALL CHECK_BRACU_EMAIL
            MOV CURRENT_BRACU, AL
            JMP LOGIN_BOX_END
            
         LOGIN_ERROR_CALL:
            ERROR_INPUT
            DEC BX
            JMP LOGIN_INPUT_LOOP_BEGIN

        LOGIN_LIMIT_FINISHED:
            PRINT_STRING RESTART
            MOV SP, INITIAL_SP
            JMP ROOT_PAGE
    
        LOGIN_BOX_END:
        
ENDM


; ---- SIGN UP BOX (REGULAR USERS ONLY - ADMIN DOES NOT SIGN UP) ----

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
                JE  INPUT_0
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
        MOV SP, INITIAL_SP
        JMP ROOT_PAGE
        
        INPUT_1:
        CALL CHECK_ADMIN_EMAIL_ONLY
        CMP AL, 1
        JE SIGNUP_ERROR_CALL

        CALL CHECK_EMAIL_ALREADY_USED
        CMP AL, 1
        JE SIGNUP_EMAIL_ALREADY_USED

        MOV AH , 2
        CALL STORE_SIGNUP_USER
        NEW_LINE
        NEW_LINE
        PRINT_STRING SPACED_DASHES
            NEW_LINE
    
        PRINT_STRING SIGNUP_SUCCESS
        NEW_LINE
        PRINT_STRING SPACED_DASHES
        NEW_LINE
        NEW_LINE
            
        MOV SIGN_UP_DONE, 1
        NEW_LINE
        
        PRINT_STRING GO_BACK_BUTTON
        NEW_LINE

        JMP  SIGNUP_INPUT_LOOP_BEGIN
        
        SIGNUP_EMAIL_ALREADY_USED:
            NEW_LINE
            NEW_LINE
            PRINT_STRING SPACED_DASHES
            NEW_LINE
            PRINT_STRING EMAIL_ALREADY_USED
            NEW_LINE
            PRINT_STRING SPACED_DASHES
            NEW_LINE
            NEW_LINE
            DEC BX
            JMP SIGNUP_INPUT_LOOP_BEGIN

        SIGNUP_ERROR_CALL:
            ERROR_INPUT
            DEC BX
            JMP SIGNUP_INPUT_LOOP_BEGIN

        SIGNUP_LIMIT_FINISHED:
            PRINT_STRING RESTART
            MOV SP, INITIAL_SP
            JMP ROOT_PAGE
    
        SIGNUP_BOX_END:
        
ENDM

.STACK 100H

.DATA

; declare variables here

;default string style from Sushmoy bhai

TITLE_BARS      DB "========================================$"
SPACED_DASHES   DB "- - - - - - - - - - - - - - - - - - - - -$"
END_MARK        DB "|$"
SPACES          DB "          $"
INVALID_INPUT   DB "  INVALID INPUT  $"
GIVE_INPUT_NO_BRACKS DB " GIVE INPUT : $"
CONTINUE_MSG    DB " PRESS 0 TO GO BACK $" 

; ---- LOGIN/SIGNUP SHARED PROMPTS ----
GIVE_INPUT           DB " GIVE INPUT ($"
MAX_ALLOWED_ATTEMPT  DB " ATTEMPTS REMAINING TO PRESS RIGHT KEY ): $"
RESTART              DB " REFRESH THE SITE $"
ITERATOR             DW 5

books_total equ 8
; equ meaning has no fixed data type can be 8/16 at a time

book_name_0 db "Harry Potter$"
book_name_1 db "Khoabnama$"
book_name_2 db "Lalshalu$"
book_name_3 db "The Brief History of Time$"
book_name_4 db "Deyal$"
book_name_5 db "Pather Panchali$"
book_name_6 db "Sapiens$"
book_name_7 db "Ekattorer Dinguli$"

book_names dw offset book_name_0, offset book_name_1, offset book_name_2, offset book_name_3, offset book_name_4, offset book_name_5, offset book_name_6, offset book_name_7

book_stock dw 0, 3, 2, 1, 0, 5, 7, 4

book_requests dw 8 dup(0)
total_requests_handled dw 0

any_out_of_stock db 0
any_pending db 0

is_admin db 0
LOGGED_IN db 0
CURRENT_BRACU db 0
SYS_TRUE db 1
SYS_FALSE db 0
INITIAL_SP dw 0

;analytics er part
total_stock_qty dw 0
out_of_stock_count dw 0
pending_req_total dw 0
most_req_idx db 0
most_req_count dw 0
                  
;Selection Text
LOGIN_SIGNUP_PAGE_TITLE DB "EMUBooks - LOGIN OR SIGN UP $"
LOGIN_NOTICE            DB ">>>>    PRESS 1 TO LOGIN $"
SIGNUP_NOTICE           DB ">>>>    PRESS 2 TO SIGN UP $"
LOGIN_SIGNUP_OPTIONS_APPEAR DB ?
LOGIN_PAGE_TITLE        DB "EMUBooks - LOG IN $"
SIGNUP_PAGE_TITLE       DB "EMUBooks - SIGN UP $"
MAIN_MENU_TITLE       DB "EMUBooks - MAIN MENU $"
STOCK_LIST_TITLE      DB "CURRENT BOOK STOCK $"
UPDATE_STOCK_TITLE    DB "UPDATE STOCK $"
REQUEST_TITLE         DB "REQUEST AN OUT OF STOCK BOOK $"
HANDLE_REQUEST_TITLE  DB "HANDLE OUT OF STOCK REQUESTS $"
ANALYTICS_TITLE       DB "SHOP ANALYTICS $"

; ---- MAIN MENU OPTIONS ----

MENU_1 DB "  PRESS 1  TO VIEW BOOK STOCK $"
MENU_2 DB "  PRESS 2  TO UPDATE STOCK $"
MENU_3 DB "  PRESS 3  TO REQUEST AN OUT OF STOCK BOOK $"
MENU_4 DB "  PRESS 4  TO HANDLE OUT OF STOCK REQUESTS $"
MENU_5 DB "  PRESS 5  TO VIEW SHOP ANALYTICS $"
MENU_6 DB "  PRESS 6  TO PURCHASE BOOKS (SHOPPING CART) $"       

; ---- GLOBAL NAVIGATION BUTTONS (SHOWN ON EVERY PAGE) ----
NAV_BACK_OPT   DB "  PRESS 0  TO GO BACK $"
NAV_LOGOUT_OPT DB "  PRESS 9  TO LOGOUT $"

; ---- SHARED PROMPTS / LABELS ----

SELECT_BOOK_PROMPT DB ">>>> ENTER BOOK NUMBER (0 TO GO BACK) : $"
ENTER_QTY_ADD       DB ">>>> ENTER QUANTITY TO ADD TO STOCK : $"
DOT_SPACE           DB ". $"
STOCK_LABEL         DB "   |   STOCK: $"
OUT_OF_STOCK_LABEL  DB "  <OUT OF STOCK> $"
PENDING_LABEL       DB "   |   PENDING REQUESTS: $"

; ---- STATUS MESSAGES ----

STOCK_UPDATED_MSG      DB " STOCK UPDATED SUCCESSFULLY $"
RESTOCK_NOTICE_1       DB " NOTE: $"
RESTOCK_NOTICE_2       DB " USER(S) WERE WAITING FOR THIS BOOK AND WILL NOW BE NOTIFIED $"
REQUEST_CONFIRM_MSG    DB " YOUR REQUEST HAS BEEN RECORDED. YOU WILL BE NOTIFIED ON RESTOCK $"
REQUEST_FULFILLED_MSG  DB " BOOK RESTOCKED. PENDING REQUESTS FOR THIS BOOK HAVE BEEN CLEARED $"
NO_OUT_OF_STOCK_MSG    DB " ALL BOOKS ARE CURRENTLY IN STOCK. NOTHING TO REQUEST $"
NO_PENDING_MSG         DB " THERE ARE NO PENDING OUT-OF-STOCK REQUESTS RIGHT NOW $"

; ---- ANALYTICS LABELS ----

TOTAL_TITLES_LABEL        DB " TOTAL BOOK TITLES : $"
TOTAL_STOCK_LABEL         DB " TOTAL STOCK QUANTITY (ALL BOOKS) : $"
OUT_OF_STOCK_COUNT_LABEL  DB " BOOKS CURRENTLY OUT OF STOCK : $"
PENDING_TOTAL_LABEL       DB " TOTAL PENDING OUT-OF-STOCK REQUESTS : $"
HANDLED_TOTAL_LABEL       DB " TOTAL REQUESTS FULFILLED (ALL TIME) : $"
MOST_REQUESTED_LABEL      DB " MOST REQUESTED OUT-OF-STOCK BOOK : $"
NONE_LABEL                DB "NONE $"
REQUESTED_TIMES_PREFIX    DB "  (REQUESTED $"
REQUESTED_TIMES_SUFFIX    DB " TIME(S)) $"                

; ---- LOGIN / SIGN UP DATA (SEPARATE OPTIONS, LIKE EMUBOOKS.ASM) ----
; Regular users must SIGN UP (option 2) before they can LOG IN (option 1).
; The admin does NOT sign up - the admin's email/password are predefined
; below and are checked first, whenever anyone attempts to log in.

ADMIN_MAIL      DB "admin"
ADMIN_MAIL_LEN  EQU 5
ADMIN_PASS      DB "admin"
ADMIN_PASS_LEN  EQU 5

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

COFIRM_BUTTON  DB ">>>> PRESS 1 TO CONFIRM $"
GO_BACK_BUTTON DB ">>>> PRESS 0 TO CANCEL AND GO BACK $"

USER_FOUND   DB 0
SIGN_UP_DONE DB 0

LOGIN_SUCCESS  DB " LOGIN SUCCESSFUL $"
LOGIN_FAILED   DB " INVALID EMAIL OR PASSWORD $"
SIGNUP_SUCCESS DB " SIGN UP SUCCESSFUL $"
EMAIL_ALREADY_USED DB " EMAIL ALREADY REGISTERED $"

; ---- SIGNED-UP USER STORAGE ----
TOTAL_USERS          DB 0
EMAIL_STORAGE        DB 100 DUP(100 DUP(?))
PASSWORD_STORAGE     DB 100 DUP(100 DUP(?))
EMAIL_LENGTH_STORAGE DB 100 DUP(0)

BRACU_DOMAIN DB "@g.bracu.ac.bd"

; ---- PURCHASE / SHOPPING CART DATA ----


book_prices dw 350, 250, 200, 450, 220, 300, 500, 280

cart_count      db 0
cart_book_idx   db 8 dup(0)
cart_qty        db 8 dup(0)

SHOP_BOOK_INDEX db 0
SHOP_BOOK_ID db 0
SHOP_QUANTITY db 0
SHOP_CART_INDEX db 0
SHOP_CART_FOUND db 0
SHOP_MENU_CHOICE db 0

CART_SUBTOTAL   DW 0
CART_TOTAL_ITEMS DW 0
CART_DISCOUNT_AMOUNT DW 0
CART_FINAL_AMOUNT DW 0

temp_cart_index db 0
cart_found      db 0
; ---- PURCHASE TEXT ----

PURCHASE_TITLE          DB " SHOPPING CART $"
CART_MENU_1              DB ">>>> PRESS 1 TO ADD BOOK $"
CART_MENU_2              DB ">>>> PRESS 2 TO REMOVE BOOK $"
CART_MENU_3              DB ">>>> PRESS 3 TO CHANGE QUANTITY $"
CART_MENU_4              DB ">>>> PRESS 4 TO VIEW CART $"
CART_MENU_6              DB ">>>> PRESS 6 TO AUTOMATIC BILL / CHECKOUT $"
CART_MENU_0              DB ">>>> PRESS 0 TO GO BACK $"

PRICE_LABEL              DB "   |   PRICE: $"
BOOK_ID_INPUT             DB ">>>> ENTER BOOK NUMBER: $"
QUANTITY_INPUT            DB ">>>> ENTER QUANTITY (1-8): $"
NEW_QUANTITY_INPUT        DB ">>>> ENTER NEW QUANTITY (1-8): $"
INVALID_QUANTITY          DB " INVALID QUANTITY $"
GIVE_INPUT_AGAIN          DB " GIVE INPUT AGAIN $"
INVALID_BOOK_MSG          DB " INVALID BOOK ID $"
ENTER_QTY_CART_PROMPT    DB ">>>> ENTER QUANTITY (1-8) : $"

BOOK_ADDED_MSG           DB " BOOK ADDED TO CART $"
BOOK_REMOVED_MSG         DB " BOOK REMOVED FROM CART $"
QTY_CHANGED_MSG          DB " QUANTITY UPDATED $"
CART_EMPTY_MSG           DB " YOUR CART IS EMPTY $"
CART_FULL_MSG            DB " CART IS FULL $"
NOT_IN_CART_MSG          DB " BOOK NOT IN CART $"
OUT_OF_STOCK_MSG         DB " THIS BOOK IS OUT OF STOCK $"
NOT_ENOUGH_STOCK_MSG     DB " NOT ENOUGH STOCK AVAILABLE $"

CART_QTY_LABEL           DB "   |   QTY: $"
CART_PRICE_LABEL         DB "   |   PRICE: $"

BILL_TITLE_TXT           DB "AUTOMATIC BILL $"
BILL_TOTAL_ITEMS_LABEL   DB " TOTAL ITEMS : $"
BILL_SUBTOTAL_LABEL      DB " TOTAL AMOUNT : $"
BILL_DISCOUNT_LABEL       DB " DISCOUNT : $"
BILL_FINAL_LABEL          DB " FINAL TOTAL : $"
DISCOUNT_APPLIED          DB " 20 PERCENT BRACU STUDENT DISCOUNT APPLIED $"
NO_DISCOUNT               DB " NO DISCOUNT APPLIED $"
BILL_READY                DB " BILL GENERATED SUCCESSFULLY $"
BILL_DONE_MSG             DB " PURCHASE COMPLETE. STOCK UPDATED. THANK YOU! $"

.CODE
MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
 
MOV INITIAL_SP, SP

; enter your code here

ROOT_PAGE:
    call page_loader
    
    cmp LOGGED_IN, 1
    JNE ROOT_PAGE

main_menu_loop:
    clear_screen
    page_title main_menu_title
    gap

    print_string menu_1
    gap

    cmp is_admin, 1
    JNE skip_menu_2

    print_string menu_2
    gap
    print_string menu_4
    gap
    print_string menu_5
    gap
    jmp show_admin_logout

    skip_menu_2:
    print_string menu_3
    gap

    show_menu_6:
    print_string menu_6
    gap
    print_string nav_logout_opt
    gap
    gap 

    jmp main_input

    show_admin_logout:
    print_string nav_logout_opt
    gap
    gap

    main_input:
    print_string GIVE_INPUT_NO_BRACKS
    input_int
    sub al, 30H

    cmp al, 9
    JE main_logout

    cmp al, 1
    JE main_opt_view

    cmp al, 2
    JNE main_check_3
    cmp is_admin, 1
    JNE main_menu_invalid
    JMP main_opt_update
    main_check_3:

    cmp al, 3
    JE main_opt_request

    cmp al, 4
    JNE main_check_5
    cmp is_admin, 1
    JNE main_menu_invalid
    JMP main_opt_handle
    main_check_5:

    cmp al, 5
    JNE main_check_6
    cmp is_admin, 1
    JNE main_menu_invalid
    JMP main_opt_analytics
    main_check_6:

    cmp al, 6
    JNE main_menu_invalid
    cmp is_admin, 1
    JE main_menu_invalid
    JMP main_opt_purchase

    main_menu_invalid:
    ERROR_INPUT
    jmp main_menu_loop

    main_opt_view:
        clear_screen
        page_title stock_list_title
        gap
        call list_all_books
        pause_continue
        jmp main_menu_loop
        
    main_opt_update:
        call update_stock_menu
        pause_continue
        jmp main_menu_loop
        
    main_opt_request:
        call request_out_of_stock_menu
        pause_continue
        jmp main_menu_loop
        
    main_opt_handle:
        call handle_requests_menu
        pause_continue
        jmp main_menu_loop
        
    main_opt_analytics:
        call shop_analytics
        jmp main_menu_loop                    

    main_opt_purchase:
        call purchase_menu
        jmp main_menu_loop       

    main_logout:
        mov LOGGED_IN, 0
        mov is_admin, 0
        mov CURRENT_BRACU, 0
        MOV SP, INITIAL_SP          ; reset stack so we can jump here from ANY nested page
        jmp ROOT_PAGE

MAIN ENDP 

; ===================================
; ============ LOGIN / SIGN UP SECTION (separate options, as in EMUBooks.asm) ============
; ===================================

page_loader proc
    mov al, SYS_TRUE
    cmp LOGGED_IN, al
    JE page_loader_done
    
    mov LOGIN_SIGNUP_OPTIONS_APPEAR, al
    call load_login_signup_page
    
    page_loader_done:
    ret
    page_loader endp


; ===================================
load_login_signup_page proc
    clear_screen
    page_title login_signup_page_title
    login_signup_page_credentials
    ret
    load_login_signup_page endp


; ===================================
load_login_box proc
    clear_screen
    page_title login_page_title
    login_box_credentials
    ret
    load_login_box endp


; ===================================
load_signup_box proc
    mov sign_up_done, 0
    clear_screen
    page_title signup_page_title
    signup_box_credentials
    ret
    load_signup_box endp


; ===================================
; Stores whatever is currently in EMAIL_BUFFER / PASSWORD_BUFFER as a new
; signed-up (regular) user.
store_signup_user proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov al, total_users
    mov ah, 0
    mov bl, 100
    mul bl
    mov di, ax
    
    lea si, email_buffer
    add si, 2
    mov cl, email_buffer+1
    mov ch, 0
    
    store_email_loop:
        cmp cx, 0
        JE store_email_done
        mov al, [si]
        mov email_storage[di], al
        inc si
        inc di
        dec cx
        jmp store_email_loop
        
    store_email_done:
    mov al, total_users
    mov ah, 0
    mov bl, 100
    mul bl
    mov di, ax
    
    lea si, password_buffer
    add si, 2
    mov cl, password_buffer+1
    mov ch, 0
    
    store_password_loop:
        cmp cx, 0
        JE store_password_done
        mov al, [si]
        mov password_storage[di], al
        inc si
        inc di
        dec cx
        jmp store_password_loop
        
    store_password_done:
    mov al, total_users
    mov ah, 0
    mov di, ax
    mov al, email_buffer+1
    mov email_length_storage[di], al

    inc total_users
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    store_signup_user endp


; ===================================
; Checks whatever is currently in EMAIL_BUFFER / PASSWORD_BUFFER.
; First compares against the predefined admin_mail / admin_pass; if that
; matches, logs the caller in as ADMIN. Otherwise looks the credentials up
; among users who have already signed up (STORE_SIGNUP_USER). Sets
; USER_FOUND (1/0) and, on success, IS_ADMIN (1/0).
check_login_user proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov user_found, 0
    mov is_admin, 0
    
    ; ---- CHECK ADMIN CREDENTIALS FIRST ----
    mov al, email_buffer+1
    cmp al, admin_mail_len
    JNE check_regular_users
    
    lea si, email_buffer
    add si, 2
    lea di, admin_mail
    mov cx, admin_mail_len
    
    check_admin_email:
        mov al, [si]
        cmp al, [di]
        JNE check_regular_users
        inc si
        inc di
        loop check_admin_email
    
    mov al, password_buffer+1
    cmp al, admin_pass_len
    JNE check_regular_users
    
    lea si, password_buffer
    add si, 2
    lea di, admin_pass
    mov cx, admin_pass_len
    
    check_admin_pass:
        mov al, [si]
        cmp al, [di]
        JNE check_regular_users
        inc si
        inc di
        loop check_admin_pass
    
    ; admin credentials matched
    mov user_found, 1
    mov is_admin, 1
    jmp check_login_done
    
    ; ---- CHECK REGULAR (SIGNED UP) USERS ----
    check_regular_users:
    mov bl, 0
    mov bh, 0
    
    check_user_loop:
        cmp bl, total_users
        JE login_not_found
        
        mov al, bl
        mov ah, 0
        mov dl, 100
        mul dl
        mov di, ax
        
        lea si, email_buffer
        add si, 2
        mov cl, email_buffer+1
        mov ch, 0
        
        check_email_match:
            cmp cx, 0
            JE email_match_done
            mov al, [si]
            cmp al, email_storage[di]
            JNE next_user
            inc si
            inc di
            dec cx
            jmp check_email_match
            
        email_match_done:
            mov al, bl
            mov ah, 0
            mov dl, 100
            mul dl
            mov di, ax
            
            lea si, password_buffer
            add si, 2
            mov cl, password_buffer+1
            mov ch, 0
            
        check_password_match:
            cmp cx, 0
            JE login_found
            mov al, [si]
            cmp al, password_storage[di]
            JNE next_user
            inc si
            inc di
            dec cx
            jmp check_password_match
            
        login_found:
            mov user_found, 1
            mov is_admin, 0
            jmp check_login_done
            
        next_user:
            inc bl
            jmp check_user_loop
            
        login_not_found:
            mov user_found, 0
    
    check_login_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    check_login_user endp


; ===================================
; Checks whether EMAIL_BUFFER currently holds EXACTLY the admin's email
; (ADMIN_MAIL), ignoring password entirely. Used during SIGN UP to make
; sure a regular user cannot register using the admin's email. Returns
; AL = 1 if it matches, AL = 0 otherwise.
check_admin_email_only proc
    push bx
    push cx
    push dx
    push si
    push di
    
    mov al, email_buffer+1
    cmp al, admin_mail_len
    JNE check_admin_email_only_no
    
    lea si, email_buffer
    add si, 2
    lea di, admin_mail
    mov cl, admin_mail_len
    mov ch, 0
    
    check_admin_email_only_loop:
        mov al, [si]
        cmp al, [di]
        JNE check_admin_email_only_no
        inc si
        inc di
        loop check_admin_email_only_loop
    
    mov al, 1
    jmp check_admin_email_only_done
    
    check_admin_email_only_no:
        mov al, 0
    
    check_admin_email_only_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
    check_admin_email_only endp

; ===================================
; Checks whether EMAIL_BUFFER matches an email that has already been
; registered by a regular user. Returns AL = 1 if found, AL = 0 otherwise.
check_email_already_used proc
    push bx
    push cx
    push dx
    push si
    push di

    mov bl, 0
    mov bh, 0

    check_email_used_user_loop:
        cmp bl, total_users
        je check_email_used_not_found

        ; Compare the stored email length first.
        mov al, bl
        mov ah, 0
        mov di, ax
        mov al, email_buffer+1
        cmp al, email_length_storage[di]
        jne check_email_used_next_user

        ; DI = user index * 100 for the email storage record.
        mov al, bl
        mov ah, 0
        mov dl, 100
        mul dl
        mov di, ax

        lea si, email_buffer
        add si, 2
        mov cl, email_buffer+1
        mov ch, 0

        check_email_used_char_loop:
            cmp cx, 0
            je check_email_used_found
            mov al, [si]
            cmp al, email_storage[di]
            jne check_email_used_next_user
            inc si
            inc di
            dec cx
            jmp check_email_used_char_loop

        check_email_used_next_user:
            inc bl
            jmp check_email_used_user_loop

        check_email_used_found:
            mov al, 1
            jmp check_email_used_done

    check_email_used_not_found:
        mov al, 0

    check_email_used_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
    check_email_already_used endp

; ===================================
PRINT_NUM PROC
    push ax
    push bx
    push cx
    push dx
    
    MOV BX, 10
    MOV CX, 0
    
    PN_DIVIDE:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNZ PN_DIVIDE
    
    PN_PRINT:
    POP DX
    ADD DL, 30H
    MOV AH, 2
    INT 21H
    LOOP PN_PRINT
    
    pop dx
    pop cx
    pop bx
    pop ax
    RET
    PRINT_NUM ENDP 

; ===================================
print_book_entry proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    print_string spaces
    
    mov ax, bx
    inc ax
    call print_num
    print_string dot_space
    
    mov si, bx
    add si, si
    mov dx, book_names[si]
    mov ah, 9
    int 21h
    
    print_string stock_label
    mov ax, book_stock[si]
    call print_num
    
    print_string price_label
    mov ax, book_prices[si]
    call print_num
    
    cmp book_stock[si], 0
    jne print_book_entry_ok
    print_string out_of_stock_label
    
    print_book_entry_ok:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    print_book_entry endp 

; ===================================
print_book_request_entry proc
    push ax
    push bx
    push cx
    push dx
    
    call print_book_entry
    
    print_string pending_label
    mov si, bx 
    add si, si
    mov ax, book_requests[si]
    call print_num
    gap
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    print_book_request_entry endp
    
    
; ===================================
list_all_books proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 0
    list_loop:
        cmp bl, books_total
        je list_all_book_done
        
        call print_book_entry
        gap
        
        inc bx
        jmp list_loop
        
    list_all_book_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
    list_all_books endp

; ===================================
update_stock_menu proc
    clear_screen
    page_title update_stock_title
    gap
    
    call list_all_books
    
    gap
    print_string select_book_prompt
    input_int
    sub al, 30H
    
    
    cmp al, 0
    JE update_stock_end
    cmp al, books_total
    jg if_invalid ;JA chilo

    mov bl, al
    dec bl
    mov bh, 0
    mov si, bx
    add si, si
    
    gap
    print_string enter_qty_add
    input_int
    sub al, 30H
    cmp al, 1
    jb if_invalid_qty
    cmp al, 9
    ja if_invalid_qty
    mov ah, 0
    
    add book_stock[si], ax
    
    cmp book_requests[si], 0
    je update_stock_no_pending
    cmp book_stock[si], 0
    JE update_stock_no_pending
    
    gap
    print_string restock_notice_1
    mov ax, book_requests[si]
    call print_num
    print_string restock_notice_2
    gap
    
    add total_requests_handled, ax
    mov book_requests[si], 0
    
    update_stock_no_pending:
        
        gap
        print_string spaced_dashes
        gap
        print_string stock_updated_msg
        gap
        print_string spaced_dashes
        gap
        jmp update_stock_end
        
    if_invalid:
        error_input
        jmp update_stock_menu

    if_invalid_qty:
        error_input
        jmp update_stock_menu

    update_stock_end:
        ret
            
    update_stock_menu endp            
    
; ===================================    
request_out_of_stock_menu proc
    clear_screen
    page_title request_title
    gap
    
    mov any_out_of_stock, 0
    mov bx, 0
    
    req_list_loop:
        cmp bl, books_total
        je req_list_done
        
        mov si, bx
        add si, si
        cmp book_stock[si], 0
        jne req_list_next
        
        mov any_out_of_stock, 1
        call print_book_entry
        gap
        
        req_list_next:
        inc bx
        jmp req_list_loop
        
    req_list_done:    
        cmp any_out_of_stock, 0
        jne req_has_books
        
        gap
        print_string no_out_of_stock_msg
        gap
        jmp request_menu_end
    
    req_has_books:
        gap
        print_string select_book_prompt
        input_int
        sub al, 30H
        
        cmp al, 0
        JE request_menu_end
        cmp al, books_total
        JG req_invalid
        
        mov bl, al
        dec bl
        mov bh, 0
        mov si, bx
        add si, si
        
        cmp book_stock[si], 0
        JNE req_invalid
        inc book_requests[si]
        
        gap
        print_string spaced_dashes
        gap
        print_string request_confirm_msg
        gap
        print_string spaced_dashes
        gap
        JMP request_menu_end
        
        req_invalid:
            error_input
            jmp req_has_books
            
        request_menu_end:
            ret
            
    request_out_of_stock_menu endp            
                

; ===================================
handle_requests_menu proc
    clear_screen
    page_title handle_request_title
    gap
    
    mov any_pending, 0
    mov bx, 0
    
    handle_list_loop:
        cmp bl, books_total
        JE handle_list_done
        
        mov si, bx
        add si, si
        cmp book_requests[si], 0
        JE handle_list_next 
        
        mov any_pending, 1
        call print_book_request_entry
        
        handle_list_next:
            inc bx
            jmp handle_list_loop
        
        handle_list_done:
            cmp any_pending, 0
            JNE handle_has_pending
            
            gap
            print_string no_pending_msg
            gap
            jmp handle_menu_end
            
        handle_has_pending:
            gap
            print_string select_book_prompt
            input_int
            sub al, 30H
            
            cmp al, 0
            JE handle_menu_end
            cmp al, books_total
            JG handle_inv
            
            mov bl, al
            dec bl
            mov bh, 0
            mov si, bx
            add si, si
            
            cmp book_requests[si], 0
            JE handle_inv
            
            gap
            print_string enter_qty_add
            input_int
            sub al, 30H
            cmp al, 1
            jb handle_qty_inv
            cmp al, 9
            ja handle_qty_inv
            mov ah, 0
            
            add book_stock[si], ax
            
            cmp book_stock[si], 0
            JE handle_still_out
            
            mov ax, book_requests[si]
            add total_requests_handled, ax
            mov book_requests[si], 0
            
            gap
            print_string spaced_dashes
            gap
            print_string request_fulfilled_msg
            gap
            print_string spaced_dashes
            gap
            JMP handle_menu_end
            
        handle_still_out:
            gap
            print_string stock_updated_msg
            gap
            JMP handle_menu_end
        handle_inv:
            error_input
            jmp handle_has_pending

        handle_qty_inv:
            error_input
            jmp handle_has_pending

        handle_menu_end:
            ret
            
    handle_requests_menu endp        
                    
; ===================================
shop_analytics proc
    clear_screen
    page_title analytics_title
    gap
    
    mov total_stock_qty, 0
    mov out_of_stock_count, 0
    mov pending_req_total, 0
    mov most_req_count, 0
    mov most_req_idx, 255
    
    mov bx, 0
    analytics_loop:
        cmp bl, books_total
        JE analytics_loop_done
        
        mov si, bx
        add si, si
        
        mov ax, book_stock[si]
        add total_stock_qty, ax
        
        cmp book_stock[si], 0
        JNE analytics_skip
        inc out_of_stock_count
        
    analytics_skip:
        mov ax, book_requests[si]
        add pending_req_total, ax
        
        cmp ax, 0
        JE analytics_skip_most
        cmp ax, most_req_count
        JBE analytics_skip_most ; JMP Below or equal for unsigned number
        mov most_req_count, AX
        mov most_req_idx, BL
        
    analytics_skip_most:
        inc bx
        jmp analytics_loop
        
    analytics_loop_done:
    
    print_string total_titles_label
    mov ax, 0
    mov al, books_total
    call print_num  
    gap
    
    print_string total_stock_label
    mov ax, total_stock_qty
    call print_num
    gap
    
    print_string pending_total_label
    mov ax, pending_req_total
    call print_num
    gap
    
    print_string handled_total_label
    mov ax, total_requests_handled
    call print_num
    gap
    
    print_string most_requested_label
    cmp most_req_idx, 255
    JNE analytics_show_most
    
    print_string none_label
    JMP analytics_most_done
    
    analytics_show_most:
        mov bl, most_req_idx
        mov bh, 0
        mov si, bx
        add si, si
        mov dx, book_names[si]
        mov ah, 9
        int 21h
        print_string requested_times_prefix
        mov ax, most_req_count
        call print_num
        print_string requested_times_suffix
        
    analytics_most_done:
    gap
    
    print_string spaced_dashes
    gap
    gap
    print_string nav_back_opt
    gap
    gap
    call wait_for_zero
    ret                      
    
    shop_analytics endp


; ===================================
; ============ PURCHASE / SHOPPING CART SECTION ============
; ===================================

PURCHASE_MENU PROC
PURCHASE_MENU_LOOP:
    CLEAR_SCREEN
    PAGE_TITLE PURCHASE_TITLE
    GAP

    PRINT_STRING CART_MENU_1
    GAP
    GAP
    PRINT_STRING CART_MENU_2
    GAP
    GAP
    PRINT_STRING CART_MENU_3
    GAP
    GAP
    PRINT_STRING CART_MENU_4
    GAP
    GAP
    PRINT_STRING CART_MENU_6
    GAP
    GAP
    PRINT_STRING CART_MENU_0
    GAP
    PRINT_STRING SPACED_DASHES
    GAP
    PRINT_STRING GIVE_INPUT_NO_BRACKS
    INPUT_INT
    SUB AL,48
    MOV SHOP_MENU_CHOICE,AL
    NEW_LINE
    MOV AL,SHOP_MENU_CHOICE

    CMP AL,1
    JE PURCHASE_OPT_ADD
    CMP AL,2
    JE PURCHASE_OPT_REMOVE
    CMP AL,3
    JE PURCHASE_OPT_CHANGE
    CMP AL,4
    JE PURCHASE_OPT_VIEWCART
    CMP AL,6
    JE PURCHASE_OPT_CHECKOUT
    CMP AL,0
    JE PURCHASE_MENU_END

    ERROR_INPUT
    JMP PURCHASE_MENU_LOOP

PURCHASE_OPT_ADD:
    CALL ADD_TO_CART
    JMP PURCHASE_MENU_LOOP

PURCHASE_OPT_REMOVE:
    CALL REMOVE_FROM_CART
    JMP PURCHASE_MENU_LOOP

PURCHASE_OPT_CHANGE:
    CALL CHANGE_CART_QTY
    JMP PURCHASE_MENU_LOOP

PURCHASE_OPT_VIEWCART:
    CLEAR_SCREEN
    PAGE_TITLE PURCHASE_TITLE
    GAP
    CALL VIEW_CART_LIST
    CALL WAIT_FOR_ZERO
    JMP PURCHASE_MENU_LOOP

PURCHASE_OPT_CHECKOUT:
    CALL CHECKOUT
    JMP PURCHASE_MENU_LOOP

PURCHASE_MENU_END:
    RET
PURCHASE_MENU ENDP



LIST_ALL_BOOKS_PRICES PROC
    PUSH AX
    PUSH BX
    PUSH SI

    MOV BX,0

LIST_BOOKS_PRICE_LOOP:
    CMP BL,books_total
    JAE LIST_BOOKS_PRICE_DONE

    CALL PRINT_BOOK_ENTRY
    MOV SI,BX
    ADD SI,SI
    PRINT_STRING PRICE_LABEL
    MOV AX,BOOK_PRICES[SI]
    CALL PRINT_NUM
    GAP

    INC BX
    JMP LIST_BOOKS_PRICE_LOOP

LIST_BOOKS_PRICE_DONE:
    POP SI
    POP BX
    POP AX
    RET
LIST_ALL_BOOKS_PRICES ENDP


FIND_CART_ITEM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SHOP_CART_FOUND,0
    MOV SHOP_CART_INDEX,0
    MOV DL,AL
    MOV SI,0

FIND_CART_LOOP:
    MOV AL,CART_COUNT
    MOV AH,0
    CMP SI,AX
    JAE FIND_CART_RET

    MOV AL,CART_BOOK_IDX[SI]
    CMP AL,DL
    JE FIND_CART_FOUND_LABEL

    INC SI
    JMP FIND_CART_LOOP

FIND_CART_FOUND_LABEL:
    MOV SHOP_CART_FOUND,1
    MOV AX,SI
    MOV SHOP_CART_INDEX,AL

FIND_CART_RET:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
FIND_CART_ITEM ENDP


FIND_SHOP_BOOK PROC
    PUSH BX
    MOV SHOP_BOOK_INDEX,0

    CMP AL,1
    JB FIND_SHOP_BOOK_INVALID
    CMP AL,books_total
    JA FIND_SHOP_BOOK_INVALID

    DEC AL
    MOV SHOP_BOOK_INDEX,AL
    MOV BL,AL
    MOV BH,0
    MOV AL,1
    JMP FIND_SHOP_BOOK_DONE

FIND_SHOP_BOOK_INVALID:
    MOV AL,0

FIND_SHOP_BOOK_DONE:
    POP BX
    RET
FIND_SHOP_BOOK ENDP


ADD_TO_CART PROC
    CLEAR_SCREEN
    PAGE_TITLE PURCHASE_TITLE
    GAP
    CALL LIST_ALL_BOOKS
    GAP

ADD_BOOK_INPUT:
    PRINT_STRING BOOK_ID_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_BOOK_ID,AL
    NEW_LINE

    MOV AL,SHOP_BOOK_ID
    CMP AL,0
    JE ADD_CART_DONE

    CALL FIND_SHOP_BOOK
    CMP AL,1
    JNE ADD_CART_INVALID_ID

    MOV AL,SHOP_BOOK_INDEX
    MOV BL,AL
    MOV BH,0
    MOV SI,BX
    ADD SI,SI

    CMP BOOK_STOCK[SI],0
    JE ADD_CART_OUT_OF_STOCK

    MOV AL,SHOP_BOOK_INDEX
    CALL FIND_CART_ITEM
    CMP SHOP_CART_FOUND,1
    JE ADD_CART_EXISTING

    MOV AL,CART_COUNT
    CMP AL,8
    JAE ADD_CART_FULL

    MOV AL,CART_COUNT
    MOV AH,0
    MOV DI,AX
    MOV AL,SHOP_BOOK_INDEX
    MOV CART_BOOK_IDX[DI],AL

ADD_CART_QTY_NEW:
    PRINT_STRING QUANTITY_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_QUANTITY,AL
    NEW_LINE

    MOV AL,SHOP_QUANTITY
    CMP AL,1
    JB ADD_CART_INVALID_QTY_NEW
    CMP AL,9
    JA ADD_CART_INVALID_QTY_NEW

    MOV BL,SHOP_BOOK_INDEX
    MOV BH,0
    MOV SI,BX
    ADD SI,SI

    MOV AL,SHOP_QUANTITY
    MOV AH,0
    CMP AX,BOOK_STOCK[SI]
    JA ADD_CART_NOT_ENOUGH

    MOV AL,CART_COUNT
    MOV AH,0
    MOV DI,AX
    MOV AL,SHOP_QUANTITY
    MOV CART_QTY[DI],AL
    INC CART_COUNT

    PRINT_STRING BOOK_ADDED_MSG
    NEW_LINE
    JMP ADD_CART_DONE

ADD_CART_INVALID_QTY_NEW:
    PRINT_STRING INVALID_QUANTITY
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP ADD_CART_QTY_NEW

ADD_CART_EXISTING:
    MOV AL,SHOP_CART_INDEX
    MOV SHOP_CART_INDEX,AL

ADD_CART_QTY_EXISTING:
    PRINT_STRING QUANTITY_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_QUANTITY,AL
    NEW_LINE

    MOV AL,SHOP_QUANTITY
    CMP AL,1
    JB ADD_CART_INVALID_QTY_EXISTING
    CMP AL,9
    JA ADD_CART_INVALID_QTY_EXISTING

    MOV AL,SHOP_CART_INDEX
    MOV AH,0
    MOV SI,AX
    MOV AL,CART_QTY[SI]
    MOV BL,SHOP_QUANTITY
    ADD AL,BL
    MOV SHOP_QUANTITY,AL

    MOV BL,SHOP_BOOK_INDEX
    MOV BH,0
    MOV DI,BX
    ADD DI,DI

    MOV AL,SHOP_QUANTITY
    MOV AH,0
    CMP AX,BOOK_STOCK[DI]
    JA ADD_CART_NOT_ENOUGH

    MOV AL,SHOP_QUANTITY
    MOV CART_QTY[SI],AL

    PRINT_STRING BOOK_ADDED_MSG
    NEW_LINE
    JMP ADD_CART_DONE

ADD_CART_INVALID_QTY_EXISTING:
    PRINT_STRING INVALID_QUANTITY
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP ADD_CART_QTY_EXISTING

ADD_CART_OUT_OF_STOCK:
    PRINT_STRING OUT_OF_STOCK_MSG
    NEW_LINE
    JMP ADD_CART_DONE

ADD_CART_NOT_ENOUGH:
    PRINT_STRING NOT_ENOUGH_STOCK_MSG
    NEW_LINE
    JMP ADD_CART_DONE

ADD_CART_FULL:
    PRINT_STRING CART_FULL_MSG
    NEW_LINE
    JMP ADD_CART_DONE

ADD_CART_INVALID_ID:
    PRINT_STRING INVALID_BOOK_MSG
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP ADD_BOOK_INPUT

ADD_CART_DONE:
    CALL WAIT_FOR_ZERO
    RET
ADD_TO_CART ENDP


REMOVE_FROM_CART PROC
    CLEAR_SCREEN
    PAGE_TITLE PURCHASE_TITLE
    GAP

    CMP CART_COUNT,0
    JE REMOVE_EMPTY

REMOVE_BOOK_INPUT:
    PRINT_STRING BOOK_ID_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_BOOK_ID,AL
    NEW_LINE

    MOV AL,SHOP_BOOK_ID
    CMP AL,0
    JE REMOVE_DONE

    CALL FIND_SHOP_BOOK
    CMP AL,1
    JNE REMOVE_NOT_FOUND

    MOV AL,SHOP_BOOK_INDEX
    CALL FIND_CART_ITEM
    CMP SHOP_CART_FOUND,1
    JNE REMOVE_NOT_FOUND

    MOV AL,SHOP_CART_INDEX
    MOV AH,0
    MOV SI,AX
    MOV DI,SI
    INC DI

REMOVE_SHIFT_LOOP:
    MOV AL,CART_COUNT
    MOV AH,0
    CMP DI,AX
    JAE REMOVE_SHIFT_DONE

    MOV AL,CART_BOOK_IDX[DI]
    MOV CART_BOOK_IDX[SI],AL
    MOV AL,CART_QTY[DI]
    MOV CART_QTY[SI],AL

    INC SI
    INC DI
    JMP REMOVE_SHIFT_LOOP

REMOVE_SHIFT_DONE:
    DEC CART_COUNT
    PRINT_STRING BOOK_REMOVED_MSG
    NEW_LINE
    JMP REMOVE_DONE

REMOVE_EMPTY:
    PRINT_STRING CART_EMPTY_MSG
    NEW_LINE
    JMP REMOVE_DONE

REMOVE_NOT_FOUND:
    PRINT_STRING NOT_IN_CART_MSG
    NEW_LINE
    JMP REMOVE_BOOK_INPUT

REMOVE_DONE:
    CALL WAIT_FOR_ZERO
    RET
REMOVE_FROM_CART ENDP


CHANGE_CART_QTY PROC
    CLEAR_SCREEN
    PAGE_TITLE PURCHASE_TITLE
    GAP

    CMP CART_COUNT,0
    JE CHANGE_EMPTY

    PRINT_STRING BOOK_ID_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_BOOK_ID,AL
    NEW_LINE

    MOV AL,SHOP_BOOK_ID
    CMP AL,0
    JE CHANGE_DONE

    CALL FIND_SHOP_BOOK
    CMP AL,1
    JNE CHANGE_INVALID_BOOK

    MOV AL,SHOP_BOOK_INDEX
    CALL FIND_CART_ITEM
    CMP SHOP_CART_FOUND,1
    JNE CHANGE_NOT_FOUND

CHANGE_QTY_INPUT:
    PRINT_STRING NEW_QUANTITY_INPUT
    INPUT_INT
    SUB AL,30H
    MOV SHOP_QUANTITY,AL
    NEW_LINE

    MOV AL,SHOP_QUANTITY
    CMP AL,1
    JB CHANGE_QTY_INVALID
    CMP AL,9
    JA CHANGE_QTY_INVALID

    MOV BL,SHOP_BOOK_INDEX
    MOV BH,0
    MOV SI,BX
    ADD SI,SI

    MOV AL,SHOP_QUANTITY
    MOV AH,0
    CMP AX,BOOK_STOCK[SI]
    JA CHANGE_NOT_ENOUGH

    MOV AL,SHOP_CART_INDEX
    MOV AH,0
    MOV DI,AX
    MOV AL,SHOP_QUANTITY
    MOV CART_QTY[DI],AL

    PRINT_STRING QTY_CHANGED_MSG
    NEW_LINE
    JMP CHANGE_DONE

CHANGE_QTY_INVALID:
    PRINT_STRING INVALID_QUANTITY
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP CHANGE_QTY_INPUT

CHANGE_NOT_ENOUGH:
    PRINT_STRING NOT_ENOUGH_STOCK_MSG
    NEW_LINE
    JMP CHANGE_DONE

CHANGE_EMPTY:
    PRINT_STRING CART_EMPTY_MSG
    NEW_LINE
    JMP CHANGE_DONE

CHANGE_INVALID_BOOK:
    PRINT_STRING INVALID_BOOK_MSG
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP CHANGE_CART_QTY

CHANGE_NOT_FOUND:
    PRINT_STRING NOT_IN_CART_MSG
    NEW_LINE

CHANGE_DONE:
    CALL WAIT_FOR_ZERO
    RET
CHANGE_CART_QTY ENDP


VIEW_CART_LIST PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    CMP CART_COUNT,0
    JE VIEW_CART_EMPTY

    MOV CART_SUBTOTAL,0
    MOV CART_TOTAL_ITEMS,0
    MOV BX,0

VIEW_CART_LOOP:
    MOV AX,0
    MOV AL,CART_COUNT
    CMP BX,AX
    JAE VIEW_CART_TOTALS

    MOV SI,BX
    MOV AL,CART_BOOK_IDX[SI]
    MOV AH,0
    MOV DI,AX
    ADD DI,DI

    PRINT_STRING SPACES
    MOV AX,BX
    INC AX
    CALL PRINT_NUM
    PRINT_STRING DOT_SPACE

    MOV DX,BOOK_NAMES[DI]
    MOV AH,9
    INT 21H

    PRINT_STRING CART_QTY_LABEL
    MOV SI,BX
    MOV AL,CART_QTY[SI]
    MOV AH,0
    MOV CX,AX
    CALL PRINT_NUM

    PRINT_STRING CART_PRICE_LABEL
    MOV AX,BOOK_PRICES[DI]
    CALL PRINT_NUM

    MOV AX,BOOK_PRICES[DI]
    MUL CX
    ADD CART_SUBTOTAL,AX
    ADD CART_TOTAL_ITEMS,CX

    GAP
    INC BX
    JMP VIEW_CART_LOOP

VIEW_CART_TOTALS:
    GAP
    PRINT_STRING SPACED_DASHES
    GAP
    PRINT_STRING BILL_TOTAL_ITEMS_LABEL
    MOV AX,CART_TOTAL_ITEMS
    CALL PRINT_NUM
    GAP
    PRINT_STRING BILL_SUBTOTAL_LABEL
    MOV AX,CART_SUBTOTAL
    CALL PRINT_NUM
    GAP
    JMP VIEW_CART_RET

VIEW_CART_EMPTY:
    PRINT_STRING CART_EMPTY_MSG
    GAP

VIEW_CART_RET:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
VIEW_CART_LIST ENDP


CHECKOUT PROC
    CLEAR_SCREEN
    PAGE_TITLE BILL_TITLE_TXT
    GAP

    CMP CART_COUNT,0
    JE CHECKOUT_EMPTY

    MOV CART_SUBTOTAL,0
    MOV CART_TOTAL_ITEMS,0
    MOV BX,0

CHECKOUT_TOTAL_LOOP:
    MOV AX,0
    MOV AL,CART_COUNT
    CMP BX,AX
    JAE CHECKOUT_TOTALS_READY

    MOV SI,BX
    MOV AL,CART_BOOK_IDX[SI]
    MOV AH,0
    MOV DI,AX
    ADD DI,DI

    MOV AL,CART_QTY[SI]
    MOV AH,0
    MOV CX,AX

    MOV AX,BOOK_PRICES[DI]
    MUL CX
    ADD CART_SUBTOTAL,AX
    ADD CART_TOTAL_ITEMS,CX

    INC BX
    JMP CHECKOUT_TOTAL_LOOP

CHECKOUT_TOTALS_READY:
    MOV CART_DISCOUNT_AMOUNT,0
    MOV AX,CART_SUBTOTAL
    MOV BX,5
    XOR DX,DX

    CMP CURRENT_BRACU,1
    JNE CHECKOUT_NO_DISCOUNT
    CMP CART_TOTAL_ITEMS,3
    JB CHECKOUT_NO_DISCOUNT

    DIV BX
    MOV CART_DISCOUNT_AMOUNT,AX
    JMP CHECKOUT_DISCOUNT_DONE

CHECKOUT_NO_DISCOUNT:
    MOV CART_DISCOUNT_AMOUNT,0

CHECKOUT_DISCOUNT_DONE:
    MOV AX,CART_SUBTOTAL
    SUB AX,CART_DISCOUNT_AMOUNT
    MOV CART_FINAL_AMOUNT,AX

    GAP
    PRINT_STRING BILL_TOTAL_ITEMS_LABEL
    MOV AX,CART_TOTAL_ITEMS
    CALL PRINT_NUM
    NEW_LINE

    PRINT_STRING BILL_SUBTOTAL_LABEL
    MOV AX,CART_SUBTOTAL
    CALL PRINT_NUM
    NEW_LINE

    PRINT_STRING BILL_DISCOUNT_LABEL
    MOV AX,CART_DISCOUNT_AMOUNT
    CALL PRINT_NUM
    NEW_LINE

    PRINT_STRING BILL_FINAL_LABEL
    MOV AX,CART_FINAL_AMOUNT
    CALL PRINT_NUM
    NEW_LINE
    NEW_LINE

    CMP CART_DISCOUNT_AMOUNT,0
    JE CHECKOUT_NO_DISCOUNT_MSG

    PRINT_STRING DISCOUNT_APPLIED
    NEW_LINE
    JMP CHECKOUT_BILL_MESSAGE

CHECKOUT_NO_DISCOUNT_MSG:
    PRINT_STRING NO_DISCOUNT
    NEW_LINE

CHECKOUT_BILL_MESSAGE:
    PRINT_STRING BILL_READY
    NEW_LINE
    PRINT_STRING SPACED_DASHES
    GAP

    MOV BX,0

CHECKOUT_DEDUCT_LOOP:
    MOV AX,0
    MOV AL,CART_COUNT
    CMP BX,AX
    JAE CHECKOUT_DEDUCT_DONE

    MOV SI,BX
    MOV AL,CART_BOOK_IDX[SI]
    MOV AH,0
    MOV DI,AX
    ADD DI,DI

    MOV AL,CART_QTY[SI]
    MOV AH,0
    SUB BOOK_STOCK[DI],AX

    INC BX
    JMP CHECKOUT_DEDUCT_LOOP

CHECKOUT_DEDUCT_DONE:
    MOV CART_COUNT,0
    MOV CART_SUBTOTAL,0
    MOV CART_TOTAL_ITEMS,0
    MOV CART_DISCOUNT_AMOUNT,0
    MOV CART_FINAL_AMOUNT,0

    GAP
    PRINT_STRING SPACED_DASHES
    GAP
    PRINT_STRING BILL_DONE_MSG
    GAP
    PRINT_STRING SPACED_DASHES
    GAP
    CALL WAIT_FOR_ZERO
    RET

CHECKOUT_EMPTY:
    PRINT_STRING CART_EMPTY_MSG
    GAP
    CALL WAIT_FOR_ZERO
    RET
CHECKOUT ENDP


CHECK_BRACU_EMAIL PROC
    MOV AL,0
    MOV BL,EMAIL_BUFFER+1
    CMP BL,14
    JB CHECK_BRACU_NOT_FOUND

    LEA SI,EMAIL_BUFFER
    ADD SI,2
    MOV AL,EMAIL_BUFFER+1
    SUB AL,14
    MOV AH,0
    ADD SI,AX

    LEA DI,BRACU_DOMAIN
    MOV CX,14

CHECK_BRACU_DOMAIN_LOOP:
    MOV AL,[SI]
    CMP AL,[DI]
    JNE CHECK_BRACU_NOT_FOUND
    INC SI
    INC DI
    LOOP CHECK_BRACU_DOMAIN_LOOP

    MOV AL,1
    RET

CHECK_BRACU_NOT_FOUND:
    MOV AL,0
    RET
CHECK_BRACU_EMAIL ENDP


WAIT_FOR_ZERO PROC
WAIT_ZERO_INPUT:
    PRINT_STRING CONTINUE_MSG
    INPUT_INT
    CMP AL,'0'
    JE WAIT_ZERO_DONE

    NEW_LINE
    PRINT_STRING INVALID_INPUT
    NEW_LINE
    PRINT_STRING GIVE_INPUT_AGAIN
    NEW_LINE
    JMP WAIT_ZERO_INPUT

WAIT_ZERO_DONE:
    RET
WAIT_FOR_ZERO ENDP


; ===================================
    
    END MAIN
