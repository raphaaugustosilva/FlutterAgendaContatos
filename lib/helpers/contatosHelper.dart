import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tabelaContato = "tabelaContato";
final String idColuna = "idColuna";
final String nomeColuna = "nomeColuna";
final String emailColuna = "emailColuna";
final String telefoneColuna = "telefoneColuna";
final String imagemColuna = "imagemColuna";

//Aplicando Singleton
class ContatosHelper {
  static final ContatosHelper _instancia = ContatosHelper.internal();

  factory ContatosHelper() => _instancia;

  ContatosHelper.internal();

  Database _bancoDados;
  Future<Database> get bancoDados async {
    if (_bancoDados != null) {
      return _bancoDados;
    } else {
      _bancoDados = await inicializaBancoDados();
      return _bancoDados;
    }
  }

  Future<Database> inicializaBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final arquivoBancoDados = join(caminhoBancoDados, "contatos.db");
    return await openDatabase(arquivoBancoDados, version: 1,
        onCreate: (Database db, int versaoMaisNova) async {
      await db.execute("CREATE TABLE $tabelaContato ("
          "$idColuna INTEGER PRIMARY KEY, "
          "$nomeColuna TEXT, "
          "$emailColuna TEXT, "
          "$telefoneColuna TEXT, "
          "$imagemColuna TEXT)");
    });
  }

  Future<Contato> salvarContato(Contato contato) async {
    Database bancoDadosContato = await bancoDados;
    contato.id = await bancoDadosContato.insert(tabelaContato, contato.toMap());
    return contato;
  }

  Future<Contato> recuperarContato(int id) async {
    Database bancoDadosContato = await bancoDados;
    List<Map> maps = await bancoDadosContato.query(
      tabelaContato,
      columns: [
        idColuna,
        nomeColuna,
        emailColuna,
        telefoneColuna,
        imagemColuna
      ],
      where: "$idColuna = ?",
      whereArgs: [id],
    );

    return (maps.length > 0) ? Contato.fromMap(maps.first) : null;
  }

  Future<int> deletarContato(int id) async {
    Database bancoDadosContato = await bancoDados;
    return await bancoDadosContato.delete(
      tabelaContato,
      where: "$idColuna = ?",
      whereArgs: [id],
    );
  }

  Future<int> atualizarContato(Contato contato) async {
    Database bancoDadosContato = await bancoDados;
    return await bancoDadosContato.update(
      tabelaContato,
      contato.toMap(),
      where: "$idColuna = ?",
      whereArgs: [contato.id],
    );
  }

  Future<List> recuperarTodosContatos() async  {
    Database bancoDadosContato = await bancoDados;
    List listaMapas = await bancoDadosContato.rawQuery("SELECT * FROM $tabelaContato");
    List<Contato> listaContatos = List();
    for(Map map in listaMapas) {
      listaContatos.add(Contato.fromMap(map));
    }

    return listaContatos;
  }

  Future<int> recuperarQtdRegistros() async {
    Database bancoDadosContato = await bancoDados;
      return Sqflite.firstIntValue(await bancoDadosContato.rawQuery("SELECT COUNT(*) FROM $tabelaContato"));
  }

  Future fechaConexao() async {
    Database bancoDadosContato = await bancoDados;
    await bancoDadosContato.close();
  }
}

class Contato {
  int id;
  String nome;
  String email;
  String telefone;
  String imagem;

  Contato();

  Contato.fromMap(Map map) {
    id = map[idColuna];
    nome = map[nomeColuna];
    email = map[emailColuna];
    telefone = map[telefoneColuna];
    imagem = map[imagemColuna];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColuna: nome,
      emailColuna: email,
      telefoneColuna: telefone,
      imagemColuna: imagem
    };

    if (id != null) {
      map[idColuna] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contato{id: $id, nome: $nome, email: $email, telefone: $telefone, imagem: $imagem";
  }
}
