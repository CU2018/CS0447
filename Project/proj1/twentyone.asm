.data
	deck: .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11,
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 11   #52 cards
	dealer: .byte 0:16    #mathmatically no more than 9 cards, just in case
	player: .byte 0:16    #mathmatically no more than 9 cards, just in case
	numc_d: .byte 0    #number of cards in dealer's hand
	numc_p: .byte 0    #number of cards in player's hand
	sumc_d: .byte 0		#sum of dealer's card points
	sumc_p: .byte 0		#sum of player's card points
	
	dealer_hand: .asciiz "Dealer's hand: "
	player_hand: .asciiz "Player's hand: "
	hit_stand: .asciiz "What would you like to do? (0 = stand, 1 = hit): "
	
	won: .asciiz "You won!!"
	lost: .asciiz "You lost...QAQ"
	tied: .asciiz "You tied."
	 
.text

.globl main
main:
	jal shuffle_deck
	jal deal_card_to_player
	jal deal_card_to_dealer
	jal deal_card_to_player
	jal deal_card_to_dealer

	_main_loop:
		jal show_hands
		jal check_scores
		jal take_turns		
		j _main_loop
	
	_main_exit:
		li v0, 10
		syscall


shuffle_deck:
	push ra
	push s0 #used as i
	
	#for(int i = 51; i >= 1; i--)
	#{
	#	other_slot = random (0, i+1);
	#	swap(deck[i], deck[other_slot]);
	#}
	
	li s0, 51	#i = 51
	_shuffle: 
		blt s0, 1, _shuffle_exit   #i < 1, exit
		#generate random
		li a0, 0 #a0: random(0, ??)
		add a1, s0, 1 #a1: i+1; upper bound a1 is exclusive 
		li v0, 42 #random call
		syscall #a0: pseudo random
		#swap slots
		la t0, deck    #t0: base address of deck
		add t1, t0, s0    #t1: address of i slot
		add t2, t0, a0    #t2: address of other_slot
		lbu a0, (t1)	#a0: value in t1/deck[i]
		lbu a1, (t2)	#a1: value in t2/deck[other_slot]
		sb a1, (t1)	#put value in t2/deck[other_slot] into deck[i]
		sb a0, (t2) 	#put value in t1/deck[i]into deck[other_slot]
		#i--
		sub s0, s0, 1
		j _shuffle 
	_shuffle_exit:
		pop s0
		pop ra
		jr ra
		
deal_card_to_player:
	push ra
	
	lbu a0, numc_p	#a0: the number of cards in player's hand
	lbu a1, numc_d 	#a1: the number of cards in dealer's hand
	lbu a2, sumc_p	#a2: the sum of player's card points
	add a1, a0, a1 	#a1: the #th card from the deck
	la t0, player 	#t0: base address of player
	add t0, t0, a0 	#t0: address of #th slot in player
	la t1, deck 	#t1: base address of deck
	add t1, t1, a1 	#t1: address of #th slot in deck
	lbu t2, (t1) 	#t2: value in #th slot in deck
	sb t2, (t0) 	#put value in t2/deck[numc_d+numc_p] into t0/player[numc_p]
	add a2, a2, t2  # sum += player[i]
	add a0, a0, 1   #numc_p++
	sb numc_p, a0	#store numc_p
	sb sumc_p, a2	#store cumc_p
	
	pop ra
	jr ra
	
deal_card_to_dealer:
	push ra
	
	lbu a0, numc_d	#a0: the number of cards in dealer's hand
	lbu a1, numc_p 	#a1: the number of cards in player's hand
	lbu a2, sumc_d	#a2: the sum of dealer's card points
	add a1, a0, a1 	#a1: the #th card from the deck
	la t0, dealer 	#t0: base address of dealer
	add t0, t0, a0 	#t0: address of #th slot in dealer
	la t1, deck 	#t1: base address of deck
	add t1, t1, a1 	#t1: address of #th slot in deck
	lbu t2, (t1) 	#t2: value in #th slot in deck
	sb t2, (t0) 	#put value in t2/deck[numc_d+numc_p] into t0/dealer[numc_d]
	add a2, a2, t2  # sum += dealer[i]
	add a0, a0, 1   #numc_d++
	sb numc_d, a0	#store numc_d
	sb sumc_d, a2	#store cumc_d
	
	pop ra
	jr ra

show_hands:
	push ra
	
	la a0, dealer_hand 	#print dealer's hand
	li v0, 4
	syscall
	la a0, dealer 	 	#print_array(dealer, numc_d)
	lbu a1, numc_d		#a0: address of dealer, a1: the number of cards in dealer's hand
	jal print_array
	lbu a0, sumc_d		#a0: the sum of dealer's card points
	li v0, 1 		#print dealer's card points
	syscall
	
	li a0, '\n'
	li v0, 11
	syscall
	
	la a0, player_hand 	#print player's hand
	li v0, 4
	syscall
	la a0, player		#print_array(player, numc_p)
	lbu a1, numc_p		#a0: address of player, a1: the number of cards in player's hand
	jal print_array
	lbu a0, sumc_p		#a0: the sum of player's card points
	li v0, 1		#print player's card points
	syscall
	
	li a0, '\n'
	li v0, 11
	syscall
	
	pop ra
	jr ra
	
print_array:
	push ra
	push s0
	
	#for (int i = 0; i < count; i++)
	#{
	#	print(arr[i] + " ");
	#}
	#print("= " + sum);
	
	li s0, 0  	#i = 0
	
	_loop_array:
		bge s0, a1, _loop_exit 	#i >= count, exit
		#print and sum
		add t0, a0, s0 		#t0: get to the i-th slot of array
		move t1, a0 		#t1: store the address of the array
		lbu a0, (t0)		#a0: value in arr[i]
		li v0, 1		#print arr[i]
		syscall
		li a0, ' '		#print space " "	
		li v0, 11
		syscall
		
		move a0, t1		#a0: the address of the array
		add s0, s0, 1		#i++
		j _loop_array
	_loop_exit:
		li a0, '='		#print("= ");
		li v0, 11
		syscall
		li a0, ' '		
		li v0, 11
		syscall
		
		pop s0
		pop ra
		jr ra
		
check_scores:	
	push ra
	
	lbu t0, sumc_d 		#t0: the sum of dealer's card points
	lbu t1, sumc_p		#t1: the sum of player's card points
	#if(sumc_p == 21)
	#{
	#    if(sumc_d == 21)
	#	print("Tie");
	#	exit;
	#    else
	#       print("won");
	#       exit;
	#}
	#else if (sumc_p > 21)
	#{
	#    print("lose");
	#    exit;
	#}
	#else if (sumc_d > 21)
	#{
	#    print("won");
	#    exit;
	#}
	#else
	#    return;
	beq t0, 21, _check_dealer21	#sumc_d == 21 --> lost/tied
	beq t1, 21, _check_player21 	#sumc_p == 21 --> won/tied
	bgt t1, 21, _check_lost		#sumc_p > 21 -->lost
	bgt t0, 21, _check_won 		#sumc_d > 21 -->won
	_check_exit: 			#else --> continue
		pop ra
		jr ra
	_check_dealer21:		#sumc_d == 21 --> lost/tied
		bne t1, 21, _check_lost #sumc_p != 21 --> lost
		j _check_tied		#sumc_p == 21 --> tied
	_check_player21:		#sumc_p == 21 --> won/tied
		bne t0, 21, _check_won	#sumc_d != 21 --> won
	_check_tied: #sumc_d == 21 --> tied
		la a0, tied
		li v0, 4
		syscall
		j _main_exit	#end the game
	_check_won:
		la a0, won
		li v0, 4
		syscall
		j _main_exit	#end the game
	_check_lost:	
		la a0, lost
		li v0, 4
		syscall
		j _main_exit	#end the game
		
take_turns:
	push ra
	
	la a0, hit_stand  	#print hit or stand
	li v0, 4
	syscall
	
	li v0, 5		#get the choice from the user
	syscall 		#v0: 0 --> hit, 1 --> stand
	
	#if (user == 1) -->hit
	#    deal_to_player();
	#else 
	#{
	#    if(sumc_d >= 17) --> stand{
	#    	if (sumc_d == sumc_p) print("tied");
	#    	else if (sumc_d > sumc_p) print("lost");
	#    	else print("won"); -->sumc_p > sumc_d
	#	}
	#}
	#if (sumc_d < 17)
	#	deal_to_dealer();
	
	beq v0, 1, _turns_hit 		#if (user == 1) -->hit
	lbu t0, sumc_d
	bge t0, 17, _turns_stand
	j _less_than_17
	_turns_hit:
		jal deal_card_to_player
		lbu t0, sumc_d
		blt t0, 17, _less_than_17
		j _turns_exit
	_turns_stand:
		lbu t0, sumc_d 		#t0: the sum of dealer's card points
		lbu t1, sumc_p		#t1: the sum of player's card points
		
		beq t0, t1, _check_tied #(sumc_d == sumc_p) print("tied")
		bgt t0, t1, _check_lost #(sumc_d > sumc_p) print("lost")
		jal _check_won		#else print("won"); -->sumc_p > sumc_d
	_less_than_17:
		jal deal_card_to_dealer
	_turns_exit:
		pop ra
		jr ra
