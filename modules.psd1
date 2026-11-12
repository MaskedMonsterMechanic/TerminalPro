@{
    # Modules the installer saves into <Terminal Pro folder>\modules (never into Documents).
    # Enabled = $true  -> installed.
    # Enabled = $false -> listed only. Flip it to $true to install on the next run.
    #
    # PSReadLine ships with PowerShell 7, so it is not listed.

    Modules = @(
        # --- from the 2019/2021 setup ---
        @{ Name = 'posh-git'; Enabled = $true
           Why  = 'Tab completion for git commands and branch names.' }

        # --- from the old setup ---
        @{ Name = 'Microsoft.PowerShell.GraphicalTools'; Enabled = $false
           Why  = 'Out-GridView for PowerShell 7. Large (about 280 MB), so off by default.' }

        # --- suggestions for a 2026 terminal (CompletionPredictor is on; the rest are off until you say so) ---
        @{ Name = 'Terminal-Icons'; Enabled = $false
           Why  = 'File and folder icons in directory listings. Needs a Nerd Font in the terminal (the default Cascadia Code would show empty boxes).' }
        @{ Name = 'CompletionPredictor'; Enabled = $true
           Why  = 'Smarter inline predictions for PSReadLine: it knows the parameters of commands, not just your history (PowerShell 7.2+).' }
        @{ Name = 'ImportExcel'; Enabled = $false
           Why  = 'Read and write Excel files without Excel (Import-Excel, Export-Excel). Handy for exporting results.' }
        @{ Name = 'Microsoft.WinGet.CommandNotFound'; Enabled = $false
           Why  = 'When a command is missing, suggests the winget package that provides it (PowerShell 7.4+).' }
    )
}
