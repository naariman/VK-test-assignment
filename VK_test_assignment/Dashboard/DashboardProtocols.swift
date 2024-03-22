//
//  DashboardProtocols.swift
//  VK Test Assignment
//
//  Created Nariman on 22.03.2024.
//  Copyright © 2024 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Dastan Makhutov @mchutov
//

import Foundation

//MARK: Wireframe -
protocol DashboardWireframeProtocol: AnyObject {
}
//MARK: Presenter -
protocol DashboardPresenterProtocol: AnyObject {
    func viewDidLoad()
    var entities: [EntityViewModel] { get set }
}

//MARK: Interactor -
protocol DashboardInteractorProtocol: AnyObject {
  var presenter: DashboardPresenterProtocol?  { get set }
}

//MARK: View -
protocol DashboardViewProtocol: AnyObject {
    var presenter: DashboardPresenterProtocol?  { get set }
    func configure(with model: EpidemiologicalSpreadModel)
}
