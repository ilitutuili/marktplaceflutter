import 'dart:convert';

import 'package:flutter/material.dart';
import 'anuncio.dart';
import 'imagem_utils.dart';

class CardAnuncio extends StatelessWidget {
  final Anuncio anuncio;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onCompartilhar;
  final VoidCallback onContato;

  const CardAnuncio({
    super.key,
    required this.anuncio,
    required this.onEditar,
    required this.onExcluir,
    required this.onCompartilhar,
    required this.onContato,
  });

  String formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: anuncio.imagemBase64 != null
                  ? Image.memory(
                      base64Decode(anuncio.imagemBase64!),
                      fit: BoxFit.cover,
                    )
                  : anuncio.imagemPath != null
                  ? FutureBuilder<bool>(
                      future: imagemExiste(anuncio.imagemPath),
                      builder: (context, snapshot) => snapshot.data == true
                          ? imagemLocal(anuncio.imagemPath)!
                          : Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: const Color(0xFF111111),
                            ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: const Color(0xFF111111),
                    ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    anuncio.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    formatarPreco(anuncio.preco),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111111),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onContato,
                        icon: const Icon(
                          Icons.contact_phone_outlined,
                          size: 18,
                        ),
                        label: const Text('Contato'),
                      ),
                      TextButton.icon(
                        onPressed: onCompartilhar,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Compartilhar'),
                      ),
                      TextButton.icon(
                        onPressed: onEditar,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                      ),
                      TextButton.icon(
                        onPressed: onExcluir,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Excluir'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
