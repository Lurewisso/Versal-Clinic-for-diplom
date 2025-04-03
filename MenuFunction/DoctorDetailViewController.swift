
import Foundation

import UIKit

class DoctorDetailViewController: UIViewController {

    private let specializationLabel = UILabel()
    private let symptomsLabel = UILabel()

    init(specialization: String, symptoms: String) {
        super.init(nibName: nil, bundle: nil)
        specializationLabel.text = specialization
        symptomsLabel.text = symptoms
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Описание"

        setupUI()
    }

    private func setupUI() {
        specializationLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        specializationLabel.textAlignment = .center
        specializationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(specializationLabel)

        symptomsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        symptomsLabel.numberOfLines = 0
        symptomsLabel.textAlignment = .center
        symptomsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(symptomsLabel)

        NSLayoutConstraint.activate([
            specializationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            specializationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            specializationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            symptomsLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 20),
            symptomsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            symptomsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
