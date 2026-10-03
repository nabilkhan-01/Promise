class DisposableEmailValidator {
  static final Set<String> _disposableDomains = {
    'mailinator.com',
    'tempmail.com',
    'temp-mail.org',
    '10minutemail.com',
    'guerrillamail.com',
    'sharklasers.com',
    'getnada.com',
    'dispostable.com',
    'yopmail.com',
    'trashmail.com',
    'throwawaymail.com',
    'maildrop.cc',
    'crazymailing.com',
    'fakeinbox.com',
    'generator.email',
    'mohmal.com',
    'tempail.com',
    'burnermail.io',
    'inboxkitten.com',
    'mytemp.email',
    'disposablemail.com',
    'tmpmail.net',
    'tmpmail.org',
    'mailnesia.com',
    'mailcatch.com',
    'disposable.com',
    'guerrillamailblock.com',
  };

  /// Normalizes and validates an email address.
  /// Throws [ArgumentError] if invalid or if domain is disposable.
  static String validateAndNormalize(String? email) {
    if (email == null) {
      throw ArgumentError('Email address is required.');
    }

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError('Email address cannot be empty.');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(normalized)) {
      throw ArgumentError('Please enter a valid email address.');
    }

    final parts = normalized.split('@');
    if (parts.length != 2) {
      throw ArgumentError('Please enter a valid email address.');
    }

    final domain = parts[1];
    if (_disposableDomains.contains(domain)) {
      throw ArgumentError(
        'This email provider is not supported. Please use a permanent email address.',
      );
    }

    return normalized;
  }

  /// Checks whether an email's domain is disposable.
  static bool isDisposableDomain(String email) {
    final normalized = email.trim().toLowerCase();
    final parts = normalized.split('@');
    if (parts.length != 2) return false;
    return _disposableDomains.contains(parts[1]);
  }
}
