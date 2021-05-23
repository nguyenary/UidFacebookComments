#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <_HttpRequest.au3>
#include <_Msgbox.au3>
#include <JSON.au3>
#include <Date.au3>

$Form1 = GUICreate("Get Uid Comment Bài Viết", 626, 521)
$Group1 = GUICtrlCreateGroup("GET UID", 8, 8, 609, 105)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
$Label1 = GUICtrlCreateLabel("Nhập Token Full quyền: ", 16, 32, 160, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Arial")
$token = GUICtrlCreateInput("", 16, 56, 393, 25)
GUICtrlSetFont(-1, 11, 400, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label3 = GUICtrlCreateLabel("ID Bài Viết:", 416, 32, 75, 21)
GUICtrlSetFont(-1, 11, 400, 0, "Arial")
$id_post = GUICtrlCreateInput("", 416, 56, 193, 25)
GUICtrlSetFont(-1, 11, 400, 0, "Arial")
$Label4 = GUICtrlCreateLabel("Lưu ý: Nếu GET Uid của Page hoặc Group thì bạn đã like Page hoặc là thành viên của Group thì mới GET được.", 16, 88, 541, 18)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$Group2 = GUICtrlCreateGroup("Kết Quả", 8, 144, 609, 345)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $ketqua =  GUICtrlCreateEdit("", 16, 168, 505, 313, BitOR($ES_AUTOVSCROLL,$ES_WANTRETURN,$WS_VSCROLL))
GUICtrlSetFont(-1, 12, 400, 0, "Arial")
Global $luu_txt = GUICtrlCreateButton("Lưu TXT", 528, 168, 81, 25)
Global $loc_trung = GUICtrlCreateButton("Lọc Trùng", 528, 457, 81, 25)
$Label5 = GUICtrlCreateLabel("Giới hạn:", 528, 200, 48, 35, $SS_CENTER)
$Limit = GUICtrlCreateInput("5000", 528, 224, 81, 25, BitOR($GUI_SS_DEFAULT_INPUT,$ES_RIGHT))
GUICtrlSetFont(-1, 11, 400, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $batdau = GUICtrlCreateButton("BẮT ĐẦU GET UID", 224, 120, 185, 25)
GUICtrlSetBkColor(-1, 0xFFFFE1)
$Label2 = GUICtrlCreateLabel("Copyright 2019 - Nguyên Ary", 480, 496, 139, 17)
Global $log_get = GUICtrlCreateLabel("", 8, 496, 230, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
GUISetState(@SW_SHOW)


While 1
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 Exit
	  Case $batdau
		 GUICtrlSetData($log_get,'Đang xử lí vui lòng đợi...')
		 GUICtrlSetData($ketqua,'')
		 GUICtrlSetState($batdau,$GUI_DISABLE)
		 GUICtrlSetState($luu_txt,$GUI_DISABLE)
		 GUICtrlSetState($loc_trung,$GUI_DISABLE)
		 $r_token = GUICtrlRead($token)
		 $r_id_post = Number(GUICtrlRead($id_post))
		 $r_limit = Number(GUICtrlRead($Limit))

		 If $r_token = '' Or $r_id_post = '' Then
			_MsgBox(16 + 0, 'Lỗi!','Không được để trống Token hoặc ID bài viết!')
			Set_Btn(1)
		 Else
			;Check Token live hay không
			If Check_Token($r_token) = False Then
			   _MsgBox(32 + 0, 'Lỗi!','Có vẻ Token của bạn đã chết vui lòng kiểm tra lại!')
			   Set_Btn(1)
			ElseIf $r_limit < 100 Or $r_limit > 5000 Then
			   _MsgBox(32 + 0, 'Lỗi!','Limit tối thiểu là 100 và tối đa là 5000!')
			   Set_Btn(1)
			Else
			   $decode= Json_Decode(Get_Uid_Cmt($r_id_post,$r_token,$r_limit))
			   $dem_id_get = UBound(Json_Get($decode,'["data"]'))
			   If $dem_id_get = 0 Then
				  _MsgBox(32 + 0, 'Lỗi!','Không tìm thấy kết quả nào vui lòng kiểm tra lại ID Post!')
				  Set_Btn(1)
			   Else
				  ;Vòng lập
				  For $i = 0 To $dem_id_get - 1
					 $id_get = Json_Get($decode,'["data"]['&$i&']["from"]["id"]')
					 If Not $id_get = '' Then
						$kqua = $id_get&@CRLF&GUICtrlRead($ketqua)
						GUICtrlSetData($ketqua,$kqua)
						;Cập nhật thông số
						GUICtrlSetData($log_get,'Đã GET được: '&$i+1&'/'&$dem_id_get&' UID')
					 EndIf
					 $i +=1
					 if $i+1 = $dem_id_get Then
						GUICtrlSetData($log_get,'Đã xử lí xong '&$dem_id_get&' UID!')
					 EndIf
				  Next
				  Set_Btn()
			   EndIf
			EndIf
		 EndIf
	  Case $luu_txt
		 $kqua = GUICtrlRead($ketqua)
		 $name = StringReplace(_NowTime(),":","_")
		 Luu_File($kqua,'nguyenary-'&$name)
	  Case $loc_trung
		 $kqua = GUICtrlRead($ketqua)
		 $tach = StringSplit($kqua, @CRLF)
		 $loctrung = _ArrayUnique($tach)
		 $dem_tach = UBound($loctrung)-1
		 $ketqua1 = Null
		 For $i=2 To $dem_tach
			If $loctrung[$i] <> '' Then
			$ketqua1 &= $loctrung[$i]&@CRLF
			EndIf
		 Next
		 GUICtrlSetData($ketqua,'')
		 GUICtrlSetData($ketqua,$ketqua1)
		 GUICtrlSetData($log_get,'Đã lọc trùng xong!')
	EndSwitch
WEnd


   Func Set_Btn($type = 0)
	  GUICtrlSetState($luu_txt,$GUI_ENABLE)
	  GUICtrlSetState($batdau,$GUI_ENABLE)
	  GUICtrlSetState($loc_trung,$GUI_ENABLE)
	  If $type = 1 Then
		 GUICtrlSetData($log_get,'')
	  EndIf
	  Return True
   EndFunc
   ;================Luu File==================

   Func Luu_File($data = '',$name = 'nguyenary')
		 If $data = '' Then
			_MsgBox(16 + 0, 'Lỗi!','Chưa có dữ liệu nào cả bạn không thể lưu nó.')
		 Else
			Local Const $sMessage = "Chọn nơi để lưu file sao lưu"
			Local $sFileSaveDialog = FileSaveDialog($sMessage, @DesktopDir, "File Uid (*.txt)", $FD_PATHMUSTEXIST,$name)
			If @error Then
			   ConsoleWrite('> Luu file loi!')
			Else
			   Local $sFileName = StringTrimLeft($sFileSaveDialog, StringInStr($sFileSaveDialog, "\", $STR_NOCASESENSEBASIC, -1))
			   Local $iExtension = StringInStr($sFileName, ".", $STR_NOCASESENSEBASIC)
			   If $iExtension Then
				  If Not (StringTrimLeft($sFileName, $iExtension - 1) = ".txt") Then $sFileSaveDialog &= ".au3"
			   Else
				  $sFileSaveDialog &= ".txt"
			   EndIf
			   $file = FileOpen($sFileSaveDialog,2+8+128)
			   FileWrite($file,StringStripWS($data,1))
			   FileClose($file)
			   _MsgBox(64+0, 'Thành Công!', "File của bạn được lưu tại:" & @CRLF & $sFileSaveDialog&"   ")
			EndIf
		 EndIf
	  EndFunc

	  #cs
	  ==============GET Uid Trong Bài Viết=============
	  #ce
	  Func Get_Uid_Cmt($id_p,$token,$limit = 100)
		 $url = 'https://graph.facebook.com/'&$id_p&'/comments?limit='&$limit&'&access_token='&$token
		 $rq = _HttpRequest(2,$url)
		 return $rq;
	  EndFunc

	  #cs
		 ===========Check Token Live Die==========
		 $token : mã token
	  #ce
	  Func Check_Token($token)
		 $link = 'https://graph.facebook.com/me/?fields=id&access_token='&$token
		 $rq = _HttpRequest(2,$link)
		 If Not IsArray(StringRegExp($rq,'\"id\": \"([0-9]+)\"',1)) Then
			Return False
		 Else
			Return True
		 EndIf
	  EndFunc