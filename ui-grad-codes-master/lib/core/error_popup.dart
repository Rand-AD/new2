import 'package:flutter/material.dart';

class ErrorPopup {
  ErrorPopup._();

  static const Color teal = Color(0xFF1D5D6D);

  static Future<void> show(
    BuildContext context, {
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ErrorPopupDialog(message: message),
    );
  }
}

class _ErrorPopupDialog extends StatelessWidget {
  const _ErrorPopupDialog({required this.message});

  final String message;

  static const Color teal = Color(0xFF1D5D6D);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: teal, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -10,
            right: -10,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, color: teal, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
