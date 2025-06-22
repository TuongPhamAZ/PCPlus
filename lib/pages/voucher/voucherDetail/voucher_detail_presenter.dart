import 'package:pcplus/pages/voucher/voucherDetail/voucher_detail_contract.dart';

class VoucherDetailPresenter {
  VoucherDetailContract contract;

  VoucherDetailPresenter(this.contract);

  bool _isDisposed = false;

  // Data được load trực tiếp từ VoucherArgument
  // Có thể thêm các methods khác nếu cần thiết trong tương lai

  Future<void> dispose() async {
    _isDisposed = true;
    // Cleanup any resources if needed in future
  }
}
