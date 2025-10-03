#!/bin/bash
set -e  # 遇到错误立即退出

echo "🚀 开始构建 Kiomet 服务器..."

# 安装 Rust（如果尚未安装）
if ! command -v rustup &> /dev/null; then
    echo "📦 安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# 加载 Rust 环境
source "$HOME/.cargo/env"

# 设置 nightly 工具链
echo "🦀 设置 Nightly Rust..."
rustup default nightly
rustup target add wasm32-unknown-unknown

# 构建项目
echo "🔨 构建服务器..."
cd server
cargo build --release

echo "✅ 构建完成！"

