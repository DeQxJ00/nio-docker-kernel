#!/usr/bin/env bash
set -euo pipefail
kernel_dir=${1:?kernel source directory}
out_dir=${2:?kernel output directory}
fragment=${3:?local config fragment}
mkdir -p "$out_dir"
make -C "$kernel_dir" O="$out_dir" ARCH=arm64 vendor_defconfig
merge="$kernel_dir/scripts/kconfig/merge_config.sh"
test -f "$merge"
"$merge" -m -O "$out_dir" "$out_dir/.config" \
  "$kernel_dir/arch/arm64/configs/vendor/ext_config/nio-default.config" \
  "$fragment"
make -C "$kernel_dir" O="$out_dir" ARCH=arm64 olddefconfig
make -C "$kernel_dir" O="$out_dir" ARCH=arm64 savedefconfig
cp "$out_dir/defconfig" "$out_dir/nio-docker-defconfig"

