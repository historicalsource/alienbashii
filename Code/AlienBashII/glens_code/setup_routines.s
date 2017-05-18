	
SINGLE_PLANE	EQU 	((OVERSCROLL_OFFSET+SCROLL_HEIGHT)*BPR)		;did have *2 on overscroll offset
PLANE_INC	EQU	SINGLE_PLANE
SCROLL_MEMORY	EQU	SINGLE_PLANE*12


MAP_MEMORY	EQU	BIGGEST_MAP_X*BIGGEST_MAP_Y*3 ;main map word, alien map byte

GAME_MEMORY	EQU	SCROLL_MEMORY+OVERSCROLL_OFFSET*BPR	; allow for scroll into memory

COPY_STORE	EQU	SINGLE_PLANE

NUMBER_OF_BLOCKS	EQU	1180

BLOCKS_MEMORY	EQU	(2*16*4)*NUMBER_OF_BLOCKS

LOADER_PIC_SIZE	EQU	8116		;bytes

FAST_MEM_MEMORY	EQU	MAP_MEMORY+COPY_STORE+BLOCKS_MEMORY+LOADER_PIC_SIZE


MEM_CHIP	EQU 	$02
MEM_FAST 	EQU 	$04
MEM_PUBLIC	EQU	$01	;Chooses fast first, chip second
MEM_CLEAR 	EQU 	$10000

BIT_PLANE_DMA	EQU	$0100
SPRITE_DMA	EQU	$0020
BLITTER_NASTY	EQU	$0400

******************************************
*****        BLANK OUT WORKBENCH     *****
******************************************
Blank_Out_Workbench

*Display shareware message
	

**set up pointers and variables so decompression is super quick	

	move.l	#blank_data,d0
	move.w	d0,swsprite0l
	move.w	d0,swsprite1l
	move.w	d0,swsprite2l
	move.w	d0,swsprite3l
	move.w	d0,swsprite4l
	move.w	d0,swsprite5l
	move.w	d0,swsprite6l
	move.w	d0,swsprite7l
	swap	d0
	move.w	d0,swsprite0h
	move.w	d0,swsprite1h
	move.w	d0,swsprite2h
	move.w	d0,swsprite3h
	move.w	d0,swsprite4h
	move.w	d0,swsprite5h
	move.w	d0,swsprite6h
	move.w	d0,swsprite7h

	move.l	#plane_positions,a2
	
	move.l	memory_base,d0
	move.w	d0,SHPLane1_Lo
	swap	d0
	move.w	d0,SHPlane1_hi
	swap	d0
	move.l	d0,(a2)
	add.l	#80*256,d0
	move.w	d0,SHPLane2_Lo
	swap	d0
	move.w	d0,SHPlane2_hi
	swap	d0
	move.l	d0,4(a2)
	add.l	#80*256,d0
	move.l	d0,8(a2)
	move.w	d0,SHPLane3_Lo
	swap	d0
	move.w	d0,SHPlane3_hi


	move.l  #$dff000,a6
	move.l	#shareware_screen_copper,cop1lch(a6)
	clr.w	copjmp1(a6)


	move.w  #BIT_PLANE_DMA+$8000,dmacon(a6)
	move.w	#SPRITE_DMA,dmacon(a6)




		
	moveq	#0,d3		;index into plane table
	move.w	#640,d4		;screen x size
	
	move.w  #3*4,d7		;number of planes ( *4 cos compare d3 with it - will inc by 4)
	
	move.w	#640,d6     ; pixel count ( count down )
	
	move.w	#640,d5	; image loaded size
	
		
	move.l  (a2,d3),a4	;get first plane
	
	move.l	#shareware_pic+4,a1
	
	move.w	iff_cols(a1),num_of_cols
	move.l	a1,colour_map_ptr
	add.l	#size_of_iff_header,colour_map_ptr
	
	move.w	iff_cols(a1),d0
	move.l	pic_data_size(a1),size_of_pic
	ext.l	d0
	asl	d0
	add.l	#size_of_iff_header,a1
	add.l	d0,a1
	move.l	a1,picture_data
	
	moveq	#0,d0		;clear

	move.l	size_of_pic,d2

	jsr	compressed_data		;Display pic


	move.w	#80,text_bpr

*	bsr	Display_System_Setup

	bsr	Sync
	move.l	colour_map_ptr,a0
	move.l	#game_list,a1
	move.w	#16-1,d0
copy_share_cols
	move.w	(a0)+,(a1)+
	dbra	d0,copy_share_cols	

	move.l	#black_list,a0
	move.l	#game_list,a1
	move.l	#share_cols+2,a2
	move.w	#16-1,d7
	move.l	#store_text_nums,a3
	move.w	#3,fade_speed
	jsr	Fade_List_To_List

*clear black list for later
	move.w	#16-1,d0
	jsr	Clear_Black_Colours	
	rts

FadeAfterLoading
	dc.w	0
	

******************************************
*****   DISPLAY_SYSTEM_SETUP         *****
******************************************
Display_System_Setup

	move.l	memory_base,a3
	move.w	#1,default_colour
	tst.w	chip_type
	beq.s	bog_standard
	move.l	#chip_type_string2,a4
	bra.s	display_chip_string
bog_standard
	move.l	#chip_type_string1,a4
display_chip_string
	move.w	#230,d0
	move.w	#80,d1
	jsr	Display_Small_String_Skip

	move.l	memory_base,a3
	cmp.w	#ON,xtra_fx
	bne.s	bog_standard_fx
	move.l	#xfx_string2,a4
	bra.s	display_fx_string
bog_standard_fx
	move.l	#xfx_string1,a4
display_fx_string
	move.w	#230,d0
	move.w	#80+9,d1
	jsr	Display_Small_String_Skip

	move.l	memory_base,a3
	cmp.w	#ON,xtra_music
	bne.s	bog_standard_music
	move.l	#music_string1,a4
	bra.s	display_music_string
bog_standard_music
	move.l	#music_string2,a4
display_music_string
	move.w	#230,d0
	move.w	#80+18,d1
	jsr	Display_Small_String_Skip

*find out fast and chip for interest

	move.l	EXEC,a6
	move.l	#MEM_CHIP,d1	;chip
	jsr	-$d8(a6)	;avail mem
	move.l	d0,chip_free

	move.l	EXEC,a6
	move.l	#MEM_FAST,d1	;chip
	jsr	-$d8(a6)	;avail mem
	move.l	d0,fast_free

	move.l	#$dff000,a6	;reset

*hehe ready for some tacky code...
	clr.w	d7
	move.l	chip_free,score
	move.l	#free_mem_string+25,a5	
	jsr	Convert_Score_To_String
	move.l	fast_free,score
	move.l	#free_mem_string+8,a5	
	jsr	Convert_Score_To_String
	
	move.l	memory_base,a3
	move.l	#free_mem_string,a4
	move.w	#230,d0
	move.w	#80+27,d1
	jsr	Display_Small_String_Skip
	rts
	
chip_free	dc.l	0
fast_free	dc.l	0
chip_type	dc.w	0	

free_mem_string
	dc.b	"FAST : 00000000  CHIP : 00000000",0
	even
chip_type_string1
	dc.b	"SYSTEM TYPE : 1000, 500, 500+ or 600",0
	even
chip_type_string2
	dc.b	"SYSTEM TYPE : 1200 OR BETTER",0
	even
	
music_string1
	dc.b	"IN GAME MUSIC : OPTIONAL ( DEFAULT ON )",0
	even
music_string2
	dc.b	"IN GAME MUSIC : NONE",0
	even
xfx_string1
	dc.b	"EXTRA SOUND FX : NO",0
	even
xfx_string2
	dc.b	"EXTRA SOUND FX : YES",0
	even

******************************************
*****           STOP_SYSTEM          *****
******************************************
Stop_System
	movem.l	a0-a6/d0-d7,-(sp)
Ensure_Blit_Fin
	btst	#14,dmaconr+$dff000
	bne.s	Ensure_Blit_Fin
	move.l	EXEC,a6
	jsr	-132(A6)		;DISABLE tasking	
	movem.l	(sp)+,a0-a6/d0-d7
	rts

******************************************
*****     ALLOCATE_GAME_MEMORY       *****
******************************************
Allocate_Game_Memory	

	move.l	EXEC,a6
	move.l	#GAME_MEMORY,d0	
	move.l	#MEM_CHIP+MEM_CLEAR,d1	;chip and clear
	jsr	-198(a6)		;try
	tst.l	d0
	bne	allocated_mem
	rts			;otherwise quit
allocated_mem
	move.l	d0,Memory_Base
	add.l	#OVERSCROLL_OFFSET*BPR,d0
	move.l	d0,Plane1
	move.l	d0,resetp1
	move.l	d0,scroll_area
	add.l	#SINGLE_PLANE*4,d0
	move.l	d0,scroll_buff_area
	move.l	d0,buff_plane1
	move.l	d0,resetp2
	add.l	#SINGLE_PLANE*4,d0
	move.l	d0,copyback_area

	move.l	EXEC,a6
	move.l	#FAST_MEM_MEMORY,d0	
	move.l	#MEM_PUBLIC+MEM_CLEAR,d1	;chip and clear
	jsr	-198(a6)		;try
	tst.l	d0
	bne	allocated_fast_mem
	rts			;otherwise quit
allocated_fast_mem
	move.l	d0,Fast_Memory_Base
	move.l	d0,buffer_map_memory
	add.l	#(BIGGEST_MAP_X*BIGGEST_MAP_Y)*MAP_BLOCK_SIZE,d0
	move.l	d0,buffer_alien_memory
	add.l	#(BIGGEST_MAP_X*BIGGEST_MAP_Y),d0
	move.l	d0,copy_store_area
	add.l	#COPY_STORE,d0
	move.l	d0,background_block_graphics
	add.l	#BLOCKS_MEMORY,d0
	move.l	d0,loader_pic_data

	rts


******************************************
*****     SETUP_SYSTEM               *****
******************************************
Setup_System


	LEA	CUSTOM,A6
	bsr	Sync
	MOVE.W	#0,BPLCON1(A6)
	move.w	#$83a0,DMACON(a6)
	move.w	#$000f,DMACON(a6)
	
	MOVE.L	#COPPERL,COP1LCH(A6)
	MOVE.W	COPJMP1(A6),D0

	rts

******************************************
*****     SETUP_INT                  *****
******************************************
Setup_Int
	move.l	$6c,oldint
	move.l	#darkint,$6c	
	rts


*********************************************
*****         RELEASE_SYSTEM            *****
*********************************************
Release_System
	movem.l	a0-a6/d0-d7,-(sp)
	
Ensure_Release_Blit_Fin
	btst	#14,dmaconr+$dff000
	bne.s	Ensure_Release_Blit_Fin
	
	MOVE.L	EXEC,A6
	JSR	-138(A6)		;ENABLE tasking
	movem.l	(sp)+,a0-a6/d0-d7
	rts
	
Fast_Memory_Base
	dc.l	0	
*********************************************
*****        Replace_System             *****
*********************************************
Replace_System	
	move.l	oldint,$6c
	move.w	#$000f,dmacon(a6)
	move.w  #$8000+BIT_PLANE_DMA,dmacon(a6)
	move.l	EXEC,a6
	move.l	#GAME_MEMORY,d0
	move.l	Memory_Base,a1
	jsr	-210(a6)
	
	move.l	EXEC,a6
	move.l	#FAST_MEM_MEMORY,d0
	move.l	Fast_Memory_Base,a1
	jsr	-210(a6)

	tst.l	in_game_music
	beq.s	no_music_mem_allocated
	move.l	EXEC,a6
	move.l	#IN_GAME_MUSIC_BUFFER,d0
	move.l	in_game_music,a1
	jsr	-210(a6)	; free only if allocated
no_music_mem_allocated	

	move.l	EXEC,a6
	move.l	Sound_Fx_Buffer_Size,d0
	move.l	sfx_mem,a1
	jsr	-210(a6)	; free only if allocated
no_xtra_fx_allocated	


	MOVE.L	#graf_NAME,A1
	MOVEQ	#0,D0
	JSR	-552(A6)		;OPEN GRAPHICS LIBRARY
	MOVE.L	D0,a4

	MOVE.W	#$8020,DMACON+$dff000	; sprites back
	
	move.l	38(a4),$dff080
	clr.w	$dff088
	move.b	#$9b,$bfed01

	rts
graf_NAME	dc.b	"graphics.library",0
	even

	

******************************************
*****     SETUP_COLOURS              *****
******************************************

setup_colours
	
	rts
	
******************************************
*****     INSERT_COLOURS             *****
******************************************
Insert_Colours	
	move.w	#$180,d0
	move.w	#16-1,d1
col_loop
	move.w	d0,(a0)+
	move.w	(a1)+,(a0)+
	add.w	#$2,d0
	dbra	d1,col_loop
	rts

******************************************
*****     INSERT_32COLOURS           *****
******************************************
Insert_32Colours	
	move.w	#$180,d0
	move.w	#32-1,d1
col_loop32
	move.w	d0,(a0)+
	move.w	(a1)+,(a0)+
	add.w	#$2,d0
	dbra	d1,col_loop32
	rts

******************************************
*****     INSERT_SPRITE_COLOURS      *****
******************************************
Insert_Sprite_Colours	
	move.w	#$1A0,d0
	move.w	#16-1,d1
sp_col_loop
	move.w	d0,(a0)+
	move.w	(a1)+,(a0)+
	add.w	#$2,d0
	dbra	d1,sp_col_loop
	rts

******************************************
*****       LOAD GAME BASICS         *****
******************************************
Load_Game_Basics

	bsr	release_system
	
	jsr	Construct_Map_Pages	
	jsr	Load_Loader_Pic
	jsr	Load_Sound_Effects
	move.w	#1,FadeAfterLoading
		
	bsr	stop_system


	rts



background_block_graphics	dc.l	0