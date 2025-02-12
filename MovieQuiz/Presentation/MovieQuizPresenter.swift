//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ди Di on 08/02/25.


import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func changeStateButton(isEnabled: Bool)
}

class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    var alertPresenter: AlertPresenter?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let message = makeResultsMessage()
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self else { return }
                    self.restartGame()
                    self.correctAnswers = 0
                    self.viewController?.showLoadingIndicator()
                    //                    self.viewController?.changeStateButton(isEnabled: true)
                }
            )
            guard let alertPresenter else { return }
            alertPresenter.showResultAlert(result: alertModel)
        } else {
            self.switchToNextQuestion()
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
            viewController?.changeStateButton(isEnabled: true)
        }
    }
    func makeResultsMessage() -> String {
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
