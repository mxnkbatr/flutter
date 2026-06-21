/// App-wide feature toggles. Flip flags when rolling out new capabilities.
class FeatureFlags {
  FeatureFlags._();

  /// Premium subscriptions, tier gating, and purchase UI.
  /// Enable in a future release.
  static const premiumSubscriptionsEnabled = false;
}
