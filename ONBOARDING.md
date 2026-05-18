# 👋 欢迎加入 boobank games 后台

这是一份你的入门手册,讲清楚:
1. **你拥有什么**(我们家的服务器现状)
2. **怎么连上去**(第一次设置)
3. **怎么发布自己的游戏到 game.boobank.com**
4. **怎么改爸爸的 Arena Shooter**
5. **遇到问题怎么办**

按顺序一步步做,有不懂的随时问爸爸或者 Claude Code。

---

# 🏠 第 1 部分:你拥有什么

## 这是我们的家底

我们有一台**自己的服务器**,放在日本东京。它每天 24 小时开着,任何人在世界各地都能访问。

```
🌐 域名:                   boobank.com(在 GoDaddy 注册,Cloudflare 管 DNS)
🚇 公网入口:               https://game.boobank.com/
🖥️  服务器:                 Vultr Tokyo, Ubuntu 24.04 Linux
🌍 服务器 IP:              207.148.98.206
💾 配置:                   2GB 内存 / 1 CPU / 55GB 硬盘 / 2TB 流量
💰 费用:                   爸爸付,每月 $12(约 ¥85)
```

## 现在挂了哪些游戏

| URL | 是什么 | 谁的 |
|---|---|---|
| https://game.boobank.com/ | 游戏门户(首页列出所有游戏) | 爸爸建,以后你也能改 |
| https://game.boobank.com/arena-shooter/ | Arena Shooter 3D(多人 FPS) | 爸爸做的 |
| https://game.boobank.com/{你的游戏}/ | 等你发布! | **你** |

## 整个系统长这样

```
玩家手机/电脑
   │
   ▼  https://game.boobank.com/...
[Cloudflare 全球边缘节点]  ← 帮我们做了 HTTPS、缓存、隐藏真实 IP
   │
   ▼  Cloudflare 命名隧道(QUIC 协议)
[Vultr Tokyo 服务器] root@207.148.98.206
   │
   ├── cloudflared 服务   把外网请求转给本机
   ├── Caddy 服务         按路径分发请求:
   │      /                 → /opt/games/portal/(门户首页)
   │      /arena-shooter/   → /opt/games/arena-shooter-3d/docs/
   │      /<你的游戏>/      → /opt/games/<你的游戏>/docs/
   │
   └── 各游戏的服务器进程(只有联机游戏才需要)
```

**重点**:你只要把游戏代码放到 `/opt/games/<游戏名>/docs/`,玩家访问 `game.boobank.com/<游戏名>/` 就能玩到。**不用动 Caddy 配置**,自动生效。

---

# 🔑 第 2 部分:第一次设置(15 分钟)

## 步骤 1:在你 Mac 上生成 SSH 钥匙

打开**终端**(Terminal),粘贴这行:

```bash
ssh-keygen -t ed25519 -C "kid@arena"
```

它会问几个问题,**全部按回车**(默认值最好)。

成功后会生成:
- 私钥(`~/.ssh/id_ed25519`)— **绝对保密**,只在你电脑上
- 公钥(`~/.ssh/id_ed25519.pub`)— 可以发给别人

## 步骤 2:查看公钥并发给爸爸

```bash
cat ~/.ssh/id_ed25519.pub
```

会输出一长串,看起来像:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...VeryLongString...lkfj kid@arena
```

**整行复制**,微信/iMessage 发给爸爸。

## 步骤 3:等爸爸开账号

爸爸收到公钥后,会:
1. 在服务器上给你创建 `kid` 用户
2. 把你的公钥装上
3. 配置好你的权限
4. 告诉你"好了"

期间你可以**先做这些准备工作**:

### 装 Claude Code(如果还没装)

```bash
# 装 Node.js(用 brew,如果没装 brew 先装一下)
brew install node

# 装 Claude Code
npm install -g @anthropic-ai/claude-code

# 验证
claude --version
```

第一次跑 `claude` 它会让你登录 Anthropic 账号 — **用你自己的账号**(爸爸会给你设一个,有零花钱限额)。

### 装 git 客户端

```bash
git --version    # 看看有没有
```

没有的话:`brew install git`,然后告诉 git 你是谁:

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

## 步骤 4:爸爸说好了之后,试 SSH

```bash
ssh kid@207.148.98.206
```

第一次会问 `Are you sure you want to continue connecting (yes/no)?` → 输 **`yes`** → 直接进系统(不问密码,因为有 SSH key)。

进去看到:

```
kid@arena-game:~$ _
```

✅ **成功了**!输 `exit` 退出回到自己 Mac。

---

# 🗂️ 第 3 部分:你在服务器上的领地

## 哪里有什么

```
/home/kid/                   ← 你的家目录,只有你能写
   ├── .ssh/                  你的 SSH 配置
   ├── .claude/               Claude Code 的配置(你的账号)
   └── (随便玩,装东西、写笔记都行)

/opt/games/                  ← 公共游戏目录,你和爸爸都能写
   ├── portal/                门户首页 (爸爸的,但你能改卡片)
   ├── arena-shooter-3d/      爸爸的游戏
   └── <你的游戏>/             ← 你的游戏放这里!
```

## 你能做什么、不能做什么

### ✅ 能做

- 在 `/home/kid/` 里随便写文件、装东西
- 在 `/opt/games/` 里 clone 新仓库、`git pull`、改文件
- 看任何 systemd 服务的日志:`sudo journalctl -u arena-game -n 50`
- 重启游戏服务器:`sudo systemctl restart arena-game`(白名单内的命令免密码)
- 看监听端口、看内存、看磁盘:`ss -ltnp`、`free -h`、`df -h`

### ❌ 不能做(尝试会被拒)

- 当 root(不能 `su -` / 不能 `sudo bash`)
- 改 `/etc/` 里的系统配置
- 改 `/root/`(爸爸的家目录)
- 改 `/etc/cloudflared/`(隧道的命根子)
- 关防火墙、改 SSH 配置
- 装/卸系统软件(`apt install` 需要 root)

如果你**需要**做被拒的事,先**问爸爸**,他会帮你做或者临时给你权限。

---

# 🎮 第 4 部分:发布你的第一个游戏(完整实战)

下面用一个**贪吃蛇**例子,把整个流程走一遍。学会之后,任何 HTML5 游戏都同样发布。

## 步骤 1:在你 Mac 上做游戏

打开终端,建项目目录:

```bash
mkdir -p ~/projects/kid-snake && cd ~/projects/kid-snake
```

启动 Claude Code:

```bash
claude
```

让他帮你写一个游戏:

```
帮我写一个简单的贪吃蛇游戏,只用一个 index.html 文件(不依赖任何外部库),
用 canvas + JavaScript,要求:
- 键盘 WASD 或方向键控制
- 吃到食物加分,撞墙或撞自己就结束
- 屏幕底部显示当前分数
- 适配手机:触摸屏上四个箭头按钮
- 用深色背景 + 鲜艳的蛇身,看着舒服
```

Claude Code 会帮你创建 `index.html`,几分钟后跑通。

## 步骤 2:本地测一下能不能玩

```bash
# 在项目目录里启动一个最简单的 web 服务器
python3 -m http.server 8000
```

浏览器打开 http://localhost:8000 → 应该看到贪吃蛇,能玩。

按 **Ctrl+C** 关掉这个服务器。

## 步骤 3:整理目录结构

Caddy 自动找 `docs/` 子目录,所以把游戏移进去:

```bash
mkdir -p docs
mv index.html docs/
# 如果还有别的 .js / .css / 图片,一起移进 docs/
```

写一份 README 给自己和别人看:

```bash
cat > README.md <<'EOF'
# Kid Snake 🐍

A classic snake game playable in browser, with touch controls for mobile.

## Play
Live: https://game.boobank.com/kid-snake/

## Local dev
```
python3 -m http.server 8000
# open http://localhost:8000/docs/
```
EOF
```

## 步骤 4:推到 GitHub

```bash
# 初始化 git 仓库
git init
git add .
git commit -m "First version of kid-snake"

# 在 GitHub 上建一个空仓库
gh repo create longmaolab/kid-snake --public --source=. --remote=origin --push
```

(如果还没装 `gh`:`brew install gh && gh auth login` 跟着提示走)

## 步骤 5:发布到服务器

SSH 上 VPS:

```bash
ssh kid@207.148.98.206
```

clone 仓库到 `/opt/games/`:

```bash
cd /opt/games
git clone https://github.com/longmaolab/kid-snake.git
exit   # 退出 SSH 回自己 Mac
```

## 步骤 6:🎉 验证上线

浏览器打开:**https://game.boobank.com/kid-snake/**

应该看到你的贪吃蛇!发链接给同学。

> 💡 **不需要改 Caddy 配置、不需要重启任何东西**。Caddy 看到 `/opt/games/kid-snake/docs/` 存在就自动 serve 了。

## 步骤 7:把游戏加到门户首页

打开 [longmaolab/portal](https://github.com/longmaolab/portal)(爸爸会邀请你当 collaborator)。

clone 到自己 Mac:

```bash
cd ~/projects
git clone git@github.com:longmaolab/portal.git
cd portal
```

打开 `index.html`,找到这段:

```html
<!-- Coming soon placeholder -->
<div class="card placeholder">
  ...
</div>
```

**把这个占位卡片改成你的游戏卡片**:

```html
<a class="card playable" href="/kid-snake/">
  <div class="thumb" style="background-image: url('thumbnails/kid-snake.png');">
    <span class="badge live">LIVE</span>
  </div>
  <div class="card-body">
    <h2>Kid Snake 🐍</h2>
    <p class="desc">经典贪吃蛇,WASD/方向键控制。手机上有触摸按钮。</p>
    <div class="meta">
      <span class="tag">single-player</span>
      <span class="tag">classic</span>
    </div>
    <div class="play-cta">Play now →</div>
  </div>
</a>
```

放一张缩略图(16:9,~600×340 像素的 PNG)到 `thumbnails/kid-snake.png`(自己设计或截图)。

一键发布门户:

```bash
./deploy.sh "Add kid-snake card"
```

刷新 https://game.boobank.com/ — **看到你的卡片了**!

## 步骤 8:之后游戏更新

改 `~/projects/kid-snake/docs/index.html`,然后:

```bash
cd ~/projects/kid-snake
git add -A
git commit -m "改了什么写这里"
git push

# 通知 VPS 拉新代码
ssh kid@207.148.98.206 'cd /opt/games/kid-snake && git pull'
```

玩家硬刷新就能看到新版本(浏览器有缓存,要 ⌘+Shift+R)。

---

# 🎯 第 5 部分:改爸爸的 Arena Shooter

爸爸的 Arena Shooter 仓库已经设好了 `deploy.sh`,你也能用。

## 步骤 1:clone 到你 Mac

```bash
cd ~/projects
git clone git@github.com:longmaolab/arena-shooter-3d.git
cd arena-shooter-3d
```

(爸爸会邀请你当这个仓库的 collaborator)

## 步骤 2:本地玩 / 改代码

**纯本地测**(不联网):

1. 用 Godot 4.6 打开 `project.godot`
2. **Debug → Run Multiple Instances → 2**(开两个窗口)
3. ⌘+B 启动
4. 窗口 1 点 **PLAY vs BOTS**(变成本机主机)
5. 窗口 2 点 **PLAY**(默认连 `ws://127.0.0.1:7777`)

改代码:
- 玩家速度、伤害、血量 → `scripts/player.gd` 顶部常量
- 胜利条件、新局倒计时 → `scripts/game.gd` 顶部常量
- 详细见 `KIDS_GUIDE.md`

## 步骤 3:发布到 game.boobank.com/arena-shooter/

一行命令搞定 —— **不用手动 export**,`deploy.sh` 会自己用 headless Godot 重打包:

```bash
cd ~/projects/arena-shooter-3d

# 告诉 deploy.sh 你的服务器账号(只要做一次,加到 ~/.zshrc)
echo 'export ARENA_SERVER_HOST=kid@207.148.98.206' >> ~/.zshrc
source ~/.zshrc

# 一键发布
./deploy.sh
```

`deploy.sh` 自动做的事:
1. 检测 `scripts/` / `scenes/` / `audio/` 等有没有比 `docs/index.pck` 新的文件
2. 有 → 调 Godot 重新 export 网页版(约 30-60 秒)
3. 没 → 跳过(约 5 秒)
4. commit + push 源码 → ssh 上 VPS → `git pull` → 重建 import 缓存 → 重启游戏服务器

**完事后让玩家硬刷新浏览器(⌘+Shift+R)就能看到新版本。**

> 💡 deploy.sh 用 headless 模式跑 Godot,**不会弹 GUI**。前提是你 Mac 上装了 Godot 4.6.2(到 `/Applications/` 或 `~/Downloads/` 都行),并且**装了 Web 导出模板**(在 Godot 编辑器里:**编辑器 → 管理导出模板 → 下载**,只装一次)。

---

# 🛠️ 第 6 部分:服务器命令速查

## SSH 上服务器

```bash
ssh kid@207.148.98.206
```

## 看正在跑的服务

```bash
sudo systemctl is-active arena-game caddy cloudflared
# 三个都应该是 active
```

## 看日志(实时)

```bash
# 看 Arena Shooter 游戏服务器日志
sudo journalctl -u arena-game -f
# Ctrl+C 退出

# 看 Caddy(网站)日志
sudo journalctl -u caddy -f

# 看 Cloudflare 隧道日志
sudo journalctl -u cloudflared -f
```

## 看历史日志(后 50 行)

```bash
sudo journalctl -u arena-game -n 50 --no-pager
```

## 重启服务

```bash
# 重启 Arena Shooter 游戏服务器(改了它的代码后用)
sudo systemctl restart arena-game

# 重载 Caddy(改了网站配置后用,但通常爸爸来做)
sudo systemctl reload caddy
```

## 看内存 / 磁盘 / 端口

```bash
free -h               # 内存
df -h /               # 磁盘
ss -ltnp              # 谁在监听哪个端口
```

## 在服务器上跑 Claude Code

```bash
ssh kid@207.148.98.206
cd ~
claude                # 第一次跑会让你登录 Anthropic 账号
```

注意服务器只有 2GB 内存,**别同时跑太多东西**。如果游戏卡了,可能是 Claude Code 抢内存。

---

# 🧰 第 7 部分:用 Claude Code 帮你

## 在自己 Mac 上(推荐主战场)

```bash
cd ~/projects/<某个项目>
claude
```

它会读懂当前目录,你可以问:

- **"帮我做一个 XXX 游戏"** — 适合从零开始
- **"这段代码有 bug,玩家走路太慢"** — 它会读代码并修
- **"加一个键盘 Tab 切换武器的功能"** — 描述需求,它写代码
- **"我推上 GitHub 之后服务器没更新,怎么回事"** — 让它排查

## 让它帮你跑 VPS 命令

Claude Code 也能 SSH。比如:

```
帮我看看服务器上 Arena Shooter 服务的最新 50 行日志
```

它会跑 `ssh kid@207.148.98.206 'sudo journalctl -u arena-game -n 50'` 给你看。

## 使用规则

- **不懂的命令先问** — "这条命令什么意思?会不会删东西?"
- **重要操作要确认** — 删大量文件、改配置之前让 Claude 解释一遍
- **VPS 上的 sudo 命令**要特别小心,你的白名单很窄,但 Claude 可能不知道
- **失败了不要硬刚** — 报错截图发给爸爸

---

# ❓ 第 8 部分:常见问题

## Q1:`ssh: connection refused` 或 `permission denied`
- 是不是 IP 输错了?(应该是 `207.148.98.206`)
- 是不是用户名错了?(应该是 `kid@...`,不是 `root@...`)
- SSH key 还在 `~/.ssh/id_ed25519` 吗?(`ls ~/.ssh/`)
- 都对的话:截图发爸爸

## Q2:`game.boobank.com/我的游戏/` 显示 404
- 服务器上有这个目录吗?`ssh kid@207.148.98.206 'ls /opt/games/'`
- 目录里有 `docs/index.html` 吗?(必须是 `docs/` 子目录)
- 都对的话:在游戏目录里 `git pull`,可能是没拉到最新

## Q3:本地能玩,推上去之后玩家硬刷新还是旧版
- 等 5 秒再硬刷新一次
- 浏览器更狠的清缓存:开 DevTools(F12)→ Application → Storage → Clear site data
- 还不行:验证 `ssh kid@... 'cat /opt/games/<你的游戏>/docs/index.html | grep "你最后改的那行"'`

## Q4:`sudo systemctl restart xxx` 报 "not allowed"
- 这条命令不在你的白名单里 → 问爸爸,他会决定加白还是替你做
- 别试 `sudo bash` / `sudo su` —— 一定被拒,而且会被记录

## Q5:服务器卡了 / 游戏掉线
- 看内存:`ssh kid@... 'free -h'` —— 如果 `available` 不到 200MB → **关掉一些进程**
- 看日志:`sudo journalctl -u arena-game -n 100 | grep -i error`
- 实在不行:`sudo systemctl restart arena-game`

## Q6:Claude Code 报 "无效 API key" 或额度用完
- 你的 Anthropic 账号额度用完了 → 问爸爸
- 或者 API key 过期 → 重新登录:`claude /logout` 然后 `claude` 重新登

## Q7:我把仓库的 git 搞乱了 / 不小心删了文件
- **不要慌**,git 几乎不会真的丢东西
- 没 push 的话:`git reflog` 找到上一个好状态
- 已经 push 了:仓库里的历史 commit 永远在 GitHub 上,可以回滚
- 实在搞不定:**别 force push**,问爸爸或 Claude Code

---

# 🚦 第 9 部分:规则

## 必须遵守的几条

1. **SSH 私钥永远不外传** — `~/.ssh/id_ed25519` 这个文件谁都不能给,泄漏了就重新生成
2. **不要分享你的 Anthropic API key** — 别人能用你的额度
3. **不懂的 `sudo` 命令先问** — 一旦执行可能弄坏东西
4. **公开的内容要合适** — `game.boobank.com` 是公开的,任何人都看得到,**别放不该公开的东西**(密码、个人信息、不适合的图)
5. **服务器是大家的** — 别开 100 个进程占内存把游戏服务器挤掉了
6. **遇到不确定的事就停一下** — 问爸爸或问 Claude Code,**不要硬试**

## 可以放心做的事

- 写代码、写游戏、写文档
- 在 `/home/kid/` 装东西、写文件
- 在 `/opt/games/` 加新游戏目录、git pull、改你自己的游戏
- 跑你白名单里的 `sudo` 命令
- 重启你自己的游戏服务器

## 紧急联系

- 不知道怎么办 → 问爸爸
- 改坏了 → 问爸爸(早说比晚说好)
- 想加新权限 → 问爸爸
- 想加新游戏路由(联机类的)→ 问爸爸

---

# 📚 参考文档

| 文档 | 在哪 | 干啥用 |
|---|---|---|
| `arena-shooter-3d/KIDS_GUIDE.md` | 那个游戏仓库里 | 怎么玩、怎么改 Arena Shooter |
| `arena-shooter-3d/OPERATIONS.md` | 那个游戏仓库里 | 完整的运维命令(给爸爸用,你也能查) |
| `arena-shooter-3d/SERVER_GUIDE.md` | 那个游戏仓库里 | 整套架构 + 从零搭建步骤 |
| `portal/README.md` | 门户仓库里 | 门户怎么改 |
| 本文(`portal/ONBOARDING.md`) | 门户仓库里 | **你的入门手册(就是这份)** |

---

🎮 **欢迎加入,玩得开心**!做出新游戏一定给爸爸 demo 一下。
