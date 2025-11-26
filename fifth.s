        AREA Module5, CODE, READONLY
        EXPORT Calc_TreatCost
        IMPORT PATIENT_ARRAY
        IMPORT BILLING_ARRAY
        IMPORT TREATMENT_TABLE
        IMPORT MAX_PATIENTS
        IMPORT PATIENT_SIZE
        IMPORT BILL_SIZE

Calc_TreatCost
        MOV R0, #0                          ; patient index

TreatLoop
        ; Load MAX_PATIENTS into R10
        LDR R10, =MAX_PATIENTS
        LDR R10, [R10]
        CMP R0, R10
        BEQ TreatDone

        ; Compute patient[i] address
        LDR R1, =PATIENT_ARRAY
        LDR R2, =PATIENT_SIZE
        LDR R2, [R2]
        MUL R3, R0, R2
        ADD R1, R1, R3                      ; R1 = patient ptr

        ; Load treatment code
        LDRB R4, [R1, #0x0C]
        LSL R4, R4, #2                      ; index * 4

        ; Get cost from table
        LDR R5, =TREATMENT_TABLE
        LDR R6, [R5, R4]

        ; Compute billing[i] address
        LDR R7, =BILLING_ARRAY
        LDR R8, =BILL_SIZE
        LDR R8, [R8]
        MUL R9, R0, R8
        ADD R7, R7, R9                      ; R7 = billing[i]

        STR R6, [R7, #0]                    ; store treatment cost

        ADD R0, R0, #1
        B TreatLoop

TreatDone
        BX LR
        END
