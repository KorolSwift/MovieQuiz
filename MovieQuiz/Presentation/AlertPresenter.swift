//
//  AlertPresenter.swift.swift
//  MovieQuiz
//
//  Created by Ди Di on 06/01/25.


import UIKit

final class AlertPresenter {
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
    }
    
    func showResultAlert(result: AlertModel) {
        guard let viewController = viewController else { return }
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = AccessibilityIdentifiers.gameResults
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
