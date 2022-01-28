import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({Key? key}) : super(key: key);

  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    initializeDateFormatting(Platform.localeName);
    Intl.defaultLocale = Platform.localeName;
    final String formattedDate = DateFormat('EEEE d. M. yyyy').format(now);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Expanded(
          // add this
          child: FittedBox(fit: BoxFit.fitWidth, child: DigitalClockWidget()),
        ),
        Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 50,
          ),
        ),
      ],
    );
  }
}

class DigitalClockWidget extends StatefulWidget {
  const DigitalClockWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DigitalClockWidgetState();
  }
}

class DigitalClockWidgetState extends State<DigitalClockWidget> {
  String formattedTime = DateFormat('HH:mm').format(DateTime.now());
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int perviousMinute =
          DateTime.now().add(const Duration(seconds: -1)).minute;
      final int currentMinute = DateTime.now().minute;
      if (perviousMinute != currentMinute) {
        setState(() {
          formattedTime = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('=====>digital clock updated');
    return Text(
      formattedTime,
      style:
          GoogleFonts.oswald(textStyle: Theme.of(context).textTheme.bodyText1!),
    );
  }
}
