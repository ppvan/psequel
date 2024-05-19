# This is just a file for me to type command faster, not the build file.

debug:
	rm -rf build/resources/gtk
	ninja -C build/ && G_MESSAGES_DEBUG=Psequel ./build/src/psequel

clean:
	rm -rf build/resources

test:
	ninja -C build/ && ./build/test/psequel-test

flatpak:
	flatpak-builder --install-deps-from=flathub build-aux/ me.ppvan.psequel.json --force-clean
	flatpak build-export export build-aux
	flatpak build-bundle export me.ppvan.psequel.flatpak me.ppvan.psequel --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

run:
	G_MESSAGES_DEBUG=Psequel ./build/src/psequel