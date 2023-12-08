import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/bus_station_model.dart';
import 'outline_circle_button.dart';

// 버스 목록 위젯
class BusListWidget extends StatefulWidget {
  final List<Bus> busList;
  final bool isLoading;
  final VoidCallback onScrollToTop;
  final Function(String) onCommentsCall;
  final Future<void> Function() onRefresh;

  const BusListWidget(
      {required this.busList,
      required this.isLoading,
      required this.onScrollToTop,
      required this.onCommentsCall,
      required this.onRefresh,
      super.key});

  @override
  State<BusListWidget> createState() => _BusListWidgetState();
}
class _BusListWidgetState extends State<BusListWidget> {
  late ScrollController scrollcon = ScrollController();
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    setState(() {isRefreshing = widget.isLoading;});
    final numOfBus = widget.busList.length;

    if (isRefreshing) {
      return Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 0.5,color: const Color(0xFF3F51B5).withOpacity(0.2),),
            bottom: BorderSide(width: 0.5,color: const Color(0xFF3F51B5).withOpacity(0.2),),
          ),
        ),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Center( child: CircularProgressIndicator(),),
          ),
        ),
      );
    }

    return Stack(
      children: [

        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 2.0,color: const Color(0xFF3F51B5).withOpacity(0.2),),
              bottom: BorderSide(width: 0.5,color: const Color(0xFF3F51B5).withOpacity(0.2),),
            ),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height / 2,

          child: RefreshIndicator(
                  color: Colors.white10,
                  displacement: 100000, // 인디케이터 보이지 마라..
                  onRefresh: () async {widget.onScrollToTop();},

                  child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: scrollcon,
                      itemCount: (numOfBus == 0) ? 1 : numOfBus + 1,
                      itemBuilder: (context, index) {
                        if (numOfBus == 0) { // 최적화인가?
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Center(child: Text("버스가 없습니다", style: TextStyle(fontSize: 20))),
                          );
                        }
                        if (index >= numOfBus) { // 마지막 줄
                          return Column(children: [
                            Divider(),
                            SizedBox(height: 85,),
                          ]);
                        }
                        Bus bus = widget.busList[index];
                        // 남는 시간에 따른 색 분류
                        final urgentColor = ((bus.arrtime / 60).toInt() >= 5)
                            ? const Color(0xFF3F51B5) : Colors.red;
                        final busColor = (bus.routetp == '일반버스')
                            ? Color(0xff05d686) : Colors.purple;  //
                        return GestureDetector(
                          onTap: () {widget.onCommentsCall(bus.code);},
                          behavior: HitTestBehavior.opaque,
                          child:  Column(
                            children: [
                              (index == 0)
                                  ? SizedBox(width: 0,)
                                  : Divider(thickness: 1.0,height: 1.0,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: 8),
                                              Icon(Icons.directions_bus,color: busColor, size: 25),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(height: 2),
                                                    Text(
                                                      '${bus.routeno}',
                                                      style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold),),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '남은 정류장 : ${bus.arrprevstationcnt}',
                                                      style: TextStyle(fontSize: 12,color: Colors.grey),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      '${(bus.arrtime / 60).toInt()}분 ${bus.arrtime % 60}초 후 도착',
                                                      style: TextStyle(fontSize: 14,color: urgentColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () { widget.onCommentsCall(bus.code);},
                                    icon: Icon(Icons.comment_outlined), //Icons.arrow_circle_up_outlined
                                    color: const Color(0xFF3F51B5),
                                  ),
                                  SizedBox(width: 18,),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                  ),
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.height * 0.03,
          child: OutlineCircleButton(
            child: Icon(Icons.refresh,color: Colors.white,),
            radius: 50.0,borderSize: 0.5,
            foregroundColor: isRefreshing ? Colors.transparent : const Color(0xFF3F51B5),
            borderColor: Colors.white,
            onTap: () async {
              await widget.onRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('업데이트됨'),duration: Duration(milliseconds: 700)),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    scrollcon.dispose();
    super.dispose();
  }
}
