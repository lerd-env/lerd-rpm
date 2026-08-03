#!/usr/bin/env bash
# Shared helpers for building lerd RPM packages from upstream release binaries.
# Sourced by build-srpm.sh, build-binary.sh and publish.sh.
set -euo pipefail

RELEASE_REPO="lerd-env/lerd"

# COPR project to publish to, as owner/project.
COPR_PROJECT="${COPR_PROJECT:-georged/lerd}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# download_binaries <version> <destdir>
# Lays the release binaries out as <destdir>/{amd64,arm64}/lerd (+ amd64/lerd-tray).
download_binaries() {
    local version="$1" dest="$2"
    local base="https://github.com/${RELEASE_REPO}/releases/download/v${version}"
    local tmp; tmp="$(mktemp -d)"
    mkdir -p "$dest/amd64" "$dest/arm64"
    curl -fsSL -o "$tmp/amd64.tgz" "$base/lerd_${version}_linux_amd64.tar.gz"
    curl -fsSL -o "$tmp/arm64.tgz" "$base/lerd_${version}_linux_arm64.tar.gz"
    tar -xzf "$tmp/amd64.tgz" -C "$dest/amd64" lerd lerd-tray
    tar -xzf "$tmp/arm64.tgz" -C "$dest/arm64" lerd
    chmod 0755 "$dest"/amd64/lerd "$dest"/amd64/lerd-tray "$dest"/arm64/lerd
    rm -rf "$tmp"
}

# prepare_topdir <version> <revision> <binaries_dir> <topdir>
# Lays out an rpmbuild _topdir with the rendered spec and the source tarball.
# One SRPM covers every chroot; %{?dist} keeps the builds apart.
prepare_topdir() {
    local version="$1" rev="$2" bins="$3" top="$4"
    local tree="$top/tree/lerd-$version"
    rm -rf "$top"
    mkdir -p "$top/SPECS" "$top/SOURCES" "$tree/prebuilt"
    cp -r "$bins/amd64" "$tree/prebuilt/amd64"
    cp -r "$bins/arm64" "$tree/prebuilt/arm64"
    cp "$REPO_ROOT/LICENSE" "$tree/LICENSE"
    tar -czf "$top/SOURCES/lerd-$version.tar.gz" -C "$top/tree" "lerd-$version"
    sed -e "s/@VERSION@/$version/g" \
        -e "s/@REVISION@/$rev/g" \
        -e "s/@DATE@/$(LC_ALL=C date '+%a %b %d %Y')/g" \
        "$REPO_ROOT/lerd.spec.in" > "$top/SPECS/lerd.spec"
}
