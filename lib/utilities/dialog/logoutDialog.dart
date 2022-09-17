import 'package:flutter/material.dart';
import 'package:notes/utilities/dialog/genericDialog.dart';

Future<bool> showLogOutDialog(BuildContext context, String title) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are You sure You want to logout?',
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
