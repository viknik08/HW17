//
//  ViewController.swift
//  HW17
//
//  Created by Виктор Басиев on 12.10.2022.
//

import UIKit

class ViewController: UIViewController {
    //    MARK: - Outlets
    
    @IBOutlet weak var randomPass: UIButton!
    @IBOutlet weak var hackPass: UIButton!
    @IBOutlet weak var changeColor: UIButton!
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
        setupView()
    }
    
    //    MARK: - Action

    @IBAction func randomAction(_ sender: Any) {
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
            }
            print(password)
        }
        DispatchQueue.main.async(execute: resultPassword)
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

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }
    
    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
    : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string
    
    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
        
        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    return str
}
