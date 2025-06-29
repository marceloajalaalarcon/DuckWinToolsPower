# Arquivo: modules/system.ps1
# Descrição: Funções de verificação e reparo do sistema (SFC, DISM).

function ExecutarSFC {
    Write-Log "Iniciando verificação SFC (Verificador de Arquivos do Sistema)..."
    Write-Log "Isso pode demorar vários minutos. Por favor, aguarde." -ForegroundColor Cyan
    
    $logPath = "$env:windir\Logs\CBS\CBS.log"
    Start-Process sfc -ArgumentList "/scannow" -Wait -Verb RunAs
    
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Log "✅ SFC: Nenhuma violação de integridade encontrada." -ForegroundColor Green
    } else {
        Write-Log "⚠️ SFC: Violações de integridade encontradas. Detalhes em $logPath" -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function ExecutarDISM {
    Write-Log "Iniciando reparo da imagem do sistema (DISM)..."
    Write-Log "Este processo pode ser demorado e parecer 'travado'. Tenha paciência." -ForegroundColor Cyan
    
    $dismArgs = "/Online /Cleanup-Image /RestoreHealth"
    Start-Process DISM.exe -ArgumentList $dismArgs -Wait -Verb RunAs
    
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Log "✅ DISM: Operação de reparo concluída com sucesso." -ForegroundColor Green
    } else {
        Write-Log "❌ DISM: Falha na operação de reparo. Verifique os logs." -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}