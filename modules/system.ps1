# Arquivo: modules/system.ps1
# Descrição: Funções de verificação e reparo do sistema (SFC, DISM).
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function ExecutarSFC {
    Clear-Host
    Write-Log "Iniciando verificação SFC (Verificador de Arquivos do Sistema)..."
    Write-Log "Isso pode demorar vários minutos. Por favor, aguarde." -ForegroundColor Cyan
    
    sfc /scannow
    
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Log "✅ SFC: Nenhuma violação de integridade encontrada." -ForegroundColor Green
    } else {
        Write-Log "⚠️ SFC: Violações de integridade encontradas. Detalhes em $logPath" -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function ExecutarDISM {
    Clear-Host
    Write-Log "Iniciando reparo da imagem do sistema (DISM)..."
    Write-Log "Este processo pode ser demorado e parecer 'travado'. Tenha paciência." -ForegroundColor Cyan
    
    DISM /Online /Cleanup-Image /RestoreHealth
    
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Log "✅ DISM: Operação de reparo concluída com sucesso." -ForegroundColor Green
    } else {
        Write-Log "❌ DISM: Falha na operação de reparo. Verifique os logs." -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}