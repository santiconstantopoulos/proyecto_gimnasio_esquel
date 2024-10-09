class AppStrings {
  // TODO organizar correctamente todos los textos

  // Login
  static const String confirmLogoutTitle = '¿Estás seguro?';
  static const String confirmLogoutMessage = '¿Deseas cerrar sesión?';
  static const String logoutMessage = 'Cerrar sesión';

  // Reservas
  static const String reservationCreated = 'Reserva creada exitosamente.';
  static const String errorReservation = 'Error al crear la reserva: ';

  static const String reservaConfirmada =
      'Reserva confirmada y crédito consumido';
  static const String errorCreditsReservation =
      'No tienes créditos suficientes para confirmar la reserva.';
  static const String errorAlConfirmar = 'Error al confirmar la reserva: ';

  static const String reservaCancelada = 'Reserva cancelada';
  static const String reservaCanceladaConRetorno =
      'Reserva cancelada y créditos devueltos';
  static const String errorAlCancelar = 'Error al cancelar la reserva:';
  static const String notCancelReservation30 =
      'No se puede cancelar la reserva, faltan menos de 30 minutos';
  static const String notCancelReservationOutDate =
      'No se puede cancelar la reserva, ya pasó la fecha';
  static const String notCancel = 'No se puede cancelar la reserva';

  static const String reservaEliminada = 'Reserva eliminada';
  static const String errorAlEliminar = 'Error al eliminar la reserva: ';
  static const String reservaEliminadaConRetorno =
      'Reserva eliminada y créditos devueltos';
  static const String notDeleteReservation30 =
      'No se puede eliminar la reserva, faltan menos de 30 minutos';
  static const String notDeleteReservationOutDate =
      'No se puede cancelar la reserva, ya pasó la fecha';

  // Beneficios
  static const String newBenefitNotificationTitle = 'Nuevo beneficio';
  static const String newBenefitNotificationBody = '20% off en proteínas';
  static const String beneficios = 'Beneficios';

  // Otros
  static const String confirm = 'confirm';
  static const String reservas = 'Reservas';
  static const String delete = 'delete';
  static const String cancel = 'cancel';

  static const String welcomeMessage = 'Bienvenido a Gym App!';
  static const String loginMessage = 'Por favor inicie sesión!';
}
