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
#============================================================================================#
#============================================================================================#
#============================================================================================#
#============================================================================================#
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
#============================================================================================#
#============================================================================================#
#============================================================================================#
#============================================================================================#
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
# SIG # Begin signature block
# MIIFfwYJKoZIhvcNAQcCoIIFcDCCBWwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAT1dyHbX8wF4ZtCBdTKUD1hd
# 8iugggMUMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQUdUjzJ7GuCjasmzkdxtBMVT7+Qj4wDQYJKoZIhvcNAQEBBQAE
# ggEALVYJnS5fzyxFsx/mjxQPi4IGvZLI4qPUKvLS5s2cq9EnxMQAgtMRb5G7MD+a
# j7mRCzpv72Nyf+yS6wPV55l1LAcgp7MBVtPAP96mpkfHffLD9AfWL/XcLID7KvX0
# eSxmPd06w7WSwXJZLkd8pOUqU02FI979YtQRwb7IEJHFR457lxejQm+Kku6Y4h/B
# L3FFaJzp8MBA9XHhmz5z02vseBef1ckCpQtMK1aiuOuOWqM04k3uG93mWGQH6uqC
# Nf4VucOWlsf8YXTMC2Km/dzQ1EPayp5f3yQa1bHoaqjAOe0lDHeTD7jBAnL0RFYn
# bsq67DmoLxTHabNXMtTt21hRnQ==
# SIG # End signature block
