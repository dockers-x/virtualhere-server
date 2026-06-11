# VirtualHere USB Server Docker

Docker images for running VirtualHere USB Server with the official Linux server
binaries downloaded at build time.

The generic Linux builds are sourced from the official VirtualHere download page:
https://www.virtualhere.com/usb_server_software

## Supported Architectures

| VirtualHere build | Docker platform | Image suffix | Dockerfile | Download URL |
| --- | --- | --- | --- | --- |
| Linux i386 | `linux/386` | `i386` | `Dockerfile.i386` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdi386` |
| Linux x86_64 | `linux/amd64` | `amd64` | `Dockerfile` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64` |
| Linux ARM 32-bit | `linux/arm/v7` | `arm` | `Dockerfile.arm` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdarm` |
| Linux ARM64 | `linux/arm64` | `arm64` | `Dockerfile.arm64` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdarm64` |
| Linux MIPS big-endian | `linux/mips` | `mips` | `Dockerfile.mips` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdmips` |
| Linux MIPS little-endian | `linux/mipsle` | `mipsel` | `Dockerfile.mipsel` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdmipsel` |
| Linux RISCV64 | `linux/riscv64` | `riscv64` | `Dockerfile.riscv64` | `https://www.virtualhere.com/sites/default/files/usbserver/vhusbdriscv64` |

`amd64`, `arm64`, and `arm` images use Ubuntu and include the shared startup
script plus `usbutils` diagnostics. `i386`, `mips`, `mipsel`, and `riscv64`
use minimal `scratch` images because common base images do not reliably cover
all of those targets. The VirtualHere server binary is statically compiled, so
the minimal images can run it directly, but they do not include a shell,
`lsusb`, or `docker exec` debugging tools.

## Quick Start

Use the multi-architecture tag when your Docker runtime can select a matching
platform from the manifest:

```bash
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  czyt/virtualhere-server:latest
```

Use an architecture-specific tag when you want to pin the target image:

```bash
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  czyt/virtualhere-server:latest-amd64
```

Replace `latest-amd64` with `latest-i386`, `latest-arm`, `latest-arm64`,
`latest-mips`, `latest-mipsel`, or `latest-riscv64` as needed.

## Registries

- Docker Hub: `czyt/virtualhere-server`
- GitHub Container Registry: `ghcr.io/dockers-x/virtualhere-server`

Both registries are published by the GitHub Actions workflow.

## Tags

| Tag | Description |
| --- | --- |
| `latest` | Multi-architecture manifest for the latest published build |
| `latest-<arch>` | Latest architecture-specific image, for example `latest-arm64` |
| `<version>` | Multi-architecture manifest for a tagged release, for example `1.2.3` |
| `<version>-<arch>` | Architecture-specific tagged release, for example `1.2.3-riscv64` |

Supported `<arch>` suffixes are `i386`, `amd64`, `arm`, `arm64`, `mips`,
`mipsel`, and `riscv64`.

## Architecture Detection

Common `uname -m` values map to these tags:

| `uname -m` | Recommended tag |
| --- | --- |
| `i386`, `i486`, `i586`, `i686` | `latest-i386` |
| `x86_64` | `latest-amd64` |
| `armv6l`, `armv7l`, `armhf` | `latest-arm` |
| `aarch64`, `arm64` | `latest-arm64` |
| `mips` | `latest-mips` |
| `mipsel` | `latest-mipsel` |
| `riscv64` | `latest-riscv64` |

## Building Locally

```bash
git clone https://github.com/dockers-x/virtualhere-server.git
cd virtualhere-server

docker build -f Dockerfile.i386 -t virtualhere-server:i386 .
docker build -f Dockerfile -t virtualhere-server:amd64 .
docker build -f Dockerfile.arm -t virtualhere-server:arm .
docker build -f Dockerfile.arm64 -t virtualhere-server:arm64 .
docker build -f Dockerfile.mips -t virtualhere-server:mips .
docker build -f Dockerfile.mipsel -t virtualhere-server:mipsel .
docker build -f Dockerfile.riscv64 -t virtualhere-server:riscv64 .
```

For cross-platform builds, use Buildx:

```bash
docker buildx build --platform linux/riscv64 \
  -f Dockerfile.riscv64 \
  -t virtualhere-server:riscv64 .
```

Auto-detect a local architecture and choose the matching Dockerfile:

```bash
ARCH=$(uname -m)
case "$ARCH" in
  i386|i486|i586|i686) docker build -f Dockerfile.i386 -t virtualhere-server . ;;
  x86_64) docker build -f Dockerfile -t virtualhere-server . ;;
  armv6l|armv7l|armhf) docker build -f Dockerfile.arm -t virtualhere-server . ;;
  aarch64|arm64) docker build -f Dockerfile.arm64 -t virtualhere-server . ;;
  mips) docker build -f Dockerfile.mips -t virtualhere-server . ;;
  mipsel) docker build -f Dockerfile.mipsel -t virtualhere-server . ;;
  riscv64) docker build -f Dockerfile.riscv64 -t virtualhere-server . ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac
```

## Project Structure

```text
.
|-- Dockerfile              # x86_64 / amd64 build
|-- Dockerfile.i386         # i386 build
|-- Dockerfile.arm          # ARM 32-bit build
|-- Dockerfile.arm64        # ARM64 build
|-- Dockerfile.mips         # MIPS big-endian build
|-- Dockerfile.mipsel       # MIPS little-endian build
|-- Dockerfile.riscv64      # RISCV64 build
|-- start-virtualhere.sh    # Shared startup script for Ubuntu-based images
|-- .github/workflows/
|   `-- docker_publish.yml  # CI/CD pipeline
`-- README.md
```

## GitHub Actions

The workflow builds each architecture as a separate image, publishes
architecture-specific tags, and then creates a multi-architecture manifest for
`latest` and version tags.

Required repository secrets:

| Secret | Description |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

GitHub Container Registry publishing uses the built-in `GITHUB_TOKEN`.

## Troubleshooting

### Container cannot access USB devices

Run the container with USB device access:

```bash
docker run --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -p 7575:7575 \
  czyt/virtualhere-server:latest
```

On Ubuntu-based images, check USB visibility:

```bash
docker exec virtualhere lsusb
```

Minimal `scratch` images do not include `lsusb` or a shell. Use host-side USB
diagnostics for those targets.

### Port 7575 is not reachable

Check that the port is published and not blocked by the host firewall:

```bash
docker ps --filter name=virtualhere
netstat -tuln | grep 7575
```

### Logs

```bash
docker logs virtualhere
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

VirtualHere USB Server itself is distributed by VirtualHere. Review the
VirtualHere licensing terms before production or multi-device use.

## Links

- VirtualHere USB Server downloads: https://www.virtualhere.com/usb_server_software
- VirtualHere client downloads: https://www.virtualhere.com/usb_client_software
- VirtualHere install script: https://github.com/virtualhere/script
