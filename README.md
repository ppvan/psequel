<!--
    2023 ppvan phuclaplace@gmail.com
-->
<h1 align="center">
<img
    src="data/icons/hicolor/scalable/apps/me.ppvan.psequel.svg" alt="PSequel"
    width="128"
    height="128"/><br/>
    PSequel
</h1>

<p align="center">
<a href="https://stopthemingmy.app">
    <img width="200" src="https://stopthemingmy.app/badge.svg"/>
</a>
</p>

<p align="center">
    <img alt="Screenshot" src="screenshots/screenshot.png"/>
</p>


Small tool for quick sql query, specialized in PostgresSQL. Written in Vala for GNOME desktop in the hope to be useful.

# Features
- Load and save connections.
- List schema info, tables, views.
- View table columns info, indexes, foreign keys
- View table data, sort by column
- Write query
- Query History

# Installation

## Flatpak file
> **Recommended**

Download flatpak file from in [Releases](https://github.com/ppvan/psequel/releases) tab, then install it by:
```bash
flatpak install me.ppvan.psequel.flatpak
```

## Build from source
### Via GNOME Builder
PSequel can be built with GNOME Builder >= 3.38. Clone this repo and click run button.

> (Warning: required to rebuild postgres, will take a little bit of time)

### Via Meson
Psequel can be built directly via Meson:
```bash
git clone https://github.com/ppvan/psequel
cd psequel
meson build
cd build
meson compile
```
Next, it can be installed by `meson install`.

# Dependencies
If you use GNOME Builder or Flatpak, dependencies will be installed automatically. If you use pure Meson, dependencies will be:
- vala >= 0.56
- gtk >= 4.10
- gtksourceview >= 5.0
- gio >= 2.74
- json-glib >= 1.6
- libadwaita >= 1.0
- postgres-libs >= 15.3

# Contributions
Contributions are welcome.

# FAQ
Why not flathub?
> There is an bug in flatpak-builder build and i don't know why yet (see [#43](https://github.com/ppvan/psequel/issues/43)). So i have to build it in GNOME Builder and upload flatpak file manually in [Releases](https://github.com/ppvan/psequel/releases) tab.
