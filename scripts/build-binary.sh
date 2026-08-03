#!/usr/bin/env bash
# Build a binary rpm for the host architecture and assert it installs the lerd
# binary. This is the smoke test that runs in CI and can be run on a Fedora VM.
#
#   build-binary.sh <version> [revision]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

version="${1:?usage: build-binary.sh <version> [revision]}"
rev="${2:-1}"

work="$(mktemp -d)"
bins="$work/bins"
download_binaries "$version" "$bins"

top="$work/rpmbuild"
prepare_topdir "$version" "$rev" "$bins" "$top"
rpmbuild -bb --define "_topdir $top" "$top/SPECS/lerd.spec"

rpm="$(ls "$top"/RPMS/*/lerd-*.rpm | head -1)"
echo "built: $rpm"
contents="$(rpm -qlp "$rpm")"
echo "$contents"
if ! grep -qx '/usr/bin/lerd' <<<"$contents"; then
    echo "FAIL: /usr/bin/lerd not present in the package" >&2
    exit 1
fi
mkdir -p "$REPO_ROOT/dist"
cp "$rpm" "$REPO_ROOT/dist/"
echo "OK: $(basename "$rpm") installs /usr/bin/lerd"
