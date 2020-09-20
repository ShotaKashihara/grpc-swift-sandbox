# grpc-swift-sandbox

## Setup

```bash
git clone git@github.com:grpc/grpc-swift.git
cd grpc-swift
make plugins
cp protoc-gen-swift protoc-gen-swiftgrpc /usr/local/bin
```
you can run code generate script.

```
./script/gen_swift
```

## 

1. Create a macOS Command Line Application
1. Add `generated` directory to this project.
1. Add `https://github.com/grpc/grpc-swift.git, from 1.0.0-alpha.12 vresion` to Package Dependencies.
