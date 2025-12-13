        AREA Module3, CODE, READONLY
        EXPORT Vital_Alert_Handler

        IMPORT MAX_PATIENTS
        IMPORT ALERT_COUNT_ARRAY
        IMPORT ALERT_BUFFERS_BASE



Vital_Alert_Handler
        MOV R4, #0

AlertLoop
        LDR R10, =MAX_PATIENTS
        LDR R10, [R10]
        CMP R4, R10
        BEQ AlertDone

        ; Load vitals
        LDR R0, =0x40000000
        ADD R0, R0, R4, LSL #4

        LDR R5, [R0]         ; HR
        LDR R6, [R0, #4]     ; SBP
        LDR R7, [R0, #8]     ; O2

        ; Threshold check
        CMP R5, #120
        BGT MakeAlert

        CMP R7, #92
        BLT MakeAlert

        CMP R6, #160
        BGT MakeAlert

        CMP R6, #90
        BLT MakeAlert

        B NextPatient


MakeAlert
        LDR R0, =ALERT_BUFFERS_BASE
        ADD R0, R0, R4, LSL #8     ; 256 bytes per patient

        LDR R1, =ALERT_COUNT_ARRAY
        LDR R9, [R1, R4, LSL #2]   ; record index

        LSL R9, R9, #4             ; index × 16

        ; temp = base + indexOffset
        ADD R3, R0, R9

        ; Write fields
        STRB R5, [R3]              ; HR at +0
        STRB R7, [R3, #1]          ; O2 at +1
        STRH R6, [R3, #2]          ; SBP at +2
        MOV R8, #0
        STR  R8, [R3, #4]          ; extra field

        ; Timestamp at +8
        STR  R9, [R3, #8]

        ; Increment alert count
        ADD R9, R9, #1
        LSR R9, R9, #4             ; undo ×16 to get index again
        STR R9, [R1, R4, LSL #2]

NextPatient
        ADD R4, R4, #1
        B AlertLoop

AlertDone
        BX LR
        END

