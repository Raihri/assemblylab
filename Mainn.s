        AREA MainCode, CODE, READONLY
        EXPORT main

        IMPORT Init_Patients
        IMPORT Vital_Alert_Handler
        IMPORT Medicine_Scheduler

        ENTRY

main
        BL Init_Patients
        BL Vital_Alert_Handler
        BL Medicine_Scheduler
main_loop
         ; simulate time passing
    LDR R0, =CURRENT_TIME
    LDR R1, [R0]
    ADD R1, R1, #1         ; increment by 1 unit per loop
    STR R1, [R0]

    ; check medicine
    BL Medicine_Scheduler
    B main_loop
    
Stop
        B Stop

        END

