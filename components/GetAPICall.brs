sub init()
    m.top.functionName = "Gettlv"
end sub
        

sub Gettlv()
    'urlPath = "API URL"

    urlPath = "https://e92c5dzx3j.execute-api.us-east-1.amazonaws.com/DEV/v1/products/list?link=:relevance:allCategories:tlv&perPageProduct=16&sortBy=relevance&page=0&ROA=1"
    'urlPath = urlPath + "0"
    
    'headersValue = getApiHeader()
    headers = CreateObject("roAssociativeArray")
    'headers.AddReplace("Host",headersValue)
    apiKey = "BbJrpdI5Gf3TazdWmsTKs2pBCFyeQMI45oIB70yk"
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