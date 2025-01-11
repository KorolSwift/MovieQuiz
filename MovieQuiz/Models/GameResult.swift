//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ди Di on 08/01/25.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    func isTheBest(_ score: GameResult) -> Bool {
        correct > score.correct
    }
}
