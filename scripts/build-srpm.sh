#!/usr/bin/env bash
# Build the source RPM into dist/. This is what gets uploaded to COPR; the COPR
# build farm compiles it into binary rpms for every enabled chroot.
#
#   build-srpm.sh <version> [revision]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

version="${1:?usage: build-srpm.sh <version> [revision]}"
rev="${2:-1}"

work="$(mktemp -d)"
bins="$work/bins"
download_binaries "$version" "$bins"

top="$work/rpmbuild"
prepare_topdir "$version" "$rev" "$bins" "$top"
rpmbuild -bs --define "_topdir $top" --undefine dist "$top/SPECS/lerd.spec"

mkdir -p "$REPO_ROOT/dist"
cp "$top"/SRPMS/lerd-*.src.rpm "$REPO_ROOT/dist/"

echo "Source RPM in dist/:"
ls -1 "$REPO_ROOT/dist/"lerd-*.src.rpm
