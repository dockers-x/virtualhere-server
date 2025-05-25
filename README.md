# VirtualHere USB Server Docker

A Docker container for running VirtualHere USB Server with pre-downloaded binaries, supporting multiple architectures with dedicated Dockerfiles.

## Features

- 🚀 **Pre-downloaded binaries** - Architecture-specific binaries downloaded during build
- 🏗️ **Multi-architecture support** - Separate Dockerfiles for AMD64, ARM64, ARM
- 🔄 **Automated builds** - GitHub Actions CI/CD pipeline
- 📦 **Multi-registry publishing** - Docker Hub and GitHub Container Registry
- 🔒 **Security scanning** - Automated vulnerability scanning with Trivy
- 📊 **Health checks** - Built-in container health monitoring
- 🏷️ **Simple tagging** - Only `latest` and `release` tags

## Quick Start

### Architecture-Specific Images

Choose the appropriate image for your system:

```bash
# For AMD64/x86_64 systems
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  yourusername/virtualhere-server:latest-amd64

# For ARM64 systems (Raspberry Pi 4, Apple Silicon, etc.)
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  yourusername/virtualhere-server:latest-arm64

# For ARM systems (Raspberry Pi 3 and older)
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  yourusername/virtualhere-server:latest-arm
```

### Multi-Architecture Image (Recommended)

The multi-arch manifest automatically selects the correct image:

```bash
docker run -d --name virtualhere --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v virtualhere-data:/data \
  -p 7575:7575 \
  yourusername/virtualhere-server:latest
```

## Available Tags

### Docker Hub & GitHub Container Registry

| Tag | Description | Architectures |
|-----|-------------|---------------|
| `latest` | Latest build from main branch | Multi-arch (amd64, arm64, arm) |
| `latest-amd64` | Latest AMD64 build | amd64 |
| `latest-arm64` | Latest ARM64 build | arm64 |
| `latest-arm` | Latest ARM build | arm/v7 |
| `release` | Latest tagged release | Multi-arch (amd64, arm64, arm) |
| `release-amd64` | Release AMD64 build | amd64 |
| `release-arm64` | Release ARM64 build | arm64 |
| `release-arm` | Release ARM build | arm/v7 |
| `v1.2.3` | Specific version | Multi-arch (amd64, arm64, arm) |

### Registry URLs

- **Docker Hub**: `yourusername/virtualhere-server:latest`
- **GitHub Container Registry**: `ghcr.io/yourusername/virtualhere-server:latest`

## Architecture Detection

The system automatically selects the appropriate image based on your architecture:

- **x86_64** → `latest-amd64` (Intel/AMD 64-bit)
- **aarch64** → `latest-arm64` (ARM 64-bit)
- **armv7l** → `latest-arm` (ARM 32-bit)

## Project Structure

```
.
├── Dockerfile.amd64          # AMD64 specific build
├── Dockerfile.arm64          # ARM64 specific build
├── Dockerfile.arm            # ARM specific build
├── start-virtualhere.sh      # Startup script (shared)
├── docker-compose.yml        # Docker Compose config
├── .github/
│   └── workflows/
│       └── build.yml         # CI/CD pipeline
└── README.md
```

## Building from Source

### Prerequisites

- Docker with BuildKit support
- Git

### Build Commands

```bash
# Clone the repository
git clone https://github.com/yourusername/virtualhere-docker.git
cd virtualhere-docker

# Build for specific architecture
docker build -f Dockerfile.amd64 -t virtualhere-server:amd64 .
docker build -f Dockerfile.arm64 -t virtualhere-server:arm64 .
docker build -f Dockerfile.arm -t virtualhere-server:arm .

# Build for current architecture (auto-detect)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) docker build -f Dockerfile.amd64 -t virtualhere-server . ;;
  aarch64) docker build -f Dockerfile.arm64 -t virtualhere-server . ;;
  armv7l) docker build -f Dockerfile.arm -t virtualhere-server . ;;
esac
```

## GitHub Actions Setup

To enable automated builds, configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

The workflow will automatically:
- Build multi-architecture images on push to main branch
- Create releases on git tags
- Perform weekly builds to get latest VirtualHere binaries
- Run security scans with Trivy

## Troubleshooting

### Container won't start

1. Check if the container has USB access:
   ```bash
   docker exec virtualhere lsusb
   ```

2. Verify USB devices are mounted:
   ```bash
   ls -la /dev/bus/usb/
   ```

### No USB devices detected

1. Ensure the host has USB devices connected
2. Check container is running with `--privileged` or proper device access
3. Verify udev rules on the host system

### Connection issues

1. Check if port 7575 is accessible:
   ```bash
   netstat -tuln | grep 7575
   ```

2. Verify firewall settings on the host
3. Test connection from VirtualHere client

### Logs and Debugging

```bash
# View container logs
docker logs virtualhere

# Interactive shell access
docker exec -it virtualhere /bin/bash

# Check running processes
docker exec virtualhere ps aux
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test them
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [VirtualHere](https://virtualhere.com/) for the excellent USB sharing software
- The Docker community for best practices and tools

## Support

- 📖 [VirtualHere Documentation](https://virtualhere.com/usb_server_software)
- 🐛 [Report Issues](https://github.com/yourusername/virtualhere-docker/issues)
- 💬 [Discussions](https://github.com/yourusername/virtualhere-docker/discussions)
