//
//  DataCollectionRouter.swift
//  VK Test Assignment
//
//  Created Nariman on 22.03.2024.
//  Copyright © 2024 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Dastan Makhutov @mchutov
//

import UIKit

final class DataCollectionRouter {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        // Change to get view from storyboard if not using progammatic UI
        let view = DataCollectionViewController()
        let interactor = DataCollectionInteractor()
        let router = DataCollectionRouter()
        let presenter = DataCollectionPresenter(interface: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}

extension DataCollectionRouter: DataCollectionWireframeProtocol {
    func routeToDashboard(with model: UserInputModel) {
        let vc = DashboardRouter.createModule(with: model)
        UIHelper.setRoot(vc)
    }
}
