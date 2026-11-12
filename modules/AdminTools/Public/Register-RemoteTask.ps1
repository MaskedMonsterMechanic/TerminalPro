function Register-RemoteTask {
<#
.SYNOPSIS
    Creates a scheduled task on another computer from a task XML file.

.DESCRIPTION
    Export the task you want from Task Scheduler (or with Export-ScheduledTask) to an XML file, then push
    it to one or more computers. The password is never written in the command: you are asked for it when
    -Credential is not given.

.PARAMETER ComputerName
    The computer(s) that should get the task.

.PARAMETER XmlPath
    The exported task file.

.PARAMETER TaskName
    The name the task gets on the computer.

.PARAMETER Credential
    An account that is allowed to manage tasks on the other computer.

.PARAMETER Force
    Replace the task if it already exists.

.EXAMPLE
    Register-RemoteTask -ComputerName SRV01 -XmlPath .\Restart-App.xml -TaskName 'Restart App' -WhatIf
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [string]$XmlPath,

        [Parameter(Mandatory, Position = 2)]
        [string]$TaskName,

        [pscredential]$Credential,

        [string]$TaskPath = '\',

        [switch]$Force
    )

    if (-not (Test-Path -LiteralPath $XmlPath -PathType Leaf)) { throw "The XML file was not found: $XmlPath" }
    if ($TaskName -match '[\\/:*?"<>|]') { throw 'The task name cannot contain \ / : * ? " < > |' }

    $xmlText = Get-Content -LiteralPath $XmlPath -Raw
    try { $doc = [xml]$xmlText } catch { throw "The file is not valid XML: $XmlPath" }
    if ($doc.DocumentElement.LocalName -ne 'Task') { throw "The file is not a scheduled task export (the root element is '$($doc.DocumentElement.LocalName)', not 'Task')." }

    foreach ($computer in $ComputerName) {
        if (-not $PSCmdlet.ShouldProcess($computer, "Create scheduled task '$TaskName' from $(Split-Path $XmlPath -Leaf)")) { continue }

        $session = $null
        try {
            $sessionArgs = @{ ComputerName = $computer; ErrorAction = 'Stop' }
            if ($Credential) { $sessionArgs.Credential = $Credential }
            $session = New-CimSession @sessionArgs

            Register-ScheduledTask -CimSession $session -TaskName $TaskName -TaskPath $TaskPath -Xml $xmlText -Force:$Force -ErrorAction Stop
        }
        catch {
            Write-Error "$computer : $($_.Exception.Message)"
        }
        finally {
            if ($session) { Remove-CimSession $session }
        }
    }
}
