//
//  DecoderJSON.swift
//  WeDream
//
//  Created by Kasianov on 24.07.2023.
//

import Foundation
import UIKit

struct Dream: Codable {
    let title: String
    let summary: String
    let detailed: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case summary = "Summary"
        case detailed = "Detailed"
    }
}

class DreamSearch {
    static let shared = DreamSearch()
    
    var dreamsInterpretation = [Dream]()
    var dreamsIcons = [Dream]()
    
    func decodePlist() {
        if let path = Bundle.main.path(forResource: "DreamData", ofType: "plist"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {

            do {
                let dreams = try PropertyListDecoder().decode([Dream].self, from: data)
                var sortedDreams = dreams
                sortedDreams.sort(by: { $0.title < $1.title })
                
                dreamsInterpretation = sortedDreams
                dreamsIcons = sortedDreams
            } catch {
                print("Помилка декодування: \(error.localizedDescription)")
            }
        } else {
            print("Plist-файл не знайдено.")
        }
    }
    
    func decodeSorted(sortOrder: [String]) {
        var sortedDreams = [Dream]()
        
        for title in sortOrder {
            if let dream = dreamsInterpretation.first(where: { $0.title.lowercased() == title }) {
                sortedDreams.append(dream)
            }
        }
        
        dreamsIcons = sortedDreams
    }
    
    func decodeJSON() {
        guard let path = Bundle.main.path(forResource: "DataBase", ofType: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let dreams = try decoder.decode([Dream].self, from: data)
            dreamsInterpretation = dreams
        } catch {
            print("Error decoding JSON data: \(error)")
        }
    }
    
    func search(text: String) -> [Dream]? {
        let dreams = DreamSearch.shared.dreamsInterpretation
        print(dreams.count)
        let dataArray = text.components(separatedBy: [",", " ", "!",".","?","\n"])
        let lowercaseArray = dataArray.map { $0.lowercased() }
        
        let originals = Array(Set(lowercaseArray))
        
        var coincidence = [Dream]()
        
        for word in originals {
            for dream in dreams {
                let word1 = word.lowercased()
                let word2 = dream.title.lowercased()
                
                if word1 == word2 {
                    coincidence.append(dream)
                }
            }
        }
        
        if !coincidence.isEmpty {
            coincidence.sort(by: { $0.title < $1.title })
        }
        
        return coincidence
    }
 
    func encodePlist(title: String, detailed: String) {
        do {
                var existingDreams = try loadPlist()

                // Додаємо новий елемент до масиву
                let newDream = Dream(title: title, summary: "", detailed: detailed)
                existingDreams.append(newDream)

                // Кодуємо та записуємо оновлений масив
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml

                let data = try encoder.encode(existingDreams)

                let archiveURL = try getDocumentsDirectory().appendingPathComponent("DreamData.plist")
                try data.write(to: archiveURL, options: .noFileProtection)
                UIPasteboard.general.string = detailed
                print("Запис даних в .plist файл")
            } catch {
                print("Помилка додавання до .plist файлу: \(error.localizedDescription)")
            }
        }

        func loadPlist() throws -> [Dream] {
            do {
                let archiveURL = try getDocumentsDirectory().appendingPathComponent("DreamData.plist")
                print(archiveURL)
                if FileManager.default.fileExists(atPath: archiveURL.path) {
                    let data = try Data(contentsOf: archiveURL)
                    // Декодуємо з Plist-даних до масиву структур Dream
                    let dreams = try PropertyListDecoder().decode([Dream].self, from: data)
                    return dreams
                } else {
                    // Якщо файл не існує, повертаємо порожній масив
                    return []
                }
            } catch {
                throw error
            }
        }

        func getDocumentsDirectory() throws -> URL {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }
}
