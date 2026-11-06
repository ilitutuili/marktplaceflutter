import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'anuncio.dart';
import 'imagem_utils.dart';

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
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _imagemTemporaria;
  Uint8List? _imagemBytes;
  bool _salvando = false;

  bool get editando => widget.anuncio != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      _tituloController.text = widget.anuncio!.titulo;
      _descricaoController.text = widget.anuncio!.descricao;
      _precoController.text = widget.anuncio!.preco.toStringAsFixed(2);
      _telefoneController.text = widget.anuncio!.telefone ?? '';
      _emailController.text = widget.anuncio!.email ?? '';
      _imagemTemporaria =
          widget.anuncio!.imagemPath ?? widget.anuncio!.imagemBase64;
      if (widget.anuncio!.imagemBase64 != null) {
        _imagemBytes = base64Decode(widget.anuncio!.imagemBase64!);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> selecionarImagem() async {
    try {
      final imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (imagem != null) {
        final bytes = await imagem.readAsBytes();
        if (mounted) {
          setState(() {
            _imagemTemporaria = imagem.path;
            _imagemBytes = bytes;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível selecionar a imagem.'),
          ),
        );
      }
    }
  }

  Future<String?> _guardarImagem() async {
    final atual = _imagemTemporaria;
    if (atual == null) return null;
    if (atual == widget.anuncio?.imagemPath) return atual;
    return guardarImagem(
      _imagemBytes!,
      'anuncio_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
  }

  String? _imagemParaWeb() => _imagemTemporaria == null
      ? null
      : _imagemBytes == null
      ? widget.anuncio?.imagemBase64
      : base64Encode(_imagemBytes!);

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? preco = double.tryParse(_precoController.text.replaceAll(',', '.'));

    if (preco == null) {
      return;
    }

    setState(() => _salvando = true);
    try {
      final imagemPath = kIsWeb ? null : await _guardarImagem();
      final anuncio = Anuncio(
        id: widget.anuncio?.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
        imagemPath: imagemPath,
        imagemBase64: kIsWeb ? _imagemParaWeb() : null,
        telefone: _telefoneController.text.trim().isEmpty
            ? null
            : _telefoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, anuncio);
    } catch (_) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível salvar o anúncio. Tente novamente.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar anúncio' : 'Novo anúncio'),
        backgroundColor: const Color(0xFF111111),
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
                'Foto do produto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: selecionarImagem,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imagemTemporaria == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 42),
                            SizedBox(height: 8),
                            Text('Toque para escolher uma imagem'),
                          ],
                        )
                      : _imagemBytes != null
                      ? Image.memory(_imagemBytes!, fit: BoxFit.cover)
                      : kIsWeb
                      ? const Icon(Icons.image_outlined, size: 42)
                      : imagemLocal(_imagemTemporaria) ??
                            const Icon(Icons.image_outlined, size: 42),
                ),
              ),
              if (_imagemTemporaria != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _imagemTemporaria = null;
                      _imagemBytes = null;
                    }),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover imagem'),
                  ),
                ),
              const SizedBox(height: 16),

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

              const Text(
                'Contato do anunciante',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (para SMS/WhatsApp)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) return null;
                  return valor.contains('@') && valor.contains('.')
                      ? null
                      : 'Digite um e-mail válido';
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : salvar,
                  icon: Icon(editando ? Icons.save : Icons.add_shopping_cart),
                  label: Text(
                    _salvando
                        ? 'SALVANDO...'
                        : editando
                        ? 'SALVAR ALTERAÇÕES'
                        : 'PUBLICAR ANÚNCIO',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
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
