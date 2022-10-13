# Simple Roku Scene Graph channel for beginners containing following Roku native components
1. Label
2. Rectangle
3. Button
4. Poster
5. Video
6. Focus Handling
7. Event Handling
8. Navigations
9. Data transitions
10. Network Connections

# How Brightscript label
    <?xml version="1.0" encoding="UTF-8"?>
    <component name="MainScene" extends="Scene"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="https://devtools.web.roku.com/schema/RokuSceneGraph.xsd">
        <script type="text/brightscript" uri="pkg:/components/MainScene.brs" />
        <children>
            <Label id="labelId" visible="false" text="Brightscript Label" translation="[700,100]" color="#000000"/>
        </children>
    </component>

# How to create Brightscript Rectangle (Embed above code inside above structure)
    <Rectangle id="bgRectId" visible="false" translation="[20,100]" height="700" width="400" color="#1A182D"/>

# How to create Brightscript Button
    <Button id="btnId1" visible="false" text="Sample Button" height="100" translation="[700,400]"/>

# How to create Brightscript Poster
     <Poster id="poster" visible="false" translation="[1300,100]" uri="pkg:/images/icon_focus_sd.png" />

# How to create Brightscript Video Node
    
    Xml Part : 

    <Video id="liveStream" width="1920" height="1080" translation="[0,0]" enableScreenSaverWhilePlaying="false" enableUI="true" />

    Brightscript part: 
    m.videoPlayer = m.top.findNode("liveStream")

    sub initiateLiveVideo()
        m.videoPlayer.observeField("state", "onLiveStreamStateChange")
        if m.videoPlayer.state = "playing" or m.videoPlayer.state = "buffering"
            m.videoPlayer.control = "stop"
        end if
        content = createObject("roSGNode", "ContentNode")
        content.url = m.url
        content.streamFormat = "hls"
        m.videoPlayer.content = content
        m.videoPlayer.visible = true
        m.videoPlayer.control = "play"
        m.videoErrorPoster.visible = false
    end sub   

    sub OnLiveStreamStateChange()
        duration = m.videoPlayer.duration
        if m.videoPlayer.state = "error" then
            'Display Error message/poster
        else if m.videoPlayer.state = "playing" then
            'Display buffering message/icon
        else if m.videoPlayer.state = "finished" then
            'Display buffering icon
        else if m.videoPlayer.state = "buffering"
            'Display buffering icon
        end if
    end sub

# How to do Focus Handling?
    When it comes to focus management, few things plays vital role

        setFocus(true/false)
        onKeyEvent(key as string, press as boolean) as boolean
            'key'-> pressed key(up, down, left, right)
            'press'-> true/false 

        Example: 
        function onKeyEvent(key as string, press as boolean) as boolean
            result = false

            if press
                if key = "left"
                if m.btn.hasFocus()
                    m.btn.setFocus(false)
                    m.labelId2.color = "#000000"

                    m.btn1.setFocus(true)
                    m.labelId1.color = "#ffffff"
                else if m.btnId2.hasFocus()
                    m.btnId1.setFocus(true)
                end if
            end if 

# Installation Guide
Take the pull of repo, build the code at VS Code or at Eclipse, sideload the channel at Roku Device using Application Installer

Happy Coding!

