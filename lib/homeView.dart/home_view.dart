// steps to making a simple obj reecoginition app
// 1) train on tflite
// 2) download and add files to proect
// 3) make create model function and init func
// 4) pick image that calls prediction function
// 5) prediction function calls modelexpression
// 6) 
import 'package:faceframe/homeView.dart/liveView.dart';
import 'package:faceframe/homeView.dart/static_view.dart';
import 'package:flutter/material.dart';


class HomeView extends StatefulWidget {
  

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

    @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400],
        title: Text("FaceFrame"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text("static")),
            Tab(child: Text("live")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StaticView(),
          LiveView()
        ],
      ),
    );
  }
}