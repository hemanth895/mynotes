import 'package:flutter/cupertino.dart';

import 'genericDialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share empty notes',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
