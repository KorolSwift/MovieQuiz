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

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol?
    var alertPresenter: AlertPresenter?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func answerButtonClicked(isYes: Bool) {
        didAnswer(isYes: isYes)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
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
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
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
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
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
                }
            )
            guard let alertPresenter else { return }
            alertPresenter.showResultAlert(result: alertModel)
        } else {
            switchToNextQuestion()
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
            viewController?.changeStateButton(isEnabled: true)
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func makeResultsMessage() -> String {
        guard let statisticService = statisticService else {
                return "Статистика недоступна"
            }
        
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = """
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        """
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = """
        \(currentGameResultLine)
        \(totalPlaysCountLine)
        \(bestGameInfoLine)
        \(averageAccuracyLine)
        """
        return resultMessage
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
