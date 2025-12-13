        AREA Module1, CODE, READONLY
        EXPORT Init_Patients

        IMPORT MAX_PATIENTS
        IMPORT PATIENT_ARRAY
        IMPORT ALERT_COUNT_ARRAY

Init_Patients
        MOV R4, #0                        ; patient index

InitLoop
        LDR R10, =MAX_PATIENTS
        LDR R10, [R10]
        CMP R4, R10
        BEQ InitDone

        ; Base = PATIENTS_BASE + i * 32
        LDR R0, =PATIENT_ARRAY
        ADD R0, R0, R4, LSL #5            ; ×32 bytes per patient

        ; Patient ID
        STR R4, [R0]

        ; Name ptr (dummy)
        LDR R1, =0x30000000
        STR R1, [R0, #4]

        ; Age
        MOV R1, #25
        STRB R1, [R0, #8]

        ; Ward number
        MOV R1, #100
        ADD R1, R1, R4
        STRH R1, [R0, #9]

        ; Treatment code
        MOV R1, #1
        STRB R1, [R0, #11]

        ; Daily rate
        MOV R1, #5000
        STR R1, [R0, #12]

        ; Medicine list pointer
        LDR R1, =0x30001000
        STR R1, [R0, #16]

        ; Alert Count = 0
        LDR R2, =ALERT_COUNT_ARRAY
        MOV R3, #0
        STR R3, [R2, R4, LSL #2]

        ADD R4, R4, #1
        B InitLoop

InitDone
        BX LR
        END
