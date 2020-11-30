// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: message.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Message_MessageObjectResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: String = String()

  var groupID: String = String()

  var groupType: String = String()

  var fromClientID: String = String()

  var clientID: String = String()

  var message: Data = SwiftProtobuf.Internal.emptyData

  var createdAt: Int64 = 0

  var updatedAt: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Message_BaseResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var success: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Request: get list message group
struct Message_GetMessagesInGroupRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var groupID: String = String()

  ///0
  var offSet: Int32 = 0

  ///8746529349
  var lastMessageAt: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Response: GetMessagesInGroupResponse
struct Message_GetMessagesInGroupResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var lstMessage: [Message_MessageObjectResponse] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// ----- PUBLISH AND SUBCRIBE MESSAGE -----
/// Request: publish a message
struct Message_PublishRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var fromClientID: String = String()

  var clientID: String = String()

  var groupID: String = String()

  var groupType: String = String()

  var message: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Request: subcribe or listen
struct Message_SubscribeAndListenRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "message"

extension Message_MessageObjectResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MessageObjectResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "group_id"),
    3: .standard(proto: "group_type"),
    4: .standard(proto: "from_client_id"),
    5: .standard(proto: "client_id"),
    6: .same(proto: "message"),
    7: .standard(proto: "created_at"),
    8: .standard(proto: "updated_at"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.id)
      case 2: try decoder.decodeSingularStringField(value: &self.groupID)
      case 3: try decoder.decodeSingularStringField(value: &self.groupType)
      case 4: try decoder.decodeSingularStringField(value: &self.fromClientID)
      case 5: try decoder.decodeSingularStringField(value: &self.clientID)
      case 6: try decoder.decodeSingularBytesField(value: &self.message)
      case 7: try decoder.decodeSingularInt64Field(value: &self.createdAt)
      case 8: try decoder.decodeSingularInt64Field(value: &self.updatedAt)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    if !self.groupID.isEmpty {
      try visitor.visitSingularStringField(value: self.groupID, fieldNumber: 2)
    }
    if !self.groupType.isEmpty {
      try visitor.visitSingularStringField(value: self.groupType, fieldNumber: 3)
    }
    if !self.fromClientID.isEmpty {
      try visitor.visitSingularStringField(value: self.fromClientID, fieldNumber: 4)
    }
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 5)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularBytesField(value: self.message, fieldNumber: 6)
    }
    if self.createdAt != 0 {
      try visitor.visitSingularInt64Field(value: self.createdAt, fieldNumber: 7)
    }
    if self.updatedAt != 0 {
      try visitor.visitSingularInt64Field(value: self.updatedAt, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_MessageObjectResponse, rhs: Message_MessageObjectResponse) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.groupID != rhs.groupID {return false}
    if lhs.groupType != rhs.groupType {return false}
    if lhs.fromClientID != rhs.fromClientID {return false}
    if lhs.clientID != rhs.clientID {return false}
    if lhs.message != rhs.message {return false}
    if lhs.createdAt != rhs.createdAt {return false}
    if lhs.updatedAt != rhs.updatedAt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message_BaseResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".BaseResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "success"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBoolField(value: &self.success)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.success != false {
      try visitor.visitSingularBoolField(value: self.success, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_BaseResponse, rhs: Message_BaseResponse) -> Bool {
    if lhs.success != rhs.success {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message_GetMessagesInGroupRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetMessagesInGroupRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    2: .standard(proto: "off_set"),
    3: .standard(proto: "last_message_at"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.groupID)
      case 2: try decoder.decodeSingularInt32Field(value: &self.offSet)
      case 3: try decoder.decodeSingularInt64Field(value: &self.lastMessageAt)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.groupID.isEmpty {
      try visitor.visitSingularStringField(value: self.groupID, fieldNumber: 1)
    }
    if self.offSet != 0 {
      try visitor.visitSingularInt32Field(value: self.offSet, fieldNumber: 2)
    }
    if self.lastMessageAt != 0 {
      try visitor.visitSingularInt64Field(value: self.lastMessageAt, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_GetMessagesInGroupRequest, rhs: Message_GetMessagesInGroupRequest) -> Bool {
    if lhs.groupID != rhs.groupID {return false}
    if lhs.offSet != rhs.offSet {return false}
    if lhs.lastMessageAt != rhs.lastMessageAt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message_GetMessagesInGroupResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GetMessagesInGroupResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "lst_message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.lstMessage)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.lstMessage.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.lstMessage, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_GetMessagesInGroupResponse, rhs: Message_GetMessagesInGroupResponse) -> Bool {
    if lhs.lstMessage != rhs.lstMessage {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message_PublishRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PublishRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "fromClientId"),
    2: .same(proto: "clientId"),
    3: .same(proto: "groupId"),
    4: .same(proto: "groupType"),
    5: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.fromClientID)
      case 2: try decoder.decodeSingularStringField(value: &self.clientID)
      case 3: try decoder.decodeSingularStringField(value: &self.groupID)
      case 4: try decoder.decodeSingularStringField(value: &self.groupType)
      case 5: try decoder.decodeSingularBytesField(value: &self.message)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.fromClientID.isEmpty {
      try visitor.visitSingularStringField(value: self.fromClientID, fieldNumber: 1)
    }
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 2)
    }
    if !self.groupID.isEmpty {
      try visitor.visitSingularStringField(value: self.groupID, fieldNumber: 3)
    }
    if !self.groupType.isEmpty {
      try visitor.visitSingularStringField(value: self.groupType, fieldNumber: 4)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularBytesField(value: self.message, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_PublishRequest, rhs: Message_PublishRequest) -> Bool {
    if lhs.fromClientID != rhs.fromClientID {return false}
    if lhs.clientID != rhs.clientID {return false}
    if lhs.groupID != rhs.groupID {return false}
    if lhs.groupType != rhs.groupType {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message_SubscribeAndListenRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SubscribeAndListenRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "clientId"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.clientID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Message_SubscribeAndListenRequest, rhs: Message_SubscribeAndListenRequest) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
