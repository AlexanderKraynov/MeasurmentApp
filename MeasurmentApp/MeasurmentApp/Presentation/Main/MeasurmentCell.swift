//
//  MeasurmentCell.swift
//  MeasurmentApp
//
//  Created by Александр Крайнов on 18.11.2020.
//

import UIKit

class MeasurmentCell: UITableViewCell {
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    func setup(with measurment: Measurement) {
        if abs(measurment.temperature - 36.6) < 2 {
            temperatureLabel.textColor = .green
        } else {
            temperatureLabel.textColor = .red
        }
        let formatter = ISO8601DateFormatter()
        temperatureLabel.text = String(measurment.temperature)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let date = formatter.date(from: measurment.timestamp) else { return }
        dateLabel.text = dateFormatter.string(from: date)
    }
}
