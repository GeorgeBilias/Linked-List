#	Computer Systems Organization
#	Winter Semester 2021-2022
#	3rd Assignment
#
#	MIPS Code by Georgios Bilias, p3200278@aueb.gr, 3200278 and Panagiotis Bourazanas, p3200268@aueb.gr, 3200268

.text

.globl main

		#---------------------------#
		#	      MAIN 	    #
		#---------------------------#

main:  

 li $s0,0 # setting the head as null

#=================================================================================#

		#---------------------------#
		#	     MENU 	    #
		#---------------------------#
	
#=================================================================================#
# this subprogram is the one that prints the menu of the program		  #
#=================================================================================#

menu:

 li $v0,4
 la $a0, msg 
 syscall 	# print the msg

 li $v0,4
 la $a0, menu_options 
 syscall		# prints the menu options

#=================================================================================#
 
		#---------------------------#
		#	    CHOICE	    #
		#---------------------------#
		
#=================================================================================#
# The choice includes the code to input a choice from the menu and based on that  #
# the jump to the appropriate subprogram                                          #
#=================================================================================#
		
choice: 
 
 li $v0,5
 syscall
 move $t0,$v0	# the user inputs a choice from the menu
 
 beq $t0,1,c
 beq $t0,2,d
 beq $t0,3,p
 beq $t0,4,exit  #  if statements to travel to based on he user's input
 
 li $v0,4
 la $a0, msg 
 syscall # print the msg
 
 li $v0,4
 la $a0, no_option 
 syscall # if he inputs another number print this message
 
 j menu # and jump back to the menu
 
 c:
   jal create
   
   la $a0,msg
   li $v0,4
   syscall # print the message
  
   la $a0,number_added
   li $v0,4
   syscall # print the message
   
   j menu

 d:
   jal delete
   j menu
 
 p:
   jal print
   j menu

#=================================================================================#

		#---------------------------#
		#	 CREATE A LIST      #
		#---------------------------#
		
#=================================================================================#
# The program asks for an input and if there is no list, therefore no head, it    #
# creates a head node and inserts the number the user inpunts  into it            #
# else it goes to insert where it creates a node and inserts a number to the node #
# for the rest of them                                                            #
#=================================================================================#
 
create:

 li $v0,4
 la $a0, msg 
 syscall # print the msg
 
 la $a0,insert_message
 li $v0,4
 syscall	# prints message to insert a number in the node
 
 li $v0,5
 syscall
 move $t4,$v0
 
 bne $s0,$0,insert # if there is already a list made go to insert
 
 li $a0,8
 li $v0,9
 syscall
 move $s0,$v0   # creates a list and sets the s0 as head

 sw $t4,0($s0)		# stores the number inserted in the 1st field 
 
 sw $0,4($s0) # set 2nd field as null, its the link of the node
 
 jr $ra

#=================================================================================#

		#----------------------------------------------------------#
		#	    INSERT A NODE TO AN ALREADY MADE LIST	   #
		#----------------------------------------------------------#
	
#=================================================================================#
# this subprogram as previously mentioned is the one where the nodes are being    #
# inserted if there is an already existing list					  #
#=================================================================================#

insert:

 move $t0,$s0 # sets t0 as the spot of the head of the list (list.head)
 
 move $t1,$t4	# stores the number from the input for later
 
 li $t2,0    # to be used as previous, initialized to null

 #=================================================================================#

       		 #----------------------------------------------------------#
		 #	    LOOP TO INSERT A NODE TO THE RIGHT PLACE	    #
		 #----------------------------------------------------------#
	
#=================================================================================#
# this is a loop where we find the appropriate place for the number of the node   #
# to be inserted inside the list						  #
#=================================================================================#
 
	loop:

	 beq $t0,$0, exit_loop # if the node is null exit the loop
	 lw $t3, 0($t0) # t3 = integer of the node
	 slt $t3,$t1,$t3 # checks if the integer of t1 is less than the one of t3 and stores it in t3
	 bne $t3,$0,exit_loop # if t1 is actually less than t3 then the loop ends

	 #else

	 move $t2,$t0 # sets the node as previous
	 lw $t0,4($t0) # goes to the next
	 j loop # does the loop again
	 
#=================================================================================#
# this subprogram creates the node if its not head else it goes to the prevnull	  #
#=================================================================================#
	 
	exit_loop:

	 li $a0,8
         li $v0,9
         syscall # creates a new node

	 sw $t1,0($v0) # gets the integer of the new node from t1
	 sw $t0,4($v0) # gets the adress of the node and adds it as the next of the new node

	 beq $t2,$0, prevnull # if the previous ($t3) is null then go to  prevnull

	 #else

	 sw $v0,4($t2)
	
	 jr $ra

#=================================================================================#
# this subprogram is the one where we insert the node as head of an already	  #
# existing list									  #
#=================================================================================#

	 prevnull:

	  # basically we set the new node as the head

	  bne $t3,$0, insertashead # if the new node is the head, go to insertashead
	  
	  jr $ra #else 

	  insertashead:
	   
	   move $s0,$v0 # setting the new node as head
	   
	   jr $ra

#=================================================================================#

		#----------------------------------------------------------#
		#	       DELETE A NODE FROM THE LIST	           #
		#----------------------------------------------------------#
		
#=================================================================================#
# this subprogram is the one where we check if the list is empty(doesn't exist)	  #
# or if its not. If its not we insert the number that we want to delete from the  #
# list and we go to the loop to find it						  #
#=================================================================================#

delete:
 
 beq $s0,$0,listisempty # if the head is null then there is nothing to delete

 #else

 move $t0,$s0
 
 li $v0,4
 la $a0, msg 
 syscall # print the msg

 la $a0,enter
 li $v0,4
 syscall # print the message
 
 li $v0, 5				
 syscall				# read the int you want to delete	
 move $t1, $v0				# move it to t1
 
 li $t2,0     # setting a t2 as null, its going to be used as previous
 
#=================================================================================#
# this subprogram is the one that we try to find the number we inserted inside to #
# the list, if there is no node with that number it goes to nonumber else it goes #
# to nodefound									  #
#=================================================================================#

 deleteloop:
  
  beq $t0,$0, nonumber # if the current node is null then that means that no node has that number
  lw $t3,0($t0) # setting as t3 the integer from inside the node
  beq $t1,$t3,nodefound # if you find a node with that number go to nodefound
  # else
  move $t2,$t0 # set as previous the t0
  lw $t0,4($t0) # set t0 as the next node from the previous t0
  j deleteloop # go back to delete loop
  
#=================================================================================#
# this subprogram is the one that checks if the node we found is head or not      #
# and if it is, it goes to delete head. Else, it removes it deletes it there      #
#=================================================================================#
  
  nodefound:
  
  beq $t2,$0,deletehead # if the previous is null then we go to delete the head
  
  # else
  
  lw $t3, 4($t0) # setting the current as the next
  sw $t3, 4($t2) # setting as previous the current we just got
  
  la $a0,msg
  li $v0,4
  syscall # print the message
  
  la $a0,number_deleted
  li $v0,4
  syscall # print the message
  
  jr $ra

#=================================================================================#
# this subprogram is the one that deletes the head and sets as head the next node #
#=================================================================================#

 deletehead:
 
 lw $t2,4($t0) # set the next one as t2
 move $s0,$t2  # set t2 as the new head
 
  la $a0,msg
  li $v0,4
  syscall # print the message
 
  la $a0,number_deleted
  li $v0,4
  syscall # print the message
  
 jr $ra
 
#=================================================================================#
# this subprogram is the one that prints the appropriate message if the list is   #
# empty and therefore nothing to delete                                           #
#=================================================================================#
 
 listisempty:
 
 li $v0,4
 la $a0, msg 
 syscall # print the msg

 la $a0,nothingtodelete
 li $v0,4
 syscall # print the message
 
 jr $ra
 
#=================================================================================#
# this subprogram is the one that prints the appropriate message if the list      #
#  doesn't have the number we want to delete                                      #
#=================================================================================#
 
 nonumber:
 
  li $v0,4
  la $a0, msg 
  syscall # print the msg
 
  la $a0,nonode
  li $v0,4
  syscall # print the message
 
   jr $ra
 
 
#=================================================================================#

		#----------------------------------------------------------#
		#	       PRINT ALL NODES FROM THE LIST	           #
		#----------------------------------------------------------#

#=================================================================================#
# this subprogram is the one that firstly checks if there is no list(no head).    #
# if that's the case it goes to listisnull, else it goes to printLoop             #
#=================================================================================#

print:

 li $v0,4
 la $a0, msg 
 syscall  # print the msg
 
 beq $s0,$0,listisnull

 move $t0,$s0 # move the head to t0
 
 la $a0,head
 li $v0,4
 syscall # print the message
 
#=================================================================================#
# this subprogram is the loop where all the numbers of the nodes are being printed#
# When theyre all printed it goes to exit loop					  #
#=================================================================================#

 printLoop:

 beq $t0,$0, exit_printloop

 lw $a0,0($t0) # load the integer 
 li $v0,1 #print the integer
 syscall # do it
 
 la $a0,space
 li $v0,4 
 syscall 
 
 lw $t0,4($t0) # go to the next
 beq $t0,$0,printLoop # if the next node is null go back to printLoop
 
 # else
 
 la $a0,arrow
 li $v0,4 
 syscall # print an arrow
 
 j printLoop
#=================================================================================#
# this subprogram is just one print message after the whole list is printed       #
#=================================================================================#
 
 exit_printloop:
 
 la $a0,tail
 li $v0,4
 syscall # print the message
 
 jr $ra

#=================================================================================#
# this subprogram is just one print message when there is no list to print        #
#=================================================================================#

 listisnull:

  la $a0, printnulllist
  li $v0,4
  syscall # print the message
  jr $ra

#=================================================================================#

		#----------------------------------------------------------#
		#	              EXIT THE PROGRAM	                   #
		#----------------------------------------------------------#

#=================================================================================#
# this subprogram is just the exit of the program aka the 4th choice of the menu  #
#=================================================================================#
 
exit:
 
 li $v0,10
 syscall	# exit the program

#=================================================================================#

.data

msg: .asciiz "------------------"
menu_options: .asciiz "\n1. Insert a Node\n2. Delete a Node\n3. Print the List\n4. Exit\n Choose: "
no_option: .asciiz "\nThis is not an option\n"
insert_message: .asciiz "\nInsert a number to the Node: "
printnulllist: .asciiz "\nThere is no list to print\n"
head: .asciiz " \nHEAD -> "
space: .asciiz " "
arrow: .asciiz "-> "
tail: .asciiz "<- TAIL\n"
nothingtodelete: .asciiz "\nThere is nothing to delete since the list is Empty\n"
nonode: .asciiz "\nThis number doesn't exist in the list\n"
number_deleted: .asciiz "\nThe number got deleted successfully\n"
number_added: .asciiz "\nThe number got added successfully\n"
enter: .asciiz "\nEnter the number you want to delete from the list: "
