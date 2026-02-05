import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'urlBase.dart';

class ApiService {
  final String baseUrl = ApiUrlPage.baseUrl;
  
  // Stockage sécurisé pour le token
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ======================== Inscription ========================
Future<http.Response> register(Map<String, String> data) async {
  final url = Uri.parse('$baseUrl/api/auth/register/');
  final body = jsonEncode(data); // encode directement le map en JSON

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  return response; 
}



  // ======================== Connexion ========================
  Future<bool> login(Map<String,dynamic> data) async {

    final url = Uri.parse('$baseUrl/api/auth/token/');
    final body = jsonEncode(data);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final responseBody = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(responseBody);

      // Stocker access token
      if (data.containsKey('access')) {
        await storage.write(key: 'access_token', value: data['access']);
      }

      // Stocker refresh token
      if (data.containsKey('refresh')) {
        await storage.write(key: 'refresh_token', value: data['refresh']);
      }

      return true;
    } else {
      print("Erreur login: $responseBody");
      return false;
    }
  }

   /// ================= Recuperer lid du user=================
  Future<String?> getUserId() async {
    // Récupère l'ID stocké si login a déjà été fait
    String? userId = await storage.read(key: 'user_id');

    if (userId != null) {
      return userId;
    }

    // Sinon, essaie de décoder le token pour obtenir l'ID
    String? token = await storage.read(key: 'access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id']?.toString();
    }
    // Pas de token ou token expiré
    return null;
  }


  // ======================== Déconnexion ========================
 Future<void> logout() async {
  try {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_id');
  } catch (e) {
    // Tu peux logger ou gérer l'erreur ici
    print('Erreur lors de la déconnexion: $e');
  } finally {
    // Cache le modal même en cas d'erreur
    Get.offAllNamed('/login');
  }
}


  // ======================== Vérifier si token valide ========================
  Future<bool> isAccessTokenValid() async {
    final token = await storage.read(key: 'access_token');
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

    // ======================== Recupere le token ou refrachir  ========================
  Future<String?> getAccessToken() async {
  var token = await storage.read(key: 'access_token');

  // Si pas de token → essai refresh
  if (token == null) {
    final refreshed = await refreshAccessToken();
    if (!refreshed) return null;
    token = await storage.read(key: 'access_token');
  }

  return token;
}


  // ======================== Rafraîchir token ========================
Future<bool> refreshAccessToken() async {
  final refreshToken = await storage.read(key: 'refresh_token');
  if (refreshToken == null) return false;

  final url = Uri.parse('$baseUrl/api/auth/token/refresh/');
  final body = jsonEncode({"refresh": refreshToken});

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final responseBody = response.body;

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(responseBody);
    if (data.containsKey('access')) {
      await storage.write(key: 'access_token', value: data['access']);
      return true;
    }
  }
  return false;
}


Future<Map<String, dynamic>> getProfile() async {
  final token = await getAccessToken();
  if (token == null) return {};

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", 
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print('Erreur serveur : ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Erreur lors de la récupération du profil : $e');
    return {};
  }
}



Future<bool> updateProfil(Map<String, dynamic> data) async {
  // Récupération du token
  final token = await getAccessToken();
  if (token == null) return false;

  try {
    // Requête POST pour mettre à jour le profil
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/update_infos/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data), 
    );

    // Vérification de la réponse HTTP
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body);
      print('Réponse serveur: $responseData');
      return true;
    } else {
      print('Erreur HTTP: ${response.statusCode}');
      print('Message: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}



// ======================== Mettre à jour son pseudo name ========================
Future<bool> updateSpeudoName(String name) async {
  final token = await getAccessToken();
  if (token == null) return false;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/update_pseudo/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "pseudo": name, 
      }),
    );

    if (response.statusCode == 200) {
      print("Pseudo mis à jour avec succès !");
      return true;
    } else {
      print('Erreur serveur : ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Erreur lors de la mise à jour du pseudo : $e');
    return false;
  }
}




// ======================== Mettre à jour son pseudo name ========================
Future<List<Map<String, dynamic>>?> getMagasin() async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    final uri = Uri.parse('$baseUrl/api/magasin/list/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final magasins = data.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
      print("Magasins récupérés : $magasins");
      return magasins;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération des magasins : $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getProduits() async {
  final token = await getAccessToken();
  if (token == null) return null;
  try {
    final uri = Uri.parse('$baseUrl/api/produit/list/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final magasins = data.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
      print("Magasins récupérés : $magasins");
      return magasins;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération des magasins : $e');
    return null;
  }
}

// ======================== Détail d'un produit ========================
Future<Map<String, dynamic>?> getProduitDetail(String id) async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    final uri = Uri.parse('$baseUrl/api/produit/$id/retreive/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("Détails du produit récupérés : $data");
      return data;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération du détail produit : $e');
    return null;
  }
}


Future<List<Map<String, dynamic>>?> getStocks() async {
  final token = await getAccessToken();
  if (token == null) return null;
  try {
    final uri = Uri.parse('$baseUrl/api/stock/list/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final magasins = data.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
      print("Mouvements récupérés : $magasins");
      return magasins;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération des mouvements: $e');
    return null;
  }
}


Future<bool> createMouvement(Map<String, dynamic> mouvementData) async {
  final token = await getAccessToken();
  if (token == null) return false;

  try {
    final uri = Uri.parse('$baseUrl/api/mouvement/create/');

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(mouvementData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Mouvement créé avec succès : ${response.body}');
      return true;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erreur lors de la création du mouvement: $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>?> getMouvements() async {
  final token = await getAccessToken();
  if (token == null) return null;
  try {
    final uri = Uri.parse('$baseUrl/api/mouvement/list/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final magasins = data.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
      print("Mouvements récupérés : $magasins");
      return magasins;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération des mouvements: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getMouvementDetail(String idMouvement) async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    // On ajoute l'ID à l'URL pour récupérer UN seul mouvement
    final uri = Uri.parse('$baseUrl/api/mouvement/$idMouvement/retreive/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      // On décode un Map (objet unique) et non une List
      final Map<String, dynamic> data = json.decode(response.body);
      print("Détails du mouvement récupérés : $data");
      return data;
    } else {
      print('Erreur serveur : ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération du détail : $e');
    return null;
  }
}

Future<bool> updateMouvement(String id, Map<String, dynamic> mouvementData) async {
  final token = await getAccessToken();
  if (token == null) return false;

  try {
    // CORRECTION : Injection de l'ID réel dans l'URL
    final uri = Uri.parse('$baseUrl/api/mouvement/$id/update/');

    final response = await http.put( 
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(mouvementData),
    );

    if (response.statusCode == 200) {
      print('Mouvement mis à jour avec succès');
      return true;
    } else {
      print('Erreur serveur : ${response.statusCode} => ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erreur lors de la modification : $e');
    return false;
  }
}

/// updateMouvement prend l'id du mouvement et les données à mettre à jour
// Future<bool> updateMouvement(String idMouvement, Map<String, dynamic> mouvementData) async {
//   final token = await getAccessToken();
//   if (token == null) return false;

//   try {
//     // URL corrigée avec http et id dynamique
//     final uri = Uri.parse('$baseUrl/api/mouvement/$idMouvement/update/');

//     final response = await http.put(
//       uri,
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: json.encode(mouvementData),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print('Mouvement mis à jour avec succès : ${response.body}');
//       return true;
//     } else {
//       print('Erreur serveur : ${response.statusCode} => ${response.body}');
//       return false;
//     }
//   } catch (e) {
//     print('Erreur lors de la mise à jour du mouvement: $e');
//     return false;
//   }
// }

//=================Methode pour créer une session=====================

Future<bool> createSession({
  required List<Map<String, dynamic>> items,
}) async {
  final token = await getAccessToken();
  final userId = await getUserId();

  if (token == null || userId == null) {
    print(" Authentification requise");
    return false;
  }

  try {
    final uri = Uri.parse('$baseUrl/api/sessions/create/');

    final requestBody = {
      "agent_livraison": userId,
      "items": items,
    };

    print("Requête envoyée : $requestBody");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(requestBody),
    );

    print("Status : ${response.statusCode}");
    print("Body : ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = json.decode(response.body);
      print(" Erreur API : $error");
      return false;
    }
  } catch (e) {
    print(' Exception : $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>?> getSession() async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    final uri = Uri.parse('$baseUrl/api/sessions/list/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("Erreur API (${response.statusCode}) : ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception getSession : $e");
    return null;
  }
}


Future<Map<String, dynamic>?> detailSession(String sessionId) async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    final uri = Uri.parse('$baseUrl/api/sessions/$sessionId/retrieve/');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      print("Erreur API (${response.statusCode}) : ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception detailSession : $e");
    return null;
  }
}

Future<Map<String, dynamic>?> clotureSession(
  String sessionId,
  Map<String, dynamic> body,
) async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    final uri = Uri.parse('$baseUrl/api/sessions/$sessionId/close/');

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("Erreur API (${response.statusCode}) : ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception clotureSession : $e");
    return null;
  }
}


// Fonction utilitaire pour gérer les nombres invalides du backend (-9223372036854776000)
dynamic _parseBigInt(dynamic value) {
  if (value == null) return 0;
  // Si la valeur est trop grande pour un int standard (64-bit signed limit)
  if (value is int && (value < -2147483648 || value > 2147483647)) {
    return 0; // Ou return value.toString() si tu veux juste l'afficher
  }
  return value;
}

Future<Map<String, dynamic>?> retrieveDetail(String idsession) async {
  final token = await getAccessToken();
  if (token == null) return null;

  try {
    // URL de récupération (GET)
    final uri = Uri.parse('$baseUrl/api/sessions/$idsession/retrieve/');
    
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erreur : ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception : $e');
    return null;
  }
}


}


