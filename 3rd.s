        AREA Module3, CODE, READONLY
        EXPORT Vital_Alert_Handler

        IMPORT PATIENT_ARRAY
        IMPORT VITAL_INDEX
        IMPORT MAX_PATIENTS
        IMPORT ALERT_COUNT_ARRAY
        IMPORT ALERT_FLAG_ARRAY
        IMPORT ALERT_BUFFERS_BASE

Vital_Alert_Handler
        MOV R4, #0                      ; patient index

AlertLoop
        LDR R10, =MAX_PATIENTS
        LDR R10, [R10]
        CMP R4, R10
        BEQ AlertDone

        ; --------------------------------
        ; Load patient struct pointer
        ; --------------------------------
        LDR R0, =PATIENT_ARRAY
        LDR R5, [R0, R4, LSL #2]        ; R5 = patient struct ptr

        ; --------------------------------
        ; Load rolling index
        ; --------------------------------
        LDR R6, =VITAL_INDEX
        LDRB R7, [R6, R4]               ; current index (0–9)

        ; last_index = (index - 1 + 10) % 10
        CMP R7, #0
        BNE NotZero
        MOV R7, #9
        B IndexOK
NotZero
        SUB R7, R7, #1
IndexOK

        ; --------------------------------
        ; Load buffer pointers
        ; --------------------------------
        LDR R8,  [R5, #24]              ; HR buffer
        LDR R9,  [R5, #28]              ; BP buffer
        LDR R11, [R5, #32]              ; O2 buffer

        ; --------------------------------
        ; Load latest readings
        ; --------------------------------
        LDR R12, [R8,  R7, LSL #2]      ; HR
        LDR R2,  [R9,  R7, LSL #2]      ; SBP
        LDR R3,  [R11, R7, LSL #2]      ; O2

        ; --------------------------------
        ; Threshold checks
        ; --------------------------------
        CMP R12, #120
        BGT RaiseAlert

        CMP R3, #92
        BLT RaiseAlert

        CMP R2, #160
        BGT RaiseAlert

        CMP R2, #90
        BLT RaiseAlert

        B NextPatient

; =====================================
; ALERT HANDLING
; =====================================
RaiseAlert
        ; --------------------------------
        ; Set ALERT FLAG = 1
        ; --------------------------------
        LDR R0, =ALERT_FLAG_ARRAY
        MOV R1, #1
        STRB R1, [R0, R4]

        ; --------------------------------
        ; Compute alert buffer base
        ; --------------------------------
        LDR R0, =ALERT_BUFFERS_BASE
        ADD R0, R0, R4, LSL #7          ; 128 bytes per patient

        ; alert index
        LDR R1, =ALERT_COUNT_ARRAY
        LDR R6, [R1, R4, LSL #2]

        LSL R6, R6, #4                  ; ×16 bytes
        ADD R7, R0, R6                  ; alert record address

        ; --------------------------------
        ; Write 16-byte alert record
        ; --------------------------------
        MOV R5, #1
        STRB R5, [R7]                   ; +0 vital type (1 = critical)

        STRB R12, [R7, #1]              ; +1 HR
        STRH R2,  [R7, #2]              ; +2 SBP
        STRB R3,  [R7, #4]              ; +4 O2

        STR R6,  [R7, #8]               ; +8 timestamp (counter)

        ; --------------------------------
        ; Increment alert count
        ; --------------------------------
        LDR R6, [R1, R4, LSL #2]
        ADD R6, R6, #1
        STR R6, [R1, R4, LSL #2]

NextPatient
        ADD R4, R4, #1
        B AlertLoop

AlertDone
        BX LR
        END
