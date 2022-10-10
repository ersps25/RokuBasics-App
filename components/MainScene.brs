' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
    m.top.SetFocus(true)
    configureUI()
end sub

sub configureUI()

    'Rect Buttons
    m.bgRectId1 = m.top.findNode("bgRectId1")
    m.bgRectId1.visible = true
    m.buttonId1 = m.top.findNode("buttonId1")
    m.labelId1 = m.top.findNode("labelId1")
    m.buttonId1.observeField("buttonSelected", "onbutton1Selected")
    m.buttonId1.setFocus(true)
    m.bgRectId1.color = "#000000"
    m.labelId1.color = "#ffffff"
    m.bgRectId2 = m.top.findNode("bgRectId2")
    m.bgRectId2.visible = true
    m.buttonId2 = m.top.findNode("buttonId2")
    m.labelId2 = m.top.findNode("labelId2")
    m.buttonId2.observeField("buttonSelected", "onbutton2Selected")

    m.grpId = m.top.findNode("grpId")
    m.grpId.observeField("buttonSelected", "onGrpSelected")


    'Actual Buttons
    m.btnId1 = m.top.findNode("btnId1")
    m.btnId1.visible = true
    m.btnId2 = m.top.findNode("btnId2")
    m.btnId2.visible = true
    m.btnId1.observeField("buttonSelected", "onbtn1Selected")
    m.btnId2.observeField("buttonSelected", "onbtn21Selected")

    'Label
    m.labelId = m.top.findNode("labelId")
    m.labelId.visible = true

    'Poster
    m.poster = m.top.findNode("poster")
    m.poster.visible = true

    'Rectangle
    m.bgRectId = m.top.findNode("bgRectId")
    m.bgRectId.visible = true

    'Back Text Label
    m.backTextLabel = m.top.findNode("backTextLabel")

    'Connect API
    connectAPI()
    
end sub

sub onGrpSelected()
    m.rokugrp = m.top.createChild("RokuGroup")
    m.rokugrp.ObserveField("removeGrpScreen", "onRemoveGrpScreen")
    m.rokugrp.visible = true
    m.rokugrp.parentNode = m.top
end sub

sub onRemoveGrpScreen()
    if m.rokugrp <> invalid
        m.top.removeChild(m.rokugrp)
        m.rokugrp = invalid
        m.grpId.setFocus(true)
    end if
end sub

sub onbutton1Selected()
    m.dialog = createObject("roSGNode", "Dialog")
    'dialog.backgroundUri = ""
    m.dialog.title = "Title"
    m.dialog.optionsDialog = true
    m.dialog.iconUri = ""
    m.dialog.message = "Alert Dialog"
    m.dialog.width = 1200
    m.dialog.buttons = ["OK"]
    m.dialog.observeField("buttonSelected", "removeAlert") 'The field is set when the dialog close field is set,
    m.top.getScene().dialog = m.dialog
end sub

sub removeAlert()
    m.top.getScene().dialog.close = true
end sub

sub onbutton2Selected()
    m.VideoScreen2 = m.top.createChild("VideoScreen")
    m.VideoScreen2.ObserveField("removeVideoScreen", "onRemoveVideoScreen")
    m.VideoScreen2.visible = true
    m.VideoScreen2.url = "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"
    m.VideoScreen2.setFocus(true)
    m.VideoScreen2.parentNode = m.top
end sub

sub onRemoveVideoScreen()
    if m.VideoScreen2 <> invalid
        m.top.removeChild(m.VideoScreen2)
        m.VideoScreen2 = invalid

        m.buttonId2.setFocus(true)
        m.bgRectId2.color = "#000000"
        m.labelId2.color = "#ffffff"
    end if
end sub

sub onUserInputReceived()
    m.backTextLabel.text = m.top.userInput
end sub    

sub onbtn1Selected()

end sub

sub onbtn21Selected()

end sub

function onKeyEvent(key as string, press as boolean) as boolean
    result = false

    if press
        if key = "left"
            if m.buttonId2.hasFocus()
                m.buttonId2.setFocus(false)
                m.bgRectId2.color = "#A9A9A9"
                m.labelId2.color = "#000000"

                m.buttonId1.setFocus(true)
                m.bgRectId1.color = "#000000"
                m.labelId1.color = "#ffffff"
            else if m.btnId2.hasFocus()
                m.btnId1.setFocus(true)
            end if
        else if key = "right"
            if m.buttonId1.hasFocus()
                m.buttonId1.setFocus(false)
                m.bgRectId1.color = "#A9A9A9"
                m.labelId1.color = "#000000"

                m.buttonId2.setFocus(true)
                m.bgRectId2.color = "#000000"
                m.labelId2.color = "#ffffff"
            else if m.btnId1.hasFocus()
                m.btnId2.setFocus(true)
            end if
        else if key = "up"
            if m.buttonId1.hasFocus()
                m.btnId1.setFocus(true)

                m.buttonId1.setFocus(false)
                m.bgRectId1.color = "#A9A9A9"
                m.labelId1.color = "#000000"
            else if m.grpId.hasFocus()
                m.buttonId1.setFocus(true)
                m.bgRectId1.color = "#000000"
                m.labelId1.color = "#ffffff"
                m.grpId.setFocus(false)
            end if
        else if key = "down"
            if m.btnId1.hasFocus()
                m.buttonId1.setFocus(true)
                m.bgRectId1.color = "#000000"
                m.labelId1.color = "#ffffff"
            else if m.buttonId1.hasFocus()
                m.grpId.setFocus(true)

                m.buttonId1.setFocus(false)
                m.bgRectId1.color = "#A9A9A9"
                m.labelId1.color = "#000000"

            end if
        end if
    end if

    return result
end function

sub connectAPI()
    di = CreateObject("roDeviceInfo")
    if(di.GetLinkStatus())
        m.getAPICall = createObject("roSGNode", "GetAPICall")
        m.getAPICall.observeField("status", "onAPIConnected")
        m.getAPICall.control = "RUN"
    else
        ? m.UIConstants.root.ErrorMessages.titleAlert
        ? "Please connect to internet and try again"
    end if
end sub

sub onAPIConnected()

    if m.getAPICall.content <> invalid
        ? "API Response Received"
    else
        ? "Something went wrong. Please try later"
    end if
end sub