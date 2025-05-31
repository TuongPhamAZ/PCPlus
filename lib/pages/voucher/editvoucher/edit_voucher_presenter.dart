import 'package:pcplus/pages/voucher/editvoucher/edit_voucher_contract.dart';

class EditVoucherPresenter {
  EditVoucherContract contract;
  String? voucherId;

  EditVoucherPresenter(this.contract);

  Future<void> handleEditVoucher({
    required String name,
    required String description,
    required int condition,
    required DateTime endDate,
    required int discount,
    required int quantity,
  }) async {
    try {
      contract.onWaitingProgressBar();

      // Validate input
      if (name.isEmpty) {
        contract.onPopContext();
        contract.onEditFailed("Vui lòng nhập tên voucher");
        return;
      }

      if (description.isEmpty) {
        contract.onPopContext();
        contract.onEditFailed("Vui lòng nhập mô tả voucher");
        return;
      }

      if (condition <= 0) {
        contract.onPopContext();
        contract.onEditFailed("Điều kiện áp dụng phải lớn hơn 0");
        return;
      }

      if (discount <= 0) {
        contract.onPopContext();
        contract.onEditFailed("Số tiền giảm giá phải lớn hơn 0");
        return;
      }

      if (quantity <= 0) {
        contract.onPopContext();
        contract.onEditFailed("Số lượng voucher phải lớn hơn 0");
        return;
      }

      if (endDate.isBefore(DateTime.now())) {
        contract.onPopContext();
        contract.onEditFailed("Ngày kết thúc phải sau ngày hiện tại");
        return;
      }

      // Mock update - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      contract.onPopContext();
      contract.onEditSucceeded();
    } catch (e) {
      contract.onPopContext();
      contract.onEditFailed("Có lỗi xảy ra: ${e.toString()}");
    }
  }
}
