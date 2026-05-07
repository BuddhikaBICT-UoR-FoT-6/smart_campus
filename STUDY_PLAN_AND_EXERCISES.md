# Flutter Exam Preparation - Study Plan & Practice Exercises

## 📋 EXAM PREP ROADMAP

### Phase 1: Fundamentals (Days 1-2)
- [ ] Understand Dart language basics
- [ ] Learn about Flutter widgets
- [ ] Understand widget lifecycle
- [ ] Practice building simple UIs

### Phase 2: State Management (Days 3-4)
- [ ] Learn Provider pattern
- [ ] Understand ChangeNotifier
- [ ] Practice with Consumer
- [ ] Study your project's providers

### Phase 3: Project Architecture (Days 5-6)
- [ ] Understand Clean Architecture
- [ ] Learn data flow in your project
- [ ] Study domain, data, presentation layers
- [ ] Understand repository pattern

### Phase 4: Practical Skills (Days 7-10)
- [ ] Data persistence (SQLite)
- [ ] API integration (HTTP)
- [ ] Form handling and validation
- [ ] Navigation and routing
- [ ] Error handling

### Phase 5: Practice (Days 11-14)
- [ ] Build mini projects
- [ ] Solve exam-style problems
- [ ] Review code patterns
- [ ] Final review

---

## 📚 STUDY GUIDE

### Day 1-2: Dart & Basic Widgets

**Topics to cover:**
1. Variables and types
2. Functions and arrow syntax
3. Classes and OOP
4. Null safety
5. Collections (List, Map, Set)
6. Basic widgets (Container, Text, Column, Row)

**Practice:**
```dart
// Exercise 1.1: Create a simple User class
class User {
  final String id;
  final String name;
  String? email;
  
  User({required this.id, required this.name, this.email});
  
  String get initials => name.split(' ').map((n) => n[0]).join();
}

// Exercise 1.2: Create a simple widget
class UserCard extends StatelessWidget {
  final User user;
  
  const UserCard({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(user.name),
          Text(user.email ?? 'No email'),
        ],
      ),
    );
  }
}
```

---

### Day 3-4: State Management (Provider)

**Topics to cover:**
1. ChangeNotifier
2. Provider registration
3. Consumer widget
4. Selector pattern
5. Context methods (read, watch, select)

**Practice Exercise:**
```dart
// Exercise 3.1: Create a Counter Provider
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// Exercise 3.2: Use in a Widget
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Consumer<CounterProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Count: ${provider.count}'),
                ElevatedButton(
                  onPressed: () => provider.increment(),
                  child: const Text('Increment'),
                ),
                ElevatedButton(
                  onPressed: () => provider.decrement(),
                  child: const Text('Decrement'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

### Day 5-6: Architecture & Data Layer

**Topics to cover:**
1. Clean Architecture layers
2. Domain models
3. Repository pattern
4. Data sources (local and remote)
5. Your project's structure

**Understanding Your Project:**
```dart
// Your project structure example
// domain/entities/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });
}

// data/repositories/event_repository.dart
class EventRepository {
  final EventLocalDataSource local;
  final EventRemoteDataSource remote;
  
  EventRepository({required this.local, required this.remote});
  
  Future<List<Event>> getEvents() async {
    try {
      final remoteEvents = await remote.getEvents();
      await local.saveEvents(remoteEvents);
      return remoteEvents;
    } catch (e) {
      return await local.getEvents();
    }
  }
}

// providers/event_provider.dart
class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _events = await _repository.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

### Day 7-10: Practical Skills

#### SQLite Database

**Exercise 7.1: Create a Todo Database**
```dart
class TodoDatabase {
  static final TodoDatabase _instance = TodoDatabase._internal();
  static Database? _database;
  
  factory TodoDatabase() => _instance;
  TodoDatabase._internal();
  
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }
  
  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            completed BOOLEAN DEFAULT 0,
            created_at DATETIME
          )
        ''');
      },
    );
  }
  
  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap());
  }
  
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return maps.map((map) => Todo.fromMap(map)).toList();
  }
  
  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }
  
  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
```

#### API Integration

**Exercise 8.1: Fetch Data from API**
```dart
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List;
        return json.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }
  
  Future<void> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body}),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }
}
```

#### Form Validation

**Exercise 9.1: Registration Form with Validation**
```dart
class RegistrationForm extends StatefulWidget {
  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthProvider>().register(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🎯 PRACTICE EXERCISES

### Project 1: Todo App with Provider & SQLite
**Difficulty: Easy**

**Requirements:**
1. Create a Todo model
2. Create TodoProvider with add, delete, update, fetch
3. Display todos in ListView
4. Add new todo form
5. Mark todo as complete
6. Delete todo
7. Persist to SQLite

**Topics covered:** State management, SQLite, Forms, List UI

---

### Project 2: Event Registration System
**Difficulty: Medium**

**Requirements:**
1. Fetch events from API (JSONPlaceholder)
2. Display events in GridView
3. Event detail screen
4. Register for event (local storage)
5. View registered events
6. Show loading states
7. Handle errors

**Topics covered:** API integration, Navigation, Local storage, Loading states

---

### Project 3: User Profile Management
**Difficulty: Medium**

**Requirements:**
1. Create user profile with avatar
2. Edit profile form with validation
3. Upload/change profile picture
4. Save profile to SQLite
5. Load profile on app start
6. Show user info in AppBar
7. Logout functionality

**Topics covered:** Forms, Image picker, Providers, Navigation

---

### Project 4: Search & Filter List
**Difficulty: Medium**

**Requirements:**
1. Display list of items
2. Real-time search functionality
3. Filter by category
4. Sort by different criteria
5. Pagination/infinite scroll
6. Pull to refresh

**Topics covered:** Filtering, State management, ListViews, API integration

---

## 📝 COMMON EXAM QUESTIONS

### Question 1: Explain the difference between StatelessWidget and StatefulWidget
**Answer Template:**
- StatelessWidget: Immutable, no state changes
- StatefulWidget: Mutable, can call setState() to trigger rebuilds
- Use StatelessWidget for static content
- Use StatefulWidget when data changes over time

### Question 2: How does Provider pattern work?
**Answer Template:**
1. Create a class extending ChangeNotifier
2. Add properties and methods
3. Call notifyListeners() when state changes
4. Register in MultiProvider
5. Access with Consumer, context.read(), context.watch()
6. UI rebuilds when state changes

### Question 3: Describe the data flow in your project
**Answer Template:**
1. UI calls provider method
2. Provider calls repository method
3. Repository calls local/remote datasource
4. Data is returned and saved
5. Provider notifies listeners
6. UI rebuilds with new data

### Question 4: How do you handle errors in async operations?
**Answer Template:**
```dart
try {
  _data = await someAsyncCall();
} catch (e) {
  _error = e.toString();
  showErrorDialog(context, _error);
} finally {
  _isLoading = false;
}
```

### Question 5: What is null safety?
**Answer Template:**
- Non-nullable by default (String)
- Nullable with ? (String?)
- Must check before using null values
- Use ?. for null-aware access
- Use ?? for null coalescing

---

## 🔍 EXAM TIPS

### Before the Exam
- [ ] Review all three study documents
- [ ] Run through quick code snippets
- [ ] Understand your project architecture
- [ ] Practice at least 3 complete projects
- [ ] Know all providers in your project
- [ ] Test your app's functionality

### During the Exam
- **Read questions carefully** - understand what's being asked
- **Plan before coding** - write pseudocode first
- **Use code snippets** - reference patterns from this guide
- **Test as you code** - build and run frequently
- **Handle edge cases** - loading, errors, empty states
- **Follow conventions** - naming, formatting, structure

### Common Mistakes to Avoid
- ❌ Forgetting to dispose controllers/resources
- ❌ Calling setState() in wrong context
- ❌ Not checking widget.mounted before setState
- ❌ Forgetting to notifyListeners() in provider
- ❌ Using BuildContext after pop
- ❌ Not handling null values
- ❌ Forgetting error handling
- ❌ Not loading data when screen opens

### What Examiners Look For
- ✅ Clean, readable code
- ✅ Proper state management
- ✅ Error handling
- ✅ Loading states
- ✅ Navigation between screens
- ✅ Form validation
- ✅ Data persistence
- ✅ UI/UX considerations

---

## ⏰ FINAL CHECKLIST (1 Day Before Exam)

- [ ] Run the Smart Campus app and understand all screens
- [ ] Review main.dart and understand provider setup
- [ ] Check all providers and their responsibilities
- [ ] Read through the quick snippets file
- [ ] Review common UI patterns
- [ ] Practice writing a simple screen from scratch
- [ ] Test creating a simple provider
- [ ] Verify you can navigate between screens
- [ ] Test form validation
- [ ] Understand error handling patterns

---

## 🚀 FINAL WORDS

> "The key to mastering Flutter is understanding that **Everything is a Widget** and **State Management is Central**."

### Three Pillars of Flutter
1. **Widgets** - Build UI with composable components
2. **State Management** - Keep data and UI in sync
3. **Async Operations** - Handle APIs and databases

### Study Approach
1. **Understand** the concept
2. **See** working examples
3. **Code** it yourself
4. **Modify** and experiment
5. **Teach** someone else

### Remember
- Dart + Widgets + Provider = Complete Flutter App
- Always dispose of resources
- Always check for null values
- Always handle errors
- Always test your code

---

**You've got this! 💪**

The fact that you're preparing this thoroughly shows you're ready. Just keep practicing, and you'll ace that exam!

Good luck! 🎓🚀
