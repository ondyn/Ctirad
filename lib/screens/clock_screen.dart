import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/time_provider.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
        builder: (BuildContext context, TimeProvider provider, Widget? child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(
                  margin: const EdgeInsets.all(0.5),
                  child: Text(
                    provider.formattedTime,
                    style: GoogleFonts.supermercadoOne(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                        fontWeight: FontWeight.bold),
                  ),
                )),
          ),
          Text(
            provider.formattedDate,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 50,
            ),
          ),
        ],
      );
    });
  }
}
