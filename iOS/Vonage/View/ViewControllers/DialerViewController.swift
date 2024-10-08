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
    
    var dropDownButton: UIButton!
    var dropDownList: UIStackView!
    var dropDownChildren: [UIMenuElement] = []
    var brandLabel: UILabel!
    var brands: [Brand] = []

    var cancellables = Set<AnyCancellable>()
    
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
        
        brandLabel = UILabel()
        brandLabel.font = .systemFont(ofSize: 14)
        brandLabel.text = "Brand:"

        dropDownList = UIStackView()
        dropDownList.axis = .vertical
        dropDownList.distribution = .fill
        dropDownList.alignment = .fill
        dropDownList.spacing = 5
        dropDownList.translatesAutoresizingMaskIntoConstraints = false

        let callCC = UIStackView()
        callCC.axis = .vertical
        callCC.distribution = .fill
        callCC.alignment = .fill
        callCC.spacing = 30
        callCC.translatesAutoresizingMaskIntoConstraints = false

        callButton = UIButton()
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("Call", for: .normal)
        callButton.tintColor = .green
        callButton.addTarget(self, action: #selector(callButtonPressed), for: .touchUpInside)

        callCC.addArrangedSubview(dropDownList)
        callCC.addArrangedSubview(callButton)

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
        stackView.addArrangedSubview(callCC)
        view.addSubview(stackView)

        NSLayoutConstraint.activate(onlineIconConstraints + vonageLogoImageViewConstraints + [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (brands.count == 0) {
            NetworkController()
                .sendGetBrandsRequest(apiType: CodeBrandAPI())
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                    }
                } receiveValue: { (response: [Brand]) in
                    self.brands = response
                    self.reloadBrandsDropdown()
                }.store(in: &cancellables)
        }
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
    
    private func reloadBrandsDropdown() {
        // Drop Down List
        dropDownButton = UIButton(primaryAction: nil)
        dropDownButton.setTitleColor(.black, for: .normal)
        dropDownButton.layer.borderColor = CGColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0)
        dropDownButton.layer.borderWidth = 1
        dropDownButton.layer.cornerRadius = 4
        dropDownButton.height(constant: 48)
        dropDownButton.titleLabel?.font = .systemFont(ofSize: 20)

        self.viewModel?.callee = brands.count > 0 ? brands[0].brand : ""
        for brand in brands {
            dropDownChildren.append(UIAction(title: brand.brand, handler: { (action: UIAction) in
                self.viewModel?.callee = action.title
            }))
        }

        dropDownButton.translatesAutoresizingMaskIntoConstraints = false
        dropDownButton.menu = UIMenu(options: .displayInline, children: dropDownChildren)
        dropDownButton.showsMenuAsPrimaryAction = true
        dropDownButton.changesSelectionAsPrimaryAction = true

        dropDownList.addArrangedSubview(UIView()) // Spacer
        dropDownList.addArrangedSubview(brandLabel)
        dropDownList.addArrangedSubview(dropDownButton)
    }

    @objc func callButtonPressed(_ sender:UIButton) {
        if (viewModel?.callee == "" ) {
            return
        }
        viewModel?.createOutboundCall()
    }
}
