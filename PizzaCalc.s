
.align 2
.text


# Function: inserts new pizza to correct place in linked list
# gets current pizza from a0
# gets head pizza from a1
# returns new head pointer in v0

insert: 
    # Save return address, s1, s2, s3, s4
    addi    $sp, -20
    sw      $ra, 0($sp)
    sw      $s1, -4($sp)
    sw      $s2, -8($sp)
    sw      $s3, -12($sp)
    sw      $s4, -16($sp)

#     // Declare a prev placeholder and an iterator
#     Pizza* prev = NULL;
    li      $s3, 0      # prev is in s3, initialize to 0       
#     Pizza* iter = *head;
    move    $s1, $a1    # iter is in s1
    move    $s2, $a0    # current is in s2
    move    $s4, $a1    # head is in s4

# Find the place to insert 
_find_insert: 
#     while (iter != NULL && iter->pizzaPerDollar > current->pizzaPerDollar){
    beqz    $s1, _next          # end the loop if at end of list
    
    move    $a0, $s2            # hold current in a0
    move    $a1, $s1            # hold iter in a1

    jal     node_compare
    blez    $v0, _next          # if iter <= current, end loop

    # Otherwise keep searching
#         prev = iter;
    move    $s3, $s1 
#         iter = iter->next;
    lw      $s1, 68($s1)
#     }
    b       _find_insert
    
_next:
#   If this is the first node
#     if (prev == NULL){
    bnez    $s3, _put_node
#         current->next = iter; // Add the node to the beginning
    sw      $s1, 68($s2)
#         *head = current; // And update the head pointer's pointer
    move    $s4, $s2
    b       _head_return

#     }
            
# Insert the new node right here
_put_node: 
#         prev->next = current;
    sw      $s2, 68($s3)

#         current->next = iter;
    sw      $s1, 68($s2)
#     }
      #     return;
_head_return: 
    # Load head in v0 for return
    move    $v0, $s4

    # Restore return address, s1, s2, s3, s4
    lw      $s4, -16($sp)
    lw      $s3, -12($sp)
    lw      $s2, -8($sp)
    lw      $s1, -4($sp)
    lw      $ra, 0($sp)
    addi    $sp, 20

    jr      $ra
# }

# Compares two strings (hopefully) if a0>a1, v0>0
# takes inputs from a0 and a1
# returns to v0
str_compare: 
    lb      $t0, 0($a0)     # char of a0 in t0
    lb      $t1, 0($a1)     # char of a1 in t1

    bne     $t0 $t1, _str_compare_ret        # if current char not equal return

    addi    $a0, 1          # if current char equal then look at next char
    addi    $a1, 1
    bnez    $t0, str_compare    # if end of a0, fall through to return

_str_compare_ret: 
    sub     $v0, $t0 $t1    # find difference between t0 and t1, will be 0 if equal
    jr      $ra             # return the difference

# Comparator for nodes
# Takes current in a0 and iter in a1
# Returns positive, negative or 0 in v0
node_compare: 
    # Save return address
    addi    $sp, -4
    sw      $ra, 0($sp)

    # First compare PPD
    lwc1    $f12, 64($a1)       # hold iter.pizzaPerDollar in f12
    lwc1    $f13, 64($a0)       # hold current.pizzaPerDollar in f13
    sub.s   $f0, $f12 $f13      # compare floats
    mfc1    $v0, $f0            # comparison result is in v0
    bnez    $v0, _node_compare_done  # if mismatch, comparison done

    # If PPD is equal, compare names
    la      $a0, 0($a0)
    la      $a1, 0($a1)
    jal     str_compare

_node_compare_done: 
    # Restore return address
    lw      $ra, 0($sp)
    addi    $sp, 4
    # v0 already contains comparison result
    jr      $ra

# String printing function: prints string in a0
str_print:
    la      $a0, prompt
    _print:
    li      $v0, 4
    syscall
    jr      $ra


# Function: gets user input and creates a pizza node
# with the next field set to null
# returns pizza pointer in v0
get_pizza: 
    # Save return address, s5
    addi    $sp, $sp -8
    sw		$ra, 0($sp)
    sw      $s5, -4($sp)

    # Allocating heap space for node
    # |--------------name: 64------------|---PPD: 4----|----next: 4-----|
    li      $a0, 72
    li      $v0, 9
    syscall
    move    $s5, $v0        # pointer to allocated heap in s5

    # Getting name
    jal     str_print       # request name

    li      $v0, 8          # read console input into heap
    la      $a0, 0($s5)
    li      $a1, 64
    syscall

    # Removing the new line character at end of input
    move    $t0, $s5     # make copy of heap pointer
_remove_nln: 
    lb      $t1, 0($t0)     # load a char of name
    addi    $t0, 1          # increment by 1 char
    bnez    $t1, _remove_nln  # keep searching for eos

    addi    $t0, -2         # on finding eos, back up 2 chars to nln
    sb      $zero, 0($t0)   # overwrite nln with eos

    # Check for DONE
    la      $a1, done       # place DONE into a1 to compare
    jal     str_compare
    beqz    $v0, _no_pizza  # if done, return 0


    jal     str_print       # request diameter

    li      $v0, 6          # read console input into f0
    syscall 
    mov.s 	$f4, $f0		# copy diameter to f4


    jal     str_print       # request cost

    li      $v0, 6          # read console input into f0
    syscall 

    mfc1    $t5, $f0
    beqz    $t5, _return_node  # check if cost is 0

    # Calculating pizza per dollar
    mul.s   $f4, $f4 $f4    # f4 = diam^2
    l.s     $f6, PIdiv4     # f6 = PI/4
    mul.s   $f4, $f4 $f6    # f4 = area of pizza
    div.s   $f4, $f4 $f0    # f4 = pizza per dollar

    swc1    $f4, 64($s5)     # store pizza per dollar to node


_return_node: 

    # return pointer of node on successful retrieval 
    move    $v0, $s5

_no_pizza: 
    # Restore return address, s5
    lw      $ra, 0($sp)
    lw      $s5, -4($sp)
    addi    $sp, 8

    # return 0 (v0 is already 0)
    jr      $ra

# Main
main: 
    # Save main's return address
    addi    $sp, $sp -4
    sw		$ra, 0($sp)		

    # Head pointer is s0
    li      $s0, 0          # initialize head pointer to 0

    # Get the next pizza
_get_pizza_loop: 
    jal     get_pizza       # pizza node returned to v0
    beqz    $v0, _print_list  # if no more pizza, start printing

    move    $a0, $v0        # pass current pizza in a0
    move    $a1, $s0        # pass head of list in a1
    jal     insert          # call insert and receive head pointer to new list
    move    $s0, $v0        # copy new head pointer into s0

    b       _get_pizza_loop # keep getting pizzas
    
_print_list: 
    beqz    $s0, _exit          # while head != 0

    # Printing results
    la      $a0, 0($s0)     # print name
    jal     _print

    la      $a0, space
    jal     _print

    li      $v0, 2          # print pizza per dollar
    lwc1    $f12, 64($s0)
    syscall

    la      $a0, nln
    jal     _print

    lw      $s0, 68($s0)    # head = head.next
    b       _print_list       

_exit: 
    # Restore main return address
    lw      $ra, 0($sp)
    addi    $sp, 4
    li      $v0, 0
    jr		$ra	

.data
prompt: .asciiz "Input: "
nln:    .asciiz "\n"
space:  .asciiz " " 
done:   .asciiz "DONE"

PIdiv4: .float 0.7853981634
