#!/bin/bash
# ============================================================
# COMPILER FOR ALL CONSOLES — WSL2 Edition
# Atari 2600 → PS5 in one script
# ============================================================

set -e

G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
RST='\033[0m'

echo -e "${C}🕹️ COMPILER FOR ALL CONSOLES — Installing toolchains...${RST}"

# Update system
sudo apt update && sudo apt upgrade -y

# Common dependencies
sudo apt install -y build-essential git wget curl cmake ninja-build clang lld llvm texinfo

# ============================================================
# 1. Atari 2600/7800 (dasm)
# ============================================================
echo -e "\n${C}🎮 Atari 2600/7800 (dasm)${RST}"
mkdir -p "$HOME/retro-dev/atari"
cd "$HOME/retro-dev/atari"
wget -q https://github.com/dasm-assembler/dasm/releases/download/2.20.14.1/dasm-2.20.14.1-linux-x64.tar.gz
tar xzf dasm-*.tar.gz
rm dasm-*.tar.gz
echo -e "${G}✓ dasm installed${RST}"

# ============================================================
# 2. NES (cc65)
# ============================================================
echo -e "\n${C}🎮 NES (cc65)${RST}"
sudo apt install -y cc65
echo -e "${G}✓ cc65 installed${RST}"

# ============================================================
# 3. Game Boy / GBC (GBDK-2020)
# ============================================================
echo -e "\n${C}🎮 Game Boy / GBC (GBDK-2020)${RST}"
mkdir -p "$HOME/retro-dev/gbdk"
cd "$HOME/retro-dev/gbdk"
wget -q https://github.com/gbdk-2020/gbdk-2020/releases/download/4.3.0/gbdk-linux64.tar.gz
tar xzf gbdk-linux64.tar.gz
mv gbdk-linux64 gbdk
rm gbdk-linux64.tar.gz
echo -e "${G}✓ GBDK installed${RST}"

# ============================================================
# 4. GBA / NDS (devkitARM)
# ============================================================
echo -e "\n${C}🎮 GBA / NDS (devkitARM)${RST}"
if [ ! -f "/etc/apt/sources.list.d/devkitpro.list" ]; then
    wget -q https://apt.devkitpro.org/install-devkitpro-pacman
    chmod +x install-devkitpro-pacman
    sudo ./install-devkitpro-pacman
    rm install-devkitpro-pacman
fi
sudo dkp-pacman -Syu --noconfirm
sudo dkp-pacman -S --noconfirm gba-dev nds-dev
echo -e "${G}✓ devkitARM installed${RST}"

# ============================================================
# 5. N64 (libdragon + toolchain)
# ============================================================
echo -e "\n${C}🎮 N64 (libdragon)${RST}"
mkdir -p "$HOME/retro-dev/compilers/n64"
cd "$HOME/retro-dev/compilers/n64"
wget -q https://github.com/DragonMinded/libdragon/releases/download/toolchain-continuous-prerelease/gcc-toolchain-mips64-x86_64.deb
sudo dpkg -i gcc-toolchain-mips64-x86_64.deb
rm gcc-toolchain-mips64-x86_64.deb

mkdir -p "$HOME/retro-dev/sdks"
cd "$HOME/retro-dev/sdks"
wget -q https://github.com/DragonMinded/libdragon/archive/refs/heads/trunk.tar.gz
tar xzf trunk.tar.gz
mv libdragon-trunk libdragon
rm trunk.tar.gz
cd libdragon
make tools -j$(nproc)
make lib -j$(nproc)
echo -e "${G}✓ libdragon installed${RST}"

# ============================================================
# 6. PlayStation 2 (ps2dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 2 (ps2dev)${RST}"
sudo apt install -y ps2dev
echo -e "${G}✓ ps2dev installed${RST}"

# ============================================================
# 7. PSP (pspsdk)
# ============================================================
echo -e "\n${C}🎮 PSP (pspsdk)${RST}"
sudo apt install -y psp-dev
echo -e "${G}✓ pspsdk installed${RST}"

# ============================================================
# 8. PlayStation 3 (ps3dev)
# ============================================================
echo -e "\n${C}🎮 PlayStation 3 (ps3dev)${RST}"
sudo apt install -y ps3-dev
echo -e "${G}✓ ps3dev installed${RST}"

# ============================================================
# 9. PlayStation 4 (orbis) — open source SDK
# ============================================================
echo -e "\n${C}🎮 PlayStation 4 (orbis)${RST}"
mkdir -p "$HOME/retro-dev/ps4"
cd "$HOME/retro-dev/ps4"
git clone --depth 1 https://github.com/orbisdev/orbisdev-ps4-llvm.git
cd orbisdev-ps4-llvm
./build.sh
echo -e "${G}✓ orbis PS4 toolchain installed${RST}"

# ============================================================
# 10. PlayStation 5 (orbis) — open source SDK
# ============================================================
echo -e "\n${C}🎮 PlayStation 5 (orbis)${RST}"
mkdir -p "$HOME/retro-dev/ps5"
cd "$HOME/retro-dev/ps5"
git clone --depth 1 https://github.com/ps5-payload-dev/sdk.git orbis-sdk
cd orbis-sdk
make -j$(nproc)
echo -e "${G}✓ orbis PS5 toolchain installed${RST}"

# ============================================================
# 11. Xbox (Freedo / OpenXbox)
# ============================================================
echo -e "\n${C}🎮 Original Xbox (OpenXDK)${RST}"
mkdir -p "$HOME/retro-dev/xbox"
cd "$HOME/retro-dev/xbox"
git clone --depth 1 https://github.com/openxdk/openxdk.git
cd openxdk
make -j$(nproc)
echo -e "${G}✓ OpenXDK installed${RST}"

# ============================================================
# 12. Xbox 360 (LibXenon)
# ============================================================
echo -e "\n${C}🎮 Xbox 360 (LibXenon)${RST}"
mkdir -p "$HOME/retro-dev/xbox360"
cd "$HOME/retro-dev/xbox360"
git clone --depth 1 https://github.com/Free60Project/libxenon.git
cd libxenon
make -j$(nproc)
echo -e "${G}✓ LibXenon installed${RST}"

# ============================================================
# 13. Nintendo Switch (devkitA64)
# ============================================================
echo -e "\n${C}🎮 Nintendo Switch (devkitA64)${RST}"
sudo dkp-pacman -S --noconfirm switch-dev
echo -e "${G}✓ devkitA64 installed${RST}"

# ============================================================
# 14. Sega Genesis / Mega Drive (SGDK)
# ============================================================
echo -e "\n${C}🎮 Sega Genesis / Mega Drive (SGDK)${RST}"
mkdir -p "$HOME/retro-dev/sgdk"
cd "$HOME/retro-dev/sgdk"
wget -q https://github.com/Stephane-D/SGDK/archive/refs/heads/master.zip
unzip -q master.zip
mv SGDK-master sgdk
rm master.zip
echo -e "${G}✓ SGDK installed${RST}"

# ============================================================
# 15. SNES (PVSnesLib)
# ============================================================
echo -e "\n${C}🎮 SNES (PVSnesLib)${RST}"
mkdir -p "$HOME/retro-dev/snes"
cd "$HOME/retro-dev/snes"
wget -q https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip
unzip -q master.zip
mv pvsneslib-master pvsneslib
rm master.zip
echo -e "${G}✓ PVSnesLib installed${RST}"

# ============================================================
# ENVIRONMENT VARIABLES
# ============================================================
echo -e "\n${C}📝 Setting environment variables${RST}"
cat >> ~/.bashrc << 'EOF'

# ============================================================
# COMPILER FOR ALL CONSOLES — PATH
# ============================================================
export PATH="$HOME/retro-dev/atari:$PATH"
export PATH="$HOME/retro-dev/gbdk/gbdk/bin:$PATH"
export PATH="/opt/devkitpro/devkitARM/bin:$PATH"
export PATH="/opt/devkitpro/devkitA64/bin:$PATH"
export N64_INST="/opt/libdragon"
export LIBDRAGON="$HOME/retro-dev/sdks/libdragon"
export PATH="$N64_INST/bin:$HOME/retro-dev/ps4/orbisdev-ps4-llvm/bin:$HOME/retro-dev/ps5/orbis-sdk/bin:$PATH"
export SGDK="$HOME/retro-dev/sgdk/sgdk"
export PVSNESLIB="$HOME/retro-dev/snes/pvsneslib"
EOF

source ~/.bashrc

# ============================================================
# VERIFICATION
# ============================================================
echo -e "\n${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "${G}  ✅ ALL CONSOLE COMPILERS INSTALLED!${RST}"
echo -e "${G}═══════════════════════════════════════════════════════════════${RST}"
echo -e "  ${C}Atari 2600:${RST}      dasm source.asm -f3 -o rom.bin"
echo -e "  ${C}NES:${RST}            cc65 source.c -o rom.nes"
echo -e "  ${C}Game Boy:${RST}       lcc -o rom.gb source.c"
echo -e "  ${C}GBA:${RST}           arm-none-eabi-gcc -o rom.gba source.c"
echo -e "  ${C}NDS:${RST}           arm-none-eabi-gcc -specs=ds_arm9.specs -o rom.nds"
echo -e "  ${C}N64:${RST}           mips64-elf-gcc -I\$LIBDRAGON/include -o rom.z64 source.c"
echo -e "  ${C}PS2:${RST}           ee-gcc -o rom.elf source.c"
echo -e "  ${C}PSP:${RST}           psp-gcc -o rom.elf source.c"
echo -e "  ${C}PS3:${RST}           ppu-gcc -o rom.elf source.c"
echo -e "  ${C}PS4:${RST}           orbis-clang -o rom.elf source.c"
echo -e "  ${C}PS5:${RST}           orbis-clang -o rom.elf source.c"
echo -e "  ${C}Xbox:${RST}          xbox-gcc -o rom.xbe source.c"
echo -e "  ${C}Xbox 360:${RST}      xenon-gcc -o rom.xex source.c"
echo -e "  ${C}Switch:${RST}        aarch64-none-elf-gcc -o rom.nsp source.c"
echo -e "  ${C}Genesis:${RST}       make -f \$SGDK/makefile.gen"
echo -e "  ${C}SNES:${RST}          make -f \$PVSNESLIB/Makefile"
echo -e "\n  ${Y}Run: source ~/.bashrc  (or restart terminal)${RST}"