import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class VeraAssets {
  static const String logo = 'assets/images/logo.svg';
  static const String mastercard = 'assets/images/mastercard.svg';
  static const String frozenBadge = 'assets/images/icon_frozen_badge.svg';
  static const String copy = 'assets/images/icon_copy.svg';
  static const String settings = 'assets/images/icon_settings.svg';
  static const String eye = 'assets/images/icon_eye.svg';
  static const String chevron = 'assets/images/icon_chevron.svg';
  static const String chevronSmall = 'assets/images/chevron_small.svg';
  static const String purchase = 'assets/images/icon_purchase.svg';
  static const String repayment = 'assets/images/icon_repayment.svg';
  static const String refund = 'assets/images/icon_refund.svg';
  static const String statements = 'assets/images/icon_statements.svg';
  static const String inbox = 'assets/images/icon_inbox.svg';
  static const String rewardsSparkle = 'assets/images/rewards_sparkle.svg';
  static const String rewardsHero = 'assets/images/rewards_hero.svg';
  static const String rewardsProgramWatermark =
      'assets/images/rewards_program_watermark.svg';
  static const String rewardsEarned = 'assets/images/rewards_earned.svg';
  static const String rewardsRedeemed = 'assets/images/rewards_redeemed.svg';
  static const String diamond = 'assets/images/diamond.svg';
  static const String tabRewards = 'assets/images/tab_rewards.svg';
  static const String tabAccount = 'assets/images/tab_account.svg';
  static const String back = 'assets/images/icon_back.svg';
  static const String info = 'assets/images/icon_info.svg';
  static const String freeze = 'assets/images/icon_freeze.svg';
  static const String toggle = 'assets/images/icon_toggle.svg';
  static const String wallet = 'assets/images/icon_wallet.svg';
  static const String replace = 'assets/images/icon_replace.svg';
  static const String key = 'assets/images/icon_key.svg';
  static const String squareInfo = 'assets/images/icon_square_info.svg';
  static const String person = 'assets/images/icon_person.svg';
  static const String lock = 'assets/images/icon_lock.svg';
  static const String bell = 'assets/images/icon_bell.svg';
  static const String folder = 'assets/images/icon_folder.svg';
  static const String phone = 'assets/images/icon_phone.svg';
  static const String logout = 'assets/images/icon_logout.svg';
  static const String minus = 'assets/images/icon_minus.svg';
  static const String plus = 'assets/images/icon_plus.svg';
  static const String checkCircle = 'assets/images/icon_check_circle.svg';
  static const String zeta = 'assets/images/zeta_powered.svg';
}

class VeraSvg extends StatelessWidget {
  const VeraSvg(
    this.asset, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
  });

  final String asset;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size ?? 24;
    final h = height ?? size ?? 24;
    return SizedBox(
      width: w,
      height: h,
      child: SvgPicture.asset(
        asset,
        width: w,
        height: h,
        fit: BoxFit.contain,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}
