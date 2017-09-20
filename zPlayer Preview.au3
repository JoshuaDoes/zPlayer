#cs ----------------------------------------------------------------------------~JD
	-- JoshuaDoes © 2017 --
	This software is still in a developmental state. Features may be added or removed without notice. Warranty is neither expressed nor implied for the system in which you run this software.

	AutoIt Version: 3.3.15.0
	Title: zPlayer Preview
	Build Number: 24
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
#AutoIt3Wrapper_Outfile=zPlayer Preview Build 24.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Play media files with a graphically clean and simple interface that users come to expect from their favorite media players.
#AutoIt3Wrapper_Res_Description=zPlayer Preview
#AutoIt3Wrapper_Res_Fileversion=24
#AutoIt3Wrapper_Res_LegalCopyright=JoshuaDoes © 2017
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon
#EndRegion ;Directives on how to compile and/or run zPlayer using AutoIt3Wrapper_GUI

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
#include "assets/libs/BASS.au3/BASS/Bass.au3" ;Library used for audio playback
#include "assets/libs/BASS.au3/BASS/BassConstants.au3" ;Constants for BASS
#include "assets/libs/BASS.au3/BASS_TAGS/BassTags.au3" ;Library used for ID3 tags
#include "assets/libs/ID3_v3.4.au3" ;Library used for ID3 tags and album artwork reading/writing
;#include "assets/libs/DSEngine/DSEngine.au3" ;Library used for DirectShow playback
#include "assets/libs/Snippets.au3" ;Library used for small function snippets from other sources
#include "assets/libs/BorderLessWinUDF.au3" ;Library used for borderless resizeable GUIs
#include "assets/libs/Google API/Google API.au3" ;Library used for various Google APIs
#EndRegion ;Required libraries for program functionality

AutoItSetOption("GUIOnEventMode", 1) ;Events are better than GUI message loops
AutoItSetOption("GUIDataSeparatorChar", Chr(1)) ;Sometimes titles have the default pipe character, and that causes issues in list views

#Region ;Program constants and statics
;Data about the current program
Global $Program_Title = "zPlayer Preview" ;Program title
Global $Program_Build = 24 ;Program build number
Global $Program_Copyright = "JoshuaDoes © 2017"
Global $Program_Notice = "This software is still in a developmental state. Features may be added or removed without notice. Warranty is neither expressed nor implied for the system in which you run this software."
Global $Program_AutoItVersion = @AutoItVersion
Global $Program_ReleaseFormat = "Proprietary Beta"
Global $Program_Author = "JoshuaDoes (Joshua Wickings)"
Global $Program_Website = "zPlayer"
Global $Program_WebsiteURL = "https://joshuadoes.com/zPlayer/"
Global $Program_License = "GPL v3.0"
Global $Program_LicenseURL = "https://www.gnu.org/licenses/gpl-3.0.en.html"
Global $Program_Description = "Play media files with a graphically clean and simple interface that users have come to expect from their favorite multimedia applications."
Global $Program_Credits[4]
$Program_Credits[0] = "The AutoIt team for creating such an amazing dynamic and diverse scripting language for the Windows operating system"
$Program_Credits[1] = "All icons in the ""Dark"" [/assets/themes/dark/], ""Light"" [/assets/themes/light/], and ""Nolan"" [/assets/themes/nolan/] themes are from Icons8 [https://icons8.com/] and are modified to match the asset availability requirements for zPlayer"
$Program_Credits[2] = "Paint.NET for allowing me to modify icons properly to be able to use them in zPlayer"
$Program_Credits[3] = "Other licenses in their respective folders"
If Not @Compiled Then ;If running from a development environment,
	Global $DevMode = 1 ;Enable developer and debug features
ElseIf @Compiled Then ;Else if running from a compiled executable,
	Global $DevMode = 0 ;Disable developer and debug features
EndIf

FileInstall(".\Bass.dll", ".\Bass.dll")
FileInstall(".\BassTags.dll", ".\BassTags.dll")
FileInstall(".\changelog.txt", ".\changelog.txt")
If Not FileExists(".\assets\") Then
	DirCreate(".\assets\")
	DirCreate(".\assets\themes\")
	DirCreate(".\assets\themes\dark\")
	DirCreate(".\assets\themes\light\")
	DirCreate(".\assets\themes\nolan\")
ElseIf Not FileExists(".\assets\themes\") Then
	DirCreate(".\assets\themes\")
	DirCreate(".\assets\themes\dark\")
	DirCreate(".\assets\themes\light\")
	DirCreate(".\assets\themes\nolan\")
EndIf

;File formats to use for adding files
Global Const $FileFormatFilter = "All Media (*.mp1;*.mp2;*.mp3;*.wav;*.wma;*.ogg;*.aiff;*.avi;*.mpg;*.wmv;*.mov;*.3gp;*.asf;*.mp4;*.flv;*.rv)|Audio (*.mp1;*.mp2;*.mp3;*.wav;*.wma;*.ogg;*.aiff)|Video (*.avi;*.mpg;*.wmv;*.mov;*.3gp;*.asf;*.mp4;*.flv;*.rv)"
Global Const $ImportPlaylistFormatFilter = "Playlist (*.m3u;*.m3u8;*.xspf)"
Global Const $ExportPlaylistFormatFilter = "Playlist (*.m3u;*.m3u8)"
#EndRegion ;Program constants and statics

#Region ;Program variables for global usage
;An array of all debug logs
Global $aLogs[0]
;An array of the following: [Playlist track number][File location, media stream handle, whether media is ready, [if audio] track number, [if audio] artist, [if audio] title, [if audio] album, [if audio] album year, media status, playlist handle, album art]
Global $aPlaylist[0][11]
;An array of all notifications: [Notification number][Date, Time, Text]
Global $aNotifications[0][3]
;HotKeySet("G", "z_Playlist_ToggleDev")
HotKeySet("^f", "z_Child_YouTubeSearch")
Global $sRegistryLocation = "HKEY_CURRENT_USER\Software\JoshuaDoes\zPlayer" ;Registry location for saving values
;A map of all current settings
Global $mSettings[]

;Custom window title handling
;$mSettings["Window Title"] = $Program_Title & " Build " & String($Program_Build)
$mSettings["Window Title"] = LoadOption($sRegistryLocation, "Window Title", "%PROGRAM_TITLE% Build %PROGRAM_BUILD%")
$mSettings["Window Title"] = StringReplace($mSettings["Window Title"], "%PROGRAM_TITLE%", $Program_Title)
$mSettings["Window Title"] = StringReplace($mSettings["Window Title"], "%PROGRAM_BUILD%", $Program_Build)

$mSettings["Volume"] = LoadOption($sRegistryLocation, "Volume", 100) ;Set the volume setting
$mSettings["Random"] = LoadOption($sRegistryLocation, "Random", False) ;Whether to play a random track in the playlist or not
$mSettings["Repeat"] = LoadOption($sRegistryLocation, "Repeat", False) ;Whether to repeat the playlist or not
$mSettings["Hidden Themes"] = LoadOption($sRegistryLocation, "Hidden Themes", False) ;Whether to include hidden directories or not in the list of themes
$mSettings["Size State"] = LoadOption($sRegistryLocation, "Size State", 0) ;0=Normal, 1=Maximized
$mSettings["Client Width"] = LoadOption($sRegistryLocation, "Client Width", 800) ;GUI initial width
$mSettings["Client Height"] = LoadOption($sRegistryLocation, "Client Height", 400) ;GUI initial height
$mSettings["Client X"] = LoadOption($sRegistryLocation, "Client X", ((@DesktopWidth / 2) - ($mSettings["Client Width"] / 2))) ;GUI initial X position
$mSettings["Client Y"] = LoadOption($sRegistryLocation, "Client Y", ((@DesktopHeight / 2) - ($mSettings["Client Height"] / 2))) ;GUI initial Y position

;Other globals
Global $sCurrentTheme = LoadOption($sRegistryLocation, "Theme", "dark") ;Current theme in use
Global $iCurrentTrack = 0 ;Current track number in the playlist
Global $iCurrentGUI = 0 ;Current child GUI being displayed
Global $bDoubleClick = False

;Media stuff (not currently in use)
Global $hStream = Null ;Main stream
#EndRegion ;Program variables for global usage

#Region ;Initialize everything
Global $ThemesDir = LoadOption($sRegistryLocation, "Themes Directory", @ScriptDir & "\assets\themes") ;Directory to scan for themes in
If Not FileExists($ThemesDir) Then
	Local $hDirCreate = DirCreate($ThemesDir)
	If @error Then
		$ThemesDir = @ScriptDir & "\assets\themes"
		If Not FileExists($ThemesDir) Then DirCreate($ThemesDir)
	EndIf
	DirCreate($ThemesDir & "\dark")
	DirCreate($ThemesDir & "\light")
	DirCreate($ThemesDir & "\nolan")
EndIf
Global $Theme[] ;A map of themes, each theme being a map of icons and settings

#Region ;Extract themes
FileInstall(".\assets\themes\dark\theme.properties", $ThemesDir & "\dark\theme.properties")
FileInstall(".\assets\themes\dark\zPlayer.ico", $ThemesDir & "\dark\zPlayer.ico")
FileInstall(".\assets\themes\dark\Add CD.ico", $ThemesDir & "\dark\Add CD.ico")
FileInstall(".\assets\themes\dark\Add File.ico", $ThemesDir & "\dark\Add File.ico")
FileInstall(".\assets\themes\dark\Add Link.ico", $ThemesDir & "\dark\Add Link.ico")
FileInstall(".\assets\themes\dark\Delete.ico", $ThemesDir & "\dark\Delete.ico")
FileInstall(".\assets\themes\dark\Export Playlist.ico", $ThemesDir & "\dark\Export Playlist.ico")
FileInstall(".\assets\themes\dark\File.ico", $ThemesDir & "\dark\File.ico")
FileInstall(".\assets\themes\dark\Hibernate.ico", $ThemesDir & "\dark\Hibernate.ico")
FileInstall(".\assets\themes\dark\Import Playlist.ico", $ThemesDir & "\dark\Import Playlist.ico")
FileInstall(".\assets\themes\dark\Maximize Window.ico", $ThemesDir & "\dark\Maximize Window.ico")
FileInstall(".\assets\themes\dark\Minimize Window.ico", $ThemesDir & "\dark\Minimize Window.ico")
FileInstall(".\assets\themes\dark\Next.ico", $ThemesDir & "\dark\Next.ico")
FileInstall(".\assets\themes\dark\Pause.ico", $ThemesDir & "\dark\Pause.ico")
FileInstall(".\assets\themes\dark\Play.ico", $ThemesDir & "\dark\Play.ico")
FileInstall(".\assets\themes\dark\Playlist.ico", $ThemesDir & "\dark\Playlist.ico")
FileInstall(".\assets\themes\dark\Previous.ico", $ThemesDir & "\dark\Previous.ico")
FileInstall(".\assets\themes\dark\Random.ico", $ThemesDir & "\dark\Random.ico")
FileInstall(".\assets\themes\dark\Repeat.ico", $ThemesDir & "\dark\Repeat.ico")
FileInstall(".\assets\themes\dark\Restore Window.ico", $ThemesDir & "\dark\Restore Window.ico")
FileInstall(".\assets\themes\dark\Resume.ico", $ThemesDir & "\dark\Resume.ico")
FileInstall(".\assets\themes\dark\Save File.ico", $ThemesDir & "\dark\Save File.ico")
FileInstall(".\assets\themes\dark\Shutdown.ico", $ThemesDir & "\dark\Shutdown.ico")
FileInstall(".\assets\themes\dark\Stop.ico", $ThemesDir & "\dark\Stop.ico")
FileInstall(".\assets\themes\dark\Theme.ico", $ThemesDir & "\dark\Theme.ico")
FileInstall(".\assets\themes\dark\YouTube.ico", $ThemesDir & "\dark\YouTube.ico")
FileInstall(".\assets\themes\dark\Notifications.ico", $ThemesDir & "\dark\Notifications.ico")
FileInstall(".\assets\themes\dark\Settings.ico", $ThemesDir & "\dark\Settings.ico")
FileInstall(".\assets\themes\dark\View.ico", $ThemesDir & "\dark\View.ico")
FileInstall(".\assets\themes\light\theme.properties", $ThemesDir & "\light\theme.properties")
FileInstall(".\assets\themes\light\zPlayer.ico", $ThemesDir & "\light\zPlayer.ico")
FileInstall(".\assets\themes\light\Add CD.ico", $ThemesDir & "\light\Add CD.ico")
FileInstall(".\assets\themes\light\Add File.ico", $ThemesDir & "\light\Add File.ico")
FileInstall(".\assets\themes\light\Add Link.ico", $ThemesDir & "\light\Add Link.ico")
FileInstall(".\assets\themes\light\Delete.ico", $ThemesDir & "\light\Delete.ico")
FileInstall(".\assets\themes\light\Export Playlist.ico", $ThemesDir & "\light\Export Playlist.ico")
FileInstall(".\assets\themes\light\File.ico", $ThemesDir & "\light\File.ico")
FileInstall(".\assets\themes\light\Hibernate.ico", $ThemesDir & "\light\Hibernate.ico")
FileInstall(".\assets\themes\light\Import Playlist.ico", $ThemesDir & "\light\Import Playlist.ico")
FileInstall(".\assets\themes\light\Maximize Window.ico", $ThemesDir & "\light\Maximize Window.ico")
FileInstall(".\assets\themes\light\Minimize Window.ico", $ThemesDir & "\light\Minimize Window.ico")
FileInstall(".\assets\themes\light\Next.ico", $ThemesDir & "\light\Next.ico")
FileInstall(".\assets\themes\light\Pause.ico", $ThemesDir & "\light\Pause.ico")
FileInstall(".\assets\themes\light\Play.ico", $ThemesDir & "\light\Play.ico")
FileInstall(".\assets\themes\light\Playlist.ico", $ThemesDir & "\light\Playlist.ico")
FileInstall(".\assets\themes\light\Previous.ico", $ThemesDir & "\light\Previous.ico")
FileInstall(".\assets\themes\light\Random.ico", $ThemesDir & "\light\Random.ico")
FileInstall(".\assets\themes\light\Repeat.ico", $ThemesDir & "\light\Repeat.ico")
FileInstall(".\assets\themes\light\Restore Window.ico", $ThemesDir & "\light\Restore Window.ico")
FileInstall(".\assets\themes\light\Resume.ico", $ThemesDir & "\light\Resume.ico")
FileInstall(".\assets\themes\light\Save File.ico", $ThemesDir & "\light\Save File.ico")
FileInstall(".\assets\themes\light\Shutdown.ico", $ThemesDir & "\light\Shutdown.ico")
FileInstall(".\assets\themes\light\Stop.ico", $ThemesDir & "\light\Stop.ico")
FileInstall(".\assets\themes\light\Theme.ico", $ThemesDir & "\light\Theme.ico")
FileInstall(".\assets\themes\light\YouTube.ico", $ThemesDir & "\light\YouTube.ico")
FileInstall(".\assets\themes\light\Notifications.ico", $ThemesDir & "\light\Notifications.ico")
FileInstall(".\assets\themes\light\Settings.ico", $ThemesDir & "\light\Settings.ico")
FileInstall(".\assets\themes\light\View.ico", $ThemesDir & "\light\View.ico")
FileInstall(".\assets\themes\nolan\theme.properties", $ThemesDir & "\nolan\theme.properties")
FileInstall(".\assets\themes\nolan\zPlayer.ico", $ThemesDir & "\nolan\zPlayer.ico")
FileInstall(".\assets\themes\nolan\Add CD.ico", $ThemesDir & "\nolan\Add CD.ico")
FileInstall(".\assets\themes\nolan\Add File.ico", $ThemesDir & "\nolan\Add File.ico")
FileInstall(".\assets\themes\nolan\Add Link.ico", $ThemesDir & "\nolan\Add Link.ico")
FileInstall(".\assets\themes\nolan\Delete.ico", $ThemesDir & "\nolan\Delete.ico")
FileInstall(".\assets\themes\nolan\Export Playlist.ico", $ThemesDir & "\nolan\Export Playlist.ico")
FileInstall(".\assets\themes\nolan\File.ico", $ThemesDir & "\nolan\File.ico")
FileInstall(".\assets\themes\nolan\Hibernate.ico", $ThemesDir & "\nolan\Hibernate.ico")
FileInstall(".\assets\themes\nolan\Import Playlist.ico", $ThemesDir & "\nolan\Import Playlist.ico")
FileInstall(".\assets\themes\nolan\Maximize Window.ico", $ThemesDir & "\nolan\Maximize Window.ico")
FileInstall(".\assets\themes\nolan\Minimize Window.ico", $ThemesDir & "\nolan\Minimize Window.ico")
FileInstall(".\assets\themes\nolan\Next.ico", $ThemesDir & "\nolan\Next.ico")
FileInstall(".\assets\themes\nolan\Pause.ico", $ThemesDir & "\nolan\Pause.ico")
FileInstall(".\assets\themes\nolan\Play.ico", $ThemesDir & "\nolan\Play.ico")
FileInstall(".\assets\themes\nolan\Playlist.ico", $ThemesDir & "\nolan\Playlist.ico")
FileInstall(".\assets\themes\nolan\Previous.ico", $ThemesDir & "\nolan\Previous.ico")
FileInstall(".\assets\themes\nolan\Random.ico", $ThemesDir & "\nolan\Random.ico")
FileInstall(".\assets\themes\nolan\Repeat.ico", $ThemesDir & "\nolan\Repeat.ico")
FileInstall(".\assets\themes\nolan\Restore Window.ico", $ThemesDir & "\nolan\Restore Window.ico")
FileInstall(".\assets\themes\nolan\Resume.ico", $ThemesDir & "\nolan\Resume.ico")
FileInstall(".\assets\themes\nolan\Save File.ico", $ThemesDir & "\nolan\Save File.ico")
FileInstall(".\assets\themes\nolan\Shutdown.ico", $ThemesDir & "\nolan\Shutdown.ico")
FileInstall(".\assets\themes\nolan\Stop.ico", $ThemesDir & "\nolan\Stop.ico")
FileInstall(".\assets\themes\nolan\Theme.ico", $ThemesDir & "\nolan\Theme.ico")
FileInstall(".\assets\themes\nolan\YouTube.ico", $ThemesDir & "\nolan\YouTube.ico")
FileInstall(".\assets\themes\nolan\Notifications.ico", $ThemesDir & "\nolan\Notifications.ico")
FileInstall(".\assets\themes\nolan\Settings.ico", $ThemesDir & "\nolan\Settings.ico")
FileInstall(".\assets\themes\nolan\View.ico", $ThemesDir & "\nolan\View.ico")
#EndRegion ;Extract themes

$Theme = z_LoadThemes($ThemesDir, $Theme)
If Not IsMap($Theme) Then
	MsgBox(0, $Program_Title & " - " & $Program_Build & " | ERROR", "There was an error attempting to find the default and/or custom themes. Make sure `" & $ThemesDir & "` is accessible to zPlayer and try again. If the error persists, delete the folder `" & $ThemesDir & "` and try again so that zPlayer may attempt to install the default themes." & @CRLF)
	Exit
EndIf

If Not MapExists($Theme, $sCurrentTheme) Then
	$aThemes = MapKeys($Theme)
	$sCurrentTheme = $aThemes[0]
EndIf

_GDIPlus_Startup()
If @error Then
	MsgBox(0, $Program_Title & " - " & $Program_Build & " | ERROR", "There was an error starting the GDI+ library.")
	Exit
EndIf

$GUI_Main_Handle = GUICreate($mSettings["Window Title"], 800, 400, ((@DesktopWidth / 2) - 400), ((@DesktopHeight / 2) - 200), BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX)) ;Create the main GUI
GUISetBkColor($Theme[$sCurrentTheme]["Settings_BackgroundColor"], $GUI_Main_Handle) ;Set the background color of the main GUI
_GUI_EnableDragAndResize($GUI_Main_Handle, 800, 400, 750, 200, False) ;Make the GUI resizeable and set the minimum resize limit

$GUI_Title_Handle = GUICtrlCreateLabel($mSettings["Window Title"], 0, 0, 800, 15, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetResizing($GUI_Title_Handle, $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_Title_Handle, 9, 0, 0, "Segoe UI")
$GUI_Notification_Handle = GUICtrlCreateLabel("", 2, 310, 776, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_Notification_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetFont($GUI_Notification_Handle, 9, 0, 0, "Segoe UI")
$GUI_ID3Tags_Handle = GUICtrlCreateLabel("No audio track is queued.", 2, 327, 796, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_ID3Tags_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetFont($GUI_ID3Tags_Handle, 9, 0, 0, "Segoe UI")
$GUI_VolumeSlider_Handle = GUICtrlCreateSlider(22, 363, 200, 20, $TBS_NOTICKS)
GUICtrlSetResizing($GUI_VolumeSlider_Handle, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetLimit($GUI_VolumeSlider_Handle, 100, 0)
GUICtrlSetData($GUI_VolumeSlider_Handle, $mSettings["Volume"])
GUICtrlSetBkColor($GUI_VolumeSlider_Handle, $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
$GUI_VolumeCounter_Handle = GUICtrlCreateLabel($mSettings["Volume"], 2, 365, 20, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_VolumeCounter_Handle, $GUI_DOCKleft + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_VolumeCounter_Handle, 9, 0, 0, "Segoe UI")
$GUI_AudioPositionSlider_Handle = GUICtrlCreateSlider(47, 344, 705, 20, $TBS_NOTICKS)
GUICtrlSetResizing($GUI_AudioPositionSlider_Handle, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetBkColor($GUI_AudioPositionSlider_Handle, $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, 0)
$GUI_AudioPosition_Handle = GUICtrlCreateLabel("00:00:00", 2, 349, 45, 15)
GUICtrlSetResizing($GUI_AudioPosition_Handle, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_AudioPosition_Handle, 9, 0, 0, "Segoe UI")
$GUI_AudioLength_Handle = GUICtrlCreateLabel("00:00:00", 755, 349, 45, 15)
GUICtrlSetResizing($GUI_AudioLength_Handle, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_AudioLength_Handle, 9, 0, 0, "Segoe UI")
$GUI_TrackPosition_Handle = GUICtrlCreateLabel("No tracks in the playlist.", 2, 383, 344, 15)
GUICtrlSetResizing($GUI_TrackPosition_Handle, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_TrackPosition_Handle, 9, 0, 0, "Segoe UI")

$GUI_Logo_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Logo"], -1, 766, 366, 32, 32) ;Create the logo
GUICtrlSetResizing($GUI_Logo_Handle, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetOnEvent($GUI_Logo_Handle, "z_Child_OpenAbout")
$GUI_AddFile_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["AddFile"], -1, 2, 17, 32, 32) ;Create the "Add File" button
GUICtrlSetResizing($GUI_AddFile_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddFile_Handle, "z_Playlist_AddFile")
$GUI_AddCD_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["AddCD"], -1, 38, 17, 32, 32) ;Create the "Add CD" button
GUICtrlSetResizing($GUI_AddCD_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddCD_Handle, "z_Child_OpenCD")
$GUI_AddURL_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["AddURL"], -1, 74, 17, 32, 32) ;Create the "Add URL" button
GUICtrlSetResizing($GUI_AddURL_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddURL_Handle, "z_Playlist_AddURL")
$GUI_PlaylistImport_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["PlaylistImport"], -1, 110, 17, 32, 32) ;Create the "Import Playlist" button
GUICtrlSetResizing($GUI_PlaylistImport_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_PlaylistImport_Handle, "z_Playlist_Import")
$GUI_PlaylistExport_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["PlaylistExport"], -1, 146, 17, 32, 32) ;Create the "Export Playlist" button
GUICtrlSetResizing($GUI_PlaylistExport_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_PlaylistExport_Handle, "z_Playlist_Export")
$GUI_View_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["View"], -1, 2, 51, 32, 32) ;Create the "View" button
GUICtrlSetResizing($GUI_View_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_View_Handle, "z_Child_OpenView")
$GUI_Playlist_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Playlist"], -1, 38, 51, 32, 32) ;Create the "Playlist" button
GUICtrlSetResizing($GUI_Playlist_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Playlist_Handle, "z_Child_OpenPlaylist")
$GUI_ThemeManagement_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Theme"], -1, 74, 51, 32, 32) ;Create the "Theme Management" button
GUICtrlSetResizing($GUI_ThemeManagement_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_ThemeManagement_Handle, "z_Child_OpenTheme")
$GUI_Notifications_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Notifications"], -1, 110, 51, 32, 32) ;Create the "Notifications" button
GUICtrlSetResizing($GUI_Notifications_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Notifications_Handle, "z_Child_OpenNotifications")
$GUI_Settings_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Settings"], -1, 146, 51, 32, 32) ;Create the "Settings" button
GUICtrlSetResizing($GUI_Settings_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Settings_Handle, "z_Child_OpenSettings")
$GUI_ServiceIdentify_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Fill"], -1, 384, 17, 32, 32) ;Create the "Service Identifier" button
GUICtrlSetResizing($GUI_ServiceIdentify_Handle, $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_ServiceIdentify_Handle, "z_Service_OpenURL")
$GUI_Minimize_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Minimize"], -1, 694, 17, 32, 32) ;Create the "Minimize" button
GUICtrlSetResizing($GUI_Minimize_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Minimize_Handle, "z_Minimize")
$GUI_Size_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Maximize"], -1, 730, 17, 32, 32) ;Create the "Maximize/Restore" button
GUICtrlSetResizing($GUI_Size_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Size_Handle, "z_MaximizeRestore")
$GUI_Hibernate_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Hibernate"], -1, 658, 17, 32, 32) ;Create the "Hibernate" button
GUICtrlSetResizing($GUI_Hibernate_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Hibernate_Handle, "z_Hibernate")
$GUI_Shutdown_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Shutdown"], -1, 766, 17, 32, 32) ;Create the "Shutdown" button
GUICtrlSetResizing($GUI_Shutdown_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Shutdown_Handle, "z_Shutdown")
$GUI_Previous_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Previous"], -1, 348, 366, 32, 32) ;Create the "Previous" button
GUICtrlSetResizing($GUI_Previous_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Previous_Handle, "z_Playback_Previous")
$GUI_PlayPauseResume_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Play"], -1, 384, 366, 32, 32) ;Create the "Play" button
GUICtrlSetResizing($GUI_PlayPauseResume_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_PlayPauseResume_Handle, "z_Playback_PlayPauseResume")
$GUI_Next_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Next"], -1, 420, 366, 32, 32) ;Create the "Next" button
GUICtrlSetResizing($GUI_Next_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Next_Handle, "z_Playback_Next")
$GUI_Stop_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Stop"], -1, 456, 366, 32, 32) ;Create the "Stop" button
GUICtrlSetResizing($GUI_Stop_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Stop_Handle, "z_Playback_Stop")
$GUI_Delete_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Delete"], -1, 300, 366, 32, 32) ;Create the "Delete Selected Playlist Entry" button
GUICtrlSetResizing($GUI_Delete_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Delete_Handle, "z_Playlist_DeleteEntry")
$GUI_Random_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Random"], -1, 490, 366, 32, 32) ;Create the "Random" button
GUICtrlSetResizing($GUI_Random_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Random_Handle, "z_Playlist_ToggleRandom")
$GUI_Repeat_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["Repeat"], -1, 524, 366, 32, 32) ;Create the "Repeat" button
GUICtrlSetResizing($GUI_Repeat_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Repeat_Handle, "z_Playlist_ToggleRepeat")
$GUI_SaveFile_Handle = GUICtrlCreateIcon($Theme[$sCurrentTheme]["SaveFile"], -1, 266, 366, 32, 32) ;Create the "Save File" button
GUICtrlSetResizing($GUI_SaveFile_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_SaveFile_Handle, "z_Playback_SaveFile")

Global $GUI_Child[1]
$GUI_Child[0] = Null
Global $hItem = Null

z_OpenChildGUI(LoadOption($sRegistryLocation, "Child Interface", 7)) ;Open the playlist by default

If $DevMode Then z_Notification("DEVMODE_MEMORY_LARGE")

_BASS_STARTUP(@ScriptDir & "\BASS.dll")
_BASS_Init(0, -1, 48000)
If @error Then
	z_Notification("BASS_INIT_FAILED", @error)
EndIf

_Bass_Tags_Startup(@ScriptDir & "\BassTags.dll")
If @error Then
	z_Notification("BASSTAGS_INIT_FAILED", @error)
EndIf

;DSEngine_Startup()
;If @error Then
;	z_Notification("DIRECTSHOW_INIT_FAILED", @error)
;EndIf

If $CmdLine[0] > 0 Then
	For $i = 1 To $CmdLine[0]
		If ProcessExists(@ScriptFullPath) Then
			;Inject the tracks into the current process
			;Plan: Implement a localhost-only server
			;	- Delete pre-existing .lock file if it exists and start server on startup
			;	- Bind to random port
			;	- Write port to .lock file and make .lock file hidden
			;	- Keep a handle open for .lock file to lock it so it cannot be modified until zPlayer closes
			;	- Close server and delete .lock file on shutdown
			;
			;	- If zPlayer is already open, attempt to connect on port specified in .lock and send playlist data
			;		- Current zPlayer will bring itself to main focus at this point
			;			If FileExists(".lock") Then
			;				Local $iPort = Number(FileRead(".lock"))
			;				If Not IsNumber($iPort) Then
			;					Local $GUI_Main_Handle = GUICreate($mSettings["Window Title"],
		Else
			If FileExists(@ScriptDir & "\hiberfil.m3u") Then
				FileDelete(@ScriptDir & "\hiberfil.m3u")
			EndIf
			If StringRight($CmdLine[$i], 4) = ".m3u" Or StringRight($CmdLine[$i], 5) = ".m3u8" Or StringRight($CmdLine[$i], 5) = ".xspf" Then
				z_Playlist_Import_Internal($CmdLine[$i])
			ElseIf StringInStr($CmdLine[$i], "http://", 0, 1, 1) Or StringInStr($CmdLine[$i], "https://", 0, 1, 1) Or StringInStr($CmdLine[$i], "ftp://", 0, 1, 1) Then
				z_Playlist_AddURL_Internal($CmdLine[$i])
			ElseIf FileExists($CmdLine[$i]) Then
				z_Playlist_AddFile_Internal($CmdLine[$i])
			EndIf
		EndIf
	Next
EndIf

OnAutoItExitRegister("z_Close")

GUISetState(@SW_SHOW, $GUI_Main_Handle) ;Bring it to life
_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))

If FileExists(@ScriptDir & "\hiberfil.m3u") Then
	z_Playlist_Import_Internal(@ScriptDir & "\hiberfil.m3u")
	FileDelete(@ScriptDir & "\hiberfil.m3u")
EndIf

HotKeySet("{MEDIA_PLAY_PAUSE}", "z_Playback_PlayPauseResume")
HotKeySet("{MEDIA_STOP}", "z_Playback_Stop")
HotKeySet("{MEDIA_PREV}", "z_Playback_Previous")
HotKeySet("{MEDIA_NEXT}", "z_Playback_Next")

AdlibRegister("z_Timer_AudioPosition", 100)
AdlibRegister("z_Timer_VolumePosition", 100)
#EndRegion ;Initialize everything

While 1
	If WinActive($GUI_Main_Handle) Then
		Local $mgetinfo = MouseGetCursor()
		Local $aMouseInfo = GUIGetCursorInfo($GUI_Main_Handle)
		If ($mgetinfo = 12) Or ($mgetinfo = 11) Or ($mgetinfo = 10) Or ($mgetinfo = 13) Then
			If Not ($aMouseInfo[4] = 0) Then GUISetCursor(2, 1)
		EndIf

		If $mSettings["Size State"] Then
			If WinGetState($GUI_Main_Handle) = 15 Then
				z_MaximizeRestore()
			EndIf
		ElseIf Not $mSettings["Size State"] Then
			If WinGetState($GUI_Main_Handle) = 47 Then
				z_MaximizeRestore()
			EndIf
		EndIf

		If Not _IsPressed(1) Or _IsPressed(2) Then _WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
	EndIf

	If UBound($aPlaylist) Then
		If $aPlaylist[$iCurrentTrack][8] = 1 Then
			If z_Audio_GetPosition(True) >= z_Audio_GetLength(True) Then
				z_Playback_Next()
			EndIf
		EndIf
	EndIf
WEnd

#Region ;All script functions
;Debug logging and how to handle it
Func z_Debug($sParentName, $sDebugMessage)
	Local $sLog = "[" & @MON & "/" & @MDAY & "/" & @YEAR & "][" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "][" & $sParentName & "]: " & $sDebugMessage
	Local $sLogFile = @ScriptDir & "\zPlayer-" & @MON & "-" & @MDAY & "-" & @YEAR & ".log"
	If $DevMode Then
		ConsoleWrite($sLog & @CRLF)
	EndIf
	ReDim $aLogs[(UBound($aLogs) + 1)]
	$aLogs[(UBound($aLogs) - 1)] = $sLog
	FileWrite($sLogFile, $sLog & @CRLF)
EndFunc   ;==>z_Debug

;Playlist management
Func z_Playlist_AddFile()
	Local $sNewFileLocation = FileOpenDialog("Select a media file...", @UserProfileDir & "\Music", $FileFormatFilter, BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT), "", $GUI_Main_Handle)
	If @error Then ;At least one file was not selected
		Switch @error
			Case 1 ;No file selected, user cancelled dialog box
				z_Notification("NO_FILE")
			Case 2 ;File filter is prepared incorrectly
				z_Notification("INTERNAL_FILE_FILTER")
		EndSwitch
		Return SetError(1, 0, False)
	EndIf
	Local $aNewFileLocations = StringSplit($sNewFileLocation, "|") ;Split the input
	If @error Then ;Only one file was selected, continue handling the original input
		z_Playlist_AddFile_Internal($sNewFileLocation)
	Else ;Multiple files were selected, handle the new array
		For $i = 2 To $aNewFileLocations[0] ;Go through all the files selected
			z_Playlist_AddFile_Internal($aNewFileLocations[1] & "\" & $aNewFileLocations[$i])
		Next
	EndIf
	z_Service_Identify()
	z_DataUpdate()
	AdlibRegister("z_DataUpdate", 1000)
EndFunc   ;==>z_Playlist_AddFile
Func z_Playlist_AddURL()
	If Not _IsInternetConnected() Then
		z_Notification("NO_INTERNET")
	Else
		Local $sTempClipboard = ""
		If StringInStr(ClipGet(), "http://", 0, 1, 1) Or StringInStr(ClipGet(), "https://", 0, 1, 1) Or StringInStr(ClipGet(), "ftp://", 0, 1, 1) Then
			$sTempClipboard = ClipGet()
		EndIf
		Local $sNewFileLocation = InputBox("Enter a network URL to an audio file or audio stream...", "Please enter a network URL to an audio file or audio stream below." & @CRLF & @CRLF & "Supported URIs: http:// | https:// | ftp://", $sTempClipboard, " M")
		If Not $sNewFileLocation Then Return
		z_Playlist_AddURL_Internal($sNewFileLocation)
		z_Service_Identify()
		z_DataUpdate()
		AdlibRegister("z_DataUpdate", 1000)
	EndIf
EndFunc   ;==>z_Playlist_AddURL
Func z_Playlist_AddFile_Internal($sFile)
	Local $sNewFileLocation = $sFile
	Local $iNewEntryCount = UBound($aPlaylist) + 1
	Local $iEntryPosition = UBound($aPlaylist)
	ReDim $aPlaylist[$iNewEntryCount][11] ;Add a new entry to the playlist
	$aPlaylist[$iEntryPosition][0] = $sNewFileLocation ;The location of the audio file
	If z_DataCheck_ContainsAudioExtension($aPlaylist[$iEntryPosition][0]) Then
		$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateFile(False, $aPlaylist[$iEntryPosition][0], 0, 0, $BASS_MUSIC_PRESCAN) ;The stream to use for playing the audio
		If @error Then
			Switch @error
				Case $BASS_ERROR_FILEOPEN
					z_Notification("ERROR_OPENING_FILE")
				Case $BASS_ERROR_FILEFORM
					z_Notification("ERROR_FILE_FORMAT")
				Case $BASS_ERROR_CODEC
					z_Notification("ERROR_AUDIO_CODEC")
				Case $BASS_ERROR_FORMAT
					z_Notification("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
				Case $BASS_ERROR_MEM
					z_Notification("ERROR_NOT_ENOUGH_MEMORY")
				Case $BASS_ERROR_SPEAKER
					z_Notification("UNAVAILABLE_SPEAKER")
				Case $BASS_ERROR_UNKNOWN
					z_Notification("ERROR_UNKNOWN")
				Case Else
					z_Notification("ERROR_UNKNOWN")
			EndSwitch
			ReDim $aPlaylist[$iEntryPosition][11] ;Remove the new entry from the playlist
			Return SetError(1, 0, False)
		EndIf
		$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
		$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,)") ;The track number within the album
		$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,)") ;The artist who made the track
		$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,)") ;The title of the track
		$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,)") ;The album the track belongs to
		$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,)") ;The year of the track's release
		$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
	ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iEntryPosition][0]) Then
		z_Playback_Stop()
		$iCurrentTrack = $iEntryPosition
		z_Child_OpenView()
	EndIf
	z_Service_Identify()
	z_DataUpdate()
	If $iCurrentGUI = 3 Then
		ReDim $GUI_Child[UBound($GUI_Child) + 1]
		$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($iEntryPosition + 1) & Chr(1) & $aPlaylist[$iEntryPosition][4] & Chr(1) & $aPlaylist[$iEntryPosition][5] & Chr(1) & $aPlaylist[$iEntryPosition][6] & Chr(1) & $aPlaylist[$iEntryPosition][3] & Chr(1) & $aPlaylist[$iEntryPosition][7] & Chr(1) & $aPlaylist[$iEntryPosition][0], $GUI_Child[0])
		$aPlaylist[$iEntryPosition][9] = $GUI_Child[UBound($GUI_Child) - 1]
		GUICtrlSetOnEvent($aPlaylist[$iEntryPosition][9], "z_Child_PlaylistEvent")
	EndIf
	AdlibRegister("z_DataUpdate", 1000)
EndFunc   ;==>z_Playlist_AddFile_Internal
Func z_Playlist_AddURL_Internal($sURL)
	If Not _IsInternetConnected() Then
		z_Notification("NO_INTERNET")
	ElseIf Not $sURL Then
		Return SetError(1, 0, False)
	Else
		$sNewFileLocation = $sURL
		If StringInStr($sNewFileLocation, "http://", 0, 1, 1) Or StringInStr($sNewFileLocation, "https://", 0, 1, 1) Or StringInStr($sNewFileLocation, "ftp://", 0, 1, 1) Then
			;Local $sTempLocation = _TempFile(@TempDir & "/zPlayer/", "", "", 20)
			Local $iNewEntryCount = UBound($aPlaylist) + 1
			Local $iEntryPosition = UBound($aPlaylist)
			ReDim $aPlaylist[$iNewEntryCount][11] ;Add a new entry to the playlist
			$aPlaylist[$iEntryPosition][0] = $sNewFileLocation ;The location of the file
			If StringInStr($sNewFileLocation, "youtube.com/watch?v=", 0, 1) Then
				;Temporarily this is going to stick to the roots of MP3 playback until YouTube-DL is incorporated
				$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL("http://www.youtubeinmp3.com/fetch/?video=" & $sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
				If @error Then
					Switch @error
						Case $BASS_ERROR_NONET
							z_Notification("ERROR_NO_CONNECTION")
						Case $BASS_ERROR_ILLPARAM
							z_Notification("ERROR_INVALID_URL")
						Case $BASS_ERROR_TIMEOUT
							z_Notification("ERROR_TIMEOUT")
						Case $BASS_ERROR_FILEOPEN
							z_Notification("ERROR_OPENING_FILE")
						Case $BASS_ERROR_FILEFORM
							z_Notification("ERROR_FILE_FORMAT")
							ConsoleWrite($sNewFileLocation & @CRLF)
						Case $BASS_ERROR_CODEC
							z_Notification("ERROR_AUDIO_CODEC")
						Case $BASS_ERROR_FORMAT
							z_Notification("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
						Case $BASS_ERROR_MEM
							z_Notification("ERROR_NOT_ENOUGH_MEMORY")
						Case $BASS_ERROR_UNKNOWN
							z_Notification("ERROR_UNKNOWN")
					EndSwitch
					ReDim $aPlaylist[$iEntryPosition][11] ;Remove the new entry from the playlist
					Return SetError(1, 0, False)
				EndIf
				If $aPlaylist[$iEntryPosition][1] = 0 Then
					Local $iCountOut = 0
					Do
						$iCountOut += 1
						$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL("http://www.youtubeinmp3.com/fetch/?video=" & $sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
					Until $aPlaylist[$iEntryPosition][1] > 0 Or $iCountOut >= 5
					If $iCountOut >= 5 Then
						z_Notification("YOUTUBE_FAILED", 5)
						ReDim $aPlaylist[$iEntryPosition][11] ;Remove the new entry from the playlist
						Return SetError(1, 0, False)
					EndIf
				EndIf
				$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
				$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,)") ;The track number within the album
				$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,)") ;The artist who made the track
				$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,)") ;The title of the track
				$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,)") ;The album the track belongs to
				$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,)") ;The year of the track's release
				$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
			ElseIf StringInStr($aPlaylist[$iEntryPosition][0], "youtube.com/playlist?list=") Then
				Local $sPlaylistID = StringRight($aPlaylist[$iEntryPosition][0], 34) ;As far as I can tell, the character count is consistent across all playlists
				Local $aSearchResults = YouTube_Playlist_GetVideos("AIzaSyAac-x77uNVpTCpsXkxF-wH9CRVnAqGk6c", $sPlaylistID, 50)
				If @error Then
					Switch @error
						Case 1
							z_Notification("YT_PLAYLIST_FAIL")
						Case 2
							z_Notification("YT_PLAYLIST_NOTFOUND")
						Case Else
							z_Notification("YT_PLAYLIST_FATAL_UNKNOWN")
					EndSwitch
				Else
					z_OpenChildGUI(8, True, $aSearchResults)
				EndIf
			ElseIf StringInStr($aPlaylist[$iEntryPosition][0], "soundcloud.com") Then
;				https://soundcloud.com/wahyusynth/jarrod-alonge-pray-for-progress-bring-me-the-horizon-parody
				Local $sSoundCloudHTML = BinaryToString(InetRead($aPlaylist[$iEntryPosition][0]))
				Local $aSoundCloud_Track = _StringBetween($sSoundCloudHTML, '"urn":"soundcloud:tracks:', '"')
				Local $sSoundCloud_Track = $aSoundCloud_Track[0]
				Local $aSoundCloud_Secret = _StringBetween($sSoundCloudHTML, '"secret_token":', ',')
				Local $sSoundCloud_Secret = $aSoundCloud_Secret[0]
				If $sSoundCloud_Secret = "null" Then $sSoundCloud_Secret = Null
				Local $aSoundCloud_Title = _StringBetween($sSoundCloudHTML, '"title":"', '"')
				Local $aSoundCloud_Album = _StringBetween($sSoundCloudHTML, '"album_title":"', '"')
				Local $aSoundCloud_Artist = _StringBetween($sSoundCloudHTML, '"username":"', '"')
				Local $aSoundCloud_ArtURL = _StringBetween($sSoundCloudHTML, '"artwork_url":"', '"')

				Local $sClientID = "2t9loNQH90kzJcsFCODdigxfp325aq4z"
				Local $sAppVersion = "1489155300"

				Local $sAPIQuery_URL = "https://api.soundcloud.com/i1/tracks/" & $sSoundCloud_Track
				$sAPIQuery_URL &= "/streams?client_id=" & $sClientID
				If $sAppVersion Then $sAPIQuery_URL &= "&app_version=" & $sAppVersion
				If $sSoundCloud_Secret Then $sAPIQuery_URL &= "&secret_token=" & $sSoundCloud_Secret

				Local $sAPIQuery = BinaryToString(InetRead($sAPIQuery_URL))
				If $sAPIQuery Then
					Local $aSoundCloud_URL = _StringBetween($sAPIQuery, '"http_mp3_128_url":"', '"')
					Local $sSoundCloud_URL = $aSoundCloud_URL[0]
					$sSoundCloud_URL = StringRegExpReplace($sSoundCloud_URL, "\\u0026", "&")

					$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL($sSoundCloud_URL, 0, $BASS_STREAM_RESTRATE)
					$aPlaylist[$iEntryPosition][2] = True
					If UBound($aSoundCloud_Artist) Then $aPlaylist[$iEntryPosition][4] = $aSoundCloud_Artist[0]
					If UBound($aSoundCloud_Title) Then $aPlaylist[$iEntryPosition][5] = $aSoundCloud_Title[0]
					If UBound($aSoundCloud_Album) Then $aPlaylist[$iEntryPosition][6] = $aSoundCloud_Album[0]
					$aPlaylist[$iEntryPosition][8] = 0
					;If UBound($aSoundCloud_ArtURL) Then $aPlaylist[$iEntryPosition][10] = $aSoundCloud_ArtURL[0]
				Else
					z_Notification("SOUNDCLOUD_FAIL")
				EndIf
			ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iEntryPosition][0]) Then
				$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL($sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
				If @error Then
					Switch @error
						Case $BASS_ERROR_NONET
							z_Notification("ERROR_NO_CONNECTION")
						Case $BASS_ERROR_ILLPARAM
							z_Notification("ERROR_INVALID_URL")
						Case $BASS_ERROR_TIMEOUT
							z_Notification("ERROR_TIMEOUT")
						Case $BASS_ERROR_FILEOPEN
							z_Notification("ERROR_OPENING_FILE")
						Case $BASS_ERROR_FILEFORM
							z_Notification("ERROR_FILE_FORMAT")
						Case $BASS_ERROR_CODEC
							z_Notification("ERROR_AUDIO_CODEC")
						Case $BASS_ERROR_FORMAT
							z_Notification("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
						Case $BASS_ERROR_MEM
							z_Notification("ERROR_NOT_ENOUGH_MEMORY")
						Case $BASS_ERROR_UNKNOWN
							z_Notification("ERROR_UNKNOWN")
					EndSwitch
					ReDim $aPlaylist[$iEntryPosition][11] ;Remove the new entry from the playlist
					Return SetError(1, 0, False)
				EndIf
				$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
				$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,)") ;The track number within the album
				$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,)") ;The artist who made the track
				$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,)") ;The title of the track
				$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,)") ;The album the track belongs to
				$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,)") ;The year of the track's release
				$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
			ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iEntryPosition][0]) Then
				;Add video to playlist and specify tags
			EndIf
		Else
			z_Notification("INVALID_URI")
			Return SetError(1, 0, False)
		EndIf
		z_Service_Identify()
		z_DataUpdate()
		If $iCurrentGUI = 3 Then
			ReDim $GUI_Child[UBound($GUI_Child) + 1]
			$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($iEntryPosition + 1) & Chr(1) & $aPlaylist[$iEntryPosition][4] & Chr(1) & $aPlaylist[$iEntryPosition][5] & Chr(1) & $aPlaylist[$iEntryPosition][6] & Chr(1) & $aPlaylist[$iEntryPosition][3] & Chr(1) & $aPlaylist[$iEntryPosition][7] & Chr(1) & $aPlaylist[$iEntryPosition][0], $GUI_Child[0])
			$aPlaylist[$iEntryPosition][9] = $GUI_Child[UBound($GUI_Child) - 1]
			GUICtrlSetOnEvent($aPlaylist[$iEntryPosition][9], "z_Child_PlaylistEvent")
		EndIf
		AdlibRegister("z_DataUpdate", 1000)
	EndIf
EndFunc   ;==>z_Playlist_AddURL_Internal
Func z_Playlist_Import()
	If _IsPressed(11) Then
		Local $sUsage = "Enter the URL to the YouTube playlist in which you wish to import." & @CRLF & @CRLF & _
						"At this time, only public playlists are supported."
		Local $sPlaylistURL = InputBox("YouTube Playlist Import", $sUsage, "", " M", 500, 160)
		;https://www.youtube.com/playlist?list=PLDJpD4kY8bkDzrxKi6dOGMJyxIOrnpvU1
		If $sPlaylistURL Then
			If StringInStr($sPlaylistURL, "youtube.com/playlist?list=") Then
				Local $sPlaylistID = StringRight($sPlaylistURL, 34) ;As far as I can tell, the character count is consistent across all playlists
				Local $aSearchResults = YouTube_Playlist_GetVideos("AIzaSyAac-x77uNVpTCpsXkxF-wH9CRVnAqGk6c", $sPlaylistID, 50)
				If @error Then
					Switch @error
						Case 1
							z_Notification("YT_PLAYLIST_FAIL")
						Case 2
							z_Notification("YT_PLAYLIST_NOTFOUND")
						Case Else
							z_Notification("YT_PLAYLIST_FATAL_UNKNOWN")
					EndSwitch
				Else
					z_OpenChildGUI(8, True, $aSearchResults)
				EndIf
			Else
				z_Notification("YT_PLAYLIST_INVALIDURL")
			EndIf
		EndIf
	Else
		Local $sFile = FileOpenDialog("Select a playlist...", @UserProfileDir & "\Music", $ImportPlaylistFormatFilter, $FD_FILEMUSTEXIST, "", $GUI_Main_Handle) ;Later I'll implement multiple playlists

		If Not FileExists($sFile) Then Return SetError(1, 0, False)
		z_Playlist_Import_Internal($sFile)
	EndIf
EndFunc   ;==>z_Playlist_Import
Func z_Playlist_Import_Internal($sFile)
	;References for implementing playlist formats
	;-	m3u: StringSplit(StringStripCR("yourfile.m3u"), @LF, 1)
	;-	xspf: StringRegExp("yourfile.xspf", "(?i)<location>(.+?)</location>", 3)

	If Not FileExists($sFile) Then Return SetError(1, 0, False)
	Local $sData = FileRead($sFile)
	If Not $sData Then Return SetError(1, 0, False)
	Select
		Case StringRight($sFile, 4) = ".m3u" Or StringRight($sFile, 5) = ".m3u8"
			Local $aTracks = StringSplit(StringStripCR($sData), @LF, 1)
			For $i = 1 To $aTracks[0]
				If StringInStr($aTracks[$i], "http://", 0, 1, 1) Or StringInStr($aTracks[$i], "https://", 0, 1, 1) Or StringInStr($aTracks[$i], "ftp://", 0, 1, 1) Then
					z_Playlist_AddURL_Internal($aTracks[$i])
				ElseIf FileExists($aTracks[$i]) Then
					z_Playlist_AddFile_Internal($aTracks[$i])
				EndIf
			Next
		Case StringRight($sFile, 5) = ".xspf"
			Local $aTracks = StringRegExp($sData, "(?i)<location>(.+?)</location", 3)
			If UBound($aTracks) Then
				For $i = 0 To UBound($aTracks) - 1
					If StringInStr($aTracks[$i], "http://", 0, 1, 1) Or StringInStr($aTracks[$i], "https://", 0, 1, 1) Or StringInStr($aTracks[$i], "ftp://", 0, 1, 1) Then
						z_Playlist_AddURL_Internal($aTracks[$i])
					Else
						Local $sAudioFile = StringReplace(_URIDecode($aTracks[$i]), "file:///", "")
						If FileExists($sAudioFile) Then
							z_Playlist_AddFile_Internal($sAudioFile)
						EndIf
					EndIf
				Next
			EndIf
		Case Else
			Return SetError(1, 0, False)
	EndSelect
EndFunc   ;==>z_Playlist_Import_Internal
Func z_Playlist_Export()
	;This is gonna take awhile, don't expect anything except M3U at first

	Local $sFile = FileSaveDialog("Select a playlist...", @UserProfileDir & "\Music", $ExportPlaylistFormatFilter, Default, "", $GUI_Main_Handle) ;Later I'll implement multiple playlists

	z_Playlist_Export_Internal($sFile)
EndFunc   ;==>z_Playlist_Export
Func z_Playlist_Export_Internal($sFile)
	;Copy z_Playlist_Export but take filename as parameter

	FileDelete($sFile)
	Select
		Case StringRight($sFile, 4) = ".m3u" Or StringRight($sFile, 5) = ".m3u8"
			For $i = 0 To UBound($aPlaylist) - 1
				FileWrite($sFile, $aPlaylist[$i][0] & @LF)
			Next
	EndSelect
EndFunc   ;==>z_Playlist_Export_Internal
Func z_Playlist_DeleteEntry()
	;Simply because I refuse to add some really long parsing method right now, I'm sticking to this
	;However, I soon plan to break free from Array.au3 and stick to internal methods
	;If I have to, I'll copy this function raw from the UDF and drop it in Snippets
	If UBound($aPlaylist) Then
		z_Playback_Stop()
		If $iCurrentGUI = 3 Then GUICtrlDelete($aPlaylist[$iCurrentTrack][9])
		_ArrayDelete($aPlaylist, $iCurrentTrack)
		If UBound($aPlaylist) Then
			If $iCurrentTrack < 0 Then
				$iCurrentTrack = 0
			ElseIf $iCurrentTrack > (UBound($aPlaylist) - 1) Then
				$iCurrentTrack = (UBound($aPlaylist) - 1)
			EndIf
		Else
			$iCurrentTrack = 0
		EndIf
		z_Service_Identify()
		z_DataUpdate()
		AdlibUnRegister("z_DataUpdate")
	Else
		$iCurrentTrack = 0
		AdlibUnRegister("z_DataUpdate")
	EndIf
EndFunc   ;==>z_Playlist_DeleteEntry
Func z_Playlist_ToggleRepeat()
	If $mSettings["Repeat"] Then
		$mSettings["Repeat"] = False
		z_Notification("REPEAT_DISABLED")
	ElseIf Not $mSettings["Repeat"] Then
		$mSettings["Repeat"] = True
		z_Notification("REPEAT_ENABLED")
	EndIf
EndFunc   ;==>z_Playlist_ToggleRepeat
Func z_Playlist_ToggleRandom()
	If $mSettings["Random"] Then
		$mSettings["Random"] = False
		z_Notification("RANDOM_DISABLED")
	ElseIf Not $mSettings["Random"] Then
		$mSettings["Random"] = True
		z_Notification("RANDOM_ENABLED")
	EndIf
EndFunc   ;==>z_Playlist_ToggleRandom

;Timers
Func z_Timer_AudioPosition()
	If UBound($aPlaylist) Then
		Local $hFocus = ControlGetFocus("")
		Local $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $hFocus)
		If $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $GUI_AudioPositionSlider_Handle) Then
			If $aPlaylist[$iCurrentTrack][8] = 1 Then
				Local $bResume = True
				Local $iType = $aPlaylist[$iCurrentTrack][8]
			Else
				Local $bResume = False
				Local $iType = $aPlaylist[$iCurrentTrack][8]
			EndIf
			$aPlaylist[$iCurrentTrack][8] = 4
			z_Audio_Pause($aPlaylist[$iCurrentTrack][1])
			z_DataUpdate()
			AdlibUnRegister("z_DataUpdate")
			Local $iOldSliderAudioPosition = GUICtrlRead($GUI_AudioPositionSlider_Handle)
			Local $iNewSliderAudioPosition = $iOldSliderAudioPosition
			Do
				$iNewSliderAudioPosition = GUICtrlRead($GUI_AudioPositionSlider_Handle)
				If $iOldSliderAudioPosition <> $iNewSliderAudioPosition Then
					z_Audio_SetPosition(GUICtrlRead($GUI_AudioPositionSlider_Handle))
					$iOldSliderAudioPosition = $iNewSliderAudioPosition
				EndIf
			Until Not _IsPressed(1) Or _IsPressed(2)
			_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
			If $bResume Then
				$aPlaylist[$iCurrentTrack][8] = $iType
				z_Audio_Play($aPlaylist[$iCurrentTrack][1], 0)
			Else
				$aPlaylist[$iCurrentTrack][8] = $iType
			EndIf
			z_DataUpdate()
		EndIf
	EndIf
EndFunc   ;==>z_Timer_AudioPosition
Func z_Timer_VolumePosition()
	Local $hFocus = ControlGetFocus("")
	Local $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $hFocus)
	If $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $GUI_VolumeSlider_Handle) Then
		Local $iOldAudioVolume = Round(GUICtrlRead($GUI_VolumeSlider_Handle))
		Local $iNewAudioVolume = $iOldAudioVolume
		Do
			$iNewAudioVolume = Round(GUICtrlRead($GUI_VolumeSlider_Handle))
			If $iOldAudioVolume <> $iNewAudioVolume Then
				z_Audio_SetVolume($iNewAudioVolume)
				$iOldAudioVolume = $iNewAudioVolume
			EndIf
			$iOldAudioVolume = $iNewAudioVolume
		Until Not _IsPressed(1) Or _IsPressed(02)
		_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
		z_DataUpdate()
	EndIf
EndFunc   ;==>z_Timer_VolumePosition

;Playback management
Func z_Playback_SaveFile()
	If UBound($aPlaylist) Then
		If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
			$sOriginLocation = $aPlaylist[$iCurrentTrack][0]
			If StringInStr($sOriginLocation, "youtube.com/watch?v=", 0, 1) Then
				$sOriginLocation = "http://www.youtubeinmp3.com/fetch/?video=" & $sOriginLocation
				$sSaveName = $aPlaylist[$iCurrentTrack][3] & ". " & $aPlaylist[$iCurrentTrack][4] & " - " & $aPlaylist[$iCurrentTrack][5] & " - " & $aPlaylist[$iCurrentTrack][6] & " (" & $aPlaylist[$iCurrentTrack][7] & ")"
				$sSaveExtension = "mp3"
			Else
				$sSaveName = $aPlaylist[$iCurrentTrack][3] & ". " & $aPlaylist[$iCurrentTrack][4] & " - " & $aPlaylist[$iCurrentTrack][5] & " - " & $aPlaylist[$iCurrentTrack][6] & " (" & $aPlaylist[$iCurrentTrack][7] & ")"
				$sSaveExtension = z_DataCheck_GetExtension($aPlaylist[$iCurrentTrack][0])
			EndIf
			$sSaveName = StringRegExpReplace($sSaveName, "[^[:print:]]", "")
			$sSaveName = StringReplace($sSaveName, "?", "")
			$sSaveName = StringReplace($sSaveName, "/", "")
			$sSaveName = StringReplace($sSaveName, "\", "")
			$sSaveName = StringReplace($sSaveName, "*", "")
			$sSaveName = StringReplace($sSaveName, """", "")
			$sSaveName = StringReplace($sSaveName, "<", "")
			$sSaveName = StringReplace($sSaveName, ">", "")
			$sSaveName = StringReplace($sSaveName, "|", "")
			$sSaveLocation = FileSaveDialog("Choose a file to save to...", @UserProfileDir & "\Music", $FileFormatFilter, Default, $sSaveName & "." & $sSaveExtension)
			If @error Then
				z_Notification("SAVING_STREAM_ERROR:" & @error)
				Return
			EndIf
			InetGet($sOriginLocation, $sSaveLocation, 0, 1)
			z_Notification("SAVING_STREAM")
		EndIf
	EndIf
EndFunc   ;==>z_Playback_SaveFile
Func z_Playback_PlayPauseResume()
	If UBound($aPlaylist) Then
		If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_SHOW)
			If $aPlaylist[$iCurrentTrack][8] = 0 Then ;No audio is playing, let's play it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				;_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $mSettings["Volume"])
				z_Audio_SetVolume($mSettings["Volume"])
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 1)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Pause"])
				GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, z_Audio_GetLength())
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Service_Identify()
				z_Notification("NOW_PLAYING", $aPlaylist[$iCurrentTrack][0])
				$sID3Tags = ""
				$i3 = False
				$i4 = False
				$i5 = False
				$i6 = False
				If $aPlaylist[$iCurrentTrack][3] Then
					$i3 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][3] & "."
				EndIf
				If $aPlaylist[$iCurrentTrack][4] Then
					If $i3 Then $sID3Tags &= " "
					$i4 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][4]
				EndIf
				If $aPlaylist[$iCurrentTrack][5] Then
					If $i4 Then $sID3Tags &= " - "
					$i5 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][5]
				EndIf
				If $aPlaylist[$iCurrentTrack][6] Then
					If $i5 Then $sID3Tags &= " - "
					$i6 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][6]
				EndIf
				If $aPlaylist[$iCurrentTrack][7] Then
					If $i6 Then $sID3Tags &= " "
					$sID3Tags &= "(" & $aPlaylist[$iCurrentTrack][7] & ")"
				EndIf
				GUICtrlSetData($GUI_ID3Tags_Handle, $sID3Tags)
			ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Then ;Audio is playing, let's pause it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				z_Notification("PAUSED_AUDIO_STREAM", $aPlaylist[$iCurrentTrack][0])
				_BASS_ChannelPause($aPlaylist[$iCurrentTrack][1])
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Resume"])
				$aPlaylist[$iCurrentTrack][8] = 2
				z_DataUpdate()
				AdlibUnRegister("z_DataUpdate")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 2 Then ;No audio is playing, let's resume it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 0)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Pause"])
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Notification("RESUME_PLAYING", $aPlaylist[$iCurrentTrack][0])
			EndIf
		ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE)
			If $aPlaylist[$iCurrentTrack][8] = 0 Then ;No audio is playing, let's play it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $mSettings["Volume"])
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 1)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Pause"])
				GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, z_Audio_GetLength())
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Service_Identify()
				z_Notification("NOW_PLAYING", $aPlaylist[$iCurrentTrack][0])
				$sID3Tags = ""
				$i3 = False
				$i4 = False
				$i5 = False
				$i6 = False
				If $aPlaylist[$iCurrentTrack][3] Then
					$i3 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][3] & "."
				EndIf
				If $aPlaylist[$iCurrentTrack][4] Then
					If $i3 Then $sID3Tags &= " "
					$i4 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][4]
				EndIf
				If $aPlaylist[$iCurrentTrack][5] Then
					If $i4 Then $sID3Tags &= " - "
					$i5 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][5]
				EndIf
				If $aPlaylist[$iCurrentTrack][6] Then
					If $i5 Then $sID3Tags &= " - "
					$i6 = True
					$sID3Tags &= $aPlaylist[$iCurrentTrack][6]
				EndIf
				If $aPlaylist[$iCurrentTrack][7] Then
					If $i6 Then $sID3Tags &= " "
					$sID3Tags &= "(" & $aPlaylist[$iCurrentTrack][7] & ")"
				EndIf
				GUICtrlSetData($GUI_ID3Tags_Handle, $sID3Tags)
			ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Then ;Audio is playing, let's pause it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				z_Notification("PAUSED_AUDIO_STREAM", $aPlaylist[$iCurrentTrack][0])
				_BASS_ChannelPause($aPlaylist[$iCurrentTrack][1])
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Resume"])
				$aPlaylist[$iCurrentTrack][8] = 2
				z_DataUpdate()
				AdlibUnRegister("z_DataUpdate")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 2 Then ;No audio is playing, let's resume it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 0)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Pause"])
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Notification("RESUME_PLAYING", $aPlaylist[$iCurrentTrack][0])
			EndIf
		ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
			;Handle playing and pausing video here
		EndIf
	Else
		z_Notification("NO_AUDIO")
		GUICtrlSetData($GUI_ID3Tags_Handle, "No playlist entry is queued for playback.")
	EndIf
EndFunc   ;==>z_Playback_PlayPauseResume
Func z_Playback_Stop()
	If UBound($aPlaylist) Then
		If $aPlaylist[$iCurrentTrack][8] = 0 Then
			z_Notification("NO_STOP_POSSIBLE")
			z_DataUpdate()
			AdlibUnRegister("z_DataUpdate")
		ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
			_BASS_ChannelStop($aPlaylist[$iCurrentTrack][1])
			_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], 0, $BASS_POS_BYTE)
			GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Play"])
			GUICtrlSetData($GUI_AudioPositionSlider_Handle, 0)
			$aPlaylist[$iCurrentTrack][8] = 0
			z_DataUpdate()
			AdlibUnRegister("z_DataUpdate")
			z_Service_Identify()
			GUICtrlSetData($GUI_ID3Tags_Handle, "No audio track is queued.")
			If $iCurrentGUI = 1 Then
				z_Child_View_DisplayImage()
			EndIf
		EndIf
	Else
		z_Notification("NO_STOP_POSSIBLE")
		z_DataUpdate()
		AdlibUnRegister("z_DataUpdate")
	EndIf
EndFunc   ;==>z_Playback_Stop
Func z_Playback_Previous()
	If UBound($aPlaylist) Then
		$iCurrentAudioPosition = z_Audio_GetPosition()

		If $iCurrentAudioPosition < 3 Then
			If $iCurrentTrack > 0 Then
				If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
					z_Playback_Stop()
					$iCurrentTrack -= 1
					z_Playback_PlayPauseResume()
				Else
					$iCurrentTrack -= 1
					z_Service_Identify()
					z_DataUpdate()
				EndIf
			ElseIf $iCurrentTrack = 0 Then
				If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
					z_Playback_Stop()
					$iCurrentTrack = UBound($aPlaylist) - 1
					z_Playback_PlayPauseResume()
				Else
					$iCurrentTrack = UBound($aPlaylist) - 1
					z_Service_Identify()
					z_DataUpdate()
				EndIf
			Else
				If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
					z_Playback_Stop()
					z_Playback_PlayPauseResume()
				Else
					z_Playback_Stop()
					z_DataUpdate()
				EndIf
			EndIf
		Else
			If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
				If $mSettings["Repeat"] Then
					z_Playback_Stop()
					z_Playback_PlayPauseResume()
				EndIf
			Else
				z_Playback_Stop()
				z_DataUpdate()
			EndIf
		EndIf

		If $iCurrentGUI = 1 Then
			z_Child_View_DisplayImage()
		EndIf
	EndIf
EndFunc   ;==>z_Playback_Previous
Func z_Playback_Next()
	If UBound($aPlaylist) Then
		;If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
		;	GUICtrlSetState($GUI_SaveFile_Handle, @SW_SHOW)
		;ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iCurrentTrack][0]) Or z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
		;	GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE)
		;EndIf

		If $mSettings["Random"] Then
			If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
				z_Playback_Stop()
				$iCurrentTrack = Round(Random(0, (UBound($aPlaylist) - 1)))
				z_Playback_PlayPauseResume()
			Else
				$iCurrentTrack = Round(Random(0, (UBound($aPlaylist) - 1)))
				z_Service_Identify()
				z_DataUpdate()
			EndIf
		Else
			If $iCurrentTrack < (UBound($aPlaylist) - 1) Then
				If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
					z_Playback_Stop()
					$iCurrentTrack += 1
					z_Playback_PlayPauseResume()
				Else
					$iCurrentTrack += 1
					z_Service_Identify()
					z_DataUpdate()
				EndIf
			Else
				If $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
					If $mSettings["Repeat"] Then
						z_Playback_Stop()
						$iCurrentTrack = 0
						z_Playback_PlayPauseResume()
					EndIf
				Else
					$iCurrentTrack = 0
					z_Service_Identify()
					z_DataUpdate()
				EndIf
			EndIf
		EndIf

		If $iCurrentGUI = 1 Then
			z_Child_View_DisplayImage()
		EndIf
	EndIf
EndFunc   ;==>z_Playback_Next
Func z_Audio_GetPosition($bReturnBytes = False)
	Local $bPosition = _BASS_ChannelGetPosition($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)
	If $bReturnBytes Then
		Return $bPosition
	Else
		Local $iPosition = _BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], $bPosition)
		Return $iPosition
	EndIf
EndFunc   ;==>z_Audio_GetPosition
Func z_Audio_SetPosition($iNewAudioPosition, $bSetBytes = False)
	If UBound($aPlaylist) Then
		If $bSetBytes Then
			_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], $iNewAudioPosition, $BASS_POS_BYTE)
			GUICtrlSetData($GUI_AudioPosition_Handle, Seconds2Time(Ceiling(_BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], _BASS_ChannelGetPosition($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)))))
		Else
			_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], _BASS_ChannelSeconds2Bytes($aPlaylist[$iCurrentTrack][1], $iNewAudioPosition), $BASS_POS_BYTE)
			GUICtrlSetData($GUI_AudioPosition_Handle, Seconds2Time(Ceiling(_BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], _BASS_ChannelGetPosition($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)))))
		EndIf
	EndIf
EndFunc   ;==>z_Audio_SetPosition
Func z_Audio_GetLength($bReturnBytes = False)
	If UBound($aPlaylist) Then
		Local $bLength = _BASS_ChannelGetLength($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)
		If $bReturnBytes Then
			Return $bLength
		Else
			Local $iLength = _BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], $bLength)
			Return $iLength
		EndIf
	EndIf
EndFunc   ;==>z_Audio_GetLength
Func z_Audio_GetVolume()
	If UBound($aPlaylist) Then
		Return _BASS_ChannelGetVolume($aPlaylist[$iCurrentTrack][1])
	EndIf
EndFunc   ;==>z_Audio_GetVolume
Func z_Audio_SetVolume($iVolume)
	$mSettings["Volume"] = $iVolume
	GUICtrlSetData($GUI_VolumeCounter_Handle, $iVolume)
	If UBound($aPlaylist) Then
		_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $iVolume)
	EndIf
EndFunc   ;==>z_Audio_SetVolume
Func z_Audio_Play($iTrack, $iReset = 0)
	_BASS_ChannelPlay($iTrack, $iReset)
EndFunc   ;==>z_Audio_Play
Func z_Audio_Pause($iTrack)
	_BASS_ChannelPause($iTrack)
EndFunc   ;==>z_Audio_Pause

;GUI management
Volatile Func z_DataUpdate()
	AdlibUnRegister("z_DataUpdate")
	If UBound($aPlaylist) Then
		If GUICtrlRead($GUI_AudioPosition_Handle) <> Seconds2Time(Ceiling(z_Audio_GetPosition())) Then GUICtrlSetData($GUI_AudioPosition_Handle, Seconds2Time(Ceiling(z_Audio_GetPosition())))
		If GUICtrlRead($GUI_AudioLength_Handle) <> Seconds2Time(Ceiling(z_Audio_GetLength())) Then GUICtrlSetData($GUI_AudioLength_Handle, Seconds2Time(Ceiling(z_Audio_GetLength())))
		Local $sTrackStatus
		Switch $aPlaylist[$iCurrentTrack][8]
			Case 0
				$sTrackStatus = "Stopped"
			Case 1
				$sTrackStatus = "Playing"
			Case 2
				$sTrackStatus = "Paused"
			Case 3
				$sTrackStatus = "Not ready"
			Case 4
				$sTrackStatus = "Seeking..."
			Case Else
				$sTrackStatus = "Unknown status"
		EndSwitch
		If GUICtrlRead($GUI_TrackPosition_Handle) <> (($iCurrentTrack + 1) & "/" & (UBound($aPlaylist)) & " - " & $sTrackStatus) Then GUICtrlSetData($GUI_TrackPosition_Handle, ($iCurrentTrack + 1) & "/" & (UBound($aPlaylist)) & " - " & $sTrackStatus)
		If $aPlaylist[$iCurrentTrack][8] = 1 Then
			If Not _WinAPI_GetFocus() = GUICtrlGetHandle($GUI_VolumeSlider_Handle) Then
				Local $iCurrentAudioVolume = Round(_BASS_ChannelGetVolume($aPlaylist[$iCurrentTrack][1]))
				GUICtrlSetData($GUI_VolumeSlider_Handle, $iCurrentAudioVolume)
				GUICtrlSetData($GUI_VolumeCounter_Handle, String($iCurrentAudioVolume))
			EndIf
			If Not _WinAPI_GetFocus() = GUICtrlGetHandle($GUI_AudioPositionSlider_Handle) Then
				GUICtrlSetData($GUI_AudioPositionSlider_Handle, z_Audio_GetPosition())
			EndIf
		EndIf
	Else
		GUICtrlSetData($GUI_TrackPosition_Handle, "No tracks in the playlist.")
	EndIf
	AdlibRegister("z_DataUpdate", 1000)
EndFunc   ;==>z_DataUpdate

;Child GUI management
Func z_Child_OpenView()
	z_OpenChildGUI(1)
EndFunc   ;==>z_Child_OpenView
Func z_Child_OpenCD()
	z_OpenChildGUI(2)
EndFunc   ;==>z_Child_OpenCD
Func z_Child_OpenPlaylist()
	z_OpenChildGUI(3)
EndFunc   ;==>z_Child_OpenPlaylist
Func z_Child_OpenTheme()
	z_OpenChildGUI(4)
EndFunc   ;==>z_Child_OpenTheme
Func z_Child_OpenNotifications()
	z_OpenChildGUI(5)
EndFunc   ;==>z_Child_OpenNotifications
Func z_Child_OpenSettings()
	z_OpenChildGUI(6)
EndFunc   ;==>z_Child_OpenSettings
Func z_Child_OpenAbout()
	z_OpenChildGUI(7)
EndFunc   ;==>z_Child_OpenAbout
Func z_Child_YouTubeSearch()
	If WinActive($GUI_Main_Handle) Then
		Local $sUsage = "Surround a word or phrase in quotes to filter out results that don't contain the exact word or phrase in order." & @CRLF & _
						"Ex: ""Music Video""" & @CRLF & @CRLF & _
						"Use the plus (+) sign to filter out results that don't contain the following word." & @CRLF & _
						"Ex: +Raining +Tacos" & @CRLF & @CRLF & _
						"Use the intitle operator to filter out results that don't contain the following word in the title." & @CRLF & _
						"Ex: intitle:Chill relaxing calm"
		Local $sQuery = InputBox("YouTube Search", $sUsage, "", " M", 500, 250)
		If $sQuery Then
			Local $aSearchResults = YouTube_Search("AIzaSyAac-x77uNVpTCpsXkxF-wH9CRVnAqGk6c", $sQuery, "video", 50)
			If @error Then
				Switch @error
					Case 1
						z_Notification("YT_SEARCH_FAIL")
					Case 2
						z_Notification("YT_SEARCH_NORESULTS")
					Case Else
						z_Notification("YT_SEARCH_FATAL_UNKNOWN")
				EndSwitch
			Else
				z_OpenChildGUI(8, True, $aSearchResults)
			EndIf
		EndIf
	Else
		HotKeySet("^f")
		Send("^f")
		HotKeySet("^f", "z_Child_YouTubeSearch")
	EndIf
EndFunc
Func z_Child_Playlist_SetDoubleClick()
	$bDoubleClick = True
	z_Child_PlaylistEvent()
EndFunc   ;==>z_Child_Playlist_SetDoubleClick
Volatile Func z_Child_PlaylistEvent()
	If $bDoubleClick Then
		$bDoubleClick = False
		$hItem = @GUI_CtrlId
		Local $aPlaylistEntry = StringSplit(GUICtrlRead(@GUI_CtrlId), Chr(1))
		Local $iSelectedTrack = ($aPlaylistEntry[1] - 1)
		If $iSelectedTrack = -1 Then
			Return SetError(1, 0, False)
		EndIf
		z_Playback_Stop()
		$iCurrentTrack = $iSelectedTrack
		z_Playback_PlayPauseResume()
		_WinAPI_SetActiveWindow($GUI_PlayPauseResume_Handle)
	Else
		$hItem = @GUI_CtrlId
		$bDoubleClick = True
	EndIf
	AdlibRegister("z_Child_PlaylistEvent_Reset", 750)
EndFunc   ;==>z_Child_PlaylistEvent
Volatile Func z_Child_YouTubeSearchEvent()
	If $bDoubleClick Then
		$bDoubleClick = False
		$hItem = @GUI_CtrlId
		Local $aSearchEntry = StringSplit(GUICtrlRead(@GUI_CtrlId), Chr(1))
		Local $sVideoID = $aSearchEntry[1]
		z_Playlist_AddURL_Internal("https://youtube.com/watch?v=" & $sVideoID)
		;z_Playback_Stop()
		;$iCurrentTrack = UBound($aPlaylist) - 1
		;z_Playback_PlayPauseResume()
		;_WinAPI_SetActiveWindow($GUI_PlayPauseResume_Handle)
	Else
		$hItem = @GUI_CtrlId
		$bDoubleClick = True
	EndIf
	AdlibRegister("z_Child_YouTubeSearchEvent_Reset", 750)
EndFunc
Func z_Child_PlaylistEvent_Reset()
	$bDoubleClick = False
	$hItem = 0
EndFunc   ;==>z_Child_PlaylistEvent_Reset
Func z_Child_YouTubeSearchEvent_Reset()
	$bDoubleClick = False
	$hItem = 0
EndFunc   ;==>z_Child_YouTubeSearchEvent_Reset
Func z_Child_View_PrepImage($sImagePath, $iGUIWidth, $iGUIHeight)
	Local $hBitmap = _GDIPlus_BitmapCreateFromFile($aPlaylist[$iCurrentTrack][10])

	Local $hGUI_Width = $iGUIWidth
	Local $hGUI_Height = $iGUIHeight
	Local $hBitmap_Width = _GDIPlus_ImageGetWidth($hBitmap)
	Local $hBitmap_Height = _GDIPlus_ImageGetHeight($hBitmap)

	If $hGUI_Width < $hBitmap_Width Or $hGUI_Height < $hBitmap_Height Then
		Local $dRatioX = $hGUI_Width / $hBitmap_Width
		Local $dRatioY = $hGUI_Height / $hBitmap_Height
		Local $dRatio = $dRatioX < $dRatioY ? $dRatioX : $dRatioY

		Local $hBitmap_NewWidth = $hBitmap_Width * $dRatio
		Local $hBitmap_NewHeight = $hBitmap_Height * $dRatio

		Local $hGUI_X = ($hGUI_Width - ($hBitmap_Width * $dRatio)) / 2
		Local $hGUI_Y = ($hGUI_Height - ($hBitmap_Height * $dRatio)) / 2

		_GDIPlus_ImageResize($hBitmap, $hBitmap_Width, $hBitmap_Height)
		_GDIPlus_ImageSaveToFile($hBitmap, $aPlaylist[$iCurrentTrack][10])
		_GDIPlus_BitmapDispose($hBitmap)

		Local $aImageData[5]
		$aImageData[0] = $hGUI_X
		$aImageData[1] = $hGUI_Y
		$aImageData[2] = $hBitmap_NewWidth
		$aImageData[3] = $hBitmap_NewHeight
		$aImageData[4] = True
		Return $aImageData
	Else
		Local $hGUI_X = ($hGUI_Width - $hBitmap_Width) / 2
		Local $hGUI_Y = ($hGUI_Height - $hBitmap_Height) / 2

		_GDIPlus_BitmapDispose($hBitmap)

		Local $aImageData[5]
		$aImageData[0] = $hGUI_X
		$aImageData[1] = $hGUI_Y
		$aImageData[2] = $hBitmap_Width
		$aImageData[3] = $hBitmap_Height
		$aImageData[4] = False
		Return $aImageData
	EndIf
EndFunc
Func z_Child_View_DisplayImage()
	;Mitigation for strange crashing where the window position can't be found
	;Also involves the same mitigation for the position of the ID3Tags control just in case
	Local $aPos_Window
	Local $aPos_ID3Tags
	Local $iCount = 0
	Local $iAttempts = 5
	Local $iWidth = 0
	Local $iHeight = 0

	Do
		$aPos_Window = WinGetPos($GUI_Main_Handle)
		$iCount += 1
	Until IsArray($aPos_Window) Or $iCount >= $iAttempts

	If $iCount >= $iAttempts Then
		GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
		Return z_Notification("ERROR_CHILD_INTERFACE", GUIGetMsg())
	Else
		$iWidth = ($aPos_Window[2] - 4)
	EndIf
	$iCount = 0

	Do
		$aPos_ID3Tags = ControlGetPos($GUI_Main_Handle, "", $GUI_ID3Tags_Handle)
		$iCount += 1
	Until IsArray($aPos_ID3Tags) Or $iCount >= $iAttempts

	If $iCount >= $iAttempts Then
		GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
		Return z_Notification("ERROR_CHILD_INTERFACE", GUIGetMsg())
	Else
		$iHeight = ($aPos_ID3Tags[1] - 89)
	EndIf
	$iCount = 0

	If UBound($aPlaylist) Then
		ReDim $GUI_Child[1]
		If z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
			$GUI_Child[0] = GUICreate($mSettings["Window Title"], 778, 225, 2, 85, $WS_POPUPWINDOW)
			;DSEngine_LoadFile($aPlaylist[$iCurrentTrack][0], $GUI_Child[0])
		Else
			If StringInStr($aPlaylist[$iCurrentTrack][0], "youtube.com/watch?v=", 0, 1) Then
				If Not $aPlaylist[$iCurrentTrack][10] Then
					Local $sArtURL = YouTube_Get_ArtURL($aPlaylist[$iCurrentTrack][0])
					$aPlaylist[$iCurrentTrack][10] = _TempFile(@TempDir, "zPlayer~YouTubeArt~", ".jpg", 20)
					InetGet($sArtURL, $aPlaylist[$iCurrentTrack][10])
				EndIf
				If FileExists($aPlaylist[$iCurrentTrack][10]) Then
					;[0] = X offset
					;[1] = Y offset
					;[2] = Width
					;[3] = Height
					Local $aImageData = z_Child_View_PrepImage($aPlaylist[$iCurrentTrack][10], $iWidth, $iHeight)

					$GUI_Child[0] = GUICtrlCreatePic($aPlaylist[$iCurrentTrack][10], 2 + $aImageData[0], 85 + $aImageData[1], $aImageData[2], $aImageData[3])
					GUICtrlSetImage($GUI_Child[0], $aPlaylist[$iCurrentTrack][10])
					If $aImageData[4] Then
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
					Else
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
					EndIf
					z_Notification("ALBUMART_SUCCEED_YT")
				Else
					z_Notification("ALBUMART_FAIL_YT")
					For $i = 0 To UBound($GUI_Child) - 1
						If ControlGetPos("", "", $GUI_Child[$i]) Then
							GUICtrlDelete($GUI_Child[$i])
						EndIf
					Next
					ReDim $GUI_Child[0]
					z_Child_OpenPlaylist()
					$iCurrentGUI = 3
				EndIf
			ElseIf StringInStr($aPlaylist[$iCurrentTrack][0], "soundcloud.com", 0, 1) Then
				If Not $aPlaylist[$iCurrentTrack][10] Then
					Local $sSoundCloudHTML = BinaryToString(InetRead($aPlaylist[$iCurrentTrack][0]))
					Local $aSoundCloud_ArtURL = _StringBetween($sSoundCloudHTML, '"artwork_url":"', '"')
					If UBound($aSoundCloud_ArtURL) Then
						Local $sSoundCloud_ArtURL = $aSoundCloud_ArtURL[0]
						ConsoleWrite("Art URL: " & $sSoundCloud_ArtURL & @CRLF)
						$aPlaylist[$iCurrentTrack][10] = _TempFile(@TempDir, "zPlayer~SoundCloudArt~", ".jpg", 20)
						ConsoleWrite("Temp file: " & $aPlaylist[$iCurrentTrack][10] & @CRLF)
						InetGet($sSoundCloud_ArtURL, $aPlaylist[$iCurrentTrack][10])
						ConsoleWrite("Inet error code: " & @error & @CRLF)
					Else
						z_Notification("ALBUMART_FAIL_SNDCLD")
						For $i = 0 To UBound($GUI_Child) - 1
							If ControlGetPos("", "", $GUI_Child[$i]) Then
								GUICtrlDelete($GUI_Child[$i])
							EndIf
						Next
						ReDim $GUI_Child[0]
						z_Child_OpenPlaylist()
						$iCurrentGUI = 3
					EndIf
				EndIf
				If FileExists($aPlaylist[$iCurrentTrack][10]) Then
					Local $aImageData = z_Child_View_PrepImage($aPlaylist[$iCurrentTrack][10], $iWidth, $iHeight)

					$GUI_Child[0] = GUICtrlCreatePic($aPlaylist[$iCurrentTrack][10], 2 + $aImageData[0], 85 + $aImageData[1], $aImageData[2], $aImageData[3])
					GUICtrlSetImage($GUI_Child[0], $aPlaylist[$iCurrentTrack][10])
					If $aImageData[4] Then
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
					Else
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
					EndIf
					z_Notification("ALBUMART_SUCCEED_SNDCLD")
				Else
					z_Notification("ALBUMART_FAIL_SNDCLD")
					For $i = 0 To UBound($GUI_Child) - 1
						If ControlGetPos("", "", $GUI_Child[$i]) Then
							GUICtrlDelete($GUI_Child[$i])
						EndIf
					Next
					ReDim $GUI_Child[0]
					z_Child_OpenPlaylist()
					$iCurrentGUI = 3
				EndIf
			Else
				If Not $aPlaylist[$iCurrentTrack][10] Then
					Local $hID3 = _ID3ReadTag($aPlaylist[$iCurrentTrack][0])
					$aPlaylist[$iCurrentTrack][10] = StringTrimRight(_TempFile(@TempDir, "zPlayer~LocalAlbumArt~", "", 20), 1)
					$aPlaylist[$iCurrentTrack][10] = _ID3GetTagField("APIC", 1, 0, $aPlaylist[$iCurrentTrack][10])
				EndIf
				If FileExists($aPlaylist[$iCurrentTrack][10]) Then
					Local $aImageData = z_Child_View_PrepImage($aPlaylist[$iCurrentTrack][10], $iWidth, $iHeight)

					$GUI_Child[0] = GUICtrlCreatePic($aPlaylist[$iCurrentTrack][10], 2 + $aImageData[0], 85 + $aImageData[1], $aImageData[2], $aImageData[3])
					GUICtrlSetImage($GUI_Child[0], $aPlaylist[$iCurrentTrack][10])
					If $aImageData[4] Then
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
					Else
						GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
					EndIf
					z_Notification("ALBUMART_SUCCEED_LOC")
				Else
					z_Notification("ALBUMART_FAIL_LOC")
					For $i = 0 To UBound($GUI_Child) - 1
						If ControlGetPos("", "", $GUI_Child[$i]) Then
							GUICtrlDelete($GUI_Child[$i])
						EndIf
					Next
					ReDim $GUI_Child[0]
					z_Child_OpenPlaylist()
					$iCurrentGUI = 3
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc
Func z_OpenChildGUI($iGUI, $bRefresh = False, $aData = Null)
	If $iCurrentGUI <> $iGUI Or $bRefresh = True Then
		;		Local $bMaximised = False
		;		If $mSettings["Size State"] Then
		;			GUISetState(@SW_RESTORE, $GUI_Main_Handle)
		;		EndIf
		GUISetState(@SW_LOCK, $GUI_Main_Handle)
		$iCurrentGUI = $iGUI
		If UBound($GUI_Child) Then
			If UBound($aPlaylist) Then
				;If z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
				;	GUICtrlSetState($GUI_Child[0], @SW_HIDE)
				;Else
				For $i = 0 To UBound($GUI_Child) - 1
					If Not UBound($GUI_Child) Then ExitLoop
					If IsHWnd(WinGetHandle($GUI_Child[$i])) And Not $GUI_Child[$i] = $GUI_Main_Handle Then
						GUIDelete($GUI_Child[$i])
					Else
						GUICtrlDelete($GUI_Child[$i])
					EndIf
				Next
				ReDim $GUI_Child[0]
			Else
				For $i = 0 To UBound($GUI_Child) - 1
					If Not UBound($GUI_Child) Then ExitLoop
					If IsHWnd(WinGetHandle($GUI_Child[$i])) And Not $GUI_Child[$i] = $GUI_Main_Handle Then
						GUIDelete($GUI_Child[$i])
					Else
						GUICtrlDelete($GUI_Child[$i])
					EndIf
					ReDim $GUI_Child[0]
				Next
			EndIf
		EndIf

		#Region
		;Mitigation for strange crashing where the window position can't be found
		;Also involves the same mitigation for the position of the ID3Tags control just in case
		Local $aPos_Window
		Local $aPos_ID3Tags
		Local $iCount = 0
		Local $iAttempts = 5
		Local $iWidth = 0
		Local $iHeight = 0

		Do
			$aPos_Window = WinGetPos($GUI_Main_Handle)
			$iCount += 1
		Until IsArray($aPos_Window) Or $iCount >= $iAttempts

		If $iCount >= $iAttempts Then
			GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
			Return z_Notification("ERROR_CHILD_INTERFACE", GUIGetMsg())
		Else
			$iWidth = ($aPos_Window[2] - 4)
		EndIf
		$iCount = 0

		Do
			$aPos_ID3Tags = ControlGetPos($GUI_Main_Handle, "", $GUI_ID3Tags_Handle)
			$iCount += 1
		Until IsArray($aPos_ID3Tags) Or $iCount >= $iAttempts

		If $iCount >= $iAttempts Then
			GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
			Return z_Notification("ERROR_CHILD_INTERFACE", GUIGetMsg())
		Else
			$iHeight = ($aPos_ID3Tags[1] - 89)
		EndIf
		$iCount = 0
		#EndRegion

		Switch $iGUI
			Case 0 ;Close whichever child GUI is currently open
				If $iCurrentGUI = 3 Then
					If UBound($aPlaylist) Then
						For $i = 0 To UBound($aPlaylist) - 1
							$aPlaylist[$i][9] = ""
						Next
					EndIf
				EndIf
				Return
			Case 1 ;View, either album art for audio or a currently playing video
				z_Child_View_DisplayImage()
			Case 2 ;Add CD
				Local $aDrives = DriveGetDrive("CDROM")
				If @error Then
					z_Notification("NO_DRIVES_EXIST")
					z_Child_OpenPlaylist()
					Return SetError(1, 0, False)
				EndIf
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("Drive", 2, 85, $iWidth, $iHeight)
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				For $i = 1 To $aDrives[0]
					ReDim $GUI_Child[UBound($GUI_Child) + 1]
					$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(StringUpper($aDrives[$i]), $GUI_Child[0])
					;Handle events here
				Next
				z_SetTheme($mSettings["Theme"])
			Case 3 ;Playlist Management
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("#" & Chr(1) & "Artist" & Chr(1) & "Title" & Chr(1) & "Album" & Chr(1) & "Track" & Chr(1) & "Year" & Chr(1) & "Source", 2, 85, $iWidth, $iHeight)
				Sleep(500)
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				If UBound($aPlaylist) Then
					For $i = 0 To UBound($aPlaylist) - 1
						ReDim $GUI_Child[UBound($GUI_Child) + 1]
						$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($i + 1) & Chr(1) & $aPlaylist[$i][4] & Chr(1) & $aPlaylist[$i][5] & Chr(1) & $aPlaylist[$i][6] & Chr(1) & $aPlaylist[$i][3] & Chr(1) & $aPlaylist[$i][7] & Chr(1) & $aPlaylist[$i][0], $GUI_Child[0])
						$aPlaylist[$i][9] = $GUI_Child[UBound($GUI_Child) - 1]
						GUICtrlSetOnEvent($aPlaylist[$i][9], "z_Child_PlaylistEvent")
					Next
				EndIf
				z_SetTheme($mSettings["Theme"])
			Case 4 ;Theme Management
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("Theme Title" & Chr(1) & "Theme ID", 2, 85, $iWidth, $iHeight)
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				If IsMap($Theme) Then
					Local $aThemes = MapKeys($Theme)
					For $vTheme In $aThemes
						Local $sTheme_ID = $vTheme
						Local $sTheme_DisplayName = $Theme[$vTheme]["Settings_DisplayName"]
						ReDim $GUI_Child[UBound($GUI_Child) + 1]
						$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem($sTheme_DisplayName & Chr(1) & $sTheme_ID, $GUI_Child[0])
						GUICtrlSetOnEvent($GUI_Child[UBound($GUI_Child) - 1], "z_ChangeTheme")
					Next
				EndIf
				z_SetTheme($mSettings["Theme"])
			Case 5 ;Notifications
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("#" & Chr(1) & "Date" & Chr(1) & "Time" & Chr(1) & "Notification Text", 2, 85, $iWidth, $iHeight, Default, $LVS_EX_DOUBLEBUFFER)
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				If UBound($aNotifications) Then
					For $i = 0 To UBound($aNotifications) - 1
						ReDim $GUI_Child[UBound($GUI_Child) + 1]
						$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($i + 1) & Chr(1) & $aNotifications[$i][0] & Chr(1) & $aNotifications[$i][1] & Chr(1) & $aNotifications[$i][2], $GUI_Child[0])
					Next
				EndIf
				z_SetTheme($mSettings["Theme"])
			Case 6 ;Settings
				;Add interface for changing various zPlayer-related settings
			Case 7 ;About
				ReDim $GUI_Child[1]
				Local $sAboutMsg = "-- " & $Program_Copyright & " --" & _
						@CRLF & _
						$Program_Notice & @CRLF & _
						@CRLF & _
						"AutoIt Version: " & $Program_AutoItVersion & @CRLF & _
						"Title: " & $Program_Title & @CRLF & _
						"Build Number: " & String($Program_Build) & @CRLF & _
						"Release Format: " & $Program_ReleaseFormat & @CRLF & _
						"Author: " & $Program_Author & @CRLF & _
						"Website: " & $Program_Website & " [" & $Program_WebsiteURL & "]" & @CRLF & _
						"License: " & $Program_License & " [" & $Program_LicenseURL & "]" & @CRLF & _
						@CRLF & _
						"Description: " & $Program_Description
				If UBound($Program_Credits) Then
					$sAboutMsg &= @CRLF & @CRLF & "Credits:"
					For $i = 0 To UBound($Program_Credits) - 1
						$sAboutMsg &= @CRLF & "- " & $Program_Credits[$i]
					Next
				EndIf
				$GUI_Child[0] = GUICtrlCreateEdit($sAboutMsg, 2, 85, $iWidth, $iHeight, BitOR($ES_CENTER, $ES_AUTOVSCROLL, $ES_NOHIDESEL, $ES_MULTILINE, $ES_READONLY))
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				GUICtrlSetFont($GUI_Child[0], 9, 0, 0, "Segoe UI")
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				z_SetTheme($mSettings["Theme"])
			Case 8
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("Video ID" & Chr(1) & "Publisher" & Chr(1) & "Title" & Chr(1) & "Description" & Chr(1) & "Publish Date", 2, 85, $iWidth, $iHeight)
				Sleep(500)
				GUICtrlSetBkColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
				GUICtrlSetColor($GUI_Child[0], $Theme[$sCurrentTheme]["Settings_TextColor"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				If UBound($aData) Then
					For $i = 0 To UBound($aData) - 1
						ReDim $GUI_Child[UBound($GUI_Child) + 1]
						$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem($aData[$i][0] & Chr(1) & $aData[$i][1] & Chr(1) & $aData[$i][2] & Chr(1) & $aData[$i][3] & Chr(1) & $aData[$i][4], $GUI_Child[0])
						GUICtrlSetOnEvent($GUI_Child[UBound($GUI_Child) - 1], "z_Child_YouTubeSearchEvent")
					Next
				EndIf
				z_SetTheme($mSettings["Theme"])
			Case Else

		EndSwitch
		$iCurrentGUI = $iGUI
		GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
		;		If $mSettings["Size State"] Then
		;			GUISetState(@SW_MAXIMIZE, $GUI_Main_Handle)
		;		EndIf
	EndIf
EndFunc   ;==>z_OpenChildGUI

;Main management
Func z_MaximizeRestore()
	If $mSettings["Size State"] Then
		GUISetState(@SW_RESTORE, $GUI_Main_Handle)
		$mSettings["Size State"] = 0
		GUICtrlSetImage($GUI_Size_Handle, $Theme[$sCurrentTheme]["Maximize"])
	Else
		GUISetState(@SW_MAXIMIZE, $GUI_Main_Handle)
		$mSettings["Size State"] = 1
		GUICtrlSetImage($GUI_Size_Handle, $Theme[$sCurrentTheme]["Restore"])
	EndIf
EndFunc   ;==>z_MaximizeRestore
Func z_Minimize()
	GUISetState(@SW_MINIMIZE, $GUI_Main_Handle)
EndFunc   ;==>z_Minimize
Func z_Hibernate()
	z_Playlist_Export_Internal(@ScriptDir & "\hiberfil.m3u")
	z_Shutdown()
EndFunc   ;==>z_Hibernate
Func z_Shutdown()
	z_Close()
EndFunc   ;==>z_Shutdown
Func z_Close()
	_BASS_Free()

	;DSEngine_Shutdown()

	SaveOption($sRegistryLocation, "Volume", $mSettings["Volume"])
	SaveOption($sRegistryLocation, "Random", $mSettings["Random"])
	SaveOption($sRegistryLocation, "Repeat", $mSettings["Repeat"])
	SaveOption($sRegistryLocation, "Hidden Themes", $mSettings["Hidden Themes"])
	SaveOption($sRegistryLocation, "Size State", $mSettings["Size State"])
	SaveOption($sRegistryLocation, "Theme", $sCurrentTheme)
	SaveOption($sRegistryLocation, "Themes Directory", $ThemesDir)

	For $i = 0 To UBound($aPlaylist) - 1
		If FileExists($aPlaylist[$i][10]) Then FileDelete($aPlaylist[$i][10])
	Next

	Exit
EndFunc   ;==>z_Close

;Notification management
Func z_Notification($sNotificationUID, $Data1 = "", $Data2 = "")
	AdlibUnRegister("z_Notifications_Clear")

	ConsoleWrite($sNotificationUID & ":" & $Data1 & ":" & $Data2 & @CRLF)
	ConsoleWrite(Binary($sNotificationUID) & ":" & Binary($Data1) & ":" & Binary($Data2) & @CRLF)

	Local $sNotification = ""
	Local $iTimeout = 0
	Switch $sNotificationUID
		Case "DEVMODE_MEMORY_LARGE"
			$sNotification = "Running from developer environment, developer mode enabled."
			$iTimeout = 10000
		Case "NO_AUDIO"
			$sNotification = "An internal error has occurred: No audio location was specified."
			$iTimeout = 5000
		Case "NO_FILE"
			$sNotification = "No file was selected."
			$iTimeout = 2500
		Case "INTERNAL_FILE_FILTER"
			$sNotification = "An internal error has occurred: The filter for audio files is not properly written."
			$iTimeout = 5000
		Case "AUDIO_FILE_LOADING"
			$sNotification = "Loading file [" & $Data1 & "]..."
		Case "AUDIO_FILE_ADDED"
			$sNotification = "Added file [" & $Data1 & "] to the playlist."
			$iTimeout = 3000 + ((StringLen($Data1) / 3) * 200)
		Case "AUDIO_URL_ADDED"
			$sNotification = "Added network URL [" & $Data1 & "] to the playlist."
			$iTimeout = 3000 + ((StringLen($Data1) / 3) * 250)
		Case "NO_FILE"
			$sNotification = "No audio file was selected to play."
			$iTimeout = 3150
		Case "NO_URL"
			$sNotification = "No network URL to an audio track was selected to play."
			$iTimeout = 3150
		Case "AUDIO_ALREADY_PLAYING"
			$sNotification = "An internal error has occurred: There is already an audio stream playing."
			$iTimeout = 5000
		Case "NO_STOP_POSSIBLE"
			$sNotification = "Audio playback could not be stopped as there is currently no audio playing."
			$iTimeout = 5000
		Case "NOW_PLAYING"
			$sNotification = "Now playing [" & $Data1 & "]."
			$iTimeout = 3000 + ((StringLen($Data1) / 3) * 200)
		Case "AUDIO_STOPPED"
			$sNotification = "Stopped the audio playback."
			$iTimeout = 3000
		Case "COULD_NOT_CREATE_STREAM_FROM_FILE"
			$sNotification = "There was an error creating an audio stream from the specified file."
			$iTimeout = 5000
		Case "COULD_NOT_CREATE_STREAM_FROM_URL"
			$sNotification = "There was an error creating an audio stream from the specified URL."
			$iTimeout = 5000
		Case "BASS_INIT_FAILED"
			$sNotification = "There was an error initializing the BASS library. All audio functions will fail."
		Case "RESUME_PLAYING"
			$sNotification = "Resumed playback of audio stream [" & $Data1 & "]."
			$iTimeout = 3000 + ((StringLen($Data1) / 3) * 200)
		Case "PAUSED_AUDIO_STREAM"
			$sNotification = "Paused playback of audio stream [" & $Data1 & "]."
			$iTimeout = 3000 + ((StringLen($Data1) / 3) * 200)
		Case "NETWORK_CACHE_NOTREADY"
			$sNotification = "Network caching for this audio track is not complete. Progress: [" & $Data1 & "]."
			$iTimeout = 5000
		Case "NETWORK_CACHE_COMPLETE"
			$sNotification = "Network caching complete for track [" & $Data1 & "] ([" & $Data2 & "])."
			$iTimeout = 4500
		Case "NETWORK_CACHE_DOWNLOADERROR"
			$sNotification = "An error occurred trying to cache track [" & $Data1 & "]: [" & $Data2 & "]."
			$iTimeout = 5000
		Case "NO_DRIVES_EXIST"
			$sNotification = "Either no CD-ROM drives exist, or there was an error gathering a list of available CD-ROM drives."
			$iTimeout = 6000
		Case "NO_INTERNET"
			$sNotification = "No internet connection is available."
			$iTimeout = 3000
		Case "SAVING_STREAM"
			$sNotification = "Saving stream to file, progress not being checked."
			$iTimeout = 4000
		Case "REPEAT_ENABLED"
			$sNotification = "Enabled repeat."
			$iTimeout = 1250
		Case "REPEAT_DISABLED"
			$sNotification = "Disabled repeat."
			$iTimeout = 1250
		Case "RANDOM_ENABLED"
			$sNotification = "Enabled random."
			$iTimeout = 1250
		Case "RANDOM_DISABLED"
			$sNotification = "Disabled random."
			$iTimeout = 1250
		Case "ERROR_CHILD_INTERFACE"
			$sNotification = "There was an error creating the child interface specified."
			If $Data1 Then $sNotification &= " [" & $Data1 & "]"
			$iTimeout = 4000
		Case Else
			$sNotification = "An undefined notice UID [" & $sNotificationUID & "] has been specified"
			If $Data1 Then
				$sNotification &= " with the following data: [1: " & $Data1 & "]"
				If $Data2 Then
					$sNotification &= ", [2: " & $Data2 & "]"
				EndIf
			ElseIf $Data2 Then
				$sNotification &= " with the following data: [2: " & $Data2 & "]"
			Else
				$sNotification &= "."
			EndIf
			$iTimeout = 5000 + ((StringLen($Data1) / 3) * 200) + ((StringLen($Data2) / 3) * 200)
	EndSwitch

	GUICtrlSetData($GUI_Title_Handle, $sNotification)
	AdlibRegister("z_Notifications_Clear", $iTimeout)

	ReDim $aNotifications[UBound($aNotifications) + 1][3]
	$iEntryPosition = UBound($aNotifications) - 1
	$aNotifications[$iEntryPosition][0] = @MON & "/" & @MDAY & "/" & @YEAR
	$aNotifications[$iEntryPosition][1] = @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC
	$aNotifications[$iEntryPosition][2] = $sNotification

	If $iCurrentGUI = 5 Then
		ReDim $GUI_Child[UBound($GUI_Child) + 1]
		$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($iEntryPosition + 1) & Chr(1) & $aNotifications[$iEntryPosition][0] & Chr(1) & $aNotifications[$iEntryPosition][1] & Chr(1) & $aNotifications[$iEntryPosition][2], $GUI_Child[0])
	EndIf
EndFunc   ;==>z_Notification
Func z_Notifications_Clear()
	GUICtrlSetData($GUI_Title_Handle, $mSettings["Window Title"])
	AdlibUnRegister("z_Notifications_Clear")
EndFunc   ;==>z_Notifications_Clear

;Theme management
Func z_LoadThemes($ThemesDir, ByRef $Theme)
	If Not FileExists($ThemesDir) Then
		Return False
	EndIf
	If Not IsMap($Theme) Then
		Return False
	EndIf

	Local $hThemes = FileFindFirstFile($ThemesDir & "\*")
	If $hThemes = -1 Then
		Return False
	EndIf

	Local $iCount = 0
	Local $mThemes[]

	While 1
		$sThemeDirName = FileFindNextFile($hThemes)
		If @error Then
			ExitLoop
		EndIf
		$sThemeDir = $ThemesDir & "\" & $sThemeDirName
		$sThemeDirAttributes = FileGetAttrib($sThemeDir)
		If StringInStr($sThemeDirAttributes, "D") Then
			If Not $mSettings["Hidden Themes"] Then
				If StringInStr($sThemeDirAttributes, "H") Then
					ContinueLoop
				EndIf
			EndIf
			$sThemeProperties = $sThemeDir & "\theme.properties"
			If FileExists($sThemeProperties) Then
				Local $mTheme[]

				$mTheme["Settings_DisplayName"] = IniRead($sThemeProperties, "Theme Settings", "DisplayName", Chr(1))
				$mTheme["Settings_BackgroundColor"] = IniRead($sThemeProperties, "Theme Settings", "BackgroundColor", Chr(1))
				$mTheme["Settings_TextColor"] = IniRead($sThemeProperties, "Theme Settings", "TextColor", Chr(1))

				$mTheme["Logo"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Logo", Chr(1)) & ".ico"
				$mTheme["Shutdown"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Shutdown", Chr(1)) & ".ico"
				$mTheme["Maximize"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Maximize", Chr(1)) & ".ico"
				$mTheme["Restore"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Restore", Chr(1)) & ".ico"
				$mTheme["Hibernate"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Hibernate", Chr(1)) & ".ico"
				$mTheme["Minimize"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Minimize", Chr(1)) & ".ico"
				$mTheme["Theme"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Theme", Chr(1)) & ".ico"
				$mTheme["AddFile"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "AddFile", Chr(1)) & ".ico"
				$mTheme["AddURL"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "AddURL", Chr(1)) & ".ico"
				$mTheme["AddCD"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "AddCD", Chr(1)) & ".ico"
				$mTheme["Playlist"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Playlist", Chr(1)) & ".ico"
				$mTheme["PlaylistImport"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "PlaylistImport", Chr(1)) & ".ico"
				$mTheme["PlaylistExport"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "PlaylistExport", Chr(1)) & ".ico"
				$mTheme["Previous"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Previous", Chr(1)) & ".ico"
				$mTheme["Play"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Play", Chr(1)) & ".ico"
				$mTheme["Pause"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Pause", Chr(1)) & ".ico"
				$mTheme["Resume"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Resume", Chr(1)) & ".ico"
				$mTheme["Next"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Next", Chr(1)) & ".ico"
				$mTheme["Stop"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Stop", Chr(1)) & ".ico"
				$mTheme["Random"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Random", Chr(1)) & ".ico"
				$mTheme["Repeat"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Repeat", Chr(1)) & ".ico"
				$mTheme["Fill"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Fill", Chr(1)) & ".ico"
				$mTheme["YouTube"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "YouTube", Chr(1)) & ".ico"
				$mTheme["File"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "File", Chr(1)) & ".ico"
				$mTheme["Delete"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Delete", Chr(1)) & ".ico"
				$mTheme["SaveFile"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "SaveFile", Chr(1)) & ".ico"
				$mTheme["View"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "View", Chr(1)) & ".ico"
				$mTheme["Notifications"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Notifications", Chr(1)) & ".ico"
				$mTheme["Settings"] = $sThemeDir & "\" & IniRead($sThemeProperties, "Theme Icons", "Settings", Chr(1)) & ".ico"
				$mThemes[$sThemeDirName] = $mTheme
				$mTheme = ""

				$iCount += 1
			EndIf
		Else
			ContinueLoop
		EndIf
	WEnd

	FileClose($hThemes)

	If $iCount >= 1 Then
		Return $mThemes
	Else
		Return False
	EndIf
EndFunc   ;==>z_LoadThemes
Func z_ChangeTheme()
	Local $sSelectedThemeData = GUICtrlRead(@GUI_CtrlId)
	Local $aSelectedThemeData = StringSplit($sSelectedThemeData, Chr(1))
	z_SetTheme($aSelectedThemeData[2])
EndFunc   ;==>z_ChangeTheme
Func z_SetTheme($sThemeName = "")
	If $sThemeName = $sCurrentTheme Then Return
	GUISetState(@SW_LOCK, $GUI_Main_Handle)
	If $sThemeName Then $sCurrentTheme = $sThemeName
	If Not IsMap($Theme[$sCurrentTheme]) Then Return
	GUISetBkColor($Theme[$sCurrentTheme]["Settings_BackgroundColor"], $GUI_Main_Handle)
	GUICtrlSetColor($GUI_ID3Tags_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetColor($GUI_Title_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetBkColor($GUI_VolumeSlider_Handle, $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
	GUICtrlSetColor($GUI_VolumeCounter_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetBkColor($GUI_AudioPositionSlider_Handle, $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
	GUICtrlSetColor($GUI_AudioPosition_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetColor($GUI_AudioLength_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetColor($GUI_TrackPosition_Handle, $Theme[$sCurrentTheme]["Settings_TextColor"])
	GUICtrlSetImage($GUI_AddCD_Handle, $Theme[$sCurrentTheme]["AddCD"])
	GUICtrlSetImage($GUI_AddFile_Handle, $Theme[$sCurrentTheme]["AddFile"])
	GUICtrlSetImage($GUI_AddURL_Handle, $Theme[$sCurrentTheme]["AddURL"])
	GUICtrlSetImage($GUI_View_Handle, $Theme[$sCurrentTheme]["View"])
	GUICtrlSetImage($GUI_ThemeManagement_Handle, $Theme[$sCurrentTheme]["Theme"])
	GUICtrlSetImage($GUI_Notifications_Handle, $Theme[$sCurrentTheme]["Notifications"])
	GUICtrlSetImage($GUI_Settings_Handle, $Theme[$sCurrentTheme]["Settings"])
	GUICtrlSetImage($GUI_Delete_Handle, $Theme[$sCurrentTheme]["Delete"])
	GUICtrlSetImage($GUI_Hibernate_Handle, $Theme[$sCurrentTheme]["Hibernate"])
	GUICtrlSetImage($GUI_Minimize_Handle, $Theme[$sCurrentTheme]["Minimize"])
	GUICtrlSetImage($GUI_Next_Handle, $Theme[$sCurrentTheme]["Next"])
	GUICtrlSetImage($GUI_Playlist_Handle, $Theme[$sCurrentTheme]["Playlist"])
	GUICtrlSetImage($GUI_PlaylistExport_Handle, $Theme[$sCurrentTheme]["PlaylistExport"])
	GUICtrlSetImage($GUI_PlaylistImport_Handle, $Theme[$sCurrentTheme]["PlaylistImport"])
	If UBound($aPlaylist) Then
		Switch $aPlaylist[$iCurrentTrack][8]
			Case 0
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Play"])
			Case 1
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Pause"])
			Case 2
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Resume"])
			Case 3
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Play"])
			Case Else
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Fill"])
		EndSwitch
	Else
		GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Theme[$sCurrentTheme]["Play"])
	EndIf
	If $mSettings["Size State"] Then
		GUICtrlSetImage($GUI_Size_Handle, $Theme[$sCurrentTheme]["Restore"])
	Else
		GUICtrlSetImage($GUI_Size_Handle, $Theme[$sCurrentTheme]["Maximize"])
	EndIf
	GUICtrlSetImage($GUI_Previous_Handle, $Theme[$sCurrentTheme]["Previous"])
	GUICtrlSetImage($GUI_Random_Handle, $Theme[$sCurrentTheme]["Random"])
	GUICtrlSetImage($GUI_Repeat_Handle, $Theme[$sCurrentTheme]["Repeat"])
	GUICtrlSetImage($GUI_SaveFile_Handle, $Theme[$sCurrentTheme]["SaveFile"])
	GUICtrlSetImage($GUI_Shutdown_Handle, $Theme[$sCurrentTheme]["Shutdown"])
	GUICtrlSetImage($GUI_Stop_Handle, $Theme[$sCurrentTheme]["Stop"])
	If UBound($GUI_Child) Then
		For $i = 0 To UBound($GUI_Child) - 1
			GUICtrlSetBkColor($GUI_Child[$i], $Theme[$sCurrentTheme]["Settings_BackgroundColor"])
			GUICtrlSetColor($GUI_Child[$i], $Theme[$sCurrentTheme]["Settings_TextColor"])
		Next
	EndIf
	GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
EndFunc   ;==>z_SetTheme

;Options saving/loading
Func LoadOption($sRegistryLocation, $sOption, $sDefault = "", $hWnd = "")
	Local $sValue = RegRead($sRegistryLocation, $sOption)
	If Not $sValue Then $sValue = $sDefault
	If IsHWnd($hWnd) Then
		If IsNumber($sValue) Then
			GUICtrlSetState($hWnd, $sValue)
		Else
			GUICtrlSetData($hWnd, $sValue)
		EndIf
	EndIf
	Return $sValue
EndFunc   ;==>LoadOption
Func SaveOption($sRegistryLocation, $sOption, $sValue)
	If IsNumber($sValue) Then
		RegWrite($sRegistryLocation, $sOption, "REG_DWORD", $sValue)
	ElseIf IsString($sValue) Then
		RegWrite($sRegistryLocation, $sOption, "REG_SZ", $sValue)
	ElseIf IsBinary($sValue) Then
		RegWrite($sRegistryLocation, $sOption, "REG_BINARY", $sValue)
	ElseIf IsBool($sValue) Then
		RegWrite($sRegistryLocation, $sOption, "REG_SZ", $sValue)
	Else
		z_Notification("ERROR_OPTION_UNKNOWN_DATA_TYPE", $sOption, $sValue)
	EndIf
EndFunc   ;==>SaveOption

;Miscellaneous
Func z_Service_Identify()
	If UBound($aPlaylist) Then
		If $iCurrentTrack < 0 Then
			$iCurrentTrack = 0
			z_DataUpdate()
		ElseIf $iCurrentTrack > (UBound($aPlaylist) - 1) Then
			$iCurrentTrack = (UBound($aPlaylist) - 1)
			z_DataUpdate()
		EndIf
		Local $sRemoteLocation = $aPlaylist[$iCurrentTrack][0]
		If StringInStr($sRemoteLocation, "youtube.com/watch?v=", 0, 1) Then
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Theme[$sCurrentTheme]["YouTube"])
		ElseIf FileExists($sRemoteLocation) Then
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Theme[$sCurrentTheme]["File"])
		Else
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Theme[$sCurrentTheme]["Fill"])
		EndIf
	Else
		GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Theme[$sCurrentTheme]["Fill"])
	EndIf
EndFunc   ;==>z_Service_Identify
Func z_Service_OpenURL()
	If UBound($aPlaylist) Then
		ShellExecute($aPlaylist[$iCurrentTrack][0])
	EndIf
EndFunc   ;==>z_Service_OpenURL
Func z_DataCheck_ContainsAudioExtension($sLocation)
	If StringRight($sLocation, 4) = ".mp1" Then Return True
	If StringRight($sLocation, 4) = ".mp2" Then Return True
	If StringRight($sLocation, 4) = ".mp3" Then Return True
	If StringRight($sLocation, 4) = ".wav" Then Return True
	If StringRight($sLocation, 4) = ".wma" Then Return True
	If StringRight($sLocation, 4) = ".ogg" Then Return True
	If StringRight($sLocation, 5) = ".aiff" Then Return True
	Return False
EndFunc   ;==>z_DataCheck_ContainsAudioExtension
Func z_DataCheck_ContainsVideoExtension($sLocation)
	If StringRight($sLocation, 4) = ".avi" Then Return True
	If StringRight($sLocation, 4) = ".mpg" Then Return True
	If StringRight($sLocation, 4) = ".wmv" Then Return True
	If StringRight($sLocation, 4) = ".mov" Then Return True
	If StringRight($sLocation, 4) = ".3gp" Then Return True
	If StringRight($sLocation, 4) = ".asf" Then Return True
	If StringRight($sLocation, 4) = ".mp4" Then Return True
	If StringRight($sLocation, 4) = ".flv" Then Return True
	If StringRight($sLocation, 3) = ".rv" Then Return True
	Return False
EndFunc   ;==>z_DataCheck_ContainsVideoExtension
Func z_DataCheck_ContainsURL($sLocation)
	If StringLeft($sLocation, 7) = "http://" Then Return True
	If StringLeft($sLocation, 8) = "https://" Then Return True
	If StringLeft($sLocation, 6) = "ftp://" Then Return True
	Return False
EndFunc   ;==>z_DataCheck_ContainsURL
Func z_DataCheck_GetExtension($sLocation)
	If StringRight($sLocation, 4) = ".mp1" Then Return "mp1"
	If StringRight($sLocation, 4) = ".mp2" Then Return "mp2"
	If StringRight($sLocation, 4) = ".mp3" Then Return "mp3"
	If StringRight($sLocation, 4) = ".wav" Then Return "wav"
	If StringRight($sLocation, 4) = ".wma" Then Return "wma"
	If StringRight($sLocation, 4) = ".ogg" Then Return "ogg"
	If StringRight($sLocation, 5) = ".aiff" Then Return "aiff"
	If StringRight($sLocation, 4) = ".avi" Then Return "avi"
	If StringRight($sLocation, 4) = ".mpg" Then Return "mpg"
	If StringRight($sLocation, 4) = ".wmv" Then Return "wmv"
	If StringRight($sLocation, 4) = ".mov" Then Return "mov"
	If StringRight($sLocation, 4) = ".3gp" Then Return "3gp"
	If StringRight($sLocation, 4) = ".asf" Then Return "asf"
	If StringRight($sLocation, 4) = ".mp4" Then Return "mp4"
	If StringRight($sLocation, 4) = ".flv" Then Return "flv"
	If StringRight($sLocation, 3) = ".rv" Then Return "rv"
	Return False
EndFunc   ;==>z_DataCheck_GetExtension
#EndRegion ;All script functions
