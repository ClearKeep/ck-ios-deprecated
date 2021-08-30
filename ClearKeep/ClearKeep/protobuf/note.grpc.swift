//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: note.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// gRPC methods
///
/// Usage: instantiate `Note_NoteClient`, then call methods of this protocol to make API calls.
public protocol Note_NoteClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Note_NoteClientInterceptorFactoryProtocol? { get }

  func create_note(
    _ request: Note_CreateNoteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Note_CreateNoteRequest, Note_UserNoteResponse>

  func edit_note(
    _ request: Note_EditNoteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Note_EditNoteRequest, Note_BaseResponse>

  func delete_note(
    _ request: Note_DeleteNoteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Note_DeleteNoteRequest, Note_BaseResponse>

  func get_user_notes(
    _ request: Note_GetUserNotesRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Note_GetUserNotesRequest, Note_GetUserNotesResponse>
}

extension Note_NoteClientProtocol {
  public var serviceName: String {
    return "note.Note"
  }

  /// Unary call to create_note
  ///
  /// - Parameters:
  ///   - request: Request to send to create_note.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func create_note(
    _ request: Note_CreateNoteRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Note_CreateNoteRequest, Note_UserNoteResponse> {
    return self.makeUnaryCall(
      path: "/note.Note/create_note",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makecreate_noteInterceptors() ?? []
    )
  }

  /// Unary call to edit_note
  ///
  /// - Parameters:
  ///   - request: Request to send to edit_note.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func edit_note(
    _ request: Note_EditNoteRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Note_EditNoteRequest, Note_BaseResponse> {
    return self.makeUnaryCall(
      path: "/note.Note/edit_note",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeedit_noteInterceptors() ?? []
    )
  }

  /// Unary call to delete_note
  ///
  /// - Parameters:
  ///   - request: Request to send to delete_note.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func delete_note(
    _ request: Note_DeleteNoteRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Note_DeleteNoteRequest, Note_BaseResponse> {
    return self.makeUnaryCall(
      path: "/note.Note/delete_note",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makedelete_noteInterceptors() ?? []
    )
  }

  /// Unary call to get_user_notes
  ///
  /// - Parameters:
  ///   - request: Request to send to get_user_notes.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func get_user_notes(
    _ request: Note_GetUserNotesRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Note_GetUserNotesRequest, Note_GetUserNotesResponse> {
    return self.makeUnaryCall(
      path: "/note.Note/get_user_notes",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeget_user_notesInterceptors() ?? []
    )
  }
}

public protocol Note_NoteClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'create_note'.
  func makecreate_noteInterceptors() -> [ClientInterceptor<Note_CreateNoteRequest, Note_UserNoteResponse>]

  /// - Returns: Interceptors to use when invoking 'edit_note'.
  func makeedit_noteInterceptors() -> [ClientInterceptor<Note_EditNoteRequest, Note_BaseResponse>]

  /// - Returns: Interceptors to use when invoking 'delete_note'.
  func makedelete_noteInterceptors() -> [ClientInterceptor<Note_DeleteNoteRequest, Note_BaseResponse>]

  /// - Returns: Interceptors to use when invoking 'get_user_notes'.
  func makeget_user_notesInterceptors() -> [ClientInterceptor<Note_GetUserNotesRequest, Note_GetUserNotesResponse>]
}

public final class Note_NoteClient: Note_NoteClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Note_NoteClientInterceptorFactoryProtocol?

  /// Creates a client for the note.Note service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Note_NoteClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// gRPC methods
///
/// To build a server, implement a class that conforms to this protocol.
public protocol Note_NoteProvider: CallHandlerProvider {
  var interceptors: Note_NoteServerInterceptorFactoryProtocol? { get }

  func create_note(request: Note_CreateNoteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Note_UserNoteResponse>

  func edit_note(request: Note_EditNoteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Note_BaseResponse>

  func delete_note(request: Note_DeleteNoteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Note_BaseResponse>

  func get_user_notes(request: Note_GetUserNotesRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Note_GetUserNotesResponse>
}

extension Note_NoteProvider {
  public var serviceName: Substring { return "note.Note" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "create_note":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Note_CreateNoteRequest>(),
        responseSerializer: ProtobufSerializer<Note_UserNoteResponse>(),
        interceptors: self.interceptors?.makecreate_noteInterceptors() ?? [],
        userFunction: self.create_note(request:context:)
      )

    case "edit_note":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Note_EditNoteRequest>(),
        responseSerializer: ProtobufSerializer<Note_BaseResponse>(),
        interceptors: self.interceptors?.makeedit_noteInterceptors() ?? [],
        userFunction: self.edit_note(request:context:)
      )

    case "delete_note":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Note_DeleteNoteRequest>(),
        responseSerializer: ProtobufSerializer<Note_BaseResponse>(),
        interceptors: self.interceptors?.makedelete_noteInterceptors() ?? [],
        userFunction: self.delete_note(request:context:)
      )

    case "get_user_notes":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Note_GetUserNotesRequest>(),
        responseSerializer: ProtobufSerializer<Note_GetUserNotesResponse>(),
        interceptors: self.interceptors?.makeget_user_notesInterceptors() ?? [],
        userFunction: self.get_user_notes(request:context:)
      )

    default:
      return nil
    }
  }
}

public protocol Note_NoteServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'create_note'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makecreate_noteInterceptors() -> [ServerInterceptor<Note_CreateNoteRequest, Note_UserNoteResponse>]

  /// - Returns: Interceptors to use when handling 'edit_note'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeedit_noteInterceptors() -> [ServerInterceptor<Note_EditNoteRequest, Note_BaseResponse>]

  /// - Returns: Interceptors to use when handling 'delete_note'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makedelete_noteInterceptors() -> [ServerInterceptor<Note_DeleteNoteRequest, Note_BaseResponse>]

  /// - Returns: Interceptors to use when handling 'get_user_notes'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeget_user_notesInterceptors() -> [ServerInterceptor<Note_GetUserNotesRequest, Note_GetUserNotesResponse>]
}
