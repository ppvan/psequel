# Dependencies

```sh
# Install gtk4, vala, meson and postgresql (provide libpq) 
## ArchLinux since I use arch btw

yay -S gtk4 vala meson postgresql flatpak-builder
```


# Psequel

```sh
# config meson

cd psequel/
meson setup build/

# install glib schema (rerun each time change setting schemas)
cd build
sudo ninja install

# back to the project dir and run
cd ..
make debug
```