//
//  Configuration.swift
//  VonageSDKClientVOIPExample
//
//  Created by Mehboob Alam on 27.06.23.
//
import Foundation

private var backendServer = ""

enum Configuration {

    static func signupUrl() -> URL {
        let urlString = "\(backendServer)/user"
        guard let url = URL(string: urlString) else {
            fatalError("Missing Sign Up URL");
        }
        return url
    }

    static func getTokenUrl() -> URL {
        let urlString = "\(backendServer)/token"
        guard let url = URL(string: urlString) else {
            fatalError("Missing Get Token URL");
        }
        return url
    }

    static func getBrandsUrl() -> URL {
        let urlString = "\(backendServer)/brands"
        guard let url = URL(string: urlString) else {
            fatalError("Missing Get Brands URL");
        }
        return url
    }
    
    static let defaultToken : String = ""
}
