        AREA Module9, CODE, READONLY
        EXPORT Sort_By_Alerts

        IMPORT PATIENT_ARRAY
        IMPORT ALERT_COUNT_ARRAY
        IMPORT MAX_PATIENTS
        IMPORT PATIENT_SIZE
			

; =====================================================
; Sort_By_Alerts
; Bubble sort patients by alert count (descending)
; =====================================================
Sort_By_Alerts
        PUSH {R0-R12, LR}

        ; Load base addresses
        LDR R0, =PATIENT_ARRAY          ; Base of patient structs
        LDR R1, =ALERT_COUNT_ARRAY      ; Alert count array
        LDR R2, =MAX_PATIENTS
        LDR R2, [R2]                    ; N patients
        LDR R3, =PATIENT_SIZE
        LDR R3, [R3]                    ; Struct size (44 bytes)

        MOV R4, #0                      ; i = 0 (outer loop)

; -----------------------------------------------------
; Outer loop: for i = 0 to N-2
; -----------------------------------------------------
OuterLoop
        SUB R12, R2, #1
        CMP R4, R12
        BGE SortDone

        MOV R5, #0                      ; j = 0
        SUB R6, R2, R4
        SUB R6, R6, #1                  ; limit = N - i - 1

; -----------------------------------------------------
; Inner loop
; -----------------------------------------------------
InnerLoop
        CMP R5, R6
        BGE NextOuter

        ; Load alert[j]
        LDR R7, [R1, R5, LSL #2]

        ; Load alert[j+1]
        ADD R8, R5, #1
        LDR R9, [R1, R8, LSL #2]

        ; If alert[j] >= alert[j+1], no swap
        CMP R7, R9
        BGE NoSwap

        ; =============================================
        ; Swap patient structs (44 bytes = 11 words)
        ; =============================================

        ; addr_j = PATIENT_ARRAY + j * PATIENT_SIZE
        MUL R10, R5, R3
        ADD R10, R0, R10

        ; addr_j1 = addr_j + PATIENT_SIZE
        ADD R11, R10, R3

        MOV R12, #11                    ; 44 / 4 = 11 words

SwapStruct
        LDR R6, [R10]
        LDR R14, [R11]

        STR R14, [R10], #4
        STR R6,  [R11], #4

        SUBS R12, R12, #1
        BNE SwapStruct

        ; =============================================
        ; Swap alert counts
        ; =============================================
        STR R9, [R1, R5, LSL #2]
        STR R7, [R1, R8, LSL #2]

NoSwap
        ADD R5, R5, #1
        B InnerLoop

NextOuter
        ADD R4, R4, #1
        B OuterLoop

SortDone
        POP {R0-R12, LR}
        BX LR

        END
