sub init()
    m.top.setFocus(true)
    configureUI()
end sub

sub configureUI()
    m.videoPlayer = m.top.findNode("liveStream")
    m.bufferingAnimation = m.top.findNode("bufferingAnimation")
    m.videoErrorPoster = m.top.findNode("videoErrorPoster")
end sub

sub onUrlReceived()
    m.url = m.top.url
    initiateLiveVideo()
end sub    

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
        m.videoErrorPoster.visible = true
        
    else if m.videoPlayer.state = "playing" then
        m.bufferingAnimation.visible = false
        m.videoErrorPoster.visible = false 
    else if m.videoPlayer.state = "finished" then
        m.bufferingAnimation.visible = false
        
    else if m.videoPlayer.state = "buffering"
        m.bufferingAnimation.visible = true
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    result = false

    if press
        if key = "back"
            m.top.parentNode.userInput = "BackButtonPressed"
            m.top.removeVideoScreen = true
        end if
    end if

    return result
end function
