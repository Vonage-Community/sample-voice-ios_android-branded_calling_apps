//
//  NetworkController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Mehboob Alam on 27.06.23.
//
import Foundation

import Foundation
import Combine

/// API TYPE
protocol ApiType {
    var url: URL {get}
    var method: String {get}
    var headers: [String: String] {get}
    var body: Encodable? {get}
    var query: String? {get}
}

extension ApiType {
    var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }
}

/// LOGIN VIA CODE
struct SignupAPI: ApiType {
    var url: URL = Configuration.signupUrl()
    var method = "POST"
    var body: (any Encodable)?
    var query: String?


    init(body: LoginRequest) {
        self.body = body
    }
}

struct GetTokenAPI: ApiType {
    var url: URL = Configuration.getTokenUrl()
    var method = "GET"
    var query: String?
    var body: (any Encodable)?

    init(body: LoginRequest) {
        self.query = body.username
    }
}

struct CodeBrandAPI {
    var url: URL = Configuration.getBrandsUrl()
    var method: String = "GET"
    var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }
}

class NetworkController {
    func sendSignupRequest<type: Decodable>(apiType: any ApiType) -> AnyPublisher<type, Error> {
        var request = URLRequest(url: apiType.url)
        request.httpMethod = apiType.method
        request.allHTTPHeaderFields = apiType.headers
        do {
            if let body = apiType.body {
                request.httpBody = try JSONEncoder().encode(body)
            }
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in

                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    let error = try? JSONSerialization.jsonObject(with: data)
                    print(error ?? "unknown")
                    throw URLError(.badServerResponse)
                }
                if data.isEmpty {
                    return Data()
                }
                return data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func sendGetTokenRequest<type: Decodable>(apiType: any ApiType) -> AnyPublisher<type, Error> {

        var components = URLComponents(url: apiType.url, resolvingAgainstBaseURL: true)
        let query = URLQueryItem(name: "username", value: apiType.query)
        components?.queryItems = [query]
        
        var request = URLRequest(url: components!.url!)
        request.httpMethod = apiType.method
        request.allHTTPHeaderFields = apiType.headers

        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in

                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    let error = try? JSONSerialization.jsonObject(with: data)
                    print(error ?? "unknown")
                    throw URLError(.badServerResponse)
                }
                if data.isEmpty {
                    return Data()
                }
                return data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func sendGetBrandsRequest<type: Decodable>(apiType: CodeBrandAPI) -> AnyPublisher<type, Error> {

        var request = URLRequest(url: apiType.url)
        request.httpMethod = "GET"
        request.httpMethod = apiType.method
        request.allHTTPHeaderFields = apiType.headers

        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in

                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    let error = try? JSONSerialization.jsonObject(with: data)
                    print(error ?? "unknown")
                    throw URLError(.badServerResponse)
                }
                if data.isEmpty {
                    return Data()
                }
                return data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

/// NetworkData Models
struct LoginRequest: Encodable {
    let username: String
}

struct TokenResponse: Decodable {
    let token: String
}
