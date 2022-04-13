section     .data

limit:      dd      4.0

section     .text
global      julia

julia:
    ; taken from function:
    ;
    ; edi - pointer to pixel array
    ; esi - size of screen
    ; xmm0 - real part of complex number
    ; xmm1 - imaginary part of complex number
    ; xmm2 - translation
    ; xmm3 - x
    ; xmm4 - y
    ;
    ; defined later:
    ; xmm5 - holds first x
    ;
    ; xmm14 - current x
    ; xmm15 - current y

    movss   xmm5, xmm3      ; will be needed later
    mov     r8d, 0xffffff   ; setting colour of the background

    mov     edx, esi        ; counter (pixelArray length)

first_loop:
    mov     ecx, esi        ; counter (pixelArray length)

second_loop:
    movss   xmm14, xmm3     ; current x
    movss   xmm15, xmm4     ; current y
    mov     r9d, 256        ; number of iterations

complex_number:
    movss   xmm7, xmm14
    mulss   xmm7, xmm7      ; xmm7 = r^2

    movss   xmm8, xmm15
    mulss   xmm8, xmm8      ; xmm8 = i^2

    mulss   xmm15, xmm14
    addss   xmm15, xmm15
    addss   xmm15, xmm1      ; i = 2ri + c_i

    movss   xmm14, xmm7
    subss   xmm14, xmm8
    addss   xmm14, xmm0      ; r = r^2 - i^2 + c_r

    movss   xmm10, xmm7
    addss   xmm10, xmm8     ; xmm10 = r^2 + i^2

    ucomiss xmm10, [limit]  ; if r^y + y^2 > 4 number if out of set
    jnb     blank

    dec     r9d
    jnz     complex_number

    mov     r10d, 0x79339c  ; set colour

blank:
    cmovnz  r10d, r8d       ; leave without colour

end_second_loop:
    mov     [rdi], r10d     ; load pixel

    add     rdi, 4          ; get next pixel in row
    addss   xmm3, xmm2
    loop    second_loop

end_loop:
    addss   xmm4, xmm2     ; get next column
    movss   xmm3, xmm5
    dec     edx
    jnz     first_loop

end:
    ret




