sub init()
    m.top.SetFocus(true)

    m.btnGrp = m.top.findNode("btnGrp")
    m.btnGrp.SetFocus(true)
    m.btnGrp.focusedTextColor = "#000000"
    m.btnGrp.buttons = ["Button1", "Button2", "Button3", "Button4", "Button5"]


end sub

function onKeyEvent(key as string, press as boolean) as boolean

    if press
        if key = "back"
            m.top.removeGrpScreen = "back"
            return false
        end if
    end if

end function