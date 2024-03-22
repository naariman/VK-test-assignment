//
//  DashboardViewController.swift
//  VK Test Assignment
//
//  Created Nariman on 22.03.2024.
//  Copyright © 2024 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Dastan Makhutov @mchutov
//

import UIKit

final class DashboardViewController: UIViewController, 
                                     DashboardViewProtocol {
	var presenter: DashboardPresenterProtocol?

	override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension DashboardViewController {
    func setupUI() {
        view.backgroundColor = .white
    }
}
