# Arquivo: modules/system.ps1
# Descrição: Funções de verificação e reparo do sistema (SFC, DISM).

function Executar-SFC {
    Clear-Host
    Write-Log '🔍 Executando verificação de arquivos do sistema (SFC)...' -ForegroundColor Yellow
    Write-Log 'Este processo pode demorar alguns minutos. Por favor, aguarde.'
    Write-Log '------------------------------------------------------------'
    
    # --- MUDANÇA AQUI ---
    # Executamos o sfc.exe diretamente para que a saída apareça na janela atual.
    sfc.exe /scannow
    
    # Capturamos o código de saída com a variável automática $LASTEXITCODE.
    $exitCode = $LASTEXITCODE
    # --------------------

    Write-Log '------------------------------------------------------------'
    if ($exitCode -eq 0) {
        Write-Log "`n✔️ Verificação SFC concluída com sucesso." -ForegroundColor Green
    } else {
        Write-Log "`n❌ Ocorreu um erro durante a execução do SFC. Código de saída: $exitCode" -ForegroundColor Red
        Write-Log "Consulte o log em C:\Windows\Logs\CBS\CBS.log para mais detalhes." -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}
#============================================================================================#
#============================================================================================#
#============================================================================================#
#============================================================================================#
function Executar-DISM {
    Clear-Host
    Write-Log '🛠️  Executando reparo da imagem do sistema (DISM)...' -ForegroundColor Yellow
    Write-Log 'Este processo pode demorar bastante e requer conexão com a internet. Por favor, aguarde.'
    Write-Log "Durante o uso do DISM, é normal que a porcentagem pare por um tempo em certos pontos.`nIsso não significa que travou — o processo ainda está em andamento.`nBasta aguardar a conclusão com paciência." -ForegroundColor Yellow
    Write-Log '--------------------------------------------------------------------------------'

    # --- MUDANÇA AQUI ---
    # Executamos o DISM.exe diretamente.
    DISM.exe /Online /Cleanup-Image /RestoreHealth
    
    # Capturamos o código de saída.
    $exitCode = $LASTEXITCODE
    # --------------------

    Write-Log '--------------------------------------------------------------------------------'
    if ($exitCode -eq 0) {
        Write-Log '`n✔️ Reparo da imagem DISM concluído com sucesso.' -ForegroundColor Green
    } else {
        Write-Log "`n❌ Ocorreu um erro durante a execução do DISM. Código de saída: $exitCode" -ForegroundColor Red
        Write-Log 'Consulte o log em C:\Windows\Logs\DISM\dism.log para mais detalhes.' -ForegroundColor Yellow
    }
    Read-Host "`nPressione ENTER para voltar ao menu"
}
# SIG # Begin signature block
# MIIFfwYJKoZIhvcNAQcCoIIFcDCCBWwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtGuC+crXWWKLW11BqRzZTkHM
# sWOgggMUMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQUSHXLP0uDm1t59iQ/actCFBlpct8wDQYJKoZIhvcNAQEBBQAE
# ggEAPxS3xLOBf6YFKxpEY/k8ZrP8m/hk2Q5bKQzMSmyhzgE2Eg8tqC/YCHjx19w+
# LXGkQKdS7MtbGoS1vYVHmlX4ljbuuC0iv6VcwfXu/U0RLctV/q0IBNXDpGOBYcCz
# EkuH2BgHDbXPoad7ib90umLvY2Q+w8VXijufImobtqr1+IyXWGOn5GJ/SngHX1Y3
# ayJlb3rSkUKaoID8gYT5dbLbClSl9TaqvEDIbtOrc/05byt314VrnQqKyw7CN99H
# OYskLvF5BaVSNgUIZqGNL09CEjNcT6XCJp/7/aeDZCkue08hQfAK8cxqO5GFaP1R
# aK3sMgiAm8mHNwVgpQDdMsM6fA==
# SIG # End signature block
