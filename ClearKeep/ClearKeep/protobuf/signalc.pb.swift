// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: signalc.proto
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

struct Signalc_BaseResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var message: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_SignalRegisterKeysRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var registrationID: Int32 = 0

  var deviceID: Int32 = 0

  var identityKeyPublic: Data = Data()

  var preKeyID: Int32 = 0

  var preKey: Data = Data()

  var signedPreKeyID: Int32 = 0

  var signedPreKey: Data = Data()

  var signedPreKeySignature: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_SignalKeysUserRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_SignalKeysUserResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var registrationID: Int32 = 0

  var deviceID: Int32 = 0

  var identityKeyPublic: Data = Data()

  var preKeyID: Int32 = 0

  var preKey: Data = Data()

  var signedPreKeyID: Int32 = 0

  var signedPreKey: Data = Data()

  var signedPreKeySignature: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_PublishRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var senderID: String = String()

  var receiveID: String = String()

  var message: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_SubscribeAndListenRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientID: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Signalc_Publication {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var senderID: String = String()

  var message: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "signalc"

extension Signalc_BaseResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".BaseResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.message) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Signalc_BaseResponse, rhs: Signalc_BaseResponse) -> Bool {
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_SignalRegisterKeysRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignalRegisterKeysRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "clientId"),
    2: .same(proto: "registrationId"),
    3: .same(proto: "deviceId"),
    4: .same(proto: "identityKeyPublic"),
    5: .same(proto: "preKeyId"),
    6: .same(proto: "preKey"),
    7: .same(proto: "signedPreKeyId"),
    8: .same(proto: "signedPreKey"),
    9: .same(proto: "signedPreKeySignature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.clientID) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.registrationID) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.deviceID) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.identityKeyPublic) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.preKeyID) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.preKey) }()
      case 7: try { try decoder.decodeSingularInt32Field(value: &self.signedPreKeyID) }()
      case 8: try { try decoder.decodeSingularBytesField(value: &self.signedPreKey) }()
      case 9: try { try decoder.decodeSingularBytesField(value: &self.signedPreKeySignature) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 1)
    }
    if self.registrationID != 0 {
      try visitor.visitSingularInt32Field(value: self.registrationID, fieldNumber: 2)
    }
    if self.deviceID != 0 {
      try visitor.visitSingularInt32Field(value: self.deviceID, fieldNumber: 3)
    }
    if !self.identityKeyPublic.isEmpty {
      try visitor.visitSingularBytesField(value: self.identityKeyPublic, fieldNumber: 4)
    }
    if self.preKeyID != 0 {
      try visitor.visitSingularInt32Field(value: self.preKeyID, fieldNumber: 5)
    }
    if !self.preKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.preKey, fieldNumber: 6)
    }
    if self.signedPreKeyID != 0 {
      try visitor.visitSingularInt32Field(value: self.signedPreKeyID, fieldNumber: 7)
    }
    if !self.signedPreKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.signedPreKey, fieldNumber: 8)
    }
    if !self.signedPreKeySignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.signedPreKeySignature, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Signalc_SignalRegisterKeysRequest, rhs: Signalc_SignalRegisterKeysRequest) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.registrationID != rhs.registrationID {return false}
    if lhs.deviceID != rhs.deviceID {return false}
    if lhs.identityKeyPublic != rhs.identityKeyPublic {return false}
    if lhs.preKeyID != rhs.preKeyID {return false}
    if lhs.preKey != rhs.preKey {return false}
    if lhs.signedPreKeyID != rhs.signedPreKeyID {return false}
    if lhs.signedPreKey != rhs.signedPreKey {return false}
    if lhs.signedPreKeySignature != rhs.signedPreKeySignature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_SignalKeysUserRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignalKeysUserRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "clientId"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.clientID) }()
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

  static func ==(lhs: Signalc_SignalKeysUserRequest, rhs: Signalc_SignalKeysUserRequest) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_SignalKeysUserResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignalKeysUserResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "clientId"),
    2: .same(proto: "registrationId"),
    3: .same(proto: "deviceId"),
    4: .same(proto: "identityKeyPublic"),
    5: .same(proto: "preKeyId"),
    6: .same(proto: "preKey"),
    7: .same(proto: "signedPreKeyId"),
    8: .same(proto: "signedPreKey"),
    9: .same(proto: "signedPreKeySignature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.clientID) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.registrationID) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.deviceID) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.identityKeyPublic) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.preKeyID) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.preKey) }()
      case 7: try { try decoder.decodeSingularInt32Field(value: &self.signedPreKeyID) }()
      case 8: try { try decoder.decodeSingularBytesField(value: &self.signedPreKey) }()
      case 9: try { try decoder.decodeSingularBytesField(value: &self.signedPreKeySignature) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.clientID.isEmpty {
      try visitor.visitSingularStringField(value: self.clientID, fieldNumber: 1)
    }
    if self.registrationID != 0 {
      try visitor.visitSingularInt32Field(value: self.registrationID, fieldNumber: 2)
    }
    if self.deviceID != 0 {
      try visitor.visitSingularInt32Field(value: self.deviceID, fieldNumber: 3)
    }
    if !self.identityKeyPublic.isEmpty {
      try visitor.visitSingularBytesField(value: self.identityKeyPublic, fieldNumber: 4)
    }
    if self.preKeyID != 0 {
      try visitor.visitSingularInt32Field(value: self.preKeyID, fieldNumber: 5)
    }
    if !self.preKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.preKey, fieldNumber: 6)
    }
    if self.signedPreKeyID != 0 {
      try visitor.visitSingularInt32Field(value: self.signedPreKeyID, fieldNumber: 7)
    }
    if !self.signedPreKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.signedPreKey, fieldNumber: 8)
    }
    if !self.signedPreKeySignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.signedPreKeySignature, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Signalc_SignalKeysUserResponse, rhs: Signalc_SignalKeysUserResponse) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.registrationID != rhs.registrationID {return false}
    if lhs.deviceID != rhs.deviceID {return false}
    if lhs.identityKeyPublic != rhs.identityKeyPublic {return false}
    if lhs.preKeyID != rhs.preKeyID {return false}
    if lhs.preKey != rhs.preKey {return false}
    if lhs.signedPreKeyID != rhs.signedPreKeyID {return false}
    if lhs.signedPreKey != rhs.signedPreKey {return false}
    if lhs.signedPreKeySignature != rhs.signedPreKeySignature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_PublishRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PublishRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "senderId"),
    2: .same(proto: "receiveId"),
    3: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.senderID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.receiveID) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.message) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.senderID.isEmpty {
      try visitor.visitSingularStringField(value: self.senderID, fieldNumber: 1)
    }
    if !self.receiveID.isEmpty {
      try visitor.visitSingularStringField(value: self.receiveID, fieldNumber: 2)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularBytesField(value: self.message, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Signalc_PublishRequest, rhs: Signalc_PublishRequest) -> Bool {
    if lhs.senderID != rhs.senderID {return false}
    if lhs.receiveID != rhs.receiveID {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_SubscribeAndListenRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SubscribeAndListenRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "clientId"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.clientID) }()
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

  static func ==(lhs: Signalc_SubscribeAndListenRequest, rhs: Signalc_SubscribeAndListenRequest) -> Bool {
    if lhs.clientID != rhs.clientID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Signalc_Publication: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Publication"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "senderId"),
    2: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.senderID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.message) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.senderID.isEmpty {
      try visitor.visitSingularStringField(value: self.senderID, fieldNumber: 1)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularBytesField(value: self.message, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Signalc_Publication, rhs: Signalc_Publication) -> Bool {
    if lhs.senderID != rhs.senderID {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
