import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';

// Platform imports
import 'dart:io';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewPaymentScreen extends StatefulWidget {
  final String checkoutUrl;
  final String paymentProvider; // 'tabby' or 'tamara'
  final String successUrl;
  final String failureUrl;
  final String cancelUrl;

  const WebViewPaymentScreen({
    super.key,
    required this.checkoutUrl,
    required this.paymentProvider,
    required this.successUrl,
    required this.failureUrl,
    required this.cancelUrl,
  });

  @override
  State<WebViewPaymentScreen> createState() => _WebViewPaymentScreenState();
}

class _WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Enable hybrid composition for Android
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = 'Failed to load payment page: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    _controller = controller;
  }

  void _handleUrlChange(String url) {
    print('WebView URL changed: $url');
    
    // Check for success URLs
    if (_isSuccessUrl(url)) {
      _handlePaymentResult('success', url);
      return;
    }
    
    // Check for failure URLs
    if (_isFailureUrl(url)) {
      _handlePaymentResult('failure', url);
      return;
    }
    
    // Check for cancel URLs
    if (_isCancelUrl(url)) {
      _handlePaymentResult('cancelled', url);
      return;
    }
  }

  bool _isSuccessUrl(String url) {
    // Common success patterns for both Tabby and Tamara
    return url.contains('success') ||
           url.contains('approved') ||
           url.contains('completed') ||
           url.contains(widget.successUrl) ||
           (widget.paymentProvider == 'tabby' && url.contains('checkout/success')) ||
           (widget.paymentProvider == 'tamara' && url.contains('checkout/success'));
  }

  bool _isFailureUrl(String url) {
    // Common failure patterns for both Tabby and Tamara
    return url.contains('failure') ||
           url.contains('declined') ||
           url.contains('rejected') ||
           url.contains('error') ||
           url.contains(widget.failureUrl) ||
           (widget.paymentProvider == 'tabby' && url.contains('checkout/failure')) ||
           (widget.paymentProvider == 'tamara' && url.contains('checkout/failure'));
  }

  bool _isCancelUrl(String url) {
    // Common cancel patterns for both Tabby and Tamara
    return url.contains('cancel') ||
           url.contains('cancelled') ||
           url.contains(widget.cancelUrl) ||
           (widget.paymentProvider == 'tabby' && url.contains('checkout/cancel')) ||
           (widget.paymentProvider == 'tamara' && url.contains('checkout/cancel'));
  }

  void _handlePaymentResult(String result, String url) {
    // Extract payment ID or transaction ID from URL if available
    String? paymentId = _extractPaymentId(url);
    
    // Navigate back with result
    Navigator.of(context).pop({
      'status': result,
      'url': url,
      'paymentId': paymentId,
      'provider': widget.paymentProvider,
    });
  }

  String? _extractPaymentId(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Try to extract payment ID from query parameters
      if (uri.queryParameters.containsKey('payment_id')) {
        return uri.queryParameters['payment_id'];
      }
      if (uri.queryParameters.containsKey('id')) {
        return uri.queryParameters['id'];
      }
      if (uri.queryParameters.containsKey('transaction_id')) {
        return uri.queryParameters['transaction_id'];
      }
      
      // Try to extract from path segments
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
    } catch (e) {
      print('Error extracting payment ID: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.paymentProvider.toUpperCase()} Payment',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.textColor,
          onPressed: () {
            // Handle back button - treat as cancelled
            Navigator.of(context).pop({
              'status': 'cancelled',
              'url': '',
              'paymentId': null,
              'provider': widget.paymentProvider,
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.primaryColor,
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Error',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.greyColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                            });
                            _controller.reload();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'status': 'error',
                              'url': '',
                              'paymentId': null,
                              'provider': widget.paymentProvider,
                              'error': _error,
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}