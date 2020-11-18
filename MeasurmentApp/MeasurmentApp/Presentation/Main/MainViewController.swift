//
//  MainViewController.swift
//  MeasurmentApp
//
//  Created by Александр Крайнов on 18.11.2020.
//

import UIKit

class MainViewController: UIViewController {
    private var data = [Measurement]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let url = URL(string: "https://alfalfa-project.herokuapp.com/api/\(UserDefaults.standard.value(forKey: "login") ?? "")/measurements")!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var helloLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadData()
        helloLabel.text = "Журнал температуры пользователя \(UserDefaults.standard.value(forKey: "login") ?? "")"
    }

    private func loadData() {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(UserDefaults.standard.value(forKey: "token") as? String ?? "", forHTTPHeaderField: "Bearer")
        URLSession.shared.dataTask(with: request) { data, response, error  in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            guard let decodedData = try? decoder.decode([Measurement].self, from: data) else {
                return
            }
            self.data = decodedData
        }
        .resume()
    }

    @IBAction private func addPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Добавление измерения вручную", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Температура"
        }
        let add = UIAlertAction(title: "Добавить", style: .default) {_ in
            guard let textField = alert.textFields?[0] as? UITextField else {return}
            var request = URLRequest(url: self.url)
            let formatter = ISO8601DateFormatter()
            let iso = formatter.string(from: Date())
            let json: [String: Any] = [
                "temperature": Double(textField.text ?? "") ?? 0.0,
                "timestamp": iso
            ]
            request.setValue(UserDefaults.standard.value(forKey: "token") as? String ?? "", forHTTPHeaderField: "Bearer")
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error  in
                print(response)
                DispatchQueue.main.async {
                    self.loadData()
                }
            }
            .resume()
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(add)
        self.present(alert, animated: true)
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurmentCell") as? MeasurmentCell else {
            return UITableViewCell()
        }
        cell.setup(with: data[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    
}
