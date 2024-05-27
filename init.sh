#!/bin/bash



# 生成 doerr.sh 脚本内容

DOERR_SCRIPT_CONTENT="#!/bin/bash
# 获取倒数第二条命令
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
chmod 755 "$DOERR_SCRIPT_PATH"

# 更新 shell 配置文件
SHELL_CONFIG_PATH="$HOME/.$(basename "$SHELL")rc"
BIND_COMMANDS="bind '\"\\C-w\":\"\\C-a\\C-k source $DOERR_SCRIPT_PATH explainchain\\e\\C-y\\C-m\"'
bind '\"\\C-g\":\"\\C-a\\C-k source $DOERR_SCRIPT_PATH sshchain\\e\\C-y\\C-m\"'
"

# 追加绑定命令到 shell 配置文件
echo -e "\n# Added by doerr init command" >> "$SHELL_CONFIG_PATH"
echo "$BIND_COMMANDS" >> "$SHELL_CONFIG_PATH"

# OPENAI_API_KEY变量
OPENAI_API_KEY="sb-f23f269cce9eb709ef36097a493c78cd67117c8a3f011140"
OPENAI_API_BASE="https://api.openai-sb.com/v1"

# 如果OPENAI_API_KEY为空，则试着从环境变量中获取
if [ -z "$OPENAI_API_KEY" ]; then
  OPENAI_API_KEY=$OPENAI_API_KEY
fi

# 如果仍为空，则提示用户输入
if [ -z "$OPENAI_API_KEY" ]; then
  echo "Please enter your OPENAI_API_KEY:"
  read OPENAI_API_KEY
fi


# 组装Docker镜像并启动
docker build -t doerr-app --build-arg OPENAI_API_KEY=$OPENAI_API_KEY --build-arg OPENAI_API_BASE=$OPENAI_API_BASE .



# 提示用户重新启动终端或加载配置
echo "doerr.sh script created and hotkeys bound. Please restart your terminal or run 'source $SHELL_CONFIG_PATH' to apply changes."