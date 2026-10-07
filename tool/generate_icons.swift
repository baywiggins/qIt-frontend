// Reproducible qIt app icons. Run `swift tool/generate_icons.swift` on macOS.
import AppKit
import Foundation
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
func icon(_ size: Int) -> Data {
 let bitmap = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:size,pixelsHigh:size,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
 NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:bitmap)!
 NSColor(red:10/255,green:16/255,blue:32/255,alpha:1).setFill();NSRect(x:0,y:0,width:size,height:size).fill()
 let s=CGFloat(size)
 NSColor(red:103/255,green:151/255,blue:255/255,alpha:1).setFill()
 NSBezierPath(roundedRect:NSRect(x:s*0.12,y:s*0.12,width:s*0.76,height:s*0.76),xRadius:s*0.18,yRadius:s*0.18).fill()
 let attrs:[NSAttributedString.Key:Any]=[.font:NSFont.systemFont(ofSize:s*0.48,weight:.bold),.foregroundColor:NSColor(red:10/255,green:16/255,blue:32/255,alpha:1)]
 let text="qIt" as NSString;let extent=text.size(withAttributes:attrs)
 text.draw(at:NSPoint(x:(s-extent.width)/2,y:(s-extent.height)/2+s*0.02),withAttributes:attrs)
 NSGraphicsContext.restoreGraphicsState();return bitmap.representation(using:.png,properties:[:])!
}
for (path,size) in [("web/favicon.png",32),("web/icons/Icon-192.png",192),("web/icons/Icon-512.png",512),("web/icons/Icon-maskable-192.png",192),("web/icons/Icon-maskable-512.png",512),("android/app/src/main/res/mipmap-mdpi/ic_launcher.png",48),("android/app/src/main/res/mipmap-hdpi/ic_launcher.png",72),("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png",96),("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png",144),("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png",192)] {try icon(size).write(to:root.appendingPathComponent(path))}
let ios=root.appendingPathComponent("ios/Runner/Assets.xcassets/AppIcon.appiconset")
let content=try JSONSerialization.jsonObject(with:Data(contentsOf:ios.appendingPathComponent("Contents.json"))) as! [String:Any]
for image in content["images"] as! [[String:String]] {if let name=image["filename"],let size=image["size"],let scale=image["scale"] {let points=Double(size.components(separatedBy:"x")[0])!;let factor=Double(scale.replacingOccurrences(of:"x",with:""))!;try icon(Int(points*factor)).write(to:ios.appendingPathComponent(name))}}
