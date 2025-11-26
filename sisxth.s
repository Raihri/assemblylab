        AREA Module6, CODE, READONLY
        EXPORT Calc_RoomRent
        IMPORT PATIENT_ARRAY
        IMPORT BILLING_ARRAY
        IMPORT STAY_DAYS
        IMPORT MAX_PATIENTS
        IMPORT PATIENT_SIZE
        IMPORT BILL_SIZE

Calc_RoomRent
        MOV R0, #0                          ; patient index

RoomLoop
        LDR R10, =MAX_PATIENTS              ; load max count
        LDR R10, [R10]
        CMP R0, R10
        BEQ RoomDone

        LDR R1, =PATIENT_ARRAY              ; base patients
        LDR R2, =PATIENT_SIZE
        LDR R2, [R2]
        MUL R3, R0, R2
        ADD R1, R1, R3                      ; R1 = patient[i]

        LDR R4, [R1, #0x10]                 ; room rate

        LDR R5, =STAY_DAYS                  ; stay days
        LDR R5, [R5]

        MUL R6, R4, R5                      ; base room cost

        CMP R5, #10                         ; check discount
        BLE NoDisc

        MOV R7, #20
        UDIV R8, R6, R7                     ; 5% of cost
        SUB R6, R6, R8                      ; discounted cost

NoDisc
        LDR R9, =BILLING_ARRAY              ; base billing
        LDR R11, =BILL_SIZE
        LDR R11, [R11]
        MUL R12, R0, R11
        ADD R9, R9, R12                     ; R9 = billing[i]

        STR R6, [R9, #4]                    ; store room cost

        ADD R0, R0, #1
        B RoomLoop

RoomDone
        BX LR
        END
