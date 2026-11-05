# TextToType: App Store Connect metadata (Deutsch)

German (de-DE) localization of [AppStore.md](AppStore.md). In App Store Connect, pick **Deutsch** from the language menu at the top right of the app page, then copy each field below.
Character limits are noted in brackets; every field below is within its limit. Fields that aren't localized (category, age rating, App Review notes, App Privacy answers) stay as they are in the English listing.

The wording uses the informal "du", matching the app's German UI.

---

## App Information

**Name** [30]
```
TextToType: Zwischenablage
```

**Subtitle** [30]
```
Tippt, wo Einfügen nicht geht
```

**Privacy Policy URL**
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```

---

## Version

**Promotional text** [170]
```
Remote-Desktop, VM oder ein Login, das Einfügen blockiert? Ein Tastenkürzel genügt und TextToType tippt deine Zwischenablage ein, Taste für Taste.
```

**Description** [4000]
```
TextToType tippt den Text aus deiner Zwischenablage in jede beliebige App, genau so, als würdest du ihn selbst auf der Tastatur eingeben.

Manche Stellen lassen dich einfach nicht einfügen: Remote-Desktops, virtuelle Maschinen, VNC- und Citrix-Sitzungen, Server-Konsolen, Installationsprogramme und Webformulare, die das Einfügen von Passwörtern oder Codes sperren. TextToType umgeht das. Kopiere deinen Text, klicke an die Stelle, an der er stehen soll, und drücke dein Tastenkürzel.

SO FUNKTIONIERT'S
• Kopiere einen beliebigen Text.
• Klicke in das Fenster, in das er eingegeben werden soll.
• Drücke dein Tastenkürzel (Standard: ⌃⌥⌘V) und TextToType tippt ihn für dich ein.
• Drücke das Tastenkürzel jederzeit erneut, um die Eingabe zu stoppen.

FUNKTIONEN
• Echte Tastenanschläge: TextToType verwendet die tatsächlichen Tasten deiner aktuellen Tastaturbelegung, inklusive Umschalt- und Wahltaste. Remote-Rechner und VMs empfangen also genau das, was du selbst tippen würdest.
• Dein eigenes Tastenkürzel: Nimm eine beliebige globale Tastenkombination auf.
• Einstellbare Tippgeschwindigkeit: Langsamer für Remote-Sitzungen, die Zeichen verschlucken, oder volle Geschwindigkeit.
• Passwort-Manager-freundlich: Löscht kopierte Passwörter auf Wunsch aus der Zwischenablage, sobald sie eingetippt sind.
• Unauffällig: TextToType wohnt in der Menüleiste und braucht kein Dock-Symbol.
• Start bei der Anmeldung: immer bereit, wenn du es brauchst.
• Unicode-fähig: Auch Emoji und Sonderzeichen, für die deine Tastatur mehr als eine Taste braucht, werden eingetippt.

DATENSCHUTZ VON ANFANG AN
TextToType liest deine Zwischenablage nur, wenn du das Tastenkürzel drückst oder im Menü „Zwischenablage eintippen“ wählst. Nichts wird gespeichert, protokolliert oder irgendwohin gesendet, und die App baut keinerlei Netzwerkverbindungen auf.

KOSTENLOS UND OPEN SOURCE
TextToType ist Open Source unter der MIT-Lizenz. Du kannst jede Zeile Code lesen, Fehler melden oder auf GitHub mitentwickeln: github.com/akandor/TextToType

BERECHTIGUNG
Damit TextToType Tastenanschläge an andere Apps senden kann, bittet macOS dich einmalig, die App unter Systemeinstellungen → Datenschutz & Sicherheit → Bedienungshilfen zu erlauben. TextToType nutzt diese Berechtigung ausschließlich, um deine Zwischenablage einzutippen, wenn du es möchtest.
```

**Keywords** [100]
```
einfügen,tippen,tastatur,remote desktop,vm,vnc,citrix,autotype,passwort,tastenkürzel,konsole,ssh
```

**What's New in This Version** [4000]
```
TextToType gibt es jetzt auch auf Deutsch. Menü, Einstellungen und Hinweise erscheinen automatisch in deutscher Sprache, wenn dein Mac auf Deutsch eingestellt ist.
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

Upload these to the German localization. They're 2880 × 1800 (16:10), like the English ones, and show the app's German UI.

| File | Shows |
| --- | --- |
| `Screenshots/de/01-type-anywhere.png` | Hero image: menu bar menu and text being typed into a remote session |
| `Screenshots/de/02-settings.png` | Settings: shortcut, typing speed, clipboard clearing, launch at login |

The sources are `screenshot-src/*.de.html`. To re-render them, run this from the project folder:

```bash
for f in 01-type-anywhere 02-settings; do "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/de/$f.png" "file://$PWD/AppStore/screenshot-src/$f.de.html"; done
```
