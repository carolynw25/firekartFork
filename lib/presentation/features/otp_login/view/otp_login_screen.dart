import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttercommerce/core/localization/localization.dart';
import 'package:fluttercommerce/core/state_manager/base_view.dart';
import 'package:fluttercommerce/core/theme/theme_provider.dart';
import 'package:fluttercommerce/presentation/res/colors.gen.dart';

import '../../../../core/utils/validator.dart';
import '../../../res/styles.dart';
import '../../../routes/navigation_handler.dart';
import '../../../widgets/commom_text_field.dart';
import '../../../widgets/common_app_loader.dart';
import '../../../widgets/common_button.dart';
import '../state/otp_login_state.dart';
import '../view_model/otp_login_view_model.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({this.phoneNumber, Key? key}) : super(key: key);

  final String? phoneNumber;

  @override
  State createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController otpNumberController = TextEditingController();
  Validator validator = Validator();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return BaseView<OtpLoginViewModel, OtpLoginState>(
        onViewModelReady: (viewModel) {
          viewModel.sendOtp(widget.phoneNumber!);
          otpNumberController.addListener(() {
            viewModel.validateButton(otpNumberController.text);
          });
        },
        builder: (context, viewModel, state) => Scaffold(
              body: Stack(
                children: <Widget>[
                  Material(
                    elevation: 5,
                    child: Container(
                      height: 250,
                      width: width,
                      decoration: BoxDecoration(
                        gradient: Styles.appBackGradient,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                      body: Column(
                        children: <Widget>[_loginCard(viewModel, state)],
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _loginCard(OtpLoginViewModel viewModel, OtpLoginState state) {
    return Card(
      margin: const EdgeInsets.only(top: 50, right: 16, left: 16),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                Localization.value.mobileVerification,
                style: ThemeProvider.textTheme.headline2,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                Localization.value.mobileVerificationDesc,
                style: ThemeProvider.textTheme.bodyText2,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  InkWell(
                    child: Text(
                      Localization.value.changeNumber,
                      style: ThemeProvider.textTheme.caption?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    onTap: () {
                      NavigationHandler.pop(true);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                textEditingController: otpNumberController,
                hint: Localization.value.enterOtp,
                validator: validator.validate6DigitCode,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 20,
              ),
              BlocConsumer<OtpLoginViewModel, OtpLoginState>(
                bloc: viewModel,
                listener: (BuildContext context, OtpLoginState state) {
                  if (state.otp != null) {
                    otpNumberController.text = state.otp!;
                  }
                },
                builder: (BuildContext context, OtpLoginState state) {
                  return CommonButton(
                    title: Localization.value.confirmOtp,
                    height: 50,
                    isEnabled: state.isButtonEnabled,
                    replaceWithIndicator: state.confirmOtpLoading,
                    onTap: () {
                      onButtonTap(viewModel);
                    },
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Builder(
                builder: (BuildContext context) {
                  if (state.resendOtpLoading) {
                    return const CommonAppLoader();
                  }
                  return GestureDetector(
                    onTap: () {
                      viewModel.sendOtp(widget.phoneNumber!);
                    },
                    child: Text(
                      Localization.value.resendOtp,
                      style: ThemeProvider.textTheme.caption?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                child: Text(
                  Localization.value.goBack,
                  style: ThemeProvider.textTheme.caption?.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                onTap: () {
                  NavigationHandler.pop();
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onButtonTap(OtpLoginViewModel viewModel, {bool isResend = false}) {
    if (_formKey.currentState!.validate()) {
      viewModel.loginWithOtp(otpNumberController.text.trim(), isResend);
    }
  }
}
