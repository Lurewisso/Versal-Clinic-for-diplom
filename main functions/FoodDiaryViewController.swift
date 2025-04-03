
//private let apiKey = "2f2c1e4ab02aeb28af3c56d1e59399be"
//private let appId = "58852065"



import UIKit
import FirebaseFirestore
import FirebaseAuth
import PDFKit
import UniformTypeIdentifiers //Для работы с типами файлов (PDF)

class FoodDiaryViewController: UIViewController {
    private let backgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        private var foodEntries: [FoodEntry] = []  //Массив для хранения записей о продуктах.
        private var cachedFoods: [String: Double] = [:] // Словарь для кэша
        
        private let apiKey = "2f2c1e4ab02aeb28af3c56d1e59399be"
        private let appId = "58852065"
        
        private let tableView = UITableView()
        private let foodNameTextField = UITextField()
    
    
        private let titleLabel = UILabel()
        private let quantityTextField = UITextField()
        private let caloriesLabel = UILabel()
        private let exportToPDFButton = UIButton()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupBackground()
            if Auth.auth().currentUser == nil {
                print("Пользователь не авторизован")
                // Перенаправить чепуха на регистрацию
            } else {
                setupUI()
                fetchFoodEntries()
                
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
            }
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
        
        private func setupBackground() {
            let gradientLayer = CAGradientLayer()
//            gradientLayer.colors = [
//                UIColor(red: 0.0, green: 0.545, blue: 0.545, alpha: 1.0).cgColor,
//                UIColor(red: 0.125, green: 0.698, blue: 0.667, alpha: 1.0).cgColor
//            ]
//            gradientLayer.colors = [
//                UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0).cgColor, // Светлый сине-голубой (верх)
//                UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0).cgColor  // Более глубокий синий (низ)
//            ]
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
        
        private func setupUI() {
            view.backgroundColor = .systemBackground
            
            
            
            titleLabel.text = "Дневник питания"
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//            titleLabel.textColor = .label // Адаптивный цвет текста
            titleLabel.textColor = .white // Адаптивный цвет текста
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Настройка текстовых полей
            foodNameTextField.placeholder = "Название продукта"
            foodNameTextField.borderStyle = .roundedRect
            foodNameTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8) // фикс белый фон
            foodNameTextField.textColor = .black // фикс черный текст
            foodNameTextField.attributedPlaceholder = NSAttributedString(
                string: "Название продукта",
                attributes: [.foregroundColor: UIColor.gray] // фикс серый плейсхолдер
            )
            foodNameTextField.delegate = self
            foodNameTextField.translatesAutoresizingMaskIntoConstraints = false
            
            quantityTextField.placeholder = "Количество (г)"
            quantityTextField.borderStyle = .roundedRect
            quantityTextField.backgroundColor = UIColor.white.withAlphaComponent(0.8) // фикс белый фон
            quantityTextField.textColor = .black // фикс черный текст
            quantityTextField.attributedPlaceholder = NSAttributedString(
                string: "Количество (г)",
                attributes: [.foregroundColor: UIColor.gray] // фикс серый плейсхолдер
            )
            quantityTextField.keyboardType = .numberPad
            quantityTextField.delegate = self
            quantityTextField.translatesAutoresizingMaskIntoConstraints = false
            
//            caloriesLabel.text = "Калории: "
//            caloriesLabel.textColor = .white
            caloriesLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            let saveButton = UIButton(type: .system)
            saveButton.setTitle("Сохранить запись", for: .normal)
            saveButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            saveButton.tintColor = .white
            saveButton.backgroundColor = .systemMint
            saveButton.layer.cornerRadius = 12
            saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            saveButton.contentHorizontalAlignment = .left
            saveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            
            
            exportToPDFButton.setTitle("Сохранить как PDF", for: .normal)
            exportToPDFButton.setImage(UIImage(systemName: "doc.fill"), for: .normal)
            exportToPDFButton.tintColor = .white
            exportToPDFButton.backgroundColor = .systemGreen
            exportToPDFButton.layer.cornerRadius = 12
            exportToPDFButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            exportToPDFButton.contentHorizontalAlignment = .left
            exportToPDFButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            exportToPDFButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            exportToPDFButton.addTarget(self, action: #selector(exportToPDFButtonTapped), for: .touchUpInside)
            exportToPDFButton.translatesAutoresizingMaskIntoConstraints = false
            
           
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.backgroundColor = .clear
            tableView.separatorColor = .systemGray4
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(titleLabel)
            view.addSubview(foodNameTextField)
            view.addSubview(quantityTextField)
            view.addSubview(caloriesLabel)
            view.addSubview(saveButton)
            view.addSubview(exportToPDFButton)
            view.addSubview(tableView)
            
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
//                foodNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                foodNameTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 40),
                foodNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                foodNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                foodNameTextField.heightAnchor.constraint(equalToConstant: 40),
                
                quantityTextField.topAnchor.constraint(equalTo: foodNameTextField.bottomAnchor, constant: 20),
                quantityTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                quantityTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                quantityTextField.heightAnchor.constraint(equalToConstant: 40),
                
                caloriesLabel.topAnchor.constraint(equalTo: quantityTextField.bottomAnchor, constant: 20),
                caloriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                
                saveButton.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 20),
                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.heightAnchor.constraint(equalToConstant: 50),
                
                exportToPDFButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
                exportToPDFButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                exportToPDFButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                exportToPDFButton.heightAnchor.constraint(equalToConstant: 50),
                
                tableView.topAnchor.constraint(equalTo: exportToPDFButton.bottomAnchor, constant: 20),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    
    @objc private func saveButtonTapped() {
        guard let foodName = foodNameTextField.text, !foodName.isEmpty,
              let quantityText = quantityTextField.text, let quantity = Double(quantityText) else {
            showAlert(title: "Ошибка", message: "Заполните все поля")
            return
        }
        fetchCalories(for: foodName, quantity: quantity)
    }
    
    @objc private func exportToPDFButtonTapped() {
        let pdfData = createPDF()
        savePDFToFiles(pdfData: pdfData)
    }
    
    // MARK: - PDF Creation
    
    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Дневник питания",
            kCGPDFContextAuthor: "Пользователь",
            kCGPDFContextTitle: "Записи о питании"
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

            for entry in foodEntries {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                let dateString = dateFormatter.string(from: entry.date)

                //  текст с подписями
                let text = """
                Время: \(dateString)
                Продукт: \(entry.foodName)
                Количество: \(entry.quantity)g
                Калории: \(entry.calories) ккал
                """
                
                // разделение текста на строки и рисуем каждую строку отдельно
                let lines = text.components(separatedBy: "\n")
                for line in lines {
                    line.draw(at: CGPoint(x: 50, y: currentY), withAttributes: attributes)
                    currentY += 20 //  на следующую строку
                }
                currentY += 20 //  отступ между записями
            }
        }
        return data
    }

    private func savePDFToFiles(pdfData: Data) {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let pdfURL = temporaryDirectory.appendingPathComponent("Дневник_питания.pdf")

        do {
            try pdfData.write(to: pdfURL)
            let documentPicker = UIDocumentPickerViewController(forExporting: [pdfURL], asCopy: true)
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        } catch {
            showAlert(title: "Ошибка", message: "Ошибка при создании PDF: \(error.localizedDescription)")
        }
    }

    private func fetchCalories(for food: String, quantity: Double) {
        // провека кэша на пустоту
        if let cachedCalories = cachedFoods[food] {
            self.saveFoodEntry(foodName: food, calories: cachedCalories, quantity: quantity)
            return
        }
        
        // Если данных нет, кидается запрос к API
        let urlString = "https://trackapi.nutritionix.com/v2/natural/nutrients" //это endpoint API
        guard let url = URL(string: urlString) else {
            print("Ошибка: неверный URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") //тело запроса в формате JSON.
        request.addValue(appId, forHTTPHeaderField: "x-app-id")
        request.addValue(apiKey, forHTTPHeaderField: "x-app-key")
        
        let body: [String: Any] = ["query": "\(quantity)g \(food)"]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print("Request Body: \(body)")
        } catch {
            print("Ошибка сериализации JSON: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in //Создает задачу для отправки HTTP-запроса.
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Ошибка: пустой ответ")
                return
            }
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "Ошибка декодирования")")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let message = json["message"] as? String, message.contains("couldn't match") {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Ошибка", message: "Продукт не найден. Попробуйте ввести название на английском.")
                        }
                        return
                    }
                    
                    if let foods = json["foods"] as? [[String: Any]],
                       let firstFood = foods.first,
                       let calories = firstFood["nf_calories"] as? Double {
                        // сохранение данных в кэш
                        self.cachedFoods[food] = calories
                        
                        DispatchQueue.main.async {
                            self.saveFoodEntry(foodName: food, calories: calories, quantity: quantity)
                        }
                    } else {
                        print("Ошибка: неверный формат JSON")
                    }
                }
            } catch {
                print("Ошибка при парсинге JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func saveFoodEntry(foodName: String, calories: Double, quantity: Double) {
        guard let user = Auth.auth().currentUser else {
            print("Ошибка: пользователь не авторизован")
            return
        }
        
        let db = Firestore.firestore()
        let newEntry = FoodEntry(id: UUID().uuidString, foodName: foodName, calories: calories, quantity: quantity, date: Date())
        
        db.collection("foodEntries").addDocument(data: [
            "id": newEntry.id,
            "userId": user.uid,
            "foodName": newEntry.foodName,
            "calories": newEntry.calories,
            "quantity": newEntry.quantity,
            "date": newEntry.date
        ]) { error in
            if let error = error {
                print("Ошибка при сохранении записи: \(error.localizedDescription)")
                self.showAlert(title: "Ошибка", message: "Ошибка при сохранении записи")
            } else {
                print("Запись успешно сохранена")
                self.foodEntries.append(newEntry)
                self.tableView.reloadData()
                self.showAlert(title: "Успех", message: "Запись сохранена")
            }
        }
    }
    
    private func fetchFoodEntries() {
        guard let user = Auth.auth().currentUser else {
            print("Ошибка: пользователь не авторизован")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("foodEntries")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ошибка при загрузке записей: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Ошибка: пустой ответ")
                    return
                }
                
                self.foodEntries = documents.compactMap { doc in
                    let data = doc.data()
                    return FoodEntry(
                        id: doc.documentID,
                        foodName: data["foodName"] as? String ?? "",
                        calories: data["calories"] as? Double ?? 0,
                        quantity: data["quantity"] as? Double ?? 0,
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
                print("Загружено записей: \(self.foodEntries.count)")
                self.tableView.reloadData()
            }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FoodDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = foodEntries[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: entry.date)

        cell.textLabel?.text = "\(dateString): \(entry.foodName) - \(entry.quantity)g, \(entry.calories) ккал"
        cell.textLabel?.numberOfLines = 0

        return cell
    }

    // удаление свайпом влево
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let entry = self.foodEntries[indexPath.row]
            self.deleteFoodEntry(entry: entry, at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteFoodEntry(entry: FoodEntry, at indexPath: IndexPath) {
        let db = Firestore.firestore()
        
        // дэлит запись из бд
        db.collection("foodEntries").document(entry.id).delete { error in
            if let error = error {
                print("Ошибка при удалении записи: \(error.localizedDescription)")
                self.showAlert(title: "Ошибка", message: "Ошибка при удалении записи")
            } else {
                print("Запись успешно удалена")
                
                // дэлит запись из массива и обновляем таблицу
                self.foodEntries.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension FoodDiaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Закрываем клаву при нажатии на вернуться
        return true
    }
}

// MARK: - UIDocumentPickerDelegate
extension FoodDiaryViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
       
        showAlert(title: "Успех", message: "Файл успешно сохранен!")
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      
        showAlert(title: "Отмена", message: "Сохранение отменено.")
    }
}

struct FoodEntry {
    let id: String
    let foodName: String
    let calories: Double
    let quantity: Double
    let date: Date
}


