
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class BookAppointmentViewController: UIViewController {

    private let backgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
   
    private let firstNameTextField = UITextField()
    private let lastNameTextField = UITextField()
    private let middleNameTextField = UITextField()
    private let ageTextField = UITextField()
    private let cityTextField = UITextField()
    private let reasonTextField = UITextField()
    private let doctorTypeTextField = UITextField()
    private let attachPhotoButton = UIButton()
    private let submitButton = UIButton()

    private var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        
       
        let backButton = UIBarButtonItem(title: "ᐸ Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
    private func setupUI() {
        
            firstNameTextField.placeholder = "Имя"
            lastNameTextField.placeholder = "Фамилия"
            middleNameTextField.placeholder = "Отчество"
            ageTextField.placeholder = "Возраст"
            cityTextField.placeholder = "Город"
            reasonTextField.placeholder = "Причина обращения"
            doctorTypeTextField.placeholder = "Какой врач вам нужен?"

            let textFields = [firstNameTextField, lastNameTextField, middleNameTextField, ageTextField, cityTextField, reasonTextField, doctorTypeTextField]
            for textField in textFields {
                textField.borderStyle = .roundedRect
                textField.backgroundColor = .white
                textField.textColor = .black
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [.foregroundColor: UIColor.gray]
                )
                textField.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(textField)
            }

        
            attachPhotoButton.setTitle("Прикрепить фото с анализами", for: .normal)
            attachPhotoButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            attachPhotoButton.tintColor = .white
            attachPhotoButton.backgroundColor = .systemBlue
            attachPhotoButton.layer.cornerRadius = 12
            attachPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            attachPhotoButton.contentHorizontalAlignment = .left
            attachPhotoButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
            attachPhotoButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
            attachPhotoButton.addTarget(self, action: #selector(attachPhotoButtonTapped), for: .touchUpInside)
            attachPhotoButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(attachPhotoButton)

           
            submitButton.setTitle("Отправить заявку", for: .normal)
            submitButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            submitButton.tintColor = .white // Цвет иконки
            submitButton.backgroundColor = .systemGreen
            submitButton.layer.cornerRadius = 12
            submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            submitButton.contentHorizontalAlignment = .left
            submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) // Отступ текста
            submitButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Отступ иконки
            submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
            submitButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(submitButton)

         
            NSLayoutConstraint.activate([
                firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
                lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                middleNameTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 10),
                middleNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                middleNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                ageTextField.topAnchor.constraint(equalTo: middleNameTextField.bottomAnchor, constant: 10),
                ageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                ageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                cityTextField.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 10),
                cityTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                cityTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                reasonTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 10),
                reasonTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                reasonTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                doctorTypeTextField.topAnchor.constraint(equalTo: reasonTextField.bottomAnchor, constant: 10),
                doctorTypeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                doctorTypeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                attachPhotoButton.topAnchor.constraint(equalTo: doctorTypeTextField.bottomAnchor, constant: 20),
                attachPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                attachPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                attachPhotoButton.heightAnchor.constraint(equalToConstant: 50),

                submitButton.topAnchor.constraint(equalTo: attachPhotoButton.bottomAnchor, constant: 20),
                submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                submitButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }


    @objc private func attachPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    @objc private func submitButtonTapped() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let age = ageTextField.text, !age.isEmpty,
              let city = cityTextField.text, !city.isEmpty,
              let reason = reasonTextField.text, !reason.isEmpty,
              let doctorType = doctorTypeTextField.text, !doctorType.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }

        // cохранение данных в бд
        saveAppointmentToFirebase(firstName: firstName, lastName: lastName, middleName: middleNameTextField.text, age: age, city: city, reason: reason, doctorType: doctorType)
    }

    private func saveAppointmentToFirebase(firstName: String, lastName: String, middleName: String?, age: String, city: String, reason: String, doctorType: String) {
//        let db = Firestore.firestore()
// тут коммент важный
        
        
        var data: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "age": age,
            "city": city,
            "reason": reason,
            "doctorType": doctorType,
            "timestamp": FieldValue.serverTimestamp()
        ]

        if let middleName = middleName {
            data["middleName"] = middleName
        }


        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("appointmentPhotos/\(UUID().uuidString).jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.showAlert(message: "Ошибка загрузки фото: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        data["photoURL"] = downloadURL.absoluteString
                        self.saveDataToFirestore(data: data)
                    } else {
                        self.showAlert(message: "Ошибка получения URL фото")
                    }
                }
            }
        } else {
            saveDataToFirestore(data: data)
        }
    }

    private func saveDataToFirestore(data: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("appointments").addDocument(data: data) { error in
            if let error = error {
                self.showAlert(message: "Ошибка сохранения данных: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Заявка успешно отправлена!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Уведомление", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension BookAppointmentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            attachPhotoButton.setTitle("Фото прикреплено", for: .normal)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
