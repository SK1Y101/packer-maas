#!/usr/bin/make -f

include ../scripts/check.mk

PACKER ?= packer
PACKER_LOG ?= 0
export PACKER_LOG

SERIES ?= bullseye
BOOT ?= uefi
ARCH ?= amd64

ifeq ($(strip $(SERIES)),buster)
	VERSION = 10
else ifeq ($(strip $(SERIES)),bullseye)
	VERSION = 11
else ifeq ($(strip $(SERIES)),bookworm)
	VERSION = 12
else
	VERSION = 11
endif

# Safeguard
ifeq ($(strip $(ARCH)),arm64)
	boot = uefi
endif

.PHONY: all clean

all: debian

$(eval $(call check_packages_deps,cloud-image-utils ovmf,cloud-image-utils ovmf))

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

debian: check-deps clean
	${PACKER} init . && ${PACKER} build \
		-var debian_series=${SERIES} \
		-var debian_version=${VERSION} \
		-var architecture=${ARCH} \
		-var boot_mode=${BOOT} .

clean:
	${RM} -rf output-* debian-custom-*.gz \
		seeds-cloudimg.iso \
		OVMF_VARS.fd \
		AAVMF_VARS.fd

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: OVMF_VARS.fd packages/custom-packages.tar.gz \
	seeds-cloudimg.iso
