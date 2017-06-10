#cs ----------------------------------------------------------------------------~JD
 -- JoshuaDoes © 2017 --

 This software is still in a development state. Features may be added or removed
 without notice. Warranty is neither expressed nor implied for the system in which
 you run this software.

 AutoIt Version:	3.3.15.0 (Beta)
 Title:				zPlayer Preview
 Build Number:		20
 Release Format:	Proprietary Beta
 Author:			JoshuaDoes (Joshua Wickings)
 Website:			zPlayer [https://joshuadoes.com/zPlayer/]
 License:			GPL v3.0 [https://www.gnu.org/licenses/gpl-3.0.en.html]

 Description:		Play media files with a graphically clean and simple interface that users
					come to expect from their favorite media players.

 Credits:
	- The AutoIt team for creating such an amazing dynamic and diverse scripting language
	  for the Windows operating system
	- All icons under [/assets/icons/icons8/] are from Icons8 [https://icons8.com/]
	  and are modified to match the asset availability requirements for zPlayer
	- Paint.NET for allowing me to modify icons properly to be able to use them in
	  zPlayer
	- Other licenses in their respective folders
#ce ----------------------------------------------------------------------------~JD

#Region ;Directives on how to compile and/or run zPlayer using AutoIt3Wrapper_GUI
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=assets\icons\zPlayer.ico
#AutoIt3Wrapper_Outfile=zPlayer Preview Build 20.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Play media files with a graphically clean and simple interface that users come to expect from their favorite media players.
#AutoIt3Wrapper_Res_Description=zPlayer Preview
#AutoIt3Wrapper_Res_Fileversion=20
#AutoIt3Wrapper_Res_LegalCopyright=JoshuaDoes © 2017
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_HiDpi=y

#NoTrayIcon
#EndRegion

FileInstall(".\Bass.dll", ".\Bass.dll")
FileInstall(".\BassTags.dll", ".\BassTags.dll")
FileInstall(".\changelog.txt", ".\changelog.txt")
If Not FileExists(".\assets\") Then
	DirCreate(".\assets\icons\")
	DirCreate(".\assets\icons\icons8\")
EndIf
FileInstall(".\assets\icons\zPlayer.ico", ".\assets\icons\zPlayer.ico")
FileInstall(".\assets\icons\icons8\Black-Add_CD.ico", ".\assets\icons\icons8\Black-Add_CD.ico")
FileInstall(".\assets\icons\icons8\Black-Add_File.ico", ".\assets\icons\icons8\Black-Add_File.ico")
FileInstall(".\assets\icons\icons8\Black-Add_Link.ico", ".\assets\icons\icons8\Black-Add_Link.ico")
FileInstall(".\assets\icons\icons8\Black-Delete.ico", ".\assets\icons\icons8\Black-Delete.ico")
FileInstall(".\assets\icons\icons8\Black-Export.ico", ".\assets\icons\icons8\Black-Export.ico")
FileInstall(".\assets\icons\icons8\Black-File.ico", ".\assets\icons\icons8\Black-File.ico")
FileInstall(".\assets\icons\icons8\Black-Hibernate.ico", ".\assets\icons\icons8\Black-Hibernate.ico")
FileInstall(".\assets\icons\icons8\Black-Import.ico", ".\assets\icons\icons8\Black-Import.ico")
FileInstall(".\assets\icons\icons8\Black-Maximize_Window.ico", ".\assets\icons\icons8\Black-Maximize_Window.ico")
FileInstall(".\assets\icons\icons8\Black-Minimize_Window.ico", ".\assets\icons\icons8\Black-Minimize_Window.ico")
FileInstall(".\assets\icons\icons8\Black-Next.ico", ".\assets\icons\icons8\Black-Next.ico")
FileInstall(".\assets\icons\icons8\Black-Pause.ico", ".\assets\icons\icons8\Black-Pause.ico")
FileInstall(".\assets\icons\icons8\Black-Play.ico", ".\assets\icons\icons8\Black-Play.ico")
FileInstall(".\assets\icons\icons8\Black-Playlist.ico", ".\assets\icons\icons8\Black-Playlist.ico")
FileInstall(".\assets\icons\icons8\Black-Previous.ico", ".\assets\icons\icons8\Black-Previous.ico")
FileInstall(".\assets\icons\icons8\Black-Random.ico", ".\assets\icons\icons8\Black-Random.ico")
FileInstall(".\assets\icons\icons8\Black-Repeat.ico", ".\assets\icons\icons8\Black-Repeat.ico")
FileInstall(".\assets\icons\icons8\Black-Restore_Window.ico", ".\assets\icons\icons8\Black-Restore_Window.ico")
FileInstall(".\assets\icons\icons8\Black-Resume.ico", ".\assets\icons\icons8\Black-Resume.ico")
FileInstall(".\assets\icons\icons8\Black-Save_File.ico", ".\assets\icons\icons8\Black-Save_File.ico")
FileInstall(".\assets\icons\icons8\Black-Shutdown.ico", ".\assets\icons\icons8\Black-Shutdown.ico")
FileInstall(".\assets\icons\icons8\Black-Stop.ico", ".\assets\icons\icons8\Black-Stop.ico")
FileInstall(".\assets\icons\icons8\Black-Waxing_Crescent.ico", ".\assets\icons\icons8\Black-Waxing_Crescent.ico")
FileInstall(".\assets\icons\icons8\Black-Waxing_Gibbous.ico", ".\assets\icons\icons8\Black-Waxing_Gibbous.ico")
FileInstall(".\assets\icons\icons8\YouTube.ico", ".\assets\icons\icons8\YouTube.ico")

#Region ;Required libraries for program functionality
#include <File.au3> ;Library used for file management
#include <WinAPI.au3> ;Library used for Windows APIs
#include <WinAPISys.au3> ;Library used for Windows System APIs
#include <Array.au3> ;Library used for array management
#include <GDIPlus.au3> ;Library used for GDI+
#include <GUIConstants.au3> ;Constants for GUI
#include <GUIConstantsEx.au3> ;Extra constants for GUI
#include <WindowsConstants.au3> ;Constants for windows
#include <FileConstants.au3> ;Constants for files
#include <String.au3> ;Library for strings
#include <Misc.au3> ;Library for miscellaneous stuff
#include "assets/libs/BASS.au3/BASS/Bass.au3" ;Library used for audio playback
#include "assets/libs/BASS.au3/BASS/BassConstants.au3" ;Constants for BASS
#include "assets/libs/BASS.au3/BASS_TAGS/BassTags.au3" ;Library used for ID3 tags
;#include "assets/libs/DSEngine/DSEngine.au3" ;Library used for DirectShow playback
#include "assets/libs/Snippets.au3" ;Library used for small function snippets from other sources
#include "assets/libs/BorderLessWinUDF.au3" ;Library used for borderless resizeable GUIs
#EndRegion

AutoItSetOption("GUIOnEventMode", 1) ;Events are better than GUI message loops

#Region ;Program constants and statics
;Data about the current program
Global Const $Program_Title = "zPlayer Preview" ;Program title
Global Const $Program_Build = 20 ;Program build number
If Not @Compiled Then ;If running from a development environment,
	Global $DevMode = 1 ;Enable developer and debug features
ElseIf @Compiled Then ;Else if running from a compiled executable,
	Global $DevMode = 0 ;Disable developer and debug features
EndIf

;Locations of image assets that should not change
Global Const $Image_Logo = @ScriptDir & "\assets\icons\zPlayer.ico"
;Dark theme icons
Global Const $Image_Black_Shutdown = @ScriptDir & "\assets\icons\icons8\Black-Shutdown.ico"
Global Const $Image_Black_Maximize = @ScriptDir & "\assets\icons\icons8\Black-Maximize_Window.ico"
Global Const $Image_Black_Restore = @ScriptDir & "\assets\icons\icons8\Black-Restore_Window.ico"
Global Const $Image_Black_Hibernate = @ScriptDir & "\assets\icons\icons8\Black-Hibernate.ico"
Global Const $Image_Black_Minimize = @ScriptDir & "\assets\icons\icons8\Black-Minimize_Window.ico"
Global Const $Image_Black_ColorMode_SetToDark = @ScriptDir & "\assets\icons\icons8\Black-Waxing_Crescent.ico"
Global Const $Image_Black_ColorMode_SetToLight = @ScriptDir & "\assets\icons\icons8\Black-Waxing_Gibbous.ico"
Global Const $Image_Black_AddFile = @ScriptDir & "\assets\icons\icons8\Black-Add_File.ico"
Global Const $Image_Black_AddURL = @ScriptDir & "\assets\icons\icons8\Black-Add_Link.ico"
Global Const $Image_Black_AddCD = @ScriptDir & "\assets\icons\icons8\Black-Add_CD.ico"
Global Const $Image_Black_Playlist = @ScriptDir & "\assets\icons\icons8\Black-Playlist.ico"
Global Const $Image_Black_PlaylistImport = @ScriptDir & "\assets\icons\icons8\Black-Import.ico"
Global Const $Image_Black_PlaylistExport = @ScriptDir & "\assets\icons\icons8\Black-Export.ico"
Global Const $Image_Black_Previous = @ScriptDir & "\assets\icons\icons8\Black-Previous.ico"
Global Const $Image_Black_Play = @ScriptDir & "\assets\icons\icons8\Black-Play.ico"
Global Const $Image_Black_Pause = @ScriptDir & "\assets\icons\icons8\Black-Pause.ico"
Global Const $Image_Black_Resume = @ScriptDir & "\assets\icons\icons8\Black-Resume.ico"
Global Const $Image_Black_Next = @ScriptDir & "\assets\icons\icons8\Black-Next.ico"
Global Const $Image_Black_Stop = @ScriptDir & "\assets\icons\icons8\Black-Stop.ico"
Global Const $Image_Black_Random = @ScriptDir & "\assets\icons\icons8\Black-Random.ico"
Global Const $Image_Black_Repeat = @ScriptDir & "\assets\icons\icons8\Black-Repeat.ico"
Global Const $Image_Black = @ScriptDir & "\assets\icons\icons8\Black.ico"
Global Const $Image_Black_YouTube = @ScriptDir & "\assets\icons\icons8\Black-YouTube.ico"
Global Const $Image_Black_File = @ScriptDir & "\assets\icons\icons8\Black-File.ico"
Global Const $Image_Black_Delete = @ScriptDir & "\assets\icons\icons8\Black-Delete.ico"
Global Const $Image_Black_SaveFile = @ScriptDir & "\assets\icons\icons8\Black-Save_File.ico"
;Light theme icons (not currently in use)
Global Const $Image_White_Shutdown = @ScriptDir & "\assets\icons\icons8\White-Shutdown.ico"
Global Const $Image_White_Maximize = @ScriptDir & "\assets\icons\icons8\White-Maximize_Window.ico"
Global Const $Image_White_Restore = @ScriptDir & "\assets\icons\icons8\White-Restore_Window.ico"
Global Const $Image_White_Hibernate = @ScriptDir & "\assets\icons\icons8\White-Hibernate.ico"
Global Const $Image_White_Minimize = @ScriptDir & "\assets\icons\icons8\White-Minimize_Window.ico"
Global Const $Image_White_ColorMode_SetToDark = @ScriptDir & "\assets\icons\icons8\White-Waxing_Crescent.ico"
Global Const $Image_White_ColorMode_SetToLight = @ScriptDir & "\assets\icons\icons8\White-Waxing_Gibbous.ico"
Global Const $Image_White_AddFile = @ScriptDir & "\assets\icons\icons8\White-Add_File.ico"
Global Const $Image_White_AddURL = @ScriptDir & "\assets\icons\icons8\White-Add_Link.ico"
Global Const $Image_White_AddCD = @ScriptDir & "\assets\icons\icons8\White-Add_CD.ico"
Global Const $Image_White_Playlist = @ScriptDir & "\assets\icons\icons8\White-Playlist.ico"
Global Const $Image_White_PlaylistImport = @ScriptDir & "\assets\icons\icons8\White-Import.ico"
Global Const $Image_White_PlaylistExport = @ScriptDir & "\assets\icons\icons8\White-Export.ico"
Global Const $Image_White_Previous = @ScriptDir & "\assets\icons\icons8\White-Previous.ico"
Global Const $Image_White_Play = @ScriptDir & "\assets\icons\icons8\White-Play.ico"
Global Const $Image_White_Pause = @ScriptDir & "\assets\icons\icons8\White-Pause.ico"
Global Const $Image_White_Resume = @ScriptDir & "\assets\icons\icons8\White-Resume.ico"
Global Const $Image_White_Next = @ScriptDir & "\assets\icons\icons8\White-Next.ico"
Global Const $Image_White_Stop = @ScriptDir & "\assets\icons\icons8\White-Stop.ico"
Global Const $Image_White_Random = @ScriptDir & "\assets\icons\icons8\White-Random.ico"
Global Const $Image_White_Repeat = @ScriptDir & "\assets\icons\icons8\White-Repeat.ico"
Global Const $Image_White = @ScriptDir & "\assets\icons\icons8\White.ico"
Global Const $Image_White_YouTube = @ScriptDir & "\assets\icons\icons8\White-YouTube.ico"
Global Const $Image_White_File = @ScriptDir & "\assets\icons\icons8\White-File.ico"
Global Const $Image_White_Delete = @ScriptDir & "\assets\icons\icons8\White-Delete.ico"
Global Const $Image_White_SaveFile = @ScriptDir & "\assets\icons\icons8\White-Save_File.ico"

;File formats to use for adding files
Global Const $FileFormatFilter = "All Media (*.mp1;*.mp2;*.mp3;*.wav;*.wma;*.ogg;*.aiff;*.avi;*.mpg;*.wmv;*.mov;*.3gp;*.asf;*.mp4;*.flv;*.rv)|Audio (*.mp1;*.mp2;*.mp3;*.wav;*.wma;*.ogg;*.aiff)|Video (*.avi;*.mpg;*.wmv;*.mov;*.3gp;*.asf;*.mp4;*.flv;*.rv)"
Global Const $ImportPlaylistFormatFilter = "Playlist (*.m3u;*.m3u8;*.xspf)"
Global Const $ExportPlaylistFormatFilter = "Playlist (*.m3u;*.m3u8)"
#EndRegion

#Region ;Program variables for global usage
;An array of all debug logs
Global $aLogs[0]
;An array of the following: [Playlist track number][File location, media stream handle, whether media is ready, [if audio] track number, [if audio] artist, [if audio] title, [if audio] album, [if audio] album year, media status, playlist handle]
Global $aPlaylist[0][10]
HotKeySet("G", "z_Playlist_ToggleDev")
;A map of all current settings
Global $mSettings[]
$mSettings["Window Title"] = $Program_Title & " Build " & String($Program_Build)
$mSettings["Volume"] = 100 ;Set the volume setting
$mSettings["Random"] = False ;Whether to play a random track in the playlist or not
$mSettings["Repeat"] = True ;Whether to repeat the playlist or not
$mSettings["Theme"] = 1
$mSettings["GUI Background Color"] = 0x1C1C1C
$mSettings["GUI Text Color"] = 0xFFFFFF
$mSettings["Size State"] = 0 ;0=Normal, 1=Maximized
;Other globals
Global $iCurrentTrack = 0 ;Current track number in the playlist
Global $iCurrentGUI = 0 ;Current child GUI being displayed
Global $bDoubleClick = False

;Media stuff (not currently in use)
Global $hStream = Null ;Main stream
#EndRegion

#Region ;Initialize everything
$GUI_Main_Handle = GUICreate($mSettings["Window Title"], 800, 400, 20, 20, BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX)) ;Create the main GUI
GUISetBkColor($mSettings["GUI Background Color"], $GUI_Main_Handle) ;Set the background color of the main GUI
_GUI_EnableDragAndResize($GUI_Main_Handle, 800, 400, 750, 200, False) ;Make the GUI resizeable and set the minimum resize limit

$GUI_Title_Handle = GUICtrlCreateLabel($mSettings["Window Title"], 0, 0, 800, 15, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetResizing($GUI_Title_Handle, $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_Title_Handle, 9, 0, 0, "Segoe UI")
$GUI_Notice_Handle = GUICtrlCreateLabel("", 2, 310, 776, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_Notice_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetFont($GUI_Notice_Handle, 9, 0, 0, "Segoe UI")
$GUI_ID3Tags_Handle = GUICtrlCreateLabel("No audio track is queued.", 2, 327, 776, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_ID3Tags_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetFont($GUI_ID3Tags_Handle, 9, 0, 0, "Segoe UI")
$GUI_VolumeSlider_Handle = GUICtrlCreateSlider(780, 85, 20, 235, BitOR($TBS_VERT, $TBS_NOTICKS))
GUICtrlSetResizing($GUI_VolumeSlider_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH)
GUICtrlSetLimit($GUI_VolumeSlider_Handle, 100, 0)
GUICtrlSetData($GUI_VolumeSlider_Handle, (100 - $mSettings["Volume"]))
GUICtrlSetBkColor($GUI_VolumeSlider_Handle, $mSettings["GUI Background Color"])
$GUI_VolumeCounter_Handle = GUICtrlCreateLabel($mSettings["Volume"], 779, 320, 20, 15, $SS_CENTER)
GUICtrlSetResizing($GUI_VolumeCounter_Handle, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_VolumeCounter_Handle, 9, 0, 0, "Segoe UI")
$GUI_AudioPositionSlider_Handle = GUICtrlCreateSlider(47, 344, 705, 20, $TBS_NOTICKS)
GUICtrlSetResizing($GUI_AudioPositionSlider_Handle, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetBkColor($GUI_AudioPositionSlider_Handle, $mSettings["GUI Background Color"])
$GUI_AudioPosition_Handle = GUICtrlCreateLabel("00:00:00", 2, 347, 45, 20)
GUICtrlSetResizing($GUI_AudioPosition_Handle, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_AudioPosition_Handle, 9, 0, 0, "Segoe UI")
$GUI_AudioLength_Handle = GUICtrlCreateLabel("00:00:00", 755, 347, 45, 20)
GUICtrlSetResizing($GUI_AudioLength_Handle, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_AudioLength_Handle, 9, 0, 0, "Segoe UI")
$GUI_TrackPosition_Handle = GUICtrlCreateLabel("No tracks in the playlist.", 2, 383, 344, 15)
GUICtrlSetResizing($GUI_TrackPosition_Handle, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
GUICtrlSetFont($GUI_TrackPosition_Handle, 9, 0, 0, "Segoe UI")

$GUI_Logo_Handle = GUICtrlCreateIcon($Image_Logo, -1, 766, 366, 32, 32) ;Create the logo
GUICtrlSetResizing($GUI_Logo_Handle, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
$GUI_AddFile_Handle = GUICtrlCreateIcon($Image_Black_AddFile, -1, 2, 17, 32, 32) ;Create the "Add File" button
GUICtrlSetResizing($GUI_AddFile_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddFile_Handle, "z_Playlist_AddFile")
$GUI_AddURL_Handle = GUICtrlCreateIcon($Image_Black_AddURL, -1, 38, 17, 32, 32) ;Create the "Add URL" button
GUICtrlSetResizing($GUI_AddURL_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddURL_Handle, "z_Playlist_AddURL")
$GUI_PlaylistImport_Handle = GUICtrlCreateIcon($Image_Black_PlaylistImport, -1, 74, 17, 32, 32) ;Create the "Import Playlist" button
GUICtrlSetResizing($GUI_PlaylistImport_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_PlaylistImport_Handle, "z_Playlist_Import")
$GUI_PlaylistExport_Handle = GUICtrlCreateIcon($Image_Black_PlaylistExport, -1, 110, 17, 32, 32) ;Create the "Export Playlist" button
GUICtrlSetResizing($GUI_PlaylistExport_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_PlaylistExport_Handle, "z_Playlist_Export")
$GUI_AddCD_Handle = GUICtrlCreateIcon($Image_Black_AddCD, -1, 2, 51, 32, 32) ;Create the "Add CD" button
GUICtrlSetResizing($GUI_AddCD_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_AddCD_Handle, "z_Child_OpenCD")
$GUI_Playlist_Handle = GUICtrlCreateIcon($Image_Black_Playlist, -1, 38, 51, 32, 32) ;Create the "Playlist" button
GUICtrlSetResizing($GUI_Playlist_Handle, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Playlist_Handle, "z_Child_OpenPlaylist")
$GUI_ServiceIdentify_Handle = GUICtrlCreateIcon($Image_Black, -1, 384, 17, 32, 32) ;Create the "Service Identifier" button
GUICtrlSetResizing($GUI_ServiceIdentify_Handle, $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_ServiceIdentify_Handle, "z_Service_OpenURL")
$GUI_Minimize_Handle = GUICtrlCreateIcon($Image_Black_Minimize, -1, 694, 17, 32, 32) ;Create the "Minimize" button
GUICtrlSetResizing($GUI_Minimize_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Minimize_Handle, "z_Minimize")
$GUI_Size_Handle = GUICtrlCreateIcon($Image_Black_Maximize, -1, 730, 17, 32, 32) ;Create the "Maximize/Restore" button
GUICtrlSetResizing($GUI_Size_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Size_Handle, "z_MaximizeRestore")
$GUI_Hibernate_Handle = GUICtrlCreateIcon($Image_Black_Hibernate, -1, 730, 51, 32, 32) ;Create the "Hibernate" button
GUICtrlSetResizing($GUI_Hibernate_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Hibernate_Handle, "z_Hibernate")
$GUI_Shutdown_Handle = GUICtrlCreateIcon($Image_Black_Shutdown, -1, 766, 17, 32, 32) ;Create the "Shutdown" button
GUICtrlSetResizing($GUI_Shutdown_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_Shutdown_Handle, "z_Shutdown")
$GUI_ColorMode_Handle = GUICtrlCreateIcon($Image_Black_ColorMode_SetToDark, -1, 766, 51, 32, 32) ;Create the "Color Mode" button
GUICtrlSetResizing($GUI_ColorMode_Handle, $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER)
GUICtrlSetOnEvent($GUI_ColorMode_Handle, "z_ColorMode")
$GUI_Previous_Handle = GUICtrlCreateIcon($Image_Black_Previous, -1, 348, 366, 32, 32) ;Create the "Previous" button
GUICtrlSetResizing($GUI_Previous_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Previous_Handle, "z_Playback_Previous")
$GUI_PlayPauseResume_Handle = GUICtrlCreateIcon($Image_Black_Play, -1, 384, 366, 32, 32) ;Create the "Play" button
GUICtrlSetResizing($GUI_PlayPauseResume_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_PlayPauseResume_Handle, "z_Playback_PlayPauseResume")
$GUI_Next_Handle = GUICtrlCreateIcon($Image_Black_Next, -1, 420, 366, 32, 32) ;Create the "Next" button
GUICtrlSetResizing($GUI_Next_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Next_Handle, "z_Playback_Next")
$GUI_Stop_Handle = GUICtrlCreateIcon($Image_Black_Stop, -1, 456, 366, 32, 32) ;Create the "Stop" button
GUICtrlSetResizing($GUI_Stop_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Stop_Handle, "z_Playback_Stop")
$GUI_Delete_Handle = GUICtrlCreateIcon($Image_Black_Delete, -1, 300, 366, 32, 32) ;Create the "Delete Selected Playlist Entry" button
GUICtrlSetResizing($GUI_Delete_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Delete_Handle, "z_Playlist_DeleteEntry")
$GUI_Random_Handle = GUICtrlCreateIcon($Image_Black_Random, -1, 490, 366, 32, 32) ;Create the "Random" button
GUICtrlSetResizing($GUI_Random_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Random_Handle, "z_Playlist_ToggleRandom")
$GUI_Repeat_Handle = GUICtrlCreateIcon($Image_Black_Repeat, -1, 524, 366, 32, 32) ;Create the "Repeat" button
GUICtrlSetResizing($GUI_Repeat_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_Repeat_Handle, "z_Playlist_ToggleRepeat")
$GUI_SaveFile_Handle = GUICtrlCreateIcon($Image_Black_SaveFile, -1, 266, 366, 32, 32) ;Create the "Save File" button
GUICtrlSetResizing($GUI_SaveFile_Handle, $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKVCENTER + $GUI_DOCKHCENTER)
GUICtrlSetOnEvent($GUI_SaveFile_Handle, "z_Playback_SaveFile")

Global $GUI_Child[1]
$GUI_Child[0] = Null
Global $hItem = Null

If $DevMode Then z_Notice("DEVMODE_MEMORY_LARGE")

_BASS_STARTUP(@ScriptDir & "\BASS.dll")
_BASS_Init(0, -1, 44100)
If @error Then
	z_Notice("BASS_INIT_FAILED", @error)
EndIf

_Bass_Tags_Startup(@ScriptDir & "\BassTags.dll")
If @error Then
	z_Notice("BASSTAGS_INIT_FAILED", @error)
EndIf

;DSEngine_Startup()
;If @error Then
;	z_Notice("DIRECTSHOW_INIT_FAILED", @error)
;EndIf

If $CmdLine[0] > 0 Then
;	Switch $CmdLine[1]
;		Case "about"
;			MsgBox(0, $Program_Title & " - About", _
;				$Program_Title & " Build " & $Program_Build & @CRLF & _
;				"Copyright JoshuaDoes © 2017")
;			Exit
;	EndSwitch
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
		Else
			If FileExists(@ScriptDir & "\hiberfil.m3u") Then
				FileDelete(@ScriptDir & "\hiberfil.m3u")
			EndIf
			If StringRight($CmdLine[$i], 4) = ".m3u" Or StringRight($CmdLine[$i], 5) = ".m3u8" Or StringRight($CmdLine[$I], 5) = ".xspf" Then
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

z_SetColors($mSettings["Theme"])
GUISetState(@SW_SHOW, $GUI_Main_Handle) ;Bring it to life
GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE) ;Hide the "Save File" button for later
_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))

If FileExists(@ScriptDir & "\hiberfil.m3u") Then
	z_Playlist_Import_Internal(@ScriptDir & "\hiberfil.m3u")
	FileDelete(@ScriptDir & "\hiberfil.m3u")
EndIf

HotKeySet("{MEDIA_PLAY_PAUSE}", "z_Playback_PlayPauseResume")
HotKeySet("{MEDIA_STOP}", "z_Playback_Stop")
HotKeySet("{MEDIA_PREV}", "z_Playback_Previous")
HotKeySet("{MEDIA_NEXT}", "z_Playback_Next")

If UBound($aPlaylist) Then z_Playback_PlayPauseResume()

$iVolumeTimer = TimerInit()
$iAudioPositionTimer = TimerInit()
#EndRegion

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
			If TimerDiff($iAudioPositionTimer) >= 100 Then
				$iAudioPositionTimer = TimerInit()
				Local $hFocus = ControlGetFocus("")
				Local $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $hFocus)
				If $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $GUI_AudioPositionSlider_Handle) Then
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
						EndIf
					Until Not _IsPressed(1) Or _IsPressed(2)
					_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
					$aPlaylist[$iCurrentTrack][8] = 1
					z_Audio_Play($aPlaylist[$iCurrentTrack][1], 0)
					z_DataUpdate()
				EndIf
			EndIf
			If TimerDiff($iVolumeTimer) >= 100 Then
				$iVolumeTimer = TimerInit()
				Local $hFocus = ControlGetFocus("")
				Local $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $hFocus)
				If $hCurrentHandle = ControlGetHandle($GUI_Main_Handle, "", $GUI_VolumeSlider_Handle) Then
					Local $iOldAudioVolume = Round(GUICtrlRead($GUI_VolumeSlider_Handle))
					Local $iNewAudioVolume = $iOldAudioVolume
					Do
						$iNewAudioVolume = (100 - Round(GUICtrlRead($GUI_VolumeSlider_Handle)))
						If $iOldAudioVolume <> $iNewAudioVolume Then
							z_Audio_SetVolume($iNewAudioVolume)
						EndIf
						$iOldAudioVolume = $iNewAudioVolume
					Until Not _IsPressed(1) Or _IsPressed(02)
					_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
					z_DataUpdate()
				EndIf
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
EndFunc

;Playlist management
Func z_Playlist_ToggleDev()
	If WinActive($GUI_Main_Handle) Then
		If $DevMode Then
			$DevMode = 0
		ElseIf Not $DevMode Then
			$DevMode = 1
		EndIf
	Else
		HotKeySet("G")
		Send("G")
		HotKeySet("G", "z_Playlist_ToggleDev")
	EndIf
EndFunc
Func z_Playlist_AddFile()
	Local $sNewFileLocation = FileOpenDialog("Select a media file...", @UserProfileDir & "\Music", $FileFormatFilter, BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT), "", $GUI_Main_Handle)
	If @error Then ;At least one file was not selected
		Switch @error
			Case 1 ;No file selected, user cancelled dialog box
				z_Notice("NO_FILE")
			Case 2 ;File filter is prepared incorrectly
				z_Notice("INTERNAL_FILE_FILTER")
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
EndFunc
Func z_Playlist_AddURL()
	If Not _IsInternetConnected() Then
		z_Notice("NO_INTERNET")
	Else
		Local $sTempClipboard = ""
		If StringInStr(ClipGet(), "http://", 0, 1, 1) Or StringInStr(ClipGet(), "https://", 0, 1, 1) Or StringInStr(ClipGet(), "ftp://", 0, 1, 1) Then
			$sTempClipboard = ClipGet()
		EndIf
		Local $sNewFileLocation = InputBox("Enter a network URL to an audio file...", "Please enter a network URL to an audio file below." & @CRLF & @CRLF & "Supported URIs: http:// | https:// | ftp://", $sTempClipboard, " M")
		z_Playlist_AddURL_Internal($sNewFileLocation)
		z_Service_Identify()
		z_DataUpdate()
		AdlibRegister("z_DataUpdate", 1000)
	EndIf
EndFunc
Func z_Playlist_AddFile_Internal($sFile)
	Local $sNewFileLocation = $sFile
	Local $iNewEntryCount = UBound($aPlaylist) + 1
	Local $iEntryPosition = UBound($aPlaylist)
	ReDim $aPlaylist[$iNewEntryCount][10] ;Add a new entry to the playlist
	$aPlaylist[$iEntryPosition][0] = $sNewFileLocation ;The location of the audio file
	If z_DataCheck_ContainsAudioExtension($aPlaylist[$iEntryPosition][0]) Then
		$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateFile(False, $aPlaylist[$iEntryPosition][0], 0, 0, $BASS_MUSIC_PRESCAN) ;The stream to use for playing the audio
		If @error Then
			Switch @error
				Case $BASS_ERROR_FILEOPEN
					z_Notice("ERROR_OPENING_FILE")
				Case $BASS_ERROR_FILEFORM
					z_Notice("ERROR_FILE_FORMAT")
				Case $BASS_ERROR_CODEC
					z_Notice("ERROR_AUDIO_CODEC")
				Case $BASS_ERROR_FORMAT
					z_Notice("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
				Case $BASS_ERROR_MEM
					z_Notice("ERROR_NOT_ENOUGH_MEMORY")
				Case $BASS_ERROR_UNKNOWN
					z_Notice("ERROR_UNKNOWN")
			EndSwitch
			ReDim $aPlaylist[$iEntryPosition][10] ;Remove the new entry from the playlist
			Return SetError(1, 0, False)
		EndIf
		$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
		$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,Unknown)") ;The track number within the album
		$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,Unknown)") ;The artist who made the track
		$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,Unknown)") ;The title of the track
		$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,Unknown)") ;The album the track belongs to
		$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,Unknown)") ;The year of the track's release
		$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
	ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iEntryPosition][0]) Then
		z_Playback_Stop()
		$iCurrentTrack = $iEntryPosition
		z_Child_OpenView()
	EndIf
	z_Service_Identify()
	z_DataUpdate()
	z_OpenChildGUI($iCurrentGUI, True)
	AdlibRegister("z_DataUpdate", 1000)
EndFunc
Func z_Playlist_AddURL_Internal($sURL)
	If Not _IsInternetConnected() Then
		z_Notice("NO_INTERNET")
	Else
		Local $sNewFileLocation = $sURL
		If @error Then
			Switch @error
				Case 1
					z_Notice("NO_URL")
			EndSwitch
			Return SetError(1, 0, False)
		EndIf
		If StringInStr($sNewFileLocation, "http://", 0, 1, 1) Or StringInStr($sNewFileLocation, "https://", 0, 1, 1) Or StringInStr($sNewFileLocation, "ftp://", 0, 1, 1) Then
			;Local $sTempLocation = _TempFile(@TempDir & "/zPlayer/", "", "", 20)
			Local $iNewEntryCount = UBound($aPlaylist) + 1
			Local $iEntryPosition = UBound($aPlaylist)
			ReDim $aPlaylist[$iNewEntryCount][10] ;Add a new entry to the playlist
			$aPlaylist[$iEntryPosition][0] = $sNewFileLocation ;The location of the file
			If StringInStr($sNewFileLocation, "youtube.com/watch?v=", 0, 1) Then
				;Temporarily this is going to stick to the roots of MP3 playback until YouTube-DL is incorporated
				$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL("http://www.youtubeinmp3.com/fetch/?video=" & $sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
				If @error Then
					Switch @error
						Case $BASS_ERROR_NONET
							z_Notice("ERROR_NO_CONNECTION")
						Case $BASS_ERROR_ILLPARAM
							z_Notice("ERROR_INVALID_URL")
						Case $BASS_ERROR_TIMEOUT
							z_Notice("ERROR_TIMEOUT")
						Case $BASS_ERROR_FILEOPEN
							z_Notice("ERROR_OPENING_FILE")
						Case $BASS_ERROR_FILEFORM
							z_Notice("ERROR_FILE_FORMAT")
						Case $BASS_ERROR_CODEC
							z_Notice("ERROR_AUDIO_CODEC")
						Case $BASS_ERROR_FORMAT
							z_Notice("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
						Case $BASS_ERROR_MEM
							z_Notice("ERROR_NOT_ENOUGH_MEMORY")
						Case $BASS_ERROR_UNKNOWN
							z_Notice("ERROR_UNKNOWN")
					EndSwitch
					ReDim $aPlaylist[$iEntryPosition][10] ;Remove the new entry from the playlist
					Return SetError(1, 0, False)
				EndIf
				If $aPlaylist[$iEntryPosition][1] = 0 Then
					Local $iCountOut = 0
					Do
						$iCountOut += 1
						$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL("http://www.youtubeinmp3.com/fetch/?video=" & $sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
					Until $aPlaylist[$iEntryPosition][1] > 0 Or $iCountOut >= 5
					If $iCountOut >= 5 Then
						z_Notice("YOUTUBE_FAILED", 5)
						ReDim $aPlaylist[$iEntryPosition][10] ;Remove the new entry from the playlist
						Return SetError(1, 0, False)
					EndIf
				EndIf
				$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
				$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,Unknown)") ;The track number within the album
				$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,Unknown)") ;The artist who made the track
				$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,Unknown)") ;The title of the track
				$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,Unknown)") ;The album the track belongs to
				$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,Unknown)") ;The year of the track's release
				$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
			ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iEntryPosition][0]) Then
				$aPlaylist[$iEntryPosition][1] = _BASS_StreamCreateURL($sNewFileLocation, 0, $BASS_STREAM_RESTRATE) ;The stream to use for playing the audio
				If @error Then
					Switch @error
						Case $BASS_ERROR_NONET
							z_Notice("ERROR_NO_CONNECTION")
						Case $BASS_ERROR_ILLPARAM
							z_Notice("ERROR_INVALID_URL")
						Case $BASS_ERROR_TIMEOUT
							z_Notice("ERROR_TIMEOUT")
						Case $BASS_ERROR_FILEOPEN
							z_Notice("ERROR_OPENING_FILE")
						Case $BASS_ERROR_FILEFORM
							z_Notice("ERROR_FILE_FORMAT")
						Case $BASS_ERROR_CODEC
							z_Notice("ERROR_AUDIO_CODEC")
						Case $BASS_ERROR_FORMAT
							z_Notice("ERROR_SAMPLE_FORMAT_NOT_SUPPORTED")
						Case $BASS_ERROR_MEM
							z_Notice("ERROR_NOT_ENOUGH_MEMORY")
						Case $BASS_ERROR_UNKNOWN
							z_Notice("ERROR_UNKNOWN")
					EndSwitch
					ReDim $aPlaylist[$iEntryPosition][10] ;Remove the new entry from the playlist
					Return SetError(1, 0, False)
				EndIf
				$aPlaylist[$iEntryPosition][2] = True ;Whether or not the audio is ready to be played
				$aPlaylist[$iEntryPosition][3] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TRCK,%TRCK,Unknown)") ;The track number within the album
				$aPlaylist[$iEntryPosition][4] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ARTI,%ARTI,Unknown)") ;The artist who made the track
				$aPlaylist[$iEntryPosition][5] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%TITL,%TITL,Unknown)") ;The title of the track
				$aPlaylist[$iEntryPosition][6] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%ALBM,%ALBM,Unknown)") ;The album the track belongs to
				$aPlaylist[$iEntryPosition][7] = _Bass_Tags_Read($aPlaylist[$iEntryPosition][1], "%IFV2(%YEAR,%YEAR,Unknown)") ;The year of the track's release
				$aPlaylist[$iEntryPosition][8] = 0 ;Flag-based status of the stream
			ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iEntryPosition][0]) Then
				;Add video to playlist and specify tags
			EndIf
		Else
			z_Notice("INVALID_URI")
			Return SetError(1, 0, False)
		EndIf
		z_Service_Identify()
		z_DataUpdate()
		AdlibRegister("z_DataUpdate", 1000)
	EndIf
	z_OpenChildGUI($iCurrentGUI, True)
EndFunc
Func z_Playlist_Import()
	;References for implementing playlists
	;m3u: StringSplit(StringStripCR("yourfile.m3u"), @LF, 1)
	;xspf: StringRegExp("yourfile.xspf", "(?i)<location>(.+?)</location>", 3)

	Local $sFile = FileOpenDialog("Select a playlist...", @UserProfileDir & "\Music", $ImportPlaylistFormatFilter, $FD_FILEMUSTEXIST, "", $GUI_Main_Handle) ;Later I'll implement multiple playlists

	If Not FileExists($sFile) Then Return SetError(1, 0, False)
	z_Playlist_Import_Internal($sFile)
EndFunc
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
EndFunc
Func z_Playlist_Export()
	;This is gonna take awhile, don't expect anything except M3U at first

	Local $sFile = FileSaveDialog("Select a playlist...", @UserProfileDir & "\Music", $ExportPlaylistFormatFilter, Default, "", $GUI_Main_Handle) ;Later I'll implement multiple playlists

	z_Playlist_Export_Internal($sFile)
EndFunc
Func z_Playlist_Export_Internal($sFile)
	;Copy z_Playlist_Export but take filename as parameter

	FileDelete($sFile)
	Select
		Case StringRight($sFile, 4) = ".m3u" Or StringRight($sFile, 5) = ".m3u8"
			For $i = 0 To UBound($aPlaylist) - 1
				FileWrite($sFile, $aPlaylist[$i][0] & @LF)
			Next
	EndSelect
EndFunc
Func z_Playlist_DeleteEntry()
	;Simply because I refuse to add some really long parsing method right now, I'm sticking to this
	;However, I soon plan to break free from Array.au3 and stick to internal methods
	;If I have to, I'll copy this function raw from the UDF and drop it in Snippets
	z_Playback_Stop()
	_ArrayDelete($aPlaylist, $iCurrentTrack)
	If $iCurrentTrack >= UBound($aPlaylist) Then $iCurrentTrack -= 1
	z_Service_Identify()
	z_DataUpdate()
	AdlibUnRegister("z_DataUpdate")
EndFunc
Func z_Playlist_ToggleRepeat()
	If $mSettings["Repeat"] Then
		$mSettings["Repeat"] = False
		z_Notice("REPEAT_DISABLED")
	ElseIf Not $mSettings["Repeat"] Then
		$mSettings["Repeat"] = True
		z_Notice("REPEAT_ENABLED")
	EndIf
EndFunc
Func z_Playlist_ToggleRandom()
	If $mSettings["Random"] Then
		$mSettings["Random"] = False
		z_Notice("RANDOM_DISABLED")
	ElseIf Not $mSettings["Random"] Then
		$mSettings["Random"] = True
		z_Notice("RANDOM_ENABLED")
	EndIf
EndFunc

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
			ConsoleWrite($sSaveName & ":" & $sSaveExtension & @CRLF)
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
				z_Notice("SAVING_STREAM_ERROR:" & @error)
				Return
			EndIf
			InetGet($sOriginLocation, $sSaveLocation, 0, 1)
			z_Notice("SAVING_STREAM")
		EndIf
	EndIf
EndFunc
Func z_Playback_PlayPauseResume()
	If UBound($aPlaylist) Then
		If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_SHOW)
			If $aPlaylist[$iCurrentTrack][8] = 0 Then ;No audio is playing, let's play it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $mSettings["Volume"])
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 1)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Pause)
				GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, z_Audio_GetLength())
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Service_Identify()
				z_Notice("NOW_PLAYING", $aPlaylist[$iCurrentTrack][0])
				GUICtrlSetData($GUI_ID3Tags_Handle, $aPlaylist[$iCurrentTrack][3] & ". " & $aPlaylist[$iCurrentTrack][4] & " - " & $aPlaylist[$iCurrentTrack][5] & " - " & $aPlaylist[$iCurrentTrack][6] & " (" & $aPlaylist[$iCurrentTrack][7] & ")")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Then ;Audio is playing, let's pause it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				z_Notice("PAUSED_AUDIO_STREAM", $aPlaylist[$iCurrentTrack][0])
				_BASS_ChannelPause($aPlaylist[$iCurrentTrack][1])
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Resume)
				$aPlaylist[$iCurrentTrack][8] = 2
				z_DataUpdate()
				AdlibUnregister("z_DataUpdate")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 2 Then ;No audio is playing, let's resume it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 0)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Pause)
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Notice("RESUME_PLAYING", $aPlaylist[$iCurrentTrack][0])
			EndIf
		ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE)
			If $aPlaylist[$iCurrentTrack][8] = 0 Then ;No audio is playing, let's play it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $mSettings["Volume"])
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 1)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Pause)
				GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, z_Audio_GetLength())
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Service_Identify()
				z_Notice("NOW_PLAYING", $aPlaylist[$iCurrentTrack][0])
				GUICtrlSetData($GUI_ID3Tags_Handle, $aPlaylist[$iCurrentTrack][3] & ". " & $aPlaylist[$iCurrentTrack][4] & " - " & $aPlaylist[$iCurrentTrack][5] & " - " & $aPlaylist[$iCurrentTrack][6] & " (" & $aPlaylist[$iCurrentTrack][7] & ")")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Then ;Audio is playing, let's pause it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				z_Notice("PAUSED_AUDIO_STREAM", $aPlaylist[$iCurrentTrack][0])
				_BASS_ChannelPause($aPlaylist[$iCurrentTrack][1])
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Resume)
				$aPlaylist[$iCurrentTrack][8] = 2
				z_DataUpdate()
				AdlibUnregister("z_DataUpdate")
			ElseIf $aPlaylist[$iCurrentTrack][8] = 2 Then ;No audio is playing, let's resume it
				_WinAPI_SetFocus(WinGetHandle($GUI_PlayPauseResume_Handle))
				_BASS_ChannelPlay($aPlaylist[$iCurrentTrack][1], 0)
				GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Pause)
				$aPlaylist[$iCurrentTrack][8] = 1
				z_DataUpdate()
				z_Notice("RESUME_PLAYING", $aPlaylist[$iCurrentTrack][0])
			EndIf
		ElseIf z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
			;Handle playing and pausing video here
		EndIf
	Else
		z_Notice("NO_AUDIO")
		GUICtrlSetData($GUI_ID3Tags_Handle, "No audio track is queued.")
	EndIf
EndFunc
Func z_Playback_Stop()
	If UBound($aPlaylist) Then
		If $aPlaylist[$iCurrentTrack][8] = 0 Then
			z_Notice("NO_STOP_POSSIBLE")
			z_DataUpdate()
			AdlibUnRegister("z_DataUpdate")
		ElseIf $aPlaylist[$iCurrentTrack][8] = 1 Or $aPlaylist[$iCurrentTrack][8] = 2 Then
			_BASS_ChannelStop($aPlaylist[$iCurrentTrack][1])
			_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], 0, $BASS_POS_BYTE)
			GUICtrlSetImage($GUI_PlayPauseResume_Handle, $Image_Black_Play)
			GUICtrlSetData($GUI_AudioPositionSlider_Handle, 0)
			GUICtrlSetLimit($GUI_AudioPositionSlider_Handle, 0)
			$aPlaylist[$iCurrentTrack][8] = 0
			z_DataUpdate()
			AdlibUnregister("z_DataUpdate")
			z_Service_Identify()
			GUICtrlSetData($GUI_ID3Tags_Handle, "No audio track is queued.")
		EndIf
	Else
		z_Notice("NO_STOP_POSSIBLE")
		z_DataUpdate()
		AdlibUnRegister("z_DataUpdate")
	EndIf
EndFunc
Func z_Playback_Previous()
	If UBound($aPlaylist) Then
		If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_SHOW)
		ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iCurrentTrack][0]) Or z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE)
		EndIf

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
	EndIf
EndFunc
Func z_Playback_Next()
	If UBound($aPlaylist) Then
		If z_DataCheck_ContainsURL($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_SHOW)
		ElseIf z_DataCheck_ContainsAudioExtension($aPlaylist[$iCurrentTrack][0]) Or z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
			GUICtrlSetState($GUI_SaveFile_Handle, @SW_HIDE)
		EndIf

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
	EndIf
EndFunc
Func z_Audio_GetPosition($bReturnBytes = False)
	Local $bPosition = _BASS_ChannelGetPosition($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)
	If $bReturnBytes Then
		Return $bPosition
	Else
		Local $iPosition = _BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], $bPosition)
		Return $iPosition
	EndIf
EndFunc
Func z_Audio_SetPosition($iNewAudioPosition, $bSetBytes = False)
	If $bSetBytes Then
		_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], $iNewAudioPosition, $BASS_POS_BYTE)
	Else
		_BASS_ChannelSetPosition($aPlaylist[$iCurrentTrack][1], _BASS_ChannelSeconds2Bytes($aPlaylist[$iCurrentTrack][1], $iNewAudioPosition), $BASS_POS_BYTE)
	EndIf
EndFunc
Func z_Audio_GetLength($bReturnBytes = False)
	Local $bLength = _BASS_ChannelGetLength($aPlaylist[$iCurrentTrack][1], $BASS_POS_BYTE)
	If $bReturnBytes Then
		Return $bLength
	Else
		Local $iLength = _BASS_ChannelBytes2Seconds($aPlaylist[$iCurrentTrack][1], $bLength)
		Return $iLength
	EndIf
EndFunc
Func z_Audio_GetVolume()
	If UBound($aPlaylist) Then
		Return _BASS_ChannelGetVolume($aPlaylist[$iCurrentTrack][1])
	EndIf
EndFunc
Func z_Audio_SetVolume($iVolume)
	If UBound($aPlaylist) Then
		_BASS_ChannelSetVolume($aPlaylist[$iCurrentTrack][1], $iVolume)
	EndIf
EndFunc
Func z_Audio_Play($iTrack, $iReset = 0)
	_BASS_ChannelPlay($iTrack, $iReset)
EndFunc
Func z_Audio_Pause($iTrack)
	_BASS_ChannelPause($iTrack)
EndFunc

;GUI management
Volatile Func z_DataUpdate()
	AdlibUnRegister("z_DataUpdate")
	If UBound($aPlaylist) Then
		GUICtrlSetData($GUI_AudioPosition_Handle, Seconds2Time(Round(z_Audio_GetPosition())))
		GUICtrlSetData($GUI_AudioLength_Handle, Seconds2Time(Round(z_Audio_GetLength())))
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
				$sTrackStatus = "Changing position..."
			Case Else
				$sTrackStatus = "Unknown status"
		EndSwitch
		GUICtrlSetData($GUI_TrackPosition_Handle, ($iCurrentTrack + 1) & "/" & (UBound($aPlaylist)) & " - " & $sTrackStatus)
		If $aPlaylist[$iCurrentTrack][8] = 1 Then
			If Not _WinAPI_GetFocus() = GUICtrlGetHandle($GUI_VolumeSlider_Handle) Then
				Local $iCurrentAudioVolume = Round(_BASS_ChannelGetVolume($aPlaylist[$iCurrentTrack][1]))
				GUICtrlSetData($GUI_VolumeSlider_Handle, (100 - $iCurrentAudioVolume))
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
EndFunc

;Child GUI management
Func z_Child_OpenView()
	z_OpenChildGUI(1)
EndFunc
Func z_Child_OpenCD()
	z_OpenChildGUI(2)
EndFunc
Func z_Child_OpenPlaylist()
	z_OpenChildGUI(3)
EndFunc
Func z_Child_Playlist_SetDoubleClick()
	$bDoubleClick = True
	z_Child_PlaylistEvent()
EndFunc
Volatile Func z_Child_PlaylistEvent()
	ConsoleWrite($bDoubleClick & ":" & $hItem & @CRLF)
	If $bDoubleClick Then
		$bDoubleClick = False
		$hItem = @GUI_CtrlId
		Local $iSelectedTrack = -1
		For $i = 0 To UBound($aPlaylist) - 1
			If $hItem = $aPlaylist[$i][9] Then
				$iSelectedTrack = $i
			EndIf
		Next
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
EndFunc
Func z_Child_PlaylistEvent_Reset()
	$bDoubleClick = False
	$hItem = 0
EndFunc
Func z_OpenChildGUI($iGUI, $bRefresh = False)
	If $iCurrentGUI <> $iGUI Or $bRefresh = True Then
		Local $bMaximised = False
		If $mSettings["Size State"] Then
			GUISetState(@SW_RESTORE, $GUI_Main_Handle)
		EndIf
		GUISetState(@SW_LOCK, $GUI_Main_Handle)
		$iCurrentGUI = $iGUI
		If UBound($GUI_Child) Then
			If UBound($aPlaylist) Then
				If z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
					GUICtrlSetState($GUI_Child[0], @SW_HIDE)
				EndIf
			EndIf
			For $i = 0 To UBound($GUI_Child) - 1
				If IsHWnd(WinGetHandle($GUI_Child[$i])) Then
					GUIDelete($GUI_Child[$i])
				Else
					GUICtrlDelete($GUI_Child[$i])
				EndIf
			Next
			ReDim $GUI_Child[0]
		EndIf
		Switch $iGUI
			Case 0 ;Close whichever child GUI is currently open
				Return
			Case 1 ;View, either album art for audio or video for video
				If UBound($aPlaylist) Then
					If UBound($GUI_Child) Then
						GUISetState(@SW_SHOW, $GUI_Child[0])
					Else
						ReDim $GUI_Child[1]
						If z_DataCheck_ContainsVideoExtension($aPlaylist[$iCurrentTrack][0]) Then
							$GUI_Child[0] = GUICreate($mSettings["Window Title"], 778, 225, 2, 85, $WS_POPUPWINDOW)
							;DSEngine_LoadFile($aPlaylist[$iCurrentTrack][0], $GUI_Child[0])
						EndIf
					EndIf
				EndIf
			Case 2 ;Add CD
				Local $aDrives = DriveGetDrive("CDROM")
				If @error Then
					z_Notice("NO_DRIVES_EXIST")
					z_Child_OpenPlaylist()
					Return SetError(1, 0, False)
				EndIf
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("Drive", 2, 85, 778, 225)
				GUICtrlSetBkColor($GUI_Child[0], $mSettings["GUI Background Color"])
				GUICtrlSetColor($GUI_Child[0], $mSettings["GUI Text Color"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				For $i = 1 To $aDrives[0]
					ReDim $GUI_Child[UBound($GUI_Child) + 1]
					$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(StringUpper($aDrives[$i]), $GUI_Child[0])
					;Handle events here
				Next
				z_SetColors($mSettings["Theme"])
			Case 3 ;Playlist Management
				ReDim $GUI_Child[1]
				$GUI_Child[0] = GUICtrlCreateListView("#|Artist|Title|Album|Track|Year|Source", 2, 85, 778, 225)
				GUICtrlSetBkColor($GUI_Child[0], $mSettings["GUI Background Color"])
				GUICtrlSetColor($GUI_Child[0], $mSettings["GUI Text Color"])
				GUICtrlSetResizing($GUI_Child[0], $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
				If UBound($aPlaylist) Then
					For $i = 0 To UBound($aPlaylist) - 1
						ReDim $GUI_Child[UBound($GUI_Child) + 1]
						$GUI_Child[UBound($GUI_Child) - 1] = GUICtrlCreateListViewItem(($i + 1) & "|" & $aPlaylist[$i][4] & "|" & $aPlaylist[$i][5] & "|" & $aPlaylist[$i][6] & "|" & $aPlaylist[$i][3] & "|" & $aPlaylist[$i][7] & "|" & $aPlaylist[$i][0], $GUI_Child[0])
						$aPlaylist[$i][9] = $GUI_Child[UBound($GUI_Child) - 1]
						GUICtrlSetOnEvent($aPlaylist[$i][9], "z_Child_PlaylistEvent")
					Next
				EndIf
				z_SetColors($mSettings["Theme"])
			Case Else

		EndSwitch
		GUISetState(@SW_UNLOCK, $GUI_Main_Handle)
		If $mSettings["Size State"] Then
			GUISetState(@SW_MAXIMIZE, $GUI_Main_Handle)
		EndIf
	EndIf
EndFunc

;Main management
Func z_MaximizeRestore()
	If $mSettings["Size State"] Then
		GUISetState(@SW_RESTORE, $GUI_Main_Handle)
		$mSettings["Size State"] = 0
		GUICtrlSetImage($GUI_Size_Handle, $Image_Black_Maximize)
	Else
		GUISetState(@SW_MAXIMIZE, $GUI_Main_Handle)
		$mSettings["Size State"] = 1
		GUICtrlSetImage($GUI_Size_Handle, $Image_Black_Restore)
	EndIf
EndFunc
Func z_Minimize()
	GUISetState(@SW_MINIMIZE, $GUI_Main_Handle)
EndFunc
Func z_Hibernate()
	z_Playlist_Export_Internal(@ScriptDir & "\hiberfil.m3u")
	z_Shutdown()
EndFunc
Func z_Shutdown()
	z_Close()
EndFunc
Func z_Close()
	_BASS_Free()
	;DSEngine_Shutdown()
	Exit
EndFunc

;Notice management
Func z_Notice($sNotice, $Data1 = "", $Data2 = "")
	AdlibUnRegister("z_Notice_Clear")
	Switch $sNotice
		Case "DEVMODE_MEMORY_LARGE"
			$sNotice = "Running from developer environment, DevMode enabled. Be aware of large memory usage and possible lag due to debug messages."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
		Case "NO_AUDIO"
			$sNotice = "An internal error has occurred: No audio location was specified."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "NO_FILE"
			$sNotice = "No file was selected."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 2500)
		Case "INTERNAL_FILE_FILTER"
			$sNotice = "An internal error has occurred: The filter for audio files is not properly written."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "AUDIO_FILE_LOADING"
			$sNotice = "Loading file [" & $Data1 & "]..."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
		Case "AUDIO_FILE_ADDED"
			$sNotice = "Added file [" & $Data1 & "] to the playlist."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000 + ((StringLen($Data1) / 3) * 200))
		Case "AUDIO_URL_ADDED"
			$sNotice = "Added network URL [" & $Data1 & "] to the playlist."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000 + ((StringLen($Data1) / 3) * 250))
		Case "AUDIO_URL_LOADING"
			$sNotice = "Loading network URL [" & $Data1 & "] from cache..."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
		Case "NO_FILE"
			$sNotice = "No audio file was selected to play."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3150)
		Case "NO_URL"
			$sNotice = "No network URL to an audio track was selected to play."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3150)
		Case "AUDIO_ALREADY_PLAYING"
			$sNotice = "An internal error has occurred: There is already an audio stream playing."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "NO_STOP_POSSIBLE"
			$sNotice = "Audio playback could not be stopped as there is currently no audio playing."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "NOW_PLAYING"
			$sNotice = "Now playing [" & $Data1 & "]."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000 + ((StringLen($Data1) / 3) * 200))
		Case "AUDIO_STOPPED"
			$sNotice = "Stopped the audio playback."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000)
		Case "COULD_NOT_CREATE_STREAM_FROM_FILE"
			$sNotice = "There was an error creating an audio stream from the specified file."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "COULD_NOT_CREATE_STREAM_FROM_URL"
			$sNotice = "There was an error creating an audio stream from the specified URL."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "BASS_INIT_FAILED"
			$sNotice = "There was an error initializing the BASS library. All audio functions will fail."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
		Case "RESUME_PLAYING"
			$sNotice = "Resumed playback of audio stream [" & $Data1 & "]."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000 + ((StringLen($Data1) / 3) * 200))
		Case "PAUSED_AUDIO_STREAM"
			$sNotice = "Paused playback of audio stream [" & $Data1 & "]."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000 + ((StringLen($Data1) / 3) * 200))
		Case "NETWORK_CACHE_NOTREADY"
			$sNotice = "Network caching for this audio track is not complete. Progress: [" & $Data1 & "]."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "NETWORK_CACHE_COMPLETE"
			$sNotice = "Network caching complete for track [" & $Data1 & "] ([" & $Data2 & "])."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 4500)
		Case "NETWORK_CACHE_DOWNLOADERROR"
			$sNotice = "An error occurred trying to cache track [" & $Data1 & "]: [" & $Data2 & "]."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
		Case "NO_DRIVES_EXIST"
			$sNotice = "Either no CD-ROM drives exist, or there was an error gathering a list of available CD-ROM drives."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 6000)
		Case "NO_INTERNET"
			$sNotice = "No internet connection is available."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 3000)
		Case "SAVING_STREAM"
			$sNotice = "Saving stream to file, progress not being checked."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 4000)
		Case "REPEAT_ENABLED"
			$sNotice = "Enabled repeat."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 1250)
		Case "REPEAT_DISABLED"
			$sNotice = "Disabled repeat."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 1250)
		Case "RANDOM_ENABLED"
			$sNotice = "Enabled random."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 1250)
		Case "RANDOM_DISABLED"
			$sNotice = "Disabled random."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 1250)
		Case Else
			$sNotice = "An internal error has occurred: An undefined notice [" & $sNotice & "] has been specified."
			GUICtrlSetData($GUI_Notice_Handle, $sNotice)
			AdlibRegister("z_Notice_Clear", 5000)
	EndSwitch
EndFunc
Func z_Notice_Clear()
	GUICtrlSetData($GUI_Notice_Handle, "")
	AdlibUnRegister("z_Notice_Clear")
EndFunc

;Theme management
Func z_ColorMode()
	z_SetColors(-1)
EndFunc
Func z_SetColors($ColorMode = 0)
	Local $MaxColorMode = 1
	Local $MinColorMode = 0
	Switch $ColorMode
		Case -1
			If ($mSettings["Theme"] + 1) > $MaxColorMode Then
				$mSettings["Theme"] = $MinColorMode
				z_SetColors($mSettings["Theme"])
				Return
			Else
				z_SetColors($mSettings["Theme"] + 1)
				Return
			EndIf
		Case 0
			$mSettings["GUI Background Color"] = 0xFAFAFA ;Background color for main GUI
			$mSettings["GUI Text Color"] = 0x000000 ;Text color for main GUI
			$mSettings["Theme"] = 0
			GUICtrlSetImage($GUI_ColorMode_Handle, $Image_Black_ColorMode_SetToDark)
		Case 1
			$mSettings["GUI Background Color"] = 0x1C1C1C
			$mSettings["GUI Text Color"] = 0xFFFFFF
			$mSettings["Theme"] = 1
			GUICtrlSetImage($GUI_ColorMode_Handle, $Image_Black_ColorMode_SetToLight)
		Case Else
			z_SetColors($MinColorMode)
			Return
	EndSwitch
	GUISetBkColor($mSettings["GUI Background Color"], $GUI_Main_Handle)
	GUICtrlSetColor($GUI_ID3Tags_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetColor($GUI_Notice_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetColor($GUI_Title_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetBkColor($GUI_VolumeSlider_Handle, $mSettings["GUI Background Color"])
	GUICtrlSetColor($GUI_VolumeCounter_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetBkColor($GUI_AudioPositionSlider_Handle, $mSettings["GUI Background Color"])
	GUICtrlSetColor($GUI_AudioPosition_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetColor($GUI_AudioLength_Handle, $mSettings["GUI Text Color"])
	GUICtrlSetColor($GUI_TrackPosition_Handle, $mSettings["GUI Text Color"])
	If UBound($GUI_Child) Then
		For $i = 0 To UBound($GUI_Child) - 1
			GUICtrlSetBkColor($GUI_Child[$i], $mSettings["GUI Background Color"])
			GUICtrlSetColor($GUI_Child[$i], $mSettings["GUI Text Color"])
		Next
	EndIf
EndFunc

;Miscellaneous
Func z_Service_Identify()
	If UBound($aPlaylist) Then
		Local $sRemoteLocation = $aPlaylist[$iCurrentTrack][0]
		If StringInStr($sRemoteLocation, "youtube.com/watch?v=", 0, 1) Then
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Image_Black_YouTube)
		ElseIf FileExists($sRemoteLocation) Then
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Image_Black_File)
		Else
			GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Image_Black)
		EndIf
	Else
		GUICtrlSetImage($GUI_ServiceIdentify_Handle, $Image_Black)
	EndIf
EndFunc
Func z_Service_OpenURL()
	If UBound($aPlaylist) Then
		ShellExecute($aPlaylist[$iCurrentTrack][0])
	EndIf
EndFunc
Func z_DataCheck_ContainsAudioExtension($sLocation)
	If StringRight($sLocation, 4) = ".mp1" Then Return True
	If StringRight($sLocation, 4) = ".mp2" Then Return True
	If StringRight($sLocation, 4) = ".mp3" Then Return True
	If StringRight($sLocation, 4) = ".wav" Then Return True
	If StringRight($sLocation, 4) = ".wma" Then Return True
	If StringRight($sLocation, 4) = ".ogg" Then Return True
	If StringRight($sLocation, 5) = ".aiff" Then Return True
	Return False
EndFunc
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
EndFunc
Func z_DataCheck_ContainsURL($sLocation)
	If StringLeft($sLocation, 7) = "http://" Then Return True
	If StringLeft($sLocation, 8) = "https://" Then Return True
	If StringLeft($sLocation, 6) = "ftp://" Then Return True
	Return False
EndFunc
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
EndFunc
#EndRegion