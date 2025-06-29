# Arquivo: modules/system.ps1
# Descrição: Funções de verificação e reparo do sistema (SFC, DISM).

function Executar-SFC {
    Clear-Host
    Write-Log '🔍 Executando verificação de arquivos do sistema (SFC)...' -ForegroundColor Yellow
    Write-Log 'Este processo pode demorar alguns minutos. Por favor, aguarde.'
    Write-Log '------------------------------------------------------------'
    
    # Executamos o sfc.exe diretamente para que a saída apareça na janela atual.
    sfc.exe /scannow
    
    # Capturamos o código de saída com a variável automática $LASTEXITCODE.
    $exitCode = $LASTEXITCODE

    Write-Log "------------------------------------------------------------"
    if ($exitCode -eq 0) {
        Write-Log "`n✔️ Verificação SFC concluída com sucesso." -ForegroundColor Green
    } else {
        Write-Log "`n❌ Ocorreu um erro durante a execução do SFC. Código de saída: $exitCode" -ForegroundColor Red
        Write-Log 'Consulte o log em C:\Windows\Logs\CBS\CBS.log para mais detalhes.' -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Executar-DISM {
    Clear-Host
    Write-Log '🛠️  Executando reparo da imagem do sistema (DISM)...' -ForegroundColor Yellow
    Write-Log 'Este processo pode demorar bastante e requer conexão com a internet. Por favor, aguarde.'
    Write-Log "Durante o uso do DISM, é normal que a porcentagem pare por um tempo em certos pontos.`nIsso não significa que travou — o processo ainda está em andamento.`nBasta aguardar a conclusão com paciência." -ForegroundColor Yellow
    Write-Log '--------------------------------------------------------------------------------'

    # Executamos o DISM.exe diretamente.
    DISM.exe /Online /Cleanup-Image /RestoreHealth
    
    # Capturamos o código de saída.
    $exitCode = $LASTEXITCODE

    Write-Log '--------------------------------------------------------------------------------'
    if ($exitCode -eq 0) {
        Write-Log "`n✔️ Reparo da imagem DISM concluído com sucesso." -ForegroundColor Green
    } else {
        Write-Log "`n❌ Ocorreu um erro durante a execução do DISM. Código de saída: $exitCode" -ForegroundColor Red
        Write-Log 'Consulte o log em C:\Windows\Logs\DISM\dism.log para mais detalhes.' -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}