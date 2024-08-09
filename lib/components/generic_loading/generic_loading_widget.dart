import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../app_flow/app_flow_model.dart';
import 'generic_loading_model.dart';

class GenericLoadingWidget extends StatefulWidget {
  const GenericLoadingWidget({super.key});

  @override
  State<GenericLoadingWidget> createState() => _GenericLoadingWidgetState();
}

class _GenericLoadingWidgetState extends State<GenericLoadingWidget> {
  late GenericLoadingModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GenericLoadingModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animation/loading.json',
        fit: BoxFit.cover,
        width: 25.w, // Adjust the width and height as needed
        height: 25.w,
        repeat: true, // Set to true if you want the animation to loop
      ),
    );
  }
}
