



import UIKit

class DoctorsListViewController: UIViewController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    private let doctors: [(specialization: String, symptoms: String)] = [
        ("Уролог", """
        - Боль при мочеиспускании
        - Кровь в моче
        - Частое мочеиспускание
        - Боль в пояснице
        - Недержание мочи
        - Камни в почках
        - Инфекции мочевыводящих путей
        - Проблемы с эрекцией
        - Боль в области паха
        """),
        ("Хирург", """
        - Острые боли в животе
        - Травмы (переломы, порезы)
        - Грыжи
        - Опухоли
        - Воспалительные процессы (абсцессы, флегмоны)
        - Аппендицит
        - Перитонит
        - Ожоги
        - Варикозное расширение вен
        """),
        ("Терапевт", """
        - Повышенная температура
        - Кашель
        - Общая слабость
        - Головная боль
        - Боль в горле
        - Насморк
        - Озноб
        - Боль в мышцах
        - Усталость
        - Потеря аппетита
        """),
        ("Кардиолог", """
        - Боль в груди
        - Одышка
        - Учащенное сердцебиение
        - Головокружение
        - Отеки ног
        - Высокое или низкое давление
        - Аритмия
        - Обмороки
        - Холодные конечности
        """),
        ("Невролог", """
        - Головные боли
        - Головокружение
        - Онемение конечностей
        - Судороги
        - Нарушение координации
        - Проблемы со сном
        - Потеря памяти
        - Тремор
        - Мышечная слабость
        """),
        ("Гастроэнтеролог", """
        - Боли в животе
        - Изжога
        - Тошнота
        - Рвота
        - Вздутие живота
        - Нарушение стула (диарея, запор)
        - Потеря веса
        - Кровь в стуле
        - Неприятный привкус во рту
        """),
        ("Дерматолог", """
        - Сыпь
        - Зуд
        - Покраснение кожи
        - Шелушение кожи
        - Угревая сыпь
        - Пигментные пятна
        - Экзема
        - Псориаз
        - Грибковые инфекции
        """),
        ("Офтальмолог", """
        - Ухудшение зрения
        - Боль в глазах
        - Покраснение глаз
        - Слезотечение
        - Сухость глаз
        - Двоение в глазах
        - Светобоязнь
        - Плавающие точки перед глазами
        - Глаукома
        """),
        ("Эндокринолог", """
        - Усталость
        - Резкое изменение веса
        - Повышенная потливость
        - Нарушение менструального цикла
        - Выпадение волос
        - Сухость кожи
        - Жажда
        - Частое мочеиспускание
        - Проблемы с щитовидной железой
        """),
        ("Гинеколог", """
        - Боли внизу живота
        - Нарушение менструального цикла
        - Выделения из влагалища
        - Зуд и жжение
        - Болезненный половой акт
        - Проблемы с зачатием
        - Кровотечения
        - Боли в молочных железах
        - Климактерические симптомы
        """),
        ("Педиатр", """
        - Повышенная температура у ребенка
        - Кашель и насморк
        - Сыпь
        - Плохой аппетит
        - Задержка развития
        - Частые простуды
        - Боли в животе
        - Рвота
        - Диарея
        """),
        ("Ортопед", """
        - Боли в суставах
        - Нарушение осанки
        - Хруст в суставах
        - Ограничение подвижности
        - Деформация конечностей
        - Травмы (переломы, вывихи)
        - Боль в спине
        - Плоскостопие
        - Артрит
        """),
        ("Психиатр", """
        - Депрессия
        - Тревожность
        - Панические атаки
        - Нарушение сна
        - Агрессивное поведение
        - Навязчивые мысли
        - Галлюцинации
        - Потеря интереса к жизни
        - Суицидальные мысли
        """),
        ("Стоматолог", """
        - Зубная боль
        - Кровоточивость десен
        - Неприятный запах изо рта
        - Повышенная чувствительность зубов
        - Кариес
        - Проблемы с прикусом
        - Бруксизм (скрежет зубами)
        - Воспаление десен
        - Потеря зубов
        """),
        ("ЛОР (Отоларинголог)", """
        - Боль в горле
        - Заложенность носа
        - Потеря слуха
        - Шум в ушах
        - Головокружение
        - Храп
        - Кровотечение из носа
        - Осиплость голоса
        - Боль в ушах
        """),
        ("Аллерголог", """
        - Сыпь и зуд
        - Насморк и чихание
        - Слезотечение
        - Отек Квинке
        - Затрудненное дыхание
        - Пищевая аллергия
        - Астма
        - Крапивница
        - Реакция на укусы насекомых
        """),
        ("Онколог", """
        - Уплотнения в тканях
        - Необъяснимая потеря веса
        - Хроническая усталость
        - Кровотечения
        - Изменение родинок
        - Длительные боли
        - Увеличение лимфоузлов
        - Кашель с кровью
        - Проблемы с глотанием
        """),
        ("Ревматолог", """
        - Боли в суставах
        - Утренняя скованность
        - Отек суставов
        - Повышенная температура
        - Слабость
        - Поражение кожи (сыпь, покраснение)
        - Артрит
        - Остеопороз
        - Боль в мышцах
        """),
        ("Инфекционист", """
        - Повышенная температура
        - Сыпь
        - Тошнота и рвота
        - Диарея
        - Головная боль
        - Увеличение лимфоузлов
        - Желтуха
        - Лихорадка
        - Боль в горле
        """),
        ("Пульмонолог", """
        - Кашель
        - Одышка
        - Боль в груди
        - Хрипы
        - Кровохарканье
        - Частые простуды
        - Астма
        - Бронхит
        - Пневмония
        """)
    ]

    private var filteredDoctors: [(specialization: String, symptoms: String)] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            setupBackground()
            view.backgroundColor = .systemBackground
            title = "Список врачей"
            

            setupUI()
            let backButton = UIBarButtonItem(title: "ᐸ Назад", style: .plain, target: self, action: #selector(backButtonTapped))
            backButton.tintColor = .white // Белый цвет кнопки
            navigationItem.leftBarButtonItem = backButton
        }

        @objc private func backButtonTapped() {
            navigationController?.popViewController(animated: true)
        }

    
    private func setupBackground() {


        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 0.6, green: 0.75, blue: 1.0, alpha: 1.0).cgColor, // Светлый синий (верх)
//            UIColor(red: 0.25, green: 0.41, blue: 0.88, alpha: 1.0).cgColor, // Основной цвет #4169E1 (центр)
//            UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0).cgColor     // Глубокий синий (низ)
//        ]
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
            
            // Настройка поисковой строки
            searchBar.placeholder = "Поиск врача"
            searchBar.delegate = self
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(searchBar)

            // Настройка таблицы
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(DoctorTableViewCell.self, forCellReuseIdentifier: "DoctorCell")
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)

            // Констрейнты
            NSLayoutConstraint.activate([
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            filteredDoctors = doctors
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    extension DoctorsListViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredDoctors.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorTableViewCell
            let doctor = filteredDoctors[indexPath.row]
            cell.configure(with: doctor.specialization, symptoms: doctor.symptoms)
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            let doctor = filteredDoctors[indexPath.row]
            let detailVC = DoctorDetailViewControllers(specialization: doctor.specialization, symptoms: doctor.symptoms)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    // MARK: - UISearchBarDelegate
    extension DoctorsListViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredDoctors = doctors
            } else {
                filteredDoctors = doctors.filter { $0.specialization.lowercased().contains(searchText.lowercased()) }
            }
            tableView.reloadData()
        }
    }

    // MARK: - Кастомная ячейка
    class DoctorTableViewCell: UITableViewCell {
        private let specializationLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        private let symptomsLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .gray
            label.numberOfLines = 0
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
            contentView.addSubview(specializationLabel)
            contentView.addSubview(symptomsLabel)

            NSLayoutConstraint.activate([
                specializationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                specializationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                specializationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

                symptomsLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 4),
                symptomsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                symptomsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                symptomsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }

        func configure(with specialization: String, symptoms: String) {
            specializationLabel.text = specialization
            symptomsLabel.text = symptoms
        }
    }

    // MARK: - Детальный экран
    class DoctorDetailViewControllers: UIViewController {
        private let specialization: String
        private let symptoms: String

        private let textView: UITextView = {
            let textView = UITextView()
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.isEditable = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            return textView
        }()

        init(specialization: String, symptoms: String) {
            self.specialization = specialization
            self.symptoms = symptoms
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            title = specialization

            setupUI()
        }

        private func setupUI() {
            view.addSubview(textView)
            textView.text = symptoms

            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
}


