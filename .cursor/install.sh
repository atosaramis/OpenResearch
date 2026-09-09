#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for openresearch-cli (orx).
# Refreshes the Rust toolchain, UI dependencies, the embedded dashboard assets,
# and warms the Rust build so `cargo run -- up` starts quickly.
set -euo pipefail

cd "$(dirname "$0")/.."

# The repository pins no toolchain and CI builds with dtolnay/rust-toolchain@stable
# (latest stable). Some dependencies require edition 2024, so a base image that
# ships an older rustc will not compile. Track latest stable, matching CI.
rustup toolchain install stable --profile minimal
rustup default stable
rustup component add rustfmt clippy

# UI dependencies for both the embedded dashboard and the Vite dev server.
pnpm -C ui install --frozen-lockfile

# Regenerate ui/dist, the SPA that the Rust build embeds via rust-embed.
pnpm -C ui build

# Warm the Rust build so the backend terminal starts without a cold compile.
cargo build --locked
