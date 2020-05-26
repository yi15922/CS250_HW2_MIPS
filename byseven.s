.text
.align 2

#int main(int argc, char* argv[]){
.globl main

main:

    li      $t2, 7                  # t2 = 7

#    int input = atoi(argv[1]);     # input is in t3
    la      $a0, msg
    li      $v0, 4
    syscall
    
    li      $v0, 5
    syscall
    
    move    $t3, $v0

    
#    for (int i = 0;                # i is in t0
    li      $t0, 0

#    i < input; i++){               # if i = input, jump to end
_loop:

    beq     $t3 $t0, end
    
#        printf("%d\n", 7*(i+1));
    addi    $t1, $t0, 1             # i+1 is in t1
    mul     $t1, $t1, $t2           # t1 = t1*7
    
    move    $a0, $t1
    li      $v0, 1
    syscall
    
    la      $a0, nln
    li      $v0, 4
    syscall
    
    addi    $t0, $t0, 1             # increment i by 1
    b _loop                         # jump back to _loop
    
    
#    }


#    return EXIT_SUCCESS;
#}
end:
    li      $v0, 0
    jr      $ra

.end main


.data
    msg:    .asciiz "Input number: "
    nln:    .asciiz "\n"
