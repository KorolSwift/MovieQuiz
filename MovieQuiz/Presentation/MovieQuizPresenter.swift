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
//        changeStateButton(isEnabled: false)
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    func noButtonClicked() {
//        changeStateButton(isEnabled: false)
        guard let currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
}
