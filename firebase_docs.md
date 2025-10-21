# Firebase Documentation (Firestore + Auth)

## Общая структура

Два ключевых класса:
- `FirestoreService` — работа с базой данных (Cloud Firestore)
- `FirebaseAuthService` — аутентификация пользователей (Firebase Auth)

---

## FirestoreService

Класс отвечает за все CRUD-операции в Firestore:
- пользователи
- рестораны
- офферы (предложения)
- бронирования

### Инициализация
```dart
final firestoreService = FirestoreService();
```

---

### Коллекции

| Коллекция | Назначение |
|------------|-------------|
| `users` | Данные пользователей |
| `restaurants` | Информация о ресторанах |
| `offers` | Активные предложения / акции |
| `bookings` | Бронирования пользователей |

---

### Пользователи

#### Создать пользователя
```dart
await firestoreService.createUser(
  userId: '123',
  userData: {'name': 'Alice', 'email': 'alice@email.com'},
);
```

#### Получить пользователя
```dart
final doc = await firestoreService.getUser('123');
final data = doc.data();
```

#### Обновить пользователя
```dart
await firestoreService.updateUser(
  userId: '123',
  updates: {'phone': '+3725555555'},
);
```

#### Удалить пользователя
```dart
await firestoreService.deleteUser('123');
```

---

### Рестораны

#### Получить все рестораны (реактивно)
```dart
Stream<QuerySnapshot> stream = firestoreService.getRestaurants();
```

#### Получить конкретный ресторан
```dart
final restaurant = await firestoreService.getRestaurant('resto123');
```

---

### Офферы (предложения)

#### Получить офферы конкретного ресторана
```dart
firestoreService.getOffersByRestaurant('resto123');
```

#### Получить все активные офферы
```dart
firestoreService.getAllActiveOffers();
```

#### Получить конкретный оффер
```dart
await firestoreService.getOffer('offer123');
```

#### Уменьшить количество доступных офферов
```dart
await firestoreService.decrementOfferQuantity('offer123');
```

#### Увеличить количество доступных офферов
```dart
await firestoreService.incrementOfferQuantity('offer123');
```

#### Подсчитать количество офферов ресторана
```dart
final count = await firestoreService.getOfferCountForRestaurant('resto123');
```

---

### Бронирования

#### Создать бронирование
```dart
final bookingId = await firestoreService.createBooking({
  'userId': '123',
  'restaurantId': 'resto123',
  'offerId': 'offer123',
  'createdAt': FieldValue.serverTimestamp(),
});
```

#### Получить бронирования пользователя
```dart
firestoreService.getUserBookings('123');
```

#### Получить конкретное бронирование
```dart
await firestoreService.getBooking('booking123');
```

#### Обновить статус бронирования
```dart
await firestoreService.updateBookingStatus(
  bookingId: 'booking123',
  status: 'confirmed',
);
```

#### Отменить бронирование
```dart
await firestoreService.cancelBooking('booking123');
```

#### Удалить бронирование
```dart
await firestoreService.deleteBooking('booking123');
```

---

## FirebaseAuthService

Класс для регистрации, входа и управления пользователями Firebase Authentication.

### Инициализация
```dart
final authService = FirebaseAuthService();
```

---

### Текущий пользователь
```dart
final user = authService.currentUser;
```

---

### Stream статуса аутентификации
```dart
authService.authStateChanges.listen((user) {
  if (user != null) print('User logged in: ${user.email}');
});
```

---

### Регистрация
```dart
await authService.registerWithEmailAndPassword(
  email: 'user@email.com',
  password: 'StrongPassword123',
);
```

---

### Вход
```dart
await authService.signInWithEmailAndPassword(
  email: 'user@email.com',
  password: 'StrongPassword123',
);
```

---

### Выход
```dart
await authService.signOut();
```

---

### Удаление аккаунта
```dart
await authService.deleteAccount();
```

## Сброс пароля

Для восстановления доступа пользователь может запросить сброс пароля по email:

```dart
await authService.sendPasswordResetEmail('user@email.com');
```

Firebase отправит письмо со ссылкой для изменения пароля. После перехода по ссылке пользователь сможет задать новый пароль.

---

## Обработка ошибок

Метод `_handleAuthException` в `FirebaseAuthService` возвращает понятные сообщения пользователю на основе кода ошибки `FirebaseAuthException`.

| Код | Сообщение |
|------|-----------|
| `weak-password` | The password provided is too weak. |
| `email-already-in-use` | An account already exists for that email. |
| `user-not-found` | No user found for that email. |
| `wrong-password` | Wrong password provided. |
| `too-many-requests` | Too many requests. Try again later. |

Эти сообщения можно локализовать или использовать напрямую для отображения пользователю.

---

## Рекомендации по использованию

### Безопасность

Убедитесь, что **Firestore Security Rules** соответствуют вашей модели данных и предотвращают несанкционированный доступ. Например:
```json
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

### Транзакции

Для операций, где важно текущее состояние (например, `incrementOfferQuantity`, `decrementOfferQuantity`), всегда используйте `runTransaction`. Это предотвратит конфликты при одновременных изменениях данных.

---

### Обновления в реальном времени

Для динамических экранов, например, списка ресторанов или активных офферов, используйте **StreamBuilder**:

```dart
StreamBuilder<QuerySnapshot>(
  stream: firestoreService.getRestaurants(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final restaurants = snapshot.data!.docs;
    return ListView(
      children: restaurants.map((r) => Text(r['name'])).toList(),
    );
  },
);
```

---

### Обработка ошибок

Всегда оборачивайте вызовы Firestore и Auth в `try/catch` и показывайте пользователю понятное сообщение:

```dart
try {
  await authService.signInWithEmailAndPassword(
    email: 'test@email.com',
    password: 'password123',
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```