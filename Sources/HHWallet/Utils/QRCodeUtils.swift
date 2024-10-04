// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import SwiftUI
#if !SKIP
import UIKit
#else
import java.util.Base64
import qrcode.render.QRCodeGraphics
import qrcode.QRCode
import qrcode.color.Colors
import android.graphics.BitmapFactory
import java.io.FileOutputStream
#endif

enum QRCodeUtils {

    // TODO: Change QR code gen lib for Android.
    // Now use https://github.com/g0dkar/qrcode-kotlin

    static func generate(for string: String, size: CGSize = .init(width: 350, height: 350)) -> URL? {
        let path = "\(string.sha256())_\(Int(size.width))x\(Int(size.height)).png"
        let url: URL = URL.temporaryDirectory.appendingPathComponent(path)
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            return url
        }
        let bytes = generateBytes(for: string, size: size)
        guard let bytes = bytes else { return nil }
#if SKIP
        let data = Data(bytes)
#else
        let data = bytes
#endif
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

#if !SKIP
    static func generateBytes(for string: String, size: CGSize = .init(width: 350, height: 350)) -> Data? {

        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            // Set the error correction level (L: 7%, M: 15%, Q: 25%, H: 30%)
            filter.setValue("H", forKey: "inputCorrectionLevel")

            if let qrImage = filter.outputImage {
                let scaleX = size.width / qrImage.extent.size.width
                let scaleY = size.height / qrImage.extent.size.height
                let ciimage = qrImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

                let uiimage = UIImage(ciImage: ciimage)
                if let bytes = uiimage.pngData() {
                    return bytes
                }
            }
        }
        return nil
    }
#else
    static func generateBytes(for string: String, size: CGSize = .init(width: 350, height: 350)) -> ByteArray? {
        return QRCode
            .ofSquares()
            .withColor(Colors.BLACK)
            .build(string)
            .render()
            .getBytes()
    }
#endif
}

#if !SKIP
extension Data {

    func base64UrlEncoded() -> URL? {
        let string = self.base64EncodedString()
        return URL(string: "data:image/png;base64,\(string)")
    }

}
#else
extension ByteArray {

    func base64UrlEncoded() -> URL? {
        let string = Base64.getEncoder().encodeToString(self)
        return URL(string: "data:image/png;base64,\(string)")
    }

}
#endif

