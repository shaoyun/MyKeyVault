import 'package:flutter/material.dart';
import 'package:myapp/models/totp_account.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddAccountScreen extends StatefulWidget {
  final TotpAccount? initialAccount;

  const AddAccountScreen({super.key, this.initialAccount});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _issuerController;
  late TextEditingController _nameController;
  late TextEditingController _secretController;

  @override
  void initState() {
    super.initState();
    _issuerController =
        TextEditingController(text: widget.initialAccount?.issuer ?? '');
    _nameController =
        TextEditingController(text: widget.initialAccount?.name ?? '');
    _secretController =
        TextEditingController(text: widget.initialAccount?.secret ?? '');
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _nameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialAccount == null ? 'Add Account' : 'Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(labelText: 'Issuer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an issuer';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: 'Secret'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a secret';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newAccount = TotpAccount(
                      id: widget.initialAccount?.id ?? const Uuid().v4(),
                      issuer: _issuerController.text,
                      name: _nameController.text,
                      secret: _secretController.text,
                    );
                    Provider.of<AccountProvider>(context, listen: false)
                        .addAccount(newAccount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
