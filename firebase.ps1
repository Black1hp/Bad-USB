# Firebase configuration
$firebaseUrl = "https://XXXXXXXX.firebaseio.com/devices.json"

# Detect operating system - don't modify $IsWindows, use a different variable
$CurrentOSIsWindows = if ($null -ne $IsWindows) { $IsWindows } else { $true }

# Function to get system information
function Get-SystemInfo {
    if ($CurrentOSIsWindows) {
        try {
            $os = Get-CimInstance Win32_OperatingSystem
            $computer = Get-CimInstance Win32_ComputerSystem
            
            return @{
                ComputerName = $env:COMPUTERNAME
                OS = $os.Caption
                OSVersion = $os.Version
                Architecture = $os.OSArchitecture
                Manufacturer = $computer.Manufacturer
                Model = $computer.Model
                TotalPhysicalMemory = [math]::Round($computer.TotalPhysicalMemory/1GB, 2)
                NumberOfProcessors = $computer.NumberOfProcessors
                SystemType = $computer.SystemType
            }
        } catch {
            return @{
                ComputerName = $env:COMPUTERNAME
                OS = "Windows (CIM Unavailable)"
                Error = $_.Exception.Message
            }
        }
    } else {
        # Linux/Mac
        try {
            $uname = (uname -a) 2>$null
            $memInfo = "Unknown"
            if (Test-Path "/proc/meminfo") {
                $memLine = Get-Content "/proc/meminfo" -TotalCount 1 2>$null
                if ($memLine -match "MemTotal:\s+(\d+)\s+kB") {
                    $memKB = [int]$matches[1]
                    $memInfo = [math]::Round($memKB/1024/1024, 2).ToString() + " GB"
                }
            }
            
            return @{
                ComputerName = (hostname) 2>$null
                OS = "$(uname -o 2>$null)"
                OSVersion = "$(uname -r 2>$null)"
                Architecture = "$(uname -m 2>$null)"
                Kernel = "$(uname -s 2>$null)"
                TotalPhysicalMemory = $memInfo
                NumberOfProcessors = (nproc 2>$null)
                Distribution = if (Test-Path "/etc/os-release") {
                    (Get-Content "/etc/os-release" -TotalCount 5 2>$null) -match "PRETTY_NAME" | ForEach-Object { $_.Split('=')[1].Trim('"') }
                } else { "Unknown" }
            }
        } catch {
            return @{
                ComputerName = "Unknown"
                OS = "Linux/Unix"
                Error = $_.Exception.Message
            }
        }
    }
}

# Function to get running processes (simplified output)
function Get-ProcessEvidence {
    if ($CurrentOSIsWindows) {
        try {
            $processes = Get-Process | Select-Object -Property Name, Id, CPU, Path -First 20
            return @($processes | ForEach-Object {
                @{
                    Name = $_.Name
                    Id = $_.Id
                    CPU = $_.CPU
                    Path = $_.Path
                }
            })
        } catch {
            return @("Error: $($_.Exception.Message)")
        }
    } else {
        # Linux/Mac - using ps command with simplified output
        try {
            $psOutput = (ps aux --sort=-%cpu 2>$null | Select-Object -First 15) -join "`n"
            return $psOutput
        } catch {
            return "Process list unavailable"
        }
    }
}

# Function to get network connections
function Get-NetworkConnections {
    try {
        if ($CurrentOSIsWindows) {
            $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
                          Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess -First 20
            return @($connections | ForEach-Object {
                @{
                    LocalAddress = $_.LocalAddress
                    LocalPort = $_.LocalPort
                    RemoteAddress = $_.RemoteAddress
                    RemotePort = $_.RemotePort
                    OwningProcess = $_.OwningProcess
                }
            })
        } else {
            # Linux/Mac - using netstat or ss
            if (Get-Command ss -ErrorAction SilentlyContinue) {
                $connections = (ss -tunp 2>$null | Select-Object -First 10) -join "`n"
            } elseif (Get-Command netstat -ErrorAction SilentlyContinue) {
                $connections = (netstat -tunp 2>$null | Select-Object -First 10) -join "`n"
            } else {
                $connections = "Network tools not available"
            }
            return $connections
        }
    }
    catch {
        return "Network connection data unavailable"
    }
}

# Function to get logged-in users
function Get-LoggedInUsers {
    try {
        if ($CurrentOSIsWindows) {
            $users = (query user 2>$null)
            if ($users) {
                return $users
            }
            return whoami
        } else {
            # Linux/Mac
            $users = (who 2>$null)
            if (-not $users) {
                $users = "No users logged in or 'who' command failed"
            }
            return $users
        }
    }
    catch {
        return "User data unavailable: $($_.Exception.Message)"
    }
}

# Function to get ARP table
function Get-ArpTable {
    try {
        if ($CurrentOSIsWindows) {
            $arp = (arp -a 2>$null) -join "`n"
        } else {
            # Linux/Mac
            $arp = (arp -a 2>$null) -join "`n"
        }
        return $arp
    }
    catch {
        return "ARP table unavailable"
    }
}

# Function to get routing table
function Get-RoutingTable {
    try {
        if ($CurrentOSIsWindows) {
            $routes = Get-NetRoute -ErrorAction SilentlyContinue | 
                     Select-Object -Property DestinationPrefix, NextHop, RouteMetric, IfIndex -First 20
            return @($routes | ForEach-Object {
                @{
                    Destination = $_.DestinationPrefix
                    NextHop = $_.NextHop
                    Metric = $_.RouteMetric
                    Interface = $_.IfIndex
                }
            })
        } else {
            # Linux/Mac
            $routes = ""
            if (Get-Command ip -ErrorAction SilentlyContinue) {
                $routes = (ip route show 2>$null) -join "`n"
            } elseif (Get-Command route -ErrorAction SilentlyContinue) {
                $routes = (route -n 2>$null) -join "`n"
            }
            return $routes
        }
    }
    catch {
        return "Routing table unavailable"
    }
}

# Function to get services (simplified)
function Get-ServicesEvidence {
    if ($CurrentOSIsWindows) {
        try {
            $services = Get-Service -ErrorAction SilentlyContinue | 
                       Select-Object -Property Name, DisplayName, Status -First 30
            return @($services | ForEach-Object {
                @{
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    Status = $_.Status.ToString()
                }
            })
        } catch {
            return @("Error: $($_.Exception.Message)")
        }
    } else {
        # Linux/Mac - systemd services (simplified)
        try {
            if (Get-Command systemctl -ErrorAction SilentlyContinue) {
                $services = (systemctl list-units --type=service --state=running --no-pager 2>$null | Select-Object -First 10) -join "`n"
            } else {
                $services = "Systemd not available"
            }
            return $services
        } catch {
            return "Service information not available"
        }
    }
}

# Collect all evidence with simplified structure
$evidence = @{
    metadata = @{
        deviceName = if ($CurrentOSIsWindows) { $env:COMPUTERNAME } else { (hostname 2>$null) }
        userName = if ($CurrentOSIsWindows) { $env:USERNAME } else { (whoami 2>$null) }
        osPlatform = if ($CurrentOSIsWindows) { "Windows" } else { "Linux/Unix" }
        collectionTime = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        timeZone = if ($CurrentOSIsWindows) { 
            try { (Get-TimeZone).Id } catch { "Unknown" }
        } else { 
            try { (cat /etc/timezone 2>$null) } catch { "UTC" }
        }
        scriptVersion = "2.0"
    }
    
    # System Info
    systemInfo = Get-SystemInfo
    
    # Core Evidence (simplified to avoid JSON depth issues)
    systemTime = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    
    runningProcessesCount = if ($CurrentOSIsWindows) { 
        try { (Get-Process).Count } catch { "Unknown" }
    } else { 
        try { (ps aux 2>$null | Measure-Object).Count } catch { "Unknown" }
    }
    
    networkConnections = Get-NetworkConnections
    loggedInUsers = Get-LoggedInUsers
    arpEntries = Get-ArpTable
    routingTable = Get-RoutingTable
    services = Get-ServicesEvidence
}

# Add process sample (limited to avoid size issues)
if ($CurrentOSIsWindows) {
    try {
        $sampleProcesses = Get-Process | Select-Object -First 5 | ForEach-Object {
            @{
                Name = $_.Name
                Id = $_.Id
                CPU = $_.CPU
            }
        }
        $evidence.processSample = $sampleProcesses
    } catch {
        $evidence.processSample = "Unable to get process sample"
    }
} else {
    try {
        $evidence.processSample = (ps aux --sort=-%cpu 2>$null | Select-Object -First 3) -join " | "
    } catch {
        $evidence.processSample = "Unable to get process sample"
    }
}

# Convert to JSON with proper handling
try {
    $json = $evidence | ConvertTo-Json -Depth 3 -Compress
    Write-Host "JSON created successfully. Size: $($json.Length) bytes" -ForegroundColor Green
} catch {
    Write-Host "Error creating JSON: $_" -ForegroundColor Red
    # Create minimal JSON
    $minimalEvidence = @{
        deviceName = $evidence.metadata.deviceName
        userName = $evidence.metadata.userName
        osPlatform = $evidence.metadata.osPlatform
        collectionTime = $evidence.metadata.collectionTime
        error = "Full evidence collection failed: $_"
    }
    $json = $minimalEvidence | ConvertTo-Json -Depth 2
}

# Send to Firebase
try {
    Write-Host "Sending evidence to Firebase..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $firebaseUrl -Method POST -Body $json -ContentType "application/json" -TimeoutSec 30
    Write-Host "Evidence successfully sent to Firebase." -ForegroundColor Green
    Write-Host "Device: $($evidence.metadata.deviceName)" -ForegroundColor Cyan
    Write-Host "OS: $($evidence.metadata.osPlatform)" -ForegroundColor Cyan
}
catch {
    Write-Host "Error sending data to Firebase: $_" -ForegroundColor Red
    Write-Host "Response details (if any):" -ForegroundColor Yellow
    Write-Host $_.Exception.Response.StatusCode.Value__
    Write-Host $_.Exception.Response.StatusDescription
    
    # Save to local file as backup
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupPath = if ($CurrentOSIsWindows) { 
        "$env:TEMP\forensic_evidence_$timestamp.json" 
    } else { 
        "/tmp/forensic_evidence_$timestamp.json" 
    }
    
    try {
        $json | Out-File -FilePath $backupPath -Encoding UTF8 -Force
        Write-Host "Evidence saved locally at: $backupPath" -ForegroundColor Yellow
        
        # Also save a readable version
        $readablePath = $backupPath -replace '\.json$', '_readable.json'
        $evidence | ConvertTo-Json -Depth 3 | Out-File -FilePath $readablePath -Encoding UTF8 -Force
        Write-Host "Readable version at: $readablePath" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to save backup: $_" -ForegroundColor Red
    }
}