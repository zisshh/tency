import SwiftUI

/// A one-shot ripple that expands and fades behind a view each time `trigger`
/// changes. Driven by `keyframeAnimator`, so every change replays the animation.
/// Drawn in the background and non-interactive, so it never affects layout or taps.
struct TapRipple<Trigger: Equatable & Sendable>: ViewModifier {
  let trigger: Trigger
  var color: Color

  private struct Ripple: Equatable {
    var scale: CGFloat = 0.2
    var opacity: Double = 0
  }

  func body(content: Content) -> some View {
    content.background {
      Circle()
        .stroke(color, lineWidth: 2)
        .keyframeAnimator(initialValue: Ripple(), trigger: trigger) { view, value in
          view.scaleEffect(value.scale).opacity(value.opacity)
        } keyframes: { _ in
          KeyframeTrack(\.scale) {
            LinearKeyframe(0.4, duration: 0.01)
            SpringKeyframe(2.4, duration: 0.45)
          }
          KeyframeTrack(\.opacity) {
            LinearKeyframe(0.55, duration: 0.01)
            LinearKeyframe(0, duration: 0.45)
          }
        }
        .allowsHitTesting(false)
    }
  }
}

extension View {
  /// Emits an expanding ring in `color` whenever `trigger` changes value.
  func tapRipple<Trigger: Equatable & Sendable>(trigger: Trigger, color: Color) -> some View {
    modifier(TapRipple(trigger: trigger, color: color))
  }
}
