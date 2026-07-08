#!/bin/bash
# .config needs to have the directory to love.exe (lovedos) 

source ./inevit/.config
if command -v dosbox &> /dev/null; then
    dosbox -c "mount c $LOVEDOS_DIR" -c "c:" -c "love game" -c "exit" -exit
else
    echo "Please install DOSBox or run install.sh for full installation."
fi