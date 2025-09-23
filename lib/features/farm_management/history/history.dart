import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'farm_history_provider.dart';

class FarmHistory extends StatelessWidget {
  const FarmHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm History")),
      body: ChangeNotifierProvider(
        create: (context) => FarmHistoryProvider(),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child:

          Tab(

          ),),
      ),
    );
  }
}
