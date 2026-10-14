import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/ac_controller.dart';
import '../models/ac_state.dart';
import 'theme.dart';

// ═══════════════════════════════════════════════════════════════════════
// ROOT
// ═══════════════════════════════════════════════════════════════════════

class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _HeaderCard(),
                SizedBox(height: 30),
                _TemperatureHero(),
                SizedBox(height: 30),
                _ModeSection(),
                SizedBox(height: 24),
                _FanSpeedSection(),
                SizedBox(height: 24),
                _AirflowSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HEADER CARD
// ═══════════════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Selector<AcController, ({bool isOn, AcMode mode})>(
      selector: (_, c) => (isOn: c.isOn, mode: c.mode),
      builder: (context, data, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: data.isOn
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppTheme.border,
            ),
            boxShadow: data.isOn ? AppTheme.whiteGlow(intensity: 0.5) : null,
          ),
          child: Row(
            children: [
              // Mode icon badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.isOn
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppTheme.surfaceMid,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: data.isOn
                        ? Colors.white.withValues(alpha: 0.35)
                        : AppTheme.border,
                  ),
                ),
                child: Icon(
                  _modeIcon(data.mode),
                  size: 20,
                  color: data.isOn ? Colors.white : AppTheme.textDim,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('O General AC',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: data.isOn
                                ? Colors.white
                                : AppTheme.textDim,
                            boxShadow: data.isOn
                                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 6)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.isOn
                              ? '${data.mode.label} mode'
                              : 'Standby',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _PowerButton(isOn: data.isOn),
            ],
          ),
        );
      },
    );
  }

  IconData _modeIcon(AcMode m) => switch (m) {
        AcMode.cool => Icons.ac_unit_rounded,
        AcMode.dry  => Icons.water_drop_outlined,
        AcMode.fan  => Icons.air_rounded,
        AcMode.auto => Icons.hdr_auto_rounded,
      };
}

// ── Power button (Black & White) ─────────────────────────────────────

class _PowerButton extends StatefulWidget {
  const _PowerButton({required this.isOn});
  final bool isOn;

  @override
  State<_PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<_PowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    if (widget.isOn) _anim.value = 1;
  }

  @override
  void didUpdateWidget(covariant _PowerButton old) {
    super.didUpdateWidget(old);
    if (widget.isOn != old.isOn) {
      widget.isOn ? _anim.forward() : _anim.reverse();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t = _anim.value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<AcController>().togglePower();
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(AppTheme.surfaceMid, Colors.white, t),
              border: Border.all(
                color: Color.lerp(AppTheme.border, Colors.white, t)!,
                width: 1.5,
              ),
              boxShadow: t > 0.5
                  ? AppTheme.whiteGlow(intensity: 0.8 * t)
                  : null,
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 20,
              color: Color.lerp(AppTheme.textDim, Colors.black, t),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TEMPERATURE HERO
// ═══════════════════════════════════════════════════════════════════════

class _TemperatureHero extends StatelessWidget {
  const _TemperatureHero();

  @override
  Widget build(BuildContext context) {
    return Selector<AcController, ({bool isOn, int temperature})>(
      selector: (_, c) => (isOn: c.isOn, temperature: c.temperature),
      builder: (context, data, _) {
        final enabled = data.isOn;
        return Column(
          children: [
            // Status label above the number
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                enabled ? _label(data.temperature) : 'OFF',
                key: ValueKey('${data.temperature}_$enabled'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: enabled ? Colors.white : AppTheme.textDim,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // Giant temperature number
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: RichText(
                key: ValueKey(data.temperature),
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.temperature}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: enabled
                                ? Colors.white
                                : AppTheme.textDim,
                          ),
                    ),
                    TextSpan(
                      text: '°C',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: enabled
                                ? AppTheme.textSecondary
                                : AppTheme.textDim,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // − / + buttons
            Row(
              children: [
                Expanded(
                  child: _TempButton(
                    label: '−',
                    enabled: enabled && data.temperature > 16,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<AcController>().decrementTemp();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _TempButton(
                    label: '+',
                    enabled: enabled && data.temperature < 30,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<AcController>().incrementTemp();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Range pip strip
            _TempRangePips(temperature: data.temperature, enabled: enabled),
          ],
        );
      },
    );
  }

  String _label(int t) {
    if (t <= 18) return 'VERY COOL';
    if (t <= 21) return 'COOL';
    if (t <= 24) return 'COMFORTABLE';
    if (t <= 27) return 'WARM';
    return 'VERY WARM';
  }
}

class _TempButton extends StatefulWidget {
  const _TempButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_TempButton> createState() => _TempButtonState();
}

class _TempButtonState extends State<_TempButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 64,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.12)
              : (widget.enabled
                  ? AppTheme.surfaceMid
                  : AppTheme.surface),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.enabled
                ? (_pressed ? Colors.white : AppTheme.borderBright)
                : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: widget.enabled && _pressed
              ? AppTheme.whiteGlow(intensity: 0.5)
              : null,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: widget.enabled ? Colors.white : AppTheme.textDim,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _TempRangePips extends StatelessWidget {
  const _TempRangePips({required this.temperature, required this.enabled});
  final int temperature;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('16°', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(15, (i) {
              final active = enabled && i < (temperature - 16);
              final isCurrent = enabled && i == (temperature - 16 - 1);
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: isCurrent ? 6 : 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: active
                        ? Colors.white.withValues(alpha: isCurrent ? 1.0 : 0.40)
                        : AppTheme.border,
                    boxShadow: isCurrent ? AppTheme.whiteGlow(intensity: 0.8) : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text('30°', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MODE SECTION
// ═══════════════════════════════════════════════════════════════════════

class _ModeSection extends StatelessWidget {
  const _ModeSection();

  static const _modes = <AcMode, ({IconData icon, String label})>{
    AcMode.cool: (icon: Icons.ac_unit_rounded,     label: 'Cool'),
    AcMode.auto: (icon: Icons.hdr_auto_rounded,    label: 'Auto'),
    AcMode.dry:  (icon: Icons.water_drop_outlined, label: 'Dry'),
    AcMode.fan:  (icon: Icons.air_rounded,         label: 'Fan'),
  };

  @override
  Widget build(BuildContext context) {
    return Selector<AcController, ({bool isOn, AcMode mode})>(
      selector: (_, c) => (isOn: c.isOn, mode: c.mode),
      builder: (context, data, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('MODE'),
            const SizedBox(height: 12),
            Row(
              children: AcMode.values.map((mode) {
                final cfg = _modes[mode]!;
                final selected = data.mode == mode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ModeCard(
                      icon: cfg.icon,
                      label: cfg.label,
                      selected: selected,
                      enabled: data.isOn,
                      onTap: data.isOn
                          ? () {
                              HapticFeedback.selectionClick();
                              context.read<AcController>().setMode(mode);
                            }
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected && enabled;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.activeGradient : null,
          color: active ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppTheme.border,
          ),
          boxShadow: active
              ? AppTheme.whiteGlow(intensity: 0.7)
              : AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: active
                  ? Colors.black // High-contrast black icon on white card
                  : enabled
                      ? AppTheme.textSecondary
                      : AppTheme.textDim,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: active
                        ? Colors.black // High-contrast black text on white card
                        : enabled
                            ? AppTheme.textSecondary
                            : AppTheme.textDim,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// FAN SPEED SECTION
// ═══════════════════════════════════════════════════════════════════════

class _FanSpeedSection extends StatelessWidget {
  const _FanSpeedSection();

  static const _fanSpeeds = [
    FanSpeed.auto,
    FanSpeed.low,
    FanSpeed.medium,
    FanSpeed.high,
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<AcController, ({bool isOn, FanSpeed fanSpeed})>(
      selector: (_, c) => (isOn: c.isOn, fanSpeed: c.fanSpeed),
      builder: (context, data, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('FAN SPEED'),
            const SizedBox(height: 12),
            Row(
              children: _fanSpeeds.map((speed) {
                final selected = data.fanSpeed == speed;
                final enabled = data.isOn;
                final active = selected && enabled;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: enabled
                          ? () {
                              HapticFeedback.selectionClick();
                              context.read<AcController>().setFanSpeed(speed);
                            }
                          : null,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppTheme.surface,
                              border: Border.all(
                                color: active
                                    ? Colors.white
                                    : AppTheme.border,
                                width: active ? 1.5 : 1,
                              ),
                              boxShadow: active
                                  ? AppTheme.whiteGlow(intensity: 0.6)
                                  : null,
                            ),
                            child: Center(
                              child: _SpinningFan(
                                active: active,
                                speed: speed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            speed.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: active
                                      ? Colors.white
                                      : enabled
                                          ? AppTheme.textSecondary
                                          : AppTheme.textDim,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _SpinningFan extends StatefulWidget {
  const _SpinningFan({required this.active, required this.speed});
  final bool active;
  final FanSpeed speed;

  @override
  State<_SpinningFan> createState() => _SpinningFanState();
}

class _SpinningFanState extends State<_SpinningFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  double _durationMs(FanSpeed s) => switch (s) {
        FanSpeed.high   => 600,
        FanSpeed.medium => 1000,
        FanSpeed.low    => 1800,
        FanSpeed.auto   => 1200,
      };

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durationMs(widget.speed).toInt()),
    );
    if (widget.active) _anim.repeat();
  }

  @override
  void didUpdateWidget(covariant _SpinningFan old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active || widget.speed != old.speed) {
      _anim.duration =
          Duration(milliseconds: _durationMs(widget.speed).toInt());
      if (widget.active) {
        _anim.repeat();
      } else {
        _anim.stop();
        _anim.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.rotate(
        angle: _anim.value * 2 * math.pi,
        child: Icon(
          Icons.wind_power_rounded,
          size: 22,
          color: widget.active ? Colors.white : AppTheme.textDim,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AIRFLOW DIRECTION (SWING & SET FLAP ANGLE)
// ═══════════════════════════════════════════════════════════════════════

class _AirflowSection extends StatelessWidget {
  const _AirflowSection();

  @override
  Widget build(BuildContext context) {
    return Selector<AcController,
        ({bool isOn, bool swingEnabled, int flapPosition, int flapAngleDegrees, String flapDescription})>(
      selector: (_, c) => (
        isOn: c.isOn,
        swingEnabled: c.swingEnabled,
        flapPosition: c.flapPosition,
        flapAngleDegrees: c.flapAngleDegrees,
        flapDescription: c.flapDescription,
      ),
      builder: (context, data, _) {
        final enabled = data.isOn;
        final swingActive = enabled && data.swingEnabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('AIRFLOW DIRECTION'),
                if (enabled)
                  Text(
                    swingActive ? 'AUTO SWINGING' : '${data.flapAngleDegrees}° FIXED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: swingActive ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // ── SWING BUTTON ──────────────────────────────────
                Expanded(
                  child: _AirflowCard(
                    title: 'SWING',
                    subtitle: swingActive ? 'Oscillating' : 'Static airflow',
                    badgeText: swingActive ? 'ON' : 'OFF',
                    badgeActive: swingActive,
                    active: swingActive,
                    enabled: enabled,
                    onTap: enabled
                        ? () {
                            HapticFeedback.selectionClick();
                            context.read<AcController>().toggleSwing();
                          }
                        : null,
                    iconWidget: _AnimatedSwingIcon(active: swingActive),
                    footerWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.waves_rounded,
                          size: 13,
                          color: swingActive ? Colors.white : AppTheme.textDim,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          swingActive ? 'Auto Oscillation' : 'Fixed Position',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: swingActive ? Colors.white : AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // ── SET BUTTON (FLAP ANGLE) ────────────────────────
                Expanded(
                  child: _AirflowCard(
                    title: 'SET',
                    subtitle: '${data.flapAngleDegrees}° · ${data.flapDescription}',
                    badgeText: 'STEP ${data.flapPosition}/6',
                    badgeActive: enabled,
                    active: enabled && !swingActive,
                    enabled: enabled,
                    onTap: enabled
                        ? () {
                            HapticFeedback.mediumImpact();
                            context.read<AcController>().cycleFlapPosition();
                          }
                        : null,
                    iconWidget: _FlapAngleIcon(
                      angleDegrees: data.flapAngleDegrees.toDouble(),
                      active: enabled && !swingActive,
                      enabled: enabled,
                    ),
                    footerWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final pos = index + 1;
                        final isCurrent = pos == data.flapPosition;
                        return Container(
                          width: isCurrent ? 14 : 5,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: enabled
                                ? (isCurrent ? Colors.white : AppTheme.border)
                                : AppTheme.border,
                            boxShadow: isCurrent && enabled
                                ? AppTheme.whiteGlow(intensity: 0.8)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AirflowCard extends StatefulWidget {
  const _AirflowCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeActive,
    required this.active,
    required this.enabled,
    required this.onTap,
    required this.iconWidget,
    required this.footerWidget,
  });

  final String title;
  final String subtitle;
  final String badgeText;
  final bool badgeActive;
  final bool active;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget iconWidget;
  final Widget footerWidget;

  @override
  State<_AirflowCard> createState() => _AirflowCardState();
}

class _AirflowCardState extends State<_AirflowCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.08)
              : (widget.active
                  ? AppTheme.surfaceMid
                  : AppTheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.active
                ? Colors.white.withValues(alpha: 0.6)
                : AppTheme.border,
            width: widget.active ? 1.5 : 1.0,
          ),
          boxShadow: widget.active
              ? AppTheme.whiteGlow(intensity: 0.5)
              : AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon + Pill badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.iconWidget,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.badgeActive
                        ? Colors.white
                        : AppTheme.surfaceMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.badgeActive
                          ? Colors.white
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    widget.badgeText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.badgeActive
                          ? Colors.black // High-contrast black text on white badge
                          : AppTheme.textDim,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: widget.enabled ? Colors.white : AppTheme.textDim,
                  ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11.5,
                    color: widget.active
                        ? Colors.white
                        : (widget.enabled ? AppTheme.textSecondary : AppTheme.textDim),
                  ),
            ),
            const SizedBox(height: 14),
            // Footer widget
            widget.footerWidget,
          ],
        ),
      ),
    );
  }
}

// ── Flap angle visual icon ───────────────────────────────────────────

class _FlapAngleIcon extends StatelessWidget {
  const _FlapAngleIcon({
    required this.angleDegrees,
    required this.active,
    required this.enabled,
  });

  final double angleDegrees;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.10)
            : AppTheme.surfaceMid,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: active
              ? Colors.white.withValues(alpha: 0.45)
              : AppTheme.border,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: angleDegrees, end: angleDegrees),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return CustomPaint(
                painter: _FlapPainter(
                  angleDegrees: val,
                  color: enabled
                      ? (active ? Colors.white : AppTheme.textSecondary)
                      : AppTheme.textDim,
                  guideColor: AppTheme.borderBright,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FlapPainter extends CustomPainter {
  _FlapPainter({
    required this.angleDegrees,
    required this.color,
    required this.guideColor,
  });

  final double angleDegrees;
  final Color color;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width * 0.28, size.height * 0.30);
    final length = size.width * 0.58;

    // Arc guide showing the movement sector (15° to 90°)
    final guidePaint = Paint()
      ..color = guideColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final arcRect = Rect.fromCircle(center: pivot, radius: length);
    const startRad = 15 * math.pi / 180;
    const sweepRad = (90 - 15) * math.pi / 180;
    canvas.drawArc(arcRect, startRad, sweepRad, false, guidePaint);

    // Hinge / pivot dot
    canvas.drawCircle(pivot, 2.5, Paint()..color = color);

    // Flap blade line
    final rad = angleDegrees * math.pi / 180;
    final endX = pivot.dx + length * math.cos(rad);
    final endY = pivot.dy + length * math.sin(rad);

    final flapPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pivot, Offset(endX, endY), flapPaint);

    // Direction tip dot
    canvas.drawCircle(Offset(endX, endY), 2.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FlapPainter old) =>
      old.angleDegrees != angleDegrees ||
      old.color != color ||
      old.guideColor != guideColor;
}

// ── Animated swing icon ──────────────────────────────────────────────

class _AnimatedSwingIcon extends StatefulWidget {
  const _AnimatedSwingIcon({required this.active});
  final bool active;

  @override
  State<_AnimatedSwingIcon> createState() => _AnimatedSwingIconState();
}

class _AnimatedSwingIconState extends State<_AnimatedSwingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    if (widget.active) _anim.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnimatedSwingIcon old) {
    super.didUpdateWidget(old);
    if (widget.active && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.active && _anim.isAnimating) {
      _anim.stop();
      _anim.animateTo(0.5);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: widget.active
            ? Colors.white.withValues(alpha: 0.10)
            : AppTheme.surfaceMid,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: widget.active
              ? Colors.white.withValues(alpha: 0.40)
              : AppTheme.border,
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.rotate(
            angle: math.sin(_anim.value * math.pi) * 0.35,
            child: Icon(
              Icons.swap_vert_rounded,
              size: 22,
              color: widget.active ? Colors.white : AppTheme.textDim,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared section label ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              )),
    );
  }
}
