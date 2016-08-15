all: setup-folders

setup-folders: dev-folders music-folders

dev-folders:
	cd ~/ ; mkdir Dev ; cd Dev ; mkdir misc ; mkdir ocaml ; mkdir haskell ; mkdir ember

music-folders:
	cd ~/ ; cd Music ; lessons ; mkdir songs ; mkdir sounds
