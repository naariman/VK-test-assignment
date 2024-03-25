//
//  DashboardPresenter.swift
//  VK Test Assignment
//
//  Created Nariman on 22.03.2024.
//  Copyright © 2024 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Dastan Makhutov @mchutov
//

import UIKit

private struct Constants {
    static var timerFormat = "%02d:%02d"
}

final class DashboardPresenter: DashboardPresenterProtocol {
    // main
    weak private var view: DashboardViewProtocol?
    var interactor: DashboardInteractorProtocol?
    private let router: DashboardWireframeProtocol
    // time
    private var timer: Timer?
    private var totalTimer: Timer?
    private var seconds = 0
    // model
    private let userInputModel: UserInputModel
    var matrix: [[Bool]] = [] {
        didSet {
            DispatchQueue.main.async {
                self.view?.update()
            }
        }
    }
    // additional
    private var isFirstSelection: Bool = true
    private var isEndCalled = false
    private var tapAmount = 0
    
    private let c: Int
    private let r: Int
    
    private let timeInterval: Double
    private let localQueue = DispatchQueue(label: "localQueue")
    private var infectedCount = 0
    private var uninfectedCount: Int
    private var infectionFactor: Int
    
    init(
        interface: DashboardViewProtocol,
        interactor: DashboardInteractorProtocol?,
        router: DashboardWireframeProtocol,
        model: UserInputModel
    ) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        self.userInputModel = model
        
        self.uninfectedCount = model.groupSize
        let c = MatrixManager.createMatrix(for: userInputModel.groupSize)[0]
        let r = MatrixManager.createMatrix(for: userInputModel.groupSize)[1]
        self.c = c
        self.r = r
        self.matrix = Array(
            repeating: Array(
                repeating: false,
                count: r
            ),
            count: c
        )
        self.infectionFactor = model.infectionFactor
        self.timeInterval = Double(model.recalculationInfected)
    }
    
    func viewDidLoad() {
        view?.configureStatisticsView(
            with: .init(uninfectedCount: userInputModel.groupSize)
        )
    }
    
}

extension DashboardPresenter {
    
    func select(at indexPath: IndexPath) {
        if isFirstSelection {
            startTimer()
            isFirstSelection = false
        }
        
        infectionProcess(
            at: (indexPath.item, indexPath.section),
            withInfectionFactor: infectionFactor
        )
    }
}

// MARK: - General calculation
private extension DashboardPresenter {
    
    func infectionProcess(
        at point: (row: Int, col: Int),
        withInfectionFactor factor: Int
    ) {
        tapAmount += 1
        matrix[point.col][point.row] = true
        infectedCount += 1
        uninfectedCount -= 1
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            let infected = self.getInfectedPoints()
            for i in infected {
                self.spreadInfection(
                    at: (i.row, i.col),
                    withInfectionFactor: factor
                )
            }
        }
        
        localQueue.asyncAfter(
            deadline: .now() + timeInterval
        ) { [weak self] in
            guard let self else { return }
            self.spreadInfection(at: point, withInfectionFactor: factor)
        }
    }
    
    func spreadInfection(
        at point: (row: Int, col: Int),
        withInfectionFactor infectionFactor: Int
    ) {
        updateStatisticView()
        var neighbors = [(row: Int, col: Int)]()
        for row in (point.row - 1)...(point.row + 1) {
            for col in (point.col - 1)...(point.col + 1) {
                if row >= 0 && row < matrix.count && col >= 0 && col < matrix[0].count && !(row == point.row && col == point.col) {
                    neighbors.append((row: row, col: col))
                }
            }
        }
        
        var numInfected = Int.random(
            in: 0...min(
                infectionFactor, neighbors.count
            )
        )
        neighbors.shuffle()
        
        neighbors.forEach { neighbor in
            guard numInfected > 0 else {
                return
            }

            localQueue.async { [self] in
                DispatchQueue.main.async {
                    if !self.matrix[neighbor.row][neighbor.col] {
                        self.matrix[neighbor.row][neighbor.col] = true
                        
                        self.infectedCount += 1
                        self.uninfectedCount -= 1
                    }
                }
            }
            numInfected -= 1
        }
    }
    
    func getInfectedPoints() -> [(row: Int, col: Int)] {
        var infectedPoints = [(row: Int, col: Int)]()
        for row in 0..<matrix.count {
            for col in 0..<matrix[0].count {
                if matrix[row][col] {
                    infectedPoints.append((row: row, col: col))
                }
            }
        }
        return infectedPoints
    }
}

// MARK: - Update UI
private extension DashboardPresenter {
    
    func updateStatisticView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.uninfectedCount == 0 && !self.isEndCalled {
                self.end()
                self.isEndCalled = true
            }
            
            self.view?.updateMainStatistic(
                uninfected: self.uninfectedCount.description,
                infected: self.infectedCount.description
            )
            if self.uninfectedCount != 0 {
                self.view?.updateProgressView(
                    Float(self.infectedCount) / Float(self.userInputModel.groupSize)
                )
            } else {
                self.view?.updateProgressView(1.0)
            }
        }
    }
}

// MARK: - Timer
private extension DashboardPresenter {
    func startTimer() {
        totalTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateTimer() {
        seconds += 1
        view?.updateTimer(with: getTimeFromTimer())
    }
    
    func stopTimers() {
        timer?.invalidate()
        totalTimer?.invalidate()
    }
    
    func getTimeFromTimer() -> String {
        let minutes = seconds / 60
        let secondsValue = seconds % 60
        let timeString = String(
            format: Constants.timerFormat,
            minutes, secondsValue
        )
        return timeString
    }
}

// MARK: - End
private extension DashboardPresenter {
    func end() {
        stopTimers()
        let model: SimulationEndModel = .init(
            userInputModel: userInputModel,
            totalTime: getTimeFromTimer(),
            tapAmount: tapAmount
        )
        view?.end(with: model)
    }
}
