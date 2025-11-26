        AREA MainCode, CODE, READONLY
        EXPORT main
        IMPORT First_module
        IMPORT Calc_TreatCost
        ENTRY

main
        BL First_module            ; initialize
        BL Calc_TreatCost          ; compute costs

Stop
        B Stop
        END
