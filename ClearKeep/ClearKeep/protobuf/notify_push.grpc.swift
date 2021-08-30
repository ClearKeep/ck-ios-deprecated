//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: notify_push.proto
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


/// Method
///
/// Usage: instantiate `NotifyPush_NotifyPushClient`, then call methods of this protocol to make API calls.
public protocol NotifyPush_NotifyPushClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: NotifyPush_NotifyPushClientInterceptorFactoryProtocol? { get }

  func register_token(
    _ request: NotifyPush_RegisterTokenRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<NotifyPush_RegisterTokenRequest, NotifyPush_BaseResponse>

  func push_text(
    _ request: NotifyPush_PushTextRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<NotifyPush_PushTextRequest, NotifyPush_BaseResponse>

  func push_voip(
    _ request: NotifyPush_PushVoipRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<NotifyPush_PushVoipRequest, NotifyPush_BaseResponse>
}

extension NotifyPush_NotifyPushClientProtocol {
  public var serviceName: String {
    return "notify_push.NotifyPush"
  }

  /// Unary call to register_token
  ///
  /// - Parameters:
  ///   - request: Request to send to register_token.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func register_token(
    _ request: NotifyPush_RegisterTokenRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<NotifyPush_RegisterTokenRequest, NotifyPush_BaseResponse> {
    return self.makeUnaryCall(
      path: "/notify_push.NotifyPush/register_token",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeregister_tokenInterceptors() ?? []
    )
  }

  /// Unary call to push_text
  ///
  /// - Parameters:
  ///   - request: Request to send to push_text.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func push_text(
    _ request: NotifyPush_PushTextRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<NotifyPush_PushTextRequest, NotifyPush_BaseResponse> {
    return self.makeUnaryCall(
      path: "/notify_push.NotifyPush/push_text",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makepush_textInterceptors() ?? []
    )
  }

  /// Unary call to push_voip
  ///
  /// - Parameters:
  ///   - request: Request to send to push_voip.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func push_voip(
    _ request: NotifyPush_PushVoipRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<NotifyPush_PushVoipRequest, NotifyPush_BaseResponse> {
    return self.makeUnaryCall(
      path: "/notify_push.NotifyPush/push_voip",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makepush_voipInterceptors() ?? []
    )
  }
}

public protocol NotifyPush_NotifyPushClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'register_token'.
  func makeregister_tokenInterceptors() -> [ClientInterceptor<NotifyPush_RegisterTokenRequest, NotifyPush_BaseResponse>]

  /// - Returns: Interceptors to use when invoking 'push_text'.
  func makepush_textInterceptors() -> [ClientInterceptor<NotifyPush_PushTextRequest, NotifyPush_BaseResponse>]

  /// - Returns: Interceptors to use when invoking 'push_voip'.
  func makepush_voipInterceptors() -> [ClientInterceptor<NotifyPush_PushVoipRequest, NotifyPush_BaseResponse>]
}

public final class NotifyPush_NotifyPushClient: NotifyPush_NotifyPushClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: NotifyPush_NotifyPushClientInterceptorFactoryProtocol?

  /// Creates a client for the notify_push.NotifyPush service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: NotifyPush_NotifyPushClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Method
///
/// To build a server, implement a class that conforms to this protocol.
public protocol NotifyPush_NotifyPushProvider: CallHandlerProvider {
  var interceptors: NotifyPush_NotifyPushServerInterceptorFactoryProtocol? { get }

  func register_token(request: NotifyPush_RegisterTokenRequest, context: StatusOnlyCallContext) -> EventLoopFuture<NotifyPush_BaseResponse>

  func push_text(request: NotifyPush_PushTextRequest, context: StatusOnlyCallContext) -> EventLoopFuture<NotifyPush_BaseResponse>

  func push_voip(request: NotifyPush_PushVoipRequest, context: StatusOnlyCallContext) -> EventLoopFuture<NotifyPush_BaseResponse>
}

extension NotifyPush_NotifyPushProvider {
  public var serviceName: Substring { return "notify_push.NotifyPush" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "register_token":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<NotifyPush_RegisterTokenRequest>(),
        responseSerializer: ProtobufSerializer<NotifyPush_BaseResponse>(),
        interceptors: self.interceptors?.makeregister_tokenInterceptors() ?? [],
        userFunction: self.register_token(request:context:)
      )

    case "push_text":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<NotifyPush_PushTextRequest>(),
        responseSerializer: ProtobufSerializer<NotifyPush_BaseResponse>(),
        interceptors: self.interceptors?.makepush_textInterceptors() ?? [],
        userFunction: self.push_text(request:context:)
      )

    case "push_voip":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<NotifyPush_PushVoipRequest>(),
        responseSerializer: ProtobufSerializer<NotifyPush_BaseResponse>(),
        interceptors: self.interceptors?.makepush_voipInterceptors() ?? [],
        userFunction: self.push_voip(request:context:)
      )

    default:
      return nil
    }
  }
}

public protocol NotifyPush_NotifyPushServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'register_token'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeregister_tokenInterceptors() -> [ServerInterceptor<NotifyPush_RegisterTokenRequest, NotifyPush_BaseResponse>]

  /// - Returns: Interceptors to use when handling 'push_text'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makepush_textInterceptors() -> [ServerInterceptor<NotifyPush_PushTextRequest, NotifyPush_BaseResponse>]

  /// - Returns: Interceptors to use when handling 'push_voip'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makepush_voipInterceptors() -> [ServerInterceptor<NotifyPush_PushVoipRequest, NotifyPush_BaseResponse>]
}
