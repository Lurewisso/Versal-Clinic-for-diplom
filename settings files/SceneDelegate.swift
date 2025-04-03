import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
//        let authVC = AuthViewController()
        let authVC = StartScreenViewController()
        
        let navController = UINavigationController(rootViewController: authVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}
