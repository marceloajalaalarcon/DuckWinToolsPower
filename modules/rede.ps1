# Arquivo: modules/rede.ps1
# Descrição: Funções auxiliares para script principal.

# Função para fazer limpeza do ip, solicitar novo ip e limpa cache dns e reiniciar windows update

function RedeDebug{
    param(
        [Parameter(Mandatory=$true)]
        [string]$Comando,
        [Parameter(Mandatory=$true)]
        [string]$MensagemProgresso,
        [Parameter(Mandatory=$true)]
        [string]$MensagemSucesso,
        [Parameter(Mandatory=$false)]
        [boolean]$PausarAoFinal = $true
    )

    try{
        Write-Host "`n$MensagemProgresso" -ForegroundColor Yellow
        Invoke-Expression -Command $Comando
        Write-Host "`n✔️ $MensagemSucesso" -ForegroundColor Green
    }
    catch{
        Write-Host "`n❌ Ocorreu um erro ao executar o comando '$Comando'." -ForegroundColor Red
        Write-Host "Detalhes do erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally{
        if($PausarAoFinal){
            Read-Host "`nPressione Enter para continuar..." | Out-Null
        }
    }
}

function Rede{
    do{
        Clear-Host
        Write-Host "📅 MENU DE CONFIGURAÇÃO DE REDE" -ForegroundColor Cyan
        Write-Host "`n[1] 🌐 Renovar Configurações de Rede (Liberar, Renovar, Limpar DNS)" -ForegroundColor Yellow
        Write-Host "[2] 🔁 Reset de IP (Liberar e Renovar IP)" -ForegroundColor Yellow
        Write-Host "[3] 🧹 Limpar DNS (Limpar cache DNS)" -ForegroundColor Yellow
        Write-Host "[4] 📴 Desconectar IP (Liberar IP atual)" -ForegroundColor Yellow
        Write-Host "[5] 📶 Reconectar IP (Solicitar novo IP)" -ForegroundColor Yellow
        Write-Host "[0] ⬅️ Voltar ao menu principal" -ForegroundColor Gray

        $escolhaRede = Read-Host "`nEscolha uma opção"

        switch($escolhaRede){
            "1"{
                RedeDebug -Comando "ipconfig /release" -MensagemProgresso "Liberando IP atual..." -MensagemSucesso "IP Liberado." -PausarAoFinal $false
                RedeDebug -Comando "ipconfig /renew" -MensagemProgresso "Renovando concessão de IP..." -MensagemSucesso "IP Renovado." -PausarAoFinal $false
                RedeDebug -Comando "ipconfig /flushdns" -MensagemProgresso "Limpando cache DNS..." -MensagemSucesso "Cache DNS limpo." -PausarAoFinal $false

                Write-Host "`n✅ Feito!" -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            "2"{
                RedeDebug -Comando "ipconfig /release" -MensagemProgresso "Liberando IP atual..." -MensagemSucesso "IP Liberado." -PausarAoFinal $false
                RedeDebug -Comando "ipconfig /renew" -MensagemProgresso "Solicitando novo IP..." -MensagemSucesso "Reset de IP feito." -PausarAoFinal $false

                Write-Host "`n✅ Feito!" -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            "3"{
                RedeDebug -Comando "ipconfig /flushdns" -MensagemProgresso "Limpando cache DNS..." -MensagemSucesso "Cache DNS limpo." -PausarAoFinal $false
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            "4"{
                RedeDebug -Comando "ipconfig /release" -MensagemProgresso "Desconectar IP..." -MensagemSucesso "IP atual liberado." -PausarAoFinal $false
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            "5"{
                RedeDebu -Comando "ipconfig /renew" -MensagemProgresso "Reconectar IP..." -MensagemSucesso "IP renovado." -PausarAoFinal $false
                Read-Host "`nPressione Enter para continuar..." | Out-Null
            }
            "0"{
                Write-Host "`nSaindo do menu de rede..." -ForegroundColor Gray
            }
            Default{
                Write-Host "`n❌ Opção inválida. Tente novamente." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($escolhaRede -ne "0")
}

function ReiniciarUp{
    Clear-Host
    Write-Log "♻️  Redefinindo componentes do Windows Update..." -ForegroundColor Yellow
    $servicos = "wuauserv", "cryptSvc", "bits", "msiserver"

    $pastas = @(
        "$env:windir\SoftwareDistribution",
        "$env:windir\System32\catroot2"
    )

    try{
        Write-Log "Parando serviços do Windows Update..."
        Stop-Service -Name $servicos -Force -ErrorAction Stop

        Write-Log "Renomeando pastas de cache..."
        foreach ($pasta in $pastas) {
            if (Test-Path $pasta) {
                Rename-Item -Path $pasta -NewName "$($pasta).old" -Force -ErrorAction Stop
            }
        }

        Write-Log "Iniciando serviços do Windows Update..."
        Start-Service -Name $servicos -ErrorAction Stop
        Write-Log "`n✔️ Componentes do Windows Update redefinidos com sucesso." -ForegroundColor Green
    }catch {
        Write-Log "`n❌ Falha ao redefinir o Windows Update. Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "Pode ser necessário reiniciar o computador." -ForegroundColor Yellow
    }

    Read-Host "`nPressione ENTER para voltar ao menu"
}