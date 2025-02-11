import UIKit

final class MovieQuizViewController: UIViewController,
                                     QuestionFactoryDelegate {
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenter?
    //    private var currentQuestion: QuizQuestion?
//    private let statisticService: StatisticServiceProtocol = StatisticService()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        presenter.viewController = self
        super.viewDidLoad()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        presenter.questionFactory = questionFactory
        self.alertPresenter = AlertPresenter(presenter: self)
//        presenter.alertPresenter = self.alertPresenter
        showLoadingIndicator()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        questionFactory.loadData()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - QuestionFactoryDelegate
    //    func didReceiveNextQuestion(question: QuizQuestion?) {
    //        guard let question else {
    //            return
    //        }
    //        self.hideLoadingIndicator()
    //        currentQuestion = question
    //        let viewModel = presenter.convert(model: question)
    //
    //        DispatchQueue.main.async { [weak self] in
    //            self?.show(quiz: viewModel)
    //        }
    //    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showFirstQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    func show(quiz step: QuizStepViewModel) {
        print("🟢 show(quiz:) вызван, отображаем вопрос: \(step.question)") // 👉 Добавь этот принт

        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
//            let bestGameDate =  statisticService.bestGame.date.dateTimeString
//            
//            let message = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount) \nКоличество сыгранных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate)) \nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
//            
//            let alertModel = AlertModel(
//                title: "Этот раунд окончен!",
//                message: message,
//                buttonText: "Сыграть еще раз",
//                completion: { [weak self] in
//                    guard let self else { return }
//                    self.presenter.resetQuestionIndex()
//                    self.correctAnswers = 0
//                    self.questionFactory?.requestNextQuestion()
//                    self.showLoadingIndicator()
//                    self.changeStateButton(isEnabled: true)
//                }
//            )
//            guard let alertPresenter else { return }
//            alertPresenter.showResultAlert(result: alertModel)
//            //            return
//        } else {
//            presenter.switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
//            showLoadingIndicator()
//            changeStateButton(isEnabled: true)
//        }
//    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
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
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.changeStateButton(isEnabled: true)
        }
        guard let alertPresenter else { return }
        alertPresenter.showResultAlert(result: alertModel)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
//        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        changeStateButton(isEnabled: false)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        changeStateButton(isEnabled: false)
//        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
}
