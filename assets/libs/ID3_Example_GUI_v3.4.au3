#include-once
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ListboxConstants.au3>
#Include <GuiStatusBar.au3>
#Include <GuiListView.au3>
#Include <File.au3>
#Include <Sound.au3>
#Include "ID3_v3.4.au3"
#Include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>

#cs #ID3_Example_GUI.au3 UDF Example Latest Changes.......: ;====================================================================
	Release 3.1 - 20120519
		-Added _GDIPlus functions to handle png file in the ID3v2 APIC Tag Frame
		-Fixed _ID3v2_SaveTag_button_Pressed() when writing ID3v2 UFID, had wrong notation
	Release 3.3
		-Added change of text color when input is edited and only saves tag info on text changed
			-added GUIRegisterMsg and MY_WM_COMMAND() to change the color of text when edited
			-added _GUICtrlGetTextColorEx() from http://www.autoitscript.com/forum/topic/130796-working-example-of-gettextcolorgetbkcolor/page__hl__guictrlgetcolor__fromsearch__1
		-Added ability to change multiple COMM and TXXX tags in ID3v2
		-Added ability to save multiple ID3v2 APIC frames with differant Picture Types
	Release 3.4 - 20120610
		-changed all _ID3v1Field_GetString and _ID3v2Field_GetString to _ID3GetTagField
	Release 3.5 TODO
		-Add Listbox of all ID3v2 frames to be able to select and remove from tag
#ce ;========================================================================================================



;Need this to show .png image files in the picturebox
_GDIPlus_Startup()

Dim $Gui_Width = 850-265-65, $Gui_Height = 550
$ID3Gui_H = GUICreate("ID3 Example GUI", $Gui_Width, $Gui_Height)
;Check for GUI Icon
If Not FileExists(@TempDir & "\id3v22.ico") Then
	InetGet("http://www.id3.org/Developer_Information?action=AttachFile&do=get&target=id3v2.ico", @TempDir & "\id3v22.ico")
EndIf
GUISetIcon(@TempDir & "\id3v22.ico")
TraySetIcon(@TempDir & "\id3v22.ico")
$ProgDir = @WorkingDir & "\"

$StatusBar = _GUICtrlStatusBar_Create($ID3Gui_H, -1, -1)
_GUICtrlStatusBar_SetText($StatusBar , "Status")

$FileOpen_button = GUICtrlCreateButton("Open", 10, 20, 50, 20, $BS_DEFPUSHBUTTON)
$File_input = GUICtrlCreateInput("", 65, 20, 400, 20)
$FilePlay_button = GUICtrlCreateButton("Play", 470, 20, 40, 20)

$FileSize_label = GUICtrlCreateLabel("FileSize:", 400, 50, 50, 20)
$FileSize_input = GUICtrlCreateInput("", 449, 45, 60, 20)



$tab = GUICtrlCreateTab(10,50,500,470)
$ID3_tab = GUICtrlCreateTabitem ("ID3 Data")
$hID3v2Group = GUICtrlCreateGroup("ID3v2",20,74,480,275)
$ID3v2_RemoveTag_button = GUICtrlCreateButton("Remove ID3v2", 100, 90, 85, 20)
$ID3v2_SaveTag_button = GUICtrlCreateButton("Save ID3v2", 190, 90, 70, 20)
$Title_label = GUICtrlCreateLabel("Title (TIT2)", 40, 110, 150, 20)
$Title_input = GUICtrlCreateInput("", 40, 125, 220, 20)
$Artist_label = GUICtrlCreateLabel("Artist (TPE1)", 40, 100+30+20, 150, 20)
$Artist_input = GUICtrlCreateInput("", 40, 100+45+20, 220, 20)
$Album_label = GUICtrlCreateLabel("Album (TALB)", 40, 150+20+20, 150, 20)
$Album_input = GUICtrlCreateInput("", 40, 150+35+20, 220, 20)
$Track_label = GUICtrlCreateLabel("Track (TRCK)", 40, 210+20, 70, 20)
$Track_input = GUICtrlCreateInput("", 40, 200+25+20, 65, 20)
$Length_label = GUICtrlCreateLabel("Length (TLEN)", 118, 210+20, 70, 20)
$Length_input = GUICtrlCreateInput("", 118, 200+25+20, 65, 20)
$Year_label = GUICtrlCreateLabel("Year (TYER)", 195, 210+20, 70, 20)
$Year_input = GUICtrlCreateInput("", 195, 200+25+20, 65, 20)
$Genre_label = GUICtrlCreateLabel("Genre (TCON)", 40, 245+20, 150, 20)
$Genre_input = GUICtrlCreateInput("", 40, 240+20+20, 220, 20)
$COMM_label = GUICtrlCreateLabel("Comment (COMM)", 40, 285+20, 190, 20)
$COMM_input = GUICtrlCreateInput("", 40, 300+20, 220, 20)
$COMM_inputUD = GUICtrlCreateUpdown($COMM_input)
$COMMSet_button = GUICtrlCreateButton("+", 242, 301, 18, 18)
GUICtrlSetState($COMMSet_button, $GUI_DISABLE)


$APIC_pic = -1
$APIC_picBKGlabel = GUICtrlCreateLabel("",285, 95, 200, 200)
GUICtrlSetBkColor($APIC_picBKGlabel, 0xefefef) ; light gray
$APIC_label = GUICtrlCreateLabel("AlbumArt (APIC)", 285, 305, 170, 20)
$APIC_input = GUICtrlCreateInput("",285,320,200,20)
$APIC_inputUD = GUICtrlCreateUpdown($APIC_input)
$APIC_PNGTOJPEG_Encoder = _GDIPlus_EncodersGetCLSID("JPG")
$APIC_GDIPlusImage = -1
GUICtrlSetLimit($APIC_inputUD, 20,0)
Dim $sAPIC_PictureTypes = "Other|32x32 pixels 'file icon'|Other file icon|Cover (front)|Cover (back)|Leaflet page|Media (e.g. lable side of CD)|"
$sAPIC_PictureTypes &= "Lead artist/lead performer/soloist|Artist/performer|Conductor|"
$sAPIC_PictureTypes &= "Lyricist/text writer|Recording Location|During recording|During performance|Movie/video screen capture|"
$sAPIC_PictureTypes &= "A bright coloured fish|Illustration|Band/artist logotype|Publisher/Studio logotype"
$ID3v2_AddAPIC_button = GUICtrlCreateButton("+", 450, 301, 18, 18)
$ID3v2_RemoveAPIC_button = GUICtrlCreateButton("-", 468, 301, 18, 18)

$hID3v1Group = GUICtrlCreateGroup("ID3v1",20, 355 ,480,155)
$TitleV1_label = GUICtrlCreateLabel("Title:", 40, 375, 50, 20)
$TitleV1_input = GUICtrlCreateInput("", 40, 390, 220, 20)
$ArtistV1_label = GUICtrlCreateLabel("Artist:", 40, 415, 50, 20)
$ArtistV1_input = GUICtrlCreateInput("", 40, 430, 220, 20)
$AlbumV1_label = GUICtrlCreateLabel("Album:", 40, 455, 50, 20)
$AlbumV1_input = GUICtrlCreateInput("", 40, 470, 220, 20)
$TrackV1_label = GUICtrlCreateLabel("Track", 280, 375, 50, 20)
$TrackV1_input = GUICtrlCreateInput("", 280, 390, 30, 20)
$YearV1_label = GUICtrlCreateLabel("Year", 340, 375, 50, 20)
$YearV1_input = GUICtrlCreateInput("", 340, 390, 40, 20)
$GenreV1_label = GUICtrlCreateLabel("Genre", 280, 415, 50, 20)
$GenreV1_input = GUICtrlCreateInput("", 280, 430, 200, 20)
$CommentV1_label = GUICtrlCreateLabel("Comment", 280, 455, 50, 20)
$CommentV1_input = GUICtrlCreateInput( "", 280, 470, 200, 20)
$ID3v1_SaveTag_button = GUICtrlCreateButton("Save ID3v1", 395, 368, 85, 20)
$ID3v1_RemoveTag_button = GUICtrlCreateButton("Remove ID3v1", 395, 390, 85, 20)

GUICtrlCreateTabItem(""); end tabitem definition


$ID3v2_tab = GUICtrlCreateTabitem ("ID3v2 More")
$ID3v2Size_label = GUICtrlCreateLabel("Tag Size:", 40, 90, 100, 20)
$ID3v2Size_input = GUICtrlCreateInput("", 40, 105, 50, 20)
$ZPADSize_label = GUICtrlCreateLabel("Zero Padding:", 130, 90, 100, 20)
$ZPADSize_input = GUICtrlCreateInput("", 130, 105, 50, 20)
$Encoder_label = GUICtrlCreateLabel("Encoder (TSSE)", 40, 130, 100, 20)
$Encoder_input = GUICtrlCreateInput("", 40, 145, 220, 20)
$Publisher_label = GUICtrlCreateLabel("Publisher (TPUB)", 40, 150+20, 150, 20)
$Publisher_input = GUICtrlCreateInput("", 40, 150+35, 220, 20)
$UFID_label = GUICtrlCreateLabel("Unique File ID (UFID)", 40, 210, 220, 20)
$UFID_input = GUICtrlCreateInput("", 40, 225, 220, 20)
$Composer_label = GUICtrlCreateLabel("Composer (TCOM)", 40, 250, 150, 20)
$Composer_input = GUICtrlCreateInput("", 40, 265, 220, 20)
$Band_label = GUICtrlCreateLabel("Band/Orchestra/Accompaniment (TPE2)", 40, 290, 220, 20)
$Band_input = GUICtrlCreateInput("", 40, 305, 220, 20)
$WCOM_label = GUICtrlCreateLabel("Commerical Info URL (WCOM)", 280, 90, 200, 20)
$WCOM_input = GUICtrlCreateInput("", 280, 105, 200, 20)
$WXXX_label = GUICtrlCreateLabel("User Defined URL (WXXX)", 280, 130, 200, 20)
$WXXX_input = GUICtrlCreateInput("", 280, 145, 200, 20)
$WOAR_label = GUICtrlCreateLabel("Official artist/performer URL (WOAR)", 280, 170, 200, 20)
$WOAR_input = GUICtrlCreateInput("", 280, 185, 200, 20)
$POPM_label = GUICtrlCreateLabel("Popularimeter (POPM)", 280, 210, 200, 20)
$POPM_input = GUICtrlCreateInput("", 280, 225, 200, 20)
$TXXX_label = GUICtrlCreateLabel("User-Defined Text (TXXX)", 280, 250, 180, 20)
$TXXXSet_button = GUICtrlCreateButton("+", 280+182, 247, 18, 18)
$TXXX_input = GUICtrlCreateInput("", 280, 265, 200, 20)
$TXXX_inputUD = GUICtrlCreateUpdown($TXXX_input)
$Lyrics_label = GUICtrlCreateLabel("Lyrics (USLT)", 40, 355, 150, 20)
$Lyrics_edit = GUICtrlCreateEdit( "", 40, 370, 440, 140)


GUICtrlCreateTabItem(""); end tabitem definition

$APEv2_tab = GUICtrlCreateTabitem ("APEv2")
$APEv2Version_label = GUICtrlCreateLabel("APE Version:", 40, 90, 70, 20)
$APEv2Version_input = GUICtrlCreateInput("", 40, 105, 70, 21)
$APEv2TagSize_label = GUICtrlCreateLabel("Tag Size:", 125, 90, 70, 20)
$APEv2TagSize_input = GUICtrlCreateInput("", 125, 105, 70, 21)
$APEv2ItemCount_label = GUICtrlCreateLabel("Item Count:", 210, 90, 70, 20)
$APEv2ItemCount_input = GUICtrlCreateInput("", 210, 105, 70, 21)
$APEv2_RemoveTag_button = GUICtrlCreateButton("Remove Tag", 300, 104, 90, 23)
$APEv2_SaveTag_button = GUICtrlCreateButton("Save Tag", 400, 104, 90, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2ItemValue_label = GUICtrlCreateLabel("Item Value:", 210, 140, 200, 20)
$APEv2ItemValue_input = GUICtrlCreateInput("", 210, 155, 280, 20)
$APEv2ItemValue_inputUD = GUICtrlCreateUpdown($APEv2ItemValue_input)
$APEv2_label = GUICtrlCreateLabel("APEv2 Item Keys:", 40, 140, 100, 20)
$APEv2_ItemList = GUICtrlCreateList("", 40, 155, 155, 320)
$APEv2_AddItem_button = GUICtrlCreateButton("Add Item", 40, 480, 70, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2_RemoveItem_button = GUICtrlCreateButton("Remove Item", 117, 480, 80, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$APEv2_pic = -1
$APEv2_picBKGlabel = GUICtrlCreateLabel("",210, 190, 284, 284)
GUICtrlSetBkColor($APEv2_picBKGlabel, 0xefefef) ; light gray

GUICtrlCreateTabItem(""); end tabitem definition

$MPEGInfo_tab = GUICtrlCreateTabitem ("MPEG")
$MPEGFrameHeader_label = GUICtrlCreateLabel("MPEG Frame Header:", 40, 110, 125, 20)
$MPEGFrameHeader_input = GUICtrlCreateInput("", 40, 125, 125, 20)
$MPEGVersion_label = GUICtrlCreateLabel("Version:", 40, 100+30+20, 80, 20)
$MPEGVersion_input = GUICtrlCreateInput("", 40, 100+45+20, 125, 20)
$MPEGLayer_label = GUICtrlCreateLabel("Layer:", 40, 150+20+20, 80, 20)
$MPEGLayer_input = GUICtrlCreateInput("", 40, 150+35+20, 125, 20)
$MPEGBitRate_label = GUICtrlCreateLabel("Bitrate:", 40, 210+20, 80, 20)
$MPEGBitRate_input = GUICtrlCreateInput("", 40, 200+25+20, 80, 20)
$MPEGSampleRate_label = GUICtrlCreateLabel("SampleRate:", 40, 210+20+40, 80, 20)
$MPEGSampleRate_input = GUICtrlCreateInput("", 40, 200+25+20+40, 80, 20)
$MPEGChannelMode_label = GUICtrlCreateLabel("ChannelMode:", 40, 210+20+80, 80, 20)
$MPEGChannelMode_input = GUICtrlCreateInput("", 40, 200+25+20+80, 80, 20)
GUICtrlCreateTabItem(""); end tabitem definition


$RawTag_tab = GUICtrlCreateTabitem ("Raw Data")
$TAGINFO_label = GUICtrlCreateLabel("TAG_INFO:", 25, 90, 100, 20)
$TAGINFO_edit = GUICtrlCreateEdit( "", 25, 105, 465, 90)
$ID3v2INFO_label = GUICtrlCreateLabel("ID3v2_INFO", 25, 205, 225, 20)
$ID3v2INFO_edit = GUICtrlCreateEdit("", 25, 220, 225, 285)
$APEv2INFO_label = GUICtrlCreateLabel("APEv2_INFO", 265, 205, 225, 20)
$APEv2INFO_edit = GUICtrlCreateEdit("", 265, 220, 225, 285)


GUICtrlCreateTabItem(""); end tabitem definition

GUIRegisterMsg($WM_COMMAND, "ID3_WM_COMMAND");so we can catch the $EN_CHANGE
Dim $InputCheckUpdates = False, $InputResetAll = False

Dim $szDrive, $szDir, $szFName, $szExt, $Filename

GUISetState()
While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $FileOpen_button
			_FileOpen_button_Pressed()
		Case $FilePlay_button
			_FilePlay_button_Pressed()
		Case $APIC_inputUD
			_APIC_inputUD_Pressed()
		Case $TXXX_inputUD
			_TXXX_inputUD_Pressed()
		Case $TXXXSet_button
			_TXXXSet_button_Pressed()
		Case $COMM_inputUD
			_COMM_inputUD_Pressed()
		Case $COMMSet_button
			_COMMSet_button_Pressed()
		Case $ID3v1_RemoveTag_button
			_ID3v1_RemoveTag_button_Pressed()
		Case $ID3v2_RemoveTag_button
			_ID3v2_RemoveTag_button_Pressed()
		Case $APEv2_RemoveTag_button
			_APEv2_RemoveTag_button_Pressed()
		Case $ID3v1_SaveTag_button
			_ID3v1_SaveTag_button_Pressed()
		Case $ID3v2_SaveTag_button
			_ID3v2_SaveTag_button_Pressed()
		Case $ID3v2_AddAPIC_button
			_ID3v2_AddAPIC_button_Pressed()
		Case $ID3v2_RemoveAPIC_button
			_ID3v2_RemoveAPIC_button_Pressed()
		Case $APEv2_ItemList
			_APEv2_ItemList_list_Pressed()
		Case $APEv2ItemValue_inputUD
			_APEv2ItemValue_inputUD_Pressed()
		Case $GUI_EVENT_CLOSE
			_GUI_EVENT_CLOSE_Pressed()
			ExitLoop
	EndSwitch
WEnd
_GDIPlus_Shutdown()


Func ID3_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	If $InputCheckUpdates Then
		Local $iIDFrom = BitAND($wParam, 0xFFFF) ; LoWord - this gives the control which sent the message
		Local $iCode = BitShift($wParam, 16) ; HiWord - this gives the message that was sent
		If $iCode = $EN_CHANGE Then ; If we have the correct message
			If $InputResetAll Then
				GUICtrlSetColor($iIDFrom, 0x000000)
			Else
				If _GUICtrlGetTextColorEx($iIDFrom) <> 16711680 Then
					GUICtrlSetColor($iIDFrom, 0xff0000)
					If ($iIDFrom == $COMM_input) Then
						GUICtrlSetState($COMMSet_button, $GUI_ENABLE)
						GUICtrlSetColor($COMMSet_button, 0xff0000)
					EndIf
					If ($iIDFrom == $TXXX_input) Then
						GUICtrlSetState($TXXXSet_button, $GUI_ENABLE)
						GUICtrlSetColor($TXXXSet_button, 0xff0000)
					EndIf
					If ($iIDFrom == $APEv2ItemValue_input) Then
						GUICtrlSetColor($APEv2ItemValue_input, 0x000000)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc   ;==>MY_WM_COMMAND


Func _FileOpen_button_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Stop") <> 0 Then
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
	_ResetAll()
	_GUICtrlStatusBar_SetText( $StatusBar , "Reading Tags...")

	$Filename = FileOpenDialog("Select MP3 File", "", "MP3 (*.mp3)", 1 + 4 )

	Dim $TimeToReadTags = 0
	If Not(@error) Then
		$InputCheckUpdates = False
		FileChangeDir($ProgDir)
		_PathSplit($Filename, $szDrive, $szDir, $szFName, $szExt)
		GUICtrlSetData($File_input, $szFName & $szExt)
		GUICtrlSetData($FileSize_input, Round(FileGetSize($Filename)/1048576,2) & " MB")




		Local $begin = TimerInit()
		Local $TAGINFO = _ID3ReadTag($Filename)
		Local $iTAGsFound = @extended
;~ 		MsgBox(0,"@extended",@extended)
;~ 		MsgBox(0,"$TAGINFO",$TAGINFO)
		$TimeToReadTags = TimerDiff($begin)
		GUICtrlSetData($TAGINFO_edit,$TAGINFO)
		GUICtrlSetData($ID3v2INFO_edit,$ID3v2_TagFrameString)
		GUICtrlSetData($APEv2INFO_edit,$APEv2_TagFrameString)

;~ 		Dim $Test = _ID3v2Tag_GetHeaderFlags()
;~ 		MsgBox(0,"Header Flags",$Test)


		;Get ID3v1 Tag
		;_ID3v1Tag_ReadFromFile($Filename)
		GUICtrlSetData($hID3v1Group,"ID3v1." & _ID3v1Tag_GetVersion())
		GUICtrlSetData($TitleV1_input, _ID3GetTagField("Title"))
		GUICtrlSetData($ArtistV1_input, _ID3GetTagField("Artist"))
		GUICtrlSetData($AlbumV1_input, _ID3GetTagField("Album"))
		GUICtrlSetData($TrackV1_input, _ID3GetTagField("Track"))
		GUICtrlSetData($YearV1_input, _ID3GetTagField("Year"))
		GUICtrlSetData($GenreV1_input, _ID3GetTagField("Genre"))
		GUICtrlSetData($CommentV1_input, _ID3GetTagField("Comment"))

		;Get ID3v2 Tag
		;_ID3v2Tag_ReadFromFile($Filename)
		;_ID3v2Tag_GetFrameIDs()
		GUICtrlSetData($hID3v2Group,"ID3v2." & _ID3v2Tag_GetVersion())
		GUICtrlSetData($Title_input, _ID3GetTagField("TIT2"))
		GUICtrlSetData($Artist_input, _ID3GetTagField("TPE1"))
		GUICtrlSetData($Album_input, _ID3GetTagField("TALB"))
		GUICtrlSetData($Track_input, _ID3GetTagField("TRCK"))
		GUICtrlSetData($Year_input, _ID3GetTagField("TYER"))
		GUICtrlSetData($Genre_input, _ID3GetTagField("TCON"))
		GUICtrlSetData($Length_input, _ID3GetTagField("TLEN"))


		;Get Album Art
;~ 		$Test = _ID3v2Frame_GetFields("APIC",1, 1)
;~ 		_ArrayDisplay($Test)

		$AlbumArtFile = _ID3GetTagField("APIC")
		Dim $NumAPIC = @extended
;~ 		MsgBox(0,"$AlbumArtFile",$AlbumArtFile)
		If FileExists($AlbumArtFile) Then

			;Added this to handle APIC tags with png files
			If StringInStr($AlbumArtFile,".png") Then
				$APIC_GDIPlusImage = _GDIPlus_ImageLoadFromFile($AlbumArtFile)
				$AlbumArtFile = StringReplace($AlbumArtFile,".png",".jpg")
				_GDIPlus_ImageSaveToFileEx($APIC_GDIPlusImage,$AlbumArtFile, $APIC_PNGTOJPEG_Encoder)
				_GDIPlus_ImageDispose($APIC_GDIPlusImage)
			EndIf

			Dim $PicTypeIndex = StringInStr($AlbumArtFile,chr(0))
			Local $aAPIC_PictureTypes = StringSplit($sAPIC_PictureTypes,"|",2)
			If _ID3v2Tag_GetVersion() == "2.0" Then
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[0])
			Else
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[Number(StringMid($AlbumArtFile,$PicTypeIndex+1))])
			EndIf

			If $APIC_pic == -1 Then
				GUISwitch($ID3Gui_H,$ID3_tab)
				$APIC_pic = GUICtrlCreatePic($AlbumArtFile,285,95, 200, 200)
				GUICtrlCreateTabItem(""); end tabitem definition
			EndIf
			GUICtrlSetState($APIC_pic, $GUI_SHOW)
			GUICtrlSetImage($APIC_pic, $AlbumArtFile)
			GUICtrlSetData($APIC_label,"AlbumArt (APIC 1 of " & $NumAPIC & ")")
			GUICtrlSetLimit($APIC_inputUD, $NumAPIC,1)
		Else
			GUICtrlSetLimit($APIC_inputUD, 1,1)
		EndIf


		;Get Stuff with multiple FrameIDs
		;TXXX
		Dim $TXXX = _ID3GetTagField("TXXX",1,1) ;return array
		Dim $NumTXXX = @extended
;~ 		_ArrayDisplay($TXXX)
;~ 		MsgBox(0,"$NumTXXX",$NumTXXX)
		If $NumTXXX > 0 Then
			GUICtrlSetLimit($TXXX_inputUD, $NumTXXX + 1,1)
			GUICtrlSetData($TXXX_input,$TXXX[2] & ":" & $TXXX[1])
			GUICtrlSetData($TXXX_label,"User-Defined Text (TXXX 1 of " & $NumTXXX & ")")
		EndIf
		;COMM
		Dim $COMM = _ID3GetTagField("COMM",1) ;return simple string
		Dim $NumCOMM = @extended
;~ 		MsgBox(0,"$NumCOMM",$NumCOMM)
		If $NumCOMM > 0 Then
			GUICtrlSetLimit($COMM_inputUD, $NumCOMM + 1,1)
			GUICtrlSetData($COMM_input,$COMM)
			GUICtrlSetData($COMM_label,"Comment (COMM 1 of " & $NumCOMM & ")")
		EndIf


		;Get More Stuff
		GUICtrlSetData($POPM_input, _ID3GetTagField("POPM"))
		GUICtrlSetData($Encoder_input, _ID3GetTagField("TSSE"))
		GUICtrlSetData($Publisher_input, _ID3GetTagField("TPUB"))
		GUICtrlSetData($Composer_input, _ID3GetTagField("TCOM"))
		GUICtrlSetData($UFID_input, _ID3GetTagField("UFID"))
		GUICtrlSetData($Band_input,_ID3GetTagField("TPE2"))
		GUICtrlSetData($WCOM_input, _ID3GetTagField("WCOM"))
		GUICtrlSetData($WXXX_input, _ID3GetTagField("WXXX"))
		GUICtrlSetData($WOAR_input, _ID3GetTagField("WOAR"))
		$LyricsFile = _ID3GetTagField("USLT")
		GUICtrlSetData($Lyrics_edit,  FileRead($LyricsFile))
		GUICtrlSetData($ZPADSize_input, _ID3v2Tag_GetZPAD())
		GUICtrlSetData($ID3v2Size_input, _ID3v2Tag_GetTagSize())


;~ 		MsgBox(0,"TOAL",_ID3v2Frame_GetFields("TOAL"))


		;Get APEv2 Tag
		;_APEv2Tag_ReadFromFile($Filename)
		If BitAND($iTAGsFound,4) Then
			GUICtrlSetData($APEv2TagSize_input, _APEv2Tag_GetTagSize())
			GUICtrlSetData($APEv2Version_input, _APEv2Tag_GetVersion())
			GUICtrlSetData($APEv2ItemCount_input, _APEv2Tag_GetItemCount())
			GUICtrlSetData($APEv2_ItemList, _APEv2_GetItemKeys("|"))
		EndIf



		;TODO Add more to MPEG Tab
;~ 		Local $MPEGbegin = TimerInit()
		Local $bMPEG = _MPEG_GetFrameHeader($Filename)
;~ 		$MPEGTimeToReadTags = TimerDiff($MPEGbegin)
;~ 		MsgBox(0,"$MPEGTimeToReadTags",Round($MPEGTimeToReadTags,2) & " ms")
		GUICtrlSetData($MPEGFrameHeader_input, $bMPEG)
		GUICtrlSetData($MPEGVersion_input, _MPEG_GetVersion($bMPEG))
		GUICtrlSetData($MPEGLayer_input, _MPEG_GetLayer($bMPEG))
		GUICtrlSetData($MPEGBitRate_input, _MPEG_GetBitRate($bMPEG))
		GUICtrlSetData($MPEGSampleRate_input, _MPEG_GetSampleRate($bMPEG))
		GUICtrlSetData($MPEGChannelMode_input, _MPEG_GetChannelMode($bMPEG))


		_ID3DeleteFiles()
		$InputCheckUpdates = True
	EndIf
	_GUICtrlStatusBar_SetText ( $StatusBar , "Status: Last Tag was read in " & Round($TimeToReadTags,2) & " ms")
EndFunc
Func _FilePlay_button_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Play") <> 0 Then
		SoundPlay($Filename)
		GUICtrlSetData($FilePlay_button,"Stop")
	Else
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
EndFunc




Func _ID3v1_SaveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Writing ID3v1 Tags...")

	If _GUICtrlGetTextColorEx($TitleV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Title",GUICtrlRead($TitleV1_input),0) ;force pad with 0x00
		GUICtrlSetColor($TitleV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($ArtistV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Artist",GUICtrlRead($ArtistV1_input),0) ;force pad with 0x00)
		GUICtrlSetColor($ArtistV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($AlbumV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Album",GUICtrlRead($AlbumV1_input),0) ;force pad with 0x00)
		GUICtrlSetColor($AlbumV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($TrackV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Track",GUICtrlRead($TrackV1_input))
		GUICtrlSetColor($TrackV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($YearV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Year",GUICtrlRead($YearV1_input))
		GUICtrlSetColor($YearV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($GenreV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Genre",GUICtrlRead($GenreV1_input),0) ;force pad with 0x00)
		GUICtrlSetColor($GenreV1_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($CommentV1_input, 0) > 0 Then
		_ID3v1Field_SetString("Comment",GUICtrlRead($CommentV1_input),0)
		GUICtrlSetColor($CommentV1_input, 0x000000)
;~ 		MsgBox(0,"$CommentV1_input","$CommentV1_input")
	EndIf


	Local $begin = TimerInit()
	_ID3v1Tag_WriteToFile($Filename)
	$TimeToReadTags = TimerDiff($begin)
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Last Tag Write in " & Round($TimeToReadTags,2) & " ms")
EndFunc
Func _ID3v2_SaveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Writing ID3v2 Tags...")

	If _GUICtrlGetTextColorEx($Title_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TIT2",GUICtrlRead($Title_input))
		GUICtrlSetColor($Title_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Artist_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TPE1",GUICtrlRead($Artist_input))
		GUICtrlSetColor($Artist_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Year_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TYER",GUICtrlRead($Year_input))
		GUICtrlSetColor($Year_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Album_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TALB",GUICtrlRead($Album_input))
		GUICtrlSetColor($Album_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Track_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TRCK",GUICtrlRead($Track_input))
		GUICtrlSetColor($Track_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Length_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TLEN",GUICtrlRead($Length_input))
		GUICtrlSetColor($Length_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Genre_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TCON",GUICtrlRead($Genre_input))
		GUICtrlSetColor($Genre_input, 0x000000)
	EndIf


;~ 	_ID3v2Frame_SetFields("COMM",GUICtrlRead($COMM_input))

	If _GUICtrlGetTextColorEx($Encoder_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TSSE",GUICtrlRead($Encoder_input))
		GUICtrlSetColor($Encoder_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Publisher_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TPUB",GUICtrlRead($Publisher_input))
		GUICtrlSetColor($Publisher_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($UFID_input, 0) > 0 Then
		_ID3v2Frame_SetFields("UFID",GUICtrlRead($UFID_input))
		GUICtrlSetColor($UFID_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Composer_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TCOM",GUICtrlRead($Composer_input))
		GUICtrlSetColor($Composer_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($Band_input, 0) > 0 Then
		_ID3v2Frame_SetFields("TPE2",GUICtrlRead($Band_input))
		GUICtrlSetColor($Band_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($WCOM_input, 0) > 0 Then
		_ID3v2Frame_SetFields("WCOM",GUICtrlRead($WCOM_input))
		GUICtrlSetColor($WCOM_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($WXXX_input, 0) > 0 Then
		_ID3v2Frame_SetFields("WXXX",GUICtrlRead($WXXX_input))
		GUICtrlSetColor($WXXX_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($WOAR_input, 0) > 0 Then
		_ID3v2Frame_SetFields("WOAR",GUICtrlRead($WOAR_input))
		GUICtrlSetColor($WOAR_input, 0x000000)
	EndIf
	If _GUICtrlGetTextColorEx($POPM_input, 0) > 0 Then
		_ID3v2Frame_SetFields("POPM",GUICtrlRead($POPM_input))
		GUICtrlSetColor($POPM_input, 0x000000)
	EndIf

	If _GUICtrlGetTextColorEx($Lyrics_edit, 0) > 0 Then
		If StringLen(GUICtrlRead($Lyrics_edit)) <> 0 Then
			FileWrite("SongLyrics.txt",GUICtrlRead($Lyrics_edit))
			_ID3v2Frame_SetFields("USLT","SongLyrics.txt")
			GUICtrlSetColor($Lyrics_edit, 0x000000)
			FileDelete("SongLyrics.txt")
		Else
			_ID3v2Frame_SetFields("USLT","") ;remove frame
			GUICtrlSetColor($Lyrics_edit, 0x000000)
		EndIf
	EndIf

	GUICtrlSetColor($COMM_label, 0x000000)
	GUICtrlSetColor($TXXX_label, 0x000000)
	If _GUICtrlGetTextColorEx($APIC_label) > 0 Then
		$AlbumArtFile = _ID3v2Frame_GetFields("APIC")
		Dim $NumAPIC = @extended
;~ 		MsgBox(0,"$AlbumArtFile",$AlbumArtFile)
		If FileExists($AlbumArtFile) Then

			;Added this to handle APIC tags with png files
			If StringInStr($AlbumArtFile,".png") Then
				$APIC_GDIPlusImage = _GDIPlus_ImageLoadFromFile($AlbumArtFile)
				$AlbumArtFile = StringReplace($AlbumArtFile,".png",".jpg")
				_GDIPlus_ImageSaveToFileEx($APIC_GDIPlusImage,$AlbumArtFile, $APIC_PNGTOJPEG_Encoder)
				_GDIPlus_ImageDispose($APIC_GDIPlusImage)
			EndIf

			Dim $PicTypeIndex = StringInStr($AlbumArtFile,chr(0))
			Local $aAPIC_PictureTypes = StringSplit($sAPIC_PictureTypes,"|",2)
			If _ID3v2Tag_GetVersion() == "2.0" Then
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[0])
			Else
				GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[Number(StringMid($AlbumArtFile,$PicTypeIndex+1))])
			EndIf

			If $APIC_pic == -1 Then
				GUISwitch($ID3Gui_H,$ID3_tab)
				$APIC_pic = GUICtrlCreatePic($AlbumArtFile,285,95, 200, 200)
				GUICtrlCreateTabItem(""); end tabitem definition
			EndIf
			GUICtrlSetState($APIC_pic, $GUI_SHOW)
			GUICtrlSetImage($APIC_pic, $AlbumArtFile)
			GUICtrlSetData($APIC_label,"AlbumArt (APIC 1 of " & $NumAPIC & ")")
			GUICtrlSetLimit($APIC_inputUD, $NumAPIC,1)
		EndIf
		GUICtrlSetColor($APIC_label, 0x000000)
	Endif
	GUICtrlSetColor($APIC_input, 0x000000)


	Local $begin = TimerInit()
	_ID3v2Tag_WriteToFile($Filename)
	$TimeToReadTags = TimerDiff($begin)
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Last Tag Write in " & Round($TimeToReadTags,2) & " ms")
EndFunc
; #FUNCTION# ======================================================================================
; Name...........: _GUICtrlGetTextColorEx
; Description ...: Get RGB text colour of in-process standard controls
; Syntax.........: _GUICtrlGetTextColorEx($hWnd, $iRType = 0)
; Parameters ....: $hWnd - Handle or Control ID of standard control: Static (Label), Edit(Edit/Input),
;                  Button (Ownerdrawn/Classic Theme PushButton**, Group, Radio, CheckBox), ListBox, ComboBox
; Parameters ....: $iRType - RGB return type: 0 = Integer / 1 = Hex String
; Return values .: Success - Returns the RGB value as Integer or Hex String
;                  Failure - $CLR_INVALID = 0xFFFFFFFF (-1), sets @error to integer indicating location in function.
; Author ........: rover 2k11 - code portions and ideas from: Chris Boss, Prog@ndy, Malkey, Yashied, and Wraithdu.
; Modified.......:
; Remarks .......: Returns text colour for visible, hidden or disabled in-process controls.
;                  on an active, inactive, hidden, locked, disabled or minimized gui.
; Related .......:
; Link ..........:
; Example .......: Yes
; =================================================================================================
Func _GUICtrlGetTextColorEx($hWnd, $iRType = 0)
	;Author: rover 2k11
	If Not IsDeclared("CLR_INVALID") Then Local Const $CLR_INVALID = 0xFFFFFFFF
	Local $iRet = $CLR_INVALID
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, $iRet)
	Local $hParent = _WinAPI_GetParent($hWnd)
	If Not IsHWnd($hParent) Then Return SetError(2, @error, $iRet)
	If Not IsDeclared("WM_CTLCOLORSTATIC") Then Local Const $WM_CTLCOLORSTATIC = 0x0138
	Local $hDC = _WinAPI_GetDC($hWnd)
	If @error Or $hDC = 0 Then Return SetError(3, @error, $iRet)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	If @error Or $hMemDC = 0 Then Return SetError(4, _WinAPI_ReleaseDC($hWnd, $hDC), $iRet)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	Local $hBrush = _SendMessage($hParent, $WM_CTLCOLORSTATIC, $hMemDC, $hWnd) ;do not delete returned brush
	If @error Or $hBrush = 0 Then Return SetError(5, _WinAPI_DeleteDC($hMemDC), $iRet)
	Local $BGR = DllCall('gdi32.dll', 'int', 'GetTextColor', 'ptr', $hMemDC)
	If @error Or $BGR[0] = $CLR_INVALID Then Return SetError(6, _WinAPI_DeleteDC($hMemDC), $iRet)
	_WinAPI_DeleteDC($hMemDC)
	;_BGR2RGB($iColor) Author: Wraithdu
	If $iRType = 0 Then $iRet = BitOR(BitShift(BitAND($BGR[0], 0x0000FF), -16), BitAND($BGR[0], 0x00FF00), BitShift(BitAND($BGR[0], 0xFF0000), 16))
	If $iRType = 1 Then $iRet = "0x" & StringRegExpReplace(Hex($BGR[0], 6), "(.{2})(.{2})(.{2})", "\3\2\1"); Author: Prog@ndy
	Return SetError(0, 0, $iRet)
EndFunc   ;==>_GUICtrlGetTextColorEx




Func _ID3v2_AddAPIC_button_Pressed()
	$hID3AddPicGui = GUICreate("Picture Type", 200, 320)
	If FileExists(@TempDir & "\id3v22.ico") Then
		GUISetIcon(@TempDir & "\id3v22.ico")
	EndIf
	$APICGUI_ItemList = GUICtrlCreateList("", 10, 10, 180, 270)
	$APICGUI_OK_button = GUICtrlCreateButton("OK", 10, 285, 80, 23)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$APICGUI_Cancel_button = GUICtrlCreateButton("Cancel", 110, 285, 80, 23)
	GUICtrlSetData($APICGUI_ItemList, $sAPIC_PictureTypes)
	GUISetState(@SW_SHOW,$hID3AddPicGui)
	Local $sAPIC_PictureType = "", $fCancelled = False
	While 1
		$picmsg = GUIGetMsg()
		Switch $picmsg
			Case $APICGUI_ItemList
				GUICtrlSetState($APICGUI_OK_button, $GUI_ENABLE)
			Case $APICGUI_OK_button
				$sAPIC_PictureType = GUICtrlRead($APICGUI_ItemList)
				ExitLoop
			Case $APICGUI_Cancel_button
				$fCancelled = True
				ExitLoop
			Case $GUI_EVENT_CLOSE
				$fCancelled = True
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_HIDE,$hID3AddPicGui)
	If $fCancelled Then
		Return 0
	EndIf

	Local $aPictureTypes = StringSplit($sAPIC_PictureTypes,"|",2)
	Local $iAPIC_PictureType = _ArraySearch($aPictureTypes, $sAPIC_PictureType)

	$PIC_Filename = FileOpenDialog("Select Image File", "", "Images (*.jpg;*.jpeg;*.png)", 1 + 4 )
	IF Not @error Then
		Local $aNumAPIC = StringSplit(GUICtrlRead($APIC_label)," of ",1)
		Local $NumAPIC = 0, $iAPIC_index = 0
		If IsArray($aNumAPIC) Then
			If $aNumAPIC[0] > 1 Then
				$NumAPIC = StringTrimRight($aNumAPIC[2],1)
				$iAPIC_index = StringTrimLeft($aNumAPIC[1],15)
			EndIf
		EndIf
		If $NumAPIC < $iAPIC_index Then
			$NumAPIC += 1
		EndIf
		If GUICtrlRead($APIC_input) <> $sAPIC_PictureType Then
			$iAPIC_index += 1
			$NumAPIC += 1
		EndIf
		GUICtrlSetLimit($APIC_inputUD, $NumAPIC,1)
		_ID3v2Frame_SetFields("APIC",$PIC_Filename & "|" & "" & "|" & String($iAPIC_PictureType),$iAPIC_index,"|")
		If $APIC_pic == -1 Then
			GUISwitch($ID3Gui_H,$ID3_tab)
			$APIC_pic = GUICtrlCreatePic($PIC_Filename,285,95, 200, 200)
			GUICtrlCreateTabItem(""); end tabitem definition
		EndIf
		GUICtrlSetData($APIC_input,$sAPIC_PictureType)
		GUICtrlSetState($APIC_pic, $GUI_SHOW)
		GUICtrlSetImage($APIC_pic, $PIC_Filename)
		GUICtrlSetData($APIC_label,"AlbumArt (APIC " & $iAPIC_index & " of " & $NumAPIC & ")")
	EndIf

EndFunc
Func _ID3v2_RemoveAPIC_button_Pressed()
	Local $aNumAPIC = StringSplit(GUICtrlRead($APIC_label)," of ",1)
	Local $NumAPIC = 0, $iAPIC_index = 1
	If IsArray($aNumAPIC) Then
		If $aNumAPIC[0] > 1 Then
			$NumAPIC = StringTrimRight($aNumAPIC[2],1)
			$iAPIC_index = StringTrimLeft($aNumAPIC[1],15)
		EndIf
	EndIf
	_ID3v2Frame_SetFields("APIC","",$iAPIC_index)
	GUICtrlSetState($APIC_pic, $GUI_HIDE) ;removes picture
	GUICtrlSetColor($APIC_input, 0xff0000)
	GUICtrlSetColor($APIC_label, 0xff0000)
	If $NumAPIC == 1 Then
		GUICtrlSetLimit($APIC_inputUD, 1,1)
		GUICtrlSetData($APIC_input,"")
		GUICtrlSetData($APIC_label,"AlbumArt (APIC)")
	EndIf
EndFunc
Func _APIC_inputUD_Pressed()
	$InputCheckUpdates = False
	Local $iAPIC_index = GUICtrlRead($APIC_input)
	$AlbumArtFile = _ID3v2Frame_GetFields("APIC",$iAPIC_index)
	Dim $NumAPIC = @extended

	If FileExists($AlbumArtFile) Then
		;Added this to handle APIC tags with png files
		If StringInStr($AlbumArtFile,".png") Then
			$APIC_GDIPlusImage = _GDIPlus_ImageLoadFromFile($AlbumArtFile)
			$AlbumArtFile = StringReplace($AlbumArtFile,".png",".jpg")
			_GDIPlus_ImageSaveToFileEx($APIC_GDIPlusImage,$AlbumArtFile, $APIC_PNGTOJPEG_Encoder)
			_GDIPlus_ImageDispose($APIC_GDIPlusImage)
		EndIf
		Dim $PicTypeIndex = StringInStr($AlbumArtFile,chr(0))
;~ 		MsgBox(0,"$PicTypeIndex",Number(StringMid($AlbumArtFile,$PicTypeIndex+1)))
		Local $aAPIC_PictureTypes = StringSplit($sAPIC_PictureTypes,"|",2)
;~ 		_ArrayDisplay($aAPIC_PictureTypes)
		If _ID3v2Tag_GetVersion() == "2.0" Then
			GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[0])
		Else
			GUICtrlSetData($APIC_input,$aAPIC_PictureTypes[Number(StringMid($AlbumArtFile,$PicTypeIndex+1))])
		EndIf
		GUICtrlSetColor($APIC_input, 0x000000)
		If $APIC_pic == -1 Then
			GUISwitch($ID3Gui_H,$ID3_tab)
			$APIC_pic = GUICtrlCreatePic($AlbumArtFile,285,95, 200, 200)
			GUICtrlCreateTabItem(""); end tabitem definition
		EndIf
		GUICtrlSetState($APIC_pic, $GUI_SHOW)
		GUICtrlSetImage($APIC_pic, $AlbumArtFile)
		GUICtrlSetData($APIC_label,"AlbumArt (APIC " & $iAPIC_index & " of " & $NumAPIC & ")")
	EndIf

	$InputCheckUpdates = True
EndFunc
Func _TXXX_inputUD_Pressed()
	$InputCheckUpdates = False
	Local $iTXXX_index = GUICtrlRead($TXXX_input)
	Local $TXXX = _ID3v2Frame_GetFields("TXXX",$iTXXX_index,1)
	Local $NumTXXX = @extended
	If $iTXXX_index > $NumTXXX Then
		GUICtrlSetData($TXXX_input,"Add New User-Defined Text...")
		GUICtrlSetColor($TXXX_input, 0x7f7f7f)
	Else
		GUICtrlSetData($TXXX_input,$TXXX[2] & ":" & $TXXX[1])
		GUICtrlSetColor($TXXX_input, 0x000000)
	EndIf
	GUICtrlSetColor($TXXXSet_button, 0x000000)
	GUICtrlSetState($TXXXSet_button, $GUI_DISABLE)
	GUICtrlSetData($TXXX_label,"User-Defined Text (TXXX " & $iTXXX_index & " of " & $NumTXXX & ")")
	$InputCheckUpdates = True
EndFunc
Func _TXXXSet_button_Pressed()
	GUICtrlSetColor($TXXXSet_button, 0x000000)
	Local $aNumTXXX = StringSplit(GUICtrlRead($TXXX_label)," of ",1)
	Local $NumTXXX = 0, $iTXXX_index = 1
	If IsArray($aNumTXXX) Then
;~ 		_ArrayDisplay($aNumTXXX)
		If $aNumTXXX[0] > 1 Then
			$NumTXXX = StringTrimRight($aNumTXXX[2],1)
			$iTXXX_index = StringTrimLeft($aNumTXXX[1],24)
		EndIf
	EndIf
	If $NumTXXX < $iTXXX_index Then
		$NumTXXX += 1
	EndIf
;~ 	MsgBox(0,"$iTXXX_index",$iTXXX_index)
	_ID3v2Frame_SetFields("TXXX",GUICtrlRead($TXXX_input),$iTXXX_index,":")
	GUICtrlSetColor($TXXX_input, 0x000000)

	_ID3v2Frame_GetFields("TXXX",$iTXXX_index)
	$NumTXXX = @extended
	GUICtrlSetLimit($TXXX_inputUD, $NumTXXX + 1,1)

	GUICtrlSetData($TXXX_label,"User-Defined Text (TXXX " & $iTXXX_index & " of " & $NumTXXX & ")")
	GUICtrlSetState($TXXXSet_button, $GUI_DISABLE)
	GUICtrlSetColor($TXXX_label, 0xff0000)
EndFunc

Func _COMM_inputUD_Pressed()
	$InputCheckUpdates = False
	Local $iCOMM_index = GUICtrlRead($COMM_input)
	Local $COMM = _ID3v2Frame_GetFields("COMM",$iCOMM_index)
	Local $NumCOMM = @extended
	If $iCOMM_index > $NumCOMM Then
		GUICtrlSetData($COMM_input,"Add New Comment...")
		GUICtrlSetColor($COMM_input, 0x7f7f7f)
	Else
		GUICtrlSetData($COMM_input,$COMM)
		GUICtrlSetColor($COMM_input, 0x000000)
	EndIf
	GUICtrlSetColor($COMMSet_button, 0x000000)
	GUICtrlSetState($COMMSet_button, $GUI_DISABLE)
	GUICtrlSetData($COMM_label,"Comment (COMM " & $iCOMM_index & " of " & $NumCOMM & ")")
	$InputCheckUpdates = True
EndFunc
Func _COMMSet_button_Pressed()
	GUICtrlSetColor($COMMSet_button, 0x000000)
	Local $aNumCOMM = StringSplit(GUICtrlRead($COMM_label)," of ",1)
	Local $NumCOMM = 0, $iCOMM_index = 1
	If IsArray($aNumCOMM) Then
		If $aNumCOMM[0] > 1 Then
			$NumCOMM = StringTrimRight($aNumCOMM[2],1)
			$iCOMM_index = StringTrimLeft($aNumCOMM[1],14)
		EndIf
	EndIf
	If $NumCOMM < $iCOMM_index Then
		$NumCOMM += 1
	EndIf
	_ID3v2Frame_SetFields("COMM",GUICtrlRead($COMM_input),$iCOMM_index)
	GUICtrlSetColor($COMM_input, 0x000000)

	_ID3v2Frame_GetFields("COMM",$iCOMM_index)
	$NumCOMM = @extended
	GUICtrlSetLimit($COMM_inputUD, $NumCOMM + 1,1)

	GUICtrlSetData($COMM_label,"Comment (COMM " & $iCOMM_index & " of " & $NumCOMM & ")")
	GUICtrlSetState($COMMSet_button, $GUI_DISABLE)
	GUICtrlSetColor($COMM_label, 0xff0000)
EndFunc


Func _APEv2_ItemList_list_Pressed()
	Local $sItemKey = GUICtrlRead($APEv2_ItemList)
;~ 	MsgBox(0,"$APEv2_ItemList",$sItemKey)
	Local $sItemValue = _APEv2_GetItemValueString($sItemKey)
	Dim $NumValues = @extended
;~ 	MsgBox(0,"$NumValues",$NumValues)
	GUICtrlSetLimit($APEv2ItemValue_inputUD, $NumValues,1)
	GUICtrlSetData($APEv2ItemValue_input,$sItemValue)
	GUICtrlSetData($APEv2ItemValue_label,"Item Value: (1 of " & $NumValues & ")")
	If StringInStr($sItemValue, ".jpg") > 0 Then
		If $APEv2_pic == -1 Then
			GUISwitch($ID3Gui_H,$APEv2_tab)
			$APEv2_pic = GUICtrlCreatePic($sItemValue,210, 190, 284, 284)
			GUICtrlCreateTabItem(""); end tabitem definition
		EndIf
		GUICtrlSetState($APEv2_pic, $GUI_SHOW)
		GUICtrlSetImage($APEv2_pic, $sItemValue)
	EndIf
;~ 	MsgBox(0,"$sItemValue",$sItemValue)
EndFunc
Func _APEv2ItemValue_inputUD_Pressed()
	Local $iAPEv2ItemValue_index = Number(GUICtrlRead($APEv2ItemValue_input))
;~ 	MsgBox(0,"$iAPEv2ItemValue_index",$iAPEv2ItemValue_index)
	Local $sItemKey = GUICtrlRead($APEv2_ItemList)
	Local $sItemValue = _APEv2_GetItemValueString($sItemKey,$iAPEv2ItemValue_index)
	Dim $NumValues = @extended
	GUICtrlSetData($APEv2ItemValue_input,$sItemValue)
	GUICtrlSetData($APEv2ItemValue_label,"Item Value: (" & $iAPEv2ItemValue_index & " of " & $NumValues & ")")
;~ 	GUICtrlSetLimit($APEv2ItemValue_inputUD, $NumValues + 1,1)
EndFunc

Func _ID3v1_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing ID3v1 Tags...")
	Local $begin = TimerInit()
	_ID3v1Tag_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	_ResetID3v1()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing ID3v1 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc
Func _ID3v2_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing ID3v2 Tags...")
	Local $begin = TimerInit()
	_ID3v2Tag_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	_ResetID3v2()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing ID3v2 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc
Func _APEv2_RemoveTag_button_Pressed()
	_GUICtrlStatusBar_SetText( $StatusBar , "Removing APEv2 Tags...")
	Local $begin = TimerInit()
	_APEv2_RemoveTag($Filename)
	$TimeToRemoveTag = TimerDiff($begin)
	 _ResetAPEv2()
	_GUICtrlStatusBar_SetText( $StatusBar , "Completed Removing APEv2 Tag in " & Round($TimeToRemoveTag,2) & " ms")
EndFunc


Func _ResetID3v1()
	GUICtrlSetData($TitleV1_input, "")
	GUICtrlSetData($ArtistV1_input, "")
	GUICtrlSetData($AlbumV1_input,"")
	GUICtrlSetData($TrackV1_input, "")
	GUICtrlSetData($YearV1_input, "")
	GUICtrlSetData($GenreV1_input, "")
	GUICtrlSetData($CommentV1_input,"")
	GUICtrlSetData($hID3v1Group,"ID3v1")
EndFunc
Func _ResetID3v2()
	GUICtrlSetData($File_input, "")
	GUICtrlSetData($Title_input, "")
	GUICtrlSetData($Artist_input, "")
	GUICtrlSetData($Album_input, "")
	GUICtrlSetData($Track_input, "")
	GUICtrlSetData($Year_input, "")
	GUICtrlSetData($Length_input, "")
	GUICtrlSetData($Genre_input, "")
	GUICtrlSetState($APIC_pic, $GUI_HIDE)
	GUICtrlSetData($APIC_input, "")
	GUICtrlSetData($APIC_label,"AlbumArt (APIC)")
	GUICtrlSetData($COMM_input, "")
	GUICtrlSetColor($COMM_label, 0x000000)
	GUICtrlSetColor($COMMSet_button, 0x000000)
	GUICtrlSetState($COMMSet_button, $GUI_DISABLE)
	GUICtrlSetData($COMM_label,"Comment (COMM)")
	GUICtrlSetData($hID3v2Group,"ID3v2")

	GUICtrlSetData($Lyrics_edit, "")
	GUICtrlSetData($Publisher_input, "")
	GUICtrlSetData($UFID_input,"")
	GUICtrlSetData($Composer_input,"")
	GUICtrlSetData($Band_input,"")
	GUICtrlSetData($WXXX_input,"")
	GUICtrlSetData($WOAR_input,"")
	GUICtrlSetData($POPM_input,"")
	GUICtrlSetData($TXXX_input,"")
	GUICtrlSetColor($TXXX_label, 0x000000)
	GUICtrlSetColor($TXXXSet_button, 0x000000)
	GUICtrlSetState($TXXXSet_button, $GUI_DISABLE)

	GUICtrlSetData($ZPADSize_input,"")
	GUICtrlSetData($ID3V2Size_input,"")
	GUICtrlSetData($Encoder_input,"")
EndFunc
Func _ResetAPEv2()
	GUICtrlSetData($APEv2Version_input, "")
	GUICtrlSetData($APEv2TagSize_input, "")
	GUICtrlSetData($APEv2ItemCount_input, "")

	GUICtrlSetData($APEv2ItemValue_input,"")
	GUICtrlSetData($APEv2ItemValue_label,"Item Value:")
	GUICtrlSetData($APEv2_ItemList, "")
	GUICtrlSetState($APEv2_pic, $GUI_HIDE)
EndFunc
Func _ResetMPEG()
	GUICtrlSetData($MPEGFrameHeader_input, "")
	GUICtrlSetData($MPEGVersion_input, "")
	GUICtrlSetData($MPEGLayer_input, "")
	GUICtrlSetData($MPEGBitRate_input, "")
	GUICtrlSetData($MPEGSampleRate_input, "")
	GUICtrlSetData($MPEGChannelMode_input,"")
EndFunc
Func _ResetAll()
	$InputResetAll = True
	GUICtrlSetData($FileSize_input, "")

	_ResetID3v1()
	_ResetID3v2()
	_ResetAPEv2()
	_ResetMPEG()

	GUICtrlSetData($TAGINFO_edit,"")
	GUICtrlSetData($ID3v2INFO_edit,"")
	GUICtrlSetData($APEv2INFO_edit,"")
	GUICtrlSetState($APEv2INFO_edit, $GUI_SHOW)
	$InputResetAll = False
EndFunc

Func _GUI_EVENT_CLOSE_Pressed()
	If StringInStr(GUICtrlRead($FilePlay_button),"Stop") <> 0 Then
		SoundPlay("")
		GUICtrlSetData($FilePlay_button,"Play")
	EndIf
EndFunc
