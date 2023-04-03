;Script by Xampa5 / Core#1460
;uses AHK 1.1

;IN-GAME KEYBINDS - edit those so they match with your in-game keybind. Check https://www.autohotkey.com/docs/v1/KeyList.htm if you're unsure of the name of a key
abilityOne := "1"
abilityFour := ;You have to manually edit the hotkey line 190 if you're using an other key than '4' for ability 4
operatorTransference := "5"
sprint := "Shift"
sliding := "Ctrl"
jump := "space" 
melee := "e" 


;TIMERS - edit to match your ability duration on khora / Vazarin Sling level
khoraCageDuration := 45  -5  ;how long in seconds will your cage last minus how many seconds before expiry do you want to be warned
vazarinSlingDuration := 5  -1.9  ;max rank is 5s. 


;SCRIPT KEYBINDS:
;Mouse wheel up: Bullet Jump
;F10: Toggle Khora mode ON/OFF
;	Mouse wheel down: Vazarin Sling; will play a sound to recall you to refresh it (with Khora mode)
;	4: Will play a sound to recall you to refresh cage (with Khora mode)
;Shit+Alt+E or F9: Melee spam E
;	E: Cancels melee spam
;F1: Zenurik Springwell (need to be host for it to work on the 1st try, thanks Warframe)

; _ _ _ _ _ _ 


#SingleInstance force
SendMode Event
busy := 0
meleeSpam :=0
abilityCount :=0
vazarinTimer :=0
khoraCageTimer := 0

warframeMode:= 0
; 0 - None
; 1 - Vazarin Khora
warframeCount := 1


SoundPlay, mixkit-correct-answer-tone-2870.wav ;relative path from the script file, add C:\Users\YourNameHere\Documents\ in front for an absolute path

Loop{ ;Events, PLAY SOUND
	global vazarinTimer
	global khoraCageTimer
	
	loopDelay := 2000
	
	;That shit below is ugly and will spaghettify exponentially the more cooldowns you track, but that's what you get when coding without sleep
	;TODO: Use array and sorting instead, I've happily saved myself from ever looking at how AHK decided to handle array so far
	
	;A_TickCount is the number of miliseconds since the script started
	
	if(vazarinTimer>0&&(khoraCageTimer==0||vazarinTimer<khoraCageTimer)){ ;If next timer to expire is this abilityOne (vazarin sling)
		if(vazarinTimer-A_TickCount<loopDelay){
			Sleep, vazarinTimer-A_TickCount
			if(vazarinTimer < A_TickCount+50){			
				SoundPlay, mixkit-message-pop-alert-2354.mp3
				vazarinTimer := 0
			}
		}
	}
	if(khoraCageTimer >0&&(vazarinTimer==0||khoraCageTimer<vazarinTimer)){ ;If next timer to expire is this abilityOne (cage)
		if(khoraCageTimer-A_TickCount<loopDelay){
			Sleep, khoraCageTimer-A_TickCount
			if(khoraCageTimer < A_TickCount+50){			
				SoundPlay, mixkit-elevator-tone-2863EDITED.wav
				khoraCageTimer := 0
			}
		}
		
	}	
	Sleep, loopDelay
}


~e:: ;CANCEL MELEE SPAM
~+e::
	meleeSpam :=0
return

#ifWinActive, ahk_exe Warframe.x64.exe ;Hotkeys below will only trigger if Warframe is the active window
; * means run with any modifier key
; + is shit, ! is alt, ^ is ctrl
; ~ will let the original input pass throught (so ~e:: will execute the hotkey AND type out 'e')

*F10::	;WARFRAME MODE SWAP	
	global warframeMode  
	global warframeCount
	
	warframeMode := warframeMode +1
	if(warframeMode > warframeCount){
		warframeMode := 0
	}
	Switch warframeMode{
			case 0:
				Progress, B Y50 ZH0 CW000000 CT808080, Khora mode OFF
			case 1:			
				Progress, B Y50 ZH0 CW000000 CT3CB043, Khora mode ON
	}
	
	Sleep, 350 
	Progress, OFF
return

*F1:: ;SPRING WELL ZENURIK, need to be host for it to work on the 1st time on new map
	global busy
	if(busy){
		return
	}
	
	Send, {Blind}%operatorTransference%  ;the {Blind} in front of the tells AHK to ignore the current modifier keys state, otherwise I think it tends to sends unwanted phantom shift or alt inputs. stolen from Zaw PT script
	Sleep, 150	
	Send, {Blind}%abilityOne%
	Sleep, 350
	Send, {Blind}%operatorTransference%
	busy := 0
	
	Sleep, 400
	if GetKeyState("F1","p") {		
		Send, {Blind}F1	
	}
return

*F8:: Reload 

~*WheelUp:: ;BULLET JUMP
	global busy	
	if(busy){
		return
	}
	busy := 1
	
	if(meleeSpam){
		Sleep, 500 ;extra delay when melee spamming to let the current melee animation finish
	}

	Send, {Blind}{%sprint% down} ;this key is never released, I also use that bullet jump hotkey as my hold down run trigger. idk I'm weird
	Send, {Blind}{%sliding% down}
	Sleep, 110
	Send, {Blind}{%jump%}
	Sleep, 100
	Send, {Blind}{%sliding% up}
	Sleep, 450

	busy := 0
return

~*LWin::
~*RWin::
~+!TAB::
~*t::
	Send, {Blind}{%sprint% up} ;release Shift when opening chat, alt tabbing, pressing Windows key
return

~*WheelDown:: ;VAZARIN SLING
	global busy
	global vazarinSlingDuration
	global vazarinTimer
	
	if(busy || warframeMode !=1){
		return
	}
	busy := 1
	
	Send, {Blind}{%sprint% up}
	Send, {Blind}%operatorTransference%
	Send, {Blind}{s down}
	Sleep, 150
	Send, {Blind}{%jump%}
	Sleep, 40 ;delays between inputs were only tested at 75FPS, could need edits
	Send, {Blind}{%sliding% down}
	Sleep, 40
	Send, {Blind}{%jump%}
	vazarinTimer := A_TickCount + vazarinSlingDuration*1000
	Send, {Blind}{s up}		
	Sleep, 40
	Send, {Blind}{%sliding% up}				
	Sleep, 100			
	;Send, {Blind}{%melee%} ;melee to exit operator mode is faster if you got a decent melee attack speed 
	Send, {Blind}%operatorTransference% 
	Sleep, 500
	Send, {Blind}{%sprint% down}			

	busy := 0
return

;~'::   ;remove the first ';' if you're using an AZERTY keyboard
~4:: 
	global warframeMode
	global khoraCageDuration
	global khoraCageTimer
	
	if(warframeMode == 1){ ;Khora's cage	
		khoraCageTimer := A_TickCount + khoraCageDuration*1000 
	}
return



	
~*F9:: ;Nekros melee spam - won't work if Warframe is not the foreground window, didn't felt like fiddling with CtrlSendInput and test how Wf reacts to it (yet)
+!e:: ;Shift+Alt+E
	global meleeSpam
	if (meleeSpam){
		return
	}
	meleeSpam :=1
	
	while (meleeSpam){		
		while GetKeyState("Shift","p"){ ;not sure if that part is useful
			Sleep, 50
		}
		if(!GetKeyState("Alt","p")&&!busy){	 ;I got noidea why but alt fucks things up 
			Send, {Blind}{%melee%}	
		}			
		Random, randomDelay, 100, 150  ;idk how fast you need to spam to fully use stacked up Berserker Fury + Arcane Strike + eventual Riven AS, this is likely fast enough tho
		Sleep, randomDelay
	}
return
