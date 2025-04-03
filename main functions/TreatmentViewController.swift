
import UIKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class TreatmentViewController: UIViewController {
    private let backgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

    private let tableView = UITableView()
    private let addButton = UIButton()
    private let bookAppointmentButton = UIButton()
    private let db = Firestore.firestore()
    private let titleLabel = UILabel()

    private var medications: [Medication] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
        setupBackground()
        setupUI()
        setupNotifications()
        loadMedications()
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor, // Глубокий фиолетовый
            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor  // Глубокий синий
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
    // MARK: - UI Setup

    private func setupUI() {
        
        titleLabel.text = "Ваше лечение"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//            titleLabel.textColor = .label // Адаптивный цвет текста
        titleLabel.textColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        
        addButton.setTitle("Добавить лекарство", for: .normal)
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal) // Иконка
        addButton.tintColor = .white
        addButton.backgroundColor = .systemMint
        addButton.layer.cornerRadius = 8
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.contentHorizontalAlignment = .left
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
        addButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

   
        bookAppointmentButton.setTitle("Записаться к врачу", for: .normal)
        bookAppointmentButton.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        bookAppointmentButton.tintColor = .white // Цвет иконки
        bookAppointmentButton.backgroundColor = .systemGreen
        bookAppointmentButton.layer.cornerRadius = 8
        bookAppointmentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        bookAppointmentButton.contentHorizontalAlignment = .left
        bookAppointmentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
        bookAppointmentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
        bookAppointmentButton.addTarget(self, action: #selector(bookAppointmentButtonTapped), for: .touchUpInside)
        bookAppointmentButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(bookAppointmentButton)

        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),

            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: bookAppointmentButton.topAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),

            
            bookAppointmentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bookAppointmentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bookAppointmentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bookAppointmentButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "Добавить лекарство", message: "Введите данные", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Название лекарства" }
        alert.addTextField { $0.placeholder = "Время (например, 08:00)"; $0.keyboardType = .numbersAndPunctuation }
        alert.addTextField { $0.placeholder = "Условия приема (например, за 30 минут до еды)" }

        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let time = alert.textFields?[1].text, !time.isEmpty,
                  let condition = alert.textFields?[2].text else {
                self.showAlert(message: "Заполните все поля")
                return
            }
            let medication = Medication(id: UUID().uuidString, name: name, time: time, condition: condition)
            self.saveMedication(medication)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func bookAppointmentButtonTapped() {
        let bookAppointmentVC = BookAppointmentViewController()
        self.navigationController?.pushViewController(bookAppointmentVC, animated: true)
    }

    // MARK: - Firebase Operations

    private func saveMedication(_ medication: Medication) {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "Пользователь не авторизован")
            return
        }

        db.collection("users").document(userID).collection("medications").document(medication.id).setData([
            "name": medication.name,
            "time": medication.time,
            "condition": medication.condition
        ]) { error in
            if let error = error {
                self.showAlert(message: "Ошибка сохранения: \(error.localizedDescription)")
            } else {
                self.medications.append(medication)
                self.tableView.reloadData()
                self.scheduleNotification(for: medication)
            }
        }
    }

    private func loadMedications() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "Пользователь не авторизован")
            return
        }

        db.collection("users").document(userID).collection("medications").getDocuments { snapshot, error in
            if let error = error {
                self.showAlert(message: "Ошибка загрузки: \(error.localizedDescription)")
                return
            }
            self.medications = snapshot?.documents.compactMap {
                let data = $0.data()
                return Medication(id: $0.documentID, name: data["name"] as? String ?? "", time: data["time"] as? String ?? "", condition: data["condition"] as? String ?? "")
            } ?? []
            self.tableView.reloadData()

            // удалить старые уведомления и создать новые для текущего юзера
            self.removeAllNotifications()
            self.medications.forEach { self.scheduleNotification(for: $0) }
        }
    }

    private func deleteMedication(at index: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            showAlert(message: "Пользователь не авторизован")
            return
        }

        let medication = medications[index]
        db.collection("users").document(userID).collection("medications").document(medication.id).delete { error in
            if let error = error {
                self.showAlert(message: "Ошибка удаления: \(error.localizedDescription)")
            } else {
                self.medications.remove(at: index)
                self.tableView.reloadData()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [medication.id])
            }
        }
    }

    // MARK: - Notifications

    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Уведомления разрешены")
            } else {
                print("Уведомления не разрешены")
            }
        }
    }

    private func scheduleNotification(for medication: Medication) {
        let content = UNMutableNotificationContent() // хранит в себе данные лекарства нашего пряника
        content.title = "Время приема лекарства"
        content.body = "Не забудьте принять \(medication.name) в \(medication.time)"
        content.sound = .default

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: medication.time) else { return }

        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        let request = UNNotificationRequest(identifier: medication.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) // центр уведомлений
    }

    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Все уведомления удалены")
    }

    // MARK: - Helpers

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension TreatmentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let medication = medications[indexPath.row]
        cell.textLabel?.text = "\(medication.name) - \(medication.time) (\(medication.condition))"
        return cell
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            deleteMedication(at: indexPath.row)
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completionHandler in
            self.deleteMedication(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
}

// MARK: - Medication Model

struct Medication {
    let id: String
    let name: String
    let time: String
    let condition: String
}








