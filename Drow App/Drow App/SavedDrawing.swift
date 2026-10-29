import SwiftData
import UIKit

/// A finished drawing, kept on the device so it is still there after the app is closed.
@Model
final class SavedDrawing {
    /// Stable id so the card selection survives view re-creation.
    var id: String
    var title: String
    var createdAt: Date
    /// The drawing as a picture. Stored as a separate file by SwiftData because it is large.
    @Attribute(.externalStorage) var imageData: Data
    /// The signature as a picture. Empty when the user did not sign.
    @Attribute(.externalStorage) var signatureData: Data
    /// Answer to "What do you think your drawing expresses?" (empty if not answered)
    var expresses: String
    /// Answer to "Did you discover something while drawing?" (empty if not answered)
    var discovery: String
    /// The strokes of each drawing page, so the drawing can be opened and edited again.
    var pagesData: [Data] = []
    /// The strokes of the signature, so it can be edited again.
    var signatureStrokes: Data = Data()

    init(title: String, image: UIImage, signature: UIImage, signatureStrokes: Data,
         pagesData: [Data], expresses: String, discovery: String) {
        self.id = UUID().uuidString
        self.createdAt = .now
        self.title = title
        self.imageData = image.pngData() ?? Data()
        self.signatureData = signature.pngData() ?? Data()
        self.signatureStrokes = signatureStrokes
        self.pagesData = pagesData
        self.expresses = expresses
        self.discovery = discovery
    }

    /// Changes only the name and signature (used from the Home page), keeping everything else.
    func updateNameAndSignature(title: String, signature: UIImage, signatureStrokes: Data) {
        self.title = title
        self.signatureData = signature.pngData() ?? Data()
        self.signatureStrokes = signatureStrokes
    }

    /// Replaces everything the user can change when editing. The id and date stay the same.
    func update(title: String, image: UIImage, signature: UIImage, signatureStrokes: Data,
                pagesData: [Data], expresses: String, discovery: String) {
        self.title = title
        self.imageData = image.pngData() ?? Data()
        self.signatureData = signature.pngData() ?? Data()
        self.signatureStrokes = signatureStrokes
        self.pagesData = pagesData
        self.expresses = expresses
        self.discovery = discovery
    }

    var image: UIImage {
        UIImage(data: imageData) ?? UIImage()
    }

    var signature: UIImage? {
        signatureData.isEmpty ? nil : UIImage(data: signatureData)
    }
}
