//
//  Alertable.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

protocol Alertable where Self: UIViewController {
    func showAlert(title: String, message: String, actions: UIAlertAction...)
}

extension Alertable {
    func showAlert(title: String, message: String, actions: UIAlertAction...) {
        let alert = UIAlertController(title: "잠시 정지하고 있어요", message: "달리기를 종료할까요?", preferredStyle: UIAlertController.Style.alert)
        actions.forEach { alert.addAction($0) }
        self.present(alert, animated: false, completion: nil)
    }
}
