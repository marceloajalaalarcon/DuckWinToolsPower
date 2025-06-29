# Arquivo: modules/helpers.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para registrar logs e exibir mensagens na tela.
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$ForegroundColor = 'White'
    )
    # Exibe a mensagem no console.
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Função para verificar a presença de antivírus de terceiros.
function Verificar-Antivirus {
    try {
        # Procura por produtos antivírus que NÃO sejam o Windows Defender.
        $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
        
        # Se encontrar algum, exibe um alerta.
        if ($avList) {
            Write-Host
            Write-Host '🛡️ ALERTA: Antivírus de terceiro detectado!' -ForegroundColor White -BackgroundColor DarkRed
            Write-Host 'Ele pode interferir em algumas operações do script.' -ForegroundColor Yellow
            Write-Host "Antivírus encontrado: $($avList -join ', ')" -ForegroundColor Yellow
            Write-Host
            # Pausa para o usuário ler o alerta.
            Read-Host 'Pressione ENTER para continuar...'
        }
    }
    catch {
        # Ignora erros caso não consiga verificar (não é uma função crítica).
    }
}
# SIG # Begin signature block
# MIIFfwYJKoZIhvcNAQcCoIIFcDCCBWwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMZ0atfupiIlIIk/RjtPHlRth
# MbegggMUMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
# AQsFADAgMR4wHAYDVQQDDBVEdWNrRGV2LVRvb2xzLUNlcnQtVjMwHhcNMjUwNjI5
# MDMxNDIzWhcNMjYwNjI5MDMzNDIzWjAgMR4wHAYDVQQDDBVEdWNrRGV2LVRvb2xz
# LUNlcnQtVjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC2Zvk6iajp
# +Nim5Q8YbW7fqnwZwaTGyiY4w2xUZJIoq1ndtRg276vX1mvX7DRTrj/9gSthFoET
# iWJUddu3i21wUAGn2o2BsBbn4FnVFKHk0Lhala+0LDypADnw8aOXXV5OxbCWM8GU
# IMYrkBJ/JZfwuoMhqXiLcVJiH0Md8hH722dF53TG7X2k+s8vsyNEMS6ivwWrnE9D
# 1hfgWEGmV6lbgn2hccthXUZbh0y1e91jsn+6BKmAvW0BHSjGNxadCLTBgENx1BEq
# PUcnAWl2+sp9qutpXjFunrMiOI5xTDcWJhIf1E4FEpBiz243Pe2/sKFY1r3HOg43
# KIsekBLAEjg9AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQUO233++ycF1kHf1EMKWzQ/UnRVdIwDQYJKoZIhvcN
# AQELBQADggEBACOhIXbBgvT4T4IsKsnLar3kOYvGx4X/8QyVDDktvCSvO7DWlKrk
# pE8X0ucApg1jScroFZWptMFQ9qtUnB8w/1r/qMcmSiNFdSWeemVE3dNJoIuCUnz9
# mg4tPCyM/m5auuDZZQI0buYOvqSyMOvAWrY9jKooc3EmY+OVUAZFgOmzKsg2vr0e
# oCFEkER/kUWnJYMsGefT9RCNmvYhlM+TJiDlwLC35BJWJ4RbF5DahTpb5OsWs9Iu
# H71xYG51MmrsFt+Pga+JkDoDfcXC12iGyod3NejAHBb3WafZe4Qdi0avzbOh4Zpl
# V5uZYvL1VBFVIr+kMQGLNdo5lMqab+pjXSMxggHVMIIB0QIBATA0MCAxHjAcBgNV
# BAMMFUR1Y2tEZXYtVG9vbHMtQ2VydC1WMwIQXhD6PU/Nf7hCcH1wB8ecAjAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUmC4+A5JmP2Uzn4lQOw5EbrZAL2EwDQYJKoZIhvcNAQEBBQAE
# ggEAg04cbgPvCjHNdw+Bc9E5qpOiYI2dbTicqUzGqKsD/AGD/XAkQJh/6Le2rCU/
# JbWFqy/E4xQlvOHbh+EfDvWZ/YplbG2mUIEDSbn8641wjiKLOaxA3eBVbMFTzFI7
# pfof3+iewIm/Wz8lIXk9GE877Fm3lse8sytwe6ALnPVOh5JtQv+MND9QpZCvpn9U
# dTRUL9UCW+5mSKbXotlB8VnragL30D37t+hqocXkMS+JP1cTsG1z/EXLFUx59ZDg
# btnmJCQYAO4rjL0w5reqg3Id2Pqd/XlXGjg4Rz4ykUoyB6GhCj8+SjARi3yR3p3d
# dLskjp90SpDI2swK5NWGXEKDlg==
# SIG # End signature block
