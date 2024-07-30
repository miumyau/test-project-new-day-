import Foundation

// Модели данных

// Модель данных для категории
struct Category: Codable, Identifiable {
    let id = UUID() // Уникальный идентификатор для SwiftUI
    let menuID: String // Идентификатор меню
    let image: String // URL изображения категории
    let name: String // Название категории
    let subMenuCount: Int // Количество подменю
    
    enum CodingKeys: String, CodingKey {
        case menuID = "menuID" // Маппинг поля menuID из JSON
        case image = "image" // Маппинг поля image из JSON
        case name = "name" // Маппинг поля name из JSON
        case subMenuCount = "subMenuCount" // Маппинг поля subMenuCount из JSON
    }
}

// Модель данных для блюда
struct Dish: Codable, Identifiable {
    let id: String // Идентификатор блюда
    let image: String // URL изображения блюда
    let name: String // Название блюда
    let content: String // Состав блюда
    let price: String // Цена блюда
    let weight: String // Вес блюда
    let spicy: String? // Информация о том, острое ли блюдо (необязательно)
}

// Модель ответа для категорий
struct CategoryResponse: Codable {
    let status: Bool // Статус запроса (успех или неудача)
    let menuList: [Category] // Список категорий
}

// Модель ответа для блюд
struct DishResponse: Codable {
    let status: Bool // Статус запроса (успех или неудача)
    let menuList: [Dish] // Список блюд
}

// ViewModel для обработки сетевых запросов и хранения данных
class MenuViewModel: ObservableObject {
    @Published var categories: [Category] = [] // Список категорий
    @Published var dishes: [Dish] = [] // Список блюд
    @Published var isLoadingCategories = false // Флаг загрузки категорий
    @Published var isLoadingDishes = false // Флаг загрузки блюд
    @Published var error: String? // Сообщение об ошибке
    
    // Инициализатор, вызывающий загрузку категорий при создании ViewModel
    init() {
        fetchCategories()
    }
    
    // Функция для загрузки категорий
    func fetchCategories() {
        isLoadingCategories = true // Устанавливаем флаг загрузки
        guard let url = URL(string: "https://vkus-sovet.ru/api/getMenu.php") else { return } // Проверка URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Устанавливаем метод запроса
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type
        
        // Создание и выполнение запроса
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Обработка ошибки запроса
                DispatchQueue.main.async {
                    self.isLoadingCategories = false // Сбрасываем флаг загрузки
                    self.error = "Error fetching categories: \(error.localizedDescription)" // Устанавливаем сообщение об ошибке
                }
                return
            }
            guard let data = data else {
                // Обработка случая отсутствия данных
                DispatchQueue.main.async {
                    self.isLoadingCategories = false // Сбрасываем флаг загрузки
                    self.error = "No data returned from fetchCategories" // Устанавливаем сообщение об ошибке
                }
                return
            }
            
            // Печать JSON-ответа для отладки
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON Response for Categories: \(jsonString)")
            }
            
            do {
                // Декодирование JSON-данных в объект CategoryResponse
                let result = try JSONDecoder().decode(CategoryResponse.self, from: data)
                if result.status {
                    DispatchQueue.main.async {
                        self.categories = result.menuList // Обновляем список категорий
                        self.isLoadingCategories = false // Сбрасываем флаг загрузки
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingCategories = false // Сбрасываем флаг загрузки
                        self.error = "Status was false in fetchCategories response" // Устанавливаем сообщение об ошибке
                    }
                }
            } catch {
                // Обработка ошибки декодирования
                DispatchQueue.main.async {
                    self.isLoadingCategories = false // Сбрасываем флаг загрузки
                    self.error = "Error decoding categories: \(error.localizedDescription)" // Устанавливаем сообщение об ошибке
                }
                // Печать данных для отладки
                debugPrint("Failed to decode CategoryResponse: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Data that failed to decode: \(dataString)")
                }
            }
        }.resume() // Запускаем задачу
    }
    
    // Функция для загрузки блюд по menuID
    func fetchDishes(for menuID: String) {
        isLoadingDishes = true // Устанавливаем флаг загрузки
        guard let url = URL(string: "https://vkus-sovet.ru/api/getSubMenu.php") else { return } // Проверка URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Устанавливаем метод запроса
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") // Устанавливаем заголовок Content-Type
        
        let parameters = "menuID=\(menuID)" // Параметры запроса
        request.httpBody = parameters.data(using: .utf8) // Устанавливаем тело запроса
        
        // Создание и выполнение запроса
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Обработка ошибки запроса
                DispatchQueue.main.async {
                    self.isLoadingDishes = false // Сбрасываем флаг загрузки
                    self.error = "Error fetching dishes: \(error.localizedDescription)" // Устанавливаем сообщение об ошибке
                }
                return
            }
            guard let data = data else {
                // Обработка случая отсутствия данных
                DispatchQueue.main.async {
                    self.isLoadingDishes = false // Сбрасываем флаг загрузки
                    self.error = "No data returned from fetchDishes" // Устанавливаем сообщение об ошибке
                }
                return
            }
            
            // Печать JSON-ответа для отладки
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON Response for Dishes: \(jsonString)")
            }
            
            do {
                // Декодирование JSON-данных в объект DishResponse
                let result = try JSONDecoder().decode(DishResponse.self, from: data)
                if result.status {
                    DispatchQueue.main.async {
                        self.dishes = result.menuList // Обновляем список блюд
                        self.isLoadingDishes = false // Сбрасываем флаг загрузки
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingDishes = false // Сбрасываем флаг загрузки
                        self.error = "Status was false in fetchDishes response" // Устанавливаем сообщение об ошибке
                    }
                }
            } catch {
                // Обработка ошибки декодирования
                DispatchQueue.main.async {
                    self.isLoadingDishes = false // Сбрасываем флаг загрузки
                    self.error = "Error decoding dishes: \(error.localizedDescription)" // Устанавливаем сообщение об ошибке
                }
                // Печать данных для отладки
                debugPrint("Failed to decode DishResponse: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Data that failed to decode: \(dataString)")
                }
            }
        }.resume() // Запускаем задачу
    }
}
