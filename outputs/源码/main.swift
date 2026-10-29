import Cocoa

struct Settings: Codable {
    var host = "127.0.0.1"
    var port = "7890"
    var kind = "HTTP"
    var app = "/Applications/Antigravity.app"
    var proxy: String { "\(kind == "HTTP" ? "http" : "socks5h")://\(host.contains(":") ? "[\(host)]" : host):\(port)" }
    var chromiumProxy: String { proxy.replacingOccurrences(of: "socks5h://", with: "socks5://") }
    func validate() throws {
        guard !host.isEmpty, host.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-:").inverted) == nil,
              let p = Int(port), (1...65535).contains(p), ["HTTP", "SOCKS5"].contains(kind) else {
            throw NSError(domain: "配置", code: 1, userInfo: [NSLocalizedDescriptionKey: "请输入有效的主机名或 IP，以及 1–65535 的端口；地址不要包含协议或密码。"])
        }
    }
}

let storage = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("AntigravityProxyHelper")
let configFile = storage.appendingPathComponent("settings.json")

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let host = NSTextField(), port = NSTextField(), path = NSTextField()
    let kind = NSPopUpButton()
    let log = NSTextView()
    var actions: [NSButton] = []
    var settings = Settings()
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let data = try? Data(contentsOf: configFile), let saved = try? JSONDecoder().decode(Settings.self, from: data) { settings = saved }
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 610), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Antigravity 代理助手"
        window.center()
        let view = window.contentView!
        func label(_ text: String, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ size: CGFloat = 13) {
            let l = NSTextField(wrappingLabelWithString: text)
            l.frame = NSRect(x: x, y: y, width: width, height: size > 20 ? 38 : 45)
            l.font = .systemFont(ofSize: size, weight: size > 20 ? .semibold : .regular)
            view.addSubview(l)
        }
        label("让 Antigravity 通过你的代理启动", 28, 543, 640, 25)
        label("先启动代理软件，再检测连接。HTTP 适合 mixed / HTTP 端口；SOCKS5 适合 SOCKS 端口。", 28, 489, 640)
        label("代理协议", 28, 439, 100)
        kind.frame = NSRect(x: 130, y: 454, width: 145, height: 28)
        kind.addItems(withTitles: ["HTTP", "SOCKS5"])
        kind.selectItem(withTitle: settings.kind)
        view.addSubview(kind)
        label("主机", 28, 393, 90)
        host.frame = NSRect(x: 130, y: 412, width: 310, height: 25)
        host.stringValue = settings.host; view.addSubview(host)
        label("端口", 463, 393, 55)
        port.frame = NSRect(x: 520, y: 412, width: 145, height: 25)
        port.stringValue = settings.port; view.addSubview(port)
        label("应用位置", 28, 348, 100)
        path.frame = NSRect(x: 130, y: 366, width: 440, height: 25)
        path.stringValue = settings.app; view.addSubview(path)
        func button(_ name: String, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ selector: Selector, _ tracked: Bool = true) {
            let b = NSButton(title: name, target: self, action: selector)
            b.frame = NSRect(x: x, y: y, width: w, height: 34); b.bezelStyle = .rounded
            view.addSubview(b); if tracked { actions.append(b) }
        }
        button("选择…", 575, 362, 95, #selector(choose), false)
        button("自动识别代理", 25, 310, 150, #selector(detect))
        button("保存配置", 180, 310, 110, #selector(save))
        button("检测代理连接", 295, 310, 165, #selector(test))
        button("通过代理启动", 465, 310, 205, #selector(launch))
        label("已有 Antigravity 窗口时，请先自行完全退出后再启动。此工具不修改系统代理。", 28, 257, 640)
        let scroll = NSScrollView(frame: NSRect(x: 28, y: 83, width: 640, height: 179))
        scroll.hasVerticalScroller = true; scroll.borderType = .bezelBorder
        log.frame = NSRect(x: 0, y: 0, width: 620, height: 179)
        log.minSize = NSSize(width: 0, height: 179)
        log.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        log.textContainer?.containerSize = NSSize(width: 620, height: CGFloat.greatestFiniteMagnitude)
        log.textContainer?.widthTracksTextView = true
        log.isEditable = false; log.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        log.autoresizingMask = [.width]; log.isVerticallyResizable = true
        scroll.documentView = log; view.addSubview(scroll)
        label("启动参数只能覆盖支持代理的网络栈，Agent 实际连通性需在编辑器内验证。本工具不是原项目的 DLL 移植版。", 28, 25, 640)
        append("就绪。配置保存在当前用户的 Application Support / AntigravityProxyHelper。")
        window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
    }
    func append(_ message: String) {
        log.string += "[\(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))] \(message)\n"
        log.scrollToEndOfDocument(nil)
    }
    func read() throws -> Settings {
        let s = Settings(host: host.stringValue.trimmingCharacters(in: .whitespacesAndNewlines), port: port.stringValue.trimmingCharacters(in: .whitespacesAndNewlines), kind: kind.titleOfSelectedItem ?? "HTTP", app: path.stringValue)
        try s.validate(); return s
    }
    func persist(_ s: Settings) throws {
        try FileManager.default.createDirectory(at: storage, withIntermediateDirectories: true)
        try JSONEncoder().encode(s).write(to: configFile, options: .atomic)
        settings = s
    }
    @objc func choose() {
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowedFileTypes = ["app"]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        if panel.runModal() == .OK, let url = panel.url { path.stringValue = url.path }
    }
    @objc func save() {
        do { try persist(read()); append("配置已保存。") } catch { append(error.localizedDescription) }
    }
    @objc func detect() {
        actions.forEach { $0.isEnabled = false }
        append("正在识别 Veee / Clash / Mihomo / Surge 等本机代理，并验证 Google 登录接口…")
        DispatchQueue.global(qos: .userInitiated).async {
            let listing = Process(); listing.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
            listing.arguments = ["-nP", "-iTCP", "-sTCP:LISTEN"]
            let pipe = Pipe(); listing.standardOutput = pipe; listing.standardError = FileHandle.nullDevice
            var ports: [String] = []
            do {
                try listing.run()
                let text = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                listing.waitUntilExit()
                for line in text.components(separatedBy: "\n") {
                    let lower = line.lowercased()
                    if ["veee", "clash", "mihomo", "surge", "sing-box", "v2ray", "xray"].contains(where: { lower.contains($0) }),
                       let endpoint = line.split(separator: " ").first(where: { $0.hasPrefix("127.0.0.1:") }),
                       let port = endpoint.split(separator: ":").last {
                        if !ports.contains(String(port)) { ports.append(String(port)) }
                    }
                }
            } catch {}
            if ports.isEmpty { ports = ["7890", "7897", "10809", "1080", "6152", "15236", "15235"] }
            for protocolName in ["HTTP", "SOCKS5"] {
                for port in ports {
                    let s = Settings(host: "127.0.0.1", port: port, kind: protocolName)
                    let task = Process(); task.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
                    task.arguments = ["--disable", "--proxy", s.proxy, "--noproxy", "", "--connect-timeout", "1", "--max-time", "4", "--silent", "--output", "/dev/null", "--write-out", "%{http_code}", "https://oauth2.googleapis.com/token"]
                    let output = Pipe(); task.standardOutput = output; task.standardError = FileHandle.nullDevice
                    do {
                        try task.run(); task.waitUntilExit()
                        let response = String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "000"
                        if task.terminationStatus == 0, let code = Int(response), code >= 200, code != 407 {
                            DispatchQueue.main.async {
                                self.host.stringValue = s.host; self.port.stringValue = s.port; self.kind.selectItem(withTitle: s.kind)
                                do { try self.persist(self.read()); self.append("已识别并保存：\(s.proxy)，Google 登录接口 HTTP \(code)。请完全退出 Antigravity 后，通过本助手启动。") } catch { self.append(error.localizedDescription) }
                                self.actions.forEach { $0.isEnabled = true }
                            }
                            return
                        }
                    } catch {}
                }
            }
            DispatchQueue.main.async { self.append("未找到可连接 Google 的本机代理。请检查代理软件与节点后重试，或手动填写端口。"); self.actions.forEach { $0.isEnabled = true } }
        }
    }
    @objc func test() {
        do {
            let s = try read(); try persist(s)
            actions.forEach { $0.isEnabled = false }; append("正在通过 \(s.proxy) 检测 Google OAuth 和 Cloud Code（每项最多 12 秒）…")
            DispatchQueue.global(qos: .userInitiated).async {
                for url in ["https://oauth2.googleapis.com/", "https://daily-cloudcode-pa.googleapis.com/"] {
                    let task = Process(); task.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
                    task.arguments = ["--disable", "--proxy", s.proxy, "--noproxy", "", "--connect-timeout", "5", "--max-time", "12", "--silent", "--show-error", "--output", "/dev/null", "--write-out", "%{http_code}", url]
                    let output = Pipe(), errors = Pipe(); task.standardOutput = output; task.standardError = errors
                    do {
                        try task.run(); task.waitUntilExit()
                        let code = String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                        let error = String(data: errors.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                        let msg = task.terminationStatus == 0 ? "连接可达：\(url) HTTP \(code)（401/403/404 等也表示已收到服务器响应，不代表账号或 Agent 可用）" : "连接失败：\(url) \(error)"
                        DispatchQueue.main.async { self.append(msg) }
                    } catch { let msg = error.localizedDescription; DispatchQueue.main.async { self.append(msg) } }
                }
                DispatchQueue.main.async { self.actions.forEach { $0.isEnabled = true }; self.append("检测完成。请在 Antigravity 内发送消息验证 Agent。") }
            }
        } catch { append(error.localizedDescription) }
    }
    @objc func launch() {
        do {
            let s = try read()
            guard let bundle = Bundle(path: s.app), let exe = bundle.executableURL, FileManager.default.isExecutableFile(atPath: exe.path), bundle.bundleIdentifier?.lowercased().contains("antigravity") == true else {
                append("未找到有效的 Antigravity.app，请重新选择应用位置。"); return
            }
            if NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == bundle.bundleIdentifier }) {
                append("Antigravity 正在运行。请用 ⌘Q 完全退出后再点击启动，避免代理参数被已有进程忽略。"); return
            }
            try persist(s)
            let task = Process(); task.executableURL = exe
            task.arguments = ["--proxy-server=\(s.chromiumProxy)", "--proxy-bypass-list=localhost;127.0.0.1;[::1]"]
            var env = ProcessInfo.processInfo.environment
            for key in ["HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"] { env[key] = s.proxy }
            for key in ["NO_PROXY", "no_proxy"] { env[key] = "localhost,127.0.0.1,::1" }
            task.environment = env
            let file = storage.appendingPathComponent("launch.log")
            if !FileManager.default.fileExists(atPath: file.path) { FileManager.default.createFile(atPath: file.path, contents: nil) }
            let handle = try FileHandle(forWritingTo: file); try handle.seekToEnd()
            task.standardOutput = handle; task.standardError = handle
            try task.run(); try? handle.close()
            append("已发起启动，PID \(task.processIdentifier)，代理 \(s.proxy)。这不代表 Agent 已连接；请进入编辑器验证。启动日志：\(file.path)")
        } catch { append("操作失败：\(error.localizedDescription)") }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

if CommandLine.arguments.contains("--self-test") {
    try Settings().validate()
    assert(Settings(host: "::1", port: "1080", kind: "SOCKS5").proxy == "socks5h://[::1]:1080")
    assert(Settings(kind: "SOCKS5").chromiumProxy == "socks5://127.0.0.1:7890")
    for bad in [Settings(host: "x;touch a"), Settings(port: "0"), Settings(port: "65536"), Settings(host: "http://localhost")] {
        do { try bad.validate(); fatalError("Accepted invalid setting") } catch {}
    }
    let original = Settings(kind: "SOCKS5")
    let restored = try JSONDecoder().decode(Settings.self, from: JSONEncoder().encode(original))
    assert(restored.proxy == original.proxy)
    print("PASS: validation, IPv6, SOCKS protocol mapping, settings round trip")
} else {
    let app = NSApplication.shared
    let delegate = AppDelegate(); app.delegate = delegate
    app.setActivationPolicy(.regular); app.run()
}
