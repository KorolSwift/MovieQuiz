//
//  AlertPresenter.swift.swift
//  MovieQuiz
//
//  Created by Ди Di on 06/01/25.
//

import UIKit

final class AlertPresenter {
    private weak var presenter: UIViewController?
    
    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    
    func showResultAlert(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion() 
        }
        alert.addAction(action)
        presenter?.present(alert, animated: true, completion: nil)
    }
}
