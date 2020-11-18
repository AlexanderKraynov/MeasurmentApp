//
//  RegistrationViewController.swift
//  MeasurmentApp
//
//  Created by Александр Крайнов on 18.11.2020.
//

import UIKit

class RegistrationViewController: UIViewController {
    private let urlRegister = URL(string: "https://alfalfa-project.herokuapp.com/api/register")!
    @IBOutlet private var loginTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var supervisorTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Регистрация"
        setupTextFields()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupTextFields() {
        loginTextField.delegate = self
        passwordTextField.delegate = self
        supervisorTextField.delegate = self
    }

    @objc private func dismissKeyboard() {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        supervisorTextField.resignFirstResponder()
    }

    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        let json: [String: Any] = [
            "login": loginTextField.text,
            "password": passwordTextField.text,
            "supervisors": [supervisorTextField.text]
        ]
        print(supervisorTextField.text)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: urlRegister)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error  in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.presentAlert()
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Пользователь зарегистрирован", message: "", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Хорошо", style: .default) {_ in 
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true)
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

    private func presentAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Проверьте данные и попробуйте снова", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Хорошо", style: .cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
