# lerd-rpm

> Open-source Herd-like local PHP development environment, packaged for Fedora
> and openSUSE and published to the [`georged/lerd`](https://copr.fedorainfracloud.org/coprs/georged/lerd/)
> COPR.

[![CI](https://github.com/lerd-env/lerd-rpm/actions/workflows/ci.yml/badge.svg)](https://github.com/lerd-env/lerd-rpm/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/lerd-env/lerd)](https://github.com/lerd-env/lerd/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-lerd.sh-blue)](https://lerd.sh)
[![Reddit](https://img.shields.io/badge/Reddit-r%2Flerd-ff2d20?logo=reddit)](https://reddit.com/r/lerd)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/5JK54s7xCC)

![Lerd dashboard tour](https://raw.githubusercontent.com/lerd-env/lerd/main/docs/assets/screenshots/tour.gif)

[Lerd](https://lerd.sh) runs Nginx, PHP-FPM, and your services as rootless
[Podman](https://podman.io) containers: automatic `.test` domains with HTTPS,
per-project PHP versions, one-click databases and services, a built-in web UI,
TUI, CLI and MCP server. No Docker, no sudo, no system pollution. This repo
makes it a first-class Fedora and openSUSE citizen: `dnf install lerd` (or
`zypper install lerd`) brings up the whole stack on its own, and every update
after that arrives with your normal system updates.

## Install

### Fedora

The COPR builds for every Fedora release in standard support (the project
follows Fedora branching, so new releases are picked up automatically):

```bash
sudo dnf copr enable georged/lerd
sudo dnf install lerd
lerd install
```

Updates arrive through dnf like any other package:

```bash
sudo dnf upgrade
```

### openSUSE

The COPR also builds for openSUSE Tumbleweed and Leap. zypper has no
`copr enable`, so add the repo file COPR generates for your distribution
(swap `opensuse-tumbleweed` for `opensuse-leap-16.0` on Leap):

```bash
sudo zypper addrepo https://copr.fedorainfracloud.org/coprs/georged/lerd/repo/opensuse-tumbleweed/georged-lerd.repo
sudo zypper refresh
sudo zypper install lerd
lerd install
```

Updates arrive through zypper like any other package:

```bash
sudo zypper update
```

## How it works

COPR builds binary rpms from source RPMs on Fedora's build farm. lerd needs a
very recent Go toolchain and a network-fetched Svelte UI, neither of which the
build environment can provide, so like [lerd-deb](https://github.com/lerd-env/lerd-deb)
this repo does not build lerd from source. Instead it repackages the binaries
already published on each [upstream release](https://github.com/lerd-env/lerd/releases):
the source tarball ships the prebuilt `lerd` (and `lerd-tray` on x86_64), and
the spec installs the one matching the architecture COPR is building for.

Unlike a Launchpad PPA there is nothing to upload per release series: one SRPM
is submitted per upstream version and COPR builds it for every enabled chroot,
with the `%{?dist}` tag (`.fc43`, `.fc44`, …) keeping the builds apart.

## Automation

`.github/workflows/publish.yml` polls the upstream repo daily. When a new
release appears it builds the SRPM and submits it to COPR with `copr-cli`, then
records the version in `published-version`. Manual runs are limited to repo
admins.

`.github/workflows/ci.yml` builds a binary `.rpm` in a Fedora container on
every push and asserts it installs `/usr/bin/lerd`.

## Prerequisites

The publishing workflow needs a COPR project and an API token:

- A [Fedora Account System](https://accounts.fedoraproject.org/) account that
  owns the COPR project named in `COPR_PROJECT` (`georged/lerd` by default;
  override the variable if the owner differs).
- The project created at [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org)
  with the `fedora-*-x86_64` and `fedora-*-aarch64` chroots of the current
  releases enabled, and "Follow Fedora branching" switched on so new releases
  are enabled automatically.
- The `opensuse-tumbleweed-*` and `opensuse-leap-*` chroots enabled for the
  openSUSE builds. Follow Fedora branching does not cover these, so a new Leap
  release needs its chroots enabled by hand.
- `COPR_API_CONFIG` secret: the contents of the API token file from
  [copr.fedorainfracloud.org/api](https://copr.fedorainfracloud.org/api/).

## Manual publish

```bash
sudo dnf install rpm-build copr-cli   # or: apt install rpm && pipx install copr-cli
# dry run, source RPM only:
scripts/build-srpm.sh 1.31.0
# build a binary .rpm and check it installs the binary:
scripts/build-binary.sh 1.31.0
# real submission (needs ~/.config/copr):
scripts/publish.sh 1.31.0
```
