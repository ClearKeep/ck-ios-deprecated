// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: video_call.proto
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

///errors response
struct VideoCall_ErrorRes {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var code: Int64 = 0

  var message: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct VideoCall_BaseResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var success: Bool = false

  var errors: VideoCall_ErrorRes {
    get {return _errors ?? VideoCall_ErrorRes()}
    set {_errors = newValue}
  }
  /// Returns true if `errors` has been explicitly set.
  var hasErrors: Bool {return self._errors != nil}
  /// Clears the value of `errors`. Subsequent reads from it will return its default value.
  mutating func clearErrors() {self._errors = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _errors: VideoCall_ErrorRes? = nil
}

struct VideoCall_ServerResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var stunServer: VideoCall_StunServer {
    get {return _stunServer ?? VideoCall_StunServer()}
    set {_stunServer = newValue}
  }
  /// Returns true if `stunServer` has been explicitly set.
  var hasStunServer: Bool {return self._stunServer != nil}
  /// Clears the value of `stunServer`. Subsequent reads from it will return its default value.
  mutating func clearStunServer() {self._stunServer = nil}

  var turnServer: VideoCall_TurnServer {
    get {return _turnServer ?? VideoCall_TurnServer()}
    set {_turnServer = newValue}
  }
  /// Returns true if `turnServer` has been explicitly set.
  var hasTurnServer: Bool {return self._turnServer != nil}
  /// Clears the value of `turnServer`. Subsequent reads from it will return its default value.
  mutating func clearTurnServer() {self._turnServer = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _stunServer: VideoCall_StunServer? = nil
  fileprivate var _turnServer: VideoCall_TurnServer? = nil
}

struct VideoCall_StunServer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var server: String = String()

  var port: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct VideoCall_TurnServer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var server: String = String()

  var port: Int64 = 0

  var type: String = String()

  var user: String = String()

  var pwd: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Request: new call
struct VideoCall_VideoCallRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var groupID: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "video_call"

extension VideoCall_ErrorRes: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ErrorRes"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.code)
      case 2: try decoder.decodeSingularStringField(value: &self.message)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != 0 {
      try visitor.visitSingularInt64Field(value: self.code, fieldNumber: 1)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_ErrorRes, rhs: VideoCall_ErrorRes) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension VideoCall_BaseResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".BaseResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "success"),
    2: .same(proto: "errors"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBoolField(value: &self.success)
      case 2: try decoder.decodeSingularMessageField(value: &self._errors)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.success != false {
      try visitor.visitSingularBoolField(value: self.success, fieldNumber: 1)
    }
    if let v = self._errors {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_BaseResponse, rhs: VideoCall_BaseResponse) -> Bool {
    if lhs.success != rhs.success {return false}
    if lhs._errors != rhs._errors {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension VideoCall_ServerResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ServerResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "stun_server"),
    2: .standard(proto: "turn_server"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &self._stunServer)
      case 2: try decoder.decodeSingularMessageField(value: &self._turnServer)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._stunServer {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if let v = self._turnServer {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_ServerResponse, rhs: VideoCall_ServerResponse) -> Bool {
    if lhs._stunServer != rhs._stunServer {return false}
    if lhs._turnServer != rhs._turnServer {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension VideoCall_StunServer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".StunServer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "server"),
    2: .same(proto: "port"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.server)
      case 2: try decoder.decodeSingularInt64Field(value: &self.port)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.server.isEmpty {
      try visitor.visitSingularStringField(value: self.server, fieldNumber: 1)
    }
    if self.port != 0 {
      try visitor.visitSingularInt64Field(value: self.port, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_StunServer, rhs: VideoCall_StunServer) -> Bool {
    if lhs.server != rhs.server {return false}
    if lhs.port != rhs.port {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension VideoCall_TurnServer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TurnServer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "server"),
    2: .same(proto: "port"),
    3: .same(proto: "type"),
    4: .same(proto: "user"),
    5: .same(proto: "pwd"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.server)
      case 2: try decoder.decodeSingularInt64Field(value: &self.port)
      case 3: try decoder.decodeSingularStringField(value: &self.type)
      case 4: try decoder.decodeSingularStringField(value: &self.user)
      case 5: try decoder.decodeSingularStringField(value: &self.pwd)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.server.isEmpty {
      try visitor.visitSingularStringField(value: self.server, fieldNumber: 1)
    }
    if self.port != 0 {
      try visitor.visitSingularInt64Field(value: self.port, fieldNumber: 2)
    }
    if !self.type.isEmpty {
      try visitor.visitSingularStringField(value: self.type, fieldNumber: 3)
    }
    if !self.user.isEmpty {
      try visitor.visitSingularStringField(value: self.user, fieldNumber: 4)
    }
    if !self.pwd.isEmpty {
      try visitor.visitSingularStringField(value: self.pwd, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_TurnServer, rhs: VideoCall_TurnServer) -> Bool {
    if lhs.server != rhs.server {return false}
    if lhs.port != rhs.port {return false}
    if lhs.type != rhs.type {return false}
    if lhs.user != rhs.user {return false}
    if lhs.pwd != rhs.pwd {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension VideoCall_VideoCallRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".VideoCallRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "client_id"),
    2: .standard(proto: "group_id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.clientID)
      case 2: try decoder.decodeSingularInt64Field(value: &self.groupID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 1)
    }
    if self.groupID != 0 {
      try visitor.visitSingularInt64Field(value: self.groupID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: VideoCall_VideoCallRequest, rhs: VideoCall_VideoCallRequest) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.groupID != rhs.groupID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
