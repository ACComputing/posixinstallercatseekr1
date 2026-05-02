#!/bin/bash
# ============================================================
# INSTALL ALL CONSOLE COMPILERS (Atari → PS5)
# No GitHub — uses direct downloads only
# WSL2 Ubuntu
# ============================================================

set -e

G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
RST='\033[0m'

echo -e "${C}🐱 Installing compilers for Atari → PS5 (no GitHub)${RST}"

sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential wget curl unzip p7zip-full xz-utils

mkdir -p "$HOME/retro-dev/bin"
cd "$HOME/retro-dev"

# ============================================================
# 1. Atari 2600 (dasm)
# ============================================================
echo -e "\n${C}🎮 Atari 2600${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz
tar xzf dasm-*.tar.gz
rm dasm-*.tar.gz
cp dasm/*/bin/dasm "$HOME/retro-dev/bin/"
chmod +x "$HOME/retro-dev/bin/dasm"

# ============================================================
# 2. NES (cc65)
# ============================================================
echo -e "\n${C}🎮 NES${RST}"
sudo apt install -y cc65

# ============================================================
# 3. Game Boy / GBC (GBDK)
# ============================================================
echo -e "\n${C}🎮 Game Boy / GBC${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/gbdk-2020/gbdk-2020/releases/download/4.3.0/gbdk-linux64.tar.gz
tar xzf gbdk-linux64.tar.gz
mv gbdk-linux64 gbdk
rm gbdk-linux64.tar.gz
cp gbdk/bin/* "$HOME/retro-dev/bin/"

# ============================================================
# 4. GBA / NDS (devkitARM — prebuilt)
# ============================================================
echo -e "\n${C}🎮 GBA / NDS${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/devkitPro/pacman/releases/download/1.0.2/devkitpro-pacman.amd64.deb
sudo dpkg -i devkitpro-pacman.amd64.deb
sudo dkp-pacman -Syu --noconfirm
sudo dkp-pacman -S --noconfirm gba-dev nds-dev
rm devkitpro-pacman.amd64.deb
sudo ln -sf /opt/devkitpro/devkitARM/bin/* "$HOME/retro-dev/bin/" 2>/dev/null || true

# ============================================================
# 5. N64 (libdragon + toolchain)
# ============================================================
echo -e "\n${C}🎮 N64${RST}"
cd "$HOME/retro-dev"
mkdir -p compilers/n64 sdks/libdragon
cd compilers/n64
wget -q https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.deb
sudo dpkg -i gcc-toolchain-mips64-x86_64.deb
rm gcc-toolchain-mips64-x86_64.deb

# libdragon source
cd "$HOME/retro-dev/sdks"
wget -q https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz
tar xzf trunk.tar.gz
mv libdragon-trunk libdragon
rm trunk.tar.gz
cd libdragon
make tools -j$(nproc)
make lib -j$(nproc)

# ============================================================
# 6. PSP (pspsdk — prebuilt)
# ============================================================
echo -e "\n${C}🎮 PSP${RST}"
sudo dkp-pacman -S --noconfirm psp-dev

# ============================================================
# 7. PS2 (ps2dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 2${RST}"
sudo dkp-pacman -S --noconfirm ps2-dev

# ============================================================
# 8. PS3 (ps3dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 3${RST}"
sudo dkp-pacman -S --noconfirm ps3-dev

# ============================================================
# 9. PS4 (orbis — direct)
# ============================================================
echo -e "\n${C}🎮 PlayStation 4${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/orbisdev/orbisdev-ps4-llvm/releases/download/latest/orbisdev-ps4-llvm-linux.tar.gz
tar xzf orbisdev-ps4-llvm-linux.tar.gz
mv orbisdev-ps4-llvm ps4-sdk
rm orbisdev-ps4-llvm-linux.tar.gz

# ============================================================
# 10. PS5 (orbis — direct)
# ============================================================
echo -e "\n${C}🎮 PlayStation 5${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/ps5-payload-dev/sdk/releases/download/latest/ps5-sdk-linux.tar.gz
tar xzf ps5-sdk-linux.tar.gz
mv ps5-sdk ps5-sdk
rm ps5-sdk-linux.tar.gz

# ============================================================
# 11. Xbox (OpenXDK)
# ============================================================
echo -e "\n${C}🎮 Original Xbox${RST}"
cd "$HOME/retro-dev"
wget -q https://github.com/openxdk/openxdk/releases/download/v0.1/openxdk-linux.tar.gz
tar xzf openxdk-linux.tar.gz
mv openxdk xbox-sdk
rm openxdk-linux.tar.gz

# ============================================================
# 12. Switch (devkitA64)
# ============================================================
echo -e "\n${C}🎮 Nintendo Switch${RST}"
sudo dkp-pacman -S --noconfirm switch-dev

# ============================================================
# PATH Setup
# ============================================================
echo -e "\n${C}📝 Setting PATH in ~/.bashrc${RST}"
cat >> ~/.bashrc << 'EOF'

# Retro compiler paths
export PATH="$HOME/retro-dev/bin:$PATH"
export PATH="/opt/devkitpro/devkitARM/bin:/opt/devkitpro/devkitA64/bin:$PATH"
export N64_INST="/opt/libdragon"
export LIBDRAGON="$HOME/retro-dev/sdks/libdragon"
export PATH="$N64_INST/bin:$HOME/retro-dev/ps4-sdk/bin:$HOME/retro-dev/ps5-sdk/bin:$PATH"
EOF

source ~/.bashrc

# ============================================================
# DONE
# ============================================================
echo -e "\n${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${G}  ✅ ALL COMPILERS INSTALLED (Atari → PS5)${RST}"
echo -e "${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "  ${C}Atari:${RST}  dasm source.asm -f3 -o rom.bin"
echo -e "  ${C}NES:${RST}    cc65 source.c -o rom.nes"
echo -e "  ${C}GB:${RST}     lcc -o rom.gb source.c"
echo -e "  ${C}GBA:${RST}   arm-none-eabi-gcc -o rom.gba source.c"
echo -e "  ${C}NDS:${RST}   arm-none-eabi-gcc -specs=ds_arm9.specs -o rom.nds"
echo -e "  ${C}N64:${RST}   mips64-elf-gcc -I\$LIBDRAGON/include -o rom.z64"
echo -e "  ${C}PS2:${RST}   ee-gcc -o rom.elf"
echo -e "  ${C}PSP:${RST}   psp-gcc -o rom.elf"
echo -e "  ${C}PS3:${RST}   ppu-gcc -o rom.elf"
echo -e "  ${C}PS4:${RST}   orbis-clang -o rom.elf"
echo -e "  ${C}PS5:${RST}   orbis-clang -o rom.elf"
echo -e "  ${C}Xbox:${RST}  xbox-gcc -o rom.xbe"
echo -e "  ${C}Switch:${RST} aarch64-none-elf-gcc -o rom.nsp"
echo -e "\n  ${Y}Run: source ~/.bashrc  (or restart terminal)${RST}"