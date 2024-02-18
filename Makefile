# This is just a file for me to type command faster, not the build file.


debug: clean
	ninja -C build/ && G_MESSAGES_DEBUG=Psequel ./build/src/psequel

clean:
	rm -rf build/res

test:
	ninja -C build/ && ./build/test/psequel-test

flatpak:
	flatpak-builder _build/ me.ppvan.psequel.Devel.json --force-clean

run:
	G_MESSAGES_DEBUG=Psequel ./_build/files/bin/psequel