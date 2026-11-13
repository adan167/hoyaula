String? requiredField(String? value, {String label = 'Campo'}) {
  if (value == null || value.trim().isEmpty) {
    return '$label es obligatorio.';
  }
  return null;
}
