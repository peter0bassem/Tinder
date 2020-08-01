//
//  AgeRangeTableViewCell.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class AgeRangeTableViewCell: UITableViewCell {
    
    static let identifier = "AgeRangeTableViewCell"

    // MARK: - UI Components
    private lazy var minLabel: AgeRangeLabel = {
        let label = AgeRangeLabel()
        label.text = "Min 88"
        return label
    }()
    private lazy var minSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(onMinSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    private lazy var maxLabel: AgeRangeLabel = {
        let label = AgeRangeLabel()
        label.text = "Max 88"
        return label
    }()
    private lazy var maxSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(onMaxSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    // MARK: - Variables
    var minSliderValueChange: ((Int) -> Void)?
    var maxSliderValueChange: ((Int) -> Void)?
    
    var minSeekingRangeValue: Int? {
        didSet {
//            guard let minSeekingRangeValue = minSeekingRangeValue else { return }
            minLabel.text = "Min \(minSeekingRangeValue ?? SettingsTableViewController.defaultMinSeekingAge)"
            minSlider.value = Float(minSeekingRangeValue ?? SettingsTableViewController.defaultMinSeekingAge)
        }
    }
    var maxSeekingRangeValue: Int? {
        didSet {
//            guard let maxSeekingRangeValue = maxSeekingRangeValue else { return }
            maxLabel.text = "Max \(maxSeekingRangeValue ?? SettingsTableViewController.defaultMaxSeekingAge)"
            maxSlider.value = Float(maxSeekingRangeValue ?? SettingsTableViewController.defaultMaxSeekingAge)
        }
    }
    
    // MARK: - UITableViewCell Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let overallStackview = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider])
        ])
        overallStackview.axis = .vertical
        overallStackview.spacing = 16
        addSubview(overallStackview)
        overallStackview.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func evaluateMinMax() {
        let minValue = Int(minSlider.value)
        var maxValue = Int(maxSlider.value)
        maxValue = max(minValue, maxValue)
        maxSlider.value = Float(maxValue)
        minLabel.text = "Min \(minValue)"
        maxLabel.text = "Max \(maxValue)"
        
        minSliderValueChange?(minValue)
        maxSliderValueChange?(maxValue)
    }
    
    // MARK: - Actions
    @objc private func onMinSliderValueChanged(_ sender: UISlider) {
//        minSliderValueChange?(sender.value)
//        minLabel.text = "Min \(Int(sender.value))"
        evaluateMinMax()
    }
    
    @objc private func onMaxSliderValueChanged(_ sender: UISlider) {
//        maxSliderValueChange?(sender.value)
//        maxLabel.text = "Max \(Int(sender.value))"
        evaluateMinMax()
    }
}
