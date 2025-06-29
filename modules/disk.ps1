# Arquivo: modules/disk.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para executar o chkdsk, limpeza dos arquivos temp e verificação stmart do SSD/HD
function ExecutarCHKDSK {
    Clear-Host
    Write-Log "Agendando verificação de disco (CHKDSK)..." -ForegroundColor Yellow
    Write-Log "A verificação será realizada na próxima vez que você reiniciar o computador."
    
    chkdsk C: /f /r /x
    
    Write-Log "Comando enviado. Por favor, reinicie o sistema para iniciar a verificação."
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function ExecutarLimpeza {
    Clear-Host
    Write-Log "Iniciando Limpeza de Disco..." -ForegroundColor Cyan
    $totalLiberado = 0
    
    $tempPaths = @(
        "$env:TEMP",
        "$env:windir\Temp",
        "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache"
    )

    try {
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                $files = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                if ($files) {
                    $tamanhoAntes = ($files | Measure-Object -Property Length -Sum).Sum
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    $totalLiberado += $tamanhoAntes
                }
            }
        }
        
        # Limpar cache de downloads do Windows Update
        $wuDownloadPath = "$env:windir\SoftwareDistribution\Download"
        if (Test-Path $wuDownloadPath) {
            $files = Get-ChildItem -Path $wuDownloadPath -Recurse -Force -ErrorAction SilentlyContinue
            if ($files) {
                $tamanhoAntes = ($files | Measure-Object -Property Length -Sum).Sum
                Remove-Item -Path $wuDownloadPath -Recurse -Force -ErrorAction SilentlyContinue
                $totalLiberado += $tamanhoAntes
            }
        }

        if ($?) {
            $totalMB = [math]::Round($totalLiberado / 1MB, 2)
            Write-Log "✅ Limpeza concluída com sucesso. Espaço liberado: $totalMB MB" -ForegroundColor Green
        } else {
            Write-Log "❌ Ocorreu um erro durante a limpeza." -ForegroundColor Red
        }
    }
    catch {
        Write-Log "❌ ERRO CRÍTICO DURANTE A LIMPEZA: $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function VerificarSMART {
    Clear-Host
    Write-Log "Verificando status SMART dos discos..."
    try {
        $disks = Get-PhysicalDisk -ErrorAction Stop
        
        foreach ($disk in $disks) {
            $status = $disk.HealthStatus
            $cor = if ($status -eq 'Healthy') { 'Green' } else { 'Red' }
            Write-Log "Disco $($disk.DeviceID) ($($disk.FriendlyName)): $status" -ForegroundColor $cor
        }
    }
    catch {
        Write-Log "❌ Não foi possível obter o status SMART. O comando Get-PhysicalDisk pode não ser suportado ou requer privilégios elevados." -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}