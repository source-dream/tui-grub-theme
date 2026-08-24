# tui-grub-theme

[English](README.md) | [简体中文](README.zh-CN.md)

一款终端风格的 GRUB 2、Plymouth 与 Ventoy 主题，使用原生菜单、Nerd Font
图标、克制的状态色以及可复现的构建脚本。

![GRUB 预览](assets/screenshots/qemu-2880x1800.png)

## 功能特性

- 使用原生 GRUB `boot_menu`、入口类别、倒计时标签和进度条。
- 提供可选的轻量 Plymouth 线条动画，用于内核启动交接阶段。
- 提供 `2880x1800` 与 `2560x1600` 两套预构建 GRUB profile。
- 提供自适应 Ventoy 版本，覆盖六种常见的 16:10、16:9 和 4:3 分辨率。
- 提供 SVG 源文件和可复现的 PNG/PF2 构建流程。
- GRUB 安装器会先备份，并在替换配置前验证新生成的配置。
- 主题中不包含主机名、磁盘型号、UUID 或设备专用路径。

GRUB、Plymouth 与 Ventoy 版本共享同一套视觉语言，但属于相互独立的软件包。
请根据实际使用的组件选择对应安装章节。

## 安装 GRUB 主题

此安装方式要求系统已在 Linux 下正常使用 GRUB 2。脚本不会安装 GRUB、
创建 EFI 启动项或修改 EFI 可执行文件。

### 1. 选择分辨率 Profile

| 显示模式 | 预构建目录 | 安装器参数 |
|---|---|---|
| `2880x1800` | `dist/tui-grub-theme/` | `--profile 2880x1800` |
| `2560x1600` | `profiles/2560x1600/dist/tui-grub-theme/` | `--profile 2560x1600` |

默认 profile 是 `2880x1800`。目前未提供其他 GRUB 分辨率；需要广泛自动匹配
分辨率时，请使用 Ventoy 版本。

### 2. 预览安装计划

在仓库根目录执行：

```sh
./scripts/install.sh --profile 2880x1800 --dry-run
```

对于 `2560x1600` 显示器：

```sh
./scripts/install.sh --profile 2560x1600 --dry-run
```

预演模式会列出所有目标路径、备份路径和 GRUB 图形模式，不会修改系统。

### 3. 安装

```sh
./scripts/install.sh --profile 2880x1800
```

需要时将 profile 替换为 `2560x1600`。安装器会：

1. 备份 `/etc/default/grub`、`/boot/grub/grub.cfg` 和已有的
   `/boot/grub/themes/tui-grub-theme/` 目录。
2. 将所选 profile 安装到 `/boot/grub/themes/tui-grub-theme/`。
3. 设置 `GRUB_THEME` 和对应的 `GRUB_GFXMODE`，并保留 `auto` 回退。
4. 生成临时 GRUB 配置。
5. 通过 `grub-script-check` 后才替换 `/boot/grub/grub.cfg`。

安装前重新构建所选 profile：

```sh
./scripts/install.sh --profile 2880x1800 --build
```

### 恢复 GRUB 备份

安装器会输出带时间戳的准确备份路径。必要时可从 Linux 或救援环境恢复：

```sh
sudo cp /etc/default/grub.bak-TIMESTAMP /etc/default/grub
sudo cp /boot/grub/grub.cfg.bak-TIMESTAMP /boot/grub/grub.cfg
```

主题故障不会删除固件中的其他 EFI 启动项。

## 安装可选 Plymouth 主题

Plymouth 在 GRUB 完成内核和 initramfs 加载后运行。配套主题按需加载紧凑的
透明帧序列，逐步绘制 Arch 轮廓，并且不会等待动画循环结束。

以下步骤适用于使用 `mkinitcpio` 的 Arch Linux。编辑前先备份配置：

```sh
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak-TIMESTAMP
sudo cp /etc/default/grub /etc/default/grub.bak-TIMESTAMP
sudo pacman -S --needed plymouth
sudo cp /etc/plymouth/plymouthd.conf /etc/plymouth/plymouthd.conf.bak-TIMESTAMP
sudo install -d /usr/share/plymouth/themes/tui-boot
sudo cp -a plymouth/tui-boot/. /usr/share/plymouth/themes/tui-boot/
sudo plymouth-set-default-theme tui-boot
```

在 `/etc/mkinitcpio.conf` 的 `HOOKS` 数组中将 `plymouth` 放到 `systemd`
之后，并在 `/etc/default/grub` 的 `GRUB_CMDLINE_LINUX_DEFAULT` 中加入
`splash`。然后重新生成：

```sh
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub-script-check /boot/grub/grub.cfg
```

主题不会替主机决定 `quiet` 和 `loglevel` 策略。启动时按 `Esc` 可显示详细
日志。恢复入口可在内核参数中加入 `plymouth.enable=0` 并省略 `splash`，无需
重新生成 initramfs 即可绕过 Plymouth。

## 安装 Ventoy 主题

预构建 Ventoy 包可以从 Windows 或 Linux 部署，不要求从源码构建。

### 前置条件

- U 盘已经安装 Ventoy `1.1+`。
- 能访问 Ventoy 存放 ISO 文件的第一个大容量数据分区。
- 不要把这些文件复制到 32 MiB 的 `VTOYEFI` 分区。

### 1. 复制主题目录

复制以下目录中的内容：

```text
ventoy/dist/ventoy/theme/
```

目标位置：

```text
Windows: E:\ventoy\theme\
Linux:  /path/to/ventoy-data/ventoy/theme/
```

请使用实际盘符或挂载点。最终目录结构必须是：

```text
Ventoy 数据分区/
└── ventoy/
    ├── ventoy.json
    └── theme/
        ├── tui-grub-theme/
        │   └── fonts/
        ├── tui-grub-theme_2880x1800/
        ├── tui-grub-theme_2560x1600/
        ├── tui-grub-theme_1920x1200/
        ├── tui-grub-theme_1920x1080/
        ├── tui-grub-theme_1366x768/
        └── tui-grub-theme_1024x768/
```

不要额外创建 `ventoy/ventoy` 或 `theme/theme` 目录。

Linux 示例：

```sh
VENTOY_ROOT=/path/to/ventoy-data
mkdir -p "$VENTOY_ROOT/ventoy/theme"
cp -R ventoy/dist/ventoy/theme/. "$VENTOY_ROOT/ventoy/theme/"
sync
```

在 Windows 中，用文件资源管理器打开 `ventoy\dist\ventoy\theme`，将其中
七个目录全部复制到 `E:\ventoy\theme\`。

### 2. 配置 `ventoy.json`

如果 U 盘中尚无 `ventoy/ventoy.json`，将：

```text
ventoy/dist/ventoy/ventoy.json
```

复制为 U 盘中的 `ventoy/ventoy.json`。

如果配置已存在，请勿直接覆盖。先备份，然后合并所提供 JSON 中顶层的
`theme` 对象。需要 Arch、Linux 和 Windows 自定义图标时，再合并可选的
`menu_class` 数组。

所提供配置使用：

- 包含每个已打包分辨率路径的主题文件数组。
- `default_file: 0` 与 `resolution_fit: 1` 自动过滤匹配项。
- 仅包含有对应主题资源的 `gfxmode` 列表。
- 高、中、低三档共享 PF2 字体。

每条主题路径中的小写 `WIDTHxHEIGHT` 是 Ventoy 匹配分辨率的必要条件。

### 3. 验证并安全弹出

弹出 U 盘前：

1. 确认每个分辨率目录都包含 `theme.txt`、`background.png` 和 `icons/`。
2. 确认 `ventoy.json` 是合法 JSON。在 Linux 中执行：

   ```sh
   jq empty /path/to/ventoy-data/ventoy/ventoy.json
   ```

3. 刷新写入缓存并安全弹出或卸载数据分区。

Ventoy 会自动选择匹配主题。可使用 `F5 Tools -> Theme Select` 临时手动选择，
或按 `F7` 回退到文本模式。

![Ventoy 预览](ventoy/assets/screenshots/qemu-2880x1800.png)

## 从源码构建

Arch Linux 依赖：

```sh
sudo pacman -S --needed grub librsvg libxml2 jq file imagemagick \
  ttf-jetbrains-mono-nerd noto-fonts-cjk
```

构建并验证两套 GRUB profile：

```sh
make build
make check
```

重新生成并检查 Plymouth 资源：

```sh
make build-plymouth
make check-plymouth
```

构建并验证自适应 Ventoy 包：

```sh
make build-ventoy
make check-ventoy
```

脚本使用 Fontconfig 查找 JetBrainsMono Nerd Font Mono 与 Noto Sans Mono CJK SC。
也可通过 `NERD_FONT_FILE`、`CJK_FONT_FILE` 和 `CJK_FONT_INDEX` 显式指定字体。

## 预览

安装 `grub2-theme-preview`、QEMU、OVMF、mtools 和 xorriso 后执行：

```sh
make preview
```

也可向预览脚本传入其他分辨率：

```sh
RESOLUTION=2560x1600 ./scripts/preview.sh --no-kvm
```

## 仓库结构

```text
.
├── assets/screenshots/                 # GRUB 预览图
├── dist/tui-grub-theme/                # 默认 2880x1800 GRUB 包
├── profiles/2560x1600/                 # 通用 2560x1600 GRUB profile
├── plymouth/                            # 可选的动态启动交接主题
├── scripts/                             # 构建、检查、安装和预览脚本
├── src/                                 # 默认 GRUB SVG/主题源文件
├── ventoy/src/                          # 自适应 Ventoy 源文件
├── ventoy/dist/ventoy/                  # 可直接部署的 Ventoy 包
└── .github/workflows/                   # 持续验证
```

## 动态与静态内容

菜单入口、类别图标、选中状态和倒计时由 GRUB 原生组件渲染。背景只包含通用
主题和组件信息，不写入主机名、磁盘型号、UUID 或启动项名称。

默认 GRUB 背景包含五行菜单的视觉分隔。菜单条目更多时 GRUB 可以滚动，
但调整布局时仍需保持背景分隔线、`boot_menu` 高度和条目高度一致。

## 许可证

主题源码使用 [MIT](LICENSE) 许可证。生成的 PF2 字体和字体衍生图标保留上游
SIL OFL 1.1 条款，详情见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
