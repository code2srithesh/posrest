import '../database/database_helper.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<String> createPayment(PaymentModel payment) async {
    await _dbHelper.insertPayment(payment);
    return payment.id;
  }

  Future<List<PaymentModel>> getPaymentsByOrderId(String orderId) {
    return _dbHelper.getPaymentsByOrderId(orderId);
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _dbHelper.updatePayment(payment);
  }

  Future<List<PaymentModel>> getAllPayments() {
    return _dbHelper.getAllPayments();
  }

  Future<double> getOrderTotalPayments(String orderId) async {
    final payments = await getPaymentsByOrderId(orderId);
    double total = 0;
    for (final payment in payments) {
      if (payment.status == 'completed') {
        total += payment.amount;
      }
    }
    return total;
  }

  Future<Map<String, double>> getPaymentMethodSummary(DateTime date) async {
    final allOrders = await _dbHelper.getAllOrders();
    final dailyOrders = allOrders.where((o) {
      return o.createdAt.year == date.year &&
          o.createdAt.month == date.month &&
          o.createdAt.day == date.day;
    }).toList();

    final summary = <String, double>{};

    for (final order in dailyOrders) {
      final payments = await getPaymentsByOrderId(order.id);
      for (final payment in payments) {
        if (payment.status == 'completed') {
          summary[payment.paymentMethod] =
              (summary[payment.paymentMethod] ?? 0) + payment.amount;
        }
      }
    }

    return summary;
  }
}
