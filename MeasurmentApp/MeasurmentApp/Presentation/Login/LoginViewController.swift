//
//  ViewController.swift
//  MeasurmentApp
//
//  Created by Александр Крайнов on 18.11.2020.
//

import UIKit

class LoginViewController: UIViewController {
    private let urlAuth = URL(string: "https://alfalfa-project.herokuapp.com/api/auth")!
    @IBOutlet private var loginTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupTextFields() {
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }

    @objc private func dismissKeyboard() {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        let login = loginTextField.text
        let json: [String: Any] = [
            "login": login,
            "password": passwordTextField.text
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: urlAuth)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error  in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.presentAlert()
                    }
                } else {
                    if let data = data {
                        let token = String(decoding: data, as: UTF8.self)
                        UserDefaults.standard.setValue(token, forKey: "token")
                        UserDefaults.standard.setValue(login, forKey: "login")
                    }
                    DispatchQueue.main.async {
                        guard let main = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else { return }
                        main.modalPresentationStyle = .fullScreen
                        self.present(main, animated: true)
                    }
                }
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.presentAlert()
                }
            }
        }
        .resume()
    }

    @IBAction private func regiserButtonPressed(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateInitialViewController() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Проверьте данные и попробуйте снова", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Хорошо", style: .cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
