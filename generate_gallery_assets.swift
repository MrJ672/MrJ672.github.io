import AppKit

let canvasWidth: CGFloat = 1242
let canvasHeight: CGFloat = 2688

let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
let outputDirectory = cwd.appendingPathComponent("marketing/site/assets", isDirectory: true)

let iconURL = cwd.appendingPathComponent("marketing/site/assets/icon.png")
let libraryScreenshotURL = cwd.appendingPathComponent("marketing/site/assets/Simulator Screenshot - iPhone 17 Pro - 2026-04-23 at 21.39.32.png")
let ttsScreenshotURL = cwd.appendingPathComponent("marketing/site/assets/Simulator Screenshot - iPhone 17 Pro - 2026-04-23 at 21.36.57.png")
let settingsScreenshotURL = cwd.appendingPathComponent("marketing/site/assets/Simulator Screenshot - iPhone 17 Pro - 2026-04-23 at 21.37.06.png")

struct Palette {
    static let ink = NSColor(hex: "#172033")
    static let muted = NSColor(hex: "#667085")
    static let primary = NSColor(hex: "#738CF2")
    static let teal = NSColor(hex: "#46C7C1")
    static let gold = NSColor(hex: "#D8B56B")
    static let warm = NSColor(hex: "#FFF7EA")
    static let warmDeep = NSColor(hex: "#F6EFE3")
    static let card = NSColor(hex: "#FFFDFC")
    static let shadow = NSColor.black.withAlphaComponent(0.14)
}

extension NSColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(
            red: CGFloat((value >> 16) & 0xff) / 255.0,
            green: CGFloat((value >> 8) & 0xff) / 255.0,
            blue: CGFloat(value & 0xff) / 255.0,
            alpha: alpha
        )
    }
}

func topRect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> NSRect {
    NSRect(x: x, y: canvasHeight - y - height, width: width, height: height)
}

func font(_ size: CGFloat, _ weight: NSFont.Weight = .regular) -> NSFont {
    NSFont.systemFont(ofSize: size, weight: weight)
}

func loadImage(at url: URL, label: String) throws -> NSImage {
    guard let image = NSImage(contentsOf: url) else {
        throw NSError(domain: "GalleryRender", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Unable to load \(label) image at \(url.path)"
        ])
    }
    return image
}

func applyShadow() {
    let shadow = NSShadow()
    shadow.shadowColor = Palette.shadow
    shadow.shadowBlurRadius = 36
    shadow.shadowOffset = NSSize(width: 0, height: -20)
    shadow.set()
}

func drawRoundedRect(
    _ rect: NSRect,
    radius: CGFloat,
    fill: NSColor,
    stroke: NSColor? = nil,
    lineWidth: CGFloat = 1,
    shadow: Bool = false
) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    NSGraphicsContext.saveGraphicsState()
    if shadow { applyShadow() }
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
    NSGraphicsContext.restoreGraphicsState()
}

func drawText(
    _ text: String,
    in rect: NSRect,
    font: NSFont,
    color: NSColor,
    alignment: NSTextAlignment = .left,
    lineHeight: CGFloat? = nil
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    if let lineHeight {
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
    }

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]

    NSString(string: text).draw(
        with: rect,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes
    )
}

func drawBadge(_ text: String, x: CGFloat, y: CGFloat, fill: NSColor, textColor: NSColor) {
    let width = max(118, CGFloat(text.count) * 18 + 56)
    let rect = topRect(x, y, width, 54)
    drawRoundedRect(rect, radius: 27, fill: fill)
    drawText(text, in: rect.insetBy(dx: 16, dy: 10), font: font(22, .semibold), color: textColor, alignment: .center)
}

func drawIcon(_ image: NSImage, in rect: NSRect) {
    let path = NSBezierPath(roundedRect: rect, xRadius: 18, yRadius: 18)
    NSGraphicsContext.saveGraphicsState()
    path.addClip()
    image.draw(in: rect)
    NSGraphicsContext.restoreGraphicsState()
}

func drawBackground(theme: Int) {
    let gradient = NSGradient(colors: [Palette.warm, Palette.warmDeep])!
    gradient.draw(in: topRect(0, 0, canvasWidth, canvasHeight), angle: -90)

    let accents: [NSColor]
    switch theme {
    case 1:
        accents = [Palette.primary.withAlphaComponent(0.10), Palette.teal.withAlphaComponent(0.08), Palette.gold.withAlphaComponent(0.08)]
    case 2:
        accents = [Palette.teal.withAlphaComponent(0.10), Palette.primary.withAlphaComponent(0.08), Palette.gold.withAlphaComponent(0.08)]
    default:
        accents = [Palette.gold.withAlphaComponent(0.10), Palette.primary.withAlphaComponent(0.08), Palette.teal.withAlphaComponent(0.08)]
    }

    accents[0].setFill()
    NSBezierPath(ovalIn: topRect(780, 110, 330, 330)).fill()

    accents[1].setFill()
    NSBezierPath(ovalIn: topRect(20, 1870, 520, 520)).fill()

    accents[2].setFill()
    NSBezierPath(ovalIn: topRect(850, 2140, 210, 210)).fill()

    drawRoundedRect(topRect(740, 462, 390, 88), radius: 44, fill: accents[0])
    drawRoundedRect(topRect(8, 1964, 470, 88), radius: 44, fill: accents[1])
}

func drawHeader(
    badge: String,
    title: String,
    subtitle: String,
    x: CGFloat,
    y: CGFloat,
    width: CGFloat,
    accent: NSColor,
    icon: NSImage
) {
    let iconRect = topRect(x, y, 66, 66)
    drawRoundedRect(iconRect, radius: 20, fill: .white.withAlphaComponent(0.96), shadow: true)
    drawIcon(icon, in: iconRect.insetBy(dx: 8, dy: 8))

    let badgeRect = topRect(x + 86, y + 8, max(146, CGFloat(badge.count) * 18 + 56), 50)
    drawRoundedRect(badgeRect, radius: 25, fill: accent.withAlphaComponent(0.14))
    drawText(badge, in: badgeRect.insetBy(dx: 12, dy: 9), font: font(21, .semibold), color: accent, alignment: .center)

    drawText(title, in: topRect(x, y + 98, width, 190), font: font(66, .bold), color: Palette.ink, lineHeight: 76)
    drawText(subtitle, in: topRect(x, y + 300, width, 110), font: font(27, .medium), color: Palette.muted, lineHeight: 40)
}

func drawScreenshot(_ image: NSImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat = 58) {
    let rect = topRect(x, y, width, height)
    drawRoundedRect(rect, radius: radius, fill: .white.withAlphaComponent(0.92), stroke: .white.withAlphaComponent(0.45), lineWidth: 2, shadow: true)
    let inner = rect.insetBy(dx: 16, dy: 16)
    let clip = NSBezierPath(roundedRect: inner, xRadius: radius - 16, yRadius: radius - 16)
    NSGraphicsContext.saveGraphicsState()
    clip.addClip()
    image.draw(in: inner)
    NSGraphicsContext.restoreGraphicsState()
}

func drawInfoCard(title: String, body: String, x: CGFloat, y: CGFloat, width: CGFloat, accent: NSColor) {
    let rect = topRect(x, y, width, 146)
    drawRoundedRect(rect, radius: 32, fill: Palette.card.withAlphaComponent(0.92), stroke: .white.withAlphaComponent(0.45), lineWidth: 1, shadow: true)
    drawRoundedRect(NSRect(x: rect.minX + 18, y: rect.maxY - 48, width: 10, height: 10), radius: 5, fill: accent)
    drawText(title, in: NSRect(x: rect.minX + 38, y: rect.maxY - 60, width: rect.width - 48, height: 32), font: font(26, .bold), color: Palette.ink)
    drawText(body, in: NSRect(x: rect.minX + 20, y: rect.minY + 18, width: rect.width - 40, height: 58), font: font(18, .medium), color: Palette.muted, lineHeight: 27)
}

func drawWaveMarks(x: CGFloat, y: CGFloat, color: NSColor) {
    let widths: [CGFloat] = [36, 62, 90]
    for (index, width) in widths.enumerated() {
        let rect = topRect(x + CGFloat(index) * 10, y + CGFloat(index) * 10, width, 80 + CGFloat(index) * 8)
        let path = NSBezierPath()
        path.appendArc(withCenter: NSPoint(x: rect.minX, y: rect.midY), radius: rect.width / 2, startAngle: -62, endAngle: 62, clockwise: false)
        path.lineWidth = 13
        color.withAlphaComponent(0.82 - CGFloat(index) * 0.12).setStroke()
        path.stroke()
    }
}

func render(name: String, theme: Int, body: () -> Void) throws {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasWidth),
        pixelsHigh: Int(canvasHeight),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "GalleryRender", code: 2)
    }

    rep.size = NSSize(width: canvasWidth, height: canvasHeight)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.white.setFill()
    topRect(0, 0, canvasWidth, canvasHeight).fill()
    drawBackground(theme: theme)
    body()
    NSGraphicsContext.restoreGraphicsState()

    let outputURL = outputDirectory.appendingPathComponent(name)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GalleryRender", code: 3)
    }
    try data.write(to: outputURL)
    print("Wrote \(outputURL.path)")
}

let iconImage = try loadImage(at: iconURL, label: "icon")
let libraryImage = try loadImage(at: libraryScreenshotURL, label: "library screenshot")
let ttsImage = try loadImage(at: ttsScreenshotURL, label: "tts screenshot")
let settingsImage = try loadImage(at: settingsScreenshotURL, label: "settings screenshot")

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

try render(name: "gallery-library.png", theme: 1) {
    drawHeader(
        badge: "실제 화면 01",
        title: "가져오기부터 보관까지\n내 서재를 한 번에",
        subtitle: "실제 라이브러리 화면으로 EPUB 가져오기와 TXT·PDF 변환 흐름을 바로 보여줍니다.",
        x: 72,
        y: 84,
        width: 820,
        accent: Palette.primary,
        icon: iconImage
    )
    drawBadge("EPUB 가져오기", x: 72, y: 472, fill: Palette.primary.withAlphaComponent(0.14), textColor: Palette.primary)
    drawBadge("URL 가져오기", x: 272, y: 472, fill: Palette.teal.withAlphaComponent(0.14), textColor: Palette.teal)
    drawBadge("TXT·PDF 변환", x: 472, y: 472, fill: Palette.gold.withAlphaComponent(0.15), textColor: Palette.ink)
    drawScreenshot(libraryImage, x: 392, y: 590, width: 738, height: 1604)
    drawInfoCard(title: "실제 라이브러리", body: "커버 중심 서재 화면과 가져오기 액션을 한 장에서 자연스럽게 보여줍니다.", x: 72, y: 1762, width: 320, accent: Palette.primary)
    drawInfoCard(title: "빠른 추가", body: "EPUB 파일, URL 링크, TXT와 PDF 변환을 하단 액션에서 바로 실행합니다.", x: 72, y: 1940, width: 320, accent: Palette.teal)
}

try render(name: "gallery-tts.png", theme: 2) {
    drawHeader(
        badge: "실제 화면 02",
        title: "본문을 들으며\n읽기 흐름을 유지",
        subtitle: "재생 오버레이와 종료 예약 패널을 그대로 담아 화면을 벗어나지 않는 TTS 흐름을 보여줍니다.",
        x: 72,
        y: 84,
        width: 810,
        accent: Palette.teal,
        icon: iconImage
    )
    drawBadge("재생 컨트롤", x: 72, y: 472, fill: Palette.primary.withAlphaComponent(0.14), textColor: Palette.primary)
    drawBadge("속도 조절", x: 256, y: 472, fill: Palette.teal.withAlphaComponent(0.14), textColor: Palette.teal)
    drawBadge("종료 예약", x: 424, y: 472, fill: Palette.gold.withAlphaComponent(0.15), textColor: Palette.ink)
    drawWaveMarks(x: 86, y: 1888, color: Palette.teal)
    drawScreenshot(ttsImage, x: 348, y: 592, width: 790, height: 1718)
    drawInfoCard(title: "읽는 중 제어", body: "재생, 속도, 종료 예약까지 본문 위에서 바로 조작할 수 있습니다.", x: 72, y: 1748, width: 320, accent: Palette.teal)
}

try render(name: "gallery-settings.png", theme: 3) {
    drawHeader(
        badge: "실제 화면 03",
        title: "독서 환경을\n내 방식대로 조절",
        subtitle: "테마, 글자 크기, 줄 간격과 좌우 여백을 읽는 도중 바로 조정할 수 있습니다.",
        x: 72,
        y: 84,
        width: 820,
        accent: Palette.gold,
        icon: iconImage
    )
    drawBadge("테마", x: 72, y: 472, fill: Palette.gold.withAlphaComponent(0.15), textColor: Palette.ink)
    drawBadge("글자 크기", x: 202, y: 472, fill: Palette.primary.withAlphaComponent(0.14), textColor: Palette.primary)
    drawBadge("줄 간격", x: 372, y: 472, fill: Palette.teal.withAlphaComponent(0.14), textColor: Palette.teal)
    drawBadge("좌우 여백", x: 526, y: 472, fill: Palette.gold.withAlphaComponent(0.12), textColor: Palette.ink)
    drawScreenshot(settingsImage, x: 248, y: 592, width: 826, height: 1796)
    drawInfoCard(title: "즉시 조절", body: "테마, 크기, 간격과 여백을 읽는 도중에도 빠르게 바꿀 수 있습니다.", x: 72, y: 1998, width: 320, accent: Palette.gold)
}
