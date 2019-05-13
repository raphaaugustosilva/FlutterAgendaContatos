import 'dart:io';

import 'package:agenda_contatos/helpers/contatosHelper.dart';
import 'package:agenda_contatos/ui/contatoPage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OpcoesOrdenacao {ordenazaoAZ, ordenazaoZA}

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  ContatosHelper contatosHelper = ContatosHelper();
  List<Contato> listaContatos = List();

  @override
  void initState() {
    super.initState();
    _recuperarTodosContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OpcoesOrdenacao>(
            itemBuilder: (contexto) => <PopupMenuEntry<OpcoesOrdenacao>>[
              const PopupMenuItem<OpcoesOrdenacao>(
                child: Text("Ordenar de A-Z"),
                value: OpcoesOrdenacao.ordenazaoAZ,
              ),
              const PopupMenuItem<OpcoesOrdenacao>(
                child: Text("Ordenar de Z-A"),
                value: OpcoesOrdenacao.ordenazaoZA,
              ),
            ],
            onSelected: _ordenarLista,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _exibirContatoPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: listaContatos.length,
          itemBuilder: (contexto, indice) {
            return _constroiCardContato(
                contexto, listaContatos[indice], indice);
          }),
    );
  }

  Widget _constroiCardContato(
      BuildContext contexto, Contato contato, int indice) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: contato.imagem != null
                          ? FileImage(File(contato.imagem))
                          : AssetImage("imagens/ps4.jpeg"),
                    )),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    contato.nome ?? "",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    contato.email ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    contato.telefone ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _exibirOpcoes(contexto, contato, indice);
      },
    );
  }

  void _exibirOpcoes(BuildContext contexto, Contato contato, int indice) {
    showModalBottomSheet(
      context: contexto,
      builder: (contexto) {
        return BottomSheet(
          builder: (contexto) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: FlatButton(
                      child: Text("Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20)),
                      onPressed: () {
                        launch("tel:${contato.telefone}");
                        Navigator.pop(contexto);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: FlatButton(
                      child: Text("Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20)),
                      onPressed: () {
                        Navigator.pop(contexto);
                        _exibirContatoPage(contato: contato);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: FlatButton(
                      child: Text("Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20)),
                      onPressed: () {
                        setState(() {
                          contatosHelper.deletarContato(contato.id);
                          listaContatos.removeAt(indice);
                          Navigator.pop(contexto);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          onClosing: () {},
        );
      },
    );
  }

  void _exibirContatoPage({Contato contato}) async {
    final contatoRecebido = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContatoPage(contato: contato)),
    );

    if (contatoRecebido != null) {
      if (contato != null)
        await contatosHelper.atualizarContato(contatoRecebido);
      else
        await contatosHelper.salvarContato(contatoRecebido);

      _recuperarTodosContatos();
    }
  }

  void _recuperarTodosContatos() {
    contatosHelper.recuperarTodosContatos().then((listaContatosRecuperada) {
      setState(() {
        listaContatos = listaContatosRecuperada;
      });
    });
  }

  void _ordenarLista(OpcoesOrdenacao resultado) {
    switch (resultado) {
      case OpcoesOrdenacao.ordenazaoAZ:        
        listaContatos.sort((a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;

      case OpcoesOrdenacao.ordenazaoZA:
        listaContatos.sort((a, b) {
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;

      default:
        break;
    }
    setState(() {
      
    });
  }
}
