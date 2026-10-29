# Antigravity Proxy Helper for macOS

一个原生 macOS 小工具，用于检测本机 HTTP／SOCKS5 代理，并带代理环境启动 Google Antigravity。

它解决的典型问题是：浏览器能访问 Google，但 Antigravity 登录时直接连接 `oauth2.googleapis.com` 超时。工具会识别常见的 Veee、Clash、Mihomo、Surge 等本机监听端口，使用 Google OAuth 接口做链路检测，并在重新启动 Antigravity 时注入 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 和 Chromium 的代理参数。

## 如果你只是想使用

不用研究源码，也不用下载整个仓库。直接下载这个压缩包就可以：

**[下载 Antigravity代理助手-Mac.zip](https://github.com/tan-shu/antigravity-proxy-helper-macos/raw/refs/heads/main/outputs/download/Antigravity代理助手-Mac.zip)**

下载后，解压并按下面的步骤操作：

1. 双击 ZIP 解压。
2. 打开解压出来的 `Antigravity代理助手.app`。
3. 如果 macOS 提示“无法验证开发者”，在 Finder 中右键点击 App，选择“打开”，再确认一次。
4. 先启动 Veee、Clash 或其他代理软件，并连接好节点。
5. 打开代理助手，点击「自动识别代理」，再点击「检测代理连接」。
6. 如果 Antigravity 已经打开，请先完全退出它，然后回到助手，点击「通过代理启动」。

仓库里如果看到 `outputs/source`、`outputs/app` 等文件夹，不用下载它们；它们分别是源码和开发用文件。普通用户只需要上面的 ZIP 文件。

## 它是做什么的？

这个小工具会检查本机代理是否能访问 Google，然后带着正确的代理配置启动 Antigravity。这样可以解决“浏览器能上 Google，但 Antigravity 登录时连接超时”的情况。

每次需要登录或使用 Antigravity 时，建议都从这个助手启动。直接从 Dock、Spotlight 或 Finder 打开 Antigravity，可能不会带上代理配置。

## 详细使用步骤

1. 打开代理软件，并连接一个可用节点。
2. 打开 `Antigravity代理助手.app`。
3. 点击「自动识别代理」。如果没有识别到，也可以手动填写 HTTP 或 SOCKS5 地址和端口。
4. 点击「检测代理连接」，看到检测成功后再继续。
5. 完全退出 Antigravity（菜单栏选择「Antigravity → Quit Antigravity」）。
6. 回到助手，点击「通过代理启动」。
7. 在 Antigravity 中点击「Continue with Google」登录。

如果登录仍然失败，先确认代理软件正在运行，再重复第 5、6 步。必要时可以打开 `outputs/docs/使用说明.md` 查看排查建议。

## 说明

这是一个 macOS 启动器和诊断工具，不是 Windows 版 DLL 的 macOS 移植。它不会修改系统代理、解密 HTTPS，也不会读取账号密码或 OAuth token。少数不读取环境变量的组件，可能仍需要代理软件开启透明代理或 TUN 模式。

## 构建

需要 macOS 和 Xcode Command Line Tools：

```sh
./outputs/source/build.command
```

构建脚本会生成并签名 `Antigravity代理助手.app`，然后运行自检。应用只使用 Apple 系统框架和 `/usr/bin/curl`，没有第三方依赖。

## 文件夹怎么分？

### 普通用户

- `outputs/download/Antigravity代理助手-Mac.zip`：**普通用户下载这个**，解压后即可使用

### 已编译程序

- `outputs/app/Antigravity代理助手.app`：已经编译好的 App，可直接打开

### 说明和开发文件

- `outputs/docs/使用说明.md`：详细使用和故障排查说明
- `outputs/source/main.swift`：源代码，仅供开发者查看或修改
- `outputs/source/build.command`：从源代码重新编译的脚本，仅供开发者使用
- `outputs/assets/代理助手图标.png`：项目图标源文件

## 许可证

本项目为针对 macOS 的独立启动器，和 [yuaotian/antigravity-proxy](https://github.com/yuaotian/antigravity-proxy) 没有代码隶属关系。请遵守 Antigravity、代理软件和相关服务的使用条款。
