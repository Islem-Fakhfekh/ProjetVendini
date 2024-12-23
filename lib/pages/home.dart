import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  String? _userName;
  String? _userProfileImage;
  bool isLoading = true;
  final Set<String> _favoriteProducts = {}; // Track favorite products
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _scrollProducts = [
    {'name': 'Produit 1', 'price': '20 TND', 'image': 'assets/images/1.png'},
    {'name': 'Produit 2', 'price': '40 TND', 'image': 'assets/images/2.png'},
    {'name': 'Produit 3', 'price': '60 TND', 'image': 'assets/images/3.png'},
    {'name': 'Produit 5', 'price': '100 TND', 'image': 'assets/images/5.png'},
  ];

  final List<Map<String, String>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();

    _initUser();
    _loadFavorites();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['nom'] + ' ' + userDoc['prenom'] ?? 'User';
            _userProfileImage =
                userDoc['profileImage'] ?? 'assets/images/default_profile.png';
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
  }

  Future<void> _loadFavorites() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userFavorites = await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .get();

        if (userFavorites.exists) {
          List<dynamic> favorites = userFavorites['favorites'] ?? [];
          setState(() {
            _favoriteProducts.addAll(
              favorites.map((item) => item['id'].toString()).toSet(),
            );
          });
        }
      } catch (e) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _addFavoriteToFirestore(
      String productId, String productName) async {
    User? user =
        _auth.currentUser; // Assurez-vous que l'utilisateur est connecté
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('favorites').doc(user.uid).set(
            {
              'favorites': FieldValue.arrayUnion([
                {'id': productId, 'name': productName}
              ])
            },
            SetOptions(
                merge:
                true)); // Utilisez merge pour ne pas écraser les données existantes
      } catch (e) {
        print('Error adding favorite: $e');
      }
    }
  }

  Future<void> _removeFavoriteFromFirestore(
      String productId, String productName) async {
    User? user =
        _auth.currentUser; // Assurez-vous que l'utilisateur est connecté
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .update({
          'favorites': FieldValue.arrayRemove([
            {'id': productId, 'name': productName}
          ])
        });
      } catch (e) {
        print('Error removing favorite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCDFDB),
        automaticallyImplyLeading:
        false, // Prevent automatic spacing of the menu
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            // Profile image with dynamic reduced size
            // Profile image with dynamic reduced size
            GestureDetector(
              onTap: () {
                // Navigate to the user profile page
                Navigator.pushNamed(context, '/profil', arguments: _auth.currentUser!.uid); // Pass the user ID
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.07, // 6% of screen width
                backgroundImage: _userProfileImage != null
                    ? NetworkImage(_userProfileImage!)
                    : AssetImage("assets/profile.png") as ImageProvider,
              ),
            ),


            SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.01), // Spacing between image and text
            // Username text
            Expanded(
              child: Text(
                _userName ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width *
                      0.035, // Dynamically reduced size
                  overflow: TextOverflow.ellipsis, // Prevent text overflow
                ),
              ),
            ),
            // Favorite icon aligned to the right with reduced spacing
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/favoris'); // Navigate to favorites page
              },
            ),
            // Cart icon aligned to the right
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.04), // Dynamic padding
              child: Text(
                'Découvrez nos offres !',
                style: TextStyle(
                  fontSize:
                  MediaQuery.of(context).size.width * 0.06, // Dynamic size
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB50D56),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.2, // 20% of screen height
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _scrollProducts
                      .map((product) => _buildStaticProductCard(
                    product['name']!,
                    product['price']!,
                    product['image']!,
                    hideDetails: true,
                    showDiscount: true,
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit par nom ou prix...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('Aucun produit trouvé'));
                          }

                          final products = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              'id': doc.id, // Include the Firestore document ID
                              'label': data['label'] ?? 'Produit inconnu',
                              'price': data['price']?.toString() ?? '0',
                              'imageUrl': data['imageUrl'] ?? 'assets/images/default.png',
                            };
                          }).where((product) {
                            final name = product['label'] ?? '';
                            final price = product['price']?.toString() ?? '';
                            return name.toLowerCase().contains(_searchQuery) ||
                                price.toLowerCase().contains(_searchQuery);
                          }).toList();


                          return GridView.builder(
                            itemCount: products.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                              MediaQuery.of(context).size.width > 600
                                  ? 3
                                  : 2,
                              crossAxisSpacing:
                              MediaQuery.of(context).size.width * 0.04,
                              mainAxisSpacing:
                              MediaQuery.of(context).size.height * 0.02,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(
                                product['label'] ?? 'Inconnu',
                                product['price'] ?? '0',
                                product['imageUrl'] ??
                                    'assets/images/default.png',
                                productId:
                                product['id'], // Passer productId ici
                                showCartIcon: true,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      _buildBottomNavBar(), // Correct placement of bottomNavigationBar
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 237, 188, 223),
            ),
            child: Text(
              'Catégories',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      color: const Color(0xFFFCDFDB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              print('Accueil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showSettingsMenu();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              print('Notifications');
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() async {
    try {
      // Show a confirmation dialog before logging out
      bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Déconnexion'),
            content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Déconnexion'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      // Only proceed with logout if confirmed
      if (confirmLogout == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Perform logout
        await FirebaseAuth.instance.signOut();

        // Dismiss loading indicator and navigate to login
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      // Handle potential logout errors
      Navigator.of(context).pop(); // Dismiss loading indicator if it's showing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de déconnexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProductCard(
      String productName,
      String price,
      String imagePath, {
        required String productId,
        bool showCartIcon = false,
        bool showDiscount = false,
        bool hideDetails = false,
      }) {
    bool isFavorite = _favoriteProducts.contains(productId);

    return GestureDetector(
      onTap: () {
        if (imagePath == 'assets/images/4.png') {
          Navigator.pushNamed(context, '/infoProd'); // Navigation vers InfoProd
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal:
            MediaQuery.of(context).size.width * 0.04), // Padding dynamique
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagePath,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
              if (showDiscount)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.red,
                    child: const Text(
                      '-50%',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!hideDetails)
                Positioned(
                  bottom: 5,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 251, 251, 251), // Noir pur pour le contraste
                          fontWeight: FontWeight.bold, // Texte en gras
                          fontSize:
                          16, // Taille du texte ajustée pour plus de lisibilité
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 143, 131, 131), // Noir pur pour le contraste
                          fontWeight: FontWeight.bold, // Texte en gras
                          fontSize:
                          16, // Taille du texte ajustée pour plus de lisibilité
                        ),
                      ),
                    ],
                  ),
                ),
              if (showCartIcon)
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      print('Produit ajouté au panier : $productName');
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(Icons.add_shopping_cart,
                          color: Colors.pink, size: 18),
                    ),
                  ),
                ),
              Positioned(
                top: 5,
                left: 5,
                child: IconButton(
                  icon: Icon(
                    _favoriteProducts.contains(productId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite
                        ? const Color.fromARGB(255, 156, 8, 77)
                        : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        _favoriteProducts
                            .remove(productId); // Retirer localement
                        _removeFavoriteFromFirestore(productId, productName); //
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Produit supprimé des favoris avec succès')),
                        );
                      } else {
                        _favoriteProducts
                            .add(productId); // Ajouter au favori local
                        _addFavoriteToFirestore(productId, productName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Produit ajouté aux favoris avec succès')),
                        );
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticProductCard(
      String productName, String price, String imagePath,
      {bool showDiscount = false,
        bool hideDetails = false,
        bool showCartIcon = false}) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details or another action if needed
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal:
            MediaQuery.of(context).size.width * 0.04), // Padding dynamique
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
              if (showDiscount)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.red,
                    child: const Text(
                      '-50%',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!hideDetails)
                Positioned(
                  bottom: 5,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 251, 251, 251), // Noir pur pour le contraste
                          fontWeight: FontWeight.bold, // Texte en gras
                          fontSize:
                          16, // Taille du texte ajustée pour plus de lisibilité
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 143, 131, 131), // Noir pur pour le contraste
                          fontWeight: FontWeight.bold, // Texte en gras
                          fontSize:
                          16, // Taille du texte ajustée pour plus de lisibilité
                        ),
                      ),
                    ],
                  ),
                ),
              if (showCartIcon)
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      print('Produit ajouté au panier : $productName');
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(Icons.add_shopping_cart,
                          color: Colors.pink, size: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}





