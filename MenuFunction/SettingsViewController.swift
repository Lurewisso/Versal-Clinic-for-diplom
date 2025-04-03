import UIKit
import UserNotifications
import AVFoundation

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Настройки"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("‹ Назад", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Sections
    
    private lazy var notificationSection = createSection(title: "Уведомления", withSwitch: true, action: #selector(notificationSwitchChanged(_:)))
    private lazy var languageSection = createLanguageSection()
    private lazy var privacySection = createSection(title: "Доступ к камере", withSwitch: true, action: #selector(cameraSwitchChanged(_:)))
    private lazy var soundSection = createSection(title: "Звуковые эффекты", withSwitch: true, action: #selector(soundSwitchChanged(_:)))
    private lazy var themeSection = createThemeSection()
    private lazy var resetSection = createActionSection(title: "Сбросить настройки", action: #selector(resetButtonTapped))
    private lazy var aboutSection = createActionSection(title: "О приложении", action: #selector(aboutButtonTapped))
    private lazy var rateSection = createActionSection(title: "Оценить приложение", action: #selector(rateButtonTapped))
    private lazy var shareSection = createActionSection(title: "Поделиться приложением", action: #selector(shareButtonTapped))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Настройка градиентного фона
        setupGradientBackground()
        
        // Добавление элементов
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Добавление секций
        let sections = [
            notificationSection,
            languageSection,
            privacySection,
            soundSection,
            themeSection,
            resetSection,
            aboutSection,
            rateSection,
            shareSection
        ]
        
        sections.forEach { contentView.addSubview($0) }
        
        // Настройка навигации
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Расположение секций
        var previousSection: UIView?
        
        for section in contentView.subviews {
            NSLayoutConstraint.activate([
                section.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                section.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                section.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            if let previous = previousSection {
                section.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 12).isActive = true
            } else {
                section.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            }
            
            previousSection = section
        }
        
        if let lastSection = previousSection {
            contentView.bottomAnchor.constraint(equalTo: lastSection.bottomAnchor, constant: 20).isActive = true
        }
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        if let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Section Creators
    
    private func createSection(title: String, withSwitch: Bool, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16)
        ])
        
        if withSwitch {
            let toggle = UISwitch()
            toggle.onTintColor = UIColor(red: 0.33, green: 0.27, blue: 0.58, alpha: 1.0)
            toggle.isOn = UserDefaults.standard.bool(forKey: "\(title)Enabled")
            toggle.addTarget(self, action: action, for: .valueChanged)
            toggle.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(toggle)
            
            NSLayoutConstraint.activate([
                toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
            ])
        }
        
        return container
    }
    
    private func createLanguageSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = "Язык"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        let segmentedControl = UISegmentedControl(items: ["Русский", "English"])
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.33, green: 0.27, blue: 0.58, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "selectedLanguage")
        segmentedControl.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            segmentedControl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            segmentedControl.widthAnchor.constraint(equalToConstant: 180)
        ])
        
        return container
    }
    
    private func createThemeSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = "Тема"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        let themeControl = UISegmentedControl(items: ["Тёмная", "Светлая"])
        themeControl.selectedSegmentTintColor = UIColor(red: 0.33, green: 0.27, blue: 0.58, alpha: 1.0)
        themeControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        themeControl.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
        themeControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "darkThemeEnabled") ? 0 : 1
        themeControl.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        themeControl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(themeControl)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            themeControl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            themeControl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            themeControl.widthAnchor.constraint(equalToConstant: 180)
        ])
        
        return container
    }
    
    private func createActionSection(title: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        container.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tapGesture)
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        let icon = UIImageView(image: UIImage(systemName: "chevron.right"))
        icon.tintColor = .lightGray
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 12),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notificationsEnabled")
        
        if sender.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    if !granted {
                        sender.isOn = false
                        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                        self.showPermissionAlert(for: .notifications)
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    @objc private func languageChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedLanguage")
        showRestartAlert()
    }
    
    @objc private func cameraSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "cameraAccessEnabled")
        
        if sender.isOn {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        sender.isOn = false
                        UserDefaults.standard.set(false, forKey: "cameraAccessEnabled")
                        self.showPermissionAlert(for: .camera)
                    }
                }
            }
        }
    }
    
    @objc private func soundSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "soundEnabled")
        // Здесь можно добавить логику включения/выключения звуков
    }
    
    @objc private func themeChanged(_ sender: UISegmentedControl) {
        let darkTheme = sender.selectedSegmentIndex == 0
        UserDefaults.standard.set(darkTheme, forKey: "darkThemeEnabled")
        showRestartAlert()
    }
    
    @objc private func resetButtonTapped() {
        let alert = UIAlertController(
            title: "Сбросить настройки?",
            message: "Все настройки будут возвращены к значениям по умолчанию",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сбросить", style: .destructive, handler: { _ in
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            self.showRestartAlert()
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func aboutButtonTapped() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @objc private func rateButtonTapped() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    @objc private func shareButtonTapped() {
        let text = "Попробуйте это приложение!"
        guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [text, url],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    @objc private func appDidBecomeActive() {
        // Обновляем состояние переключателей при возвращении в приложение
        updateSwitchesState()
    }
    
    // MARK: - Helpers
    
    private func updateSwitchesState() {
        // Обновляем состояние переключателя камеры
        if let cameraSwitch = privacySection.subviews.compactMap({ $0 as? UISwitch }).first {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            cameraSwitch.isOn = status == .authorized && UserDefaults.standard.bool(forKey: "cameraAccessEnabled")
        }
        
        // Обновляем состояние переключателя уведомлений
        if let notificationSwitch = notificationSection.subviews.compactMap({ $0 as? UISwitch }).first {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationSwitch.isOn = settings.authorizationStatus == .authorized && UserDefaults.standard.bool(forKey: "notificationsEnabled")
                }
            }
        }
    }
    
    private func showPermissionAlert(for type: PermissionType) {
        let title: String
        let message: String
        
        switch type {
        case .camera:
            title = "Доступ к камере запрещен"
            message = "Пожалуйста, разрешите доступ к камере в настройках"
        case .notifications:
            title = "Уведомления запрещены"
            message = "Пожалуйста, разрешите уведомления в настройках"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Настройки", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl)
        }))
        
        present(alert, animated: true)
    }
    
    private func showRestartAlert() {
        let alert = UIAlertController(
            title: "Перезапустите приложение",
            message: "Для применения изменений требуется перезапуск",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Enums
    
    private enum PermissionType {
        case camera
        case notifications
    }
}
