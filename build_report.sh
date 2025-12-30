#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

# 定义路径
SRC_DIR="$PROJECT_ROOT/docs/src"
BUILD_DIR="$PROJECT_ROOT/docs/build"
OUTPUT_PDF="$PROJECT_ROOT/docs/report.pdf"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting build process...${NC}"

# 1. 创建构建目录
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
fi

# 2. 进入源码目录
cd "$SRC_DIR" || { echo -e "${RED}Error: Cannot change directory to $SRC_DIR${NC}"; exit 1; }

# 3. 编译 LaTeX (运行多次以解决引用和目录)
echo "Compiling report.tex (Pass 1/2)..."
xelatex -interaction=nonstopmode -output-directory="$BUILD_DIR" report.tex > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Compilation failed on pass 1.${NC}"
    # 这里不退出，因为第一次编译可能会有非致命警告，但如果完全失败则要注意
    # 为了看到错误信息，可以移除 > /dev/null 或者查看 log
    echo "Check $BUILD_DIR/report.log for details."
fi

echo "Compiling report.tex (Pass 2/2)..."
xelatex -interaction=nonstopmode -output-directory="$BUILD_DIR" report.tex > /dev/null

# 4. 复制 PDF 到输出位置
if [ -f "$BUILD_DIR/report.pdf" ]; then
    cp "$BUILD_DIR/report.pdf" "$OUTPUT_PDF"
    echo -e "${GREEN}Build successful!${NC}"
    echo "Report generated at: $OUTPUT_PDF"
else
    echo -e "${RED}Error: Output PDF not found.${NC}"
    exit 1
fi
