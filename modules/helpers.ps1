# Arquivo: modules/helpers.ps1
# Descrição: Funções auxiliares para o script principal.

# Função para registrar logs e exibir mensagens na tela.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$ForegroundColor = "White"
    )
    # Exibe a mensagem no console.
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Função para verificar a presença de antivírus de terceiros.
function VerificarAntivirus {
    try {
        # Procura por produtos antivírus que NÃO sejam o Windows Defender.
        $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
        
        # Se encontrar algum, exibe um alerta.
        if ($avList) {
            Write-Host
            Write-Host '🛡️ ALERTA: Antivírus de terceiro detectado!' -ForegroundColor White -BackgroundColor DarkRed
            Write-Host 'Ele pode interferir em algumas operações do script.' -ForegroundColor Yellow
            Write-Host "Antivírus encontrado: $($avList -join ', ')" -ForegroundColor Yellow
            Write-Host
            # Pausa para o usuário ler o alerta.
            Read-Host 'Pressione ENTER para continuar...'
        }
    }
    catch {
        # Ignora erros caso não consiga verificar (não é uma função crítica).
    }
}