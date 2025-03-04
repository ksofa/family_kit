import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScanner({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late MobileScannerController _controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isScanning = false);
        widget.onBarcodeDetected(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black26,
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: ValueListenableBuilder(
                        valueListenable: _controller.torchState,
                        builder: (context, state, child) {
                          return Icon(
                            state == TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.white,
                          );
                        },
                      ),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: ValueListenableBuilder(
                        valueListenable: _controller.cameraFacingState,
                        builder: (context, state, child) {
                          return Icon(
                            state == CameraFacing.front
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            color: Colors.white,
                          );
                        },
                      ),
                      onPressed: () => _controller.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 