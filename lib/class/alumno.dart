import 'package:rs_tools/rs_tools.dart';

class Alumno extends RSObject {
  Alumno({
    Map<String, dynamic>? data,
    required String documentId,
  }) : super(
          data,
          collectionName: 'alumnos',
          documentId: documentId,
        );

  static Alumno newItem() => Alumno(documentId: RSObject.createDocumentId());

  String? get nombre => stringFromKey('nombre');
  set nombre(String? nombre) => setObject('nombre', nombre);

  String? get dni => stringFromKey('dni');
  set dni(String? dni) => setObject('dni', dni);

  DateTime? get nacimiento => dateFromKey('nacimiento');
  set nacimiento(DateTime? nacimiento) => setObject('nacimiento', nacimiento);

  String? get curso => stringFromKey('curso');
  set curso(String? curso) => setObject('curso', curso);

  String? get fotoUrl => stringFromKey('fotoUrl');
  set fotoUrl(String? fotoUrl) => setObject('fotoUrl', fotoUrl);

  bool get createdCard => boolFromKey('createdCard');
  set createdCard(bool? createdCard) => setObject('createdCard', createdCard);

  @override
  List<Object?> get props => [
        ...super.props,
        nombre,
        dni,
        nacimiento,
        curso,
        fotoUrl,
        createdCard,
      ];
}
