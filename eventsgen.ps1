# Set up logging
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "DEBUG"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Debug "$timestamp - $Level - $Message"
}

function Send-SyslogMessage {
    param(
        [string]$Message,
        [string]$Program,
        [int]$Facility = 1,
        [int]$Severity = 6
    )
    $SYSLOG_SERVER = '192.168.0.117'
    $SYSLOG_PORT = 514

    $priority = ($Facility * 8) + $Severity
    $timestamp = Get-Date -Format "MMM dd HH:mm:ss"
    $hostname = [System.Net.Dns]::GetHostName()
    $syslog_message = "<{0}>{1} {2} {3}: {4}" -f $priority, $timestamp, $hostname, $Program, $Message

    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect($SYSLOG_SERVER, $SYSLOG_PORT)
        $encodedMessage = [System.Text.Encoding]::UTF8.GetBytes($syslog_message)
        $udpClient.Send($encodedMessage, $encodedMessage.Length) | Out-Null
        Write-Log "Sent message: $syslog_message"
        
        # Debug: Print the full message
        Write-Host "Full message sent: $syslog_message"
    }
    catch {
        Write-Log "Failed to send message: $_" -Level "ERROR"
    }
    finally {
        $udpClient.Close()
    }
}

function Generate-TestLogs {
    $special_logs = @(
        @{Program="kernel"; Message="[UFW BLOCK] IN=eth0 OUT= MAC=00:00:00:00:00:00:00:00:00:00:00:00:00:00 SRC=10.0.0.1 DST=10.0.0.2 LEN=40"},
        @{Program="kernel"; Message="CPU usage: 80%"},
        @{Program="kernel"; Message="Memory usage: 75%"},
        @{Program="sshd"; Message="Failed password for invalid user admin from 192.168.1.100 port 22 ssh2"},
        @{Program="nginx"; Message='192.168.1.50 - - [03/Oct/2024:12:00:00 +0000] "GET /index.html HTTP/1.1" 200 2326 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"'},
        @{Program="mysql"; Message="MySQL server has started"},
        @{Program="apache2"; Message="AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message"},
        @{Program="postfix/smtp"; Message="connect to gmail-smtp-in.l.google.com[2a00:1450:4010:c03::1b]:25: Network is unreachable"},
        @{Program="systemd"; Message="Started Apache HTTP Server."},
        @{Program="fail2ban"; Message="2024-10-03 12:05:32,123 fail2ban.filter [14759]: INFO [sshd] Found 192.168.1.100 - 2024-10-03 12:05:32"}
    )

    while ($true) {
        try {
            # Generate a special log message
            $logEntry = $special_logs | Get-Random
            $program = $logEntry.Program
            $message = $logEntry.Message
            Send-SyslogMessage -Message $message -Program $program

            # Wait for a random interval between 1 and 5 seconds
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
        }
        catch {
            Write-Log "Error in Generate-TestLogs: $_" -Level "ERROR"
        }
    }
}

Write-Host "Starting to generate test logs. Press Ctrl+C to stop."
try {
    Generate-TestLogs
}
catch [System.Management.Automation.PipelineStoppedException] {
    Write-Host "`nStopped generating test logs."
}
catch {
    Write-Log "Unexpected error: $_" -Level "ERROR"
}
