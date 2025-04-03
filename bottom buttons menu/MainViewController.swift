import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        setupTabBarAppearance()
        setupTabBarAnimations()
    }

    private func setupTabs() {
        let menuVC = MenuViewController()
        menuVC.tabBarItem = UITabBarItem(title: "Меню", image: UIImage(systemName: "line.horizontal.3"), tag: 0)

        let diaryVC = DiaryViewController()
        diaryVC.tabBarItem = UITabBarItem(title: "Дневник", image: UIImage(systemName: "book.fill"), tag: 1)

        let analysisVC = MedicalNewsViewController()
        analysisVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 2)
        
        let foodDiaryVC = FoodDiaryViewController()
        foodDiaryVC.tabBarItem = UITabBarItem(title: "Питание", image: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill"), tag: 3)
        
        let medicineVC = TreatmentViewController()
        medicineVC.tabBarItem = UITabBarItem(title: "Лечение", image: UIImage(systemName: "pills.fill"), tag: 4)

        viewControllers = [menuVC, diaryVC, analysisVC, foodDiaryVC, medicineVC]
    }

    private func setupTabBarAppearance() {
        // 1. Полностью очищаем стандартный фон
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .clear
        
        // 2. Создаем кастомный контейнер
        let ovalContainer = UIView()
        ovalContainer.backgroundColor = .clear
        ovalContainer.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(ovalContainer)
        tabBar.sendSubviewToBack(ovalContainer)
        
        // 3. Точные отступы (подправьте эти значения по необходимости)
        NSLayoutConstraint.activate([
            ovalContainer.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: 6),  // Боковые отступы
            ovalContainer.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: -6),
            ovalContainer.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 1),  // Поднимаем сверху (увеличиваем отступ)
            ovalContainer.bottomAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.bottomAnchor, constant: 9)  // Чуть убираем снизу
        ])
        
        // 4. Градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 1.0).cgColor,       // Темно-синий (основа)
            UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 1.0).cgColor,       // Насыщенный сапфировый
            UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 1.0).cgColor        // Яркий акцент
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // 5. Настройка овальной формы
        DispatchQueue.main.async {
            gradientLayer.frame = ovalContainer.bounds
            ovalContainer.layer.cornerRadius = ovalContainer.frame.height / 2
            ovalContainer.layer.masksToBounds = true
            ovalContainer.layer.insertSublayer(gradientLayer, at: 0)
            
            // Убираем возможную черную полосу (артефакт рендеринга)
            ovalContainer.layer.borderWidth = 0
            ovalContainer.layer.borderColor = UIColor.clear.cgColor
        }
        
        // 6. Настройка внешнего вида
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Важные настройки для устранения артефактов
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        
        // Стиль иконок
        appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.7)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // 7. Мягкая тень
        ovalContainer.layer.shadowColor = UIColor.black.cgColor
        ovalContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        ovalContainer.layer.shadowRadius = 8
        ovalContainer.layer.shadowOpacity = 0.15
    }

    private func setupTabBarAnimations() {
        delegate = self
    }
}

extension MainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }

        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}

//import UIKit
//
//class MainViewController: UITabBarController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupTabs()
//        setupTabBarAppearance()
//        setupTabBarAnimations()
//    }
//
//    private func setupTabs() {
//        let menuVC = MenuViewController()
//        menuVC.tabBarItem = UITabBarItem(title: "Меню", image: UIImage(systemName: "line.horizontal.3"), tag: 0)
//
//        let diaryVC = DiaryViewController()
//        diaryVC.tabBarItem = UITabBarItem(title: "Дневник", image: UIImage(systemName: "book.fill"), tag: 1)
//
////        let analysisVC = MainCenterMenuViewController()
//        let analysisVC = MedicalNewsViewController()
////        let analysisVC = NewsView()
//        analysisVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 2)
//        
//        let foodDiaryVC = FoodDiaryViewController()
//        foodDiaryVC.tabBarItem = UITabBarItem(title: "Питание", image: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill"), tag: 3)
//        
//        let medicineVC = TreatmentViewController()
//        medicineVC.tabBarItem = UITabBarItem(title: "Лечение", image: UIImage(systemName: "pills.fill"), tag: 4)
//
//        viewControllers = [menuVC, diaryVC, analysisVC, foodDiaryVC, medicineVC]
//    }
//
//    private func setupTabBarAppearance() {
//        // Настройка градиентного фона для TabBar
//        let gradientLayer = CAGradientLayer()
////        gradientLayer.colors = [
////            UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 1.0).cgColor, // Начальный цвет градиента
////            UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0).cgColor  // Конечный цвет градиента
////        ]
//        gradientLayer.colors = [
//            UIColor(red: 0.08, green: 0.2, blue: 0.4, alpha: 1.0).cgColor, // Начальный цвет градиента (глубокий синий)
//            UIColor(red: 0.3, green: 0.1, blue: 0.3, alpha: 1.0).cgColor  // Конечный цвет градиента (темный фиолетовый)
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//        gradientLayer.frame = tabBar.bounds
//
//        // Добавляем градиентный слой в качестве фона
//        if let backgroundImage = createImage(from: gradientLayer) {
//            let appearance = UITabBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundImage = backgroundImage
//
//            // Настройка теней
//            appearance.shadowColor = .black.withAlphaComponent(0.3)
//            appearance.shadowImage = UIImage()
//
//            // Настройка цвета иконок и текста в неактивном состоянии
//            appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.7)
//            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
//                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7),
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium)
//            ]
//
//            // Настройка цвета иконок и текста в активном состоянии
//            appearance.stackedLayoutAppearance.selected.iconColor = .white
//            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
//                NSAttributedString.Key.foregroundColor: UIColor.white,
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold)
//            ]
//
//            tabBar.standardAppearance = appearance
//            if #available(iOS 15.0, *) {
//                tabBar.scrollEdgeAppearance = appearance
//            }
//        }
//
//        // Закругленные углы для TabBar
//        tabBar.layer.cornerRadius = 50
//        
//        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        tabBar.layer.masksToBounds = true
//    }
//
//    private func setupTabBarAnimations() {
//        // Анимация при переключении вкладок
//        delegate = self
//    }
//
//    // Создание изображения из слоя
//    private func createImage(from layer: CALayer) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        layer.render(in: context)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//}
//
//// Расширение для анимации переключения вкладок
//extension MainViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
//            return false
//        }
//
//        if fromView != toView {
//            // Анимация перехода
//            UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
//        }
//
//        return true
//    }
//}





























//class MainViewController: UITabBarController {
//   
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupTabs()
//        setupTabBarAppearance()
//    }
//
//
//    
//    private func setupTabs() {
//        let menuVC = MenuViewController()
//        menuVC.tabBarItem = UITabBarItem(title: "Меню", image: UIImage(systemName: "line.horizontal.3"), tag: 0)
//
//        let diaryVC = DiaryViewController()
//        diaryVC.tabBarItem = UITabBarItem(title: "Дневник", image: UIImage(systemName: "book.fill"), tag: 1)
//
//        let analysisVC = AnalysisViewController()
//        analysisVC.tabBarItem = UITabBarItem(title: "Анализы", image: UIImage(systemName: "doc.fill"), tag: 2)
//        
//        let foodDiaryVC = FoodDiaryViewController()
//        foodDiaryVC.tabBarItem = UITabBarItem(title: "Питание", image: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill"), tag: 3)
//        
//        let medicineVC = TreatmentViewController()
//        medicineVC.tabBarItem = UITabBarItem(title: "Лечение", image: UIImage(systemName: "doc.fill"), tag: 4)
//
//        viewControllers = [menuVC, diaryVC, analysisVC, foodDiaryVC, medicineVC]
//    }
//
//    private func setupTabBarAppearance() {
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 0.0, green: 0.545, blue: 0.545, alpha: 1.0).cgColor, 
//            UIColor(red: 0.125, green: 0.698, blue: 0.667, alpha: 1.0).cgColor
//        ]
//        
//        //  фон TabBar
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .systemMint
//
//        
//        
//        //  цвета текста и иконок
//        appearance.stackedLayoutAppearance.normal.iconColor = .white // Цвет иконок в неактивном состоянии
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Цвет текста в неактивном состоянии
//
//        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue // Цвет иконок в активном состоянии
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue] // Цвет текста в активном состоянии
//
//       
//        tabBar.standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            tabBar.scrollEdgeAppearance = appearance
//        }
//    }
//}








//
//
//import UIKit
//
//class MainViewController: UITabBarController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTabs()
//    }
//
//    private func setupTabs() {
//        
////        let profileVC = ProfileViewController()
////        profileVC.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 0)
//        
//        let menuVC = MenuViewController()
//        menuVC.tabBarItem = UITabBarItem(title: "Меню", image: UIImage(systemName: "line.horizontal.3"), tag: 0)
//
//        let diaryVC = DiaryViewController()
//        diaryVC.tabBarItem = UITabBarItem(title: "Дневник", image: UIImage(systemName: "book.fill"), tag: 1)
//
//        let analysisVC = AnalysisViewController()
//        analysisVC.tabBarItem = UITabBarItem(title: "Анализы", image: UIImage(systemName: "doc.fill"), tag: 2)
//        
//        let foodDiaryVC = FoodDiaryViewController()
//        foodDiaryVC.tabBarItem = UITabBarItem(title: "Питание", image: UIImage(systemName: "takeoutbag.and.cup.and.straw.fill"), tag: 3)
//        
//        let medicineVC = TreatmentViewController()
//        medicineVC.tabBarItem = UITabBarItem(title: "Лечение", image: UIImage(systemName: "doc.fill"), tag: 4)
//
////        viewControllers = [profileVC, diaryVC, analysisVC,foodDiaryVC,medicineVC]
//        viewControllers = [menuVC, diaryVC, analysisVC,foodDiaryVC,medicineVC]
//    }
//}
