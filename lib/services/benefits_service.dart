import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/benefit.dart';

class BenefitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Benefit>> getBenefits() async {
    final snapshot = await _firestore.collection('benefits').get();
    return snapshot.docs.map((doc) => Benefit.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> addBenefit(Benefit benefit) async {
    await _firestore.collection('benefits').add(benefit.toJson());
  }

  Future<void> editBenefit(String benefitId, Benefit benefit) async {
    await _firestore.collection('benefits').doc(benefitId).update(benefit.toJson());
  }

  Future<void> deleteBenefit(String benefitId) async {
    await _firestore.collection('benefits').doc(benefitId).delete();
  }
}