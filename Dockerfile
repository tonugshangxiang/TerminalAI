# 使用Python 3.9及以上版本的基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 复制当前目录下的所有文件到容器中的工作目录
COPY . .

ENV OPENAI_API_KEY=${OPENAI_API_KEY}
ENV OPENAI_API_BASE=${OPENAI_API_BASE}

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt  -i https://pypi.tuna.tsinghua.edu.cn/simple

# 设置ENTRYPOINT来运行doerr.py
ENTRYPOINT ["python", "doerr.py"]