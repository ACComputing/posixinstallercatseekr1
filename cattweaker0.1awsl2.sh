#!/bin/bash
# CAT TWEAKER — Ubuntu WSL2 Edition
# Atari 2600 + N64 + PS5 cross-compiler module

set -e

G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
RST='\033[0m'

echo -e "${C}🐱 CAT TWEAKER — Installing cross-compilers for WSL2${RST}"

# Update system
sudo apt update && sudo apt upgrade -y

# Common dependencies
sudo apt install -y build-essential git wget curl cmake ninja-build clang lld llvm

# ============================================================
# 1. Atari 2600/7800 Toolchain (dasm)
# ============================================================
echo -e "\n${C}▸ Installing Atari 2600/7800 assembler (dasm)${RST}"
mkdir -p "$HOME/retro-dev/atari"
cd "$HOME/retro-dev/atari"
wget -q https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz
tar xzf dasm-*.tar.gz
rm dasm-*.tar.gz
echo -e "${G}✓ dasm installed${RST}"

# ============================================================
# 2. N64 Toolchain (libdragon)
# ============================================================
echo -e "\n${C}▸ Installing N64 toolchain (libdragon)${RST}"
mkdir -p "$HOME/retro-dev/compilers/n64"
cd "$HOME/retro-dev/compilers/n64"

# Download and install .deb
wget -q https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.deb
sudo dpkg -i gcc-toolchain-mips64-x86_64.deb
rm gcc-toolchain-mips64-x86_64.deb

export N64_INST="/opt/libdragon"
export PATH="$N64_INST/bin:$PATH"

# Build libdragon
mkdir -p "$HOME/retro-dev/sdks"
cd "$HOME/retro-dev/sdks"
wget -q https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz
tar xzf trunk.tar.gz
mv libdragon-trunk libdragon
rm trunk.tar.gz

cd libdragon
make tools -j$(nproc)
make lib -j$(nproc)
echo -e "${G}✓ libdragon built${RST}"

# ============================================================
# 3. PS5 Open-Source Toolchain (orbis)
# ============================================================
echo -e "\n${C}▸ Installing PS5 homebrew toolchain (orbis)${RST}"
mkdir -p "$HOME/retro-dev/ps5"
cd "$HOME/retro-dev/ps5"
git clone --depth 1 https://github.com/ps5-payload-dev/sdk.git orbis-sdk
cd orbis-sdk
make -j$(nproc)
echo -e "${G}✓ PS5 orbis toolchain ready${RST}"

# ============================================================
# 4. Environment Setup
# ============================================================
echo -e "\n${C}▸ Adding environment variables to ~/.bashrc${RST}"
cat >> "$HOME/.bashrc" << 'EOF'

# CAT TWEAKER — Cross-compiler paths
export PATH="$HOME/retro-dev/atari:$PATH"
export N64_INST="/opt/libdragon"
export LIBDRAGON="$HOME/retro-dev/sdks/libdragon"
export PATH="$N64_INST/bin:$HOME/retro-dev/ps5/orbis-sdk/bin:$PATH"
EOF

source "$HOME/.bashrc"

# ============================================================
# 5. Verification
# ============================================================
echo -e "\n${C}▸ Verification${RST}"
echo -n "  Atari (dasm): "
dasm --version 2>/dev/null | head -1 || echo "not found"
echo -n "  N64 (mips64-elf-gcc): "
mips64-elf-gcc --version 2>/dev/null | head -1 || echo "not found"
echo -n "  PS5 (orbis-ld): "
orbis-ld --version 2>/dev/null | head -1 || echo "not found"

echo -e "\n${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${G}  ✅ CAT TWEAKER — All toolchains installed!${RST}"
echo -e "${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "  ${C}Atari 2600:${RST}  dasm source.asm -f3 -o output.bin"
echo -e "  ${C}N64:${RST}        cd \$LIBDRAGON/examples/simple && make"
echo -e "  ${C}PS5:${RST}       orbis-ld -T ps5.ld -o game.elf game.o"
echo -e "\n  ${Y}Run: source ~/.bashrc  (or restart terminal)${RST}"