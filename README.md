# serv00_x-ui

**A fully translated English management script for the x-ui panel on FreeBSD systems**

![GitHub release (latest by date)](https://img.shields.io/github/v/release/argh94/serv00_x-ui)
![License](https://img.shields.io/github/license/argh94/serv00_x-ui)

## Overview

`serv00_x-ui` is a Bash script designed to manage the [x-ui](https://github.com/vaxilu/x-ui) panel, a powerful user interface for controlling [Xray](https://github.com/XTLS/Xray-core) proxies. Originally developed by the creator of the [amclubs/am-serv00-x-ui](https://github.com/amclubs/am-serv00-x-ui) repository, this script has been fully translated into English and adapted for ease of use on FreeBSD systems. The goal of this project is to provide an accessible, user-friendly, and English-language tool for managing x-ui and Xray, making it easier for a global audience to deploy and maintain proxy services.

This repository includes two main scripts:

- `x-ui.sh`: The primary management script for installing, updating, starting, stopping, and configuring the x-ui panel.
- `install.sh`: A helper script that handles the installation of x-ui and Xray binaries.

## Features

- **Complete English Translation**: All messages, menus, and prompts are in English, removing the original mix of Persian and Chinese text for better accessibility.
- **Interactive Menu**: A user-friendly menu with 14 options to manage the x-ui panel, including installation, updates, port configuration, and more.
- **FreeBSD Compatibility**: Specifically tailored for FreeBSD systems with support for `amd64` and `arm64` architectures.
- **Robust Management**: Start, stop, restart, or check the status of x-ui and Xray, reset settings, manage auto-start, and more.
- **Easy Installation**: One-line `curl` command to download and run the script, with automatic installation of required binaries.

## Background

The original `x-ui.sh` and `install.sh` scripts were developed by the creator of the `amclubs/am-serv00-x-ui` repository. While highly functional, the original scripts contained a mix of Persian and Chinese messages, which could be challenging for non-native speakers. This project, maintained by [argh94](https://github.com/argh94), translates all text into English, ensuring a seamless experience for a global audience. The binary files (x-ui and Xray) are still sourced from the original `amclubs` repository and the official [Xray-core](https://github.com/XTLS/Xray-core) releases.

## Prerequisites

- **Operating System**: FreeBSD (tested on FreeBSD systems; other OSes are not supported).
- **Architecture**: `amd64` or `arm64`.
- **Dependencies**: 
  - `wget` for downloading files.
  - `unzip` for extracting Xray binaries.
  - Internet access to fetch binaries from GitHub.
- **Root Access**: Some operations (e.g., installing cron jobs) may require elevated privileges.

## Installation and Usage

### Quick Start

To get started, run the following command in your FreeBSD terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/argh94/serv00_x-ui/main/x-ui.sh -o ~/x-ui.sh && chmod +x ~/x-ui.sh && ~/x-ui.sh
```

## Dependencies

- **Binaries**: The x-ui and Xray binaries are fetched from the [amclubs](https://github.com/amclubs/am-serv00-x-ui) repository and [Xray-core](https://github.com/XTLS/Xray-core).
- **Tools**: `wget`, `unzip` (install via your package manager if not present).

## Security

While every effort has been made to ensure the safety of this script, you should **review all scripts and source code before running them on production or sensitive systems**. Use at your own risk.

## Contributing

Contributions are welcome! Please feel free to submit issues, pull requests, or suggestions to help improve the project. See [`CONTRIBUTING.md`](CONTRIBUTING.md) if available.

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.

## Acknowledgments

- Thanks to the original creator of the [amclubs/am-serv00-x-ui](https://github.com/amclubs/am-serv00-x-ui) project.
- Special thanks to the developers of [x-ui](https://github.com/vaxilu/x-ui) and [Xray-core](https://github.com/XTLS/Xray-core).
- English translation, FreeBSD adaptation, and maintenance by [argh94](https://github.com/argh94).

## Contact

For questions, support, or feedback, please open an issue on [GitHub](https://github.com/argh94/serv00_x-ui/issues).
