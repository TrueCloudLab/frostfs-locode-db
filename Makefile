#!/usr/bin/make -f

VERSION ?= "$(shell git describe --tags --match "v*" --dirty --always --abbrev=8 2>/dev/null || cat VERSION 2>/dev/null || echo "develop")"
FROST ?= frostfs-cli

.PHONY: all clean version help unlocode debpackage

DIRS = in tmp

space := $(subst ,, )

# .deb package versioning
OS_RELEASE = $(shell lsb_release -cs)
PKG_VERSION ?= $(shell echo $(VERSION) | sed "s/^v//" | \
	sed -E "s/(.*)-(g[a-fA-F0-9]{6,8})(.*)/\1\3~\2/" | \
	sed "s/-/~/")-${OS_RELEASE}

all: $(DIRS) locode_db

$(DIRS):
	@echo "⇒ Ensure dir: $@"
	@mkdir -p $@

in/airports.dat:
	wget -c https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat -O in/airports.dat

in/countries.dat:
	wget -c https://raw.githubusercontent.com/jpatokal/openflights/master/data/countries.dat -O in/countries.dat

in/continents.geojson: $(DIRS)
	zcat continents.geojson.gz > in/continents.geojson

unlocode:
	wget -c https://service.unece.org/trade/locode/loc222csv.zip -O tmp/loc222csv.zip
	unzip -u tmp/loc222csv.zip -d in/

locode_db: unlocode in/continents.geojson in/airports.dat in/countries.dat
	$(FROST) util locode generate \
	--airports in/airports.dat \
	--continents in/continents.geojson \
	--countries in/countries.dat \
	--in in/2022-2\ UNLOCODE\ CodeListPart1.csv,in/2022-2\ UNLOCODE\ CodeListPart2.csv,in/2022-2\ UNLOCODE\ CodeListPart3.csv \
	--subdiv in/2022-2\ SubdivisionCodes.csv \
	--out locode_db
	chmod 644 locode_db

# Print version
version:
	@echo $(VERSION)

# Show this help prompt
help:
	@echo '  Usage:'
	@echo ''
	@echo '    make <target>'
	@echo ''
	@echo '  Targets:'
	@echo ''
	@awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | grep -v 'IGNORE' | sort -u

# Clean up
clean:
	rm -f in/*
	rm -f tmp/*
	rm -f locode_db

# Package for Debian
debpackage:
	dch --package frostfs-locode-db \
		--controlmaint \
		--newversion $(PKG_VERSION) \
		--force-bad-version \
		--distribution $(OS_RELEASE) \
		"Please see CHANGELOG.md for code changes for $(VERSION)"
	dpkg-buildpackage --no-sign -b

debclean:
	dh clean
