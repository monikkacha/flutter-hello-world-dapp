import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contract_linking.dart';
import 'hello_ui.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inserting Provider as a parent of HelloUI()
    return ChangeNotifierProvider<ContractLinking>(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        title: "Flutter Dapp Hello World",
        home: HelloUI(),
      ),
    );
  }
}
