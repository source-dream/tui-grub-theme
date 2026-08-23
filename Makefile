.PHONY: build build-ventoy check check-ventoy dry-run install preview

build:
	./scripts/build.sh

build-ventoy:
	./scripts/build-ventoy.sh

check:
	./scripts/check.sh

check-ventoy:
	./scripts/check-ventoy.sh

dry-run:
	./scripts/install.sh --dry-run

install:
	./scripts/install.sh

preview:
	./scripts/preview.sh
