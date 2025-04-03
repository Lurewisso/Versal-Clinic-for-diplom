


import UIKit

// MARK: - Модель новости
struct MedicalNews: Decodable {
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
}

struct NewsApiResponse: Decodable {
    let articles: [MedicalNews]
}

// MARK: - Ячейка для новости
class NewsTableViewCell: UITableViewCell {
    static let cellId = "NewsTableViewCell"
    
    private let newsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(newsCardView)
        newsCardView.addSubview(newsTitleLabel)
        newsCardView.addSubview(newsDescriptionLabel)
        newsCardView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            newsCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            newsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newsCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            newsTitleLabel.topAnchor.constraint(equalTo: newsCardView.topAnchor, constant: 16),
            newsTitleLabel.leadingAnchor.constraint(equalTo: newsCardView.leadingAnchor, constant: 16),
            newsTitleLabel.trailingAnchor.constraint(equalTo: newsCardView.trailingAnchor, constant: -16),
            
            newsDescriptionLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 8),
            newsDescriptionLabel.leadingAnchor.constraint(equalTo: newsCardView.leadingAnchor, constant: 16),
            newsDescriptionLabel.trailingAnchor.constraint(equalTo: newsCardView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: newsDescriptionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: newsCardView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: newsCardView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: newsCardView.bottomAnchor, constant: -16)
        ])
    }
    
    func setup(with news: MedicalNews) {
        newsTitleLabel.text = news.title
        newsDescriptionLabel.text = news.description
        
        if let dateString = news.publishedAt {
            dateLabel.text = formatDate(dateString)
        } else {
            dateLabel.text = ""
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

// MARK: - Главный экран с новостями
class MedicalNewsViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Главные новости медицины"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    private var medicalNewsList: [MedicalNews] = []
    private let newsApiKey = "33a45a13a4ef48dd984db98eae070d7c"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        loadMedicalNews()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        // Градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.15, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Добавляем элементы
        view.addSubview(titleLabel)
        view.addSubview(newsTableView)
        view.addSubview(activityIndicator)
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            newsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            newsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        newsTableView.refreshControl = refreshControl
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func refreshNews() {
        loadMedicalNews()
    }
    
    @objc private func appDidBecomeActive() {
        loadMedicalNews()
    }
    
    private func loadMedicalNews() {
        activityIndicator.startAnimating()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let dateString = dateFormatter.string(from: thirtyDaysAgo)
        
//        let query = "медицина+OR+здоровье+OR+болезни+OR+врачи+OR+COVID+OR+ОРВИ"
        let query = "медицина OR здоровье OR болезни OR врачи OR COVID OR ОРВИ OR грипп OR вакцина OR лечение"
        let newsApiUrl = "https://newsapi.org/v2/everything?q=\(query)&language=ru&sortBy=publishedAt&from=\(dateString)&apiKey=\(newsApiKey)"
        
        guard let url = URL(string: newsApiUrl) else {
            print("Ошибка: Некорректный URL")
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
            
            if let error = error {
                print("Ошибка загрузки новостей: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Нет данных в ответе")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(NewsApiResponse.self, from: data)
                DispatchQueue.main.async {
                    self.medicalNewsList = decodedData.articles
                    self.newsTableView.reloadData()
                    
                    // Прокрутка к самым свежим новостям
                    if !self.medicalNewsList.isEmpty {
                        self.newsTableView.scrollToRow(
                            at: IndexPath(row: 0, section: 0),
                            at: .top,
                            animated: true
                        )
                    }
                }
            } catch {
                print("Ошибка декодирования JSON: \(error)")
            }
        }.resume()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MedicalNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicalNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.cellId, for: indexPath) as! NewsTableViewCell
        let newsItem = medicalNewsList[indexPath.row]
        cell.setup(with: newsItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newsItem = medicalNewsList[indexPath.row]
        if let url = URL(string: newsItem.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
