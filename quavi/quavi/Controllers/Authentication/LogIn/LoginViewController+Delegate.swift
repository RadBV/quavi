//
//  LoginViewController+Delegate.swift
//  quavi
//
//  Created by Mr Wonderful on 3/26/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
