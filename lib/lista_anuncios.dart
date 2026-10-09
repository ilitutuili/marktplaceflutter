import 'package:flutter/material.dart';

import 'anuncio.dart';
import 'card_anuncio.dart';
import 'formulario_anuncio.dart';

class ListaAnuncios extends StatefulWidget {
  const ListaAnuncios({super.key});

  @override
  State<ListaAnuncios> createState() => _ListaAnunciosState();
}

class _ListaAnunciosState extends State<ListaAnuncios> {
  final List<Anuncio> anuncios = [];

  Future<void> adicionarAnuncio() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioAnuncio()),
    );

    if (resultado is Anuncio) {
      setState(() {
        anuncios.add(resultado);
      });
    }
  }

  Future<void> editarAnuncio(Anuncio anuncio) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioAnuncio(anuncio: anuncio),
      ),
    );

    if (resultado == true) {
      setState(() {});
    }
  }

  void excluirAnuncio(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir anúncio'),
          content: const Text('Tem certeza que deseja excluir este anúncio?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  anuncios.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anúncio excluído com sucesso!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 10),
            Text(
              'Meu Marketplace',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar anúncios...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: anuncios.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Nenhum anúncio cadastrado',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: anuncios.length,
                    itemBuilder: (context, index) {
                      final anuncio = anuncios[index];

                      return CardAnuncio(
                        anuncio: anuncio,

                        onEditar: () {
                          editarAnuncio(anuncio);
                        },

                        onExcluir: () {
                          excluirAnuncio(index);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: adicionarAnuncio,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo anúncio'),
      ),
    );
  }
}
