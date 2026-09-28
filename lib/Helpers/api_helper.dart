import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ruitoque/Helpers/supabase_config.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';

/// Data access layer.
///
/// Originally this talked to a .NET REST API (GolfApi). It now calls
/// Supabase RPC functions (schema `golf`, wrappers in `public`) that return
/// the exact same JSON shapes the models expect, so no screen or model
/// needed to change — only the internals of these methods.
class ApiHelper {
  // ─────────────────────────── helpers ───────────────────────────

  static Map<String, dynamic> _asMap(dynamic v) =>
      (v as Map).cast<String, dynamic>();

  /// The legacy .NET API returned raw JSON *strings* in `result`, and several
  /// screens call `jsonDecode(response.result)`. Supabase RPC returns already
  /// decoded JSON, so re-encode it to keep that contract intact.
  static String? _encode(dynamic v) => v == null ? null : jsonEncode(v);

  static List<Map<String, dynamic>> _asList(dynamic v) =>
      (v as List).map((e) => (e as Map).cast<String, dynamic>()).toList();

  static int? _idFromPath(String path) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(path.trim());
    return m != null ? int.tryParse(m.group(1)!) : null;
  }

  static String _normalize(String controller) => controller
      .toLowerCase()
      .replaceAll('\\', '/')
      .replaceAll(RegExp(r'^/+'), '');

  // ─────────────────────────── players ───────────────────────────

  static Future<Response> getPlayers() async {
    try {
      final data = await supabase.rpc('golf_get_players');
      final players = _asList(data).map((j) => Jugador.fromJson(j)).toList();
      return Response(isSuccess: true, result: players);
    } catch (e) {
      return Response(isSuccess: false, message: 'Error fetching players: $e');
    }
  }

  static Future<Response> logIn(String id) async {
    try {
      final pin = int.tryParse(id);
      if (pin == null) {
        return Response(isSuccess: false, message: 'PIN inválido');
      }
      final data = await supabase.rpc('golf_get_player_by_pin', params: {'p_pin': pin});
      if (data == null) {
        return Response(isSuccess: false, message: 'PIN incorrecto');
      }
      return Response(isSuccess: true, result: Jugador.fromJson(_asMap(data)));
    } catch (e) {
      // Un PIN que no existe devuelve null (arriba); una excepción es de red o del servidor.
      debugPrint('logIn: $e');
      return Response(
        isSuccess: false,
        message: 'No hay conexión con el servidor. Revisa tu internet e intenta de nuevo.',
      );
    }
  }

  static Future<Response> updateHandicap(int id, int handicap) async {
    try {
      await supabase.rpc('golf_update_handicap', params: {'p_id': id, 'p_handicap': handicap});
      return Response(isSuccess: true);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  static Future<Response> getTarjetasById(String id, {int page = 1, int pageSize = 5}) async {
    try {
      final playerId = int.tryParse(id) ?? 0;
      final data = await supabase.rpc('golf_get_tarjetas_by_player',
          params: {'p_player': playerId, 'p_page': page, 'p_page_size': pageSize});
      if (data == null) {
        return Response(isSuccess: false, message: 'Jugador no encontrado');
      }
      return Response(isSuccess: true, result: Jugador.fromJson(_asMap(data)));
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  // ─────────────────────────── campos ────────────────────────────

  static Future<Response> getCampos() async {
    try {
      final data = await supabase.rpc('golf_get_campos');
      final campos = _asList(data).map((j) => Campo.fromJson(j)).toList();
      return Response(isSuccess: true, result: campos);
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  static Future<Response> getCampo(String id) async {
    try {
      final data = await supabase.rpc('golf_get_campo', params: {'p_id': int.tryParse(id) ?? 0});
      if (data == null) {
        return Response(isSuccess: false, message: 'Campo no encontrado');
      }
      return Response(isSuccess: true, result: Campo.fromJson(_asMap(data)));
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  // ─────────────────────────── rondas ────────────────────────────

  static Future<Response> getRondasAbiertas(int id) async {
    try {
      final data = await supabase.rpc('golf_get_rondas_abiertas', params: {'p_player': id});
      final rondas = _asList(data).map((j) => Ronda.fromJson(j)).toList();
      return Response(isSuccess: true, result: rondas);
    } catch (e) {
      return Response(isSuccess: false, message: 'Error fetching Rondas Abiertas: $e');
    }
  }

  static Future<Response> getFinishedRoundsByPlayer({
    required int playerId,
    required int page,
    int pageSize = 5,
  }) async {
    try {
      final data = await supabase.rpc('golf_get_finished_rounds',
          params: {'p_player': playerId, 'p_page': page, 'p_page_size': pageSize});
      final map = _asMap(data);
      final total = (map['total'] as num?)?.toInt() ?? 0;
      final list = _asList(map['items']).map((j) => Ronda.fromJson(j)).toList();
      return Response(isSuccess: true, result: list, totalCount: total);
    } catch (e) {
      return Response(isSuccess: false, message: e.toString());
    }
  }

  static Future<Response> getRondaById(int id) async {
    try {
      final data = await supabase.rpc('golf_get_ronda', params: {'p_id': id});
      if (data == null) {
        return Response(isSuccess: false, message: 'Ronda no encontrada');
      }
      return Response(isSuccess: true, result: Ronda.fromJson(_asMap(data)));
    } catch (e) {
      return Response(isSuccess: false, message: "Exception: ${e.toString()}");
    }
  }

  // ─────────────── generic verbs (routed to RPCs) ────────────────

  static Future<Response> post(String controller, Map<String, dynamic> request) async {
    final path = _normalize(controller);
    try {
      if (path.startsWith('api/players')) {
        final data = await supabase.rpc('golf_create_player', params: {'payload': request});
        return Response(isSuccess: true, result: _encode(data));
      }
      if (path.startsWith('api/rondas')) {
        final data = await supabase.rpc('golf_save_ronda', params: {'payload': request});
        return Response(isSuccess: true, result: _encode(data));
      }
      if (path.startsWith('api/campos')) {
        return Response(
            isSuccess: false,
            message: 'Crear campos aún no está disponible en el nuevo backend.');
      }
      return Response(isSuccess: false, message: 'Ruta no soportada: $controller');
    } catch (e) {
      return Response(isSuccess: false, message: e.toString());
    }
  }

  static Future<Response> put(String controller, Map<String, dynamic> request) async {
    final path = _normalize(controller);
    try {
      if (path.contains('updatehandicap')) {
        final id = _idFromPath(path) ?? 0;
        final hcp = (request['handicap'] as num?)?.toInt() ?? 0;
        await supabase.rpc('golf_update_handicap', params: {'p_id': id, 'p_handicap': hcp});
        return Response(isSuccess: true);
      }
      if (path.startsWith('api/players/')) {
        final id = _idFromPath(path) ?? 0;
        final data = await supabase.rpc('golf_update_player', params: {'p_id': id, 'payload': request});
        return Response(isSuccess: true, result: _encode(data));
      }
      if (path.startsWith('api/rondas/')) {
        final data = await supabase.rpc('golf_save_ronda', params: {'payload': request});
        return Response(isSuccess: true, result: _encode(data));
      }
      if (path.contains('campos')) {
        return Response(
            isSuccess: false,
            message: 'Editar campos aún no está disponible en el nuevo backend.');
      }
      return Response(isSuccess: false, message: 'Ruta no soportada: $controller');
    } catch (e) {
      return Response(isSuccess: false, message: e.toString());
    }
  }

  static Future<Response> delete(String controller) async {
    final path = _normalize(controller);
    try {
      if (path.contains('rondas')) {
        final id = _idFromPath(path);
        if (id == null) {
          return Response(isSuccess: false, message: 'Id de ronda inválido');
        }
        await supabase.rpc('golf_delete_ronda', params: {'p_id': id});
        return Response(isSuccess: true);
      }
      return Response(isSuccess: false, message: 'Ruta no soportada: $controller');
    } catch (e) {
      return Response(isSuccess: false, message: 'Error: $e');
    }
  }

  // ──────────────────── RondaDeAmigos (no soportado aún) ────────────────────
  // El respaldo actual de GolfBd no incluye estas tablas. Se devuelven listas
  // vacías para que las pantallas no fallen; las escrituras informan que la
  // función no está disponible todavía.

  static Future<Response> getRondaDeAmigosById(int id) async {
    return Response(isSuccess: false, message: 'Rondas de amigos no disponibles aún.');
  }

  static Future<Response> getRondasDeAmigosByPlayer(int playerId) async {
    return Response(isSuccess: true, result: <RondaDeAmigos>[]);
  }

  static Future<Response> getRondasDeAmigosAbiertas(int playerId) async {
    return Response(isSuccess: true, result: <RondaDeAmigos>[]);
  }

  static Future<Response> createRondaDeAmigos(RondaDeAmigos rondaDeAmigos) async {
    return Response(isSuccess: false, message: 'Rondas de amigos no disponibles aún.');
  }

  static Future<Response> updateRondaDeAmigos(RondaDeAmigos rondaDeAmigos) async {
    return Response(isSuccess: false, message: 'Rondas de amigos no disponibles aún.');
  }

  static Future<Response> deleteRondaDeAmigos(int id) async {
    return Response(isSuccess: false, message: 'Rondas de amigos no disponibles aún.');
  }
}
