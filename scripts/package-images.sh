#!/usr/bin/env bash
set -euo pipefail
artifact_dir=$(realpath "${1:?artifact directory}")
base_dir=$(realpath "${2:?base image directory}")
tool=${MAGISKBOOT:-magiskboot}
if [[ "$tool" == */* ]]; then
  tool=$(realpath "$tool")
else
  tool=$(command -v "$tool")
fi
out="$artifact_dir/flashable"
mkdir -p "$out"
for f in boot.img vendor_boot.img dtbo.img; do
  test -f "$base_dir/$f"
done
test -x "$tool"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/boot"
cp "$base_dir/boot.img" "$work/boot/original.img"
(cd "$work/boot" && "$tool" unpack original.img >/dev/null)
test -f "$work/boot/kernel"
cp "$artifact_dir/Image" "$work/boot/kernel"
(cd "$work/boot" && "$tool" repack original.img "$out/boot.img" >/dev/null)
cp "$base_dir/vendor_boot.img" "$out/vendor_boot.img"
cp "$base_dir/dtbo.img" "$out/dtbo.img"
printf '%s\n' \
  'boot.img is repacked from the matching official LineageOS image with the newly built Image.' \
  'vendor_boot.img is retained from the matching official LineageOS build; nio vendor_boot contains ramdisk and dtb, not the kernel.' \
  'dtbo.img is retained from the matching official LineageOS build; built DTB/DTBO files are in the parent artifact.' \
  > "$out/README.txt"
(cd "$out" && sha256sum ./*.img > SHA256SUMS)
