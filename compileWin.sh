#!/bin/sh

echo "zipping..."
zip -r puku.zip assets dialogs entities gamestates libs main.lua

echo "loving..."
mv puku.zip puku.love 

echo "making an .exe..."
cat love.exe puku.love > puku.exe

echo "moving .exe to folder..."
mv puku.exe pukuWin64

echo "zipping pukuWin64 folder..."
zip -r pukuWin64.zip pukuWin64
