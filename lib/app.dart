import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:mpac_app/core/localizations/L10n.dart';
import 'package:mpac_app/core/presentation/bloc/app_bloc.dart';
import 'package:mpac_app/core/presentation/bloc/app_state.dart';
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:mpac_app/core/utils/general/app_screens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return BlocBuilder(
      bloc: BlocProvider.of<AppBloc>(context),
      builder: (BuildContext context, AppState state) {
        return Container(
          constraints: kIsWeb
              ? const BoxConstraints(
                  minHeight: 300,
                  minWidth: 300,
                )
              : null,
          child: Sizer(
            builder: (BuildContext context, Orientation orientation,
                DeviceType deviceType,) {
              return MaterialApp(
                shortcuts: {
                  LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
                },
                theme: ThemeData(
                  fontFamily: "Lato",
                  scaffoldBackgroundColor: AppColors.backgroundColor,
                  appBarTheme: AppBarTheme(
                      color: AppColors.secondaryBackgroundColor,
                      elevation: 0.0,),
                ),
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  // return child!;
                  if (MediaQuery.of(context).size.width > 900) {
                    return Row(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.black,
                        ),),
                        SizedBox(width: 900, child: child!),
                        Expanded(
                            child: Container(
                          color: Colors.black,
                        ),),
                      ],
                    );
                  } else {
                    return child!;
                  }
                },
                initialRoute: AppScreens.splashPage,
                onGenerateRoute: ScreenGenerator.onGenerate,
                locale: BlocProvider.of<AppBloc>(context).currentLocale,
                supportedLocales: L10n.all,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/*

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'features/home_features/home_feature/presentation/widgets/fb_ractions_buttons_widget.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Reactions by Flutter',
      theme: ThemeData(primaryColor: Color(0xff3b5998)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('MAIN'),
          centerTitle: true,
        ),
        body: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  static List<double> timeDelays = [1.0, 2.0, 3.0, 4.0, 5.0];
  int selectedIndex = 0;

  void onSpeedSettingPress(int index) {
    timeDilation = timeDelays[index];
    setState(() {
      selectedIndex = index;
    });
  }

  List<Widget> buildList() {
    final List<Widget> list = [
      Text(
        'SPEED:',
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      )
    ];
    timeDelays.asMap().forEach((index, delay) {
      list.add(Container(
        child: GestureDetector(
          onTap: () => onSpeedSettingPress(index),
          child: Container(
            child: Text(delay.toString(), style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: index == selectedIndex ? Color(0xff3b5998) : Color(0xffDAA520),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        margin: EdgeInsets.all(5.0),
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: Row(children: buildList()),
                margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
              ),
              Container(
                height: 15.0,
              ),
              buildButton(context, 'Facebook reactions animation', FbReactionBox())
            ],
          )),
    );
  }

  Widget buildButton(BuildContext context, String name, StatelessWidget screenTo) {
    return TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screenTo)),
      child: Container(
        child: Text(
          name,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          textAlign: TextAlign.center,
        ),
        width: 270.0,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) return Color(0xff3b5998).withOpacity(0.8);
            return Color(0xff3b5998);
          },
        ),
        splashFactory: NoSplash.splashFactory,
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.fromLTRB(30, 15, 30, 15),
        ),
      ),
    );
  }
}
*/
