Sub init()
    m.image = m.top.findNode("image")
    m.image.observeField("loadStatus", "omImageLoadStatusChange")
    m.text = m.top.findNode("text")
    m.rotationAnimation = m.top.findNode("rotationAnimation")
    m.rotationAnimationInterpolator = m.top.findNode("rotationAnimationInterpolator")
    m.fadeAnimation = m.top.findNode("fadeAnimation")
    m.loadingIndicatorGroup = m.top.findNode("loadingIndicatorGroup")
    m.loadingGroup = m.top.findNode("loadingGroup")
    m.background = m.top.findNode("background")

    m.textHeight = 0
    m.textPadding = 0
    m.areParentSizeObserversSet = false
    
    ' image could've been loaded by this time
    omImageLoadStatusChange()

    startAnimation()
End Sub


Sub updateLayout()
    ' check for parent node and set observers only once
    If not m.areParentSizeObserversSet Then
        parentNode = m.top.getParent()
        If parentNode <> invalid Then
            parentNode.observeField("width", "updateLayout")
            parentNode.observeField("height", "updateLayout")
            m.areParentSizeObserversSet = true
        End If
    End If

    componentWidth = getComponentWidth()
    componentHeight = getComponentHeight()
    
    m.text.width = componentWidth - m.textPadding * 2
    m.background.width = componentWidth
    m.background.height = componentHeight
    
    If m.top.centered Then
        m.top.translation = [(getParentWidth() - componentWidth) / 2, (getParentHeight() - componentHeight) / 2]
    End If
    
    loadingGroupWidth = max(m.image.width, m.text.width)
    
    loadingGroupHeight = m.image.height + m.textHeight
    
    ' check whether image and text fit into component, if they don't - downscale image
    If m.imageAspectRatio <> invalid Then
        loadingGroupAspectRatio = loadingGroupWidth / loadingGroupHeight
        If loadingGroupWidth > componentWidth Then
            m.image.width = m.image.width - (loadingGroupWidth - componentWidth)
            m.image.height = m.image.width / m.imageAspectRatio
            loadingGroupWidth = max(m.image.width, m.text.width)
            loadingGroupHeight = loadingGroupWidth / loadingGroupAspectRatio
        End If
        If loadingGroupHeight > componentHeight Then
            m.image.height = m.image.height - (loadingGroupHeight - componentHeight)
            m.image.width = m.image.height * m.imageAspectRatio
            loadingGroupHeight = m.image.height + m.textHeight
            loadingGroupWidth = loadingGroupHeight * loadingGroupAspectRatio
        End If
    End If
    
    m.image.scaleRotateCenter = [m.image.width / 2, m.image.height / 2]
    
    ' position loading group, image and text at the center
    m.loadingGroup.translation = [(componentWidth - loadingGroupWidth) / 2, (componentHeight - loadingGroupHeight) / 2]
    m.image.translation = [(loadingGroupWidth - m.image.width) / 2, 0]
    m.text.translation = [0, m.image.height + m.top.spacing]
End Sub


Sub changeRotationDirection()
    If m.top.clockwise Then
        m.rotationAnimationInterpolator.key = [1, 0]
    Else
        m.rotationAnimationInterpolator.key = [0, 1]
    End If
End Sub


Sub omImageLoadStatusChange()
    If m.image.loadStatus = "ready" Then
        m.imageAspectRatio = m.image.bitmapWidth / m.image.bitmapHeight
        
        If m.top.imageWidth > 0 and m.top.imageHeight <= 0 Then
            m.image.height = m.image.width / m.imageAspectRatio
        Else If m.top.imageHeight > 0 and m.top.imageWidth <= 0 Then
            m.image.width = m.image.height * m.imageAspectRatio
        Else If m.top.imageHeight <= 0 and m.top.imageWidth <= 0 Then
            m.image.height = m.image.bitmapHeight
            m.image.width = m.image.bitmapWidth
        End If
        updateLayout()
    End If
End Sub


Sub onImageWidthChange()
    If m.top.imageWidth > 0 Then
        m.image.width = m.top.imageWidth
        If m.top.imageHeight <= 0 and m.imageAspectRatio <> invalid Then
            m.image.height = m.image.width / m.imageAspectRatio
        End If
        updateLayout()
    End If
End Sub


Sub onImageHeightChange()
    If m.top.imageHeight > 0 Then
        m.image.height = m.top.imageHeight
        If m.top.imageWidth <= 0 and m.imageAspectRatio <> invalid Then
            m.image.width = m.image.height * m.imageAspectRatio
        End If
        updateLayout()
    End If
End Sub


Sub onTextChange()
    prevTextHeight = m.textHeight
    If m.top.text = "" Then
        m.textHeight = 0
    Else
        m.textHeight = m.text.localBoundingRect().height + m.top.spacing
    End If
    If m.textHeight <> prevTextHeight Then
        updatelayout()    
    End If
End Sub


Sub onBackgroundImageChange()
    If m.top.backgroundUri <> "" Then
        previousBackground = m.background
        m.background = m.top.findNode("backgroundImage")
        m.background.opacity = previousBackground.opacity
        m.background.translation = previousBackground.translation
        m.background.width = previousBackground.width
        m.background.height = previousBackground.height
        m.background.uri = m.top.backgroundUri
        previousBackground.visible = false
    End If
End Sub


Sub onBackgroundOpacityChange()
    If m.background <> invalid Then
        m.background.opacity = m.top.backgroundOpacity
    End If
End Sub


Sub onTextPaddingChange()
    If m.top.textPadding > 0 Then
        m.textPadding = m.top.textPadding
    Else
        m.textPadding = 0
    End If
    updateLayout()
End Sub


Sub onControlChange()
    If m.top.control = "start" Then
        ' opacity could be set to 0 by fade animation so restore it
        m.loadingIndicatorGroup.opacity = 1
        startAnimation()
    Else If m.top.control = "stop"
        ' if there is fadeInterval set, fully dispose component before stopping spinning animation
        If m.top.fadeInterval > 0 Then
            m.fadeAnimation.duration = m.top.fadeInterval
            m.fadeAnimation.observeField("state", "onFadeAnimationStateChange")
            m.fadeAnimation.control = "start"
        Else
            stopAnimation()
        End If
    End If
End Sub


Sub onFadeAnimationStateChange()
    If m.fadeAnimation.state = "stopped" Then
        stopAnimation()
    End If
End Sub


Function getComponentWidth() as Float
    If m.top.width = 0 Then
        ' use parent's width
        return getParentWidth()
    Else
        return m.top.width
    End If
End Function


Function getComponentHeight() as Float
    If m.top.height = 0 Then
        ' use parent's height
        return getParentHeight()
    Else
        return m.top.height
    End If
End Function


Function getParentWidth() as Float
    parentNode = m.top.getParent()
    If parentNode <> invalid and parentNode.width <> invalid Then
        return parentNode.width
    Else
        return 1920
    End If
End Function


Function getParentHeight() as Float
    parentNode = m.top.getParent()
    If parentNode <> invalid and parentNode.height <> invalid Then
        return parentNode.height
    Else
        return 1080
    End If
End Function


Sub startAnimation()
    m.model = createObject("roDeviceInfo").getModel()
    first = Left(m.model, 1).trim()
    If first <> invalid and first.Len() = 1 Then
        firstAsInt = val(first, 10)
        If (firstAsInt) > 3 Then
            m.rotationAnimation.control = "start"
            m.top.state = "running"
        End If
    End If
End Sub

Sub stopAnimation()
    m.rotationAnimation.control = "stop"
    m.top.state = "stopped"
End Sub


Function max(a as Float, b as Float) as Float
    If a > b Then
        return a
    Else
        return b
    End If
End Function