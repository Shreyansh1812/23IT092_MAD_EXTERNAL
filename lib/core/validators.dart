class Validators {
  static String? requiredString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? requiredAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount greater than zero';
    }
    return null;
  }

  static String? validateDates(DateTime? start, DateTime? end) {
    if (start != null && end != null && end.isBefore(start)) {
      return 'End date cannot be before start date';
    }
    return null;
  }

  static String? validateParticipants(List<String> participants) {
    if (participants.isEmpty) {
      return 'At least one participant is required';
    }
    return null;
  }
}
