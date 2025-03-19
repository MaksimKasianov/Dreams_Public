import UIKit
import FirebaseStorage

class FirebaseImageLoader {
    static let shared = FirebaseImageLoader()
    
    func listFilesInStorage(path: String, complection: @escaping ([String]) -> Void) {
        var listAll = [String]()
        
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: path)
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Помилка отримання списку файлів: \(error.localizedDescription)")
                complection(listAll)
                return
            }
            
            for item in result!.items {
                let name = item.name.replacingOccurrences(of: ".png", with: "")
                
                listAll.append(name)
            }
            complection(listAll)
        }
    }
    
    private var activeDownloads = [String: StorageDownloadTask]()

    func loadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        let imageURL = "Dreams/\(imageName.lowercased()).png"
        
        let fileURL = FileManager.default.getImagesDirectory().appendingPathComponent(imageURL)
        print(fileURL)
        
        if let cachedImage = UIImage(contentsOfFile: fileURL.path) {
            completion(cachedImage)
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference().child(imageURL)
            
            let downloadTask = storageRef.write(toFile: fileURL) { [weak self] url, error in
                guard let self = self else { return }
                                
                defer {
                    self.activeDownloads[imageURL] = nil
                }
                
                if let error = error {
                    print("Помилка завантаження фотографії: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url, let image = UIImage(contentsOfFile: url.path) {
                    completion(image)
                }
            }
            
            activeDownloads[imageURL] = downloadTask
        }
    }
}

func listFilesInStorage(path: String, complection: @escaping ([String]) -> Void) {
    var listAll = [String]()
    
    let storage = Storage.storage()
    let storageRef = storage.reference(withPath: path)
    
    storageRef.listAll { (result, error) in
        if let error = error {
            print("Помилка отримання списку файлів: \(error.localizedDescription)")
            return
        }
        
        for item in result!.items {
            let name = item.name//.replacingOccurrences(of: ".png", with: "")
            
            listAll.append(name)
        }
        
        complection(listAll)
    }
}
