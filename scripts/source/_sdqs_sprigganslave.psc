Scriptname _SDQS_sprigganslave extends Quest Conditional

Import Utility

_SDQS_snp Property snp Auto
_SDQS_functions Property funct  Auto

GlobalVariable Property _SDGVP_positions  Auto  
GlobalVariable Property _SDGVP_poses  Auto  
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property _SDGVP_spriggan_comment Auto
GlobalVariable Property _SDGVP_spriggan_secret  Auto  
GlobalVariable[] Property _SDGVP_config  Auto 

Spell Property _SDSP_cum  Auto
Sound Property _SDSMP_spriggananger  Auto  

ReferenceAlias Property _SDRAP_spriggan  Auto  
ReferenceAlias Property _SDRAP_host  Auto  
ReferenceAlias Property _SDRAP_marker  Auto  
ReferenceAlias Property _SDRAP_sprigganbook  Auto  

ActorBase Property _SDABP_sprigganhost  Auto
FormList Property _SDFLP_allied  Auto
FormList Property _SDFLP_slaver  Auto
Keyword Property _SDKP_sex  Auto  

Spell Property _SDSP_host_flare  Auto
Cell Property _SDLP_dream  Auto  

Bool Property bQuestActive = False Auto Conditional
Float Property fSprigganPower = 0.0625 Auto Conditional
VisualEffect Property SprigganFX  Auto  

SexLabFramework Property SexLab  Auto  
Float fDaysEnslaved
; when the player reaches the spriggan grove
Float fDaysUpdate
Float fTimeElapsed
Float fSprigganPunish
ObjectReference kRef1
ObjectReference kRef2
Bool bAllyToActor
int randomVar

float fNext = 0.0
float fNextAllowed = 0.02

Function Commented()
	fNext = GameDaysPassed.GetValue() + fNextAllowed + Utility.RandomFloat( 0.125, 0.25 )
	_SDGVP_spriggan_comment.SetValue( fNext )
EndFunction

Function CommentTrigger()
	If ( Self.GetStage() == 10 && _SDGVP_spriggan_secret.GetValue() == 0 )
		( _SDRAP_sprigganbook.GetReference() as ObjectReference ).EnableNoWait()
		 Self.SetStage( 20 )
		 Self.SetObjectiveDisplayed( 20 )
	EndIf
EndFunction


; ObjectReference akRef1 = master
; ObjectReference akRef2 = slave
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
	bAllyToActor = funct.allyToActor( akRef1 as Actor, akRef2 as Actor, _SDFLP_slaver, _SDFLP_allied )
	If ( !bQuestActive && bAllyToActor )
		bQuestActive = True
		If ( _SDGVP_config[0].GetValue() )
		;	( akRef2 as Actor ).GetActorBase().SetEssential( False )
		EndIf
		
		kRef2 = akRef2 ; player
		_SDGVP_sprigganEnslaved.SetValue(1)

		fDaysEnslaved = GetCurrentGameTime()
		fSprigganPunish = -1.0
		; funct.actorCombatShutdown( akRef1 as Actor )
		; funct.actorCombatShutdown( akRef2 as Actor )

		If ( _SDGVP_config[3].GetValue() as Bool )
			funct.limitedRemoveAllItems ( kRef2, _SD_sprigganHusk, True, _SDFLP_ignore_items )
		Else
			; kSlave.RemoveAllItems(akTransferTo = kMaster, abKeepOwnership = True)
			kRef2.RemoveAllItems(akTransferTo = _SD_sprigganHusk, abKeepOwnership = True)

			; Testing use of limitedRemove for all cases to allow for detection of Devious Devices, SoS underwear and other exceptions
			; funct.limitedRemoveAllItems ( kSlave, kMaster, True )

		EndIf

		akRef1.Disable()
		kRef1 = akRef1.placeAtMe( _SDABP_sprigganhost )
		akRef1.RemoveAllItems(akTransferTo = kRef1)
		akRef1.Delete()

		_SDRAP_spriggan.ForceRefTo( kRef1 )
				
		( kRef1 as Actor ).RestoreAV("health", ( kRef1 as Actor ).GetBaseAV("health") )
		( kRef2 as Actor ).RestoreAV("health", ( kRef2 as Actor ).GetBaseAV("health") )

		; For SexLab Hormones compatibiltiy... should not have any effect if it isn't installed
		Int iSprigganSkinColor = Math.LeftShift(255, 24) + Math.LeftShift(196, 16) + Math.LeftShift(238, 8) + 218
		StorageUtil.SetIntValue(none, "_SLH_iSkinColor", iSprigganSkinColor ) 
		StorageUtil.SetFloatValue(none, "_SLH_fBreast", 0.8 ) 
		StorageUtil.SetFloatValue(none, "_SLH_fWeight", 20.0 ) 
		StorageUtil.SetIntValue(none, "_SLH_iForcedRefresh", 1)
			

		_SDKP_sex.SendStoryEvent( akRef1 = kRef1, akRef2 = kRef2, aiValue1 = 2, aiValue2 = RandomInt( 0, _SDGVP_positions.GetValueInt() ) )
		;_SDKP_sex.SendStoryEvent( akRef1 = kRef1, akRef2 = kRef2, aiValue1 = 2, aiValue2 = 6 )

		If ( Self )
			RegisterForSingleUpdateGameTime( 0.125 )
			RegisterForSingleUpdate( 0.1 )
		EndIf
	Else
		Debug.Trace("_SD:: Spriggan slave fail to start: bQuestActive=" + bQuestActive + " bAllyToActor=" + bAllyToActor)
	EndIf
EndEvent

Event OnUpdateGameTime()
	; Debug.Notification( "[Spriggan slave loop] kRef2 = " + kRef2)

	If (!kRef2)
		Return
	EndIf
	
	While ( !kRef2.Is3DLoaded() )
	EndWhile

	; Debug.Notification( "[Spriggan slave loop] kRef2 = Loaded " )

	fTimeElapsed = GetCurrentGameTime() - fDaysEnslaved
	fSprigganPunish = funct.floatWithinRange( fTimeElapsed, 2.5, 80.0 )
	
	If ( fTimeElapsed < 120.0 )
		fSprigganPower = funct.floatLinearInterpolation( 0.0625, 1.0, 0.0, fTimeElapsed, 120.0 )
	Else
		fSprigganPower = 1.0
	EndIf

	; Debug.Notification( "[Spriggan slave loop] fTimeElapsed = " + fTimeElapsed)       ; 4
	; Debug.Notification( "[Spriggan slave loop] fSprigganPunish = " + fSprigganPunish) ; 4
	; Debug.Notification( "[Spriggan slave loop] fSprigganPower = " + fSprigganPower)   ; 0.09

    randomVar = RandomInt( 0, 100 ) 

    If (!( kRef2 as Actor ).IsInCombat() && !( kRef2 as Actor ).GetDialogueTarget() ) ; !( kRef2 as Actor ).GetCurrentScene() && 
        ; Debug.Notification( randomVar )
		If (randomVar >= 98 ) &&  (SexLab.ValidateActor(kRef2 as Actor) > 0) 
			_SDSP_host_flare.RemoteCast(kRef2 as Actor, kRef2 as Actor, kRef2 as Actor)
			Debug.Notification( "Tendrils are digging deeper under your skin..." )

			SprigganFX.Play( kRef2, 60 )
			Utility.Wait(1.0)
			
			; HACK: select rough sexlab animations 
			; sslBaseAnimation[] animations = SexLab.GetAnimationsByTags(1,  "Masturbation,Female","Estrus,Dwemer")

			; HACK: get actors for sexlab
			; actor[] sexActors = new actor[1]
			; sexActors[0] = kRef2 as Actor

			; HACK: start sexlab animation
			; SexLab.StartSex(sexActors, animations)

			sslThreadModel Thread = SexLab.NewThread()
			Thread.AddActor(SexLab.PlayerRef, true) ; // IsVictim = true
			Thread.SetAnimations(SexLab.GetAnimationsByTags(1, "Solo,F","Estrus,Dwemer"))
			Thread.StartThread()

		ElseIf (randomVar >= 90 )
			; _SDSP_host_flare.RemoteCast(kRef2 as Actor, kRef2 as Actor, kRef2 as Actor)
			Debug.Notification( "Sap is slowly pumping into your veins.." )

			SprigganFX.Play( kRef2, 30 )
		ElseIf (randomVar >= 80 )
			Debug.Notification( "Sweet sap runs down your legs..." )

			SexLab.ApplyCum(kRef2 as Actor, 1)
		EndIf
	Else
		; Debug.Notification( "[Spriggan slave loop] Player is busy: " + SexLab.ValidateActor(kRef2 as Actor) )       
	EndIf

	; random punishment events
	If( RandomFloat(0.0, 100.0) < fSprigganPunish && GetStage() < 70 && !( kRef2 as Actor ).GetCurrentScene() && !( kRef2 as Actor ).IsInCombat() && !( kRef2 as Actor ).GetDialogueTarget() )
		; _SDSP_host_flare.RemoteCast(kRef2 as Actor, kRef2 as Actor, kRef2 as Actor)
		Debug.Notification( "The roots throb deeply in and out of you..." )

		Int iSprigganSkinColor = Math.LeftShift(255, 24) + Math.LeftShift(133, 16) + Math.LeftShift(184, 8) + 160
		StorageUtil.SetIntValue(none, "_SLH_iSkinColor", iSprigganSkinColor ) 
		StorageUtil.SetFloatValue(none, "_SLH_fBreast", Utility.RandomFloat(0.8, 1.4) ) 
		StorageUtil.SetFloatValue(none, "_SLH_fBelly", Utility.RandomFloat(0.8, 2.0) ) 
		StorageUtil.SetFloatValue(none, "_SLH_fWeight", Utility.RandomFloat(0.0, 50.0) ) 
		StorageUtil.SetIntValue(none, "_SLH_iForcedRefresh", 1)

		SprigganFX.Play( kRef2, 30 )
		_SDSMP_spriggananger.play( kRef2 )
		_SDKP_sex.SendStoryEvent( akRef1 = kRef1, akRef2 = kRef2, aiValue1 = 8, aiValue2 = RandomInt( 0, _SDGVP_poses.GetValueInt() ) )
    EndIf
	; Initial stage
	If (GetStage() == 0)
		self.SetStage( 10 )
	EndIf
	
	; ends the punishment period after arriving at the grove
	If ( GetCurrentGameTime() - fDaysUpdate > fSprigganPower && GetStage() == 70 )
		While ( kRef1.GetCurrentScene() || kRef2.GetCurrentScene() )
		EndWhile
		fDaysUpdate = GetCurrentGameTime()
		SetStage( 80 )
	EndIf
	
	; keep spriggans friendly for a while to let the player move away
	If ( GetCurrentGameTime() - fDaysUpdate > 0.25 && GetStage() == 80 )
		While ( kRef1.GetCurrentScene() || kRef2.GetCurrentScene() )
		EndWhile
		SetStage( 90 )
	EndIf
	If ( Self )
		RegisterForSingleUpdateGameTime( 0.25 )
	EndIf
EndEvent

Event OnUpdate()
	if (kRef2)
		While ( !kRef2.Is3DLoaded() )
		EndWhile

		ObjectReference marker = _SDRAP_marker.GetReference() as ObjectReference
		If ( marker && kRef2.GetDistance( marker ) < 500.0 && GetStage() == 60 )
			fDaysUpdate = GetCurrentGameTime()
			SetObjectiveCompleted( 60 )
			self.SetStage( 70 )
		ElseIf ( !kRef1.GetCurrentScene() && !kRef2.GetCurrentScene() && GetStage() == 70 )
			While ( kRef1.GetCurrentScene() || kRef2.GetCurrentScene() )
			EndWhile
			Wait( 10.0 )
			; _SDKP_sex.SendStoryEvent( akRef1 = kRef1, akRef2 = kRef2, aiValue1 = 0, aiValue2 = RandomInt( 0, _SDGVP_positions.GetValueInt() ) )
		EndIf
	EndIf

	If ( Self )
		RegisterForSingleUpdate( 0.1 )
	EndIf
EndEvent

GlobalVariable Property _SDGVP_sprigganEnslaved  Auto  

ObjectReference Property _SD_sprigganHusk  Auto  
FormList Property _SDFLP_ignore_items  Auto
