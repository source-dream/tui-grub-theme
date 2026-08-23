# tui-grub-theme

一套面向高分辨率屏幕的 GRUB 2 TUI 主题。设计参考现代终端界面，使用单层轮廓、Nerd Font 图标和克制的状态色，同时保留 GRUB 原生菜单行为。

仓库同时提供独立的 Ventoy 变体，用于跨设备多启动和恢复 U 盘。两套主题共享视觉语言，但菜单容量、运行时状态和图标分类分别适配各自的引导器。

![GRUB QEMU preview](assets/screenshots/qemu-2880x1800.png)

## 特性

- 针对 `2880x1800` 原生分辨率设计，并配置 `auto` 回退。
- 菜单文字、选中框和滚动行为由 GRUB 原生 `boot_menu` 渲染。
- 根据 menuentry class 动态显示 Arch Linux 和 Windows 图标。
- 倒计时文字及进度条由 `__timeout__` 组件实时更新。
- 提供已构建资源，可直接安装，无需在目标机重新生成字体。
- 提供 SVG/PF2 可复现构建、QEMU 预览和备份优先的安装脚本。

## 已验证环境

- Arch Linux
- GRUB `2.14`
- UEFI/GOP `2880x1800`
- JetBrainsMono Nerd Font Mono
- QEMU + OVMF 原生分辨率预览

主题不会安装或改写 EFI 可执行文件。它只部署 gfxmenu 资源，并更新 `/etc/default/grub` 与生成的 `/boot/grub/grub.cfg`。

## 选择安装目标

| 目标 | 适用系统 | 入口 |
|---|---|---|
| 小新 GRUB 主题 | 安装了 GRUB 2 的 Linux | `./scripts/install.sh` |
| Redmi G GRUB 主题 | Redmi G 上安装了 GRUB 2 的 Linux | `./devices/redmi/scripts/install.sh` |
| Ventoy U 盘主题 | Windows 或 Linux | 复制 `ventoy/dist/ventoy/` 中的预构建文件 |

GRUB 主题需要修改 Linux 的 `/boot/grub` 和 `/etc/default/grub`，不能在 Windows 中安装。Ventoy 主题只是数据分区中的普通文件，Windows 和 Linux 都可以部署，不需要在目标电脑上安装 GRUB 构建工具。

## 安装 GRUB 主题（Linux）

### 小新版本

当前预构建版本针对小新的 `2880x1800` 屏幕。进入仓库根目录，先查看安装计划，再执行安装：

```sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

安装器会：

1. 备份现有主题目录、`/etc/default/grub` 和 `/boot/grub/grub.cfg`。
2. 将 `dist/xiaoxin-tui/` 安装到 `/boot/grub/themes/xiaoxin-tui/`。
3. 设置 `GRUB_GFXMODE=2880x1800,auto` 和 `GRUB_THEME`。
4. 在临时文件中运行 `grub-mkconfig` 与 `grub-script-check`。
5. 仅在校验通过后替换正式 `grub.cfg`。

需要从源码重新生成资源时使用：

```sh
./scripts/install.sh --build
```

### Redmi G 版本

Redmi G 使用独立的 `2560x1600` 主题。安装前先检查预构建资源：

```sh
./devices/redmi/scripts/check.sh
./devices/redmi/scripts/install.sh
```

它会安装到 `/boot/grub/themes/redmi-tui/`，不会使用或覆盖小新的主题目录。

## 安装 Ventoy 主题（Windows / Linux）

### 前置条件

- U 盘已经使用 Ventoy 制作，建议使用 Ventoy `1.1+`。
- 仓库已包含预构建主题，部署时不需要 Linux、WSL 或 GRUB 工具链。
- 操作的是保存 ISO 文件的 Ventoy **第一数据分区**，不是 32 MiB 的 `VTOYEFI` 分区。

假设 Ventoy 数据分区根目录为 `E:\`（Windows）或 `/run/media/user/ISO/`（Linux），部署后的关键结构应为：

```text
Ventoy 数据分区根目录/
└── ventoy/
    ├── ventoy.json
    └── theme/
        ├── xiaoxin-tui/
        │   └── fonts/
        ├── xiaoxin-tui_2880x1800/
        ├── xiaoxin-tui_2560x1600/
        ├── xiaoxin-tui_1920x1200/
        ├── xiaoxin-tui_1920x1080/
        ├── xiaoxin-tui_1366x768/
        └── xiaoxin-tui_1024x768/
```

当前 `xiaoxin-tui` 是 Ventoy 变体沿用的旧目录前缀；它不会限制主题只能在小新上运行。后续版本会将该跨设备变体改为通用名称。

### 复制主题文件

从仓库复制：

```text
ventoy/dist/ventoy/theme/
```

到 U 盘：

```text
Windows: E:\ventoy\theme\
Linux:  /Ventoy数据分区挂载点/ventoy/theme/
```

复制的是源目录中的**全部主题子目录**，不要额外嵌套一层 `theme/theme` 或 `ventoy/ventoy`。

复制前应备份已有的 `ventoy/ventoy.json` 和所有即将被同名覆盖的主题目录。

Linux 示例：

```sh
VENTOY_ROOT=/run/media/user/ISO
mkdir -p "$VENTOY_ROOT/ventoy/theme"
cp -R ventoy/dist/ventoy/theme/. "$VENTOY_ROOT/ventoy/theme/"
sync
```

Windows 可以在资源管理器中打开 `ventoy\dist\ventoy\theme`，将其中所有目录复制到 U 盘的 `E:\ventoy\theme\`。

### 配置 `ventoy.json`

如果 U 盘中不存在 `ventoy/ventoy.json`，直接复制：

```text
仓库：ventoy/dist/ventoy/ventoy.json
目标：Ventoy数据分区/ventoy/ventoy.json
```

如果 U 盘已经存在 `ventoy.json`，**不要直接覆盖**。先创建 `ventoy.json.bak-时间戳`，再把仓库 JSON 中顶层的 `theme` 配置合并进去；需要 Arch、Windows 等自定义分类图标时，再合并 `menu_class` 数组。核心主题配置如下：

```json
"theme": {
  "file": [
    "/ventoy/theme/xiaoxin-tui_2880x1800/theme.txt",
    "/ventoy/theme/xiaoxin-tui_2560x1600/theme.txt",
    "/ventoy/theme/xiaoxin-tui_1920x1200/theme.txt",
    "/ventoy/theme/xiaoxin-tui_1920x1080/theme.txt",
    "/ventoy/theme/xiaoxin-tui_1366x768/theme.txt",
    "/ventoy/theme/xiaoxin-tui_1024x768/theme.txt"
  ],
  "default_file": 0,
  "resolution_fit": 1,
  "gfxmode": "2880x1800,2560x1600,1920x1200,1920x1080,1366x768,1024x768",
  "display_mode": "GUI",
  "ventoy_left": "72%",
  "ventoy_top": "7%",
  "ventoy_color": "#748096",
  "fonts": [
    "/ventoy/theme/xiaoxin-tui/fonts/JetBrainsMono-Ventoy-24.pf2",
    "/ventoy/theme/xiaoxin-tui/fonts/NotoSansMonoCJKSC-Menu-28.pf2",
    "/ventoy/theme/xiaoxin-tui/fonts/JetBrainsMono-Ventoy-18.pf2",
    "/ventoy/theme/xiaoxin-tui/fonts/NotoSansMonoCJKSC-Menu-20.pf2",
    "/ventoy/theme/xiaoxin-tui/fonts/JetBrainsMono-Ventoy-14.pf2",
    "/ventoy/theme/xiaoxin-tui/fonts/NotoSansMonoCJKSC-Menu-16.pf2"
  ]
}
```

注意：上面是完整 JSON 文件中的一个顶层成员，不能单独保存为缺少外层 `{}` 的文件。最稳妥的方式是以仓库中的完整 `ventoy.json` 为参考合并。

### 部署后检查

1. 确认 `ventoy.json` 是合法 JSON；Linux 可运行 `jq empty /挂载点/ventoy/ventoy.json`。
2. 确认六个分辨率目录中的 `theme.txt`、`background.png` 和 `icons/` 都存在。
3. 安全弹出或卸载 U 盘后再重启测试。
4. Ventoy 会通过 `resolution_fit` 自动选择与当前图形模式匹配的目录。
5. 可以通过 `F5 Tools -> Theme Select` 临时切换主题，通过 `F7` 切换文本模式。

## 构建

Arch Linux 构建依赖：

```sh
sudo pacman -S --needed grub librsvg libxml2 jq file \
  ttf-jetbrains-mono-nerd noto-fonts-cjk
```

生成发行资源：

```sh
make build
make check
```

默认通过 Fontconfig 定位 `JetBrainsMono Nerd Font Mono`。也可以显式指定字体：

```sh
NERD_FONT_FILE=/path/to/JetBrainsMonoNerdFontMono-Regular.ttf make build
```

## Ventoy 变体

Ventoy 源码位于 `ventoy/src/`，构建结果是可直接复制到 Ventoy 数据分区根目录的 `ventoy/dist/ventoy/`。该变体以 `2880x1800` 为设计基准，构建 `2880x1800`、`2560x1600`、`1920x1200`、`1920x1080`、`1366x768` 和 `1024x768` 六个布局，并由 Ventoy 的 `resolution_fit` 自动选择。每个布局都提供 10 行可滚动菜单、ISO/IMG/WIM/VHD 图标和 Ventoy 运行时状态。

六个布局共用高、中、低三档字体资源，以兼顾可读性和启动盘读取开销。目标分辨率维护在 `ventoy/src/profiles.txt`；布局坐标、菜单资源和图标尺寸由构建脚本从 `2880x1800` 基准按比例生成。

![Ventoy QEMU preview](ventoy/assets/screenshots/qemu-2880x1800.png)

构建与检查：

```sh
make build-ventoy
make check-ventoy
```

完整部署方法见上面的“安装 Ventoy 主题（Windows / Linux）”。修改 U 盘前必须备份已有的 `/ventoy/ventoy.json` 和同名主题目录；不要将主题或配置写入 32 MiB 的 `VTOYEFI` 分区。

## 预览

安装 `grub2-theme-preview`、QEMU、OVMF、mtools 与 xorriso 后运行：

```sh
make preview
```

也可以传递额外参数：

```sh
./scripts/preview.sh --timeout 10 --no-kvm
```

## 目录结构

```text
.
├── assets/screenshots/       # 真实 GRUB/QEMU 截图
├── dist/xiaoxin-tui/         # 可直接安装的主题
├── devices/redmi/            # Redmi G 独立源码、产物和安装脚本
├── scripts/                  # 构建、检查、安装和预览脚本
├── src/                      # SVG 与 theme.txt 源码
├── ventoy/                   # Ventoy 专用源码、发布树和截图
└── .github/workflows/        # 持续集成校验
```

## 动态与静态内容

左侧菜单、Arch/Windows 图标、选中状态和倒计时是动态内容。右侧主机、文件系统、存储设备与 loader 状态是为当前设计制作的静态背景信息，移植到其他设备时应修改 `src/background.svg` 并重新构建。

顶层背景按五个入口排版。GRUB 仍可处理更多入口，但超过可视数量时会滚动；此时建议同步调整菜单高度和背景分隔线。

## 恢复

安装器会输出本次时间戳。若主题显示异常，可从 Linux、Arch 安装介质或其他救援环境恢复：

```sh
sudo cp /etc/default/grub.bak-TIMESTAMP /etc/default/grub
sudo cp /boot/grub/grub.cfg.bak-TIMESTAMP /boot/grub/grub.cfg
```

主题问题不会删除 EFI 引导文件；固件中的 Windows Boot Manager 和 GRUB fallback 仍可独立使用。

## License

Theme source code is licensed under [MIT](LICENSE). Generated PF2 fonts and
font-derived icon assets retain their upstream SIL OFL 1.1 terms; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
