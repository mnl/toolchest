#!/usr/bin/env make

name := toolchest
tag ?= latest

.PHONY: lint clean build test all wipe

.podman-host-ok:
	# Ensure that podman can build and run containers
	echo from scratch | buildah build -qt $(name)-pause -
	podman run --replace --detach --rm \
		--name $(name)-pause --init localhost/$(name)-pause /run/podman-init -P
	podman stop $(name)-pause
	podman rmi $(name)-pause
	touch .podman-host-ok

build: Containerfile .buildid-$(name).stamp

Containerfile: .podman-host-ok

.buildid-$(name).stamp: Containerfile
	-cat .buildid-$(name).stamp >> .buildid-$(name).previous.stamp
	echo >> .buildid-$(name).previous.stamp
	buildah bud --layers -f $< \
		--annotation=org.opencontainers.image.version="$(tag)" \
		--annotation=org.opencontainers.image.title="$(name)" \
		--annotation=org.opencontainers.image.revision="$(shell git rev-parse --short HEAD)" \
		--created-annotation \
		--iidfile=.buildid-$(name).stamp \
		--tag $(name):$(tag)

clean:
	-buildah rmi $$(cat .buildid-$(name).stamp .buildid-$(name).previous.stamp)
	$(RM) .buildid-$(name).stamp .buildid-$(name).previous.stamp

wipe: clean
	$(RM) .podman-host-ok

all: clean build
