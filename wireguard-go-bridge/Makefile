# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

UPSTREAM_FILES := $(filter-out %/main.go %/queueconstants.go,$(wildcard ../wireguard-go/*/*.go) $(wildcard ../wireguard-go/*.go)) ../wireguard-go/go.mod ../wireguard-go/go.sum
DOWNSTREAM_FILES := $(wildcard src/*.go) $(wildcard src/*/*.go)

ifndef PLATFORM_NAME
$(error PLATFORM_NAME is undefined (Should be 'iphoneos', 'iphonesimulator' or 'macosx'))
endif

ifeq ($(PLATFORM_NAME), iphoneos)
# No need for armv7 because iOS doesn't support armv7 apps from iOS 11
# onwards, and our iOS app requires iOS 12.
ARCH := arm64
GOARCH := arm64
else ifeq ($(PLATFORM_NAME), iphonesimulator)
ARCH := x86_64
GOARCH := amd64
else ifeq ($(PLATFORM_NAME), macosx)
ARCH := x86_64
GOARCH := amd64
else
$(error Unknown value for PLATFORM_NAME: $(PLATFORM_NAME) (Should be 'iphoneos', 'iphonesimulator' or 'macosx'))
endif

DEPLOYMENT_CFLAGS := -$(DEPLOYMENT_TARGET_CLANG_FLAG_NAME)=$($(DEPLOYMENT_TARGET_CLANG_ENV_NAME))

CGO_FLAGS := -arch $(ARCH) -isysroot $(shell xcrun --sdk $(PLATFORM_NAME) --show-sdk-path) $(DEPLOYMENT_CFLAGS)
CC :=  $(shell xcrun --sdk $(PLATFORM_NAME) --find clang)

CONFIGURATION_BUILD_DIR ?= $(CURDIR)/out
CONFIGURATION_TEMP_DIR ?= $(CURDIR)/.tmp
DESTDIR ?= $(CONFIGURATION_BUILD_DIR)
BUILDDIR ?= $(CONFIGURATION_TEMP_DIR)/wireguard-go-bridge
export GOOS := darwin
export CGO_ENABLED := 1

build: $(DESTDIR)/libwg-go.a
version-header: $(DESTDIR)/wireguard-go-version.h

ifneq ($(shell uname -m), x86_64)
$(error WireGuardGoBridge must be built using an x86_64 machine)
endif

GOBUILDARCH := amd64
GOBUILDOS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
GOBUILDVERSION := 1.11.2
GOBUILDTARBALL := https://dl.google.com/go/go$(GOBUILDVERSION).$(GOBUILDOS)-$(GOBUILDARCH).tar.gz
GOBUILDVERSION_NEEDED := go version go$(GOBUILDVERSION) $(GOBUILDOS)/$(GOBUILDARCH)
export GOROOT := $(BUILDDIR)/goroot
export GOPATH := $(BUILDDIR)/gopath
export PATH := $(GOROOT)/bin:$(PATH)
GOBUILDVERSION_CURRENT := $(shell $(GOROOT)/bin/go version 2>/dev/null)
ifneq ($(GOBUILDVERSION_NEEDED),$(GOBUILDVERSION_CURRENT))
$(shell rm -f $(GOROOT)/bin/go)
endif
$(GOROOT)/bin/go:
	rm -rf "$(GOROOT)"
	mkdir -p "$(GOROOT)"
	curl "$(GOBUILDTARBALL)" | tar -C "$(GOROOT)" --strip-components=1 -xzf - || { rm -rf "$(GOROOT)"; exit 1; }
	patch -p1 -f -N -r- -d "$(GOROOT)" < goruntime-boottime-over-monotonic.diff || { rm -rf "$(GOROOT)"; exit 1; }

$(shell test "$$(cat "$(BUILDDIR)/.gobuildversion" 2>/dev/null)" = "$(GOBUILDVERSION_CURRENT)" || rm -f "$(DESTDIR)/libwg-go.a")

define copy-src-to-build
$(subst $(1),$(BUILDDIR)/,$(2)): $(2)
	@mkdir -vp "$$(dir $$@)"
	@cp -vp "$$<" "$$@"
$(BUILDDIR)/.prepared: $(subst $(1),$(BUILDDIR)/,$(2))
endef

$(foreach FILE,$(UPSTREAM_FILES),$(eval $(call copy-src-to-build,../wireguard-go/,$(FILE))))
$(foreach FILE,$(DOWNSTREAM_FILES),$(eval $(call copy-src-to-build,src/,$(FILE))))

$(BUILDDIR)/.prepared: $(GOROOT)/bin/go
	cd "$(BUILDDIR)" || exit $$?; CC="$(CC)" CGO_CFLAGS="$(CGO_FLAGS)" CGO_LDFLAGS="$(CGO_FLAGS)" GOARCH="$(GOARCH)" go get -tags ios || { ret=$$?; chmod -fR +w "$(GOPATH)/pkg/mod"; rm -rf "$(GOPATH)/pkg/mod"; exit $$ret; };
	chmod -fR +w "$(GOPATH)/pkg/mod"
	touch "$@"

$(BUILDDIR)/libwg-go.a: $(BUILDDIR)/.prepared
	cd "$(BUILDDIR)" || exit $$$$?; \
	CC="$(CC)" \
	CGO_CFLAGS="$(CGO_FLAGS)" \
	CGO_LDFLAGS="$(CGO_FLAGS)" \
	GOARCH="$(GOARCH)" \
	go build -tags ios -ldflags=-w -v -o "$(BUILDDIR)/libwg-go.a" -buildmode c-archive && go version > "$(BUILDDIR)/.gobuildversion"; \
	ret=$$?; \
	rm -f "$(BUILDDIR)/libwg-go.h"; \
	exit $$ret

$(DESTDIR)/wireguard-go-version.h: ../wireguard-go/version.go
	sed -n 's/.*WireGuardGoVersion = "\(.*\)"/#define WIREGUARD_GO_VERSION "\1"/p' "$^" > "$@"

$(DESTDIR)/libwg-go.a: $(BUILDDIR)/libwg-go.a
	@mkdir -vp "$(DESTDIR)"
	cp $^ "$@"

$(DESTDIR)/example: example.c $(DESTDIR)/libwg-go.a
	xcrun --sdk $(PLATFORM_NAME) clang -framework CoreFoundation -isysroot "$(shell xcrun --sdk $(PLATFORM_NAME) --show-sdk-path)" -arch $(ARCH) -L"$(DESTDIR)" -lwg-go -o "$@" "$<"

example: $(DESTDIR)/example

clean:
	rm -rf "$(BUILDDIR)" "$(DESTDIR)/libwg-go.a" "$(DESTDIR)/example" "$(DESTDIR)/wireguard-go-version.h"

install: build

.PHONY: clean build example version-header install
