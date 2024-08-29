//
//  UserController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import Foundation
import Combine
 
typealias UserToken = String

enum UserControllerErrors:Error {
    case InvalidCredentials
    case unknown
}



class UserController: NSObject {
    
    var user =  PassthroughSubject<(User)?,UserControllerErrors>()
    var cancellables = Set<AnyCancellable>()

    func login(loginUser: User) {
        UserDefaults.standard.setValue(loginUser.username, forKey: "USER_NAME")
        UserDefaults.standard.setValue(loginUser.token, forKey: "TOKEN")
        user.send(loginUser)

    }
    
    func restoreUser(refreshToken: Bool = false) {
          guard let token =  UserDefaults.standard.string(forKey: "TOKEN"),
           let username =  UserDefaults.standard.string(forKey: "USER_NAME")else {
              user.send(nil)
            return
          }
        if (!refreshToken) {
            login(loginUser: User(username: username, token: token))
            return
          }
              
              // refresh token
          NetworkController()
              .sendGetCredentialRequest(apiType: CodeLoginAPI(body: LoginRequest(username: username)))
              .sink { completion in
                  if case .failure(let error) = completion {
                      print(error)
                  }
              } receiveValue: { (response: TokenResponse) in
                  self.login(loginUser: User(username: username, token: response.token))
              }.store(in: &cancellables)
    }
}
