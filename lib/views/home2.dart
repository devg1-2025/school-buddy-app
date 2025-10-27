import 'package:flutter/material.dart';
import 'package:school_buddy_app/views/deadlines/deadlines.dart';
import 'package:school_buddy_app/views/study_materials/study_materials.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../view_models/study_files_viewmodel.dart';
import '../models/study_file_model.dart';
import '../services/reading_history_service.dart';
import 'study_materials/file_reader_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

  
}

class _HomeState extends State<Home> {
  
  String date = DateFormat.MMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    
    final vm = context.watch<StudyFilesViewModel>();
    final lastOpened = vm.lastOpened;

    final lastReadData = ReadingHistoryService.getLastRead();

  //   if (lastReadData == null) {
  //   return const Text("No file read yet");
  // }

    return Scaffold(
      backgroundColor: Color(AppColors.homeBgColor),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600]),),
                ],
              ),
        
              const SizedBox(height: 20,),
              Text('Hi Scholar,', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
              Text("What will you learn today?", style: TextStyle(fontSize: 11),),
        
        
        SizedBox(height: 20,),
              // deadline box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Upcoming Deadline", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
              SizedBox(width: 10,),
                  Expanded(child: Container(color: Color(AppColors.primaryColor), height: 1,))
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.only(top: 10, bottom: 10, left:  25, ),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CSC 324 assignment", style: TextStyle(fontSize: 14, color: Colors.white,),),
                  
                        SizedBox(height: 10,),
                        // timer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                  Text("10", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: Colors.white),),
                                  Text("Minutes", style: TextStyle(fontSize: 11 ,color: Colors.white),)
                                ],
                              ),
                            )
                          ],
                        ),
                    
                        SizedBox(height: 10,),
                        Text("View all deadlines >", style: TextStyle(color: Colors.white, fontSize: 10),)
                      ],
                    ),
        
        
                    // alarm clock image
                    Positioned(
                      right: -20,
                      bottom: 5,
                      child: Image.asset(
                        'lib/assets/icons_3d/alarm_clock_3d.png',
                      width: 80,
                        ),)
                  ],
                ),
              ),
        

              SizedBox(height: 20,),

              // continue reading section
                if (lastReadData == null) ...[

                   Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Container(
                       width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                      child: Text(
                        "No recently read files",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              if (lastReadData != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("Continue Reading", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {
                    final file = StudyFileModel(
                      id: lastReadData['id'] ??
                          'temp-id-${DateTime.now().millisecondsSinceEpoch}',
                      path: lastReadData['filePath'] ?? '',
                      name: lastReadData['fileName'] ?? 'Unknown File',
                      type: lastReadData['fileType'] ?? 'pdf',
                      lastPage: lastReadData['currentPage'] ?? 0,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FileReaderPage(file: file),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon(Icons.picture_as_pdf, size: 40, color: Colors.redAccent,),
                        // SizedBox(width: 15,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lastReadData['fileName'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,),
                              SizedBox(height: 5,),
                              Text("Last opened page: ${lastReadData['currentPage']}", style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600],)
                      ],
                    ),
                  ),
                ),
              ],


              SizedBox(height: 20,),
        
                    // Quick action buttons
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text("Quick Actions",style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
                    ),
        
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
        
                        // first card
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to Study Materials Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudyMaterials(),
                                ),
                              );
                            },
                            child: Container(
                              width:  MediaQuery.of(context).size.width /2.5,
                              // height: 200,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                              decoration: BoxDecoration(
                                color: Color(AppColors.cardColor1),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text("Organize study materials", style: TextStyle(fontSize: 18),),
                            ),
                          ),
                        ),
                    
                        SizedBox(width: 20,),
                    
                        // second card
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Deadlines(),
                                ),
                              );
                            },
                            child: Container(
                              width:  MediaQuery.of(context).size.width /2.7,
                              // height: 180,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                              decoration: BoxDecoration(
                                color: Color(AppColors.cardColor2),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text("Add a deadline", style: TextStyle(fontSize: 18,),),
                            ),
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