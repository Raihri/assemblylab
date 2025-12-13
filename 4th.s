        AREA Module4, CODE, READONLY
        EXPORT Medicine_Scheduler

        IMPORT MAX_PATIENTS
        IMPORT MED_INTERVAL_ARRAY
        IMPORT MED_LAST_ADMIN_ARRAY
        IMPORT DOSAGE_DUE_ARRAY
        IMPORT CURRENT_TIME_COUNTER

Medicine_Scheduler
        MOV R4, #0

MedLoop
        LDR R10, =MAX_PATIENTS
        LDR R10, [R10]
        CMP R4, R10
        BEQ MedDone

        ; Load interval[i]
        LDR R0, =MED_INTERVAL_ARRAY
        LDR R5, [R0, R4, LSL #2]

        ; Load last_admin[i]
        LDR R1, =MED_LAST_ADMIN_ARRAY
        LDR R6, [R1, R4, LSL #2]

        ; Compute next_due = last + interval
        ADD R7, R6, R5

        ; Load current time
        LDR R8, =CURRENT_TIME_COUNTER
        LDR R8, [R8]

        ; Compare with next_due
        CMP R8, R7
        BLT NotDue

        ; Set DOSAGE_DUE flag
        LDR R2, =DOSAGE_DUE_ARRAY
        MOV R3, #1
        STRB R3, [R2, R4]
        B NextP

NotDue
        LDR R2, =DOSAGE_DUE_ARRAY
        MOV R3, #0
        STRB R3, [R2, R4]

NextP
        ADD R4, R4, #1
        B MedLoop

MedDone
        BX LR
        END
