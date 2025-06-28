#region Carregamento de Módulos Dinâmico
# ======================================================================================================================
# Esta seção carrega dinamicamente todas as funções listadas em um arquivo de manifesto (modules.json).
# Isso torna a adição de novos módulos muito mais fácil.
# ======================================================================================================================
Write-Host 'Iniciando carregamento dinâmico de módulos...' -ForegroundColor Cyan

# URL base para a pasta de módulos no seu GitHub.
# ❗ IMPORTANTE: Verifique se este é o URL correto do seu repositório! 
$baseUrl = 'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/modules/'

# URL completo para o arquivo de manifesto.
$manifestUrl = $baseUrl + 'modules.json'

try {
    Write-Host "=> Baixando o manifesto de módulos de: $manifestUrl"
    
    # 1. Baixa o conteúdo do manifesto e converte o texto JSON em um objeto PowerShell.
    $modulesToLoad = irm $manifestUrl

    Write-Host '=> Manifesto lido com sucesso. Carregando os seguintes módulos:' -ForegroundColor Green
    $modulesToLoad | ForEach-Object { Write-Host "   - $_" } # Lista os módulos que serão carregados

    # 2. Faz um loop em cada nome de arquivo retornado pelo manifesto.
    foreach ($moduleFile in $modulesToLoad) {
        $moduleUrl = $baseUrl + $moduleFile
        Write-Host "-> Carregando módulo: $moduleFile" -ForegroundColor Yellow
        
        # 3. Baixa e executa o script do módulo.
        irm $moduleUrl | iex
    }
    
    Write-Host '`n✔️ Todos os módulos foram carregados com sucesso!' -ForegroundColor Green
    Start-Sleep -Seconds 1

} catch {
    Write-Host '❌ Falha crítica durante o carregamento dinâmico dos módulos.' -ForegroundColor Red
    Write-Host 'Verifique sua conexão e se o arquivo "modules.json" existe e está acessível.'
    Write-Host "Erro: $($_.Exception.Message)"
    Read-Host 'Pressione ENTER para sair.'
    exit
}

# ======================================================================================================================
#  >>>>>>>>> INÍCIO DA SEÇÃO ADICIONADA <<<<<<<<<
# ======================================================================================================================

#region Lógica Principal de Execução

# Após carregar todos os módulos, o script entra no loop principal do menu interativo.
do {
    # A função Mostrar-Menu (que foi carregada de um dos seus módulos) exibe as opções.
    Mostrar-Menu
    $opcao = Read-Host "Escolha uma opção"

    # O switch direciona para a função correta com base na escolha do usuário.
    switch ($opcao) {
        "0" { 
            Write-Host "Saindo da ferramenta. Até mais!" -ForegroundColor Green
            exit 
        }
        "1" { Executar-SFC }
        "2" { Executar-DISM }
        "3" { Executar-CHKDSK }
        "4" { Executar-Limpeza }
        "5" { Verificar-SMART }
        "6" { Network-Rede } # Assumindo que o nome da função do menu de rede seja este
        "7" { Reiniciar-WU }
        "8" { Agendar-Tarefa }
        "9" { Limpar-FilaImpressao }
        default {
            Write-Log "`n❗ Opção inválida. Por favor, tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($true) # O loop continua indefinidamente até que a opção "0" chame 'exit'.

#endregion

#endregion
# SIG # Begin signature block
# MIIbjgYJKoZIhvcNAQcCoIIbfzCCG3sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9CPqJkMrpJ48ZjO/EfnYEfTe
# 1zOgghYHMIIDADCCAeigAwIBAgIQNpJ3aGZvmopKsMhVmpuZUDANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1EdWNrRGV2IFRvb2xzMB4XDTI1MDYyNzAyNTY0M1oX
# DTI2MDYyNzAzMTY0M1owGDEWMBQGA1UEAwwNRHVja0RldiBUb29sczCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBAKn4Kp9OE2fKY7IgOxgVryfIA2r9+xSj
# RrqgXPquezWZEFz/XWm1ULBTxf3Ij6JOYKcNb7xdjEceAWEOLnisQTd4DLsNum3N
# CBfWEiJwkwdSdwQ/imwNluRl6ouM5odNc9gimUpOj96bHoqKCzbw/AuEi5EKF/KU
# rHbYvKnSj+4aWRzgtFaqYXMhDNuxrGdTFVJUgbwRkSDH7Yk8PCQVzPLD9G8DekZf
# X/VMamAH5eU39Awg8RljBXYYyi/dlOrjkvO9wTt/eciqsMqdzC2rTjBJwovNnBTM
# i82cugjUQq0JeMewACStnH8uPbHhloVAaDDCM6o4gWcxgP3+Fg+nOVkCAwEAAaNG
# MEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQW
# BBRqedNOpH/kDJiAX69bLw20ATSysTANBgkqhkiG9w0BAQsFAAOCAQEApP7dLlux
# WBqwC1ZZSTR2yCWsTptUieXUP7zNuCS0zjU9aChbZS/zMBpsJ1Y93KhOW9yso7o+
# gRyJdOZrJWOyWsLeSEPcBMIl1PqvShv4QhcJ/fd0la5VlmXpeW2xvpZ+JaLqljm6
# xSXrxoA7sS5b7ixBmAGinqPUuZXswxVSsjxvQHUcDiRs1kQdRATZULPQ55viYCpd
# v0+i/rFZDDkUvHLy3ZVNIKfUEzt7hOOrDPhBjFdoLbcG3RDQ+E/xHLOIxLsxXFQm
# XgX5AkK3rvQGRlM/CAtnyHJVvckuOCzkcWBfmYNvre63g4oDGCAhJnpxQy9F8Bse
# I2ZVOAlcgTVG0TCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZI
# hvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNz
# dXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVow
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290
# IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjww
# IjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J5
# 8soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMH
# hOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6
# Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQ
# ecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4b
# A3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9
# WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCU
# tNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvo
# ZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/J
# vNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCP
# orF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMB
# Af8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXr
# oq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRt
# MGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEF
# BQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgw
# BgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cH
# vZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8
# UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTn
# f+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxU
# jG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8j
# LfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDCCBq4w
# ggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4X
# DTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVk
# IEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5M
# om2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE
# 2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWN
# lCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFo
# bjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhN
# ef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3Vu
# JyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtz
# Q87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4O
# uGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5
# sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm
# 4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIz
# tM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6
# FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYB
# BQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# QQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZ
# MBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmO
# wJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H
# 6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/
# R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzv
# qLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/ae
# sXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdm
# kfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3
# EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh
# 3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA
# 3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8
# BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsf
# gPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwgga8MIIEpKADAgECAhALrma8
# Wrp/lYfG+ekE4zMEMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBH
# NCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAw
# WhcNMzUxMTI1MjM1OTU5WjBCMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNl
# cnQxIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ
# 46XB/QowIEMSvgjEdEZ3v4vrrTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4I
# Qmn7dHY7yijvoQ7ujm0u6yXF2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRv
# flJ9YeHjes4fduksTHulntq9WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2G
# ePfsMRhNf1F41nyEg5h7iOXv+vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf3
# 3rp9HlfqSBePejlYeEdU740GKQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BB
# FnV+KwPxRNUNK6lYk2y1WSKour4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8Wu
# lU2d6zhzXomJ2PleI9V2yfmfXSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/T
# BeSA2z4I78JpwGpTRHiT7yHqBiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPA
# GogmoiZ33c1HG93Vp6lJ415ERcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQ
# SgDpW9rtvVcIH7WvG9sqYup9j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1D
# hoQo5fkCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAA
# MBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNV
# HQ4EFgQUn1csA3cOKBWQZqVjXu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNI
# QTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5
# NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0e
# H3aZW+M4hBJH2UOR9hHbm04IHdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnC
# s+8GZl2uVYFvQe+pPTScVJeCZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60
# HofN6V51sMLMXNTLfhVqs+e8haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5
# OruCP1QUAvVSu4kqVOcJVozZR5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA7
# 5oBfFZSbdakHJe2BVDGIGVNVjOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9
# ZOUKzfRUAYSyyEmYtsnpltD/GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj
# 5TMHq8CWT/xrW7twipXTJ5/i5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuF
# ixUDobZaA0VhqAsMHOmaT3XThZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatS
# F+02kULkftARjsyEpHKsF7u5zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP
# 5M9WArHYSAR16gc0dP2XdkMEP5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XH
# Bx1yomzLP8lx4Q1zZKDyHcp4VQJLu2kWTsKsOqQxggTxMIIE7QIBATAsMBgxFjAU
# BgNVBAMMDUR1Y2tEZXYgVG9vbHMCEDaSd2hmb5qKSrDIVZqbmVAwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFFBRC0PdtpdF+ilZzOdIeBw5Z5C+MA0GCSqGSIb3DQEBAQUABIIBADmN
# PUUllBxlAzZD9v2YrhsBHdayKnYqmrDEGRwx49ShcdCcYPLOk2OyFZzSNwaJykxX
# sbmdUb3Bj1F8RM9O5HQcTXYMPnO4kmOViXGVTMmbQ2dGeh68FQVEod3zZvf1QuNI
# 7irZVQ5X1PW8YFlPWJZSKd5ygLsm1i2+bWsMFpnCV67T1tAV9S8H5wO/wfWVvUBp
# iFWa/RzUYScKGQAhgml1dDn8yOIggRzPupF61/AMd+4lf6oHPrU6utwHLEmgYl0B
# CKj6NghobU2Ft/5WKamOoIob8cJ9lMpM8OQGVav2+hyRoKaNmGBJ3X+M4/9Pi5oo
# mMJpxhxodGV9XVY+mBehggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBAhALrma8Wrp/lYfG+ekE4zMEMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjUwNjI4MjM0MjIzWjAv
# BgkqhkiG9w0BCQQxIgQg3u0JA0EvTAoyX4dkMdvCcWL9hyPEc+fziGFHgbtPQEUw
# DQYJKoZIhvcNAQEBBQAEggIALkdxpfCSTW0GKsdKtlPZMKfCls4OWYLVcuwO3c2P
# daVMCmDxBADP8INag5/Ah9lttp7PPcH2Dq9Sbz+sdsj5D2w4ZrvsS64lXEbhI/jF
# RtOt9JxYW4iBDC2wbR1dgnhF5pc8ZFPV0gDKIPmZ0nZJJZ7DD1Z21DBngqDSPHUQ
# KkVW9WNkBCdEc7egA9c4b1kkE+r6HqnmBW9W0igXK3C/mE/OCdFhPa2O64p5iW7g
# 1DU05RfBmuEjpbBJyx+LDFKUTqthTOZnkKlK8Ux/uyFQE2/J50/NZIqXkgs94acQ
# uz0U7O5cF73DW0OC163upPlrmKgrtkepJMJyhgE/oE7q2+QsCyLJOz3ZbdN5UZIx
# edEuGai2/1qcY1wEco1bLlqUyktoVkr37QjdvY8Yr+rYr7/TzZuQoGr/q0C8C5oJ
# 9rR+IgkBCqgS06phPHuQZ+Sbjnmi8XYlfCt6MsznV7PkUyOcBdWSAFFFKNXSFzT+
# 4R4MXzY5Edw8ugF9Q2DIiakPjvfoJG1N9X1jiBdUsjuaisVVWk7cuB+xdbWaNXOl
# /5EOvb9TpvW2zG3rrat7nGXuGdnywMdtb6ZJTDHirtRTGomq6CUbmPyHg55b+CBh
# XMEC4OxQ+SxMMCVgPw+KdWv94ukdm1Gxd9US9CKlWl5AA16l2Gn2kD0noA+j6Rv2
# tKw=
# SIG # End signature block
