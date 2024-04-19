import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      // Set Splash screen as the initial route
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/pokemonList': (context) => PokemonList(),
        '/paymentScreen': (context) => PaymentScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Delay navigation by 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/p.gif',
          fit: BoxFit.cover, // Ensure image covers the entire screen
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  bool isButtonEnabled = false;

  void _toggleButton() {
    setState(() {
      isButtonEnabled = username.isNotEmpty && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  username = value;
                  _toggleButton();
                });
              },
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                  _toggleButton();
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                // Navigate to the Pokémon list if username and password are not empty
                if (username.isNotEmpty && password.isNotEmpty) {
                  Navigator.pushReplacementNamed(context, '/pokemonList');
                }
              }
                  : null,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonData = [];

  @override
  void initState() {
    super.initState();
    // Delay fetching data and displaying the list by 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      fetchPokemonData();
    });
  }

  Future<void> fetchPokemonData() async {
    final Uri url = Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void sortPokemonList() {
    setState(() {
      pokemonData.sort((a, b) => a['name'].compareTo(b['name']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon Cards'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              sortPokemonList();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: pokemonData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: pokemonData.length,
        itemBuilder: (BuildContext context, int index) {
          final pokemon = pokemonData[index];
          final marketPrice = pokemon['tcgplayer'] != null &&
              pokemon['tcgplayer']['prices'] != null &&
              pokemon['tcgplayer']['prices']['holofoil'] != null &&
              pokemon['tcgplayer']['prices']['holofoil']['market'] !=
                  null
              ? pokemon['tcgplayer']['prices']['holofoil']['market']
              : 0.0;
          return GestureDetector(
            onTap: () {
              // Navigate to the payment screen when a Pokémon is tapped
              Navigator.pushNamed(context, '/paymentScreen');
            },
            child: ListTile(
              leading: Image.network(pokemon['images']['small']),
              title: Text(pokemon['name']),
              subtitle:
              Text('Market Price: \$${marketPrice.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController personNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/pokemonList');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: expiryDateController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: personNameController,
                      decoration: InputDecoration(
                        labelText: 'Person\'s Name',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform payment processing here
                // For now, just show a snackbar with payment success message
                final snackBar =
                SnackBar(content: Text('Payment Successful'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                // Navigate back to the Pokémon list
                Navigator.pop(context);
              },
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
