        NAME    main
        
        PUBLIC  __iar_program_start
	PUBLIC  __iar_data_init3
        
        SECTION .intvec : CODE (2)
        thumb
        
__iar_program_start
        B       main

	SECTION .data: DATA (2)
__iar_data_init3
	Cat_mass_array: DCD 2, 35, 3.5, 4, 0.8
	projectedMass: DS32 25
        
        SECTION .text : CODE (2)
        thumb

main   	
	LDR R3, =projectedMass
	MOV R0, #500
	STR R0, [R3]
	
	LDR R3, =sequence
	LDR R4, =sequence + 4
	LDR R5, =sequence + 8
	MOV R0, #-1
	MOV R1, #-1
	MOV R2, #2
	STR R0, [R3]
	STR R1, [R4]
	STR R2, [R5]
	Mov R1,R1
	MOV R10, #22	

Loop
	LDR R0, [R3]
	LDR R1, [R4]
	LDR R2, [R5]
	ADD R8,R0,R1
	ADD R8,R8,R2
	ADD R3,R3, #4
	ADD R4,R4, #4
	ADD R5,R5, #4
	STR R8,[R5]
	SUB R10,R10, #1
	CMP R10, #0x0
	
	BEQ Mass
	B Loop
Mass
	LDR R0, =projectedMass
	LDR R1, =sequence
	Mov R10, #24
MassLoop	
	LDR R2, [R0]
	LDR R3, [R1]
	ADD R4, R2,R3
	ADD R0,R0, #4
	STR R4, [R0]
	ADD R1,R1, #4
	SUB R10,R10,#1
	CMP R10, #0x0
	
	BEQ OUT
	B MassLoop
	
OUT
standby 
	b standby

        END
