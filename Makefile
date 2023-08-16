# This is just a file for me to type command faster, not the build file.


debug:
	cd build; ninja && G_MESSAGES_DEBUG=Psequel ./src/psequel

flatpak:
	flatpak-builder _build/ me.ppvan.psequel-debug.json --force-clean

run:
	G_MESSAGES_DEBUG=Psequel ./_build/files/bin/psequel