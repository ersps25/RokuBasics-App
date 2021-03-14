sub init()
    m.top.functionName = "Gettlv"
end sub
        

sub Gettlv()
    urlPath = "API URL"
    'urlPath = urlPath + "0"
    
    'headersValue = getApiHeader()
    headers = CreateObject("roAssociativeArray")
    'headers.AddReplace("Host",headersValue)
    apiKey = "API Key"
    headers.AddReplace("x-api-key",apiKey)

    m.jsonObject = getGetApiJsonWithoutResponse(urlPath,"",false,headers,invalid)
    
    if(m.jsonObject.errMsg = invalid)
        m.top.content = m.jsonObject
        m.top.status = "success"
    else
        m.top.content = m.jsonObject
        m.top.status = "failure"
    end if
end sub