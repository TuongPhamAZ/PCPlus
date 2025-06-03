import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';
import 'package:pcplus/models/vouchers/voucher_repo.dart';
import 'package:pcplus/pages/voucher/addvoucher/add_voucher_contract.dart';

class AddVoucherPresenter {
  AddVoucherContract contract;

  AddVoucherPresenter(this.contract);

  final VoucherRepository _voucherRepo = VoucherRepository();

  Future<void> handleAddVoucher({
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
        contract.onAddFailed("Vui lòng nhập tên voucher");
        return;
      }

      if (description.isEmpty) {
        contract.onAddFailed("Vui lòng nhập mô tả voucher");
        return;
      }

      if (condition <= 0) {
        contract.onAddFailed("Điều kiện áp dụng phải lớn hơn 0");
        return;
      }

      if (discount <= 0) {
        contract.onAddFailed("Số tiền giảm giá phải lớn hơn 0");
        return;
      }

      if (quantity <= 0) {
        contract.onAddFailed("Số lượng voucher phải lớn hơn 0");
        return;
      }

      if (endDate.isBefore(DateTime.now())) {
        contract.onAddFailed("Ngày kết thúc phải sau ngày hiện tại");
        return;
      }

      // Create voucher model
      // ignore: unused_local_variable
      VoucherModel voucher = VoucherModel(
        name: name,
        description: description,
        condition: condition,
        endDate: endDate,
        discount: discount,
        quantity: quantity,
      );

      // TODO: Implement save voucher to database
      await _voucherRepo.addVoucherToFirestore(SessionController.getInstance().userID!, voucher);

      contract.onPopContext();
      contract.onAddSucceeded();
    } catch (e) {
      contract.onPopContext();
      contract.onAddFailed("Có lỗi xảy ra: ${e.toString()}");
    }
  }
}
