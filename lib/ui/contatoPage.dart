import 'dart:io';

import 'package:agenda_contatos/helpers/contatosHelper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  bool _usuarioEditou = false;
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorTelefone = TextEditingController();

  final _focoNome = FocusNode();
  Contato _contatoEditado;

  @override
  void initState() {
    super.initState();
    if (widget.contato == null)
      _contatoEditado = Contato();
    else {
      _contatoEditado = Contato.fromMap(widget.contato.toMap());
      _controladorNome.text = _contatoEditado.nome;
      _controladorEmail.text = _contatoEditado.email;
      _controladorTelefone.text = _contatoEditado.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exibeMensagemPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_contatoEditado.nome ?? "Novo contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_contatoEditado.nome != null && _contatoEditado.nome.isNotEmpty)
              Navigator.pop(context, _contatoEditado);
            else
              FocusScope.of(context).requestFocus(_focoNome);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _contatoEditado.imagem != null
                            ? FileImage(File(_contatoEditado.imagem))
                            : AssetImage("imagens/ps4.jpeg"),
                      )),
                ),
                onTap: () async {
                  File fotoTirada =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (fotoTirada == null) return;
                  setState(() {
                    _contatoEditado.imagem = fotoTirada.path;
                  });
                },
              ),
              TextField(
                controller: _controladorNome,
                focusNode: _focoNome,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (texto) {
                  _usuarioEditou = true;
                  setState(() {
                    _contatoEditado.nome = texto;
                  });
                },
              ),
              TextField(
                controller: _controladorEmail,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (texto) {
                  _usuarioEditou = true;
                  _contatoEditado.email = texto;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _controladorTelefone,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (texto) {
                  _usuarioEditou = true;
                  _contatoEditado.telefone = texto;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _exibeMensagemPop() {
    if (_usuarioEditou) {
      showDialog(
        context: context,
        builder: (contexto) {
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Se sair, as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(contexto);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  Navigator.pop(contexto);
                  Navigator.pop(contexto);
                },
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
