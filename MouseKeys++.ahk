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
#InstallMouseHook

;; ***************
;; global settings
;; ***************

;; time between movements in milliseconds
mouseMoveInterval := 15

;; version
VERSION := "0.9.6.2"

;; name of the config file
configFile := "settings.ini"

;; mouseEvent codes
mouseEventLeftDown := 0x0002
mouseEventLeftUp := 0x0004
mouseEventRightDown := 0x0008
mouseEventRightUp := 0x0010
mouseEventMiddleDown := 0x0020
mouseEventMiddleUp := 0x0040

;; ***********
;; init config
;; ***********

;; possible actions and their default keys
actions := {"Click":"NumpadClear","Doubleclick":"NumpadAdd","Right":"NumpadRight","UpRight":"NumpadPgUp","Up":"NumpadUp","UpLeft":"NumpadHome","Left":"NumpadLeft","DownLeft":"NumpadEnd","Down":"NumpadDown","DownRight":"NumpadPgDn","Rightclick":"NumpadSub","WheelUp":"PgUp","WheelDown":"PgDn","ToggleEnable":"Pause","DragLeft":"NumpadIns","DragMiddle":"[ none ]","DragRight":"[ none ]","AltTab":"[ none ]","Middleclick":"[ none ]"}

;; load keys
Hotkey, IfWinNotActive, MouseKeys++ - enter key
For action, default in actions
{
	IniRead, Hotkey%action%, %configFile%, Keys, %action% , %default%
	if (Hotkey%action% != "[ none ]")
		Hotkey, % "*" . Hotkey%action%, Action%action%
}

;; disabled keys
IniRead, DoNothingKeys, %configFile%, Keys, DoNothing, %A_Space%
if (DoNothingKeys != "")
{
	Loop, parse, DoNothingKeys, |
	{
		try {
			Hotkey, % "*" . A_LoopField, ActionDoNothing
		}
	}
}

Hotkey, IfWinNotActive

;; load general settings
IniRead, TrayBalloon, %configFile%, General, BalloonTip , 0
IniRead, PlaySound, %configFile%, General, PlaySound , 0
IniRead, AsAdmin, %configFile%, General, AsAdmin , 0
IniRead, TopPriority, %configFile%, General, TopPriority, 0
IniRead, Autostart, %configFile%, General, Autostart , 0
IniRead, TrayClickStart, %configFile%, General, TrayClickStart , 1

;; load Advanced
IniRead, useMouseEvent, %configFile%, Advanced, useMouseEvent , 1
IniRead, useMouseMoveEvent, %configFile%, Advanced, useMouseMoveEvent , 0
IniRead, logWindow, %configFile%, Advanced, logWindow , 0

;; ************
;; run as admin
;; ************

if (AsAdmin && not A_IsAdmin)
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
}


;; **************************************
;; run with higher priority to avoid lags
;; **************************************

if (TopPriority)
{
    if (A_IsAdmin)
    {
        Process, Priority, , R
    } else
    {
        Process, Priority, , H
    }
}

;; load speed settings
IniRead, mouseDoubleclickSpeed, %configFile%, Speed, mouseDoubleclickSpeed , 55
IniRead, mouseMoveSpeed, %configFile%, Speed, mouseMoveSpeed , 1
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
FileInstall, files\mousekeys++grey.ico, files\mousekeys++grey.ico
FileInstall, files\disabled.wav, files\disabled.wav

;; *********
;; Tray menu
;; *********


;; tooltip
OnMessage(0x200, "GUITT")
;; remove standard Menu items
Menu, Tray, NoStandard
Menu, Tray, Icon, files\mousekeys++.ico,,1

;; gui instead of Menu, to prevent hold
OnMessage(0x404, "AHK_NOTIFYICON")
AHK_NOTIFYICON(wParam, lParam)
{
	global TrayClickStart
	if (lParam = 0x0205)
	{
		SetTimer, ShowRbuttonMenu, -1
		return 0
	} else
	if (lParam = 0x202 && TrayClickStart)
	{
		SetTimer, ActionToggleEnable, -1
		return 0
	}
}

Gui, traymenu:New, -sysmenu +toolwindow -Border -Caption +AlwaysOnTop, MouseKeys++ - tray menu
Gui, trayMenu:Margin, 0, 0
Gui, trayMenu:Add, Button, x0 y0 w0 h0,
Gui, trayMenu:Add, Button, xp-5 yp-3 w110 h30 gActionToggleEnable vTrayMenuEnable, Disable
Gui, trayMenu:Add, Button, yp+27 w110 h30 gShowSettingsGUI, Settings
Gui, trayMenu:Add, Button, yp+27 w110 h30 gShowInfo, Info
Gui, trayMenu:Add, Button, yp+27 w110 h30 gExitSub, Exit

;; old tray menu, puts script on hold while active
;trayEnabledLabel := "&Enabled (E)"
;traySettingsLabel := "&Settings (S)"
;trayInfoLabel := "&Info (I)"
;trayExitLabel := "&Exit (X)"

;Menu, Tray, Add , %trayEnabledLabel%, ActionToggleEnable
;Menu, Tray, Check , %trayEnabledLabel%
;Menu, Tray, Add
;Menu, Tray, Add , %traySettingsLabel%, ShowSettingsGUI
;Menu, Tray, Add , %trayInfoLabel%, ShowInfo
;Menu, Tray, Add
;Menu, Tray, Add , %trayExitLabel%, ExitSub
;Menu, Tray, Tip , MouseKeys++`nActive
;Menu, Tray, Default , %trayEnabledLabel%

;; ***
;; GUI
;; ***

;; add tabs
Gui, settings:Add, Tab2, -Wrap vTabControl w500 h375, General|Keys|Speed|Advanced
Gui, settings:Margin, 5, 5
Gui, settings:Tab, Keys

;; KEYS
;; ----

;; Mouse keys
Gui, settings:Add, Picture, x38 y40 w200 h-1 , files\mouse.gif
Gui, settings:Add, Button, x50 y80 w50 h50 gOpenSetKey vSetKeyClick, %HotkeyClick%
setKeyClick_TT := "Left mouseclick"
Gui, settings:Add, Button, x110 y80 w50 h50 gOpenSetKey vSetKeyMiddleclick, %HotkeyMiddleclick%
setKeyMiddleclick_TT := "Middle mouseclick"
Gui, settings:Add, Button, x170 y80 w50 h50 gOpenSetKey vSetKeyRightclick, %HotkeyRightclick%
setKeyRightclick_TT := "Right mouseclick"

Gui, settings:Add, Button, x110 y40 w50 h30 gOpenSetKey vSetKeyWheelUp, %HotkeyWheelUp%
SetKeyWheelUp_TT := "Wheel up"
Gui, settings:Add, Button, x110 y140 w50 h30 gOpenSetKey vSetKeyWheelDown, %HotkeyWheelDown%
SetKeyWheelDown_TT := "Wheel down"

Gui, settings:Add, Button, x50 y180 w50 h50 gOpenSetKey vSetKeyUpLeft, %HotkeyUpLeft%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyUp, %HotkeyUp%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyUpRight, %HotkeyUpRight%
Gui, settings:Add, Button, xp-120 y+10 w50 h50 gOpenSetKey vSetKeyLeft, %HotkeyLeft%
Gui, settings:Add, Button, x+70 yp+0 w50 h50 gOpenSetKey vSetKeyRight, %HotkeyRight%
Gui, settings:Add, Button, xp-120 y+10 w50 h50 gOpenSetKey vSetKeyDownLeft, %HotkeyDownLeft%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyDown, %HotkeyDown%
Gui, settings:Add, Button, x+10 yp+0 w50 h50 gOpenSetKey vSetKeyDownRight, %HotkeyDownRight%


;; other keys
Gui, settings:Add, GroupBox, x260 y40 w240 h170 , Additional
Gui, settings:Add, Text, xp+10 yp+20 w120 h20 section, Activation Key:
Gui, settings:Add, Text, y+5 w120 h20 , Double-Click Key:
Gui, settings:Add, Text, y+5 w120 h20 , Left Drag:
Gui, settings:Add, Text, y+5 w120 h20 , Right Drag:
Gui, settings:Add, Text, y+5 w120 h20 , Middle Drag:
Gui, settings:Add, Text, y+5 w120 h20 , Alt-Tab:
Gui, settings:Add, Button, ys-2 w100 h20 gOpenSetKey vSetkeyToggleEnable, %HotkeyToggleEnable%
Gui, settings:Add, Button, w100 h20 gOpenSetKey vSetkeyDoubleclick, %HotkeyDoubleclick%
Gui, settings:Add, Button, w100 h20 gOpenSetKey vSetkeyDragLeft, %HotkeyDragLeft%
Gui, settings:Add, Button, w100 h20 gOpenSetKey vSetkeyDragRight, %HotkeyDragRight%
Gui, settings:Add, Button, w100 h20 gOpenSetKey vSetkeyDragMiddle, %HotkeyDragMiddle%
Gui, settings:Add, Button, w100 h20 gOpenSetKey vSetkeyAltTab, %HotkeyAltTab%

;; disable keys
Gui, settings:Add, GroupBox, xs-10 w240 h85 , Disable Keys
Gui, settings:Add, Button, xp+10 yp+20 w100 h20 section gOpenSetKey vSetkeyDoNothing, Disable Key
SetKeyDoNothing_TT := "Disable the default function of a key"
Gui, settings:Add, Button, w100 h20 disabled gReenableKey vReenableKey, Re-enable Key
ReenableKey_TT := "Re-enable the default function of a key"
Gui, settings:Add, ListBox, ys w100 R4 gDisabledKeysSelect vDisabledKeys, %DoNothingKeys%

;; Speed settings
;; --------------
Gui, settings:Tab, Speed

Gui, settings:Add, GroupBox, w475 h125 , Movement
Gui, settings:Add, Text, xp+10 yp+20 w110 h20 section, Base (px/sec)
Gui, settings:Add, Text, y+5 w110 h20 , Maximum (px/sec)
Gui, settings:Add, Text, y+5 w110 h20 , Acceleration (px/sec)
Gui, settings:Add, Text, y+5 w110 h20 , Accel. Delay (ms)
Gui, settings:Add, edit, ys w40 h20 disabled vMouseMoveSpeedEdit, %mouseMoveSpeed%
Gui, settings:Add, edit, w40 h20 disabled vMouseMoveSpeedMaxEdit, %MouseMoveSpeedMax%
Gui, settings:Add, edit, w40 h20 disabled vMouseMoveAccelerationEdit,  %MouseMoveAcceleration%
Gui, settings:Add, edit, w40 h20 disabled vMouseMoveAccelerationDelayEdit, %MouseMoveAccelerationDelay%
Gui, settings:Add, slider, ys w300 h20 Range1-8000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveSpeed, %MouseMoveSpeed%
Gui, settings:Add, slider, w300 h20 Range10-8000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveSpeedMax, %MouseMoveSpeedMax%
Gui, settings:Add, slider, w300 h20 Range0-8000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveAcceleration, %MouseMoveAcceleration%
Gui, settings:Add, slider, w300 h20 Range0-5000 ToolTip Line5 gSpeedSettingsSubmit vMouseMoveAccelerationDelay, %MouseMoveAccelerationDelay%

Gui, settings:Add, GroupBox, xp-170 y+15 w475 h75 , other
Gui, settings:Add, Text, xp+10 yp+20 w110 h20 section, Double-click (ms)
Gui, settings:Add, Text, y+5 w110 h20 , Scroll Speed
Gui, settings:Add, edit, ys w40 h20 disabled vMouseDoubleClickSpeedEdit, %mouseDoubleclickSpeed%
Gui, settings:Add, edit, w40 h20 disabled vScrollSpeedEdit, %scrollSpeed%
Gui, settings:Add, slider, ys w300 h20 Range10-500 ToolTip Line5 gSpeedSettingsSubmit vMouseDoubleclickSpeed, %mouseDoubleclickSpeed%
Gui, settings:Add, slider, w300 h20 Range1-100 ToolTip Line5  gSpeedSettingsSubmit vScrollSpeed, %scrollSpeed%

;; advanced features
Gui, settings:Tab, Advanced
Gui, settings:Add, GroupBox, w475 h145 , Advanced Settings
Gui, settings:Add, Text, xp+10 yp+20, Warning! This settings are for advanced users only.
Gui, settings:Add, CheckBox, h20 checked%useMouseEvent% gToggleMouseEvent, Use mouseevents for clicks
Gui, settings:Add, CheckBox, h20 checked%useMouseMoveEvent% gToggleMouseMoveEvent vTogglemouseMoveEvent, Use mouseevents for movement
ToggleMouseMoveEvent_TT := "lacks precision, but may work where default mode does not."
Gui, settings:Add, CheckBox, h20 checked%logWindow% gToggleLogWindow, Show log window



;; General Settings
Gui, settings:Tab, General

Gui, settings:Add, GroupBox, w475 h145 , General Settings
Gui, settings:Add, CheckBox, xp+10 yp+20 h20 checked%TrayBalloon% gToggleTrayBalloon, Show Balloon Tip on Start/Stop
Gui, settings:Add, CheckBox, h20 checked%PlaySound% gTogglePlaySound, Play Sound on Start/Stop
Gui, settings:Add, CheckBox, h20 checked%TrayClickStart% gToggleTrayClickStart, Start/Stop on tray icon click
Gui, settings:Add, CheckBox, h20 checked%asAdmin% gToggleAdmin vToggleAdmin, Run as Admin (recommended)
ToggleAdmin_TT := "Needed to work with system windows like taskmanager, but shows UAC prompt on start."
Gui, settings:Add, CheckBox, h20 checked%topPriority% gTogglePriority vTogglePriority, Run with top priority (recommended)
TogglePriority_TT := "Gives the process higher priority to avoid lag. Needs to run as administrator to gain realtime (real top) priority."
Gui, settings:Add, CheckBox, h20 checked%autostart% gToggleAutostart vToggleAutostart, Autostart MouseKeys++
ToggleAutostart_TT := "Autostart MouseKeys++ on Windows startup."
Gui, settings:Add, Button, y+15 x350 h20 gResetToDefault, Restore default configuration


Gui, settings:Tab

;; bottom line
Gui, settings:Add, Text, y385 x10 R1 section, Benedikt Schneyer
Gui, settings:Add, Link, x+35 R1, <a href="http://djquad.com/mousekeys-plus-plus">Project Page</a>
Gui, settings:Add, Link, x+35 R1, <a href="mailto:MouseKeys@djquad.com">MouseKeys@djquad.com</a>
Gui, settings:Add, Link, x+35 R1, <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H6D2YMDPLV69S">Donate</a> Thanks!



;; ********
;; Info GUI
;; ********

Gui, info:Add, Pic, w128 h-1 x10 y10, files\mousekeys++.ico
Gui, info:Font, s20,
Gui, info:Add, Text, ys section, MouseKeys++
Gui, info:Font,
Gui, info:Add, Text, xs section, MouseKeys++ is a free and open source Windows program that emulates mouse movement from the keyboard. `nThe intended use is for those with physical disabilities who can't grasp, drag, nor click using a physical mouse.
Gui, info:Add, Text, xs, Author: Benedikt Schneyer
Gui, info:Add, Text, x500 yp+0, Version: %VERSION%
Gui, info:Add, Link, xs, Any Feedback? <a href="mailto:MouseKeys@djquad.com">mail</a>
Gui, info:Add, Link, x500 yp+0 , Like it? <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H6D2YMDPLV69S">Donate</a>
Gui, info:Add, link, xs, For more infos, updates and other stuff visit our <a href="http://djquad.com/mousekeys-plus-plus">Project Page</a> or on <a href="https://github.com/DarthBrento/MouseKeysPlusPlus">GitHub</a>.

;;startLog
if (logWindow)
	Cinit()

return

/*
    ######## ##     ## ########  ######     		######## ##    ## ########
    ##        ##   ##  ##       ##    ##    		##       ###   ## ##     ##
    ##         ## ##   ##       ##          		##       ####  ## ##     ##
    ######      ###    ######   ##          		######   ## ## ## ##     ##
    ##         ## ##   ##       ##          		##       ##  #### ##     ##
    ##        ##   ##  ##       ##    ##    		##       ##   ### ##     ##
    ######## ##     ## ########  ######     		######## ##    ## ########
*/

;; ********
;; Settings
;; ********

SpeedSettingsSubmit:
	Gui, settings:submit, NoHide
	GuiControl, settings:, %A_GuiControl%Edit, % %A_GuiControl%
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
	Gui, settings:-disabled
	Gui, setkey:destroy
return

SetKeyGuiClose:
	Gui, settings:-disabled
	Gui, setkey:destroy
return

ReenableKey:
	Gui, settings:submit, NoHide

	if (DisabledKeys = "")
		return

	;; re-enable key
	Hotkey, IfWinNotActive, MouseKeys++ - enter key
	try {
		Hotkey, % "*" . DisabledKeys, , Off
	}
	Hotkey, IfWinNotActive

	;; update GUI

	;; remove key from list
	DoNothingKeys := RegExReplace(DoNothingKeys,  "(" . DisabledKeys . "\||\|" . DisabledKeys . "|^" . DisabledKeys . "$)")

	;; strip additional pipes, funny regex ;-)
	DoNothingKeys := RegExReplace(DoNothingKeys, "(^\||\|\||\|$)")

	GuiControl,settings:,DisabledKeys, |
	GuiControl,settings:,DisabledKeys, %DoNothingKeys%

	if (DoNothingKeys != "")
	{
		;; choose first entry
		GuiControl,settings:choose,DisabledKeys, 1
	} else
	{
		GuiControl, settings:+disabled, ReenableKey
	}

	;; save in settings
	IniWrite, %DoNothingKeys%, %configFile%, Keys, DoNothing

return

DisabledKeysSelect:
	GuiControl, settings:-disabled, ReenableKey
return

#IfWinActive, MouseKeys++ - enter key

ESC::
	Gui, setkey:submit
	action := SubStr(A_GuiControl, 10)
	setHotkey("[ none ]",NewHotkeyAction)
	Gui, settings:-disabled
	Gui, setkey:destroy
return

#if

ToggleTrayClickStart:
	TrayClickStart := !TrayClickStart
	IniWrite, %TrayClickStart%, %configFile%, General, TrayClickStart
return

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
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\MouseKeys++.lnk , %A_WorkingDir%,, Improved MouseKeys tool ,%A_WorkingDir%\files\mousekeys++.ico
	Else
		FileDelete, %A_Startup%\MouseKeys++.lnk
return

ToggleAdmin:
	AsAdmin := !AsAdmin
	IniWrite, %AsAdmin%, %configFile%, General, AsAdmin
return

TogglePriority:
	TopPriority := !TopPriority
	IniWrite, %TopPriority%, %configFile%, General, TopPriority
return

ToggleMouseEvent:
	useMouseEvent := !useMouseEvent
	IniWrite, %useMouseEvent%, %configFile%, Advanced, useMouseEvent
return

ToggleMouseMoveEvent:
	useMouseMoveEvent := !useMouseMoveEvent
	IniWrite, %useMouseMoveEvent%, %configFile%, Advanced, useMouseMoveEvent
return

ToggleLogWindow:
	logWindow := !logWindow
	IniWrite, %logWindow%, %configFile%, Advanced, logWindow
	if (logWindow)
		Cinit()
	Else
		Cdestroy()
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
	Cadd("doubleclick")
	if (useMouseEvent)
	{
		mouseEventClick("Left")
		sleep %mouseDoubleclickSpeed%
		mouseEventClick("Left")
	} else
	{
		send % getActiveModifier() . "{click}"
		sleep %mouseDoubleclickSpeed%
		send % getActiveModifier() . "{click}"
	}
return

ActionClick:
	Cadd("click left")
	if (useMouseEvent)
	{
		mouseEventClick("Left")
	}
	else
		send % getActiveModifier() . "{click}"
return

ActionRightclick:
	Cadd("click right")
	if (useMouseEvent)
	{
		mouseEventClick("Right")
	}
	else
		send % getActiveModifier() . "{click right}"
return

ActionMiddleclick:
	Cadd("click middle")
	if (useMouseEvent)
	{
		mouseEventClick("Middle")
	}
	else
		send % getActiveModifier() . "{click right}"
return

ActionWheelUp:
	moveWheel(1,scrollSpeed)
return

ActionWheelDown:
	moveWheel(-1,scrollSpeed)
return

ActionDragLeft:
	drag("Left")
return

ActionDragMiddle:
	drag("Middle")
return

ActionDragRight:
	drag("Right")
return

ActionAltTab:
	run C:\Users\Default\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Window Switcher.lnk
return

ActionReload:
	reload
return

ActionToggleEnable:
	suspend
	if (A_IsSuspended)
	{
		GuiControl, trayMenu:, TrayMenuEnable, Enable
		Menu, Tray, Icon, files\mousekeys++grey.ico,,1
		Menu, Tray, Tip , MouseKeys++`nsuspended
		if (TrayBalloon)
			TrayTip , MouseKeys++, suspended
		If (playSound)
			SoundPlay, files\enabled.wav
	} else
	{
		GuiControl, trayMenu:, TrayMenuEnable, Disable
		Menu, Tray, Icon, files\mousekeys++.ico,,1
		Menu, Tray, Tip , MouseKeys++`nactive
		if (TrayBalloon)
			TrayTip , MouseKeys++, active
		If (playSound)
			SoundPlay, files\disabled.wav
	}
return


ActionDoNothing:
return

mouseEventClick(button, dir = "")
{
	global
	if (dir != "U")
	{
		DllCall("mouse_event", uint, mouseEvent%button%Down, int, 100, int, 0)
		sleep 15
	}
	if (dir != "D")
		DllCall("mouse_event", uint, mouseEvent%button%Up, int, 100, int, 0)
}

setHotkey(key, action)
{
	global
	;; get current hotkey for defined action

	Hotkey, IfWinNotActive, MouseKeys++ - enter key

	if (action != "DoNothing")
	{
		;; disable old hotkey, if it exists ( -> try)
		try {
			Hotkey, % "*" . Hotkey%action%, , Off
		}
	}

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

	if (action = "DoNothing") {
		if (!RegExMatch(DoNothingKeys, "^(\w*\|)*" . key . "(\|\w*)*$" ))
		{
			;; save global
			DoNothingKeys .= "|" . key

			;; strip additional pipes, funny regex ;-)
			DoNothingKeys := RegExReplace(DoNothingKeys, "(^\||\|\||\|$)")

			;; update GUI
			GuiControl, settings: , DisabledKeys, %key%

			;; save in settings
			IniWrite, %DoNothingKeys%, %configFile%, Keys, DoNothing
		}
	} Else
	{
		;; update GUI
		GuiControl, settings: , SetKey%action%, %key%

		;; save in settings
		IniWrite, %key%, %configFile%, Keys, %action%

		;; save global
		Hotkey%action% := key
	}
}

moveWheel(direction,scrollSpeed)
{
	Cadd((direction = 1 ? "WheelUp" : "WheelDown") . " press")
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
	Cadd((direction = 1 ? "WheelUp" : "WheelDown") . " up")
}

moveMouse(x,y)
{
	global mouseMoveAccelerationDelay, mouseMoveInterval, mouseMoveAcceleration, mouseMoveSpeed, mouseMovespeedMax, useMouseMoveEvent

	;; get buttonname
	MovementButtonName := A_ThisHotkey
	StringReplace, MovementButtonName, MovementButtonName, *

	;; get current position
	MouseGetPos, xPos, yPos

	;; move one pixel instantly
	xPos += x
	yPos += y

	Cadd(MovementButtonName . " press down")
	While GetKeyState(MovementButtonName, "P")
	{
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

		xBefore := xPos
		yBefore := yPos

		xPos += x * speed
		yPos += y * speed

		xPosR := Round(xPos)
		yPosR := Round(yPos)

		;; i like to move it
		if (useMouseMoveEvent)
		{
			;; if we move a pix move a mickey, hacky and lacks precision
			xMick := (A_Index = 1? x : xPosR - xBefore)
			yMick := (A_Index = 1? y : yPosR - yBefore)

			DllCall("mouse_event", uint, 0x0001, int, xMick, int, yMick)
		}
		else
		{
			MouseMove, % xPosR , % yPosR , 2
		}

		sleep %mouseMoveInterval%
	}
	KeyWait, %MovementButtonName%
	Cadd(MovementButtonName . " press up")
}

drag(key)
{
	ButtonName := A_ThisHotkey
	StringReplace, ButtonName, ButtonName, *

	If GetKeyState( Substr(key,1,1) . "Button")
		d := "U"
	else
		d := "D"

	if (useMouseEvent)
		mouseEventClick(key,d)
	else
		send % getActiveModifier() . "{click " . d . " " . key . "}"

	KeyWait, %ButtonName%
	Cadd("click " . key . (d = "U" ? "Up" : "Down") . " " . ButtonName)
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

ExitSub:
ExitApp

ShowRbuttonMenu:
	MouseGetPos, xPos, yPos

	xPos -= 100
	yPos -= 120

	;; show tray GUI
	Gui, traymenu:Show, x%xPos% y%yPos% w100 h105

	;; keep open until it loses focus
	Loop {

		IfWinNotActive, MouseKeys++ - tray menu
		{
			break
		}

		sleep 50
	}

	;; close tray menu
	Gui, traymenu:Cancel
return

GUITT(){
	static CurrControl, PrevControl, _TT

	CurrControl := A_GuiControl
	If (CurrControl <> PrevControl) {
		SetTimer, RemoveToolTip, -1
		SetTimer, DisplayToolTip, -500
		PrevControl := CurrControl
	}
	return

	DisplayToolTip:
		try {
			ToolTip % %CurrControl%_TT
		}
		catch {
			ToolTip
		}
	return
}

F12::
	WinGetActiveStats, Title, Width, Height, X, Y

	MouseMove, Width / 2, Height / 2, 0
return

F11::
	DllCall("mouse_event", uint, 0x0001, int, 10, int, 0)
return

#Include consolelog.ahk
