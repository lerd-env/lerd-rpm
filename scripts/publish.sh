#!/usr/bin/env bash
# Build the source RPM and submit it to COPR. COPR builds and publishes the
# binary rpms for every enabled chroot; users get them via dnf.
#
#   publish.sh <version> [revision]
#
# Needs copr-cli and an API token in ~/.config/copr (from
# https://copr.fedorainfracloud.org/api/).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

version="${1:?usage: publish.sh <version> [revision]}"
rev="${2:-1}"

if [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/copr" ]; then
    echo "No COPR credentials at ~/.config/copr; get a token from https://copr.fedorainfracloud.org/api/" >&2
    exit 1
fi

"$REPO_ROOT/scripts/build-srpm.sh" "$version" "$rev"

copr-cli build --nowait "$COPR_PROJECT" "$REPO_ROOT/dist/lerd-${version}-${rev}.src.rpm"

echo "Submitted lerd ${version} to COPR project ${COPR_PROJECT}."
