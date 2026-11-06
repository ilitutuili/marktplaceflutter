import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

Future<String> guardarImagem(Uint8List bytes, String nome) async {
  final pasta = await getApplicationDocumentsDirectory();
  final destino = p.join(pasta.path, nome);
  return (await File(destino).writeAsBytes(bytes, flush: true)).path;
}

Future<bool> imagemExiste(String? caminho) async =>
    caminho != null && await File(caminho).exists();

Future<Uint8List> lerImagem(String caminho) => File(caminho).readAsBytes();

Widget? imagemLocal(String? caminho) =>
    caminho != null ? Image.file(File(caminho), fit: BoxFit.cover) : null;
