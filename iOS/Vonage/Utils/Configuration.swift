//
//  Configuration.swift
//  VonageSDKClientVOIPExample
//
//  Created by Mehboob Alam on 27.06.23.
//
import Foundation

private var backendServer = ""

enum Configuration {

    static func getLoginUrl() -> URL {
        let urlString = "\(backendServer)/user"
        guard let url = URL(string: urlString) else {
            fatalError("Missing Login URL");
        }
        return url
    }

    static func getRefreshTokenUrl() -> URL {
        let urlString = "\(backendServer)/user"
        guard let url = URL(string: urlString) else {
            fatalError("Missing Refresh Token URL");
        }
        return url
    }
    
    static let defaultToken : String = ""
}
