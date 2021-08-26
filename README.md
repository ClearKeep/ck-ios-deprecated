# ck-ios
iOS client with end to end encryption messaging

# Prerequisites
* Xcode 12.0.1
* Swift-protobuf version 1.12.0
* grpc-swift commit: e2e138df61dcbfc2dc1cf284fdab6f983539ab48

## Build & Run

* Git clone source code
* Pod update 
* Using Xcode import this project
* Tab run app (cmd + R)
* Generate protobuf, version generate match with version at xcode.
  mkdir protobuf
  protoc *.proto \
    --proto_path=. \
    --plugin={PATH-TO-SWIFT-PROTOBUF}/swift-protobuf/.build/release/protoc-gen-swift \
    --swift_opt=Visibility=Public \
    --swift_out=protobuf \
    --plugin={PATH-TO-GRPC-SWIFT}/grpc-swift/.build/release/protoc-gen-grpc-swift \
    --grpc-swift_opt=Visibility=Public \
    --grpc-swift_out=protobuf

## Usage
