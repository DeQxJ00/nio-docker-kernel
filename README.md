# Motorola edge s / moto g100 (`nio`) kernel automation

This repository keeps repeatable customization and CI machinery. It does not vendor the large LineageOS kernel tree, proprietary vendor blobs, or device partition dumps.

## Upstream mapping

The mapping is in [`upstream.yml`](upstream.yml), based on official LineageOS GitHub repositories and branch `lineage-23.2`: `android_device_motorola_nio`, `android_device_motorola_sm8250-common`, `android_kernel_motorola_sm8250`, and `android_hardware_motorola`. The device `BoardConfig.mk` adds `vendor/ext_config/nio-default.config`; the common tree declares the kernel and hardware dependencies.

The local `.github/kernel/docker.config` contains the container-oriented additions identified from the existing `base-only.config` → `final.config` delta. Device-specific options remain upstream-owned and are re-read from the upstream nio config on each build.

The kernel is configured in the same order as the official device tree: `vendor/kona-perf_defconfig`, `moto-kona.config`, `nio-default.config`, then the local eight-symbol Docker fragment. CI uses the verified AOSP Android 12 Clang `r416183b` toolchain and external system DTC (`DTC_EXT=/usr/bin/dtc`), matching the successful standalone nio build recorded for this project.

## GitHub setup

1. Create an empty GitHub repository and upload this directory. Do not upload the existing device backups or generated image dumps unless intentionally accepting that risk.
2. Enable Actions and allow the workflow to create releases. It uses the repository `GITHUB_TOKEN`; no personal token is required.
3. For flashable `boot.img`, `vendor_boot.img`, and `dtbo.img`, configure repository variable `BASE_IMAGES_URL` for a ZIP containing matching images, secret `BASE_IMAGES_SHA256`, and variable `MAGISKBOOT_URL` for a trusted pinned MagiskBoot binary. These matching base images are intentionally not checked in.

The schedule runs daily at 03:17 UTC and `workflow_dispatch` supports `force`. Changes pushed to the workflow, build scripts, kernel fragment, patches, or upstream mapping also run the resolver so CI changes are tested immediately. The resolver hashes the four official branch heads and skips a coordinate already marked by a `ci-state-*` tag. A changed coordinate is cloned, configured, built for arm64, uploaded as an artifact, and released only after success. Failed runs remain in Actions with their logs.

## Artifacts and safety

Artifacts include `Image`, optional `Image.gz`, DTB/DTBO files, modules, the final config, a defconfig, and build metadata. With base images configured, `flashable/` contains repacked boot/vendor_boot candidates and the matching dtbo image. The workflow deliberately does not rewrite `vendor.img`; that requires a device-specific AVB/ext4 procedure and fresh proprietary contents.

Do not flash directly to a daily-use phone. Verify codename, slot, boot/vendor_boot header, AVB state, module vermagic, hashes, and a complete backup first. Prefer `fastboot boot` where supported. Keep untouched stock/LineageOS images and exact rollback commands; mismatched images can soft-brick the device or break data access.

## First launch checklist

- Review `upstream.yml` and the fragment against the intended branch.
- Supply and independently verify matching base images if flashable candidates are wanted.
- Push the local files to a new repository, enable Actions, then run `workflow_dispatch` once with `force=true`.
- Inspect metadata before any hardware test. Local historical evidence records `nio`, product `nio_retcn`, model `XT2125_4`, and kernel commit `e5e04d270edd…`; this is not a substitute for current upstream resolution.
