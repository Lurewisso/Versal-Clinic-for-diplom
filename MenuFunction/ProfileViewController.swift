//
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import Photos
import Foundation

class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.1)
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.2)
        view.layer.cornerRadius = 60
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let changeAvatarButton: UIButton = {
        let button = UIButton()
        button.setTitle("Изменить фото", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Мой профиль"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let surnameLabel = UILabel()
    private let surnameTextField = UITextField()
    private let cityLabel = UILabel()
    private let cityTextField = UITextField()
    private let phoneLabel = UILabel()
    private let phoneTextField = UITextField()
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let genderLabel = UILabel()
    
    private let genderSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Мужской", "Женский"])
        sc.selectedSegmentTintColor = UIColor.systemBlue
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.systemRed.withAlphaComponent(0.8), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        loadUserData()
        setupKeyboardHandling()
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.12, green: 0.08, blue: 0.25, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.15, blue: 0.35, alpha: 1.0).cgColor
        ]
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Добавляем карточку профиля
        contentView.addSubview(profileCardView)
        profileCardView.addSubview(titleLabel)
        profileCardView.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        profileCardView.addSubview(changeAvatarButton)
        
        // Настройка полей ввода
        setupField(label: nameLabel, textField: nameTextField, placeholder: "Имя")
        setupField(label: surnameLabel, textField: surnameTextField, placeholder: "Фамилия")
        setupField(label: cityLabel, textField: cityTextField, placeholder: "Город")
        setupField(label: phoneLabel, textField: phoneTextField, placeholder: "Телефон", keyboardType: .phonePad)
        setupField(label: emailLabel, textField: emailTextField, placeholder: "Email", keyboardType: .emailAddress)
        
        genderLabel.text = "Пол"
        genderLabel.textColor = .white.withAlphaComponent(0.9)
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем элементы на карточку
        profileCardView.addSubview(nameLabel)
        profileCardView.addSubview(nameTextField)
        profileCardView.addSubview(surnameLabel)
        profileCardView.addSubview(surnameTextField)
        profileCardView.addSubview(cityLabel)
        profileCardView.addSubview(cityTextField)
        profileCardView.addSubview(phoneLabel)
        profileCardView.addSubview(phoneTextField)
        profileCardView.addSubview(emailLabel)
        profileCardView.addSubview(emailTextField)
        profileCardView.addSubview(genderLabel)
        profileCardView.addSubview(genderSegmentedControl)
        
        // Кнопки
        contentView.addSubview(saveButton)
        contentView.addSubview(logoutButton)
        contentView.addSubview(activityIndicator)
        
        // Настройка активности кнопок
        changeAvatarButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        // Констрейнты
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Карточка профиля
            profileCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileCardView.bottomAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 30),
            
            // Аватар
            avatarContainer.centerXAnchor.constraint(equalTo: profileCardView.centerXAnchor),
            avatarContainer.topAnchor.constraint(equalTo: profileCardView.topAnchor, constant: 30),
            avatarContainer.widthAnchor.constraint(equalToConstant: 120),
            avatarContainer.heightAnchor.constraint(equalToConstant: 120),
            
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            changeAvatarButton.centerXAnchor.constraint(equalTo: profileCardView.centerXAnchor),
            changeAvatarButton.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 10),
            
            // Заголовок
            titleLabel.centerXAnchor.constraint(equalTo: profileCardView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: changeAvatarButton.bottomAnchor, constant: 20),
            
            // Поля ввода
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            nameLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            surnameLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            surnameLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            surnameTextField.topAnchor.constraint(equalTo: surnameLabel.bottomAnchor, constant: 5),
            surnameTextField.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            surnameTextField.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            surnameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            cityLabel.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 15),
            cityLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            cityTextField.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
            cityTextField.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            cityTextField.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            cityTextField.heightAnchor.constraint(equalToConstant: 44),
            
            phoneLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 15),
            phoneLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5),
            phoneTextField.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            phoneTextField.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 15),
            emailLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            emailTextField.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            genderLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            genderLabel.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 25),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -25),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Кнопки
            saveButton.topAnchor.constraint(equalTo: profileCardView.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: profileCardView.widthAnchor, multiplier: 0.8),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20)
        ])
    }

    private func setupField(label: UILabel, textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        label.text = placeholder
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(white: 1, alpha: 0.1)
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка цвета placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
    }

    // MARK: - Actions
    @objc private func changeAvatarTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let item = results.first?.itemProvider else { return }
        if item.canLoadObject(ofClass: UIImage.self) {
            item.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.avatarImageView.image = image
                    }
                }
            }
        }
    }

    @objc private func saveButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userData: [String: Any] = [
            "name": nameTextField.text ?? "",
            "surname": surnameTextField.text ?? "",
            "city": cityTextField.text ?? "",
            "phone": phoneTextField.text ?? "",
            "email": emailTextField.text ?? "",
            "gender": genderSegmentedControl.selectedSegmentIndex == 0 ? "Муж" : "Жен"
        ]
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        saveButton.isEnabled = false
        activityIndicator.startAnimating()
        
        // Анимация нажатия кнопки
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
        
        userRef.setData(userData) { error in
            self.saveButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            
            if let error = error {
//                self.showAlert(message: "Ошибка сохранения данных: \(error.localizedDescription)")
                self.showAlertWithAnimation(message: "Ошибка сохранения данных: \(error.localizedDescription)")
            } else {
                self.showAlertWithAnimation(message: "Данные успешно сохранены!")
            }
        }
    }
    
    private func showAlertWithAnimation(message: String) {
        let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Анимация появления
        alert.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        present(alert, animated: true) {
            UIView.animate(withDuration: 0.3) {
                alert.view.transform = .identity
            }
        }
    }
    
    @objc private func logoutButtonTapped() {
        // Реализация выхода (оставлена без изменений)
    }
    
    private func loadUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            let authVC = AuthViewController()
            let navController = UINavigationController(rootViewController: authVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.nameTextField.text = data?["name"] as? String
                self.surnameTextField.text = data?["surname"] as? String
                self.cityTextField.text = data?["city"] as? String
                self.phoneTextField.text = data?["phone"] as? String
                self.emailTextField.text = data?["email"] as? String
                let gender = data?["gender"] as? String ?? "Муж"
                self.genderSegmentedControl.selectedSegmentIndex = (gender == "Муж") ? 0 : 1
            }
        }
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}












































//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseStorage
//import PhotosUI
//import Photos
//import Foundation
//
//
//
//
//
//class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
//    private let backgroundView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    // MARK: - UI Elements
//
//    private let scrollView = UIScrollView() 
//    private let contentView = UIView() // Контейнер всего хлама на экране
//
//    private let avatarImageView = UIImageView()
//    private let changeAvatarButton = UIButton()
//    
//    private let nameLabel = UILabel()
//    private let nameTextField = UITextField()
//    
//    private let surnameLabel = UILabel()
//    private let surnameTextField = UITextField()
//    
//    private let cityLabel = UILabel()
//    private let cityTextField = UITextField()
//    
//    private let phoneLabel = UILabel()
//    private let phoneTextField = UITextField()
//    
//    private let emailLabel = UILabel()
//    private let emailTextField = UITextField()
//    
//    private let genderLabel = UILabel()
//    private let genderSegmentedControl = UISegmentedControl(items: ["Муж", "Жен"])
//    
//    private let saveButton = UIButton()
//    private let titleLabel = UILabel()
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    
//    // допилить кнопку выхода
//    private let logoutButton = UIButton()
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupBackground()
////        view.backgroundColor = .systemBackground
//        setupUI()
//        loadUserData()
//        setupKeyboardHandling() // Настройка клавы
//        
//       
//        let backButton = UIBarButtonItem(title: "ᐸ Назад", style: .plain, target: self, action: #selector(backButtonTapped))
//        backButton.tintColor = .white
//        navigationItem.leftBarButtonItem = backButton
//    }
//
//    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//    private func setupBackground() {
//
//
//        let gradientLayer = CAGradientLayer()
////        gradientLayer.colors = [
////            UIColor(red: 0.0, green: 0.545, blue: 0.545, alpha: 1.0).cgColor,
////            UIColor(red: 0.125, green: 0.698, blue: 0.667, alpha: 1.0).cgColor
////        ]
//        gradientLayer.colors = [
//            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor, // Глубокий фиолетовый
//            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor  // Глубокий синий
//        ]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = view.bounds
//        backgroundView.layer.addSublayer(gradientLayer)
//        view.addSubview(backgroundView)
//        
//        NSLayoutConstraint.activate([
//            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    // MARK: - Setup UI
//
//    private func setupUI() {
//        // Настройка пролистывания
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        // хэдер
//        titleLabel.text = "Профиль"
//        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
////        titleLabel.textColor = .label
//        titleLabel.textColor = .white
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Авка
//        avatarImageView.image = UIImage(systemName: "person.circle.fill")
//        avatarImageView.tintColor = .gray
//        avatarImageView.contentMode = .scaleAspectFill
//        avatarImageView.layer.cornerRadius = 50
//        avatarImageView.clipsToBounds = true
//        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // не работает , ограничение бд
//        changeAvatarButton.setTitle("Изменить фото", for: .normal)
//        changeAvatarButton.setTitleColor(.systemBlue, for: .normal)
//        changeAvatarButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        changeAvatarButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
//        changeAvatarButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // ввод
//        setupField(label: nameLabel, textField: nameTextField, placeholder: "Имя")
//        setupField(label: surnameLabel, textField: surnameTextField, placeholder: "Фамилия")
//        setupField(label: cityLabel, textField: cityTextField, placeholder: "Город")
//        setupField(label: phoneLabel, textField: phoneTextField, placeholder: "Телефон", keyboardType: .phonePad)
//        setupField(label: emailLabel, textField: emailTextField, placeholder: "Email", keyboardType: .emailAddress)
//        
//        // джендер
//        genderLabel.text = "Пол"
//        genderLabel.textColor = .white
//        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        genderLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        genderSegmentedControl.selectedSegmentIndex = 0
//        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
//
//        // Кнопка
//        saveButton.setTitle("Сохранить", for: .normal)
//        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        saveButton.backgroundColor = UIColor.systemBlue
//        saveButton.layer.cornerRadius = 10
//        saveButton.setTitleColor(.white, for: .normal)
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Индикатор загрузки
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicator.hidesWhenStopped = true
//
//        // Кнопка
//        logoutButton.setTitle("", for: .normal)
//        logoutButton.setTitleColor(.systemRed, for: .normal)
//        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
//        logoutButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Добавление всего на экран
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(avatarImageView)
//        contentView.addSubview(changeAvatarButton)
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(nameTextField)
//        contentView.addSubview(surnameLabel)
//        contentView.addSubview(surnameTextField)
//        contentView.addSubview(cityLabel)
//        contentView.addSubview(cityTextField)
//        contentView.addSubview(phoneLabel)
//        contentView.addSubview(phoneTextField)
//        contentView.addSubview(emailLabel)
//        contentView.addSubview(emailTextField)
//        contentView.addSubview(genderLabel)
//        contentView.addSubview(genderSegmentedControl)
//        contentView.addSubview(saveButton)
//        contentView.addSubview(activityIndicator)
//        contentView.addSubview(logoutButton)
//
//        // привязки к экрану
//        NSLayoutConstraint.activate([
//            // ScrollView
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//
//            // ContentView
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            // Заголовок
//            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            
//            // Аватар и кнопка изменения фото
//            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            avatarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
//            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            changeAvatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            changeAvatarButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
//            
//            // Имя
//            nameLabel.topAnchor.constraint(equalTo: changeAvatarButton.bottomAnchor, constant: 20),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
//            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            nameTextField.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Фамилия
//            surnameLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
//            surnameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            surnameTextField.topAnchor.constraint(equalTo: surnameLabel.bottomAnchor, constant: 5),
//            surnameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            surnameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            surnameTextField.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Город
//            cityLabel.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 15),
//            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            cityTextField.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
//            cityTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            cityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            cityTextField.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Телефон
//            phoneLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 15),
//            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5),
//            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            phoneTextField.heightAnchor.constraint(equalToConstant: 44),
//            
//            // мыло
//            emailLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 15),
//            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
//            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            emailTextField.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Пол уокер
//            genderLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
//            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 5),
//            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
//            
//            // саве
//            saveButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 30),
//            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            saveButton.widthAnchor.constraint(equalToConstant: 200),
//            saveButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // Кнопка выхода
//            logoutButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
//            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            
//            // загрузка
//            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            activityIndicator.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20)
//        ])
//    }
//
//    // Хелпер для настройки полей ввода с подписью
//    private func setupField(label: UILabel, textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
//        label.text = placeholder
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        textField.placeholder = placeholder
//        textField.borderStyle = .roundedRect
//        textField.keyboardType = keyboardType
//        textField.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    // MARK: - Actions
//
//    @objc private func changeAvatarTapped() {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = .images
//        
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//    
//    // Метод делегата PHPickerViewController
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        guard let item = results.first?.itemProvider else { return }
//        if item.canLoadObject(ofClass: UIImage.self) {
//            item.loadObject(ofClass: UIImage.self) { image, error in
//                DispatchQueue.main.async {
//                    if let image = image as? UIImage {
//                        self.avatarImageView.image = image
//                    }
//                }
//            }
//        }
//    }
//
//    
//    @objc private func saveButtonTapped() {
//        guard let userID = Auth.auth().currentUser?.uid else { return }
//        
//        let userData: [String: Any] = [
//            "name": nameTextField.text ?? "",
//            "surname": surnameTextField.text ?? "",
//            "city": cityTextField.text ?? "",
//            "phone": phoneTextField.text ?? "",
//            "email": emailTextField.text ?? "",
//            "gender": genderSegmentedControl.selectedSegmentIndex == 0 ? "Муж" : "Жен"
//        ]
//        
//        
//        //подключение к дб
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userID)
//        
//        saveButton.isEnabled = false
//        activityIndicator.startAnimating()
//        
//        userRef.setData(userData) { error in
//            self.saveButton.isEnabled = true
//            self.activityIndicator.stopAnimating()
//            
//            if let error = error {
//                self.showAlert(message: "Ошибка сохранения данных: \(error.localizedDescription)")
//            } else {
//                self.showAlert(message: "Данные успешно сохранены!")
//            }
//        }
//    }
//
//    private func showAlert(message: String) {
//        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    
//    
//    private func removeAllNotifications() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        print("Все уведомления удалены")
//    }
//    
//    
//    
//    
//
//    @objc private func logoutButtonTapped() {
////        do {
////            // Очищаем все уведомления перед выходом
////            removeAllNotifications()
////            
////            // разлогин
////            try Auth.auth().signOut()
////            
////            // Очистка полей
////            self.nameTextField.text = ""
////            self.surnameTextField.text = ""
////            self.cityTextField.text = ""
////            self.phoneTextField.text = ""
////            self.emailTextField.text = ""
////            self.genderSegmentedControl.selectedSegmentIndex = 0
////            self.avatarImageView.image = UIImage(systemName: "person.circle.fill")
////            
////            // скока можно тебя пилить
////            // переход на окно логирования
////            let authVC = AuthViewController()
////            let navController = UINavigationController(rootViewController: authVC)
////            navController.modalPresentationStyle = .fullScreen
////            self.present(navController, animated: true, completion: nil)
////        } catch {
////            print("Ошибка при выходе из аккаунта: \(error.localizedDescription)")
////        }
//    }
//    
//    
//    
//
//    
//    private func loadUserData() {
//        guard let userID = Auth.auth().currentUser?.uid else {
//            // ты кто такой, чепушила, иди регайся
//            
//            
//            
//            let authVC = AuthViewController()
//            let navController = UINavigationController(rootViewController: authVC)
//            navController.modalPresentationStyle = .fullScreen
//            self.present(navController, animated: true, completion: nil)
//            return
//        }
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userID)
//        
//        userRef.getDocument { document, error in
//            if let error = error {
//                print("Ошибка загрузки данных: \(error.localizedDescription)")
//                return
//            }
//            
//            if let document = document, document.exists {
//                let data = document.data()
//                self.nameTextField.text = data?["name"] as? String
//                self.surnameTextField.text = data?["surname"] as? String
//                self.cityTextField.text = data?["city"] as? String
//                self.phoneTextField.text = data?["phone"] as? String
//                self.emailTextField.text = data?["email"] as? String
//                let gender = data?["gender"] as? String ?? "Муж"
//                self.genderSegmentedControl.selectedSegmentIndex = (gender == "Муж") ? 0 : 1
//            }
//        }
//    }
//    
//    
//    
//
//
//    // MARK: - Keyboard Handling
//
//    private func setupKeyboardHandling() {
//        // Скрываем клавиатуру при нажатии вне текстовых полей
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
//
//        // Настройка уведомлений о клавиатуре
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    @objc private func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
//        scrollView.contentInset = contentInsets
//        scrollView.scrollIndicatorInsets = contentInsets
//    }
//
//    @objc private func keyboardWillHide(notification: NSNotification) {
//        scrollView.contentInset = .zero
//        scrollView.scrollIndicatorInsets = .zero
//    }
//}
//
//
//
//
//
//
//
//
//
