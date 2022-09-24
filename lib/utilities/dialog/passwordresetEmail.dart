import 'package:flutter/material.dart';
import 'package:notes/utilities/dialog/genericDialog.dart';

Future<void> showpasswordResetSendDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'password reset',
    content: 'we ahve sent a password reset link to  your mail',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
