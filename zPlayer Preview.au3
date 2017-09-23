#cs ----------------------------------------------------------------------------~JD
	-- JoshuaDoes © 2017 --
	This software is still in a developmental state. Features may be added or removed without notice. Warranty is neither expressed nor implied for the system in which you run this software.

	AutoIt Version: 3.3.15.0
	Title: zPlayer Preview
	Build Number: 25
	Release Format: Proprietary Beta
	Author: JoshuaDoes (Joshua Wickings)
	Website: zPlayer [https://joshuadoes.com/zPlayer/]
	License: GPL v3.0 [https://www.gnu.org/licenses/gpl-3.0.en.html]

	Description: Play media files with a graphically clean and simple interface that users have come to expect from their favorite multimedia applications.

	Credits:
	- The AutoIt team for creating such an amazing dynamic and diverse scripting language for the Windows operating system
	- All icons in the "Dark" [/assets/themes/dark/], "Light" [/assets/themes/light/], and "Nolan" [/assets/themes/nolan/] themes are from Icons8 [https://icons8.com/] and are modified to match the asset availability requirements for zPlayer
	- Paint.NET for allowing me to modify icons properly to be able to use them in zPlayer
	- Other licenses in their respective folders
#ce ----------------------------------------------------------------------------~JD

#Region ;Directives on how to compile and/or run zPlayer using AutoIt3Wrapper_GUI
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=zPlayer.ico
#AutoIt3Wrapper_Outfile=zPlayer Preview Build 25 (Beta).exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Play media files with a graphically clean and simple interface that users come to expect from their favorite media players.
#AutoIt3Wrapper_Res_Description=zPlayer Preview (Beta)
#AutoIt3Wrapper_Res_Fileversion=25
#AutoIt3Wrapper_Res_LegalCopyright=JoshuaDoes © 2017
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon

AutoItSetOption("GUIOnEventMode", 1) ;Events are better than GUI message loops
AutoItSetOption("GUIDataSeparatorChar", Chr(1)) ;Sometimes titles have the default pipe character, and that causes issues in list views
#EndRegion ;Directives on how to compile and/or run zPlayer

#Region ;Required libraries for program functionality
#include <File.au3> ;Library used for file management
#include <WinAPI.au3> ;Library used for Windows APIs
#include <WinAPISys.au3> ;Library used for Windows System APIs
#include <GUIConstants.au3> ;Constants for GUI
#include <GUIConstantsEx.au3> ;Extra constants for GUI
#include <WindowsConstants.au3> ;Constants for windows
#include <FileConstants.au3> ;Constants for files
#include <String.au3> ;Library for strings
#include <GDIPlus.au3> ;Library for GDI+
#include <Misc.au3> ;Library for miscellaneous stuff
#include <SendMessage.au3> ;Library for window management
#include "libs/BASS.au3/BASS/Bass.au3" ;Library used for audio playback
#include "libs/BASS.au3/BASS/BassConstants.au3" ;Constants for BASS
#include "libs/BASS.au3/BASS_TAGS/BassTags.au3" ;Library used for ID3 tags
#include "libs/BorderLessWinUDF.au3" ;Library used for borderless resizeable GUIs
#include "libs/JSON/JSON.au3" ;Library used for JSON
#include "libs/GUICtrlOnHover.au3" ;Library used to add hover and click effects to buttons
#include "libs/CompInfo.au3" ;Library used to gather computer information
#EndRegion ;Required libraries for program functionality

#Region ;Initiation sequence
	Global $mTemp[] ;Contains temporary data, must not be depended on
	$mTemp["Execution Duration"] = TimerInit()

	Global $mInternal[] ;Contains data used for internal things that should not be controlled via an outside source

	Global $mProgram[] ;Contains data about the current program
	$mProgram["Author"] = "JoshuaDoes (Joshua Wickings)"
	$mProgram["Name"] = "zPlayer"
	$mProgram["Edition Name"] = "Preview"
	$mProgram["Build"] = 25
	$mProgram["Registry Address Old"] = "HKEY_CURRENT_USER\Software\JoshuaDoes\zPlayer"
	If _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Window Title", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Volume", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Random", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Repeat", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Hidden Themes", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Size State", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Width", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Height", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client X", "", False) Or _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Y", "", False) Then _zPlayer_Settings_Upgrade(22)
	$mProgram["Registry Address"] = "HKEY_CURRENT_USER\Software\JoshuaDoes\zPlayer"
	$mProgram["Registry Address Main"] = $mProgram["Registry Address"] & "\v1"
	If Not @Compiled Then
		$mProgram["Developer Mode"] = _zPlayer_Settings_Load($mProgram["Registry Address"], "Developer Mode", True)
		If $mProgram["Developer Mode"] Then
			$mProgram["Registry Address Main"] = $mProgram["Registry Address Main"] & "\Developer"
		Else
			$mProgram["Registry Address Main"] = $mProgram["Registry Address Main"] & "\Standard"
		EndIf
		$mProgram["Debug Mode"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Debug Mode", True)
		$mProgram["STDOUT"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "STDOUT", True)
		$mProgram["STDERR"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "STDERR", True)
	Else
		$mProgram["Developer Mode"] = _zPlayer_Settings_Load($mProgram["Registry Address"], "Developer Mode", False)
		If $mProgram["Developer Mode"] Then
			$mProgram["Registry Address Main"] = $mProgram["Registry Address Main"] & "\Developer"
		Else
			$mProgram["Registry Address Main"] = $mProgram["Registry Address Main"] & "\Standard"
		EndIf
		$mProgram["Debug Mode"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Debug Mode", False)
		$mProgram["STDOUT"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "STDOUT", False)
		$mProgram["STDERR"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "STDERR", False)
	EndIf
	$mProgram["Registry Address GUI"] = $mProgram["Registry Address Main"] & "\GUI"
	$mProgram["Registry Address User"] = $mProgram["Registry Address Main"] & "\User"
	$mProgram["Current Installed Version"] = _zPlayer_Settings_Load($mProgram["Registry Address"], "Current Installed Version", $mProgram["Build"])
	If $mProgram["Current Installed Version"] < $mProgram["Build"] Then
		_zPlayer_Settings_Upgrade($mProgram["Current Installed Version"])
		_zPlayer_Settings_Save($mProgram["Registry Address"], "Current Installed Version", $mProgram["Build"])
	EndIf

	$mProgram["Main Directory"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Main Directory", @ScriptDir)
	$mProgram["Install Directory"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Install Directory", @ScriptDir & "\app")
	$mProgram["Temp Directory"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Temp Directory", $mProgram["Install Directory"] & "\temp")
	$mProgram["Update URL"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Update URL", "https://example.com/this_is_not_decided")
	$mProgram["Update Channel"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Update Channel", "Preview")
	$mProgram["Theme Store URL"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Theme Store URL", "https://example.com/this_is_not_decided")
	$mProgram["Theme Directory"] = _zPlayer_Settings_Load($mProgram["Registry Address Main"], "Theme Directory", $mProgram["Install Directory"] & "\themes")

	If Not FileExists($mProgram["Main Directory"]) Then
		$mProgram["Main Directory"] = @ScriptDir
		_zPlayer_Settings_Save($mProgram["Registry Address Main"], "Main Directory", $mProgram["Main Directory"])
	EndIf
	If Not FileExists($mProgram["Install Directory"]) Then
		$mProgram["Install Directory"] = $mProgram["Main Directory"] & "\app"
		_zPlayer_Settings_Save($mProgram["Registry Address Main"], "Install Directory", $mProgram["Install Directory"])
		DirCreate($mProgram["Install Directory"])
	EndIf
	If Not FileExists($mProgram["Temp Directory"]) Then
		$mProgram["Temp Directory"] = $mProgram["Install Directory"] & "\temp"
		_zPlayer_Settings_Save($mProgram["Registry Address Main"], "Temp Directory", $mProgram["Temp Directory"])
		DirCreate($mProgram["Temp Directory"])
	EndIf
	If Not FileExists($mProgram["Theme Directory"]) Then
		$mProgram["Theme Directory"] = $mProgram["Install Directory"] & "\themes"
		_zPlayer_Settings_Save($mProgram["Registry Address Main"], "Theme Directory", $mProgram["Theme Directory"])
		DirCreate($mProgram["Theme Directory"])
	EndIf

	Global $mGUISettings[] ;Contains settings related to the GUI
	$mGUISettings["Window Title"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Window Title", "%Name% %Edition Name% Build %Build%")
	$mGUISettings["Client Width"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Client Width", 800)
	If $mGUISettings["Client Width"] > @DesktopWidth Then
		$mGUISettings["Client Width"] = 800
	EndIf
	$mGUISettings["Client Height"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Client Height", 400)
	If $mGUISettings["Client Height"] > @DesktopHeight Then
		$mGUISettings["Client Height"] = 400
	EndIf
	$mGUISettings["Client X"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Client X", ((@DesktopWidth / 2) - ($mGUISettings["Client Width"] / 2)))
	If $mGUISettings["Client X"] >= @DesktopWidth Then
		$mGUISettings["Client X"] = ((@DesktopWidth / 2) - ($mProgram["Client Width"] / 2))
	EndIf
	$mGUISettings["Client Y"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Client Y", ((@DesktopHeight / 2) - ($mGUISettings["Client Height"] / 2)))
	If $mGUISettings["Client Y"] >= @DesktopHeight Then
		$mGUISettings["Client Y"] = ((@DesktopHeight / 2) - ($mProgram["Client Height"] / 2))
	EndIf
	$mGUISettings["Client State"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Client State", 0) ;0=Normal, 1=Maximized, 2=Minimized
	$mGUISettings["Window Shadow"] = _zPlayer_Settings_Load($mProgram["Registry Address GUI"], "Window Shadow", False)

	Global $mUserSettings[]
	$mUserSettings["Hidden Themes"] = _zPlayer_Settings_Load($mProgram["Registry Address User"], "Hidden Themes", False)
	$mUserSettings["Theme"] = _zPlayer_Settings_Load($mProgram["Registry Address User"], "Theme", "dark")
	$mUserSettings["Volume"] = _zPlayer_Settings_Load($mProgram["Registry Address User"], "Volume", 67)
	$mUserSettings["Random"] = _zPlayer_Settings_Load($mProgram["Registry Address User"], "Random", False)
	$mUserSettings["Repeat"] = _zPlayer_Settings_Load($mProgram["Registry Address User"], "Repeat", 1) ;0=No repeat, 1=Repeat playlist, 2=Repeat once

	Global $mThemes[]
	_zPlayer_Themes_Refresh($mProgram["Theme Directory"], $mThemes)
	If Not UBound(MapKeys($mThemes)) Then
		_zPlayer_Debug_LogError("> A theme is required for a functional GUI, fatally exiting")
		Exit MsgBox(-1, $mGUISettings["Window Title"], "A theme must be installed in order for zPlayer to provide a functional user interface." & @CRLF & @CRLF & "Please reinstall zPlayer or download a theme from the zPlayer Theme Store.")
	EndIf
	If Not MapExists($mThemes, $mUserSettings["Theme"]) Then
		Local $aThemes = MapKeys($mThemes)
		$mUserSettings["Theme"] = $aThemes[0]
		_zPlayer_Settings_Save($mProgram["Registery Address User"], "Theme", $mUserSettings["Theme"])
	EndIf

	_GDIPlus_Startup()
#EndRegion

#cs
If $mProgram["Debug Mode"] Then
	_zPlayer_Debug_Log("> Listing all map keys...")
	$aProgram = MapKeys($mProgram)
	$aGUISettings = MapKeys($mGUISettings)
	$aUserSettings = MapKeys($mUserSettings)
	For $i = 0 To UBound($aProgram) - 1
		_zPlayer_Debug_Log("Key #" & ($i + 1) & " (" & $aProgram[$i] & "): " & $mProgram[$aProgram[$i]])
	Next
	For $i = 0 To UBound($aGUISettings) - 1
		_zPlayer_Debug_Log("Key #" & ($i + 1 + UBound($aProgram)) & " (" & $aGUISettings[$i] & "): " & $mGUISettings[$aGUISettings[$i]])
	Next
	For $i = 0 To UBound($aUserSettings) - 1
		_zPlayer_Debug_Log("Key #" & ($i + 1 + UBound($aProgram) + UBound($aGUISettings)) & " (" & $aUserSettings[$i] & "): " & $mUserSettings[$aUserSettings[$i]])
	Next
EndIf
#ce

#Region ;GUI Initialization
Global $mTheme = $mThemes[$mUserSettings["Theme"]]

Global $GUI[4][2]
Global $Icons[]
$GUI[0][0] = 0 ;Normal GUI
$GUI[0][1] = GUICreate($mGUISettings["Window Title"], $mGUISettings["Client Width"], $mGUISettings["Client Height"], $mGUISettings["Client X"], $mGUISettings["Client Y"])
_GUI_EnableDragAndResize($GUI[0][1], $mGUISettings["Client Width"], $mGUISettings["Client Height"], 0, 0, $mGUISettings["Window Shadow"])
GUISetOnEvent($GUI_EVENT_CLOSE, "_zPlayer_Close")

$GUI[1][0] = 0 ;Titlebar
$GUI[1][1] = GUICtrlCreateLabel($mGUISettings["Window Title"], 0, 0, $mGUISettings["Client Width"], 30, $SS_CENTER + $SS_SUNKEN, $GUI_WS_EX_PARENTDRAG)
$GUI[2][0] = 1 ;Icon
$GUI[2][1] = GUICtrlCreateIcon($mTheme["Icon: Logo"], -1, 782, 382, 16, 16)
$GUI[3][0] = 1
$GUI[3][1] = GUICtrlCreatePic("", 384, 366, 32, 32)
$Icons[$GUI[3][1] & ": Normal"] = _zPlayer_Load_Icon($mTheme["Icon: Play"])
$Icons[$GUI[3][1] & ": Hover"] = _zPlayer_Load_Icon($mTheme["Icon: Play Hover"])
$Icons[$GUI[3][1] & ": Click"] = _zPlayer_Load_Icon($mTheme["Icon: Play Click"])
_SendMessage(GUICtrlGetHandle($GUI[3][1]), 0x0172, 0, $Icons[$GUI[3][1] & ": Normal"])
_GUICtrl_OnHoverRegister($GUI[3][1], "_zPlayer_Event_Button_Hover", "_zPlayer_Event_Button_Hover", "_zPlayer_Event_Button_Click", "_zPlayer_Event_Button_Click", 0)

_zPlayer_Themes_Apply($GUI, $mUserSettings["Theme"])

GUISetState(@SW_SHOW)
#EndRegion

While 1
	Sleep(100)
WEnd

#Region ;Functions
	Func _zPlayer_Close()
		_zPlayer_Debug_Log("Shutting down...")
		For $i = 0 To UBound($GUI) - 1
			If IsHWnd(WinGetHandle($GUI[$i][1])) Then
				;GUI
				_zPlayer_Debug_Log("> Nothing to do for GUI")
			Else
				;Control
				Switch $GUI[$i][0]
					Case 0 ;Titlebar
						_zPlayer_Debug_Log("> Nothing to do for titlebar")
					Case 1 ;Icon
						_zPlayer_Debug_Log("> Deleting icon...")
						_WinAPI_DeleteObject($Icons[$GUI[$i][1] & ": Normal"])
						_zPlayer_Debug_Log("--> Deleted main icon bitmap")
						If $Icons[$GUI[$i][1] & ": Hover"] Then
							_WinAPI_DeleteObject($Icons[$GUI[$i][1] & ": Hover"])
							_zPlayer_Debug_Log("--> Deleted hover icon bitmap")
						EndIf
						If $Icons[$GUI[$i][1] & ": Click"] Then
							_WinAPI_DeleteObject($Icons[$GUI[$i][1] & ": Click"])
							_zPlayer_Debug_Log("--> Deleted click icon bitmap")
						EndIf
					Case Else ;Unknown
						_zPlayer_Debug_Log("> Unknown control type, doing nothing")
				EndSwitch
			EndIf
		Next
		Exit
	EndFunc
	#Region ;Debug stuff
		Func _zPlayer_Debug_Log($sMsg)
			If $mProgram["Debug Mode"] Or $mProgram["Developer Mode"] Or $mProgram["STDOUT"] Then
				ConsoleWrite($sMsg & @CRLF)
			EndIf
		EndFunc
		Func _zPlayer_Debug_LogError($sMsg)
			If $mProgram["Debug Mode"] Or $mProgram["Developer Mode"] Or $mProgram["STDERR"] Then
				ConsoleWrite($sMsg & @CRLF)
			EndIf
		EndFunc
	#EndRegion
	#Region ;Theme stuff
		Func _zPlayer_Event_Button_Hover($hControl, $iParam)
			GUICtrlSetImage($hControl, "")

			Local $hBitmap = 0

			Switch $iParam
				Case 1 ;Hover
					$hBitmap = $Icons[$hControl & ": Hover"]
				Case 2 ;Unhover
					$hBitmap = $Icons[$hControl & ": Normal"]
			EndSwitch

			_SendMessage(GUICtrlGetHandle($hControl), 0x0172, 0, $hBitmap)
		EndFunc
		Func _zPlayer_Event_Button_Click($hControl, $iParam)
			GUICtrlSetImage($hControl, "")

			Local $hBitmap = 0

			Switch $iParam
				Case 1 ;Click
					$hBitmap = $Icons[$hControl & ": Click"]
				Case 2 ;Unclick
					$hBitmap = $Icons[$hControl & ": Hover"]
			EndSwitch

			_SendMessage(GUICtrlGetHandle($hControl), 0x0172, 0, $hBitmap)
		EndFunc
		Func _zPlayer_Load_Icon($sIconPath)
			_zPlayer_Debug_Log("> Loading icon [" & $sIconPath & "]...")
			Local $hImage = _GDIPlus_ImageLoadFromFile($sIconPath)
			If @error Then
				_zPlayer_Debug_Log("> Error loading icon")
				Return SetError(1, 0, False)
			EndIf
			$hImage = _GDIPlus_ImageResize($hImage, 32, 32)
			If @error Then
				_zPlayer_Debug_Log("> Error resizing icon")
				Return SetError(2, 0, False)
			EndIf
			Local $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
			If @error Then
				_zPlayer_Debug_Log("> Error creating bitmap from icon")
				Return SetError(3, 0, False)
			EndIf
			_GDIPlus_ImageDispose($hImage)
			Return $hBitmap
		EndFunc
		Func _zPlayer_Themes__AddIcon(ByRef $mTheme, $oTheme_Icons, $sIcon)
			If Not IsMap($mTheme) Then Return SetError(1, 0, False)
			If Not IsObj($oTheme_Icons) Then Return SetError(2, 0, False)
			Local $sTheme_Icon = Json_Get($oTheme_Icons, '["' & $sIcon & '"]')
			If @error Then Return SetError(3, 0, False)
			Local $sTheme_IconLoc = $mProgram["Theme Directory"] & "\" & $mTheme["ID"] & "\" & $sTheme_Icon & "." & $mTheme["Icon Type"]
			If Not FileExists($sTheme_IconLoc) Then Return SetError(4, 0, False)
			$mTheme["Icon: " & $sIcon] = $sTheme_IconLoc
			_zPlayer_Debug_Log("> Found icon [" & $sIcon & "] for theme [" & $mTheme["Name"] & "] at location [" & $sTheme_IconLoc & "]")
		EndFunc
		Func _zPlayer_Themes_Refresh($sThemesDir, ByRef $mThemes)
			_zPlayer_Debug_Log("> Refreshing themes list...")
			If Not FileExists($sThemesDir) Then
				_zPlayer_Debug_Log("> Themes directory not found")
				Return SetError(1, 0, False)
			EndIf
			If Not IsMap($mThemes) Then
				_zPlayer_Debug_Log("> Themes map invalid")
				Return SetError(2, 0, False)
			EndIf

			_zPlayer_Debug_Log("> Scanning [" & $sThemesDir & "]...")
			Local $hThemesList = FileFindFirstFile($sThemesDir & "\*")
			If $hThemesList = -1 Then
				_zPlayer_Debug_Log("> No themes were found")
				Return SetError(3, 0, False)
			EndIf

			Local $iThemesCount = 0

			While 1
				Local $sTheme_ID = FileFindNextFile($hThemesList)
				If @error Then
					If $iThemesCount = 0 Then
						_zPlayer_Debug_Log("> No themes were found, failed to cause exception earlier")
					Else
						_zPlayer_Debug_Log("> No more themes were found")
					EndIf
					ExitLoop
				EndIf
				Local $sTheme_Dir = $sThemesDir & "\" & $sTheme_ID
				Local $sTheme_DirAttributes = FileGetAttrib($sTheme_Dir)
				If StringInStr($sTheme_DirAttributes, "D") Then
					_zPlayer_Debug_Log("> Found possible theme directory [" & $sTheme_Dir & "] with attributes [" & $sTheme_DirAttributes & "]")
					If Not $mUserSettings["Hidden Themes"] And StringInStr($sTheme_DirAttributes, "H") Then
						_zPlayer_Debug_Log("> Possible theme directory marked as hidden, ignoring...")
						ContinueLoop
					EndIf
					Local $sTheme_Properties = $sTheme_Dir & "\theme.json"
					If FileExists($sTheme_Properties) Then
						_zPlayer_Debug_Log("> Found theme configuration [" & $sTheme_Properties & "]")
						_zPlayer_Debug_Log("> Reading theme configuration...")
						Local $sTheme_JSON = FileRead($sTheme_Properties)
						If @error Then
							_zPlayer_Debug_Log("> Error reading theme configuration, backing out...")
							ContinueLoop
						ElseIf Not $sTheme_JSON Then
							_zPlayer_Debug_Log("> Theme configuration is empty, backing out...")
							ContinueLoop
						EndIf
						$oTheme = Json_Decode($sTheme_JSON)
						If @error Then
							_zPlayer_Debug_Log("> Theme configuration is not valid JSON, backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Debug_Log("> Creating map to store data in...")
						Local $mTheme[]
						$mTheme["ID"] = $sTheme_ID
						$oTheme_Meta = Json_Get($oTheme, '["meta"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding theme meta, backing out...")
							ContinueLoop
						EndIf
						$sTheme_Meta_Author = Json_Get($oTheme_Meta, '["author"]')
						If @error Then
							_zPlayer_Debug_Log("> Theme author not found")
							$sTheme_Meta_Author = ""
						EndIf
						$mTheme["Author"] = $sTheme_Meta_Author
						$sTheme_Meta_Name = Json_Get($oTheme_Meta, '["name"]')
						If @error Then
							_zPlayer_Debug_Log("> Theme name not found")
							$sTheme_Meta_Name = ""
						EndIf
						$mTheme["Name"] = $sTheme_Meta_Name
						$aTheme_Meta_Credits = Json_Get($oTheme_Meta, '["credits"]')
						If @error Then
							_zPlayer_Debug_Log("> Theme credits not found")
							Local $aArray[0]
							$aTheme_Meta_Credits = $aArray
						EndIf
						$mTheme["Credits"] = $aTheme_Meta_Credits
						$oTheme_Settings = Json_Get($oTheme, '["settings"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding settings, backing out...")
							ContinueLoop
						EndIf
						$sTheme_IconType = Json_Get($oTheme_Settings, '["iconType"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon type, backing out...")
							ContinueLoop
						EndIf
						$mTheme["Icon Type"] = $sTheme_IconType
						$sTheme_BackgroundColor = Json_Get($oTheme_Settings, '["backgroundColor"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding background color, using default...")
							$sTheme_BackgroundColor = "000000"
						EndIf
						$mTheme["Background Color"] = $sTheme_BackgroundColor
						$sTheme_BackgroundImage = Json_Get($oTheme_Settings, '["backgroundImage"]')
						If @error Then
							_zPlayer_Debug_log("> Error finding background image")
						EndIf
						$mTheme["Background Image"] = $sTheme_BackgroundImage
						$sTheme_foregroundColor = Json_Get($oTheme_Settings, '["foregroundColor"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding Foreground Color, using default...")
							$sTheme_foregroundColor = "FFFFFF"
						EndIf
						$mTheme["Foreground Color"] = $sTheme_foregroundColor

						$oTheme_Icons = Json_Get($oTheme, '["icons"]')
						If @error Then
							_zPlayer_Debug_Log("> Error finding icons list, backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Logo")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Logo], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Play")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Play], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Play Hover")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Play Hover], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Play Click")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Play Click], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Pause")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Pause], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Resume")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Resume], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Previous")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Previous], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Next")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Next], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Stop")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Stop], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Shuffle")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Shuffle], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Repeat")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Repeat], backing out...")
							ContinueLoop
						EndIf
						_zPlayer_Themes__AddIcon($mTheme, $oTheme_Icons, "Repeat Once")
						If @error Then
							_zPlayer_Debug_Log("> Error finding icon [Repeat Once], backing out...")
							ContinueLoop
						EndIf

						;If all went well,
						$iThemesCount += 1
						$mThemes[$sTheme_ID] = $mTheme
					EndIf
				EndIf
				_zPlayer_Debug_Log("> Looking for more themes...")
			WEnd

			FileClose($hThemesList)

			If $iThemesCount >= 1 Then
				Return $mThemes
			Else
				Return SetError(3, 0, False)
			EndIf
		EndFunc
		Func _zPlayer_Themes_Apply($vHandle, $sTheme)
			If Not UBound($vHandle) Then
				If Not IsMap($vHandle) Then
					If Not IsHWnd($vHandle) Then
						If Not IsHwnd(WinGetHandle($vHandle)) Then
							Return SetError(1, 0, False)
						EndIf
					EndIf
				EndIf
			EndIf
			If Not $sTheme Then Return SetError(2, 0, False)
			If Not MapExists($mThemes, $sTheme) Then Return SetError(3, 0, False)
			Local $mTheme = $mThemes[$sTheme]
			If IsArray($vHandle) Then
				For $i = 0 To UBound($vHandle) - 1
					If IsHWnd(WinGetHandle($vHandle[$i][1])) Then
						;GUI
						Switch $vHandle[$i][0]
							Case 0 ;Normal GUI
								_zPlayer_Debug_Log("> Styling GUI...")
								Local $sTheme_Icon = $mTheme["Icon: Logo"]
								GUISetBkColor($mTheme["Background Color"], $vHandle[$i][1])
								_zPlayer_Debug_Log("--> Set background color to [" & $mTheme["Background Color"] & "]")
								GUISetIcon($sTheme_Icon, -1, $vHandle[$i][1])
								_zPlayer_Debug_Log("--> Set icon to [" & $mTheme["Icon: Logo"] & "]")
							Case Else ;Unknown
								_zPlayer_Debug_Log("> Unknown GUI type, not applying a style")
						EndSwitch
					Else
						;Control
						Switch $vHandle[$i][0]
							Case 0 ;Titlebar
								_zPlayer_Debug_Log("> Styling titlebar...")
								GUICtrlSetBkColor($vHandle[$i][1], $mTheme["Background Color"])
								_zPlayer_Debug_Log("--> Set background color to [" & $mTheme["Background Color"] & "]")
								GUICtrlSetColor($vHandle[$i][1], $mTheme["Foreground Color"])
								_zPlayer_Debug_Log("--> Set foreground color to [" & $mTheme["Foreground Color"] & "]")
							Case 1 ;Icon
								_zPlayer_Debug_Log("> Nothing to do for icon")
								;Do nothing
							Case Else ;Unknown
								_zPlayer_Debug_Log("> Unknown control type, not applying a style")
						EndSwitch
					EndIf
				Next
			ElseIf IsMap($vHandle) Then

			ElseIf IsHWnd($vHandle) Then

			ElseIf IsHwnd(WinGetHandle($vHandle)) Then

			EndIf
		EndFunc
	#EndRegion
	#Region ;Settings
		Func _zPlayer_Settings_Load($sRegistryLocation, $sOption, $sDefault = "", $bSave = True, $hWnd = "")
			Local $retValue = RegRead($sRegistryLocation, $sOption)
			If Not $retValue Then
				$retValue = $sDefault
				If $bSave Then
					_zPlayer_Settings_Save($sRegistryLocation, $sOption, $sDefault)
				EndIf
			EndIf
			If IsHWnd($hWnd) Then
				If IsNumber($retValue) Then
					GUICtrlSetState($hWnd, $retValue)
				Else
					GUICtrlSetData($hWnd, $retValue)
				EndIf
			EndIf
			_zPlayer_Settings_ProcessVariables($retValue)
			_zPlayer_Debug_Log("> Loaded setting [" & $sOption & "] with value [" & $retValue & "] from address [" & $sRegistryLocation & "]")
			Return $retValue
		EndFunc   ;==>_zPlayer_Settings_Load
		Func _zPlayer_Settings_ProcessVariables(ByRef $retValue)
			$retValue = StringReplace($retValue, "%Name%", $mProgram["Name"])
			$retValue = StringReplace($retValue, "%Edition Name%", $mProgram["Edition Name"])
			$retValue = StringReplace($retValue, "%Build%", $mProgram["Build"])
		EndFunc
		Func _zPlayer_Settings_Save($sRegistryLocation, $sOption, $sValue)
			_zPlayer_Debug_Log("> Saving setting [" & $sOption & "] with value [" & $sValue & "] at address [" & $sRegistryLocation & "]")
			If IsNumber($sValue) Then
				RegWrite($sRegistryLocation, $sOption, "REG_DWORD", $sValue)
			ElseIf IsString($sValue) Then
				RegWrite($sRegistryLocation, $sOption, "REG_SZ", $sValue)
			ElseIf IsBinary($sValue) Then
				RegWrite($sRegistryLocation, $sOption, "REG_BINARY", $sValue)
			ElseIf IsBool($sValue) Then
				RegWrite($sRegistryLocation, $sOption, "REG_SZ", $sValue)
			Else
				_zPlayer_Debug_Log("> Error saving setting, unknown data type")
			EndIf
		EndFunc   ;==>_zPlayer_Settings_Save
		Func _zPlayer_Settings_Upgrade($iOldVersion)
			_zPlayer_Debug_Log("> Checking if settings need to be upgraded...")
			Switch $iOldVersion
				Case 22
					Local $sBuild22_WindowTitle = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Window Title", "", False)
					If $sBuild22_WindowTitle Then
						$sBuild22_WindowTitle = StringReplace($sBuild22_WindowTitle, "%PROGRAM_TITLE%", "%Name%")
						$sBuild22_WindowTitle = StringReplace($sBuild22_WindowTitle, "%PROGRAM_BUILD%", "%Build%")
						_zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Window Title", $sBuild22_WindowTitle)
					EndIf
					Local $sBuild22_Volume = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Volume", "", False)
					If $sBuild22_Volume Then _zPlayer_Settings_Save($mProgram["Registry Address User"], "Volume", $sBuild22_Volume)
					Local $sBuild22_Random = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Random", "", False)
					If $sBuild22_Random Then _zPlayer_Settings_Save($mProgram["Registry Address User"], "Random", $sBuild22_Random)
					Local $sBuild22_Repeat = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Repeat", "", False)
					If $sBuild22_Repeat Then _zPlayer_Settings_Save($mProgram["Registry Address User"], "Repeat", $sBuild22_Repeat)
					Local $sBuild22_HiddenThemes = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Hidden Themes", "", False)
					If $sBuild22_HiddenThemes Then _zPlayer_Settings_Save($mProgram["Registry Address User"], "Hidden Themes", $sBuild22_HiddenThemes)
					Local $sBuild22_SizeState = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Size State", "", False)
					If $sBuild22_SizeState Then _zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Client State", $sBuild22_SizeState)
					Local $sBuild22_ClientWidth = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Width", "", False)
					If $sBuild22_ClientWidth Then _zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Client Width", $sBuild22_ClientWidth)
					Local $sBuild22_ClientHeight = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Height", "", False)
					If $sBuild22_ClientHeight Then _zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Client Height", $sBuild22_ClientHeight)
					Local $sBuild22_ClientX = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client X", "", False)
					If $sBuild22_ClientX Then _zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Client X", $sBuild22_ClientX)
					Local $sBuild22_ClientY = _zPlayer_Settings_Load($mProgram["Registry Address Old"], "Client Y", "", False)
					If $sBuild22_ClientY Then _zPlayer_Settings_Save($mProgram["Registry Address GUI"], "Client Y", $sBuild22_ClientY)
				Case Else
					_zPlayer_Debug_Log("> No settings to upgrade")
			EndSwitch
		EndFunc
	#EndRegion
#EndRegion