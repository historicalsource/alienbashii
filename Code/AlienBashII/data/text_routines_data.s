Game_Over_Text
	dc.b	CENTER_LINE,"G A M E",-1
	dc.b	CENTER_LINE,"O V E R",-1
	dc.b	0
	even	

Continue_Text
	dc.b	CENTER_LINE,"CHEAT MODE ENABLED",-1
Number_Of_Continues	
	dc.b	CENTER_LINE,"CREDITS LEFT 0",-1
	dc.b	CENTER_LINE,"CONTINUE (Y/N)",-1
	dc.b	0	
	even

Level_Over_Text
	dc.b	-1
	dc.b	CENTER_LINE,"* LEVEL COMPLETE! *",-1,-1
score_line	
	dc.b	CENTER_LINE,"* SCORE : 00000000 *",-1
cash_line	
	dc.b	CENTER_LINE,"* CASH : 00000 *",-1,-1
	dc.b	CENTER_LINE,"Press FIRE to continue",-1
	dc.b	0
	even
	
store_nums
	ds.w	32*6
store_text_nums
	ds.w	32*6	

text_bpr
	dc.w	BPR

copy_store_area
	dc.l	0	

malfont_mask_table	
	dc.l	%00000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%11000000000000000000000000000000
	dc.l	%11100000000000000000000000000000
	dc.l	%11110000000000000000000000000000
	dc.l	%11111000000000000000000000000000
	dc.l	%11111100000000000000000000000000
	dc.l	%11111110000000000000000000000000
	dc.l	%11111111000000000000000000000000	
	dc.l	%11111111100000000000000000000000
	dc.l	%11111111110000000000000000000000
	dc.l	%11111111111000000000000000000000
	dc.l	%11111111111100000000000000000000
	dc.l	%11111111111110000000000000000000
	dc.l	%11111111111111000000000000000000
	dc.l	%11111111111111100000000000000000
	dc.l	%11111111111111110000000000000000

white_list
	dcb.w	32,$fff	

black_list
	ds.w	32	
game_list
	ds.w	32
