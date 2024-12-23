import 'package:flutter/material.dart';

class FourPage extends StatelessWidget {
  const FourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/back.png'), // Image d'arrière-plan
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Image principale (ordinateur avec sac)
                Image.asset(
                  'assets/images/pc.png', // Remplacez par votre image
                  height: 200,
                ),
                const SizedBox(height: 30),
                // Titre "Comment Vendre ?"
                const Text(
                  "Comment Vendre ?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB4004E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Description
                const Text(
                  "Prenez des photos\nDéposez votre article\nDès que vendu, un livreur\nviendra le récupérer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffad492b),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Flèche pour naviguer vers la page suivante
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/five'); // Navigation vers SixPage
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFB4004E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
              child: Image.asset(
                'assets/images/Home.png', // Path to your home image
                height: 30, // Adjust the height as needed
                width: 30, // Adjust the width as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
