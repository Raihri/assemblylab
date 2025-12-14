		AREA Module3, CODE, READONLY
		EXPORT Vital_Alert_Handler

		IMPORT PATIENT_ARRAY
		IMPORT VITAL_INDEX
		IMPORT MAX_PATIENTS
		IMPORT ALERT_COUNT_ARRAY
		IMPORT ALERT_FLAG_ARRAY
		IMPORT ALERT_BUFFERS_BASE

Vital_Alert_Handler
    PUSH {R4-R12, LR}          ; Save ALL registers
    MOV R4, #0                 ; patient index

AlertLoop
    ; Check if done with all patients
    CMP R4, #3
    BGE AlertDone

    ; ----- Get patient struct address -----
    LDR R0, =PATIENT_ARRAY
    MOV R5, #44               ; Patient struct size
    MUL R5, R4, R5            ; index * 44
    ADD R5, R0, R5            ; R5 = &PATIENT_ARRAY[index]

    ; ----- Load rolling index -----
    LDR R6, =VITAL_INDEX
    LDRB R7, [R6, R4]         ; R7 = current index (0-9)
    
    ; Check if index is valid (0-9)
    CMP R7, #10
    BGE NextPatient           ; Skip if invalid

    ; ----- Load buffer pointers -----
    LDR R8,  [R5, #24]        ; HR buffer
    LDR R9,  [R5, #28]        ; BP buffer
    LDR R11, [R5, #32]        ; O2 buffer

    ; Check if buffers exist
    CMP R8, #0
    BEQ NextPatient
    CMP R9, #0
    BEQ NextPatient
    CMP R11, #0
    BEQ NextPatient

    ; ----- Load LATEST readings (at current index) -----
    LDR R12, [R8, R7, LSL #2] ; HR
    LDR R2,  [R9, R7, LSL #2] ; SBP
    LDR R3,  [R11, R7, LSL #2] ; O2

    ; ----- Threshold checks -----
    CMP R12, #120
    BGT RaiseAlert

    CMP R3, #92
    BLT RaiseAlert

    CMP R2, #160
    BGT RaiseAlert

    CMP R2, #90
    BLT RaiseAlert

    B NextPatient

; =====================================
; ALERT HANDLING
; =====================================
RaiseAlert
    ; ----- Save patient struct address (R5) -----
    PUSH {R5}

    ; ----- Set ALERT FLAG = 1 -----
    LDR R0, =ALERT_FLAG_ARRAY
    MOV R1, #1
    STRB R1, [R0, R4]

    ; ----- Compute alert buffer base -----
    LDR R0, =ALERT_BUFFERS_BASE
    LDR R0, [R0]               ; Load the base address value
    MOV R1, #128               ; 128 bytes per patient
    MUL R6, R4, R1             ; R6 = patient_index * 128
    ADD R0, R0, R6             ; R0 = base for this patient

    ; ----- Get alert count -----
    LDR R1, =ALERT_COUNT_ARRAY
    LDR R6, [R1, R4, LSL #2]   ; R6 = alert count

    ; Calculate offset: alert_count * 16
    MOV R10, #16
    MUL R10, R6, R10           ; R10 = alert_count * 16
    ADD R10, R0, R10           ; R10 = alert record address

        ; ----- Write 16-byte alert record -----
    MOV R0, #1                 ; Alert type = critical
    STRB R0, [R10]             ; +0 vital type

    STRB R12, [R10, #1]        ; +1 HR
    STRH R2, [R10, #2]         ; +2 SBP (values 90-160 fit in halfword)
    STRB R3, [R10, #4]         ; +4 O2

    MOV R0, #0
    STR R0, [R10, #8]          ; +8 timestamp    ; +8 timestamp

    ; ----- Increment alert count -----
    ADD R6, R6, #1
    STR R6, [R1, R4, LSL #2]

    ; ----- Restore patient struct address -----
    POP {R5}

NextPatient
    ADD R4, R4, #1
    B AlertLoop

AlertDone
    POP {R4-R12, PC}           ; Return properly

    END
