!- Sudoku for the unexpanded VIC-20 by Chris Zinn
!- Version 1.00 10/13/2024  1.01 10/14/2024
!- Check out my youtube channel: https://www.youtube.com/@MyDeveloperThoughts
!- Check out the video for this project: 

!- This source code is for CBM Prog Studio 4.4.0
!- Be sure to go to settings -> BASIC Code Generation -> UNCHECK Include Spaces
!-          You will get an Out of Memory error if you do not
 
!- Variables used
!-n$       = For quick translation of a number to a string
!-gb      = Board Number (1..?)
!-gb%(8,8) = Game Board
!-c       = temp variable used for misc things
!-b       = boolean answer for gosubs.  -1 true 0 false
!-lf      = pieces left
!-sc      = score
!-qt      = Quit Flag.. if -1 then main loop continues
!-cx cx  = Cursor x and y position in the board
!-px py  = x,y on the screen relative to cx,cx

!- Constant replacements - these are used often, memory and speed benefit
!- k (_CHARS_IN_KBD_BUF_)       19

!- Constants for important memory addresses
!- Check these memory addresses out in the book Mapping the VIC
!-CONST _SOUND_VOLUME_     36878 
!-CONST _KERNAL_PLOT_      65520
!-CONST _CHARS_IN_KBD_BUF_ 198
!-CONST _CURSOR_BLINK_     204
!-CONST _CURSOR_REV_       207
!-CONST _CRS_SCN_LO_       209
!-CONST _CRS_SCN_HI_       210
!-CONST _CRS_LINE_X_       211
!-CONST _CRS_CLR_LO_       243
!-CONST _CRS_CLR_HI_       244
!-CONST _CURSOR_COLOR_     646
!-CONST _CPU_X_REG_        781
!-CONST _CPU_Y_REG_        782
!-CONST _CPU_STATUS_FLAGS_ 783
!-CONST _COLORS_           36879
!-CONST _BASS_SOUND_       36874
!-CONST _SOPRANO_SOUND_    36876
10 n$=" 123456789":dim gb%(8,8):c=0:b=0:poke _COLORS_,10:poke _SOUND_VOLUME_,15
11 k=198
20 print "{clear}{white}select puzzle"chr$(13)"{green}1-4 {yellow}5-8 {purple}9-10 {red}11{white}":input gb
30 if (gb<0 or gb>11) then end
40 print "{cyan}one moment...":gosub800:print"{clear}bye":end

!-start and play the game
800 cx=0:cy=0:sc=0:qt=-1
810 gosub 8000:gosub 7000
820 gosub 1000:iflf=0thengosub4000:return
830 ifqtthen820
840 return

!- wait for key press: 204,0 forces cursor blink.
!- set it to 1 when your done
!- _KERNAL_PLOT_ 65520 x,y
!-       Clear Carry should be clear.
!-       X=row Y=column then sys it to move the cursor there
1000 px=cx:py=cy:poke_CURSOR_COLOR_,7
1010 if px>2 then px=px+1
1020 if px>6 then px=px+1
1030 if py>2 then py=py+1
1040 if py>6 then py=py+1
1080 poke_CPU_STATUS_FLAGS_,0:poke_CPU_X_REG_,py+7:poke_CPU_Y_REG_,px+5:sys_KERNAL_PLOT_
1090 poke _CURSOR_BLINK_,0:poke k,0:wait k,1:poke _CURSOR_BLINK_,1:poke _CURSOR_REV_,0
1100 pokek,0:a$=chr$(peek(631))
1110 x=peek(_CRS_SCN_LO_)+peek(_CRS_SCN_HI_)*256+peek(_CRS_LINE_X_):pokex,peek(x)and127
1120 x=peek(_CRS_CLR_LO_)+peek(_CRS_CLR_HI_)*256+peek(_CRS_LINE_X_):pokex,1
1130 if a$="{left}"andcx>0thencx=cx-1
1140 if a$="{right}"andcx<8thencx=cx+1
1150 if a$="{up}"andcy>0thency=cy-1
1160 if a$="{down}"andcy<8thency=cy+1
1170 if a$="q" then gosub8500
1175 if a$="r" then gosub4500
1180 if a$>="1" and a$<="9" then gosub 2000:gosub 5000
1999 return

!- process a piece placement
2000 c=val(a$)
2010 if gb%(cx,cy)<>0 then gosub 6000:return

!- Does our number exist anywhere in this row? If so play buzzer
2020 b=0:forx=0to8:if(gb%(x,cy)and127)=cthenb=-1
2030 next:if b then gosub 6010:sc=sc-50:return

!- Does our number exist anywhere in this column? If so play buzzer
2040 b=0:forx=0to8:if(gb%(cx,x)and127)=cthenb=-1
2050 next:if b then gosub 6010:sc=sc-50:return

!- Does our number exist in this grid section
!- gx and gy are starting point for the grid we are input
2060 gx=int(cx/3)*3:gy=int(cy/3)*3
2070 b=0:forx=0to2:fory=0to2:if (gb%(gx+x,gy+y)and127)=cthenb=-1
2080 next:next:if b then gosub 6010:sc=sc-50:return

!- place the correct number on the board
!- Place new pieces on the board with the high bit set
!- This way we can tell which are original pieces and which we added
2090 gb%(cx,cy)=cor128:x=peek(209)+peek(210)*256+peek(211):pokex,c+48
2100 lf=lf-1:sc=sc+100:gosub 6020
2120 return


!- you win!
4000 print"{home}{down*2}{yellow}   puzzle finished!"
4010 print"     press any key":pokek,0:wait k,1:geta$:return


!- remove piece.  If the high bit is not set, don't remove it (Its an original piece)
4500 if gb%(cx,cy)=0 or (gb%(cx,cy)and128)=0 then return
4510 gb%(cx,cy)=0:sc=sc-100:lf=lf+1:gosub 7000:return


!- update score
5000 print"{home}{down*4}{purple}      puzzle {cyan}"gb
5005 if sc<-500 then sc=-500
5010 print"{purple}left:{cyan}"lf"{left}  {purple}score:{green}"sc"{left}  ":return


!- buzzer sound for piece exists in this spot
6000 forx=140to238step4:poke_BASS_SOUND_,x:next:poke_BASS_SOUND_,0:return
!- buzzer sound for wrong answer
6010 forx=140to238step4:poke_BASS_SOUND_,140:next:poke_BASS_SOUND_,0:return
!- ding for correct answer
6020 forx=235to250:poke_SOPRANO_SOUND_,x:next:poke_SOPRANO_SOUND_,0:return


!- paint the board
7000 print "{clear}{yellow}        s{blue}u{red}d{cyan}o{purple}k{green}u{down*5}
7010 print "    {cyan}U{sh asterisk*3}{cm r}{sh asterisk*3}{cm r}{sh asterisk*3}I
7020 for y=0 to 8:print"    {sh -}";
7030 for x = 0 to 8
7040 c=(gb%(x,y)and127)
7050 print"{white}"mid$(n$,c+1,1)"{cyan}";
7060 ifx=2orx=5thenprint"{sh -}";
7070 next x:print"{sh -}"
7080 if(y=2ory=5)thenprint"    {cm q}{sh asterisk*3}{sh +}{sh asterisk*3}{sh +}{sh asterisk*3}{cm w}
7090 next y
7100 print "    J{sh asterisk*3}{cm e}{sh asterisk*3}{cm e}{sh asterisk*3}K
7105 print "{down} {green}q{blue}uit {green}1-9{blue} {green}crsr{blue} {green}r{blue}emove{down}
7110 print "{red}  by chris zinn 2024";

!-Looking for memory leaks
!-7110 print "{red}  free:";fre(0);

7910 gosub5000:return


!- Read in the puzzle in our packed nibble format
!- c is passed in as the board number.  We will skip c-1*41 bytes

!- compacted board
!- xxxx yyyy   Pack 2 values per byte by using 4 bits per number
!- Example: 8 9
!- Value 8 ; we will move left 4 bits by multiplying it by 16
!- Value 9 ; we OR the bits to combine it into the byte
!- Packed value = 8*16 or 9
!-
!- Unpacking the 2 values
!- Packed value = 137 10001001
!- 137 and 00001111 (15) - this will mask out the upper to get the lower
!- 137 / 16 to the high value
!- print int(137/16),137 and 15 (will display 8 9)
8000 restore:c=(gb-1)*41:ifc>0thenforx=0toc-1:ready:next
8010 lf=81:x=0:y=0:forn=0to40:read c:gb%(x,y)=int(c/16)
8015 if int(c/16)>0 then lf=lf-1
8020 ifn=40thenc=0
8030 ifn<40thenc=cand15
8035 ifc>0thenlf=lf-1
8040 x=x+1:ifx=9thenx=0:y=y+1
8050 if(y<9)thengb%(x,y)=c
8060 x=x+1:ifx=9thenx=0:y=y+1
8070 nextn:return

!- End of game
8500 print"{home}{down*2}{yellow}    quit the game?":poke k,0:wait k,1:geta$
8510 if a$<>"y"thengosub7000:return
8520 qt=0:return

!- I copied these puzzles from a Sudoku booklet I bought at Walmart for $6
!- Puzzle 1 nibble packed (Each board is 41 bytes)
9000 data 9,,,64,16,48,9,32,128,117,,4,,8,9,16,86,,2,80,112,137,,6
9010 data 144,129,7,,5,,6,64,128,54,,16,144,48,,7,

!- Puzzle 2
9020 data 112,3,32,5,,4,,6,,,5,104,,65,9,96,,,35,4,89
9030 data 1,96,,,35,9,96,8,55,,,1,,8,,5,,150,,32
!- Puzzle 3
9040 data 80,112,9,,105,52,6,,,,40,115,5,6,32,,9,,,144,80
9050 data 32,,3,,,100,1,2,69,96,,,3,1,71,48,1,,80,128
!- Puzzle 4
9060 data 7,96,48,,,16,5,4,,3,4,145,8,,32,48,149,4,5,48,
9070 data 22,7,4,16,80,48,8,5,22,4,,2,4,,144,,,32,101,
!- Puzzle 5 (Medium) 31
9080 data 80,2,144,19,,3,,64,9,,32,80,,9,,8,32,5,2,96,
9090 data 57,4,,151,,8,,,32,128,2,,128,4,,4,128,23,,32
!- Puzzle 6 (Medium) 32
9100 data 64,,9,,,,16,4,6,96,112,,,7,86,,1,6,6,64,16
9110 data 53,5,,2,72,,,,64,80,129,6,,80,,,2,,,144
!- Puzzle 7 (medium) 34
9120 data ,32,1,,,8,2,,83,116,,6,32,1,,,9,96,6,144,
9130 data 23,,117,,,8,,23,,9,68,32,5,7,,,1,,48,
!- Puzzle 8 (medium) 36)
9140 data ,96,,,8,16,3,,32,32,116,1,,,,,137,,16,137,6
9150 data 80,64,4,32,,,,8,7,32,144,80,9,,120,,,,48,
!- Puzzle 9 (hard) 66
9160 data ,,8,,6,,53,,128,16,,64,121,,4,,3,16,,1,9
9170 data ,,145,,8,,4,32,128,,80,128,9,96,2,,2,,,
!- Puzzel 10 (hard) 68
9180 data ,16,,114,,135,,,3,3,2,,,4,,9,,88,,8,5
9190 data ,8,80,4,,6,,,2,9,6,,,3,64,1,144,,96,
!- Puzzle 11 (diabolical) 100
9200 data 128,0,0,9,80,36,0,0,7,0,112,9,0,0,5,6,66,0,0,3,2
9210 data 0,0,2,113,8,0,0,6,0,16,6,0,0,9,64,33,0,0,0,48
