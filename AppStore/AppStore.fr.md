# TextToType: App Store Connect metadata (Français)

French (fr-FR) localization of [AppStore.md](AppStore.md). In App Store Connect, pick **Français**. Vous pouvez aussi copier les mêmes textes dans **Français (Canada)** from the language menu at the top right of the app page, then copy each field below.
Character limits are noted in brackets; every field below is within its limit. Fields that aren't localized (category, age rating, App Review notes, App Privacy answers) stay as they are in the English listing.

The wording uses "vous", matching the app's French UI and Apple's French style.

---

## App Information

**Name** [30]
```
TextToType : Presse-papiers
```

**Subtitle** [30]
```
Tape là où coller est bloqué
```

**Privacy Policy URL**
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```

---

## Version

**Promotional text** [170]
```
Bureau à distance, VM ou formulaire qui bloque le collage ? Un raccourci suffit : TextToType saisit votre presse-papiers pour vous, touche par touche.
```

**Description** [4000]
```
TextToType saisit le texte de votre presse-papiers dans n’importe quelle app, exactement comme si vous le tapiez au clavier.

Certains endroits refusent tout simplement le collage : bureaux à distance, machines virtuelles, sessions VNC et Citrix, consoles de serveur, programmes d’installation et formulaires web qui bloquent le collage de mots de passe ou de codes. TextToType contourne ce problème. Copiez votre texte, cliquez là où il doit aller et appuyez sur votre raccourci.

COMMENT ÇA MARCHE
• Copiez n’importe quel texte.
• Cliquez dans la fenêtre où il doit être saisi.
• Appuyez sur votre raccourci (par défaut : ⌃⌥⌘V) et TextToType le tape pour vous.
• Appuyez à nouveau sur le raccourci à tout moment pour arrêter.

FONCTIONNALITÉS
• Fonctionne avec tous les systèmes : par défaut, TextToType envoie chaque caractère sous forme de texte Unicode, la disposition du clavier n’a donc pas d’importance. Pour les machines virtuelles et les consoles, il peut aussi appuyer sur de vraies touches, selon la disposition de votre Mac ou celle d’un PC Windows en Bureau à distance, y compris les caractères AltGr comme @.
• Votre propre raccourci : enregistrez n’importe quelle combinaison de touches globale.
• Vitesse de saisie réglable : plus lente pour les sessions à distance qui perdent des caractères, ou à pleine vitesse.
• Compatible avec les gestionnaires de mots de passe : efface, si vous le souhaitez, les mots de passe copiés du presse-papiers une fois saisis.
• Discret : TextToType vit dans la barre des menus, sans icône dans le Dock.
• Ouverture à la connexion : toujours prêt quand vous en avez besoin.
• Dans votre langue : français, anglais, allemand, italien, espagnol et portugais (Brésil), à choisir dans les réglages.

CONFIDENTIALITÉ DÈS LA CONCEPTION
TextToType ne lit votre presse-papiers que lorsque vous appuyez sur le raccourci ou choisissez « Saisir le presse-papiers » dans le menu. Rien n’est enregistré, journalisé ni envoyé où que ce soit, et l’app n’établit aucune connexion réseau.

GRATUIT ET OPEN SOURCE
TextToType est open source sous licence MIT. Vous pouvez lire chaque ligne de code, signaler des problèmes ou contribuer sur GitHub : github.com/akandor/TextToType

AUTORISATION
Pour que TextToType puisse envoyer des frappes à d’autres apps, macOS vous demande une seule fois de l’autoriser dans Réglages Système → Confidentialité et sécurité → Accessibilité. TextToType utilise cette autorisation uniquement pour saisir votre presse-papiers lorsque vous le demandez.
```

**Keywords** [100]
```
coller,saisie,clavier,bureau à distance,vm,vnc,citrix,autotype,mot de passe,raccourci,console,ssh
```

**What's New in This Version** [4000]
```
Nouveau réglage « Saisir pour » : envoyez les caractères sous forme de texte Unicode pour n’importe quel système (par défaut), comme frappes de touches pour votre Mac, ou pour un PC Windows en Bureau à distance, où les caractères comme @ passent désormais correctement.

TextToType est maintenant disponible en français, en italien, en espagnol et en portugais (Brésil), et vous pouvez choisir la langue de l’app dans les réglages.
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

Upload these to the French localization. They're 2880 × 1800 (16:10), like the English ones, and show the app's French UI.

| File | Shows |
| --- | --- |
| `Screenshots/fr/01-type-anywhere.png` | Hero image: menu bar menu (with Type for) and text being typed into a remote session |
| `Screenshots/fr/02-settings.png` | Settings, Typing tab: Type for, typing speed, clipboard clearing |

The sources are `screenshot-src/*.fr.html`. To re-render them, run this from the project folder:

```bash
for f in 01-type-anywhere 02-settings; do "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/fr/$f.png" "file://$PWD/AppStore/screenshot-src/$f.fr.html"; done
```
