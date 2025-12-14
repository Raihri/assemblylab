		AREA Module10_Code, CODE, READONLY
		EXPORT Module10_Run
		IMPORT PATIENT_ARRAY
		IMPORT ALERT_COUNT_ARRAY

; =================================================
; Constants
; =================================================
ITM_PORT0   EQU 0xE0000000
ITM_TCR     EQU 0xE0000E80
ITM_TER     EQU 0xE0000E00
ITM_TPR     EQU 0xE0000E40
ITM_LAR     EQU 0xE0000FB0

; =================================================
; Module10_Run - Main entry point
; =================================================
Module10_Run
    PUSH {R4-R11, LR}

    ; Initialize ITM for debug output
    BL init_itm

    ; Print header once
    LDR R0, =title_str
    BL print_string
    LDR R0, =sep_str
    BL print_string

    ; Loop through all 3 patients
    MOV R4, #0                  ; Patient index
    MOV R5, #3                  ; Total patients
    LDR R6, =PATIENT_ARRAY      ; Base address of array
    LDR R7, =ALERT_COUNT_ARRAY  ; Base address of alert counts

patient_loop
    CMP R4, R5
    BGE patient_loop_end

    ; Calculate patient address: R6 + (R4 * 44)
    MOV R0, R4
    MOV R1, #44
    MUL R8, R0, R1             ; R8 = index * 44
    ADD R8, R6, R8             ; R8 = current patient address

    ; Print this patient
    MOV R0, R8                  ; Patient struct address
    MOV R1, R4                  ; Patient index (for alerts)
    MOV R2, R7                  ; Alert array address
    BL print_patient_details

    ; Add separator between patients
    CMP R4, #2                  ; Don't add after last patient
    BGE no_separator
    LDR R0, =sep_str
    BL print_string
no_separator

    ADD R4, R4, #1
    B patient_loop

patient_loop_end
    POP {R4-R11, PC}

; =================================================
; Print Patient Details
; Input: R0 = patient struct address
;        R1 = patient index
;        R2 = ALERT_COUNT_ARRAY address
; =================================================
print_patient_details
    PUSH {R4-R8, LR}
    MOV R4, R0          ; Save patient address
    MOV R5, R1          ; Save patient index
    MOV R6, R2          ; Save alert array address

    ; ----- ID -----
    LDR R0, =id_str
    BL print_string
    LDR R0, [R4, #0]    ; id at offset 0
    BL print_number
    BL print_newline

    ; ----- Name -----
    LDR R0, =name_str
    BL print_string
    LDR R0, [R4, #4]    ; name pointer at offset 4
    BL print_string
    BL print_newline

    ; ----- Age -----
    LDR R0, =age_str
    BL print_string
    LDRB R0, [R4, #8]   ; age at offset 8 (byte)
    BL print_number
    BL print_newline

    ; ----- Ward -----
    LDR R0, =ward_str
    BL print_string
    LDRH R0, [R4, #10]  ; ward at offset 10 (halfword)
    BL print_number
    BL print_newline

    ; ----- Heart Rate (latest) -----
    LDR R0, =hr_str
    BL print_string
    LDR R1, [R4, #24]   ; hr_history pointer at offset 24
    CMP R1, #0          ; Check if pointer is valid
    BEQ hr_invalid
    ; Get HR at index 0 (first reading)
    LDR R0, [R1, #0]    ; Read first element
    BL print_number
    B hr_done
hr_invalid
    LDR R0, =na_str     ; Print "N/A" if invalid
    BL print_string
hr_done
    BL print_newline

    ; ----- Blood Pressure (latest) -----
    LDR R0, =bp_str
    BL print_string
    LDR R1, [R4, #28]   ; bp_history pointer at offset 28
    CMP R1, #0          ; Check if pointer is valid
    BEQ bp_invalid
    ; Get BP at index 0
    LDR R0, [R1, #0]    ; Read first element
    BL print_number
    B bp_done
bp_invalid
    LDR R0, =na_str     ; Print "N/A" if invalid
    BL print_string
bp_done
    BL print_newline

    ; ----- Oxygen Level (latest) -----
    LDR R0, =o2_str
    BL print_string
    LDR R1, [R4, #32]   ; o2_history pointer at offset 32
    CMP R1, #0          ; Check if pointer is valid
    BEQ o2_invalid
    ; Get O2 at index 0
    LDR R0, [R1, #0]    ; Read first element
    BL print_number
    B o2_done
o2_invalid
    LDR R0, =na_str     ; Print "N/A" if invalid
    BL print_string
o2_done
    BL print_newline

    ; ----- Alerts -----
    LDR R0, =alert_str
    BL print_string
    ; Get alert count: alert_array[patient_index]
    LDR R0, [R6, R5, LSL #2]  ; R0 = alert_array[index * 4]
    BL print_number
    BL print_newline

    ; ----- Bill -----
    LDR R0, =bill_str
    BL print_string
    LDR R0, [R4, #16]   ; bill at offset 16
    BL print_bill       ; Special function to print as dollars.cents

    POP {R4-R8, PC}

; =================================================
; Print Bill as dollars.cents
; Input: R0 = amount in cents
; =================================================
print_bill
    PUSH {R4-R5, LR}
    MOV R4, R0          ; Save amount
    
    ; Calculate dollars: R5 = R4 / 100
    MOV R5, #0
dollar_loop
    CMP R4, #100
    BLT dollar_done
    SUB R4, R4, #100
    ADD R5, R5, #1
    B dollar_loop
dollar_done
    
    ; Print dollars
    MOV R0, R5
    BL print_number
    
    ; Print decimal point
    MOV R0, #'.'
    BL send_char
    
    ; Print cents (always 2 digits)
    ; R4 now has remainder (0-99)
    MOV R0, R4
    
    ; Check if less than 10
    CMP R0, #10
    BGE two_digits
    
    ; Print leading zero
    MOV R0, #'0'
    BL send_char
    
    ; Get cents again
    MOV R0, R4
    B print_one_digit
    
two_digits
    ; Print tens digit
    MOV R1, #10
    BL divide_10        ; R0 = tens, R1 = ones
    ADD R0, R0, #'0'
    BL send_char
    MOV R0, R1          ; ones digit
    
print_one_digit
    ADD R0, R0, #'0'
    BL send_char
    
    ; Print newline
    BL print_newline
    
    POP {R4-R5, PC}

; =================================================
; Divide by 10
; Input: R0 = number
; Output: R0 = quotient, R1 = remainder
; =================================================
divide_10
    MOV R1, #0
div10_loop
    CMP R0, #10
    BLT div10_done
    SUB R0, R0, #10
    ADD R1, R1, #1
    B div10_loop
div10_done
    ; R0 = remainder, R1 = quotient
    ; Swap to standard: R0 = quotient, R1 = remainder
    MOV R2, R0
    MOV R0, R1
    MOV R1, R2
    BX LR

; =================================================
; Print Number (0-999) - FIXED VERSION
; Input: R0 = number
; =================================================
print_number
    PUSH {R4-R6, LR}
    MOV R4, R0          ; Save original number
    
    ; Check for 0
    CMP R4, #0
    BNE not_zero
    MOV R0, #'0'
    BL send_char
    B num_done
    
not_zero
    ; Check if 3 digits (100-999)
    CMP R4, #100
    BLT two_digit_check
    
    ; Print hundreds digit
    MOV R0, R4
    MOV R1, #100
    BL divide_simple    ; R0 = hundreds digit
    ADD R0, R0, #'0'
    BL send_char
    
    ; Remove hundreds: R4 = R4 - (hundreds * 100)
    MOV R5, R0
    SUB R5, R5, #'0'    ; Convert back to number
    MOV R6, #100
    MUL R6, R5, R6
    SUB R4, R4, R6
    
two_digit_check
    ; Check if 2 digits (10-99)
    CMP R4, #10
    BLT one_digit
    
    ; Print tens digit
    MOV R0, R4
    MOV R1, #10
    BL divide_simple    ; R0 = tens digit
    ADD R0, R0, #'0'
    BL send_char
    
    ; Remove tens: R4 = R4 - (tens * 10)
    MOV R5, R0
    SUB R5, R5, #'0'
    MOV R6, #10
    MUL R6, R5, R6
    SUB R4, R4, R6
    
one_digit
    ; Print ones digit
    MOV R0, R4
    ADD R0, R0, #'0'
    BL send_char
    
num_done
    POP {R4-R6, PC}

; Simple division: R0 / R1, result in R0
divide_simple
    PUSH {R2}
    MOV R2, #0
ds_loop
    CMP R0, R1
    BLT ds_done
    SUB R0, R0, R1
    ADD R2, R2, #1
    B ds_loop
ds_done
    MOV R0, R2
    POP {R2}
    BX LR

; =================================================
; ITM Initialization
; =================================================
init_itm
    PUSH {R0-R1, LR}
    LDR R0, =ITM_LAR
    LDR R1, =0xC5ACCE55
    STR R1, [R0]

    LDR R0, =ITM_TCR
    MOV R1, #1
    STR R1, [R0]

    LDR R0, =ITM_TER
    MOV R1, #1
    STR R1, [R0]

    LDR R0, =ITM_TPR
    MOV R1, #0
    STR R1, [R0]
    POP {R0-R1, PC}

; =================================================
; Print String
; Input: R0 = string pointer
; =================================================
print_string
    PUSH {R1, LR}
    MOV R1, R0
ps_loop
    LDRB R0, [R1], #1
    CMP R0, #0
    BEQ ps_done
    BL send_char
    B ps_loop
ps_done
    POP {R1, PC}

; =================================================
; Print Newline
; =================================================
print_newline
    PUSH {LR}
    MOV R0, #'\r'
    BL send_char
    MOV R0, #'\n'
    BL send_char
    POP {PC}

; =================================================
; Send Character to ITM
; Input: R0 = character
; =================================================
send_char
    PUSH {R1-R2, LR}
    LDR R1, =ITM_PORT0
    
    ; Wait for FIFO ready
wait_loop
    LDR R2, =0xE0000E00  ; ITM TER
    LDR R2, [R2]
    TST R2, #1           ; Check port 0 enabled
    BEQ wait_loop
    
    STR R0, [R1]
    POP {R1-R2, PC}

; =================================================
; String Data (placed in literal pool)
; =================================================
    LTORG

title_str   DCB "\r\nICU PATIENT SUMMARY\r\n", 0
sep_str     DCB "----------------------\r\n", 0
id_str      DCB "ID: ", 0
name_str    DCB "Name: ", 0
age_str     DCB "Age: ", 0
ward_str    DCB "Ward: ", 0
hr_str      DCB "HR: ", 0
bp_str      DCB "BP: ", 0
o2_str      DCB "O2: ", 0
alert_str   DCB "Alerts: ", 0
bill_str    DCB "Bill: $", 0
na_str      DCB "N/A", 0

    END
