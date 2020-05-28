
.align 2

.text

# // Defining constants
# #define MAX 64
# #define PI 3.14159265358979323846



# /*
#  Type definition for Pizza
#  Has 3 fields: name, pizzaPerCost, and next
#  Call with Pizza
#  */
# typedef struct Pizza {
#     char* name;
#     float pizzaPerDollar;
#     Pizza* next;
# } Pizza;


# /*
#  Function to create a Pizza node
#  takes FILE* as input
#  uses fgets() to read each line
#  uses a for loop to count tokens
#  allocates new Pizza* on each call
 
#  returns a Pizza*
#  */
# Pizza* create(FILE* theFile){
#     char str[MAX] = "empty"; // Buffer, placeholder to check if file is empty
#     char done[] = "DONE\n"; // Done has a newline after it... wtf?

#     // Allocate a new Pizza*
#     Pizza* aPizza = (struct Pizza*)malloc(sizeof(Pizza));

#     // Token counter: 0 = name, 1 = diameter, 2 = cost
#     for (int i = 0; i < 3; i++){
        
#         // Read one line
#         fgets(str, MAX, theFile);
        
#         // Buffer is unchanged if file is empty
#         if (strcmp(str, "empty") == 0){
#             printf("PIZZA FILE IS EMPTY");
            
#             // If no pizza, panic and yeet out everything

#             free(aPizza);
#             return NULL;
#         }
        
#         // Return NULL if "DONE" is encountered
#         if (strcmp(str, done) == 0){
#             free(aPizza);
#             return NULL;
#         }
        
#         // Make a copy of buffer
#         char* copiedString = (char*)malloc(sizeof(char)*MAX);
#         strcpy(copiedString, str);
#         strtok(copiedString, "\n"); // Remove any newline character at the end

#         // Token 1 = name
#         if (i == 0){
#             aPizza->name = copiedString;
#         }
        
#         // Token 2 = diameter, temporarily storing in pizzaPerDollar
#         if (i == 1){
#             aPizza->pizzaPerDollar = atof(copiedString);
#             free(copiedString);
#         }
        
#         // Token 2 = cost, do the math
#         if (i == 2){
#             // If cost is 0, no pizza, there is no free lunch!
#             if (!atof(copiedString)){

#                 aPizza->pizzaPerDollar = 0;
#                 free(copiedString);
#             } else {
#                 float cost = atof(copiedString);
#                 float PPD = pow(aPizza->pizzaPerDollar/2, 2)*PI/cost;
#                 free(copiedString);
#                 aPizza->pizzaPerDollar = PPD;
#             }
#         }
#     }
    
#     aPizza->next = NULL; // Initialize the next field
#     return aPizza;
# }


# /*
#  Function for inserting nodes alphabetically
#  maybe a tree could work too?
 
#  Takes the pointer to the node being inserted and
#  the pointer to the head pointer of linked list
#  */
# void insert(Pizza* current, Pizza** head){


# Function: inserts new pizza to correct place in linked list
# gets current pizza from a0
# gets head pizza from a1
# returns new head pointer in v0

insert: 
    # Save return address
    addi    $sp, -4
    sw      $ra, 0($sp)

#     // Declare a prev placeholder and an iterator
#     Pizza* prev = NULL;
    li      $t0, 0      # prev is in t0, initialize to 0       
#     Pizza* iter = *head;
    move    $t1, $a1    # iter is in t1
    move    $t2, $a0    # current is in t2
    move    $t4, $a1    # head is in t4

_compare_PPD: 
#     while (iter != NULL && iter->pizzaPerDollar > current->pizzaPerDollar){
    beqz    $t1, _next          # end the loop if at end of list
    lwc1    $f12, 64($t1)       # hold iter.pizzaPerDollar in f12
    lwc1    $f13, 64($t2)       # hold current.pizzaPerDollar in f13

    jal     float_compare

    mfc1    $t3, $f0            # comparison result is in t3
    blez    $t3, _next          # if iter.PDD <= current.PDD, end loop

#     // Advance to the element with a lower pizzaPerDollar value
#         prev = iter;
    move    $t0, $t1 
#         iter = iter->next;
    lw      $t1, 68($t1)
#     }
    b       _compare_PPD
    
_next:
#     // If this is the first node
#     if (prev == NULL){
    bnez    $t0, _compare_name
#         current->next = iter; // Add the node to the beginning
    sw      $t1, 68($t2)
#         *head = current; // And update the head pointer's pointer
    move    $t4, $t2
    b       _head_return

#     } else {
_compare_name: 
#         // In case the two pizzaPerDollar are the same
#         while (iter != NULL && iter->pizzaPerDollar == current->pizzaPerDollar){
    beqz    $t1, _put_node
    bnez    $t3, _put_node

#             // If the next node is higher alphabetically
#             if (strcmp(current->name, iter->name) < 0){
    la      $a0, 0($t2)
    la      $a1, 0($t1)
    jal     str_compare
    bgtz    $v0, _continue
#                 // Insert this node right before the next
#                 prev->next = current;
    sw      $t2, 68($t0)
#                 current->next = iter;
    sw      $t1, 68($t2)
#                 return;
    b       _head_return
#             }
            
#             // Otherwise keep searching for a place to put it
_continue: 
#             prev = iter;
    move    $t0, $t1
#             iter = iter->next;
    lw      $t1, 68($t1)
    b       _compare_name
#         }
_put_node: 

#         // If pizzaPerDollar are not the same then insert the new node right here
#         prev->next = current;
    sw      $t2, 68($t0)

#         current->next = iter;
    sw      $t1, 68($t2)
#     }
      #     return;
_head_return: 

    # Restore return address
    lw      $ra, 0($sp)
    addi    $sp, 4

    move    $v0, $t4
    jr      $ra
# }




# Compares two strings (hopefully) if a0>a1, v0>0
str_compare: 
    # Push t0 and t1 on stack
    addi    $sp, -8
    sw      $t0, 0($sp)
    sw      $t1, -4($sp)

_str_compare_loop: 
    lb      $t0, 0($a0)     # char of a0 in t0
    lb      $t1, 0($a1)     # char of a1 in t1

    bne     $t0 $t1, _str_compare_ret        # if current char not equal return

    addi    $a0, 1          # if current char equal then look at next char
    addi    $a1, 1
    bnez    $t0, _str_compare_loop    # if end of a0, fall through to return

_str_compare_ret: 

    sub     $v0, $t0 $t1    # find difference between t0 and t1, will be 0 if equal

    # Pop t0 and t1 from stack
    lw      $t1, -4($sp)
    lw      $t0, 0($sp)
    addi    $sp, 8

    jr      $ra             # return the difference


# Compares 2 floats
float_compare: 
    sub.s   $f0, $f12 $f13
    jr      $ra



# String printing function: prints string in a0
str_print:
    li      $v0, 4
    syscall
    jr      $ra


# Function: gets user input and creates a pizza node
# with the next field set to null
# returns pizza pointer in v0
get_pizza: 
    # Save return address
    addi    $sp, $sp -4
    sw		$ra, 0($sp)

    # Allocating heap space for node
    # |--------------name: 64 bytes------------|---PPD: 4 bytes----|----next: 4bytes-----|
    li      $a0, 72
    li      $v0, 9
    syscall
    move    $t4, $v0        # pointer to allocated heap in t4

    # Getting name
    la		$a0, name
    jal     str_print       # request name

    li      $v0, 8          # read console input into heap
    la      $a0, 0($t4)
    li      $a1, 64
    syscall

    # Removing the new line character at end of input
    move    $t0, $t4     # make copy of heap pointer
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


    la		$a0, diam
    jal     str_print       # request diameter

    li      $v0, 6          # read console input into f0
    syscall 
    mov.s 	$f4, $f0		# copy diameter to f4


    la		$a0, cost
    jal     str_print       # request cost

    li      $v0, 6          # read console input into f0
    syscall 
    mfc1    $t5, $f0
    beqz    $t5, _zero_PPD  # check if cost is 0
    mov.s 	$f5, $f0		# copy cost to f5

    # Calculating pizza per dollar
    l.s     $f6, two        # f6 = 2
    div.s   $f4, $f4 $f6    # f4 = diameter/2
    mul.s   $f4, $f4 $f4    # f4 = (diam/2)^2
    l.s     $f6, PI         # f6 = PI
    mul.s   $f4, $f4 $f6    # f4 = area of pizza
    div.s   $f4, $f4 $f5    # f4 = pizza per dollar


    swc1    $f4, 64($t4)     # store pizza per dollar to node

_return_node: 
    # Setting next field to null
    sw		$zero, 68($t4)	


    # Restore return address
    lw      $ra, 0($sp)
    addi    $sp, 4

    # return pointer of node on successful retrieval 
    move    $v0, $t4
    jr      $ra

_zero_PPD: 
    
    sw      $zero, 64($t4)   # set PDD to 0
    b       _return_node

_no_pizza: 
    # Restore return address
    lw      $ra, 0($sp)
    addi    $sp, 4

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
    move    $s0, $v0        # copy head pointer into s0

    b       _get_pizza_loop # keep getting pizzas
    
_print_list: 
    beqz    $s0, _exit          # while head != 0

    # Printing results
    la      $a0, 0($s0)     # print name
    jal     str_print

    la      $a0, space
    jal     str_print

    li      $v0, 2          # print pizza per dollar
    lwc1    $f12, 64($s0)
    syscall

    la      $a0, nln
    jal     str_print

    lw      $s0, 68($s0)    # head = head.next
    b       _print_list       






_exit: 
    # Restore main return address
    lw      $ra, 0($sp)
    addi    $sp, 4
    li      $v0, 0
    jr		$ra	
    


    
#     // Allocate a pointer to the head pointer of linked list
#     Pizza** head = (Pizza**)malloc(sizeof(Pizza*));
#     *head = NULL;
    

#     while (1){
        
#         // Create a new node
#         Pizza* current = create(theFile);
        
#         // If the node returns null then either file is empty or finished
#         if (current == NULL){
#             fclose(theFile);
#             break;
#         }
        
#         // Insert the new node created to correct place in linked list
#         insert(current, head);
#     }
    
#     // Point an iterator to first node
#     Pizza* iter = *head;
#     Pizza* temp; // The third hand
    
#     // Print the list of pizza while releasing memory allocated
#     while (iter != NULL){
#         printf("%s %f\n", iter->name, iter->pizzaPerDollar);
#         free(iter->name);
#         temp = iter;
#         iter = iter->next;
#         free(temp);
#     }
    
#     // Release everything else
#     free(head);
#     return EXIT_SUCCESS;
# }

.data
name:   .asciiz "Pizza name: " 
diam:   .asciiz "Pizza diameter: "
cost:   .asciiz "Pizza cost: "
nln:    .asciiz "\n"
space:  .asciiz " " 
done:   .asciiz "DONE"

PI:     .float 3.14159265358979323846
two:    .float 2.0

buf:    .space 64
