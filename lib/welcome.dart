import 'package:flutter/material.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/widgets/bottom_action.dart';
import 'package:todo_app/widgets/features_section.dart';
import 'package:todo_app/widgets/header_section.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      HeaderSection(),
                      SizedBox(height: 32),
                      FeaturesSection(),
                    ],
                  ),
                ),
              ),
              BottomAction(),
            ],
          ),
        ),
      ),
    );
  }
}
