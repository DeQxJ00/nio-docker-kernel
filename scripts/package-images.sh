#!/usr/bin/env bash
set -euo pipefail
artifact_dir=${1:?artifact directory}
base_dir=${2:?base image directory}
tool=${MAGISKBOOT:-magiskboot}
out="$artifact_dir/flashable"
mkdir -p "$out"
for f in boot.img vendor_boot.img dtbo.img; do
  test -f "$base_dir/$f"
done
command -v "$tool" >/dev/null 2>&1 || test -x "$tool"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
for image in boot vendor_boot; do
  mkdir "$work/$image"
  cp "$base_dir/$image.img" "$work/$image/original.img"
  (cd "$work/$image" && "$tool" unpack original.img >/dev/null)
  test -f "$work/$image/kernel"
  cp "$artifact_dir/Image" "$work/$image/kernel"
  (cd "$work/$image" && "$tool" repack original.img "$out/$image.img" >/dev/null)
done
cp "$base_dir/dtbo.img" "$out/dtbo.img"
echo 'dtbo.img is retained from the matching base image; built DTB/DTBO files are in the parent artifact.' > "$out/README.txt"
sha256sum "$out"/*.img > "$out/SHA256SUMS"

