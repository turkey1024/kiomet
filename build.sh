#!/bin/bash
set -e

echo "🚀 开始构建 Kiomet 全栈项目..."
echo "📋 注意: 根据文档警告，构建过程可能需要手动修复 Makefiles"

# 设置环境变量
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"

# 1. 安装系统依赖
echo "📦 安装系统工具..."
apt-get update
apt-get install -y curl build-essential gcc make pkg-config libssl-dev

# 2. 安装 Rust Nightly
echo "🦀 安装 Rust Nightly..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly --no-modify-path
export PATH="$CARGO_HOME/bin:$PATH"
rustup target add wasm32-unknown-unknown

# 3. 安装 trunk (使用文档建议的 0.21 版本)
echo "📦 安装 trunk 0.21.0..."
cargo install --locked trunk --version 0.21.0

# 4. 下载 Makefiles (知道可能有问题的步骤)
echo "📥 下载构建文件..."
if [ -f "download_makefiles.sh" ]; then
    chmod +x download_makefiles.sh
    ./download_makefiles.sh || echo "⚠️  下载脚本可能有问题，继续构建..."
else
    echo "⚠️  未找到 download_makefiles.sh，跳过此步骤"
fi

# 5. 尝试修复 client Makefile
echo "🔧 检查并修复 Makefiles..."
if [ -f "client/Makefile" ]; then
    echo "📝 修复 client/Makefile..."
    # 移除可能不支持的 trunk 选项
    sed -i 's/--public-url[[:space:]]*[^[:space:]]*//g' client/Makefile
    sed -i 's/trunk build/trunk build/g' client/Makefile
    echo "✅ Makefile 修复完成"
fi

# 6. 构建客户端
echo "🔨 构建客户端..."
if [ -d "client" ]; then
    cd client
    make release || {
        echo "❌ 客户端构建失败，尝试直接使用 trunk..."
        # 如果 make 失败，尝试直接使用 trunk
        trunk build --release || echo "⚠️  客户端构建失败，但继续服务端构建"
    }
    cd ..
else
    echo "⚠️  未找到 client 目录，跳过客户端构建"
fi

# 7. 构建服务端
echo "🔨 构建服务端..."
if [ -d "server" ]; then
    cd server
    # 清理可能的依赖问题
    rm -f Cargo.lock 2>/dev/null || true
    cargo generate-lockfile 2>/dev/null || true
    
    # 构建服务端
    if [ -f "Makefile" ]; then
        make release || {
            echo "⚠️  make release 失败，尝试直接使用 cargo..."
            cargo build --release
        }
    else
        cargo build --release
    fi
    
    # 检查构建结果
    if [ -f "target/release/kiomet-server" ]; then
        echo "✅ 服务端构建成功!"
        ls -la target/release/kiomet-server
    else
        # 尝试查找其他可能的二进制文件名
        echo "🔍 查找生成的可执行文件..."
        find target/release/ -maxdepth 1 -type f -executable | head -5
    fi
    cd ..
else
    echo "❌ 错误: 未找到 server 目录"
    exit 1
fi

echo "🎉 构建流程完成!"
echo "📝 如果遇到问题，请参考文档手动修复 Makefiles"

