//
//  DialerViewController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import UIKit
import Combine
import SwiftUI

enum callType: Int {
    case phone = 0, app = 1
}

class DialerViewModel: ObservableObject{
    @Published var callee: String = ""
    @Published var connection: Connection = .connected
    
    var controller: CallController?
    var userController: UserController?
    
    func createOutboundCall(){
        // TODO: how to handle Errors?
        // via returned channel ?
        // if there is an username it will have the priority
        let _ = controller?.startOutboundCall(["to": callee ])

    }
}


// MARK: UI

class DialerViewController: UIViewController {
    var callButton: UIButton!

    var userName: UILabel!

    var onlineIcon: UIView!
    
    var viewModel: DialerViewModel? = nil
    var cancels = Set<AnyCancellable>()
    
    var userController: UserController?
    
    
    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        
        let online = UIStackView()
        online.axis = .horizontal
        online.distribution = .fill
        online.alignment = .center
        online.spacing = 5
        online.setContentHuggingPriority(.defaultHigh, for: .vertical)
        online.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let onlineLabel = UILabel()
        onlineLabel.text = "Connection:"
        onlineIcon = UIButton()
        onlineIcon.backgroundColor = .systemRed
        onlineIcon.layer.cornerRadius = 10
        onlineIcon.clipsToBounds = true
        let onlineIconConstraints = [
            onlineIcon.widthAnchor.constraint(equalToConstant: 20.0),
            onlineIcon.heightAnchor.constraint(equalTo: onlineIcon.widthAnchor)
        ]
        online.addArrangedSubview(UIView()) // Spacer
        online.addArrangedSubview(onlineLabel)
        online.addArrangedSubview(onlineIcon)
        
        userName = UILabel()
        userName.font = .systemFont(ofSize: 18)

        userName.text = UserDefaults.standard.string(forKey: "USER_NAME")!
        
        // Vonage Image
        let vonageLogoImageName = "vonage-image"
        let vonageLogoImage = UIImage(named: vonageLogoImageName)
        let vonageLogoImageView = UIImageView(image: vonageLogoImage!)
        vonageLogoImageView.contentMode = .scaleAspectFit
        vonageLogoImageView.translatesAutoresizingMaskIntoConstraints = false

        let vonageLogoImageViewConstraints = [
            vonageLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vonageLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            vonageLogoImageView.heightAnchor.constraint(equalToConstant: 200),
        ]
        
        self.viewModel?.callee = "contact center"
        callButton = UIButton()
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("Call", for: .normal)
        callButton.tintColor = .green
        callButton.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)
        
        // MARK: RootView
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10;
        stackView.addArrangedSubview(online)
        
        stackView.addArrangedSubview(userName)
        stackView.addArrangedSubview(UIView()) // spacer
        stackView.addArrangedSubview(vonageLogoImageView)
        stackView.addArrangedSubview(callButton)
        view.addSubview(stackView)

        NSLayoutConstraint.activate(onlineIconConstraints + vonageLogoImageViewConstraints + [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let viewModel else {
            return
        }
        
        viewModel.$connection
            .receive(on: RunLoop.main)
            .sink { (connectionState) in
                switch (connectionState) {
                case .connected:
                    self.callButton.isEnabled = true
                    self.callButton.backgroundColor = UIColor.systemGreen
                    self.onlineIcon.backgroundColor = UIColor.systemGreen
                case .reconnecting:
                    self.callButton.isEnabled = true
                    self.onlineIcon.backgroundColor = UIColor.systemOrange
                default:
                    self.callButton.isEnabled = false
                    self.callButton.backgroundColor = UIColor.systemGray
                    self.onlineIcon.backgroundColor = UIColor.red

                }
                self.onlineIcon.setNeedsDisplay()

        }
        .store(in: &cancels)
    }
    
    @objc func callButtonPressed(_ sender:UIButton) {
        viewModel?.createOutboundCall()
    }
}
