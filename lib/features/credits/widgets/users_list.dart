import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';

class UsersList extends StatelessWidget {
  final List<User> users;
  final Function(User, int) onAddCredits;

  const UsersList({
    super.key,
    required this.users,
    required this.onAddCredits,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No se encontraron usuarios'),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profileImageUrl.isNotEmpty
                ? NetworkImage(user.profileImageUrl)
                : const AssetImage('assets/placeholder.png') as ImageProvider,
          ),
          title: Text(user.name),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'add_credits') {
                _showAddCreditsDialog(context, user);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_credits',
                  child: Text('Agregar créditos'),
                ),
              ];
            },
          ),
        );
      },
    );
  }

  void _showAddCreditsDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController creditsController = TextEditingController();

        return AlertDialog(
          title: Text('Agregar créditos a ${user.name}'),
          content: TextField(
            controller: creditsController,
            decoration: const InputDecoration(
              labelText: 'Cantidad de créditos',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () {
                final int credits = int.tryParse(creditsController.text) ?? 0;
                if (credits > 0) {
                  onAddCredits(user, credits);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
