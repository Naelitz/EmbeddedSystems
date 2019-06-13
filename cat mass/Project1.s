        #include <st/iostm32f207zx.h>
	NAME    main
        
        PUBLIC  __iar_program_start
	PUBLIC  __iar_data_init3
        
        SECTION .intvec : CODE (2)
        thumb
        
__iar_program_start
        B       main

	SECTION .data: DATA (2)
__iar_data_init3
	cat_mass_array: DS32 79, 99, 115, 25, 42, 31, 36, 130, 27, 71, 19, 88, 98
        
        SECTION .text : CODE (2)
        thumb

main   	
	// board initialization
	// Port G pin 6 is the user push button
	// Port F pins 6 through 9 are LEDs 1 through 4
	
	// Enable ports F and G by setting AHB1 peripheral clock register
		LDR	R0, =RCC_AHB1ENR // R0=address of RCC_AHB1ENR
		LDR	R1, [R0]
		ORR	R1, R1, #(1<<6|1<<5) // set bits 5 and 6
		STR	R1, [R0] // and copy back into RCC_AHN1ENR
		
	// Set mode of port G pin 6 to discrete input
		LDR	R0, =GPIOG_MODER // R0=address of GPIOF_MODER
		LDR	R1, [R0] // R1= contents of GPIOG_MODER
		BIC	R1, R1, #0x00003000 // clear bits 12 and 13
		STR	R1, [R0] // and copy back into GPIOG_MODER
	// Set mode of port F pints 6 to 9 to discrete output
		LDR	R0, =GPIOF_MODER // R0=address of GPIOF_MODER
		LDR R1, [R0] // R1=contents of GPIOF_MODER
		BIC	R1, R1, #0x000AA000 // clear bits 13, 15, 17, and 19
		ORR	R1, R1, #0x00055000 // set bits 12, 14, 16, and 18
		STR	R1, [R0] // and copy back into GPIOF_MODER
		
	// inititalize timer TIM2
		LDR	R0, =RCC_APB1ENR // R0=address of RCC_APB1ENR
		LDR	R1, [R0] // R1=contents of RCC
		ORR 	R1,R1, #(1<<0) //set bit 0 to enable peripheral clock
		STR 	R1,[R0] //and copy back into RCC_APB1ENR
		
	// inititalize TIM2 prescalar for 1-ms intervals
		LDR 	R0 , =TIM2_PSC // R0 = address of TIM2_PSC
		LDR 	R1, [R0] // R1 = contents of TIM2_PSC
		MOV	R1, #0x00003E7F //set prescalar to 15999 decimal
		STR 	R1, [R0] //and copy back into TIM2_PSC
		
start_loop
	// turn LED 6 on immediately, users port F output data register GPIOF_ODR
		LDR 	R0, =GPIOF_ODR // R0=address of GPIOF_ODR
		LDR 	R1, [R0] // R1 =contents of GPIOF_ODR
		ORR 	R1, R1 , #(1<<6) // set bit 6 to turn on LED 1 (bit 6)
		STR	R1, [R0] //and copy back into GPIOF_ODR
		
		

	// check if the button is pressed
user_button_press
		/// turn off TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		BIC 	R1, R1, #(1<<0) // set bit 0 to turn off timer
		STR	R1, [R0] // and copy back into TIM2_CR1		
		
		//reset timer
		LDR	R0, = TIM2_EGR // R0=address of TIM2_EGR
		LDR	R1, [R0] 
		ORR	R1, R1, #(1<<0) //reset timer
		STR	R1, [R0] // and copy bac into TIM2_EGR	
		
		LDR	R0, =GPIOG_IDR // address GPIOG_IDR input data register
		LDR	R1, [R0] //R1=address of GPIOG_IDR
		CMP 	R1, #0x00007600 //check to see if bit 6 is not set + 0x7600
		BNE 	user_button_press //branch to check user pushbutton if not pressed
	
		// turn LED 6 off immediately, users port F output data register GPIOF_ODR
		LDR 	R0, =GPIOF_ODR // R0=address of GPIOF_ODR
		LDR 	R1, [R0] // R1 =contents of GPIOF_ODR
		BIC 	R1, R1 , #(1<<6) // set bit 6 to zero to turn off LED 1 (bit 6)
		STR	R1, [R0] //and copy back into GPIOF_ODR	
		
		// inititalize TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		ORR 	R1, R1, #(1<<0) // set bit 0 to enable timer
		STR	R1, [R0] // and copy back into TIM2_CR1		
	
	// now that the timer is running, check the counts
wait_for_timer
		LDR	R2, =GPIOG_IDR // address GPIOG_IDR input data register
		LDR	R3, [R2] //R1=address of GPIOG_IDR
		CMP 	R3, #0x00007600 //check to see if bit 6 is not set + 0x7600
		BNE 	user_button_press //branch to check user pushbutton if not pressed
		LDR 	R0, =TIM2_CNT //R0=address of TIM2_CNT
		LDR 	R1, [R0] // R1 = contents of TIM2_CNT
		CMP	R1, #0x01f4 //check to see if timer counts >=500
		BLT	wait_for_timer //if not, go back and wait
		
		/// turn off TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		BIC 	R1, R1, #(1<<0) // set bit 0 to enable timer
		STR	R1, [R0] // and copy back into TIM2_CR1		
		
		//reset timer
		LDR	R0, = TIM2_EGR // R0=address of TIM2_EGR
		LDR	R1, [R0] 
		ORR	R1, R1, #(1<<0) //reset timer
		STR	R1, [R0] // and copy bac into TIM2_EGR	


light_loop	//turn on LED6 on now that the timer as timed has timed out flashing for 500ms, uses port F output data register GPIOF_ODR
		LDR	R0, =GPIOF_ODR //R0 = address of GPIOF_ODR
		LDR	R1, [R0] //R1=contents of GPIOF_ODR
		ORR	R1, R1, #(1<<6) //set bit 6 to turn on LED 2 (bit 6)
		STR 	R1, [R0] //and copy back into GPIOF_ODR

		// inititalize TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		ORR 	R1, R1, #(1<<0) // set bit 0 to enable timer
		STR	R1, [R0] // and copy back into TIM2_CR1
		
light_wait
		LDR 	R0, =TIM2_CNT //R0=address of TIM2_CNT
		LDR 	R1, [R0] // R1 = contents of TIM2_CNT
		CMP	R1, #0x01f4 //check to see if timer counts >=500
		BLT	light_wait //if not, go back and wait
		
		/// turn off TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		BIC 	R1, R1, #(1<<0) // set bit 0 to disable timer
		STR	R1, [R0] // and copy back into TIM2_CR1	
		
		//reset timer
		LDR	R0, = TIM2_EGR // R0=address of TIM2_EGR
		LDR	R1, [R0] 
		ORR	R1, R1, #(1<<0) //reset timer
		STR	R1, [R0] // and copy bac into TIM2_EGR		
		
		// turn LED 6 off immediately, users port F output data register GPIOF_ODR
		LDR 	R0, =GPIOF_ODR // R0=address of GPIOF_ODR
		LDR 	R1, [R0] // R1 =contents of GPIOF_ODR
		BIC 	R1, R1 , #(1<<6) // set bit 6 to zero to turn off LED 1 (bit 6)
		STR	R1, [R0] //and copy back into GPIOF_ODR	

		LDR R0, =cat_mass_array
Read_cat_mass	//read in cat mass values
		LDR R1, [R0]
		CMP R1, #0x014
		BLE X_underweight
		CMP R1, #0x023
		BLE underweight
		CMP R1, #0x037
		BLE average
		CMP R1, #0x05A
		BLE overweight
		CMP R1, #0x05B
		BGE X_overweight
		

X_underweight


		
	//reset timer if button is off
user_button_release 	//wait for button to be released
		LDR 	R0, = GPIOG_IDR //address of GPIOG_IDR input data register
		LDR 	R1, [R0] //R1 = contents of GPIOG_IDR
		//AND	R1, R1, #(1<<6) //clear all bits except the 6th bit -- fake
		CMP	R1, #0x00007600 //check to see if bit 6 is present + 0x7600
		BEQ	user_button_release //branch to check user pushbutton if not pressed
		
		LDR	R0, = TIM2_CR1 // R0 = address of TIM2_CR1
		LDR	R1, [R0] // R1 = contents of TIM2_CR1
		BIC	R1, R1, #(1<<0) //reset bit 0 to clear timer
		STR	R1, [R0] // and copy back into TIM2_CR1
		
		b start_loop	//unconditional branch to do it all again
		
	END
	
		
light_off_loop
		// inititalize TIM2 control register
		LDR 	R0, =TIM2_CR1 //R0=address of TIM2_CR1
		LDR 	R1, [R0] // R1=contents of TIM2_CR1
		ORR 	R1, R1, #(1<<0) // set bit 0 to enable timer
		STR	R1, [R0] // and copy back into TIM2_CR1
	
light_off_wait
		LDR 	R0, =TIM2_CNT //R0=address of TIM2_CNT
		LDR 	R1, [R0] // R1 = contents of TIM2_CNT
		CMP	R1, #0x064 //check to see if timer counts >=500
		BLT	light_off_wait //if not, go back and wait		
	

OUT
standby 
	b standby

        END
