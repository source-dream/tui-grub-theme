.PHONY: build build-plymouth build-ventoy check check-plymouth check-ventoy dry-run install preview

build:
	./scripts/build.sh
	./profiles/2560x1600/scripts/build.sh

build-ventoy:
	./scripts/build-ventoy.sh

build-plymouth:
	./plymouth/tools/build-assets.sh

check:
	./scripts/check.sh
	./profiles/2560x1600/scripts/check.sh
	./scripts/check-plymouth.sh

check-plymouth:
	./scripts/check-plymouth.sh

check-ventoy:
	./scripts/check-ventoy.sh

dry-run:
	./scripts/install.sh --dry-run

install:
	./scripts/install.sh

preview:
	./scripts/preview.sh
