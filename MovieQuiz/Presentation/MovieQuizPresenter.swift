//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ди Di on 08/02/25.
//

import UIKit

class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
//    private var currentQuestion: QuizQuestion?
    var currentQuestion: QuizQuestion?

    weak var viewController: MovieQuizViewController?
    private var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private var alertPresenter: AlertPresenter?



    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
//        guard let currentQuestion else { return }
//        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
//        guard let currentQuestion else { return }
//        let givenAnswer = false
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func showNextQuestionOrResults() {

        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGameDate =  statisticService.bestGame.date.dateTimeString
            
            let message = "Ваш результат: \(correctAnswers)/\(questionsAmount) \nКоличество сыгранных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate)) \nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    guard let self else { return }
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                    self.viewController?.showLoadingIndicator()
                    self.viewController?.changeStateButton(isEnabled: true)
                }
            )
            guard let alertPresenter else { return }
            alertPresenter.showResultAlert(result: alertModel)
            //            return
        } else {
            switchToNextQuestion()
            viewController?.hideLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
            viewController?.changeStateButton(isEnabled: true)
        }
    }
}
