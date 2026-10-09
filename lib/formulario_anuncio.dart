import 'package:flutter/material.dart';
import 'anuncio.dart';

class FormularioAnuncio extends StatefulWidget {
  final Anuncio? anuncio;

  const FormularioAnuncio({super.key, this.anuncio});

  @override
  State<FormularioAnuncio> createState() => _FormularioAnuncioState();
}

class _FormularioAnuncioState extends State<FormularioAnuncio> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();

  final TextEditingController _descricaoController = TextEditingController();

  final TextEditingController _precoController = TextEditingController();

  bool get editando => widget.anuncio != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      _tituloController.text = widget.anuncio!.titulo;
      _descricaoController.text = widget.anuncio!.descricao;
      _precoController.text = widget.anuncio!.preco.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();

    super.dispose();
  }

  void salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? preco = double.tryParse(_precoController.text.replaceAll(',', '.'));

    if (preco == null) {
      return;
    }

    if (editando) {
      widget.anuncio!.titulo = _tituloController.text;
      widget.anuncio!.descricao = _descricaoController.text;
      widget.anuncio!.preco = preco;

      Navigator.pop(context, true);
    } else {
      Anuncio novoAnuncio = Anuncio(
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        preco: preco,
      );

      Navigator.pop(context, novoAnuncio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar anúncio' : 'Novo anúncio'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações do anúncio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              const Text(
                'Título',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  hintText: 'Digite o título do anúncio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite um título';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Descrição',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Digite a descrição do anúncio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 70),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite uma descrição';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Preço',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _precoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite um preço';
                  }

                  double? preco = double.tryParse(valor.replaceAll(',', '.'));

                  if (preco == null || preco < 0) {
                    return 'Digite um preço válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: salvar,
                  icon: Icon(editando ? Icons.save : Icons.add_shopping_cart),
                  label: Text(
                    editando ? 'SALVAR ALTERAÇÕES' : 'PUBLICAR ANÚNCIO',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
