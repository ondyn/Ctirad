import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/constants.dart';
import '../../models/app.dart';

class SettingBaudratePage extends StatelessWidget {
  const SettingBaudratePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: kBaudrateList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('${kBaudrateList[index]}'),
            onTap: () {
              Provider.of<AppModel>(context, listen: false)
                  .updateBaudrate(kBaudrateList[index]);
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 0.0),
      ),
    );
  }
}
