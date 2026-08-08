# Motorola edge s / moto g100 (`nio`) kernel automation

This repository keeps repeatable customization and CI machinery. It does not vendor the large LineageOS kernel tree, proprietary vendor blobs, or device partition dumps.

## Upstream mapping

The mapping is in [`upstream.yml`](upstream.yml), based on official LineageOS GitHub repositories and branch `lineage-23.2`: `android_device_motorola_nio`, `android_device_motorola_sm8250-common`, `android_kernel_motorola_sm8250`, and `android_hardware_motorola`. The device `BoardConfig.mk` adds `vendor/ext_config/nio-default.config`; the common tree declares the kernel and hardware dependencies.

The local `.github/kernel/docker.config` contains the container-oriented additions identified from the existing `base-only.config` → `final.config` delta. Device-specific options remain upstream-owned and are re-read from the upstream nio config on each build.

The kernel is configured in the same order as the official device tree: `vendor/kona-perf_defconfig`, `moto-kona.config`, `nio-default.config`, then the local eight-symbol Docker fragment. CI uses the verified AOSP Android 12 Clang `r416183b` toolchain and external system DTC (`DTC_EXT=/usr/bin/dtc`), matching the successful standalone nio build recorded for this project.

## GitHub setup

1. Create an empty GitHub repository and upload this directory. Do not upload the existing device backups or generated image dumps unless intentionally accepting that risk.
2. Enable Actions and allow the workflow to create releases. It uses the repository `GITHUB_TOKEN`; no personal token is required.
3. No base-image secret is required. The resolver reads the official LineageOS nio downloads API, includes the latest signed build in the update key, and downloads its separately published `boot.img`, `vendor_boot.img`, and `dtbo.img` with their official SHA-256 values. A pinned official Magisk APK supplies the Linux `magiskboot` repacker.

The schedule runs daily at 03:17 UTC, every push to `master` runs the workflow, and `workflow_dispatch` supports `force`. The resolver hashes the four official branch heads and skips a coordinate already marked by a `ci-state-*` tag, so a normal push does not rebuild an already successful upstream coordinate. A changed coordinate is cloned, configured, built for arm64, uploaded as an artifact, and released only after success. Failed runs remain in Actions with their logs.

## Artifacts and safety

Artifacts include `Image`, optional `Image.gz`, DTB/DTBO files, modules, the final config, a defconfig, and build metadata. `flashable/` contains a repacked boot candidate plus the unchanged matching official LineageOS vendor_boot and dtbo images. The nio vendor_boot contains its vendor ramdisk and DTB rather than the kernel, so only boot is repacked. The workflow deliberately does not rewrite `vendor.img`; that requires a device-specific AVB/ext4 procedure and fresh proprietary contents.

Do not flash directly to a daily-use phone. Verify codename, slot, boot/vendor_boot header, AVB state, module vermagic, hashes, and a complete backup first. Prefer `fastboot boot` where supported. Keep untouched stock/LineageOS images and exact rollback commands; mismatched images can soft-brick the device or break data access.

## First launch checklist

- Review `upstream.yml` and the fragment against the intended branch.
- Confirm the resolved official LineageOS build in `build-metadata.txt` before testing its flashable candidates.
- Push the local files to a new repository, enable Actions, then run `workflow_dispatch` once with `force=true`.
- Inspect metadata before any hardware test. Local historical evidence records `nio`, product `nio_retcn`, model `XT2125_4`, and kernel commit `e5e04d270edd…`; this is not a substitute for current upstream resolution.
