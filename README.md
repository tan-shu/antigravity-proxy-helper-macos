# Antigravity Proxy Helper for macOS

一个原生 macOS 小工具，用于检测本机 HTTP／SOCKS5 代理，并带代理环境启动 Google Antigravity。

它解决的典型问题是：浏览器能访问 Google，但 Antigravity 登录时直接连接 `oauth2.googleapis.com` 超时。工具会识别常见的 Veee、Clash、Mihomo、Surge 等本机监听端口，使用 Google OAuth 接口做链路检测，并在重新启动 Antigravity 时注入 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 和 Chromium 的代理参数。

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

## 文件

- `源码/main.swift`：AppKit 界面、端口识别、连通性检测和代理启动逻辑
- `源码/build.command`：本机编译和签名脚本
- `outputs/Antigravity代理助手.app`：可直接双击的应用
- `outputs/使用说明.md`：详细使用和故障排查说明

## 许可证

本项目为针对 macOS 的独立启动器，和 [yuaotian/antigravity-proxy](https://github.com/yuaotian/antigravity-proxy) 没有代码隶属关系。请遵守 Antigravity、代理软件和相关服务的使用条款。
