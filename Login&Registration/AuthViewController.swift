




import UIKit
import FirebaseAuth
import Foundation

class AuthViewController: UIViewController {

    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let forgetPasswordButton = UIButton(type: .system)
    private let dontHaveAnAccLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()

        // Проверяем, авторизован ли пользователь
        if Auth.auth().currentUser != nil {
            navigateToMainScreen()
        }
        let backButton = UIBarButtonItem(title: "<  Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        // Настройка заголовка
        titleLabel.text = "Добро пожаловать"
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        titleLabel.textColor = .systemBlue
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Настройка текстовых полей
        setupTextField(emailTextField, placeholder: "Почта или номер телефона")
        setupTextField(passwordTextField, placeholder: "Пароль", isSecure: true)

        // Настройка кнопки входа
        setupButton(loginButton, title: "Войти", color: .systemBlue, action: #selector(loginButtonTapped))

        // Настройка кнопки "Forget Password"
        forgetPasswordButton.setTitle("Забыли пароль?", for: .normal)
        forgetPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgetPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        forgetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgetPasswordButton.addTarget(self, action: #selector(forgetPasswordTapped), for: .touchUpInside)

        // Настройка текста "Don't have an account? Sign Up"
        dontHaveAnAccLabel.text = "Нет аккаунта? "
        dontHaveAnAccLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dontHaveAnAccLabel.textColor = .black
        dontHaveAnAccLabel.translatesAutoresizingMaskIntoConstraints = false

        // Настройка кнопки регистрации
        signUpButton.setTitle("создать", for: .normal)
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)

        // Добавление элементов на экран
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(forgetPasswordButton)
        view.addSubview(dontHaveAnAccLabel)
        view.addSubview(signUpButton)

        // Констрейнты
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),

            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            forgetPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgetPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),

            dontHaveAnAccLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            dontHaveAnAccLabel.topAnchor.constraint(equalTo: forgetPasswordButton.bottomAnchor, constant: 20),

            signUpButton.leadingAnchor.constraint(equalTo: dontHaveAnAccLabel.trailingAnchor, constant: 5),
            signUpButton.centerYAnchor.constraint(equalTo: dontHaveAnAccLabel.centerYAnchor)
        ])
    }

    // Настройка текстовых полей
    private func setupTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = isSecure
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 10
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
    }

    // Настройка кнопок
    private func setupButton(_ button: UIButton, title: String, color: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 25
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false

        // Анимация при нажатии
        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpOutside)

        // Действие
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    // Анимация нажатия кнопки
    @objc private func animateButtonTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.8)
        }
    }

    // Анимация отпускания кнопки
    @objc private func animateButtonRelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(1.0)
        }
    }

    // Логика входа
    @objc private func loginButtonTapped() {
        animateButtonTap(loginButton)
        animateButtonRelease(loginButton)
        performLogin()
    }

    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(message: "Ошибка: \(error.localizedDescription)")
            } else {
                self.navigateToMainScreen()
            }
        }
    }

    // Переход на экран регистрации
    @objc private func signUpButtonTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    // Переход на главный экран
    private func navigateToMainScreen() {
        let mainViewController = MainViewController()
        navigationController?.setViewControllers([mainViewController], animated: true)
    }

    // Показ алерта
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Действие при нажатии на "Forget Password"
//    @objc private func forgetPasswordTapped() {
//        // Реализуйте логику восстановления пароля
//        showAlert(message: "Функция восстановления пароля")
//    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    @objc private func forgetPasswordTapped() {
           guard let email = emailTextField.text, !email.isEmpty else {
               showAlert2(message: "Пожалуйста, введите ваш email")
               return
           }

        guard isValidEmail(email) else {
                showAlert(message: "Пожалуйста, введите корректный email")
                return
            }
           // Отправка письма для сброса пароля
           Auth.auth().sendPasswordReset(withEmail: email) { error in
               if let error = error {
                   self.showAlert2(message: "Ошибка: \(error.localizedDescription)")
               } else {
                   self.showAlert2(message: "Письмо для сброса пароля отправлено на \(email)")
               }
           }
       }
    // Показ алерта
        private func showAlert2(message: String) {
            let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}


