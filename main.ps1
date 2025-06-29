#region Script Configuration
# ======================================================================================================================
# 🔧 Ferramenta de Manutenção do Sistema - DuckDev
# Descrição: Script para realizar tarefas comuns de manutenção e reparo do Windows.
# Autor: Marcelo Ajala Alarcon
# Versão: 3.0 (Final Híbrida)
# ======================================================================================================================

[CmdletBinding()]
param (
    [Switch]$ScheduledClean
)
#endregion

#region Carregamento Híbrido (Local ou GitHub)
# ======================================================================================================================
# Detecta se o script está rodando localmente ou remotamente e carrega os módulos de acordo.
# ======================================================================================================================

if ($PSScriptRoot) { # MODO LOCAL
    Write-Host "✅ Detectado modo de execução local." -ForegroundColor Green
    try {
        $localModulesPath = Join-Path $PSScriptRoot "modules"
        $helperModulePath = Join-Path $localModulesPath "helpers.ps1"

        if (Test-Path $helperModulePath) {
            Write-Host "   -> Carregando módulo essencial: helpers.ps1" -ForegroundColor Yellow
            . $helperModulePath
        } else {
            throw "Arquivo de módulo essencial 'helpers.ps1' não encontrado!"
        }

        $otherModules = Get-ChildItem -Path $localModulesPath -Filter "*.ps1" -Exclude "helpers.ps1"
        foreach ($module in $otherModules) {
            Write-Host "   -> Carregando módulo: $($module.Name)" -ForegroundColor Yellow
            . $module.FullName
        }
        
        Write-Host "✔️ Módulos locais carregados com sucesso!" -ForegroundColor Green

    } catch {
        Write-Host "❌ Falha ao carregar módulos locais." -ForegroundColor Red
        Write-Host "Verifique se a pasta 'modules' e todos os arquivos existem e estão corretos."
        Write-Host "Erro: $($_.Exception.Message)"
        Read-Host "Pressione ENTER para sair."
        exit
    }
    
} else { # MODO REMOTO (GITHUB)
    Write-Host "✅ Detectado modo de execução remoto (GitHub)." -ForegroundColor Cyan
    $githubBaseUrl = 'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/modules/'
    $manifestUrl = $githubBaseUrl + "modules.json"
    
    try {
        Write-Host "=> Baixando o manifesto de: $manifestUrl"
        $modulesToLoad = irm $manifestUrl | ConvertFrom-Json
        
        Write-Host "=> Carregando os seguintes módulos:" -ForegroundColor Green
        $modulesToLoad | ForEach-Object { Write-Host "   - $_" }

        foreach ($moduleFile in $modulesToLoad) {
            $moduleUrl = $githubBaseUrl + $moduleFile
            Write-Host "   -> Carregando módulo remoto: $moduleFile" -ForegroundColor Yellow
            irm $moduleUrl | iex
        }
        Write-Host "✔️ Módulos remotos carregados com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Falha crítica durante o carregamento dos módulos remotos." -ForegroundColor Red
        Write-Host "Erro: $($_.Exception.Message)"
        Read-Host "Pressione ENTER para sair."
        exit
    }
}
Start-Sleep -Seconds 1
#endregion

#region Verificação de Privilégios e Configuração Inicial
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
#endregion
# SIG # Begin signature block
# MIIbjgYJKoZIhvcNAQcCoIIbfzCCG3sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/vFOUTsupUssiGGHYSooKSSJ
# HxegghYHMIIDADCCAeigAwIBAgIQNpJ3aGZvmopKsMhVmpuZUDANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1EdWNrRGV2IFRvb2xzMB4XDTI1MDYyNzAyNTY0M1oX
# DTI2MDYyNzAzMTY0M1owGDEWMBQGA1UEAwwNRHVja0RldiBUb29sczCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBAKn4Kp9OE2fKY7IgOxgVryfIA2r9+xSj
# RrqgXPquezWZEFz/XWm1ULBTxf3Ij6JOYKcNb7xdjEceAWEOLnisQTd4DLsNum3N
# CBfWEiJwkwdSdwQ/imwNluRl6ouM5odNc9gimUpOj96bHoqKCzbw/AuEi5EKF/KU
# rHbYvKnSj+4aWRzgtFaqYXMhDNuxrGdTFVJUgbwRkSDH7Yk8PCQVzPLD9G8DekZf
# X/VMamAH5eU39Awg8RljBXYYyi/dlOrjkvO9wTt/eciqsMqdzC2rTjBJwovNnBTM
# i82cugjUQq0JeMewACStnH8uPbHhloVAaDDCM6o4gWcxgP3+Fg+nOVkCAwEAAaNG
# MEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQW
# BBRqedNOpH/kDJiAX69bLw20ATSysTANBgkqhkiG9w0BAQsFAAOCAQEApP7dLlux
# WBqwC1ZZSTR2yCWsTptUieXUP7zNuCS0zjU9aChbZS/zMBpsJ1Y93KhOW9yso7o+
# gRyJdOZrJWOyWsLeSEPcBMIl1PqvShv4QhcJ/fd0la5VlmXpeW2xvpZ+JaLqljm6
# xSXrxoA7sS5b7ixBmAGinqPUuZXswxVSsjxvQHUcDiRs1kQdRATZULPQ55viYCpd
# v0+i/rFZDDkUvHLy3ZVNIKfUEzt7hOOrDPhBjFdoLbcG3RDQ+E/xHLOIxLsxXFQm
# XgX5AkK3rvQGRlM/CAtnyHJVvckuOCzkcWBfmYNvre63g4oDGCAhJnpxQy9F8Bse
# I2ZVOAlcgTVG0TCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZI
# hvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNz
# dXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVow
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290
# IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjww
# IjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J5
# 8soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMH
# hOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6
# Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQ
# ecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4b
# A3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9
# WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCU
# tNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvo
# ZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/J
# vNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCP
# orF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMB
# Af8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXr
# oq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRt
# MGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEF
# BQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgw
# BgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cH
# vZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8
# UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTn
# f+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxU
# jG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8j
# LfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDCCBq4w
# ggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4X
# DTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVk
# IEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5M
# om2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE
# 2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWN
# lCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFo
# bjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhN
# ef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3Vu
# JyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtz
# Q87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4O
# uGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5
# sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm
# 4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIz
# tM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6
# FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYB
# BQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# QQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZ
# MBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmO
# wJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H
# 6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/
# R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzv
# qLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/ae
# sXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdm
# kfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3
# EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh
# 3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA
# 3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8
# BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsf
# gPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwgga8MIIEpKADAgECAhALrma8
# Wrp/lYfG+ekE4zMEMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBH
# NCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAw
# WhcNMzUxMTI1MjM1OTU5WjBCMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNl
# cnQxIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ
# 46XB/QowIEMSvgjEdEZ3v4vrrTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4I
# Qmn7dHY7yijvoQ7ujm0u6yXF2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRv
# flJ9YeHjes4fduksTHulntq9WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2G
# ePfsMRhNf1F41nyEg5h7iOXv+vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf3
# 3rp9HlfqSBePejlYeEdU740GKQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BB
# FnV+KwPxRNUNK6lYk2y1WSKour4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8Wu
# lU2d6zhzXomJ2PleI9V2yfmfXSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/T
# BeSA2z4I78JpwGpTRHiT7yHqBiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPA
# GogmoiZ33c1HG93Vp6lJ415ERcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQ
# SgDpW9rtvVcIH7WvG9sqYup9j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1D
# hoQo5fkCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAA
# MBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNV
# HQ4EFgQUn1csA3cOKBWQZqVjXu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNI
# QTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5
# NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0e
# H3aZW+M4hBJH2UOR9hHbm04IHdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnC
# s+8GZl2uVYFvQe+pPTScVJeCZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60
# HofN6V51sMLMXNTLfhVqs+e8haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5
# OruCP1QUAvVSu4kqVOcJVozZR5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA7
# 5oBfFZSbdakHJe2BVDGIGVNVjOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9
# ZOUKzfRUAYSyyEmYtsnpltD/GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj
# 5TMHq8CWT/xrW7twipXTJ5/i5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuF
# ixUDobZaA0VhqAsMHOmaT3XThZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatS
# F+02kULkftARjsyEpHKsF7u5zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP
# 5M9WArHYSAR16gc0dP2XdkMEP5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XH
# Bx1yomzLP8lx4Q1zZKDyHcp4VQJLu2kWTsKsOqQxggTxMIIE7QIBATAsMBgxFjAU
# BgNVBAMMDUR1Y2tEZXYgVG9vbHMCEDaSd2hmb5qKSrDIVZqbmVAwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFKwE4cWaJKE4cwoUBnx8dPi3+sRfMA0GCSqGSIb3DQEBAQUABIIBAECP
# h4aJKpqBTvcpO+Tv2h5bY+eW+Z1ZpqIemPq+MJJA8X2nf6/BjT38/lbbdW9PE7Bl
# EJTktfRJ2cikyfKSybdxKhucVhQeiyOyB9pS+13UtuTXG7SCxJUko37aDpLP50R8
# ssRKTS0govF43H6QiDt9TnPO5xOHozhnQuuGUPLf5Hqr5McpaLh26m536C+lI8lE
# UA4x7BADl0e1+VUaEj/m81hdElDEgegMRBQDoClv2UEHNxmzMh98cGvvF19lflA7
# OSKbqToJQUOXYPNSMjzyNA4euMd93MZ9k47PvvQeeZrOCYXvnk9jLUt7KFMlhBi3
# n/rN49ZmWDLh9s37rOyhggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBAhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjUwNjI4MjM1OTUzWjAv
# BgkqhkiG9w0BCQQxIgQgjvPfjxyimR7QcGnIKh6Z1ZWq0Su3mSa0RFtte5HERhEw
# DQYJKoZIhvcNAQEBBQAEggIArBgdRypaSGn7Z3vx1JcUAW7nvoDMA5rhIUUfoeH4
# Xr2ZacUfpsed8UWh8xfrjM6w+83i5jOhb5UtX9w6/ArhEp4D4m3luQnvsug/D+vl
# z8P4r8qI2DMypH9VFY13ju51CNW/YEgPpQgQdSI46GwI9Fr0dxquXe3FD9tS8F8g
# tfWIP4GNeuFHD/nMaIU2rEDFY+tRjaE6HFtoiJBY/gfvZcUxg11Cq1VPIrLze7AC
# lNmkgeSyoslCh9JyKtjT4tm/eDZJQYYvOpqTyehFXpClGgWXhbmd97f9jLTuPJs3
# LbppJNdvj1TO0obEll7xHF/vcBlUfg0JFtMhvmMl/fHDFaDmyyN3qciw4DpE57Mg
# lPwwHLDZDbtkgHCCSlRd8C2Kzg2YqdAo61+3eNuYTsG0XnCogNiixBO6mCYNNNN1
# 2X0VAxu/bW6fS3Ioth2437PAvSqQmZ+jKCwUFqprHDrmKsoz/jUT7BDxInjsLOvx
# Ap17ODfdEigQkHI+C0rFr2tHg13XSWPh3NcGCGgyJ0nfHW1O9cT32dRGl7VpimrZ
# 0g7XmxOu09z/4kN4ZbzqTrGbdcpipQak4FNTmf+Mj7bVCT7hJAt4P9+YY4Z6lz47
# jDMZkFPFlA7lW06d2bonLc/I9NSQEY7u+ADT7bPOmcmCdTT3POd1YtJ2sSM++0Mn
# CB0=
# SIG # End signature block
