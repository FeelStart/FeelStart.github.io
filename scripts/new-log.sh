#!/usr/bin/env bash
# 新建日志条目，无需标题，文件名自动用时间戳
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HUGO_DIR="$REPO_ROOT/hugo"

TIMESTAMP="$(date +%Y-%m-%d-%H%M)"
DATE="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
FILE_PATH="logs/${TIMESTAMP}.md"
FULL_PATH="$HUGO_DIR/content/$FILE_PATH"

cat > "$FULL_PATH" <<EOF
---
title: "${DATE} ${TIME}"
date: $(date +%Y-%m-%dT%H:%M:%S+08:00)
categories: ["日志"]
tags: []
---

EOF

echo "已创建：hugo/content/${FILE_PATH}"
echo ""

