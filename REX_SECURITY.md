# Rex 的安全定制版（agent-reach-rex-secure 分支）

上游：Panniantong/Agent-Reach（v1.6.1 之后的 main，c70ae6d），2026-11-20 复查。
安装位置：`~/.agent-reach-venv`（Homebrew python@3.12），`/opt/homebrew/bin/agent-reach` 指向它。
坏掉的原因（11-09、11-20）：旧环境用的 python@3.13 被 Homebrew 删了。3.12 是手动装的，不会被自动删。

## 复查结论
整体写得规范：不上传用户数据，没有后台自动更新，私密文件权限 0600、目录 0700，解压时防路径穿越，
Node 下载会校验 SHA256，浏览器调试端口只绑定本机 127.0.0.1。

## 补丁（代码里搜 `REX-SECURE`）
1. OpenCLI 浏览器扩展：原来下载 GitHub 上的「最新版」，而且不校验。这个扩展跑在已登录的浏览器里，
   上游一旦被盗，就能读到所有登录状态。→ 改成固定 v2.0.3，并校验 SHA256。
2. uv：原来下载 astral.sh 的安装脚本后直接执行。→ 禁用，需要时自己运行 `brew install uv`。
3. boss-agent-cli：第三方 GitHub 压缩包没有指纹。→ 加上 `#sha256=`。
4. `agent-reach update`：原来会从上游重装，覆盖本版（还会迁到 uv）。→ 只同步各渠道的工具；
   Agent Reach 本体只通过 `rex_update.sh` 更新。

## 没改，知道就行
- 浏览器调试端口在 127.0.0.1，本机其他程序也能连。单人用的 Mac 可以接受。
- cloakbrowser 0.6.3、opencli 2.0.3、bili-cli 0.6.2 固定了版本，但没有指纹（来自 PyPI、npm 官方源）。
- 网页读取经过 r.jina.ai、mcp.exa.ai，查询的网址会发给它们。

## 上游更新时
1. 运行 `./rex_update.sh`：拉取上游，同步 fork 的 main，再把补丁接到新版上。
2. 让 Claude 复查新增的代码。扩展的版本和指纹要跟着更新。
3. 运行 `./rex_update.sh --install`。
