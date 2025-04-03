//import UIKit
//import FirebaseAuth
//import Foundation
//
//



//import UIKit
//import FirebaseAuth
//import Foundation
//


import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let fullNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let mobileNumberTextField = UITextField()
    private let dateOfBirthTextField = UITextField()
    private let signUpButton = UIButton(type: .system)
    private let termsLabel = UILabel()

    private let datePicker = UIPickerView()
    private let days = Array(1...31)
    private let months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    private let years = Array(1900...Calendar.current.component(.year, from: Date()))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupDatePicker()
        
        let backButton = UIBarButtonItem(title: "<  Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        // Настройка текстовых полей
        setupTextField(fullNameTextField, placeholder: "Полное имя")
        setupTextField(emailTextField, placeholder: "Электронная почта", keyboardType: .emailAddress)
        setupTextField(passwordTextField, placeholder: "Пароль", isSecure: true)
        setupTextField(mobileNumberTextField, placeholder: "Номер телефона", keyboardType: .phonePad)
        setupTextField(dateOfBirthTextField, placeholder: "Дата рождения", keyboardType: .default)

        // Настройка кнопки регистрации
        setupButton(signUpButton, title: "Зарегистрироваться", color: .systemBlue, action: #selector(signUpButtonTapped))

        // Настройка текста с условиями
        termsLabel.text = "Продолжая, вы соглашаетесь с Условиями использования и Политикой конфиденциальности."
        termsLabel.font = UIFont.systemFont(ofSize: 10)
        termsLabel.textColor = .gray
        termsLabel.numberOfLines = 0
        termsLabel.textAlignment = .center
        termsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Добавление элементов на экран
        view.addSubview(fullNameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(mobileNumberTextField)
        view.addSubview(dateOfBirthTextField)
        view.addSubview(signUpButton)
        view.addSubview(termsLabel)

        // Констрейнты
        NSLayoutConstraint.activate([
            fullNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fullNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fullNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            fullNameTextField.heightAnchor.constraint(equalToConstant: 50),

            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            mobileNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mobileNumberTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            mobileNumberTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            mobileNumberTextField.heightAnchor.constraint(equalToConstant: 50),

            dateOfBirthTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateOfBirthTextField.topAnchor.constraint(equalTo: mobileNumberTextField.bottomAnchor, constant: 20),
            dateOfBirthTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            dateOfBirthTextField.heightAnchor.constraint(equalToConstant: 50),

            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: dateOfBirthTextField.bottomAnchor, constant: 30),
            signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),

            termsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            termsLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            termsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
            
        ])
    }

    private func setupTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 55 // Более округлые углы
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
       
    }

    private func setupButton(_ button: UIButton, title: String, color: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 25 // Более округлые углы
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpOutside)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func animateButtonTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.8)
        }
    }

    @objc private func animateButtonRelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(1.0)
        }
    }

    @objc private func signUpButtonTapped() {
        animateButtonTap(signUpButton)
        animateButtonRelease(signUpButton)

        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let fullName = fullNameTextField.text, !fullName.isEmpty,
              let mobileNumber = mobileNumberTextField.text, !mobileNumber.isEmpty,
              let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }

        guard password.count >= 6 else {
            showAlert(message: "Пароль должен содержать не менее 6 символов")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Ошибка регистрации: \(error.localizedDescription)")
                self.showAlert(message: "Ошибка: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Регистрация успешна!") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    // MARK: - UIPickerView для даты рождения

    private func setupDatePicker() {
        datePicker.delegate = self
        datePicker.dataSource = self
        dateOfBirthTextField.inputView = datePicker

        // Добавляем тулбар для кнопки "Готово"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneDatePicker))
        toolbar.setItems([doneButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolbar
    }

    @objc private func doneDatePicker() {
        let day = days[datePicker.selectedRow(inComponent: 0)]
        let month = months[datePicker.selectedRow(inComponent: 1)]
        let year = years[datePicker.selectedRow(inComponent: 2)]
        dateOfBirthTextField.text = "\(day) \(month) \(year)"
        view.endEditing(true)
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // День, месяц, год
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return days.count
        case 1: return months.count
        case 2: return years.count
        default: return 0
        }
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(days[row])"
        case 1: return months[row]
        case 2: return "\(years[row])"
        default: return nil
        }
    }
}



























