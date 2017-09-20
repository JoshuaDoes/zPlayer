#include-once
#include <Array.au3>
#include <JSON.au3>

Func YouTube_Search($sAPIKey, $sQuery, $sType = "video", $iMaxResults = 50)
	Local $sAPI_Name = "youtube"
	Local $sAPI_Version = "v3"
	Local $sAPI_Endpoint = "search"
	Local $aAPI_Parameters = ["part", "maxResults", "q", "type", "key"]
	Local $sAPI_URL = Google_API_FormURL($sAPI_Name, $sAPI_Version, $sAPI_Endpoint, $aAPI_Parameters)
	Google_API_BindParam($sAPI_URL, "snippet")
	Google_API_BindParam($sAPI_URL, $iMaxResults)
	Google_API_BindParam($sAPI_URL, $sQuery)
	Google_API_BindParam($sAPI_URL, $sType)
	Google_API_BindParam($sAPI_URL, $sAPIKey)

	Local $bJSON_Results = InetRead($sAPI_URL)
	If @error Then Return SetError(1, @error, False)
	Local $sJSON_Results = BinaryToString($bJSON_Results)
	Local $oJSON_Results = Json_Decode($sJSON_Results)
	Local $aJSON_Items = Json_Get($oJSON_Results, '["items"]')
	If Not IsArray($aJSON_Items) Then Return SetError(2, 0, False)

	Local $aResults[0][5] ;Video ID, Publisher, Title, Description, Publish Date
	For $i = 0 To UBound($aJSON_Items) - 1
		Local $aJSON_Result_ID = Json_Get($aJSON_Items[$i], '["id"]')
		Local $sResult_VideoID = Json_Get($aJSON_Result_ID, '["videoId"]')
		Local $aJSON_Result_Snippet = Json_Get($aJSON_Items[$i], '["snippet"]')
		Local $sResult_Publisher = Json_Get($aJSON_Result_Snippet, '["channelTitle"]')
		Local $sResult_Title = Json_Get($aJSON_Result_Snippet, '["title"]')
		Local $sResult_Description = Json_Get($aJSON_Result_Snippet, '["description"]')
		Local $sResult_PublishDate = Json_Get($aJSON_Result_Snippet, '["publishedAt"]')

		ReDim $aResults[UBound($aResults) + 1][5]
		$aResults[UBound($aResults) - 1][0] = $sResult_VideoID
		$aResults[UBound($aResults) - 1][1] = $sResult_Publisher
		$aResults[UBound($aResults) - 1][2] = $sResult_Title
		$aResults[UBound($aResults) - 1][3] = $sResult_Description
		$aResults[UBound($aResults) - 1][4] = $sResult_PublishDate
	Next
	Return SetError(0, 0, $aResults)
EndFunc
Func YouTube_Playlist_GetVideos($sAPIKey, $sPlaylistID, $iMaxResults = 50)
	Local $sAPI_Name = "youtube"
	Local $sAPI_Version = "v3"
	Local $sAPI_Endpoint = "playlistItems"
	Local $aAPI_Parameters = ["part", "maxResults", "playlistId", "key"]
	Local $sAPI_URL = Google_API_FormURL($sAPI_Name, $sAPI_Version, $sAPI_Endpoint, $aAPI_Parameters)
	Google_API_BindParam($sAPI_URL, "snippet")
	Google_API_BindParam($sAPI_URL, $iMaxResults)
	Google_API_BindParam($sAPI_URL, $sPlaylistID)
	Google_API_BindParam($sAPI_URL, $sAPIKey)

	Local $bJSON_Results = InetRead($sAPI_URL)
	If @error Then Return SetError(1, @error, False)
	Local $sJSON_Results = BinaryToString($bJSON_Results)
	Local $oJSON_Results = Json_Decode($sJSON_Results)
	Local $aJSON_Items = Json_Get($oJSON_Results, '["items"]')
	If Not IsArray($aJSON_Items) Then Return SetError(2, 0, False)

	Local $aResults[0][5] ;Video ID, Publisher, Title, Description, Publish Date
	For $i = 0 To UBound($aJSON_Items) - 1
		Local $aJSON_Result_Snippet = Json_Get($aJSON_Items[$i], '["snippet"]')
		Local $sResult_Publisher = Json_Get($aJSON_Result_Snippet, '["channelTitle"]')
		Local $sResult_Title = Json_Get($aJSON_Result_Snippet, '["title"]')
		Local $sResult_Description = Json_Get($aJSON_Result_Snippet, '["description"]')
		Local $sResult_PublishDate = Json_Get($aJSON_Result_Snippet, '["publishedAt"]')
		Local $aJSON_Result_Snippet_ResourceID = Json_Get($aJSON_Result_Snippet, '["resourceId"]')
		Local $sResult_VideoID = Json_Get($aJSON_Result_Snippet_ResourceID, '["videoId"]')

		ReDim $aResults[UBound($aResults) + 1][5]
		$aResults[UBound($aResults) - 1][0] = $sResult_VideoID
		$aResults[UBound($aResults) - 1][1] = $sResult_Publisher
		$aResults[UBound($aResults) - 1][2] = $sResult_Title
		$aResults[UBound($aResults) - 1][3] = $sResult_Description
		$aResults[UBound($aResults) - 1][4] = $sResult_PublishDate
	Next
	Return SetError(0, 0, $aResults)
EndFunc
Func Google_API_FormURL($sName, $sVersion, $sEndpoint, $aParams = Null)
	Local $sAPI_URL = "https://www.googleapis.com/" & $sName & "/" & $sVersion & "/" & $sEndpoint
	If IsArray($aParams) Then
		$sAPI_URL &= "?" & $aParams[0] & "=*"
		If UBound($aParams) >= 2 Then
			For $i = 1 To UBound($aParams) - 1
				$sAPI_URL &= "&" & $aParams[$i] & "=*"
			Next
		EndIf
	EndIf
	Return $sAPI_URL
EndFunc
Func Google_API_BindParam(ByRef $sAPIURL, $sValue)
	$sAPIURL = StringReplace($sAPIURL, "=*", "=" & $sValue, 1)
	If @error Then
		Return False
	Else
		Return $sAPIURL
	EndIf
EndFunc