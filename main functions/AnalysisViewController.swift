

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import PDFKit
import UniformTypeIdentifiers

class AnalysisViewController: UIViewController {

    // MARK: - UI Elements

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private let exportToPDFButton = UIButton(type: .system)

    private var analyses: [Analysis] = [] // хранения анализов

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        loadAnalyses() //  данные при запуске
        let backButton = UIBarButtonItem(title: "ᐸ Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white // Белый цвет кнопки
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        // хэдер
        titleLabel.text = "Анализы"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        titleLabel.textColor = .label // Адаптивный цвет текста
        titleLabel.textColor = .white // Адаптивный цвет текста
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Таблица анализес
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AnalysisCell.self, forCellReuseIdentifier: "AnalysisCell")
        tableView.backgroundColor = .clear // Прозрачный фон таблицы
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false

    
        setupButton(
            addButton,
            title: "Добавить анализ",
            icon: "plus.circle.fill",
            action: #selector(addButtonTapped),
            color: .systemMint
        )

        
        setupButton(
            exportToPDFButton,
            title: "Сохранить как PDF",
            icon: "doc.fill",
            action: #selector(exportToPDFButtonTapped),
            color: .systemGreen
        )

       
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(exportToPDFButton)

     
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

          
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: exportToPDFButton.topAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),

            exportToPDFButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportToPDFButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exportToPDFButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            exportToPDFButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupButton(_ button: UIButton, title: String, icon: String, action: Selector, color: UIColor) {
       
        let iconImage = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(iconImage, for: .normal)
        button.tintColor = .white

        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

       
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false

        
        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpOutside)

        // цель
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    // MARK: - Button Animations

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

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let addAnalysisVC = AddAnalysisViewController()
        addAnalysisVC.delegate = self
        let navController = UINavigationController(rootViewController: addAnalysisVC)
        present(navController, animated: true)
    }

    @objc private func exportToPDFButtonTapped() {
        let pdfData = createPDF()
        savePDFToFiles(pdfData: pdfData)
    }

    // MARK: - PDF Creation

    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Анализы",
            kCGPDFContextAuthor: "Пользователь",
            kCGPDFContextTitle: "Список анализов"
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

            for analysis in analyses {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: analysis.date)

                // Форматируем текст с подписями
                let text = """
                Название анализа: \(analysis.name)
                Дата анализа: \(dateString)
                Показатель: \(analysis.result)
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
        let pdfURL = temporaryDirectory.appendingPathComponent("Анализы.pdf")

        do {
            try pdfData.write(to: pdfURL)
            let documentPicker = UIDocumentPickerViewController(forExporting: [pdfURL], asCopy: true)
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        } catch {
            showAlert(message: "Ошибка при создании PDF: \(error.localizedDescription)")
        }
    }

    // Загрузка анализов из Firestore
    private func loadAnalyses() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("analyses")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(message: "Ошибка загрузки анализов: \(error.localizedDescription)")
                    return
                }

                self.analyses = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return Analysis(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        result: data["result"] as? String ?? "",
                        imageURL: data["imageURL"] as? String
                    )
                } ?? []

                self.tableView.reloadData()
            }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AnalysisViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnalysisCell", for: indexPath) as! AnalysisCell
        let analysis = analyses[indexPath.row]
        cell.configure(with: analysis)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let analysis = analyses[indexPath.row]
        let detailVC = AddAnalysisViewController(analysis: analysis)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.deleteAnalysis(at: indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteAnalysis(at indexPath: IndexPath) {
        let analysis = analyses[indexPath.row]
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("analyses").document(analysis.id).delete { error in
            if let error = error {
                self.showAlert(message: "Ошибка удаления анализа: \(error.localizedDescription)")
            } else {
                self.analyses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension AnalysisViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Файл уже сохранен системой, просто показываем уведомление
        showAlert(message: "Файл успешно сохранен!")
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Пользователь отменил выбор места сохранения
        showAlert(message: "Сохранение отменено.")
    }
}

// MARK: - AddAnalysisDelegate

extension AnalysisViewController: AddAnalysisDelegate {
    func didAddAnalysis(_ analysis: Analysis) {
        analyses.append(analysis)
        tableView.reloadData()
    }
}

// MARK: - AnalysisCell

class AnalysisCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let resultLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Настройка элементов ячейки
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .label // Адаптивный цвет текста
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .label // Адаптивный цвет текста
        resultLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        resultLabel.textColor = .label // Адаптивный цвет текста

        let stackView = UIStackView(arrangedSubviews: [nameLabel, dateLabel, resultLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with analysis: Analysis) {
        nameLabel.text = analysis.name
        dateLabel.text = "Дата: \(analysis.date.formatted())"
        resultLabel.text = "Результат: \(analysis.result)"
    }
}

// MARK: - AddAnalysisViewController

protocol AddAnalysisDelegate: AnyObject {
    func didAddAnalysis(_ analysis: Analysis)
}

class AddAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let nameTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let resultTextField = UITextField()
    private let imageView = UIImageView()
    private let uploadButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    weak var delegate: AddAnalysisDelegate?

    private var analysis: Analysis?

    init(analysis: Analysis? = nil) {
        self.analysis = analysis
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        setupNavigationBar() // Добавляем кнопку "Назад"

        if let analysis = analysis {
            nameTextField.text = analysis.name
            datePicker.date = analysis.date
            resultTextField.text = analysis.result
        }
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    private func setupUI() {
        // текстовые поля
        nameTextField.placeholder = "Название анализа"
        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8) // фикс белый фон с прозрачностью
        nameTextField.textColor = .black // фикс черный текст
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Название анализа",
            attributes: [.foregroundColor: UIColor.gray] // фикс серый цвет плейсхолдера
        )
        nameTextField.translatesAutoresizingMaskIntoConstraints = false

        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        resultTextField.placeholder = "Результат"
        resultTextField.borderStyle = .roundedRect
        resultTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8) // фикс белый фон с прозрачностью
        resultTextField.textColor = .black // фикс черный текст
        resultTextField.attributedPlaceholder = NSAttributedString(
            string: "Результат",
            attributes: [.foregroundColor: UIColor.gray] // фикс серый цвет плейсхолдера
        )
        resultTextField.translatesAutoresizingMaskIntoConstraints = false

        //  imageView
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Настройка кнопок
        setupButton(uploadButton, title: "Загрузить изображение", icon: "photo.fill", action: #selector(uploadButtonTapped), color: .systemBlue)
        setupButton(saveButton, title: "Сохранить", icon: "checkmark.circle.fill", action: #selector(saveButtonTapped), color: .systemGreen)

        // Создание stackView
        let stackView = UIStackView(arrangedSubviews: [nameTextField, datePicker, resultTextField, imageView, uploadButton, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Добавление элементов на экран
        view.addSubview(stackView)

        // Констрейнты
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupButton(_ button: UIButton, title: String, icon: String, action: Selector, color: UIColor = .systemBlue) {
        let iconImage = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(iconImage, for: .normal)
        button.tintColor = .white

        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpOutside)

        button.addTarget(self, action: action, for: .touchUpInside)

        // Увеличиваем высоту кнопок
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
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

    @objc private func uploadButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let result = resultTextField.text, !result.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }

        let analysis = Analysis(id: UUID().uuidString, name: name, date: datePicker.date, result: result, imageURL: nil)

        saveAnalysisToFirestore(analysis)

        delegate?.didAddAnalysis(analysis)
        dismiss(animated: true)
    }

    private func saveAnalysisToFirestore(_ analysis: Analysis) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).collection("analyses").document(analysis.id).setData([
            "id": analysis.id,
            "name": analysis.name,
            "date": analysis.date,
            "result": analysis.result,
            "imageURL": analysis.imageURL ?? ""
        ]) { error in
            if let error = error {
                self.showAlert(message: "Ошибка сохранения анализа: \(error.localizedDescription)")
            } else {
                print("Анализ успешно сохранен в Firestore")
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
// MARK: - Analysis Model

struct Analysis {
    let id: String
    let name: String
    let date: Date
    let result: String
    let imageURL: String?
}


