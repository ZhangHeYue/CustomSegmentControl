//
//  CustomSegmentControl.swift
//  CustomSegmentControl
//
//  Created by Howie.Zhang on 16/12/15.
//  Copyright © 2016年 Howie.Zhang. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import SnapKit

class CustomSegmentControl: UIView {
    
    typealias TapClosureType = (() -> ())
    fileprivate var buttons = [UIButton]()
    fileprivate var closures = [TapClosureType]()
    fileprivate var cocoaActions = [CocoaAction<UIButton>]()
    
    var buttonHeight: CGFloat = 30 {
        didSet { update(height: buttonHeight )}
    }
    var buttonWidth: CGFloat = 200 {
        didSet { update(width: buttonWidth )}
    }
    var buttonSpace: CGFloat = 1 {
        didSet { update(buttonSpace: buttonSpace )}
    }
    var font = UIFont.systemFont(ofSize: 15) {
        didSet { update(font: font )}
    }
    
    //MARK: - 初始化
    init(number: Int) {
        super.init(frame: CGRect.zero)
        for _ in 0..<number {
            let button = getDefaultButton()
            buttons.append(button)
        }
        for _ in 0..<number {
            let closure = {() -> () in }
            closures.append(closure)
        }
        for _ in 0..<number {
            let cocoaAction: CocoaAction<UIButton> = CocoaAction(defaultAction() , input: ())
            cocoaActions.append(cocoaAction)
        }
        
        addSubButton()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getDefaultButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.titleLabel?.font = font
        return button
    }
    
    private func defaultAction() -> Action<(), (), NoError> {
        return Action {
            return SignalProducer<(), NoError> { observe, disposable in
                observe.send(value: ())
                observe.sendCompleted()
            }
        }
    }
    
    private func addSubButton() {
        for button in buttons {
            addSubview(button)
        }
    }
    
    private func layout() {
        guard buttons.count > 1 else {
            return
        }
        buttons[0].snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
            make.top.bottom.equalTo(0)
            make.left.equalTo(0)
        }
        for index in 1..<buttons.count - 1{
            buttons[index].snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
                make.height.equalTo(buttonHeight)
                make.top.bottom.equalTo(0)
                make.left.equalTo(buttons[index - 1].snp.right).offset(buttonSpace)
            }
        }
        buttons[buttons.count - 1].snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
            make.top.bottom.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(buttons[buttons.count - 2].snp.right).offset(buttonSpace)
        }
    }
}
//MARK: - 修改属性
extension CustomSegmentControl {
    
    func set(backgroundColor: UIColor, forState state: UIControlState, index: Int? = nil) {
        let backgroundImage = UIImage(color: backgroundColor, size: CGSize(width: buttonWidth, height: buttonHeight))
        guard let index = index else {
            for button in buttons {
                button.setBackgroundImage(backgroundImage, for: state)
            }
            return
        }
        buttons[index].setBackgroundImage(backgroundImage, for: state)
    }
    
    func set(attributedTitle: NSAttributedString, forState state: UIControlState, index: Int? = nil) {
        guard let index = index else {
            for button in buttons {
                button.setAttributedTitle(attributedTitle, for: state)
            }
            return
        }
        buttons[index].setAttributedTitle(attributedTitle, for: state)
    }
    
    func set(image: UIImage?, forState state: UIControlState, index: Int? = nil) {
        guard let index = index else {
            for button in buttons {
                button.setImage(image, for: state)
            }
            return
        }
        buttons[index].setImage(image, for: state)
    }
    
    func set(title: String, forState state: UIControlState, index: Int? = nil) {
        guard let index = index else {
            for button in buttons {
                button.setTitle(title, for: state)
            }
            return
        }
        buttons[index].setTitle(title, for: state)
    }
    
    func set(titleColor: UIColor, forState state: UIControlState, index: Int? = nil) {
        guard let index = index else {
            for button in buttons {
                button.setTitleColor(titleColor, for: state)
            }
            return
        }
        buttons[index].setTitleColor(titleColor, for: state)
    }
    
    func set(selectedForIndex index: Int) {
        guard index < buttons.count else {
            return
        }
        for button in buttons {
            button.isSelected = false
        }
        buttons[index].isSelected = true
    }
    
}
//MARK: - 修改约束
extension CustomSegmentControl {
    
    fileprivate func update(height: CGFloat) {
        for button in buttons {
            button.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }
    }
    
    fileprivate func update(width: CGFloat) {
        for button in buttons {
            button.snp.updateConstraints { (make) in
                make.width.equalTo(width)
            }
        }
    }
    
    fileprivate func update(buttonSpace: CGFloat) {
        for index in 1..<buttons.count - 1 {
            buttons[index].snp.updateConstraints { (make) in
                make.left.equalTo(buttonSpace)
            }
        }
    }
    
    fileprivate func update(font: UIFont) {
        for button in buttons {
            button.titleLabel?.font = font
        }
    }
    
}
//MARK: - 添加方法
extension CustomSegmentControl {
    
    func add(forIndex index: Int, closure: @escaping (TapClosureType)) {
        guard index < buttons.count else {
            return
        }
        closures[index] = closure
        cocoaActions[index] = getCocoaAction(action: getAction(index: index))
        buttons[index].addTarget(cocoaActions[index], action: CocoaAction<UIButton>.selector, for: .touchUpInside)
    }
    
    private func getCocoaAction(action: Action<(), (), NoError>) -> CocoaAction<UIButton> {
        return CocoaAction(action, input: ())
    }
    
    private func getAction(index: Int) -> Action<(), (), NoError> {
        return Action {
            return SignalProducer<(), NoError> { [weak self] observe, disposable in
                guard let strongSelf = self else {
                    observe.sendCompleted()
                    return
                }
                guard index < strongSelf.closures.count && !strongSelf.buttons[index].isSelected else {
                    observe.sendCompleted()
                    return
                }
                strongSelf.set(selectedForIndex: index)
                strongSelf.closures[index]()
                observe.send(value: ())
                observe.sendCompleted()
            }
        }
    }
}
