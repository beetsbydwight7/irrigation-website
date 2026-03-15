import AppKit
import Foundation

func cropLogo() {
    let inputPath = "img/logo.png"
    let outputPath = "img/logo_icon.png"
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
    print("Content bounds: \(minX),\(minY) \(contentWidth)x\(contentHeight)")
    
    // 2. Try Vertical Split (Left/Right)
    var splitX = -1
    var maxVGap = 0
    
    var colHasInk = [Bool](repeating: false, count: contentWidth)
    for x in 0..<contentWidth {
        for y in minY...maxY {
             if let color = bitmap.colorAt(x: minX + x, y: y) {
                if color.redComponent < whiteThreshold || color.greenComponent < whiteThreshold || color.blueComponent < whiteThreshold {
                    colHasInk[x] = true
                    break
                }
             }
        }
    }
    
    // Find gaps in columns
    var currentGap = 0
    for x in 0..<contentWidth {
        if !colHasInk[x] {
            currentGap += 1
        } else {
            if currentGap > maxVGap && x > contentWidth/5 && x < contentWidth*4/5 {
                maxVGap = currentGap
                splitX = minX + (x - currentGap/2)
            }
            currentGap = 0
        }
    }

    // 3. Try Horizontal Split (Top/Bottom)
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
    currentGap = 0
    for y in 0..<contentHeight {
        if !rowHasInk[y] {
            currentGap += 1
        } else {
            if currentGap > maxHGap && y > contentHeight/5 && y < contentHeight*4/5 {
                maxHGap = currentGap
                splitY = minY + (y - currentGap/2)
            }
            currentGap = 0
        }
    }
    
    var cropRect: NSRect
    
    if maxVGap > 10 {
        print("Found vertical gap (Left/Right split). Cropping Left.")
        cropRect = NSRect(x: minX, y: minY, width: splitX - minX, height: contentHeight)
    } else if maxHGap > 10 {
        print("Found horizontal gap (Top/Bottom split). Cropping Top.")
        // Note: Y in AppKit can be weird, but for bitmap iteration we treat 0 as top typically in these loops
        // Let's assume Top is 0. 
        cropRect = NSRect(x: minX, y: minY, width: contentWidth, height: splitY - minY)
    } else {
        print("No split found. Using content bounds.")
        cropRect = NSRect(x: minX, y: minY, width: contentWidth, height: contentHeight)
    }
    
    print("Cropping to: \(cropRect)")

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
    print("Saved crop to \(outputPath)")
}

cropLogo()
