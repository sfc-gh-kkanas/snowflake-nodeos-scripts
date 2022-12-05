#!/bin/bash
set -euo pipefail
if [ x"$TGT" = x"" ]; then
	echo no TGT set {$TGT} fix it
	exit 44
fi

# TODO test base64 have -w flag
# macos have gbase64

COMMAND=$(gbase64 -w0 provision_target.sh)
ssh -A $TGT "echo $COMMAND | base64 -d | bash "
