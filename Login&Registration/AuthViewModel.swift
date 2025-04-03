import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false

    func signUp(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription) //Замыкание, которое возвращает результат операции (Bool) и сообщение 
                return
            }
            self.isAuthenticated = true
            completion(true, "Успешная регистрация!")
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            self.isAuthenticated = true
            completion(true, "Успешный вход!")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch {
            print("Ошибка при выходе: \(error.localizedDescription)")
        }
    }
}
