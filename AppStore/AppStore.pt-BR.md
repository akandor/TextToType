# TextToType: App Store Connect metadata (Português (Brasil))

Brazilian Portuguese (pt-BR) localization of [AppStore.md](AppStore.md). In App Store Connect, pick **Português (Brasil)** from the language menu at the top right of the app page, then copy each field below.
Character limits are noted in brackets; every field below is within its limit. Fields that aren't localized (category, age rating, App Review notes, App Privacy answers) stay as they are in the English listing.

The wording uses "você", matching the app's Brazilian Portuguese UI and Apple's style.

---

## App Information

**Name** [30]
```
TextToType: Digita o Copiado
```

**Subtitle** [30]
```
Digita onde colar não funciona
```

**Privacy Policy URL**
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```

---

## Version

**Promotional text** [170]
```
Área de trabalho remota, VM ou um login que bloqueia colar? Basta um atalho e o TextToType digita sua área de transferência por você, tecla por tecla.
```

**Description** [4000]
```
O TextToType digita o texto da sua área de transferência em qualquer app, exatamente como se você estivesse digitando no teclado.

Alguns lugares simplesmente não deixam você colar: áreas de trabalho remotas, máquinas virtuais, sessões VNC e Citrix, consoles de servidor, instaladores e formulários web que bloqueiam colar senhas ou códigos. O TextToType resolve isso. Copie o texto, clique onde ele deve entrar e pressione seu atalho.

COMO FUNCIONA
• Copie qualquer texto.
• Clique na janela onde ele deve ser digitado.
• Pressione seu atalho (padrão: ⌃⌥⌘V) e o TextToType digita por você.
• Pressione o atalho novamente a qualquer momento para parar.

RECURSOS
• Funciona com qualquer sistema: por padrão, o TextToType envia cada caractere como texto Unicode, então o layout do teclado não importa. Para máquinas virtuais e consoles, ele também pode pressionar teclas reais, de acordo com o layout do seu Mac ou de um PC com Windows na Área de Trabalho Remota, incluindo caracteres AltGr como @.
• Seu próprio atalho: grave qualquer combinação de teclas global.
• Velocidade de digitação ajustável: mais lenta para sessões remotas que perdem caracteres, ou em velocidade máxima.
• Compatível com gerenciadores de senhas: se quiser, apaga da área de transferência as senhas copiadas assim que são digitadas.
• Discreto: o TextToType fica na barra de menus e não precisa de ícone no Dock.
• Abrir ao iniciar sessão: sempre pronto quando você precisar.
• No seu idioma: português (Brasil), inglês, alemão, francês, italiano e espanhol, à escolha nos ajustes.

PRIVACIDADE DESDE A CONCEPÇÃO
O TextToType só lê sua área de transferência quando você pressiona o atalho ou escolhe “Digitar Área de Transferência” no menu. Nada é salvo, registrado ou enviado para lugar nenhum, e o app não faz nenhuma conexão de rede.

GRATUITO E DE CÓDIGO ABERTO
O TextToType é de código aberto sob a licença MIT. Você pode ler cada linha de código, relatar problemas ou contribuir no GitHub: github.com/akandor/TextToType

PERMISSÃO
Para que o TextToType possa enviar toques de teclas a outros apps, o macOS pede uma única vez que você o permita em Ajustes do Sistema → Privacidade e Segurança → Acessibilidade. O TextToType usa essa permissão somente para digitar sua área de transferência quando você quiser.
```

**Keywords** [100]
```
colar,digitar,teclado,área de trabalho remota,vm,vnc,citrix,autotype,senha,atalho,console,ssh
```

**What's New in This Version** [4000]
```
Novo ajuste “Digitar para”: envie os caracteres como texto Unicode para qualquer sistema (padrão), como toques de teclas para o seu Mac, ou para um PC com Windows na Área de Trabalho Remota, onde caracteres como @ agora chegam corretamente.

O TextToType agora está disponível em português (Brasil), francês, italiano e espanhol, e você pode escolher o idioma do app nos ajustes.
```

**Support URL**
```
https://github.com/akandor/TextToType/issues
```

**Marketing URL**
```
https://github.com/akandor/TextToType
```

---

## Screenshots

Upload these to the Brazilian Portuguese localization. They're 2880 × 1800 (16:10), like the English ones, and show the app's Portuguese UI.

| File | Shows |
| --- | --- |
| `Screenshots/pt-BR/01-type-anywhere.png` | Hero image: menu bar menu (with Type for) and text being typed into a remote session |
| `Screenshots/pt-BR/02-settings.png` | Settings, Typing tab: Type for, typing speed, clipboard clearing |

The sources are `screenshot-src/*.pt-BR.html`. To re-render them, run this from the project folder:

```bash
for f in 01-type-anywhere 02-settings; do "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/pt-BR/$f.png" "file://$PWD/AppStore/screenshot-src/$f.pt-BR.html"; done
```
