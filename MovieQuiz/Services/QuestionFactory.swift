//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ди Di on 03/01/25.

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    init (moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self .moviesLoader = moviesLoader
        self.delegate = delegate
    }
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<movies.count).randomElement() ?? 0
            guard let movie = movies[safe: index] else { return }
            var imageData: Data?
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                imageData = nil
            }
            
            guard let validImageData = imageData else {
                DispatchQueue.main.async { [weak self] in
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить изображение"])
                    self?.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let randomRatingValue = Int.random(in: 4...8)
            let rating = Float(movie.rating) ?? 0
            let words = ["больше", "меньше"]
            let randomWord = words.randomElement() ?? words[0] 
            
            let correctAnswer = randomWord == "больше" ? rating > Float(randomRatingValue) : rating < Float(randomRatingValue)
            
            let text = "Рейтинг этого фильма \(randomWord) чем \(randomRatingValue)?"
            let question = QuizQuestion(image: validImageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion (
    //            image: "The Godfather",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "The Dark Knight",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "Kill Bill",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "The Avengers",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "Deadpool",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "The Green Knight",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion (
    //            image: "Old",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion (
    //            image: "The Ice Age Adventures of Buck Wild",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion (
    //            image: "Tesla",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion (
    //            image: "Vivarium",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //    ]
}
