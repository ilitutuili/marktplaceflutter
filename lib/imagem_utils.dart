import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'arquivo_imagem_stub.dart'
    if (dart.library.io) 'arquivo_imagem_io.dart'
    as plataforma;

Future<String> guardarImagem(Uint8List bytes, String nome) =>
    plataforma.guardarImagem(bytes, nome);

Future<bool> imagemExiste(String? caminho) => plataforma.imagemExiste(caminho);

Widget? imagemLocal(String? caminho) => plataforma.imagemLocal(caminho);
