	.text
	.syntax unified
	.eabi_attribute	67, "2.09"	@ Tag_conformance
	.eabi_attribute	6, 1	@ Tag_CPU_arch
	.eabi_attribute	8, 1	@ Tag_ARM_ISA_use
	.eabi_attribute	34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute	17, 1	@ Tag_ABI_PCS_GOT_use
	.eabi_attribute	20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute	21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute	23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute	24, 1	@ Tag_ABI_align_needed
	.eabi_attribute	25, 1	@ Tag_ABI_align_preserved
	.eabi_attribute	38, 1	@ Tag_ABI_FP_16bit_format
	.eabi_attribute	18, 4	@ Tag_ABI_PCS_wchar_t
	.eabi_attribute	14, 0	@ Tag_ABI_PCS_R9_use
	.file	"main.cpp"
	.section	.text.startup,"ax",%progbits
	.p2align	2                               @ -- Begin function __cxx_global_var_init
	.type	__cxx_global_var_init,%function
	.code	32                              @ @__cxx_global_var_init
__cxx_global_var_init:
	.fnstart
@ %bb.0:
	push	{r4, r10, r11, lr}
	add	r11, sp, #8
	ldr	r4, .LCPI0_0
	mov	r0, r4
	bl	_ZNSt8ios_base4InitC1Ev
	ldr	r0, .LCPI0_1
	ldr	r2, .LCPI0_2
	mov	r1, r4
	bl	__cxa_atexit
	pop	{r4, r10, r11, lr}
	mov	pc, lr
	.p2align	2
@ %bb.1:
.LCPI0_0:
	.long	_ZStL8__ioinit
.LCPI0_1:
	.long	_ZNSt8ios_base4InitD1Ev
.LCPI0_2:
	.long	__dso_handle
.Lfunc_end0:
	.size	__cxx_global_var_init, .Lfunc_end0-__cxx_global_var_init
	.fnend
                                        @ -- End function
	.text
	.globl	main                            @ -- Begin function main
	.p2align	2
	.type	main,%function
	.code	32                              @ @main
main:
	.fnstart
@ %bb.0:
	push	{r11, lr}
	mov	r11, sp
	sub	sp, sp, #16
	mov	r0, #0
	str	r0, [r11, #-4]
	ldr	r0, .LCPI1_0
	add	r1, sp, #4
	bl	_ZNSirsERi
	mov	r0, #2
	str	r0, [sp, #8]
	mov	r0, #1
	str	r0, [sp]
	b	.LBB1_1
.LBB1_1:                                @ =>This Inner Loop Header: Depth=1
	ldr	r0, [sp, #8]
	ldr	r1, [sp, #4]
	cmp	r0, r1
	bgt	.LBB1_3
	b	.LBB1_2
.LBB1_2:                                @   in Loop: Header=BB1_1 Depth=1
	ldr	r0, [sp]
	ldr	r1, [sp, #8]
	mul	r2, r0, r1
	str	r2, [sp]
	ldr	r0, [sp, #8]
	add	r0, r0, #1
	str	r0, [sp, #8]
	b	.LBB1_1
.LBB1_3:
	ldr	r1, [sp]
	ldr	r0, .LCPI1_1
	bl	_ZNSolsEi
	ldr	r1, .LCPI1_2
	bl	_ZNSolsEPFRSoS_E
	ldr	r0, [r11, #-4]
	mov	sp, r11
	pop	{r11, lr}
	mov	pc, lr
	.p2align	2
@ %bb.4:
.LCPI1_0:
	.long	_ZSt3cin
.LCPI1_1:
	.long	_ZSt4cout
.LCPI1_2:
	.long	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.fnend
                                        @ -- End function
	.section	.text.startup,"ax",%progbits
	.p2align	2                               @ -- Begin function _GLOBAL__sub_I_main.cpp
	.type	_GLOBAL__sub_I_main.cpp,%function
	.code	32                              @ @_GLOBAL__sub_I_main.cpp
_GLOBAL__sub_I_main.cpp:
	.fnstart
@ %bb.0:
	push	{r11, lr}
	mov	r11, sp
	bl	__cxx_global_var_init
	pop	{r11, lr}
	mov	pc, lr
.Lfunc_end2:
	.size	_GLOBAL__sub_I_main.cpp, .Lfunc_end2-_GLOBAL__sub_I_main.cpp
	.fnend
                                        @ -- End function
	.type	_ZStL8__ioinit,%object          @ @_ZStL8__ioinit
	.local	_ZStL8__ioinit
	.comm	_ZStL8__ioinit,1,1
	.hidden	__dso_handle
	.section	.init_array,"aw",%init_array
	.p2align	2
	.long	_GLOBAL__sub_I_main.cpp(target1)
	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",%progbits
