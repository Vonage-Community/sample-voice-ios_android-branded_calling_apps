//
//  LoginViewController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import Foundation
import UIKit
import Combine


class LoginViewModel {
    @Published var user: Result<User,UserControllerErrors>? =  nil
    @Published var error: Error?

    var cancellables = Set<AnyCancellable>()
    var controller:UserController? {
        didSet(value) {
            value != nil ? bind(controller: value!) : nil
        }
    }
    
    func login(phoneNumber: String, newuser: Bool = false) {
        if (newuser) {
            NetworkController()
                .sendSignupRequest(apiType: SignupAPI(body: LoginRequest(username: phoneNumber)))
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                        self.error = error
                    }
                } receiveValue: { (response: TokenResponse) in
                    self.controller?.login(loginUser: User(username: phoneNumber, token: response.token))
                }.store(in: &cancellables)
        }
        else {
            NetworkController()
                .sendGetTokenRequest(apiType: GetTokenAPI(body: LoginRequest(username: phoneNumber)))
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                        self.error = error
                    }
                } receiveValue: { (response: TokenResponse) in
                    self.controller?.login(loginUser: User(username: phoneNumber, token: response.token))
                }.store(in: &cancellables)
        }
    }
    
    func bind(controller:UserController) {
        controller.user.compactMap{$0}.asResult().map { result in result.map { $0} }
        .assign(to: &self.$user)
    }
}


class LoginViewController: BaseViewController {
    
    var loginLabel: UILabel!
    var phoneNumberLabel: UILabel!
    var phoneNumberInput: UITextField!

    var loginButton: UIButton!
    var signupButton: UIButton!
    
    var viewModel: LoginViewModel? {
        didSet(value) {
            if (self.isViewLoaded) { bind()}
        }
    }
    
    var cancels = Set<AnyCancellable>()

    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white

        loginLabel = UILabel()
        loginLabel.text = "Login"
        loginLabel.font = .systemFont(ofSize: 24)
        
        
        phoneNumberLabel = UILabel()
        phoneNumberLabel.text = "Phone number:"
        phoneNumberLabel.font = .systemFont(ofSize: 14)
        
        phoneNumberInput = UITextField()
        phoneNumberInput.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberInput.placeholder = "6512345678"
        phoneNumberInput.keyboardType = .numberPad
        
        loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.black
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        loginButton.isEnabled = true

        signupButton = UIButton()
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.backgroundColor = UIColor.secondaryLabel
        signupButton.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        signupButton.isEnabled = true
        
        let formContainerView = UIStackView()
        formContainerView.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.axis = .vertical
        formContainerView.distribution = .equalSpacing
        formContainerView.alignment = .fill
        formContainerView.spacing = 20;
        formContainerView.setContentHuggingPriority(.defaultLow, for: .vertical)

        formContainerView.addArrangedSubview(loginLabel)
        formContainerView.addArrangedSubview(phoneNumberLabel)
        formContainerView.addArrangedSubview(phoneNumberInput)
        formContainerView.addArrangedSubview(loginButton)
        formContainerView.addArrangedSubview(signupButton)
        formContainerView.addArrangedSubview(UIView())

        let formContainerParentView = UIView()
        formContainerParentView.addSubview(formContainerView)

        
        let RootView = UIStackView()
        RootView.translatesAutoresizingMaskIntoConstraints = false
        RootView.axis = .vertical
        RootView.distribution = .fill
        RootView.alignment = .fill
        RootView.addArrangedSubview(formContainerParentView)

        view.addSubview(RootView)
        
        NSLayoutConstraint.activate([
            RootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22.5),
            RootView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            RootView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            RootView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            formContainerView.widthAnchor.constraint(equalTo: formContainerParentView.widthAnchor),
            formContainerView.centerXAnchor.constraint(equalTo: formContainerParentView.centerXAnchor),

            //formContainerView.centerYAnchor.constraint(equalTo: formContainerParentView.centerYAnchor),
            
            loginLabel.heightAnchor.constraint(equalToConstant: 45.0),
            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 20.0),
            phoneNumberInput.heightAnchor.constraint(equalToConstant: 45.0),
            loginButton.heightAnchor.constraint(equalToConstant: 45.0),
            signupButton.heightAnchor.constraint(equalToConstant: 45.0),
        ])
        
        viewModel?.$error
            .compactMap { $0?.localizedDescription }
            .receive(on: DispatchQueue.main)
            .assign(to: &($error))
        
        bind()
    }
    
    func bind() {
        
        guard viewModel != nil else {
            return
        }
    }

    @objc func loginButtonPressed(_ sender:UIButton) {
        viewModel?.login(phoneNumber: phoneNumberInput.text ?? "")
    }

    @objc func signupButtonPressed(_ sender:UIButton) {
        viewModel?.login(phoneNumber: phoneNumberInput.text ?? "", newuser: true)
    }
}
