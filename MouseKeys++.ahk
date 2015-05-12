;-------------------------------------------------------------------------------
; MouseKeys++
; A Mouse Replacement for single finger use
;-------------------------------------------------------------------------------
; AutoHotkey Version: 1.1.x
; Author:		Benedikt Schneyer (and Phil Iovino)

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Only one instance at a time
#Persistent

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2 ; partial match
CoordMode Mouse, Screen

;; prevent all natural actions of the keys
#UseHook
#InstallKeybdHook

;; ***************
;; global settings
;; ***************

;; Basic MoveSpeed in pixel per Second
mouseMoveSpeed := 1

;; time between movements in milliseconds
mouseMoveInterval := 15

;; version
VERSION := "0.6.5.0"

;; name of the config file
configFile := "settings.ini"

;; ***********
;; init config
;; ***********

;; possible actions and their default keys
actions := {"Click":"NumpadClear","Doubleclick":"NumpadAdd","Right":"NumpadRight","UpRight":"NumpadPgUp","Up":"NumpadUp","UpLeft":"NumpadHome","Left":"NumpadLeft","DownLeft":"NumpadEnd","Down":"NumpadDown","DownRight":"NumpadPgDn","Rightclick":"NumpadSub","WheelUp":"PgUp","WheelDown":"PgDn","ToggleEnable":"Pause","DragLeft":"NumpadIns","DragMiddle":"[ none ]","DragRight":"[ none ]"}

;; load keys
Hotkey, IfWinNotActive, MouseKeys++ - enter key
For action, default in actions
{
	IniRead, Hotkey%action%, %configFile%, Keys, %action% , %default%
	if (Hotkey%action% != "[ none ]")
		Hotkey, % "*" . Hotkey%action%, Action%action%
}
Hotkey, IfWinNotActive

;; load general settings
IniRead, TrayBalloon, %configFile%, General, BalloonTip , 0
IniRead, PlaySound, %configFile%, General, PlaySound , 0
IniRead, AsAdmin, %configFile%, General, AsAdmin , 0
IniRead, Autostart, %configFile%, General, Autostart , 0


;; ************
;; run as admin
;; ************

if (AsAdmin && not A_IsAdmin)
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}


;; load speed settings
IniRead, mouseDoubleclickSpeed, %configFile%, Speed, mouseDoubleclickSpeed , 55
IniRead, mouseMoveSpeedMax, %configFile%, Speed, mouseMoveSpeedMax , 1000
IniRead, mouseMoveAcceleration, %configFile%, Speed, mouseMoveAcceleration , 1000
IniRead, mouseMoveAccelerationDelay, %configFile%, Speed, mouseMoveAccelerationDelay , 0.5
IniRead, scrollSpeed, %configFile%, Speed, ScrollSpeed , 400

;; *************
;; install Files
;; *************

FileCreateDir, files

FileInstall, files\mouse.gif, files\mouse.gif
FileInstall, files\enabled.wav, files\enabled.wav
FileInstall, files\mousekeys++.ico, files\mousekeys++.ico
FileInstall, files\disabled.wav, files\disabled.wav

;; *********
;; Tray menu
;; *********

trayEnabledLabel := "&Enabled (E)"
traySettingsLabel := "&Settings (S)"
trayInfoLabel := "&Info (I)"
trayExitLabel := "&Exit (X)"

;; remove standard Menu items
Menu, Tray, NoStandard
;; add new ones
Menu, Tray, Add , %trayEnabledLabel%, ActionToggleEnable
Menu, Tray, Check , %trayEnabledLabel%
Menu, Tray, Add
Menu, Tray, Add , %traySettingsLabel%, ShowSettingsGUI
Menu, Tray, Add , %trayInfoLabel%, ShowInfo
Menu, Tray, Add
Menu, Tray, Add , %trayExitLabel%, ExitSub
Menu, Tray, Tip , MouseKeys++`nActive
Menu, Tray, Default , %trayEnabledLabel%
Menu, Tray, Icon, mousekeys++.ico,,1

;; ***
;; GUI
;; ***

;; Mouse keys
Gui, settings:Add, Picture, x238 y20 w200 h-1 , mouse.gif
Gui, settings:Add, Button, x260 y60 w50 h50 gOpenSetKey vSetKeyClick, %HotkeyClick%
Gui, settings:Add, Button, x360 y60 w50 h50 gOpenSetKey vSetKeyRightclick, %HotkeyRightclick%

Gui, settings:Add, Button, x310 y20 w50 h30 gOpenSetKey vSetKeyWheelUp, %HotkeyWheelUp%
Gui, settings:Add, Button, x310 y120 w50 h30 gOpenSetKey vSetKeyWheelDown, %HotkeyWheelDown%

Gui, settings:Add, Button, x250 y160 w50 h50 gOpenSetKey vSetKeyUpLeft, %HotkeyUpLeft%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyUp, %HotkeyUp%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyUpRight, %HotkeyUpRight%
Gui, settings:Add, Button, xp-120 y+10 w50 h50 gOpenSetKey vSetKeyLeft, %HotkeyLeft%
Gui, settings:Add, Button, x+70 yp+0 w50 h50 gOpenSetKey vSetKeyRight, %HotkeyRight%
Gui, settings:Add, Button, xp-120 y+10 w50 h50 gOpenSetKey vSetKeyDownLeft, %HotkeyDownLeft%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyDown, %HotkeyDown%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyDownRight, %HotkeyDownRight%

;; other keys
Gui, settings:Add, GroupBox, x460 y20 w250 h145 , Keys
Gui, settings:Add, Text, xp+10 yp+20 w120 h20 , Activation Key:
Gui, settings:Add, Text, y+5 w120 h20 , Double-Click Key:
Gui, settings:Add, Text, y+5 w120 h20 , Left Drag:
Gui, settings:Add, Text, y+5 w120 h20 , Right Drag:
Gui, settings:Add, Text, y+5 w120 h20 , Middle Drag:
Gui, settings:Add, Button, xp+110 yp-105 w100 h20 gOpenSetKey vSetkeyToggleEnable, %HotkeyToggleEnable%
Gui, settings:Add, Button, y+5 w100 h20 gOpenSetKey vSetkeyDoubleclick, %HotkeyDoubleclick%
Gui, settings:Add, Button, y+5 w100 h20 gOpenSetKey vSetkeyDragLeft, %HotkeyDragLeft%
Gui, settings:Add, Button, y+5 w100 h20 gOpenSetKey vSetkeyDragRight, %HotkeyDragRight%
Gui, settings:Add, Button, y+5 w100 h20 gOpenSetKey vSetkeyDragMiddle, %HotkeyDragMiddle%

;; Speed settings
Gui, settings:Add, GroupBox, x460 y180 w250 h140 , Speed
Gui, settings:Add, Text, xp+10 yp+20 w140 h20 , Double-click Speed:
Gui, settings:Add, Text, y+5 w140 h20 , Maximum Speed:
Gui, settings:Add, Text, y+5 w140 h20 , Acceleration Speed:
Gui, settings:Add, Text, y+5 w140 h20 , Acceleration Delay:
Gui, settings:Add, Text, y+5 w140 h20 , Scroll Speed:
;Gui, settings:Add, Edit, xp+150 yp-105 w80 h20 gSpeedSettingsSubmit vMouseDoubleclickSpeed, %mouseDoubleclickSpeed%
;Gui, settings:Add, Edit, y+5 w80 h20 gSpeedSettingsSubmit vMouseMoveSpeedMax, %MouseMoveSpeedMax%
;Gui, settings:Add, Edit, y+5 w80 h20 gSpeedSettingsSubmit vMouseMoveAcceleration, %MouseMoveAcceleration%
;Gui, settings:Add, Edit, y+5 w80 h20 gSpeedSettingsSubmit vMouseMoveAccelerationDelay, %MouseMoveAccelerationDelay%
;Gui, settings:Add, Edit, y+5 w80 h20  gSpeedSettingsSubmit vScrollSpeed, %scrollSpeed%
Gui, settings:Add, slider, xp+140 yp-105 w100 h20 Range10-500 ToolTip Line5 gSpeedSettingsSubmit vMouseDoubleclickSpeed, %mouseDoubleclickSpeed%
Gui, settings:Add, slider, y+5 w100 h20 Range10-8000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveSpeedMax, %MouseMoveSpeedMax%
Gui, settings:Add, slider, y+5 w100 h20 Range0-8000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveAcceleration, %MouseMoveAcceleration%
Gui, settings:Add, slider, y+5 w100 h20 Range0-1000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveAccelerationDelay, %MouseMoveAccelerationDelay%
Gui, settings:Add, slider, y+5 w100 h20 Range1-100 ToolTip Line5  gSpeedSettingsSubmit vScrollSpeed, %scrollSpeed%

;; General Settings
Gui, settings:Add, GroupBox, x20 y20 w190 h120 , General Settings
Gui, settings:Add, CheckBox, xp+10 yp+20 h20 checked%TrayBalloon% gToggleTrayBalloon, Show Balloon Tip on Start/Stop
Gui, settings:Add, CheckBox, y+5 h20 checked%PlaySound% gTogglePlaySound, Play Sound on Start/Stop
Gui, settings:Add, CheckBox, y+5 h20 checked%asAdmin% gToggleAdmin, Run as Admin (recommended)
Gui, settings:Add, CheckBox, y+5 h20 checked%autostart% gToggleAutostart, Autostart MouseKeys++

Gui, settings:Add, Button, x20 y300 h20 gResetToDefault, Reset all settings


;; ********
;; Info GUI
;; ********

Gui, info:Add, Pic, w100 h-1 x10 y10, mousekeys++.ico
Gui, info:Font, s20,
Gui, info:Add, Text, x120 y20, MouseKeys++
Gui, info:Font,
Gui, info:Add, Text, , MouseKeys++ is a free and open source Windows program that emulates mouse movement from the keyboard. `nThe intended use is for those with physical disabilities who can't grasp, drag, nor click using a physical mouse.
Gui, info:Add, Text, x120, Author: Benedikt Schneyer
Gui, info:Add, Text, x500 yp+0, Version: %VERSION%
Gui, info:Add, Link, x120, Any Feedback? <a href="mailto:MouseKeys++@schneyer.com">Contact me</a>
Gui, info:Add, Link, x500 yp+0 , Like it? <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H6D2YMDPLV69S">Buy me a beer</a>
Gui, info:Add, link, x120, For more infos, updates and other stuff visit <a href="http://djquad.com/mousekeys-plus-plus">http://djquad.com/mousekeys/</a>.

return

;; ********
;; Settings
;; ********

SpeedSettingsSubmit:
	Gui, settings:submit, NoHide
	IniWrite, % %A_GuiControl%, %configFile%, Speed, %A_GuiControl%
return

OpenSetKey:
	action := SubStr(A_GuiControl, 7)
	Gui, settings:+disabled
	Gui, setKey:+Ownersettings
	Gui, setKey:Add, Text, x30 y20, Press key (Esc to remove)
	Gui, setkey:Add, Hotkey, vNewHotkey%action% gSetKeySubmit
	Gui, setkey:Add, Edit, hidden vNewHotkeyAction, %action%
	Gui, setkey:Show, center w200 h80, MouseKeys++ - enter key
return

SetKeySubmit:
	action := SubStr(A_GuiControl, 10)
	setHotkey(%A_GuiControl%,action)
	Gui, setkey:destroy
return

SetKeyGuiClose:
	Gui, settings:-disabled
	Gui, setkey:destroy
return

#IfWinActive, MouseKeys++ - enter key

ESC::
	Gui, setkey:submit
	action := SubStr(A_GuiControl, 10)
	setHotkey("[ none ]",NewHotkeyAction)
	Gui, setkey:destroy
return

#if

ToggleTrayBalloon:
	TrayBalloon := !TrayBalloon
	IniWrite, %TrayBalloon%, %configFile%, General, BalloonTip
return

TogglePlaySound:
	PlaySound := !PlaySound
	IniWrite, %PlaySound%, %configFile%, General, PlaySound
return

ToggleAutostart:
	Autostart := !Autostart
	IniWrite, %Autostart%, %configFile%, General, Autostart
	If (Autostart)
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\MouseKeys++.lnk , %A_WorkingDir%,, Improved MouseKeys tool ,%A_WorkingDir%\mousekeys++.ico
	Else
		FileDelete, %A_Startup%\MouseKeys++.lnk
return

ToggleAdmin:
	AsAdmin := !AsAdmin
	IniWrite, %AsAdmin%, %configFile%, General, AsAdmin
return

;; **************
;; Hotkey Actions
;; **************

ActionDownRight:
	moveMouse(1,1)
return

ActionDown:
	moveMouse(0,1)
return

ActionDownLeft:
	moveMouse(-1,1)
return

ActionLeft:
	moveMouse(-1,0)
return

ActionUpLeft:
	moveMouse(-1,-1)
return

ActionUp:
	moveMouse(0,-1)
return

ActionUpRight:
	moveMouse(1,-1)
return

ActionRight:
	moveMouse(1,0)
return

ActionDoubleclick:
	send % getActiveModifier() . "{click}"
	sleep %mouseDoubleclickSpeed%
	send % getActiveModifier() . "{click}"
return

ActionClick:
	send % getActiveModifier() . "{click}"
return

ActionRightclick:
	send % getActiveModifier() . "{click right}"
return

ActionWheelUp:
	moveWheel(1,scrollSpeed)
return

ActionWheelDown:
	moveWheel(-1,scrollSpeed)
return

ActionDragLeft:
	drag("L")
return

ActionDragMiddle:
	drag("M")
return

ActionDragRight:
	drag("R")
return

setHotkey(key, action)
{
	global
	;; get current hotkey for defined action

	Hotkey, IfWinNotActive, MouseKeys++ - enter key

	;; disable old hotkey, if it exists ( -> try)
	try {
		Hotkey, % "*" . Hotkey%action%, , Off
	}

	;; set new Hotkey
	if (key != "[ none ]")
	{
		;; update other GUI button with same Hotkey
		For unhotAction, default in actions
		{
			if (Hotkey%unhotAction% = key)
			{
				;GuiControl, settings: , SetKey%unhotAction%, [ none ]
				setHotkey("[ none ]", unhotAction)
				break
			}
		}

		Hotkey, % "*" . key, Action%action%, ON
	}
	Hotkey, IfWinNotActive

	;; update GUI
	GuiControl, settings: , SetKey%action%, %key%

	;; save in settings
	IniWrite, %key%, %configFile%, Keys, %action%

	;; save global
	Hotkey%action% := key


}

moveWheel(direction,scrollSpeed)
{
	Loop {
		wheelKey := getActiveButton()

		if (GetKeyState( wheelKey, "P" ))
		{
			Send % getActiveModifier() . "{" . (direction = 1 ? "WheelUp" : "WheelDown") . "}"
			Sleep 100 - scrollSpeed
		}
		else
			break
	}
}

moveMouse(x,y)
{
	global ; to get config

	;; get buttonname
	MovementButtonName := A_ThisHotkey
	StringReplace, MovementButtonName, MovementButtonName, *

	;; get current position
	MouseGetPos, xPos, yPos

	;; move one pixel instantly
	xPos += x
	yPos += y
	Loop {
		GetKeyState, keystate, %MovementButtonName%, P
		if (keystate = "U")
			break

		;; acceleration delay
		if ((A_Index * mouseMoveInterval) >= mouseMoveAccelerationDelay)
			moveAccel := ((A_Index * mouseMoveInterval) - mouseMoveAccelerationDelay) * (mouseMoveAcceleration / 1000)
		else
			moveAccel := 0

		;; max speed
		speed := (mouseMoveSpeed + moveAccel)
		if (speed > mouseMovespeedMax)
			speed := mouseMovespeedMax

		speed /= (1000 / mouseMoveInterval)

		xPos += x * speed
		yPos += y * speed

		;; i like to move it
		MouseMove, % Round(xPos) , % Round(yPos) , 2

		sleep %mouseMoveInterval%
	}
}

drag(key)
{
	If GetKeyState( key . "Button", "P" )
		d := "up"
	else
		d := "down"
	send % getActiveModifier() . "{click " . d . " " . key . "}"
}

;; return active modifier keys
getActiveModifier() {
	return GetKeyState( "Ctrl", "P" ) ? "^" : GetKeyState( "Alt", "P" ) ? "!" : GetKeyState( "Shift", "P" ) ? "+" : ""
}

;; get triggering button
getActiveButton()
{
	;; get buttonname
	trigger := A_ThisHotkey
	;; remove *
	StringReplace, trigger, trigger, *
	return %trigger%
}

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return

ResetToDefault:
	MsgBox, 1, , % "Do you want to reset all settings and restart?"
	IfMsgBox, OK
	{
		IniDelete, %configFile%, General
		IniDelete, %configFile%, Keys
		IniDelete, %configFile%, Speed
		reload
	}
return

ShowSettingsGUI:
	Gui, settings:Show, center autosize, MouseKeys++  Settings
return

ShowInfo:
	Gui, info:Show, center autosize, MouseKeys++ - Info
return

ActionToggleEnable:
	suspend
	Menu, Tray, ToggleCheck , %trayEnabledLabel%
	if (A_IsSuspended)
	{
		Menu, Tray, Tip , MouseKeys++`nsuspended
		if (TrayBalloon)
			TrayTip , MouseKeys++, suspended
		If (playSound)
			SoundPlay, enabled.wav
	} else
	{
		Menu, Tray, Tip , MouseKeys++`nactive
		if (TrayBalloon)
			TrayTip , MouseKeys++, activated
		If (playSound)
			SoundPlay, disabled.wav
	}
return

ExitSub:
ExitApp