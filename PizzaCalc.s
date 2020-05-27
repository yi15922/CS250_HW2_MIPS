
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
    
#     // Declare a prev placeholder and an iterator
#     Pizza* prev = NULL;
#     Pizza* iter = *head;
    
#     // Advance to the element with a lower pizzaPerDOllar value
#     while (iter != NULL && iter->pizzaPerDollar > current->pizzaPerDollar){
#         prev = iter;
#         iter = iter->next;
#     }
    
#     // If this is the first node
#     if (prev == NULL){
        
#         current->next = iter; // Add the node to the beginning
#         *head = current; // And update the head pointer's pointer

#     } else {
        
#         // In case the two pizzaPerDollar are the same
#         while (iter != NULL && iter->pizzaPerDollar == current->pizzaPerDollar){
            
#             // If the next node is higher alphabetically
#             if (strcmp(current->name, iter->name) < 0){
                
#                 // Insert this node right before the next
#                 prev->next = current;
#                 current->next = iter;
#                 return;
#             }
            
#             // Otherwise keep searching for a place to put it
#             prev = iter;
#             iter = iter->next;
#         }
        
#         // If pizzaPerDollar are not the same then insert the new node right here
#         prev->next = current;
#         current->next = iter;
#     }
        
#     return;
# }

# int main(int argc, char* argv[]){
main: 
    
    li      $v0, 4          # print name prompt
    la		$a0, name
    syscall

    li      $v0, 8          # read console input into buf
    la      $a0, buf
    li      $a1, 64
    syscall

    li      $v0, 4          # print diameter prompt
    la		$a0, diam
    syscall

    li      $v0, 6          # read console input into f0
    syscall 
    mov.s 	$f4, $f0		# copy diameter to f4

    li      $v0, 4          # print cost prompt
    la		$a0, cost
    syscall

    li      $v0, 6          # read console input into f0
    syscall 
    mov.s 	$f5, $f0		# copy cost to f5

    

    la      $a0, buf        # print name
    li      $v0, 4
    syscall

    l.s     $f6, two        # f6 = 2
    div.s   $f4, $f4 $f6    # f4 = diameter/2
    mul.s   $f4, $f4 $f4    # f4 = (diam/2)^2
    l.s     $f6, PI         # f6 = PI
    mul.s   $f4, $f4 $f6    # f4 = area of pizza
    div.s   $f4, $f4 $f5    # f4 = pizza per dollar

    li      $v0, 2          # print pizza per dollar
    mov.s   $f12, $f4
    syscall

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
