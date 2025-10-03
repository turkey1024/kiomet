#!/bin/bash
set -e

echo "🚀 开始构建 Kiomet 服务器..."

# 设置环境变量
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# 安装 Rust（如果尚未安装）
if ! command -v cargo &> /dev/null; then
    echo "📦 安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
    export PATH="$CARGO_HOME/bin:$PATH"
else
    echo "✅ Rust 已安装"
fi

# 设置 nightly 工具链
echo "🦀 设置 Nightly Rust..."
rustup default nightly
rustup target add wasm32-unknown-unknown

# 进入项目目录
cd server

# 清理和修复依赖
echo "🔧 清理和修复依赖..."

# 删除可能损坏的 lock 文件
rm -f Cargo.lock 2>/dev/null || true

# 重新生成 lock 文件
cargo generate-lockfile

# 专门尝试更新 minicdn 依赖
echo "🔄 更新 minicdn 依赖..."
if cargo update minicdn 2>/dev/null; then
    echo "✅ 成功更新 minicdn"
else
    echo "⚠️  直接更新 minicdn 失败，尝试全面更新..."
    cargo update
fi

# 构建项目
echo "🔨 构建服务器..."
cargo build --release

# 检查构建结果
if [ -f "target/release/kiomet-server" ]; then
    echo "✅ 构建成功！可执行文件: target/release/kiomet-server"
    ls -la target/release/kiomet-server
else
    echo "❌ 构建失败，未找到可执行文件"
    # 列出 target/release 目录看看有什么
    ls -la target/release/ 2>/dev/null || echo "target/release 目录不存在"
    exit 1
fi

echo "🎉 所有步骤完成！"

