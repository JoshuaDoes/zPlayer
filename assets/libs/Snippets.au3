#Region ;Snippets that are conversions by JoshuaDoes from other source codes
#cs ;This code is from https://gist.github.com/opello/3797251
-- Helper function to get a parameter's value in a URL
function get_url_param( url, name )
    local _, _, res = string.find( url, "[&?]"..name.."=([^&]*)" )
    return res
end
#ce
Func Get_URL_Param($sURL, $sName)
	Local $Result = StringRegExp($sURL, "[&?]" & $sName & "=([^&]*)", 1)
	If @error Then
		Return SetError(1, @error, False)
	Else
		Return SetError(0, $Result, $Result[0])
	EndIf
EndFunc

#cs ;This code is from https://gist.github.com/opello/3797251
function get_arturl()
    local iurl = get_url_param( vlc.path, "iurl" )
    if iurl then
        return iurl
    end
    local video_id = get_url_param( vlc.path, "v" )
    if not video_id then
        return nil
    end
    return "http://img.youtube.com/vi/"..video_id.."/default.jpg"
end
#ce
Func YouTube_Get_ArtURL($sYouTubeWatchURL)
	Local $VideoID = Get_URL_Param($sYouTubeWatchURL, "v")
	If Not $VideoID Then
		Return SetError(1, 0, False)
	Else
		Return SetError(0, $sYouTubeWatchURL, "https://img.youtube.com/vi/" & $VideoID & "/maxresdefault.jpg")
	EndIf
EndFunc
#EndRegion

#Region ;Snippets from the AutoIt website
Func _URIDecode($sData) ;Modified to look neater
    ; Prog@ndy
    Local $aData = StringSplit(StringReplace($sData, "+", " ", 0, 1), "%")
    $sData = ""
    For $i = 2 To $aData[0]
        $aData[1] &= Chr(Dec(StringLeft($aData[$i], 2))) & StringTrimLeft($aData[$i], 2)
    Next
    Return BinaryToString(StringToBinary($aData[1], 1), 4)
EndFunc
#EndRegion

#Region ;Snippets from the AutoIt website, sources will be found again soon
Func Seconds2Time($nr_sec)
   $sec2time_hour = Int($nr_sec / 3600)
   $sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
   $sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
   Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
EndFunc
Func _IsInternetConnected() ;Created by "guinness": http://www.autoitscript.com/forum/user/35302-guinness
    Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')
    If @error Then
        Return SetError(1, 0, False)
    EndIf
    Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected
#EndRegion