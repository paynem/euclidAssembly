TITLE GCD_and_LCM     (Michael_Payne_project.asm)

; Author: Michael Payne
; Last Modified:08/14/2019
; OSU email address: paynemi
; Course number/section: cs271
; Project Number:     Finalproject            Due Date: 08/16/2019
; Description:	This program takes 20 benchmark arrays of integers and and generates a GCD and LCM for each one.  For each benchmark array, the
; program will print the benchmark name (eg benchmark10), all of the elements in the array (1, 2, 3, etc.) and then the GCD and LCM of all of those
; integers.  It formats and presents everything in such a way that it is more readable and nice to look at.
; Here are corner cases that the program looks for:
; 1: less than 2 integers in an array
; 2: more than 4 integers in an array
; 3: arrays with datatype bigger than dword
; 4: arrays that generate LCMs larger than 32 bits
; 5: Don't know if this counts as a corner case, but the program is very careful about handling 0s, and has numerous checks
; to make sure they don't blow up the program when GCD and LCM are being calculated
; This program doesn't look for and zap arrays with uninitialized values, because I remember you saying we didn't need to worry about that.
; This program also calculates and prints out its execution time.  I decided to do the extra credit option of printing out a 64-bit version
; of the what ends up being stuck in edx:eax.
; I tried to get it in by 5pm on 8/16, but ironing out the 64-bit implementation and documenting everything as thoroughly as I wanted
; (explaining how the 64-bit printing procedure took absolutey forever to type out for some reason).  Oh well


INCLUDE Irvine32.inc

; arrayInfo is a macro that takes an array, and number as paramters.  It pushes the array address, array type, length of the array, and the 
; passed in number into the stack and then calls the procedure processArray, which calculates the GCD and LCM of the numbers in the array.
; num is used as an index when processArray is storing the GCD and LCMS into Result_Benchmark_GCD and Result_Benchmark_LCM
arrayInfo	MACRO	benchmark, num
	push	OFFSET benchmark				; pushing address of benchmark array onto system stack
	push	TYPE benchmark					; pushing benchmark datatype onto system stack
	push	LENGTHOF benchmark				; pushing number of elements in benchmark onto system stack
	push	num								; pushing num, which is index for gcd and lcm storage arrays onto system stack
	call	processArray					; calling procedure to calculate gcd and lcm of numbers in benchmark array
ENDM
; printInfo is a macro that functions almost identically to arrayInfo.  Except instead of calling processArray to calculate GCD and LCM, it calls
; printLine, which prints all of the numbers in each benchmark and the corresponding GCD and LCM for each benchmark (in an organized and readable
; fashion
printInfo	MACRO	benchmark,num
	push	OFFSET benchmark				; pushing address of benchmark array onto system stack
	push	TYPE benchmark					; pushing benchmark datatype onto system stack
	push	LENGTHOF benchmark				; pushing number of elements in benchmark onto system stack
	push	num								; pushing num, which is index for gcd and lcm storage arrays onto system stack
	call	printLine						; callin printline to print everything in a presentable fashion
ENDM

; Do not change the name of Benchmarks. Data Types and Values may change when your code is tested.
.data
intro			byte	"CS 271 Final Project by Michael Payne",0
display1		byte	"Benchmark ", 0
gcdText			byte	"GCD is ", 0
lcmText			byte	" and LCM is ",0
exeTime			byte	"Total execution time is: ",0
nano			byte	" ns.",0
; *insert benchmarks in between here*
Benchmark1				WORD	16, 32, 64, 128
Benchmark2				WORD	6, 28038, 27444
Benchmark3				WORD	-32766, 32766
Benchmark4				BYTE	-128, 127
Benchmark5				TBYTE	-988422, 286331153
Benchmark6				DWORD	-65537, 6700417
Benchmark7				DWORD	104831, 104827, 0, 0
Benchmark8				BYTE	56, -77, 42
Benchmark9				BYTE	54, 24
Benchmark10				BYTE	3
Benchmark11				WORD	7536, 28260
Benchmark12				DWORD	4673, 65537, 274177
Benchmark13				WORD	132, 104, 56, 118
Benchmark14				WORD	6, 32766
Benchmark15				WORD	0, 0, 0, 0, 0, 0, 0, 0
Benchmark16				WORD	8224, 18504, 16448, 30840
Benchmark17				DWORD	83898162, 1039405007, 1542793979, -20416337
Benchmark18				DWORD	4001, 5573, 4649, 6047
Benchmark19				WORD	11538, 32691, 3205
Benchmark20				DWORD	13400834, -34614, -201274
Result_Benchmark_GCD	DWORD	20 DUP(?)
Result_Benchmark_LCM	DWORD	20 DUP(?)
; *insert benchmarks in between here*
timestamp1		DWORD	?					; stores edx part of rdtsc time stamp
timestamp2		dword	?					; stores eax part of rdtsc time stamp
;Result_Benchmark_LCM	QWORD	20 DUP(?)	; Extra credit option


; (insert variable definitions here)

.code
main PROC
	rdtsc									; measure your time
	mov timestamp1, edx						; moving high bit portion of rdtsc results to timestamp1
	mov timestamp2, eax						; moving high bit portion of rdtsc results to timestamp2
; Calculate GCD and LCM for 20 Benchmarks.
; (insert executable instructions here)
; segment 1 - Calculating and storing LCM and GCD - This segment makes a call to the arrayInfo macro, which, in turn, calls the processArray
; procedure for each benchmark.  Each call will generate an GCD and LCM for the respective benchmark (the one that is passed to the macro).
; The call also results in that GCD and LCM being stored in result arrays, so that this data can later be printed.
	arrayInfo Benchmark1, 0
	arrayInfo Benchmark2, 1
	arrayInfo Benchmark3, 2					
	arrayInfo Benchmark4, 3
	arrayInfo Benchmark5, 4
	arrayInfo Benchmark6, 5
	arrayInfo Benchmark7, 6
	arrayInfo Benchmark8, 7
	arrayInfo Benchmark9, 8
	arrayInfo Benchmark10, 9
	arrayInfo Benchmark11, 10
	arrayInfo Benchmark12, 11				
	arrayInfo Benchmark13, 12
	arrayInfo Benchmark14, 13
	arrayInfo Benchmark15, 14
	arrayInfo Benchmark16, 15
	arrayInfo Benchmark17, 16
	arrayInfo Benchmark18, 17
	arrayInfo Benchmark19, 18
	arrayInfo Benchmark20, 19				

; segment 2 - finish calculating program execution time - this segment takes another time stamp and then uses that to determine the program
; execution time in nanoseconds (it does this before it calls the print_results procedure, since we're really only interested in how long it
; takes to calculate the gcd and lcm of all of the benchmark arrays.  It stores the data in the memory locations timestamp2 and timestamp1,
; and the procedure printBigNum takes that information and prints out a 64 bit number that HOPEFULLY is an accurate representation of what 
; was in edx and eax after the subtraction was done.  The commented out code is there just in case you want to plug in dummy numbers to see
; if a proper 64-bit number is printed since edx is normally going to be 0 with this program.  There is also a commented out line of code that allows you to
; print out the execution time if you need print_result to be commented out (since normally, the execution time is printed out after everything
; else is printed out by print_result)
	rdtsc									; measure your time
	sub eax, timestamp2						; subtracting old low bit timestamp from new low bit timestamp
	sbb edx, timestamp1						; using subtraction with borrow to deal subtract old high-bit timestamp from new high-bit timestamp
	xchg timeStamp2, eax
	xchg timeStamp1, edx
	;mov timeStamp1, 230h					; test printBigNum with non-zero value in edx
	;mov timeStamp2, 49771					; dummy value for testing
	;call printBigNum						; if you want to print execution time without running print_result, uncomment this
	
;*****************************************************************************
; Do not change this section - segment 3 - calling print_result
;*****************************************************************************	
	call print_result						; print your final result
	exit            						; exit to operating system
main ENDP
;*****************************************************************************

; processArray procedure - This procedure takes a benchmark array and does a number of things to it.  It runs the array through a number of checks
; to eliminate corner cases.  It makes sure that the array has more than 1 element and less than 5 elements (anything outside that range is considered
; a corner case.  It then checks to see if the benchmark's datatype is more than 32 bits.  if it isn't less than or equal to 32 bits, it is considered
; a corner case.  Once the benchmark array passes those checks, processArray then checks the benchmark's datatype and, if necessary, essentially
; converts it to a dword (by moving it to eax and then pushing it to the stack).  While converting the elements of the benchmark array to dwords
; processArray also checks to see if each individual number is negative or not.  Negative numbers are converted to positive with the neg instruction as
; leaving the numbers in their negative forms would produce incorrect results (since it is only possible to determine if the numbers are negative or positive
; while checking them in their original form (byte for byte, word for word, etc.) when calculating GCD and LCM.  Once all of the elements of the benchmark
; array have been pushed to the system stack, processArray repositions ESI to the last element on the stack (the top of the stack, I suppose).  It then 
; calls procedures that take the elements and calculate GCD and LCM.  Once it has that data, it stores it in two separate arrays (one for gcd
; and one for LCM).  All corner cases jump to a block of code that inputs 0s for LCM and GCD.  Once it has finished the task of calculating GCD and LCM
; process array does some bookkeeping with the system stack and EBP and then returns to main
; Implementation Note: This procedure accesses its passed in parameters via the stack (it establishes a stack frame).  
; Parameters must be passed in this order and fashion:
; 1 - benchmark array - address must be passed, so elements can be converted to dwords and pushed to the system stack (in order to calculate GCD and LCM)
; 2 - type of benchmark array - value that represents data type of the array (1 for byte, 2 for word, etc) must be passed in to check for corner cases
; 3 - length of benchmark array - value that represents length of the array must be passed in.  it is used a counter for a variety of processes in processArray
; and procedures that it calls
; 4 - num - a value that represents the index that calculated GCD and LCM will be placed into in two arrays that are used to store GCD and LCM
; receives: benchmark address, benchmark type (value), benchmark length (value), and num/index (value) all on the system stack
; returns: Nothing really.  uses passed in data to generate LCMs and GCDS of benchmark arrays and then stores that data in two arrays (that are accessed
; as global variables)
; preconditions: num must match up with the index that the user wants the GCD and LCMS of the benchmarks to be stored in in the two results arrays.  Num must be
; be between 0 and 19 (anything else will cause problems).  
; registers changed: eax ebx, ecx, edx, esi, and edi (through called procedures)
processArray PROC
	push ebp								; setting up stack frame
	mov ebp, esp			
	mov esi, [ebp+20]						; moving array to esi
	mov ebx, [ebp+16]						; moving type to ebx
	cmp ebx, 4								; checking to see if array is higher than 32 bits
	jg wInput								; if so, jump to jump to wInput, which inputs 0 for GCD and LCM
	mov ecx, [ebp+12]						; moving lengthof to ecx
	cmp ecx, 1								; checking to see if array is less than or equal to 1 
	jle wInput								; if so, input 0 for GCD and LCM
	cmp ecx, 4								; checking to see if array larger than 4
	jg wInput								; if so, input 0 for GCD and LCM
	xor eax, eax							; clearing eax in case array to prep for arrays with bytes and words
	cmp ebx, 2								; checking to see if data type of array is byte, word, or dword
	jl byteStore							; need to move bytes to stack
	jg dwordStore							; moving dwords to stack and checking for 64 bit integers	
; wordstore is a block of code that converts word datatypes into dwords.  It also checks for negative numbers and converts them to positive numbers
wordStore:
	mov ax, [esi]							; moving first value in array to ax
	cmp	ax, 0								; checking to see if value is negative
	jge	positiveW							; if not push to stack 
	neg ax									; otherwise, get two's compliment (we need absolute value)
; positive numbers are pushed to the stack, and the loop is restarted until the counter (length of the benchmark array) hits 0
positiveW:
	push eax								; pushing integer to stack
	add esi, 2								; incrementing esi to next spot in array (value of 2 because this array has 16-bit values)
	loop wordStore							; restarting loop
	jmp GCDandLCM							; jump to GCDandLCM so program can begin calculating GCD and LCM
; byteStore is a block of code that converts byte datatypes into dwords.  It also checks for negative numers and converts them to positive numbers
byteStore:
	mov al, [esi]							; moving bytes to al so they can be pushed to stack as 32 bit integers
	cmp al, 0								; checking to see if integer is negative
	jge positiveB							; if not, push value to stack
	neg al									; if negative, use neg instruction to get absolute value
; positive numbers are pushed to system stack, and loop is restarted until the counter (length of the benchmark array) hits 0
positiveB:
	push eax								; pushing value to stack
	add esi, 1								; moving to next spot in array
	loop byteStore							; restarting loop
	jmp GCDandLCM							; moving to block of code to begin calculating GCD and LCM
; dwordStore is a block of code that moves dwords to the stack (no need to convert anything) and turns negative numbers to positive numbers
dwordStore:
	mov eax, [esi]							; storing 32-bit value from array in eax
	cmp eax, 0								; checking to see if value is negative
	jge positiveD							; if not, move push to stack
	neg eax									; otherwise, get absolute value with neg instruction
; positive dwords are pushed to stack, and loop is started over until counter (length of benchmark array) hits 0
positiveD:
	push eax								; push value to stack
	add esi, 4								; increment to next value in array 
	loop dwordStore							; restart loop
; GCDandLCM is a block of code that calls procedures that calculate GCD and LCM of the benchmark array.  First, it moves ESI to point to the top of
; the stack (which contains the last element of the benchmark array that was pushed to the stack).  It then calls gcdWrapper, which calculates GCD.
; it takes the result from that (which is stored in eax) and moves that to the appropriate position in Result_Benchmark_GCD (using num as an index).
; It points esi back to to the top of the stack and then calls the lcm procedure, which calculates the lcm of the benchmark array.  It stores the generated
; lcm, and then points esp at ebp (to correct for all of the values pushed onto the stack earler) and jumps to a block of code labelled finished
GCDandLCM:	
	mov	ecx, [ebp+12]						; resetting counter (lengthof array) to calulate gcd
	mov	esi, esp							; copying location of first number in stack to esi		
	call gcdWrapper							; calling procedure to calculate GCD of numbers in array
	mov edx, [ebp+8]						; moving benchmark number to edx, so we can store gcd in correct spot in gcd array
	mov Result_Benchmark_GCD[edx*4], eax	; storing gcd
	mov esi, esp							; resetting esi to start of array of numbers
	mov	ecx, [ebp+12]						; resetting counter (lengthof array) to calulate lcm
	call lcm								; calling procedure to calculate lcm
	mov edx, [ebp+8]						; moving benchmark number to edx, so we can store LCM in correct spot in LCM array
	mov Result_Benchmark_LCM[edx*4], eax	; storing lcm in lcm array
	mov esp, ebp							; moving stack back to position at beginning of procedure
	jmp finished							; getting ready to exit procedure
; wInput is a block of code that arrayProcess jumps to when corner cases are detected.  It inserts 0s for GCD and LCM in the two result arrays
; and then moves on to finished
wInput:
	mov edx, [ebp+8]						; need to insert 0s for GCD and LCM, because inputs are corner case
	mov Result_Benchmark_GCD[edx*4],0
	mov Result_Benchmark_LCM[edx*4], 0
	mov esp, ebp							; moving stack back to original position (to beginning of stack frame)
; finished restores the stack by popping ebp and adding 16 to the ESP's address (through ret 16).  The program then returns to main
finished:
	pop ebp									; stack bookkeeping so we can exit procedure
	ret 16									; returning to main and moving adjusting stack to correct position
processarray endp

; gcdWrapper procedure - This procedure takes values from a benchmark array that have been pushed to the stack (and are pointed to by ESI) and
; runs them through checks to make sure whatever is in value A isn't being divided by 0.  If a 0 is detected in ebx, the procedure skips the gcd 
; procedure call and moves to the next step.  If no 0 is detected in ebx, gcd is called, and the gcd of the 2 values is calculated and stored in 
; eax.  ECX is then checked (it has the value of the length of the benchmark array stored, so it is used as a counter) to see if there are any 
; elements left in the benchmark array left to process.  If there aren't, whatever is in eax is returned as the GCD.  IF there are, the loop restarts.
; So, to sum things up, the formula for getting the GCD of a series of numbers IN THIS program looks like this:
; gcd(a, b) -- gcd(gcd(a,b), c) -- gcd(gcd(gcd(a,b), c), d) -- etc.
; Implementation Note: This procedure accesses its parameters via registers, and the stack (indirectly).  Things must be set up in a very 
; way, which will be outlined in receives and preconditions
; receives: all elements (value) from benchmark array via system stack and eax register, address of top of system stack in esi, length of (value)
; benchmark array in ecx
; returns: GCD of benchmark array in eax
; preconditions: All of the elements of the benchmark array must be in the system stack, and they all must be positive values (negative values need to be converted
; to absolute value).  ESI must point to the top of the system stack as it through the system stack and is used to put new values into ebx.   The length of the array
; must be put into ecx, because it is used as a counter and is essential in making sure gcdLoop only accesses things from the system stack that it is supposed to.
; EAX must contain the value of the last element placed onto the system stack (I probably didn't need to push that value into the stack since I have it in eax).
; or gcdLoop and GCD will not produce an accurate GCD.
; registers changed: eax, ebx, ecx, edx (by calling gcd), and esi
gcdWrapper PROC
gcdLoop:					
	add esi, 4								; incrementing to next number in array
	mov ebx, [esi]							; moving next number in array to ebx
	test ebx, ebx							; if b is 0, we skip gcd call and move on to check ecx
	jz zero
	call gcd								; calling gcd proc to calculate GCD of two numbers
zero:
	cmp ecx, 2								; checking to see if there are any integers left to process in array
	jle quit								; quit if there aren't
	dec ecx									; otherwise decrement ecx and get gcd of next number in array and gcd in eax
	jmp gcdLoop								; restart loop
quit:
	ret										; exit procedure
gcdWrapper endp

; gcd procedure - gcd takes two values (1 in eax, and the other in ebx) and calculates the greatest common divisor of the two values.  This procedure
; does not check for any corner cases (gcdWrapper and lcm handle that).  It simply divides the value in eax by ebx, moves ebx into eax, and moves the remainder
; into ebx.  It the tests to see if the value in ebx equals 0.  If it does, the procedure ends (the value in eax is the GCD of the 2 values).
; So, the method for calculating (in a more mathematical form) looks like this:  (note r signifies remainder)
; a/b
; does remainder equal 0? 
; if not, b / (r(of a/b))
; does remainder equal ?
; if not, (r(of a/b)) / (r(b/r(of a/b))
; and so on.
; Implementation Note: This procedure accesses its parameters via the registers eax and ebx
; receives: value A (value) in eax and value B (value) in ebx
; returns: GCD in eax
; preconditions: value in ebx cannot be 0
; registers changed: eax and ebx
gcd proc
euclid:
	xor edx, edx							; clearing edx for division
    div	ebx									; dividing to determine gcd
    mov eax, ebx							; moving value B to eax
    mov ebx, edx							; moving remainder to ebx
    test ebx, ebx							; if remainder doesn't equal 0, restart loop
    jnz	euclid						
	ret
gcd endp

; lcm procedure - This procedure takes values from a benchmark array that have been pushed to the system stack and uses the GCD procedure to generate
; an lcm.  LCM makes sure to look for values of 0 in either eax (just in the very beginning) and ebx.  A 0 means that the LCM is automatically a 0 (so the procedure
; ends).  If ebx is ever 0, eax is assigned value of 0 and procedure ends.  Once these checks are passed, gcd is called to get the gcd of
; a and b (a is in eax, and b is in ebx).  a is then divided by gcd(a, b), and the quotient of that is multiplied by b.  The program checks for
; overflow (overflow means the multiplication has resulted in a 64-bit digit).  If there is overflow, a 0 is generated as the LCM (meaning a 0 is put into
; eax), and the procedure ends.  If there is no overflow, the program checks ecx (again,lengthof is used as a counter) to see if there are any 
; elements from the benchmark array left to process.  If there are, ecx is decremented, and the next value from the benchmark array is moved into 
; ebx, and lcm is calculated again.  
; So, a mathematical version of all of this would look like this:
; lcm = (a / gcd(a, b)) * b
; to lcm = (lcm((a / gcd(a, b)) * b) / (gcd (lcm((a / gcd(a, b)) * b), b)) * c
; and so on
; Implementation Note: This procedure accesses its parameters via registers, and the stack (indirectly).  Things must be set up in a very 
; way, which will be outlined in receives and preconditions
; receives: all elements (value) from benchmark array via system stack and eax register, address of top of system stack in esi, length of (value)
; benchmark array in ecx
; returns: lcm (value) in eax
; preconditions: All of the elements of the benchmark array must be in the system stack, and they all must be positive values (negative values need to be converted
; to absolute value).  ESI must point to the top of the system stack as it through the system stack and is used to put new values into ebx.   The length of the array
; must be put into ecx, because it is used as a counter and is essential in making sure lcm only accesses things from the system stack that it is supposed to.
; EAX must contain the value of the last element placed onto the system stack (I probably didn't need to push that value into the stack since I have it in eax).
; or LCM and GCD will not produce an accurate LCM.
; registers changed: eax, ebx, ecx, edx, esi, edi (some of these are changed through a call to gcd)
lcm PROC
	mov eax, [esi]							; copy first number in array to eax
	test eax, eax							; checking to see if a value is 0
	jz quit									; if it is, end procedure
lcmLoop:
	add esi, 4								; increment to next number in array
	mov ebx, [esi]							; move that number to ebx
	test ebx, ebx							; if b value is 0, assign LCM (eax) a value of 0 and exit procedure
	jz overFlow
LCMnonZero:
	mov edi, eax							; copy number in eax to edi, because multiple operations have to be done to both operands
	call gcd								; getting gcd of a and b
	xchg eax, edi							; swapping gcd with product of a and b, so we can do division
	xor edx, edx							; clearing edx for division
	mov ebx, [esi]							; need to put original b-value back into ebx to calculate LCM
	div edi									; divide a-value by GCD
	mul ebx									; multiply result of division by b-value
	test edx, edx							; checking for overflow into edx (if multiplication results in lcm over 32 bits)
	jnz overFlow							; if so, make result 0 (corner case) and exit procedure
	cmp ecx, 2								; checking to see if there is another integer in array to process
	jle quit								; if not exit proedure
	dec ecx									; otherwise, decrement ecx and restart loop
	jmp lcmLoop
overFlow:
	mov eax, 0								; assigning eax a value of 0 if there is overflow (or if ebx equals 0)
quit:
	ret
lcm endp

; print_result procedure - This procedure doesn't do much on its own.  It exists mostly to call macros and other procedures that print out the
; elements in the benchmark arrays and the corresponding gcds and lcms. it also calls a procedure that prints out a 64-bit integer (that represents
; execution time of the program).  It assigns a 0 to ecx (which is important for the procedures that it cals) and also prints an introductory message for the program.
; receives: It accesses some global variables (specifically the benchmark arrays and the intro string).
; returns: Nothing.  It uses other procedures (for the most part) to print data.  It does print the title of the program, though
; preconditions: timeStamp1 and timeStamp2 need to have proper values generated by rdtsc assigned to them.
; registers changed: ecx and edx (and most of the other registers through procedure calls)
print_result	PROC
	mov ecx, 0								; ecx is used as counter for GCD and LCM prints
	mov edx, offset intro					; printing introduction to program that lists my  name and title of program
	call writestring
	call crlf
	printInfo Benchmark1,1					; using macro to pass information about benchmark1 to procedure that will print all of our numbers and resultss
	printInfo Benchmark2,2
	printInfo Benchmark3,3
	printInfo Benchmark4,4
	printInfo Benchmark5,5
	printInfo Benchmark6,6
	printInfo Benchmark7,7
	printInfo Benchmark8,8
	printInfo Benchmark9,9
	printInfo Benchmark10,10
	printInfo Benchmark11,11
	printInfo Benchmark12,12
	printInfo Benchmark13,13
	printInfo Benchmark14,14
	printInfo Benchmark15,15
	printInfo Benchmark16,16
	printInfo Benchmark17,17
	printInfo Benchmark18,18
	printInfo Benchmark19,19
	printInfo Benchmark20,20
	call printBigNum
	;Result_Benchmark_GCD	DWORD	20 DUP(?)
	;Result_Benchmark_LCM	DWORD	20 DUP(?)
	
	ret										; return to main
print_result	ENDP


; printLine procedure - printLine is incredibly similar to processArray in that it takes in a benchmark array address, the length of the benchmark (value),
; the data type (value) of the benchmark, and a num (the number of the benchmark for printing), and uses all of them to print out all of the
; elements in the benchmark arrays, and the associated gcds and lcms.  PrintLine prints out a series of strings (that surround the number values that
; it pulls from the benchmark arrays and the lcm and gcd result arrays) so that everything is printed out in a neat and readable way.
; The general format is:
; (display1 string) + (num) + (colon) + (space) + (element from benchmark array) + (comma) + (space) + (next element from benchmark array) etc.
; an example would be:
; Benchmark 1: 22, 93
; printLine functions similarly to processArray in that it converts individual elements from the benchmark arrays into dwords (if they are words
; or bytes) and pushes them to the system stack.  It then assigns the address stored at ebp to esi and progresses to the top of the stack and prints
; all of the benchmark array elements that had been pushed to the system stack.  printResults is called, which prints the GCD and LCM for the benchmark
; array that is being called.  And, once that is finished, the printLine does some stack bookkeeping and returns to print_result
; Implementation Note: This procedure accesses most of its passed in parameters via the stack (it establishes a stack frame).  
; Parameters must be passed in this order and fashion:
; 1 - benchmark array - address must be passed, so elements can be converted to dwords and pushed to the system stack (so they can be moved to eax and printed)
; 2 - type of benchmark array - value that represents data type of the array (1 for byte, 2 for word, etc) must be passed in, because printLine must
; determine what datatype each benchmark array is (in order to move elements around and print them
; 3 - length of benchmark array - value that represents length of the array must be passed in.  it is used a counter for a variety of processes in printLine
; and procedures that it calls
; 4 - num - This is the number of the benchmark array that is being passed in (a value of 1 means we're dealing with benchmark1).  This is necessary to print
; things correctly
; receives: benchmark address, benchmark type (value), benchmark length (value), and num (value) all on the system stack.  Some strings are accessed
; as global variables, a counter in ecx
; returns: this modifies 
; preconditions: Ecx must set to 0 before the first call by the calling procedure.  After that, it cannot be altered (as ecx is used to access
; elements in the gcd and lcm result arrays)
; registers changed: eax, ebx, ecx, edx, esi, and edi
printLine proc
	push ebp								; establishing stack frame	
	mov ebp, esp
	mov edx, offset display1				; printing out first part of line of text that displays elements in a benchmark array
	call writestring
	mov eax, [ebp+8]						; printing out number of benchmark (eg benchmark 1  or benchmark 2)
	call writedec
	mov al, 3Ah								; printing colon character
	call writechar
	mov al, 20h								; printing space character
	call writechar	
	xor eax, eax							; clearing eax in case we have to process bytes or words
	xchg ecx, edx							; storing counter in ecx in edx
	mov ecx, [ebp+12]						; moving length of benchmark array to ecx
	mov ebx, [ebp+16]						; moving datatype of benchmark array to ebx
	mov esi, [ebp+20]						; storing address of benchmark array in esi
	cmp ebx, 2								; checking to see if data type is byte, word, or dword
	jl byteStore							; need to move bytes to stack
	jg dwordStore							; moving dwords to stack and checking for 64 bit integers
wordStore:
	mov ax, [esi]							; moving word to eax
	cmp	ax, 0								; checking for negative numbers
	jge	positiveW							; if not negative, push to stack
	neg ax									; if negative, get two's compliment
positiveW:
	push eax								; positive, so pushing to stack
	add esi, 2								; incrementing to next spot in benchmark array
	loop wordStore							; restarting loop if necessary
	jmp printLoopPrep						; moving ahead to print elements
byteStore:
	mov al, [esi]							; moving bytes to al so they can be pushed to stack as 32 bit integers
	cmp al, 0								; checking to see if number is negative
	jge positiveB							; if not, push to stack
	neg al									; if negative, get two's complement
positiveB:
	push eax				
	add esi, 1								; moving to next spot in array
	loop byteStore							; restarting loop
	jmp printLoopPrep						; moving ahead to print elements
bigStore:
	push 0									; pushing 0s to stack since we have 64-bit integers
	loop bigStore							; restarting loop if necessary
	jmp printLoopPrep						; skipping ahead to print elements
dwordStore:
	cmp ebx, 4								; checking for 64-bit integers
	jg bigStore								; if greater than 32 bit, jump up to insert 0s into stack
dwordAdd:
	mov eax, [esi]							; moving dwords numbers to eax
	cmp eax, 0								; checking to see if negative
	jge positiveD							; if not, push to stack
	neg eax									; if negative, get two's complement
positiveD:
	push eax								; pushing positive value to stack
	add esi, 4								; moving to next spot in array
	loop dwordAdd			
printLoopPrep:
	xchg ecx, edx							; moving passed in counter back to ecx
	mov edx, [ebp+12]						; copying length of benchmark array to edx
	mov esi, ebp							; setting esi to point to first element from benchmark array pushed to stack	
printLoop:
	sub esi, 4								; decrementing esi by 4 so we can move to next element on stack
	mov eax, [esi]							; moving element to eax so it can be printed
	call writedec
	dec edx									; decrementing edx (length of array is our counter for this loop)
	test edx, edx							; is edx 0?  if so, jump out of loop to quit code block
	jz quit							
	mov al, 2ch								; printing comma character
	call writechar
	mov al, 20h								; printing space
	call writechar
	jmp printLoop							; restarting loop

quit:
	mov esp, ebp							; stack bookkeeping (pointing esp to where it was before elements from benchmark array were pushed to stack)
	call crlf
	call printResults						; caling printResults so GCD and LCM of benchmark can be printed
	pop ebp									; stack bookkeeping so we can exit procedure
	ret 16									; stack bookkeping
printLine endp

; printResults procedure - This procedure prints out a line with some strings and the GCD and LCM of whatever benchmark is currently being processed
; by printLine.  printResults accesses the gcd and lcm result arrays and uses the counter stored in ecx (way back in print_printResults) increment through
; each array and print out the correct numbers.  Each output line should look like this:
; (gcdText string) + (GCD) + (lcmText string) + LCM
; an example would be:
; GCD is 2 and LCM is 16
; receives: counter (value) via ecx register.  This procedure accesses Result_Benchmark_GCD and Result_Benchmark_LCM as global variables
; returns: It returns an adjusted ECX value (it increments it by 4)
; preconditions: If a sequence of arrays is being printed (say, benchmark1 through benchmark 10 or whatever), ecx cannot be altered by any procedure
; other than printResults
; registers changed: ecx, edx
printResults proc
	mov edx, offset gcdText					; Printing out first part of line of text that displays GCD and LCM of a benchmark array
	call writestring
	mov eax, Result_Benchmark_GCD[ecx]		; printing appropriate GCD (uses ecx to get correct one)
	call writedec	
	mov edx, offset lcmText					; printing out another string to make this line of text neat and readable (look at description of procedure)
	call writestring
	mov eax, Result_Benchmark_LCM[ecx]		; printing out appropriate LCM
	call writedec
	add ecx,4								; incrementing ecx counter by 4
	call crlf								; 2 spaces for readability
	call crlf
	ret										
printResults endp

; printBigNum procedure - This procedure takes two 32-bit integers and prints them out (high bit is stored in edx, and low bit is stored in eax)
; as a proper 64-bit integer.  This is tricky to explain (and I don't think my method is optimal), so I'll just write out an example to show
; how it works:
; high bits = 230h, low bits = c26b
; 230h / Ah = 38h with remainder 0
; c26bh / Ah = 1371h with remainder 1
; push 1 to stack
; 38h / Ah = 5 with remainder 6  (now here's where it's weird)
; since 6 is in edx, and 00001371h is in eax, dividing eax by 10 is like:
; 600001371h / Ah = 99999b8bh with remainder of 3
; push 3
; 5h / Ah = 0 with remainder of 5
; 5h in edx, and 99999b8bh in eax and dividing eax by Ah is like:
; 599999b8bh / Ah = 8f5c2927h with remainder of 5
; push 5
; Since high bit value is 0 now, we start printing the numbers that we have generated.
; Print 8f5c2927h, then 5, then 3, then , then 1
; 8f5c2927h = 2405181735 + 5 + 3 + 1  = 2405181735531, which is our 64-bit number
; This procedure also prints out some strings along with the number so that everything is readble and neat.
; receives: timeStamp2 and timeStamp1 as global variables (well, that's how it access them)
; returns: It generates a 64 bit number and prints it out, but it doesn't really return a value
; preconditions: timeStamp2 must contain the low bits, and timeStamp1 must contain the high bits
; registers changed: eax, ebx, ecx, edx, esi
printBigNum proc
	xchg timeStamp2, eax					; moving low bits to eax
	xchg timeStamp1, edx					; moving high bits to edx
	test edx, edx							; if high bits equal 0, just print out low bits as 32 bit number
	jnz doWork								; if not, jump to block of code to generate 64-bit number
	mov edx, offset exeTime					; printing out string to make line of text more readable and neat
	call writestring
	call writedec
	mov edx, offset nano					; printing out string to make line of text readable
	call writestring
	call crlf
	jmp quit								; quit out since we only need to print out 32-bit number
doWork:
	mov ecx, 0								; setting up ecx as counter (need to know how many digits we're putting on stack)
	mov ebx, 10								; need to divide by 10
bigLoop:
	mov esi, eax							; storing low bits in esi
	mov eax, edx							; moving high bits to eax
	xor edx, edx							; clearing edx for division
	div ebx									; dividing by 10
	xchg eax, esi							; moving low bits to eax, and result of division to esi
	div ebx									; dividing by 10
	push edx								; push remainder to stack (this is digit that we'll print later
	inc ecx									; keeping track of how many digits we've pushed to stack
	mov edx, esi							; moving high bits (after dividing by to) back to edx
	test edx, edx							; if edx equals 10, we're done and can start printing
	jz printNum
	jmp bigLoop								; if not, we start loop over
printNum:
	mov edx, offset exeTime					; printing out string to make line of text readable and nice
	call writestring
	call writedec							; printing out number in eax (first part of 64-bit number)
printRest:
	pop eax									; popping digit to eax
	call writedec							; printing digit
	loop printRest							; keep popping till out of digits
	mov edx, offset nano					; another string for readability
	call writestring
	call crlf
quit:
ret											; we're finally done
printBigNum endp
END main