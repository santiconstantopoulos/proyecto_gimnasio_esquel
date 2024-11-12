import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/benefit.dart';

class BenefitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene todos los beneficios
  Future<List<Benefit>> getBenefits() async {
    final snapshot = await _firestore.collection('benefits').get();
    return snapshot.docs.map((doc) => Benefit.fromFirestore(doc.id, doc.data())).toList();
  }

  // Agrega un nuevo beneficio
  Future<void> addBenefit(Benefit benefit) async {
    await _firestore.collection('benefits').add(benefit.toJson());
  }

  // Edita un beneficio (implementa si necesitas editar beneficios)
  Future<void> editBenefit(String benefitId, Benefit benefit) async {
    await _firestore.collection('benefits').doc(benefitId).update(benefit.toJson());
  }

  // Elimina un beneficio (implementa si necesitas eliminar beneficios)
  Future<void> deleteBenefit(String benefitId) async {
    await _firestore.collection('benefits').doc(benefitId).delete();
  }
}