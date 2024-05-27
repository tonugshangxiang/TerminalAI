import os
import typer
from pathlib import Path

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

app = typer.Typer()


app = typer.Typer()
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)


def create_chain(prompt: str, text: str):
    chat_prompt = ChatPromptTemplate.from_messages([
        ('system', prompt),
        ('user', '{text}')
    ])

    parser = StrOutputParser()
    chain = chat_prompt | llm | parser
    result = chain.invoke({
        "text": text,
    })
    return result


def SSHChain(text: str):
    prompt = """
    # Role: Linux终端指令生成助手

    ## Profile

    - Author: Doerr
    - Version: 0.2
    - Language: 中文
    - Description: 你是一个专业的Linux系统终端指令生成助手。根据用户提供的信息，生成一条可以在Linux终端运行的命令。注意只能生成一句命令，可以通过`&`来拼接多个命令使其成为一句命令。
    - 注意： 我希望你生成的命令是可以在Linux终端运行的，所以你提供的类似```bash\nps -aux | grep Java\n```这样的命令是不符合要求的。
    ### 生成Linux终端命令
    1. 获取用户提供的信息
    2. 将信息转换为一句可以在Linux终端运行的命令
    3. 使用`&`来拼接多个命令使其成为一句命令（如果需要）

    ## Rules
    1. 不论任何情况都不能脱离角色。
    2. 避免任何多余的描述性文字或解释。
    3. 只能生成一句命令。
    4. 请不要提供markdown格式的文本。


    ## Workflow
    1. 解析用户提供的信息。
    2. 将信息转换为一句Linux终端命令。
    3. 返回生成的命令给用户。
    """
    result = create_chain(prompt, text)
    # result可能会是类似：`lsb_release -a`这样的命令，我们需要把`去掉
    if result.startswith("`") and result.endswith("`"):
        result = result[1:-1]
    return result


def ExplainChain(text: str):
    prompt = """
    # Role: 专业的Linux系统终端助手

    ## Profile

    - Author: Doerr
    - Version: 0.1
    - Language: 中文
    - Description: 你是一个专业的Linux系统终端助手，擅长用简短的语句解释用户的问题。根据用户提供的信息，生成简洁的解释或操作指令。

    ### 生成简短的解释和操作指令
    1. 获取用户的问题或需求
    2. 用简短的语句进行解释或提供操作指令
    3. 确保内容简明扼要，不拖泥带水

    ## Rules
    1. 不论任何情况都不能脱离角色。
    2. 避免任何多余的描述性文字或解释。
    3. 解释和指令都要尽可能简短。

    ## Workflow
    1. 解析用户的问题或需求。
    2. 用简短的语句进行解释或提供操作指令。
    3. 返回简洁的解释或指令给用户。
    """
    return create_chain(prompt, text)


@app.command()
def sshchain(c: str):
    print("接收到的命令是：", c)
    c = process_command_string(c)
    print("处理后的命令是：", c)
    if c.startswith('#'):
        result = SSHChain(c[1:])  # 去掉开头的 '#'
        typer.echo(result)
        typer.echo("[E]xecute, [D]escribe, [A]bort: ", nl=False)
        choice = typer.prompt("").lower()
        if choice == 'e':
            os.system(result)
        elif choice == 'd':
            prompt = "请详细解释一下这个命令的作用：" + c[1:]
            typer.echo(ExplainChain(prompt))
        elif choice == 'a':
            typer.echo("Aborted.")
        else:
            typer.echo("Invalid choice.")
    else:
        typer.echo("Invalid command. It must start with '#'. but got: " + c)


@app.command()
def explainchain(o: str):
    command = process_command_string(o)

    if command.startswith('#'):
        result = ExplainChain(command[1:])  # 去掉开头的 '#'
        typer.echo(result)
    else:
        typer.echo("Invalid command. It must start with '#'. but got: " + command)




def process_command_string(o: str):
    """
        处理输入字符串，去掉行号并返回命令部分。
    """
    # 去掉行号前面的空格
    o = o.lstrip()
    return o



if __name__ == "__main__":
    app()
