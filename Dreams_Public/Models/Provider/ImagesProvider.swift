import Foundation
import UIKit
import SwiftOpenAI

class ImagesProvider {
    
    var service: OpenAIService!
    
    @Published var images: [UIImage]?
    
    init() {
        self.service = OpenAIServiceFactory.service(apiKey: Shared.shared.apiKey)
    }
    
    func createImages(prompt: String) async throws {
        let parameters: ImageCreateParameters = .init(prompt: prompt, model: .dalle3(.landscape))
        
        do {
            let urls = try await service.createImages(parameters: parameters).data.map(\.url)
            let validURLs = urls.compactMap { $0 }
            let images = try await fetchImages(with: validURLs)
            self.images = images
        } catch {
            print("Error creating images: \(error)")
            throw error
        }
    }

    func fetchImages(with urls: [URL]) async throws -> [UIImage] {
        var images: [UIImage] = []
        
        for url in urls {
            do {
                let imageData = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: imageData.0) {
                    images.append(image)
                }
            } catch {
                print("Error loading image from \(url): \(error)")
            }
        }
        
        return images
    }
}
