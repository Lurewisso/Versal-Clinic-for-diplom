//
//import UIKit
//import FirebaseAuth
//import Foundation
//



import UIKit
import FirebaseAuth
import Foundation

class MenuViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let profileButton = UIButton(type: .system)
    private let doctorsListButton = UIButton(type: .system)
    private let clinicsMapButton = UIButton(type: .system)
    private let analysisButton = UIButton(type: .system)
    private let paymentMethodButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    private let geolinkButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }
    
    // MARK: - Setup Background
    
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor, // Глубокий фиолетовый
            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor  // Глубокий синий
        ]
//        gradientLayer.colors = [
//            UIColor(red: 0.25, green: 0.22, blue: 0.35, alpha: 1.0).cgColor, // Более светлый фиолетовый
//            UIColor(red: 0.18, green: 0.25, blue: 0.4, alpha: 1.0).cgColor  // Более светлый синий
//        ]
//        gradientLayer.colors = [
//            UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0).cgColor, // Светлый сине-голубой (верх)
//            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0).cgColor  // Более глубокий синий (низ)
//        ]
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        
        
        
        
        backgroundView.layer.addSublayer(gradientLayer)
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Настройка кнопок
        setupButton(profileButton, title: "Профиль", icon: "person.fill", action: #selector(profileTapped))
        setupButton(doctorsListButton, title: "Список врачей", icon: "stethoscope", action: #selector(doctorsListTapped))
        setupButton(clinicsMapButton, title: "Карта клиник", icon: "map.fill", action: #selector(clinicsMapTapped))
        
        setupButton(analysisButton, title: "Мои анализы", icon: "doc.fill", action: #selector(analysisTapped))
        
        setupButton(paymentMethodButton, title: "Способы оплаты", icon: "creditcard.fill", action: #selector(paymentMethodTapped))
        setupButton(settingsButton, title: "Настройки", icon: "gearshape.fill", action: #selector(settingsTapped))
        setupButton(helpButton, title: "Помощь", icon: "questionmark.circle.fill", action: #selector(helpTapped))
        setupButton(logoutButton, title: "Выйти", icon: "arrow.backward.circle.fill", action: #selector(logoutTapped), color: .systemRed)
        
        // Добавляем кнопки в стек
        stackView.addArrangedSubview(profileButton)
        stackView.addArrangedSubview(doctorsListButton)
        stackView.addArrangedSubview(clinicsMapButton)
        stackView.addArrangedSubview(analysisButton)
        stackView.addArrangedSubview(paymentMethodButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(helpButton)
        stackView.addArrangedSubview(logoutButton)
        
        // Добавляем стек на экран
        view.addSubview(stackView)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupButton(_ button: UIButton, title: String, icon: String, action: Selector, color: UIColor = .white) {
        // Иконка
        let iconImage = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(iconImage, for: .normal)
        button.tintColor = color
        
        // Текст
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        // Выравнивание
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        // Стиль кнопки
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Анимация при нажатии
        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpOutside)
        
        // Действие
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Констрейнты для высоты кнопки
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Button Animations
    
    @objc private func animateButtonTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    @objc private func animateButtonRelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
    }
    
    // MARK: - Actions
    
    @objc private func profileTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func doctorsListTapped() {
        let doctorsListVC = DoctorsListViewController()
        navigationController?.pushViewController(doctorsListVC, animated: true)
    }
    
    @objc private func clinicsMapTapped() {
        let clinicsMapVC = ClinicsMapViewController()
        navigationController?.pushViewController(clinicsMapVC, animated: true)
    }
    
    @objc private func analysisTapped() {
        let analysisVC = AnalysisViewController()
        navigationController?.pushViewController(analysisVC, animated: true)
    }
    
    @objc private func paymentMethodTapped() {
        let paymentMethodVC = PaymentMethodViewController()
        navigationController?.pushViewController(paymentMethodVC, animated: true)
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func helpTapped() {
        let helpVC = HelpViewController()
        navigationController?.pushViewController(helpVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Выйти", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            do {
                self.removeAllNotifications()
                try Auth.auth().signOut()
                self.clearUserData()
                let startScreenVC = StartScreenViewController()
                let navController = UINavigationController(rootViewController: startScreenVC)
                navController.modalPresentationStyle = .fullScreen
                if let window = self.view.window ?? UIApplication.shared.windows.first {
                    window.rootViewController = navController
                    window.makeKeyAndVisible()
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
                }
            } catch {
                print("Ошибка при выходе из аккаунта: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Все уведомления удалены")
    }
    
    private func clearUserData() {
        print("Данные пользователя очищены")
    }
}























