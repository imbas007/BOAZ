#!/bin/bash
# Simplified installation script for BOAZ evasion tool

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[*] Installing required packages for BOAZ evasion tool...${NC}"

# Install Go if not present
if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}[*] Installing Go...${NC}"
    echo "kali" | sudo -S apt install -y golang-go
fi

# Install required packages
echo -e "${YELLOW}[*] Installing system packages...${NC}"
echo "kali" | sudo -S apt install -y git cmake ninja-build build-essential nasm python3 gcc g++ zlib1g-dev wine64 mingw-w64 mingw-w64-tools gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 osslsigncode

# Install Python packages in virtual environment
echo -e "${YELLOW}[*] Setting up Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install pyopenssl pyinstaller

# Install Mangle
echo -e "${YELLOW}[*] Installing Mangle...${NC}"
if [ ! -f ./signature/Mangle ]; then
    if [ -d "Mangle" ]; then
        rm -rf Mangle
    fi
    git clone https://github.com/optiv/Mangle.git
    cd Mangle
    go get github.com/Binject/debug/pe
    go build Mangle.go
    mv Mangle ../signature/
    cd ..
    rm -rf Mangle
    echo -e "${GREEN}[*] Mangle installed successfully.${NC}"
else
    echo -e "${GREEN}[*] Mangle already installed.${NC}"
fi

# Install pyMetaTwin
echo -e "${YELLOW}[*] Installing pyMetaTwin...${NC}"
if [ ! -f "./signature/metatwin.py" ]; then
    if [ -d "pyMetaTwin" ]; then
        rm -rf pyMetaTwin
    fi
    git clone https://github.com/thomasxm/pyMetaTwin
    cp -r pyMetaTwin/* signature/
    cd signature
    if [ -f "./install.sh" ]; then
        chmod +x install.sh
        echo "kali" | sudo -S ./install.sh
    fi
    cd ..
    rm -rf pyMetaTwin
    echo -e "${GREEN}[*] pyMetaTwin installed successfully.${NC}"
else
    echo -e "${GREEN}[*] pyMetaTwin already installed.${NC}"
fi

# Install SysWhispers2
echo -e "${YELLOW}[*] Installing SysWhispers2...${NC}"
if [ ! -d "./SysWhispers2" ]; then
    git clone https://github.com/jthuraisamy/SysWhispers2
    cd SysWhispers2
    python3 ./syswhispers.py --preset common -o syscalls_common
    cd ..
    echo -e "${GREEN}[*] SysWhispers2 installed successfully.${NC}"
else
    echo -e "${GREEN}[*] SysWhispers2 already installed.${NC}"
fi

# Build the main executable
echo -e "${YELLOW}[*] Building main executable...${NC}"
source venv/bin/activate
pyinstaller --onefile Boaz.py

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[*] Executable created successfully.${NC}"
    mv dist/Boaz .
    rm -rf dist/ build/ *.spec
    echo -e "${GREEN}[+] Setup completed successfully!${NC}"
    echo -e "${YELLOW}[+] Main program can be run with python3 Boaz.py or ./Boaz.${NC}"
else
    echo -e "${RED}[!] Failed to create the executable.${NC}"
fi
