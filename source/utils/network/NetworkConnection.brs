Function getConnectionTime() as integer
'time in seconds
    return 200
End Function

Function getPortConnectionTime() as integer
'time in seconds
    return 60*60000
End Function

Function HttpEncode(str As String) As String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
End Function

Function getGetApiJson(url as String,isShowDialog as boolean,headers as object,mainScreen) as object
    return getApiJsonWithDialog(url,"",isShowDialog,headers,mainScreen)
End Function

Function getPostApiJson(url as String, params as String,isShowDialog as boolean,headers as object,mainScreen) as object
    return getApiJsonWithDialog(url,params,isShowDialog,headers,mainScreen)
End Function

Function getApiJsonWithDialog(url as String, params as String,isShowDialog as boolean,headers as Object,mainScreen=invalid)
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.EnableEncodings(true)
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")

    request.AddHeader("Content-type", "application/json")
    If type(headers)="roAssociativeArray" Then
        For Each key in headers
            request.AddHeader(key,headers[key])
            '? "****** headers *****";key
             '? "****** headers *****";headers[key]
        End For
    End If
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    checkRokuConnection = CreateObject("roDeviceInfo")
    If(checkrokuconnection.GetLinkStatus()) Then
        If(params <> "")
            requestType = request.AsyncPostFromString(params)
        Else
            requestType = request.AsyncGetToString()
        End If
        timer=createobject("roTimeSpan")
        timer.Mark()
        If (requestType)
            ''? "***** requestType ******"
            while (true)
                ''? "**** true *******"
                msg = wait(getPortConnectionTime(), port)
                ''? "****** msg *****";msg
                If (type(msg) = "roUrlEvent") then
                     ''? "****** msg *****";type(msg)
                    code = msg.GetResponseCode()
                    ''? "**** Code ****";code
                    responseString = msg.GetString()
                    '? "***** responseString in failure case ******";responseString
                    responseStringFail = msg.GetFailureReason()
                    '? "***** responseString in failure case ******";responseStringFail
                    If (code = 200) then
                        responseString = msg.GetString()
                        '? "*********** responseString in Fetch Price Api*********== *****";responseString
                        json = ParseJSON(responseString)
                      '? "**********8 json == ****************";json
                        if json <> invalid
                             if json.response <> invalid
                                  return json
                             else
                                  return {"errMsg":"Error"}
                             end if
                        else
                              return {"errMsg":"Error"}
                        end if
                     Else
                        return {"errMsg":"Error"}
                     End If
                Else
                    request.AsyncCancel()
                    return {"errMsg":"Error"}
                End If
            End while
        End If
     Else
         return {"errMsg":"Error"}
     End If
End Function



Function showLoadingDialog() as Object
    m.top.pdialogAuth = CreateObject("roSGNode", "ProgressDialog")
    m.top.pdialogAuth.title = "Please wait..."
End Function

Function hideLoadingDialog(showDialog=invalid,dialog=invalid) as Object
    dialog = invalid
    If showDialog <> invalid and dialog<>invalid Then
        If showDialog = true Then
             dialog.Close()
        EndIf
    EndIf
    return dialog
End Function

'   Below are the API Helper Method
'   which is used for above section.
'   Don't Change the code of the below section.
'

Function SimpleJSONParser( jsonString As String ) As Object
    ' setup "null" variable
    null = invalid

    regex = CreateObject( "roRegex", Chr(34) + "([a-zA-Z0-9_\-\s]*)" + Chr(34) + "\:", "i" )
    regexSpace = CreateObject( "roRegex", "[\s]", "i" )
    regexQuote = CreateObject( "roRegex", "\\" + Chr(34), "i" )

    ' Replace escaped quotes
    jsonString = regexQuote.ReplaceAll( jsonString, Chr(34) + " + Chr(34) + " + Chr(34) )

    jsonMatches = regex.Match( jsonString )
    iLoop = 0
    While jsonMatches.Count() > 1
        ' strip spaces from key
        key = regexSpace.ReplaceAll( jsonMatches[ 1 ], "" )
        jsonString = regex.Replace( jsonString, key + ":" )
        jsonMatches = regex.Match( jsonString )

        ' break out if we're stuck in a loop
        iLoop = iLoop + 1
        If iLoop > 5000 Then
            Exit While
        End If
    End While

    jsonObject = invalid
    ' Eval the BrightScript formatted JSON string
    ParseJson("jsonObject = " + jsonString )
    Return jsonObject
End Function


Function SimpleJSONBuilder( jsonArray As Object ) As String
    Return SimpleJSONAssociativeArray( jsonArray )
End Function


Function SimpleJSONAssociativeArray( jsonArray As Object ) As String
    jsonString = "{"

    For Each key in jsonArray
        jsonString = jsonString + Chr(34) + key + Chr(34) + ":"
        value = jsonArray[ key ]
        If Type( value ) = "roString" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        else if Type( value ) = "String" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        Else If Type( value ) = "roInt" Or Type( value ) = "roFloat" Then
            jsonString = jsonString + value.ToStr()
        Else If Type( value ) = "roInteger" Then
            jsonString = jsonString + value.ToStr()
        Else If Type( value ) = "roBoolean" Then
            jsonString = jsonString + IIf( value, "true", "false" )
        Else If Type( value ) = "roArray" Then
            jsonString = jsonString + SimpleJSONArray( value )
        Else If Type( value ) = "roAssociativeArray" Then
            jsonString = jsonString + SimpleJSONBuilder( value )
        End If
        jsonString = jsonString + ","
    Next
    If Right( jsonString, 1 ) = "," Then
        jsonString = Left( jsonString, Len( jsonString ) - 1 )
    End If

    jsonString = jsonString + "}"
    Return jsonString
End Function


Function SimpleJSONArray( jsonArray As Object ) As String
    jsonString = "["

    For Each value in jsonArray
        If Type( value ) = "roString" Then
            jsonString = jsonString + Chr(34) + value + Chr(34)
        Else If Type( value ) = "roInt" Or Type( value ) = "roFloat" Then
            jsonString = jsonString + value.ToStr()
        Else If Type( value ) = "roBoolean" Then
            jsonString = jsonString + IIf( value, "true", "false" )
        Else If Type( value ) = "roArray" Then
            jsonString = jsonString + SimpleJSONArray( value )
        Else If Type( value ) = "roAssociativeArray" Then
            jsonString = jsonString + SimpleJSONAssociativeArray( value )
        End If
        jsonString = jsonString + ","
    Next
    If Right( jsonString, 1 ) = "," Then
        jsonString = Left( jsonString, Len( jsonString ) - 1 )
    End If

    jsonString = jsonString + "]"
    Return jsonString
End Function

Function IIf( Condition, Result1, Result2 )
    If Condition Then
        Return Result1
    Else
        Return Result2
    End If
End Function


' Below code are testing code
Function testVoid () as void
End Function

Function apiWithPutRequest(url as String, params as String,isShowDialog as boolean,headers as Object,enablePut as Boolean,mainScreen=invalid)
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.EnableEncodings(true)
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    if enablePut = true
       request.SetRequest("PUT")
    end if
    request.AddHeader("Content-type", "application/json")
    If type(headers)="roAssociativeArray" Then
        For Each key in headers
            request.AddHeader(key,headers[key])
        End For
    End If
    request.InitClientCertificates()
    checkRokuConnection = CreateObject("roDeviceInfo")
    If(checkrokuconnection.GetLinkStatus()) Then
        If(params <> "") Or enablePut = true
            requestType = request.AsyncPostFromString(params)
        Else
            requestType = request.AsyncGetToString()
        End If
        timer=createobject("roTimeSpan")
        timer.Mark()
        If (requestType)
            ''? "***** requestType ******"
            while (true)
                ''? "**** true *******"
                msg = wait(getPortConnectionTime(), port)
                ''? "****** msg *****";msg
                If (type(msg) = "roUrlEvent") then
                    '' ? "****** msg *****";type(msg)
                    code = msg.GetResponseCode()
                    ''? "**** Code ****";code
                    responseString = msg.GetString()
                    '? "***** responseString in failure case ******";responseString
                    If (code = 200) then
                        responseString = msg.GetString()
                        '? "*********** responseString in Fetch Price Api*********== *****";responseString
                        json = ParseJSON(responseString)
                        '? "**********8 json == ****************";json
                        if json <> invalid
                             if json.response <> invalid
                                  return json
                             else
                                  return {"errMsg":"Error"}
                             end if
                        else
                                  return {"errMsg":"Error"}
                        end if
                     Else
                        return {"errMsg":"Error"}
                     EndIf
                Else
                    request.AsyncCancel()
                    return {"errMsg":"Error"}
                End If
            End while
        End If
     Else
         return {"errMsg":"Error"}
     End If
End Function

Function getGetApiJsonWithoutResponse(url as String, params as String,isShowDialog as boolean,headers as Object,mainScreen=invalid)
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.EnableEncodings(true)
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")

    request.AddHeader("Content-type", "application/json")
    If type(headers)="roAssociativeArray" Then
        For Each key in headers
            request.AddHeader(key,headers[key])
            '? "****** headers *****";key
             '? "****** headers *****";headers[key]
        End For
    End If
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    checkRokuConnection = CreateObject("roDeviceInfo")
    If(checkrokuconnection.GetLinkStatus()) Then
        If(params <> "")
            requestType = request.AsyncPostFromString(params)
        Else
            requestType = request.AsyncGetToString()
        End If
        timer=createobject("roTimeSpan")
        timer.Mark()
        If (requestType)
            ''? "***** requestType ******"
            while (true)
                ''? "**** true *******"
                msg = wait(getPortConnectionTime(), port)
                ''? "****** msg *****";msg
                If (type(msg) = "roUrlEvent") then
                     ''? "****** msg *****";type(msg)
                    code = msg.GetResponseCode()
                    ''? "**** Code ****";code
                    responseString = msg.GetString()
                    '? "***** responseString in failure case ******";responseString
                    responseStringFail = msg.GetFailureReason()
                    '? "***** responseString in failure case ******";responseStringFail
                    If (code = 200) then
                        responseString = msg.GetString()
                        '? "*********** responseString in Fetch Price Api*********== *****";responseString
                        json = ParseJSON(responseString)
                       '? "**********8 json == ****************";json
                        if json <> invalid
                            return json
                        else
                              return {"errMsg":"Error"}
                        end if
                     Else
                        return {"errMsg":"Error"}
                     End If
                Else
                    request.AsyncCancel()
                    return {"errMsg":"Error"}
                End If
            End while
        End If
     Else
         return {"errMsg":"Error"}
     End If
End Function

