import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';

import '../../core/widgets/primary_button.dart';

enum AlertDialogStatus {
  info,
  success,
  error,
}
class Globals {
  // FAVORITE ARTICLE TOAST
  showToast(msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      // backgroundColor: Colors.red,
      // backgroundColor: status == MessageStatus.success ? ADColors.successToastBackgroundColor : status == MessageStatus.info ? ADColors.infoToastBackgroundColor : ADColors.errorToastBackgroundColor,
      textColor: Colors.white,
    );
  }

  showSnackBar({  BuildContext? context,String? title, String? message, int? duration, Color? backgroundColor}) {
    Get.snackbar(title!, message!,
        messageText: Text(
          message,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        backgroundColor: backgroundColor??Colors.red,
        duration: duration != null
            ? Duration(seconds: duration)
            : const Duration(seconds: 3));
  }

  showOkayDialog({
    BuildContext? context,
    String? title,
    Widget? content,
    String? image,
    Function? okayTap,
  }) {
    AlertDialog(
      elevation: 0,
      // backgroundColor: ,
      scrollable: false,
      insetPadding: const EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      content: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(
            vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image!, height: 70),
            const SizedBox(height: 15),
            Text(title!,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context!).colorScheme.onSurface)),
            const SizedBox(height: 10),
            content!,
            const SizedBox(
              height: 25,
            ),
            PrimaryButton(
              backgroundColor: Colors.black12,
              
              
              onTap: () {
                okayTap != null ? okayTap() : Navigator.of(context).pop();
              },
              child: const Text(
                'Okay',
                style: TextStyle(color: Colors.black, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    ).show(context!,
        dialogTransitionType: DialogTransitionType.NONE,
        barrierDismissible: false,
        barrierColor: Theme.of(context).colorScheme.surface.withOpacity(0.8));
  }

  showAlertDialog(context, title, msg, status) {
    NDialog(
      dialogStyle: DialogStyle(contentPadding: EdgeInsets.zero),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            // color: ADColors.danger,
            // child: Lottie.asset('assets/lottie/error.json', height: 70)
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              msg,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                          side: const BorderSide(color: Colors.red)))),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK".toUpperCase(),
              )),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ).show(context);
  }

  void showBasicDialog({BuildContext? context, Widget? content, int? status}) {
    NDialog(
      dialogStyle: DialogStyle(contentPadding: EdgeInsets.zero),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              width: double.infinity,
              color: Colors.white,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: status == AlertDialogStatus.info
                    ? Colors.black12
                    : status == AlertDialogStatus.success
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Icon(
                  Icons.info,
                  color: status == AlertDialogStatus.info
                      ? Colors.black54
                      : status == AlertDialogStatus.success
                      ? Colors.green
                      : Colors.red,
                ),
              )),
          // SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
            child: content!,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              backgroundColor: Colors.black12,
              
              
              onTap: () => Navigator.of(context!).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.black, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ).show(context!, transitionType: DialogTransitionType.Bubble);
  }

  void showSecondaryDialog(
      {BuildContext? context,
        Widget? content,
        int? status,
        Function? okayTap}) {
    AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      content: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                  child: content!,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PrimaryButton(
                    backgroundColor: Colors.black12,
                    
                    
                    // onTap: () => okayTap?.call() ?? Navigator.of(context!).pop(),
                    onTap: () {
                      okayTap != null
                          ? okayTap()
                          : Navigator.of(context!).pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.black, fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          Positioned(
              top: -40,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: status == AlertDialogStatus.info
                    ? Colors.white
                    : status == AlertDialogStatus.success
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Icon(
                  Icons.info,
                  size: 30,
                  color: status == AlertDialogStatus.info
                      ? Colors.black
                      : status == AlertDialogStatus.success
                      ? Colors.green
                      : Colors.red,
                ),
              )),
        ],
      ),
    ).show(context!, dialogTransitionType: DialogTransitionType.Bubble);
  }

  void showCustomDialog(
      {BuildContext? context,
        Widget? content,
        Widget? header,
        Color? headerBackground,
        double? headerBottomMargin = 0,
        Function? okayTap}) {
    AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context!).size.width,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                  color: headerBackground,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18))),
              child: header!,
            ),
            SizedBox(
              height: headerBottomMargin,
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
              child: content!,
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                backgroundColor: Colors.black12,
                
                
                // onTap: () => okayTap?.call() ?? Navigator.of(context!).pop(),
                onTap: () {
                  okayTap != null ? okayTap() : Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    ).show(context, dialogTransitionType: DialogTransitionType.Bubble);
  }

  primaryConfirmDialog(
      {BuildContext? context,
        String? title, okayText,
        bool dismissible = true,
        Widget? content,
        String? image,
        Function? okayTap,
        Function? cancelTap}) {
    AlertDialog(
      elevation: 0,
      backgroundColor: Colors.white,
      scrollable: false,
      insetPadding: const EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
      content: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(
            vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image!, height: 70),
            const SizedBox(height: 15),
            Text(title!,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context!).colorScheme.onSurface)),
            const SizedBox(height: 10),
            content!,
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PrimaryButton(
                  
                  backgroundColor: Theme.of(context!).colorScheme.primary ,
                  
                  
                  onTap: () => cancelTap != null
                      ? cancelTap()
                      : Navigator.of(context!).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context!).colorScheme.onSurface, fontSize: 11),
                  ),
                ),
                PrimaryButton(
                  
                  backgroundColor: Theme.of(context!).colorScheme.primary,
                  
                  
                  onTap: () => okayTap != null
                      ? okayTap()
                      : Navigator.of(context).pop(),
                  child: Text(
                    okayText??'Yes',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).show(context!,
        dialogTransitionType: DialogTransitionType.NONE,
        barrierDismissible: dismissible,
        barrierColor:  Theme.of(context).colorScheme.onSurface.withOpacity(0.6));
  }

  void showConfirmDialog(
      {BuildContext? context,
        Widget? content,
        int? status,
        Function? yesTap,
        Function? noTap,
        Color? yesButtonBackground,
        Color? noButtonBackground,
        Widget? yesChild,
        Widget? noChild}) {
    AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      content: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                  child: content!,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PrimaryButton(
                        
                        backgroundColor: noButtonBackground,
                        
                        
                        // onTap: () => okayTap?.call() ?? Navigator.of(context!).pop(),
                        onTap: () {
                          noTap != null
                              ? noTap()
                              : Navigator.of(context!).pop();
                        },
                        child: noChild!,
                      ),
                      PrimaryButton(
                        
                        backgroundColor: yesButtonBackground,
                        
                        
                        // onTap: () => okayTap?.call() ?? Navigator.of(context!).pop(),
                        onTap: () {
                          yesTap != null
                              ? yesTap()
                              : Navigator.of(context!).pop();
                        },
                        child: yesChild!,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          Positioned(
              top: -40,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: status == AlertDialogStatus.info
                    ? Colors.white
                    : status == AlertDialogStatus.success
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Icon(
                  Icons.info,
                  size: 30,
                  color: status == AlertDialogStatus.info
                      ? Colors.black
                      : status == AlertDialogStatus.success
                      ? Colors.green
                      : Colors.red,
                ),
              )),
        ],
      ),
    ).show(context!, dialogTransitionType: DialogTransitionType.Bubble);
  }

  startWait(BuildContext context) {
    CustomProgressDialog progressDialog = CustomProgressDialog(
      context,
      dismissable: false,
      loadingWidget: ClipOval(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary,))
          // Image.asset('assets/gif/loading2.gif', height: 60)),
        ),
      ),

      // loadingWidget: Container(
      //   color: Colors.white.withOpacity(0.5),
      //   padding: const EdgeInsets.all(15),
      //   child: Image.asset('assets/gif/loading1.gif', height: 30)
      // ),
    );
    progressDialog.show();
  }

  endWait(context) {
    Navigator.of(context).pop();
  }
}