import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final Function onReload;
  final String message;
  final String btnContent;
  final Color color;
  final bool withRefreshBtn;

  const ErrorView(
      {super.key, required this.onReload,
      required this.message,
      required this.color,
      this.withRefreshBtn = true,
      required this.btnContent,});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 1.4,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    message,
                    style: TextStyle(color: color, fontSize: 17.0),
                  ),
                ),
              ),),
          const SizedBox(
            height: 8.0,
          ),
          withRefreshBtn
              ? GestureDetector(
                  onTap: () => onReload(),
                  child: Container(
                    height: 35.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                    child: Center(
                      child: Text(
                        btnContent,
                        style: const TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
