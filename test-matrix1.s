	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 13
	.globl	_main                   ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:                               ## %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$1, %edi
	movl	$1, %esi
	callq	_initMatrix_CG
	movq	%rax, (%rsp)
	movq	%rax, %rdi
	movl	$1, %esi
	movl	$1, %edx
	callq	_print_int_matrix
	xorl	%eax, %eax
	popq	%rcx
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_fmt:                                  ## @fmt
	.asciz	"%d\n"

L_fmt.1:                                ## @fmt.1
	.asciz	"%c\n"

L_fmt.2:                                ## @fmt.2
	.asciz	"%s\n"

L_fmt.3:                                ## @fmt.3
	.asciz	"%g\n"


.subsections_via_symbols
