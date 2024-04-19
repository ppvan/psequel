# This is just a file for me to type command faster, not the build file.

debug:
	ninja -C build/ && G_MESSAGES_DEBUG=Psequel ./build/src/me.ppvan.psequel

clean:
	rm -rf build/res

test:
	ninja -C build/ && ./build/test/psequel-test

flatpak:
	flatpak-builder build-aux/ me.ppvan.psequel.json --force-clean
	flatpak build-export export build-aux
	flatpak build-bundle export me.ppvan.psequel.flatpak --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

run:
	G_MESSAGES_DEBUG=Psequel ./build/src/me.ppvan.psequel