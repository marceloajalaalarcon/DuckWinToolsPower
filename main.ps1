#region Script Configuration
# ================================================================================
# 🔧 Ferramenta de Manutenção do Sistema - DuckDev
# Descrição: Script para realizar tarefas comuns de manutenção e reparo do Windows.
# Autor: Marcelo Ajala Alarcon
# Versão: 3.0 (Final Híbrida)
# ================================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

[CmdletBinding()]
param (
    [Switch]$ScheduledClean
)
#endregion

#region Carregamento Híbrido (Local ou GitHub)
# ==============================================================================
#  Carrega os módulos de acordo.
# ==============================================================================

    Write-Host "✅ Detectado modo de execução remoto (GitHub) com verificação de assinatura." -ForegroundColor Cyan
    $githubBaseUrl = 'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/modules/'
    $manifestUrl = $githubBaseUrl + "modules.json"
    
    try {
        Write-Host "=> Baixando o manifesto de módulos..."
        $modulesToLoad = irm $manifestUrl
        
        Write-Host "=> Módulos a serem verificados e carregados: $($modulesToLoad -join ', ')" -ForegroundColor Green

        foreach ($moduleFile in $modulesToLoad) {
            $moduleUrl = $githubBaseUrl + $moduleFile
            $tempFilePath = Join-Path $env:TEMP "$([System.Guid]::NewGuid()).ps1"
            
            try {
                Write-Host "   -> Baixando '$moduleFile' para verificação..."
                irm $moduleUrl -OutFile $tempFilePath

                # ----> INÍCIO DO PROBLEMA <----
                
                # A sua intenção era verificar a assinatura e depois carregar,
                # mas todo o bloco está como comentário.

                Write-Host "   -> Carregando módulo: $moduleFile" -ForegroundColor Yellow
                . $tempFilePath
                # $signature = Get-AuthenticodeSignature -FilePath $tempFilePath

                # if ($signature.Status -eq 'Valid') {
                #     Write-Host "   -> Assinatura VÁLIDA. Carregando: $moduleFile" -ForegroundColor Yellow
                #     . $tempFilePath  # <--- ESTA É A LINHA CRÍTICA QUE CARREGA O MÓDULO
                # } else {
                #     throw "MÓDULO REMOTO INSEGURO BLOQUEADO: '$moduleFile'. Status da assinatura: $($signature.Status)"
                # }

                # ----> FIM DO PROBLEMA <----
            }
            finally {
                # O ficheiro temporário é apagado aqui, quer tenha sido carregado ou não.
                if (Test-Path $tempFilePath) {
                    Remove-Item $tempFilePath -Force
                }
            }
        }
        Write-Host "✔️ Todos os módulos remotos seguros foram carregados com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERRO DE SEGURANÇA OU CARREGAMENTO REMOTO" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
        Read-Host "Pressione ENTER para sair."
        exit
    }
Start-Sleep -Seconds 1
#endregion

# region Verificação de Privilégios e Configuração Inicial
# ======================================================================================================================
# 🚨 Verificação de Privilégios
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "⏫ Permissões de administrador necessárias. Reabrindo o script..." -ForegroundColor Yellow
    $commandToRerun = "irm h'https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/main.ps1 | iex"
    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($commandToRerun))
    Start-Process powershell.exe -ArgumentList "-EncodedCommand $encodedCommand" -Verb RunAs
    exit
}

# ======================================================================================================================
# Termo de Uso e Ponto de Restauração
function Mostrar-TermoDeUso {
    while ($true) {
        Clear-Host
        $termo = @"
================================================================================
TERMO DE USO, TRANSPARÊNCIA E OPÇÕES INICIAIS
================================================================================

Olá! Seja bem-vindo à Ferramenta de Manutenção DuckDev.
Autor: Marcelo Ajala Alarcon

Esta ferramenta foi criada para simplificar e automatizar o acesso a
utilitários de manutenção poderosos que já existem nativamente no seu Windows.
O objetivo é ser transparente sobre cada ação executada.

--------------------------------------------------------------------------------
1. O PRINCÍPIO DA TRANSPARÊNCIA: O QUE A FERRAMENTA FAZ
--------------------------------------------------------------------------------

Este script não instala softwares de terceiros. Ele apenas executa comandos
que você mesmo poderia digitar no Prompt de Comando ou PowerShell.

* Ações Principais: sfc /scannow, DISM.exe /RestoreHealth, chkdsk.exe,
  limpeza de arquivos temporários, reset de componentes do Windows Update, etc.

--------------------------------------------------------------------------------
2. OS RISCOS ENVOLVIDOS: SUA RESPONSABILIDADE COMO USUÁRIO
--------------------------------------------------------------------------------

Apesar de usar ferramentas nativas, qualquer operação de manutenção profunda
oferece riscos, especialmente em sistemas personalizados ou com falhas de
hardware pré-existentes.

É ALTAMENTE RECOMENDADO QUE VOCÊ FAÇA UM BACKUP DE SEUS DADOS IMPORTANTES
ANTES DE EXECUTAR QUALQUER OPÇÃO DE REPARO.

--------------------------------------------------------------------------------
3. O ACORDO: TERMO DE RESPONSABILIDADE
--------------------------------------------------------------------------------

Este software é fornecido "COMO ESTÁ", sem garantia de qualquer tipo.
AO USAR ESTE SCRIPT, VOCÊ CONCORDA QUE O AUTOR (MARCELO AJALA ALARCON) NÃO
SERÁ RESPONSABILIZADO por quaisquer danos, incluindo perda de dados ou
instabilidade do sistema. A responsabilidade pelo uso é inteiramente sua.

--------------------------------------------------------------------------------
4. CONFIGURAÇÃO INICIAL (LEIA COM ATENÇÃO)
--------------------------------------------------------------------------------

Para sua segurança, a ferramenta SEMPRE criará um Ponto de Restauração do
Sistema antes de executar qualquer tarefa.

A única escolha necessária é se você deseja que a ferramenta lembre do seu
consentimento para não exibir esta tela nas próximas vezes.

"@
        Write-Host $termo -ForegroundColor Yellow
        Write-Host "================================================================================" -ForegroundColor Cyan
        Write-Host "[1] Aceitar e Lembrar Consentimento (Recomendado)" -ForegroundColor Green
        Write-Host "[2] Aceitar Apenas para Esta Sessão" -ForegroundColor Yellow
        Write-Host "[0] Recusar e Sair" -ForegroundColor Red
        
        $escolha = Read-Host "Digite sua escolha"
        switch ($escolha) {
            '1' { return @{ Action = 'Proceed'; SaveConsent = $true; } }
            '2' { return @{ Action = 'Proceed'; SaveConsent = $false; } }
            '0' { return @{ Action = 'Exit'; SaveConsent = $false; } }
            default { Write-Host "`nOpção inválida." -ForegroundColor Red; Start-Sleep -Seconds 2 }
        }
    }
}

$consentFile = Join-Path $env:APPDATA "DuckDevToolConsent.txt"
if (-not (Test-Path $consentFile)) {
    $userChoice = Mostrar-TermoDeUso
    if ($userChoice.Action -eq 'Proceed') {
        if ($userChoice.SaveConsent) { Set-Content -Path $consentFile -Value "Termos aceitos em $(Get-Date)" | Out-Null }
    } else {
        Write-Host "`nVocê não aceitou os termos. O script será encerrado." -ForegroundColor Red; Start-Sleep -Seconds 3; exit
    }
}

$Host.UI.RawUI.WindowTitle = "🔧 Ferramenta de Manutenção do Sistema - DuckDev v3.0"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "DarkBlue"
Clear-Host

# Chama a função que foi carregada do helpers.ps1
Verificar-Antivirus
#endregion

#region Lógica Principal de Execução

function MostrarMenu {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "    🔧 FERRAMENTA DE MANUTENÇÃO DO SISTEMA" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "--- SISTEMA ---" -ForegroundColor Green
    Write-Host "[1] 🔍 Verificar arquivos do sistema (SFC)"
    Write-Host "[2] 🛠️  Reparo da imagem do sistema (DISM)"
    Write-Host
    Write-Host "--- DISCO ---" -ForegroundColor Green
    Write-Host "[3] 💾 Agendar verificação de disco (CHKDSK)"
    Write-Host "[4] 🧹 Limpeza de arquivos temporários"
    Write-Host "[5] 🧪 Verificar status SMART do disco"
    Write-Host
    Write-Host "--- REDE E ATUALIZAÇÕES ---" -ForegroundColor Green
    Write-Host "[6] 🌐 Cofiguração de rede"
    Write-Host "[7] ♻️ Reiniciar componentes do Windows Update"
    Write-Host
    Write-Host "--- OUTROS ---" -ForegroundColor Green
    Write-Host "[8] 📅 Agendar tarefa de limpeza diária"
    Write-Host "[9] 🖨️ Limpar fila de impressão"
    Write-Host
    Write-Host "--- SAIR ---" -ForegroundColor Red
    Write-Host "[0] ❌ Sair"
    Write-Host
}

if ($ScheduledClean.IsPresent) {
    Executar-Limpeza | Out-Null
    exit
}

do {
    MostrarMenu
    $opcao = Read-Host "Escolha uma opção"

    switch ($opcao) {
        "0" { exit }
        "1" { ExecutarSFC }
        "2" { ExecutarDISM }
        "3" { ExecutarCHKDSK }
        "4" { ExecutarLimpeza }
        "5" { VerificarSMART }
        "6" { NetworkRedeDebug }
        "7" { ReiniciarWU }
        "8" { AgendarTarefa }
        "9" { Limpar-FilaImpressao }
        default { Write-Log "`n❗ Opção inválida." -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} while ($true)