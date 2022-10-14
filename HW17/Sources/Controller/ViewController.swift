//
//  ViewController.swift
//  HW17
//
//  Created by Виктор Басиев on 12.10.2022.
//

import UIKit

class ViewController: UIViewController {
    //    MARK: - Outlets
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var randomPass: UIButton!
    @IBOutlet weak var changeColor: UIButton!
    @IBOutlet weak var hackPass: UIButton!
    @IBOutlet weak var labelPass: UILabel!
    @IBOutlet weak var textFieldPass: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let allowedCharacters: [String] = String().printable.map { String($0) }
    var password: String = ""
    var isHacking = false
    let queue = DispatchQueue(label: "brute", qos: .utility)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPass.delegate = self
        setupView()
    }
    
    //    MARK: - Action
    @IBAction func stopAction(_ sender: Any) {
            isHacking = false
        DispatchQueue.main.async {
            self.textFieldPass.text = self.password
            self.labelPass.text = "Your password: " + "\(self.password)"
            self.textFieldPass.isSecureTextEntry = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func randomAction(_ sender: Any) {
        hackPass.isHidden = false
        textFieldPass.clearButtonMode = .always
        password = generatePassword()
        textFieldPass.text = password
        self.textFieldPass.isSecureTextEntry = true
    }
    
    @IBAction func hackAction(_ sender: Any) {
        queue.async {
            self.bruteForce(passwordToUnlock: self.password)
        }
    }
    
    @IBAction func changeColorAction(_ sender: Any) {
        changingColor.toggle()
    }
    
    // MARK: - Functions
    
    func bruteForce(passwordToUnlock: String) {
        
        var password = String()
        isHacking = true
        
        let hackPassword = DispatchWorkItem {
            self.labelPass.text = "Hacking... " + "\(password)"
            self.textFieldPass.isSecureTextEntry = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        let resultPassword = DispatchWorkItem {
            self.labelPass.text = "Your password: " + "\(password)"
            self.textFieldPass.isSecureTextEntry = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
        while password != passwordToUnlock {
            password = generateBruteForce(password, fromArray: allowedCharacters)
            if isHacking {
                DispatchQueue.main.async(execute: hackPassword)
            } else {
                break
            }
            print(password)
        }
        if isHacking {
            DispatchQueue.main.async(execute: resultPassword)
        }
    }
    
    func generatePassword() -> String {
        var password = String()
        for _ in 1...3 {
            let character = allowedCharacters[Int.random(in: 0...allowedCharacters.count - 1)]
            password += character
        }
        return password
    }
    
    var changingColor: Bool = false {
        didSet {
            if changingColor {
                self.view.backgroundColor = .systemGray
                self.labelPass.textColor = .white
                self.activityIndicator.color = .white
            } else {
                self.view.backgroundColor = .white
                self.labelPass.textColor = .black
                self.activityIndicator.color = .black
            }
        }
    }
    
    private func setupView() {
        activityIndicator.isHidden = true
    }
}

// MARK: - Extension

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let rangeText = Range(range, in: text) {
            let updataText = text.replacingCharacters(in: rangeText, with: string)
            password = updataText
        }
        textFieldPass.isSecureTextEntry = true
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldPass.clearButtonMode = .always
        hackPass.isHidden = false
        return true
    }
}
