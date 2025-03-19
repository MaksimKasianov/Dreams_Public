//
//  AWSLambda.swift
//  DreamApp
//
//  Created by Kasianov on 26.12.2023.
//

import Foundation

class AWSLambda {
    func sendAWSLambda(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let textEncoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: Cannot encode text")
            return
        }
    
        let urlString = "\(textEncoded.replacingOccurrences(of: " ", with: "-"))"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(.failure(MyError.genericError("Invalid URL")))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(MyError.genericError(error?.localizedDescription ?? "Unknown error")))
                return
            }
            // Обробляйте результат тут
            let output = (String(data: data, encoding: .utf8) ?? "Sorry. Error server")
            print(output)
            let textCorrect = output.trimmingCharacters(in: .whitespacesAndNewlines)
            
            completion(.success(textCorrect))
        }
        task.resume()
    }
    
    enum MyError: Error {
        case genericError(String)
        
        var localizedDescription: String {
            switch self {
            case .genericError(let message):
                return message
            }
        }
    }
}
