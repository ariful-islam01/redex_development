import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/apis.dart';

class RedexBalancePage extends StatefulWidget {
  @override
  _RedexBalancePageState createState() => _RedexBalancePageState();
}

class _RedexBalancePageState extends State<RedexBalancePage> {
  double redexCoin = 0.0; // Initially set to 0.0 for new users
  String userId = APIs.user.uid; // Use dynamic user ID from APIs class
  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _getRedexCoin();
  }

  // Fetch Redex balance from Firebase using APIs class
  void _getRedexCoin() async {
    try {
      double balance = await APIs.getRedexBalance();
      setState(() {
        redexCoin = balance;
      });
    } catch (e) {
      print("Error fetching Redex Coin: $e");
    }
  }

  // Method to update Redex Coin in Firebase using APIs class
  Future<void> _updateRedexCoin(double amount) async {
    await APIs.updateRedexBalance(amount);
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the height to be controlled
      builder: (BuildContext context) {
        return Container(
          height: 400, // Set a fixed height for the bottom sheet
          padding: const EdgeInsets.all(20),
          child: Center( // Center the content vertically
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    hint: const Text('Choose a payment method'),
                    items: [
                      DropdownMenuItem(
                        value: 'Bkash',
                        child: Row(
                          children: const [
                            ImageIcon(
                              AssetImage("images/bkash.png"),
                              color: Color.fromRGBO(209, 32, 83, 1),
                              size: 50,
                            ),
                            SizedBox(width: 10),
                            Text('Buy with Bkash'),
                          ],
                        ),
                      ),
                      // Add more payment methods as needed
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmPurchase();
                    },
                    child: const Text('Confirm Purchase'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _confirmPurchase() {
    if (selectedPaymentMethod != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Purchase'),
            content: Text('Do you want to buy 100 Redex Coins with $selectedPaymentMethod?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _buyRedexCoin(); // Call to buy Redex Coin
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
    }
  }

  // Method to buy Redex Coin
  void _buyRedexCoin() async {
    double amountToAdd = 100.0; // The amount to add to the balance
    await _updateRedexCoin(amountToAdd); // Update the balance in Firebase
    setState(() {
      redexCoin += amountToAdd; // Update the local state with the new balance
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully purchased 100 Redex Coins!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Redex Balance',
          style: TextStyle(
            fontSize: 24,             // Increase font size
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 170.0, left: 30.0),
            child: Column(
              children: [
                const Text(
                  'Your Redex Coin Balance',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                Text(
                  redexCoin.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 48.0, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 350.0, left: 35),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                _showPaymentOptions();
              },
              child: const Text(
                'Buy Redex Coin',
                style: TextStyle(
                  color: Colors.white,         // Set text color to white
                  fontWeight: FontWeight.bold, // Make text bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
