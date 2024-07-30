import SwiftUI

// Главный вид приложения, содержащий TabView для навигации между страницами
struct MenuView: View {
    @StateObject var viewModel = MenuViewModel() // Объект модели для управления состоянием
    @State private var selectedCategory: Category? // Хранит выбранную категорию
    @Environment(\.colorScheme) var colorScheme // Обнаруживает текущую цветовую схему (тема)

    var body: some View {
        TabView {
            // Представление для списка категорий и блюд
            NavigationView {
                VStack {
                    // Показ прогресс-индикатора, если категории загружаются
                    if viewModel.isLoadingCategories {
                        ProgressView("Loading categories...")
                    }
                    // Показ прогресс-индикатора, если блюда загружаются
                    else if viewModel.isLoadingDishes {
                        ProgressView("Loading dishes...")
                    }
                    // Показ сообщения об ошибке, если возникла ошибка
                    else if let error = viewModel.error {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // Горизонтальный скролл для категорий
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.categories) { category in
                                    // Визуализация категории
                                    CategoryView(category: category)
                                        .onTapGesture {
                                            // Обработчик нажатия на категорию
                                            selectedCategory = category
                                            viewModel.fetchDishes(for: category.menuID)
                                        }
                                }
                            }
                            .padding()
                        }
                        
                        // Отображение имени выбранной категории
                        if let selectedCategory = selectedCategory {
                            Text(selectedCategory.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding()
                        }
                        
                        // Скролл для блюд
                        ScrollView {
                            LazyVGrid(
                                columns: [
                                    GridItem(.fixed(150), spacing: 16),
                                    GridItem(.fixed(150), spacing: 16)
                                ],
                                spacing: 16
                            ) {
                                ForEach(viewModel.dishes) { dish in
                                    // Визуализация блюда
                                    DishView(dish: dish)
                                }
                            }
                            .padding()
                        }
                    }
                }
                // Настройка навигационной строки
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Левый элемент навигационной строки (логотип)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("logo") // Замените на имя вашего логотипа
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                    }
                    // Правый элемент навигационной строки (иконка телефона)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                        }) {
                            Image(systemName: "phone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            .tabItem {
                Label("", systemImage: "list.dash") // Иконка для вкладки "Список"
            }
            
            // Представление для корзины
            PurchaseView()
                .tabItem {
                    Label("", systemImage: "cart") // Иконка для вкладки "Корзина"
                }
            
            // Представление для информации
            InformationView()
                .tabItem {
                    Label("", systemImage: "info.circle") // Иконка для вкладки "Информация"
                }
        }
    }
}

// Представление для корзины
struct PurchaseView: View {
    var body: some View {
        Text("Корзина") // Заголовок страницы корзины
            .font(.largeTitle)
    }
}

// Представление для информации
struct InformationView: View {
    var body: some View {
        Text("Информация") // Заголовок страницы информации
            .font(.largeTitle)
    }
}

// Представление для категории
struct CategoryView: View {
    let category: Category

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://vkus-sovet.ru" + category.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
            Text(category.name)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1) // Не позволяет тексту переноситься на несколько строк
                .frame(width: 100, alignment: .center) // Устанавливает фиксированную ширину для согласованности
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Представление для блюда
struct DishView: View {
    let dish: Dish

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://vkus-sovet.ru" + dish.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
            } placeholder: {
                ProgressView()
                    .frame(width: 150, height: 100)
            }
            Text(dish.name)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1) // Не позволяет тексту переноситься на несколько строк
                .frame(width: 150, alignment: .center) // Устанавливает фиксированную ширину для согласованности
            Text(dish.price)
                .font(.subheadline)
            if dish.spicy == "Y" {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .frame(width: 150) // Устанавливает фиксированную ширину для согласованности
    }
}

// Превью
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
