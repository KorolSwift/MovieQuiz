import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenter?
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = ""
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        presenter?.alertPresenter = alertPresenter
        showLoadingIndicator()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter?.restartGame()
            }
        )
        alertPresenter?.showResultAlert(result: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        changeStateButton(isEnabled: true)
        view.isUserInteractionEnabled = true
        hideLoadingIndicator()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else { return }
            self.showLoadingIndicator()
            self.presenter?.restartGame()
            self.changeStateButton(isEnabled: true)
        }
        guard let alertPresenter else { return }
        alertPresenter.showResultAlert(result: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.answerButtonClicked(isYes: true)
        view.isUserInteractionEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.answerButtonClicked(isYes: false)
        view.isUserInteractionEnabled = false
    }
}
