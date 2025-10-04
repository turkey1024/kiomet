#!/bin/bash
set -e

echo "🚀 在 Render 上构建 Kiomet 服务端..."

export CARGO_HOME="/opt/render/project/src/.cargo"
export RUSTUP_HOME="/opt/render/project/src/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
export PATH="$CARGO_HOME/bin:$PATH"

cd server

# 清理并更新所有依赖
cargo clean
cargo update

# 构建
cargo build --release

echo "✅ 构建完成!"

