
        AREA Adress, DATA, READWRITE
PATIENT_RECORD  SPACE 32      
PATIENT_NAME  DCB "unga bunga", 0
MED_LIST      DCD 1,2,3,4,5	
	    AREA first,CODE,READONLY
		EXPORT First_module
        
First_module
        LDR R0, =PATIENT_RECORD  ; Base address 

        ; Patient ID
        MOV R1, #12345
        STR R1, [R0, #0]

        ; Name pointer 
        LDR R1, =PATIENT_NAME
        STR R1, [R0, #4]

        ; Age
        MOV R1, #25
        STRB R1, [R0, #8]

        ; Ward number
        MOV R1, #101
        STRH R1, [R0, #0x0A]

        ; Treatment 
        MOV R1, #3
        STRB R1, [R0, #0x0C]

        ; Room Rate
        MOV R1, #5000
        STR R1, [R0, #0x10]

        ;med pointer
        LDR R1, =MED_LIST
        STR R1, [R0, #0x14]

        BX  LR
		
