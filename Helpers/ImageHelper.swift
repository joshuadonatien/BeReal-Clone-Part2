//
//  ImageHelper.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/17/26.
//

//
//  ImageHelper.swift
//  BeReal-Clone
//
//  Helper class for image processing operations
//

import UIKit

class ImageHelper {
    
    // Singleton instance
    static let shared = ImageHelper()
    
    private init() {}
    
    // MARK: - Image Compression
    
    /// Compress image to reduce file size
    /// - Parameters:
    ///   - image: Original UIImage
    ///   - quality: Compression quality (0.0 to 1.0)
    /// - Returns: Compressed image data or nil
    func compressImage(_ image: UIImage, quality: CGFloat = Constants.ImageSettings.compressionQuality) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    /// Resize image to maximum dimensions
    /// - Parameters:
    ///   - image: Original UIImage
    ///   - maxSize: Maximum width/height
    /// - Returns: Resized UIImage
    func resizeImage(_ image: UIImage, maxSize: CGFloat = Constants.ImageSettings.maxImageSize) -> UIImage {
        
        // Check if resizing is needed
        let size = image.size
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / ratio)
        } else {
            newSize = CGSize(width: maxSize * ratio, height: maxSize)
        }
        
        // Render resized image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Compress and resize image for upload
    /// - Parameter image: Original UIImage
    /// - Returns: Processed image data
    func prepareImageForUpload(_ image: UIImage) -> Data? {
        let resized = resizeImage(image)
        return compressImage(resized)
    }
    
    // MARK: - Image Validation
    
    /// Check if image data size is within acceptable limits
    /// - Parameter data: Image data
    /// - Returns: true if size is acceptable
    func isImageSizeAcceptable(_ data: Data) -> Bool {
        let sizeInMB = Double(data.count) / (1024.0 * 1024.0)
        return sizeInMB < 10.0 // 10MB limit
    }
    
    /// Get human-readable file size
    /// - Parameter data: Image data
    /// - Returns: Formatted string (e.g., "2.5 MB")
    func getImageSizeString(_ data: Data) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(data.count))
    }
    
    // MARK: - Image Cropping
    
    /// Crop image to square aspect ratio
    /// - Parameter image: Original UIImage
    /// - Returns: Square cropped UIImage
    func cropToSquare(_ image: UIImage) -> UIImage {
        let size = image.size
        let side = min(size.width, size.height)
        
        let x = (size.width - side) / 2
        let y = (size.height - side) / 2
        
        let cropRect = CGRect(x: x, y: y, width: side, height: side)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - Placeholder Images
    
    /// Generate a placeholder image with a color
    /// - Parameters:
    ///   - color: Background color
    ///   - size: Image size
    /// - Returns: Placeholder UIImage
    func createPlaceholder(color: UIColor = .systemGray5, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    /// Get a user profile placeholder
    /// - Returns: Default profile image
    func getProfilePlaceholder() -> UIImage {
        return UIImage(systemName: "person.circle.fill") ?? createPlaceholder(color: .systemGray4)
    }
}

// MARK: - UIImage Extension

extension UIImage {
    
    /// Convenience method to resize image
    func resized(to maxSize: CGFloat) -> UIImage {
        return ImageHelper.shared.resizeImage(self, maxSize: maxSize)
    }
    
    /// Convenience method to compress image
    func compressed(quality: CGFloat = 0.7) -> Data? {
        return ImageHelper.shared.compressImage(self, quality: quality)
    }
    
    /// Convenience method to prepare for upload
    func preparedForUpload() -> Data? {
        return ImageHelper.shared.prepareImageForUpload(self)
    }
    
    /// Convenience method to crop to square
    func croppedToSquare() -> UIImage {
        return ImageHelper.shared.cropToSquare(self)
    }
}
