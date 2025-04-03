

import Foundation
import UIKit
import MessageUI
class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "О приложении"
        
        setupUI()
    }

    private func setupUI() {
        
        let logoImageView = UIImageView(image: UIImage(named: "medical_logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
       
        let appNameLabel = UILabel()
        appNameLabel.text = "Versal Clinic"
        appNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        appNameLabel.textAlignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let versionLabel = UILabel()
        versionLabel.text = "Версия: Бета 2.0"
        versionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        versionLabel.textColor = .secondaryLabel
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = """
        Это приложение создано для удобного учета ваших лекарств, заболеваний и медицинских показателей.
        Здесь вы можете:
        - Вести дневник приема лекарств.
        - Отслеживать симптомы заболеваний.
        - Настраивать напоминания о приемах.
        - Хранить важные медицинские данные.
        """
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let developerLabel = UILabel()
        developerLabel.text = "Разработчик: Команда VersalTech"
        developerLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        developerLabel.textColor = .secondaryLabel
        developerLabel.textAlignment = .center
        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let supportButton = UIButton(type: .system)
        supportButton.setTitle("Связаться с поддержкой", for: .normal)
        supportButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        supportButton.addTarget(self, action: #selector(supportButtonTapped), for: .touchUpInside)
        supportButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(versionLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(developerLabel)
        view.addSubview(supportButton)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            appNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 10),
            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            developerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            developerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            developerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            supportButton.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: 30),
            supportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

  
    @objc private func supportButtonTapped() {
//        if let url = URL(string: "lurewisso@list.ru") {
//            UIApplication.shared.open(url)
        
        let telegramURL = URL(string: "https://t.me/lurewisso")!
        if UIApplication.shared.canOpenURL(telegramURL) {
            UIApplication.shared.open(telegramURL, options: [:], completionHandler: nil)
        } else {
            showAlert(message: "Приложение Telegram не установлено.")
        }
    }
}
