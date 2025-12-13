        AREA DataSection, DATA, READWRITE
        EXPORT MAX_PATIENTS
        EXPORT PATIENT_SIZE
        EXPORT PATIENT_ARRAY
		

        EXPORT ALERT_COUNT_ARRAY
        EXPORT ALERT_BUFFERS_BASE
        EXPORT ALERT_RECORD_SIZE

        EXPORT MED_INTERVAL_ARRAY
        EXPORT MED_LAST_ADMIN_ARRAY
        EXPORT DOSAGE_DUE_ARRAY

; -------------------------------
; CONSTANTS
; -------------------------------
MAX_PATIENTS        DCD 4
PATIENT_SIZE        DCD 32

ALERT_RECORD_SIZE   DCD 16          ; 16 bytes per alert record
ALERT_BUFFERS_BASE  DCD 0x20001000  ; base of alert buffers

; -------------------------------
; PATIENT ARRAY (4 × 32 = 128B)
; -------------------------------
PATIENT_ARRAY       SPACE 32*4

; -------------------------------
; ALERTS
; -------------------------------
; 4-word array storing how many alerts each patient has
ALERT_COUNT_ARRAY   SPACE 4*4

; -------------------------------
; MEDICINE SCHEDULER (Module 4)
; -------------------------------
; Each patient has:
;   med interval (hours)
;   last administered timestamp
;   dosage due flag
;
; Arrays indexed by patient number
MED_INTERVAL_ARRAY      SPACE 4*4
MED_LAST_ADMIN_ARRAY    SPACE 4*4
DOSAGE_DUE_ARRAY        SPACE 4    ; byte flags

        END
