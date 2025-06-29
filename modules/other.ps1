# Arquivo: modules/other.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para fazer agendar tarefa de limpeza do temp diaria e limpa fila da impressora
function Agendar-Tarefa {
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
#============================================================================================#
#============================================================================================#
#============================================================================================#
#============================================================================================#
function Limpar-FilaImpressao {
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
# SIG # Begin signature block
# MIIbpgYJKoZIhvcNAQcCoIIblzCCG5MCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQkBIh5GNFUci6Wvd/CqQiR0p
# ocmgghYXMIIDEDCCAfigAwIBAgIQXhD6PU/Nf7hCcH1wB8ecAjANBgkqhkiG9w0B
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
# V5uZYvL1VBFVIr+kMQGLNdo5lMqab+pjXSMwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMy
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcg
# Q0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXH
# JQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMf
# UBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w
# 1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRk
# tFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYb
# qMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUm
# cJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP6
# 5x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzK
# QtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo
# 80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjB
# Jgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXche
# MBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU
# 7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDig
# NqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd
# 4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiC
# qBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl
# /Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeC
# RK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYT
# gAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/
# a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37
# xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmL
# NriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0
# YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJ
# RyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIG
# vDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVowQjELMAkGA1UEBhMCVVMx
# ETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAg
# MjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5qc5/2lSGrljC6
# W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L660x5XltSVhhK64zi9Ce
# C9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLuslxdr9Qq82aKcpA9O//X6Q
# E+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7avVnpUVmPvkxT8c2a2yC0
# WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl7/r419CvEYVIrH6sN00y
# x49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+NBikDO0mlUh902wS/Eeh8
# F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVkiqLq+ISTdEjJKGjVfIcsg
# A4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5n10jxmGpxoMc6iPkoaDh
# i6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h6gYldp4FCMgrXdKWfM4N
# 0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNeREXAu2xUDEW8aqzFQDYm
# r9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLqfY/M/SdV6mwWTyeVy5Z/
# JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAE
# GTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3Mp
# dpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGalY17uT5IfdqBbMFoGA1Ud
# HwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRy
# dXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUF
# BwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# WAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZI
# hvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tOCB3RKE/P09x7gUsmXqt4
# 0ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSXgmUrDKNSQqGTdpjHsPy+
# LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPnvIWrqVogK0qM8gJhh/+q
# DEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM2UeUUW/8z3fvjxhN6hdT
# 98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlTVYzqfLDbe9PpBKDBfk+r
# abTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ/xll/HjO9JbNVekBv2Tg
# em+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef4uaZFORNekUgQHTqddms
# PCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk9104WQzYuVNsxyoVLObhx3
# RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7ucykW7eaCuWBsBb4HOKR
# FVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZDBD+XgbF+23/zBjeCtxz+
# dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3KeFUCS7tpFk7CrDqkMYIE
# +TCCBPUCAQEwNDAgMR4wHAYDVQQDDBVEdWNrRGV2LVRvb2xzLUNlcnQtVjMCEF4Q
# +j1PzX+4QnB9cAfHnAIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFG0suGleBgiESg3V0AIlM0ll
# jrH6MA0GCSqGSIb3DQEBAQUABIIBAH66W9g+fJ3VVHtqTDYJUW8vOuwfYFkD5wv/
# LNn/gZj209yIj9MKxcch3eY6GyNNg+YU312v9W21vfy4vptZ4FGRTtzgKfDETf/q
# C3a41kh/WwbKN6eVjf8hULmrGS5GdVi0qC2Qn4QdzQ++vYuoqHEdqjzpYX/3Rmhq
# FCKEvAct53FafcNKYpUm0gUgtil0WTF/9qaogYVzu0sgThFVMDm7V6l+Fo2kqvA6
# N/eUXT6O1NtoJcxLJJp9m6zbbuBvAlpzMweKUF1PVxZ8rmAcbkS5/Uj7OGVeRD/Z
# hdZUCpUTKOVmwLnwb1WXzDJXGfVLyoJymhKGyrmnipCsvghn01mhggMgMIIDHAYJ
# KoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNB
# NDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhALrma8Wrp/lYfG+ekE4zMEMA0G
# CWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
# 9w0BCQUxDxcNMjUwNjI5MDM1NTUwWjAvBgkqhkiG9w0BCQQxIgQgNg9wm4SRJgBP
# CT2tZzBwj2HJHlj5AvUp7e2Eyp2t5XYwDQYJKoZIhvcNAQEBBQAEggIAWTvTeW55
# /DaS+fpTfoiifrMuulwt3MDpKDXpZ7/KsoSiaV0/gGnVKnzW7JGXaVJr/AJvdmDj
# aphIqlHgp6p8xO+jVNeU54ZqV/sTZvu8Ib/27HzQlAXkG/AxwCDWYbIKkXrCQfZI
# b4J6Na9rau6pAGuRUBe13uONYIw5pcYCWcSBazQTQ/9MztT2woohtqcnTJwu0ZCy
# pDj4yGnvOYZKsDccs88s2q8Ue4EYnMtTExZeiSOA8Mv/BX2DL1IIDsyQnWF221ZV
# o/B7aoftSO2uOuKG1TlVVPp2EcLKPzC2Gnpwt+hl/hKEVvruXKzCg/ADibPXSH9J
# +L07OYVdLFTNqHJPra1HdTdLCIg5VNwuX7h6lC3s2deBOwZzOzmVEQ3w/TTCM0J7
# AH1VjL8dMfhXElUQRuORa1oI1W38rFJaM6ygfwRIYK+giLwvyq7vdMtBd4/OwJv4
# bh6V/NjXU8mgH5v3np2nVKvu4qA+2Z5gpclakWqeBKiS5g3HPDEMHrudAMC7kJ/Q
# YOyJJeogzCM5bkBPuBqYKbrxvHepZNcFkb2chPa211Dk8zFwBFmvHgkMmI1jLivO
# VNQWZqlKzwl57YFnbDo4ZYyIRFsl/qarhUkOXsRPkHC2Zbg2rbDHMCKlcjhseNrZ
# 8J72HGXie1y1gC6CqbvhcYFDhj7LGX7rCdY=
# SIG # End signature block
