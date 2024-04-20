Include Irvine32.inc


.data
    welcome BYTE "Welcome to Connect Four Game!", 0
    over BYTE "Game Over!", 0
    promptp BYTE "Select a column from 1 to 7:", 0
    selected BYTE "You selected: ", 0
    human_win BYTE "You Won!", 0
    ai_win BYTE "You Lost!", 0
    colFullprompt BYTE "Column is Full !",0
    invalidprompt BYTE "Invalid Move!",0
    drawprompt BYTE "This Game Is A Draw ! ",0
    p1Move BYTE "Player 1: ",0
    p2Move BYTE "Player 2: ",0
    MenuPrompt byte 10,13," Welcome To Connect 4 Game !",10,13,"1. Play AI",10,13,"2. Two-Player",10,13,"->",0
    playerinput  dword 0
    AIinput  dword 0
    validMove dword 0
    playerNoMove BYTE 1 
    colno byte " 1 2 3 4 5 6 7",0
    BELOWLINE byte "---------------",0
    vFlag BYTE 0 
    moves SDWORD 7 dup(-2)
    msg_winner1 db "Player 1 Wins!",0
    msg_winner2 db "Player 2 Wins!",0
    msg_no_winner db "No winner found.",0
    aiStopsWin dword 0
    indexInterecepted dword 1000
    colInterecepted dword 1000
    columnTracker dword 0
    rows  = 6
    cols = 7
    win = 4
    human = 1
    ai = -1 
    empty = 0
    aplha = -999999999
    player dword ai

    board dword rows*cols dup(0)
    copy dword rows*cols dup(0)


.code
main PROC
    call Menu
    ;call Aimove
    Exit
main ENDP

Menu PROC  Uses esi ecx edi ebx eax
    menuloop:
    lea edx,MenuPrompt  ;Prompt user for game modes 
    call writestring
    call Readdec
    cmp eax,1
    je AImode
    cmp eax,2
    je twopmode

    AImode:
    call PlayAi
    ret 
    twopmode:
    call PlayGame
    ret 
    jmp menuloop
    RET
Menu ENDP
Display PROC Uses esi ecx edi ebx eax
    call clrscr
    mov esi, 0   ; saving index of rows
    mov ecx, rows
    l1:
    push ecx
    mov edi, 0  ;index of column
    mov al, '|'   ;printing space after each  value
    call writechar
    mov ecx, cols
        l2:
            mov eax, cols; Index = row * columns + col
            mul esi  
            add eax, edi
            mov ebx, eax ;index of element
            mov eax, board[4*ebx]   ;print the value the array index holds
            cmp eax, 0
            jne skipp
            mov al, ' '
            call writechar
            jmp nextt
            skipp:
            call writedec
            nextt:
            mov al, '|'   ;printing space after each  value
            call writechar
            inc edi

        loop l2

    call crlf
    inc esi
    pop ecx
    loop l1

    lea edx,BELOWLINE
    call writestring
    call crlf
    mov edx, offset colno
    call writestring

    ret
Display ENDP



generateMoves PROC uses eax ebx ecx edx esi edi
    mov esi, 140   ; saving index of rows
    mov ecx, cols
    mov ebx, empty
    mov edi, 0
    c1:
    push ecx
    mov ecx, rows
    mov edx, esi
        c2:
            cmp ebx, board[edx]
            jne continue
            mov moves[edi], edx
            
            jmp nextt
            continue:
            sub edx,28 ;move to previous row if place not empty

        loop c2
    mov moves[edi], -1
    nextt:
    add edi, 4
    ;call crlf
    add esi, 4
    pop ecx
    loop c1
    ret
generateMoves ENDP

evaluate PROC
    ret
evaluate ENDP

playAi PROC  uses eax edx ecx ebx esi edi

    call Display
    XX: ;infine loop for player inputs 
    call playermove
    call Display
    mov ebx, 1   ; updating which player is playing 
    call checkVerticalWin
    call checkHorizontalWin
    call checkRightDiagonalWin
    call checkLeftDiagonalWin
    call isDraw
    
    call checkOppVerticalWin 
    call checkOppHorizontalWin
    cmp aiStopsWin,1 
    je specialmove 
    call Aimove ;ai makes hi move 
    jmp skipspecialmove
    specialmove:
    mov edi, colInterecepted
    mov playerinput,edi ;col no where human was winning 
    mov playerNoMove,2 ;to print 2 
    call checkColumn ;print move 
    skipspecialmove:
    mov eax, 500
    call DELAY
    call Display
    mov ebx, 2
    call checkVerticalWin
    call checkHorizontalWin
    call checkRightDiagonalWin
    call checkLeftDiagonalWin
    call isDraw
    mov aiStopsWin,0
    jmp XX
    ret
PlayAi ENDP

playGame PROC
    call Display
    XX: ;infine loop for player inputs 
    call playermove
    call Display
    mov ebx, 1
    call checkVerticalWin
    call checkHorizontalWin
    call checkRightDiagonalWin
    call checkLeftDiagonalWin
    call isDraw
    call player2move
    call Display
    mov ebx, 2
    call checkVerticalWin
    call checkHorizontalWin
    call checkRightDiagonalWin
    call checkLeftDiagonalWin
    call isDraw
    jmp XX
    ret
PlayGame ENDP


isDraw PROC uses eax edx ecx ebx esi edi
    mov ebx,0 ;works for index 
    mov esi,-1
    mov ecx , 7 ; run loop till length of moves array 
    drawLoop:
    cmp moves[ebx],esi  ;compare each value in moves array with -1 (if true means its a draw)
    jne notdraw  ;if value founnd doesnt equal to -1 then its not a draw 
    add ebx,4 ;else if val == -1 then iterate to next index 
    loop drawLoop
    draw:  ;if complete array is traversed and equals to -1 , its a draw 
    call crlf 
    call Display
    lea edx,drawprompt
    call crlf 
    call writestring
    exit 
    notdraw:  ;not a draw , as moves can be made .So just carry on
    RET
isDraw ENDP
Aimove PROC uses eax edx ecx ebx esi edi
    mov eax,0
    call Randomize 
    takeinput: ;take infinite input incase (to deal with wrong input )
    mov playerNoMove,3  ;variable states that its Ai move 
    call crlf
    mov validMove,0
    ;now generate AI's move
    mov eax,7
    call RandomRange 
    add eax,1
    mov playerinput, eax ;store player input in variable
    call checkColumn ;check where to insert move        
    cmp validMove,1 ;if the move made by player was valid, stop infinte input else take input again
    je outsideloop
    jmp takeinput

    outsideloop:

    RET
Aimove ENDP
playermove PROC uses eax edx ecx ebx esi edi
    mov eax,0
    takeinput: ;take infinite input incase (to deal with wrong input )
    mov playerNoMove,1  ;variable states that its player 1 move 
    call crlf
    mov validMove,0
    lea edx, promptp ;player move prompt
    call writestring
    call crlf
    lea edx,p1Move ;prompt for player 1 move
    call writestring
    mov eax,0 ; intialize eax
    call Readdec  ;taking player input
    mov playerinput, eax ;store player input in variable
    call checkColumn ;check where to insert move 
    call isDraw         
    cmp validMove,1 ;if the move made by player was valid, stop infinte input else take input again
    je outsideloop
    jmp takeinput

    outsideloop:

    RET
playermove ENDP
 
player2move PROC 
    mov eax,0
    takeinput2: ;take infinite input incase (to deal with wrong input )
    mov playerNoMove,2
    call crlf
    mov validMove,0
    lea edx, promptp ;player move prompt
    call writestring
    call crlf 
    lea edx,p2Move ;prompt for player 2 move
    call writestring
    mov eax,0 ; intialize eax
    call Readdec  ;taking player input
    mov playerinput, eax ;store player input in variable
    call checkColumn
    call isDraw
    cmp validMove,1 ;if the move made by player was valid, stop infinte input else take input again
    je outsideloop2
    jmp takeinput2

    outsideloop2:
    RET
player2move ENDP

checkColumn  PROC uses eax edx ecx ebx esi edi
    mov ebx,0
    mov eax, playerinput ;register holds input
   
    cmp eax ,1 ; checking if input lies in column 1 range and so on  (0-6)
    je col1
    cmp eax ,2 ; checking if input lies in column 1 range and so on  (0-6)
    je col2
    cmp eax ,3 ; checking if input lies in column 1 range and so on  (0-6)
    je col3
    cmp eax ,4 ; checking if input lies in column 1 range and so on  (0-6)
    je col4
    cmp eax ,5 ; checking if input lies in column 1 range and so on  (0-6)
    je col5
    cmp eax ,6 ; checking if input lies in column 1 range and so on  (0-6)
    je col6
    cmp eax ,7 ; checking if input lies in column 1 range and so on  (0-6)
    je col7

    lea edx,invalidprompt ; if no input was made btw 1-7 , inform player about invalid input
    call writestring
    ret

    col1:
    mov ebx,140 ;index for column
    jmp outt

    col2:
    mov ebx,144 ;index for column
    jmp outt

    col3:
    mov ebx,148 ;index for column
    jmp outt

    col4:
    mov ebx,152 ;index for column
    jmp outt

    col5:
    mov ebx,156 ;index for column
    jmp outt

    col6:
    mov ebx,160;index for column
    jmp outt

    col7:
    mov ebx,164;index for column
    jmp outt
   

    outt:
    mov ecx,6 ; iterate on every row
    columncheckloop:
    mov edx , board[ebx] ;index value move  
    cmp edx, empty ;cmp with 0
    je markmove  ;mark respective players move if empty space is found 
    jne nexttt  ;carry on if space is not empty 
    markmove:
    cmp playerNoMove,1 ;check if its player 1 move 
    je m1 ;jump to m1 if its true 
    cmp playerNoMove,2 ; check for 2nd player 
    je m2 
    cmp playerNoMove,3
    je m3
    m1:
    call MarkPlayer1Move
    call generateMoves
    ret ;return after making move 
    m2:
    call MarkPlayer2Move
    call generateMoves
    ret     ;ret after making move 
    m3:
    call MarkAiMove
    call generateMoves
    ret     ;ret after making move 
    nexttt:
    sub ebx,28 ;move to previous row if place not empty
    loop columncheckloop
    call crlf
    lea edx,colFullprompt ;if column is full already , inform the player
    call writestring
 
    RET
checkColumn  ENDP

MarkPlayer1Move PROC 
    mov validMove,1 ;marking that move made was legal
    mov edx , 1
    mov board[ebx],edx ;mark the move  with 1
    RET
MarkPlayer1Move ENDP

MarkPlayer2Move PROC 
    mov validMove,1 ;marking that move made was legal
    mov edx , 2
    mov board[ebx],edx ;mark the move  with 2
    RET
MarkPlayer2Move ENDP

MarkAiMove PROC 
    mov validMove,1 ;marking that move made was legal
    mov edx , 2
    mov board[ebx],edx ;mark the move  with 1
    RET
MarkAiMove ENDP

checkOppVerticalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword , col_track:dword
    mov c_player, ebx
    mov columnTracker,0 ;intialize 
    mov ecx,7 ;looping for all columns 

    mov edx,140 ;start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    changeColumnLoop:
    add columnTracker,1 ; increment to manage column number 
        mov indexInterecepted,edx ;  track where to intercept

        mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 3 ;loop 3 times 

        verticalcheck: ; loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,1 ;check fill condition
        je checkmore  ;if value is 1 , look for 3 more 1s above it
        jmp agliIteration
        checkmore:
        mov eax,board[edx-28];check 1 above 
        cmp eax,1
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            mov eax,board[edx-56];check 2 above 
            cmp eax,1
            je twoclear 
            jmp agliIteration
                twoclear:
                mov eax,board[edx-84];check 3 above 
                cmp eax,0
                je winningpositionfound
                jmp agliIteration
                    winningpositionfound:
                        ;intercept humans winning condition 
                        sub indexInterecepted, 84 ;exact index to be intercepted found 
                        mov aiStopsWin,1 ;indicate a special move 
                        mov edi , columnTracker
                        mov colInterecepted,edi
                        ret 

                    

        agliIteration:
        sub edx,28
        loop verticalcheck
        add esi,4 ;go to next column if no win in the previous column 
        mov edx,esi ; give that value to edx for upcoming iterations 
        mov ecx,ebx  ;maintaning outer loop value 
    loop changeColumnLoop
    RET
checkOppVerticalWin ENDP


checkOppHorizontalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword , rowloopcounter:dword
    mov rowloopcounter,0 
    mov c_player, ebx
    mov columnTracker,0 ;intialize 
    mov ecx,6 ;looping for all columns 

    mov edx,140 ;start checking right  from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    RowLoop:
    inc rowloopcounter
    cmp rowloopcounter,6
    jg loopends
    mov columnTracker,1 ;intialize 
    
        mov indexInterecepted,edx ;  track where to intercept

        mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 4 ;loop 3 times 

        ;*horizontalcheck*
        verticalcheck: ; loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,1 ;check fill condition
        je checkmore  ;if value is 1 , look for 3 more 1s above it
        jmp agliIteration
        checkmore:
        mov eax,board[edx+4];check 1 r 
        cmp eax,1
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            inc columnTracker
            mov eax,board[edx+8];check 2 r 
            cmp eax,1
            je twoclear 
            jmp agliIteration
                twoclear:
                inc columnTracker 
                mov eax,board[edx+12];check 3 r 
                cmp eax,0
                je winningpositionfound
                jmp agliIteration
                    winningpositionfound:
                        inc columnTracker ;exact column found 

                        ;intercept humans winning condition 
                        ;sub indexInterecepted, 84 ;exact index to be intercepted found 
                        mov aiStopsWin,1 ;indicate a special move 
                        mov edi , columnTracker
                        mov colInterecepted,edi
                        ret 

                    

        agliIteration:
        add edx,4
        loop verticalcheck
        sub esi,28 ;go to next row if no win in the previous row 
        mov edx,esi ; give that value to edx for upcoming iterations 
        mov ecx,ebx  ;maintaning outer loop value 
    jmp RowLoop
    loopends:
    RET
checkOppHorizontalWin ENDP

checkVerticalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,7 ;looping for all columns 

    mov edx,140 ;start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    changeColumnLoop:

        mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 3 ;loop 3 times 

        verticalcheck: ; loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player ;check fill condition
        je checkmore  ;if value is 1 , look for 3 more 1s above it
        jmp agliIteration
        checkmore:
        mov eax,board[edx-28];check 1 above 
        cmp eax,c_player
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            mov eax,board[edx-56];check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp agliIteration
                twoclear:
                mov eax,board[edx-84];check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp agliIteration
                    winnerfound:
                        call crlf 
                        cmp c_player, 2
                        je p2wins
                        lea edx,msg_winner1
                        call writestring
                        exit

                        p2wins:
                        lea edx,msg_winner2
                        call writestring
                        exit

        agliIteration:
        sub edx,28
        loop verticalcheck
        add esi,4 ;go to next column if no win in the previous column 
        mov edx,esi ; give that value to edx for upcoming iterations 
        mov ecx,ebx  ;maintaning outer loop value 
    loop changeColumnLoop
    RET
checkVerticalWin ENDP

checkHorizontalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,6 ;looping for all rows 

    mov edx,140 ;start checking right  from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    changeRowLoop:

        mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 4 ;loop 4 times 

        horizontalcheck: ; loop to traverse horizontally and check win condition 
        mov eax,board[edx]
        cmp eax,c_player ;check fill condition (p1 or p2 move )
        je checkmore  ;if value is 1 , look for 3 more 1s to the right of it
        jmp agliIteration
        checkmore:
        mov eax,board[edx+4];check 1 to the right  
        cmp eax,c_player
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            mov eax,board[edx+8];check 2 to the right  
            cmp eax,c_player
            je twoclear 
            jmp agliIteration
                twoclear:
                mov eax,board[edx+12];check 3 to the right  
                cmp eax,c_player
                je winnerfound
                jmp agliIteration
                    winnerfound:
                        call crlf 
                        cmp c_player, 2
                        je p2wins
                        lea edx,msg_winner1
                        call writestring
                        exit

                        p2wins:
                        lea edx,msg_winner2
                        call writestring
                        exit

        agliIteration:
        add edx,4 ;if condition fail , start assesing from its adjacent node
        loop horizontalcheck
        sub esi,28 ;go to above column if no win in the below column 
        mov edx,esi ; give that value to edx for upcoming iterations 
        mov ecx,ebx  ;maintaning outer loop value 
    loop changeRowLoop
    RET
checkHorizontalWin ENDP


checkRightDiagonalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,4 ;looping for all columns 

    mov edx,140 ;start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    changeColumnLoop:
        push ecx
        ; mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 3 ;loop 3 times 

        Diagonalcheck: ; loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player ;check fill condition
        je checkmore  ;if value is 1 , look for 3 more 1s above it
        jmp agliIteration
        checkmore:
        mov eax,board[edx-24];check 1 above and 1 right
        cmp eax,c_player
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            mov eax,board[edx-48];check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp agliIteration
                twoclear:
                mov eax,board[edx-72];check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp agliIteration
                winnerfound:
                    call crlf 
                    cmp c_player, 2
                    je p2wins
                    lea edx,msg_winner1
                    call writestring
                    exit

                    p2wins:
                    lea edx,msg_winner2
                    call writestring
                    exit

        agliIteration:
        sub edx,28
        loop Diagonalcheck
        add esi,4 ;go to next column if no win in the previous column 
        mov edx,esi ; give that value to edx for upcoming iterations 
        ; mov ecx,ebx  ;maintaning outer loop value 
        pop ecx
    loop changeColumnLoop
    RET
checkRightDiagonalWin ENDP

checkLeftDiagonalWin PROC  uses eax edx ecx ebx esi edi
    local c_player:dword
    mov c_player, ebx
    mov ecx,4 ;looping for all columns 

    mov edx,152 ;start checking vertically up from last row of 1st col  (at first we start from here )
    mov esi,edx ; preserving edx value 
    changeColumnLoop:
        push ecx
        ; mov ebx,ecx ;save ecx val for nested loop 
        mov ecx , 3 ;loop 3 times 

        Diagonalcheck: ; loop to traverse vertically and check win condition 
        mov eax,board[edx]
        cmp eax,c_player ;check fill condition
        je checkmore  ;if value is 1 , look for 3 more 1s above it
        jmp agliIteration
        checkmore:
        mov eax,board[edx-32];check 1 above and 1 right
        cmp eax,c_player
        je oneclear ; we need to clear 2 more for win
        jmp agliIteration
        oneclear:
            mov eax,board[edx-64];check 2 above 
            cmp eax,c_player
            je twoclear 
            jmp agliIteration
                twoclear:
                mov eax,board[edx-96];check 3 above 
                cmp eax,c_player
                je winnerfound
                jmp agliIteration
                winnerfound:
                    call crlf 
                    cmp c_player, 2
                    je p2wins
                    lea edx,msg_winner1
                    call writestring
                    exit

                    p2wins:
                    lea edx,msg_winner2
                    call writestring
                    exit

        agliIteration:
        sub edx,28
        loop Diagonalcheck
        add esi,4 ;go to next column if no win in the previous column 
        mov edx,esi ; give that value to edx for upcoming iterations 
        ; mov ecx,ebx  ;maintaning outer loop value 
        pop ecx
    loop changeColumnLoop
    RET
checkLeftDiagonalWin ENDP

END main