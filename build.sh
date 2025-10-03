#!/bin/bash
set -e

echo "🚀 在 Render 上构建 Kiomet 项目..."

# 设置用户级 Rust 安装路径
export CARGO_HOME="/opt/render/project/src/.cargo"
export RUSTUP_HOME="/opt/render/project/src/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# 1. 安装 Rust Nightly (用户级别)
echo "🦀 安装 Rust Nightly..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
export PATH="$CARGO_HOME/bin:$PATH"

# 2. 安装 WebAssembly 目标
echo "📦 安装 WebAssembly 目标..."
rustup target add wasm32-unknown-unknown

# 3. 安装 trunk (用户级别)
echo "📦 安装 trunk..."
cargo install --locked trunk --version 0.21.0

# 4. 下载构建文件 (如果存在)
echo "📥 处理构建文件..."
if [ -f "download_makefiles.sh" ]; then
    chmod +x download_makefiles.sh
    # 在 Render 上可能无法执行下载，跳过错误
    ./download_makefiles.sh || echo "⚠️  下载脚本可能有问题，继续构建..."
fi

# 5. 构建服务端 (主要目标)
echo "🔨 构建服务端..."
cd server

# 清理和准备依赖
rm -f Cargo.lock 2>/dev/null || true
cargo generate-lockfile 2>/dev/null || true

# 构建服务端
cargo build --release

# 检查构建结果
if [ -f "target/release/kiomet-server" ]; then
    echo "✅ 服务端构建

