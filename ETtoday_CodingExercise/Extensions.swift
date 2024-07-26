//
//  Extensions.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit

extension UIViewController {
    func tapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
