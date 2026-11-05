# TextToType: App Store Connect metadata (Italiano)

Italian (it-IT) localization of [AppStore.md](AppStore.md). In App Store Connect, pick **Italiano** from the language menu at the top right of the app page, then copy each field below.
Character limits are noted in brackets; every field below is within its limit. Fields that aren't localized (category, age rating, App Review notes, App Privacy answers) stay as they are in the English listing.

The wording uses the informal "tu", matching the app's Italian UI and Apple's Italian style.

---

## App Information

**Name** [30]
```
TextToType: Digita appunti
```

**Subtitle** [30]
```
Digita dove incollare non va
```

**Privacy Policy URL**
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```

---

## Version

**Promotional text** [170]
```
Desktop remoto, VM o un login che blocca l’incolla? Basta una scorciatoia e TextToType digita i tuoi appunti al posto tuo, tasto dopo tasto.
```

**Description** [4000]
```
TextToType digita il testo dei tuoi appunti in qualsiasi app, esattamente come se lo stessi scrivendo tu sulla tastiera.

Alcuni posti semplicemente non ti lasciano incollare: desktop remoti, macchine virtuali, sessioni VNC e Citrix, console di server, programmi di installazione e moduli web che bloccano l’incolla di password o codici. TextToType aggira il problema. Copia il testo, fai clic dove deve andare e premi la tua scorciatoia.

COME FUNZIONA
• Copia un testo qualsiasi.
• Fai clic nella finestra in cui deve essere digitato.
• Premi la tua scorciatoia (predefinita: ⌃⌥⌘V) e TextToType lo digita per te.
• Premi di nuovo la scorciatoia in qualsiasi momento per interrompere.

FUNZIONALITÀ
• Funziona con qualsiasi sistema: per impostazione predefinita TextToType invia ogni carattere come testo Unicode, quindi il layout di tastiera non conta. Per macchine virtuali e console può invece premere tasti reali, secondo il layout del tuo Mac o quello di un PC Windows in Desktop remoto, inclusi i caratteri AltGr come @.
• La tua scorciatoia: registra qualsiasi combinazione di tasti globale.
• Velocità di digitazione regolabile: più lenta per le sessioni remote che perdono caratteri, oppure a piena velocità.
• Compatibile con i gestori di password: se vuoi, cancella dagli appunti le password copiate appena sono state digitate.
• Discreto: TextToType vive nella barra dei menu e non ha bisogno di un’icona nel Dock.
• Apertura al login: sempre pronto quando ti serve.
• Nella tua lingua: italiano, inglese, tedesco, francese, spagnolo e portoghese (Brasile), da scegliere nelle impostazioni.

PRIVACY FIN DALLA PROGETTAZIONE
TextToType legge i tuoi appunti solo quando premi la scorciatoia o scegli «Digita appunti» dal menu. Niente viene salvato, registrato o inviato altrove, e l’app non apre alcuna connessione di rete.

GRATUITO E OPEN SOURCE
TextToType è open source con licenza MIT. Puoi leggere ogni riga di codice, segnalare problemi o contribuire su GitHub: github.com/akandor/TextToType

AUTORIZZAZIONE
Perché TextToType possa inviare battute ad altre app, macOS ti chiede una sola volta di autorizzarlo in Impostazioni di Sistema → Privacy e sicurezza → Accessibilità. TextToType usa questa autorizzazione solo per digitare i tuoi appunti quando lo chiedi tu.
```

**Keywords** [100]
```
incollare,digitare,tastiera,desktop remoto,vm,vnc,citrix,autotype,password,scorciatoia,console,ssh
```

**What's New in This Version** [4000]
```
Nuova impostazione «Digita per»: invia i caratteri come testo Unicode per qualsiasi sistema (predefinito), come pressioni di tasti per il tuo Mac, oppure per un PC Windows in Desktop remoto, dove caratteri come @ ora arrivano correttamente.

TextToType è ora disponibile in italiano, francese, spagnolo e portoghese (Brasile), e puoi scegliere la lingua dell’app nelle impostazioni.
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

Upload these to the Italian localization. They're 2880 × 1800 (16:10), like the English ones, and show the app's Italian UI.

| File | Shows |
| --- | --- |
| `Screenshots/it/01-type-anywhere.png` | Hero image: menu bar menu and text being typed into a remote session |
| `Screenshots/it/02-settings.png` | Settings: shortcut, typing speed, clipboard clearing, launch at login |

The sources are `screenshot-src/*.it.html`. To re-render them, run this from the project folder:

```bash
for f in 01-type-anywhere 02-settings; do "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/it/$f.png" "file://$PWD/AppStore/screenshot-src/$f.it.html"; done
```
