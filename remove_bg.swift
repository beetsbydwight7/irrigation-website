import AppKit

func removeBackground() {
    let inputPath = "img/logo.png"
    let outputPath = "img/logo_transparent.png"
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
    
    guard let newBitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                           pixelsWide: width,
                                           pixelsHigh: height,
                                           bitsPerSample: 8,
                                           samplesPerPixel: 4,
                                           hasAlpha: true,
                                           isPlanar: false,
                                           colorSpaceName: .deviceRGB,
                                           bytesPerRow: width * 4,
                                           bitsPerPixel: 32) else {
        print("Failed to create new bitmap")
        exit(1)
    }
    
    let whiteThreshold: CGFloat = 0.90
    
    for y in 0..<height {
        for x in 0..<width {
            if let color = bitmap.colorAt(x: x, y: y) {
                // If pixel is white (or very close), make it transparent
                if color.redComponent > whiteThreshold && color.greenComponent > whiteThreshold && color.blueComponent > whiteThreshold {
                    newBitmap.setColor(NSColor.clear, atX: x, y: y)
                } else {
                    newBitmap.setColor(color, atX: x, y: y)
                }
            }
        }
    }
    
    guard let pngData = newBitmap.representation(using: .png, properties: [:]) else {
        print("Failed to convert to PNG")
        exit(1)
    }
    
    try? pngData.write(to: URL(fileURLWithPath: cwd + "/" + outputPath))
    print("Saved transparent logo to \(outputPath)")
}

removeBackground()
