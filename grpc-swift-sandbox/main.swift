//
//  main.swift
//  grpc-swift-sandbox
//
//  Created by wantedly on 2020/09/20.
//  Copyright © 2020 shota.kashihara. All rights reserved.
//

import Foundation

print("Hello, World!")

let user = Users_User.with {
    $0.id = 12345678
    $0.addresses = [
        .with {
            $0.email = "shota@example.com"
            $0.verified = true
        },
        .with {
            $0.email = "kashihara@example.com"
            $0.verified = false
        },
    ]
}

let json = try! user.jsonString()
print(json)
