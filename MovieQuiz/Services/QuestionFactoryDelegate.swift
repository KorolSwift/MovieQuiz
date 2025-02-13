//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ди Di on 06/01/25.


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
