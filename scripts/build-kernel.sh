#!/usr/bin/env bash
set -euo pipefail
kernel_dir=${1:?kernel source directory}
out_dir=${2:?kernel output directory}
artifact_dir=${3:?artifact directory}
mkdir -p "$artifact_dir"
make_args=(
  O="$out_dir"
  ARCH=arm64
  LLVM=1
  DTC_EXT="${DTC_EXT:-/usr/bin/dtc}"
)
make -C "$kernel_dir" "${make_args[@]}" -j"$(nproc)" Image dtbs modules
make -C "$kernel_dir" "${make_args[@]}" INSTALL_MOD_PATH="$artifact_dir/modules" modules_install
cp "$out_dir/arch/arm64/boot/Image" "$artifact_dir/Image"
if [[ -f "$out_dir/arch/arm64/boot/Image.gz" ]]; then cp "$out_dir/arch/arm64/boot/Image.gz" "$artifact_dir/Image.gz"; fi
find "$out_dir/arch/arm64/boot/dts" -type f \( -name '*.dtb' -o -name '*.dtbo' \) -exec cp --parents {} "$artifact_dir" \;
cp "$out_dir/.config" "$artifact_dir/final.config"
cp "$out_dir/nio-docker-defconfig" "$artifact_dir/defconfig"
make -C "$kernel_dir" "${make_args[@]}" kernelrelease > "$artifact_dir/kernelrelease"
