# TextToType: App Store Connect metadata (Español)

Spanish (es-ES) localization of [AppStore.md](AppStore.md). In App Store Connect, pick **Español (España)**. You can also copy the same texts into **Español (México)** from the language menu at the top right of the app page, then copy each field below.
Character limits are noted in brackets; every field below is within its limit. Fields that aren't localized (category, age rating, App Review notes, App Privacy answers) stay as they are in the English listing.

The wording uses the informal "tú", matching the app's Spanish UI and Apple's Spanish style.

---

## App Information

**Name** [30]
```
TextToType: Portapapeles
```

**Subtitle** [30]
```
Escribe donde no puedes pegar
```

**Privacy Policy URL**
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```

---

## Version

**Promotional text** [170]
```
¿Escritorio remoto, máquina virtual o un formulario que bloquea el pegado? Pulsa un atajo y TextToType escribe tu portapapeles por ti, tecla a tecla.
```

**Description** [4000]
```
TextToType escribe el texto de tu portapapeles en cualquier app, exactamente como si lo estuvieras tecleando tú.

Hay sitios que simplemente no te dejan pegar: escritorios remotos, máquinas virtuales, sesiones VNC y Citrix, consolas de servidor, instaladores y formularios web que bloquean el pegado de contraseñas o códigos. TextToType lo soluciona. Copia el texto, haz clic donde debe ir y pulsa tu atajo.

CÓMO FUNCIONA
• Copia cualquier texto.
• Haz clic en la ventana donde debe escribirse.
• Pulsa tu atajo (por omisión: ⌃⌥⌘V) y TextToType lo escribe por ti.
• Vuelve a pulsar el atajo en cualquier momento para detenerlo.

FUNCIONES
• Funciona con cualquier sistema: por omisión, TextToType envía cada carácter como texto Unicode, así que la distribución del teclado no importa. Para máquinas virtuales y consolas también puede pulsar teclas reales, según la distribución de tu Mac o la de un PC con Windows en Escritorio remoto, incluidos caracteres AltGr como @.
• Tu propio atajo: graba cualquier combinación de teclas global.
• Velocidad de escritura ajustable: más lenta para sesiones remotas que pierden caracteres, o a toda velocidad.
• Compatible con gestores de contraseñas: si quieres, borra del portapapeles las contraseñas copiadas en cuanto se han escrito.
• Discreto: TextToType vive en la barra de menús y no necesita icono en el Dock.
• Apertura al iniciar sesión: siempre listo cuando lo necesitas.
• En tu idioma: español, inglés, alemán, francés, italiano y portugués (Brasil), a elegir en los ajustes.

PRIVACIDAD DESDE EL DISEÑO
TextToType solo lee tu portapapeles cuando pulsas el atajo o eliges «Escribir portapapeles» en el menú. No se guarda, registra ni envía nada a ningún sitio, y la app no establece ninguna conexión de red.

GRATIS Y DE CÓDIGO ABIERTO
TextToType es de código abierto con licencia MIT. Puedes leer cada línea de código, informar de problemas o colaborar en GitHub: github.com/akandor/TextToType

PERMISO
Para que TextToType pueda enviar pulsaciones de teclas a otras apps, macOS te pide una sola vez que lo permitas en Ajustes del Sistema → Privacidad y seguridad → Accesibilidad. TextToType usa este permiso únicamente para escribir tu portapapeles cuando tú quieras.
```

**Keywords** [100]
```
pegar,escribir,teclado,escritorio remoto,vm,vnc,citrix,autotype,contraseña,atajo,consola,ssh
```

**What's New in This Version** [4000]
```
Nuevo ajuste «Escribir para»: envía los caracteres como texto Unicode para cualquier sistema (por omisión), como pulsaciones de teclas para tu Mac, o para un PC con Windows en Escritorio remoto, donde caracteres como @ ahora llegan correctamente.

TextToType ya está disponible en español, francés, italiano y portugués (Brasil), y puedes elegir el idioma de la app en los ajustes.
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

Upload these to the Spanish localization(s). They're 2880 × 1800 (16:10), like the English ones, and show the app's Spanish UI.

| File | Shows |
| --- | --- |
| `Screenshots/es/01-type-anywhere.png` | Hero image: menu bar menu and text being typed into a remote session |
| `Screenshots/es/02-settings.png` | Settings: shortcut, typing speed, clipboard clearing, launch at login |

The sources are `screenshot-src/*.es.html`. To re-render them, run this from the project folder:

```bash
for f in 01-type-anywhere 02-settings; do "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/es/$f.png" "file://$PWD/AppStore/screenshot-src/$f.es.html"; done
```
