import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'storage.dart';
import 'theme.dart';

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TesdyPom',
      debugShowCheckedModeBanner: false,
      theme: buildBrandTheme(),
      home: const PomodoroPage(),
    );
  }
}

enum SessionType { work, breakSession }

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with TickerProviderStateMixin {
  static const int _defaultWorkMinutes = 25;
  static const int _defaultBreakMinutes = 5;
  static const int _xpPerSession = 20;

  int _workMinutes = _defaultWorkMinutes;
  int _breakMinutes = _defaultBreakMinutes;

  late int _totalSeconds;
  int _sessionCounter = 0;
  SessionType _session = SessionType.work;
  bool _isRunning = false;

  Timer? _ticker;
  final StatsStore _store = StatsStore();
  AppStats _stats = AppStats();

  final Set<String> _unlockedAchievements = {};

  List<_Confetti> _confetti = [];
  int _quoteIndex = 0;
  bool _showConfetti = false;
  Ticker? _confettiTicker;
  double _confettiTime = 0;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _workMinutes * 60;
    _quoteIndex = math.Random().nextInt(motivationalQuotes.length);
    _confettiTicker =
        createTicker((elapsed) {
          setState(() {
            _confettiTime = elapsed.inMilliseconds / 1000.0;
            _confetti.removeWhere(
                (c) => c.y > _confettiTarget() + 40);
          });
        });
    _loadStats();
  }

  double _confettiTarget() => 600;

  @override
  void dispose() {
    _ticker?.cancel();
    _confettiTicker?.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await _store.load();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _evaluateAchievements(showUnlocks: false);
    });
  }

  void _resetToStart() {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _session = SessionType.work;
      _totalSeconds = _workMinutes * 60;
    });
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isRunning) {
        _ticker?.cancel();
        _isRunning = false;
      } else {
        _isRunning = true;
        _ticker =
            Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    });
  }

  void _tick() {
    if (_totalSeconds <= 0) {
      _onSessionComplete();
      return;
    }
    setState(() {
      _totalSeconds--;
    });
  }

  Future<void> _onSessionComplete() async {
    _ticker?.cancel();
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();

    if (_session == SessionType.work) {
      final counterToday = _stats.todayCount() + 1;
      final completedCycle =
          counterToday > 0 && counterToday % 4 == 0;

      setState(() {
        _sessionCounter++;
        _stats.totalSessions++;
        _stats.xp += _xpPerSession;
        final key = _dayKey(DateTime.now());
        _stats.dailySessions[key] = counterToday;
      });
      await _store.save(_stats);
      _evaluateAchievements(showUnlocks: true);

      if (completedCycle) {
        _launchConfetti();
        _celebrateCycle();
      }

      setState(() {
        _session = SessionType.breakSession;
        _totalSeconds = _breakMinutes * 60;
        _isRunning = false;
        _quoteIndex = math.Random().nextInt(motivationalQuotes.length);
      });
      _breakSnack('Take a well-earned break! 🌿');
    } else {
      setState(() {
        _session = SessionType.work;
        _totalSeconds = _workMinutes * 60;
        _isRunning = false;
      });
      _breakSnack('Back to focus — let\'s go! 🚀');
    }
  }

  void _celebrateCycle() {
    // Fire a bonus reward for finishing a full 4-pomodoro cycle.
    const bonusXp = 30;
    setState(() => _stats.xp += bonusXp);
    _store.save(_stats);
    final quote = motivationalQuotes[_quoteIndex];
    _showSnack('🎉 4-pomodoro cycle complete! +$bonusXp XP bonus',
        long: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(quote),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _launchConfetti() {
    setState(() {
      _confetti = List.generate(60, (i) {
        return _Confetti(
          x: math.Random().nextDouble(),
          velocity: 140 + math.Random().nextDouble() * 160,
          hue: math.Random().nextDouble() * 360,
          size: 6 + math.Random().nextDouble() * 8,
          rotation: math.Random().nextDouble() * math.pi * 2,
          spin: (math.Random().nextDouble() - 0.5) * 6,
        );
      });
      _showConfetti = true;
    });
    if (!_confettiTicker!.isActive) {
      _confettiTicker!.start();
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
            _confetti = [];
          });
          _confettiTicker!.stop();
        }
      });
    }
  }

  void _evaluateAchievements({required bool showUnlocks}) {
    final newly = <Achievement>[];
    for (final a in achievements) {
      if (!_unlockedAchievements.contains(a.id) && a.condition(_stats)) {
        _unlockedAchievements.add(a.id);
        newly.add(a);
      }
    }
    if (newly.isNotEmpty && showUnlocks && mounted) {
      _showAchievementUnlocks(newly);
    }
  }

  void _showAchievementUnlocks(List<Achievement> list) {
    for (final a in list) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          content: Row(
            children: [
              Icon(a.icon,
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text('🏅 ${a.title} — ${a.description}'),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _breakSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSnack(String msg, {bool long = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
        duration: Duration(seconds: long ? 4 : 2),
      ),
    );
  }

  String _dayKey(DateTime day) {
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '${day.year}-$m-$d';
  }

  Future<void> _showSettings() async {
    final workController =
        TextEditingController(text: _workMinutes.toString());
    final breakController =
        TextEditingController(text: _breakMinutes.toString());
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize durations'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: workController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Work minutes',
                  icon: Icon(Icons.work),
                ),
                validator: (value) => _validateMinutes(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: breakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Break minutes',
                  icon: Icon(Icons.self_improvement),
                ),
                validator: (value) => _validateMinutes(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'work': int.parse(workController.text),
                  'break': int.parse(breakController.text),
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _workMinutes = result['work']!;
        _breakMinutes = result['break']!;
        _totalSeconds = _workMinutes * 60;
        _session = SessionType.work;
        _isRunning = false;
      });
      _ticker?.cancel();
    }
  }

  String? _validateMinutes(String? value) {
    final n = int.tryParse(value ?? '');
    if (n == null || n < 1 || n > 120) {
      return 'Enter a number between 1 and 120';
    }
    return null;
  }

  String get _timeLabel {
    final minutes = (_totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    final total = (_session == SessionType.work
            ? _workMinutes
            : _breakMinutes) *
        60;
    if (total == 0) return 0;
    return (_totalSeconds / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWork = _session == SessionType.work;
    final sessionColor = isWork ? Brand.green700 : Brand.gold600;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sessionColor.withOpacity(0.25),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLevelBar(colorScheme),
                    const SizedBox(height: 12),
                    Text(
                      isWork ? 'FOCUS' : 'BREAK',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                            color: sessionColor,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _buildTimerCircle(sessionColor),
                    const SizedBox(height: 24),
                    _buildControls(),
                    const SizedBox(height: 16),
                    _buildStatusLine(),
                    const SizedBox(height: 24),
                    _buildWeekChart(colorScheme),
                    const SizedBox(height: 16),
                    _buildAchievementsRow(colorScheme),
                  ],
                ),
              ),
            ),
          ),
          if (_showConfetti) _buildConfettiLayer(),
        ],
      ),
    );
  }

  Widget _buildLevelBar(ColorScheme colorScheme) {
    final prefix = 'Lv.${_stats.level}';
    return Card(
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            prefix,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          'Level ${_stats.level} — ${_stats.nextLevelXp - _stats.xp} XP to next',
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _stats.levelProgress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        trailing: Text(
          '🔥 ${_stats.currentStreak()} day streak',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(Color sessionColor) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, _) {
              return CustomPaint(
                painter: _GradientRingPainter(
                  value: value,
                  color: sessionColor,
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRunning
                      ? 'Running'
                      : _totalSeconds ==
                              (_session == SessionType.work
                                  ? _workMinutes
                                  : _breakMinutes) *
                                  60
                          ? 'Ready'
                          : 'Paused',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: _resetToStart,
          tooltip: 'Reset',
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _toggle,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(_isRunning ? 'Pause' : 'Start'),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          onPressed: _showSettings,
          tooltip: 'Settings',
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildStatusLine() {
    final today = _stats.todayCount();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(Icons.today, '$today today'),
        const SizedBox(width: 12),
        _chip(Icons.timer, '$_sessionCounter this session'),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildWeekChart(ColorScheme colorScheme) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon..7=Sun
    final maxCount = _stats.totalForLastNDays(7);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This week',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                // Start from Monday of current week.
                final day = now.subtract(
                    Duration(days: weekday - 1 - i));
                final count = _stats.countOn(day);
                final isToday = i == weekday - 1;
                final barHeight =
                    maxCount == 0 ? 4.0 : (count / maxCount) * 60;
                final label = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 22,
                          height: isToday ? barHeight : barHeight - 4,
                          decoration: BoxDecoration(
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.primary.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        )),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsRow(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((a) {
                final unlocked = _unlockedAchievements.contains(a.id);
                return Tooltip(
                  message: '${a.title} — ${a.description}',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: unlocked
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    child: Icon(
                      unlocked ? a.icon : Icons.lock_outline,
                      color: unlocked
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConfettiPainter(particles: _confetti, time: _confettiTime),
        ),
      ),
    );
  }
}

class _Confetti {
  final double x;
  final double velocity;
  final double hue;
  final double size;
  final double rotation;
  final double spin;
  double y = 0;
  _Confetti({
    required this.x,
    required this.velocity,
    required this.hue,
    required this.size,
    required this.rotation,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> particles;
  final double time;
  _ConfettiPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.y = (p.velocity * time) * 0.3;
      final xPos = p.x * size.width;
      final yPos = p.y;
      final paint = Paint()
        ..color = HSLColor.fromAHSL(1, p.hue, 0.7, 0.6).toColor();
      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(p.spin * time);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.particles != particles || oldDelegate.time != time;
}

class _GradientRingPainter extends CustomPainter {
  final double value;
  final Color color;
  _GradientRingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withOpacity(0.15);
    canvas.drawCircle(center, radius, trackPaint);

    final sweepRect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [color, HSLColor.fromColor(color).withHue(20).toColor()],
      stops: const [0, 1],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(sweepRect);

    canvas.drawArc(
      sweepRect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arcPaint,
    );

    // Soft glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..color = color.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      sweepRect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
