import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - UI Elements
    
    private let backgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Свяжитесь с нами"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(translationX: 0, y: -20)
        return label
    }()
    
    private let contactButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fillEqually
        stack.alpha = 0
        return stack
    }()
    
    private lazy var callButton = createContactButton(
        title: "Позвонить: 8 (938) 497-14-53",
        icon: UIImage(systemName: "phone.fill"),
        color: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0),
        action: #selector(callButtonTapped)
        )
    
    private lazy var telegramButton = createContactButton(
        title: "Telegram: @lurewisso",
        icon: UIImage(systemName: "paperplane.fill"),
        color: UIColor(red: 0.22, green: 0.60, blue: 0.86, alpha: 1.0),
        action: #selector(telegramButtonTapped)
    )
    
    private lazy var emailButton = createContactButton(
        title: "Email: lurewisso@list.ru",
        icon: UIImage(systemName: "envelope.fill"),
        color: UIColor(red: 0.96, green: 0.49, blue: 0.00, alpha: 1.0),
        action: #selector(emailButtonTapped)
        )
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Мы всегда рады помочь!"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(titleLabel)
        view.addSubview(contactButtonsStack)
        view.addSubview(footerLabel)
        
        contactButtonsStack.addArrangedSubview(callButton)
        contactButtonsStack.addArrangedSubview(telegramButton)
        contactButtonsStack.addArrangedSubview(emailButton)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contactButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            contactButtonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            contactButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contactButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            footerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            footerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Button Creation
    
    private func createContactButton(title: String, icon: UIImage?, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = color
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Shadow and depth effect
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        
        // Content layout
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: -12)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 12)
        
        // Transform for animation
        button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        button.alpha = 0
        
        // Press animation
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    // MARK: - Animations
    
    private func animateViews() {
        // Конфигурация анимаций
        let titleAnimDuration = 0.7
        let buttonsAnimDuration = 0.6
        let buttonStaggerDelay = 0.1 // Увеличена задержка между кнопками
        let footerAnimDuration = 0.4
        
        // 1. Анимация заголовка (более плавная)
        UIView.animate(
            withDuration: titleAnimDuration,
            delay: 0.1,
            usingSpringWithDamping: 0.7, // Меньше значение = более "пружинисто"
            initialSpringVelocity: 0.4,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.alpha = 1
                self.titleLabel.transform = .identity
            }
        )
        
        // 2. Анимация стека кнопок (появится одновременно с первой кнопкой)
        UIView.animate(
            withDuration: buttonsAnimDuration,
            delay: 0.3,
            options: .curveEaseInOut,
            animations: {
                self.contactButtonsStack.alpha = 1
            }
        )
        
        // 3. Каскадная анимация кнопок
        for (index, button) in contactButtonsStack.arrangedSubviews.enumerated() {
            UIView.animate(
                withDuration: buttonsAnimDuration,
                delay: 0.3 + Double(index) * buttonStaggerDelay, // Более заметный каскад
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.7,
                options: .curveEaseOut,
                animations: {
                    button.alpha = 1
                    button.transform = .identity
                }
            )
        }
        
        // 4. Анимация подписи (быстрее, появляется последней)
        UIView.animate(
            withDuration: footerAnimDuration,
            delay: 0.9,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: {
                self.footerLabel.alpha = 1
            }
        )
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.layer.shadowOpacity = 0.2
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            sender.transform = .identity
            sender.layer.shadowOpacity = 0.4
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func callButtonTapped() {
        let phoneNumber = "89384971453"
        guard let url = URL(string: "tel://\(phoneNumber)") else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func telegramButtonTapped() {
        let telegramURL = URL(string: "https://t.me/lurewisso")!
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if UIApplication.shared.canOpenURL(telegramURL) {
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            showAlert(title: "Telegram не установлен", message: "Пожалуйста, установите Telegram для связи")
        }
    }
    
    @objc private func emailButtonTapped() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["lurewisso@list.ru"])
            mail.setSubject("Обращение из приложения")
            mail.setMessageBody("Здравствуйте, у меня вопрос по поводу...", isHTML: false)
            
            present(mail, animated: true) {
                UIView.animate(withDuration: 0.3) {
                    self.view.alpha = 0.95
                }
            }
        } else {
            showAlert(title: "Почта не настроена", message: "Пожалуйста, настройте почтовый клиент на вашем устройстве")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            UIView.animate(withDuration: 0.3) {
                self.view.alpha = 1.0
            }
            
            if result == .sent {
                self.showAlert(title: "Успешно", message: "Ваше сообщение отправлено!")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Customize alert appearance
        if let alertBg = alert.view.subviews.first?.subviews.first?.subviews.first {
            alertBg.backgroundColor = UIColor(red: 0.12, green: 0.11, blue: 0.22, alpha: 1.0)
            alertBg.layer.cornerRadius = 12
        }
        
        alert.view.tintColor = .white
        
        present(alert, animated: true) {
            alert.view.tintColor = UIColor(red: 0.33, green: 0.27, blue: 0.58, alpha: 1.0)
        }
    }
}
