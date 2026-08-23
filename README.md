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
- 提供 SVG/PFF2 可复现构建、QEMU 预览和备份优先的安装脚本。

## 已验证环境

- Arch Linux
- GRUB `2.14`
- UEFI/GOP `2880x1800`
- JetBrainsMono Nerd Font Mono
- QEMU + OVMF 原生分辨率预览

主题不会安装或改写 EFI 可执行文件。它只部署 gfxmenu 资源，并更新 `/etc/default/grub` 与生成的 `/boot/grub/grub.cfg`。

## 快速安装

仓库已包含 `dist/xiaoxin-tui/`，安装前先检查计划：

```sh
./scripts/install.sh --dry-run
./scripts/install.sh
```

安装器会：

1. 备份现有主题目录、`/etc/default/grub` 和 `/boot/grub/grub.cfg`。
2. 安装主题到 `/boot/grub/themes/xiaoxin-tui`。
3. 设置 `GRUB_GFXMODE=2880x1800,auto` 和 `GRUB_THEME`。
4. 在临时文件中运行 `grub-mkconfig` 与 `grub-script-check`。
5. 仅在校验通过后替换正式 `grub.cfg`。

可使用 `--build` 在安装前重新构建资源：

```sh
./scripts/install.sh --build
```

## 构建

Arch Linux 构建依赖：

```sh
sudo pacman -S --needed grub librsvg libxml2 ttf-jetbrains-mono-nerd
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

部署前备份数据分区中已有的 `/ventoy/ventoy.json` 和同名主题目录，然后复制发布树：

```sh
cp -R ventoy/dist/ventoy /path/to/ventoy-data-partition/
```

主题只应放在保存 ISO 文件的第一个 Ventoy 数据分区。不要将主题或 `ventoy.json` 写入 32 MiB 的 `VTOYEFI` 分区。Ventoy 会按固件实际采用的分辨率自动匹配目录名中的小写 `宽x高`；也可以在 `F5 Tools -> Theme Select` 中临时切换主题。图形模式不兼容时可按 `F7` 临时切换到文本模式。

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
