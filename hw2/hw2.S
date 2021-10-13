@this is comment

@the information that tells arm-none-eabi-as what arch. to assemble to
	.cpu arm926ej-s
	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
main:
@prologue
	STMFD	sp!, {fp, lr}
	ADD	fp, sp, #4
@code body
	MOV 	r2, #0                     @ num1 #-16
    	MOV 	r3, #0                     @ num2 #-12
    	MOV 	r4, #0                     @ op   #-8
    	STMFD 	sp!, {r1, r2, r3, r4}
@int A
    	MOV 	r9, #0
    	MOV 	r0, #4
    	BL 	str_To_int
    	CMP 	r9, #1
    	STRNE 	r2, [fp, #-16]
    	BEQ 	error1
@int B
    	MOV 	r9, #0
    	MOV 	r0, #8
    	BL 	str_To_int
    	CMP 	r9, #1
    	STRNE 	r2, [fp, #-12]
    	BEQ 	error2
@op
    	MOV 	r0, #12
    	BL 	str_To_int
    	STR 	r2, [fp, #-8]

    	LDR 	r1, [fp, #-16]		@int A
    	LDR 	r2, [fp, #-12]		@int B
    	LDR 	r0, [fp, #-8]		@op

    	ADR 	r3, jumptable
    	CMP 	r0, #8
    	LDRLS 	pc, [r3, r0, LSL #2]
	B 	end

str_To_int:
    	STMFD 	sp!, {fp, lr} 
    	ADD	fp, sp, #4          
    	MOV 	r3, #0                  @ loop r3 = i
    	STMFD 	sp!, {r3}		@ stores i in stack
    	MOV 	r2, #0                  @ reset return value r2 = 0
    	MOV 	r5, #10                 @ r5 = 10

loop_str_To_int:
    	LDR 	r3, [fp, #-8]          	@ loads i
    	LDR 	r4, [r1, r0]		@int A
    	LDRB 	r4, [r4, r3]			
    	CMP 	r4, #0
    	BEQ 	end_str_To_int
    	CMP 	r4, #46			@'.'
    	MOVEQ 	r9, #1                  @ error flag
    	SUB 	r4, r4, #48		@r4=r4-'0' 字元變數字
    	MUL 	r6, r2, r5		@r6=r2*r5
    	MOV 	r2, r6
    	ADD 	r2, r2, r4
    	ADD 	r3, r3, #1
    	STR 	r3, [fp, #-8]          	@ stores i
    	BAL 	loop_str_To_int

end_str_To_int:
    	SUB	sp, fp, #4
    	LDMFD 	sp!, {fp, lr}
    	MOV 	pc, lr

error1:
    	LDR 	r0, =invalid_type1
    	LDR 	r2, [r1, #12]
    	LDR 	r1, [r1, #8]
    	BL 	printf
    	B 	end

error2:
    	LDR 	r0, =invalid_type2
    	LDR 	r2, [r1, #12]
    	LDR 	r1, [fp, #-16]
    	BL 	printf

end:
    	MOV 	r0, #0                     
    	SUB	sp, fp, #4
    	LDMFD 	sp!, {fp, lr} 
    	MOV 	pc, lr                   

@ addition
func0:
    	ADD 	r3, r1, r2
    	LDR 	r0, =print_type0
    	B 	result

@ subtraction
func1:
    	SUB 	r3, r1, r2
    	LDR 	r0, =print_type1
    	B 	result

@ bit-reverse
func2:
    	MOV 	r3, #0
    	MOV 	r4, #0
    	MOV 	r5, #1
    	MOV 	r6, #31
    	B 	loop2

addloop2:
    	ADD 	r4, r4, #1

loop2:
    	CMP 	r4, #32
    	BGE 	end_loop2
    	LSL 	r7, r5, r4
   	AND 	r0, r1, r7
    	CMP 	r0, #0
    	BEQ 	addloop2
    	SUB 	r2, r6, r4
    	LSL 	r7, r5, r2
    	ORR 	r3, r3, r7
   	B 	addloop2

end_loop2:
    	LDR 	r0, =print_type2
    	B	result

@ division
func3:
    	MOV 	r3, #0

loop3:
    	SUB 	r1, r1, r2
    	CMP 	r1, #0
    	BLT 	end_loop3
    	ADD 	r3, r3, #1
    	BAL 	loop3

end_loop3:
    	LDR 	r0, =print_type3
    	B 	result

@ maximum
func4:
    	CMP 	r1, r2
    	MOVGE 	r3, r1
    	MOVLT 	r3, r2
    	LDR 	r0, =print_type4
    	B 	result

@ exponent
func5:
    	MOV 	r4, #0
    	MOV 	r5, #1
    	B 	loop5

addloop5:
    	ADD 	r4, r4, #1

loop5:
    	CMP 	r4, r2
    	BGE 	end_loop5
    	MUL 	r3, r5, r1
    	MOV 	r5, r3
    	B 	addloop5

end_loop5:
    	MOV 	r3, r5
    	LDR 	r0, =print_type5
    	B 	result

@ GCD
func6:
    	CMP 	r1, r2
    	SUBGT 	r1, r1, r2
    	SUBLT 	r2, r2, r1
    	BNE 	func6
    	MOV 	r3, r1
    	LDR 	r0, =print_type6
    	B 	result

@ multiplication
func7:
    	MUL 	r3, r1, r2
    	LDR 	r0, =print_type7
    	B 	result

@ LCM
func8:
    	MOV 	r3, #0
    	MUL 	r5, r1, r2

loop8_1:
    	CMP 	r1, r2
    	SUBGT 	r1, r1, r2
    	SUBLT 	r2, r2, r1
    	BNE 	loop8_1
    	MOV 	r4, r1

loop8_2:
    	SUB 	r5, r5, r4
    	CMP 	r5, #0
    	BLT 	end_func8
    	ADD 	r3, r3, #1
    	BAL 	loop8_2

end_func8:
    	LDR 	r0, =print_type8
    	B 	result

result:
    	LDR 	r1, [r11, #-16]
    	LDR 	r2, [r11, #-12]
    	BL 	printf
    	B 	end

.align 2
print_type0:
    .asciz "Function 0: addition of %d and %d is %d.\n"
print_type1:
    .asciz "Function 1: subtraction of %d and %d is %d.\n"
print_type2:
    .asciz "Function 2: bit-reverse of %d and %d is %d.\n"
print_type3:
    .asciz "Function 3: division of %d and %d is %d.\n"
print_type4:
    .asciz "Function 4: maximum of %d and %d is %d.\n"
print_type5:
    .asciz "Function 5: exponent of %d and %d is %d.\n"
print_type6:
    .asciz "Function 6: greatest common divisor of %d and %d is %d.\n"
print_type7:
    .asciz "Function 7: multiplication of %d and %d is %d.\n"
print_type8:
    .asciz "Function 8: least common multiply of %d and %d is %d.\n"
invalid_type1:
    .asciz "Invalid input operands: %s, %s\n"
invalid_type2:
    .asciz "Invalid input operands: %d, %s\n"

.align 4
jumptable:
    .word func0
    .word func1
    .word func2
    .word func3
    .word func4
    .word func5
    .word func6
    .word func7
    .word func8

.end
