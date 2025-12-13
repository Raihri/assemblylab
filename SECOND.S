        AREA Module2, CODE, READONLY
        EXPORT Second_Module

        IMPORT PATIENT_ARRAY
        IMPORT VITAL_INDEX
		IMPORT HR_SENSORS
		IMPORT O2_SENSORS
		IMPORT BP_SENSORS

Second_Module
        PUSH {R0-R10, LR}

        ; -----------------------------
        ; Arrays of sensor addresses
        ; -----------------------------
        LDR R0, =HR_SENSORS
        LDR R1, =BP_SENSORS
        LDR R2, =O2_SENSORS

        MOV R3, #0                ; patient index

patient_loop
        CMP R3, #3
        BEQ done

        ; -----------------------------
        ; Load patient struct pointer
        ; -----------------------------
        LDR R4, =PATIENT_ARRAY
        LDR R5, [R4, R3, LSL #2] ; patient struct pointer

        ; -----------------------------
        ; Load rolling index for patient
        ; -----------------------------
        LDR R6, =VITAL_INDEX
        LDRB R7, [R6, R3]         ; current index 0-9

        ; -----------------------------
        ; Load buffer pointers from struct
        ; -----------------------------
        LDR R8, [R5, #24]         ; HR buffer pointer
        LDR R9, [R5, #28]         ; BP buffer pointer
        LDR R10,[R5, #32]         ; O2 buffer pointer

        ; -----------------------------
        ; Read HR
        ; -----------------------------
        LDR R11, [R0, R3, LSL #2] ; sensor address
        LDR R12, [R11]            ; HR reading
        STR R12, [R8, R7, LSL #2]

        ; -----------------------------
        ; Read BP
        ; -----------------------------
        LDR R11, [R1, R3, LSL #2]
        LDR R12, [R11]
        STR R12, [R9, R7, LSL #2]

        ; -----------------------------
        ; Read O2
        ; -----------------------------
        LDR R11, [R2, R3, LSL #2]
        LDR R12, [R11]
        STR R12, [R10, R7, LSL #2]

        ; -----------------------------
        ; Increment index modulo 10
        ; -----------------------------
        ADD R7, R7, #1
        CMP R7, #10
        IT GE
        MOVGE R7, #0
        STRB R7, [R6, R3]

        ADD R3, R3, #1
        B patient_loop

done
        POP {R0-R10, LR}
        BX LR
