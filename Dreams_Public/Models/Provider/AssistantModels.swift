import Foundation

struct Message: Identifiable, Codable, Comparable {
  var id: UUID
  var threadId: String
  var role: String
  var content: String
  var createdAt: Date

  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.createdAt < rhs.createdAt
  }
}

struct MessageParameter: Encodable {
  enum Role: String, Encodable {
    case user = "user"
    case assistant = "assistant"
  }

  let role: Role
  let content: String
}

struct MessageCreationResponse: Identifiable, Codable {
  var id: String
  var object: String
  var createdAt: Int
  var threadId: String
  var role: String
  var content: [Content]
}

struct TextContent: Codable {
  var value: String
  var annotations: [String]?
}

public enum Content: Codable {
  case text(Text)
  case imageFile(ImageFile)

  public struct Text: Codable {
    public let value: String
  }

  public struct ImageFile: Codable {
  }
}

struct Tool {
  var type: String
}

struct MessageResponse: Codable {
  let id: String
  let threadId: String
  let role: String
  let content: [MessageContent]
  let createdAt: Double

  enum CodingKeys: String, CodingKey {
    case id
    case threadId = "thread_id"
    case role
    case content
    case createdAt = "created_at"
  }
}

struct MessageContent: Codable {
  let type: String
  let text: String?
  let role: String
}

struct RunResponse: Codable {
  var id: String?
  var status: String?
}

struct ThreadResponse: Codable {
  let id: String?
  let object: String
  let createdAt: Int
  let metadata: [String: String]

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case metadata
  }

}

enum Assistant: String {
    case promptDalle = ""
    case dreamReview = ""
    case chat = ""
}
