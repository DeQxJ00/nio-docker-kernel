#!/usr/bin/env bash
set -euo pipefail
kernel_dir=$(realpath "${1:?kernel source directory}")
out_dir=$(realpath -m "${2:?kernel output directory}")
fragment=$(realpath "${3:?local config fragment}")
mkdir -p "$out_dir"
make_args=(
  O="$out_dir"
  ARCH=arm64
  LLVM=1
  DTC_EXT="${DTC_EXT:-/usr/bin/dtc}"
)
make -C "$kernel_dir" "${make_args[@]}" vendor/kona-perf_defconfig
merge="$kernel_dir/scripts/kconfig/merge_config.sh"
test -f "$merge"
"$merge" -m -O "$out_dir" "$out_dir/.config" \
  "$kernel_dir/arch/arm64/configs/vendor/ext_config/moto-kona.config" \
  "$kernel_dir/arch/arm64/configs/vendor/ext_config/nio-default.config" \
  "$fragment"
make -C "$kernel_dir" "${make_args[@]}" olddefconfig
make -C "$kernel_dir" "${make_args[@]}" savedefconfig
cp "$out_dir/defconfig" "$out_dir/nio-docker-defconfig"
