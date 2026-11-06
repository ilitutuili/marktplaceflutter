class Anuncio {
  int? id;
  String titulo;
  String descricao;
  double preco;
  String? imagemPath;
  String? imagemBase64;
  String? telefone;
  String? email;

  Anuncio({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    this.imagemPath,
    this.imagemBase64,
    this.telefone,
    this.email,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'preco': preco,
    'imagemPath': imagemPath,
    'imagemBase64': imagemBase64,
    'telefone': telefone,
    'email': email,
  };

  factory Anuncio.fromMap(Map<String, Object?> map) => Anuncio(
    id: map['id'] as int?,
    titulo: map['titulo'] as String,
    descricao: map['descricao'] as String,
    preco: (map['preco'] as num).toDouble(),
    imagemPath: map['imagemPath'] as String?,
    imagemBase64: map['imagemBase64'] as String?,
    telefone: map['telefone'] as String?,
    email: map['email'] as String?,
  );
}
