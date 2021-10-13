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
	stmfd	sp!, {fp, lr}		@store content of ctl regs
	add	fp, sp, #4

@code body
	bl start_deasm
	.include "test.s"

start_deasm:
	sub	r1, pc, #8		@ or use: ldr r1, =start_deasm
	sub 	r1, r1, lr
	mov 	r6, r1			@ r6 save total number of instruction
	mov 	r5, lr			@ r5 save addr of first instruction
	ldr 	r0, = format_str	@print format
	bl	printf
	mov r4, #-4			@ r4 as index counter

KEEP_SCAN:
	add 	r4, r4, #4 		@ r4 start from 0
	subs 	r6, r6, #4
	bmi 	END_SCAN_DATA		@ r6 is negative, end.
	ldr 	r7, [r5], #4 		@r7 get data, r5 post-incre

PRINT_PC:
	ldr 	r0, = pc_str
	mov 	r1, r4
	bl 	printf			@print PC-count	
	b  	COND

COND:
	@condition
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsl #3		@Aligned with cond_str_data
	ldr 	r0, = cond_str_data
	add 	r0, r0, r1
	bl 	printf
	b  	ZERO_ZERO

ZERO_ZERO:
	@ 00 -data-process?
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #12
	bic 	r1, #0xFFFFFFFC
	cmp 	r1, #0			@is it a data process instruction?
	bne 	NOT_DATA_PCS		@not a data ProCeSs instruction!
	b   	OP_CODE

NOT_DATA_PCS:
	ldr 	r0, = no_instr_str
	bl 	printf
	b  	ADD_END_LINE		@jump to bottom-of-loop

OP_CODE:
	@ opcode
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #7
	bic 	r1, #0xFFFFFFF0
	mov 	r1, r1, lsl #3   	@Aligned with instr_str_data
	ldr 	r0, = instr_str_data
	add 	r0, r0, r1
	bl 	printf
	b  	CHECK_NO_DST

CHECK_NO_DST:
	@use opcode to check if no need for dstreg
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #7
	bic 	r1, #0xFFFFFFF0
	cmp 	r1, #8
	blt 	GET_RD
	cmp 	r1, #11
	bgt 	GET_RD
NO_RD_NEED:
	ldr 	r0, = no_dstreg_str
	bl 	printf
	b  	NOT_MOV_TYPE

GET_RD:
	@ Rd
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #12
	bic 	r1, #0xFFFFFFF0
	ldr 	r0, = dstreg_str
	bl 	printf
	b  	CHECK_MOV_TYPE

CHECK_MOV_TYPE:	
	@use opcode to check if it is mov type instruction
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #7
	bic 	r1, #0xFFFFFFF0	
	cmp 	r1, #13			@mov
	beq 	IS_MOV_TYPE
	cmp 	r1, #15			@mvn
	beq 	IS_MOV_TYPE
	b   	NOT_MOV_TYPE

IS_MOV_TYPE:
SC_NUM_FOR_MV:
	@ # -second-op-pure-num?
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #11
	bic 	r1, #0xFFFFFFFE
	cmp 	r1, #1
	bmi 	NOT_IMMD_FOR_MV
GET_IMMD_FOR_MV:
	@ 8-bits-immediate
	mov 	r1, r7			@r7 always contain instruction data
	bic 	r1, #0xFFFFFF00
	ldr 	r0, = sec_pure_num_str
	bl 	printf
	b  	ADD_END_LINE		@jump to bottom-of-loop

NOT_IMMD_FOR_MV:
GET_RM_FOR_MV:
	@ Rm
	mov 	r1, r7			@r7 always contain instruction data
	bic 	r1, #0xFFFFFFF0
	ldr 	r0, = sec_op_str
	bl 	printf
	b  	ADD_END_LINE		@jump to bottom-of-loop

NOT_MOV_TYPE:
GET_RN:
	@ Rn
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #2
	bic 	r1, #0xFFFFFFF0
	ldr 	r0, = fst_op_str
	bl 	printf
SC_NUM:
	@ # -second-op-pure-num?
	mov 	r1, r7			@r7 always contain instruction data
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #11
	bic 	r1, #0xFFFFFFFE
	cmp 	r1, #1
	bmi 	NOT_IMMD
GET_IMMD:
	@ 8-bits-immediate
	mov 	r1, r7			@r7 always contain instruction data
	bic 	r1, #0xFFFFFF00
	ldr 	r0, = sec_pure_num_str
	bl 	printf
	b  	ADD_END_LINE		@jump to bottom-of-loop

NOT_IMMD:
GET_RM:
	@ Rm
	mov 	r1, r7			@r7 always contain instruction data
	bic 	r1, #0xFFFFFFF0
	ldr 	r0, = sec_op_str
	bl 	printf
	b  	ADD_END_LINE		@jump to bottom-of-loop

ADD_END_LINE:
	ldr 	r0, = end_line_str
	bl 	printf
	b  	KEEP_SCAN		@bottom-of-loop loop-back

END_SCAN_DATA:
EndProgram:

@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr

@below not used this time:
S_BIT:
	@ S bit
	mov 	r1, r6
	mov 	r1, r1, lsr #14
	mov 	r1, r1, lsr #6
	bic 	r1, #0xFFFFFFFE
	ldr 	r0, = answer_str
	bl 	printf
GET_SHIFT:
	@shift length
	mov 	r1, r6
	mov 	r1, r1, lsr #7
	bic 	r1, #0xFFFFFFE0
	ldr 	r0, = answer_str
	bl 	printf
GET_SH:
	@Sh -shift-type
	mov 	r1, r6
	mov 	r1, r1, lsr #5
	bic 	r1, #0xFFFFFFFC
	ldr 	r0, = answer_str
	bl 	printf
GET_SH_CK_BIT:
	@ 0 or 1 -sh-length-from-rg-or-immd
	mov 	r1, r6
	mov 	r1, r1, lsr #4
	bic 	r1, #0xFFFFFFFE
	ldr 	r0, = answer_str
	bl 	printf
GET_RS:
	@ rs -register-for-shift
	mov 	r1, r6
	mov 	r1, r1, lsr #8
	bic 	r1, #0xFFFFFFF0
	ldr 	r0, = answer_str
	bl 	printf
@above not used this time:

@data section
debug_input_str:
	.ascii	"There are %d Bytes of instruction\n\0"

format_str:
	.ascii	"PC \tcondition \tinstruction \tdstreg \n\0" 

pc_str:
	.ascii	"%d \t\0"

cond_str_data:
	.ascii	"EQ   \t\t\0" @ 8 bytes
	.ascii	"NE   \t\t\0" @ 8 bytes
	.ascii	"CS/HS\t\t\0" @ 8 bytes
	.ascii	"CC/LO\t\t\0" @ 8 bytes
	.ascii	"MI   \t\t\0" @ 8 bytes
	.ascii	"PL   \t\t\0" @ 8 bytes
	.ascii	"VS   \t\t\0" @ 8 bytes
	.ascii	"VC   \t\t\0" @ 8 bytes
	.ascii	"HI   \t\t\0" @ 8 bytes
	.ascii	"LS   \t\t\0" @ 8 bytes
	.ascii	"GE   \t\t\0" @ 8 bytes
	.ascii	"LT   \t\t\0" @ 8 bytes
	.ascii	"GT   \t\t\0" @ 8 bytes
	.ascii	"LE   \t\t\0" @ 8 bytes
	.ascii	"AL   \t\t\0" @ 8 bytes
	.ascii	"NV   \t\t\0" @ 8 bytes

instr_str_data:
	.ascii	"AND  \t\t\0" @ 8 bytes
	.ascii	"EOR  \t\t\0" @ 8 bytes
	.ascii	"SUB  \t\t\0" @ 8 bytes
	.ascii	"RSB  \t\t\0" @ 8 bytes
	.ascii	"ADD  \t\t\0" @ 8 bytes
	.ascii	"ADC  \t\t\0" @ 8 bytes
	.ascii	"SBC  \t\t\0" @ 8 bytes
	.ascii	"RSC  \t\t\0" @ 8 bytes
	.ascii	"TST  \t\t\0" @ 8 bytes
	.ascii	"TEQ  \t\t\0" @ 8 bytes
	.ascii	"CMP  \t\t\0" @ 8 bytes
	.ascii	"CMN  \t\t\0" @ 8 bytes
	.ascii	"ORR  \t\t\0" @ 8 bytes
	.ascii	"MOV  \t\t\0" @ 8 bytes
	.ascii	"BIC  \t\t\0" @ 8 bytes
	.ascii	"MVN  \t\t\0" @ 8 bytes

no_instr_str:
	.ascii	"xxx   \t\0" @ 8 bytes

dstreg_str:
	.ascii	"r%d\t\0"

no_dstreg_str:
	.ascii	"r0\t\0"

fst_op_str:
	.ascii	"\0"

sec_op_str:
	.ascii	"\0"

sec_pure_num_str:
	.ascii	"\0"

end_line_str:
	.ascii	" \n\0"

answer_str:
	.ascii	"oh wow %d\n\0"

    .end

