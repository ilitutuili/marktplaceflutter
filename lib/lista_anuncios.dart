import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'anuncio.dart';
import 'banco_dados.dart';
import 'card_anuncio.dart';
import 'formulario_anuncio.dart';
import 'imagem_utils.dart';
import 'arquivo_imagem_stub.dart'
    if (dart.library.io) 'arquivo_imagem_io.dart'
    as arquivo_imagem;

class ListaAnuncios extends StatefulWidget {
  const ListaAnuncios({super.key});

  @override
  State<ListaAnuncios> createState() => _ListaAnunciosState();
}

class _ListaAnunciosState extends State<ListaAnuncios> {
  final _banco = BancoDados.instancia;
  final _buscaController = TextEditingController();
  List<Anuncio> anuncios = [];
  bool carregando = true;
  String busca = '';

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
    _buscaController.addListener(() {
      setState(() => busca = _buscaController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarAnuncios() async {
    try {
      final dados = await _banco.listar();
      if (!mounted) return;
      setState(() {
        anuncios = dados;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar os anúncios.')),
      );
    }
  }

  Future<void> adicionarAnuncio() async {
    final resultado = await Navigator.push<Anuncio>(
      context,
      MaterialPageRoute(builder: (_) => const FormularioAnuncio()),
    );
    if (resultado == null) return;
    try {
      resultado.id = await _banco.inserir(resultado);
      await _carregarAnuncios();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao publicar o anúncio.')),
        );
    }
  }

  Future<void> editarAnuncio(Anuncio anuncio) async {
    final resultado = await Navigator.push<Anuncio>(
      context,
      MaterialPageRoute(builder: (_) => FormularioAnuncio(anuncio: anuncio)),
    );
    if (resultado == null) return;
    try {
      await _banco.atualizar(resultado);
      await _carregarAnuncios();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao atualizar o anúncio.')),
        );
    }
  }

  Future<void> compartilharAnuncio(Anuncio anuncio, Rect origem) async {
    final preco =
        'R\$ ${anuncio.preco.toStringAsFixed(2).replaceAll('.', ',')}';
    final texto = '${anuncio.titulo}\n\n${anuncio.descricao}\n\nPreço: $preco';
    final temImagem = await imagemExiste(anuncio.imagemPath);
    final arquivos = <XFile>[];
    if (temImagem) {
      arquivos.add(
        XFile.fromData(
          await arquivo_imagem.lerImagem(anuncio.imagemPath!),
          mimeType: 'image/jpeg',
          name: 'anuncio.jpg',
        ),
      );
    } else if (anuncio.imagemBase64 != null) {
      arquivos.add(
        XFile.fromData(
          base64Decode(anuncio.imagemBase64!),
          mimeType: 'image/jpeg',
          name: 'anuncio.jpg',
        ),
      );
    }
    await SharePlus.instance.share(
      ShareParams(
        text: texto,
        subject: anuncio.titulo,
        files: arquivos.isEmpty ? null : arquivos,
        sharePositionOrigin: origem,
      ),
    );
  }

  Future<void> abrirContato(Anuncio anuncio, String canal) async {
    final texto = Uri.encodeComponent(
      'Olá! Tenho interesse no anúncio "${anuncio.titulo}" (${anuncio.preco.toStringAsFixed(2).replaceAll('.', ',')}).',
    );
    final mensagem =
        'Olá! Tenho interesse no anúncio "${anuncio.titulo}" (${anuncio.preco.toStringAsFixed(2).replaceAll('.', ',')}).';
    final telefone = anuncio.telefone?.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri? uri;
    switch (canal) {
      case 'WhatsApp':
        if (telefone == null || telefone.isEmpty) return;
        uri = Uri.parse('https://wa.me/$telefone?text=$texto');
      case 'SMS':
        if (telefone == null || telefone.isEmpty) return;
        uri = Uri(
          scheme: 'sms',
          path: telefone,
          queryParameters: {'body': mensagem},
        );
      default:
        if (anuncio.email == null || anuncio.email!.isEmpty) return;
        uri = Uri(
          scheme: 'mailto',
          path: anuncio.email,
          queryParameters: {
            'subject': 'Interesse: ${anuncio.titulo}',
            'body': mensagem,
          },
        );
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir $canal neste aparelho.'),
          ),
        );
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir $canal neste aparelho.'),
          ),
        );
    }
  }

  void _mostrarContatos(Anuncio anuncio) {
    final canais = <String>[];
    if (anuncio.telefone?.isNotEmpty == true)
      canais.addAll(['WhatsApp', 'SMS']);
    if (anuncio.email?.isNotEmpty == true) canais.add('E-mail');
    if (canais.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este anúncio não tem contato cadastrado.'),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Entrar em contato',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final canal in canais)
              ListTile(
                leading: Icon(
                  canal == 'WhatsApp'
                      ? Icons.chat
                      : canal == 'SMS'
                      ? Icons.sms_outlined
                      : Icons.email_outlined,
                ),
                title: Text(canal),
                onTap: () {
                  Navigator.pop(sheetContext);
                  abrirContato(anuncio, canal);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> excluirAnuncio(Anuncio anuncio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anúncio'),
        content: const Text('Tem certeza que deseja excluir este anúncio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || anuncio.id == null) return;
    try {
      await _banco.excluir(anuncio.id!);
      await _carregarAnuncios();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anúncio excluído com sucesso!')),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao excluir o anúncio.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = anuncios.where((anuncio) {
      return anuncio.titulo.toLowerCase().contains(busca) ||
          anuncio.descricao.toLowerCase().contains(busca);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Marketplace do Fogão',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _buscaController,
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
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : filtrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          anuncios.isEmpty
                              ? 'Nenhum anúncio cadastrado'
                              : 'Nenhum anúncio encontrado',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final anuncio = filtrados[index];
                      return CardAnuncio(
                        anuncio: anuncio,
                        onEditar: () => editarAnuncio(anuncio),
                        onExcluir: () => excluirAnuncio(anuncio),
                        onCompartilhar: () {
                          final box = context.findRenderObject() as RenderBox?;
                          final origem = box == null
                              ? Rect.zero
                              : box.localToGlobal(Offset.zero) & box.size;
                          compartilharAnuncio(anuncio, origem);
                        },
                        onContato: () => _mostrarContatos(anuncio),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: adicionarAnuncio,
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo anúncio'),
      ),
    );
  }
}
