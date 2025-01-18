DetectHiddenWindows, On

global WindowTarget := False ; เก็บข้อมูล browser firefox ที่เปิดอยู่

global isHealing := False ; ตรวจสอบว่าหยุดหรือยัง
global HealingLoop := [ 2, 1000 ] ; ตำแหน่งปุ่มสำหรับ ฮิว [ ปุ่ม, ระยะเวลา ] ปุ่ม Mouse Botton Back

global isMininHealing := False ; ตรวจสอบว่าหยุดหรือยัง
global MiniHealingLoop := [ 1, 1500 ] ; ตำแหน่งปุ่มสำหรับ มินิฮิว [ ปุ่ม, ระยะเวลา ] ปุ่ม Mouse Botton Next

global BetweenHealing1 = [ 8, 7500 ] ; ตำแหน่งปุ่ม ระหว่างฮิว [ ปุ่ม, ระยะเวลา ] จะทำงานระหว่างฮิวหลัก 
global BetweenHealing2 = [ 9, 10000 ] ; ตำแหน่งปุ่ม ระหว่างฮิว [ ปุ่ม, ระยะเวลา ] จะทำงานระหว่างฮิวหลัก
global BetweenHealing3 = False ; [ 0, 9000 ] ; ตำแหน่งปุ่ม ระหว่างฮิว [ ปุ่ม, ระยะเวลา ] จะทำงานระหว่างฮิวหลัก

global FirstStep := [ [ 3, 500 ], [4, 500 ] ] ; ตำแหน่งปุ่มสำหรับเริ่มต้น [ ปุ่ม, ระยะเวลา ] จะทำงานก่อน ฮิว หลัก

global IsShowTrayTip := False

; ขนาดหน้าต่าง UI
GuiWidth := 100
GuiHeight := 25

; คำนวณตำแหน่งขวาล่างของหน้าจอ
PosX := A_ScreenWidth - GuiWidth - 5  ; ห่างจากขอบขวา 10 พิกเซล
PosY := A_ScreenHeight - GuiHeight - 50 ; ห่างจากขอบล่าง 10 พิกเซล

; กำหนดสถานะเริ่มต้น
StatusText := "Ready"
GuiColor := "White"

; สร้าง GUI
Gui, +AlwaysOnTop +ToolWindow -Caption +E0x20
Gui, Color, %GuiColor%
Gui, Font, s10, Verdana
Gui, Add, Text, Center x0 y4 w%GuiWidth% h%GuiHeight% vStatusText, %StatusText%

; แสดง GUI ที่มุมขวาล่าง
Gui, Show, x%PosX% y%PosY% w%GuiWidth% h%GuiHeight%, Status UI

; ฟังก์ชันเปลี่ยนสถานะ
ChangeStatus(status, color) {
    global
    GuiColor := color
    StatusText := status
    Gui, Color, %GuiColor%
    GuiControl,, StatusText, %StatusText%
}


GuiShow( status, color ) {
    Gui, Show
    ChangeStatus( status, color )
}

GuiHide( ) {
    Gui, Hide
}

GuiHide( )

FindWindowTarget( ) {
    if !WindowTarget {
        if WinExist("ahk_exe firefox.exe") {
            WinGet, WindowTarget, ID, ahk_exe firefox.exe 
        } else {
            WindowTarget := False
            if IsShowTrayTip {
                TrayTip
                TrayTip, AutoHeal, Please open the Firefox
            }
            Return
        }
    }
}

StartHeal( ) {

    if !WindowTarget {
        FindWindowTarget( )
    }

    if WindowTarget {
        
        GuiShow( "Healing", "Green" )

        if FirstStep {
            For i, Value in FirstStep {
    
                StepButton := Value[1]
                StepDelay := Value[2]
                WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
                ControlSend, , {%StepButton%}, ahk_pid %WindowTargetPID%
                
                Sleep, StepDelay 
    
            }
            
        }
    
        HealTimer := HealingLoop[2]
        SetTimer, HealingTimer, %HealTimer%

        if BetweenHealing1 {
            BGTimer := BetweenHealing1[2]
            SetTimer, BetweenHealingTimer1, %BGTimer%
        }

        if BetweenHealing2 {
            BGTimer := BetweenHealing2[2]
            SetTimer, BetweenHealingTimer2, %BGTimer%
        }

        if BetweenHealing3 {
            BGTimer := BetweenHealing3[2]
            SetTimer, BetweenHealingTimer3, %BGTimer%
        }

        isHealing := True
    }

}

StopHeal( ) {
    SetTimer, HealingTimer, Off
    SetTimer, BetweenHealingTimer1, Off
    SetTimer, BetweenHealingTimer2, Off
    SetTimer, BetweenHealingTimer3, Off
    isHealing := False
    GuiShow( "Heal Stopping", "Green" )
}

StartMiniHeal( ) {

    if !WindowTarget {
        FindWindowTarget( )
    }

    if WindowTarget {
        if !isMininHealing {
            GuiShow( "Mini Healing", "Yellow" )

            WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
            MiniHealButton := MiniHealingLoop[1]
            ControlSend, , {%MiniHealButton%}, ahk_pid %WindowTargetPID%
    
            intervalMiniHealing := MiniHealingLoop[2]
            SetTimer, MiniHealingTimer, %intervalMiniHealing%
    
            isMininHealing := True
            
            if IsShowTrayTip {
                TrayTip
                TrayTip, AutoHeal, Start Mini Healing
            }

        }
    }

}

StopMiniHeal( ) {
    if isMininHealing {
        SetTimer, MiniHealingTimer, Off
        isMininHealing := False

        if IsShowTrayTip {
            TrayTip
            TrayTip, AutoHeal, Mini Heal Stopped
        }
        GuiShow( "Mini Stopping", "Yellow" )
    }
}

XButton1::

    if isMininHealing {
        StopMiniHeal( )
        Sleep 500
    }

    if isHealing {
        StopHeal( )
        GuiHide()
    } else {
        StartHeal( )
    }
    
return

XButton2::

    if isHealing {
        StopHeal( )
        Sleep 500
    }

    if isMininHealing {
        StopMiniHeal( )
        GuiHide()
    } else {
        StartMiniHeal( )
    }

return

HealingTimer:

    if WindowTarget {
        HealButton := HealingLoop[1]
        WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
        ControlSend, , {%HealButton%}, ahk_pid %WindowTargetPID%
    }

Return

MiniHealingTimer:

    if WindowTarget {
        MiniHealButton := MiniHealingLoop[1]
        WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
        ControlSend, , {%MiniHealButton%}, ahk_pid %WindowTargetPID%
    }

Return


BetweenHealingTimer1:

    if WindowTarget {
        WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
        BGButton := BetweenHealing1[1]
        ControlSend, , {%BGButton%}, ahk_pid %WindowTargetPID%
    }

Return

BetweenHealingTimer2:

    if WindowTarget {
        WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
        BGButton := BetweenHealing2[1]
        ControlSend, , {%BGButton%}, ahk_pid %WindowTargetPID%
    }


Return

BetweenHealingTimer3:

    if WindowTarget {
        WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
        BGButton := BetweenHealing3[1]
        ControlSend, , {%BGButton%}, ahk_pid %WindowTargetPID%
    }

Return

IsInArray(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}

FindWindowTarget( )