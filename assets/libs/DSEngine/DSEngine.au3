;;; IMPORTANT!!!!
;;; All functions that doesn't return specific data has E_FAIL as error return and S_OK as success
;;; Most functions will fail if no file is playing

#include <winapi.au3>
Global $DllEngine
Global $hEngine

; Removes the current overlay bmp
Func DSEngine_RemoveOverlay()
	DllCall($DllEngine,"int:cdecl","RemoveBitmap","ptr",$hEngine)
EndFunc

; Sets a HBITMAP to overlay the current playing video.
; Remove the overlay with Engine_RemoveOverlay
; Source rectangle is in pixels while destination rectangle is in relative coords (0.0 is top, 1.0 is bottom etc.)
; Colorkey is in RRGGBB format (24 bits)
; Alpha channel is 0.0->1.0

Func DSEngine_SetOverlay($hbitmap, $sourceLeft, $sourceTop, $sourceRight, $sourceBottom, _
		$destinationLeft, $destinationTop, $destinationRight, $destinationBottom, $colorkey, $alpha)

	$sourcerect = DllStructCreate($tagRECT)
	DllStructSetData($sourcerect, "left", $sourceLeft)
	DllStructSetData($sourcerect, "top", $sourceTop)
	DllStructSetData($sourcerect, "right", $sourceright)
	DllStructSetData($sourcerect, "bottom", $sourceBottom)

	$destrect = DllStructCreate("float left;float top;float right;float bottom")
	DllStructSetData($destrect, "left", $destinationLeft)
	DllStructSetData($destrect, "top", $destinationTop)
	DllStructSetData($destrect, "right", $destinationRight)
	DllStructSetData($destrect, "bottom", $destinationBottom)

	$ret=DllCall($DllEngine, "int:cdecl", "BlendBitmap", "ptr", $hEngine, "ptr", $hbitmap, "ptr", _
	DllStructGetPtr($sourcerect), "ptr", DllStructGetPtr($destrect), "dword", $colorkey, "float", $alpha)
	Return $ret[0]
EndFunc   ;==>Engine_SetOverlay

; Force VMR9 to redraw the current frame into the selected window
Func DSEngine_Repaint()
	DllCall($DllEngine,"int:cdecl","RepaintFrame","ptr",$hEngine)
EndFunc

; Mutes the audio from directshow
Func DSEngine_Mute()
	$ret=DllCall($DllEngine,"int:cdecl","Mute","ptr",$hEngine)
EndFunc


; Recieve events from DirectShow, see DSEngineConstants.au3 for values
; Also has a minor block, think of it as GUIGetMsg()
Func DSEngine_GetEvent()
	Local $arr[3]
	$ret = DllCall($DllEngine, "int:cdecl", "GetEvent", "ptr", $hEngine, "long*", 0, "long*", 0, "long*", 0)
;~ 	IF @error Then MsgBox(0,"",@error)
	If Not @error And $ret[0] Then
		$arr[0] = $ret[2]
		$arr[1] = $ret[3]
		$arr[2] = $ret[4]
		Return $arr
	Else
		Return False
	EndIf
EndFunc   ;==>Engine_GetEvent

; Get's the playback state, see DSEngineConstants.au3 for values
Func DSEngine_GetState()
;~ 	ConsoleWrite($DllEngine)
	$ret = DllCall($DllEngine, "long:cdecl", "GetState", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetState

;; Sets the letterbox border color, default is black
Func DSEngine_SetBorderColor($RGBColor)
	$ret = DllCall($DllEngine, "int:cdecl", "SetBorderColor", "ptr", $hEngine, "dword", $RGBColor)
	Return $ret[0]
EndFunc   ;==>Engine_SetBorderColor

; All left=-10000
; All right=10000
; Equal balance=0
Func DSEngine_GetAudioBalance()
	$ret = DllCall($DllEngine, "long:cdecl", "GetAudioBalance", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetAudioBalance

; All left=-10000
; All right=10000
; Equal balance=0
Func DSEngine_SetAudioBalance($iBalance)
	$ret = DllCall($DllEngine, "int:cdecl", "SetAudioBalance", "ptr", $hEngine, "long", $iBalance)
	Return $ret[0]
EndFunc   ;==>Engine_SetAudioBalance

; Gets the playback rate as a multiplier (1.0 is normal speed, 0.5 is half, 2.0 is double etc.)
Func DSEngine_GetPlaybackRate()
	$ret = DllCall($DllEngine, "double:cdecl", "GetPlaybackRate", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetPlaybackRate

; Sets the playback rate as a multiplier (1.0 is normal speed, 0.5 is half, 2.0 is double etc.)
Func DSEngine_SetPlaybackRate($dRate)
	$ret = DllCall($DllEngine, "int:cdecl", "SetPlaybackRate", "ptr", $hEngine, "double", $dRate)
	Return $ret[0]
EndFunc   ;==>Engine_SetPlaybackRate

; Save the current frame as a bmp file
Func DSEngine_SaveScreencap($sFilename)
	$ret = DllCall($DllEngine, "int:cdecl", "SaveScreencap", "ptr", $hEngine, "wstr", $sFilename)
	Return $ret[0]
EndFunc   ;==>Engine_SaveScreencap

; Gets the current frame as a hbitmap
Func DSEngine_GetCurrentFrame()
	$ret=DllCall($DllEngine,"ptr:cdecl","GetCurrentFrame","ptr",$hEngine)
	Return $ret[0]
EndFunc

; Gets an array where [0] is width and [1] is height
Func DSEngine_GetVideoSize()
	$ret = DllCall($DllEngine, "int:cdecl", "GetVideoDimensions", "ptr", $hEngine, "long*", 0, "long*", 0)
	Local $arr[2]
	$arr[0] = $ret[2] ; Width
	$arr[1] = $ret[3] ; Height
	Return $arr
EndFunc   ;==>Engine_GetVideoSize

; Sets the playback position in seconds (floating point is ok)
Func DSEngine_SetPosition($dTime)
	$ret = DllCall($DllEngine, "int:cdecl", "SetStreamPosition", "ptr", $hEngine, "double", $dTime)
	Return $ret[0]
EndFunc   ;==>Engine_SetPosition

; Gets the playback position in seconds (floating point is ok)
Func DSEngine_GetPosition()
	$ret = DllCall($DllEngine, "double:cdecl", "GetStreamPosition", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetPosition

; Get the length of the current playing file (in seconds)
Func DSEngine_GetLength()
	$ret = DllCall($DllEngine, "double:cdecl", "GetStreamLength", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetLength

; Makes file ready for playback, also specifying which window the payback should start in
Func DSEngine_LoadFile($sFilename, $WinHandle)
	$ret = DllCall($DllEngine, "int:cdecl", "LoadFile", "ptr", $hEngine, "wstr", $sFilename, "hwnd", $WinHandle)
;~ 	MsgBox(0,"",@error)
	Return $ret[0]
EndFunc   ;==>Engine_LoadFile

; Starts playback
Func DSEngine_StartPlayback()
	$ret = DllCall($DllEngine, "int:cdecl", "StartPlayback", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_StartPlayback

; Pause playback (other function will still work)
Func DSEngine_PausePlayback()
	$ret = DllCall($DllEngine, "int:cdecl", "PausePlayback", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_PausePlayback

; Stop playback (all directshow interfaces is cleared and all functions related to active directshow functions stop working)
Func DSEngine_StopPlayback()
	$ret = DllCall($DllEngine, "int:cdecl", "StopPlayback", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_StopPlayback

; Shutdown the engine, also stopping all active streams
Func DSEngine_Shutdown()
	DllCall($DllEngine, "int:cdecl", "ShutdownEngine", "ptr", $hEngine)
	DllClose($DllEngine)
EndFunc   ;==>Engine_Shutdown

; Gets the volume, max i 0 and min is -10 000 (divide by 100 to get dB)
Func DSEngine_GetVolume()
	$ret = DllCall($DllEngine, "long:cdecl", "GetVolume", "ptr", $hEngine)
	Return $ret[0]
EndFunc   ;==>Engine_GetVolume

; Sets the volume, max i 0 and min is -10 000 (divide by 100 to get dB)
Func DSEngine_SetVolume($vol)
	$ret = DllCall($DllEngine, "int:cdecl", "SetVolume", "ptr", $hEngine, "long", $vol)
	Return $ret[0]
EndFunc   ;==>Engine_SetVolume

; If this is set to false video will not be letterboxed while size changes
Func DSEngine_MaintainAspectRatio($maintain = True)
	$ret = DllCall($DllEngine, "int:cdecl", "MaintainAspectRatio", "ptr", $hEngine, "int", $maintain)
	Return $ret[0]
EndFunc   ;==>Engine_MaintainAspectRatio



; Sets the playing window, also adjust video to client rect
Func DSEngine_SetWindow($WinHandle)
	$ret = DllCall($DllEngine, "int:cdecl", "SetWindow", "ptr", $hEngine, "hwnd", $WinHandle)
	$wsize = WinGetClientSize($WinHandle)
	If @error Then Return False
	DSEngine_SetRects(0, 0, 0, 0, 0, 0, $wsize[0], $wsize[1])
	Return $ret[0]
EndFunc   ;==>Engine_SetWindow

; If rect1 = {0,0,0,0} source is entire video
; Rect1= source rect
; rect2 = destination rect
Func DSEngine_SetRects($left1, $top1, $right1, $bottom1, $left2, $top2, $right2, $bottom2)
	If ($left1 + $top1 + $right1 + $bottom1) > 0 Then
		$rect1 = DllStructCreate($tagRECT)
		DllStructSetData($rect1, "left", $left1)
		DllStructSetData($rect1, "right", $right1)
		DllStructSetData($rect1, "top", $top1)
		DllStructSetData($rect1, "bottom", $bottom1)
		$prect1 = DllStructGetPtr($rect1)
	Else
		$prect1 = 0
	EndIf
	$rect2 = DllStructCreate($tagRECT)
	DllStructSetData($rect2, "left", $left2)
	DllStructSetData($rect2, "right", $right2)
	DllStructSetData($rect2, "top", $top2)
	DllStructSetData($rect2, "bottom", $bottom2)
	$prect2 = DllStructGetPtr($rect2)

	$ret = DllCall($DllEngine, "int:cdecl", "SetRects", "ptr", $hEngine, "ptr", $prect1, "ptr", $prect2)
EndFunc   ;==>Engine_SetRects


; Starts the engine.
Func DSEngine_Startup($sPath = "")
	If Not $sPath Then
		If @AutoItX64 Then
			$sPath = "DSEngine_x64.dll"
		ElseIf Not @AutoItX64 Then
			$sPath = "DSEngine_x86.dll"
		EndIf
	EndIf
	$DllEngine = DllOpen($sPath)
	$ret = DllCall($DllEngine, "ptr:cdecl", "StartupEngine")
	$hEngine = $ret[0]
EndFunc   ;==>Engine_Startup