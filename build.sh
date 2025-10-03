#!/bin/bash
set -e

echo "🚀 开始构建 Kiomet 服务器..."

# 设置 PATH（无论 Rust 是否已安装）
export PATH="$HOME/.cargo/bin:$PATH"

# 检查并安装 Rust
if ! command -v cargo &> /dev/null; then
    echo "📦 安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# 验证 Rust 安装
cargo --version || {
    echo "❌ Rust 安装失败"
    exit 1
}

# 设置 nightly 工具链
echo "🦀 设置 Nightly Rust..."
rustup default nightly
rustup target add wasm32-unknown-unknown

# 构建项目
echo "🔨 构建服务器..."
cd server
cargo build --release

echo "✅ 构建完成！"

