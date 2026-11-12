# Scripts

One place for scripts that put PaulShell to work.

The cheat-sheets (`adsrv`, `adbuild`, `addns`, `addhcp`, `adusers`, `adfiles`, …) show you **what** to type. A script is what you write when the same job has to run on many hosts, many times. That is the recursive loop of admin work: look it up, try it once, then wrap the loop.

You do not need a big library of scripts here. Open PaulShell, open a page, and ask an AI (or write it yourself) to turn the page into a script that takes a list or a CSV. PaulShell is the precursor; AI is complementary: it helps you **make** the scripts that automate the work.

## What is here

| Script | What it does |
|---|---|
| `Lab-HealthCheck.ps1` | DNS, ping, remoting, OS and uptime for a list of servers. Mixes `Resolve-HostList`, `Test-HostList` and `Get-PCInfo`. |
| `Client-NetCheck.ps1` | From your PC: your addresses, then DNS, ping and a few TCP ports on a target (default: your gateway). Mixes `Get-NetIPAdapter`, `Resolve-HostList`, `Test-HostList` and `Test-TcpPort`. |

```powershell
# In a PaulShell window:
cd $env:LOCALAPPDATA\TerminalPro\scripts   # or the project folder
.\Lab-HealthCheck.ps1
.\Lab-HealthCheck.ps1 dc01, file01 -Remoting
.\Lab-HealthCheck.ps1 -Path .\servers.example.txt -Remoting | Format-Table
.\Client-NetCheck.ps1
.\Client-NetCheck.ps1 -LocalOnly
.\Client-NetCheck.ps1 dc01 -Port 389, 636, 3389
.\Client-NetCheck.ps1 | Where-Object { $_.Kind -eq 'Port' -and $_.Open }
```

`servers.example.txt` is a sample list for the health check. Copy it to `servers.txt` and put your own names in.

## More scripts?

Maybe. The build recipes and the tools already cover a lot. Add a script when you have a real loop you run often. Keep each one small, return objects, and point back to the cheat-sheet that taught it.
