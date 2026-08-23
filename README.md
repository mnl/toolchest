# Toolchest
This is my big toolchest of useful tools.

Built on Alpine 3.23 with things missing from alpine repo added
as binaries from their official repo sources.

## Usage:
Works as a toolbox container:
```bash
toolbox create toolchest --image toolchest:latest
toolbox enter toolchest
```

Or as regular container:
```bash
podman/docker run --rm --hostname toolz -it toolchest bash
```

## Building:
Build with buildah using included Makefile
