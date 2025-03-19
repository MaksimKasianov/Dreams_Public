//
//  Protocols.swift
//  WeDream
//
//  Created by Kasianov on 16.10.2023.
//

import Foundation

protocol NewDreamDelegate: AnyObject {
    func update()
    func delete(dream: DreamData)
}

protocol EditDreamDelegate: AnyObject {
    func editNotes(notes: String)
    func editDream(dream: String)
}

protocol NewMoodDelegate: AnyObject {
    func newMood()
    func delete(mood: MoodData)
}
