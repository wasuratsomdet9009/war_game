#!/bin/bash
# Double-click this file in Finder (or run ./play.command) to start the game.
# The game is macOS-only: refuse to run anywhere else.

cd "$(dirname "$0")" || exit 1

if [ "$(uname -s)" != "Darwin" ]; then
  echo "เกมนี้เล่นได้เฉพาะบน macOS เท่านั้น"
  read -r -p "กด Enter เพื่อปิด..."
  exit 1
fi

# TODO: เรียกใช้เกมตรงนี้เมื่อเลือกเอนจินและแผนการทำเกมแล้ว
echo "โครงสร้างพร้อมแล้ว ยังไม่มีตัวเกมให้เล่น"
read -r -p "กด Enter เพื่อปิด..."
