import Cocoa

let width = 600
let height = 400
let rect = CGRect(x: 0, y: 0, width: width, height: height)

let image = NSImage(size: rect.size)
image.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext

// Emerald green gradient background
let colors = [
    CGColor(red: 0.05, green: 0.37, blue: 0.24, alpha: 1),  // #0D5E3C emerald top
    CGColor(red: 0.00, green: 0.10, blue: 0.05, alpha: 1),  // #001A0D deep green bottom
]
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: CGFloat(height)), options: [])

// Subtle grid/dots pattern for texture
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.03))
for x in stride(from: 30, to: width, by: 30) {
    for y in stride(from: 30, to: height, by: 30) {
        ctx.fillEllipse(in: CGRect(x: CGFloat(x), y: CGFloat(y), width: 2, height: 2))
    }
}

// App icon zone — left side (notch pill shape outline)
let pillWidth: CGFloat = 120
let pillHeight: CGFloat = 60
let pillX: CGFloat = 140
let pillY: CGFloat = 150
let pillRadius: CGFloat = 14

ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.15))
ctx.setLineWidth(2)
ctx.setLineDash(phase: 0, lengths: [6, 4])

let pillPath = CGMutablePath()
pillPath.move(to: CGPoint(x: pillX + 4, y: pillY + pillHeight))
pillPath.addLine(to: CGPoint(x: pillX + pillWidth - 4, y: pillY + pillHeight))
pillPath.addArc(tangent1End: CGPoint(x: pillX + pillWidth, y: pillY + pillHeight),
                tangent2End: CGPoint(x: pillX + pillWidth, y: pillY),
                radius: pillRadius)
pillPath.addLine(to: CGPoint(x: pillX + pillWidth, y: pillY + pillRadius))
pillPath.addArc(tangent1End: CGPoint(x: pillX + pillWidth, y: pillY),
                tangent2End: CGPoint(x: pillX + pillWidth - pillRadius, y: pillY),
                radius: pillRadius)
pillPath.addLine(to: CGPoint(x: pillX + pillRadius, y: pillY))
pillPath.addArc(tangent1End: CGPoint(x: pillX, y: pillY),
                tangent2End: CGPoint(x: pillX, y: pillY + pillRadius),
                radius: pillRadius)
pillPath.addLine(to: CGPoint(x: pillX, y: pillY + pillHeight - pillRadius))
pillPath.addArc(tangent1End: CGPoint(x: pillX, y: pillY + pillHeight),
                tangent2End: CGPoint(x: pillX + 4, y: pillY + pillHeight),
                radius: pillRadius)
pillPath.closeSubpath()
ctx.addPath(pillPath)
ctx.strokePath()

// "Resound" label under left icon
let label1 = "Resound"
let attr1: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 11, weight: .medium),
    .foregroundColor: NSColor(white: 1, alpha: 0.3)
]
let size1 = (label1 as NSString).size(withAttributes: attr1)
(label1 as NSString).draw(at: CGPoint(x: pillX + pillWidth / 2 - size1.width / 2, y: pillY - 28), withAttributes: attr1)

// Applications icon zone — right side (folder outline)
let folderWidth: CGFloat = 90
let folderHeight: CGFloat = 72
let folderX: CGFloat = 370
let folderY: CGFloat = 144

ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.15))
ctx.setLineWidth(2)
ctx.setLineDash(phase: 0, lengths: [6, 4])

let folderPath = CGMutablePath()
folderPath.move(to: CGPoint(x: folderX, y: folderY + folderHeight))
folderPath.addLine(to: CGPoint(x: folderX + folderWidth, y: folderY + folderHeight))
folderPath.addLine(to: CGPoint(x: folderX + folderWidth, y: folderY + folderHeight * 0.35))
folderPath.addLine(to: CGPoint(x: folderX + folderWidth * 0.55, y: folderY + folderHeight * 0.35))
folderPath.addLine(to: CGPoint(x: folderX + folderWidth * 0.45, y: folderY + folderHeight * 0.2))
folderPath.addLine(to: CGPoint(x: folderX + folderWidth * 0.1, y: folderY + folderHeight * 0.2))
folderPath.closeSubpath()
ctx.addPath(folderPath)
ctx.strokePath()

// "Applications" label under right icon
let label2 = "Applications"
let attr2: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 11, weight: .medium),
    .foregroundColor: NSColor(white: 1, alpha: 0.3)
]
let size2 = (label2 as NSString).size(withAttributes: attr2)
(label2 as NSString).draw(at: CGPoint(x: folderX + folderWidth / 2 - size2.width / 2, y: folderY - 28), withAttributes: attr2)

// Arrow connecting them
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.08))
ctx.setLineWidth(1.5)
ctx.setLineDash(phase: 0, lengths: [])

let arrowStart = CGPoint(x: pillX + pillWidth + 20, y: pillY + pillHeight / 2)
let arrowEnd = CGPoint(x: folderX - 20, y: folderY + folderHeight / 2)

ctx.move(to: arrowStart)
ctx.addLine(to: arrowEnd)
ctx.strokePath()

// Arrowhead
let arrowLen: CGFloat = 8
let angle = atan2(arrowEnd.y - arrowStart.y, arrowEnd.x - arrowStart.x)
ctx.move(to: arrowEnd)
ctx.addLine(to: CGPoint(x: arrowEnd.x - arrowLen * cos(angle - 0.4), y: arrowEnd.y - arrowLen * sin(angle - 0.4)))
ctx.move(to: arrowEnd)
ctx.addLine(to: CGPoint(x: arrowEnd.x - arrowLen * cos(angle + 0.4), y: arrowEnd.y - arrowLen * sin(angle + 0.4)))
ctx.strokePath()

// Instruction text at bottom
let instruction = "Drag Resound to your Applications folder"
let instrAttr: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13, weight: .regular),
    .foregroundColor: NSColor(white: 1, alpha: 0.2)
]
let instrSize = (instruction as NSString).size(withAttributes: instrAttr)
(instruction as NSString).draw(at: CGPoint(x: CGFloat(width) / 2 - instrSize.width / 2, y: 40), withAttributes: instrAttr)

// Version text
let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
let verAttr: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 9, weight: .regular),
    .foregroundColor: NSColor(white: 1, alpha: 0.1)
]
("v\(version)" as NSString).draw(at: CGPoint(x: CGFloat(width) - 30, y: 20), withAttributes: verAttr)

image.unlockFocus()

// Save as PNG
guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Failed to generate background")
    exit(1)
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/dmg-background.png"
try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Background saved to \(outputPath)")
