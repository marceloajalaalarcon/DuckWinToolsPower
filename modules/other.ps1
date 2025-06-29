# Arquivo: modules/other.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para fazer agendar tarefa de limpeza do temp diaria e limpa fila da impressora
function AgendarTarefa {
    Clear-Host
    Write-Host '📅 MENU DE AGENDAMENTO DE TAREFAS' -ForegroundColor Cyan
    Write-Host "`n[1] Agendar limpeza diária do TEMP às 04:00"
    Write-Host '[0] Voltar ao menu principal'
    $escolha = Read-Host "`nEscolha uma opção"

    switch ($escolha) {
        '1' {
            $pastaAgendada = "C:\Agendati"
            if (-not (Test-Path $pastaAgendada)) {
                New-Item -Path $pastaAgendada -ItemType Directory | Out-Null
            }

            $scriptLimpeza = @'
            `$pastas = @(
                `"`$env:TEMP`",
                `"`$env:windir\Temp`"
            )
            foreach (`$pasta in `$pastas) {
                try {
                    Get-ChildItem -Path `$pasta -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                } catch {}
            }
'@

            $scriptPath = "$pastaAgendada\limpeza.ps1"
            Set-Content -Path $scriptPath -Value $scriptLimpeza -Encoding UTF8

            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `'$scriptPath`""
            $trigger = New-ScheduledTaskTrigger -Daily -At 4:00AM
            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
            $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

            Register-ScheduledTask -TaskName "Limpeza_TEMP_Diaria" -InputObject $task -Force

            Write-Host "`n✔️  Tarefa agendada com sucesso! Será executada todos os dias às 04:00." -ForegroundColor Green
            Pause
}
        '0' { return }
        Default {
            Write-Host "`n❌ Opção inválida. Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 2
            Agendar-Tarefa
        }
    }
}

function LimparFilaImpressao {
    [CmdletBinding()]
    param(
        [string] $PrinterName  # opcional, se quiser focar em só uma impressora
    )
    try {
        Write-Host '🖨️  Parando serviço de impressão...' -ForegroundColor Yellow
        Stop-Service Spooler -Force

        Write-Host '🔪 Matando processos remanescentes...' -ForegroundColor Yellow
        Get-Process spoolsv -ErrorAction SilentlyContinue | Stop-Process -Force

        Write-Host '🗑️  Limpando arquivos de spool...' -ForegroundColor Yellow
        Remove-Item -Path "$env:WINDIR\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue

        if ($PrinterName) {
            Write-Host '❌ Removendo driver da impressora $PrinterName...' -ForegroundColor Yellow
            # Remove-Printer só existe no Windows 8+/Server 2012+
            Remove-Printer -Name $PrinterName -ErrorAction SilentlyContinue
            # (re)instalar driver pode ser feito aqui se você tiver o INF disponível:
            # Add-Printer -Name $PrinterName -DriverName 'NomeDoDriver' -PortName 'PORTA'
        }

        Write-Host '▶️  Reiniciando serviço de impressão...' -ForegroundColor Yellow
        Start-Service Spooler

        Write-Host '✅ Spooler resetado.' -ForegroundColor Green
    } catch {
        Write-Error '❌ Falha ao resetar spooler'
    }
    Pause
}