# Psequel

Remind future me:
```
 .
├──  application.vala
├──  gtk -> blue print, will compile to .ui files (2)
│  ├──  box.blp
│  ├──  help-overlay.ui
│  └──  window.blp
├── 謹 psequel.gresource.xml <- List the ui files in this file (3)
├──  main.vala
├──  meson.build <- List the blue prints in this files to make the compiler running. (1)
├──  ui <- Create a class (.vala file) to load template in this file (4) 
└──  window.vala

```

Remind me 2:
 Please install the schema for each change.
 `ninja install`

Prefer setting:
- UI Font
- Editor font
- Color scheme

- Connection timeout
- Query timeout
- Query limit.