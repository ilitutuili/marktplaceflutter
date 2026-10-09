import 'package:flutter/material.dart';
import 'lista_anuncios.dart';

void main() {
  runApp(const MeuMarketplace());
}

class MeuMarketplace extends StatelessWidget {
  const MeuMarketplace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Marketplace',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const ListaAnuncios(),
    );
  }
}
