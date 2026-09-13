class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? studentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del estudiante es obligatorio';
    }
    return null;
  }

  static String? subject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La asignatura es obligatoria';
    }
    return null;
  }

  static String? grade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa la calificación';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingresa un número válido (ej. 4.5)';
    }
    if (parsed < 0 || parsed > 5) {
      return 'Debe estar entre 0.0 y 5.0';
    }
    return null;
  }
}
