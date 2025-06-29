# Arquivo: modules/disk.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para executar o chkdsk, limpeza dos arquivos temp e verificação stmart do SSD/HD
function Executar-CHKDSK {
    Clear-Host
    Write-Log '💾 Agendando verificação de disco (CHKDSK)...' -ForegroundColor Yellow
    Write-Log 'O CHKDSK será executado na próxima vez que o computador for reiniciado.' -ForegroundColor Cyan

    try {
        # Usando a variável de ambiente para o disco do sistema.
        chkdsk.exe $env:SystemDrive /f /r
        Write-Log "`n✔️ CHKDSK agendado com sucesso para a unidade $env:SystemDrive." -ForegroundColor Green
        Write-Log "Reinicie o computador para iniciar a verificação." -ForegroundColor Yellow
    } catch {
        Write-Log "`n❌ Falha ao agendar o CHKDSK. Erro: $_" -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Executar-Limpeza {
    Clear-Host
    Write-Log '🧹 Limpando arquivos temporários...' -ForegroundColor Yellow
    
    # Lista de pastas a serem limpas.
    $pastas = @(
        [System.IO.Path]::GetTempPath(), # Pasta Temp do usuário atual
        "$env:windir\Temp"               # Pasta Temp do Windows
    )

    foreach ($pasta in $pastas) {
        if (Test-Path $pasta) {
            Write-Log "`n🗂️  Limpando: $pasta" -ForegroundColor Cyan
            try {
                # Pega os itens e os remove. O -ErrorAction SilentlyContinue ignora arquivos em uso.
                Get-ChildItem -Path $pasta -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Log "✔️  Limpeza de $pasta concluída." -ForegroundColor Green
            } catch {
                # Captura erros inesperados durante a limpeza.
                Write-Log "❌ Falha ao limpar '$pasta': $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Log "`n⚠️ Pasta não encontrada: $pasta" -ForegroundColor Yellow
        }
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}

function Verificar-SMART {
    Clear-Host
    Write-Log '🧪 Verificando status SMART dos discos...' -ForegroundColor Yellow
    try {
        # Usando Get-CimInstance, que é o comando moderno.
        $discos = Get-CimInstance -ClassName Win32_DiskDrive
        foreach ($disco in $discos) {
            Write-Host "`nModelo: $($disco.Model)"
            $status = switch ($disco.Status) {
                'OK' { Write-Host "Status: $($disco.Status)" -ForegroundColor Green }
                default { Write-Host "Status: $($disco.Status)" -ForegroundColor Red }
            }
        }
    } catch {
        Write-Log "`n❌ Não foi possível verificar o status SMART. Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}