# Arquivo: modules/network.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para fazer limpeza do ip, solicitar novo ip e limpa cache dns e reiniciar windows update
function Network-Rede-Debug {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Comando,

        [Parameter(Mandatory=$true)]
        [string]$MensagemSucesso,

        [Parameter(Mandatory=$true)]
        [string]$MensagemProgresso,
        
        [Parameter(Mandatory=$false)]
        [boolean]$PausarAoFinal = $true
    )

    try {
        Write-Host "`n$MensagemProgresso" -ForegroundColor Yellow
        
        # O comando Invoke-Expression executa uma string como se fosse um comando
        Invoke-Expression -Command $Comando

        Write-Host "`n✔️ $MensagemSucesso" -ForegroundColor Green
    }
    catch {
        Write-Host "`n❌ Ocorreu um erro ao executar o comando '$Comando'." -ForegroundColor Red
        Write-Host "   Detalhes do erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        # Uma pausa mais explícita para o usuário
        if($PausarAoFinal) {
            Read-Host '`nPressione Enter para continuar...' | Out-Null
        }
        
    }
}

function Network-Rede {
    
    # O loop do-until garante que o menu seja exibido pelo menos uma vez
    # e continue aparecendo até que a escolha seja '0'.
    do {
        Clear-Host
        Write-Host '📅 MENU DE CONFIGURAÇÃO DE REDE' -ForegroundColor Cyan
        Write-Host "`n[1] 🌐 Renovar Configurações de Rede (Liberar, Renovar, Limpar DNS)" -ForegroundColor Yellow
        Write-Host '[2] 🔁 Reset de IP (Liberar e Renovar IP)' -ForegroundColor Yellow
        Write-Host '[3] 🧹 Limpar DNS (Limpar cache DNS)' -ForegroundColor Yellow
        Write-Host '[4] 📴 Desconectar IP (Liberar IP atual)' -ForegroundColor Yellow
        Write-Host '[5] 📶 Reconectar IP (Solicitar novo IP)' -ForegroundColor Yellow
        Write-Host '[0] ⬅️ Voltar ao menu principal' -ForegroundColor Gray

        $escolhaREDE = Read-Host '`nEscolha uma opção'

        switch ($escolhaREDE) {
            '1' {
                # Executa cada comando sem pausar
                Diagnostico-Rede-Debug  -Comando "ipconfig /release" -MensagemProgresso 'Liberando IP atual...' -MensagemSucesso 'IP Liberado.' -PausarAoFinal $false
                Diagnostico-Rede-Debug  -Comando "ipconfig /renew" -MensagemProgresso 'Renovando concessão de IP...' -MensagemSucesso 'IP Renovado.' -PausarAoFinal $false
                Diagnostico-Rede-Debug  -Comando "ipconfig /flushdns" -MensagemProgresso 'Limpando cache DNS...' -MensagemSucesso 'Cache DNS limpo.' -PausarAoFinal $false
            
                # Adiciona uma mensagem final e uma única pausa
                Write-Host "`n✅ Feito!" -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            '2' {
                Diagnostico-Rede-Debug -Comando "ipconfig /release" -MensagemProgresso 'Liberando IP atual...' -MensagemSucesso 'IP Liberado.' -PausarAoFinal $false
                Diagnostico-Rede-Debug -Comando "ipconfig /renew" -MensagemProgresso 'Solicitando novo IP...' -MensagemSucesso 'Reset de IP feito.' -PausarAoFinal $false
                
                # Adiciona uma mensagem final e uma única pausa
                Write-Host "`n✅ Feito!" -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            '3' {
                Diagnostico-Rede-Debug -Comando "ipconfig /flushdns" -MensagemProgresso 'Limpando cache DNS...' -MensagemSucesso 'Cache DNS limpo.' -PausarAoFinal $false

                # Adiciona uma mensagem final e uma única pausa
                Read-Host '`nPressione Enter para continuar...' | Out-Null
            }
            '4' {
                Diagnostico-Rede-Debug -Comando "ipconfig /release" -MensagemProgresso 'Desconectar IP...' -MensagemSucesso 'IP atual liberado.' -PausarAoFinal $false
                
                # Adiciona uma mensagem final e uma única pausa
                Read-Host '`nPressione Enter para continuar...' | Out-Null
            }
            '5' {
                Diagnostico-Rede-Debug -Comando "ipconfig /renew" -MensagemProgresso 'Reconectar IP...' -MensagemSucesso 'IP renovado.' -PausarAoFinal $false
            
                # Adiciona uma mensagem final e uma única pausa
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            '0' {
                Write-Host "`nSaindo do menu de rede..." -ForegroundColor Gray
            }
            Default {
                Write-Host "`n❌ Opção inválida. Tente novamente." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($escolhaREDE -ne '0')
}
#============================================================================================#
#============================================================================================#
#============================================================================================#
#============================================================================================#
function Reiniciar-WU {
    Clear-Host
    Write-Log '♻️  Redefinindo componentes do Windows Update...' -ForegroundColor Yellow
    
    $servicos = 'wuauserv', 'cryptSvc', 'bits', 'msiserver'
    $pastas = @(
        "$env:windir\SoftwareDistribution",
        "$env:windir\System32\catroot2"
    )

    try {
        Write-Log 'Parando serviços do Windows Update...'
        Stop-Service -Name $servicos -Force -ErrorAction Stop

        Write-Log 'Renomeando pastas de cache...'
        foreach ($pasta in $pastas) {
            if (Test-Path $pasta) {
                Rename-Item -Path $pasta -NewName "$($pasta).old" -Force -ErrorAction Stop
            }
        }

        Write-Log 'Iniciando serviços do Windows Update...'
        Start-Service -Name $servicos -ErrorAction Stop

        Write-Log "`n✔️ Componentes do Windows Update redefinidos com sucesso." -ForegroundColor Green
    } catch {
        Write-Log "`n❌ Falha ao redefinir o Windows Update. Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "Pode ser necessário reiniciar o computador." -ForegroundColor Yellow
    }
    
    Read-Host "`nPressione ENTER para voltar ao menu"
}
# SIG # Begin signature block
# MIIFfwYJKoZIhvcNAQcCoIIFcDCCBWwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1YdQkKgj+ToeKShDqJSJO4Kk
# JIegggMUMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQU8aP5KNJeVcz6S5L/T4isM7d3hEcwDQYJKoZIhvcNAQEBBQAE
# ggEAaBVOFyfTvLs/NpCPlxnw64Re4hQyZY8iFVZQmCm4KMAemwMMd3EtDVVfTfZJ
# nRzn4MpN/863TuiWeW6rCTOHLMmhfHTio6ltqOud4OPu0DNn6AWyJnYFZrfiwX5z
# oehtX7N881waYQreBZCHNoovmKy/PXBqJn9eBEgVbGfSIMwG2rd6nJinQW3U3/FI
# RmyySFN9FtFm1RikBzjYeqvTkcrPg+H5VdKzSQTRUAIUzZsEjLLpZpZwdmXGBlYu
# h8qKZ30FO5/Zvvk3Dr/kXGzMAaHT1qyI+Qf5pOc8JRsikdOq1uHGh82ldyqigMpi
# ETQrw73rFONEnOT3+46NH5ikAg==
# SIG # End signature block
