import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nv;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../models/category.dart';
import '../widgets/dropdown_button.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({Key? key}) : super(key: key);

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  TextEditingController startDateController = new TextEditingController();
  TextEditingController endDateController = new TextEditingController();

  final pw.Document pdf = pw.Document();

  bool loading = false;

  String? pdfPath;

  nv.PdfController? pdfController;

  List<TransactionModel> transactionsList = [];

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedCategory = "All";

  final TransactionScreenAmountController amountController =
  TransactionScreenAmountController();


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController startTimeController = TextEditingController();

  final TextEditingController endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitaab"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: startTimeController,
                    onTap: () async {
                      selectedStartDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025));
                      if (selectedStartDate != null) {
                        startTimeController.text = DateFormat("dd-MM-yyyy")
                            .format(selectedStartDate!)
                            .toString();
                        // setState(() {});
                      }
                    },

                    validator: (value) {
                      if (selectedStartDate == null) {
                        return "field is required";
                      }
                      return null;
                    },

                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      hintText: "Start Date",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    readOnly: true,
                    // enabled: false,
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                    controller: endTimeController,
                    onTap: () async {
                      selectedEndDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025));
                      if (selectedEndDate != null) {
                        endTimeController.text = DateFormat("dd-MM-yyyy")
                            .format(selectedEndDate!)
                            .toString();
                        // setState(() {});
                      }
                    },

                    validator: (value) {
                      if (selectedEndDate == null) {
                        return "field is required";
                      }
                      return null;
                    },

                    decoration: const InputDecoration(
                      labelText: "End Date",
                      hintText: "End Date",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      disabledBorder: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    readOnly: true,
                    // enabled: false,
                  ))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Collections.categories)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    List<String> categories = [];
                    final Map<String,Color> colorsMap = {};

                    if ((snapshot.hasData) &&
                        (!(snapshot.connectionState ==
                            ConnectionState.waiting))) {
                      categories = snapshot.data!.docs
                          .map((DocumentSnapshot<Map<String, dynamic>>
                                  document) =>
                              CategoryModel.fromMap(document.data()!).title)
                          .toList();
                      categories.insert(0, "All");

                      for (var snapshot in snapshot.data!.docs) {

                        CategoryModel model = CategoryModel.fromMap(snapshot.data());
                        colorsMap[model.title] = Color(model.colorCode).withOpacity(1);
                      }

                    }

                    return MyDropDownButton(
                        dropdownValue: selectedCategory,
                        items: categories,
                        function: (String v) {
                          selectedCategory = v;
                        },
                        hintText: "Select Category",
                        colorsMap: colorsMap
                    );
                  }),
              const SizedBox(
                height: 20,
              ),
              // buttonsRow(),
              // const SizedBox(height: 30),
              SizedBox(height: pdfPath==null ? 30 : 0,),
              (!loading) ?
              (pdfPath==null ?
              ElevatedButton(
                  onPressed: ()async{
                    if(formKey.currentState!.validate()){
                              await _exportPdf();
                            }
                          },
                  child: const Text(
                      "Export Data"
                  )
              ) : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text("PDF is saved in Directory : $pdfPath"),
              )) : const SizedBox(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

              pdfController != null ? Expanded(child: Container(
                  color: Colors.blue,
                  child: pdfView())) : const SizedBox(),
              pdfController != null ? ElevatedButton(
                  onPressed: ()async{
                    Share.shareFiles([pdfPath!,], text: 'Kitaab Transactions');
                  },
                  child: const Text(
                      "Share PDF"
                  )
              ) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fillTransactionsList() async {
    print("fetching transactions");

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection(Collections.transactions)
        .where("createdAt",
            isGreaterThanOrEqualTo: selectedStartDate,
            isLessThanOrEqualTo: selectedEndDate)
        .orderBy("createdAt", descending: true)
        .get();
    transactionsList = querySnapshot.docs
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) =>
            TransactionModel.fromMap(snapshot.data()!))
        .toList();

    print("all transactions fetched");
  }

  Future<void> _addJobPageToPdf(int startingIndex, {bool firstPage = false}) async {
    print("adding page in pdf");

    pdf.addPage(
        pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            child: pw.Column(
                children: [
                  pw.SizedBox(height: 20),
                  startingIndex==0 ? _buildAmountCards() : pw.SizedBox(),
                  _buildTransactionWidget(transactionsList[startingIndex]),
                  transactionsList.length > (startingIndex+1) ?  _buildTransactionWidget(transactionsList[startingIndex+1]) : pw.SizedBox(),
                  transactionsList.length > (startingIndex+2)? _buildTransactionWidget(transactionsList[startingIndex+2]) : pw.SizedBox(),
                  transactionsList.length > (startingIndex+3)? _buildTransactionWidget(transactionsList[startingIndex+3]) : pw.SizedBox(),
                  transactionsList.length > (startingIndex+4)? _buildTransactionWidget(transactionsList[startingIndex+4]) : pw.SizedBox(),
                  firstPage ? pw.SizedBox() : (transactionsList.length > (startingIndex+5)? _buildTransactionWidget(transactionsList[startingIndex+5]) : pw.SizedBox()),

                ])
          ); // Center
        }));
  }

  pw.Widget _buildAmountCards(){
    return pw.Row(
        // mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Expanded(
            child:           amountContainer(
              "Total Amount (Cash)",
              amountController.totalAmountCash.toString(),
              amountController.totalAddedCash.toString(),
              amountController.totalWithdrawCash
                  .toString(),
            )
          ),
    pw.Expanded(
      child:           amountContainer(
        "Total Amount (Card)",
        amountController.totalAmountCard.toString(),
        amountController.totalAddedCard.toString(),
        amountController.totalWithdrawCard
            .toString(),
      ),
    ),



        ]
    );

  }

  pw.Widget _buildTransactionWidget(TransactionModel transactionModel){

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8.0),
      child: pw.Container(
        margin: const pw.EdgeInsets.all(8),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(DateFormat.yMMMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(transactionModel.createdAt.millisecondsSinceEpoch))),
            pw.SizedBox(height: 5,),
            pw.Row(
              children:  [
                pw.Text("${transactionModel.createdBy.name} has ${ (transactionModel.transactionSign == '+') ? "added" : "withdrawn"} ${transactionModel.amount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 18),),
                pw.Spacer(),
                pw.Text(transactionModel.transactionType.toUpperCase(),style: const pw.TextStyle(fontSize: 16, )),
                pw.SizedBox(width: 20,),
                pw.Text("${transactionModel.transactionSign} ${transactionModel.amount}", style: pw.TextStyle(color: transactionModel.transactionSign=="+" ? PdfColor(0, 1, 0) : PdfColor(1,0,0), fontWeight: pw.FontWeight.bold, fontSize: 22),),
              ],
            ),
            pw.SizedBox(height: 5,),
            pw.Text("Category : ${transactionModel.category}",),
            pw.SizedBox(height: 5,),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.max,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Note : ${transactionModel.desc}"),
              ],
            ),
            // Divider(),

          ],
        ),
      ),
    );


  }

  _exportPdf() async {
    bool success = false;

    if ((await Permission.storage.request().isGranted)) {
      // if (await Permission.accessMediaLocation.request().isGranted){
      //   if((await Permission.manageExternalStorage.request().isGranted)) {
      success = true;
      //   }
      // }
    }

    if (!success) {
      Fluttertoast.showToast(msg: "Permission not granted");
      return;
    }

    print("exporting started");
    setState(() {
      loading = true;
    });

    await fillTransactionsList();

    if(selectedCategory.toLowerCase()!='all'){
      transactionsList.removeWhere((TransactionModel transactionModel) => transactionModel.category!=selectedCategory);
    }

    for(int i=0; i<transactionsList.length; i++){
      setAmounts(transactionsList[i]);
    }

    // pdf.addPage(
    //     pw.Page(
    //         pageFormat: PdfPageFormat.a4,
    //         build: (pw.Context context) {
    //           return pw.Center(
    //             child: pw.Row(
    //                 mainAxisSize: pw.MainAxisSize.min,
    //                 children: [
    //                   amountContainer(
    //                     "Total Amount (Cash)",
    //                     amountController.totalAmountCash.toString(),
    //                     amountController.totalAddedCash.toString(),
    //                     amountController.totalWithdrawCash
    //                         .toString(),
    //                   ),
    //                   amountContainer(
    //                     "Total Amount (Card)",
    //                     amountController.totalAmountCard.toString(),
    //                     amountController.totalAddedCard.toString(),
    //                     amountController.totalWithdrawCard
    //                         .toString(),
    //                   ),
    //
    //
    //
    //                 ]
    //             )
    //           ); // Center
    //         }));



    print("list length : ${transactionsList.length}");

    int loopCount = 0;
    int i = 0;
    while( i<transactionsList.length){
      loopCount = loopCount+1;
      print("running loop $loopCount");
      await _addJobPageToPdf(i,firstPage: i==0 );
      i= (i==0) ? i+5 : i+6;
      print("i value at the end of loop $loopCount : $i");
    }

    // pdf.document.

    final Directory? output = await getExternalStorageDirectory();
    final File file = File("${output!.path}/money_tracker_transactions.pdf");
    File updatedFile = await file.writeAsBytes(await pdf.save());

    Fluttertoast.showToast(
        msg: "PDF saved successfully in directory: ${file.path}",
        toastLength: Toast.LENGTH_LONG);
    print(file.path);
    print(updatedFile.absolute.path);

    pdfController = nv.PdfController(
      document: nv.PdfDocument.openFile(file.path),
    );

    setState(() {
      pdfPath = file.path;
      loading = false;
    });
  }

  Widget pdfView() => nv.PdfView(
        controller: pdfController!,
        scrollDirection: Axis.vertical,
        pageLoader: const SizedBox(
            height: 20, child: Center(child: CircularProgressIndicator())),
      );


  pw.Widget amountContainer(
      String title, String amount, String totalAdded, String totalWithdrawal) {
    return pw.SizedBox(
      width: double.infinity,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 12.0),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(title,
                style:  pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold)),
             pw.SizedBox(
              height: 20,
            ),
            pw.Text(
              amount,
              style:  pw.TextStyle(
                  color: const PdfColor(0, 0, 1),
                  fontSize: 18,
              ),
            ),
            pw.SizedBox(
              height: 20,
            ),
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 8.0),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text("Total Added:       "),
                      pw.SizedBox(
                        width: 10,
                      ),
                      pw.Text(
                        totalAdded,
                        style: pw.TextStyle(
                            color: PdfColor(0, 1, 0), fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: 5,
                  ),
                  pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text("Total Withdrawn:"),
                      pw.SizedBox(
                        width: 10,
                      ),
                      pw.Text(
                        totalWithdrawal,
                        style: pw.TextStyle(
                            color: PdfColor(1, 0, 0), fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose(){
    pdfController?.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void setAmounts(TransactionModel transaction) {
    if (transaction.transactionSign == '+') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash = transaction.amount + amountController.totalAmountCash;
        amountController.totalAddedCash = transaction.amount + amountController.totalAddedCash;
      } else {
        amountController.totalAmountCard = amountController.totalAmountCard + transaction.amount;
        amountController.totalAddedCard = transaction.amount + amountController.totalAddedCard;
      }
    } else if (transaction.transactionSign == '-') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash = amountController.totalAmountCash - transaction.amount;
        amountController.totalWithdrawCash = transaction.amount + amountController.totalWithdrawCash;
      } else {
        amountController.totalAmountCard = amountController.totalAmountCard - transaction.amount;
        amountController.totalWithdrawCard = transaction.amount + amountController.totalWithdrawCard;
      }
    }
  }



}
