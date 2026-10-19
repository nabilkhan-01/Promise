/// Privacy note for Promise Flutter app:
///
/// Automatic background clipboard reads are eliminated directly at the widget source
/// in [PromiseVerificationCodeInput] by passing `onClipboardFound: null` to Pinput.
///
/// User-initiated clipboard access (e.g. tapping "Paste Code from Clipboard") is executed
/// explicitly upon direct user tap events.
abstract class ClipboardPrivacyGuard {}
