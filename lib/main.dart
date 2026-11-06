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
      title: 'Marketplace do Fogão',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF111111),
          primary: const Color(0xFF111111),
          secondary: const Color(0xFF555555),
          surface: const Color(0xFFF7F7F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home: const ListaAnuncios(),
    );
  }
}
