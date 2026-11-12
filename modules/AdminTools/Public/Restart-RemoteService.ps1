function Restart-RemoteService {
<#
.SYNOPSIS
    Restarts one or more Windows services on this computer or on other computers.

.DESCRIPTION
    Without -ComputerName it restarts the service on this computer. With -ComputerName it connects with CIM
    (the same way in Windows PowerShell 5.1 and PowerShell 7), stops the service, waits until it has stopped,
    and starts it again. Use -WhatIf first to see what would happen. One result per computer and service.
    Replaces the old "Service-StartStop" scripts.

.PARAMETER Name
    The service name(s), for example winmgmt (not the display name).

.PARAMETER ComputerName
    The computer(s). Leave out for this computer.

.PARAMETER Credential
    An account that is allowed to manage services on the other computer.

.PARAMETER TimeoutSeconds
    How long to wait for the service to stop and to start (default 30).

.EXAMPLE
    Restart-RemoteService -Name winmgmt -ComputerName SRV01, SRV02 -WhatIf
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Name,

        [Parameter(Position = 1)]
        [string[]]$ComputerName,

        [pscredential]$Credential,

        [ValidateRange(5, 600)]
        [int]$TimeoutSeconds = 30
    )

    foreach ($n in $Name) {
        if ($n -match '["''`;|&<>]' -or -not $n.Trim()) { throw "Not a valid service name: $n" }
    }

    $local = -not $ComputerName
    if ($local) { $ComputerName = @($env:COMPUTERNAME) }

    foreach ($computer in $ComputerName) {
        $session = $null
        foreach ($svc in $Name) {
            if (-not $PSCmdlet.ShouldProcess("$computer : $svc", 'Restart service')) { continue }

            $result = 'Restarted'
            $message = ''
            try {
                if ($local) {
                    Restart-Service -Name $svc -ErrorAction Stop
                }
                else {
                    if (-not $session) {
                        $sessionArgs = @{ ComputerName = $computer; ErrorAction = 'Stop' }
                        if ($Credential) { $sessionArgs.Credential = $Credential }
                        $session = New-CimSession @sessionArgs
                    }
                    $filter = "Name='$svc'"
                    $obj = Get-CimInstance -CimSession $session -ClassName Win32_Service -Filter $filter -ErrorAction Stop
                    if (-not $obj) { throw "No service named '$svc'." }

                    if ($obj.State -ne 'Stopped') {
                        $r = Invoke-CimMethod -InputObject $obj -MethodName StopService -ErrorAction Stop
                        if ($r.ReturnValue -notin 0, 5) { throw "StopService returned code $($r.ReturnValue)." }   # 5 = already stopped
                        $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
                        do {
                            Start-Sleep -Milliseconds 500
                            $obj = Get-CimInstance -CimSession $session -ClassName Win32_Service -Filter $filter -ErrorAction Stop
                        } while ($obj.State -ne 'Stopped' -and (Get-Date) -lt $deadline)
                        if ($obj.State -ne 'Stopped') { throw "The service did not stop within $TimeoutSeconds seconds." }
                    }

                    $r = Invoke-CimMethod -InputObject $obj -MethodName StartService -ErrorAction Stop
                    if ($r.ReturnValue -notin 0, 10) { throw "StartService returned code $($r.ReturnValue)." }   # 10 = already running
                    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
                    do {
                        Start-Sleep -Milliseconds 500
                        $obj = Get-CimInstance -CimSession $session -ClassName Win32_Service -Filter $filter -ErrorAction Stop
                    } while ($obj.State -ne 'Running' -and (Get-Date) -lt $deadline)
                    if ($obj.State -ne 'Running') { throw "The service did not start within $TimeoutSeconds seconds." }
                }
            }
            catch {
                $result = 'Failed'
                $message = $_.Exception.Message
            }

            [pscustomobject]@{
                PSTypeName = 'TerminalPro.ServiceRestart'
                Computer   = $computer
                Service    = $svc
                Result     = $result
                Message    = $message
            }
        }
        if ($session) { Remove-CimSession $session }
    }
}
