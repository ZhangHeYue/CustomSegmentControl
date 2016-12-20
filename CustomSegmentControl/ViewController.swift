//
//  ViewController.swift
//  CustomSegmentControl
//
//  Created by Howie.Zhang on 16/12/20.
//  Copyright © 2016年 Howie.Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let segmentControl = CustomSegmentControl(number: 2)
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        segmentControl.tintColor = UIColor.clear
        segmentControl.set(backgroundColor: UIColor.gray, forState: .normal)
        segmentControl.set(backgroundColor: UIColor.purple, forState: .selected)
        segmentControl.set(titleColor: UIColor.gray, forState: .normal)
        segmentControl.set(titleColor: UIColor.white, forState: .selected)
        segmentControl.font = UIFont.systemFont(ofSize: 15)
        segmentControl.buttonWidth = 150
        segmentControl.clipsToBounds = true
        segmentControl.layer.cornerRadius = 3
        segmentControl.layer.borderWidth = 1
        segmentControl.layer.borderColor = UIColor.clear.cgColor
        segmentControl.set(selectedForIndex: 0)
        segmentControl.set(image: UIImage(named: "history_sms_active"), forState: .selected, index: 0)
        segmentControl.set(image: UIImage(named: "history_sms_inactive"), forState: .normal, index: 0)
        segmentControl.set(image: UIImage(named: "history_call_active"), forState: .selected, index: 1)
        segmentControl.set(image: UIImage(named: "history_call_inactive"), forState: .normal, index: 1)
        segmentControl.add(forIndex: 0) { [weak self] in
            self?.setLabel(result: "短信")
        }
        segmentControl.add(forIndex: 1) { [weak self] in
            self?.setLabel(result: "电话")
        }
        view.addSubview(segmentControl)
        
        resultLabel.textColor = UIColor.brown
        resultLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(resultLabel)
    }
    
    private func layout() {
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.centerX.equalTo(self.view)
        }
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(200)
            make.centerX.equalTo(segmentControl.snp.centerX)
        }
    }

    private func setLabel(result: String) {
        resultLabel.text = result
    }
}
