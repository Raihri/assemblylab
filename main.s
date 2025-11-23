    AREA kjr, CODE, READONLY
		ENTRY
		IMPORT First_module
    EXPORT main


main
        
		BL First_module
stop
		B stop
		END
