//
//  StartScreenViewController.swift
//  VersalClinic
//
//  Created by Rahim Lutsenko on 14.03.2025.
//


import Foundation
import UIKit
import FirebaseAuth

class StartScreenViewController: UIViewController {
    
    private let logoImageView = UIImageView() // UIImageView для логотипа
    private let firstNameLabel = UILabel()
    private let slogan = UILabel()
    private let emptyTextAbout = UILabel()
    private let logInBtn = UIButton()
    private let signUpBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //test>
        if Auth.auth().currentUser != nil {
            navigateToMainScreen()
        }
        //test<
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // Настройка UIImageView для логотипа
        logoImageView.image = UIImage(named: "AppLogo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка заголовка
        firstNameLabel.text = "Versal Clinic"
//        firstNameLabel.font = UIFont.italicSystemFont(ofSize: 40)
        firstNameLabel.font = UIFont.systemFont(ofSize: 60, weight: .thin)
        
        firstNameLabel.textColor = .blue
        firstNameLabel.textAlignment = .center
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка слогана
        slogan.text = "Make your health stronger with you"
        slogan.font = UIFont.systemFont(ofSize: 15, weight: .thin) // Увеличил размер шрифта
        slogan.textColor = .systemBlue
        slogan.textAlignment = .center
        slogan.numberOfLines = 0
        slogan.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка текста о правах
        emptyTextAbout.text = "All rights reserved"
        emptyTextAbout.font = UIFont.systemFont(ofSize: 12, weight: .thin) // Увеличил размер шрифта
        emptyTextAbout.textColor = .tertiaryLabel
        emptyTextAbout.textAlignment = .center
        emptyTextAbout.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка кнопки входа
        logInBtn.setTitle("Войти", for: .normal)
        logInBtn.backgroundColor = .systemBlue
        logInBtn.layer.cornerRadius = 25
        logInBtn.layer.shadowColor = UIColor.systemBlue.cgColor
        logInBtn.layer.shadowOpacity = 0.5
        logInBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        logInBtn.layer.shadowRadius = 4
        logInBtn.addTarget(self, action: #selector(logInBtnTapped), for: .touchUpInside)
        logInBtn.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка кнопки регистрации
        signUpBtn.setTitle("Регистрация", for: .normal)
//        signUpBtn.backgroundColor = UIColor(red: 152/255, green: 255/255, blue: 152/255, alpha: 1)
        signUpBtn.backgroundColor = .systemGreen
        signUpBtn.setTitleColor(.white, for: .normal)
        signUpBtn.layer.cornerRadius = 25
        signUpBtn.layer.shadowColor = UIColor.systemBlue.cgColor
        signUpBtn.layer.shadowOpacity = 0.3
        signUpBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        signUpBtn.layer.shadowRadius = 4
        signUpBtn.addTarget(self, action: #selector(signUpBtnTapped), for: .touchUpInside)
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавление элементов на экран
        view.addSubview(logoImageView)
        view.addSubview(firstNameLabel)
        view.addSubview(slogan)
        view.addSubview(emptyTextAbout)
        view.addSubview(logInBtn)
        view.addSubview(signUpBtn)
        
        // Настройка констрейнтов
        NSLayoutConstraint.activate([
            // Логотип
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5), // Адаптивный размер
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor), // Квадратное изображение
            
            // Заголовок
            firstNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Слоган
            slogan.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 10),
            slogan.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slogan.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Текст о правах
//            emptyTextAbout.topAnchor.constraint(equalTo: slogan.bottomAnchor, constant: 10),
//            emptyTextAbout.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            emptyTextAbout.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Кнопка входа
            logInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центрируем по горизонтали
            logInBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5), // Ширина = 50% от ширины экрана
            logInBtn.bottomAnchor.constraint(equalTo: signUpBtn.topAnchor, constant: -20),
            logInBtn.heightAnchor.constraint(equalToConstant: 50),
            
            // Кнопка регистрации
            signUpBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центрируем по горизонтали
            signUpBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5), // Ширина = 50% от ширины экрана
            signUpBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpBtn.heightAnchor.constraint(equalToConstant: 50),
            
            
            emptyTextAbout.topAnchor.constraint(equalTo: signUpBtn.bottomAnchor, constant: 10),
            emptyTextAbout.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyTextAbout.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func signUpBtnTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func logInBtnTapped() {
        let authVC = AuthViewController()
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //test>
    private func navigateToMainScreen() {
        let mainViewController = MainViewController()
        navigationController?.setViewControllers([mainViewController], animated: true)
    }
    //test<
}
