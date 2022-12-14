import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scooby_app/src/models/actores_model.dart';

class ActoresProvider {
  String _apikey = 'eb7f91b01852a625d2a6d261122f83b5';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Actor> _populares = [];

  final _popularesStreamController = StreamController<List<Actor>>.broadcast();

  Function(List<Actor>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Actor>> get popularesStream => _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController?.close();
  }

  Future<List<Actor>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final actores = new Actor.fromJsonList(decodedData['results']);

    return actores.items;
  }

  Future<List<Actor>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apikey, 'language': _language}); // Pelicula
    return await _procesarRespuesta(url);
  }

  Future<List<Actor>> getPopulares() async {
    if (_cargando) return [];

    _cargando = true;
    _popularesPage++;

    final url = Uri.https(_url, '3/person/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularesPage.toString()
    }); // Pelicula
    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink(_populares);

    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits',
        {'api_key': _apikey, 'language': _language}); // pelicula

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;
  }

  Future<String> getActorBio(int id) async {
    final url = Uri.https(
        _url, '3/person/$id', {'api_key': _apikey, 'language': _language});
    final resp = await http.get(url);
    var decodedData = json.decode(resp.body); //CAMBIADO
    if (decodedData['biography'] == "")
      return decodedData = 'No te descripci??';
    else 
      return decodedData['biography'];
  }

    Future<List<Actor>> buscarActor(String query) async {
    final url = Uri.https(_url, '3/search/person', {
      'api_key': _apikey,
      'language': _language,
      'query': query
    }); // Actors
    return await _procesarRespuesta(url);
  }
}