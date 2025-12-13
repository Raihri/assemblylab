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

Stop
        B Stop

        END
