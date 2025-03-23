import 'dart:ffi';
import 'dart:math';

class RandomTool {
  String generateRandomText(int length, bool upperCase) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();

    String text = List.generate(
      length,
          (_) => characters[random.nextInt(characters.length)],
    ).join();

    return upperCase ? text : text.toLowerCase();
  }

  String generateRandomNumberString(int length) {
    final random = Random();
    // Tạo một chuỗi số ngẫu nhiên độ dài `length`
    return List.generate(length, (_) => random.nextInt(10).toString()).join();
  }

  String generateRandomString(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();

    return List.generate(
      length,
          (_) => characters[random.nextInt(characters.length)],
    ).join();
  }

  DateTime generateRandomDate(DateTime startDate, DateTime endDate) {
    final random = Random();

    // Tính khoảng cách ngày giữa startDate và endDate
    int differenceInDays = endDate.difference(startDate).inDays;

    // Tạo số ngày ngẫu nhiên từ 0 đến differenceInDays
    int randomDays = random.nextInt(differenceInDays + 1);

    // Trả về ngày ngẫu nhiên bằng cách cộng randomDays vào startDate
    return startDate.add(Duration(days: randomDays));
  }

  int generateRandomNumber(int min, int max) {
    final random = Random();

    // Tạo giá trị baseValue ngẫu nhiên trong khoảng [min, max]
    return random.nextInt(max - min + 1) + min;
  }

  

  int generateRandomPrice(int min, int max, int maxMultiplierPower) {
    final random = Random();

    // Tạo giá trị baseValue ngẫu nhiên trong khoảng [min, max]
    int baseValue = random.nextInt(max - min + 1) + min;

    // Tạo bội số ngẫu nhiên theo lũy thừa của 10 từ 10^0 tới 10^maxMultiplierPower
    int multiplier = pow(10, random.nextInt(maxMultiplierPower + 1)).toInt();

    // Tính giá tiền cuối cùng
    return baseValue * multiplier;
  }

  String generateRandomPhoneNumber() {
    final random = Random();

    // Tạo một số điện thoại ngẫu nhiên bắt đầu bằng 0
    String phoneNumber = '0';

    // Tạo 9 chữ số còn lại
    phoneNumber += List.generate(9, (_) => random.nextInt(10).toString()).join();

    return phoneNumber;
  }

  String generateRandomEmail() {
    final random = Random();

    // Tạo một email ngẫu nhiên
    String email = generateRandomText(10, false);

    // Thêm ký tự '@'
    email += '@';

    // Thêm domain ngẫu nhiên
    email += generateRandomText(5, false);

    // Thêm phần mở rộng ngẫu nhiên
    email += ['.com', '.net', '.org'][random.nextInt(3)];

    return email;
  }

  String generateRandomAddress() {
    final random = Random();

    // Tạo một địa chỉ ngẫu nhiên
    String address = generateRandomText(10, false);

    // Thêm số nhà ngẫu nhiên
    address += ' ' + random.nextInt(100).toString();

    // Thêm tên đường ngẫu nhiên
    address += ' ' + generateRandomText(5, false);

    return address;
  }


}