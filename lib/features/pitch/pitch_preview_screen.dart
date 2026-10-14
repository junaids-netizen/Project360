import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_colors.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/brand/brand_picker_sheet.dart';
import 'package:project360/features/home/bank_shell.dart';
import 'package:project360/features/pitch/bank_url.dart';
import 'package:project360/features/pitch/brand_mark.dart';
import 'package:project360/features/pitch/site_brand_client.dart';
import 'package:project360/features/pitch/site_brand_extract.dart';

/// Loads a bank page and applies it to the active brand.
typedef SiteBrandLoader = Future<ExtractedSiteBrand> Function(Uri url);

/// Builds the logo widget for a pitch. Tests pass a stand-in; the app loads
/// the image from the site.
typedef PitchLogoBuilder = Widget Function(String url);

/// Paste a bank website, then watch the card and tokens take on its brand.
///
/// The URL field lives on this screen because the index launches it as the
/// pitch step, ahead of the Vera app. Colours go through [BrandScope], so the
/// rest of the pitch — brand studio, Vera, Capsule — follows the same tokens.
class PitchPreviewScreen extends StatefulWidget {
  const PitchPreviewScreen({super.key, this.load, this.logoBuilder});

  final SiteBrandLoader? load;
  final PitchLogoBuilder? logoBuilder;

  @override
  State<PitchPreviewScreen> createState() => _PitchPreviewScreenState();
}

enum _PitchStatus {
  idle,
  loading,
  extracted,
  invalid,
  unreachable,
  blocked,
  noColor,
  demo,
}

class _PitchPreviewScreenState extends State<PitchPreviewScreen> {
  final TextEditingController _url = TextEditingController();
  final SiteBrandClient _client = SiteBrandClient();

  _PitchStatus _status = _PitchStatus.idle;
  bool _busy = false;
  String? _host;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_busy) return;
    final uri = parseBankUrl(_url.text);
    if (uri == null) {
      setState(() => _status = _PitchStatus.invalid);
      return;
    }
    setState(() {
      _busy = true;
      _status = _PitchStatus.loading;
    });
    try {
      final extracted = await (widget.load ?? _client.load)(uri);
      if (!mounted) return;
      final brand = extracted.toBrand();
      if (brand == null) {
        setState(() {
          _busy = false;
          _status = _PitchStatus.noColor;
        });
        return;
      }
      BrandScope.read(context).select(brand);
      Haptics.selection();
      setState(() {
        _busy = false;
        _status = _PitchStatus.extracted;
        _host = extracted.host;
      });
    } on SiteBrandException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = error.issue == SiteBrandIssue.blocked
            ? _PitchStatus.blocked
            : _PitchStatus.unreachable;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = _PitchStatus.unreachable;
      });
    }
  }

  void _useDemo() {
    BrandScope.read(context).select(pitchDemoBrand);
    Haptics.selection();
    setState(() {
      _status = _PitchStatus.demo;
      _host = null;
    });
  }

  String _message(Brand brand) {
    return switch (_status) {
      _PitchStatus.loading => 'Reading website...',
      _PitchStatus.invalid => 'Enter an https website URL.',
      _PitchStatus.unreachable => 'Could not reach that site.',
      _PitchStatus.blocked => 'That site blocked the request.',
      _PitchStatus.noColor => 'Could not find a brand colour on that page.',
      _PitchStatus.demo => 'Using demo brand',
      _PitchStatus.extracted =>
        'Using extracted brand · ${_host ?? brand.sourceHost ?? ''}',
      _PitchStatus.idle
          when brand.id == Brand.websiteId && brand.sourceHost != null =>
        'Using extracted brand · ${brand.sourceHost}',
      _PitchStatus.idle when brand.id == pitchDemoBrand.id =>
        'Using demo brand',
      _PitchStatus.idle =>
        'Paste a bank website. Its colours and logo restyle this preview.',
    };
  }

  bool get _failed =>
      _status == _PitchStatus.unreachable ||
      _status == _PitchStatus.blocked ||
      _status == _PitchStatus.noColor;

  Color _messageColor(BrandColors colors) {
    return switch (_status) {
      _PitchStatus.invalid ||
      _PitchStatus.unreachable ||
      _PitchStatus.blocked ||
      _PitchStatus.noColor => colors.danger,
      _PitchStatus.extracted || _PitchStatus.demo => colors.success,
      _ => colors.textSecondary,
    };
  }

  Widget _logo(
    String url, {
    required String slot,
    required double width,
    required double height,
  }) {
    return SizedBox(
      key: ValueKey<String>('pitch-$slot:$url'),
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: (widget.logoBuilder ?? pitchNetworkLogo)(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;
    final logoUrl = brand.logoUrl;

    return Material(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            VeraToolbar(
              title: 'Pitch preview',
              showBack: Navigator.of(context).canPop(),
              onBack: () => Navigator.of(context).pop(),
              onInfo: () => showBrandPicker(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  Text('Bank website', style: context.type.h4),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('pitch-url'),
                    controller: _url,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    autocorrect: false,
                    enableSuggestions: false,
                    cursorColor: colors.accent,
                    style: context.type.h4,
                    decoration: InputDecoration(
                      hintText: 'https://www.bank.com',
                      hintStyle: context.type.p1.copyWith(
                        color: colors.textTertiary,
                      ),
                      filled: true,
                      fillColor: colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VeraRadii.card),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VeraRadii.card),
                        borderSide: BorderSide(
                          color: colors.accent,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VeraRadii.card),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                    onSubmitted: (_) => _apply(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_status == _PitchStatus.loading) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          _message(brand),
                          key: const Key('pitch-status'),
                          style: context.type.p1.copyWith(
                            color: _messageColor(colors),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_failed) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      key: const Key('pitch-demo'),
                      onTap: _useDemo,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Use demo brand',
                        style: context.type.h4.copyWith(color: colors.accent),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  VeraPrimaryButton(
                    label: 'Apply',
                    onTap: _busy ? null : () => _apply(),
                  ),
                  const SizedBox(height: 28),
                  if (logoUrl != null && logoUrl.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.white,
                            borderRadius: BorderRadius.circular(VeraRadii.card),
                            border: Border.all(color: colors.border),
                          ),
                          child: _logo(
                            logoUrl,
                            slot: 'header',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(brand.name, style: context.type.h3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Preview', style: context.type.h4),
                  const SizedBox(height: 8),
                  VeraCardFace(
                    logo: logoUrl == null || logoUrl.isEmpty
                        ? null
                        : _logo(logoUrl, slot: 'card', width: 44, height: 22),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _TokenSwatch(label: 'Primary', color: colors.accent),
                      const SizedBox(width: 8),
                      _TokenSwatch(
                        label: 'Background',
                        color: colors.background,
                      ),
                      const SizedBox(width: 8),
                      _TokenSwatch(label: 'Text', color: colors.textPrimary),
                      const SizedBox(width: 8),
                      _TokenSwatch(
                        label: 'Accent',
                        color: colors.accentSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: Haptics.wrap(() {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const BankApp(),
                          ),
                        );
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Open in Vera app',
                        style: context.type.h4.copyWith(color: colors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenSwatch extends StatelessWidget {
  const _TokenSwatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(VeraRadii.card),
              border: Border.all(color: context.brand.border),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: context.type.p2),
        ],
      ),
    );
  }
}
