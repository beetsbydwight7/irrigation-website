import AppKit
import Foundation

func cropLogoText() {
    let inputPath = "img/logo.png"
    let outputPath = "img/logo_text.png"
    let cwd = FileManager.default.currentDirectoryPath
    let fileURL = URL(fileURLWithPath: cwd + "/" + inputPath)
    
    guard let image = NSImage(contentsOf: fileURL),
          let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData) else {
        print("Failed to load image")
        exit(1)
    }
    
    let width = bitmap.pixelsWide
    let height = bitmap.pixelsHigh
    
    // 1. Find content bounding box
    var minX = width, maxX = 0, minY = height, maxY = 0
    let whiteThreshold: CGFloat = 0.90 
    
    for y in 0..<height {
        for x in 0..<width {
            if let color = bitmap.colorAt(x: x, y: y) {
                if color.redComponent < whiteThreshold || color.greenComponent < whiteThreshold || color.blueComponent < whiteThreshold {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
    }
    
    if minX > maxX {
        print("No content found")
        exit(1)
    }
    
    let contentWidth = maxX - minX + 1
    let contentHeight = maxY - minY + 1
    
    // 3. Try Horizontal Split (Top/Bottom) - same logic as before to find the split line
    var splitY = -1
    var maxHGap = 0
    
    var rowHasInk = [Bool](repeating: false, count: contentHeight)
    for y in 0..<contentHeight {
        for x in minX...maxX {
             if let color = bitmap.colorAt(x: x, y: minY + y) {
                if color.redComponent < whiteThreshold || color.greenComponent < whiteThreshold || color.blueComponent < whiteThreshold {
                    rowHasInk[y] = true
                    break
                }
             }
        }
    }
    
    // Find gaps in rows
    var currentGap = 0
    for y in 0..<contentHeight {
        if !rowHasInk[y] {
            currentGap += 1
        } else {
            if currentGap > maxHGap && y > contentHeight/5 && y < contentHeight*4/5 {
                maxHGap = currentGap
                // splitY is the end of the gap (start of bottom section) or middle?
                // logic before: splitY = minY + (y - currentGap/2)
                splitY = minY + (y - currentGap/2)
            }
            currentGap = 0
        }
    }
    
    var cropRect: NSRect
    
    if maxHGap > 10 {
        print("Found horizontal gap (Top/Bottom split). HGap: \(maxHGap) at Y: \(splitY). Cropping Bottom.")
        // Bottom part: Start at splitY (or slightly below gap center), height = maxY - splitY
        // Actually splitY calculated above is roughly the center of the gap.
        // We want to verify where the next ink starts?
        // Let's just trust splitY is a safe dividing line.
        let bottomStart = splitY
        let bottomHeight = maxY - bottomStart + 1
        cropRect = NSRect(x: minX, y: bottomStart, width: contentWidth, height: bottomHeight)
    } else {
        print("No horizontal split found. Cannot isolate text.")
        exit(1)
    }
    
    print("Cropping text to: \(cropRect)")

    guard let resultBitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                              pixelsWide: Int(cropRect.width),
                                              pixelsHigh: Int(cropRect.height),
                                              bitsPerSample: 8,
                                              samplesPerPixel: 4,
                                              hasAlpha: true,
                                              isPlanar: false,
                                              colorSpaceName: .deviceRGB,
                                              bytesPerRow: Int(cropRect.width) * 4,
                                              bitsPerPixel: 32) else {
        exit(1)
    }
    
    for y in 0..<Int(cropRect.height) {
        for x in 0..<Int(cropRect.width) {
            let srcX = Int(cropRect.origin.x) + x
            let srcY = Int(cropRect.origin.y) + y
             if let color = bitmap.colorAt(x: srcX, y: srcY) {
                 resultBitmap.setColor(color, atX: x, y: y)
             }
        }
    }
    
    guard let pngData = resultBitmap.representation(using: .png, properties: [:]) else {
        exit(1)
    }
    
    try? pngData.write(to: URL(fileURLWithPath: cwd + "/" + outputPath))
    print("Saved text crop to \(outputPath)")
}

cropLogoText()
