import 'package:flutter/material.dart';
import 'package:mpac_app/app.dart';

class ResponsiveWidget extends StatefulWidget {
  const ResponsiveWidget({Key? key}) : super(key: key);

  @override
  State<ResponsiveWidget> createState() => _ResponsiveWidgetState();
}

class _ResponsiveWidgetState extends State<ResponsiveWidget> {

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).size.width > 500){
      return Row(
        children: [
          const Expanded(child: SizedBox()),
          SizedBox(width: MediaQuery.of(context).size.width * 0.5, child: const App()),
          const Expanded(child: SizedBox()),
        ],
      );
    } else {
      return const App();
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
