import Carbon
import Foundation

// Retrieve all available input sources (installed + built-in)
let sources = TISCreateInputSourceList(nil, true).takeRetainedValue() as! [TISInputSource]

var found = 0
for src in sources {
    guard let namePtr = TISGetInputSourceProperty(src, kTISPropertyLocalizedName) else { continue }
    let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String

    guard name.lowercased().contains("german") else { continue }

    guard let dataPtr = TISGetInputSourceProperty(src, kTISPropertyUnicodeKeyLayoutData) else {
        print("[\(name)] no UCKeyboardLayout data")
        continue
    }
    let data = Unmanaged<CFData>.fromOpaque(dataPtr).takeUnretainedValue() as Data

    let safeName = name.replacingOccurrences(of: "/", with: "-")
                       .replacingOccurrences(of: " ", with: "_")
    let outPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("\(safeName).ucdata")

    do {
        try data.write(to: outPath)
        print("Saved \(name)  →  \(outPath.path)  (\(data.count) bytes)")
        found += 1
    } catch {
        print("Error writing \(name): \(error)")
    }
}

if found == 0 {
    print("No German layouts found.")
}
