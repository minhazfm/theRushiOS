//
//  LoginViewController.swift
//  theRush
//
//  Created by Minhaz Mohammad on 8/28/19.
//  Copyright © 2019 SMPL Inc. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class LoginViewController: UIViewController, ViewModelAttachingProtocol {

    // MARK: - Conformance to ViewModelAttachingProtocol
    var bindings: LoginViewModel.Bindings {
        return LoginViewModel.Bindings(logInButtonTap: logInButton.rx.tap.asObservable())
    }
    
    var viewModel: Attachable<LoginViewModel>!
    
    
    // MARK: - Logic variables
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - UI variables
    fileprivate var areConstraintsSet: Bool = false
    
    fileprivate lazy var logInButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 18.0)
        button.titleLabel?.textColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func configureReactiveBinding(viewModel: LoginViewModel) -> LoginViewModel {
        return viewModel
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !areConstraintsSet {
            areConstraintsSet = true
            configureConstraints()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureAppearance()
    }

    deinit {
        print("LoginViewController deinit")
        viewModel = nil
    }
    
}

extension LoginViewController {
    
    fileprivate func configureAppearance() {
        view.backgroundColor = .orange
        view.addSubview(logInButton)
    }
    
    fileprivate func configureConstraints() {
        NSLayoutConstraint.activate([
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logInButton.widthAnchor.constraint(equalToConstant: 60),
            logInButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}
