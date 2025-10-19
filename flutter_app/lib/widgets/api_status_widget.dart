import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ApiStatusWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const ApiStatusWidget({
    super.key,
    this.onRefresh,
  });

  @override
  State<ApiStatusWidget> createState() => _ApiStatusWidgetState();
}

class _ApiStatusWidgetState extends State<ApiStatusWidget> {
  bool _isLoading = false;
  Map<String, dynamic> _healthData = {};

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthData = await ApiService.checkHealth();
      setState(() {
        _healthData = healthData;
      });
      
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = _healthData['isHealthy'] ?? false;
    final modelLoaded = _healthData['modelLoaded'] ?? false;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.defaultPadding),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHealthy ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.error,
                color: isHealthy ? AppColors.success : AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHealthy ? AppStrings.apiConnected : AppStrings.apiDisconnected,
                      style: TextStyle(
                        color: isHealthy ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isHealthy && _healthData.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Modelo: ${_healthData['modelType']} ${modelLoaded ? '✓' : '✗'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ] else if (_healthData['error'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _healthData['error'],
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton(
                  onPressed: _checkHealth,
                  child: const Text(AppStrings.verify),
                ),
            ],
          ),
          
          if (isHealthy && _healthData.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('URL:', ApiService.currentBaseUrl),
                  _buildInfoRow('TensorFlow:', _healthData['tensorflowVersion'] ?? 'N/A'),
                  _buildInfoRow('Input Size:', _healthData['inputSize'] ?? 'N/A'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}