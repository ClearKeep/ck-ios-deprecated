// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Messages.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Signal_SignalMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var ratchetKey: Data {
    get {return _ratchetKey ?? SwiftProtobuf.Internal.emptyData}
    set {_ratchetKey = newValue}
  }
  /// Returns true if `ratchetKey` has been explicitly set.
  var hasRatchetKey: Bool {return self._ratchetKey != nil}
  /// Clears the value of `ratchetKey`. Subsequent reads from it will return its default value.
  mutating func clearRatchetKey() {self._ratchetKey = nil}

  var counter: UInt32 {
    get {return _counter ?? 0}
    set {_counter = newValue}
  }
  /// Returns true if `counter` has been explicitly set.
  var hasCounter: Bool {return self._counter != nil}
  /// Clears the value of `counter`. Subsequent reads from it will return its default value.
  mutating func clearCounter() {self._counter = nil}

  var previousCounter: UInt32 {
    get {return _previousCounter ?? 0}
    set {_previousCounter = newValue}
  }
  /// Returns true if `previousCounter` has been explicitly set.
  var hasPreviousCounter: Bool {return self._previousCounter != nil}
  /// Clears the value of `previousCounter`. Subsequent reads from it will return its default value.
  mutating func clearPreviousCounter() {self._previousCounter = nil}

  var ciphertext: Data {
    get {return _ciphertext ?? SwiftProtobuf.Internal.emptyData}
    set {_ciphertext = newValue}
  }
  /// Returns true if `ciphertext` has been explicitly set.
  var hasCiphertext: Bool {return self._ciphertext != nil}
  /// Clears the value of `ciphertext`. Subsequent reads from it will return its default value.
  mutating func clearCiphertext() {self._ciphertext = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _ratchetKey: Data? = nil
  fileprivate var _counter: UInt32? = nil
  fileprivate var _previousCounter: UInt32? = nil
  fileprivate var _ciphertext: Data? = nil
}

struct Signal_PreKeySignalMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var preKeyID: UInt32 {
    get {return _preKeyID ?? 0}
    set {_preKeyID = newValue}
  }
  /// Returns true if `preKeyID` has been explicitly set.
  var hasPreKeyID: Bool {return self._preKeyID != nil}
  /// Clears the value of `preKeyID`. Subsequent reads from it will return its default value.
  mutating func clearPreKeyID() {self._preKeyID = nil}

  var signedPreKeyID: UInt32 {
    get {return _signedPreKeyID ?? 0}
    set {_signedPreKeyID = newValue}
  }
  /// Returns true if `signedPreKeyID` has been explicitly set.
  var hasSignedPreKeyID: Bool {return self._signedPreKeyID != nil}
  /// Clears the value of `signedPreKeyID`. Subsequent reads from it will return its default value.
  mutating func clearSignedPreKeyID() {self._signedPreKeyID = nil}

  var baseKey: Data {
    get {return _baseKey ?? SwiftProtobuf.Internal.emptyData}
    set {_baseKey = newValue}
  }
  /// Returns true if `baseKey` has been explicitly set.
  var hasBaseKey: Bool {return self._baseKey != nil}
  /// Clears the value of `baseKey`. Subsequent reads from it will return its default value.
  mutating func clearBaseKey() {self._baseKey = nil}

  var identityKey: Data {
    get {return _identityKey ?? SwiftProtobuf.Internal.emptyData}
    set {_identityKey = newValue}
  }
  /// Returns true if `identityKey` has been explicitly set.
  var hasIdentityKey: Bool {return self._identityKey != nil}
  /// Clears the value of `identityKey`. Subsequent reads from it will return its default value.
  mutating func clearIdentityKey() {self._identityKey = nil}

  /// SignalMessage
  var message: Data {
    get {return _message ?? SwiftProtobuf.Internal.emptyData}
    set {_message = newValue}
  }
  /// Returns true if `message` has been explicitly set.
  var hasMessage: Bool {return self._message != nil}
  /// Clears the value of `message`. Subsequent reads from it will return its default value.
  mutating func clearMessage() {self._message = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _preKeyID: UInt32? = nil
  fileprivate var _signedPreKeyID: UInt32? = nil
  fileprivate var _baseKey: Data? = nil
  fileprivate var _identityKey: Data? = nil
  fileprivate var _message: Data? = nil
}

struct Signal_SenderKeyMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: UInt32 {
    get {return _id ?? 0}
    set {_id = newValue}
  }
  /// Returns true if `id` has been explicitly set.
  var hasID: Bool {return self._id != nil}
  /// Clears the value of `id`. Subsequent reads from it will return its default value.
  mutating func clearID() {self._id = nil}

  var iteration: UInt32 {
    get {return _iteration ?? 0}
    set {_iteration = newValue}
  }
  /// Returns true if `iteration` has been explicitly set.
  var hasIteration: Bool {return self._iteration != nil}
  /// Clears the value of `iteration`. Subsequent reads from it will return its default value.
  mutating func clearIteration() {self._iteration = nil}

  var ciphertext: Data {
    get {return _ciphertext ?? SwiftProtobuf.Internal.emptyData}
    set {_ciphertext = newValue}
  }
  /// Returns true if `ciphertext` has been explicitly set.
  var hasCiphertext: Bool {return self._ciphertext != nil}
  /// Clears the value of `ciphertext`. Subsequent reads from it will return its default value.
  mutating func clearCiphertext() {self._ciphertext = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _id: UInt32? = nil
  fileprivate var _iteration: UInt32? = nil
  fileprivate var _ciphertext: Data? = nil
}

struct Signal_SenderKeyDistributionMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: UInt32 {
    get {return _id ?? 0}
    set {_id = newValue}
  }
  /// Returns true if `id` has been explicitly set.
  var hasID: Bool {return self._id != nil}
  /// Clears the value of `id`. Subsequent reads from it will return its default value.
  mutating func clearID() {self._id = nil}

  var iteration: UInt32 {
    get {return _iteration ?? 0}
    set {_iteration = newValue}
  }
  /// Returns true if `iteration` has been explicitly set.
  var hasIteration: Bool {return self._iteration != nil}
  /// Clears the value of `iteration`. Subsequent reads from it will return its default value.
  mutating func clearIteration() {self._iteration = nil}

  var chainKey: Data {
    get {return _chainKey ?? SwiftProtobuf.Internal.emptyData}
    set {_chainKey = newValue}
  }
  /// Returns true if `chainKey` has been explicitly set.
  var hasChainKey: Bool {return self._chainKey != nil}
  /// Clears the value of `chainKey`. Subsequent reads from it will return its default value.
  mutating func clearChainKey() {self._chainKey = nil}

  var signingKey: Data {
    get {return _signingKey ?? SwiftProtobuf.Internal.emptyData}
    set {_signingKey = newValue}
  }
  /// Returns true if `signingKey` has been explicitly set.
  var hasSigningKey: Bool {return self._signingKey != nil}
  /// Clears the value of `signingKey`. Subsequent reads from it will return its default value.
  mutating func clearSigningKey() {self._signingKey = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _id: UInt32? = nil
  fileprivate var _iteration: UInt32? = nil
  fileprivate var _chainKey: Data? = nil
  fileprivate var _signingKey: Data? = nil
}

struct Signal_DeviceConsistencyCodeMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var generation: UInt32 {
    get {return _generation ?? 0}
    set {_generation = newValue}
  }
  /// Returns true if `generation` has been explicitly set.
  var hasGeneration: Bool {return self._generation != nil}
  /// Clears the value of `generation`. Subsequent reads from it will return its default value.
  mutating func clearGeneration() {self._generation = nil}

  var signature: Data {
    get {return _signature ?? SwiftProtobuf.Internal.emptyData}
    set {_signature = newValue}
  }
  /// Returns true if `signature` has been explicitly set.
  var hasSignature: Bool {return self._signature != nil}
  /// Clears the value of `signature`. Subsequent reads from it will return its default value.
  mutating func clearSignature() {self._signature = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _generation: UInt32? = nil
  fileprivate var _signature: Data? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "Signal"

extension Signal_SignalMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignalMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ratchetKey"),
    2: .same(proto: "counter"),
    3: .same(proto: "previousCounter"),
    4: .same(proto: "ciphertext"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self._ratchetKey)
      case 2: try decoder.decodeSingularUInt32Field(value: &self._counter)
      case 3: try decoder.decodeSingularUInt32Field(value: &self._previousCounter)
      case 4: try decoder.decodeSingularBytesField(value: &self._ciphertext)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._ratchetKey {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 1)
    }
    if let v = self._counter {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 2)
    }
    if let v = self._previousCounter {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 3)
    }
    if let v = self._ciphertext {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Signal_SignalMessage) -> Bool {
    if self._ratchetKey != other._ratchetKey {return false}
    if self._counter != other._counter {return false}
    if self._previousCounter != other._previousCounter {return false}
    if self._ciphertext != other._ciphertext {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Signal_PreKeySignalMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PreKeySignalMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "preKeyId"),
    6: .same(proto: "signedPreKeyId"),
    2: .same(proto: "baseKey"),
    3: .same(proto: "identityKey"),
    4: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self._preKeyID)
      case 2: try decoder.decodeSingularBytesField(value: &self._baseKey)
      case 3: try decoder.decodeSingularBytesField(value: &self._identityKey)
      case 4: try decoder.decodeSingularBytesField(value: &self._message)
      case 6: try decoder.decodeSingularUInt32Field(value: &self._signedPreKeyID)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._preKeyID {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 1)
    }
    if let v = self._baseKey {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 2)
    }
    if let v = self._identityKey {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 3)
    }
    if let v = self._message {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 4)
    }
    if let v = self._signedPreKeyID {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Signal_PreKeySignalMessage) -> Bool {
    if self._preKeyID != other._preKeyID {return false}
    if self._signedPreKeyID != other._signedPreKeyID {return false}
    if self._baseKey != other._baseKey {return false}
    if self._identityKey != other._identityKey {return false}
    if self._message != other._message {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Signal_SenderKeyMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SenderKeyMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "iteration"),
    3: .same(proto: "ciphertext"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self._id)
      case 2: try decoder.decodeSingularUInt32Field(value: &self._iteration)
      case 3: try decoder.decodeSingularBytesField(value: &self._ciphertext)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._id {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 1)
    }
    if let v = self._iteration {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 2)
    }
    if let v = self._ciphertext {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Signal_SenderKeyMessage) -> Bool {
    if self._id != other._id {return false}
    if self._iteration != other._iteration {return false}
    if self._ciphertext != other._ciphertext {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Signal_SenderKeyDistributionMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SenderKeyDistributionMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "iteration"),
    3: .same(proto: "chainKey"),
    4: .same(proto: "signingKey"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self._id)
      case 2: try decoder.decodeSingularUInt32Field(value: &self._iteration)
      case 3: try decoder.decodeSingularBytesField(value: &self._chainKey)
      case 4: try decoder.decodeSingularBytesField(value: &self._signingKey)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._id {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 1)
    }
    if let v = self._iteration {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 2)
    }
    if let v = self._chainKey {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 3)
    }
    if let v = self._signingKey {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Signal_SenderKeyDistributionMessage) -> Bool {
    if self._id != other._id {return false}
    if self._iteration != other._iteration {return false}
    if self._chainKey != other._chainKey {return false}
    if self._signingKey != other._signingKey {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Signal_DeviceConsistencyCodeMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".DeviceConsistencyCodeMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "generation"),
    2: .same(proto: "signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt32Field(value: &self._generation)
      case 2: try decoder.decodeSingularBytesField(value: &self._signature)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._generation {
      try visitor.visitSingularUInt32Field(value: v, fieldNumber: 1)
    }
    if let v = self._signature {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Signal_DeviceConsistencyCodeMessage) -> Bool {
    if self._generation != other._generation {return false}
    if self._signature != other._signature {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}
