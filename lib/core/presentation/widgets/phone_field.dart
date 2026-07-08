import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ── Dial-code data ────────────────────────────────────────────────────────────

class _DialCode {
  const _DialCode(this.flag, this.dialCode, this.country);
  final String flag;
  final String dialCode;
  final String country;
}

const List<_DialCode> _kDialCodes = [
  // ── Most common ──────────────────────────────────────────────────────
  _DialCode('🇹🇳', '+216', 'Tunisie'),
  _DialCode('🇫🇷', '+33',  'France'),
  _DialCode('🇩🇿', '+213', 'Algérie'),
  _DialCode('🇲🇦', '+212', 'Maroc'),
  _DialCode('🇧🇪', '+32',  'Belgique'),
  _DialCode('🇨🇭', '+41',  'Suisse'),
  _DialCode('🇱🇺', '+352', 'Luxembourg'),
  // ── Europe ───────────────────────────────────────────────────────────
  _DialCode('🇬🇧', '+44',  'Royaume-Uni'),
  _DialCode('🇩🇪', '+49',  'Allemagne'),
  _DialCode('🇪🇸', '+34',  'Espagne'),
  _DialCode('🇮🇹', '+39',  'Italie'),
  _DialCode('🇳🇱', '+31',  'Pays-Bas'),
  _DialCode('🇵🇹', '+351', 'Portugal'),
  _DialCode('🇬🇷', '+30',  'Grèce'),
  _DialCode('🇦🇹', '+43',  'Autriche'),
  _DialCode('🇸🇪', '+46',  'Suède'),
  _DialCode('🇳🇴', '+47',  'Norvège'),
  _DialCode('🇩🇰', '+45',  'Danemark'),
  _DialCode('🇫🇮', '+358', 'Finlande'),
  _DialCode('🇵🇱', '+48',  'Pologne'),
  // ── Afrique ──────────────────────────────────────────────────────────
  _DialCode('🇱🇾', '+218', 'Libye'),
  _DialCode('🇪🇬', '+20',  'Égypte'),
  _DialCode('🇸🇳', '+221', 'Sénégal'),
  _DialCode('🇨🇮', '+225', "Côte d'Ivoire"),
  _DialCode('🇨🇲', '+237', 'Cameroun'),
  _DialCode('🇨🇩', '+243', 'Congo (RDC)'),
  _DialCode('🇳🇬', '+234', 'Nigéria'),
  // ── Moyen-Orient ─────────────────────────────────────────────────────
  _DialCode('🇸🇦', '+966', 'Arabie Saoudite'),
  _DialCode('🇦🇪', '+971', 'Émirats Arabes Unis'),
  _DialCode('🇶🇦', '+974', 'Qatar'),
  _DialCode('🇰🇼', '+965', 'Koweït'),
  _DialCode('🇯🇴', '+962', 'Jordanie'),
  _DialCode('🇱🇧', '+961', 'Liban'),
  // ── Amériques ────────────────────────────────────────────────────────
  _DialCode('🇺🇸', '+1',   'États-Unis / Canada'),
  _DialCode('🇧🇷', '+55',  'Brésil'),
  _DialCode('🇲🇽', '+52',  'Mexique'),
  // ── Asie / Océanie ───────────────────────────────────────────────────
  _DialCode('🇨🇳', '+86',  'Chine'),
  _DialCode('🇯🇵', '+81',  'Japon'),
  _DialCode('🇰🇷', '+82',  'Corée du Sud'),
  _DialCode('🇮🇳', '+91',  'Inde'),
  _DialCode('🇦🇺', '+61',  'Australie'),
];

// ── Main widget ───────────────────────────────────────────────────────────────

/// Phone field = dial-code button + national number input.
/// Access [fullNumber] (e.g. "+216 12 345 678") or use [onChanged].
class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.label,
    this.onChanged,
    this.validator,
    this.initialDialCode = '+216',
    this.initialNationalNumber,
  });

  final String label;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String initialDialCode;
  final String? initialNationalNumber;

  @override
  State<PhoneField> createState() => PhoneFieldState();
}

class PhoneFieldState extends State<PhoneField> {
  late _DialCode _selected;
  final TextEditingController _numberCtrl = TextEditingController();

  String get fullNumber {
    final num = _numberCtrl.text.trim();
    return num.isEmpty ? '' : '${_selected.dialCode} $num';
  }

  @override
  void initState() {
    super.initState();
    _selected = _kDialCodes.firstWhere(
      (d) => d.dialCode == widget.initialDialCode,
      orElse: () => _kDialCodes.first,
    );
    if (widget.initialNationalNumber != null &&
        widget.initialNationalNumber!.isNotEmpty) {
      _numberCtrl.text = widget.initialNationalNumber!;
    }
    _numberCtrl.addListener(_notify);
  }

  void _notify() => widget.onChanged?.call(fullNumber);

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPicker(BuildContext context) async {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final picked  = await showModalBottomSheet<_DialCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DialCodeSheet(isDark: isDark, current: _selected),
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final textColor  = isDark ? AppColors.darkBodyPrimary  : AppColors.lightBodyPrimary;
    final hintColor  = isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final surfColor  = isDark ? AppColors.darkSurface       : AppColors.lightSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor, fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dial-code button ─────────────────────────────────────
            _DialCodeButton(
              selected: _selected,
              surfColor: surfColor,
              textColor: textColor,
              hintColor: hintColor,
              onTap: () => _openPicker(context),
            ),
            const SizedBox(width: 10),
            // ── Number input ─────────────────────────────────────────
            Expanded(
              child: TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyLarge.copyWith(color: textColor),
                validator: widget.validator,
                decoration: InputDecoration(
                  hintText: '12 345 678',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: hintColor),
                  filled: true,
                  fillColor: surfColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Dial-code button ──────────────────────────────────────────────────────────

class _DialCodeButton extends StatelessWidget {
  const _DialCodeButton({
    required this.selected,
    required this.surfColor,
    required this.textColor,
    required this.hintColor,
    required this.onTap,
  });

  final _DialCode    selected;
  final Color        surfColor;
  final Color        textColor;
  final Color        hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        constraints: const BoxConstraints(minWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: surfColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag
            Text(selected.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            // Dial code
            Text(
              selected.dialCode,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: hintColor, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Bottom-sheet picker ───────────────────────────────────────────────────────

class _DialCodeSheet extends StatefulWidget {
  const _DialCodeSheet({required this.isDark, required this.current});

  final bool      isDark;
  final _DialCode current;

  @override
  State<_DialCodeSheet> createState() => _DialCodeSheetState();
}

class _DialCodeSheetState extends State<_DialCodeSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_DialCode> get _filtered {
    if (_query.isEmpty) return _kDialCodes;
    final q = _query.toLowerCase();
    return _kDialCodes.where((d) =>
      d.country.toLowerCase().contains(q) || d.dialCode.contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg     = isDark ? const Color(0xFF131313) : Colors.white;
    final surf   = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5);
    final text   = isDark ? AppColors.darkBodyPrimary  : AppColors.lightBodyPrimary;
    final hint   = isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final border = isDark ? const Color(0xFF2A2A3E)    : const Color(0xFFE5E5E5);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 120 : 40),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Handle ───────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 14, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: hint.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choisir le pays',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: text,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: surf, borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close, size: 18, color: hint),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: hint, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.bodyMedium.copyWith(color: text),
                        decoration: InputDecoration(
                          hintText: 'Pays ou indicatif…',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: hint),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.close_rounded, size: 18, color: hint),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Divider ───────────────────────────────────────────────
            Divider(height: 1, color: border),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: hint),
                        const SizedBox(height: 12),
                        Text('Aucun résultat',
                            style: AppTextStyles.bodyMedium.copyWith(color: hint)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: ctrl,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final dc        = _filtered[i];
                      final isCurrent = dc.dialCode == widget.current.dialCode;
                      return _DialCodeTile(
                        dc:        dc,
                        isCurrent: isCurrent,
                        text:      text,
                        hint:      hint,
                        surf:      surf,
                        onTap:     () => Navigator.pop(context, dc),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────────

class _DialCodeTile extends StatelessWidget {
  const _DialCodeTile({
    required this.dc,
    required this.isCurrent,
    required this.text,
    required this.hint,
    required this.surf,
    required this.onTap,
  });

  final _DialCode    dc;
  final bool         isCurrent;
  final Color        text;
  final Color        hint;
  final Color        surf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withAlpha(20),
      highlightColor: AppColors.primary.withAlpha(12),
      child: Container(
        color: isCurrent ? AppColors.primary.withAlpha(15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            // Flag in a subtle container
            Container(
              width: 44, height: 36,
              decoration: BoxDecoration(
                color: surf, borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(dc.flag, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            // Country name
            Expanded(
              child: Text(
                dc.country,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppColors.primary : text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Dial code chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withAlpha(20)
                    : surf,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dc.dialCode,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? AppColors.primary : hint,
                ),
              ),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
