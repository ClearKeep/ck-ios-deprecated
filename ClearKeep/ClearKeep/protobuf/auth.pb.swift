// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: auth.proto
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
struct Auth_ErrorRes {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var code: Int64 = 0

  var message: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Auth_BaseResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var success: Bool = false

  var errors: Auth_ErrorRes {
    get {return _errors ?? Auth_ErrorRes()}
    set {_errors = newValue}
  }
  /// Returns true if `errors` has been explicitly set.
  var hasErrors: Bool {return self._errors != nil}
  /// Clears the value of `errors`. Subsequent reads from it will return its default value.
  mutating func clearErrors() {self._errors = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _errors: Auth_ErrorRes? = nil
}

///Login message struct
struct Auth_AuthReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var email: String = String()

  var password: String = String()

  var authType: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Auth_LogoutReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var deviceID: String = String()

  var refreshToken: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// fogot password
struct Auth_FogotPassWord {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var email: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Auth_AuthRes {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var accessToken: String = String()

  var expiresIn: Int64 = 0

  var refreshExpiresIn: Int64 = 0

  var refreshToken: String = String()

  var tokenType: String = String()

  var sessionState: String = String()

  var scope: String = String()

  var hashKey: String = String()

  var baseResponse: Auth_BaseResponse {
    get {return _baseResponse ?? Auth_BaseResponse()}
    set {_baseResponse = newValue}
  }
  /// Returns true if `baseResponse` has been explicitly set.
  var hasBaseResponse: Bool {return self._baseResponse != nil}
  /// Clears the value of `baseResponse`. Subsequent reads from it will return its default value.
  mutating func clearBaseResponse() {self._baseResponse = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _baseResponse: Auth_BaseResponse? = nil
}

///Register message struct
struct Auth_RegisterReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var email: String = String()

  var displayName: String = String()

  var password: String = String()

  var authType: Int64 = 0

  var firstName: String = String()

  var lastName: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Auth_RegisterRes {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var baseResponse: Auth_BaseResponse {
    get {return _baseResponse ?? Auth_BaseResponse()}
    set {_baseResponse = newValue}
  }
  /// Returns true if `baseResponse` has been explicitly set.
  var hasBaseResponse: Bool {return self._baseResponse != nil}
  /// Clears the value of `baseResponse`. Subsequent reads from it will return its default value.
  mutating func clearBaseResponse() {self._baseResponse = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _baseResponse: Auth_BaseResponse? = nil
}

///Login Google message struct
struct Auth_GoogleLoginReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var idToken: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///Login Office365 message struct
struct Auth_OfficeLoginReq {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var accessToken: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "auth"

extension Auth_ErrorRes: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
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

  static func ==(lhs: Auth_ErrorRes, rhs: Auth_ErrorRes) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_BaseResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
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

  static func ==(lhs: Auth_BaseResponse, rhs: Auth_BaseResponse) -> Bool {
    if lhs.success != rhs.success {return false}
    if lhs._errors != rhs._errors {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_AuthReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".AuthReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "email"),
    2: .same(proto: "password"),
    3: .standard(proto: "auth_type"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.email)
      case 2: try decoder.decodeSingularStringField(value: &self.password)
      case 3: try decoder.decodeSingularInt64Field(value: &self.authType)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.email.isEmpty {
      try visitor.visitSingularStringField(value: self.email, fieldNumber: 1)
    }
    if !self.password.isEmpty {
      try visitor.visitSingularStringField(value: self.password, fieldNumber: 2)
    }
    if self.authType != 0 {
      try visitor.visitSingularInt64Field(value: self.authType, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_AuthReq, rhs: Auth_AuthReq) -> Bool {
    if lhs.email != rhs.email {return false}
    if lhs.password != rhs.password {return false}
    if lhs.authType != rhs.authType {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_LogoutReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LogoutReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "device_id"),
    2: .standard(proto: "refresh_token"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.deviceID)
      case 2: try decoder.decodeSingularStringField(value: &self.refreshToken)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.deviceID.isEmpty {
      try visitor.visitSingularStringField(value: self.deviceID, fieldNumber: 1)
    }
    if !self.refreshToken.isEmpty {
      try visitor.visitSingularStringField(value: self.refreshToken, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_LogoutReq, rhs: Auth_LogoutReq) -> Bool {
    if lhs.deviceID != rhs.deviceID {return false}
    if lhs.refreshToken != rhs.refreshToken {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_FogotPassWord: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".FogotPassWord"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "email"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.email)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.email.isEmpty {
      try visitor.visitSingularStringField(value: self.email, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_FogotPassWord, rhs: Auth_FogotPassWord) -> Bool {
    if lhs.email != rhs.email {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_AuthRes: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".AuthRes"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "access_token"),
    2: .standard(proto: "expires_in"),
    3: .standard(proto: "refresh_expires_in"),
    4: .standard(proto: "refresh_token"),
    5: .standard(proto: "token_type"),
    6: .standard(proto: "session_state"),
    7: .same(proto: "scope"),
    8: .standard(proto: "hash_key"),
    9: .standard(proto: "base_response"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.accessToken)
      case 2: try decoder.decodeSingularInt64Field(value: &self.expiresIn)
      case 3: try decoder.decodeSingularInt64Field(value: &self.refreshExpiresIn)
      case 4: try decoder.decodeSingularStringField(value: &self.refreshToken)
      case 5: try decoder.decodeSingularStringField(value: &self.tokenType)
      case 6: try decoder.decodeSingularStringField(value: &self.sessionState)
      case 7: try decoder.decodeSingularStringField(value: &self.scope)
      case 8: try decoder.decodeSingularStringField(value: &self.hashKey)
      case 9: try decoder.decodeSingularMessageField(value: &self._baseResponse)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.accessToken.isEmpty {
      try visitor.visitSingularStringField(value: self.accessToken, fieldNumber: 1)
    }
    if self.expiresIn != 0 {
      try visitor.visitSingularInt64Field(value: self.expiresIn, fieldNumber: 2)
    }
    if self.refreshExpiresIn != 0 {
      try visitor.visitSingularInt64Field(value: self.refreshExpiresIn, fieldNumber: 3)
    }
    if !self.refreshToken.isEmpty {
      try visitor.visitSingularStringField(value: self.refreshToken, fieldNumber: 4)
    }
    if !self.tokenType.isEmpty {
      try visitor.visitSingularStringField(value: self.tokenType, fieldNumber: 5)
    }
    if !self.sessionState.isEmpty {
      try visitor.visitSingularStringField(value: self.sessionState, fieldNumber: 6)
    }
    if !self.scope.isEmpty {
      try visitor.visitSingularStringField(value: self.scope, fieldNumber: 7)
    }
    if !self.hashKey.isEmpty {
      try visitor.visitSingularStringField(value: self.hashKey, fieldNumber: 8)
    }
    if let v = self._baseResponse {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_AuthRes, rhs: Auth_AuthRes) -> Bool {
    if lhs.accessToken != rhs.accessToken {return false}
    if lhs.expiresIn != rhs.expiresIn {return false}
    if lhs.refreshExpiresIn != rhs.refreshExpiresIn {return false}
    if lhs.refreshToken != rhs.refreshToken {return false}
    if lhs.tokenType != rhs.tokenType {return false}
    if lhs.sessionState != rhs.sessionState {return false}
    if lhs.scope != rhs.scope {return false}
    if lhs.hashKey != rhs.hashKey {return false}
    if lhs._baseResponse != rhs._baseResponse {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_RegisterReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RegisterReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "email"),
    2: .standard(proto: "display_name"),
    3: .same(proto: "password"),
    4: .standard(proto: "auth_type"),
    5: .standard(proto: "first_name"),
    6: .standard(proto: "last_name"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.email)
      case 2: try decoder.decodeSingularStringField(value: &self.displayName)
      case 3: try decoder.decodeSingularStringField(value: &self.password)
      case 4: try decoder.decodeSingularInt64Field(value: &self.authType)
      case 5: try decoder.decodeSingularStringField(value: &self.firstName)
      case 6: try decoder.decodeSingularStringField(value: &self.lastName)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.email.isEmpty {
      try visitor.visitSingularStringField(value: self.email, fieldNumber: 1)
    }
    if !self.displayName.isEmpty {
      try visitor.visitSingularStringField(value: self.displayName, fieldNumber: 2)
    }
    if !self.password.isEmpty {
      try visitor.visitSingularStringField(value: self.password, fieldNumber: 3)
    }
    if self.authType != 0 {
      try visitor.visitSingularInt64Field(value: self.authType, fieldNumber: 4)
    }
    if !self.firstName.isEmpty {
      try visitor.visitSingularStringField(value: self.firstName, fieldNumber: 5)
    }
    if !self.lastName.isEmpty {
      try visitor.visitSingularStringField(value: self.lastName, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_RegisterReq, rhs: Auth_RegisterReq) -> Bool {
    if lhs.email != rhs.email {return false}
    if lhs.displayName != rhs.displayName {return false}
    if lhs.password != rhs.password {return false}
    if lhs.authType != rhs.authType {return false}
    if lhs.firstName != rhs.firstName {return false}
    if lhs.lastName != rhs.lastName {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_RegisterRes: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".RegisterRes"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "base_response"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &self._baseResponse)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._baseResponse {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_RegisterRes, rhs: Auth_RegisterRes) -> Bool {
    if lhs._baseResponse != rhs._baseResponse {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_GoogleLoginReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".GoogleLoginReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "id_token"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.idToken)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.idToken.isEmpty {
      try visitor.visitSingularStringField(value: self.idToken, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_GoogleLoginReq, rhs: Auth_GoogleLoginReq) -> Bool {
    if lhs.idToken != rhs.idToken {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Auth_OfficeLoginReq: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".OfficeLoginReq"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "access_token"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.accessToken)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.accessToken.isEmpty {
      try visitor.visitSingularStringField(value: self.accessToken, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Auth_OfficeLoginReq, rhs: Auth_OfficeLoginReq) -> Bool {
    if lhs.accessToken != rhs.accessToken {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
