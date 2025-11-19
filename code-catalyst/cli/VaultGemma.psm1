# 🔐 VaultGemma CLI Wrapper for PowerShell
# Makes VaultGemma commands available from any directory

function VaultGemma {
    <#
    .SYNOPSIS
    WealthBridge VaultGemma Security Management CLI
    
    .DESCRIPTION
    Manage credentials, scan code for vulnerabilities, and handle encryption
    
    .EXAMPLE
    VaultGemma store stripe-key sk_live_xxxx
    VaultGemma list
    VaultGemma scan backend/app/api.py
    #>
    
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Command,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    
    $CodeCatalystPath = "c:\Users\VICTOR MORALES\Documents\WealthBridge\code-catalyst"
    $CliScript = Join-Path $CodeCatalystPath "cli\vaultgemma_cli.py"
    
    # Build command
    $FullCommand = @($Command) + $Arguments
    
    # Run Python script
    python $CliScript @FullCommand
}

function Vault {
    <#
    .SYNOPSIS
    Quick alias for VaultGemma
    #>
    VaultGemma @args
}

# Export functions
Export-ModuleMember -Function VaultGemma, Vault

# Show available commands on import
Write-Host "🔐 VaultGemma CLI loaded! Available commands:" -ForegroundColor Green
Write-Host "   Vault store <name> <value>    - Store a credential" -ForegroundColor Cyan
Write-Host "   Vault get <name>              - Retrieve a credential" -ForegroundColor Cyan
Write-Host "   Vault list                    - List all credentials" -ForegroundColor Cyan
Write-Host "   Vault scan <file>             - Scan file for vulnerabilities" -ForegroundColor Cyan
Write-Host "   Vault verify                  - Verify installation" -ForegroundColor Cyan
Write-Host "   Vault help                    - Show all commands" -ForegroundColor Cyan
