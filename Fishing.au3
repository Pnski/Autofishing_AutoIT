#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <WinAPIMisc.au3>

testline

#RequireAdmin

; Globals
Global $vStatePause = True ; switch states

Global $iniName = "fishing.ini"

Global $vColorCoord[2] = [IniRead($iniName,"Coord", 0, 0), IniRead($iniName,"Coord", 1, 0)]
Global $vColorRef[3] = [IniRead($iniName,"Color", 0, 0), IniRead($iniName,"Color", 1, 0), IniRead($iniName,"Color", 2, 0)]

; Locals

; GUI

Opt("GUICoordMode", 2)

Local Const $widthCell = 100

$hGui = GUICreate("AutoFishing", 350, 600)
GUICtrlCreateLabel( "Coordinates 1:", 10, 30, $widthCell)
$l1Gui = GUICtrlCreateLabel( $vColorCoord[0] & " / " & $vColorCoord[1], 0, -1)
GUICtrlCreateLabel( "5:", -2 * $widthCell, 0)
$i1Gui = GUICtrlCreateInput( "0", 0, -1)
GUICtrlCreateLabel( "6:", -2 * $widthCell, 0)
$i2Gui = GUICtrlCreateInput( "0", 0, -1)
GUICtrlCreateLabel( "7:", -2 * $widthCell, 0)
$i3Gui = GUICtrlCreateInput( "0", 0, -1)
GUICtrlCreateLabel( "8:", -2 * $widthCell, 0)
$i4Gui = GUICtrlCreateInput( "0", 0, -1)
GUICtrlCreateLabel("Usage:" & @CRLF & _
				   "F1: Display tooltip for coordinates to use" & @CRLF & _
                   "F2: Set coordinates by left clicking where your f-skill is normally" & @CRLF & _
                   "F3: Toogle start of the fishing" & @CRLF & _
				   "F4: Toggle pause of the fishing" & @CRLF & _
				   "Make sure that at the initial start of the fishing no" & @CRLF & _
				   "moving partikels are in the way, this script checks for colorchanges." & @CRLF & _
                   "F5 : Terminate",-2 * $widthCell, 0, 550, 200)
GUISetState(@SW_SHOW, $hGui)

; HotKeys

HotKeySet("{F5}", "Terminate")
HotKeySet("{F4}", "PauseFishing")
HotKeySet("{F3}", "RunFishing")
HotKeySet("{F2}", "SetCoord")
HotKeySet("{F1}", "Tip")

; Functions

Func Fishing()
   Sleep("250")
   If $vColorRef[0] = 0 Then
	  $vColorRef[0] = PixelGetColor($vColorCoord[0],$vColorCoord[1]) ; outside
	  ToolTip("Detecting fishing cycle..", $vColorCoord[0]+50, $vColorCoord[1])
   EndIf
   SetBasket()
   If $vColorRef[1] = 0 Then
	  Do
		 Sleep(100)
	  Until PixelGetColor($vColorCoord[0],$vColorCoord[1]) <> $vColorRef[0]
	  $vColorRef[1] = PixelGetColor($vColorCoord[0],$vColorCoord[1])
	  ToolTip("Detecting fishing cycle...", $vColorCoord[0]+50, $vColorCoord[1])
   EndIf
   If $vColorRef[2] = 0 Then
	  Do
		 Sleep(100)
	  Until PixelGetColor($vColorCoord[0],$vColorCoord[1]) <> $vColorRef[1]
	  $vColorRef[2] = PixelGetColor($vColorCoord[0],$vColorCoord[1])
	  ToolTip("Fishing cycle detected.", $vColorCoord[0]+50, $vColorCoord[1])
   EndIf
   Do
	  Sleep(500)
   Until PixelGetColor($vColorCoord[0],$vColorCoord[1]) = $vColorRef[2]
   Send("f")
EndFunc   ;==>Fishing

; HotkeySection
Func Terminate()
   FileDelete($iniName)
   IniWrite($iniName,"Coord",0,$vColorCoord[0])
   IniWrite($iniName,"Coord",1,$vColorCoord[1])
   IniWrite($iniName,"Color",0,$vColorRef[0])
   IniWrite($iniName,"Color",1,$vColorRef[1])
   IniWrite($iniName,"Color",2,$vColorRef[2])
   Exit
EndFunc   ;==>Terminate

Func RunFishing()
   $vStatePause = False
EndFunc

Func PauseFishing()
   $vStatePause = True
EndFunc

Func SetCoord()
   Local $hDLL = DllOpen("user32.dll")
   While Not _IsPressed("01", $hDLL)
	  Sleep(1)
   WEnd
   DllClose($hDLL)
   $vColorCoord[0] = MouseGetPos(0)
   $vColorCoord[1] = MouseGetPos(1)
   For $i = 0 to UBound($vColorRef) - 1 Step 1
	  $vColorRef[$i] = 0
   Next
   GUICtrlSetData( $l1Gui, $vColorCoord[0] & " / " & $vColorCoord[1])
   Tip()
EndFunc

Func Tip()
   ToolTip("<--Checking Here", $vColorCoord[0]+5, $vColorCoord[1])
   Sleep(1000)
   ToolTip("")
EndFunc

; HelpSection

Func SetBasket()
   Select
	  Case GUICtrlRead($i1Gui) > 0 ; 5
		 Send("5")
		 GUICtrlSetData($i1Gui, GUICtrlRead($i1Gui)-1)
	  Case GUICtrlRead($i2Gui) > 0 ; 6
		 Send("6")
		 GUICtrlSetData($i2Gui, GUICtrlRead($i2Gui)-1)
	  Case GUICtrlRead($i3Gui) > 0 ; 7
		 Send("7")
		 GUICtrlSetData($i3Gui, GUICtrlRead($i3Gui)-1)
	  Case GUICtrlRead($i4Gui) > 0 ; 8
		 Send("8")
		 GUICtrlSetData($i4Gui, GUICtrlRead($i4Gui)-1)
	  Case Else
		 ToolTip("Fishing cycle completed.", $vColorCoord[0]+50, $vColorCoord[1])
		 PauseFishing()
   EndSelect
EndFunc

; InitLoop

While 1
   Sleep(100)
   If $vStatePause = False And WinActivate("Blade & Soul", "") Then
	  Fishing()
   EndIf
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 Terminate()
   EndSwitch
WEnd