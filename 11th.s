        AREA Module11, CODE, READONLY
        EXPORT Module11_Run

        IMPORT HR_BUFFER
        IMPORT BP_BUFFER
        IMPORT O2_BUFFER
        IMPORT DOSAGE_DUE_ARRAY
        IMPORT ERROR_FLAG
        IMPORT ERROR_FLASH_LOG
        IMPORT ERROR_LOG_INDEX

; -----------------------------
; CONSTANTS
; -----------------------------
RAM_END         EQU 0x20008000
SENSOR_REPEAT   EQU 10

; -----------------------------
; MODULE 11 ENTRY
; -----------------------------
Module11_Run
        PUSH {R0-R12, LR}

; =============================
; 1. SENSOR MALFUNCTION CHECK
; =============================
        LDR R0, =HR_BUFFER
        BL Check_Repeated

        LDR R0, =BP_BUFFER
        BL Check_Repeated

        LDR R0, =O2_BUFFER
        BL Check_Repeated

; =============================
; 2. INVALID DOSAGE CHECK
; =============================
        LDR R0, =DOSAGE_DUE_ARRAY
        MOV R1, #3              ; 3 patients

DosageLoop
        LDRB R2, [R0], #1
        CMP R2, #0
        BEQ Set_Error
        SUBS R1, R1, #1
        BNE DosageLoop

; =============================
; 3. MEMORY OVERFLOW CHECK
; =============================
        LDR R9, =HR_BUFFER
        ADD R9, R9, #120        ; buffer size

        LDR R10, =RAM_END
        CMP R9, R10
        BHI Set_Error

        POP {R0-R12, LR}
        BX LR

; =============================
; ERROR HANDLER
; =============================
Set_Error
        LDR R0, =ERROR_FLAG
        MOV R1, #1
        STRB R1, [R0]

        BL Store_Error_Record

        POP {R0-R12, LR}
        BX LR

; =============================
; CHECK REPEATED SENSOR VALUES
; R0 = buffer base
; =============================
Check_Repeated
        PUSH {R1-R7, LR}

        LDR R1, [R0]            ; first value
        MOV R2, #1
        MOV R3, #1

RepeatLoop
        LDR R4, [R0, R3, LSL #2]
        CMP R4, R1
        BNE ExitRepeat

        ADD R2, R2, #1
        MOV  R3, #SENSOR_REPEAT
        CMP  R2, R3
        BGE  Set_Error
		
        ADD R3, R3, #1
        CMP R3, #10
        BLT RepeatLoop

ExitRepeat
        POP {R1-R7, LR}
        BX LR

; =============================
; STORE ERROR RECORD (FLASH SIM)
; =============================
Store_Error_Record
        PUSH {R0-R3, LR}

        LDR R0, =ERROR_FLASH_LOG
        LDR R1, =ERROR_LOG_INDEX
        LDR R2, [R1]

        ADD R0, R0, R2, LSL #2
        MOV R3, #0xEE
        STR R3, [R0]

        ADD R2, R2, #1
        STR R2, [R1]

        POP {R0-R3, LR}
        BX LR

        END
