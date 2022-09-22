//import 'dart:html';

// ignore_for_file: camel_case_types, dead_code

//import 'package:firebase_core/firebase_core.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
//import 'dart:html';

//import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/Views/loginView.dart';
import 'package:notes/Views/registerview.dart';
import 'package:notes/Views/verifyemailview.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/Views/notes/notesview.dart';
import 'package:notes/services/auth/Bloc/Auth_Events.dart';
import 'package:notes/services/auth/Bloc/authBloc.dart';
import 'package:notes/services/auth/Bloc/auth_state.dart';
//import 'package:notes/services/auth/auth_provider.dart';
//import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/auth/firebase_auth_provider.dart';
//import 'package:path/path.dart';

import 'Views/notes/createUpdateNoteView.dart';
//import 'dart:developer' as devtools show log;

//import 'Views/notesview.dart';
//import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const homePage(),
    ),
    routes: {
      //key value pairs strings->functions
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      notesRoute: (context) => const Notes(),
      verify: (context) => const VerifyEmailView(),
      createUpdateNoteRoute: (context) => const createUpdateNoteView()
    },
  ));
}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);
//being manager for routing to different pages of the app
//and need to initialise firebase app

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialise());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const Notes();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return LoginView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });

//     return FutureBuilder(
//         future: AuthService.firebase().initialize(),
//         builder: (BuildContext context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;

//               if (user != null) {
//                 if (user.isEmailVerified) {
//                   return const Notes();
//                 }
//                 return const RegisterView();
//               } else {
//                 return const VerifyEmailView();
//               }
//               //return const Text('Done');

//               return const LoginView();
//             default:
//               return const CircularProgressIndicator();
//           }
//         });
//   }
// }

//tap on
//upon pressing on popupmenuitem simulates onselect event
//showDialog(stf class) and AlertDialog(stl class)

//

//CTA call to action
//future and functions

//write a logout func to display dialog
    Future<bool> showLogOutDialog(BuildContext context) {
      return showDialog<bool>(
          //return optional boolean
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('sign out'),
                content: const Text('Are u sure u want to signout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('logout'),
                  ),
                ]);
          }).then((value) => value ?? false);
    }
  }

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//           appBar: AppBar(
//             title: const Text('testing Bloc'),
//           ),
//           body: BlocConsumer<CounterBloc, CounterState>(
//             listener: (context, state) {
//               _controller.clear();
//             },
//             builder: (context, state) {
//               final invlaidValue = (state is CounterStateInvalidNumber)
//                   ? state.invalidValue
//                   : '';
//               return Column(
//                 children: [
//                   Text('current Value=>${state.value}'),
//                   Visibility(
//                     child: Text('invalid Input :$invlaidValue'),
//                     visible: state is CounterStateInvalidNumber,
//                   ),
//                   TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                         hintText: 'enter Your number here'),
//                     keyboardType: TextInputType.number,
//                   ),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBloc>()
//                               .add(DecrementEvent(_controller.text));
//                         },
//                         child: const Text('-'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBloc>()
//                               .add(IncrementEvent(_controller.text));
//                         },
//                         child: const Text('+'),
//                       )
//                     ],
//                   ),
//                 ],
//               );
//             },
//           )),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;

//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int preveousValue,
//   }) : super(preveousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(
//           CounterStateInvalidNumber(
//               invalidValue: event.value, preveousValue: state.value),
//         );
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });
//     on<DecrementEvent>((Event, emit) {
//       final integer = int.tryParse(Event.value);
//       if (integer == null) {
//         emit(
//           CounterStateInvalidNumber(
//               invalidValue: Event.value, preveousValue: state.value),
//         );
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
}
