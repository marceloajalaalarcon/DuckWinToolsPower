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
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            '4' {
                Diagnostico-Rede-Debug -Comando "ipconfig /release" -MensagemProgresso 'Desconectar IP...' -MensagemSucesso 'IP atual liberado.' -PausarAoFinal $false
                
                # Adiciona uma mensagem final e uma única pausa
                Read-Host "`nPressione Enter para continuar..." | Out-Null
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