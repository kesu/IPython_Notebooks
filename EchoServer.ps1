$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add("http://localhost:15900/")
$HttpListener.Start()

While($HttpListener.IsListening) {

    $Context = $HttpListener.GetContext()
    $Request = $Context.Request
    $Response = $Context.Response

    $headers = @{}; $query_string = @{}
    $Request.Headers.Keys.ForEach({$headers.add($_, $Request.Headers.Get($_))})
    $Request.QueryString.ForEach({$query_string.add($_, $Request.QueryString.Get($_))})

    
    If($Request.HasEntityBody) {
        $body = $Request.InputStream
        $encoding = $Request.ContentEncoding
        $reader = New-Object System.IO.StreamReader($body, $encoding)
        $body_str = $reader.ReadToEnd()        
        $body.Close()
        $reader.Close()
    }
    
    $response_dict = @{"HttpMethod"=$Request.HttpMethod;
             "Headers"=$headers; 
             "QueryString"=$query_string; 
             "URL"=$Request.Url;
             "RequestBody"=$body_str}
             
        


   
    $response_json = ConvertTo-Json -InputObject $response_dict

    [byte[]] $Buffer = [System.Text.Encoding]::UTF8.GetBytes($response_json)
    $Response.ContentLength64 = $Buffer.Length
    $Output = $Response.OutputStream
    $Output.Write($Buffer, 0, $Buffer.Length)
    $Output.Close()
    $HttpListener.Close()
    
}

