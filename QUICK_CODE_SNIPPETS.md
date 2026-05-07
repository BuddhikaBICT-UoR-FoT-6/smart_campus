# Flutter Exam - Quick Code Snippets & Patterns

## Table of Contents
1. [Essential Imports](#essential-imports)
2. [Widget Templates](#widget-templates)
3. [State Management Patterns](#state-management-patterns)
4. [Common UI Patterns](#common-ui-patterns)
5. [Data Management Patterns](#data-management-patterns)
6. [Navigation Patterns](#navigation-patterns)
7. [Form & Validation](#form--validation)
8. [Error Handling](#error-handling)
9. [API Integration](#api-integration)
10. [Database Operations](#database-operations)

---

## ESSENTIAL IMPORTS

### Most Common Imports
```dart
import 'package:flutter/material.dart';           // Main UI library
import 'package:provider/provider.dart';          // State management
import 'dart:async';                              // Futures, Streams
import 'dart:convert';                            // JSON encoding/decoding
import 'package:http/http.dart' as http;         // HTTP requests
import 'package:sqflite/sqflite.dart';           // SQLite database
```

---

## WIDGET TEMPLATES

### Stateless Widget Template
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hello World'),
          ],
        ),
      ),
    );
  }
}
```

### Stateful Widget Template
```dart
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Center(
        child: Text('Count: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Provider Template
```dart
class MyProvider extends ChangeNotifier {
  String _data = 'Initial value';

  String get data => _data;

  void updateData(String newValue) {
    _data = newValue;
    notifyListeners();
  }

  Future<void> fetchData() async {
    try {
      // Async operation
      final result = await someAsyncCall();
      _data = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
```

---

## STATE MANAGEMENT PATTERNS

### Pattern 1: Basic Consumer
```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.data);
  },
)
```

### Pattern 2: Multiple Providers (Consumer2)
```dart
Consumer2<AuthProvider, EventProvider>(
  builder: (context, auth, events, _) {
    if (!auth.isLoggedIn) return LoginScreen();
    return EventsList(events: events.events);
  },
)
```

### Pattern 3: Conditional Rebuilds (Selector)
```dart
Selector<MyProvider, String>(
  selector: (context, provider) => provider.userName,
  builder: (context, userName, child) {
    return Text(userName);
  },
)
```

### Pattern 4: Loading State
```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (provider.data.isEmpty) {
      return const Center(child: Text('No data'));
    }
    
    return ListView.builder(
      itemCount: provider.data.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(provider.data[index]),
      ),
    );
  },
)
```

### Pattern 5: Read vs Watch
```dart
// Use read() when you need value once
void submitForm() {
  final provider = context.read<AuthProvider>();
  provider.login(email, password);
}

// Use watch() when you need to react to changes
if (context.watch<AuthProvider>().isLoggedIn) {
  return HomeScreen();
} else {
  return LoginScreen();
}
```

---

## COMMON UI PATTERNS

### Responsive Layout
```dart
// Mobile-first approach
Widget buildLayout(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  
  if (width < 600) {
    // Mobile layout
    return MobileLayout();
  } else if (width < 1000) {
    // Tablet layout
    return TabletLayout();
  } else {
    // Desktop layout
    return DesktopLayout();
  }
}
```

### List with Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await context.read<MyProvider>().refreshData();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(items[index].title),
    ),
  ),
)
```

### Infinite Scroll (Pagination)
```dart
class PaginatedList extends StatefulWidget {
  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more items
      context.read<MyProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index].title),
      ),
    );
  }
}
```

### Search & Filter
```dart
class SearchableList extends StatefulWidget {
  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        Expanded(
          child: Consumer<MyProvider>(
            builder: (context, provider, _) {
              final filtered = provider.items
                  .where((item) =>
                      item.title.toLowerCase().contains(_searchQuery))
                  .toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(filtered[index].title),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Choose Option'),
        ListTile(
          title: const Text('Option 1'),
          onTap: () {
            Navigator.pop(context, 'option1');
          },
        ),
        ListTile(
          title: const Text('Option 2'),
          onTap: () {
            Navigator.pop(context, 'option2');
          },
        ),
      ],
    ),
  ),
);
```

### Alert Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm Delete?'),
    content: const Text('This action cannot be undone.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          context.read<MyProvider>().deleteItem(id);
          Navigator.pop(context);
        },
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

### Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Item deleted'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        context.read<MyProvider>().undoDelete();
      },
    ),
  ),
);
```

---

## DATA MANAGEMENT PATTERNS

### Loading Data on Screen Init
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyProvider>().fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MyProvider>(
        builder: (context, provider, _) {
          // Build UI
        },
      ),
    );
  }
}
```

### Handling Async Operations
```dart
Future<void> handleAsync() async {
  try {
    final result = await futureOperation();
    if (mounted) {  // Check if widget still exists
      setState(() {
        _data = result;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

### Caching Data
```dart
class MyProvider extends ChangeNotifier {
  List<Item>? _cachedData;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<List<Item>> fetchData() async {
    // Return cache if fresh
    if (_cachedData != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedData!;
      }
    }

    // Fetch fresh data
    _cachedData = await _repository.getData();
    _cacheTime = DateTime.now();
    notifyListeners();
    return _cachedData!;
  }
}
```

---

## NAVIGATION PATTERNS

### Push New Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextScreen(),
  ),
);
```

### Named Routes
```dart
// Setup in main.dart
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/details': (context) => DetailsScreen(),
    '/profile': (context) => ProfileScreen(),
  },
)

// Navigate
Navigator.pushNamed(context, '/details');

// With arguments
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'id': '123'},
);

// Receive arguments
@override
void initState() {
  super.initState();
  final args = ModalRoute.of(context)!.settings.arguments as Map;
  final id = args['id'];
}
```

### Pop and Return Data
```dart
// Pop with data
Navigator.pop(context, 'result_data');

// Handle returned data
Navigator.push(...).then((result) {
  if (result != null) {
    // Use result
    setState(() {
      _data = result;
    });
  }
});
```

### Replace Route
```dart
Navigator.pushReplacementNamed(context, '/login');
```

### Tab Navigation
```dart
class TabNavigationScreen extends StatefulWidget {
  @override
  State<TabNavigationScreen> createState() => _TabNavigationScreenState();
}

class _TabNavigationScreenState extends State<TabNavigationScreen>
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
          tabs: const [
            Tab(text: 'Home'),
            Tab(text: 'Search'),
            Tab(text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeTab(),
          SearchTab(),
          ProfileTab(),
        ],
      ),
    );
  }
}
```

---

## FORM & VALIDATION

### Basic Form
```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!value.contains('@')) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
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
                context.read<AuthProvider>().login(
                  email: _emailController.text,
                  password: _passwordController.text,
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

---

## ERROR HANDLING

### Try-Catch Pattern
```dart
try {
  final data = await fetchData();
  setState(() {
    _data = data;
  });
} on TimeoutException catch (e) {
  showError('Request timeout');
} on SocketException catch (e) {
  showError('Network error');
} catch (e) {
  showError('Unexpected error: $e');
} finally {
  setState(() {
    _isLoading = false;
  });
}
```

### Error Handling in Provider
```dart
class MyProvider extends ChangeNotifier {
  String? _error;

  String? get error => _error;

  Future<void> loadData() async {
    try {
      _error = null;
      _data = await _repository.getData();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### Display Error UI
```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    if (provider.error != null) {
      return ErrorScreen(
        error: provider.error!,
        onRetry: () => provider.loadData(),
      );
    }
    // Normal UI
    return ListView(...);
  },
)
```

---

## API INTEGRATION

### Simple GET Request
```dart
Future<List<Item>> fetchItems() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.example.com/items'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed with status ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}
```

### POST Request with Body
```dart
Future<void> createItem(String title, String description) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.example.com/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('Item created');
    } else {
      throw Exception('Failed to create item');
    }
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}
```

### With Authentication
```dart
Future<List<Item>> fetchSecureItems(String token) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/items'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as List;
    return json.map((item) => Item.fromJson(item)).toList();
  } else if (response.statusCode == 401) {
    // Token expired
    throw UnauthorizedException();
  } else {
    throw Exception('Failed to fetch items');
  }
}
```

---

## DATABASE OPERATIONS

### Initialize SQLite Database
```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'app_database.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            created_at DATETIME
          )
        ''');
      },
    );
  }
}
```

### CRUD Operations
```dart
class UserDAO {
  final DatabaseService _dbService = DatabaseService();

  // Create
  Future<void> insertUser(User user) async {
    final db = await _dbService.database;
    await db.insert('users', user.toMap());
  }

  // Read
  Future<List<User>> getAllUsers() async {
    final db = await _dbService.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Read Single
  Future<User?> getUserById(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Update
  Future<void> updateUser(User user) async {
    final db = await _dbService.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Delete
  Future<void> deleteUser(String id) async {
    final db = await _dbService.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
```

### Database Transactions
```dart
Future<void> transferData(String fromId, String toId, int amount) async {
  final db = await _dbService.database;
  
  await db.transaction((txn) async {
    // Deduct from first account
    await txn.rawUpdate(
      'UPDATE accounts SET balance = balance - ? WHERE id = ?',
      [amount, fromId],
    );
    
    // Add to second account
    await txn.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [amount, toId],
    );
  });
}
```

---

## BONUS: Life-Saver Patterns

### The Safe Navigation Pattern
```dart
// ❌ Can throw null error
String name = user.profile.name;

// ✅ Safe with null-coalescing
String name = user?.profile?.name ?? 'Unknown';
```

### The Loading-Error-Success Pattern
```dart
class StateProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<Item> items = [];

  Future<void> loadItems() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await _repository.getItems();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

### The Widget Disposal Pattern
```dart
// Always implement dispose() for resources
@override
void dispose() {
  _controller?.dispose();
  _scrollController?.dispose();
  super.dispose();
}
```

### The Mounted Check Pattern
```dart
// Prevent setState after widget disposal
if (mounted) {
  setState(() {
    _data = result;
  });
}
```

---

Remember: **Copy, understand, then modify!** 🚀

Good luck on your exam! 📱
