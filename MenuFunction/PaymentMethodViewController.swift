import UIKit
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication // Импортируем LocalAuthentication

class PaymentMethodViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PaymentMethodCell.self, forCellReuseIdentifier: PaymentMethodCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let addCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить карту", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var paymentMethods: [PaymentMethod] = []
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPaymentMethods()
        
        
        let backButton = UIBarButtonItem(title: "ᐸ Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    

    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Способы оплаты"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(addCardButton)
        addCardButton.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: addCardButton.topAnchor, constant: -20),
            
            addCardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCardButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Load Payment Methods
    
    private func loadPaymentMethods() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("paymentMethods").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки карт: \(error.localizedDescription)")
                return
            }
            
            self.paymentMethods.removeAll()
            for document in snapshot?.documents ?? [] {
                if let cardToken = document.data()["cardToken"] as? String,
                   let last4 = document.data()["last4"] as? String,
                   let expiryDate = document.data()["expiryDate"] as? String {
                    let paymentMethod = PaymentMethod(cardToken: cardToken, last4: last4, expiryDate: expiryDate, documentId: document.documentID)
                    self.paymentMethods.append(paymentMethod)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Add Card
    
    @objc private func addCardTapped() {
        let alert = UIAlertController(title: "Добавить карту", message: "Введите данные карты", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Номер карты"
        }
        alert.addTextField { textField in
            textField.placeholder = "Срок действия (ММ/ГГ)"
        }
        alert.addTextField { textField in
            textField.placeholder = "CVV"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            guard let self = self,
                  let cardNumber = alert.textFields?[0].text,
                  let expiryDate = alert.textFields?[1].text,
                  let cvv = alert.textFields?[2].text else { return }
            
            let cardToken = "tok_visa" // Пример токена
            let last4 = String(cardNumber.suffix(4))
            self.saveCardToken(cardToken, last4: last4, expiryDate: expiryDate)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveCardToken(_ cardToken: String, last4: String, expiryDate: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "cardToken": cardToken,
            "last4": last4,
            "expiryDate": expiryDate,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).collection("paymentMethods").addDocument(data: data) { error in
            if let error = error {
                print("Ошибка сохранения карты: \(error.localizedDescription)")
            } else {
                print("Карта успешно сохранена")
                self.loadPaymentMethods()
            }
        }
    }
    
    // MARK: - Delete Card
    
    private func deleteCard(at index: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let paymentMethod = paymentMethods[index]
        
        db.collection("users").document(userId).collection("paymentMethods")
            .document(paymentMethod.documentId)
            .delete { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Ошибка удаления карты: \(error.localizedDescription)")
                } else {
                    print("Карта успешно удалена")
                    self.paymentMethods.remove(at: index)
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Edit Card
    
    private func editCard(at index: Int) {
        let paymentMethod = paymentMethods[index]
        
        let alert = UIAlertController(title: "Изменить данные карты", message: "Введите новые данные", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Номер карты"
            textField.text = "**** **** **** \(paymentMethod.last4)"
        }
        alert.addTextField { textField in
            textField.placeholder = "Срок действия (ММ/ГГ)"
            textField.text = paymentMethod.expiryDate
        }
        alert.addTextField { textField in
            textField.placeholder = "CVV"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            guard let self = self,
                  let cardNumber = alert.textFields?[0].text,
                  let expiryDate = alert.textFields?[1].text,
                  let cvv = alert.textFields?[2].text else { return }
            
            // Запрашиваем аутентификацию перед изменением данных карты
            self.authenticateUser { success in
                if success {
                    // Если аутентификация успешна, обновляем данные карты
                    self.updateCard(at: index, cardNumber: cardNumber, expiryDate: expiryDate)
                } else {
                    // Если аутентификация не удалась, показываем сообщение
                    let errorAlert = UIAlertController(title: "Ошибка", message: "Аутентификация не удалась", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateCard(at index: Int, cardNumber: String, expiryDate: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let paymentMethod = paymentMethods[index]
        let last4 = String(cardNumber.suffix(4))
        
        db.collection("users").document(userId).collection("paymentMethods")
            .document(paymentMethod.documentId)
            .updateData([
                "last4": last4,
                "expiryDate": expiryDate
            ]) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Ошибка обновления карты: \(error.localizedDescription)")
                } else {
                    print("Данные карты успешно обновлены")
                    self.paymentMethods[index].last4 = last4
                    self.paymentMethods[index].expiryDate = expiryDate
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Face ID/Touch ID Authentication
    
    private func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Проверяем, доступна ли аутентификация через Face ID/Touch ID
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Для изменения номера карты требуется аутентификация"
            
            // Запрашиваем аутентификацию
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true) // Аутентификация успешна
                    } else {
                        if let error = authenticationError as? LAError {
                            print("Ошибка аутентификации: \(error.localizedDescription)")
                        }
                        completion(false) // Аутентификация не удалась
                    }
                }
            }
        } else {
            // Если Face ID/Touch ID недоступен, используем пароль
            let alert = UIAlertController(title: "Аутентификация", message: "Введите пароль", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "Пароль"
            }
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let password = alert.textFields?.first?.text, password == "1234" { // Пример пароля
                    completion(true)
                } else {
                    completion(false)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension PaymentMethodViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.identifier, for: indexPath) as! PaymentMethodCell
        let paymentMethod = paymentMethods[indexPath.row]
        cell.configure(with: paymentMethod)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteCard(at: indexPath.row)
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { [weak self] _, _, completion in
            self?.editCard(at: indexPath.row)
            completion(true)
        }
        
        editAction.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let paymentMethod = paymentMethods[indexPath.row]
        showCardDetails(paymentMethod)
    }
    
    private func showCardDetails(_ paymentMethod: PaymentMethod) {
        let alert = UIAlertController(title: "Данные карты", message: "Последние 4 цифры: \(paymentMethod.last4)\nСрок действия: \(paymentMethod.expiryDate)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - PaymentMethodCell

class PaymentMethodCell: UITableViewCell {
    static let identifier = "PaymentMethodCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "creditcard.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expiryDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(cardIcon)
        cardView.addSubview(cardNumberLabel)
        cardView.addSubview(expiryDateLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            cardIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            cardIcon.widthAnchor.constraint(equalToConstant: 24),
            cardIcon.heightAnchor.constraint(equalToConstant: 24),
            
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardIcon.trailingAnchor, constant: 16),
            cardNumberLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            
            expiryDateLabel.leadingAnchor.constraint(equalTo: cardIcon.trailingAnchor, constant: 16),
            expiryDateLabel.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with paymentMethod: PaymentMethod) {
        cardNumberLabel.text = "Карта **** \(paymentMethod.last4)"
        expiryDateLabel.text = "Срок действия: \(paymentMethod.expiryDate)"
    }
}

// MARK: - PaymentMethod Model

struct PaymentMethod {
    let cardToken: String
    var last4: String
    var expiryDate: String
    let documentId: String
}
