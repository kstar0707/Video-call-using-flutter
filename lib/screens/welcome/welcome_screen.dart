import 'package:flutter/material.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/welcome_image.png"),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              Text(
                AppConfig.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  "app_short_description".tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: greyColor, fontSize: 18),
                ),
              ),
              const SizedBox(height: 50),
              FittedBox(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        Future(() => Get.offAllNamed(AppRoutes.signInOrSignUp)),
                    child: Row(
                      children: [
                        Text(
                          "get_started".tr,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(width: defaultPadding / 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white70,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
