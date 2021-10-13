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
	stmfd	r13!, {r0, r1, r11, r14}	@r14,r11,r1,r0 的值存入memory
	add	r11, r13, #4			
@code body
	add 	r1, r1, #4
	ldr 	r6, [r1]			@r6=argv[1]
	str 	r6, [r5]
	mov 	r0, r6				@r0=r6=argv[1]
	bl 	strlen				@r0=strlen(r0)
	mov 	r4, r0				@r4=r0
	mov 	r7, #0				@r7 is counter
LOOP:
	ldr	r6, [r5]
	ldrb	r6, [r6, r7]			@r6=argv[1][r7]
	mov	r0, r6
	cmp	r0, #65				@65='A'
	addge	r0, r0, #32			@r0>='A'則r0+=32，大寫轉小寫，a(97~)
	cmp	r0, #123			@123='z'+1，加一是因為會扣到Z(122)
	subge	r0, r0, #32			@r0>122則r0-=32，Z(90~)
	cmp	r0, #97				@97='a'
	blt	ELSE				@r0<'a'，91~96不屬於字母範圍
	cmp	r0, #122
	bgt	ELSE				@r0>'z'，122~不屬於字母範圍
	bl	putchar
ELSE:
	add 	r7, r7, #1
	cmp	r7, r4
	bne	LOOP
@end
	sub	r13, r11, #4
	ldmfd	r13!, {r0, r1, r11, lr}
	mov	pc, lr