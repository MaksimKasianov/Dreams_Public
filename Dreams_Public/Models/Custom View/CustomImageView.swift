import UIKit
import FirebaseStorage

// Image Caching
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var isLoading: Bool {
        get { return activityIndicator.isAnimating }
        set {
            if newValue {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        self.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        return indicator
    }()
    
    var lastImgUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String, finding isFinding: Bool = false) {
        self.image = nil
        
        let url = "Dreams/\(urlString.lowercased()).png"
        
        lastImgUrlUsedToLoadImage = url
        
        if let cachedIamge = imageCache[url] {
            print("Loading Image Cache")
            self.image = cachedIamge
            self.isLoading = false
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child(url)
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                self.image = UIImage(named: "default-cover")
                self.isLoading = false
                
                if isFinding {
                    AmplitudeManager.shared.eventTrack(type: "No picture", properties: ["dream" : urlString])
                }
                
                print("Failed to load image with error", error.localizedDescription)
            }
            
            if self.lastImgUrlUsedToLoadImage != url {
                return
            }
            
            guard let imageData = data else { return }
            
            let photoImage = UIImage(data: imageData)
            
            // Save a cache
            imageCache[url] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
                self.isLoading = false
            }
        }.resume()
    }
}
