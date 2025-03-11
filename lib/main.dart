import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Main function where the app is initialized with ChangeNotifierProvider
void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MyAppState(), // Provides the app's state for state management
    child: const MyApp(), // The main MyApp widget
  ));
}

// MyApp class sets up the MaterialApp for the app with basic theme and home page
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu', // Title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color for the app
        scaffoldBackgroundColor: Colors.white, // Background color of the scaffold
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Text color for body large
          bodyMedium: TextStyle(color: Colors.black), // Text color for body medium
        ),
      ),
      home: const HomePage(), // The home page of the app
    );
  }
}

// The app state (state management using ChangeNotifier)
class MyAppState extends ChangeNotifier {
  // Menu items list with names and prices
final List<Map<String, dynamic>> menuItems = [
  {'name': 'Pizza', 'price': 12.5, 'description': 'Cheesy, oven-baked with fresh toppings.'},
  {'name': 'Burger', 'price': 8.0, 'description': 'Juicy beef patty with fresh lettuce and tomato.'},
  {'name': 'Pasta', 'price': 10.0, 'description': 'Classic Italian pasta with rich tomato sauce.'},
  {'name': 'Sushi', 'price': 15.0, 'description': 'Fresh sushi rolls with wasabi and soy sauce.'},
  {'name': 'Salad', 'price': 7.0, 'description': 'Crisp greens with a tangy vinaigrette.'},
  {'name': 'Steak', 'price': 20.0, 'description': 'Grilled to perfection with a side of veggies.'},
  {'name': 'Tacos', 'price': 9.5, 'description': 'Spicy and flavorful, served with salsa.'},
  {'name': 'Soup', 'price': 6.5, 'description': 'Warm and comforting, made fresh daily.'},
  {'name': 'Ice Cream', 'price': 5.0, 'description': 'Creamy and delicious, available in many flavors.'},
  {'name': 'Cake', 'price': 6.0, 'description': 'Soft and fluffy with a sweet frosting.'},
];

  // Cart where items will be stored when added
  final List<Map<String, dynamic>> cart = [];
  double bankBalance = 50.0; // Starting balance for the user
  static const double dutchTax = 0.21; // Tax rate for Dutch transactions
  static const double deliveryFee = 5.0; // Flat delivery fee

  // Getter for the count of items in the cart
  int get cartItemCount => cart.length;

  // Add item to the cart
  void addToCart(Map<String, dynamic> item) {
    // Find an existing item in the cart or create a new one if not found
    var cartItem = cart.firstWhere(
      (cartItem) => cartItem['name'] == item['name'],
      orElse: () => {},
    );

    // If item exists, increment quantity, else add it to the cart
    if (cartItem.isNotEmpty) {
      cartItem['quantity'] += 1;
    } else {
      cart.add({'name': item['name'], 'price': item['price'], 'quantity': 1});
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  // Remove item from the cart
  void removeFromCart(Map<String, dynamic> item) {
    var cartItem = cart.firstWhere(
      (cartItem) => cartItem['name'] == item['name'],
      orElse: () => {},
    );

    // If item exists, decrement quantity or remove it if quantity is 1
    if (cartItem.isNotEmpty) {
      if (cartItem['quantity'] > 1) {
        cartItem['quantity'] -= 1;
      } else {
        cart.remove(cartItem);
      }
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  // Calculate total cost including tax and delivery fee
  double calculateTotalCost() {
    double totalCost = cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    double tax = totalCost * dutchTax; // Tax calculation
    return totalCost + tax + deliveryFee; // Return total cost including tax and delivery
  }

  // Place the order by deducting the total cost from the bank balance
  void placeOrder() {
    double totalCost = calculateTotalCost();
    if (bankBalance >= totalCost) { // Ensure there's enough balance to place the order
      bankBalance -= totalCost; // Deduct total cost from the balance
      cart.clear(); // Clear the cart after placing the order
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Update the bank balance
  void updateBalance(double amount) {
    bankBalance = amount;
    notifyListeners(); // Notify listeners to update the UI
  }
}

// HomePage widget where the main structure of the screen is displayed
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')), // AppBar with title
      drawer: const AppDrawer(), // Drawer with menu options
      body: const MenuPage(), // Main content showing the menu
    );
  }
}

// AppDrawer widget displays the side menu with navigation options
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue), // Drawer header style
            child: Text('Menu App', style: TextStyle(color: Colors.white, fontSize: 24)), // Title in drawer
          ),
          ListTile(
            title: const Text('Home'), // Home option
            onTap: () => Navigator.pop(context), // Close the drawer
          ),
          ListTile(
            title: const Text('Order'), // Navigate to the order page
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderPage()),
            ),
          ),
          ListTile(
            title: const Text('Contact'), // Navigate to the contact page
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactPage()),
            ),
          ),
        ], // List of menu items in the drawer
      ),
    );
  }
}

// MenuPage widget that displays the list of menu items and allows adding/removing items from the cart
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Watch for state changes in appState
    return ListView(
      padding: const EdgeInsets.all(20), // Padding around the menu list
      children: appState.menuItems.map((item) => _buildMenuItem(context, item)).toList(), // Build list of menu items
    );
  }

  // Helper function to build each individual menu item with a shopping cart icon
  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    var appState = context.watch<MyAppState>(); // Access app state to check cart
    var cartItem = appState.cart.firstWhere(
      (cartItem) => cartItem['name'] == item['name'],
      orElse: () => {},
    );

    int quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0; // Get quantity of item in the cart, default to 0

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500), // Animation duration for fade-in effect
      curve: Curves.easeInOut, // Easing curve for smooth animation
      opacity: quantity > 0 ? 1.0 : 0.5,  // Set opacity to 1 if the item is in the cart, else 0.5
      child: ListTile(
        title: Text('${item['name']} (x$quantity) - \$${item['price']}'),
        subtitle: Text(item['description'], style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Button to remove item from the cart
            IconButton(
              icon: Icon(Icons.remove_circle, color: quantity > 0 ? Colors.red : Colors.grey),
              onPressed: quantity > 0 ? () => appState.removeFromCart(item) : null,
            ),

            // Animated button to add item to the cart, enlarges when added
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IconButton(
                iconSize: quantity > 0 ? 32 : 24, // Change icon size when item is added
                icon: Icon(Icons.add_shopping_cart, color: quantity > 0 ? Colors.green : Colors.black),
                onPressed: () => appState.addToCart(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ContactPage widget that displays the restaurant's contact details.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')), // AppBar for Contact page
      body: Padding(
        padding: const EdgeInsets.all(20), // Padding for the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: const [
            Text('📍 Address: American School of The Hague, Wassenaar, The Netherlands'),
            SizedBox(height: 10), // Space between lines
            Text('📞 Phone: +31617873081'),
            SizedBox(height: 10),
            Text('📧 Email: pgandhi2022@ash.nl'),
          ],
        ),
      ),
    );
  }
}

// OrderPage widget for displaying the order summary and options to place an order.
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Access app state to get cart and balance info

    // Generate list of ordered items from the cart
    List<Widget> orderedItems = appState.cart.map((item) {
      return ListTile(
        title: Text('${item['name']} (x${item['quantity']})'), // Display item name and quantity
        subtitle: Text('\$${(item['price'] * item['quantity']).toStringAsFixed(2)}'), // Display price
      );
    }).toList();

    // Controller to allow the user to update their balance
    TextEditingController balanceController = TextEditingController();
    balanceController.text = appState.bankBalance.toStringAsFixed(2); // Set initial balance text

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'), // AppBar for Order Summary page
        backgroundColor: Colors.green, // Custom AppBar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Padding for the body
        child: Center( // Center-align the column content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the column elements
            children: [
              // Display the current balance with bold font
              Text(
                'Current Balance: \$${appState.bankBalance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Space between balance display and input field
              
              // TextField for updating balance
              TextField(
                controller: balanceController, // Link the controller to the TextField
                keyboardType: TextInputType.number, // Allow only number input
                decoration: InputDecoration(
                  labelText: 'Update Balance', // Label for the input field
                  border: OutlineInputBorder(), // Border for the TextField
                ),
                onChanged: (newValue) {
                  // When the balance input changes, update the balance in the app state
                  double newBalance = double.tryParse(newValue) ?? appState.bankBalance; 
                  appState.updateBalance(newBalance); // Update balance in app state
                },
              ),
              const SizedBox(height: 20),

              // Display each ordered item
              ...orderedItems,

              // Display the tax and delivery fee
              const SizedBox(height: 20),
              Text(
                'Tax (21%): \$${(appState.calculateTotalCost() - appState.calculateTotalCost() / (1 + MyAppState.dutchTax)).toStringAsFixed(2)}', // Calculate and display tax
              ),
              const SizedBox(height: 10),
              Text('Delivery Fee: \$${MyAppState.deliveryFee.toStringAsFixed(2)}'), // Display delivery fee
              const SizedBox(height: 20),

              // Display the total cost of the order
              Text(
                'Total: \$${appState.calculateTotalCost().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold total cost
              ),
              const SizedBox(height: 20),

              // Button to place the order
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: (appState.bankBalance >= appState.calculateTotalCost() && appState.cart.isNotEmpty) // Only enable button if balance is sufficient and cart is not empty
                    ? () {
                        appState.placeOrder(); // Place the order and deduct from balance
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Order Placed'), // Dialog title
                            content: const Text('Your order has been placed successfully.'), // Dialog content
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context), // Close dialog
                              ),
                            ],
                          ),
                        );
                      }
                    : null, // Disable button if conditions are not met

                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
