import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/credits/widgets/users_list.dart';
import 'package:proyecto_gimnasio_esquel/features/credits/widgets/users_search_bar.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/services/users_service.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  final UsersService _usersService = UsersService();
  final CreditsService _creditsService = CreditsService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Carga los usuarios
  Future<void> _loadUsers() async {
    try {
      final users = await _usersService.getUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  // Filtrar usuarios por nombre
  void _filterUsers(String query) {
    final filtered = _allUsers.where((user) {
      final name = user.name.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  // Agregar créditos
  void _addCreditsToUser(User user, int credits) async {
    try {
      await _creditsService.addCreditsToUser(user.id, credits);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se han agregado $credits créditos a ${user.name}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar créditos al usuario ${user.name}: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.agregarCreditos),
        centerTitle: true,
      ),
      body: Column(
        children: [
          UsersSearchBar(
            controller: _searchController,
            onChanged: _filterUsers,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text('No se encontraron usuarios'),
                      )
                    : UsersList(
                        users: _filteredUsers,
                        onAddCredits: _addCreditsToUser,
                      ),
          ),
        ],
      ),
    );
  }
}
