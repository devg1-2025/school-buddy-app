import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

  
}

class _HomeState extends State<Home> {
  
  String date = DateFormat.MMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.homeBgColor),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(date, style: TextStyle(fontSize: 14, color: Colors.grey[600]),),
                ],
              ),
        
              const SizedBox(height: 40,),
              Text('Hi Scholar,', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
              Text("What will you be learning today?", style: TextStyle(fontSize: 14),),
        
              
              SizedBox(height: 20,),
        
        
              // deadline box
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("CSC 324 assignment", style: TextStyle(fontSize: 18, color: Colors.white,),),
                    
                      // Divider(color: Colors.white54,),
                        SizedBox(height: 15,),
                        // timer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            // days
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(AppColors.numberBoxColor),
                                borderRadius: BorderRadius.circular(10),
                                
                              ),
                              child: Column(
                                children: [
                                  Text("10", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white),),
                                  Text("Days", style: TextStyle(fontSize: 12, color: Colors.white),)
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(":", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                            SizedBox(width: 10,),
                            
                            // hours
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(AppColors.numberBoxColor),
                                borderRadius: BorderRadius.circular(10),
                                
                              ),
                              child: Column(
                                children: [
                                  Text("10", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
                                  Text("Hours", style: TextStyle(fontSize: 12, color: Colors.white),)
                                ],
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(":", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                            SizedBox(width: 10,),
                            // minutes
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(AppColors.numberBoxColor),
                                borderRadius: BorderRadius.circular(10),
                                
                              ),
                              child: Column(
                                children: [
                                  Text("10", style: TextStyle(fontSize: 20, color: Colors.white),),
                                  Text("Minutes", style: TextStyle(fontSize: 11 ,color: Colors.white),)
                                ],
                              ),
                            )
                          ],
                        ),
                    
                        SizedBox(height: 20,),
                        Text("View all deadlines >", style: TextStyle(color: Colors.white),)
                      ],
                    ),
        
        
                    // alarm clock image
                    Positioned(
                      right: -25,
                      bottom: -20,
                      child: Image.asset(
                        'lib/assets/icons_3d/alarm_clock_3d.png',
                      width: 80,
                        ),)
                  ],
                ),
              ),
        
              SizedBox(height: 20,),
        
                    // Quick action buttons
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text("Quick Actions",style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                    ),
        
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
        
                        // first card
                        Container(
                          width:  MediaQuery.of(context).size.width /2.5,
                          // height: 200,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                          decoration: BoxDecoration(
                            color: Color(AppColors.cardColor1),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text("Organize study materials", style: TextStyle(fontSize: 20),),
                        ),
                    
                        SizedBox(width: 20,),
                    
                        // second card
                        Expanded(
                          child: Container(
                            width:  MediaQuery.of(context).size.width /2.7,
                            // height: 180,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                            decoration: BoxDecoration(
                              color: Color(AppColors.cardColor2),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text("Add a deadline", style: TextStyle(fontSize: 20,),),
                          ),
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}