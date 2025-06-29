# 🦆 DuckDev - Ferramenta de Manutenção do Sistema v2.0

**Autor:** Marcelo Ajala Alarcon

Seu canivete suíço em PowerShell para diagnosticar, reparar e otimizar o sistema operacional Windows de forma simples e transparente.

## O que é o DuckWinTools?

O **DuckWinTools** (ou Ferramenta DuckDev) é um poderoso script PowerShell que centraliza as ferramentas de manutenção mais importantes e nativas do Windows em uma interface de menu interativa e fácil de usar. Criado com foco em transparência, o script não instala software de terceiros, apenas executa comandos essenciais como `sfc`, `DISM` e `chkdsk` de maneira guiada e segura.

O objetivo é dar a técnicos e usuários domésticos o poder de resolver problemas comuns do sistema sem a necessidade de decorar comandos complexos, sempre com avisos claros e a criação de um ponto de restauração para maior segurança.

## ✨ Principais Funcionalidades

* **Interface de Menu Intuitiva:** Navegue facilmente por todas as opções.
* **Verificação de Permissões:** O script solicita elevação para administrador automaticamente.
* **Termo de Uso e Transparência:** Explica cada ação e seus riscos antes do uso.
* **Alerta de Antivírus:** Verifica se softwares de terceiros podem interferir nas operações.
* **Reparo do Sistema:**
    * 🔍 **SFC:** Verifica a integridade dos arquivos de sistema (`sfc /scannow`).
    * 🛠️ **DISM:** Repara a imagem do Windows (`DISM /Online /Cleanup-Image /RestoreHealth`).
* **Manutenção de Disco:**
    * 💾 **CHKDSK:** Agenda uma verificação completa do disco na reinicialização.
    * 🧹 **Limpeza de Arquivos:** Remove arquivos temporários do sistema e do usuário.
    * 🧪 **Status SMART:** Verifica a saúde dos discos rígidos e SSDs.
* **Rede e Atualizações:**
    * 🌐 **Configuração de Rede:** Libera, renova e limpa o cache DNS.
    * ♻️ **Reset do Windows Update:** Redefine os componentes do Windows Update para corrigir falhas.
* **Outras Ferramentas:**
    * 🖨️ **Limpeza da Fila de Impressão:** Força a limpeza do spooler de impressão.
    * 📅 **Agendador de Tarefas:** Permite agendar uma limpeza diária automática do sistema.

## 🚀 Como Usar

Para executar a ferramenta, você só precisa de uma conexão com a internet e do Windows PowerShell.

1.  Abra o **PowerShell** (pode ser como usuário normal, o script pedirá elevação).
2.  Copie e cole o seguinte comando e pressione Enter:

    ```powershell
    irm https://duckurl.vercel.app/nGCd3W | iex
    ```
    ou o link direto:
    ```powershell
    irm https://raw.githubusercontent.com/marceloajalaalarcon/DuckWinToolsPower/refs/heads/main/main.ps1 | iex
    ```

## ⚠️ Aviso Importante

- Foi usado um encurtador de link para referenciar melhor, caso queria use o link direto.
- Este software é fornecido "COMO ESTÁ". Embora utilize ferramentas nativas do Windows, operações de manutenção profundas sempre envolvem riscos. **É altamente recomendável fazer um backup de seus dados importantes antes de usar as opções de reparo.** O uso da ferramenta é de sua inteira responsabilidade.