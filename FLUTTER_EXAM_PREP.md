# Flutter Practical Exam Preparation Guide
## From Bare Basics to Expert Level

---

## TABLE OF CONTENTS
1. [Flutter Fundamentals](#flutter-fundamentals)
2. [Dart Language Basics](#dart-language-basics)
3. [Widgets & Widget Tree](#widgets--widget-tree)
4. [State Management (Provider)](#state-management-provider)
5. [Project Architecture](#project-architecture)
6. [Data Management](#data-management)
7. [Common Exam Scenarios](#common-exam-scenarios)
8. [Tips & Tricks](#tips--tricks)

---

## FLUTTER FUNDAMENTALS

### What is Flutter?
- **Cross-platform mobile framework** built by Google
- Write once, run on iOS, Android, Web, Windows, macOS, Linux
- Uses **Dart** programming language
- **Hot Reload** for fast development
- **Material Design** and **Cupertino** design systems

### Flutter Architecture
```
┌─────────────────────────────────────┐
│     Your Dart Code (Apps)           │
├─────────────────────────────────────┤
│   Flutter Framework (Widgets)       │
├─────────────────────────────────────┤
│   Flutter Engine (C++)              │
├─────────────────────────────────────┤
│   Platform Channel (Android/iOS)    │
├─────────────────────────────────────┤
│   Native Code & System APIs         │
└─────────────────────────────────────┘
```

### Key Concepts
- **Everything is a Widget** - UI components, layouts, navigation
- **Reactive Framework** - UI automatically updates when data changes
- **Hot Reload** - See changes instantly without restarting
- **Material Design** - Google's design system (default in your project)

---

## DART LANGUAGE BASICS

### 1. Variables & Types
```dart
// Final (immutable) - cannot be changed
final String name = 'John';

// Const (compile-time constant)
const int maxUsers = 100;

// Var (type inferred)
var age = 25;  // Inferred as int
var email = 'john@example.com';  // Inferred as String

// Dynamic (runtime type checking)
dynamic value = 'anything';
value = 123;  // OK
```

### 2. Functions
```dart
// Basic function
String greet(String name) {
  return 'Hello, $name!';
}

// Arrow syntax (single expression)
String greet(String name) => 'Hello, $name!';

// Named parameters
void printUser({required String name, String? email}) {
  print('Name: $name, Email: $email');
}
printUser(name: 'John', email: 'john@example.com');

// Default values
void configure(String host, {int port = 8080}) {
  print('Connecting to $host:$port');
}

// Optional positional parameters
String format(String text, [bool uppercase = false]) {
  return uppercase ? text.toUpperCase() : text;
}
```

### 3. Classes & OOP
```dart
class User {
  final String id;
  final String name;
  String? email;  // Nullable
  
  // Constructor
  User({
    required this.id,
    required this.name,
    this.email,
  });
  
  // Method
  void updateEmail(String newEmail) {
    email = newEmail;
  }
  
  // Getter
  String get displayName => '$name ($email)';
  
  // Factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
```

### 4. Null Safety (Important!)
```dart
// Non-nullable (must have value)
String name = 'John';  // Cannot be null

// Nullable (can be null)
String? email = null;  // OK

// Null coalescing
String displayEmail = email ?? 'No email provided';

// Null-aware navigation
String? result = user?.getEmail();
List<String>? names = users?.map((u) => u.name).toList();

// Non-null assertion (risky!)
String realEmail = email!;  // Throws if null
```

### 5. Collections
```dart
// List
List<String> names = ['John', 'Jane', 'Bob'];
names.add('Alice');
names.removeAt(0);

// Map (Dictionary/Hash)
Map<String, int> scores = {
  'John': 95,
  'Jane': 87,
};
scores['Bob'] = 92;
String? score = scores['John'];

// Set
Set<int> uniqueNumbers = {1, 2, 3, 3};  // {1, 2, 3}

// Spread operator
List<int> combined = [...[1, 2], ...[3, 4]];  // [1, 2, 3, 4]

// Collection if
var items = [
  'Home',
  if (isAdmin) 'Admin Panel',
  'Settings',
];
```

### 6. Async/Await (Very Important!)
```dart
// Future - async operation that may complete later
Future<String> fetchUser(int id) async {
  // Simulate network call
  await Future.delayed(Duration(seconds: 2));
  return 'User: $id';
}

// Using async/await
void loadUser() async {
  try {
    String user = await fetchUser(1);
    print(user);
  } catch (e) {
    print('Error: $e');
  }
}

// Using .then()
fetchUser(1).then((user) {
  print(user);
}).catchError((error) {
  print('Error: $error');
});
```

---

## WIDGETS & WIDGET TREE

### What is a Widget?
- **Immutable description of part of UI**
- Two types: **Stateless** and **Stateful**

### Stateless Widget
```dart
class MyWidget extends StatelessWidget {
  final String title;
  
  const MyWidget({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
```

### Stateful Widget
```dart
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;
  
  // Called when widget is first created
  @override
  void initState() {
    super.initState();
    print('Widget created');
  }
  
  // Called when widget is destroyed
  @override
  void dispose() {
    super.dispose();
    print('Widget destroyed');
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;  // Triggers rebuild
            });
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### Common Widgets

#### Layout Widgets
```dart
// Column - vertical arrangement
Column(
  children: [Text('A'), Text('B')],
)

// Row - horizontal arrangement
Row(
  children: [Text('A'), Text('B')],
)

// Stack - overlapping widgets
Stack(
  children: [
    Container(color: Colors.blue),
    Positioned(top: 10, child: Text('Overlay')),
  ],
)

// Center - centers child
Center(child: Text('Centered'))

// ListView - scrollable list
ListView.builder(
  itemCount: 10,
  itemBuilder: (context, index) => Text('Item $index'),
)

// GridView - grid layout
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemBuilder: (context, index) => Container(),
)
```

#### Material Widgets
```dart
// Scaffold - basic app structure
Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: Center(child: Text('Content')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)

// Card - elevated container
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card content'),
  ),
)

// Button widgets
ElevatedButton(onPressed: () {}, child: Text('Elevated'))
TextButton(onPressed: () {}, child: Text('Text'))
IconButton(onPressed: () {}, icon: Icon(Icons.delete))

// TextField - input
TextField(
  decoration: InputDecoration(labelText: 'Enter name'),
  onChanged: (value) => print(value),
)

// Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
    ],
  ),
)
```

#### Styling Widgets
```dart
// Container - styling and layout
Container(
  width: 100,
  height: 100,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(blurRadius: 5)],
  ),
  child: Text('Styled'),
)

// Padding
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text('Padded'),
)

// SizedBox - spacing
SizedBox(width: 16, height: 16)

// Expanded - flexible space
Row(
  children: [
    Text('Fixed'),
    Expanded(child: SizedBox()),  // Takes remaining space
    Text('Fixed'),
  ],
)
```

### Widget Lifecycle

```
StatelessWidget:
  build() -> rendered -> displayed

StatefulWidget:
  createState()
    ↓
  initState() [called once]
    ↓
  build() [called when state changes]
    ↓
  dispose() [called on cleanup]
```

---

## STATE MANAGEMENT (PROVIDER)

### Why State Management?
- **Problem**: Passing data deeply through widget tree is tedious
- **Solution**: Centralized state management with Provider

### Provider Pattern (Used in Your Project)

#### 1. Creating a Provider
```dart
// In providers/timetable_provider.dart
class TimetableProvider extends ChangeNotifier {
  List<Timetable> _timetables = [];
  bool _isLoading = false;
  
  // Getters
  List<Timetable> get timetables => _timetables;
  bool get isLoading => _isLoading;
  
  // Methods that modify state
  void addTimetable(Timetable timetable) {
    _timetables.add(timetable);
    notifyListeners();  // Notify all listeners to rebuild
  }
  
  Future<void> fetchTimetables() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch from API/database
      _timetables = await repository.getTimetables();
    } catch (e) {
      print('Error: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
```

#### 2. Registering in Main
```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TimetableProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => EventProvider()),
    // ... more providers
  ],
  child: MyApp(),
)
```

#### 3. Using in Widgets
```dart
// Option A: Consumer (rebuilds only when provider changes)
Consumer<TimetableProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: provider.timetables.length,
      itemBuilder: (context, index) {
        return Text(provider.timetables[index].courseName);
      },
    );
  },
)

// Option B: Direct access (less efficient but simpler)
final provider = context.read<TimetableProvider>();
provider.addTimetable(newTimetable);

// Option C: Accessing in initState
@override
void initState() {
  super.initState();
  context.read<TimetableProvider>().fetchTimetables();
}

// Option D: Listening to specific properties
Selector<TimetableProvider, int>(
  selector: (context, provider) => provider.timetables.length,
  builder: (context, count, _) => Text('Total: $count'),
)
```

### Key Methods
```dart
// Notify all listeners
notifyListeners();

// Read value (doesn't listen for changes)
context.read<MyProvider>();

// Watch value (rebuilds when changes)
context.watch<MyProvider>();

// Select specific value (rebuilds only if this value changes)
context.select<MyProvider, String>(
  (provider) => provider.userName,
)
```

---

## PROJECT ARCHITECTURE

### Understanding Your Project Structure

Your project uses **Clean Architecture** with layers:

```
lib/
├── domain/           ← Business logic (Models, use cases)
├── data/             ← Data sources (APIs, databases)
│   ├── local/        ← SQLite
│   ├── remote/       ← MySQL, REST APIs
│   └── repositories/ ← Combines local & remote
├── presentation/     ← UI (Screens, Widgets)
│   ├── screens/      ← Full screens
│   └── widgets/      ← Reusable components
├── providers/        ← State management
├── core/             ← Constants, extensions, utilities
├── app/              ← App configuration, routes, theme
└── utils/            ← Helper functions
```

### Layer Responsibilities

#### Domain Layer
- **Pure Dart, no dependencies**
- Models (data structures)
- Abstract repositories (interfaces)
- Use cases (business rules)

```dart
// Example: domain/models/timetable.dart
class Timetable {
  final String id;
  final String courseName;
  final String roomNumber;
  final DateTime startTime;
  final DateTime endTime;
  
  Timetable({
    required this.id,
    required this.courseName,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
  });
}
```

#### Data Layer
- **Implements repositories from domain**
- Calls APIs and databases
- Transforms data to models

```dart
// Example: data/repositories/timetable_repository.dart
class TimetableRepository {
  final TimetableLocalDataSource local;
  final TimetableRemoteDataSource remote;
  
  TimetableRepository({
    required this.local,
    required this.remote,
  });
  
  Future<List<Timetable>> getTimetables() async {
    try {
      // Try remote first
      final remoteData = await remote.getTimetables();
      // Save to local
      await local.saveTimetables(remoteData);
      return remoteData;
    } catch (e) {
      // Fallback to local
      return await local.getTimetables();
    }
  }
}
```

#### Presentation Layer
- **UI screens and widgets**
- Uses providers for state management
- Calls repository methods

#### Providers
- **State management layer**
- Holds application state
- Calls repositories to get/modify data
- Notifies listeners when state changes

---

## DATA MANAGEMENT

### Local Database (SQLite)

Your project uses **sqflite** for local storage.

#### Basic Operations
```dart
// Opening database
Future<Database> _openDatabase() async {
  final path = await getDatabasesPath();
  return openDatabase(
    join(path, 'smart_campus.db'),
    version: 1,
    onCreate: (db, version) async {
      // Create tables
      await db.execute(
        'CREATE TABLE users('
        'id TEXT PRIMARY KEY,'
        'name TEXT,'
        'email TEXT'
        ')',
      );
    },
  );
}

// Insert
Future<void> insertUser(User user) async {
  final db = await database;
  await db.insert('users', user.toMap());
}

// Query all
Future<List<User>> getAllUsers() async {
  final db = await database;
  final maps = await db.query('users');
  return maps.map((map) => User.fromMap(map)).toList();
}

// Query with condition
Future<User?> getUserById(String id) async {
  final db = await database;
  final maps = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  }
  return null;
}

// Update
Future<void> updateUser(User user) async {
  final db = await database;
  await db.update(
    'users',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}

// Delete
Future<void> deleteUser(String id) async {
  final db = await database;
  await db.delete('users', where: 'id = ?', whereArgs: [id]);
}
```

### Remote Database (MySQL / REST API)

Your project connects to MySQL for remote data.

```dart
// Example: data/remote/mysql_database.dart
class MySqlDatabase {
  static Future<void> getConnection() async {
    try {
      final conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: 'your_host',
          port: 3306,
          user: 'your_user',
          password: 'your_password',
          db: 'smart_campus',
        ),
      );
      // Use connection
      await conn.close();
    } catch (e) {
      print('Connection error: $e');
    }
  }
}
```

### HTTP API Calls

```dart
import 'package:http/http.dart' as http;

Future<List<Event>> fetchEvents() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.example.com/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123',
      },
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json.map((item) => Event.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

---

## COMMON EXAM SCENARIOS

### Scenario 1: Display List of Items with Loading State
```dart
class TimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.timetables.isEmpty) {
          return Center(child: Text('No timetables found'));
        }
        
        return ListView.builder(
          itemCount: provider.timetables.length,
          itemBuilder: (context, index) {
            final timetable = provider.timetables[index];
            return Card(
              child: ListTile(
                title: Text(timetable.courseName),
                subtitle: Text('${timetable.startTime} - ${timetable.endTime}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate or show details
                },
              ),
            );
          },
        );
      },
    );
  }
}
```

### Scenario 2: Form Input and Validation
```dart
class EventRegistrationForm extends StatefulWidget {
  @override
  State<EventRegistrationForm> createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Submit form
                context.read<EventProvider>().registerEvent(
                  name: _nameController.text,
                  email: _emailController.text,
                );
              }
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
```

### Scenario 3: Search and Filter
```dart
class EventSearchScreen extends StatefulWidget {
  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search events...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: Consumer<EventProvider>(
            builder: (context, provider, _) {
              final filtered = provider.events
                  .where((event) => event.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();
              
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filtered[index].title),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Scenario 4: Navigation
```dart
// Simple navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EventDetailScreen(eventId: '123'),
  ),
);

// Pop and return data
Navigator.pop(context, 'selected_data');

// Named routes (configured in routes.dart)
Navigator.pushNamed(context, '/event-details', arguments: {'eventId': '123'});

// Replace route
Navigator.pushReplacementNamed(context, '/home');
```

### Scenario 5: Image Picker
```dart
import 'package:image_picker/image_picker.dart';

class ProfilePhotoUpload extends StatefulWidget {
  @override
  State<ProfilePhotoUpload> createState() => _ProfilePhotoUploadState();
}

class _ProfilePhotoUploadState extends State<ProfilePhotoUpload> {
  XFile? _image;
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null)
          Image.file(File(_image!.path), width: 200, height: 200)
        else
          Container(
            width: 200,
            height: 200,
            color: Colors.grey,
            child: Icon(Icons.image),
          ),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Image'),
        ),
      ],
    );
  }
}
```

### Scenario 6: Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Option 1'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          title: Text('Option 2'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
);
```

### Scenario 7: Tab Navigation
```dart
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.calendar), text: 'Timetable'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(),
          TimetableScreen(),
          EventsScreen(),
        ],
      ),
    );
  }
}
```

---

## TIPS & TRICKS

### 1. Hot Reload vs Hot Restart
- **Hot Reload**: `Ctrl+\` (quick, preserves state)
- **Hot Restart**: `Ctrl+Shift+\` (full restart, clears state)

### 2. Debugging
```dart
// Print to console
debugPrint('Debug message');
print('Regular message');

// Set breakpoints in VS Code (F9)
// Use debugger console to inspect variables
```

### 3. Performance Tips
- Use `const` constructors when possible
- Avoid rebuilds with `Consumer` and `Selector`
- Use `ListView.builder` instead of `ListView` for large lists
- Lazy load images with `Image.network`

### 4. Common Mistakes to Avoid
```dart
// ❌ Don't: rebuild on every change
Text(provider.data)  // Rebuilds entire widget tree

// ✅ Do: use Consumer for selective rebuilds
Consumer<MyProvider>(
  builder: (context, provider, _) => Text(provider.data),
)

// ❌ Don't: call notifyListeners() without changing state
void badMethod() {
  notifyListeners();  // Does nothing useful
}

// ✅ Do: notify only after state change
void goodMethod() {
  _data = newValue;
  notifyListeners();
}

// ❌ Don't: forget to dispose resources
TextEditingController _controller = TextEditingController();

// ✅ Do: dispose in dispose()
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 5. Common Exam Questions

**Q1: What's the difference between StatelessWidget and StatefulWidget?**
- **StatelessWidget**: Immutable, cannot change after build
- **StatefulWidget**: Mutable, can change state and rebuild

**Q2: How does Provider work?**
- Extends ChangeNotifier, holds app state
- Calls notifyListeners() to rebuild widgets
- Consumer rebuilds when provider changes

**Q3: What is Hot Reload?**
- Feature that reloads code without restarting app
- Preserves app state
- Useful for UI development

**Q4: Explain async/await**
- async marks function as asynchronous
- await pauses execution until Future completes
- Used for network calls, database operations

**Q5: What's Clean Architecture?**
- Domain (business logic) → Data (APIs/databases) → Presentation (UI)
- Layers are independent and testable
- Used to maintain large codebases

**Q6: How do you handle errors?**
```dart
try {
  final data = await fetchData();
} catch (e) {
  print('Error: $e');
} finally {
  // Always runs
}
```

**Q7: What's null safety?**
- Non-nullable by default (`String`)
- Optional with `?` (`String?`)
- Access with `?.` operator

**Q8: How to navigate between screens?**
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
Navigator.pushNamed(context, '/route-name');
Navigator.pop(context);
```

---

## PRACTICE EXERCISES

### Exercise 1: Simple Counter App
Create a StatefulWidget that:
- Displays a number
- Has buttons to increment/decrement
- Shows "Count is even/odd"

### Exercise 2: Todo List with Provider
Create an app that:
- Shows list of todos
- Add new todos
- Mark as complete
- Delete todos
- Use Provider for state management

### Exercise 3: API Integration
Create a screen that:
- Fetches users from JSONPlaceholder API
- Displays them in a ListView
- Shows loading and error states
- Has a refresh button

### Exercise 4: Form with Validation
Create a registration form that:
- Validates name (not empty)
- Validates email (contains @)
- Validates password (min 6 chars)
- Submits form and shows success message

### Exercise 5: Image Gallery
Create an app that:
- Pick images from gallery
- Display in GridView
- Allow delete images
- Store in local database

---

## QUICK REFERENCE

### Widget Shortcuts
```
Scaffold - appBar, body, floatingActionButton
AppBar - title, leading, actions
FloatingActionButton - onPressed, child
Container - padding, margin, decoration, child
Column/Row - children, mainAxisAlignment, crossAxisAlignment
ListView - scrollable list of widgets
Card - elevated container with shadow
TextField - input field with validation
ElevatedButton - primary action button
```

### Provider Shortcuts
```
ChangeNotifier - notifyListeners()
MultiProvider - multiple providers
Consumer - rebuild when provider changes
context.read() - get provider value
context.watch() - rebuild on change
Selector - rebuild only if selected value changes
```

### Navigation
```
Navigator.push() - push new route
Navigator.pop() - go back
Navigator.pushNamed() - named route
Navigator.pushReplacement() - replace current route
```

---

## RESOURCES

- **Official Flutter Docs**: https://flutter.dev/docs
- **Dart Language Tour**: https://dart.dev/guides/language/language-tour
- **Provider Package**: https://pub.dev/packages/provider
- **Material Design**: https://material.io/design

---

**Good luck with your exam! 🚀**

Key takeaway: **Flutter = Dart + Widgets + State Management**

Practice building small apps and you'll master it!
