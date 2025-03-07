import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MyAppState(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Pizza', 'price': 12.5},
    {'name': 'Burger', 'price': 8.0},
    {'name': 'Pasta', 'price': 10.0},
    {'name': 'Sushi', 'price': 15.0},
    {'name': 'Salad', 'price': 7.0},
    {'name': 'Steak', 'price': 20.0},
    {'name': 'Tacos', 'price': 9.5},
    {'name': 'Soup', 'price': 6.5},
    {'name': 'Ice Cream', 'price': 5.0},
    {'name': 'Cake', 'price': 6.0},
  ];

  final List<Map<String, dynamic>> cart = [];
  double bankBalance = 50.0;
  static const double dutchTax = 0.21;
  static const double deliveryFee = 5.0;

  int get cartItemCount => cart.length;

  void addToCart(Map<String, dynamic> item) {
    if (!cart.any((cartItem) => cartItem['name'] == item['name'] && cartItem['price'] == item['price'])) {
      print("Adding ${item['name']} to cart");
      cart.add(item);
      notifyListeners();
    } else {
      print("${item['name']} is already in the cart.");
    }
  }

  void removeFromCart(Map<String, dynamic> item) {
    print("Removing ${item['name']} from cart");
    cart.remove(item);
    notifyListeners();
  }

  double calculateTotalCost() {
    double totalCost = cart.fold(0, (sum, item) => sum + item['price']);
    double tax = totalCost * dutchTax;
    print("Calculating total cost: \$${totalCost.toStringAsFixed(2)} + tax: \$${tax.toStringAsFixed(2)} + delivery fee: \$${deliveryFee.toStringAsFixed(2)}");
    return totalCost + tax + deliveryFee;
  }

  void placeOrder() {
    double totalCost = calculateTotalCost();
    print("Placing order. Total cost: \$${totalCost.toStringAsFixed(2)}");
    print("Current bank balance: \$${bankBalance.toStringAsFixed(2)}");
    if (bankBalance >= totalCost) {
      bankBalance -= totalCost;
      cart.clear();
      print("Order placed successfully. New bank balance: \$${bankBalance.toStringAsFixed(2)}");
      notifyListeners();
    } else {
      print("Not enough balance to place the order. Current balance: \$${bankBalance.toStringAsFixed(2)}");
    }
  }

  void updateBalance(double amount) {
    print("Updating bank balance to \$${amount.toStringAsFixed(2)}");
    bankBalance = amount;
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      drawer: const AppDrawer(),
      body: const MenuPage(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(context, 'Ordering', const MenuPage()),
          _buildDrawerItem(context, 'Placing Order', const CartPage()),
          _buildDrawerItem(context, 'Contact', const ContactPage()),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: appState.menuItems.map((item) => _buildMenuItem(context, item)).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    var appState = context.watch<MyAppState>();
    bool isItemInCart = appState.cart.any((cartItem) => cartItem['name'] == item['name'] && cartItem['price'] == item['price']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isItemInCart ? Colors.green.shade100 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isItemInCart ? Colors.greenAccent.withAlpha(127) : Colors.grey.withAlpha(50),
            blurRadius: 5,
          )
        ],
      ),
      child: ListTile(
        title: Text(item['name']),
        subtitle: Text('Price: \$${item['price']}'),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart, color: isItemInCart ? Colors.green : Colors.black),
          onPressed: () => appState.addToCart(item),
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: appState.cart.map((item) => _buildCartItem(context, item)).toList(),
            ),
          ),
          _buildSummary(context, appState),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item) {
    var appState = context.watch<MyAppState>();
    return ListTile(
      title: Text(item['name']),
      subtitle: Text('Price: \$${item['price']}'),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => appState.removeFromCart(item),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, MyAppState appState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Total: \$${appState.calculateTotalCost().toStringAsFixed(2)}'),
          ElevatedButton(onPressed: appState.placeOrder, child: const Text('Place Order')),
        ],
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Phone: +31617873081\nEmail: pgandhi2022@ash.nl\nAddress: American School of The Hague, The Netherlands, Wassenaar', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
