import UIKit
import MapKit
import CoreLocation

class ClinicsMapViewController: UIViewController {
    
    // MARK: - UI Elements
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    
    private let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let zoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let zoomOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var clinics: [Clinic] = []
    private var searchRadius: Double = 2000 // метров по умолчанию
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        setupMapView()
        
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationItem.title = "Карта клиник"
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Gradient Background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.89, green: 0.92, blue: 0.98, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add Subviews
        view.addSubview(mapView)
        view.addSubview(currentLocationButton)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(filterButton)
        view.addSubview(activityIndicator)
        
        // Setup Constraints
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50),
            
            zoomInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            zoomInButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -12),
            zoomInButton.widthAnchor.constraint(equalToConstant: 50),
            zoomInButton.heightAnchor.constraint(equalToConstant: 50),
            
            zoomOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            zoomOutButton.bottomAnchor.constraint(equalTo: zoomInButton.topAnchor, constant: -12),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 50),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 50),
            
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.bottomAnchor.constraint(equalTo: zoomOutButton.topAnchor, constant: -12),
            filterButton.widthAnchor.constraint(equalToConstant: 50),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Button Actions
        currentLocationButton.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            let alert = UIAlertController(
                title: "Доступ к геолокации",
                message: "Приложению нужен доступ к вашей геопозиции для поиска ближайших клиник",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Разрешить", style: .default) { _ in
                self.locationManager.requestWhenInUseAuthorization()
            })
            
            alert.addAction(UIAlertAction(title: "Отказать", style: .cancel) { _ in
                self.useDefaultLocation()
            })
            
            present(alert, animated: true)
        } else if status == .denied || status == .restricted {
            showLocationAccessAlert()
        } else {
            startLocationUpdates()
        }
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(ClinicAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    // MARK: - Location Methods
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.userLocation == nil {
                self.useDefaultLocation()
            }
        }
    }
    
    private func useDefaultLocation() {
        let krasnodarCoordinate = CLLocationCoordinate2D(latitude: 45.035470, longitude: 38.975313)
        let region = MKCoordinateRegion(center: krasnodarCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        searchClinics(near: krasnodarCoordinate)
    }
    
    private func showLocationAccessAlert() {
        let alert = UIAlertController(
            title: "Геолокация отключена",
            message: "Пожалуйста, включите доступ к геолокации в настройках для поиска клиник рядом с вами",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Использовать Краснодар", style: .default) { _ in
            self.useDefaultLocation()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Zoom Actions
    @objc private func zoomIn() {
        var region = mapView.region
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func zoomOut() {
        var region = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Location Actions
    @objc private func centerOnUserLocation() {
        if let userLocation = userLocation {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
            mapView.setRegion(region, animated: true)
        } else {
            showAlert(title: "Ошибка", message: "Ваше местоположение пока не определено. Пожалуйста, подождите...")
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Filter Methods
    @objc private func showFilterOptions() {
        let alert = UIAlertController(title: "Фильтры", message: "Выберите тип клиники", preferredStyle: .actionSheet)
        
        let allAction = UIAlertAction(title: "Все клиники", style: .default) { _ in
            self.searchClinics(near: self.mapView.centerCoordinate)
        }
        
        let dentalAction = UIAlertAction(title: "Стоматологии", style: .default) { _ in
            self.searchClinics(near: self.mapView.centerCoordinate, query: "стоматология")
        }
        
        let medicalAction = UIAlertAction(title: "Медцентры", style: .default) { _ in
            self.searchClinics(near: self.mapView.centerCoordinate, query: "медицинский центр")
        }
        
        let diagnosticAction = UIAlertAction(title: "Диагностические центры", style: .default) { _ in
            self.searchClinics(near: self.mapView.centerCoordinate, query: "диагностический центр")
        }
        
        let radiusAction = UIAlertAction(title: "Изменить радиус поиска", style: .default) { _ in
            self.showRadiusSelection()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(allAction)
        alert.addAction(dentalAction)
        alert.addAction(medicalAction)
        alert.addAction(diagnosticAction)
        alert.addAction(radiusAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showRadiusSelection() {
        let alert = UIAlertController(title: "Радиус поиска", message: "Выберите расстояние для поиска клиник", preferredStyle: .actionSheet)
        
        let radius500 = UIAlertAction(title: "500 метров", style: .default) { _ in
            self.searchRadius = 500
            self.searchClinics(near: self.mapView.centerCoordinate)
        }
        
        let radius1000 = UIAlertAction(title: "1 км", style: .default) { _ in
            self.searchRadius = 1000
            self.searchClinics(near: self.mapView.centerCoordinate)
        }
        
        let radius2000 = UIAlertAction(title: "2 км", style: .default) { _ in
            self.searchRadius = 2000
            self.searchClinics(near: self.mapView.centerCoordinate)
        }
        
        let radius5000 = UIAlertAction(title: "5 км", style: .default) { _ in
            self.searchRadius = 5000
            self.searchClinics(near: self.mapView.centerCoordinate)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(radius500)
        alert.addAction(radius1000)
        alert.addAction(radius2000)
        alert.addAction(radius5000)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Data Methods
    private func searchClinics(near coordinate: CLLocationCoordinate2D, query: String? = nil) {
        activityIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query ?? "медицинские клиники"
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                print("Ошибка поиска: \(error.localizedDescription)")
                return
            }
            
            guard let items = response?.mapItems else {
                print("Клиники не найдены")
                return
            }
            
            self.clinics = items.enumerated().map { index, item in
                Clinic(
                    id: index,
                    name: item.name ?? "Неизвестная клиника",
                    address: item.placemark.title ?? "Адрес не указан",
                    phone: item.phoneNumber ?? "Телефон не указан",
                    coordinate: item.placemark.coordinate,
                    type: self.determineClinicType(from: item.name)
                )
            }
            
            self.updateMapAnnotations()
        }
    }
    
    private func determineClinicType(from name: String?) -> String {
        guard let name = name?.lowercased() else { return "клиника" }
        
        if name.contains("стоматолог") || name.contains("зуб") {
            return "стоматология"
        } else if name.contains("медицинск") || name.contains("медцентр") {
            return "медицинский центр"
        } else if name.contains("диагност") {
            return "диагностический центр"
        } else {
            return "клиника"
        }
    }
    
    private func updateMapAnnotations() {
        for clinic in clinics {
            let annotation = ClinicAnnotation(clinic: clinic)
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Clinic Details Methods
    private func showClinicDetails(_ clinic: Clinic) {
        let alert = UIAlertController(
            title: clinic.name,
            message: "\(clinic.address)\nТелефон: \(clinic.phone)",
            preferredStyle: .actionSheet
        )
        
        // Действие для построения маршрута
        let routeAction = UIAlertAction(title: "Построить маршрут", style: .default) { _ in
            self.buildRoute(to: clinic.coordinate)
        }
        
        // Действие для звонка
        if let phoneURL = URL(string: "tel://\(clinic.phone.filter("0123456789".contains))"), UIApplication.shared.canOpenURL(phoneURL) {
            let callAction = UIAlertAction(title: "Позвонить", style: .default) { _ in
                UIApplication.shared.open(phoneURL)
            }
            alert.addAction(callAction)
        }
        
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        
        alert.addAction(routeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func buildRoute(to coordinate: CLLocationCoordinate2D) {
            // Проверяем, есть ли у нас текущее местоположение
            guard let userLocation = locationManager.location?.coordinate else {
                // Если местоположение не определено, пытаемся его получить
                locationManager.startUpdatingLocation()
                
                // Показываем индикатор загрузки
                activityIndicator.startAnimating()
                
                // Даем 5 секунд на определение местоположения
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.activityIndicator.stopAnimating()
                    
                    if let currentLocation = self.locationManager.location?.coordinate {
                        // Если получили местоположение, строим маршрут
                        self.showRouteOnMap(from: currentLocation, to: coordinate)
                    } else {
                        // Если не удалось, показываем ошибку с вариантами действий
                        self.showLocationErrorAlert(for: coordinate)
                    }
                }
                return
            }
            
            // Если местоположение уже есть, сразу строим маршрут
            showRouteOnMap(from: userLocation, to: coordinate)
        }
        
        private func showRouteOnMap(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
            
            let sourceItem = MKMapItem(placemark: sourcePlacemark)
            let destinationItem = MKMapItem(placemark: destinationPlacemark)
            destinationItem.name = "Клиника"
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceItem
            directionRequest.destination = destinationItem
            directionRequest.transportType = .automobile
            directionRequest.requestsAlternateRoutes = true
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { [weak self] (response, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Не удалось построить маршрут: \(error.localizedDescription)")
                    return
                }
                
                guard let route = response?.routes.first else {
                    self.showAlert(title: "Ошибка", message: "Маршрут не найден")
                    return
                }
                
                // Отображаем маршрут на карте
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                
                // Масштабируем карту чтобы показать весь маршрут
                let rect = route.polyline.boundingMapRect
                self.mapView.setVisibleMapRect(
                    rect,
                    edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
                    animated: true
                )
                
                // Показываем информацию о маршруте
                let distance = Measurement(value: route.distance, unit: UnitLength.meters)
                let travelTime = route.expectedTravelTime / 60 // в минутах
                
                let formatter = MeasurementFormatter()
                formatter.unitOptions = .naturalScale
                formatter.unitStyle = .short
                formatter.numberFormatter.maximumFractionDigits = 1
                
                let distanceString = formatter.string(from: distance.converted(to: .kilometers))
                
                self.showAlert(
                    title: "Маршрут построен",
                    message: "Расстояние: \(distanceString)\nПримерное время в пути: ~\(Int(travelTime)) мин"
                )
            }
        }
        
        private func showLocationErrorAlert(for destinationCoordinate: CLLocationCoordinate2D) {
            let alert = UIAlertController(
                title: "Ошибка определения местоположения",
                message: "Не удалось определить ваше текущее местоположение. Выберите действие:",
                preferredStyle: .alert
            )
            
            // Попробовать еще раз
            alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default) { _ in
                self.buildRoute(to: destinationCoordinate)
            })
            
            // Открыть настройки геолокации
            alert.addAction(UIAlertAction(title: "Настройки геолокации", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            // Показать маршрут от центра карты
            alert.addAction(UIAlertAction(title: "От центра карты", style: .default) { _ in
                self.showRouteOnMap(from: self.mapView.centerCoordinate, to: destinationCoordinate)
            })
            
            // Отмена
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            
            present(alert, animated: true)
        }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension ClinicsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Фильтруем неточные местоположения
        guard location.horizontalAccuracy <= 100 else { return }
        
        userLocation = location.coordinate
        manager.stopUpdatingLocation()
        
        // Центрируем карту и ищем клиники
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
        mapView.setRegion(region, animated: true)
        searchClinics(near: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка определения местоположения: \(error.localizedDescription)")
        useDefaultLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            showLocationAccessAlert()
        default:
            break
        }
    }
}

// MARK: - MKMapViewDelegate
extension ClinicsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let clinicAnnotation = annotation as? ClinicAnnotation else {
            return nil
        }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: clinicAnnotation) as! ClinicAnnotationView
        view.configure(with: clinicAnnotation.clinic)
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let clinicAnnotation = view.annotation as? ClinicAnnotation else { return }
        showClinicDetails(clinicAnnotation.clinic)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            renderer.lineDashPattern = [0, 6]
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: - Custom Types
struct Clinic {
    let id: Int
    let name: String
    let address: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
    let type: String
}

class ClinicAnnotation: NSObject, MKAnnotation {
    let clinic: Clinic
    
    var coordinate: CLLocationCoordinate2D {
        return clinic.coordinate
    }
    
    var title: String? {
        return clinic.name
    }
    
    var subtitle: String? {
        return clinic.type.capitalized
    }
    
    init(clinic: Clinic) {
        self.clinic = clinic
        super.init()
    }
}

class ClinicAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "clinic"
        canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with clinic: Clinic) {
        glyphImage = UIImage(systemName: "cross.fill")
        
        switch clinic.type {
        case "стоматология":
            markerTintColor = .systemTeal
        case "медицинский центр":
            markerTintColor = .systemBlue
        case "диагностический центр":
            markerTintColor = .systemIndigo
        default:
            markerTintColor = .systemPurple
        }
    }
}
