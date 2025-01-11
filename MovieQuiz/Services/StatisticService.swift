//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ди Di on 08/01/25.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case gamesCount
        case bestCorrect
        case bestTotal
        case bestDate
        case correctAnswers
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestTotal.rawValue)
            let date = storage.object(forKey: Keys.bestDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            guard gamesCount > 0 else { return 0.0 }
            return (Double(correctAnswers) / Double(10 * gamesCount)) * 100
        }
    }
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isTheBest(bestGame) {
            bestGame = currentGame
        }
    }
}
