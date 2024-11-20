import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/benefit.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/benefits_service.dart';
import 'package:proyecto_gimnasio_esquel/features/benefits/widgets/benefits_card.dart';
import 'package:proyecto_gimnasio_esquel/features/benefits/widgets/benefits_dialog.dart';

class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  _BenefitsScreenState createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  final BenefitsService _benefitsService = BenefitsService();
  final AuthService _authService = AuthService();
  bool isAdmin = false;
  List<Benefit> benefits = [];

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _loadBenefits();
  }

  Future<void> _checkAdminRole() async {
    isAdmin = await _authService.isAdmin;
    setState(() {});
  }

  Future<void> _loadBenefits() async {
    try {
      benefits = await _benefitsService.getBenefits();
      setState(() {});
    } catch (e) {
      print('Error al cargar los beneficios: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los beneficios: $e')),
      );
    }
  }

  Future<void> _showAddBenefitDialog() async {
    final newBenefit = await showDialog<Benefit>(
      context: context,
      builder: (BuildContext context) {
        return const AddBenefitDialog();
      },
    );

    if (newBenefit != null) {
      try {
        await _benefitsService.addBenefit(newBenefit);
        _loadBenefits();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beneficio agregado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar beneficio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficios'),
      ),
      body: isAdmin
          ? _buildAdminBenefits()
          : _buildUserBenefits(),
    );
  }

  Widget _buildAdminBenefits() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showAddBenefitDialog,
            child: const Text('Agregar Beneficio'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return BenefitCard(
                benefit: benefit,
                onEdit: () {
                },
                onDelete: () {
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserBenefits() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(16.0),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return BenefitCard(
          benefit: benefit,
        );
      },
    );
  }
}