

import UIKit
import FirebaseFirestore
import FirebaseAuth
import PDFKit
import UniformTypeIdentifiers

class DiaryViewController: UIViewController {

    // MARK: - UI Elements

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Дневник самочувствия"
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск записей"
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .white
        searchBar.tintColor = .white
        searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.2)
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск записей",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .white.withAlphaComponent(0.2)
        textView.textColor = .white
        textView.tintColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить запись", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let exportToPDFButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить в PDF", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .systemGray4
        tableView.layer.cornerRadius = 12
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var diaryEntries: [DiaryEntry] = []
    private var filteredEntries: [DiaryEntry] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        loadDiaryEntries()

        //  жест для закрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // хватит печатать , закрывай свой станок
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Setup Background

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

    // MARK: - Setup UI

    private func setupUI() {
        // Настройка элементов
        textView.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

       
        saveButton.setTitle("Сохранить запись", for: .normal)
        saveButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal) // Иконка
        saveButton.tintColor = .white // Цвет иконки
        saveButton.backgroundColor = .systemMint
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.contentHorizontalAlignment = .left
        saveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

       
        exportToPDFButton.setTitle("Сохранить в PDF", for: .normal)
        exportToPDFButton.setImage(UIImage(systemName: "doc.fill"), for: .normal) // Иконка
        exportToPDFButton.tintColor = .white // Цвет иконки
        exportToPDFButton.backgroundColor = .systemGreen
        exportToPDFButton.layer.cornerRadius = 12
        exportToPDFButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        exportToPDFButton.contentHorizontalAlignment = .left
        exportToPDFButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
        exportToPDFButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
        exportToPDFButton.addTarget(self, action: #selector(exportToPDFButtonTapped), for: .touchUpInside)

      
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(textView)
        view.addSubview(saveButton)
        view.addSubview(exportToPDFButton)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 120),

            saveButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            exportToPDFButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            exportToPDFButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportToPDFButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exportToPDFButton.heightAnchor.constraint(equalToConstant: 50),

            // Таблица занимает всю ширину экрана
            tableView.topAnchor.constraint(equalTo: exportToPDFButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), // Убрали отступ слева
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor), // Убрали отступ справа
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func saveButtonTapped() {
        guard let text = textView.text, !text.isEmpty else {
            showAlert(message: "Заполните поле")
            return
        }
        saveDiaryEntry(text: text)
    }

    @objc private func exportToPDFButtonTapped() {
        let pdfData = createPDF()
        savePDFToFiles(pdfData: pdfData)
    }

    // MARK: - PDF Creation

    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Мой дневник",
            kCGPDFContextAuthor: "Пользователь",
            kCGPDFContextTitle: "Дневник записей"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0 // Ширина страницы A4
        let pageHeight = 792.0 // Высота страницы A4
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            var currentY = 50.0

            for entry in diaryEntries {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                let dateString = dateFormatter.string(from: entry.date)

                // Форматируем текст 
                let text = """
                Дата: \(dateString)
                Запись: \(entry.text)
                """
                
                // Разделяем текст на строки и рисуем каждую строку отдельно
                let lines = text.components(separatedBy: "\n")
                for line in lines {
                    line.draw(at: CGPoint(x: 50, y: currentY), withAttributes: attributes)
                    currentY += 20 // Переход на следующую строку
                }
                currentY += 20 // Добавляем отступ между записями
            }
        }
        return data
    }

    private func savePDFToFiles(pdfData: Data) {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let pdfURL = temporaryDirectory.appendingPathComponent("Дневник.pdf")

        do {
            try pdfData.write(to: pdfURL)
            let documentPicker = UIDocumentPickerViewController(forExporting: [pdfURL], asCopy: true)
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        } catch {
            showAlert(message: "Ошибка при создании PDF: \(error.localizedDescription)")
        }
    }

    // MARK: - Firestore Operations

    private func saveDiaryEntry(text: String) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        saveButton.isEnabled = false
        activityIndicator.startAnimating()

        let newEntry = DiaryEntry(id: UUID().uuidString, text: text, date: Date())
        diaryEntries.insert(newEntry, at: 0)
        filteredEntries = diaryEntries
        tableView.reloadData()

        db.collection("diaryEntries").addDocument(data: [
            "userId": user.uid,
            "text": text,
            "date": Date()
        ]) { error in
            self.saveButton.isEnabled = true
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                self.diaryEntries.removeFirst()
                self.filteredEntries = self.diaryEntries
                self.tableView.reloadData()
            } else {
                self.textView.text = ""
            }
        }
    }

    private func loadDiaryEntries(completion: (() -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        activityIndicator.startAnimating()

        db.collection("diaryEntries")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                self.activityIndicator.stopAnimating()

                if let error = error {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                    return
                }

                self.diaryEntries = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return DiaryEntry(
                        id: doc.documentID,
                        text: data["text"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                self.filteredEntries = self.diaryEntries
                self.tableView.reloadData()

                if self.diaryEntries.isEmpty {
                    let messageLabel = UILabel()
                    messageLabel.text = "Записей пока нет"
                    messageLabel.textColor = .white
                    messageLabel.textAlignment = .center
                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                }

                completion?()
            }
    }

    private func editDiaryEntry(at index: Int, newText: String) {
        let entry = filteredEntries[index]
        let db = Firestore.firestore()

        diaryEntries[index].text = newText
        filteredEntries = diaryEntries
        tableView.reloadData()

        db.collection("diaryEntries").document(entry.id).updateData([
            "text": newText
        ]) { error in
            if let error = error {
                self.showAlert(message: "Ошибка обновления: \(error.localizedDescription)")
                self.diaryEntries[index].text = entry.text
                self.filteredEntries = self.diaryEntries
                self.tableView.reloadData()
            }
        }
    }

    private func deleteDiaryEntry(at index: Int) {
        let entry = filteredEntries[index]
        let db = Firestore.firestore()

        db.collection("diaryEntries").document(entry.id).delete { error in
            if let error = error {
                self.showAlert(message: "Ошибка удаления: \(error.localizedDescription)")
            } else {
                self.diaryEntries.remove(at: index)
                self.filteredEntries = self.diaryEntries
                self.tableView.reloadData()
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = filteredEntries[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = dateFormatter.string(from: entry.date)

        cell.textLabel?.text = "\(dateString): \(entry.text)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let entry = filteredEntries[indexPath.row]
        let alert = UIAlertController(title: "Редактировать запись", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = entry.text
        }
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            if let newText = alert.textFields?.first?.text, !newText.isEmpty {
                self.editDiaryEntry(at: indexPath.row, newText: newText)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completionHandler in
            self.deleteDiaryEntry(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchBarDelegate
extension DiaryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredEntries = searchText.isEmpty ? diaryEntries : diaryEntries.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
        tableView.reloadData()
    }
}

// MARK: - UITextViewDelegate
extension DiaryViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - UIDocumentPickerDelegate
extension DiaryViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        showAlert(message: "Файл успешно сохранен!")
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        showAlert(message: "Сохранение отменено.")
    }
}

struct DiaryEntry {
    let id: String
    var text: String
    let date: Date
}






































