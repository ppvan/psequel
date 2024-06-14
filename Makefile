# This is just a file for me to type command faster, not the build file.

debug:
	rm -rf build/resources/gtk
	meson configure -Dbuildtype=debug build
	ninja -C build/ && G_MESSAGES_DEBUG=Psequel ./build/src/psequel

release:
	meson configure -Dbuildtype=release build
	ninja -C build/ && G_MESSAGES_DEBUG=Psequel ./build/src/psequel

clean:
	rm -rf build/resources

test:
	ninja -C build/ && ./build/test/psequel-test

flatpak:
	flatpak-builder --install-deps-from=flathub build-aux/ me.ppvan.psequel.json --force-clean
	flatpak build-export export build-aux
	flatpak build-bundle export ./build-aux/me.ppvan.psequel.flatpak me.ppvan.psequel --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

run:
	G_MESSAGES_DEBUG=Psequel ./build/src/psequel