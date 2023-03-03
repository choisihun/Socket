//
//  Signup.swift
//  Stompsocket
//
//  Created by 최시훈 on 2023/02/27.
//

import Foundation

struct SignUpData: Decodable, Hashable {
    let status: Int
    let message: String
    let data: LoginDatas
}

struct SignUpDatas: Decodable, Hashable {
    let token: String!
}
