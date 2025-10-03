#!/bin/bash
# 安装 Rust Nightly
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup default nightly

# 构建项目
cd server
cargo build --release

