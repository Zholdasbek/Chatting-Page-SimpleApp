//
//  KeyboardObserving.swift
//  FinalProject
//
//  Created by Zholdas on 4/9/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

protocol KeyboardObserving: class {
    func addObservers()
    func removeObservers()
    func keyboardWillShow(withHeight height: CGFloat)
    func keyboardWillHide()
}

extension KeyboardObserving {
    
    func addObservers(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let keyboardSizeValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else{
                return
            }
            let keyboardSize = keyboardSizeValue.cgRectValue
            
            
            if (Device.IS_IPHONE_X || Device.IS_IPHONE_XS_MAX){
                //iPhone X-XR-XS-XS_max
                self?.keyboardWillShow(withHeight: -keyboardSize.height + 33)
            }
            else {
                //iPhone 6-7-8 +
                self?.keyboardWillShow(withHeight: -keyboardSize.height)
            }
            
            
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.keyboardWillHide()
        }
    }
    func removeObservers(){
        NotificationCenter.default.removeObserver(self)
    }
    
}
