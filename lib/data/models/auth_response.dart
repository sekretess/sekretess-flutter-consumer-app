import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'id_token')
  final String idToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'refresh_expires_in')
  final int refreshExpiresIn;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'not-before-policy')
  final int? notBeforePolicy;

  @JsonKey(name: 'session_state')
  final String sessionState;

  @JsonKey(name: 'scope')
  final String scope;

  AuthResponse({
    required this.accessToken,
    required this.idToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.refreshToken,
    required this.tokenType,
    this.notBeforePolicy,
    required this.sessionState,
    required this.scope,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
