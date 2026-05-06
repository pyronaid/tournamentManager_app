import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tournamentmanager/pages/core/add_people/scanned_barcode_label.dart';
import 'package:tournamentmanager/pages/core/add_people/scanner_button_widgets.dart';
import 'package:tournamentmanager/pages/core/add_people/scanner_error_widget.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../components/custom_appbar_widget.dart';

class BarcodeScannerWithZoom extends StatefulWidget {
  const BarcodeScannerWithZoom({super.key});

  @override
  State<BarcodeScannerWithZoom> createState() => _BarcodeScannerWithZoomState();
}

class _BarcodeScannerWithZoomState extends State<BarcodeScannerWithZoom> {
  double _zoomFactor = 0.0;
  late final MobileScannerController controller;
  bool _isPageClosed = false;


  @override
  void initState() {
    controller = MobileScannerController(
      torchEnabled: false,
    );
    super.initState();
  }


  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isPageClosed) return; // Skip if already popped

    if (barcodes.barcodes.isNotEmpty) {
      final barcode = barcodes.barcodes.first;
      if (mounted) {
        _isPageClosed = true; // Mark the page as closed
        Navigator.pop(context, barcode.displayValue);
      }
    }
  }

  Widget _buildZoomScaleSlider() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final TextStyle labelStyle = Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: Colors.white);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '0%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
              Expanded(
                child: Slider(
                  value: _zoomFactor,
                  onChanged: (value) {
                    setState(() {
                      _zoomFactor = value;
                      controller.setZoomScale(value);
                    });
                  },
                ),
              ),
              Text(
                '100%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                color: CustomFlowTheme.of(context).secondary,
                child: Column(
                  children: [
                    const CustomAppbarWidget(backButton: true),
                    ////////////////
                    //PAGE TITLE
                    /////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
                      child: Text(
                        'Scannerizza il qr code del giocatore',
                        style: CustomFlowTheme.of(context).displaySmall,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                //height: 50.h,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        fit: BoxFit.contain,
                        onDetect: _handleBarcode,
                        errorBuilder: (context, error, child) {
                          return ScannerErrorWidget(error: error);
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height: 100,
                          color: Colors.black.withValues(alpha: 0.4),
                          child: Column(
                            children: [
                              if (!kIsWeb) _buildZoomScaleSlider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ToggleFlashlightButton(controller: controller),
                                  //StartStopMobileScannerButton(controller: controller),
                                  Expanded(
                                    child: Center(
                                      child: ScannedBarcodeLabel(
                                        barcodes: controller.barcodes,
                                      ),
                                    ),
                                  ),
                                  //SwitchCameraButton(controller: controller),
                                  AnalyzeImageFromGalleryButton(controller: controller),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}