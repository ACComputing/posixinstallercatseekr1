#!/bin/bash
# ============================================================
# INSTALL ATARI → PS5 COMPILERS
# Atari, NES, GB, GBA, NDS, 3DS, N64, PS2, PSP, PS3, PS4, PS5
# ============================================================

set -eo pipefail

mkdir -p "$HOME/retro-dev/bin"

# devkitPro pacman lives here; `sudo` resets PATH so call it explicitly
DKP_PM="/opt/devkitpro/tools/bin/dkp-pacman"
sudo_dkp() { sudo env "PATH=/opt/devkitpro/tools/bin:$PATH" "$DKP_PM" "$@"; }

G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
RST='\033[0m'

echo -e "${C}🐱 Installing Atari → PS5 Compilers${RST}"

sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential wget curl git cmake unzip p7zip-full

# ============================================================
# 1. Atari 2600 (dasm) — already installed
# ============================================================
echo -e "\n${C}🎮 Atari 2600${RST}"
if ! command -v dasm &>/dev/null; then
    mkdir -p ~/retro-dev/atari
    cd ~/retro-dev/atari
    wget -q https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz
    tar xzf dasm-*.tar.gz
    rm dasm-*.tar.gz
    # Release tarball has the binary at ./dasm (not dasm/dasm)
    sudo cp ./dasm /usr/local/bin/dasm 2>/dev/null || cp ./dasm "$HOME/retro-dev/bin/dasm"
    echo -e "${G}✓ dasm installed${RST}"
else
    echo -e "${G}✓ dasm already installed${RST}"
fi

# ============================================================
# 2. NES (cc65) — already installed
# ============================================================
echo -e "\n${C}🎮 NES${RST}"
sudo apt install -y cc65
echo -e "${G}✓ cc65 ready${RST}"

# ============================================================
# 3. Game Boy (GBDK) — already installed
# ============================================================
echo -e "\n${C}🎮 Game Boy / GBC${RST}"
if ! command -v lcc &>/dev/null; then
    cd ~/retro-dev
    wget -q https://github.com/gbdk-2020/gbdk-2020/releases/download/4.3.0/gbdk-linux64.tar.gz
    tar xzf gbdk-linux64.tar.gz
    rm gbdk-linux64.tar.gz
    # 4.3.0 archive unpacks to gbdk/ (older releases used gbdk-linux64/)
    echo 'export PATH="$HOME/retro-dev/gbdk/bin:$PATH"' >> ~/.bashrc
    echo -e "${G}✓ GBDK installed${RST}"
else
    echo -e "${G}✓ GBDK already installed${RST}"
fi

# ============================================================
# 4. GBA/NDS/3DS (devkitARM) — already installed
# ============================================================
echo -e "\n${C}🎮 GBA / NDS / 3DS${RST}"
if [[ ! -x "$DKP_PM" ]]; then
    cd ~/retro-dev
    wget -q https://github.com/devkitPro/pacman/releases/download/1.0.2/devkitpro-pacman.amd64.deb
    sudo dpkg -i devkitpro-pacman.amd64.deb
    rm -f devkitpro-pacman.amd64.deb
fi
# Do not treat Ubuntu's gcc-arm-none-eabi (/usr/bin) as devkitPro — we need dkp-pacman for PS2/PSP/PS3
if [[ ! -x /opt/devkitpro/devkitARM/bin/arm-none-eabi-gcc ]]; then
    sudo_dkp -Syu --noconfirm
    sudo_dkp -S --noconfirm gba-dev nds-dev 3ds-dev
    echo -e "${G}✓ devkitARM installed${RST}"
else
    echo -e "${G}✓ devkitARM already installed${RST}"
fi

# ============================================================
# 5. PS2 (ps2dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 2${RST}"
if ! command -v ee-gcc &>/dev/null; then
    sudo_dkp -S --noconfirm ps2-dev || {
        echo "Trying manual PS2 install..."
        cd ~/retro-dev
        git clone https://github.com/ps2dev/ps2toolchain.git
        cd ps2toolchain
        ./toolchain.sh
    }
    echo -e "${G}✓ PS2 toolchain installed${RST}"
else
    echo -e "${G}✓ PS2 already installed${RST}"
fi

# ============================================================
# 6. PSP (pspsdk)
# ============================================================
echo -e "\n${C}🎮 PSP${RST}"
if ! command -v psp-gcc &>/dev/null; then
    sudo_dkp -S --noconfirm psp-dev || {
        cd ~/retro-dev
        git clone https://github.com/pspdev/psptoolchain.git
        cd psptoolchain
        ./toolchain.sh
    }
    echo -e "${G}✓ PSP toolchain installed${RST}"
else
    echo -e "${G}✓ PSP already installed${RST}"
fi

# ============================================================
# 7. PS3 (ps3dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 3${RST}"
if ! command -v ppu-gcc &>/dev/null; then
    sudo_dkp -S --noconfirm ps3-dev || {
        cd ~/retro-dev
        git clone https://github.com/ps3dev/ps3toolchain.git
        cd ps3toolchain
        ./toolchain.sh
    }
    echo -e "${G}✓ PS3 toolchain installed${RST}"
else
    echo -e "${G}✓ PS3 already installed${RST}"
fi

# ============================================================
# 8. PS4 (orbis)
# ============================================================
echo -e "\n${C}🎮 PlayStation 4${RST}"
if ! command -v orbis-clang &>/dev/null; then
    cd ~/retro-dev
    git clone --depth 1 https://github.com/orbisdev/orbisdev-ps4-llvm.git ps4-sdk
    cd ps4-sdk
    ./build.sh
    echo 'export PATH="$HOME/retro-dev/ps4-sdk/bin:$PATH"' >> ~/.bashrc
    echo -e "${G}✓ PS4 toolchain installed${RST}"
else
    echo -e "${G}✓ PS4 already installed${RST}"
fi

# ============================================================
# 9. PS5 (orbis) — check SDK dir, not orbis-clang (PS4 may already provide that name)
# ============================================================
echo -e "\n${C}🎮 PlayStation 5${RST}"
if ! [[ -x "$HOME/retro-dev/ps5-sdk/bin/orbis-clang" ]]; then
    cd ~/retro-dev
    git clone --depth 1 https://github.com/ps5-payload-dev/sdk.git ps5-sdk
    cd ps5-sdk
    make -j$(nproc)
    echo 'export PATH="$HOME/retro-dev/ps5-sdk/bin:$PATH"' >> ~/.bashrc
    echo -e "${G}✓ PS5 toolchain installed${RST}"
else
    echo -e "${G}✓ PS5 already installed${RST}"
fi

# ============================================================
# 10. N64 (libdragon) — already installed
# ============================================================
echo -e "\n${C}🎮 N64${RST}"
if ! command -v mips64-elf-gcc &>/dev/null; then
    mkdir -p ~/retro-dev/compilers/n64
    cd ~/retro-dev/compilers/n64
    wget -q https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.deb
    sudo dpkg -i gcc-toolchain-mips64-x86_64.deb
    rm gcc-toolchain-mips64-x86_64.deb
    echo -e "${G}✓ N64 toolchain installed${RST}"
else
    echo -e "${G}✓ N64 already installed${RST}"
fi

# ============================================================
# PATH and finalize
# ============================================================
echo -e "\n${C}📝 Updating PATH${RST}"
cat >> ~/.bashrc << 'EOF'

# Atari → PS5 paths
export PATH="$HOME/retro-dev/bin:$PATH"
export PATH="$HOME/retro-dev/gbdk/bin:$PATH"
export PATH="/opt/devkitpro/devkitARM/bin:$PATH"
export PATH="$HOME/retro-dev/ps4-sdk/bin:$HOME/retro-dev/ps5-sdk/bin:$PATH"
export PATH="/opt/libdragon/bin:$PATH"
EOF

source ~/.bashrc

# ============================================================
# VERIFICATION
# ============================================================
echo -e "\n${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${G}  ✅ ATARI → PS5 COMPILERS INSTALLED${RST}"
echo -e "${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "  ${C}Atari:${RST}  dasm"
echo -e "  ${C}NES:${RST}    cc65"
echo -e "  ${C}GB:${RST}     lcc"
echo -e "  ${C}GBA/NDS/3DS:${RST} arm-none-eabi-gcc"
echo -e "  ${C}N64:${RST}   mips64-elf-gcc"
echo -e "  ${C}PS2:${RST}   ee-gcc"
echo -e "  ${C}PSP:${RST}   psp-gcc"
echo -e "  ${C}PS3:${RST}   ppu-gcc"
echo -e "  ${C}PS4/PS5:${RST} orbis-clang"

echo -e "\n${Y}Run: source ~/.bashrc${RST}"
echo -e "${G}🐱 Captain DeepSeek — Mission Complete!${RST}"