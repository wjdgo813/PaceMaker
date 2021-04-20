//
//  TableView+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/20.
//

import UIKit

public protocol CellRegister {
    static var nibName: String { get }
}

public protocol CellFactory: class {
    static var identifier: String { get }
    associatedtype Dependency
    func bindData(value: Dependency)
}

extension UITableView {
    public func register<T>(_ config: T.Type) where T: CellRegister & CellFactory {
        self.register(UINib(nibName: config.nibName, bundle: Bundle(for: config)), forCellReuseIdentifier: config.identifier)
    }
    
    public func getCell<Cell>(value: Cell.Type, indexPath: IndexPath, data: Cell.Dependency) -> Cell where Cell: CellFactory {
        let cell = self.dequeueReusableCell(withIdentifier: value.identifier, for: indexPath) as! Cell
        cell.bindData(value: data)
        return cell
    }
    
    public func getCell<Cell>(value: Cell.Type, data: Cell.Dependency) -> Cell where Cell: CellFactory {
        let cell = self.dequeueReusableCell(withIdentifier: value.identifier) as! Cell
        cell.bindData(value: data)
        return cell
    }
}
