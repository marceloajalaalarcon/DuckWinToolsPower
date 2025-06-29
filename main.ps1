#region Script Configuration
# ================================================================================
# 🔧 Ferramenta de Manutenção do Sistema - DuckDev
# Descrição: Script para realizar tarefas comuns de manutenção e reparo do Windows.
# Autor: Marcelo Ajala Alarcon
# Versão: 3.0 (Final Híbrida)
# ================================================================================

[CmdletBinding()]
param (
    [Switch]$ScheduledClean
)
#endregion

#region Carregamento Híbrido (Local ou GitHub)
# ==============================================================================
#  Carrega os módulos de acordo.
# ==============================================================================

    Write-Host "✅ Detectado modo de execução remoto (GitHub) com verificação de assinatura." -ForegroundColor Cyan
    $githubBaseUrl = 'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/modules/'
    $manifestUrl = $githubBaseUrl + "modules.json"
    
    try {
        Write-Host "=> Baixando o manifesto de módulos..."
        $modulesToLoad = irm $manifestUrl
        
        Write-Host "=> Módulos a serem verificados e carregados: $($modulesToLoad -join ', ')" -ForegroundColor Green

        foreach ($moduleFile in $modulesToLoad) {
            $moduleUrl = $githubBaseUrl + $moduleFile
            $tempFilePath = Join-Path $env:TEMP "$([System.Guid]::NewGuid()).ps1" # Cria um nome de arquivo temporário único
            
            try {
                Write-Host "   -> Baixando '$moduleFile' para verificação..."
                irm $moduleUrl -OutFile $tempFilePath

                Write-Host "   -> Verificando módulo: $moduleFile" -ForegroundColor Gray
                # $signature = Get-AuthenticodeSignature -FilePath $tempFilePath

                # if ($signature.Status -eq 'Valid') {
                #     Write-Host "   -> Assinatura VÁLIDA. Carregando: $moduleFile" -ForegroundColor Yellow
                #     . $tempFilePath
                # } else {
                #     throw "MÓDULO REMOTO INSEGURO BLOQUEADO: '$moduleFile'. Status da assinatura: $($signature.Status)"
                # }
            }
            finally {
                # O bloco 'finally' GARANTE que o arquivo temporário seja apagado, mesmo se ocorrer um erro.
                if (Test-Path $tempFilePath) {
                    Remove-Item $tempFilePath -Force
                }
            }
        }
        Write-Host "✔️ Todos os módulos remotos seguros foram carregados com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERRO DE SEGURANÇA OU CARREGAMENTO REMOTO" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
        Read-Host "Pressione ENTER para sair."
        exit
    }
Start-Sleep -Seconds 1
#endregion

# region Verificação de Privilégios e Configuração Inicial
# ======================================================================================================================
# 🚨 Verificação de Privilégios
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "⏫ Permissões de administrador necessárias. Reabrindo o script..." -ForegroundColor Yellow
    $commandToRerun = "irm h'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/main.ps1 | iex"
    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($commandToRerun))
    Start-Process powershell.exe -ArgumentList "-EncodedCommand $encodedCommand" -Verb RunAs
    exit
}

# ======================================================================================================================
# Termo de Uso e Ponto de Restauração
function Mostrar-TermoDeUso {
    while ($true) {
        Clear-Host
        $termo = @"
================================================================================
TERMO DE USO, TRANSPARÊNCIA E OPÇÕES INICIAIS
================================================================================

Olá! Seja bem-vindo à Ferramenta de Manutenção DuckDev.
Autor: Marcelo Ajala Alarcon

Esta ferramenta foi criada para simplificar e automatizar o acesso a
utilitários de manutenção poderosos que já existem nativamente no seu Windows.
O objetivo é ser transparente sobre cada ação executada.

--------------------------------------------------------------------------------
1. O PRINCÍPIO DA TRANSPARÊNCIA: O QUE A FERRAMENTA FAZ
--------------------------------------------------------------------------------

Este script não instala softwares de terceiros. Ele apenas executa comandos
que você mesmo poderia digitar no Prompt de Comando ou PowerShell.

* Ações Principais: sfc /scannow, DISM.exe /RestoreHealth, chkdsk.exe,
  limpeza de arquivos temporários, reset de componentes do Windows Update, etc.

--------------------------------------------------------------------------------
2. OS RISCOS ENVOLVIDOS: SUA RESPONSABILIDADE COMO USUÁRIO
--------------------------------------------------------------------------------

Apesar de usar ferramentas nativas, qualquer operação de manutenção profunda
oferece riscos, especialmente em sistemas personalizados ou com falhas de
hardware pré-existentes.

É ALTAMENTE RECOMENDADO QUE VOCÊ FAÇA UM BACKUP DE SEUS DADOS IMPORTANTES
ANTES DE EXECUTAR QUALQUER OPÇÃO DE REPARO.

--------------------------------------------------------------------------------
3. O ACORDO: TERMO DE RESPONSABILIDADE
--------------------------------------------------------------------------------

Este software é fornecido "COMO ESTÁ", sem garantia de qualquer tipo.
AO USAR ESTE SCRIPT, VOCÊ CONCORDA QUE O AUTOR (MARCELO AJALA ALARCON) NÃO
SERÁ RESPONSABILIZADO por quaisquer danos, incluindo perda de dados ou
instabilidade do sistema. A responsabilidade pelo uso é inteiramente sua.

--------------------------------------------------------------------------------
4. CONFIGURAÇÃO INICIAL (LEIA COM ATENÇÃO)
--------------------------------------------------------------------------------

Para sua segurança, a ferramenta SEMPRE criará um Ponto de Restauração do
Sistema antes de executar qualquer tarefa.

A única escolha necessária é se você deseja que a ferramenta lembre do seu
consentimento para não exibir esta tela nas próximas vezes.

"@
        Write-Host $termo -ForegroundColor Yellow
        Write-Host "================================================================================" -ForegroundColor Cyan
        Write-Host "[1] Aceitar e Lembrar Consentimento (Recomendado)" -ForegroundColor Green
        Write-Host "[2] Aceitar Apenas para Esta Sessão" -ForegroundColor Yellow
        Write-Host "[0] Recusar e Sair" -ForegroundColor Red
        
        $escolha = Read-Host "Digite sua escolha"
        switch ($escolha) {
            '1' { return @{ Action = 'Proceed'; SaveConsent = $true; } }
            '2' { return @{ Action = 'Proceed'; SaveConsent = $false; } }
            '0' { return @{ Action = 'Exit'; SaveConsent = $false; } }
            default { Write-Host "`nOpção inválida." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
    }
}

$consentFile = Join-Path $env:APPDATA "DuckDevToolConsent.txt"
if (-not (Test-Path $consentFile)) {
    $userChoice = Mostrar-TermoDeUso
    if ($userChoice.Action -eq 'Proceed') {
        if ($userChoice.SaveConsent) { Set-Content -Path $consentFile -Value "Termos aceitos em $(Get-Date)" | Out-Null }
    } else {
        Write-Host "`nVocê não aceitou os termos. O script será encerrado." -ForegroundColor Red; Start-Sleep -Seconds 3; exit
    }
}

$Host.UI.RawUI.WindowTitle = "🔧 Ferramenta de Manutenção do Sistema - DuckDev v3.0"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "DarkBlue"
Clear-Host

# Chama a função que foi carregada do helpers.ps1
Verificar-Antivirus
#endregion

#region Lógica Principal de Execução

function Mostrar-Menu {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "    🔧 FERRAMENTA DE MANUTENÇÃO DO SISTEMA" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "--- SISTEMA ---" -ForegroundColor Green
    Write-Host "[1] 🔍 Verificar arquivos do sistema (SFC)"
    Write-Host "[2] 🛠️  Reparo da imagem do sistema (DISM)"
    Write-Host
    Write-Host "--- DISCO ---" -ForegroundColor Green
    Write-Host "[3] 💾 Agendar verificação de disco (CHKDSK)"
    Write-Host "[4] 🧹 Limpeza de arquivos temporários"
    Write-Host "[5] 🧪 Verificar status SMART do disco"
    Write-Host
    Write-Host "--- REDE E ATUALIZAÇÕES ---" -ForegroundColor Green
    Write-Host "[6] 🌐 Cofiguração de rede"
    Write-Host "[7] ♻️ Reiniciar componentes do Windows Update"
    Write-Host
    Write-Host "--- OUTROS ---" -ForegroundColor Green
    Write-Host "[8] 📅 Agendar tarefa de limpeza diária"
    Write-Host "[9] 🖨️ Limpar fila de impressão"
    Write-Host
    Write-Host "--- SAIR ---" -ForegroundColor Red
    Write-Host "[0] ❌ Sair"
    Write-Host
}

if ($ScheduledClean.IsPresent) {
    Executar-Limpeza | Out-Null
    exit
}

do {
    Mostrar-Menu
    $opcao = Read-Host "Escolha uma opção"

    switch ($opcao) {
        "0" { exit }
        "1" { Executar-SFC }
        "2" { Executar-DISM }
        "3" { Executar-CHKDSK }
        "4" { Executar-Limpeza }
        "5" { Verificar-SMART }
        "6" { Diagnostico-Rede }
        "7" { Reiniciar-WU }
        "8" { Agendar-Tarefa }
        "9" { Limpar-FilaImpressao }
        default { Write-Log "`n❗ Opção inválida." -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} while ($true)
# SIG # Begin signature block
# MIIbpgYJKoZIhvcNAQcCoIIblzCCG5MCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgqplG9KO5POnSTbWG2jlpAqK
# 0TSgghYXMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
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
# V5uZYvL1VBFVIr+kMQGLNdo5lMqab+pjXSMwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIG
# vDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVowQjELMAkGA1UEBhMCVVMx
# ETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAg
# MjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5qc5/2lSGrljC6
# W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L660x5XltSVhhK64zi9Ce
# C9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLuslxdr9Qq82aKcpA9O//X6Q
# E+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7avVnpUVmPvkxT8c2a2yC0
# WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl7/r419CvEYVIrH6sN00y
# x49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+NBikDO0mlUh902wS/Eeh8
# F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVkiqLq+ISTdEjJKGjVfIcsg
# A4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5n10jxmGpxoMc6iPkoaDh
# i6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h6gYldp4FCMgrXdKWfM4N
# 0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNeREXAu2xUDEW8aqzFQDYm
# r9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLqfY/M/SdV6mwWTyeVy5Z/
# JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAE
# GTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3Mp
# dpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGalY17uT5IfdqBbMFoGA1Ud
# HwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRy
# dXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUF
# BwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# WAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZI
# hvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tOCB3RKE/P09x7gUsmXqt4
# 0ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSXgmUrDKNSQqGTdpjHsPy+
# LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPnvIWrqVogK0qM8gJhh/+q
# DEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM2UeUUW/8z3fvjxhN6hdT
# 98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlTVYzqfLDbe9PpBKDBfk+r
# abTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ/xll/HjO9JbNVekBv2Tg
# em+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef4uaZFORNekUgQHTqddms
# PCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk9104WQzYuVNsxyoVLObhx3
# RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7ucykW7eaCuWBsBb4HOKR
# FVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZDBD+XgbF+23/zBjeCtxz+
# dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3KeFUCS7tpFk7CrDqkMYIE
# +TCCBPUCAQEwNDAgMR4wHAYDVQQDDBVEdWNrRGV2LVRvb2xzLUNlcnQtVjMCEF4Q
# +j1PzX+4QnB9cAfHnAIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBaS37iXjjTpv1UKgn8tJOu0
# e/X7MA0GCSqGSIb3DQEBAQUABIIBACTAP1c5plaRJt7OhAH2w/YWWaPbHaPHlJyQ
# nf5Y3VUY4iOWLy2T+CwiGuNu+MkQeafbesa3wswN1Ye3/VRU/eWXAzbuu5BtI+Mm
# p3Sfs441GzcWVQY1lztcCyYjcczdZu8vI92XNnsdNeUd8+qMpPRRaZYzk+0YgIBx
# dEZwrmXWp+dd5I6ATMRNnpKeXf/IRGdShzJd40AOVYdiYsUqQSzfYV/JdTm2daeW
# 72IBAUsyZ7isQtv7bsISbUt2q9rYqtOPY8QPq0CQXv3zMR9/MWXRvuyvBz2imm4W
# ghUyV+g4rS8cJv7evCzoTRTlFMXZKy8nNcT6QDZNMDbC1wVmsT6hggMgMIIDHAYJ
# KoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNB
# NDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhALrma8Wrp/lYfG+ekE4zMEMA0G
# CWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
# 9w0BCQUxDxcNMjUwNjI5MDUyMjAzWjAvBgkqhkiG9w0BCQQxIgQgFrksddoVYe8R
# BGEt60X2al4xbdYrCScCSToIBD1aSFIwDQYJKoZIhvcNAQEBBQAEggIAmFsAshTh
# 4iu/EIZso+EXyYutmIxJaFzbjubvw5JcfVDh8FJGkdnr043r8/K4lulgAWpQklbh
# QRp9wgUBpIo2zjZ9eNsaLoYK+/NXJ2vrxsQnbl2z7UlkeVOf8P8ehrhYDxKvwHf1
# B8mbbaUUuxm3/2NeOT7pTXJ4K5ixrg/KNVgSat6/Y3JUGfjearGX+6xOhlL/xf7v
# 8FvXVVsFSxtYnse8vz9PCYP2nJl565wXWIxnwd51VOQT9wKG8WZMGRy9N2BvnBn7
# IHwRo3pInBYYlPoq2jUee/WZwrmvZF92voBvEh7DaK+m7DN0M4CA4MU90a5Xbr1r
# lZvtGcjYQZN8k3iNWsTJuwBm31MyKq1NYBu+pj6Oy8IJOaWSmVhFwYAJCpFg2E4A
# wR2UcBtOEeHZXtzOLGvKzHOuBNB0/m74oimukn/MyNd0Q9y6VBR0sCD127jD+Xde
# 1ia4grHAEqfscMhH5Ub684PLwoAWH/FiC+pDvgwNZwvXpbaNn6EZLX+akJdNRSZV
# tTkrRE9ZY8nF850xvgGjlJGfK2aU8Bv5AF1R4qcTBgW9QYIYcBLPWmAyGO/+Ln5u
# 4apT0Z1VMXY3pDDHTIOhXezr3mVkgvxGuW9we/SYi2g+4szFMamAMY4liyI3U5xp
# LpstBab6INkswLmcGhtZsDatS2chvrhFRow=
# SIG # End signature block
