#!/bin/bash
set -e

echo "🚀 开始构建 Kiomet 服务器..."

# 设置用户目录安装路径
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# 检查并安装 Rust
if ! command -v cargo &> /dev/null; then
    echo "📦 在用户目录安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
    export PATH="$CARGO_HOME/bin:$PATH"
    
    # 手动设置工具链
    "$CARGO_HOME/bin/rustup" default nightly
    "$CARGO_HOME/bin/rustup" target add wasm32-unknown-unknown
fi

# 确保工具链设置正确
rustup default nightly
rustup target add wasm32-unknown-unknown

# 验证安装
cargo --version
rustc --version

# 构建项目
echo "🔨 构建服务器..."
cd server
cargo build --release

echo "✅ 构建完成！"

