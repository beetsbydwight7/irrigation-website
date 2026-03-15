import AppKit

let inputPath = "img/logo.png" 
let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/" + inputPath)

if let image = NSImage(contentsOf: fileURL),
   let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData) {
    if let color = bitmap.colorAt(x: 0, y: 0) {
        print("Pixel at 0,0: R=\(color.redComponent) G=\(color.greenComponent) B=\(color.blueComponent) A=\(color.alphaComponent)")
    } else {
        print("Could not read pixel")
    }
} else {
    print("Failed to load image")
}
