        AREA Module11, CODE, READONLY
        EXPORT Anomaly_Check_Handler

        IMPORT MAX_PATIENTS
        IMPORT HR_BUFFER
        IMPORT BP_BUFFER
        IMPORT O2_BUFFER
        IMPORT VITAL_INDEX
        IMPORT MED_INTERVAL_ARRAY
        IMPORT ERROR_FLAG
        IMPORT ERROR_FLASH_LOG
        IMPORT ERROR_LOG_INDEX

; ------------------------------
; Constants
; ------------------------------
SENSOR_STUCK     EQU 1
INVALID_DOSAGE   EQU 2
MEMORY_OVERFLOW  EQU 3

BUF_WORDS        EQU 10              ; rolling buffer length
REC_SIZE         EQU 16              ; 16-byte error record
FLASH_BLOCK      EQU 64              ; 64 bytes per patient

; ------------------------------
; Entry
; ------------------------------
Anomaly_Check_Handler
        PUSH {R4-R12, LR}

        MOV  R4, #0                  ; patient index
Chk_Patient
        LDR  R0, =MAX_PATIENTS
        LDR  R0, [R0]
        CMP  R4, R0
        BGE  Done

        ; -------- Check sensor stuck (HR/BP/O2) --------
        LDR  R5, =HR_BUFFER
        MOV  R6, #40                 ; 10 words * 4 bytes
        MUL  R6, R4, R6
        ADD  R5, R5, R6
        BL   Check_Buffer_AllSame
        CMP  R0, #0
        BEQ  SensorErr

        LDR  R5, =BP_BUFFER
        MOV  R6, #40
        MUL  R6, R4, R6
        ADD  R5, R5, R6
        BL   Check_Buffer_AllSame
        CMP  R0, #0
        BEQ  SensorErr

        LDR  R5, =O2_BUFFER
        MOV  R6, #40
        MUL  R6, R4, R6
        ADD  R5, R5, R6
        BL   Check_Buffer_AllSame
        CMP  R0, #0
        BEQ  SensorErr

        ; -------- Check invalid medicine dosage --------
        LDR  R7, =MED_INTERVAL_ARRAY
        LDR  R8, [R7, R4, LSL #2]
        CMP  R8, #0
        BEQ  DosageErr

NextP
        ADD  R4, R4, #1
        B    Chk_Patient

; ------------------------------
; Errors funnel here
; ------------------------------
SensorErr
        MOV  R0, #SENSOR_STUCK
        MOV  R1, R4                  ; pass patient index
        BL   Handle_Error
        B    NextP

DosageErr
        MOV  R0, #INVALID_DOSAGE
        MOV  R1, R4
        BL   Handle_Error
        B    NextP

MemErr
        MOV  R0, #MEMORY_OVERFLOW
        MOV  R1, R4
        BL   Handle_Error
        B    NextP

Done
        POP  {R4-R12, PC}

; ------------------------------
; Check_Buffer_AllSame
; ------------------------------
Check_Buffer_AllSame
        PUSH {R1-R4, LR}
        LDR  R1, [R5]               ; first value
        MOV  R2, #1
CB_Loop
        CMP  R2, #BUF_WORDS
        BGE  AllSame
        LDR  R3, [R5, R2, LSL #2]
        CMP  R3, R1
        BNE  NotSame
        ADD  R2, R2, #1
        B    CB_Loop
AllSame
        MOV  R0, #0
        POP  {R1-R4, PC}
NotSame
        MOV  R0, #1
        POP  {R1-R4, PC}

; ------------------------------
; Handle_Error
; R0 = error code
; R1 = patient index
; ------------------------------
Handle_Error
        PUSH {R2-R7, LR}

        ; Set patient error flag
        LDR  R2, =ERROR_FLAG
        ADD  R2, R2, R1
        MOV  R3, #1
        STRB R3, [R2]

        ; Compute patient’s flash block base
        LDR  R4, =ERROR_FLASH_LOG
        MOV  R5, #FLASH_BLOCK
        MUL  R5, R1, R5
        ADD  R4, R4, R5              ; R4 = base for patient

        ; Compute offset for next record
        LDR  R5, =ERROR_LOG_INDEX
        LDR  R6, [R5, R1, LSL #2]   ; current record index
        MOV  R7, #REC_SIZE
        MUL  R7, R6, R7
        ADD  R4, R4, R7              ; R4 = address to write

        ; Write 16-byte error record (simple)
        STR  R0, [R4, #0]            ; error code
        STR  R1, [R4, #4]            ; patient index
        MOV  R7, #0
        STR  R7, [R4, #8]            ; timestamp (placeholder)
        STR  R7, [R4, #12]

        ; Increment log index
        ADD  R6, R6, #1
        STR  R6, [R5, R1, LSL #2]

        POP  {R2-R7, PC}

        END
