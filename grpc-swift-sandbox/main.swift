import Foundation
import SwiftProtobuf
import GRPC

/// SwiftProtobuf.Message -> String(json)
do {
    let binaryOperation = BinaryOperation.with {
        $0.firstOperand = 3.0
        $0.secondOperand = 2.0
        $0.operation = .add
    }
    var encodingOptions = JSONEncodingOptions()
    // enum を文字列で encoding する
    encodingOptions.alwaysPrintEnumsAsInts = false
    // field name を snake_case にする
    encodingOptions.preserveProtoFieldNames = true
    let json = try binaryOperation.jsonString(options: encodingOptions)
    print(json)
}

/// String(json, enum as Int) -> SwiftProtobuf.Message
do {
    let json = """
    {
        "first_operand": 3.0,
        "second_operand": 2.0,
        "operation": 5,
        "unknown_field": "unknown_field"
    }
    """
    var options = JSONDecodingOptions()
    // JSON に Message に定義されていない field が合っても Error にしない
    options.ignoreUnknownFields = true
    let binaryOperation = try! BinaryOperation(jsonString: json, options: options)
    dump(binaryOperation)
}

/// String(json, enum as String) -> SwiftProtobuf.Message
do {
    let json = """
    {
        "first_operand": 3.0,
        "second_operand": 2.0,
        "operation": "ADD2",
        "unknown_field": "unknown_field"
    }
    """
    do {
        var options = JSONDecodingOptions()
        options.ignoreUnknownFields = true
        _ = try BinaryOperation(jsonString: json, options: options)
    } catch {
        /// raised an error: SwiftProtobuf.JSONDecodingError.unrecognizedEnumValue
        /// enum field に不明な String value が入っていた場合の動作
        /// https://github.com/apple/swift-protobuf/pull/896 で改善されるかも？
        dump(error)
    }
}


extension String {
    func toQueryItems() -> [URLQueryItem] {
        let data = self.data(using: .utf8)!
        let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return dictionary?.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        } ?? []
    }
}

/// SwiftProtobuf.Message

/// grpc-gateway

//let e = Example_User.with {
//    $0.id = UUID().uuidString
//}
//
//var url = URLComponents(string: "https://grpc-gateway-go-sandbox-wnld2gd2oa-an.a.run.app")!
//url.path = "/api/v1/users"
//var encodingOptions = JSONEncodingOptions()
//// enum を文字列で encoding する
//encodingOptions.alwaysPrintEnumsAsInts = false
//// field name を snake_case にする
//encodingOptions.preserveProtoFieldNames = true
////url.queryItems = try! e.jsonString(options: encodingOptions).toQueryItems()
//var request = URLRequest(url: url.url!)
//request.httpMethod = "GET"
//request.addValue("application/json", forHTTPHeaderField: "accept")
//request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//    guard let data = data else { return }
//    do {
//        let json = String(data: data, encoding: .utf8)
//        print(json)
//        let object = try JSONSerialization.jsonObject(with: data, options: [])
//        print(object)
//        // rpc ListUsers(ListUsersRequest) returns (stream User)
//        // ※ stream の場合、JSON のルートが `request` あるいは `error` で wrap される
//        // 更に、stream が3つ連続していた場合は改行で3つのJSON がつながって返ってくるのでそれを parse する必要がある
//        // "{\"result\":{\"id\":\"2ab1d03b-5197-4af3-aaca-519028fb210b\"}}\n{\"result\":{\"id\":\"96c173ab-513d-4a43-ad0f-70195949a426\"}}\n{\"result\":{\"id\":\"c6f2ee3a-89c1-4509-a219-f07c8b443179\"}}\n"
//        var decodingOptions = JSONDecodingOptions()
//        decodingOptions.ignoreUnknownFields = true
//        let response = try Example_User(jsonUTF8Data: data, options: decodingOptions)
//        print(response)
//    } catch let error {
//        print(error)
//    }
//}
//task.resume()
//sleep(10)


let host = "grpc-go-sandbox-wnld2gd2oa-an.a.run.app"
let port = 443

let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
let configuration = ClientConnection.Configuration(
    target: .hostAndPort(host, port),
    eventLoopGroup: group,
    tls: ClientConnection.Configuration.TLS()
)
let connection = ClientConnection(configuration: configuration)
let client = CalculatorClient(channel: connection)
let call = client.calculate(.with {
    $0.firstOperand = 4.0
    $0.secondOperand = 5.0
    $0.operation = .add
})
call.response.whenComplete { result in
    switch result {
    case .success(let response):
        print("success.")
        print("  response: \(response.result)")
    case .failure(let error):
        print("error.")
        print(error)
    }
}
let status = try! call.status.wait()
print(status)
