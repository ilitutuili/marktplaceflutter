import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'anuncio.dart';

class BancoDados {
  BancoDados._();

  static final BancoDados instancia = BancoDados._();
  Database? _banco;

  Future<Database> get banco async {
    if (_banco != null) return _banco!;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final caminho = kIsWeb
        ? 'marketplace.db'
        : '${await getDatabasesPath()}/marketplace.db';
    _banco = await openDatabase(
      caminho,
      version: 3,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE anuncios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          descricao TEXT NOT NULL,
          preco REAL NOT NULL,
          imagemPath TEXT,
          imagemBase64 TEXT,
          telefone TEXT,
          email TEXT
        )
      '''),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE anuncios ADD COLUMN telefone TEXT');
          await db.execute('ALTER TABLE anuncios ADD COLUMN email TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE anuncios ADD COLUMN imagemBase64 TEXT');
        }
      },
    );
    return _banco!;
  }

  Future<List<Anuncio>> listar() async {
    final db = await banco;
    final linhas = await db.query('anuncios', orderBy: 'id DESC');
    return linhas.map(Anuncio.fromMap).toList();
  }

  Future<int> inserir(Anuncio anuncio) async =>
      (await banco).insert('anuncios', anuncio.toMap());

  Future<int> atualizar(Anuncio anuncio) async => (await banco).update(
    'anuncios',
    anuncio.toMap()..remove('id'),
    where: 'id = ?',
    whereArgs: [anuncio.id],
  );

  Future<int> excluir(int id) async =>
      (await banco).delete('anuncios', where: 'id = ?', whereArgs: [id]);
}
