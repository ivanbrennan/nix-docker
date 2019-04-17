#!/bin/sh

set -eu

NIX_RELEASE=2.1.3
NIX_HASH=3169d05aa713f6ffa774f001cae133557d3ad72e23d9b6f6ebbddd77b477304f
DOWNLOAD_URL="https://nixos.org/releases/nix/nix-${NIX_RELEASE}/nix-${NIX_RELEASE}-x86_64-linux.tar.bz2"

sudo addgroup -g 30000 -S nixbld
for i in $(seq 1 30)
do
    sudo adduser -S -D -h /var/empty -g "Nix build user $i" -u $((30000 + i)) -G nixbld nixbld$i
done

set -x

wget -O nix.tar.bz2 $DOWNLOAD_URL
echo "$NIX_HASH  nix.tar.bz2" | sha256sum -c
tar xjf nix.tar.bz2
sh nix-*-x86_64-linux/install
rm -r nix.tar.bz2 nix-*-x86_64-linux*

bin=/nix/var/nix/profiles/per-user/$USER/profile/bin
$bin/nix-collect-garbage --delete-old
$bin/nix-store --optimise
$bin/nix-store --verify --check-contents
