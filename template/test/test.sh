#!/bin/bash
echo "Đang kiểm tra file..."
if [ -f "$(pwd)/app/index.html" ]; then
  echo "✔️ Tồn tại file index.html"
  exit 0
else
  echo "❌ Không tìm thấy file index.html"
  exit 1
fi
