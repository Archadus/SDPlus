Scriptname _SD_Reset extends Quest  

Quest Property _SD_arrested Auto
Quest Property _SD_bountyslave  Auto
Quest Property _SD_controller  Auto
Quest Property _SD_crime  Auto
Quest Property _SD_dream  Auto
Quest Property _SD_dream_destinations  Auto
Quest Property _SD_enslavement  Auto
Quest Property _SD_enslavement_tasks  Auto
Quest Property _SD_mcm_001  Auto
Quest Property _SD_naked  Auto
Quest Property _SD_snp  Auto
Quest Property _SD_sprigganslave  Auto
Quest Property _SD_thugslave  Auto
Quest Property _SD_watcher  Auto
Quest Property _SD_whore  Auto
GlobalVariable Property _SDGVP_enslaved Auto
GlobalVariable Property _SDGVP_naked_rape_delay Auto
GlobalVariable Property GameDaysPassed Auto
ReferenceAlias Property Alias__SDRA_master  Auto

Float fVersion = 0.0

Event OnInit()
	_doInit()
	RegisterForSingleUpdate(5)
EndEvent

Function _doInit()
;

EndFunction

Function Maintenance()

	; UnregisterForAllModEvents()
	; Debug.Trace("Reset SexLab events")
	; RegisterForModEvent("AnimationStart", "OnSexLabStart")
	; RegisterForModEvent("AnimationEnd",   "OnSexLabEnd")

	If fVersion < 2.0 ; <--- Edit this value when updating
		fVersion = 2.0 ; and this
		Debug.Notification("Updating to SD+ version: " + fVersion)
		; Update Code

		Float fNext = GameDaysPassed.GetValue() + Utility.RandomFloat( 0.125, 0.25 )
		_SDGVP_naked_rape_delay.SetValue( fNext )
		_SDGVP_naked_rape_chance.SetValue(25.0)

		If ( _SD_dream_destinations.IsRunning() )
			_SD_dream_destinations.Stop()
		EndIf

		If ( _SD_snp.IsRunning() )
			_SD_snp.Stop()
		EndIf

		; Maintenance code scaffold for now - not in use.
		; Find better way to restart these quests safely

		If ( _SD_enslavement_tasks.IsRunning() )
			; Debug.Notification("Shutting down Enslavement Tasks Quest" )
			; _SD_enslavement_tasks.SetStage(1000)
		EndIf

		If ( _SD_enslavement.IsRunning() )
			; Debug.Notification("Shutting down Enslavement Quest" )

			; Disabled for now
			; - Sets slave faction to 0 in loop
			; - Breaks enslavement

			; _SD_enslavement.SetStage(100)
		EndIf

		If ( _SD_dream.GetStage() > 0 )
			; Debug.Notification("Restarting Dream  Quest" )

			; Disabled for now
			; - Instantly brings player to dreamworld
			; - NPCs victims are messed up (two idle overlap)

			; _SD_dream.SetStage(999)
			Utility.Wait(2.0)
			;_SD_dream.Stop()
		EndIf

	EndIf

	Actor master = Alias__SDRA_master.GetReference() as Actor
	; Debug.Notification("Master:" + master.GetName() + " - Dead: " +  master.IsDead())
	If (master)
		If ( _SD_enslavement.GetStage() < 90 )  &&  (master.IsDead() )
			; Debug.Notification("Master is dead." )

			If ( _SDGVP_enslaved.GetValue() == 1)
				Debug.Notification("You are still enslaved." )
				Debug.Notification("Shutting down Enslavement Quest" )
				_SDGVP_enslaved.SetValue(0)
				_SD_enslavement.SetStage(100)
			EndIf
		EndIf
	EndIf
EndFunction


Event OnUpdate()
;
EndEvent


GlobalVariable Property _SDGVP_naked_rape_chance  Auto  