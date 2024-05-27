#!/bin/bash

# 设置默认的 OPENAI_API_BASE
DEFAULT_OPENAI_API_BASE="https://api.openai.com/v1"

# 生成 doerr.sh 脚本内容

DOERR_SCRIPT_CONTENT="#!/bin/bash
# 获取倒数第1条命令
INPUT_LINE=\$(history | tail -1 | head -1 | sed -e 's/^[ ]*[0-9]*[ ]*//')
echo \"\$INPUT_LINE\"
# 调用 Python 程序并传递命令
if [ \"\$1\" == \"sshchain\" ]; then
    docker run --rm -it doerr-app sshchain \"\$INPUT_LINE\"
elif [ \"\$1\" == \"explainchain\" ]; then
    docker run --rm -it doerr-app explainchain \"\$INPUT_LINE\"
fi
"

# 写入 doerr.sh 脚本
DOERR_SCRIPT_PATH="$HOME/doerr.sh"
echo "$DOERR_SCRIPT_CONTENT" > "$DOERR_SCRIPT_PATH"
# 确保脚本具有可执行权限
chmod +x "$DOERR_SCRIPT_PATH"

# 更新 shell 配置文件
SHELL_CONFIG_PATH="$HOME/.$(basename "$SHELL")rc"
BIND_COMMANDS="bind '\"\\C-w\":\"\\C-a\\C-k source $DOERR_SCRIPT_PATH explainchain\\e\\C-y\\C-m\"'
bind '\"\\C-g\":\"\\C-a\\C-k source $DOERR_SCRIPT_PATH sshchain\\e\\C-y\\C-m\"'
"

# 追加绑定命令到 shell 配置文件
{
    echo -e "\n# Added by doerr init command"
    echo "$BIND_COMMANDS"
} >> "$SHELL_CONFIG_PATH"

# 获取 OPENAI_API_KEY 和 OPENAI_API_BASE
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
OPENAI_API_BASE="${OPENAI_API_BASE:-}"

# 如果OPENAI_API_KEY为空，则提示用户输入
if [ -z "$OPENAI_API_KEY" ]; then
    read -p "Please enter your OPENAI_API_KEY: " OPENAI_API_KEY
    echo
fi

# 提示用户选择是否更改 OPENAI_API_BASE
read -p "Current OPENAI_API_BASE is set to $DEFAULT_OPENAI_API_BASE. Do you want to change it? (y/n): " change_base
if [[ "$change_base" == "y" || "$change_base" == "Y" ]]; then
    read -p "Please enter your OPENAI_API_BASE: " OPENAI_API_BASE
else
    OPENAI_API_BASE="$DEFAULT_OPENAI_API_BASE"
fi
#debug 输出$OPENAI_API_KEY、$OPENAI_API_BASE
echo "OPENAI_API_KEY: $OPENAI_API_KEY"
echo "OPENAI_API_BASE: $OPENAI_API_BASE"

## 组装Docker镜像并 启动
docker build -t doerr-app --build-arg OPENAI_API_KEY="$OPENAI_API_KEY" --build-arg OPENAI_API_BASE="$OPENAI_API_BASE" .

# 提示用户重新启动终端或加载配置
echo "doerr.sh script created and hotkeys bound. Please restart your terminal or run 'source $SHELL_CONFIG_PATH' to apply changes."