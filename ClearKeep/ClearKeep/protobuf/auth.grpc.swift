//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: auth.proto
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


/// Usage: instantiate `Auth_AuthClient`, then call methods of this protocol to make API calls.
public protocol Auth_AuthClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Auth_AuthClientInterceptorFactoryProtocol? { get }

  func login(
    _ request: Auth_AuthReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_AuthReq, Auth_AuthRes>

  func login_google(
    _ request: Auth_GoogleLoginReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_GoogleLoginReq, Auth_AuthRes>

  func login_office(
    _ request: Auth_OfficeLoginReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_OfficeLoginReq, Auth_AuthRes>

  func login_facebook(
    _ request: Auth_FacebookLoginReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_FacebookLoginReq, Auth_AuthRes>

  func validate_otp(
    _ request: Auth_MfaValidateOtpRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_MfaValidateOtpRequest, Auth_AuthRes>

  func resend_otp(
    _ request: Auth_MfaResendOtpReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_MfaResendOtpReq, Auth_MfaResendOtpRes>

  func register(
    _ request: Auth_RegisterReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_RegisterReq, Auth_RegisterRes>

  func fogot_password(
    _ request: Auth_FogotPassWord,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_FogotPassWord, Auth_BaseResponse>

  func logout(
    _ request: Auth_LogoutReq,
    callOptions: CallOptions?
  ) -> UnaryCall<Auth_LogoutReq, Auth_BaseResponse>
}

extension Auth_AuthClientProtocol {
  public var serviceName: String {
    return "auth.Auth"
  }

  /// Unary call to login
  ///
  /// - Parameters:
  ///   - request: Request to send to login.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func login(
    _ request: Auth_AuthReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_AuthReq, Auth_AuthRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/login",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeloginInterceptors() ?? []
    )
  }

  /// Unary call to login_google
  ///
  /// - Parameters:
  ///   - request: Request to send to login_google.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func login_google(
    _ request: Auth_GoogleLoginReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_GoogleLoginReq, Auth_AuthRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/login_google",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makelogin_googleInterceptors() ?? []
    )
  }

  /// Unary call to login_office
  ///
  /// - Parameters:
  ///   - request: Request to send to login_office.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func login_office(
    _ request: Auth_OfficeLoginReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_OfficeLoginReq, Auth_AuthRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/login_office",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makelogin_officeInterceptors() ?? []
    )
  }

  /// Unary call to login_facebook
  ///
  /// - Parameters:
  ///   - request: Request to send to login_facebook.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func login_facebook(
    _ request: Auth_FacebookLoginReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_FacebookLoginReq, Auth_AuthRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/login_facebook",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makelogin_facebookInterceptors() ?? []
    )
  }

  /// Unary call to validate_otp
  ///
  /// - Parameters:
  ///   - request: Request to send to validate_otp.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func validate_otp(
    _ request: Auth_MfaValidateOtpRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_MfaValidateOtpRequest, Auth_AuthRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/validate_otp",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makevalidate_otpInterceptors() ?? []
    )
  }

  /// Unary call to resend_otp
  ///
  /// - Parameters:
  ///   - request: Request to send to resend_otp.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func resend_otp(
    _ request: Auth_MfaResendOtpReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_MfaResendOtpReq, Auth_MfaResendOtpRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/resend_otp",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeresend_otpInterceptors() ?? []
    )
  }

  /// Unary call to register
  ///
  /// - Parameters:
  ///   - request: Request to send to register.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func register(
    _ request: Auth_RegisterReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_RegisterReq, Auth_RegisterRes> {
    return self.makeUnaryCall(
      path: "/auth.Auth/register",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeregisterInterceptors() ?? []
    )
  }

  /// Unary call to fogot_password
  ///
  /// - Parameters:
  ///   - request: Request to send to fogot_password.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func fogot_password(
    _ request: Auth_FogotPassWord,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_FogotPassWord, Auth_BaseResponse> {
    return self.makeUnaryCall(
      path: "/auth.Auth/fogot_password",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makefogot_passwordInterceptors() ?? []
    )
  }

  /// Unary call to logout
  ///
  /// - Parameters:
  ///   - request: Request to send to logout.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func logout(
    _ request: Auth_LogoutReq,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Auth_LogoutReq, Auth_BaseResponse> {
    return self.makeUnaryCall(
      path: "/auth.Auth/logout",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makelogoutInterceptors() ?? []
    )
  }
}

public protocol Auth_AuthClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'login'.
  func makeloginInterceptors() -> [ClientInterceptor<Auth_AuthReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when invoking 'login_google'.
  func makelogin_googleInterceptors() -> [ClientInterceptor<Auth_GoogleLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when invoking 'login_office'.
  func makelogin_officeInterceptors() -> [ClientInterceptor<Auth_OfficeLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when invoking 'login_facebook'.
  func makelogin_facebookInterceptors() -> [ClientInterceptor<Auth_FacebookLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when invoking 'validate_otp'.
  func makevalidate_otpInterceptors() -> [ClientInterceptor<Auth_MfaValidateOtpRequest, Auth_AuthRes>]

  /// - Returns: Interceptors to use when invoking 'resend_otp'.
  func makeresend_otpInterceptors() -> [ClientInterceptor<Auth_MfaResendOtpReq, Auth_MfaResendOtpRes>]

  /// - Returns: Interceptors to use when invoking 'register'.
  func makeregisterInterceptors() -> [ClientInterceptor<Auth_RegisterReq, Auth_RegisterRes>]

  /// - Returns: Interceptors to use when invoking 'fogot_password'.
  func makefogot_passwordInterceptors() -> [ClientInterceptor<Auth_FogotPassWord, Auth_BaseResponse>]

  /// - Returns: Interceptors to use when invoking 'logout'.
  func makelogoutInterceptors() -> [ClientInterceptor<Auth_LogoutReq, Auth_BaseResponse>]
}

public final class Auth_AuthClient: Auth_AuthClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Auth_AuthClientInterceptorFactoryProtocol?

  /// Creates a client for the auth.Auth service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Auth_AuthClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// To build a server, implement a class that conforms to this protocol.
public protocol Auth_AuthProvider: CallHandlerProvider {
  var interceptors: Auth_AuthServerInterceptorFactoryProtocol? { get }

  func login(request: Auth_AuthReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_AuthRes>

  func login_google(request: Auth_GoogleLoginReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_AuthRes>

  func login_office(request: Auth_OfficeLoginReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_AuthRes>

  func login_facebook(request: Auth_FacebookLoginReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_AuthRes>

  func validate_otp(request: Auth_MfaValidateOtpRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_AuthRes>

  func resend_otp(request: Auth_MfaResendOtpReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_MfaResendOtpRes>

  func register(request: Auth_RegisterReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_RegisterRes>

  func fogot_password(request: Auth_FogotPassWord, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_BaseResponse>

  func logout(request: Auth_LogoutReq, context: StatusOnlyCallContext) -> EventLoopFuture<Auth_BaseResponse>
}

extension Auth_AuthProvider {
  public var serviceName: Substring { return "auth.Auth" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "login":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_AuthReq>(),
        responseSerializer: ProtobufSerializer<Auth_AuthRes>(),
        interceptors: self.interceptors?.makeloginInterceptors() ?? [],
        userFunction: self.login(request:context:)
      )

    case "login_google":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_GoogleLoginReq>(),
        responseSerializer: ProtobufSerializer<Auth_AuthRes>(),
        interceptors: self.interceptors?.makelogin_googleInterceptors() ?? [],
        userFunction: self.login_google(request:context:)
      )

    case "login_office":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_OfficeLoginReq>(),
        responseSerializer: ProtobufSerializer<Auth_AuthRes>(),
        interceptors: self.interceptors?.makelogin_officeInterceptors() ?? [],
        userFunction: self.login_office(request:context:)
      )

    case "login_facebook":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_FacebookLoginReq>(),
        responseSerializer: ProtobufSerializer<Auth_AuthRes>(),
        interceptors: self.interceptors?.makelogin_facebookInterceptors() ?? [],
        userFunction: self.login_facebook(request:context:)
      )

    case "validate_otp":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_MfaValidateOtpRequest>(),
        responseSerializer: ProtobufSerializer<Auth_AuthRes>(),
        interceptors: self.interceptors?.makevalidate_otpInterceptors() ?? [],
        userFunction: self.validate_otp(request:context:)
      )

    case "resend_otp":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_MfaResendOtpReq>(),
        responseSerializer: ProtobufSerializer<Auth_MfaResendOtpRes>(),
        interceptors: self.interceptors?.makeresend_otpInterceptors() ?? [],
        userFunction: self.resend_otp(request:context:)
      )

    case "register":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_RegisterReq>(),
        responseSerializer: ProtobufSerializer<Auth_RegisterRes>(),
        interceptors: self.interceptors?.makeregisterInterceptors() ?? [],
        userFunction: self.register(request:context:)
      )

    case "fogot_password":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_FogotPassWord>(),
        responseSerializer: ProtobufSerializer<Auth_BaseResponse>(),
        interceptors: self.interceptors?.makefogot_passwordInterceptors() ?? [],
        userFunction: self.fogot_password(request:context:)
      )

    case "logout":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Auth_LogoutReq>(),
        responseSerializer: ProtobufSerializer<Auth_BaseResponse>(),
        interceptors: self.interceptors?.makelogoutInterceptors() ?? [],
        userFunction: self.logout(request:context:)
      )

    default:
      return nil
    }
  }
}

public protocol Auth_AuthServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'login'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeloginInterceptors() -> [ServerInterceptor<Auth_AuthReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when handling 'login_google'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makelogin_googleInterceptors() -> [ServerInterceptor<Auth_GoogleLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when handling 'login_office'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makelogin_officeInterceptors() -> [ServerInterceptor<Auth_OfficeLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when handling 'login_facebook'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makelogin_facebookInterceptors() -> [ServerInterceptor<Auth_FacebookLoginReq, Auth_AuthRes>]

  /// - Returns: Interceptors to use when handling 'validate_otp'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makevalidate_otpInterceptors() -> [ServerInterceptor<Auth_MfaValidateOtpRequest, Auth_AuthRes>]

  /// - Returns: Interceptors to use when handling 'resend_otp'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeresend_otpInterceptors() -> [ServerInterceptor<Auth_MfaResendOtpReq, Auth_MfaResendOtpRes>]

  /// - Returns: Interceptors to use when handling 'register'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeregisterInterceptors() -> [ServerInterceptor<Auth_RegisterReq, Auth_RegisterRes>]

  /// - Returns: Interceptors to use when handling 'fogot_password'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makefogot_passwordInterceptors() -> [ServerInterceptor<Auth_FogotPassWord, Auth_BaseResponse>]

  /// - Returns: Interceptors to use when handling 'logout'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makelogoutInterceptors() -> [ServerInterceptor<Auth_LogoutReq, Auth_BaseResponse>]
}
