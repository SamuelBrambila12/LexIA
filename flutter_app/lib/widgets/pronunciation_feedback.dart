import 'package:flutter/material.dart';

class PronunciationFeedback extends StatelessWidget {
  final double score;
  final String feedback;
  final List<String>? issues;
  final List<String>? tips;

  const PronunciationFeedback({
    super.key,
    required this.score,
    required this.feedback,
    this.issues,
    this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Círculo de puntaje
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[200],
                    color: scoreColor,
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${score.round()}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      'Puntaje',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Retroalimentación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    score >= 80 ? Icons.check_circle : Icons.info,
                    color: scoreColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if ((issues?.isNotEmpty ?? false)) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Qué salió mal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...issues!.map((e) => _BulletItem(text: e)).toList(),
              const SizedBox(height: 12),
            ],
            if ((tips?.isNotEmpty ?? false)) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cómo mejorarlo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...tips!
                  .map((e) => _BulletItem(
                        text: e,
                        icon: Icons.lightbulb_rounded,
                        color: Colors.amber,
                      ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const _BulletItem({
    required this.text,
    this.icon = Icons.close_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
