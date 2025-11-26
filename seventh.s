        AREA Module7, CODE, READONLY
        EXPORT Calc_MedBill
        IMPORT PATIENT_ARRAY
        IMPORT BILLING_ARRAY
        IMPORT MED_DAYS
        IMPORT MAX_PATIENTS
        IMPORT PATIENT_SIZE
        IMPORT BILL_SIZE

Calc_MedBill
        MOV R0, #0                          ; patient index

MedOuter
        LDR R10, =MAX_PATIENTS              ; load max
        LDR R10, [R10]
        CMP R0, R10
        BEQ MedDone

        LDR R1, =PATIENT_ARRAY              ; base patients
        LDR R2, =PATIENT_SIZE
        LDR R2, [R2]
        MUL R3, R0, R2
        ADD R1, R1, R3                      ; R1 = patient[i]

        LDR R4, [R1, #0x14]                 ; med list pointer

        LDR R5, =MED_DAYS                   ; number of days
        LDR R5, [R5]

        MOV R6, #5                          ; number of meds
        MOV R7, #0                          ; total med cost

MedInner
        CMP R6, #0
        BEQ MedStore

        LDR R8, [R4], #4                    ; unit price
        LDR R9, [R4], #4                    ; quantity

        MUL R10, R8, R9                     ; price * qty
        MUL R10, R10, R5                    ; * days
        ADD R7, R7, R10                     ; accumulate

        SUB R6, R6, #1
        B MedInner

MedStore
        LDR R11, =BILLING_ARRAY             ; base billing
        LDR R12, =BILL_SIZE
        LDR R12, [R12]
        MUL R2, R0, R12
        ADD R11, R11, R2                    ; R11 = billing[i]

        STR R7, [R11, #8]                   ; store med cost

        ADD R0, R0, #1
        B MedOuter

MedDone
        BX LR
        END
