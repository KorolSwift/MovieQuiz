//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ди Di on 08/01/25.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    func store(correct count: Int, total amount: Int)
}
