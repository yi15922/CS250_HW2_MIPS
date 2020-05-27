.text
.align 2


#int recurse(int input){        # input is in a0
recurse:

#    if (input == 0){           # jump to _end
    beq     $a0 0, _end

#    }

#    int result = 3*(input-1)+recurse(input-1)+1;       # result is in t0
    addi    $t0, $a0 -1
    mul     $t0, $t0 3          # 3*(input-1) is in t0
    
    addi    $a0, $a0 -1         # input-1 is in a0
    
                                # need to save: ra, t0
                                
    addi    $sp, -8             # create stack frame for 2 words
    sw      $ra, 0($sp)         # push ra to 0 byte on stack
    sw      $t0, -4($sp)        # push t0 to -4 byte on stack
    
    jal     recurse             # a0 passed to recurse, return address in a0
    
    lw      $t0, -4($sp)        # pop t0 from stack
    lw      $ra, 0($sp)         # pop ra from stack
    addi    $sp, 8              # collapse stack frame

    add     $t0, $t0 $v0        # t0 = 3*(input-1)+recurse(input-1)
    addi    $t0, $t0 1          # t0 is complete
    
    move    $v0, $t0            # return result
    jr      $ra                 # return to caller
    
#    return result;

_end:
#        return 2;
    li      $v0, 2
    jr      $ra

main:

#   int input = atoi(argv[1]);      # input is in a0
    la      $a0, msg
    li      $v0, 4
    syscall
    
    li      $v0, 5
    syscall
    
    move    $a0, $v0

#   int result = recurse(input);    # result is in v0

    addiu   $sp, -4                 # create 1 byte stack frame
    sw      $ra, 0($sp)             # push ra on stack
    
    jal     recurse                 # call recurse
    
    lw      $ra, 0($sp)             # pop ra from stack
    addiu   $sp, 4                  # collapse stack frame
    

#    printf("%d\n", result);
    move    $a0, $v0                # copy result to a0
    li      $v0, 1                  # print result
    syscall
    
    la      $a0, nln
    li      $v0, 4                  # print new line
    syscall
    
    b _exit                         # branch to exit


_exit:

#    return EXIT_SUCCESS;
    li      $v0, 0                  # return 0
    jr      $ra
#}


.data
nln:    .asciiz "\n"
msg:    .asciiz "Input number: "

