import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'theme.dart';

/// Gabungkan nilai yang tidak kosong dengan pemisah.
String joinParts(Iterable<dynamic> parts, [String separator = ' • ']) => parts
    .where((e) => e != null && e.toString().trim().isNotEmpty)
    .join(separator);

bool hasText(dynamic value) => (value?.toString().trim() ?? '').isNotEmpty;

String initials(String? name) {
  final words =
      (name ?? '').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// Waktu relatif singkat: "Hari ini", "Kemarin", "3 hari lalu".
String relativeDay(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;
  if (days <= 0) return 'Hari ini';
  if (days == 1) return 'Kemarin';
  if (days < 30) return '$days hari lalu';
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Wadah putih bergaris tipis dengan bayangan halus.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.onTap,
    this.radius = 16,
    this.color = Colors.white,
    this.borderColor = AppColors.outline,
    this.shadow = AppShadows.level1,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final double radius;
  final Color color;
  final Color borderColor;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: shape,
          border: Border.all(color: borderColor),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Judul halaman tab: ikon dalam kotak biru muda, judul, dan avatar.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.icon = Icons.contactless,
    this.name,
  });
  final String title;
  final IconData icon;
  final String? name;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
        ),
        child: Row(
          children: [
            IconBox(icon, size: 34, radius: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (name != null)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoftBorder,
                  shape: BoxShape.circle,
                ),
                child: InitialsAvatar(name: name, size: 34),
              ),
          ],
        ),
      );
}

/// Halaman tab: header tetap di atas, isi dapat digulir dan disegarkan.
class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.header,
    required this.children,
    this.onRefresh,
  });
  final Widget header;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: children,
    );
    return Column(
      children: [
        header,
        Expanded(
          child: onRefresh == null
              ? list
              : RefreshIndicator(onRefresh: onRefresh!, child: list),
        ),
      ],
    );
  }
}

/// Label bagian kecil berhuruf kapital.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.color = AppColors.textTertiary,
  });
  final String text;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: color,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Label isian tebal di atas kolom input.
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.trailing,
    this.icon,
  });
  final String text;
  final bool required;
  final String? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
            ],
            Text.rich(
              TextSpan(
                text: text,
                children: [
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                ],
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
              ),
            ),
            const Spacer(),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      );
}

/// Badge kecil, misalnya kategori relasi atau status.
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.text, {
    super.key,
    this.color = AppColors.secondary,
    this.background = AppColors.primaryContainer,
    this.border = AppColors.primarySoftBorder,
    this.icon,
    this.dot,
    this.radius = 999,
    this.fontSize = 11,
  });
  final String text;
  final Color color;
  final Color background;
  final Color? border;
  final IconData? icon;
  final Color? dot;
  final double radius;
  final double fontSize;

  factory StatusBadge.category(String category) => switch (category) {
        'Klien' => StatusBadge(
            category,
            color: AppColors.successStrong,
            background: AppColors.successContainer,
            border: const Color(0xFFD1FAE5),
            radius: 6,
            fontSize: 10,
          ),
        'Prospek' => StatusBadge(
            category,
            color: AppColors.purple,
            background: AppColors.purpleContainer,
            border: AppColors.purpleBorder,
            radius: 6,
            fontSize: 10,
          ),
        'Teman Profesional' => StatusBadge(
            category,
            color: AppColors.textSecondary,
            background: AppColors.tonal,
            border: AppColors.outline,
            radius: 6,
            fontSize: 10,
          ),
        _ => StatusBadge(category, radius: 6, fontSize: 10),
      };

  /// Badge hijau dengan titik, misalnya "Kartu Digital Aktif".
  factory StatusBadge.live(String text) => StatusBadge(
        text,
        color: AppColors.successStrong,
        background: AppColors.successContainer,
        border: AppColors.successBorder,
        dot: AppColors.successDot,
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            if (icon != null) ...[
              Icon(icon, size: fontSize + 3, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

const _avatarGradients = [
  [Color(0xFF2563EB), Color(0xFF6366F1)],
  [Color(0xFF0EA5E9), Color(0xFF2563EB)],
  [Color(0xFF6366F1), Color(0xFF9333EA)],
  [Color(0xFF1E40AF), Color(0xFF3B82F6)],
];

/// Avatar bulat bergradien berisi inisial nama.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.status,
    this.square = false,
  });
  final String? name;
  final double size;

  /// Warna titik status di sudut kanan bawah, jika ada.
  final Color? status;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final colors = _avatarGradients[
        (name ?? '').codeUnits.fold<int>(0, (a, b) => a + b) %
            _avatarGradients.length];
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: colors,
        ),
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(size * 0.25) : null,
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
    if (status == null) return avatar;
    return StatusDot(color: status!, size: size * 0.27, child: avatar);
  }
}

/// Titik status berbingkai putih di sudut kanan bawah widget.
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.child,
    this.color = AppColors.successDot,
    this.size = 12,
  });
  final Widget child;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      );
}

/// Ikon dalam kotak bersudut membulat.
class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    this.size = 40,
    this.radius = 12,
    this.color = AppColors.secondary,
    this.background = AppColors.primaryContainer,
    this.border,
  });
  final IconData icon;
  final double size;
  final double radius;
  final Color color;
  final Color background;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Icon(icon, color: color, size: size * 0.52),
      );
}

/// Kotak catatan informasi berlatar biru muda.
class InfoNote extends StatelessWidget {
  const InfoNote(
    this.text, {
    super.key,
    this.icon = Icons.info_outline,
    this.title,
    this.boxed = false,
  });
  final String text;
  final IconData icon;
  final String? title;

  /// Tampilkan ikon di dalam kotak, seperti catatan keamanan.
  final bool boxed;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 4, bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primarySoftBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            boxed
                ? IconBox(
                    icon,
                    size: 32,
                    radius: 8,
                    color: AppColors.primary,
                    background: AppColors.primarySoftBorder,
                  )
                : Icon(icon, size: 18, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Warna untuk baris kontak dan tombol aksinya.
class Tint {
  const Tint(this.color, this.background, this.border);
  final Color color;
  final Color background;
  final Color border;

  static const blue = Tint(
    AppColors.secondary,
    AppColors.primaryContainer,
    AppColors.primarySoftBorder,
  );
  static const green = Tint(
    AppColors.success,
    AppColors.successContainer,
    Color(0xFFD1FAE5),
  );
  static const indigo = Tint(
    AppColors.indigo,
    AppColors.indigoContainer,
    AppColors.indigoBorder,
  );
}

/// Baris kontak: ikon, label kecil, nilai, dan tombol aksi di kanan.
class ContactRow extends StatelessWidget {
  const ContactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.action,
    this.actionIcon = Icons.arrow_forward,
    this.tint = Tint.blue,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final String action;
  final IconData actionIcon;
  final Tint tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            IconBox(
              icon,
              size: 44,
              color: tint.color,
              background: tint.background,
              border: tint.border,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tint.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tint.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tint.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(actionIcon, size: 14, color: tint.color),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Baris pengaturan dengan ikon berbingkai.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accent = true,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Ikon biru untuk pengaturan utama, abu-abu untuk menu info.
  final bool accent;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconBox(
                icon,
                size: 44,
                radius: 14,
                color: accent ? AppColors.secondary : AppColors.textBody,
                background:
                    accent ? AppColors.primaryContainer : AppColors.canvas,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
            ],
          ),
        ),
      );
}

/// Kelompok baris pengaturan dalam satu kartu.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(color: AppColors.outlineSoft),
              children[i],
            ],
          ],
        ),
      );
}

/// Lingkaran cahaya lembut di permukaan kartu bergradien.
class GlowSpot extends StatelessWidget {
  const GlowSpot({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.size = 220,
    this.color = const Color(0x1AFFFFFF),
  });
  final double? left, top, right, bottom;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      );
}

/// Kapsul semi-transparan di atas kartu bergradien.
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.dark = false,
    this.radius = 999,
  });
  final Widget child;
  final bool dark;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: dark
              ? Colors.black.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(radius),
          border: dark
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      );
}

/// Tombol kembali/batal berbentuk kapsul kecil.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Latar abu-abu tanpa garis (gaya "Batalkan").
  final bool filled;

  @override
  Widget build(BuildContext context) => Material(
        color: filled ? AppColors.tonal : Colors.white,
        shape: StadiumBorder(
          side: filled
              ? BorderSide.none
              : const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: filled ? AppColors.textSecondary : AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: filled ? FontWeight.w500 : FontWeight.w600,
                    color:
                        filled ? AppColors.textSecondary : AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Tombol aksi bawah berlatar biru muda, misalnya "Bagikan Pesan".
ButtonStyle tintedButton() => OutlinedButton.styleFrom(
      backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
      foregroundColor: AppColors.secondary,
      side: const BorderSide(color: AppColors.primaryBorder),
    );
