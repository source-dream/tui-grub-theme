.PHONY: build check dry-run install preview

build:
	./scripts/build.sh

check:
	./scripts/check.sh

dry-run:
	./scripts/install.sh --dry-run

install:
	./scripts/install.sh

preview:
	./scripts/preview.sh
