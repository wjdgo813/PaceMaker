//
//  Alertable.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

protocol Alertable where Self: UIViewController {
    func showAlert(title: String, message: String, actions: UIAlertAction...)
    func showAction(title: String?, message: String?, actions: UIAlertAction...)
}

extension Alertable {
    func showAlert(title: String, message: String, actions: UIAlertAction...) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        actions.forEach { alert.addAction($0) }
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAction(title: String? = nil, message: String? = nil, actions: UIAlertAction...) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        actions.forEach { sheet.addAction($0) }
        self.present(sheet, animated: false, completion: nil)
    }
}
