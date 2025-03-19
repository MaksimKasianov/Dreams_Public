//
//  AssistantViewModel.swift
//  testAssistent
//
//  Created by Kasianov on 21.03.2024.
//

import UIKit
import SwiftOpenAI
import CoreData

class AssistantChatStreamProvider {
    @Published var messages: [Message] = []
    @Published var sortedMessages: [Message] = []
    @Published var threadId: String?
    
    let apiKey: String = ""
    var service: OpenAIService!
    
    init() {
        self.service = OpenAIServiceFactory.service(apiKey: Shared.shared.apiKey)
        //MARK: Core Data
        self.messages = loadMessages()
    }
    
    func createThread() {
        Task {
            do {
                let thread = try await service.createThread(parameters: CreateThreadParameters())
                DispatchQueue.main.async {
                    self.threadId = thread.id
                }
            } catch {
                print("Error creating thread: \(error)")
            }
        }
    }
    
    func createMessage(threadId: String, content: String) async throws {
        let parameters = SwiftOpenAI.MessageParameter(role: .user, content: content)
                
        do {
            let messageResponse = try await service.createMessage(
                threadID: threadId, parameters: parameters)
            
            let id = UUID()
            let date = Date(timeIntervalSince1970: TimeInterval(messageResponse.createdAt))
            
            let newMessage = Message(
                id: id,
                threadId: threadId,
                role: MessageParameter.Role.user.rawValue,
                content: content,
                createdAt: date
            )
            
            DispatchQueue.main.async {
                //MARK: Core Data
                addMessageEntity(id: id, threadId: threadId, role: MessageParameter.Role.user.rawValue, content: content, createdAt: date)
                
                self.messages.append(newMessage)
                self.updateSortedMessages()
            }
        } catch {
            print("Error creating message: \(error)")
        }
    }
    
    func updateSortedMessages() {
        let sorted = messages.sorted { $0.createdAt > $1.createdAt }
        DispatchQueue.main.async {
            self.sortedMessages = sorted
        }
    }
    
    func createRunAndStreamMessage(threadId: String, parameters: RunParameter) async throws {
        do {
            let stream = try await service.createRunStream(threadID: threadId, parameters: parameters)
            
            var outputText = ""
            
            for try await result in stream {
                switch result {
                case .threadMessageDelta(let messageDelta):
                    let content = messageDelta.delta.content.first
                    switch content {
                    case .imageFile, nil:
                        break
                    case .text(let textContent):
                        outputText += textContent.text.value
                    }
                case .threadRunStepDelta(_):
                    break
                default: break
                }
            }
            
            let newMessage = Message(
                id: UUID(),
                threadId: threadId,
                role: MessageParameter.Role.assistant.rawValue,
                content: outputText,
                createdAt: Date()
            )
            
            DispatchQueue.main.async {
                //MARK: Core Data
                addMessageEntity(id: newMessage.id, threadId: newMessage.threadId, role: newMessage.role, content: newMessage.content, createdAt: newMessage.createdAt)
                
                self.messages.append(newMessage)
            }
            
        }  catch {
            print("THREAD ERROR: \(error.localizedDescription)")
            throw error
        }
    }
}
