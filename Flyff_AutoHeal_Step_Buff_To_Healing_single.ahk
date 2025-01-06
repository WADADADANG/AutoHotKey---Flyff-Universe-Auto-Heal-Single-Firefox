DetectHiddenWindows, On

global WindowTarget := False ; เก็บข้อมูล browser firefox ที่เปิดอยู่

global isHealing := False ; ตรวจสอบว่าหยุดหรือยัง
global HealingLoop := [ 2, 1000 ] ; ตำแหน่งปุ่มสำหรับ ฮิว [ ปุ่ม, ระยะเวลา ] ปุ่ม Mouse Botton Back

global isMininHealing := False ; ตรวจสอบว่าหยุดหรือยัง
global MiniHealingLoop := [ 1, 1500 ] ; ตำแหน่งปุ่มสำหรับ มินิฮิว [ ปุ่ม, ระยะเวลา ] ปุ่ม Mouse Botton Next

global BetweenHealing1 = [8, 12000] ; ตำแหน่งปุ่ม ระหว่างฮิว [ ปุ่ม, ระยะเวลา ] จะทำงานระหว่างฮิวหลัก 
global BetweenHealing2 = [9, 10000] ; ตำแหน่งปุ่ม ระหว่างฮิว [ ปุ่ม, ระยะเวลา ] จะทำงานระหว่างฮิวหลัก

global FirstStep := [ [3, 500], [4, 500] ] ;[ [3, 500], [4, 500] ] ; ตำแหน่งปุ่มสำหรับเริ่มต้น [ ปุ่ม, ระยะเวลา ] จะทำงานก่อน ฮิว หลัก

FindWindowTarget( ) {
    if !WindowTarget {
        if WinExist("ahk_exe firefox.exe") {
            WinGet, WindowTarget, ID, ahk_exe firefox.exe 
        } else {
            WindowTarget := False
            TrayTip
            TrayTip, AutoHeal, กรุณาเปิดโปรแกรม Firefox
            Return
        }
    }
}

StartHeal( ) {

    if !WindowTarget {
        FindWindowTarget( )
    }

    if isMininHealing {
        StopMiniHeal( )
    }

    if WindowTarget {
        
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
        SetTimer HealingTimer, %HealTimer%

        if BetweenHealing1 {
            BGTimer := BetweenHealing1[2]
            SetTimer BetweenHealingTimer1, %BGTimer%
        }

        if BetweenHealing2 {
            BGTimer := BetweenHealing2[2]
            SetTimer BetweenHealingTimer2, %BGTimer%
        }
    
        TrayTip
        TrayTip, AutoHeal, เริ่มฮิวแล้ว
        isHealing := True
    }

}

StopHeal( ) {
    SetTimer HealingTimer, Off
    SetTimer BetweenHealingTimer1, Off
    SetTimer BetweenHealingTimer2, Off
    isHealing := False
    TrayTip
    TrayTip, AutoHeal, หยุดแล้ว
}

StartMiniHeal( ) {

    if isHealing {
        StopHeal( )
    }

    if !WindowTarget {
        FindWindowTarget( )
    }

    if WindowTarget {
         if !isMininHealing {

            WinGet, WindowTargetPID, PID, ahk_id %WindowTarget%
            ControlSend, , {%MiniHealButton%}, ahk_pid %WindowTargetPID%
    
            intervalMiniHealing := MiniHealingLoop[2]
            SetTimer, MiniHealingTimer, %intervalMiniHealing%
    
            isMininHealing := True
         }
    }

}

StopMiniHeal( ) {
    if isMininHealing {
        SetTimer, MiniHealingTimer, Off
        isMininHealing := False 
    }
}

XButton1::

    if !isHealing {
        StartHeal( )
    } else {
        StopHeal( )
    }

return

XButton2::

    if !isMininHealing {
        StartMiniHeal( )

        TrayTip
        TrayTip, AutoHeal, เริ่มมินิฮิวแล้ว
    } else {
        StopMiniHeal( )

        TrayTip
        TrayTip, AutoHeal, หยุดมินิฮิวแล้ว
    }

return

End::
    if isHealing {
        StopHeal( )
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

IsInArray(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}
