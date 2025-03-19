import Foundation
import SwiftOpenAI

class AssistantChatProvider {
        
    @Published var threadId: String?
    @Published var message: Message?
    
    private let service: OpenAIService!
    // MARK: - Initializer
    
    init() {
        self.service = OpenAIServiceFactory.service(apiKey: Shared.shared.apiKey)
    }
    
    func createThread() {
        Task {
            do {
                let thread = try await service.createThread(parameters: .init())
                DispatchQueue.main.async {
                    self.threadId = thread.id
                }
            } catch {
                print("Error creating thread: \(error)")
            }
        }
    }
    
    func createMessage(threadID: String, content: String) async throws {
        do {
            let parameters = SwiftOpenAI.MessageParameter(role: .user, content: content)
            _ = try await service.createMessage(threadID: threadID, parameters: parameters)
        } catch {
            print("Error creating message: \(error)")
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
                role: "assistant",
                content: outputText,
                createdAt: Date()
            )
            
            DispatchQueue.main.async {
                self.message = newMessage
            }
            
        }  catch {
            print("THREAD ERROR: \(error.localizedDescription)")
            throw error
        }
    }
}

