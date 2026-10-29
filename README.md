# Antigravity Proxy Helper for macOS

一个原生 macOS 小工具，用于检测本机 HTTP／SOCKS5 代理，并带代理环境启动 Google Antigravity。

它解决的典型问题是：浏览器能访问 Google，但 Antigravity 登录时直接连接 `oauth2.googleapis.com` 超时。工具会识别常见的 Veee、Clash、Mihomo、Surge 等本机监听端口，使用 Google OAuth 接口做链路检测，并在重新启动 Antigravity 时注入 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 和 Chromium 的代理参数。

## 先下载这个（普通用户）

如果你只是想使用，不需要看源码，也不要下载整个仓库。请直接点击下面的链接：

**[下载 Antigravity代理助手-Mac.zip](https://github.com/tan-shu/antigravity-proxy-helper-macos/raw/refs/heads/main/outputs/Antigravity代理助手-Mac.zip)**

下载后按下面操作：

1. 双击 ZIP 解压。
2. 打开解压出来的 `Antigravity代理助手.app`。
3. 如果 macOS 提示“无法验证开发者”，在 Finder 中右键点击 App，选择“打开”，再确认一次。
4. 先启动 Veee、Clash 或其他代理软件，再打开助手。
5. 在助手中点击「自动识别代理」，然后点击「检测代理连接」。
6. 完全退出 Antigravity，再点击「通过代理启动」。

> 仓库页面里的 `outputs/Antigravity代理助手-Mac.zip` 就是上面这个可直接使用的文件。不要下载 `源码` 文件夹，也不需要自己编译。

## 使用

1. 打开你的代理软件并连接可用节点。
2. 双击 `Antigravity代理助手.app`。
3. 点击「自动识别代理」，或手动填写 HTTP／SOCKS5 地址和端口。
4. 点击「检测代理连接」，确认能收到 Google 的 HTTP 响应。
5. 完全退出 Antigravity（菜单栏「Antigravity → Quit Antigravity」）。
6. 回到助手，点击「通过代理启动」。
7. 在 Antigravity 中点击「Continue with Google」完成登录。

必须从助手启动新的 Antigravity 进程；从 Dock、Spotlight 或 Finder 直接打开，可能不会继承代理环境变量。

## macOS 限制

这是启动器和诊断工具，不是 Windows 版 DLL 的 macOS 移植。它不修改系统代理，不解密 HTTPS，也不接触账号密码或 OAuth token。某些不读取环境变量的原生组件可能仍需透明代理或 TUN 模式。

## 构建

需要 macOS 和 Xcode Command Line Tools：

```sh
./源码/build.command
```

构建脚本会生成并签名 `Antigravity代理助手.app`，然后运行自检。应用只使用 Apple 系统框架和 `/usr/bin/curl`，没有第三方依赖。

## 仓库文件说明

- `outputs/Antigravity代理助手-Mac.zip`：**普通用户应下载的文件**，解压后即可使用
- `outputs/Antigravity代理助手.app`：已经编译好的 App，也可以直接打开
- `outputs/使用说明.md`：详细使用和故障排查说明
- `源码/main.swift`：源代码，仅供开发者查看或修改
- `源码/build.command`：从源代码重新编译的脚本，仅供开发者使用

## 许可证

本项目为针对 macOS 的独立启动器，和 [yuaotian/antigravity-proxy](https://github.com/yuaotian/antigravity-proxy) 没有代码隶属关系。请遵守 Antigravity、代理软件和相关服务的使用条款。
