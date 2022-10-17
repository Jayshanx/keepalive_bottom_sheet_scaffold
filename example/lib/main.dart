import 'package:flutter/material.dart';
import 'package:keepalive_bottom_sheet_scaffold/keepalive_bottom_sheet_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _onOpenBottomSheet(BuildContext context) {
    KeepAliveBottomSheet.of(context).show();
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveBottomSheetScaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _onOpenBottomSheet(context);
                },
                child: const Text(
                  'open',
                ),
              ),
              const Text(
                'click bottom to open bottom sheet',
              ),
            ],
          ),
        );
      }),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      keepAliveBottomSheet: KeepAliveBottomWidget(
        child: const BottomSheetListWidget(),
        enableDrag: true,
        bounce: false,
        onHide: (){
          print('closed====');
        }
      ),
    );
  }
}

//bottom sheet with list
class BottomSheetListWidget extends StatelessWidget {
  const BottomSheetListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .7),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            height: 200,
            color: index.isOdd ? Colors.black12 : Colors.white,
            alignment: Alignment.center,
            child: Text('$index'),
          );
        },
        itemCount: 20,
      ),
    );
  }
}
